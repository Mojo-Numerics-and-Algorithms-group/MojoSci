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

from linalg.static_matrix import StaticMat, StaticRowVec, StaticColVec


alias Mat = StaticMat
alias RVec = StaticRowVec
alias CVec = StaticColVec


trait AutoDESys:
    fn deriv[sdim: Int, S: CVec[sdim]](self, s: S) raises -> S:
        pass

    @staticmethod
    fn ndim() -> Int:
        pass


struct Lorenz(AutoDESys):
    var p1: Float64
    var p2: Float64
    var p3: Float64

    fn __init__(inout self, p1: Float64, p2: Float64, p3: Float64):
        self.p1 = p1
        self.p2 = p2
        self.p3 = p3

    @always_inline
    fn deriv(self, s: CVec[3]) raises -> CVec[3]:
        return CVec[3](
            self.p1 * (s[1] - s[0]),
            s[0] * (self.p2 - s[2]) - s[1],
            s[0] * s[1] - self.p3 * s[2],
        )

    @staticmethod
    fn ndim() -> Int:
        return 3


fn diffeq_stages[
    npars: Int,
    sys_dim: Int,
    strides: Int,
    coefs: Mat[strides, strides],
    stages: RVec[strides],
](
    t: Float64,
    dt: Float64,
    s: CVec[sys_dim],
    diff: fn (Float64, CVec[sys_dim], CVec[npars]) -> CVec[sys_dim],
    pars: CVec[npars],
    inout k: Mat[sys_dim, strides],
) raises:
    var knots = t + stages * dt

    @parameter
    for i in range(len(stages)):
        var s_proj = s + k.get_col[i]() @ coefs.get_col[i]()
        k.set_col[i](diff(knots[i], s_proj, pars))


fn diffeq_integrate[
    npars: Int,
    sys_dim: Int,
    strides: Int,
    coefs: Mat[strides, strides],
    stages: RVec[strides],
    weights: CVec[strides],
](
    steps: Int,
    dt: Float64,
    init_value: CVec[sys_dim],
    diff: fn (Float64, CVec[sys_dim], CVec[npars]) -> CVec[sys_dim],
    pars: CVec[npars],
    t0: Float64 = 0,
) raises -> Tuple[List[Float64], List[CVec[sys_dim]]]:
    var times = List[Float64]()
    var values = List[CVec[sys_dim]]()
    times.append(t0)
    values.append(init_value)
    var t = t0
    var value = init_value
    var k = Mat[sys_dim, strides].zeros()
    for _ in range(steps):
        diffeq_stages[npars, sys_dim, strides, coefs, stages](
            t, dt, value, diff, pars, k
        )
        value = value + k @ weights * dt
        t += dt
        times.append(t)
        values.append(value)
    return (times, values)


fn diffeq_integrate_adaptive[
    npars: Int,
    sys_dim: Int,
    strides: Int,
    coefs: Mat[strides, strides],
    stages: RVec[strides],
    weights_low: CVec[strides],
    weights_high: CVec[strides],
](
    stop_at: Float64,
    init_dt: Float64,
    init_value: CVec[sys_dim],
    diff: fn (Float64, CVec[sys_dim], CVec[npars]) -> CVec[sys_dim],
    pars: CVec[npars],
    t0: Float64 = 0,
    tol: Float64 = 1e-6,
) raises -> Tuple[List[Float64], List[CVec[sys_dim]]]:
    alias p: Float64 = len(stages) - 2  # FixMe
    var times = List[Float64]()
    var values = List[CVec[sys_dim]]()
    times.append(t0)
    values.append(init_value)
    var t = t0
    var delt = init_dt
    var value = init_value
    var k = Mat[sys_dim, strides].zeros()
    while t < stop_at:
        delt = min(delt, stop_at - t)
        if t + delt == t:
            print("Step size too small. Exiting.")
            break
        diffeq_stages[npars, sys_dim, strides, coefs, stages](
            t, delt, value, diff, pars, k
        )
        var next = value + k @ weights_low * delt
        var err = k @ (weights_high - weights_low) * delt
        if err.max_value() < tol:
            t += delt
            value = next
            times.append(t)
            values.append(value)
        var s = (tol / err.max_value() / 2) ** (1 / p)
        delt *= min(s, 4)
    return (times, values)


