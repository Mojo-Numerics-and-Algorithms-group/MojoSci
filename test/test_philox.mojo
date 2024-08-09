from testing import assert_equal
from stochasticity.philox import philox432
from stochasticity.splitmix import SplitMix

from python import Python


def test_philox432():
    Python.add_to_path("./sdifphilox")
    var np = Python.import_module("numpy")
    var sd = Python.import_module("sdifphilox")

    alias rounds = 10
    alias low_mask = 0xFFFFFFFF

    var sm = SplitMix(1234)
    var cnt0 = sm.next()
    var cnt1 = sm.next()
    var key = sm.next()

    var counter = np.zeros((4, 1), dtype=np.uint32)
    counter[0] = cnt0 & low_mask
    counter[1] = cnt0 >> 32
    counter[2] = cnt1 & low_mask
    counter[3] = cnt1 >> 32

    var sd_key = np.zeros((2, 1), dtype=np.uint32)
    sd_key[0] = key & low_mask
    sd_key[1] = key >> 32

    var sd_res = sd.philox4_32(counter, sd_key, rounds=rounds)

    var ms_res = philox432[rounds=rounds](cnt0, cnt1, key)

    var sd0: UInt32 = sd_res[0]
    var sd1: UInt32 = sd_res[1]
    var sd2: UInt32 = sd_res[2]
    var sd3: UInt32 = sd_res[3]

    var ms0: UInt32 = (ms_res[0] & 0xFFFFFFFF).cast[DType.uint32]()
    var ms1: UInt32 = (ms_res[0] >> 32).cast[DType.uint32]()
    var ms2: UInt32 = (ms_res[1] & 0xFFFFFFFF).cast[DType.uint32]()
    var ms3: UInt32 = (ms_res[1] >> 32).cast[DType.uint32]()

    assert_equal(sd0, ms0)
    assert_equal(sd1, ms1)
    assert_equal(sd2, ms2)
    assert_equal(sd3, ms3)
