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


from math import sqrt, log, cos
from utils.numerics import nextafter
from stochasticity.prng_traits import PRNGEngine


# @register_passable("trivial")
struct PRNG[T: PRNGEngine]:
    var engine: T

    fn __init__(inout self, owned engine: T):
        self.engine = engine^

    fn uniform_uint(inout self, min: UInt64 = 0, max: UInt64 = 1) -> UInt64:
        """Generate uniform random unsigned integers."""
        var res = self.engine.next_scalar()
        var scaled = res % (max - min + 1)
        return scaled + min

    fn uniform(inout self, min: Float64 = 0, max: Float64 = 1) -> Float64:
        """Generate uniform random floats."""
        alias max_val = UInt64.MAX_FINITE.cast[DType.float64]()
        var res = self.engine.next_scalar()
        var scaled = res.cast[DType.float64]() / max_val
        return (max - min) * scaled + min

    fn normal(inout self, mean: Float64 = 0, sd: Float64 = 1) -> Float64:
        """Generate normal deviates."""
        alias guard = nextafter(0.0, 1.0)
        alias pi2 = 6.28318530718
        var a = self.uniform(min=guard)
        var b = self.uniform(max=pi2)
        return sd * sqrt(-2 * log(a)) * cos(b) + mean

    fn bernoulli(inout self, p: Float64 = 0.5) -> Int:
        if p > self.uniform():
            return 0
        else:
            return 1

    fn exp(inout self, mean: Float64 = 1) -> Float64:
        return -log(self.uniform()) * mean


# from stochasticity.xoshiro import *


# fn main() raises:
#     var eng = Xoshiro256PlusPlus()
#     var rng = PRNG(eng)
#     print(rng.bernoulli())
