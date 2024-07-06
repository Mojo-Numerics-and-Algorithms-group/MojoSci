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

# ===----------------------------------------------------------------------=== #
#   Initializations
# ===----------------------------------------------------------------------=== #

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

    # ===----------------------------------------------------------------------=== #
    # Sized trait
    # ===----------------------------------------------------------------------=== #

    @always_inline
    fn __len__(self) -> Int:
        return self.storage_size

    # ===----------------------------------------------------------------------=== #
    # Runtime modification
    # ===----------------------------------------------------------------------=== #

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

    # ===----------------------------------------------------------------------=== #
    # Run-time indexed access
    # ===----------------------------------------------------------------------=== #

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

    # ===----------------------------------------------------------------------=== #
    # Run-time indexed modification
    # ===----------------------------------------------------------------------=== #

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

    # ===----------------------------------------------------------------------=== #
    # Compile-time indexed access
    # ===----------------------------------------------------------------------=== #

    @always_inline
    fn pos[i: Int](self) -> Int:
        constrained[i >= 0 and i < self.storage_size, "Row index out of bounds"]()
        return i

    @always_inline
    fn pos[row: Int, col: Int](self) -> Int:
        constrained[row >= 0 and row < rows, "Row index out of bounds"]()
        constrained[col >= 0 and col < cols, "Col index out of bounds"]()
        return col * rows + row

    @always_inline
    fn get[i: Int](self) -> Self.ElementType:
        return self.elements[self.pos[i]()]

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

    # ===----------------------------------------------------------------------=== #
    # Compile-time indexed modification
    # ===----------------------------------------------------------------------=== #

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

    # ===----------------------------------------------------------------------=== #
    # Matrix builders
    # ===----------------------------------------------------------------------=== #

    @staticmethod
    fn diag(value: Self.ElementType = 1) -> Self:
        """Create diagonal matrix of matching dimensions."""
        var res = Self(0)
        res.set_diag(value)
        return res

    @staticmethod
    fn iota() -> Self:
        """Fill matrix with sequence from 0 to number of elements."""
        var res = Self()
        @parameter
        for i in range(res.storage_size):
            res.elements[i] = i
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
        from testing import assert_equal
        from linalg.static_matrix import StaticMat
        var x = StaticMat[3, 3](1)
        var y = x @ x.ones_col() # row sums
        #assert_equal(y, StaticMat[3, 1](3))
        ```
        """
        return StaticColVec[rows](1)

    @staticmethod
    fn ones_row() -> StaticRowVec[cols]:
        """Create zeros matrix of matching dimensions."""
        return StaticRowVec[cols](1)

    # ===----------------------------------------------------------------------=== #
    # Predicates
    # ===----------------------------------------------------------------------=== #

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
        return not self.__eq__(other)

    # ===----------------------------------------------------------------------=== #
    # Elementwise operators
    # ===----------------------------------------------------------------------=== #

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

    @always_inline
    fn __iadd__(inout self, other: Self):

        @parameter
        for i in range(self.storage_size):
            self.elements[i] += other.elements[i]

    @always_inline
    fn __sub__(inout self, other: Self):
        @parameter
        for i in range(self.storage_size):
            self.elements[i] -= other.elements[i]

    @always_inline
    fn __mul__(inout self, other: Self):

        @parameter
        for i in range(self.storage_size):
            self.elements[i] *= other.elements[i]

    @always_inline
    fn __truediv__(inout self, other: Self):

        @parameter
        for i in range(self.storage_size):
            self.elements[i] /= other.elements[i]

    # ===----------------------------------------------------------------------=== #
    # Scalar operators
    # ===----------------------------------------------------------------------=== #

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

    # ===----------------------------------------------------------------------=== #
    # Matrix operators
    # ===----------------------------------------------------------------------=== #

    @always_inline
    fn __matmul__(self, other: StaticMat) -> StaticMat[rows, other.cols]:
        """Perform a matrix-matrix multiply and return the result.

        All loops should be unrolled and the entire operation inlined.
        This may be very slow for large matrices as the code size could
        balloon into many millions of rows. This will not compile if the
        two matrices do not have compatible dimensions."""
        constrained[cols == other.rows, "Incompatible dimensions"]()
        var res = StaticMat[rows, other.cols]()

        @parameter
        for i in range(res.rows):

            @parameter
            for j in range(res.cols):

                res.elements[res.pos[i, j]()] =  self.elements[self.pos[i, 0]()]
                        * other.elements[other.pos[0, j]()]

                @parameter
                for k in range(1, other.rows):
                    res.elements[res.pos[i, j]()] += (
                        self.elements[self.pos[i, k]()]
                        * other.elements[other.pos[k, j]()]
                    )

        return res

    @always_inline
    fn max_value(self) -> Self.ElementType:
        var max = self.elements[0]
        @parameter
        for i in range(1, self.storage_size):
            if self.elements[i] > max:
                max = self.elements[i]
        return max

    @always_inline
    fn min_value(self) -> Self.ElementType:
        var min = self.elements[0]
        @parameter
        for i in range(1, self.storage_size):
            if self.elements[i] < min:
                min = self.elements[i]
        return min

    @always_inline
    fn sum(self) -> Self.ElementType:
        var sum = self.elements[0]
        @parameter
        for i in range(1, self.storage_size):
                sum += self.elements[i]
        return sum

    # ===----------------------------------------------------------------------=== #
    # Matrix transforms
    # ===----------------------------------------------------------------------=== #

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
    fn transpose_inplace(inout self):
        """Swap rows and columns."""

        @parameter
        for row in range(rows):

            @parameter
            for col in range(cols):
                var tmp = self.get[row, col]()
                self.set[row, col](self.get[col, row]())
                self.set[col, row](tmp)

    @always_inline
    fn inverse(self) raises -> Self:
        constrained[rows == cols, "Cannot invert a non-square matrix."]()

        if isclose(self.determinant(), 0):
            raise Error("Matrix is singular; cannot compute the inverse.")

        var I = Self.diag()
        var A = self

        @parameter
        for k in range(cols):
            var max_row = k
            var max_value = abs(A.get[k, k]())
            @parameter
            for i in range(k + 1, rows):
                var this_value = abs(A.get[i, k]())
                if this_value > max_value:
                    max_value = this_value
                    max_row = i

            if max_row != k:
                I.swap_rows(k, max_row)
                A.swap_rows(k, max_row)

            @parameter
            for i in range(k + 1, rows):
                if not isclose(A.get[k, k](), 0):
                    var f = A.get[i, k]() / A.get[k, k]()
                    A.set[i, k](0.0)
                    @parameter
                    for j in range(k + 1, cols):
                        A.set[i, j](A.get[i, j]() - f * A.get[k, j]())
                    @parameter
                    for j in range(cols):
                        I.set[i, j](I.get[i, j]() - f * I.get[k, j]())

        @parameter
        for k in reversed(range(cols)):
            @parameter
            for j in range(cols):
                I.set[k, j](I.get[k, j]() / A.get[k, k]())
            @parameter
            for i in reversed(range(k)):
                @parameter
                for j in range(cols):
                    I.set[i, j](I.get[i, j]() - A.get[i, k]() * I.get[k, j]())

        return I

    @always_inline
    fn PLU_decompose(self) -> (StaticMat[rows, rows], StaticMat[rows, rows], Self):
        """Computes the PLU decomposition of the input matrix.

        Returns (P, L, U) such that P @ A == L @ U where
        A in the (possibly non-square) input matrix."""

        var P = StaticMat[rows, rows].diag()
        var L = StaticMat[rows, rows].diag()
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
                if not isclose(U.get[k, k](), 0):
                    # L[i, k] = U[i, k] / U[k, k]
                    L.set[i, k](U.get[i, k]() / U.get[k, k]())

                @parameter
                for j in range(k + 1, cols):
                    # U[i, j] = U[i, j] - L[i, k] * U[k, j]
                    U.set[i, j](U.get[i, j]() - L.get[i, k]() * U.get[k, j]())

                U.set[i, k](0.0)  # U[i, k] = 0

        return (P, L, U)

    @always_inline
    fn PLU_decompose2(self) raises -> (StaticMat[rows, rows], StaticMat[rows, rows], Self):
        """Computes the PLU decomposition of the input matrix.
        
        Returns (P, L, U) such that P @ A == L @ U where
        A in the (possibly non-square) input matrix."""

        var P = StaticMat[rows, rows].diag()
        var L = StaticMat[rows, rows](0.0)
        var U = self

        # rows, cols are compile-time parameters (constants)
        for k in range(min(rows, cols)):
            var pivot_row = k
            var max_value = abs(U[k, k])  # |U[k, k]|

            for i in range(k + 1, rows):
                if abs(U[i, k]) > max_value:
                    max_value = abs(U[i, k])  # |U[i, k]|
                    pivot_row = i

            if pivot_row != k:
                # Swap full rows
                P.swap_rows(k, pivot_row)
                U.swap_rows(k, pivot_row)
                L.swap_rows(k, pivot_row)

            for i in range(k + 1, rows):
                if not isclose(U[k, k], 0):
                    # L[i, k] = U[i, k] / U[k, k]
                    L[i, k] = U[i, k] / U[k, k]

                for j in range(k + 1, cols):
                    # U[i, j] = U[i, j] - L[i, k] * U[k, j]
                    U[i, j] = U[i, j] - L[i, k] * U[k, j]

                U[i, k] = 0.0  # U[i, k] = 0

        # Set the diagonal of L to 1
        for i in range(rows):
            L[i, i] = 1.0

        return (P, L, U)

    @always_inline
    fn determinant(self) -> Float64:
        """Computes the determinant of the input matrix using PLU decomposition."""
        var PLU = self.PLU_decompose()

        var det = 1.0
        @parameter
        for i in range(rows):
            det *= PLU[2].get[i, i]()
            if PLU[0].get[i, i]() != 1.0:
                det *= -1

        return det


# ===----------------------------------------------------------------------=== #
# Vector types
# ===----------------------------------------------------------------------=== #

alias StaticRowVec = StaticMat[1, _]
alias StaticColVec = StaticMat[_, 1]

fn to_scalar[n: Int, m: Int](owned x: StaticMat[n, m]) -> Float64:
    constrained[n == 1 and m == 1, "Only 1x1 matrices can be converted to a scalar value."]()
    return x.get[0, 0]()

fn print_mat[rows: Int, cols: Int](x: StaticMat[rows, cols]) raises:
    for row in range(rows):
        for col in range(cols):
            print(x[row, col], end = " ")
        print()

""" fn main() raises:
   var X8 = StaticMat[2, 2](4, 6, 3, 3)
   print_mat(X8)
   print()
   var LU8 = X8.PLU_decompose2()
   var Pgen = LU8[0]
   var Pexp = StaticMat[2, 2].diag()
   print_mat(Pgen)
   print()
   print_mat(Pexp)
   print()
   var Lgen = LU8[1]
   var Lexp = StaticMat[2, 2](1, 1.5, 0, 1)
   print_mat(Lgen)
   print()
   print_mat(Lexp)
   print()
   var Ugen = LU8[2]
   var Uexp = StaticMat[2, 2](4, 0, 3, -1.5)
   print_mat(Ugen)
   print()
   print_mat(Uexp)
   print()
 """

fn main() raises:
    var X8 = StaticMat[2, 2](4, 6, 3, 3)  # Column-major order
    print("Original matrix X8:")
    print_mat(X8)
    print()

    var LU8 = X8.PLU_decompose2()

    var Pgen = LU8[0]
    var Pexp = StaticMat[2, 2].diag()  # Correct expected P matrix
    print("Generated P matrix:")
    print_mat(Pgen)
    print()
    print("Expected P matrix:")
    print_mat(Pexp)
    print()

    var Lgen = LU8[1]
    var Lexp = StaticMat[2, 2](1, 0, 0.75, 1)  # Correct expected L matrix
    print("Generated L matrix:")
    print_mat(Lgen)
    print()
    print("Expected L matrix:")
    print_mat(Lexp)
    print()

    var Ugen = LU8[2]
    var Uexp = StaticMat[2, 2](4, 3, 0, 0.75)  # Correct expected U matrix
    print("Generated U matrix:")
    print_mat(Ugen)
    print()
    print("Expected U matrix:")
    print_mat(Uexp)
    print()

    # Verify the reconstruction PA = LU
    var PA = Pgen @ X8
    var LU = Lgen @ Ugen
    print("PA matrix:")
    print_mat(PA)
    print()
    print("LU matrix:")
    print_mat(LU)
    print()