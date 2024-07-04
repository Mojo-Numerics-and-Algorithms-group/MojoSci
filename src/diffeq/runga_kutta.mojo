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

from diffeq.traits import (
    DESys,
    ExplicitRK,
    EmbeddedRK,
    StateStepper,
    StepLogger,
)

from diffeq.observer import NullLogger, StateLogger

from linalg.static_matrix import (
    StaticMat as Mat,
    StaticColVec as ColVec,
    StaticRowVec as RowVec,
)


struct RKFixedStepper[Strategy: ExplicitRK, Sys: DESys, n: Int](StateStepper):
    """Stepper for explicit Runga-Kutta strategies."""
    alias StateType = ColVec[n]

    var state: Self.StateType
    var dt: Float64
    var t: Float64
    var sys: Sys

    fn __init__(
        inout self,
        sys: Sys,
        state: Self.StateType,
        dt: Float64,
        t0: Float64 = 0,
    ) raises:
        if len(state) != Sys.ndim():
            raise Error("Initial state has the wrong number of dimensions")
        self.sys = sys
        self.state = state
        self.dt = dt
        self.t = t0

    fn step(inout self, ntimes: Int = 1):
        for _ in range(ntimes):
            self._step()

    fn step[S: StepLogger](inout self, inout obs: S, ntimes: Int = 1):
        for _ in range(ntimes):
            self._step()
            obs.record_state(self.t, self.state)

    fn step_until(inout self, tstop: Float64):
        while self.t + self.dt < tstop:
            self._step()
        if self.t < tstop:
            self.dt = tstop - self.t
            self._step()

    fn step_until[S: StepLogger](inout self, inout obs: S, tstop: Float64):
        while self.t + self.dt < tstop:
            self._step()
            obs.record_state(self.t, self.state)
        if self.t < tstop:
            self.dt = tstop - self.t
            self._step()
            obs.record_state(self.t, self.state)

    fn _step(inout self):
        alias m = Strategy.stages()

        var k = Mat[n, m].zeros()
        var kt = self.t + Strategy.strides[m]() * self.dt

        @parameter
        for i in range(m):
            var t = kt.get[i]()
            alias coefs = Strategy.coefs[i, m]()
            var s = self.state + k @ coefs * self.dt
            k.set_col[i](self.sys.deriv(t, s))

        alias w = Strategy.weights[m]()
        self.state += k @ w * self.dt
        self.t += self.dt


struct RKAdaptiveStepper[Strategy: EmbeddedRK, Sys: DESys, n: Int](
    StateStepper
):
"""Stepper for embedded Runga-Kutta strategies."""
    alias StateType = ColVec[n]

    var state: Self.StateType
    var tol: Float64
    var dt: Float64
    var t: Float64
    var sys: Sys

    fn __init__(
        inout self,
        sys: Sys,
        state: Self.StateType,
        dt: Float64,
        t0: Float64 = 0,
        tol: Float64 = 1e-9,
    ) raises:
        if len(state) != Sys.ndim():
            raise Error("Initial state has the wrong number of dimensions")
        self.sys = sys
        self.state = state
        self.tol = tol
        self.dt = dt
        self.t = t0

    fn step(inout self, ntimes: Int = 1):
        for _ in range(ntimes):
            self._step()

    fn step[S: StepLogger](inout self, inout obs: S, ntimes: Int = 1):
        for _ in range(ntimes):
            self._step()
            obs.record_state(self.t, self.state)

    fn step_until(inout self, tstop: Float64):
        while self.t + self.dt < tstop:
            self._step()
        if self.t < tstop:
            self.dt = tstop - self.t
            self._step[fixed = True]()

    fn step_until[S: StepLogger](inout self, inout obs: S, tstop: Float64):
        while self.t + self.dt < tstop:
            self._step()
            obs.record_state(self.t, self.state)
        if self.t < tstop:
            self.dt = tstop - self.t
            self._step[fixed = True]()
            obs.record_state(self.t, self.state)

    fn _step[fixed: Bool = False](inout self):
        alias p = Strategy.order2()
        alias w1 = Strategy.weights[m]()
        alias w2 = Strategy.weights2[m]()
        alias m = Strategy.stages()

        var k = Mat[n, m].zeros()
        var kt = self.t + Strategy.strides[m]() * self.dt

        @parameter
        for i in range(m):
            var t = kt.get[i]()
            alias coefs = Strategy.coefs[i, m]()
            var s = self.state + k @ coefs * self.dt
            k.set_col[i](self.sys.deriv(t, s))

        @parameter
        if (fixed):
            self.state += k @ w1 * self.dt
            self.t += self.dt

        else:
            alias dw = w1 - w2
            var err = k @ dw * self.dt

            if err.max_value() < self.tol:
                self.state += k @ w1 * self.dt
                self.t += self.dt

            var s = (self.tol / err.max_value() / 2) ** (1 / p)
            self.dt *= max(min(s, 4), 1 / 4)


from diffeq.desys_examples import Lorenz
from diffeq.rk_strategies import RK4, RK45, LStable


fn main() raises:
    var grad = Lorenz(10, 28, 8 / 3)
    var s0 = ColVec[3](2.0, 1.0, 1.0)
    var obs = StateLogger(0, s0)
    var stepper = RKAdaptiveStepper[RK45](grad, s0, 0.01)
    stepper.step()
