from testing import *
from numojo.xoroshiro import *


def test_xoroshiro128p():
    var rng = Xoroshiro128p(123456789)
    rng.step()
    rng.step()
    assert_equal(rng.next(), 0xE11CE5D658C7A3C0)
    rng.jump()
    assert_equal(rng.next(), 0xBF336E33B2C5F409)
    rng.long_jump()
    assert_equal(rng.next(), 0x7C40660CFD822A23)
