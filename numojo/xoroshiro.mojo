# Copyright Timothy H. Keitt 2024
# Adapted from https://prng.di.unimi.it/
# https://github.com/keittlab/numojo


from time import now
from numojo.rand_utils import *


alias Xoroshiro128State = SIMD[DType.uint64, 2]


@always_inline
fn xoroshiro128_plus(state: Xoroshiro128State) -> UInt64:
    """Scrambler for xoshiro plus generator with 128-bits of state."""
    return state[0] + state[1]


@always_inline
fn xoroshiro128_plus_plus(state: Xoroshiro128State) -> UInt64:
    """Scrambler for xoshiro plus-plus generator with 128-bits of state."""
    return rotate_left[17](state[0] + state[1]) + state[0]


@always_inline
fn xoroshiro128_star_star(state: Xoroshiro128State) -> UInt64:
    """Scrambler for xoshiro star-star generator with 128-bits of state."""
    return rotate_left[7](state[1] * 5) * 9


struct Xoroshiro128[scrambler: fn (Xoroshiro128State) -> UInt64]:
    """Engine for xoshiro generators with 128-bits of state."""

    var state: Xoroshiro128State
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
        var res: Xoroshiro128State = 0
        var coefs = Xoroshiro128State(0xDF900294D8F554A5, 0x170865DF4B3201FC)
        for i in range(2):
            for j in range(64):
                if coefs[i] & (1 << j):
                    res ^= self.state
                self.step()
        self.state = res

    fn long_jump(inout self):
        """Jump forward in the sequence."""
        var res: Xoroshiro128State = 0
        var coefs = Xoroshiro128State(0xD2A98B26625EEE7B, 0xDDDF9B1090AA7AC1)
        for i in range(2):
            for j in range(64):
                if coefs[i] & (1 << j):
                    res ^= self.state
                self.step()
        self.state = res


alias Xoroshiro128p = Xoroshiro128[xoroshiro128_plus]
alias Xoroshiro128pp = Xoroshiro128[xoroshiro128_plus_plus]
alias Xoroshiro128ss = Xoroshiro128[xoroshiro128_star_star]
