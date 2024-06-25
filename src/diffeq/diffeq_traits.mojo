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


trait StateStepper:
    fn step(inout self):
        pass


trait SelfDocumenting:
    @staticmethod
    fn description() -> String:
        pass

    @staticmethod
    fn reference() -> String:
        pass


trait ExplicitRK(SelfDocumenting):
    @staticmethod
    fn order() -> Int:
        pass

    @staticmethod
    fn stages() -> Int:
        pass

    @staticmethod
    fn coefs[i: Int, n: Int]() -> ColVec[n]:
        pass

    @staticmethod
    fn strides[n: Int]() -> ColVec[n]:
        pass

    @staticmethod
    fn weights[n: Int]() -> ColVec[n]:
        pass


trait EmbeddedRK(ExplicitRK):
    @staticmethod
    fn order2() -> Int:
        pass

    @staticmethod
    fn weights2[n: Int]() -> ColVec[n]:
        pass


trait FSALEmbeddedRK(EmbeddedRK):
    pass


trait ImplicitRK(SelfDocumenting):
    @staticmethod
    fn order() -> Int:
        pass

    @staticmethod
    fn stages() -> Int:
        pass

    @staticmethod
    fn coefs[i: Int, n: Int]() -> ColVec[n]:
        pass

    @staticmethod
    fn strides[n: Int]() -> ColVec[n]:
        pass

    @staticmethod
    fn weights[n: Int]() -> ColVec[n]:
        pass


trait DIRK(SelfDocumenting):
    @staticmethod
    fn order() -> Int:
        pass

    @staticmethod
    fn stages() -> Int:
        pass

    @staticmethod
    fn coefs[i: Int, n: Int]() -> ColVec[n]:
        pass

    @staticmethod
    fn strides[n: Int]() -> ColVec[n]:
        pass

    @staticmethod
    fn weights[n: Int]() -> ColVec[n]:
        pass
