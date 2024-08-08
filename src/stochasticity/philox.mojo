from time import now
from stochasticity.prng_traits import PRNGEngine


@always_inline
fn philox432[
    n: Int = 1, rounds: Int = 10
](
    key: SIMD[DType.uint64, n],
    cnt0: SIMD[DType.uint64, n],
    cnt1: SIMD[DType.uint64, n] = 0,
) -> (SIMD[DType.uint64, n], SIMD[DType.uint64, n]):
    """Compute output of the Philox 4x32-bit generator.

    Arguments
        key: 2 32-bit keys packed in a 64-bit unsigned interger.
        cnt0: The first 2 32-bit counters packed in a 64-bit integer.
        cnt1: The second 2 32-bit counters.

    Parameters
        n: thd dimentions of the SIMD values.
        rounds: how many rounds of updates.

    Example:
        ```mojo
        from stochasticity.philox import philox432
        var res = philox432(1, 2, 3)
        print(res[0])
        print(res[1])
        ```
    """
    alias T = SIMD[DType.uint64, n]

    @always_inline
    fn l32(x: T) -> T:
        return x & 0xFFFFFFFF

    @always_inline
    fn u32(x: T) -> T:
        return x >> 32

    @always_inline
    fn u32m(x: T) -> T:
        return x & ~0xFFFFFFFF

    var c0 = cnt0
    var c1 = cnt1

    @parameter
    for _ in range(rounds):
        var p0 = l32(key) * l32(c0)
        p0 |= (u32(c0) + l32(p0)) << 32
        var p1 = u32(key) * l32(c1)
        p1 |= (u32(c1) + l32(p1)) << 32
        c0 = u32m(p1) | l32(p1 ^ (p1 >> 48))
        c1 = u32m(p0) | l32(p0 ^ (p0 >> 48))

    return (c0, c1)


fn main():
    var res = philox432(1111111, 2222222, 3333333)
    print(res[0] & 0xFFFFFFFF)
    print(res[0] >> 32)
    print(res[1] & 0xFFFFFFFF)
    print(res[1] >> 32)