""" trait RKMethod:
    fn get_order(self) -> Int:
        pass

    fn get_strides(self) -> Int:
        pass

    fn get_weights(self) -> CVec[]:
        pass


struct RK4(RKMethod):
    alias order: Int = 4
    alias strides: Int = 4
    alias weights = CVec[4](1 / 6, 1 / 3, 1 / 3, 1 / 6)
    alias stages = RVec[4](0, 1 / 2, 1 / 2, 1)
    alias coefs = Mat[4, 4](
        0, 0, 0, 0, 1 / 2, 0, 0, 0, 0, 1 / 2, 0, 0, 0, 0, 1, 0
    )

    fn __init__(inout self):
        pass

    @always_inline
    fn get_order(self) -> Int:
        return self.order

    @always_inline
    fn get_strides(self) -> Int:
        return self.strides

    @always_inline
    fn get_weights(self) -> CVec[self.strides]:
        return self.strides
 """


# fn logis(t: Float64, s: Float64, pars: List[Float64]) -> Float64:
#     return pars[0] * s * (1 - s / pars[1])


fn main():
    var x = Lorenz(10, 28, 8 / 3)


alias RK4_Coefs = Mat[4, 4](
    0, 0, 0, 0, 1 / 2, 0, 0, 0, 0, 1 / 2, 0, 0, 0, 0, 1, 0
)
alias RK4_Weights = CVec[4](1 / 6, 1 / 3, 1 / 3, 1 / 6)
alias RK4_Stages = RVec[4](0, 1 / 2, 1 / 2, 1)


alias RK38_Coefs = Mat[4, 4](
    0, 0, 0, 0, 1 / 3, 0, 0, 0, -1 / 3, 1, 0, 0, 1, -1, 1, 0
)
alias RK38_Weights = CVec[4](1 / 8, 3 / 8, 3 / 8, 1 / 8)
alias RK38_Stages = RVec[4](0, 1 / 3, 2 / 3, 1)

alias MidPoint_Coefs = Mat[2, 2](0, 0, 1 / 2, 0)
alias MidPoint_Weights = CVec[2](0, 1)
alias MidPoint_Stages = RVec[2](0, 1 / 2)

alias Heun_Coefs = Mat[2, 2](0, 0, 1, 0)
alias Heun_Weights = CVec[2](1 / 2, 1 / 2)
alias Heun_Stages = RVec[2](0, 1)

alias Ralston_Coefs = Mat[2, 2](0, 0, 2 / 3, 0)
alias Ralston_Weights = CVec[2](1 / 4, 3 / 4)
alias Ralston_Stages = RVec[2](0, 2 / 3)

alias Fehlberg45_Coefs = Mat[6, 6](
    0,  # 0, 0
    0,  # 0, 1
    0,  # 0, 2
    0,  # 0, 3
    0,  # 0, 4
    0,  # 0, 5
    1 / 4,  # 1, 0
    0,  # 1, 1
    0,  # 1, 2
    0,  # 1, 3
    0,  # 1, 4
    0,  # 1, 5
    3 / 32,  # 2, 0
    9 / 32,  # 2, 1
    0,  # 2, 2
    0,  # 2, 3
    0,  # 2, 4
    0,  # 2, 5
    1932 / 2197,  # 3, 0
    -7200 / 2197,  # 3, 1
    7296 / 2197,  # 3, 2
    0,  # 3, 3
    0,  # 3, 4
    0,  # 3, 5
    439 / 216,  # 4, 0
    -8,  # 4, 1
    3680 / 513,  # 4, 2
    -845 / 4104,  # 4, 3
    0,  # 4, 4
    0,  # 4, 5
    -8 / 27,  # 5, 0
    2,  # 5, 1
    -3544 / 2565,  # 5, 2
    1859 / 4104,  # 5, 3
    -11 / 40,  # 5, 4
    0,  # 5, 5
)
alias Fehlberg4_Weights = CVec[6](
    25 / 216,
    0,
    1408 / 2565,
    2197 / 4104,
    -1 / 5,
    0,
)
alias Fehlberg5_Weights = CVec[6](
    16 / 135, 0, 6656 / 12825, 28561 / 56430, -9 / 50, 2 / 55
)
alias Fehlberg45_Stages = RVec[6](0, 1 / 4, 3 / 8, 12 / 13, 1, 1 / 2)
