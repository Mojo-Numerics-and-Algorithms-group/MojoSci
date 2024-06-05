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

# Some very basic utilities for learning and to support modeling


@value
@register_passable("trivial")
struct Vec[size: Int](Sized):
    alias element_type = Float64
    var elements: Pointer[Self.element_type]

    @always_inline
    fn __init__(inout self):
        constrained[size > 0, "Vector size must be greater than zero."]()
        self.elements = stack_allocation[size, Self.element_type]()

    @always_inline
    fn __init__(inout self, fill: Self.element_type):
        constrained[size > 0, "Vector size must be greater than zero."]()
        self.elements = stack_allocation[size, Self.element_type]()

        @parameter
        for i in range(size):
            self.elements[i] = fill

    # TODO: Bounds checking, intable, etc.
    @always_inline
    fn __getitem__(self, index: Int) -> Self.element_type:
        return self.elements[index]

    # TODO: Bounds checking, intable, etc.
    @always_inline
    fn __setitem__(inout self, index: Int, value: Self.element_type):
        self.elements[index] = value

    @always_inline
    fn __len__(self) -> Int:
        return size

    @always_inline
    fn __add__(self, other: Self) -> Self:
        var res = Self()

        @parameter
        for i in range(size):
            res.elements[i] = self.elements[i] + other.elements[i]

        return res

    @always_inline
    fn __sub__(self, other: Self) -> Self:
        var res = Self()

        @parameter
        for i in range(size):
            res.elements[i] = self.elements[i] - other.elements[i]

        return res

    @always_inline
    fn __mul__(self, other: Self) -> Self:
        var res = Self()

        @parameter
        for i in range(size):
            res.elements[i] = self.elements[i] * other.elements[i]

        return res

    @always_inline
    fn __matmul__(self, other: Self) -> Self.element_type:
        var res: Self.element_type = 0

        @parameter
        for i in range(size):
            res += self.elements[i] * other.elements[i]

        return res

    @always_inline
    fn __truediv__(self, other: Self) -> Self:
        var res = Self()

        @parameter
        for i in range(size):
            res.elements[i] = self.elements[i] / other.elements[i]

        return res

    @always_inline
    fn __add__(self, other: Self.element_type) -> Self:
        var res = Self()

        @parameter
        for i in range(size):
            res.elements[i] = self.elements[i] + other

        return res

    @always_inline
    fn __sub__(self, other: Self.element_type) -> Self:
        var res = Self()

        @parameter
        for i in range(size):
            res.elements[i] = self.elements[i] - other

        return res

    @always_inline
    fn __mul__(self, other: Self.element_type) -> Self:
        var res = Self()

        @parameter
        for i in range(size):
            res.elements[i] = self.elements[i] * other

        return res

    @always_inline
    fn __truediv__(self, other: Self.element_type) -> Self:
        var res = Self()

        @parameter
        for i in range(size):
            res.elements[i] = self.elements[i] / other

        return res

    @always_inline
    fn __radd__(self, other: Self.element_type) -> Self:
        var res = Self()

        @parameter
        for i in range(size):
            res.elements[i] = self.elements[i] + other

        return res

    @always_inline
    fn __rsub__(self, other: Self.element_type) -> Self:
        var res = Self()

        @parameter
        for i in range(size):
            res.elements[i] = other - self.elements[i]

        return res

    @always_inline
    fn __rmul__(self, other: Self.element_type) -> Self:
        var res = Self()

        @parameter
        for i in range(size):
            res.elements[i] = self.elements[i] * other

        return res

    @always_inline
    fn __rtruediv__(self, other: Self.element_type) -> Self:
        var res = Self()

        @parameter
        for i in range(size):
            res.elements[i] = other / self.elements[i]

        return res


