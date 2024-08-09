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
    fn do_round[
        n: Int
    ](
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
    fn update_key[
        n: Int
    ](inout key: SIMD[DType.uint64, n],):
        var key0 = key & 0xFFFFFFFF
        var key1 = key >> 32
        key = ((key1 + 0xBB67AE85) << 32) | ((key0 + 0x9E3779B9) & 0xFFFFFFFF)

    @parameter
    for _ in range(rounds):
        do_round(cnt0, cnt1, key)
        update_key(key)

    return (cnt0, cnt1)
