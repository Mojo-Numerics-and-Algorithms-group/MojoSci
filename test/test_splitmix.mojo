from testing import *
from numojo.rand_utils import *


def test_splitmix():
    var rng = SplitMix(123456789)
    assert_equal(rng.next(), 0x9E3779B986A6492A)
