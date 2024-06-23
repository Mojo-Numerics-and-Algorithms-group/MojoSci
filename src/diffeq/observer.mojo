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

from linalg.static_matrix import (
    StaticMat as Mat,
    StaticColVec as ColVec,
    StaticRowVec as RowVec,
)


# Arghhhh!
trait RKObserver[n: Int]:
    fn __init__(inout self):
        pass

    fn observe(inout self, t: Float64, s: ColVec[n]):
        pass


struct NullRKObserver[n: Int](RKObserver):
    fn __init__(inout self):
        pass

    fn observe(inout self, t: Float64, s: ColVec[n]):
        pass


struct RKObserverAll[n: Int](RKObserver):
    var t: List[Float64]
    var state: List[ColVec[n]]

    fn __init__(inout self):
        self.t = List[Float64]()
        self.state = List[ColVec[n]]()

    fn observe(inout self, t: Float64, s: ColVec[n]):
        self.t.append(t)
        self.state.append(s)
