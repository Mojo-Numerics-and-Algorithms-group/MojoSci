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

from numojo.linalg import StaticMat, StaticRowVec, StaticColVec

# Eventually struct, matrix, or tensor type
alias RK4_Coefs = StaticMat[4, 4](
    0, 0, 0, 0, 1 / 2, 0, 0, 0, 0, 1 / 2, 0, 0, 0, 0, 1, 0
)
alias RK4_Weights = StaticColVec[4](1 / 6, 1 / 3, 1 / 3, 1 / 6)
alias RK4_Nodes = StaticRowVec[4](0, 1 / 2, 1 / 2, 1)

alias RK38_Coefs = StaticMat[4, 4](
    0, 0, 0, 0, 1 / 3, 0, 0, 0, -1 / 3, 1, 0, 0, 1, -1, 1, 0
)
alias RK38_Weights = StaticColVec[4](1 / 8, 3 / 8, 3 / 8, 1 / 8)
alias RK38_Nodes = StaticRowVec[4](0, 1 / 3, 2 / 3, 1)

alias MidPoint_Coefs = StaticMat[2, 2](0, 0, 1 / 2, 0)
alias MidPoint_Weights = StaticColVec[2](0, 1)
alias MidPoint_Nodes = StaticRowVec[2](0, 1 / 2)

alias Heun_Coefs = StaticMat[2, 2](0, 0, 1, 0)
alias Heun_Weights = StaticColVec[2](1 / 2, 1 / 2)
alias Heun_Nodes = StaticRowVec[2](0, 1)

alias Ralston_Coefs = StaticMat[2, 2](0, 0, 2 / 3, 0)
alias Ralston_Weights = StaticColVec[2](1 / 4, 3 / 4)
alias Ralston_Nodes = StaticRowVec[2](0, 2 / 3)

