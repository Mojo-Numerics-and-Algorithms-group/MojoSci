from testing import *
from numojo.xoshiro import *

def test_step_splitmix():
    var state: SplitMixState = 0
    step(state)
    assert_equal(state, 0x9e3779b97f4a7c15)

