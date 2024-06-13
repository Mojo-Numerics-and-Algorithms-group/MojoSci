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


trait PRNGEngine(Copyable):
    fn __call__(inout self) -> UInt64:
        pass


struct PRNG[T: PRNGEngine]:
    alias max_value = UInt64.MAX_FINITE.cast[DType.float64]()

    var engine: T

    fn __init__(inout self, engine: T):
        self.engine = engine

    fn uniform(inout self, min: Float64 = 0, max: Float64 = 1) -> Float64:
        var res = self.engine().cast[DType.float64]()
        return (max - min) * (res / self.max_value) + min

    fn normal(inout self, mean: Float64 = 0, sd: Float64 = 1) -> Float64:
        alias pi2: Float64 = 6.28318530718
        var a: Float64 = self.uniform(min=1e-7)
        var b: Float64 = self.uniform()
        return sd * sqrt(-2 * log(a)) * cos(pi2 * b) + mean
