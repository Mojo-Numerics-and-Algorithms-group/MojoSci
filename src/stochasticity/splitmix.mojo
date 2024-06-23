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

@register_passable("trivial")
struct SplitMix(PRNGEngine):
    """SplitMix 64-bit pseudo-random generator."""

    alias SeedType = UInt64
    alias StateType = UInt64
    alias ValueType = UInt64

    var seed: Self.SeedType
    var state: Self.StateType

    @staticmethod
    fn ndim() -> Int:
        return 1

    fn __init__(inout self, warmup: Int = 0):
        """Seed with current time.
        
        Arguments:
            warmup -- advance the state this many times."""
        self.state = 0
        self.seed = now()
        self.reset(warmup)

    fn __init__(inout self, seed: Self.SeedType, warmup: Int = 0):
        """Seed with provided value.
        
        Arguments:
            warmup -- advance the state this many times."""
        self.state = 0
        self.seed = seed
        self.reset(warmup)

    fn reset(inout self, warmup: Int = 0):
        """Start the sequence over using the current seed value.
        
        Arguments:
            warmup -- advance the state this many times."""
        self.state = self.seed
        self.step(warmup)

    fn reseed(inout self, seed: Self.SeedType, warmup: Int = 0):
        """Set a new seed and reset the generator.
        
        Arguments:
            warmup -- advance the state this many times."""
        self.seed = seed
        self.reset(warmup)

    fn get_seed(self) -> Self.SeedType:
        """Return the current seed value."""
        return self.seed

    @always_inline
    fn step(inout self):
        """Advance the generator by one step."""
            self.state += 0x9E3779B97F4A7C15

    @always_inline
    fn step(inout self, times: Int):
        """Advance the generator by times steps."""
        for _ in range(times):
            self.step()

    @always_inline
    fn next(inout self) -> Self.ValueType:
        """Return the next value in the sequence."""
        self.step()
        var z = self.state
        z = (z ^ (z >> 30)) * 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) * 0x94D049BB133111EB
        return z ^ (z >> 31)

    @always_inline
    fn next_scalar(inout self) -> UInt64:
        return self.next()

    @always_inline
    fn __call__(inout self) -> Self.ValueType:
        """Same as calling next()."""
        return self.next()
