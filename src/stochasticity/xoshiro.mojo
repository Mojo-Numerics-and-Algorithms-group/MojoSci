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
from utils.numerics import max_finite
from stochasticity.splitmix import SplitMix
from stochasticity.prng_traits import PRNGEngine

@always_inline
fn xoshiro256_plus[n: Int, T: DType](s0: SIMD[T, n], s1: SIMD[T, n], s2: SIMD[T, n], s3: SIMD[T, n]) -> SIMD[T, n]:
    """Mixer for xoshiro plus generator with 256-bits of state."""
    return s0 + s3


@always_inline
fn xoshiro256_plus_plus[n: Int, T: DType](s0: SIMD[T, n], s1: SIMD[T, n], s2: SIMD[T, n], s3: SIMD[T, n]) -> SIMD[T, n]:
    """Mixer for xoshiro plus-plus generator with 256-bits of state."""
    return rotate_bits_left[23](s0 + s3) + s0


@always_inline
fn xoshiro256_star_star[n: Int, T: DType](s0: SIMD[T, n], s1: SIMD[T, n], s2: SIMD[T, n], s3: SIMD[T, n]) -> SIMD[T, n]:
     """Mixer for xoshiro star-star generator with 256-bits of state."""
    return rotate_bits_left[7](s1 * 5) * 9

alias MixerType = fn[n: Int, T: DType](SIMD[T, n], SIMD[T, n], SIMD[T, n], SIMD[T, n]) -> SIMD[T, n]

