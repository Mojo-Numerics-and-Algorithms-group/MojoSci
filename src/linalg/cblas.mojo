from sys.ffi import DLHandle
from os.path import isfile
from os.env import getenv


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

    alias PF32 = UnsafePointer[Float32]
    alias PF64 = UnsafePointer[Float64]
    alias PC32 = UnsafePointer[(Float32, Float32)]
    alias PC64 = UnsafePointer[(Float64, Float64)]

    alias SdsdotType = fn (
        Int, Float32, Self.PF32, Int, Self.PF32, Int
    ) -> Float32
    alias DsdotType = fn (
        Int, Float32, Self.PF32, Int, Self.PF32, Int
    ) -> Float64
    alias SdotType = fn (Int, Self.PF32, Int, Self.PF32, Int) -> Float32
    alias DdotType = fn (Int, Self.PF64, Int, Self.PF64, Int) -> Float64
    alias CdotSubType = fn (
        Int, Self.PC32, Int, Self.PC32, Int, Self.PC32
    ) -> None
    alias ZdotSubType = fn (
        Int, Self.PC64, Int, Self.PC64, Int, Self.PC64
    ) -> None
    alias SReductType = fn (Int, Self.PF32, Int) -> Float32
    alias DReductType = fn (Int, Self.PF64, Int) -> Float64
    alias CReductType = fn (Int, Self.PC32, Int) -> Float32
    alias ZReductType = fn (Int, Self.PC64, Int) -> Float64
    alias SWhichType = fn (Int, Self.PF32, Int) -> Int
    alias DWhichType = fn (Int, Self.PF64, Int) -> Int
    alias CWhichType = fn (Int, Self.PC32, Int) -> Int
    alias ZWhichType = fn (Int, Self.PC64, Int) -> Int

    var handle: DLHandle
    var sdsdot: Self.SdsdotType
    var dsdot: Self.DsdotType
    var sdot: Self.SdotType
    var ddot: Self.DdotType
    var cdotc_sub: Self.CdotSubType
    var cdotu_sub: Self.CdotSubType
    var zdotc_sub: Self.ZdotSubType
    var zdotu_sub: Self.ZdotSubType
    var snrm2: Self.SReductType
    var sasum: Self.SReductType
    var dnrm2: Self.DReductType
    var dasum: Self.DReductType
    var scnrm2: Self.CReductType
    var scasum: Self.CReductType
    var dznrm2: Self.ZReductType
    var dzasum: Self.ZReductType
    var isamax: Self.SWhichType
    var idamax: Self.DWhichType
    var icamax: Self.CWhichType
    var izamax: Self.ZWhichType

    fn __init__(inout self) raises:
        var path = getenv("MOJOSCI_CBLAS_DYNLIB_PATH")
        self.__init__(path)

    fn __init__(inout self, path: String) raises:
        if not isfile(path):
            raise Error("Path does not point to a file")
        self.handle = DLHandle(path)
        if not self.handle:
            raise Error("Cannot open dynamic library")
        var h = self.handle
        # float  cblas_sdsdot(const int N, const float alpha, const float *X,
        #                     const int incX, const float *Y, const int incY);
        self.sdsdot = h.get_function[Self.SdsdotType]("cblas_sdsdot")
        # double cblas_dsdot(const int N, const float *X, const int incX, const float *Y,
        #                    const int incY);
        self.dsdot = h.get_function[Self.DsdotType]("cblas_dsdot")
        # float  cblas_sdot(const int N, const float  *X, const int incX,
        #                   const float  *Y, const int incY);
        self.sdot = h.get_function[Self.SdotType]("cblas_sdot")
        # double cblas_ddot(const int N, const double *X, const int incX,
        #                   const double *Y, const int incY);
        self.ddot = h.get_function[Self.DdotType]("cblas_ddot")
        # void   cblas_cdotu_sub(const int N, const void *X, const int incX,
        #                        const void *Y, const int incY, void *dotu);
        self.cdotu_sub = h.get_function[Self.CdotSubType]("cblas_cdotu_sub")
        # void   cblas_cdotc_sub(const int N, const void *X, const int incX,
        #                        const void *Y, const int incY, void *dotc);
        self.cdotc_sub = h.get_function[Self.CdotSubType]("cblas_cdotc_sub")
        # void   cblas_zdotu_sub(const int N, const void *X, const int incX,
        #                        const void *Y, const int incY, void *dotu);
        self.zdotu_sub = h.get_function[Self.ZdotSubType]("cblas_zdotu_sub")
        # void   cblas_zdotc_sub(const int N, const void *X, const int incX,
        #                        const void *Y, const int incY, void *dotc);
        self.zdotc_sub = h.get_function[Self.ZdotSubType]("cblas_zdotc_sub")
        # float  cblas_snrm2(const int N, const float *X, const int incX);
        self.snrm2 = h.get_function[Self.SReductType]("cblas_snrm2")
        # float  cblas_sasum(const int N, const float *X, const int incX);
        self.sasum = h.get_function[Self.SReductType]("cblas_sasum")
        # double cblas_dnrm2(const int N, const double *X, const int incX);
        self.dnrm2 = h.get_function[Self.DReductType]("cblas_dnrm2")
        # double cblas_dasum(const int N, const double *X, const int incX);
        self.dasum = h.get_function[Self.DReductType]("cblas_dasum")
        # float  cblas_scnrm2(const int N, const void *X, const int incX);
        self.scnrm2 = h.get_function[Self.CReductType]("cblas_scnrm2")
        # float  cblas_scasum(const int N, const void *X, const int incX);
        self.scasum = h.get_function[Self.CReductType]("cblas_scasum")
        # double cblas_dznrm2(const int N, const void *X, const int incX);
        self.dznrm2 = h.get_function[Self.ZReductType]("cblas_dznrm2")
        # double cblas_dzasum(const int N, const void *X, const int incX);
        self.dzasum = h.get_function[Self.ZReductType]("cblas_dzasum")
        # CBLAS_INDEX cblas_isamax(const int N, const float  *X, const int incX);
        self.isamax = h.get_function[Self.SWhichType]("cblas_isamax")
        # CBLAS_INDEX cblas_idamax(const int N, const double *X, const int incX);
        self.idamax = h.get_function[Self.DWhichType]("cblas_idamax")
        # CBLAS_INDEX cblas_icamax(const int N, const void   *X, const int incX);
        self.icamax = h.get_function[Self.CWhichType]("cblas_icamax")
        # CBLAS_INDEX cblas_izamax(const int N, const void   *X, const int incX);
        self.izamax = h.get_function[Self.ZWhichType]("cblas_izamax")


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
