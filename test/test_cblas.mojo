from testing import *
from linalg.cblas import CBLAS


def test_sdsdot():
    var n: Int = 3
    var x = UnsafePointer[Float64].alloc(n.value)
    var y = UnsafePointer[Float64].alloc(n.value)

    for i in range(n):
        x[i] = i
        y[i] = i

    var cblas = CBLAS("/opt/homebrew/opt/openblas/lib/libopenblas.dylib")

    var res = cblas.ddot(n, x, 1, y, 1)

    assert_equal(res, 14)