@register_passable("trivial")
struct Xoshiro256Vect[n: Int, mixer: MixerType](PRNGEngine):
    """Compute n parallel streams."""

    alias StateType = SIMD[DType.uint64, n]
    alias ValueType = Self.StateType
    alias SeedType = UInt64

    var seed: Self.SeedType
    
    var s0: Self.StateType
    var s1: Self.StateType
    var s2: Self.StateType
    var s3: Self.StateType

    @staticmethod
    fn ndim() -> Int:
        return n

    fn __init__(inout self):
        """Seed with current time."""
        self.s0 = 0
        self.s1 = 0
        self.s2 = 0
        self.s3 = 0
        self.seed = now()
        self.reset()

    fn __init__(inout self, seed: Self.SeedType):
        """Seed with provided value."""
        self.s0 = 0
        self.s1 = 0
        self.s2 = 0
        self.s3 = 0
        self.seed = seed
        self.reset()

    fn reset(inout self):
         """Start the sequence over using the current seed value.
         
        The scalar engine is seeded by SplitMix. If there are more
        dimentions, other n-1 streams are seeded by taking a jump
        and assigning the jumped state to the next generator.
        This will result in independent streams, which will be
        returned as n-values in a SIMD."""
        @parameter
        if n == 1:
            var seedr = SplitMix(self.seed, 1000)
            self.s0 = seedr.next()
            self.s1 = seedr.next()
            self.s2 = seedr.next()
            self.s3 = seedr.next()
        else:
            var seedr = Xoshiro256Vect[1, mixer](self.seed)
            for i in range(n):
                self.s0[i] = seedr.s0
                self.s1[i] = seedr.s1
                self.s2[i] = seedr.s2
                self.s3[i] = seedr.s3
                seedr.jump()

    fn reseed(inout self, seed: Self.SeedType):
        """Set a new seed and reset the generator."""
        self.seed = seed
        self.reset()

    fn get_seed(self) -> Self.SeedType:
        """Return the current seed value."""
        return self.seed

    @always_inline
    fn step(inout self):
        """Advance the generator by one step.
        
        The streams are advanced in parallel
        using SIMD operations."""
        var t = self.s1 << 17
        self.s2 ^= self.s0
        self.s3 ^= self.s1
        self.s1 ^= self.s2
        self.s0 ^= self.s3
        self.s2 ^= t
        self.s3 = rotate_bits_left[45](self.s3)

    @always_inline
    fn next(inout self) -> Self.ValueType:
        """Return the next value in the sequence.
        
        The nth stream value will be in result[n - 1]."""
        var res = mixer(self.s0, self.s1, self.s2, self.s3)
        self.step()
        return res

    @always_inline
    fn next_scalar(inout self) -> UInt64:
        """Required for generics."""
        return self.next()[0]

    @always_inline
    fn __call__(inout self) -> Self.ValueType:
        """Same as calling next()."""
        return self.next()

    fn jump(inout self):
        """Jump forward in the sequence.
        
        It is equivalent to 2^128 calls to step(); it can be used to generate 2^128
        non-overlapping subsequences for parallel computations."""
        alias coefs0: UInt64 = 0x180EC6D33CFD0ABA
        alias coefs1: UInt64 = 0xD5A61266F0C9392C
        alias coefs2: UInt64 = 0xA9582618E03FC9AA
        alias coefs3: UInt64 = 0x39ABDC4529B1661C
        var s0: Self.StateType = 0
        var s1: Self.StateType = 0
        var s2: Self.StateType = 0
        var s3: Self.StateType = 0
        for j in range(64):
            if coefs0 & (1 << j):
                s0 ^= self.s0
                s1 ^= self.s1
                s2 ^= self.s2
                s3 ^= self.s3
            self.step()
        for j in range(64):
            if coefs1 & (1 << j):
                s0 ^= self.s0
                s1 ^= self.s1
                s2 ^= self.s2
                s3 ^= self.s3
            self.step()
        for j in range(64):
            if coefs2 & (1 << j):
                s0 ^= self.s0
                s1 ^= self.s1
                s2 ^= self.s2
                s3 ^= self.s3
            self.step()
        for j in range(64):
            if coefs3 & (1 << j):
                s0 ^= self.s0
                s1 ^= self.s1
                s2 ^= self.s2
                s3 ^= self.s3
            self.step()
        self.s0 = s0
        self.s1 = s1
        self.s2 = s2
        self.s3 = s3

    fn long_jump(inout self):
        """Jump forward in the sequence.
        
        It is equivalent to 2^192 calls to step();
        it can be used to generate 2^64 starting points,
        from each of which jump() will generate 2^64 non-overlapping
        subsequences for parallel distributed computations."""
        alias coefs0: UInt64 = 0x76E15D3EFEFDCBBF
        alias coefs1: UInt64 = 0xC5004E441C522FB3
        alias coefs2: UInt64 = 0x77710069854EE241
        alias coefs3: UInt64 = 0x39109BB02ACBE635
        var s0: Self.StateType = 0
        var s1: Self.StateType = 0
        var s2: Self.StateType = 0
        var s3: Self.StateType = 0
        for j in range(64):
            if coefs0 & (1 << j):
                s0 ^= self.s0
                s1 ^= self.s1
                s2 ^= self.s2
                s3 ^= self.s3
            self.step()
        for j in range(64):
            if coefs1 & (1 << j):
                s0 ^= self.s0
                s1 ^= self.s1
                s2 ^= self.s2
                s3 ^= self.s3
            self.step()
        for j in range(64):
            if coefs2 & (1 << j):
                s0 ^= self.s0
                s1 ^= self.s1
                s2 ^= self.s2
                s3 ^= self.s3
            self.step()
        for j in range(64):
            if coefs3 & (1 << j):
                s0 ^= self.s0
                s1 ^= self.s1
                s2 ^= self.s2
                s3 ^= self.s3
            self.step()
        self.s0 = s0
        self.s1 = s1
        self.s2 = s2
        self.s3 = s3

alias Xoshiro256VectStarStar = Xoshiro256Vect[mixer = xoshiro256_star_star]
alias Xoshiro256VectPlusPlus = Xoshiro256Vect[mixer = xoshiro256_plus_plus]
alias Xoshiro256VectPlus = Xoshiro256Vect[mixer = xoshiro256_plus]
alias Xoshiro256StarStar = Xoshiro256VectStarStar[n = 1]
alias Xoshiro256PlusPlus = Xoshiro256VectPlusPlus[n = 1]
alias Xoshiro256Plus = Xoshiro256VectPlus[n = 1]

# fn main():
#     var rng = Xoshiro256VectPlusPlus[4]()
#     print(rng.get_seed())
#     print(rng.next_scalar())