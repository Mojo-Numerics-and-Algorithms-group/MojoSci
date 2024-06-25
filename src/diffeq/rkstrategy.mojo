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

from diffeq.diffeq_traits import (
    ExplicitRK,
    EmbeddedRK,
    FSALEmbeddedRK,
    ImplicitRK,
    DIRK,
)

from linalg.static_matrix import (
    StaticMat as Mat,
    StaticColVec as ColVec,
    StaticRowVec as RowVec,
)


struct Euler(ExplicitRK):
    @staticmethod
    fn description() -> String:
        return "Basic Euler method"

    @staticmethod
    fn reference() -> String:
        return "Please add a reference!"

    @staticmethod
    fn order() -> Int:
        return 1

    @staticmethod
    fn stages() -> Int:
        return 1

    @staticmethod
    fn coefs[i: Int, n: Int]() -> ColVec[n]:
        constrained[i == 0, "Coefficient stage index out of range."]()
        return ColVec[n](1)

    @staticmethod
    fn strides[n: Int]() -> ColVec[n]:
        return ColVec[n](0)

    @staticmethod
    fn weights[n: Int]() -> ColVec[n]:
        return ColVec[n](1)


struct BackwardEuler(ImplicitRK):
    @staticmethod
    fn description() -> String:
        return "Backward (implicit) Euler strategy"

    @staticmethod
    fn reference() -> String:
        return "Please add a reference!"

    @staticmethod
    fn order() -> Int:
        return 1

    @staticmethod
    fn stages() -> Int:
        return 1

    @staticmethod
    fn coefs[i: Int, n: Int]() -> ColVec[n]:
        constrained[i == 0, "Coefficient stage index out of range."]()
        return ColVec[n](1)

    @staticmethod
    fn strides[n: Int]() -> ColVec[n]:
        return ColVec[n](1)

    @staticmethod
    fn weights[n: Int]() -> ColVec[n]:
        return ColVec[n](1)


struct LStable(DIRK):
    @staticmethod
    fn description() -> String:
        return "Four-stage, 3rd order, L-stable Diagonally Implicit Runga-Kutta"

    @staticmethod
    fn reference() -> String:
        return "Please add a reference!"

    @staticmethod
    fn order() -> Int:
        return 3

    @staticmethod
    fn stages() -> Int:
        return 4

    @staticmethod
    fn coefs[i: Int, n: Int]() -> ColVec[n]:
        constrained[i >= 0 and i < 4, "Coefficient stage index out of range."]()

        @parameter
        if i == 0:
            return ColVec[n](1 / 2, 0, 0, 0)
        elif i == 1:
            return ColVec[n](1 / 6, 1 / 2, 0, 0)
        elif i == 2:
            return ColVec[n](-1 / 2, 1 / 2, 1 / 2, 0)
        else:
            return ColVec[n](3 / 2, -3 / 2, 1 / 2, 1 / 2)

    @staticmethod
    fn strides[n: Int]() -> ColVec[n]:
        return ColVec[n](1 / 2, 2 / 3, 1 / 2, 1)

    @staticmethod
    fn weights[n: Int]() -> ColVec[n]:
        return ColVec[n](3 / 2, -3 / 2, 1 / 2, 1 / 2)


struct RK4(ExplicitRK):
    @staticmethod
    fn description() -> String:
        return "Standard 4th order Runga-Kutta"

    @staticmethod
    fn reference() -> String:
        return (
            "https://en.wikipedia.org/wiki/List_of_Runge%E2%80%93Kutta_methods"
        )

    @staticmethod
    fn order() -> Int:
        return 4

    @staticmethod
    fn stages() -> Int:
        return 4

    @staticmethod
    fn coefs[i: Int, n: Int]() -> ColVec[n]:
        constrained[i >= 0 and i < 4, "Coefficient stage index out of range."]()

        @parameter
        if i == 0:
            return ColVec[n](0, 0, 0, 0)
        elif i == 1:
            return ColVec[n](1 / 2, 0, 0, 0)
        elif i == 2:
            return ColVec[n](0, 1 / 2, 0, 0)
        else:
            return ColVec[n](0, 0, 1, 0)

    @staticmethod
    fn strides[n: Int]() -> ColVec[n]:
        return ColVec[n](0, 1 / 2, 1 / 2, 1)

    @staticmethod
    fn weights[n: Int]() -> ColVec[n]:
        return ColVec[n](1 / 6, 1 / 3, 1 / 3, 1 / 6)


