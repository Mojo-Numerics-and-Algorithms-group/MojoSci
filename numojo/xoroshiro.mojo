# Copyright Timothy H. Keitt 2024
# Adapted from https://prng.di.unimi.it/
# https://github.com/keittlab/numojo


from time import now
from math import rotate_bits_left
from numojo.splitmix import SplitMix


alias Xoroshiro128State = SIMD[DType.uint64, 2]


struct Xoroshiro128plus:
    """Xoroshiro128plus generator."""

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
            rotate_bits_left[24](self.state[0])
            ^ self.state[1]
            ^ (self.state[1] << 16)
        )
        self.state[1] = rotate_bits_left[37](self.state[1])

    @always_inline
    fn next(inout self) -> UInt64:
        """Return the next value in the sequence."""
        var res = self.state[0] + self.state[1]
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


struct Xoroshiro128plusplus:
    """Xoroshiro128plusplus generator."""

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
            rotate_bits_left[49](self.state[0])
            ^ self.state[1]
            ^ (self.state[1] << 21)
        )
        self.state[1] = rotate_bits_left[28](self.state[1])

    @always_inline
    fn next(inout self) -> UInt64:
        """Return the next value in the sequence."""
        var res = rotate_bits_left[17](
            self.state[0] + self.state[1]
        ) + self.state[0]
        self.step()
        return res

    fn jump(inout self):
        """Jump forward in the sequence."""
        var res: Xoroshiro128State = 0
        var coefs = Xoroshiro128State(0x2BD7A6A6E99C2DDC, 0x0992CCAF6A6FCA05)
        for i in range(2):
            for j in range(64):
                if coefs[i] & (1 << j):
                    res ^= self.state
                self.step()
        self.state = res

    fn long_jump(inout self):
        """Jump forward in the sequence."""
        var res: Xoroshiro128State = 0
        var coefs = Xoroshiro128State(0x360FD5F2CF8D5D99, 0x9C6E6877736C46E3)
        for i in range(2):
            for j in range(64):
                if coefs[i] & (1 << j):
                    res ^= self.state
                self.step()
        self.state = res


struct Xoroshiro128starstar:
    """Xoroshiro128starstar generator."""

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
            rotate_bits_left[24](self.state[0])
            ^ self.state[1]
            ^ (self.state[1] << 16)
        )
        self.state[1] = rotate_bits_left[37](self.state[1])

    @always_inline
    fn next(inout self) -> UInt64:
        """Return the next value in the sequence."""
        var res = rotate_bits_left[7](self.state[0] * 5) * 9
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
