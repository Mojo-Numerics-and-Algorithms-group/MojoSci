# ===----------------------------------------------------------------------=== #
# Copyright (c) 2024, Timothy H. Keitt. All rights reserved.
#
# Licensed under the Apache License v2.0 with LLVM Exceptions:
# https://llvm.org/LICENSE.txt
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ===----------------------------------------------------------------------=== #

from time import now
from bit import rotate_bits_left
from numojo.splitmix import SplitMix


@register_passable("trivial")
struct Xoroshiro128Plus:
    """Xoroshiro128plus generator."""

    alias StateType = UInt64

    var seed: UInt64
    var s0: Self.StateType
    var s1: Self.StateType

    fn __init__(inout self):
        """Seed with current time."""
        self.s0 = 0
        self.s1 = 9
        self.seed = now()
        self.reset()

    fn __init__(inout self, seed: UInt64):
        """Seed with provided value."""
        self.s0 = 0
        self.s1 = 0
        self.seed = seed
        self.reset()

    fn reset(inout self):
        """Start the sequence over using the current seed value."""
        var seedr = SplitMix(self.seed)
        self.s0 = seedr.next()
        self.s1 = seedr.next()

    fn reseed(inout self, seed: UInt64):
        """Set a new seed and reset the generator."""
        self.seed = seed
        self.reset()

    fn get_seed(self) -> UInt64:
        """Return the current seed value."""
        return self.seed

    @always_inline
    fn step(inout self):
        """Advance the generator by one step."""
        self.s1 ^= self.s0
        self.s0 = rotate_bits_left[24](self.s0) ^ self.s1 ^ (self.s1 << 16)
        self.s1 = rotate_bits_left[37](self.s1)

    @always_inline
    fn next(inout self) -> UInt64:
        """Return the next value in the sequence."""
        var res = self.s0 + self.s1
        self.step()
        return res

    fn jump(inout self):
        """Jump forward in the sequence."""
        alias coefs0: UInt64 = 0xDF900294D8F554A5
        alias coefs1: UInt64 = 0x170865DF4B3201FC
        var s0: Self.StateType = 0
        var s1: Self.StateType = 0
        for j in range(64):
            if coefs0 & (1 << j):
                s0 ^= self.s0
                s1 ^= self.s1
            self.step()
        for j in range(64):
            if coefs1 & (1 << j):
                s0 ^= self.s0
                s1 ^= self.s1
            self.step()
        self.s0 = s0
        self.s1 = s1

    fn long_jump(inout self):
        """Jump forward in the sequence."""
        alias coefs0: UInt64 = 0xD2A98B26625EEE7B
        alias coefs1: UInt64 = 0xDDDF9B1090AA7AC1
        var s0: Self.StateType = 0
        var s1: Self.StateType = 0
        for j in range(64):
            if coefs0 & (1 << j):
                s0 ^= self.s0
                s1 ^= self.s1
            self.step()
        for j in range(64):
            if coefs1 & (1 << j):
                s0 ^= self.s0
                s1 ^= self.s1
            self.step()
        self.s0 = s0
        self.s1 = s1


