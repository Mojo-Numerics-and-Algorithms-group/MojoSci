from sys.ffi import DLHandle
from os.path import isfile
from os.env import getenv

# enum CBLAS_ORDER {CblasRowMajor=101, CblasColMajor=102};
alias CblasRowMajor = 101
alias CblasColMajor = 102
# enum CBLAS_TRANSPOSE {CblasNoTrans=111, CblasTrans=112, CblasConjTrans=113};
alias CblasNoTrans = 111
alias CblasTrans = 112
alias CblasConjTrans = 113
# enum CBLAS_UPLO {CblasUpper=121, CblasLower=122};
alias CblasUpper = 121
alias CblasLower = 122
# enum CBLAS_DIAG {CblasNonUnit=131, CblasUnit=132};
alias CblasNonUnit = 131
alias CblasUnit = 132
# enum CBLAS_SIDE {CblasLeft=141, CblasRight=142};
alias CblasLeft = 141
alias CblasRight = 142


struct CBLAS:
    var handle: DLHandle

    fn __init__(inout self) raises:
        var path = getenv("MOJOSCI_CBLAS_DYNLIB_PATH")
        if not isfile(path):
            raise Error("Provided path does not point to a file")
        self.handle = DLHandle(path)
        if not self.handle:
            raise Error("Path not recognized as a dynamic library")

    fn __init__(inout self, path: String) raises:
        if not isfile(path):
            raise Error("Provided path does not point to a file")
        self.handle = DLHandle(path)
        if not self.handle:
            raise Error("Path not recognized as a dynamic library")

    # float  cblas_sdsdot(const int N, const float alpha, const float *X,
    #                 const int incX, const float *Y, const int incY);
    fn sdsdot(
        self,
        n: Int,
        a: Float32,
        x: UnsafePointer[Float32],
        x_inc: Int,
        y: UnsafePointer[Float32],
        y_inc: Int,
    ) raises -> Float32:
        if not self.handle.check_symbol("cblas_sdsdot"):
            raise Error("Dynamic library does not contain cblas_sdsdot")
        var cblas_func = self.handle.get_function[
            fn (
                Int,
                Float32,
                UnsafePointer[Float32],
                Int,
                UnsafePointer[Float32],
                Int,
            ) -> Float32
        ]("cblas_sdsdot")
        return cblas_func(n, a, x, x_inc, y, y_inc)

    # double cblas_dsdot(const int N, const float *X, const int incX, const float *Y,
    #                    const int incY);
    fn dsdot(
        self,
        n: Int,
        a: Float32,
        x: UnsafePointer[Float32],
        x_inc: Int,
        y: UnsafePointer[Float32],
        y_inc: Int,
    ) raises -> Float64:
        if not self.handle.check_symbol("cblas_dsdot"):
            raise Error("Dynamic library does not contain cblas_dsdot")
        var cblas_func = self.handle.get_function[
            fn (
                Int,
                Float32,
                UnsafePointer[Float32],
                Int,
                UnsafePointer[Float32],
                Int,
            ) -> Float64
        ]("cblas_dsdot")
        return cblas_func(n, a, x, x_inc, y, y_inc)

    # float  cblas_sdot(const int N, const float  *X, const int incX,
    #                   const float  *Y, const int incY);
    fn sdot(
        self,
        n: Int,
        x: UnsafePointer[Float32],
        x_inc: Int,
        y: UnsafePointer[Float32],
        y_inc: Int,
    ) raises -> Float32:
        if not self.handle.check_symbol("cblas_sdot"):
            raise Error("Dynamic library does not contain cblas_sdot")
        var cblas_func = self.handle.get_function[
            fn (
                Int,
                UnsafePointer[Float32],
                Int,
                UnsafePointer[Float32],
                Int,
            ) -> Float32
        ]("cblas_sdot")
        return cblas_func(n, x, x_inc, y, y_inc)

    # double cblas_ddot(const int N, const double *X, const int incX,
    #                   const double *Y, const int incY);
    fn ddot(
        self,
        n: Int,
        x: UnsafePointer[Float64],
        x_inc: Int,
        y: UnsafePointer[Float64],
        y_inc: Int,
    ) raises -> Float64:
        if not self.handle.check_symbol("cblas_ddot"):
            raise Error("Dynamic library does not contain cblas_ddot")
        var cblas_func = self.handle.get_function[
            fn (
                Int,
                UnsafePointer[Float64],
                Int,
                UnsafePointer[Float64],
                Int,
            ) -> Float64
        ]("cblas_ddot")
        return cblas_func(n, x, x_inc, y, y_inc)


def main():
    var n: Int = 100
    var a: Float64 = 1
    var x = UnsafePointer[Float64].alloc(n.value)
    var x_inc: Int = 1
    var y = UnsafePointer[Float64].alloc(n.value)
    var y_inc: Int = 1

    for i in range(n):
        x[i] = i
        y[i] = i

    var cblas = CBLAS("/opt/homebrew/opt/openblas/lib/libopenblas.dylib")

    var res = cblas.ddot(n, x, x_inc, y, y_inc)

    print(res)
