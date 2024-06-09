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


from utils import StaticTuple
from math import isclose


@value
@register_passable("trivial")
struct StaticMat[rows: Int, cols: Int](Sized):
    """A fixed-size small-matrix type."""

    alias element_type = Float64
    alias storage_size = rows * cols
    alias storage_type = StaticTuple[Self.element_type, Self.storage_size]
    var elements: Self.storage_type

    @always_inline
    fn __init__(inout self):
        constrained[
            self.storage_size > 0, "Matrix size must be greater than zero."
        ]()
        self.elements = self.storage_type()

    @always_inline
    fn __init__(inout self, fill: self.element_type):
        constrained[
            self.storage_size > 0, "Matrix size must be greater than zero."
        ]()
        self.elements = self.storage_type()
        self.fill(fill)

    @always_inline
    fn __init__(inout self, generator: fn () -> Self.element_type):
        constrained[
            self.storage_size > 0, "Matrix size must be greater than zero."
        ]()
        self.elements = self.storage_type()
        self.fill(generator)

    @always_inline
    fn __init__(inout self, *elems: Self.element_type):
        self.elements = self.storage_type(elems)

    @always_inline
    fn __init__(inout self, values: VariadicList[Self.element_type]):
        self.elements = self.storage_type(values)

    @always_inline
    fn fill(inout self, value: Self.element_type):
        @parameter
        for i in range(self.storage_size):
            self.elements[i] = value

    @always_inline
    fn fill(inout self, generator: fn () -> Self.element_type):
        @parameter
        for i in range(self.storage_size):
            self.elements[i] = generator()

    @always_inline
    fn set_diag(inout self, value: Self.element_type):
        alias diag_len = min(rows, cols)

        @parameter
        for i in range(diag_len):
            self.elements[self.pos[i, i]()] = value

    @staticmethod
    fn diag(value: Self.element_type = 1) -> Self:
        var res = Self(0)
        res.set_diag(value)
        return res

    @always_inline
    fn __getitem__(self, index: Int) raises -> self.element_type:
        if index < 0 or index > self.storage_size:
            raise Error("Index out of bounds")
        return self.elements[index]

    @always_inline
    fn __setitem__(inout self, index: Int, value: self.element_type) raises:
        if index < 0 or index > self.storage_size:
            raise Error("Index out of bounds")
        self.elements[index] = value

    @always_inline
    fn __getitem__(self, row: Int, col: Int) raises -> self.element_type:
        if row < 0 or row > rows or col < 0 or col > cols:
            raise Error("Index out of bounds")
        return self.elements[self.pos(row, col)]

    @always_inline
    fn __setitem__(
        inout self, row: Int, col: Int, value: self.element_type
    ) raises:
        if row < 0 or row > rows or col < 0 or col > cols:
            raise Error("Index out of bounds")
        self.elements[self.pos(row, col)] = value

    @always_inline
    fn get_col(self, col: Int) raises -> StaticColVec[rows]:
        if col < 0 or col > cols:
            raise Error("Index out of bounds")
        var res = StaticColVec[rows]()

        @parameter
        for i in range(rows):
            res.elements[i] = self.elements[self.pos(i, col)]

        return res

    @always_inline
    fn get_col[col: Int](self) -> StaticColVec[rows]:
        var res = StaticColVec[rows]()

        @parameter
        for row in range(rows):
            res.set[row, 1](self.get[row, col]())

        return res

    @always_inline
    fn get_row(self, row: Int) raises -> StaticRowVec[cols]:
        if row < 0 or row > rows:
            raise Error("Index out of bounds")
        var res = StaticRowVec[cols]()

        @parameter
        for i in range(cols):
            res.elements[i] = self.elements[self.pos(row, i)]

        return res

    @always_inline
    fn get_row[row: Int](self) -> StaticRowVec[cols]:
        var res = StaticRowVec[cols]()

        @parameter
        for col in range(cols):
            res.set[1, col](self.get[row, col]())

        return res

    @always_inline
    fn __len__(self) -> Int:
        return self.storage_size

    @always_inline
    fn __eq__(self, other: Self) -> Bool:
        var res = True

        @parameter
        for i in range(self.storage_size):
            res &= isclose(self.elements[i], other.elements[i])

        return res

    @always_inline
    fn __ne__(self, other: Self) -> Bool:
        return ~self.__eq__(other)

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
    fn pos(self, row: Int, col: Int) -> Int:
        return col * rows + row

    @always_inline
    fn __matmul__(self, other: StaticMat) -> StaticMat[rows, other.cols]:
        constrained[cols == other.rows, "Incompatible dimensions"]()
        var res = StaticMat[rows, other.cols](0)

        @parameter
        for i in range(res.rows):

            @parameter
            for j in range(res.cols):

                @parameter
                for k in range(other.rows):
                    res.elements[res.pos[i, j]()] += (
                        self.elements[self.pos[i, k]()]
                        * other.elements[other.pos[k, j]()]
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
    fn pos[row: Int, col: Int](self) -> Int:
        constrained[row >= 0 and row < rows, "Row index out of bounds"]()
        constrained[col >= 0 and col < cols, "Col index out of bounds"]()
        return col * rows + row

    @always_inline
    fn get[row: Int, col: Int](self) -> Self.element_type:
        return self.elements[self.pos[row, col]()]

    @always_inline
    fn set[row: Int, col: Int](inout self, value: Self.element_type):
        self.elements[self.pos[row, col]()] = value

    @always_inline
    fn swap_rows[first: Int, second: Int](inout self):
        @parameter
        for col in range(cols):
            var tmp = self.get[first, col]()
            self.set[first, col](self.get[second, col]())
            self.set[second, col](tmp)

    @always_inline
    fn swap_rows[c1: Int = 0, c2: Int = cols](inout self, r1: Int, r2: Int):
        @parameter
        for col in range(c1, c2):
            swap(
                self.elements[self.pos(r1, col)],
                self.elements[self.pos(r2, col)],
            )

    @always_inline
    fn swap_cols[first: Int, second: Int](inout self):
        @parameter
        for row in range(rows):
            var tmp = self.get[row, first]()
            self.set[row, first](self.get[row, second]())
            self.set[row, second](tmp)

    @always_inline
    fn swap_cols(inout self, first: Int, second: Int):
        @parameter
        for row in range(rows):
            swap(
                self.elements[self.pos(row, first)],
                self.elements[self.pos(row, second)],
            )

    @always_inline
    fn transpose(self) -> StaticMat[cols, rows]:
        var res = StaticMat[cols, rows]()

        @parameter
        for row in range(rows):

            @parameter
            for col in range(cols):
                res.set[col, row](self.get[row, col]())

        return res

    @always_inline
    fn PLU_decompose(
        self,
    ) -> (StaticMat[rows, rows], StaticMat[rows, rows], Self):
        """Compute PLU decomposition."""

        var P = StaticMat[rows, rows].diag()
        var L = P
        var U = self

        # rows, cols are compile-time parameters (constants)
        @parameter
        for k in range(min(rows, cols)):
            var pivot_row = k
            var max_value = abs(U.get[k, k]())  # |U[k, k]|

            @parameter
            for i in range(k + 1, rows):
                if abs(U.get[i, k]()) > max_value:
                    max_value = abs(U.get[i, k]())  # |U[i, k]|
                    pivot_row = i

            if pivot_row != k:
                # Swap full rows
                P.swap_rows(k, pivot_row)
                # Swap rows with col in k to cols - 1
                U.swap_rows[k, cols](k, pivot_row)
                # Swap rows with col in 0 to k - 1
                L.swap_rows[0, k](k, pivot_row)

            @parameter
            for i in range(k + 1, rows):
                if ~isclose(U.get[k, k](), 0):
                    # L[i, k] = U[i, k] / U[k, k]
                    L.set[i, k](U.get[i, k]() / U.get[k, k]())

                @parameter
                for j in range(k + 1, cols):
                    # U[i, j] = U[i, j] - L[i, k] * U[k, j]
                    U.set[i, j](U.get[i, j]() - L.get[i, k]() * U.get[k, j]())

                U.set[i, k](0.0)  # U[i, k] = 0

        return (P, L, U)


alias StaticRowVec = StaticMat[1, _]
alias StaticColVec = StaticMat[_, 1]


fn main() raises:
    var X6 = StaticMat[5, 3](1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15)
    var LU6 = X6.PLU_decompose()
    print(LU6[1] @ LU6[2] == LU6[0] @ X6)
    var P = LU6[0]
    var L = LU6[1]
    var U = LU6[2]
    for i in range(L.rows):
        for j in range(L.cols):
            print(L[i, j], end=" ")
        print("\n")
    for i in range(U.rows):
        for j in range(U.cols):
            print(U[i, j], end=" ")
        print("\n")
    for i in range(P.rows):
        for j in range(P.cols):
            print(P[i, j], end=" ")
        print("\n")
    var LU = L @ U
    for i in range(LU.rows):
        for j in range(LU.cols):
            print(LU[i, j], end=" ")
        print("\n")
    var PA = P @ X6
    for i in range(PA.rows):
        for j in range(PA.cols):
            print(PA[i, j], end=" ")
        print("\n")
    print(LU == PA)
