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
from utils.numerics import max_finite
from stochasticity.traits import *


# @register_passable("trivial")
struct PRNG[T: PRNGEngine]:
    # alias EngineReturnType: DType = T.return_type()
    # alias max_value = max_finite[Self.EngineReturnType]()
    alias max_value = UInt64.MAX_FINITE

    var engine: T

    fn __init__(inout self, owned engine: T):
        self.engine = engine^

    fn uniform_uint(inout self, min: UInt64 = 0, max: UInt64 = 1) -> UInt64:
        """Generate uniform random unsigned integers."""
        var res = self.engine()
        var scaled = res % (max - min + 1)
        return scaled + min

    fn uniform(inout self, min: Float64 = 0, max: Float64 = 1) -> Float64:
        """Generate uniform random floats."""
        var res = self.engine().cast[DType.float64]()
        var scaled = res / self.max_value.cast[DType.float64]()
        return (max - min) * scaled + min

    fn normal(inout self, mean: Float64 = 0, sd: Float64 = 1) -> Float64:
        """Generate normal deviates.

        This method is not highly accurate in the
        tails of the distrubtion."""
        alias pi2: Float64 = 6.28318530718
        var a: Float64 = self.uniform(min=1e-7)
        var b: Float64 = self.uniform()
        return sd * sqrt(-2 * log(a)) * cos(pi2 * b) + mean


from stochasticity.xoshiro import *


fn main():
    var eng = Xoshiro256PlusPlus()
    var rng = PRNG(eng)
    print(rng.uniform_uint())