struct Xoroshiro128PlusPlus:
    """Xoroshiro128plusplus generator."""

    alias StateType = UInt64

    var seed: UInt64
    var s0: Self.StateType
    var s1: Self.StateType

    fn __init__(inout self):
        """Seed with current time."""
        self.s0 = 0
        self.s1 = 0
        self.seed = now()
        self.reset()

    fn __init__(inout self, seed: UInt64):
        """Seed with provided value."""
        self.s0 = 0
        self.s1 = 0
        self.seed = seed
        self.reset()

    fn reset(inout self):
        """Start the sequence over using the current seed value."""
        var seedr = SplitMix(self.seed)
        self.s0 = seedr.next()
        self.s1 = seedr.next()

    fn reseed(inout self, seed: UInt64):
        """Set a new seed and reset the generator."""
        self.seed = seed
        self.reset()

    fn get_seed(self) -> UInt64:
        """Return the current seed value."""
        return self.seed

    @always_inline
    fn step(inout self):
        """Advance the generator by one step."""
        self.s1 ^= self.s0
        self.s0 = rotate_bits_left[49](self.s0) ^ self.s1 ^ (self.s1 << 21)
        self.s1 = rotate_bits_left[28](self.s1)

    @always_inline
    fn next(inout self) -> UInt64:
        """Return the next value in the sequence."""
        var res = rotate_bits_left[17](self.s0 + self.s1) + self.s0
        self.step()
        return res

    fn jump(inout self):
        """Jump forward in the sequence."""
        alias coefs0: UInt64 = 0x2BD7A6A6E99C2DDC
        alias coefs1: UInt64 = 0x0992CCAF6A6FCA05
        var s0: Self.StateType = 0
        var s1: Self.StateType = 0
        for j in range(64):
            if coefs0 & (1 << j):
                s0 ^= self.s0
                s1 ^= self.s1
            self.step()
        for j in range(64):
            if coefs1 & (1 << j):
                s0 ^= self.s0
                s1 ^= self.s1
            self.step()
        self.s0 = s0
        self.s1 = s1

    fn long_jump(inout self):
        """Jump forward in the sequence."""
        alias coefs0: UInt64 = 0x360FD5F2CF8D5D99
        alias coefs1: UInt64 = 0x9C6E6877736C46E3
        var s0: Self.StateType = 0
        var s1: Self.StateType = 0
        for j in range(64):
            if coefs0 & (1 << j):
                s0 ^= self.s0
                s1 ^= self.s1
            self.step()
        for j in range(64):
            if coefs1 & (1 << j):
                s0 ^= self.s0
                s1 ^= self.s1
            self.step()
        self.s0 = s0
        self.s1 = s1


struct Xoroshiro128StarStar:
    """Xoroshiro128starstar generator."""

    alias StateType = UInt64

    var seed: UInt64
    var s0: Self.StateType
    var s1: Self.StateType

    fn __init__(inout self):
        """Seed with current time."""
        self.s0 = 0
        self.s1 = 0
        self.seed = now()
        self.reset()

    fn __init__(inout self, seed: UInt64):
        """Seed with provided value."""
        self.s0 = 0
        self.s1 = 0
        self.seed = seed
        self.reset()

    fn reset(inout self):
        """Start the sequence over using the current seed value."""
        var seedr = SplitMix(self.seed)
        self.s0 = seedr.next()
        self.s1 = seedr.next()

    fn reseed(inout self, seed: UInt64):
        """Set a new seed and reset the generator."""
        self.seed = seed
        self.reset()

    fn get_seed(self) -> UInt64:
        """Return the current seed value."""
        return self.seed

    @always_inline
    fn step(inout self):
        """Advance the generator by one step."""
        self.s1 ^= self.s0
        self.s0 = rotate_bits_left[24](self.s0) ^ self.s1 ^ (self.s1 << 16)
        self.s1 = rotate_bits_left[37](self.s1)

    @always_inline
    fn next(inout self) -> UInt64:
        """Return the next value in the sequence."""
        var res = rotate_bits_left[7](self.s0 * 5) * 9
        self.step()
        return res

    fn jump(inout self):
        """Jump forward in the sequence."""
        alias coefs0: UInt64 = 0xDF900294D8F554A5
        alias coefs1: UInt64 = 0x170865DF4B3201FC
        var s0: Self.StateType = 0
        var s1: Self.StateType = 0
        for j in range(64):
            if coefs0 & (1 << j):
                s0 ^= self.s0
                s1 ^= self.s1
            self.step()
        for j in range(64):
            if coefs1 & (1 << j):
                s0 ^= self.s0
                s1 ^= self.s1
            self.step()
        self.s0 = s0
        self.s1 = s1

    fn long_jump(inout self):
        """Jump forward in the sequence."""
        alias coefs0: UInt64 = 0xD2A98B26625EEE7B
        alias ceofs1: UInt64 = 0xDDDF9B1090AA7AC1
        var s0: Self.StateType = 0
        var s1: Self.StateType = 0
        for j in range(64):
            if coefs0 & (1 << j):
                s0 ^= self.s0
                s1 ^= self.s1
            self.step()
        for j in range(64):
            if ceofs1 & (1 << j):
                s0 ^= self.s0
                s1 ^= self.s1
            self.step()
        self.s0 = s0
        self.s1 = s1
