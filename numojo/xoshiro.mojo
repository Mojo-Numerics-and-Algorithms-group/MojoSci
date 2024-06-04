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


alias Xoshiro256State = SIMD[DType.uint64, 4]


@always_inline
fn xoshiro256_plus(state: Xoshiro256State) -> UInt64:
    """Scrambler for xoshiro plus generator with 256-bits of state."""
    return state[0] + state[3]


@always_inline
fn xoshiro256_plus_plus(state: Xoshiro256State) -> UInt64:
    """Scrambler for xoshiro plus-plus generator with 256-bits of state."""
    return rotate_bits_left[23](state[0] + state[3]) + state[0]


@always_inline
fn xoshiro256_star_star(state: Xoshiro256State) -> UInt64:
     """Scrambler for xoshiro star-star generator with 256-bits of state."""
    return rotate_bits_left[7](state[1] * 5) * 9


@register_passable("trivial")
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
        self.state[3] = rotate_bits_left[45](self.state[3])

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


alias Xoshiro256plus = Xoshiro256[xoshiro256_plus]
alias Xoshiro256plusplus = Xoshiro256[xoshiro256_plus_plus]
alias Xoshiro256starstar = Xoshiro256[xoshiro256_star_star]
