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

from diffeq.traits import StepLogger

from linalg.static_matrix import (
    StaticMat as Mat,
    StaticColVec as ColVec,
    StaticRowVec as RowVec,
)


struct NullLogger[m: Int](StepLogger):
    fn __init__(inout self):
        pass

    fn log_state[n: Int](inout self, t: Float64, s: ColVec[n]):
        pass


struct StateLogger[m: Int](StepLogger):
    var t: List[Float64]
    var state: List[ColVec[m]]

    fn __init__(inout self):
        self.t = List[Float64]()
        self.state = List[ColVec[m]]()

    fn __init__(inout self, t0: Float64, s0: ColVec[m]):
        self.t = List[Float64]()
        self.state = List[ColVec[m]]()
        self.t.append(t0)
        self.state.append(s0)

    fn log_state[n: Int](inout self, t: Float64, s: ColVec[n]):
        constrained[m == n, "Invalid state size"]()
        self.t.append(t)
        self.state.append(rebind[ColVec[m]](s))
