from testing import *
from numojo.utils import *


def test_rotate_left():
    var res = rotate_left[3](123456789)
    assert_equal(res, 0x3ADE68A8)
