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


from .traits import *


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
    fn deriv(self, t: Float64, s: List[Float64]) -> List[Float64]:
        return List(
            self.p1 * (s[1] - s[0]),
            s[0] * (self.p2 - s[2]) - s[1],
            s[0] * s[1] - self.p3 * s[2],
        )

    @staticmethod
    fn ndim() -> Int:
        return 3


struct EulerSteoper[S: DESys]:
    var state: List[Float64]
    var dt: Float64
    var t: Float64
    var sys: S

    fn __init__(
        inout self, sys: S, state: List[Float64], dt: Float64, t0: Float64 = 0
    ) raises:
        if len(state) != S.ndim():
            raise Error("Initial state has the wrong number of dimensions")
        self.sys = sys
        self.state = state
        self.dt = dt
        self.t = t0

    fn step(inout self):
        var dy = self.sys.deriv(self.t, self.state)

        @parameter
        for i in range(S.ndim()):
            self.state[i] += dy[i] * self.dt

        self.t += self.dt


struct Euler(RKStrategy):
    @staticmethod
    fn order() -> Int:
        return 1

    @staticmethod
    fn stages() -> Int:
        return 1

    @staticmethod
    fn coef[i: Int, j: Int]() -> Float64:
        constrained[False, "Coefficient index out of range."]()
        return 1

    @staticmethod
    fn stride[i: Int]() -> Float64:
        constrained[i == 0, "Stride index out of range."]()
        return 0

    @staticmethod
    fn weight[i: Int]() -> Float64:
        constrained[i == 0, "Weight index out of range."]()
        return 1


struct BackwardEuler(RKStrategy):
    @staticmethod
    fn order() -> Int:
        return 1

    @staticmethod
    fn stages() -> Int:
        return 1

    @staticmethod
    fn coef[i: Int, j: Int]() -> Float64:
        constrained[False, "Coefficient index out of range."]()
        return 1

    @staticmethod
    fn stride[i: Int]() -> Float64:
        constrained[i == 0, "Stride index out of range."]()
        return 1

    @staticmethod
    fn weight[i: Int]() -> Float64:
        constrained[i == 0, "Weight index out of range."]()
        return 1


struct RK4(RKStrategy):
    @staticmethod
    fn order() -> Int:
        return 4

    @staticmethod
    fn stages() -> Int:
        return 4

    @staticmethod
    fn coef[i: Int, j: Int]() -> Float64:
        constrained[i >= 0 and i < 4, "Coefficient stage index out of range."]()
        constrained[j >= 0 and j < i, "Coefficent step index out of range."]()
        alias pos = (i * (i - 1)) // 2 + j
        return [1 / 2, 0, 1 / 2, 0, 0, 1].get[pos, Float64]()

    @staticmethod
    fn stride[i: Int]() -> Float64:
        constrained[i >= 0 and i < 4, "Stride index out of range."]()
        return [0, 1 / 2, 1 / 2, 1].get[i, Float64]()

    @staticmethod
    fn weight[i: Int]() -> Float64:
        constrained[i >= 0 and i < 4, "Weight index out of range."]()
        return [1 / 6, 1 / 3, 1 / 3, 1 / 6].get[i, Float64]()


struct RKStepper[Strategy: RKStrategy, Sys: DESys]:
    var state: List[Float64]
    var dt: Float64
    var t: Float64
    var sys: Sys

    fn __init__(
        inout self, sys: Sys, state: List[Float64], dt: Float64, t0: Float64 = 0
    ) raises:
        if len(state) != Sys.ndim():
            raise Error("Initial state has the wrong number of dimensions")
        self.sys = sys
        self.state = state
        self.dt = dt
        self.t = t0

    fn step(inout self):
        var k = List[List[Float64]]()

        @parameter
        for stage in range(Strategy.stages()):
            var t = self.t + Strategy.stride[stage]() * self.dt
            k.append(self.state)

            @parameter
            for step in range(stage):

                @parameter
                for i in range(Sys.ndim()):
                    k[stage][i] += (
                        Strategy.coef[stage, step]() * k[step][i] * self.dt
                    )

            k[stage] = self.sys.deriv(t, k[stage])

        @parameter
        for i in range(Strategy.stages()):

            @parameter
            for j in range(Sys.ndim()):
                self.state[j] += Strategy.weight[i]() * k[i][j] * self.dt

        self.t += self.dt


fn main() raises:
    var grad = Lorenz(10, 28, 8 / 3)
    var s0 = List[Float64](2.0, 1.0, 1.0)
    var stepper = RKStepper[RK4](grad, s0, 0.001)
    for _ in range(30):
        print("t =", stepper.t, end=": ")
        for i in range(3):
            print(stepper.state[i], end=" ")
        print()
        stepper.step()
