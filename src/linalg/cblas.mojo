from sys.ffi import DLHandle
from os.path import isfile


struct CBLAS:
    var handle: DLHandle

    fn __init__(inout self, path: String) raises:
        if not isfile(path):
            raise Error("Provided path does not point to a file")
        self.handle = DLHandle(path)
        if not self.handle:
            raise Error("Path not recognized as a dynamic library")

    fn sdsdot(
        self,
        n: Int32,
        a: Float32,
        x: UnsafePointer[Float32],
        x_inc: Int32,
        y: UnsafePointer[Float32],
        y_inc: Int32,
    ) raises -> Float32:
        if not self.handle.check_symbol("cblas_sdsdot"):
            raise Error("Dynamic library does not contain cblas_sdsdot")
        var cblas_func = self.handle.get_function[
            fn (
                Int32,
                Float32,
                UnsafePointer[Float32],
                Int32,
                UnsafePointer[Float32],
                Int32,
            ) -> Float32
        ]("cblas_sdsdot")
        return cblas_func(n, a, x, x_inc, y, y_inc)

    fn dsdot(
        self,
        n: Int32,
        a: Float32,
        x: UnsafePointer[Float32],
        x_inc: Int32,
        y: UnsafePointer[Float32],
        y_inc: Int32,
    ) raises -> Float64:
        if not self.handle.check_symbol("cblas_dsdot"):
            raise Error("Dynamic library does not contain cblas_dsdot")
        var cblas_func = self.handle.get_function[
            fn (
                Int32,
                Float32,
                UnsafePointer[Float32],
                Int32,
                UnsafePointer[Float32],
                Int32,
            ) -> Float64
        ]("cblas_dsdot")
        return cblas_func(n, a, x, x_inc, y, y_inc)

    fn sdot(
        self,
        n: Int32,
        x: UnsafePointer[Float32],
        x_inc: Int32,
        y: UnsafePointer[Float32],
        y_inc: Int32,
    ) raises -> Float32:
        if not self.handle.check_symbol("cblas_sdot"):
            raise Error("Dynamic library does not contain cblas_sdot")
        var cblas_func = self.handle.get_function[
            fn (
                Int32,
                UnsafePointer[Float32],
                Int32,
                UnsafePointer[Float32],
                Int32,
            ) -> Float32
        ]("cblas_sdot")
        return cblas_func(n, x, x_inc, y, y_inc)

    fn ddot(
        self,
        n: Int32,
        x: UnsafePointer[Float64],
        x_inc: Int32,
        y: UnsafePointer[Float64],
        y_inc: Int32,
    ) raises -> Float64:
        if not self.handle.check_symbol("cblas_ddot"):
            raise Error("Dynamic library does not contain cblas_ddot")
        var cblas_func = self.handle.get_function[
            fn (
                Int32,
                UnsafePointer[Float64],
                Int32,
                UnsafePointer[Float64],
                Int32,
            ) -> Float64
        ]("cblas_ddot")
        return cblas_func(n, x, x_inc, y, y_inc)


def main():
    var n: Int32 = 100
    var a: Float64 = 1
    var x = UnsafePointer[Float64].alloc(n.value)
    var x_inc: Int32 = 1
    var y = UnsafePointer[Float64].alloc(n.value)
    var y_inc: Int32 = 1

    for i in range(n):
        x[i] = i
        y[i] = i

    var cblas = CBLAS("/opt/homebrew/opt/openblas/lib/libopenblas.dylib")

    var res = cblas.ddot(n, x, x_inc, y, y_inc)

    print(res)
