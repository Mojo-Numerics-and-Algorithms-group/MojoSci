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


trait DESys(Copyable):
    """Required methods defining a differential system."""

    fn deriv(self, t: Float64, s: List[Float64]) -> List[Float64]:
        """Return dY.

        Args:
            t (Float64): the current time step.
            s (List[Float64]): the system state."""
        pass

    @staticmethod
    fn ndim() -> Int:
        """The number of state variables."""
        pass


trait RKStrategy:
    @staticmethod
    fn order() -> Int:
        pass

    @staticmethod
    fn stages() -> Int:
        pass

    @staticmethod
    fn coef[i: Int, j: Int]() -> Float64:
        pass

    @staticmethod
    fn stride[i: Int]() -> Float64:
        pass

    @staticmethod
    fn weight[i: Int]() -> Float64:
        pass
