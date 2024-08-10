from time import now
from stochasticity.prng_traits import PRNGEngine

# Ported from https://git.unicorn.org.cn/sd/webui/-/blob/v1.6.0/modules/rng_philox.py
# This should match pytorch, except no conversion to normal deviates


@always_inline
fn philox432[
    n: Int = 1, rounds: Int = 10
](
    owned cnt0: SIMD[DType.uint64, n],
    owned cnt1: SIMD[DType.uint64, n],
    owned key: SIMD[DType.uint64, n],
) -> (SIMD[DType.uint64, n], SIMD[DType.uint64, n]):
    """Compute output of the Philox 4x32-bit generator.

    Arguments
        cnt0: The first 2 32-bit counters packed in a 64-bit integer.
        cnt1: The second 2 32-bit counters.
        key: 2 32-bit keys packed in a 64-bit unsigned interger.

    Parameters
        n: thd dimentions of the SIMD values.
        rounds: how many rounds of updates.

    Example:
        ```mojo
        %#from stochasticity.philox import philox432
        var res = philox432(1234, 4321, 7777)
        print(res[0], res[1])
        ```
    """

    @always_inline
    fn do_round(
        inout cnt0: SIMD[DType.uint64, n],
        inout cnt1: SIMD[DType.uint64, n],
        key: SIMD[DType.uint64, n],
    ):
        var v1 = 0xD2511F53 * (cnt0 & 0xFFFFFFFF)
        var v2 = 0xCD9E8D57 * (cnt1 & 0xFFFFFFFF)
        var key0 = key << 32
        cnt0 = (v2 << 32) | ((v2 ^ cnt0 ^ key0) >> 32)
        cnt1 = (v1 << 32) | ((v1 ^ cnt1 ^ key) >> 32)

    @always_inline
    fn update_key(
        inout key: SIMD[DType.uint64, n],
    ):
        var key0 = key & 0xFFFFFFFF
        var key1 = key >> 32
        key = ((key1 + 0xBB67AE85) << 32) | ((key0 + 0x9E3779B9) & 0xFFFFFFFF)

    @parameter
    for _ in range(rounds):
        do_round(cnt0, cnt1, key)
        update_key(key)

    return (cnt0, cnt1)


# from testing import assert_equal
# from stochasticity.splitmix import SplitMix

# from python import Python


# def main():
#     alias rounds = 10
#     alias low_mask = 0xFFFFFFFF

#     var sm = SplitMix(1234)
#     var cnt0: UInt64 = sm.next()
#     var cnt1: UInt64 = sm.next()
#     var key: UInt64 = sm.next()

#     var ms_res = philox432[rounds=rounds](cnt0, cnt1, key)

#     var ms0: UInt32 = (ms_res[0] & 0xFFFFFFFF).cast[DType.uint32]()
#     var ms1: UInt32 = (ms_res[0] >> 32).cast[DType.uint32]()
#     var ms2: UInt32 = (ms_res[1] & 0xFFFFFFFF).cast[DType.uint32]()
#     var ms3: UInt32 = (ms_res[1] >> 32).cast[DType.uint32]()

#     print(ms0, ms1, ms2, ms3)

#    var np = Python.import_module("numpy")
#    var sd = Python.import_module("sdifphilox")

#     var counter = np.zeros((4, 1), dtype=np.uint32)
#     counter[0] = cnt0 & low_mask
#     counter[1] = cnt0 >> 32
#     counter[2] = cnt1 & low_mask
#     counter[3] = cnt1 >> 32

#     var sd_key = np.zeros((2, 1), dtype=np.uint32)
#     sd_key[0] = key & low_mask
#     sd_key[1] = key >> 32

#     var sd_res = sd.philox4_32(counter, sd_key, rounds=rounds)

#     var sd0: UInt32 = sd_res[0]
#     var sd1: UInt32 = sd_res[1]
#     var sd2: UInt32 = sd_res[2]
#     var sd3: UInt32 = sd_res[3]

#     assert_equal(sd0, ms0)
#     assert_equal(sd1, ms1)
#     assert_equal(sd2, ms2)
#     assert_equal(sd3, ms3)
