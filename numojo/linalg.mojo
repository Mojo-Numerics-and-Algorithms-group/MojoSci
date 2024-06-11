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

    alias ElementType = Float64
    alias storage_size = rows * cols
    alias StorageType = StaticTuple[Self.ElementType, Self.storage_size]
    var elements: Self.StorageType

    # ==========================================
    # Initializations
    # ==========================================

    @always_inline
    fn __init__(inout self):
        """Evoke default initializer for StaticTuple."""
        constrained[
            self.storage_size > 0, "Matrix size must be greater than zero."
        ]()
        self.elements = Self.StorageType()

    @always_inline
    fn __init__(inout self, fill: Self.ElementType):
        """Initialize matrix and set elements to fill value."""
        constrained[
            self.storage_size > 0, "Matrix size must be greater than zero."
        ]()
        self.elements = Self.StorageType()
        self.fill(fill)

    @always_inline
    fn __init__(inout self, generator: fn () -> Self.ElementType):
        """"Initialize matrix and use generator to fill values."""
        constrained[
            self.storage_size > 0, "Matrix size must be greater than zero."
        ]()
        self.elements = Self.StorageType()
        self.fill(generator)

    @always_inline
    """Initialize matrix and fill with the provided arguments."""
    fn __init__(inout self, *elems: Self.ElementType):
        self.elements = Self.StorageType(elems)

    @always_inline
    fn __init__(inout self, values: VariadicList[Self.ElementType]):
        """Initialize matrix and fill from variadic list of values."""
        self.elements = Self.StorageType(values)

    # ==========================================
    # Sized trait
    # ==========================================

    @always_inline
    fn __len__(self) -> Int:
        return self.storage_size

    # ==========================================
    # Runtime modification
    # ==========================================

    @always_inline
    fn fill(inout self, value: Self.ElementType):
        @parameter
        for i in range(self.storage_size):
            self.elements[i] = value

    @always_inline
    fn fill(inout self, generator: fn () -> Self.ElementType):
        @parameter
        for i in range(self.storage_size):
            self.elements[i] = generator()

    @always_inline
    fn set_diag(inout self, value: Self.ElementType):
        alias diag_len = min(rows, cols)

        @parameter
        for i in range(diag_len):
            self.set[i, i](value)

    # ==========================================
    # Run-time indexed access
    # ==========================================

    @always_inline
    fn pos(self, row: Int, col: Int) -> Int:
        """Return linear element position."""
        return col * rows + row

    @always_inline
    fn __getitem__(self, index: Int) raises -> Self.ElementType:
        """Get element at storage position."""
        if index < 0 or index > self.storage_size:
            raise Error("Index out of bounds")
        return self.elements[index]

    @always_inline
    fn __getitem__(self, row: Int, col: Int) raises -> Self.ElementType:
        """Get element by row and column indices."""
        if row < 0 or row > rows or col < 0 or col > cols:
            raise Error("Index out of bounds")
        return self.elements[self.pos(row, col)]

    @always_inline
    fn get_row(self, row: Int) raises -> StaticRowVec[cols]:
        """Return a row of elements."""
        if row < 0 or row > rows:
            raise Error("Index out of bounds")
        var res = StaticRowVec[cols]()

        @parameter
        for i in range(cols):
            res.elements[i] = self.elements[self.pos(row, i)]

        return res
        
    @always_inline
    fn get_col(self, col: Int) raises -> StaticColVec[rows]:
        """Return a column of elements."""
        if col < 0 or col > cols:
            raise Error("Index out of bounds")
        var res = StaticColVec[rows]()

        @parameter
        for i in range(rows):
            res.elements[i] = self.elements[self.pos(i, col)]

        return res

    # ==========================================
    # Run-time indexed modification
    # ==========================================

    @always_inline
    fn __setitem__(inout self, index: Int, value: Self.ElementType) raises:
        if index < 0 or index > self.storage_size:
            raise Error("Index out of bounds")
        self.elements[index] = value

    @always_inline
    fn __setitem__(
        inout self, row: Int, col: Int, value: Self.ElementType
    ) raises:
        """Set a value with bounds checking."""
        if row < 0 or row > rows or col < 0 or col > cols:
            raise Error("Index out of bounds")
        self.elements[self.pos(row, col)] = value

    @always_inline
    fn swap_rows[cstart: Int = 0, cend: Int = cols](inout self, row1: Int, row2: Int):
        """Swap rows in-place with option for partial swap."""
        @parameter
        for col in range(cstart, cend):
            swap(
                self.elements[self.pos(row1, col)],
                self.elements[self.pos(row2, col)],
            )

    @always_inline
    fn swap_cols[rstart: Int = 0, rend: Int = rows](inout self, col1: Int, col2: Int):
        """Swap columns in-place with option for partial swap."""
        @parameter
        for row in range(rstart, rend):
            swap(
                self.elements[self.pos(row, col1)],
                self.elements[self.pos(row, col2)],
            )

    # ==========================================
    # Compile-time indexed access
    # ==========================================

    @always_inline
    fn pos[row: Int, col: Int](self) -> Int:
        constrained[row >= 0 and row < rows, "Row index out of bounds"]()
        constrained[col >= 0 and col < cols, "Col index out of bounds"]()
        return col * rows + row

    @always_inline
    fn get[row: Int, col: Int](self) -> Self.ElementType:
        return self.elements[self.pos[row, col]()]

    @always_inline
    fn get_col[col: Int](self) -> StaticColVec[rows]:
        var res = StaticColVec[rows]()

        @parameter
        for row in range(rows):
            res.set[row, 1](self.get[row, col]())

        return res

    @always_inline
    fn get_row[row: Int](self) -> StaticRowVec[cols]:
        var res = StaticRowVec[cols]()

        @parameter
        for col in range(cols):
            res.set[1, col](self.get[row, col]())

        return res

    # ==========================================
    # Compile-time indexed modification
    # ==========================================

    @always_inline
    fn set[row: Int, col: Int](inout self, value: Self.ElementType):
        self.elements[self.pos[row, col]()] = value

    @always_inline
    fn set_row[row: Int](inout self, value: StaticRowVec[cols]):
        @parameter
        for col in range(cols):
            self.set[row, col](value.get[0, col]())

    @always_inline
    fn set_col[col: Int](inout self, value: StaticColVec[rows]):
        @parameter
        for row in range(rows):
            self.set[row, col](value.get[row, 0]())

    @always_inline
    fn swap_rows[first: Int, second: Int](inout self):
        @parameter
        for col in range(cols):
            var tmp = self.get[first, col]()
            self.set[first, col](self.get[second, col]())
            self.set[second, col](tmp)

    @always_inline
    fn swap_cols[first: Int, second: Int](inout self):
        @parameter
        for row in range(rows):
            var tmp = self.get[row, first]()
            self.set[row, first](self.get[row, second]())
            self.set[row, second](tmp)

    # ==========================================
    # Matrix builders
    # ==========================================

    @staticmethod
    fn diag(value: Self.ElementType = 1) -> Self:
        """Create diagonal matrix of matching dimensions."""
        var res = Self(0)
        res.set_diag(value)
        return res

    @staticmethod
    fn zeros() -> Self:
        """Create zeros matrix of matching dimensions."""
        return Self(0)

    @staticmethod
    fn zeros_col() -> StaticColVec[rows]:
        """Create zeros matrix of matching dimensions."""
        return StaticColVec[rows](0)

    @staticmethod
    fn zeros_row() -> StaticRowVec[cols]:
        """Create zeros matrix of matching dimensions."""
        return StaticRowVec[cols](0)

    @staticmethod
    fn ones() -> Self:
        """Create zeros matrix of matching dimensions."""
        return Self(1)
    
    @staticmethod
    fn ones_col() -> StaticColVec[rows]:
        """Create zeros matrix of matching dimensions.
        
        ```mojo
        var x = StaticMat[3, 3](1)
        var y = x @ x.ones_col() # row sums
        assert_equal(y, StaticMat[3, 1](3))
        ```
        """
        return StaticColVec[rows](1)

    @staticmethod
    fn ones_row() -> StaticRowVec[cols]:
        """Create zeros matrix of matching dimensions."""
        return StaticRowVec[cols](1)

    # ==========================================
    # Predicates
    # ==========================================

    # TODO: Elementwise + all/any functions
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

    # ==========================================
    # Elementwise operators
    # ==========================================

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
    fn __truediv__(self, other: Self) -> Self:
        var res = Self()

        @parameter
        for i in range(self.storage_size):
            res.elements[i] = self.elements[i] / other.elements[i]

        return res

    # ==========================================
    # Scalar operators
    # ==========================================

    @always_inline
    fn __add__(self, other: Self.ElementType) -> Self:
        var res = Self()

        @parameter
        for i in range(self.storage_size):
            res.elements[i] = self.elements[i] + other

        return res

    @always_inline
    fn __sub__(self, other: Self.ElementType) -> Self:
        var res = Self()

        @parameter
        for i in range(self.storage_size):
            res.elements[i] = self.elements[i] - other

        return res

    @always_inline
    fn __mul__(self, other: Self.ElementType) -> Self:
        var res = Self()

        @parameter
        for i in range(self.storage_size):
            res.elements[i] = self.elements[i] * other

        return res

    @always_inline
    fn __truediv__(self, other: Self.ElementType) -> Self:
        var res = Self()

        @parameter
        for i in range(self.storage_size):
            res.elements[i] = self.elements[i] / other

        return res

    @always_inline
    fn __radd__(self, other: Self.ElementType) -> Self:
        """Add the elements of a matrix to a scalar and return a matrix."""
        var res = Self()

        @parameter
        for i in range(self.storage_size):
            res.elements[i] = self.elements[i] + other

        return res

    @always_inline
    fn __rsub__(self, other: Self.ElementType) -> Self:
        """Subtract elements of a matrix from a scalar and return a matrix."""
        var res = Self()

        @parameter
        for i in range(self.storage_size):
            res.elements[i] = other - self.elements[i]

        return res

    @always_inline
    fn __rmul__(self, other: Self.ElementType) -> Self:
        """Multiply a scalar by the elments of a matrix returing a matrix."""
        var res = Self()

        @parameter
        for i in range(self.storage_size):
            res.elements[i] = self.elements[i] * other

        return res

    @always_inline
    fn __rtruediv__(self, other: Self.ElementType) -> Self:
        """Divide a scalar by the elements of a matrix returning a matrix."""
        var res = Self()

        @parameter
        for i in range(self.storage_size):
            res.elements[i] = other / self.elements[i]

        return res

    # ==========================================
    # Matrix operators
    # ==========================================

    @always_inline
    fn __matmul__(self, other: StaticMat) -> StaticMat[rows, other.cols]:
        """Perform a matrix-matrix multiply and return the result.

        All loops should be unrolled and the entire operation inlined.
        This may be very slow for large matrices as the code size could
        balloon into many millions of rows. This will not compile if the
        two matrices do not have compatible dimensions."""
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

    # ==========================================
    # Matrix transforms
    # ==========================================

    @always_inline
    fn transpose(self) -> StaticMat[cols, rows]:
        """Return the matrix with rows and columns swapped."""
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
        """Computes the PLU decomposition of the input matrix.
        
        Returns (P, L, U) such that P @ A == L @ U where
        A in the (possibly non-square) input matrix."""

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

