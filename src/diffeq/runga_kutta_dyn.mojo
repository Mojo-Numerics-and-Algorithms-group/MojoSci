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
    fn deriv(self, t: Float64, s: List[Float64]) -> List[Float64]:
        pass

    @staticmethod
    fn ndim() -> Int:
        pass


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


struct EulerIntegrate[S: DESys]:
    var state: List[Float64]
    var dt: Float64
    var t: Float64
    var sys: S

    fn __init__(
        inout self, sys: S, state: List[Float64], dt: Float64, t: Float64 = 0
    ) raises:
        if len(state) != S.ndim():
            raise Error("Initial state has the wrong number of dimensions")
        self.sys = sys
        self.state = state
        self.dt = dt
        self.t = t

    fn step(inout self):
        var dy = self.sys.deriv(self.t, self.state)
        for i in range(len(dy)):
            self.state[i] += dy[i] * self.dt
        self.t += self.dt


fn main() raises:
    var grad = Lorenz(10, 28, 8 / 3)
    var s0 = List[Float64](2.0, 1.0, 1.0)
    var stepper = EulerIntegrate(grad, s0, 1e-3)
    for _ in range(10):
        print("t =", stepper.t, end=": ")
        for i in range(3):
            print(stepper.state[i], end=" ")
        print()
        stepper.step()