struct SSPRK3(ExplicitRK):
    @staticmethod
    fn description() -> String:
        return "Third-order Strong Stability Preserving Runge-Kutta"

    @staticmethod
    fn reference() -> String:
        return (
            "https://en.wikipedia.org/wiki/List_of_Runge%E2%80%93Kutta_methods"
        )

    @staticmethod
    fn order() -> Int:
        return 3

    @staticmethod
    fn stages() -> Int:
        return 3

    @staticmethod
    fn coefs[i: Int, n: Int]() -> ColVec[n]:
        constrained[i >= 0 and i < 3, "Coefficient stage index out of range."]()

        @parameter
        if i == 0:
            return ColVec[n](0, 0, 0, 0)
        elif i == 1:
            return ColVec[n](1, 0, 0, 0)
        else:
            return ColVec[n](1 / 4, 1 / 4, 0)

    @staticmethod
    fn strides[n: Int]() -> ColVec[n]:
        return ColVec[n](0, 1, 1 / 2)

    @staticmethod
    fn weights[n: Int]() -> ColVec[n]:
        return ColVec[n](1 / 6, 1 / 6, 2 / 3)


struct RK45(FSALEmbeddedRK):
    @staticmethod
    fn description() -> String:
        return "Dormand-Prince 5th order embedded Runga-Kutta"

    @staticmethod
    fn reference() -> String:
        return "https://doi.org/10.1016%2F0771-050X%2880%2990013-3"

    @staticmethod
    fn order() -> Int:
        return 5

    @staticmethod
    fn order2() -> Int:
        return 4

    @staticmethod
    fn stages() -> Int:
        return 7

    @staticmethod
    fn coefs[i: Int, n: Int]() -> ColVec[n]:
        constrained[i >= 0 and i < 7, "Coefficient stage index out of range."]()

        @parameter
        if i == 0:
            return ColVec[n](0, 0, 0, 0, 0, 0, 0)
        elif i == 1:
            return ColVec[n](1 / 5, 0, 0, 0, 0, 0, 0)
        elif i == 2:
            return ColVec[n](3 / 40, 9 / 40, 0, 0, 0, 0, 0)
        elif i == 3:
            return ColVec[n](44 / 45, -56 / 15, 32 / 9, 0, 0, 0, 0)
        elif i == 4:
            return ColVec[n](
                19372 / 6561, -25360 / 2187, 64448 / 6561, -212 / 729, 0, 0, 0
            )
        elif i == 5:
            return ColVec[n](
                9017 / 3168,
                -355 / 33,
                46732 / 5247,
                49 / 176,
                -5103 / 18656,
                0,
                0,
            )
        else:
            return ColVec[n](
                35 / 384, 0, 500 / 1113, 125 / 192, -2187 / 6784, 11 / 84, 0
            )

    @staticmethod
    fn strides[n: Int]() -> ColVec[n]:
        return ColVec[n](0, 1 / 5, 3 / 10, 4 / 5, 8 / 9, 1, 1)

    @staticmethod
    fn weights[n: Int]() -> ColVec[n]:
        return ColVec[n](
            35 / 384, 0, 500 / 1113, 125 / 192, -2187 / 6784, 11 / 84, 0
        )

    @staticmethod
    fn weights2[n: Int]() -> ColVec[n]:
        return ColVec[n](
            5179 / 57600,
            0,
            7571 / 16695,
            393 / 640,
            -92097 / 339200,
            187 / 2100,
            1 / 40,
        )


struct BS23(FSALEmbeddedRK):
    @staticmethod
    fn description() -> String:
        return "Bogacki-Shampine 3rd order embedded Runga-Kutta"

    @staticmethod
    fn reference() -> String:
        return "https://doi.org/10.1016%2F0893-9659%2889%2990079-7"

    @staticmethod
    fn order() -> Int:
        return 3

    @staticmethod
    fn order2() -> Int:
        return 2

    @staticmethod
    fn stages() -> Int:
        return 4

    @staticmethod
    fn coefs[i: Int, n: Int]() -> ColVec[n]:
        constrained[i >= 0 and i < 4, "Coefficient stage index out of range."]()

        @parameter
        if i == 0:
            return ColVec[n](0, 0, 0, 0)
        elif i == 1:
            return ColVec[n](1 / 2, 0, 0, 0)
        elif i == 2:
            return ColVec[n](0, 3 / 4, 0, 0)
        else:
            return ColVec[n](2 / 9, 1 / 3, 4 / 9, 0)

    @staticmethod
    fn strides[n: Int]() -> ColVec[n]:
        return ColVec[n](0, 1 / 2, 3 / 4, 1)

    @staticmethod
    fn weights[n: Int]() -> ColVec[n]:
        return ColVec[n](2 / 9, 1 / 3, 4 / 9, 0)

    @staticmethod
    fn weights2[n: Int]() -> ColVec[n]:
        return ColVec[n](7 / 24, 1 / 4, 1 / 3, 1 / 8)
