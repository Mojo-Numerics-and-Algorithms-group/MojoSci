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

from sys.ffi import DLHandle
from os.path.path import isfile
from os.env import getenv

from testing.testing import Testable

alias F32 = Float32
alias F64 = Float64


@value
struct C32(Testable):
    var real: F32
    var imaginary: F32

    fn __init__(inout self, r: F32, i: F32):
        self.real = r
        self.imaginary = i

    fn __eq__(self, other: Self) -> Bool:
        return self.real == other.real and self.imaginary == other.imaginary

    fn __ne__(self, other: Self) -> Bool:
        return self.real != other.real or self.imaginary != other.imaginary

    fn __str__(self) -> String:
        return str(self.real) + " + " + str(self.imaginary) + "i"


@value
struct C64(Testable):
    var real: F64
    var imaginary: F64

    fn __init__(inout self, r: F64, i: F64):
        self.real = r
        self.imaginary = i

    fn __eq__(self, other: Self) -> Bool:
        return self.real == other.real and self.imaginary == other.imaginary

    fn __ne__(self, other: Self) -> Bool:
        return self.real != other.real or self.imaginary != other.imaginary

    fn __str__(self) -> String:
        return str(self.real) + " + " + str(self.imaginary) + "i"


alias PF32 = UnsafePointer[F32]
alias PF64 = UnsafePointer[F64]
alias PC32 = UnsafePointer[C32]
alias PC64 = UnsafePointer[C64]


