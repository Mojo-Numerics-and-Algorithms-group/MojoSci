from time import now
from stochasticity.prng_traits import PRNGEngine


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
