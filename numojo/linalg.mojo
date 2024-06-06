# ===----------------------------------------------------------------------=== #
# Copyright (c) 2024, Timothy H. Keitt. All rights reserved.
#
# Licensed under the Apache License v2.0 with LLVM Exceptions:
# https://llvm.org/LICENSE.txt
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ===----------------------------------------------------------------------=== #

# Some very basic utilities for learning and to support modeling. I am keeping the
# code as simple as possible. Return values are 100% value semantics. This may
# facilitate inlining and elmination of temproaries at compile time.


@value
@register_passable("trivial")
struct Mat[rows: Int, cols: Int](Sized):
    alias element_type = Float64
    alias storage_size = rows * cols
    var elements: Pointer[Self.element_type]

    @always_inline
    fn __init__(inout self):
        constrained[
            self.storage_size > 0, "Matrix size must be greater than zero."
        ]()
        self.elements = stack_allocation[self.storage_size, self.element_type]()

    @always_inline
    fn __init__(inout self, fill: self.element_type):
        constrained[
            self.storage_size > 0, "Matrix size must be greater than zero."
        ]()
        self.elements = stack_allocation[self.storage_size, self.element_type]()

        @parameter
        for i in range(self.storage_size):
            self.elements[i] = fill

    # TODO: Bounds checking, intable, etc.
    @always_inline
    fn __getitem__(self, index: Int) raises -> self.element_type:
        if index < 0 or index > self.storage_size:
            raise Error("Index out of bounds")
        return self.elements[index]

    # TODO: Bounds checking, intable, etc.
    @always_inline
    fn __setitem__(inout self, index: Int, value: self.element_type) raises:
        if index < 0 or index > self.storage_size:
            raise Error("Index out of bounds")
        self.elements[index] = value

    # TODO: Bounds checking, intable, etc.
    @always_inline
    fn __getitem__(self, row: Int, col: Int) raises -> self.element_type:
        if row < 0 or row > rows or col < 0 or col > cols:
            raise Error("Index out of bounds")
        return self.elements[col * rows + row]

    # TODO: Bounds checking, intable, etc.
    @always_inline
    fn __setitem__(
        inout self, row: Int, col: Int, value: self.element_type
    ) raises:
        if row < 0 or row > rows or col < 0 or col > cols:
            raise Error("Index out of bounds")
        self.elements[col * rows + row] = value

    @always_inline
    fn get_col(self, col: Int) raises -> ColVec[rows]:
        if col < 0 or col > cols:
            raise Error("Index out of bounds")
        var res = ColVec[rows]()

        @parameter
        for i in range(rows):
            res.elements[i] = self.elements[self.index(i, col)]

        return res

    @always_inline
    fn get_row(self, row: Int) raises -> RowVec[cols]:
        if row < 0 or row > rows:
            raise Error("Index out of bounds")
        var res = RowVec[cols]()

        @parameter
        for i in range(cols):
            res.elements[i] = self.elements[i * cols + row]

        return res

    @always_inline
    fn __len__(self) -> Int:
        return self.storage_size

    @always_inline
    fn __add__(self, other: Self) -> Self:
        var res = Self()

        @parameter
        for i in range(self.storage_size):
            res.elements[i] = self.elements[i] + other.elements[i]

        return res

    @always_inline
    fn __sub__(self, other: Self) -> Self:
        var res = Self()

        @parameter
        for i in range(self.storage_size):
            res.elements[i] = self.elements[i] - other.elements[i]

        return res

    @always_inline
    fn __mul__(self, other: Self) -> Self:
        var res = Self()

        @parameter
        for i in range(self.storage_size):
            res.elements[i] = self.elements[i] * other.elements[i]

        return res

    @always_inline
    fn index(self, row: Int, col: Int) -> Int:
        return col * rows + row

    @always_inline
    fn __matmul__(self, other: Mat) -> Mat[rows, other.cols]:
        constrained[cols == other.rows, "Incompatible dimensions"]()
        var res = Mat[rows, other.cols](0)

        @parameter
        for i in range(rows):  # == res.rows

            @parameter
            for j in range(other.cols):  # == res.cols

                @parameter
                for k in range(cols):  # == other.rows
                    res.elements[res.index(i, j)] += (
                        self.elements[self.index(i, k)]
                        * other.elements[other.index(k, j)]
                    )

        return res

    @always_inline
    fn __truediv__(self, other: Self) -> Self:
        var res = Self()

        @parameter
        for i in range(self.storage_size):
            res.elements[i] = self.elements[i] / other.elements[i]

        return res

    @always_inline
    fn __add__(self, other: self.element_type) -> Self:
        var res = Self()

        @parameter
        for i in range(self.storage_size):
            res.elements[i] = self.elements[i] + other

        return res

    @always_inline
    fn __sub__(self, other: self.element_type) -> Self:
        var res = Self()

        @parameter
        for i in range(self.storage_size):
            res.elements[i] = self.elements[i] - other

        return res

    @always_inline
    fn __mul__(self, other: self.element_type) -> Self:
        var res = Self()

        @parameter
        for i in range(self.storage_size):
            res.elements[i] = self.elements[i] * other

        return res

    @always_inline
    fn __truediv__(self, other: self.element_type) -> Self:
        var res = Self()

        @parameter
        for i in range(self.storage_size):
            res.elements[i] = self.elements[i] / other

        return res

    @always_inline
    fn __radd__(self, other: self.element_type) -> Self:
        var res = Self()

        @parameter
        for i in range(self.storage_size):
            res.elements[i] = self.elements[i] + other

        return res

    @always_inline
    fn __rsub__(self, other: self.element_type) -> Self:
        var res = Self()

        @parameter
        for i in range(self.storage_size):
            res.elements[i] = other - self.elements[i]

        return res

    @always_inline
    fn __rmul__(self, other: self.element_type) -> Self:
        var res = Self()

        @parameter
        for i in range(self.storage_size):
            res.elements[i] = self.elements[i] * other

        return res

    @always_inline
    fn __rtruediv__(self, other: self.element_type) -> Self:
        var res = Self()

        @parameter
        for i in range(self.storage_size):
            res.elements[i] = other / self.elements[i]

        return res

    @always_inline
    fn transpose(self) -> Mat[cols, rows]:
        var res = Mat[cols, rows]()

        @parameter
        for i in range(rows):

            @parameter
            for j in range(cols):
                res.elements[res.index(j, i)] = self.elements[self.index(i, j)]

        return res


alias RowVec = Mat[1, _]
alias ColVec = Mat[_, 1]


# fn main() raises:
#     var x = Mat[3, 1](2)
#     var y = Mat[3, 1](3)
#     var z = y.transpose() @ x
#     print(z[0])
