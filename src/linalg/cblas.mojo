from sys.ffi import DLHandle
from os.path import isfile
from os.env import getenv

alias F32 = Float32
alias F64 = Float64


@value
struct C32:
    var real: F32
    var imaginary: F32

    fn __init__(inout self, r: F32, i: F32):
        self.real = r
        self.imaginary = i


@value
struct C64:
    var real: F64
    var imaginary: F64

    fn __init__(inout self, r: F64, i: F64):
        self.real = r
        self.imaginary = i


alias PF32 = UnsafePointer[F32]
alias PF64 = UnsafePointer[F64]
alias PC32 = UnsafePointer[C32]
alias PC64 = UnsafePointer[C64]


struct CBLAS:
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

    # float  cblas_sdsdot(const int N, const float alpha, const float *X, const int incX, const float *Y, const int incY);
    alias SDSDotType = fn (Int, F32, PF32, Int, PF32, Int) -> F32
    # double cblas_dsdot(const int N, const float *X, const int incX, const float *Y, const int incY);
    alias DSDotType = fn (Int, F32, PF32, Int, PF32, Int) -> F64
    # float  cblas_sdot(const int N, const float  *X, const int incX, const float  *Y, const int incY);
    alias SDotType = fn (Int, PF32, Int, PF32, Int) -> F32
    # double cblas_ddot(const int N, const double *X, const int incX, const double *Y, const int incY);
    alias DDotType = fn (Int, PF64, Int, PF64, Int) -> F64
    # void   cblas_cdotu_sub(const int N, const void *X, const int incX, const void *Y, const int incY, void *dotu);
    alias CDotUSubType = fn (Int, PC32, Int, PC32, Int, PC32) -> None
    # void   cblas_cdotc_sub(const int N, const void *X, const int incX, const void *Y, const int incY, void *dotc);
    alias CDotCSubType = fn (Int, PC32, Int, PC32, Int, PC32) -> None
    # void   cblas_zdotu_sub(const int N, const void *X, const int incX, const void *Y, const int incY, void *dotu);
    alias ZDotUSubType = fn (Int, PC64, Int, PC64, Int, PC64) -> None
    # void   cblas_zdotc_sub(const int N, const void *X, const int incX, const void *Y, const int incY, void *dotc);
    alias ZDotCSubType = fn (Int, PC64, Int, PC64, Int, PC64) -> None
    # float  cblas_snrm2(const int N, const float *X, const int incX);
    alias SNrm2Type = fn (Int, PF32, Int) -> F32
    # float  cblas_sasum(const int N, const float *X, const int incX);
    alias SASumType = fn (Int, PF32, Int) -> F32
    # double cblas_dnrm2(const int N, const double *X, const int incX);
    alias DNrm2Type = fn (Int, PF64, Int) -> F64
    # double cblas_dasum(const int N, const double *X, const int incX);
    alias DASumType = fn (Int, PF64, Int) -> F64
    # float  cblas_scnrm2(const int N, const void *X, const int incX);
    alias SCNrm2Type = fn (Int, PC32, Int) -> F32
    # float  cblas_scasum(const int N, const void *X, const int incX);
    alias SCASumType = fn (Int, PC32, Int) -> F32
    # double cblas_dznrm2(const int N, const void *X, const int incX);
    alias DZNrm2Type = fn (Int, PC64, Int) -> F64
    # double cblas_dzasum(const int N, const void *X, const int incX);
    alias DZASumType = fn (Int, PC64, Int) -> F64
    # CBLAS_INDEX cblas_isamax(const int N, const float  *X, const int incX);
    alias ISAMaxType = fn (Int, PF32, Int) -> Int
    # CBLAS_INDEX cblas_idamax(const int N, const double *X, const int incX);
    alias IDAMaxType = fn (Int, PF64, Int) -> Int
    # CBLAS_INDEX cblas_icamax(const int N, const void   *X, const int incX);
    alias ICAMaxType = fn (Int, PC32, Int) -> Int
    # CBLAS_INDEX cblas_izamax(const int N, const void   *X, const int incX);
    alias IZAMaxType = fn (Int, PC64, Int) -> Int
    # void cblas_sswap(const int N, float *X, const int incX, float *Y, const int incY);
    alias SSwapType = fn (Int, PF32, Int, PF32, Int) -> None
    # void cblas_scopy(const int N, const float *X, const int incX, float *Y, const int incY);
    alias SCopyType = fn (Int, PF32, Int, PF32, Int) -> None
    # void cblas_saxpy(const int N, const float alpha, const float *X, const int incX, float *Y, const int incY);
    alias SAxpyType = fn (Int, F32, PF32, Int, PF32, Int) -> None
    # void cblas_dswap(const int N, double *X, const int incX, double *Y, const int incY);
    alias DSwapType = fn (Int, PF64, Int, PF64, Int) -> None
    # void cblas_dcopy(const int N, const double *X, const int incX, double *Y, const int incY);
    alias DCopyType = fn (Int, PF64, Int, PF64, Int) -> None
    # void cblas_daxpy(const int N, const double alpha, const double *X, const int incX, double *Y, const int incY);
    alias DAxpyType = fn (Int, F64, PF64, Int, PF64, Int) -> None

    var sdsdot: Self.SDSDotType
    var dsdot: Self.DSDotType
    var sdot: Self.SDotType
    var ddot: Self.DDotType
    var cdotu_sub: Self.CDotUSubType
    var cdotc_sub: Self.CDotCSubType
    var zdotu_sub: Self.ZDotUSubType
    var zdotc_sub: Self.ZDotCSubType
    var snrm2: Self.SNrm2Type
    var sasum: Self.SASumType
    var dnrm2: Self.DNrm2Type
    var dasum: Self.DASumType
    var scnrm2: Self.SCNrm2Type
    var scasum: Self.SCASumType
    var dznrm2: Self.DZNrm2Type
    var dzasum: Self.DZASumType
    var isamax: Self.ISAMaxType
    var idamax: Self.IDAMaxType
    var icamax: Self.ICAMaxType
    var izamax: Self.IZAMaxType
    var sswap: Self.SSwapType
    var scopy: Self.SCopyType
    var saxpy: Self.SAxpyType
    var dswap: Self.DSwapType
    var dcopy: Self.DCopyType
    var daxpy: Self.DAxpyType

    var h: DLHandle

    fn __init__(inout self) raises:
        var path = getenv("MOJOSCI_CBLAS_DYNLIB_PATH")
        self.__init__(path)

    fn __init__(inout self, path: String) raises:
        if not isfile(path):
            raise Error("Path does not point to a file")
        self.h = DLHandle(path)
        if not self.h:
            raise Error("Cannot open dynamic library")

        self.sdsdot = self.h.get_function[Self.SDSDotType]("cblas_sdsdot")
        self.dsdot = self.h.get_function[Self.DSDotType]("cblas_dsdot")
        self.sdot = self.h.get_function[Self.SDotType]("cblas_sdot")
        self.ddot = self.h.get_function[Self.DDotType]("cblas_ddot")
        self.cdotu_sub = self.h.get_function[Self.CDotUSubType](
            "cblas_cdotu_sub"
        )
        self.cdotc_sub = self.h.get_function[Self.CDotCSubType](
            "cblas_cdotc_sub"
        )
        self.zdotu_sub = self.h.get_function[Self.ZDotUSubType](
            "cblas_zdotu_sub"
        )
        self.zdotc_sub = self.h.get_function[Self.ZDotCSubType](
            "cblas_zdotc_sub"
        )
        self.snrm2 = self.h.get_function[Self.SNrm2Type]("cblas_snrm2")
        self.sasum = self.h.get_function[Self.SASumType]("cblas_sasum")
        self.dnrm2 = self.h.get_function[Self.DNrm2Type]("cblas_dnrm2")
        self.dasum = self.h.get_function[Self.DASumType]("cblas_dasum")
        self.scnrm2 = self.h.get_function[Self.SCNrm2Type]("cblas_scnrm2")
        self.scasum = self.h.get_function[Self.SCASumType]("cblas_scasum")
        self.dznrm2 = self.h.get_function[Self.DZNrm2Type]("cblas_dznrm2")
        self.dzasum = self.h.get_function[Self.DZASumType]("cblas_dzasum")
        self.isamax = self.h.get_function[Self.ISAMaxType]("cblas_isamax")
        self.idamax = self.h.get_function[Self.IDAMaxType]("cblas_idamax")
        self.icamax = self.h.get_function[Self.ICAMaxType]("cblas_icamax")
        self.izamax = self.h.get_function[Self.IZAMaxType]("cblas_izamax")
        self.sswap = self.h.get_function[Self.SSwapType]("cblas_sswap")
        self.scopy = self.h.get_function[Self.SCopyType]("cblas_scopy")
        self.saxpy = self.h.get_function[Self.SAxpyType]("cblas_saxpy")
        self.dswap = self.h.get_function[Self.DSwapType]("cblas_dswap")
        self.dcopy = self.h.get_function[Self.DCopyType]("cblas_dcopy")
        self.daxpy = self.h.get_function[Self.DAxpyType]("cblas_daxpy")