struct CBLAS:
    alias Order_Rowmajor = 101
    alias Order_Colmajor = 102
    alias Transpose_Notrans = 111
    alias Transpose_Trans = 112
    alias Transpose_Conjtrans = 113
    alias Uplo_Upper = 121
    alias Uplo_Lower = 122
    alias Diag_Nonunit = 131
    alias Diag_Unit = 132
    alias Side_Left = 141
    alias Side_Right = 142
    # { float cblas_sdsdot(const int N, const float alpha, const float *X, const int incX, const float *Y, const int incY);
    alias SdsdotType = fn (Int, F32, PF32, Int, PF32, Int) -> F32
    # double cblas_dsdot(const int N, const float *X, const int incX, const float *Y, const int incY);
    alias DsdotType = fn (Int, PF32, Int, PF32, Int) -> F64
    # float cblas_sdot(const int N, const float *X, const int incX, const float *Y, const int incY);
    alias SdotType = fn (Int, PF32, Int, PF32, Int) -> F32
    # double cblas_ddot(const int N, const double *X, const int incX, const double *Y, const int incY);
    alias DdotType = fn (Int, PF64, Int, PF64, Int) -> F64
    # void cblas_cdotu_sub(const int N, const void *X, const int incX, const void *Y, const int incY, void *dotu);
    alias CdotuSubType = fn (Int, PC32, Int, PC32, Int, PC32) -> None
    # void cblas_cdotc_sub(const int N, const void *X, const int incX, const void *Y, const int incY, void *dotc);
    alias CdotcSubType = fn (Int, PC32, Int, PC32, Int, PC32) -> None
    # void cblas_zdotu_sub(const int N, const void *X, const int incX, const void *Y, const int incY, void *dotu);
    alias ZdotuSubType = fn (Int, PC64, Int, PC64, Int, PC64) -> None
    # void cblas_zdotc_sub(const int N, const void *X, const int incX, const void *Y, const int incY, void *dotc);
    alias ZdotcSubType = fn (Int, PC64, Int, PC64, Int, PC64) -> None
    # float cblas_snrm2(const int N, const float *X, const int incX);
    alias Snrm2Type = fn (Int, PF32, Int) -> F32
    # float cblas_sasum(const int N, const float *X, const int incX);
    alias SasumType = fn (Int, PF32, Int) -> F32
    # double cblas_dnrm2(const int N, const double *X, const int incX);
    alias Dnrm2Type = fn (Int, PF64, Int) -> F64
    # double cblas_dasum(const int N, const double *X, const int incX);
    alias DasumType = fn (Int, PF64, Int) -> F64
    # float cblas_scnrm2(const int N, const void *X, const int incX);
    alias Scnrm2Type = fn (Int, PC32, Int) -> F32
    # float cblas_scasum(const int N, const void *X, const int incX);
    alias ScasumType = fn (Int, PC32, Int) -> F32
    # double cblas_dznrm2(const int N, const void *X, const int incX);
    alias Dznrm2Type = fn (Int, PC64, Int) -> F64
    # double cblas_dzasum(const int N, const void *X, const int incX);
    alias DzasumType = fn (Int, PC64, Int) -> F64
    # CBLAS_INDEX cblas_isamax(const int N, const float *X, const int incX);
    alias IsamaxType = fn (Int, PF32, Int) -> Int
    # CBLAS_INDEX cblas_idamax(const int N, const double *X, const int incX);
    alias IdamaxType = fn (Int, PF64, Int) -> Int
    # CBLAS_INDEX cblas_icamax(const int N, const void *X, const int incX);
    alias IcamaxType = fn (Int, PC32, Int) -> Int
    # CBLAS_INDEX cblas_izamax(const int N, const void *X, const int incX);
    alias IzamaxType = fn (Int, PC64, Int) -> Int
    # void cblas_sswap(const int N, float *X, const int incX, float *Y, const int incY);
    alias SswapType = fn (Int, PF32, Int, PF32, Int) -> None
    # void cblas_scopy(const int N, const float *X, const int incX, float *Y, const int incY);
    alias ScopyType = fn (Int, PF32, Int, PF32, Int) -> None
    # void cblas_saxpy(const int N, const float alpha, const float *X, const int incX, float *Y, const int incY);
    alias SaxpyType = fn (Int, F32, PF32, Int, PF32, Int) -> None
    # void cblas_dswap(const int N, double *X, const int incX, double *Y, const int incY);
    alias DswapType = fn (Int, PF64, Int, PF64, Int) -> None
    # void cblas_dcopy(const int N, const double *X, const int incX, double *Y, const int incY);
    alias DcopyType = fn (Int, PF64, Int, PF64, Int) -> None
    # void cblas_daxpy(const int N, const double alpha, const double *X, const int incX, double *Y, const int incY);
    alias DaxpyType = fn (Int, F64, PF64, Int, PF64, Int) -> None
    # void cblas_cswap(const int N, void *X, const int incX, void *Y, const int incY);
    alias CswapType = fn (Int, PC32, Int, PC32, Int) -> None
    # void cblas_ccopy(const int N, const void *X, const int incX, void *Y, const int incY);
    alias CcopyType = fn (Int, PC32, Int, PC32, Int) -> None
    # void cblas_caxpy(const int N, const void *alpha, const void *X, const int incX, void *Y, const int incY);
    alias CaxpyType = fn (Int, PC32, PC32, Int, PC32, Int) -> None
    # void cblas_zswap(const int N, void *X, const int incX, void *Y, const int incY);
    alias ZswapType = fn (Int, PC64, Int, PC64, Int) -> None
    # void cblas_zcopy(const int N, const void *X, const int incX, void *Y, const int incY);
    alias ZcopyType = fn (Int, PC64, Int, PC64, Int) -> None
    # void cblas_zaxpy(const int N, const void *alpha, const void *X, const int incX, void *Y, const int incY);
    alias ZaxpyType = fn (Int, PC64, PC64, Int, PC64, Int) -> None
    # void cblas_srotg(float *a, float *b, float *c, float *s);
    alias SrotgType = fn (PF32, PF32, PF32, PF32) -> None
    # void cblas_srotmg(float *d1, float *d2, float *b1, const float b2, float *P);
    alias SrotmgType = fn (PF32, PF32, PF32, F32, PF32) -> None
    # void cblas_srot(const int N, float *X, const int incX, float *Y, const int incY, const float c, const float s);
    alias SrotType = fn (Int, PF32, Int, PF32, Int, F32, F32) -> None
    # void cblas_srotm(const int N, float *X, const int incX, float *Y, const int incY, const float *P);
    alias SrotmType = fn (Int, PF32, Int, PF32, Int, PF32) -> None
    # void cblas_drotg(double *a, double *b, double *c, double *s);
    alias DrotgType = fn (PF64, PF64, PF64, PF64) -> None
    # void cblas_drotmg(double *d1, double *d2, double *b1, const double b2, double *P);
    alias DrotmgType = fn (PF64, PF64, PF64, F64, PF64) -> None
    # void cblas_drot(const int N, double *X, const int incX, double *Y, const int incY, const double c, const double s);
    alias DrotType = fn (Int, PF64, Int, PF64, Int, F64, F64) -> None
    # void cblas_drotm(const int N, double *X, const int incX, double *Y, const int incY, const double *P);
    alias DrotmType = fn (Int, PF64, Int, PF64, Int, PF64) -> None
    # void cblas_sscal(const int N, const float alpha, float *X, const int incX);
    alias SscalType = fn (Int, F32, PF32, Int) -> None
    # void cblas_dscal(const int N, const double alpha, double *X, const int incX);
    alias DscalType = fn (Int, F64, PF64, Int) -> None
    # void cblas_cscal(const int N, const void *alpha, void *X, const int incX);
    alias CscalType = fn (Int, PC32, PC32, Int) -> None
    # void cblas_zscal(const int N, const void *alpha, void *X, const int incX);
    alias ZscalType = fn (Int, PC64, PC64, Int) -> None
    # void cblas_csscal(const int N, const float alpha, void *X, const int incX);
    alias CsscalType = fn (Int, F32, PC32, Int) -> None
    # void cblas_zdscal(const int N, const double alpha, void *X, const int incX);
    alias ZdscalType = fn (Int, F64, PC64, Int) -> None
    # void cblas_sgemv(const enum CBLAS_ORDER order, const enum CBLAS_TRANSPOSE TransA, const int M, const int N, const float alpha, const float *A, const int lda, const float *X, const int incX, const float beta, float *Y, const int incY);
    alias SgemvType = fn (
        Int, Int, Int, Int, F32, PF32, Int, PF32, Int, F32, PF32, Int
    ) -> None
    # void cblas_sgbmv(const enum CBLAS_ORDER order, const enum CBLAS_TRANSPOSE TransA, const int M, const int N, const int KL, const int KU, const float alpha, const float *A, const int lda, const float *X, const int incX, const float beta, float *Y, const int incY);
    alias SgbmvType = fn (
        Int, Int, Int, Int, Int, Int, F32, PF32, Int, PF32, Int, F32, PF32, Int
    ) -> None
    # void cblas_strmv(const enum CBLAS_ORDER order, const enum CBLAS_UPLO Uplo, const enum CBLAS_TRANSPOSE TransA, const enum CBLAS_DIAG Diag, const int N, const float *A, const int lda, float *X, const int incX);
    alias StrmvType = fn (Int, Int, Int, Int, Int, PF32, Int, PF32, Int) -> None
    # void cblas_stbmv(const enum CBLAS_ORDER order, const enum CBLAS_UPLO Uplo, const enum CBLAS_TRANSPOSE TransA, const enum CBLAS_DIAG Diag, const int N, const int K, const float *A, const int lda, float *X, const int incX);
    alias StbmvType = fn (
        Int, Int, Int, Int, Int, Int, PF32, Int, PF32, Int
    ) -> None
    # void cblas_stpmv(const enum CBLAS_ORDER order, const enum CBLAS_UPLO Uplo, const enum CBLAS_TRANSPOSE TransA, const enum CBLAS_DIAG Diag, const int N, const float *Ap, float *X, const int incX);
    alias StpmvType = fn (Int, Int, Int, Int, Int, PF32, PF32, Int) -> None
    # void cblas_strsv(const enum CBLAS_ORDER order, const enum CBLAS_UPLO Uplo, const enum CBLAS_TRANSPOSE TransA, const enum CBLAS_DIAG Diag, const int N, const float *A, const int lda, float *X, const int incX);
    alias StrsvType = fn (Int, Int, Int, Int, Int, PF32, Int, PF32, Int) -> None
    # void cblas_stbsv(const enum CBLAS_ORDER order, const enum CBLAS_UPLO Uplo, const enum CBLAS_TRANSPOSE TransA, const enum CBLAS_DIAG Diag, const int N, const int K, const float *A, const int lda, float *X, const int incX);
    alias StbsvType = fn (
        Int, Int, Int, Int, Int, Int, PF32, Int, PF32, Int
    ) -> None
    # void cblas_stpsv(const enum CBLAS_ORDER order, const enum CBLAS_UPLO Uplo, const enum CBLAS_TRANSPOSE TransA, const enum CBLAS_DIAG Diag, const int N, const float *Ap, float *X, const int incX);
    alias StpsvType = fn (Int, Int, Int, Int, Int, PF32, PF32, Int) -> None
    # void cblas_dgemv(const enum CBLAS_ORDER order, const enum CBLAS_TRANSPOSE TransA, const int M, const int N, const double alpha, const double *A, const int lda, const double *X, const int incX, const double beta, double *Y, const int incY);
    alias DgemvType = fn (
        Int, Int, Int, Int, F64, PF64, Int, PF64, Int, F64, PF64, Int
    ) -> None
    # void cblas_dgbmv(const enum CBLAS_ORDER order, const enum CBLAS_TRANSPOSE TransA, const int M, const int N, const int KL, const int KU, const double alpha, const double *A, const int lda, const double *X, const int incX, const double beta, double *Y, const int incY);
    alias DgbmvType = fn (
        Int, Int, Int, Int, Int, Int, F64, PF64, Int, PF64, Int, F64, PF64, Int
    ) -> None
    # void cblas_dtrmv(const enum CBLAS_ORDER order, const enum CBLAS_UPLO Uplo, const enum CBLAS_TRANSPOSE TransA, const enum CBLAS_DIAG Diag, const int N, const double *A, const int lda, double *X, const int incX);
    alias DtrmvType = fn (Int, Int, Int, Int, Int, PF64, Int, PF64, Int) -> None
    # void cblas_dtbmv(const enum CBLAS_ORDER order, const enum CBLAS_UPLO Uplo, const enum CBLAS_TRANSPOSE TransA, const enum CBLAS_DIAG Diag, const int N, const int K, const double *A, const int lda, double *X, const int incX);
    alias DtbmvType = fn (
        Int, Int, Int, Int, Int, Int, PF64, Int, PF64, Int
    ) -> None
    # void cblas_dtpmv(const enum CBLAS_ORDER order, const enum CBLAS_UPLO Uplo, const enum CBLAS_TRANSPOSE TransA, const enum CBLAS_DIAG Diag, const int N, const double *Ap, double *X, const int incX);
    alias DtpmvType = fn (Int, Int, Int, Int, Int, PF64, PF64, Int) -> None
    # void cblas_dtrsv(const enum CBLAS_ORDER order, const enum CBLAS_UPLO Uplo, const enum CBLAS_TRANSPOSE TransA, const enum CBLAS_DIAG Diag, const int N, const double *A, const int lda, double *X, const int incX);
    alias DtrsvType = fn (Int, Int, Int, Int, Int, PF64, Int, PF64, Int) -> None
    # void cblas_dtbsv(const enum CBLAS_ORDER order, const enum CBLAS_UPLO Uplo, const enum CBLAS_TRANSPOSE TransA, const enum CBLAS_DIAG Diag, const int N, const int K, const double *A, const int lda, double *X, const int incX);
    alias DtbsvType = fn (
        Int, Int, Int, Int, Int, Int, PF64, Int, PF64, Int
    ) -> None
    # void cblas_dtpsv(const enum CBLAS_ORDER order, const enum CBLAS_UPLO Uplo, const enum CBLAS_TRANSPOSE TransA, const enum CBLAS_DIAG Diag, const int N, const double *Ap, double *X, const int incX);
    alias DtpsvType = fn (Int, Int, Int, Int, Int, PF64, PF64, Int) -> None
    # void cblas_cgemv(const enum CBLAS_ORDER order, const enum CBLAS_TRANSPOSE TransA, const int M, const int N, const void *alpha, const void *A, const int lda, const void *X, const int incX, const void *beta, void *Y, const int incY);
    alias CgemvType = fn (
        Int, Int, Int, Int, PC32, PC32, Int, PC32, Int, PC32, PC32, Int
    ) -> None
    # void cblas_cgbmv(const enum CBLAS_ORDER order, const enum CBLAS_TRANSPOSE TransA, const int M, const int N, const int KL, const int KU, const void *alpha, const void *A, const int lda, const void *X, const int incX, const void *beta, void *Y, const int incY);
    alias CgbmvType = fn (
        Int,
        Int,
        Int,
        Int,
        Int,
        Int,
        PC32,
        PC32,
        Int,
        PC32,
        Int,
        PC32,
        PC32,
        Int,
    ) -> None
    # void cblas_ctrmv(const enum CBLAS_ORDER order, const enum CBLAS_UPLO Uplo, const enum CBLAS_TRANSPOSE TransA, const enum CBLAS_DIAG Diag, const int N, const void *A, const int lda, void *X, const int incX);
    alias CtrmvType = fn (Int, Int, Int, Int, Int, PC32, Int, PC32, Int) -> None
    # void cblas_ctbmv(const enum CBLAS_ORDER order, const enum CBLAS_UPLO Uplo, const enum CBLAS_TRANSPOSE TransA, const enum CBLAS_DIAG Diag, const int N, const int K, const void *A, const int lda, void *X, const int incX);
    alias CtbmvType = fn (
        Int, Int, Int, Int, Int, Int, PC32, Int, PC32, Int
    ) -> None
    # void cblas_ctpmv(const enum CBLAS_ORDER order, const enum CBLAS_UPLO Uplo, const enum CBLAS_TRANSPOSE TransA, const enum CBLAS_DIAG Diag, const int N, const void *Ap, void *X, const int incX);
    alias CtpmvType = fn (Int, Int, Int, Int, Int, PC32, PC32, Int) -> None
    # void cblas_ctrsv(const enum CBLAS_ORDER order, const enum CBLAS_UPLO Uplo, const enum CBLAS_TRANSPOSE TransA, const enum CBLAS_DIAG Diag, const int N, const void *A, const int lda, void *X, const int incX);
    alias CtrsvType = fn (Int, Int, Int, Int, Int, PC32, Int, PC32, Int) -> None
    # void cblas_ctbsv(const enum CBLAS_ORDER order, const enum CBLAS_UPLO Uplo, const enum CBLAS_TRANSPOSE TransA, const enum CBLAS_DIAG Diag, const int N, const int K, const void *A, const int lda, void *X, const int incX);
    alias CtbsvType = fn (
        Int, Int, Int, Int, Int, Int, PC32, Int, PC32, Int
    ) -> None
    # void cblas_ctpsv(const enum CBLAS_ORDER order, const enum CBLAS_UPLO Uplo, const enum CBLAS_TRANSPOSE TransA, const enum CBLAS_DIAG Diag, const int N, const void *Ap, void *X, const int incX);
    alias CtpsvType = fn (Int, Int, Int, Int, Int, PC32, PC32, Int) -> None
    # void cblas_zgemv(const enum CBLAS_ORDER order, const enum CBLAS_TRANSPOSE TransA, const int M, const int N, const void *alpha, const void *A, const int lda, const void *X, const int incX, const void *beta, void *Y, const int incY);
    alias ZgemvType = fn (
        Int, Int, Int, Int, PC64, PC64, Int, PC64, Int, PC64, PC64, Int
    ) -> None
    # void cblas_zgbmv(const enum CBLAS_ORDER order, const enum CBLAS_TRANSPOSE TransA, const int M, const int N, const int KL, const int KU, const void *alpha, const void *A, const int lda, const void *X, const int incX, const void *beta, void *Y, const int incY);
    alias ZgbmvType = fn (
        Int,
        Int,
        Int,
        Int,
        Int,
        Int,
        PC64,
        PC64,
        Int,
        PC64,
        Int,
        PC64,
        PC64,
        Int,
    ) -> None
    # void cblas_ztrmv(const enum CBLAS_ORDER order, const enum CBLAS_UPLO Uplo, const enum CBLAS_TRANSPOSE TransA, const enum CBLAS_DIAG Diag, const int N, const void *A, const int lda, void *X, const int incX);
    alias ZtrmvType = fn (Int, Int, Int, Int, Int, PC64, Int, PC64, Int) -> None
    # void cblas_ztbmv(const enum CBLAS_ORDER order, const enum CBLAS_UPLO Uplo, const enum CBLAS_TRANSPOSE TransA, const enum CBLAS_DIAG Diag, const int N, const int K, const void *A, const int lda, void *X, const int incX);
    alias ZtbmvType = fn (
        Int, Int, Int, Int, Int, Int, PC64, Int, PC64, Int
    ) -> None
    # void cblas_ztpmv(const enum CBLAS_ORDER order, const enum CBLAS_UPLO Uplo, const enum CBLAS_TRANSPOSE TransA, const enum CBLAS_DIAG Diag, const int N, const void *Ap, void *X, const int incX);
    alias ZtpmvType = fn (Int, Int, Int, Int, Int, PC64, PC64, Int) -> None
    # void cblas_ztrsv(const enum CBLAS_ORDER order, const enum CBLAS_UPLO Uplo, const enum CBLAS_TRANSPOSE TransA, const enum CBLAS_DIAG Diag, const int N, const void *A, const int lda, void *X, const int incX);
    alias ZtrsvType = fn (Int, Int, Int, Int, Int, PC64, Int, PC64, Int) -> None
    # void cblas_ztbsv(const enum CBLAS_ORDER order, const enum CBLAS_UPLO Uplo, const enum CBLAS_TRANSPOSE TransA, const enum CBLAS_DIAG Diag, const int N, const int K, const void *A, const int lda, void *X, const int incX);
    alias ZtbsvType = fn (
        Int, Int, Int, Int, Int, Int, PC64, Int, PC64, Int
    ) -> None
    # void cblas_ztpsv(const enum CBLAS_ORDER order, const enum CBLAS_UPLO Uplo, const enum CBLAS_TRANSPOSE TransA, const enum CBLAS_DIAG Diag, const int N, const void *Ap, void *X, const int incX);
    alias ZtpsvType = fn (Int, Int, Int, Int, Int, PC64, PC64, Int) -> None
    # void cblas_ssymv(const enum CBLAS_ORDER order, const enum CBLAS_UPLO Uplo, const int N, const float alpha, const float *A, const int lda, const float *X, const int incX, const float beta, float *Y, const int incY);
    alias SsymvType = fn (
        Int, Int, Int, F32, PF32, Int, PF32, Int, F32, PF32, Int
    ) -> None
    # void cblas_ssbmv(const enum CBLAS_ORDER order, const enum CBLAS_UPLO Uplo, const int N, const int K, const float alpha, const float *A, const int lda, const float *X, const int incX, const float beta, float *Y, const int incY);
    alias SsbmvType = fn (
        Int, Int, Int, Int, F32, PF32, Int, PF32, Int, F32, PF32, Int
    ) -> None
    # void cblas_sspmv(const enum CBLAS_ORDER order, const enum CBLAS_UPLO Uplo, const int N, const float alpha, const float *Ap, const float *X, const int incX, const float beta, float *Y, const int incY);
    alias SspmvType = fn (
        Int, Int, Int, F32, PF32, PF32, Int, F32, PF32, Int
    ) -> None
    # void cblas_sger(const enum CBLAS_ORDER order, const int M, const int N, const float alpha, const float *X, const int incX, const float *Y, const int incY, float *A, const int lda);
    alias SgerType = fn (
        Int, Int, Int, F32, PF32, Int, PF32, Int, PF32, Int
    ) -> None
    # void cblas_ssyr(const enum CBLAS_ORDER order, const enum CBLAS_UPLO Uplo, const int N, const float alpha, const float *X, const int incX, float *A, const int lda);
    alias SsyrType = fn (Int, Int, Int, F32, PF32, Int, PF32, Int) -> None
    # void cblas_sspr(const enum CBLAS_ORDER order, const enum CBLAS_UPLO Uplo, const int N, const float alpha, const float *X, const int incX, float *Ap);
    alias SsprType = fn (Int, Int, Int, F32, PF32, Int, PF32) -> None
    # void cblas_ssyr2(const enum CBLAS_ORDER order, const enum CBLAS_UPLO Uplo, const int N, const float alpha, const float *X, const int incX, const float *Y, const int incY, float *A, const int lda);
    alias Ssyr2Type = fn (
        Int, Int, Int, F32, PF32, Int, PF32, Int, PF32, Int
    ) -> None
    # void cblas_sspr2(const enum CBLAS_ORDER order, const enum CBLAS_UPLO Uplo, const int N, const float alpha, const float *X, const int incX, const float *Y, const int incY, float *A);
    alias Sspr2Type = fn (
        Int, Int, Int, F32, PF32, Int, PF32, Int, PF32
    ) -> None
    # void cblas_dsymv(const enum CBLAS_ORDER order, const enum CBLAS_UPLO Uplo, const int N, const double alpha, const double *A, const int lda, const double *X, const int incX, const double beta, double *Y, const int incY);
    alias DsymvType = fn (
        Int, Int, Int, F64, PF64, Int, PF64, Int, F64, PF64, Int
    ) -> None
    # void cblas_dsbmv(const enum CBLAS_ORDER order, const enum CBLAS_UPLO Uplo, const int N, const int K, const double alpha, const double *A, const int lda, const double *X, const int incX, const double beta, double *Y, const int incY);
    alias DsbmvType = fn (
        Int, Int, Int, Int, F64, PF64, Int, PF64, Int, F64, PF64, Int
    ) -> None
    # void cblas_dspmv(const enum CBLAS_ORDER order, const enum CBLAS_UPLO Uplo, const int N, const double alpha, const double *Ap, const double *X, const int incX, const double beta, double *Y, const int incY);
    alias DspmvType = fn (
        Int, Int, Int, F64, PF64, PF64, Int, F64, PF64, Int
    ) -> None
    # void cblas_dger(const enum CBLAS_ORDER order, const int M, const int N, const double alpha, const double *X, const int incX, const double *Y, const int incY, double *A, const int lda);
    alias DgerType = fn (
        Int, Int, Int, F64, PF64, Int, PF64, Int, PF64, Int
    ) -> None
    # void cblas_dsyr(const enum CBLAS_ORDER order, const enum CBLAS_UPLO Uplo, const int N, const double alpha, const double *X, const int incX, double *A, const int lda);
    alias DsyrType = fn (Int, Int, Int, F64, PF64, Int, PF64, Int) -> None
    # void cblas_dspr(const enum CBLAS_ORDER order, const enum CBLAS_UPLO Uplo, const int N, const double alpha, const double *X, const int incX, double *Ap);
    alias DsprType = fn (Int, Int, Int, F64, PF64, Int, PF64) -> None
    # void cblas_dsyr2(const enum CBLAS_ORDER order, const enum CBLAS_UPLO Uplo, const int N, const double alpha, const double *X, const int incX, const double *Y, const int incY, double *A, const int lda);
    alias Dsyr2Type = fn (
        Int, Int, Int, F64, PF64, Int, PF64, Int, PF64, Int
    ) -> None
    # void cblas_dspr2(const enum CBLAS_ORDER order, const enum CBLAS_UPLO Uplo, const int N, const double alpha, const double *X, const int incX, const double *Y, const int incY, double *A);
    alias Dspr2Type = fn (
        Int, Int, Int, F64, PF64, Int, PF64, Int, PF64
    ) -> None
    # void cblas_chemv(const enum CBLAS_ORDER order, const enum CBLAS_UPLO Uplo, const int N, const void *alpha, const void *A, const int lda, const void *X, const int incX, const void *beta, void *Y, const int incY);
    alias ChemvType = fn (
        Int, Int, Int, PC32, PC32, Int, PC32, Int, PC32, PC32, Int
    ) -> None
    # void cblas_chbmv(const enum CBLAS_ORDER order, const enum CBLAS_UPLO Uplo, const int N, const int K, const void *alpha, const void *A, const int lda, const void *X, const int incX, const void *beta, void *Y, const int incY);
    alias ChbmvType = fn (
        Int, Int, Int, Int, PC32, PC32, Int, PC32, Int, PC32, PC32, Int
    ) -> None
    # void cblas_chpmv(const enum CBLAS_ORDER order, const enum CBLAS_UPLO Uplo, const int N, const void *alpha, const void *Ap, const void *X, const int incX, const void *beta, void *Y, const int incY);
    alias ChpmvType = fn (
        Int, Int, Int, PC32, PC32, PC32, Int, PC32, PC32, Int
    ) -> None
    # void cblas_cgeru(const enum CBLAS_ORDER order, const int M, const int N, const void *alpha, const void *X, const int incX, const void *Y, const int incY, void *A, const int lda);
    alias CgeruType = fn (
        Int, Int, Int, PC32, PC32, Int, PC32, Int, PC32, Int
    ) -> None
    # void cblas_cgerc(const enum CBLAS_ORDER order, const int M, const int N, const void *alpha, const void *X, const int incX, const void *Y, const int incY, void *A, const int lda);
    alias CgercType = fn (
        Int, Int, Int, PC32, PC32, Int, PC32, Int, PC32, Int
    ) -> None
    # void cblas_cher(const enum CBLAS_ORDER order, const enum CBLAS_UPLO Uplo, const int N, const float alpha, const void *X, const int incX, void *A, const int lda);
    alias CherType = fn (Int, Int, Int, F32, PC32, Int, PC32, Int) -> None
    # void cblas_chpr(const enum CBLAS_ORDER order, const enum CBLAS_UPLO Uplo, const int N, const float alpha, const void *X, const int incX, void *A);
    alias ChprType = fn (Int, Int, Int, F32, PC32, Int, PC32) -> None
    # void cblas_cher2(const enum CBLAS_ORDER order, const enum CBLAS_UPLO Uplo, const int N, const void *alpha, const void *X, const int incX, const void *Y, const int incY, void *A, const int lda);
    alias Cher2Type = fn (
        Int, Int, Int, PC32, PC32, Int, PC32, Int, PC32, Int
    ) -> None
    # void cblas_chpr2(const enum CBLAS_ORDER order, const enum CBLAS_UPLO Uplo, const int N, const void *alpha, const void *X, const int incX, const void *Y, const int incY, void *Ap);
    alias Chpr2Type = fn (
        Int, Int, Int, PC32, PC32, Int, PC32, Int, PC32
    ) -> None
    # void cblas_zhemv(const enum CBLAS_ORDER order, const enum CBLAS_UPLO Uplo, const int N, const void *alpha, const void *A, const int lda, const void *X, const int incX, const void *beta, void *Y, const int incY);
    alias ZhemvType = fn (
        Int, Int, Int, PC64, PC64, Int, PC64, Int, PC64, PC64, Int
    ) -> None
    # void cblas_zhbmv(const enum CBLAS_ORDER order, const enum CBLAS_UPLO Uplo, const int N, const int K, const void *alpha, const void *A, const int lda, const void *X, const int incX, const void *beta, void *Y, const int incY);
    alias ZhbmvType = fn (
        Int, Int, Int, Int, PC64, PC64, Int, PC64, Int, PC64, PC64, Int
    ) -> None
    # void cblas_zhpmv(const enum CBLAS_ORDER order, const enum CBLAS_UPLO Uplo, const int N, const void *alpha, const void *Ap, const void *X, const int incX, const void *beta, void *Y, const int incY);
    alias ZhpmvType = fn (
        Int, Int, Int, PC64, PC64, PC64, Int, PC64, PC64, Int
    ) -> None
    # void cblas_zgeru(const enum CBLAS_ORDER order, const int M, const int N, const void *alpha, const void *X, const int incX, const void *Y, const int incY, void *A, const int lda);
    alias ZgeruType = fn (
        Int, Int, Int, PC64, PC64, Int, PC64, Int, PC64, Int
    ) -> None
    # void cblas_zgerc(const enum CBLAS_ORDER order, const int M, const int N, const void *alpha, const void *X, const int incX, const void *Y, const int incY, void *A, const int lda);
    alias ZgercType = fn (
        Int, Int, Int, PC64, PC64, Int, PC64, Int, PC64, Int
    ) -> None
    # void cblas_zher(const enum CBLAS_ORDER order, const enum CBLAS_UPLO Uplo, const int N, const double alpha, const void *X, const int incX, void *A, const int lda);
    alias ZherType = fn (Int, Int, Int, F64, PC64, Int, PC64, Int) -> None
    # void cblas_zhpr(const enum CBLAS_ORDER order, const enum CBLAS_UPLO Uplo, const int N, const double alpha, const void *X, const int incX, void *A);
    alias ZhprType = fn (Int, Int, Int, F64, PC64, Int, PC64) -> None
    # void cblas_zher2(const enum CBLAS_ORDER order, const enum CBLAS_UPLO Uplo, const int N, const void *alpha, const void *X, const int incX, const void *Y, const int incY, void *A, const int lda);
    alias Zher2Type = fn (
        Int, Int, Int, PC64, PC64, Int, PC64, Int, PC64, Int
    ) -> None
    # void cblas_zhpr2(const enum CBLAS_ORDER order, const enum CBLAS_UPLO Uplo, const int N, const void *alpha, const void *X, const int incX, const void *Y, const int incY, void *Ap);
    alias Zhpr2Type = fn (
        Int, Int, Int, PC64, PC64, Int, PC64, Int, PC64
    ) -> None
    # void cblas_sgemm(const enum CBLAS_ORDER Order, const enum CBLAS_TRANSPOSE TransA, const enum CBLAS_TRANSPOSE TransB, const int M, const int N, const int K, const float alpha, const float *A, const int lda, const float *B, const int ldb, const float beta, float *C, const int ldc);
    alias SgemmType = fn (
        Int, Int, Int, Int, Int, Int, F32, PF32, Int, PF32, Int, F32, PF32, Int
    ) -> None
    # void cblas_ssymm(const enum CBLAS_ORDER Order, const enum CBLAS_SIDE Side, const enum CBLAS_UPLO Uplo, const int M, const int N, const float alpha, const float *A, const int lda, const float *B, const int ldb, const float beta, float *C, const int ldc);
    alias SsymmType = fn (
        Int, Int, Int, Int, Int, F32, PF32, Int, PF32, Int, F32, PF32, Int
    ) -> None
    # void cblas_ssyrk(const enum CBLAS_ORDER Order, const enum CBLAS_UPLO Uplo, const enum CBLAS_TRANSPOSE Trans, const int N, const int K, const float alpha, const float *A, const int lda, const float beta, float *C, const int ldc);
    alias SsyrkType = fn (
        Int, Int, Int, Int, Int, F32, PF32, Int, F32, PF32, Int
    ) -> None
    # void cblas_ssyr2k(const enum CBLAS_ORDER Order, const enum CBLAS_UPLO Uplo, const enum CBLAS_TRANSPOSE Trans, const int N, const int K, const float alpha, const float *A, const int lda, const float *B, const int ldb, const float beta, float *C, const int ldc);
    alias Ssyr2KType = fn (
        Int, Int, Int, Int, Int, F32, PF32, Int, PF32, Int, F32, PF32, Int
    ) -> None
    # void cblas_strmm(const enum CBLAS_ORDER Order, const enum CBLAS_SIDE Side, const enum CBLAS_UPLO Uplo, const enum CBLAS_TRANSPOSE TransA, const enum CBLAS_DIAG Diag, const int M, const int N, const float alpha, const float *A, const int lda, float *B, const int ldb);
    alias StrmmType = fn (
        Int, Int, Int, Int, Int, Int, Int, F32, PF32, Int, PF32, Int
    ) -> None
    # void cblas_strsm(const enum CBLAS_ORDER Order, const enum CBLAS_SIDE Side, const enum CBLAS_UPLO Uplo, const enum CBLAS_TRANSPOSE TransA, const enum CBLAS_DIAG Diag, const int M, const int N, const float alpha, const float *A, const int lda, float *B, const int ldb);
    alias StrsmType = fn (
        Int, Int, Int, Int, Int, Int, Int, F32, PF32, Int, PF32, Int
    ) -> None
    # void cblas_dgemm(const enum CBLAS_ORDER Order, const enum CBLAS_TRANSPOSE TransA, const enum CBLAS_TRANSPOSE TransB, const int M, const int N, const int K, const double alpha, const double *A, const int lda, const double *B, const int ldb, const double beta, double *C, const int ldc);
    alias DgemmType = fn (
        Int, Int, Int, Int, Int, Int, F64, PF64, Int, PF64, Int, F64, PF64, Int
    ) -> None
    # void cblas_dsymm(const enum CBLAS_ORDER Order, const enum CBLAS_SIDE Side, const enum CBLAS_UPLO Uplo, const int M, const int N, const double alpha, const double *A, const int lda, const double *B, const int ldb, const double beta, double *C, const int ldc);
    alias DsymmType = fn (
        Int, Int, Int, Int, Int, F64, PF64, Int, PF64, Int, F64, PF64, Int
    ) -> None
    # void cblas_dsyrk(const enum CBLAS_ORDER Order, const enum CBLAS_UPLO Uplo, const enum CBLAS_TRANSPOSE Trans, const int N, const int K, const double alpha, const double *A, const int lda, const double beta, double *C, const int ldc);
    alias DsyrkType = fn (
        Int, Int, Int, Int, Int, F64, PF64, Int, F64, PF64, Int
    ) -> None
    # void cblas_dsyr2k(const enum CBLAS_ORDER Order, const enum CBLAS_UPLO Uplo, const enum CBLAS_TRANSPOSE Trans, const int N, const int K, const double alpha, const double *A, const int lda, const double *B, const int ldb, const double beta, double *C, const int ldc);
    alias Dsyr2KType = fn (
        Int, Int, Int, Int, Int, F64, PF64, Int, PF64, Int, F64, PF64, Int
    ) -> None
    # void cblas_dtrmm(const enum CBLAS_ORDER Order, const enum CBLAS_SIDE Side, const enum CBLAS_UPLO Uplo, const enum CBLAS_TRANSPOSE TransA, const enum CBLAS_DIAG Diag, const int M, const int N, const double alpha, const double *A, const int lda, double *B, const int ldb);
    alias DtrmmType = fn (
        Int, Int, Int, Int, Int, Int, Int, F64, PF64, Int, PF64, Int
    ) -> None
    # void cblas_dtrsm(const enum CBLAS_ORDER Order, const enum CBLAS_SIDE Side, const enum CBLAS_UPLO Uplo, const enum CBLAS_TRANSPOSE TransA, const enum CBLAS_DIAG Diag, const int M, const int N, const double alpha, const double *A, const int lda, double *B, const int ldb);
    alias DtrsmType = fn (
        Int, Int, Int, Int, Int, Int, Int, F64, PF64, Int, PF64, Int
    ) -> None
    # void cblas_cgemm(const enum CBLAS_ORDER Order, const enum CBLAS_TRANSPOSE TransA, const enum CBLAS_TRANSPOSE TransB, const int M, const int N, const int K, const void *alpha, const void *A, const int lda, const void *B, const int ldb, const void *beta, void *C, const int ldc);
    alias CgemmType = fn (
        Int,
        Int,
        Int,
        Int,
        Int,
        Int,
        PC32,
        PC32,
        Int,
        PC32,
        Int,
        PC32,
        PC32,
        Int,
    ) -> None
    # void cblas_csymm(const enum CBLAS_ORDER Order, const enum CBLAS_SIDE Side, const enum CBLAS_UPLO Uplo, const int M, const int N, const void *alpha, const void *A, const int lda, const void *B, const int ldb, const void *beta, void *C, const int ldc);
    alias CsymmType = fn (
        Int, Int, Int, Int, Int, PC32, PC32, Int, PC32, Int, PC32, PC32, Int
    ) -> None
    # void cblas_csyrk(const enum CBLAS_ORDER Order, const enum CBLAS_UPLO Uplo, const enum CBLAS_TRANSPOSE Trans, const int N, const int K, const void *alpha, const void *A, const int lda, const void *beta, void *C, const int ldc);
    alias CsyrkType = fn (
        Int, Int, Int, Int, Int, PC32, PC32, Int, PC32, PC32, Int
    ) -> None
    # void cblas_csyr2k(const enum CBLAS_ORDER Order, const enum CBLAS_UPLO Uplo, const enum CBLAS_TRANSPOSE Trans, const int N, const int K, const void *alpha, const void *A, const int lda, const void *B, const int ldb, const void *beta, void *C, const int ldc);
    alias Csyr2KType = fn (
        Int, Int, Int, Int, Int, PC32, PC32, Int, PC32, Int, PC32, PC32, Int
    ) -> None
    # void cblas_ctrmm(const enum CBLAS_ORDER Order, const enum CBLAS_SIDE Side, const enum CBLAS_UPLO Uplo, const enum CBLAS_TRANSPOSE TransA, const enum CBLAS_DIAG Diag, const int M, const int N, const void *alpha, const void *A, const int lda, void *B, const int ldb);
    alias CtrmmType = fn (
        Int, Int, Int, Int, Int, Int, Int, PC32, PC32, Int, PC32, Int
    ) -> None
    # void cblas_ctrsm(const enum CBLAS_ORDER Order, const enum CBLAS_SIDE Side, const enum CBLAS_UPLO Uplo, const enum CBLAS_TRANSPOSE TransA, const enum CBLAS_DIAG Diag, const int M, const int N, const void *alpha, const void *A, const int lda, void *B, const int ldb);
    alias CtrsmType = fn (
        Int, Int, Int, Int, Int, Int, Int, PC32, PC32, Int, PC32, Int
    ) -> None
    # void cblas_zgemm(const enum CBLAS_ORDER Order, const enum CBLAS_TRANSPOSE TransA, const enum CBLAS_TRANSPOSE TransB, const int M, const int N, const int K, const void *alpha, const void *A, const int lda, const void *B, const int ldb, const void *beta, void *C, const int ldc);
    alias ZgemmType = fn (
        Int,
        Int,
        Int,
        Int,
        Int,
        Int,
        PC64,
        PC64,
        Int,
        PC64,
        Int,
        PC64,
        PC64,
        Int,
    ) -> None
    # void cblas_zsymm(const enum CBLAS_ORDER Order, const enum CBLAS_SIDE Side, const enum CBLAS_UPLO Uplo, const int M, const int N, const void *alpha, const void *A, const int lda, const void *B, const int ldb, const void *beta, void *C, const int ldc);
    alias ZsymmType = fn (
        Int, Int, Int, Int, Int, PC64, PC64, Int, PC64, Int, PC64, PC64, Int
    ) -> None
    # void cblas_zsyrk(const enum CBLAS_ORDER Order, const enum CBLAS_UPLO Uplo, const enum CBLAS_TRANSPOSE Trans, const int N, const int K, const void *alpha, const void *A, const int lda, const void *beta, void *C, const int ldc);
    alias ZsyrkType = fn (
        Int, Int, Int, Int, Int, PC64, PC64, Int, PC64, PC64, Int
    ) -> None
    # void cblas_zsyr2k(const enum CBLAS_ORDER Order, const enum CBLAS_UPLO Uplo, const enum CBLAS_TRANSPOSE Trans, const int N, const int K, const void *alpha, const void *A, const int lda, const void *B, const int ldb, const void *beta, void *C, const int ldc);
    alias Zsyr2KType = fn (
        Int, Int, Int, Int, Int, PC64, PC64, Int, PC64, Int, PC64, PC64, Int
    ) -> None
    # void cblas_ztrmm(const enum CBLAS_ORDER Order, const enum CBLAS_SIDE Side, const enum CBLAS_UPLO Uplo, const enum CBLAS_TRANSPOSE TransA, const enum CBLAS_DIAG Diag, const int M, const int N, const void *alpha, const void *A, const int lda, void *B, const int ldb);
    alias ZtrmmType = fn (
        Int, Int, Int, Int, Int, Int, Int, PC64, PC64, Int, PC64, Int
    ) -> None
    # void cblas_ztrsm(const enum CBLAS_ORDER Order, const enum CBLAS_SIDE Side, const enum CBLAS_UPLO Uplo, const enum CBLAS_TRANSPOSE TransA, const enum CBLAS_DIAG Diag, const int M, const int N, const void *alpha, const void *A, const int lda, void *B, const int ldb);
    alias ZtrsmType = fn (
        Int, Int, Int, Int, Int, Int, Int, PC64, PC64, Int, PC64, Int
    ) -> None
    # void cblas_chemm(const enum CBLAS_ORDER Order, const enum CBLAS_SIDE Side, const enum CBLAS_UPLO Uplo, const int M, const int N, const void *alpha, const void *A, const int lda, const void *B, const int ldb, const void *beta, void *C, const int ldc);
    alias ChemmType = fn (
        Int, Int, Int, Int, Int, PC32, PC32, Int, PC32, Int, PC32, PC32, Int
    ) -> None
    # void cblas_cherk(const enum CBLAS_ORDER Order, const enum CBLAS_UPLO Uplo, const enum CBLAS_TRANSPOSE Trans, const int N, const int K, const float alpha, const void *A, const int lda, const float beta, void *C, const int ldc);
    alias CherkType = fn (
        Int, Int, Int, Int, Int, F32, PC32, Int, F32, PC32, Int
    ) -> None
    # void cblas_cher2k(const enum CBLAS_ORDER Order, const enum CBLAS_UPLO Uplo, const enum CBLAS_TRANSPOSE Trans, const int N, const int K, const void *alpha, const void *A, const int lda, const void *B, const int ldb, const float beta, void *C, const int ldc);
    alias Cher2KType = fn (
        Int, Int, Int, Int, Int, PC32, PC32, Int, PC32, Int, F32, PC32, Int
    ) -> None
    # void cblas_zhemm(const enum CBLAS_ORDER Order, const enum CBLAS_SIDE Side, const enum CBLAS_UPLO Uplo, const int M, const int N, const void *alpha, const void *A, const int lda, const void *B, const int ldb, const void *beta, void *C, const int ldc);
    alias ZhemmType = fn (
        Int, Int, Int, Int, Int, PC64, PC64, Int, PC64, Int, PC64, PC64, Int
    ) -> None
    # void cblas_zherk(const enum CBLAS_ORDER Order, const enum CBLAS_UPLO Uplo, const enum CBLAS_TRANSPOSE Trans, const int N, const int K, const double alpha, const void *A, const int lda, const double beta, void *C, const int ldc);
    alias ZherkType = fn (
        Int, Int, Int, Int, Int, F64, PC64, Int, F64, PC64, Int
    ) -> None
    # void cblas_zher2k(const enum CBLAS_ORDER Order, const enum CBLAS_UPLO Uplo, const enum CBLAS_TRANSPOSE Trans, const int N, const int K, const void *alpha, const void *A, const int lda, const void *B, const int ldb, const double beta, void *C, const int ldc);
    alias Zher2KType = fn (
        Int, Int, Int, Int, Int, PC64, PC64, Int, PC64, Int, F64, PC64, Int
    ) -> None
    # void cblas_xerbla(int p, const char *rout, const char *form, ...);
    # alias XerblaType = fn (Int, Pointer[char], Pointer[char], ...) -> None

    var h: DLHandle
    var sdsdot: Self.SdsdotType
    var dsdot: Self.DsdotType
    var sdot: Self.SdotType
    var ddot: Self.DdotType
    var cdotusub: Self.CdotuSubType
    var cdotcsub: Self.CdotcSubType
    var zdotusub: Self.ZdotuSubType
    var zdotcsub: Self.ZdotcSubType
    var snrm2: Self.Snrm2Type
    var sasum: Self.SasumType
    var dnrm2: Self.Dnrm2Type
    var dasum: Self.DasumType
    var scnrm2: Self.Scnrm2Type
    var scasum: Self.ScasumType
    var dznrm2: Self.Dznrm2Type
    var dzasum: Self.DzasumType
    var isamax: Self.IsamaxType
    var idamax: Self.IdamaxType
    var icamax: Self.IcamaxType
    var izamax: Self.IzamaxType
    var sswap: Self.SswapType
    var scopy: Self.ScopyType
    var saxpy: Self.SaxpyType
    var dswap: Self.DswapType
    var dcopy: Self.DcopyType
    var daxpy: Self.DaxpyType
    var cswap: Self.CswapType
    var ccopy: Self.CcopyType
    var caxpy: Self.CaxpyType
    var zswap: Self.ZswapType
    var zcopy: Self.ZcopyType
    var zaxpy: Self.ZaxpyType
    var srotg: Self.SrotgType
    var srotmg: Self.SrotmgType
    var srot: Self.SrotType
    var srotm: Self.SrotmType
    var drotg: Self.DrotgType
    var drotmg: Self.DrotmgType
    var drot: Self.DrotType
    var drotm: Self.DrotmType
    var sscal: Self.SscalType
    var dscal: Self.DscalType
    var cscal: Self.CscalType
    var zscal: Self.ZscalType
    var csscal: Self.CsscalType
    var zdscal: Self.ZdscalType
    var sgemv: Self.SgemvType
    var sgbmv: Self.SgbmvType
    var strmv: Self.StrmvType
    var stbmv: Self.StbmvType
    var stpmv: Self.StpmvType
    var strsv: Self.StrsvType
    var stbsv: Self.StbsvType
    var stpsv: Self.StpsvType
    var dgemv: Self.DgemvType
    var dgbmv: Self.DgbmvType
    var dtrmv: Self.DtrmvType
    var dtbmv: Self.DtbmvType
    var dtpmv: Self.DtpmvType
    var dtrsv: Self.DtrsvType
    var dtbsv: Self.DtbsvType
    var dtpsv: Self.DtpsvType
    var cgemv: Self.CgemvType
    var cgbmv: Self.CgbmvType
    var ctrmv: Self.CtrmvType
    var ctbmv: Self.CtbmvType
    var ctpmv: Self.CtpmvType
    var ctrsv: Self.CtrsvType
    var ctbsv: Self.CtbsvType
    var ctpsv: Self.CtpsvType
    var zgemv: Self.ZgemvType
    var zgbmv: Self.ZgbmvType
    var ztrmv: Self.ZtrmvType
    var ztbmv: Self.ZtbmvType
    var ztpmv: Self.ZtpmvType
    var ztrsv: Self.ZtrsvType
    var ztbsv: Self.ZtbsvType
    var ztpsv: Self.ZtpsvType
    var ssymv: Self.SsymvType
    var ssbmv: Self.SsbmvType
    var sspmv: Self.SspmvType
    var sger: Self.SgerType
    var ssyr: Self.SsyrType
    var sspr: Self.SsprType
    var ssyr2: Self.Ssyr2Type
    var sspr2: Self.Sspr2Type
    var dsymv: Self.DsymvType
    var dsbmv: Self.DsbmvType
    var dspmv: Self.DspmvType
    var dger: Self.DgerType
    var dsyr: Self.DsyrType
    var dspr: Self.DsprType
    var dsyr2: Self.Dsyr2Type
    var dspr2: Self.Dspr2Type
    var chemv: Self.ChemvType
    var chbmv: Self.ChbmvType
    var chpmv: Self.ChpmvType
    var cgeru: Self.CgeruType
    var cgerc: Self.CgercType
    var cher: Self.CherType
    var chpr: Self.ChprType
    var cher2: Self.Cher2Type
    var chpr2: Self.Chpr2Type
    var zhemv: Self.ZhemvType
    var zhbmv: Self.ZhbmvType
    var zhpmv: Self.ZhpmvType
    var zgeru: Self.ZgeruType
    var zgerc: Self.ZgercType
    var zher: Self.ZherType
    var zhpr: Self.ZhprType
    var zher2: Self.Zher2Type
    var zhpr2: Self.Zhpr2Type
    var sgemm: Self.SgemmType
    var ssymm: Self.SsymmType
    var ssyrk: Self.SsyrkType
    var ssyr2k: Self.Ssyr2KType
    var strmm: Self.StrmmType
    var strsm: Self.StrsmType
    var dgemm: Self.DgemmType
    var dsymm: Self.DsymmType
    var dsyrk: Self.DsyrkType
    var dsyr2k: Self.Dsyr2KType
    var dtrmm: Self.DtrmmType
    var dtrsm: Self.DtrsmType
    var cgemm: Self.CgemmType
    var csymm: Self.CsymmType
    var csyrk: Self.CsyrkType
    var csyr2k: Self.Csyr2KType
    var ctrmm: Self.CtrmmType
    var ctrsm: Self.CtrsmType
    var zgemm: Self.ZgemmType
    var zsymm: Self.ZsymmType
    var zsyrk: Self.ZsyrkType
    var zsyr2k: Self.Zsyr2KType
    var ztrmm: Self.ZtrmmType
    var ztrsm: Self.ZtrsmType
    var chemm: Self.ChemmType
    var cherk: Self.CherkType
    var cher2k: Self.Cher2KType
    var zhemm: Self.ZhemmType
    var zherk: Self.ZherkType
    var zher2k: Self.Zher2KType
    # var xerbla: Self.XerblaType

    fn __init__(inout self) raises:
        var path = getenv("MOJOSCI_CBLAS_DYNLIB_PATH")
        self.__init__(path)

    fn __init__(inout self, path: String) raises:
        if not isfile(path):
            raise Error("Path does not point to a file")
        self.h = DLHandle(path)
        if not self.h:
            raise Error("Cannot open dynamic library")
        self.sdsdot = self.h.get_function[Self.SdsdotType]("cblas_sdsdot")
        self.dsdot = self.h.get_function[Self.DsdotType]("cblas_dsdot")
        self.sdot = self.h.get_function[Self.SdotType]("cblas_sdot")
        self.ddot = self.h.get_function[Self.DdotType]("cblas_ddot")
        self.cdotusub = self.h.get_function[Self.CdotuSubType](
            "cblas_cdotu_sub"
        )
        self.cdotcsub = self.h.get_function[Self.CdotcSubType](
            "cblas_cdotc_sub"
        )
        self.zdotusub = self.h.get_function[Self.ZdotuSubType](
            "cblas_zdotu_sub"
        )
        self.zdotcsub = self.h.get_function[Self.ZdotcSubType](
            "cblas_zdotc_sub"
        )
        self.snrm2 = self.h.get_function[Self.Snrm2Type]("cblas_snrm2")
        self.sasum = self.h.get_function[Self.SasumType]("cblas_sasum")
        self.dnrm2 = self.h.get_function[Self.Dnrm2Type]("cblas_dnrm2")
        self.dasum = self.h.get_function[Self.DasumType]("cblas_dasum")
        self.scnrm2 = self.h.get_function[Self.Scnrm2Type]("cblas_scnrm2")
        self.scasum = self.h.get_function[Self.ScasumType]("cblas_scasum")
        self.dznrm2 = self.h.get_function[Self.Dznrm2Type]("cblas_dznrm2")
        self.dzasum = self.h.get_function[Self.DzasumType]("cblas_dzasum")
        self.isamax = self.h.get_function[Self.IsamaxType]("cblas_isamax")
        self.idamax = self.h.get_function[Self.IdamaxType]("cblas_idamax")
        self.icamax = self.h.get_function[Self.IcamaxType]("cblas_icamax")
        self.izamax = self.h.get_function[Self.IzamaxType]("cblas_izamax")
        self.sswap = self.h.get_function[Self.SswapType]("cblas_sswap")
        self.scopy = self.h.get_function[Self.ScopyType]("cblas_scopy")
        self.saxpy = self.h.get_function[Self.SaxpyType]("cblas_saxpy")
        self.dswap = self.h.get_function[Self.DswapType]("cblas_dswap")
        self.dcopy = self.h.get_function[Self.DcopyType]("cblas_dcopy")
        self.daxpy = self.h.get_function[Self.DaxpyType]("cblas_daxpy")
        self.cswap = self.h.get_function[Self.CswapType]("cblas_cswap")
        self.ccopy = self.h.get_function[Self.CcopyType]("cblas_ccopy")
        self.caxpy = self.h.get_function[Self.CaxpyType]("cblas_caxpy")
        self.zswap = self.h.get_function[Self.ZswapType]("cblas_zswap")
        self.zcopy = self.h.get_function[Self.ZcopyType]("cblas_zcopy")
        self.zaxpy = self.h.get_function[Self.ZaxpyType]("cblas_zaxpy")
        self.srotg = self.h.get_function[Self.SrotgType]("cblas_srotg")
        self.srotmg = self.h.get_function[Self.SrotmgType]("cblas_srotmg")
        self.srot = self.h.get_function[Self.SrotType]("cblas_srot")
        self.srotm = self.h.get_function[Self.SrotmType]("cblas_srotm")
        self.drotg = self.h.get_function[Self.DrotgType]("cblas_drotg")
        self.drotmg = self.h.get_function[Self.DrotmgType]("cblas_drotmg")
        self.drot = self.h.get_function[Self.DrotType]("cblas_drot")
        self.drotm = self.h.get_function[Self.DrotmType]("cblas_drotm")
        self.sscal = self.h.get_function[Self.SscalType]("cblas_sscal")
        self.dscal = self.h.get_function[Self.DscalType]("cblas_dscal")
        self.cscal = self.h.get_function[Self.CscalType]("cblas_cscal")
        self.zscal = self.h.get_function[Self.ZscalType]("cblas_zscal")
        self.csscal = self.h.get_function[Self.CsscalType]("cblas_csscal")
        self.zdscal = self.h.get_function[Self.ZdscalType]("cblas_zdscal")
        self.sgemv = self.h.get_function[Self.SgemvType]("cblas_sgemv")
        self.sgbmv = self.h.get_function[Self.SgbmvType]("cblas_sgbmv")
        self.strmv = self.h.get_function[Self.StrmvType]("cblas_strmv")
        self.stbmv = self.h.get_function[Self.StbmvType]("cblas_stbmv")
        self.stpmv = self.h.get_function[Self.StpmvType]("cblas_stpmv")
        self.strsv = self.h.get_function[Self.StrsvType]("cblas_strsv")
        self.stbsv = self.h.get_function[Self.StbsvType]("cblas_stbsv")
        self.stpsv = self.h.get_function[Self.StpsvType]("cblas_stpsv")
        self.dgemv = self.h.get_function[Self.DgemvType]("cblas_dgemv")
        self.dgbmv = self.h.get_function[Self.DgbmvType]("cblas_dgbmv")
        self.dtrmv = self.h.get_function[Self.DtrmvType]("cblas_dtrmv")
        self.dtbmv = self.h.get_function[Self.DtbmvType]("cblas_dtbmv")
        self.dtpmv = self.h.get_function[Self.DtpmvType]("cblas_dtpmv")
        self.dtrsv = self.h.get_function[Self.DtrsvType]("cblas_dtrsv")
        self.dtbsv = self.h.get_function[Self.DtbsvType]("cblas_dtbsv")
        self.dtpsv = self.h.get_function[Self.DtpsvType]("cblas_dtpsv")
        self.cgemv = self.h.get_function[Self.CgemvType]("cblas_cgemv")
        self.cgbmv = self.h.get_function[Self.CgbmvType]("cblas_cgbmv")
        self.ctrmv = self.h.get_function[Self.CtrmvType]("cblas_ctrmv")
        self.ctbmv = self.h.get_function[Self.CtbmvType]("cblas_ctbmv")
        self.ctpmv = self.h.get_function[Self.CtpmvType]("cblas_ctpmv")
        self.ctrsv = self.h.get_function[Self.CtrsvType]("cblas_ctrsv")
        self.ctbsv = self.h.get_function[Self.CtbsvType]("cblas_ctbsv")
        self.ctpsv = self.h.get_function[Self.CtpsvType]("cblas_ctpsv")
        self.zgemv = self.h.get_function[Self.ZgemvType]("cblas_zgemv")
        self.zgbmv = self.h.get_function[Self.ZgbmvType]("cblas_zgbmv")
        self.ztrmv = self.h.get_function[Self.ZtrmvType]("cblas_ztrmv")
        self.ztbmv = self.h.get_function[Self.ZtbmvType]("cblas_ztbmv")
        self.ztpmv = self.h.get_function[Self.ZtpmvType]("cblas_ztpmv")
        self.ztrsv = self.h.get_function[Self.ZtrsvType]("cblas_ztrsv")
        self.ztbsv = self.h.get_function[Self.ZtbsvType]("cblas_ztbsv")
        self.ztpsv = self.h.get_function[Self.ZtpsvType]("cblas_ztpsv")
        self.ssymv = self.h.get_function[Self.SsymvType]("cblas_ssymv")
        self.ssbmv = self.h.get_function[Self.SsbmvType]("cblas_ssbmv")
        self.sspmv = self.h.get_function[Self.SspmvType]("cblas_sspmv")
        self.sger = self.h.get_function[Self.SgerType]("cblas_sger")
        self.ssyr = self.h.get_function[Self.SsyrType]("cblas_ssyr")
        self.sspr = self.h.get_function[Self.SsprType]("cblas_sspr")
        self.ssyr2 = self.h.get_function[Self.Ssyr2Type]("cblas_ssyr2")
        self.sspr2 = self.h.get_function[Self.Sspr2Type]("cblas_sspr2")
        self.dsymv = self.h.get_function[Self.DsymvType]("cblas_dsymv")
        self.dsbmv = self.h.get_function[Self.DsbmvType]("cblas_dsbmv")
        self.dspmv = self.h.get_function[Self.DspmvType]("cblas_dspmv")
        self.dger = self.h.get_function[Self.DgerType]("cblas_dger")
        self.dsyr = self.h.get_function[Self.DsyrType]("cblas_dsyr")
        self.dspr = self.h.get_function[Self.DsprType]("cblas_dspr")
        self.dsyr2 = self.h.get_function[Self.Dsyr2Type]("cblas_dsyr2")
        self.dspr2 = self.h.get_function[Self.Dspr2Type]("cblas_dspr2")
        self.chemv = self.h.get_function[Self.ChemvType]("cblas_chemv")
        self.chbmv = self.h.get_function[Self.ChbmvType]("cblas_chbmv")
        self.chpmv = self.h.get_function[Self.ChpmvType]("cblas_chpmv")
        self.cgeru = self.h.get_function[Self.CgeruType]("cblas_cgeru")
        self.cgerc = self.h.get_function[Self.CgercType]("cblas_cgerc")
        self.cher = self.h.get_function[Self.CherType]("cblas_cher")
        self.chpr = self.h.get_function[Self.ChprType]("cblas_chpr")
        self.cher2 = self.h.get_function[Self.Cher2Type]("cblas_cher2")
        self.chpr2 = self.h.get_function[Self.Chpr2Type]("cblas_chpr2")
        self.zhemv = self.h.get_function[Self.ZhemvType]("cblas_zhemv")
        self.zhbmv = self.h.get_function[Self.ZhbmvType]("cblas_zhbmv")
        self.zhpmv = self.h.get_function[Self.ZhpmvType]("cblas_zhpmv")
        self.zgeru = self.h.get_function[Self.ZgeruType]("cblas_zgeru")
        self.zgerc = self.h.get_function[Self.ZgercType]("cblas_zgerc")
        self.zher = self.h.get_function[Self.ZherType]("cblas_zher")
        self.zhpr = self.h.get_function[Self.ZhprType]("cblas_zhpr")
        self.zher2 = self.h.get_function[Self.Zher2Type]("cblas_zher2")
        self.zhpr2 = self.h.get_function[Self.Zhpr2Type]("cblas_zhpr2")
        self.sgemm = self.h.get_function[Self.SgemmType]("cblas_sgemm")
        self.ssymm = self.h.get_function[Self.SsymmType]("cblas_ssymm")
        self.ssyrk = self.h.get_function[Self.SsyrkType]("cblas_ssyrk")
        self.ssyr2k = self.h.get_function[Self.Ssyr2KType]("cblas_ssyr2k")
        self.strmm = self.h.get_function[Self.StrmmType]("cblas_strmm")
        self.strsm = self.h.get_function[Self.StrsmType]("cblas_strsm")
        self.dgemm = self.h.get_function[Self.DgemmType]("cblas_dgemm")
        self.dsymm = self.h.get_function[Self.DsymmType]("cblas_dsymm")
        self.dsyrk = self.h.get_function[Self.DsyrkType]("cblas_dsyrk")
        self.dsyr2k = self.h.get_function[Self.Dsyr2KType]("cblas_dsyr2k")
        self.dtrmm = self.h.get_function[Self.DtrmmType]("cblas_dtrmm")
        self.dtrsm = self.h.get_function[Self.DtrsmType]("cblas_dtrsm")
        self.cgemm = self.h.get_function[Self.CgemmType]("cblas_cgemm")
        self.csymm = self.h.get_function[Self.CsymmType]("cblas_csymm")
        self.csyrk = self.h.get_function[Self.CsyrkType]("cblas_csyrk")
        self.csyr2k = self.h.get_function[Self.Csyr2KType]("cblas_csyr2k")
        self.ctrmm = self.h.get_function[Self.CtrmmType]("cblas_ctrmm")
        self.ctrsm = self.h.get_function[Self.CtrsmType]("cblas_ctrsm")
        self.zgemm = self.h.get_function[Self.ZgemmType]("cblas_zgemm")
        self.zsymm = self.h.get_function[Self.ZsymmType]("cblas_zsymm")
        self.zsyrk = self.h.get_function[Self.ZsyrkType]("cblas_zsyrk")
        self.zsyr2k = self.h.get_function[Self.Zsyr2KType]("cblas_zsyr2k")
        self.ztrmm = self.h.get_function[Self.ZtrmmType]("cblas_ztrmm")
        self.ztrsm = self.h.get_function[Self.ZtrsmType]("cblas_ztrsm")
        self.chemm = self.h.get_function[Self.ChemmType]("cblas_chemm")
        self.cherk = self.h.get_function[Self.CherkType]("cblas_cherk")
        self.cher2k = self.h.get_function[Self.Cher2KType]("cblas_cher2k")
        self.zhemm = self.h.get_function[Self.ZhemmType]("cblas_zhemm")
        self.zherk = self.h.get_function[Self.ZherkType]("cblas_zherk")
        self.zher2k = self.h.get_function[Self.Zher2KType]("cblas_zher2k")
        # self.xerbla = self.h.get_function[Self.XerblaType]("cblas_xerbla")


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

    var dsdot_res = cblas.dsdot(n, x32, 1, y32, 1)
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

    cblas.cdotusub(n, xc32, 1, yc32, 1, cres32)
    assert_equal(cres32[0], C32(0, 10))

    cblas.cdotcsub(n, xc32, 1, yc32, 1, cres32)
    assert_equal(cres32[0], C32(10, 0))

    var cres64 = PC64.alloc(1)

    var xc64 = PC64.alloc(n.value)
    var yc64 = PC64.alloc(n.value)

    for i in range(n):
        xc64[i] = C64(i, i)
        yc64[i] = C64(i, i)

    cblas.zdotusub(n, xc64, 1, yc64, 1, cres64)
    assert_equal(cres64[0], C64(0, 10))

    cblas.zdotcsub(n, xc64, 1, yc64, 1, cres64)
    assert_equal(cres64[0], C64(10, 0))

    var snrm2_res = cblas.snrm2(n, x32, 1)
    assert_almost_equal(snrm2_res, 2.2360680103302002)

    var sasum_res = cblas.sasum(n, y32, 1)
    assert_almost_equal(sasum_res, 3.0)

    var dnrm2_res = cblas.dnrm2(n, x64, 1)
    assert_almost_equal(dnrm2_res, 2.2360680103302002)

    var dasum_res = cblas.dasum(n, y64, 1)
    assert_almost_equal(dasum_res, 3.0)

    var scnrm2_res = cblas.scnrm2(n, xc32, 1)
    assert_almost_equal(scnrm2_res, 3.1622776985168457)

    var scasum_res = cblas.scasum(n, yc32, 1)
    assert_almost_equal(scasum_res, 6.0)

    var dznrm2_res = cblas.dznrm2(n, xc64, 1)
    assert_almost_equal(dznrm2_res, 3.1622776985168457)

    var dzasum_res = cblas.dzasum(n, yc64, 1)
    assert_almost_equal(dzasum_res, 6.0)

    var isamax_res = cblas.isamax(n, x32, 1)
    assert_equal(isamax_res, 2)

    var idamax_res = cblas.idamax(n, y64, 1)
    assert_equal(idamax_res, 2)

    var icamax_res = cblas.icamax(n, xc32, 1)
    assert_equal(icamax_res, 2)

    var izamax_res = cblas.izamax(n, yc64, 1)
    assert_equal(izamax_res, 2)

    cblas.sswap(n, x32, 1, y32, 1)
    cblas.scopy(n, x32, 1, y32, 1)
    cblas.saxpy(n, 2, x32, 1, y32, 1)
    assert_almost_equal(y32[2], 6.0)

    cblas.dswap(n, x64, 1, y64, 1)
    cblas.dcopy(n, x64, 1, y64, 1)
    cblas.daxpy(n, 2, x64, 1, y64, 1)
    assert_almost_equal(y64[2], 6.0)
