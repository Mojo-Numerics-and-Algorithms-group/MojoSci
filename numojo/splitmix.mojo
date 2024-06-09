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


@register_passable("trivial")
struct SplitMix:
    """SplitMix 64-bit pseudo-random generator."""

    alias SeedType = UInt64
    alias StateType = UInt64
    alias ValueType = UInt64

    var seed: Self.SeedType
    var state: Self.StateType

    fn __init__(inout self):
        """Seed with current time."""
        self.seed = now()
        self.state = self.seed

    fn __init__(inout self, seed: Self.SeedType):
        """Seed with provided value."""
        self.seed = seed
        self.state = seed

    fn reset(inout self):
        """Start the sequence over using the current seed value."""
        self.state = self.seed

    fn reseed(inout self, seed: Self.SeedType):
        """Set a new seed and reset the generator."""
        self.seed = seed
        self.reset()

    fn get_seed(self) -> Self.SeedType:
        """Return the current seed value."""
        return self.seed

    @always_inline
    fn step(inout self):
        """Advance the generator by one step."""
        self.state += 0x9E3779B97F4A7C15

    @always_inline
    fn next(inout self) -> Self.ValueType:
        """Return the next value in the sequence."""
        self.step()
        var z = self.state
        z = (z ^ (z >> 30)) * 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) * 0x94D049BB133111EB
        return z ^ (z >> 31)

    @always_inline
    fn __call__(inout self) -> Self.ValueType:
        return self.next()

    fn fill[k: Int](inout self, inout other: SIMD[DType.uint64, k]):
        """Fill a SIMD with pseudo-random numbers."""
        for i in range(k):
            other[i] = self.next()
