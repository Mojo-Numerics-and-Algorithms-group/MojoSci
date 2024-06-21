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

from diffeq.desys import DESys

from linalg.static_matrix import (
    StaticMat as Mat,
    StaticColVec as ColVec,
    StaticRowVec as RowVec,
)


struct EulerSteoper[S: DESys, n: Int]:
    """Step a differential system using the Euler method."""

    var state: ColVec[n]
    var dt: Float64
    var t: Float64
    var sys: S

    fn __init__(
        inout self, sys: S, state: ColVec[n], dt: Float64, t0: Float64 = 0
    ) raises:
        if len(state) != S.ndim():
            raise Error("Initial state has the wrong number of dimensions")
        self.sys = sys
        self.state = state
        self.dt = dt
        self.t = t0

    fn step(inout self):
        self.state += self.sys.deriv(self.t, self.state) * self.dt
        self.t += self.dt
