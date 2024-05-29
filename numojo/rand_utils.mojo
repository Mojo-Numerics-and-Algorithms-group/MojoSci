# Copyright Timothy H. Keitt 2024
# Adapted from https://prng.di.unimi.it/
# https://github.com/keittlab/numojo


from time import now


struct SplitMix:
    """SplitMix 64-bit pseudo-random generator."""
    var seed: UInt64
    var state: UInt64

    fn __init__(inout self):
        """Seed with current time."""
        self.seed = now()
        self.state = self.seed

    fn __init__(inout self, seed: UInt64):
        """Seed with provided value."""
        self.seed = seed
        self.state = seed

    fn reset(inout self):
        """Start the sequence over using the current seed value."""
        self.state = self.seed

    fn set_seed(inout self, seed: UInt64):
        """Set a new seed and reset the generator."""
        self.seed = seed
        self.reset()

    fn get_seed(self) -> UInt64:
        """Return the current seed value."""
        return self.seed

    @always_inline
    fn step(inout self: SplitMix):
        """Advance the generator by one step."""
        self.state += 0x9E3779B97F4A7C15

    @always_inline
    fn next(inout self: SplitMix) -> UInt64:
        """Return the next value in the sequence."""
        self.step()
        var z = self.state
        z = (z ^ (z >> 30)) * 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) * 0x94D049BB133111EB
        return z ^ (z >> 31)

    fn fill[k: Int](inout self, inout other: SIMD[DType.uint64, k]):
        """Fill a SIMD with pseudo-random numbers."""
        for i in range(k):
            other[i] = self.next()


@always_inline
fn rotate_left[k: UInt64](x: UInt64) -> UInt64:
    """Performs bitwise rotation of a 64-bit integer."""
    constrained[k < 64, "Invalid rotation"]()
    return x << k | x >> 64 - k
