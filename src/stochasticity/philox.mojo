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
from stochasticity.prng_traits import PRNGEngine
from stochasticity.splitmix import SplitMix

# Ported from https://git.unicorn.org.cn/sd/webui/-/blob/v1.6.0/modules/rng_philox.py
# This should match pytorch, except no conversion to normal deviates

alias SIMD64 = SIMD[DType.uint64]

@always_inline
fn philox432[
    n: Int = 1, rounds: Int = 10
](
    owned cnt0: SIMD64[n],
    owned cnt1: SIMD64[n],
    owned key: SIMD64[n],
) -> (SIMD64[n], SIMD64[n]):
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
    fn do_round(
        inout cnt0: SIMD64[n],
        inout cnt1: SIMD64[n],
        key: SIMD64[n],
    ):
        var v0 = 0xD2511F53 * (cnt0 & 0xFFFFFFFF)
        var v1 = 0xCD9E8D57 * (cnt1 & 0xFFFFFFFF)
        var key0 = key << 32
        cnt0 = (v1 << 32) | ((v1 ^ cnt0 ^ key0) >> 32)
        cnt1 = (v0 << 32) | ((v0 ^ cnt1 ^ key) >> 32)

    @always_inline
    fn update_key(
        inout key: SIMD64[n],
    ):
        alias max32 = 2 ** 32
        var key0 = ((key & 0xFFFFFFFF) + 0x9E3779B9) % max32
        var key1 = ((key >> 32) + 0xBB67AE85) % max32
        key = (key1 << 32) | (key0 & 0xFFFFFFFF)

    @parameter
    for _ in range(rounds):
        do_round(cnt0, cnt1, key)
        update_key(key)

    return (cnt0, cnt1)

@register_passable("trivial")
struct PhiloxVect[n: Int, rounds: Int = 10](PRNGEngine):
    """Compute n parallel streams."""

    alias StateType = SIMD64[n]
    alias ValueType = Self.StateType
    alias SeedType = UInt64

    var seed: Self.SeedType
    
    var counter0: Self.StateType
    var counter1: Self.StateType
    var key: Self.StateType

    @staticmethod
    fn ndim() -> Int:
        return n

    fn __init__(inout self):
        """Seed with current time."""
        self.counter0 = 0
        self.counter1 = 0
        self.key = 0
        self.seed = now()
        self.reset()

    fn __init__(inout self, seed: Self.SeedType):
        """Seed with provided value."""
        self.counter0 = 0
        self.counter1 = 0
        self.key = 0
        self.seed = seed
        self.reset()

    fn reset(inout self):
         """Start the sequence over using the current seed value.
         
        After 1000 warmup steps, the SplitMix prng is used to set the
        key of each parallel rng. Counters are started at zero."""
        var seedr = SplitMix(self.seed, 1000)
        @parameter      
        for i in range(n):
            self.key[i] = seedr.next()
        self.counter0 = 0
        self.counter1 = 0
                
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
        @parameter
        self.counter0 += 1
        if any(self.counter0 == 0):
            self.counter1 += 1

    @always_inline
    fn next(inout self) -> Self.ValueType:
        """Return the next value in the sequence.
        
        The nth stream value will be in result[n - 1]."""
        var res = philox432[rounds=rounds](self.counter0, self.counter1, self.key)
        self.step()
        return res[0]

    @always_inline
    fn next_scalar(inout self) -> UInt64:
        """Required for generics."""
        return self.next()[0]

    @always_inline
    fn __call__(inout self) -> Self.ValueType:
        """Same as calling next()."""
        return self.next()

    fn jump(inout self):
        """Incerment first counter."""
        self.counter0 += 1

    fn long_jump(inout self):
        """Increment second counter."""
        self.counter1 += 1

alias Philox = PhiloxVect[n=1]

# fn main():
#     var rng = PhiloxVect[n = 1, rounds = 7]()
#     rng.long_jump()
#     print(rng.next())