@value
@register_passable("trivial")
struct Mat[size: Int](Sized):
    alias element_type = Float64
    alias storage_size = size * size
    var elements: Pointer[Self.element_type]

    @always_inline
    fn __init__(inout self):
        constrained[size > 0, "Matrix size must be greater than zero."]()
        self.elements = stack_allocation[Self.storage_size, Self.element_type]()

    @always_inline
    fn __init__(inout self, fill: Self.element_type):
        constrained[size > 0, "Matrix size must be greater than zero."]()
        self.elements = stack_allocation[Self.storage_size, Self.element_type]()

        @parameter
        for i in range(Self.storage_size):
            self.elements[i] = fill

    # TODO: Bounds checking, intable, etc.
    @always_inline
    fn __getitem__(self, index: Int) -> Self.element_type:
        return self.elements[index]

    # TODO: Bounds checking, intable, etc.
    @always_inline
    fn __setitem__(inout self, index: Int, value: Self.element_type):
        self.elements[index] = value

    # TODO: Bounds checking, intable, etc.
    @always_inline
    fn __getitem__(self, row: Int, col: Int) -> Self.element_type:
        return self.elements[col * size + row]

    # TODO: Bounds checking, intable, etc.
    @always_inline
    fn __setitem__(inout self, row: Int, col: Int, value: Self.element_type):
        self.elements[col * size + row] = value

    @always_inline
    fn get_col(self, col: Int) -> Vec[size]:
        var res = Vec[size]()

        @parameter
        for i in range(size):
            res[i] = self.elements[col * size + i]

        return res

    @always_inline
    fn get_row(self, row: Int) -> Vec[size]:
        var res = Vec[size]()

        @parameter
        for i in range(size):
            res[i] = self.elements[i * size + row]

        return res

    @always_inline
    fn __len__(self) -> Int:
        return Self.storage_size

    @always_inline
    fn __add__(self, other: Self) -> Self:
        var res = Self()

        @parameter
        for i in range(Self.storage_size):
            res.elements[i] = self.elements[i] + other.elements[i]

        return res

    @always_inline
    fn __sub__(self, other: Self) -> Self:
        var res = Self()

        @parameter
        for i in range(Self.storage_size):
            res.elements[i] = self.elements[i] - other.elements[i]

        return res

    @always_inline
    fn __mul__(self, other: Self) -> Self:
        var res = Self()

        @parameter
        for i in range(Self.storage_size):
            res.elements[i] = self.elements[i] * other.elements[i]

        return res

    @always_inline
    fn __matmul__(self, other: Self) -> Self:
        var res = Self()

        @parameter
        for i in range(size):

            @parameter
            for j in range(size):
                res[i, j] = self.get_row(i) @ other.get_col(j)

        return res

    @always_inline
    fn __matmul__(self, other: Vec[size]) -> Vec[size]:
        var res = Vec[size]()

        @parameter
        for i in range(size):
            res[i] = self.get_row(i) @ other

        return res

    @always_inline
    fn __rmatmul__(self, other: Vec[size]) -> Vec[size]:
        var res = Vec[size]()

        @parameter
        for i in range(size):
            res[i] = self.get_col(i) @ other

        return res

    @always_inline
    fn __truediv__(self, other: Self) -> Self:
        var res = Self()

        @parameter
        for i in range(Self.storage_size):
            res.elements[i] = self.elements[i] / other.elements[i]

        return res

    @always_inline
    fn __add__(self, other: Self.element_type) -> Self:
        var res = Self()

        @parameter
        for i in range(Self.storage_size):
            res.elements[i] = self.elements[i] + other

        return res

    @always_inline
    fn __sub__(self, other: Self.element_type) -> Self:
        var res = Self()

        @parameter
        for i in range(Self.storage_size):
            res.elements[i] = self.elements[i] - other

        return res

    @always_inline
    fn __mul__(self, other: Self.element_type) -> Self:
        var res = Self()

        @parameter
        for i in range(Self.storage_size):
            res.elements[i] = self.elements[i] * other

        return res

    @always_inline
    fn __truediv__(self, other: Self.element_type) -> Self:
        var res = Self()

        @parameter
        for i in range(Self.storage_size):
            res.elements[i] = self.elements[i] / other

        return res

    @always_inline
    fn __radd__(self, other: Self.element_type) -> Self:
        var res = Self()

        @parameter
        for i in range(Self.storage_size):
            res.elements[i] = self.elements[i] + other

        return res

    @always_inline
    fn __rsub__(self, other: Self.element_type) -> Self:
        var res = Self()

        @parameter
        for i in range(Self.storage_size):
            res.elements[i] = other - self.elements[i]

        return res

    @always_inline
    fn __rmul__(self, other: Self.element_type) -> Self:
        var res = Self()

        @parameter
        for i in range(Self.storage_size):
            res.elements[i] = self.elements[i] * other

        return res

    @always_inline
    fn __rtruediv__(self, other: Self.element_type) -> Self:
        var res = Self()

        @parameter
        for i in range(Self.storage_size):
            res.elements[i] = other / self.elements[i]

        return res


# fn main():
#     var x = Vec[3](2)
#     var y = 2 / x
#     var z = y / x
#     var a = y @ z
#     print(a)
