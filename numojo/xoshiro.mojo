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


alias Xoshiro256State = SIMD[DType.uint64, 4]


@always_inline
fn xoshiro256_plus(state: Xoshiro256State) -> UInt64:
    """Scrambler for xoshiro plus generator with 256-bits of state."""
    return state[0] + state[3]


@always_inline
fn xoshiro256_plus_plus(state: Xoshiro256State) -> UInt64:
    """Scrambler for xoshiro plus-plus generator with 256-bits of state."""
    return rotate_left[23](state[0] + state[3]) + state[0]


@always_inline
fn xoshiro256_star_star(state: Xoshiro256State) -> UInt64:
     """Scrambler for xoshiro star-star generator with 256-bits of state."""
    return rotate_left[7](state[1] * 5) * 9


struct Xoshiro256[scrambler: fn (Xoshiro256State) -> UInt64]:
    """Engine for xoshiro generators with 256-bits of state."""
    var state: Xoshiro256State
    var seed: UInt64

    fn __init__(inout self):
        """Seed with current time."""
        self.state = 0
        self.seed = now()
        self.reset()

    fn __init__(inout self, seed: UInt64):
        """Seed with provided value."""
        self.state = 0
        self.seed = seed
        self.reset()

    fn reset(inout self):
         """Start the sequence over using the current seed value."""
        var seedr = SplitMix(self.seed)
        seedr.fill(self.state)

    fn set_seed(inout self, seed: UInt64):
        """Set a new seed and reset the generator."""
        self.seed = seed
        self.reset()

    fn get_seed(self) -> UInt64:
        """Return the current seed value."""
        return self.seed

    @always_inline
    fn step(inout self):
        """Advance the generator by one step."""
        var t = self.state[1] << 17
        self.state[2] ^= self.state[0]
        self.state[3] ^= self.state[1]
        self.state[1] ^= self.state[2]
        self.state[0] ^= self.state[3]
        self.state[2] ^= t
        self.state[3] = rotate_left[45](self.state[3])

    @always_inline
    fn next(inout self) -> UInt64:
        """Return the next value in the sequence."""
        var res = scrambler(self.state)
        self.step()
        return res

    fn jump(inout self):
        """Jump forward in the sequence."""
        var res: Xoshiro256State = 0
        var coefs = Xoshiro256State(
            0x180EC6D33CFD0ABA,
            0xD5A61266F0C9392C,
            0xA9582618E03FC9AA,
            0x39ABDC4529B1661C,
        )
        for i in range(4):
            for j in range(64):
                if coefs[i] & (1 << j):
                    res ^= self.state
                self.step()
        self.state = res

    fn long_jump(inout self):
        """Jump forward in the sequence."""
        var res: Xoshiro256State = 0
        var coefs = Xoshiro256State(
            0x76E15D3EFEFDCBBF,
            0xC5004E441C522FB3,
            0x77710069854EE241,
            0x39109BB02ACBE635,
        )
        for i in range(4):
            for j in range(64):
                if coefs[i] & (1 << j):
                    res ^= self.state
                self.step()
        self.state = res


alias Xoshiro256p = Xoshiro256[xoshiro256_plus]
alias Xoshiro256pp = Xoshiro256[xoshiro256_plus_plus]
alias Xoshiro256ss = Xoshiro256[xoshiro256_star_star]

alias Xoshiro128State = SIMD[DType.uint64, 2]


@always_inline
fn xoshiro128_plus(state: Xoshiro128State) -> UInt64:
    """Scrambler for xoshiro plus generator with 128-bits of state."""
    return state[0] + state[1]


@always_inline
fn xoshiro128_plus_plus(state: Xoshiro128State) -> UInt64:
    """Scrambler for xoshiro plus-plus generator with 128-bits of state."""
    return rotate_left[17](state[0] + state[1]) + state[0]


@always_inline
fn xoshiro128_star_star(state: Xoshiro128State) -> UInt64:
    """Scrambler for xoshiro star-star generator with 128-bits of state."""
    return rotate_left[7](state[1] * 5) * 9


struct Xoshiro128[scrambler: fn (Xoshiro128State) -> UInt64]:
    """Engine for xoshiro generators with 128-bits of state."""
    var state: Xoshiro128State
    var seed: UInt64

    fn __init__(inout self):
    """Seed with current time."""
        self.state = 0
        self.seed = now()
        self.reset()

    fn __init__(inout self, seed: UInt64):
    """Seed with provided value."""
        self.state = 0
        self.seed = seed
        self.reset()

    fn reset(inout self):
    """Start the sequence over using the current seed value."""
        var seedr = SplitMix(self.seed)
        seedr.fill(self.state)

    fn set_seed(inout self, seed: UInt64):
        """Set a new seed and reset the generator."""
        self.seed = seed
        self.reset()

    fn get_seed(self) -> UInt64:
        """Return the current seed value."""
        return self.seed

    @always_inline
    fn step(inout self):
        """Advance the generator by one step."""
        self.state[1] ^= self.state[0]
        self.state[0] = (
            rotate_left[24](self.state[0])
            ^ self.state[1]
            ^ (self.state[1] << 16)
        )
        self.state[1] = rotate_left[37](self.state[1])

    @always_inline
    fn next(inout self) -> UInt64:
        """Return the next value in the sequence."""
        var res = scrambler(self.state)
        self.step()
        return res

    fn jump(inout self):
        """Jump forward in the sequence."""
        var res: Xoshiro128State = 0
        var coefs = Xoshiro128State(0xDF900294D8F554A5, 0x170865DF4B3201FC)
        for i in range(2):
            for j in range(64):
                if coefs[i] & (1 << j):
                    res ^= self.state
                self.step()
        self.state = res

    fn long_jump(inout self):
        """Jump forward in the sequence."""
        var res: Xoshiro128State = 0
        var coefs = Xoshiro128State(0xD2A98B26625EEE7B, 0xDDDF9B1090AA7AC1)
        for i in range(2):
            for j in range(64):
                if coefs[i] & (1 << j):
                    res ^= self.state
                self.step()
        self.state = res


alias Xoshiro129p = Xoshiro128[xoshiro128_plus]
alias Xoshiro128pp = Xoshiro128[xoshiro128_plus_plus]
alias Xoshiro128ss = Xoshiro128[xoshiro128_star_star]
