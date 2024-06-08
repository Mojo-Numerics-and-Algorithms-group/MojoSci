from testing import *
from numojo.linalg import Mat, ColVec


def test_mat_init_w_value():
    var x = Mat[3, 3](2)
    for i in range(3):
        for j in range(3):
            assert_equal(x[i, j], 2)


def test_mat_init_w_values():
    var x = Mat[2, 3](1, 2, 3, 4, 5, 6)
    assert_equal(x[1, 1], 4)


def test_mat_fill():
    var x = Mat[5, 4](1)
    x.fill(2)
    assert_equal(x[4, 3], 2)
    x.set_diag(10)
    assert_equal(x[2, 2], 10)


def test_mat_create_diag():
    var x = Mat[7, 3].diag(2)
    assert_equal(x[1, 1], 2)


def test_mat_get_set_item():
    var x = Mat[8, 8](0)
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
    var x = Mat[3, 5](1)
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
    var x = Mat[3, 3]()
    assert_equal(len(x), x.rows * x.cols)


def test_mat_alg():
    var a = Mat[2, 3](1)
    var b = Mat[2, 3](2)
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
    fn dy(s: ColVec[3], pars: ColVec[3]) raises -> ColVec[3]:
        return ColVec[3](
            pars[0] * (s[1] - s[0]),
            s[0] * (pars[1] - s[2]) - s[1],
            s[0] * s[1] - pars[2] * s[2],
        )

    var s = ColVec[3](2, 1, 1)
    var p = ColVec[3](10, 28, 8 / 3)

    var deriv = dy(s, p)

    assert_equal(deriv[0], -10)


def test_mat_lu_decomp():
    var A = Mat[3, 3](2, -1, 1, 3, 3, 9, 3, 3, 5).transpose()
    var LU = A.LU_decompose()
    assert_true(LU[0] @ LU[1] == LU[2] @ A)
    # assert_true(LU[0] == Mat[3, 3](1, 0, 0, 1.5, 1, 0, 1.5, 0, 1).transpose())
