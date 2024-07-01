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

from diffeq.traits import DESys

from linalg.static_matrix import (
    StaticMat as Mat,
    StaticColVec as ColVec,
    StaticRowVec as RowVec,
)


@value
struct Lorenz(DESys):
    var p1: Float64
    var p2: Float64
    var p3: Float64

    fn __init__(inout self, p1: Float64, p2: Float64, p3: Float64):
        self.p1 = p1
        self.p2 = p2
        self.p3 = p3

    @always_inline
    fn deriv[n: Int](self, t: Float64, s: ColVec[n]) -> ColVec[n]:
        return ColVec[n](
            self.p1 * (s.get[1]() - s.get[0]()),
            s.get[0]() * (self.p2 - s.get[2]()) - s.get[1](),
            s.get[0]() * s.get[1]() - self.p3 * s.get[2](),
        )

    @staticmethod
    fn ndim() -> Int:
        return 3


@value
struct Logistic(DESys):
    var p1: Float64
    var p2: Float64

    fn __init__(inout self, p1: Float64, p2: Float64):
        self.p1 = p1
        self.p2 = p2

    @always_inline
    fn deriv[n: Int](self, t: Float64, s: ColVec[n]) -> ColVec[n]:
        return ColVec[n](self.p1 * s.get[0]() * (1 - s.get[0]() / self.p2))

    @staticmethod
    fn ndim() -> Int:
        return 1