alias Fehlberg45_Coefs = StaticMat[6, 6](
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
alias Fehlberg4_Weights = StaticColVec[6](
    25 / 216,
    0,
    1408 / 2565,
    2197 / 4104,
    -1 / 5,
    0,
)
alias Fehlberg5_Weights = StaticColVec[6](
    16 / 135, 0, 6656 / 12825, 28561 / 56430, -9 / 50, 2 / 55
)
alias Fehlberg45_Nodes = StaticRowVec[6](0, 1 / 4, 3 / 8, 12 / 13, 1, 1 / 2)


fn diffeq_steps[
    sys_dim: Int,
    steps: Int,
    coefs: StaticMat[steps, steps],
    nodes: StaticRowVec[steps],
](
    t: Float64,
    dt: Float64,
    s: StaticColVec[sys_dim],
    diff: fn (Float64, StaticColVec[sys_dim], List[Float64]) -> StaticColVec[
        sys_dim
    ],
    pars: List[Float64],
    inout k: StaticMat[sys_dim, steps],
) raises:
    var knots = t + nodes * dt

    @parameter
    for i in range(len(nodes)):
        var s_proj = s + k.get_col[i]() @ coefs.get_col[i]()
        k.set_col[i](diff(knots[i], s_proj, pars))


fn diffeq_integrate[
    sys_dim: Int,
    steps: Int,
    coefs: StaticMat[steps, steps],
    nodes: StaticRowVec[steps],
    weights: StaticColVec[steps],
](
    intervals: Int,
    dt: Float64,
    init_value: StaticColVec[sys_dim],
    diff: fn (Float64, StaticColVec[sys_dim], List[Float64]) -> StaticColVec[
        sys_dim
    ],
    pars: List[Float64],
    t0: Float64 = 0,
) raises -> Tuple[List[Float64], List[StaticColVec[sys_dim]]]:
    var times = List[Float64]()
    var values = List[StaticColVec[sys_dim]]()
    times.append(t0)
    values.append(init_value)
    var t = t0
    var value = init_value
    var k = StaticMat[sys_dim, steps](0)
    for _ in range(intervals):
        diffeq_steps[sys_dim, steps, coefs, nodes](t, dt, value, diff, pars, k)
        value = value + (dt * k @ weights)
        t += dt
        times.append(t)
        values.append(value)
    return (times, values)


fn diffeq_integrate_adaptive[
    sys_dim: Int,
    steps: Int,
    coefs: StaticMat[steps, steps],
    nodes: StaticRowVec[steps],
    weights_low: StaticColVec[steps],
    weights_high: StaticColVec[steps],
](
    stop_at: Float64,
    init_dt: Float64,
    init_value: StaticColVec[sys_dim],
    diff: fn (Float64, StaticColVec[sys_dim], List[Float64]) -> StaticColVec[
        sys_dim
    ],
    pars: List[Float64],
    t0: Float64 = 0,
    tol: Float64 = 1e-6,
) raises -> Tuple[List[Float64], List[StaticColVec[sys_dim]]]:
    alias p: Float64 = len(nodes) - 2
    var times = List[Float64]()
    var values = List[StaticColVec[sys_dim]]()
    times.append(t0)
    values.append(init_value)
    var t = t0
    var delt = init_dt
    var value = init_value
    var k = StaticMat[sys_dim, steps](0)
    while t < stop_at:
        if t + delt == t:
            print("Step size too small. Exiting.")
            break
        diffeq_steps[sys_dim, steps, coefs, nodes](
            t, delt, value, diff, pars, k
        )
        var next = value + value + (delt * k @ weights_low)
        var err = k @ (weights_high - weights_low) * delt
        if err.max_value() < tol:
            t += min(delt, stop_at - t)
            value = next
            times.append(t)
            values.append(value)
        var s = (tol / err.max_value() / 2) ** (1 / p)
        delt *= min(s, 4)
    return (times, values)


fn rk4_integrate(
    steps: Int,
    dt: Float64,
    init_value: Float64,
    diff: fn (Float64, Float64, List[Float64]) -> Float64,
    pars: List[Float64],
    t0: Float64 = 0,
) -> Tuple[List[Float64], List[Float64]]:
    return diffeq_integrate[
        RK4_Coefs,
        RK4_Weights,
        RK4_Nodes,
    ](steps, dt, init_value, diff, pars, t0)


fn euler_integrate(
    steps: Int,
    dt: Float64,
    init_value: Float64,
    diff: fn (Float64, Float64, List[Float64]) -> Float64,
    pars: List[Float64],
    t0: Float64 = 0,
) -> Tuple[List[Float64], List[Float64]]:
    return diffeq_integrate[
        List[Float64](1), List[Float64](1), List[Float64](0)
    ](steps, dt, init_value, diff, pars, t0)


fn reverse_euler_integrate(
    steps: Int,
    dt: Float64,
    init_value: Float64,
    diff: fn (Float64, Float64, List[Float64]) -> Float64,
    pars: List[Float64],
    t0: Float64 = 0,
) -> Tuple[List[Float64], List[Float64]]:
    return diffeq_integrate[
        List[Float64](1), List[Float64](1), List[Float64](1)
    ](steps, dt, init_value, diff, pars, t0)


fn fehlberg45_integrate(
    stop_at: Float64,
    init_dt: Float64,
    init_value: Float64,
    diff: fn (Float64, Float64, List[Float64]) -> Float64,
    pars: List[Float64],
    t0: Float64 = 0,
    tol: Float64 = 1e-6,
) -> Tuple[List[Float64], List[Float64]]:
    return diffeq_integrate_adaptive[
        Fehlberg45_Coefs,
        Fehlberg5_Weights,
        Fehlberg4_Weights,
        Fehlberg45_Nodes,
    ](stop_at, init_dt, init_value, diff, pars, t0, tol)


# fn logis(t: Float64, s: Float64, pars: List[Float64]) -> Float64:
#     return pars[0] * s * (1 - s / pars[1])


# fn main():
#     var pars = List[Float64](0.1, 10)
#     var res = fehlberg45_integrate(10000, 1e-6, 0.001, logis, pars, tol=1e-6)
#     var times = res[0]
#     var values = res[1]
#     for i in range(times.size):
#         print(times[i], values[i])
