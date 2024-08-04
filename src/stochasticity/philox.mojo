from time import now
from stochasticity.prng_traits import PRNGEngine


@always_inline
fn l32[n: Int = 1](x: SIMD[DType.uint64, n]) -> SIMD[DType.uint64, n]:
    alias lb: SIMD[DType.uint64, n] = 0xFFFFFFFF
    return x & lb


@always_inline
fn u32[n: Int = 1](x: SIMD[DType.uint64, n]) -> SIMD[DType.uint64, n]:
    return x >> 32


@always_inline
fn philox432[
    n: Int = 1, rounds: Int = 10
](
    key: SIMD[DType.uint64, n],
    cnt0: SIMD[DType.uint64, n],
    cnt1: SIMD[DType.uint64, n],
) -> (SIMD[DType.uint64, n], SIMD[DType.uint64, n]):
    var c0 = cnt0
    var c1 = cnt1

    @parameter
    for _ in range(rounds):
        var p0 = l32(key) * l32(c0)
        p0 |= (u32(c0) + l32(p0)) << 32
        var p1 = u32(key) * l32(c1)
        p1 |= (u32(c1) + l32(p1)) << 32
        c0 = u32(p1) << 32 | l32(p1 ^ (p1 >> 48))
        c1 = u32(p0) << 32 | l32(p0 ^ (p0 >> 48))

    return (c0, c1)


@register_passable("trivial")
struct Philox4x32(PRNGEngine):
    """Philox 32-bit pseudo-random generator."""

    alias StateType = UInt32
    alias ValueType = UInt64

    var c0: Self.StateType
    var c1: Self.StateType
    var c2: Self.StateType
    var c3: Self.StateType
    var k0: Self.StateType
    var k1: Self.StateType
    var p0: Self.StateType
    var p1: Self.StateType
    var p2: Self.StateType
    var p3: Self.StateType

    fn _do_round(inout self):
        var x0 = self.c0.cast[DType.uint64]() * self.k0.cast[DType.uint64]()
        var x1 = self.c2.cast[DType.uint64]() * self.k1.cast[DType.uint64]()
        self.p0 = x0.cast[DType.uint32]()
        self.p1 = self.c1 + (x0 >> 32).cast[DType.uint32]()
        self.p2 = x1.cast[DType.uint32]()
        self.p3 = self.c3 + (x1 >> 32).cast[DType.uint32]()
        self.p0 ^= self.p1 >> 16
        self.p2 ^= self.p3 >> 16
        swap(self.p0, self.p2)
        swap(self.p1, self.p3)
