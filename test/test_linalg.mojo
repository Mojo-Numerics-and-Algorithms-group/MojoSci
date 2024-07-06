from testing import *
from linalg.static_matrix import StaticMat, StaticColVec
from stochasticity.splitmix import SplitMix


var rng = SplitMix()


fn mkfloat() -> Float64:
    return rng()


def test_mat_init_w_value():
    var x = StaticMat[3, 3](2)
    for i in range(3):
        for j in range(3):
            assert_equal(x[i, j], 2)


def test_mat_init_w_values():
    var x = StaticMat[2, 3](1, 2, 3, 4, 5, 6)
    assert_equal(x[1, 1], 4)


def test_mat_fill():
    var x = StaticMat[5, 4](1)
    x.fill(2)
    assert_equal(x[4, 3], 2)
    x.set_diag(10)
    assert_equal(x[2, 2], 10)


def test_mat_create_diag():
    var x = StaticMat[7, 3].diag(2)
    assert_equal(x[1, 1], 2)


def test_mat_get_set_item():
    var x = StaticMat[8, 8](0)
    for i in range(len(x)):
        x[i] = 2 / 3
        assert_equal(x[i], 2 / 3)
    for i in range(x.rows):
        for j in range(x.cols):
            x[i, j] = 1 / 3
            assert_equal(x[i, j], 1 / 3)
    with assert_raises():
        _ = x[-1]
    with assert_raises():
        _ = x[100]
    with assert_raises():
        _ = x[-1, 1]
    with assert_raises():
        _ = x[100, 2]
    with assert_raises():
        _ = x[1, -1]
    with assert_raises():
        _ = x[2, 100]


def test_get_row_col():
    var x = StaticMat[3, 5](1)
    var r = x.get_row(1)
    var c = x.get_col(4)
    assert_equal(r.rows, 1)
    assert_equal(r.cols, 5)
    assert_equal(c.rows, 3)
    assert_equal(c.cols, 1)
    for i in range(len(r)):
        assert_equal(r[i], 1)
    for i in range(len(c)):
        assert_equal(c[i], 1)
    with assert_raises():
        _ = x.get_row(-1)
    with assert_raises():
        _ = x.get_row(10)
    with assert_raises():
        _ = x.get_col(-1)
    with assert_raises():
        _ = x.get_col(10)


def test_mat_len():
    var x = StaticMat[3, 3]()
    assert_equal(len(x), x.rows * x.cols)


def test_mat_alg():
    var a = StaticMat[2, 3](1)
    var b = StaticMat[2, 3](2)
    assert_equal((a + b)[1, 1], 3)
    assert_equal((a - b)[1, 1], -1)
    assert_equal((a * b)[1, 1], 2)
    assert_equal((a / b)[1, 1], 1 / 2)
    assert_equal((a @ b.transpose())[0, 0], 6)
    assert_equal((a + 1)[1, 1], 2)
    assert_equal((a - 1)[1, 1], 0)
    assert_equal((a * 2)[1, 1], 2)
    assert_equal((a / 3)[1, 1], 1 / 3)
    assert_equal((1 + b)[1, 1], 3)
    assert_equal((1 - b)[1, 1], -1)
    assert_equal((2 * b)[1, 1], 4)
    assert_equal((3 / b)[1, 1], 3 / 2)


def test_mat_nonlin_sys():
    @always_inline
    fn dy(s: StaticColVec[3], pars: StaticColVec[3]) raises -> StaticColVec[3]:
        return StaticColVec[3](
            pars[0] * (s[1] - s[0]),
            s[0] * (pars[1] - s[2]) - s[1],
            s[0] * s[1] - pars[2] * s[2],
        )

    var s = StaticColVec[3](2, 1, 1)
    var p = StaticColVec[3](10, 28, 8 / 3)

    var deriv = dy(s, p)

    assert_equal(deriv[0], -10)


def test_mat_lu_decomp():
    var X1 = StaticMat[3, 3](mkfloat)
    var LU1 = X1.PLU_decompose()
    assert_true(LU1[1] @ LU1[2] == LU1[0] @ X1)
    var X2 = StaticMat[1, 1](mkfloat)
    var LU2 = X2.PLU_decompose()
    assert_true(LU2[1] @ LU2[2] == LU2[0] @ X2)
    var X3 = StaticMat[1, 3](mkfloat)
    var LU3 = X3.PLU_decompose()
    assert_true(LU3[1] @ LU3[2] == LU3[0] @ X3)
    var X4 = StaticMat[3, 1](mkfloat)
    var LU4 = X4.PLU_decompose()
    assert_true(LU4[1] @ LU4[2] == LU4[0] @ X4)
    var X5 = StaticMat[3, 5](mkfloat)
    var LU5 = X5.PLU_decompose()
    assert_true(LU5[1] @ LU5[2] == LU5[0] @ X5)
    var X6 = StaticMat[5, 3](mkfloat)
    var LU6 = X6.PLU_decompose()
    assert_true(LU6[1] @ LU6[2] == LU6[0] @ X6)
    var X7 = StaticMat[2, 2](mkfloat)
    var LU7 = X7.PLU_decompose()
    assert_true(LU7[1] @ LU7[2] == LU7[0] @ X7)
    var X8 = StaticMat[2, 2](4, 6, 3, 3)
    var LU8 = X8.PLU_decompose()
    var Pgen = LU8[0]
    var Pexp = StaticMat[2, 2].diag()
    assert_true(Pgen == Pexp)
    var Lgen = LU8[1]
    var Lexp = StaticMat[2, 2](1, 1.5, 0, 1)
    assert_true(Lgen == Lexp)
    var Ugen = LU8[2]
    var Uexp = StaticMat[2, 2](4, 0, 3, -1.5)
    assert_true(Ugen == Uexp)


def test_determinant():
    var m1 = StaticMat[3, 3].diag()
    assert_equal(m1.determinant(), 1.0)
    var m2 = StaticMat[3, 3](2.0, 0.0, 0.0, 0.0, 3.0, 0.0, 0.0, 0.0, 4.0)
    assert_equal(m2.determinant(), 24.0)
    var m3 = StaticMat[3, 3](1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0)
    assert_equal(m3.determinant(), 0.0)
    var m4 = StaticMat[2, 2](1.0, 2.0, 3.0, 4.0)
    assert_equal(m4.determinant(), -2.0)
    var m5 = StaticMat[3, 3](6.0, 1.0, 1.0, 4.0, -2.0, 5.0, 2.0, 8.0, 7.0)
    assert_equal(m5.determinant(), -306.0)
    var m6 = StaticMat[3, 3](0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
    assert_equal(m6.determinant(), 0.0)