from testing import *


def main():
    var n: Int = 3

    var cblas = CBLAS("/opt/homebrew/opt/openblas/lib/libopenblas.dylib")

    var x32 = PF32.alloc(n.value)
    var y32 = PF32.alloc(n.value)

    for i in range(n):
        x32[i] = i
        y32[i] = i

    sdsdot_res = cblas.sdsdot(n, 2, x32, 1, y32, 1)
    assert_equal(sdsdot_res, 7)

    var dsdot_res = cblas.dsdot(n, 2, x32, 1, y32, 1)
    assert_equal(dsdot_res, 5)

    var sdot_res = cblas.sdot(n, x32, 1, y32, 1)
    assert_equal(sdot_res, 5)

    var x64 = PF64.alloc(n.value)
    var y64 = PF64.alloc(n.value)

    for i in range(n):
        x64[i] = i
        y64[i] = i

    var ddot_res = cblas.ddot(n, x64, 1, y64, 1)
    assert_equal(ddot_res, 5)

    var cres32 = PC32.alloc(1)

    var xc32 = PC32.alloc(n.value)
    var yc32 = PC32.alloc(n.value)

    for i in range(n):
        xc32[i] = C32(i, i)
        yc32[i] = C32(i, i)

    cblas.cdotu_sub(n, xc32, 1, yc32, 1, cres32)
    print(cres32[0].real, cres32[0].imaginary)

    cblas.cdotc_sub(n, xc32, 1, yc32, 1, cres32)
    print(cres32[0].real, cres32[0].imaginary)

    var cres64 = PC64.alloc(1)

    var xc64 = PC64.alloc(n.value)
    var yc64 = PC64.alloc(n.value)

    for i in range(n):
        xc64[i] = C64(i, i)
        yc64[i] = C64(i, i)

    cblas.zdotu_sub(n, xc64, 1, yc64, 1, cres64)
    print(cres64[0].real, cres64[0].imaginary)

    cblas.zdotc_sub(n, xc64, 1, yc64, 1, cres64)
    print(cres64[0].real, cres64[0].imaginary)

    var snrm2_res = cblas.snrm2(n, x32, 1)
    print(snrm2_res)

    var sasum_res = cblas.sasum(n, y32, 1)
    print(sasum_res)

    var dnrm2_res = cblas.dnrm2(n, x64, 1)
    print(dnrm2_res)

    var dasum_res = cblas.dasum(n, y64, 1)
    print(dasum_res)

    var scnrm2_res = cblas.scnrm2(n, xc32, 1)
    print(scnrm2_res)

    var scasum_res = cblas.scasum(n, yc32, 1)
    print(scasum_res)

    var dznrm2_res = cblas.dznrm2(n, xc64, 1)
    print(dznrm2_res)

    var dzasum_res = cblas.dzasum(n, yc64, 1)
    print(dzasum_res)

    var isamax_res = cblas.isamax(n, x32, 1)
    print(isamax_res)

    var idamax_res = cblas.idamax(n, y64, 1)
    print(idamax_res)

    var icamax_res = cblas.icamax(n, xc32, 1)
    print(icamax_res)

    var izamax_res = cblas.izamax(n, yc64, 1)
    print(izamax_res)

    cblas.sswap(n, x32, 1, y32, 1)
    cblas.scopy(n, x32, 1, y32, 1)
    cblas.saxpy(n, 2, x32, 1, y32, 1)
    print(y32[2])

    cblas.dswap(n, x64, 1, y64, 1)
    cblas.dcopy(n, x64, 1, y64, 1)
    cblas.daxpy(n, 2, x64, 1, y64, 1)
    print(y64[2])