# ==========================================
# Vector types
# ==========================================

alias StaticRowVec = StaticMat[1, _]
alias StaticColVec = StaticMat[_, 1]

# fn main():
#     var x = StaticMat[3, 3](1)
#     var y = x @ x.ones_col()

# fn main() raises:
#     var X6 = StaticMat[5, 3](1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15)
#     var LU6 = X6.PLU_decompose()
#     print(LU6[1] @ LU6[2] == LU6[0] @ X6)
#     var P = LU6[0]
#     var L = LU6[1]
#     var U = LU6[2]
#     for i in range(L.rows):
#         for j in range(L.cols):
#             print(L[i, j], end=" ")
#         print("\n")
#     for i in range(U.rows):
#         for j in range(U.cols):
#             print(U[i, j], end=" ")
#         print("\n")
#     for i in range(P.rows):
#         for j in range(P.cols):
#             print(P[i, j], end=" ")
#         print("\n")
#     var LU = L @ U
#     for i in range(LU.rows):
#         for j in range(LU.cols):
#             print(LU[i, j], end=" ")
#         print("\n")
#     var PA = P @ X6
#     for i in range(PA.rows):
#         for j in range(PA.cols):
#             print(PA[i, j], end=" ")
#         print("\n")
#     print(LU == PA)
