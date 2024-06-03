from collections import List

# Eventually struct, matrix, or tensor type
alias RK4_Coefs = List[Float64](
    0, 0, 0, 0, 1 / 2, 0, 0, 0, 0, 1 / 2, 0, 0, 0, 0, 1, 0
)
alias RK4_Weights = List[Float64](1 / 6, 1 / 3, 1 / 3, 1 / 6)
alias RK4_Nodes = List[Float64](0, 1 / 2, 1 / 2, 1)

alias RK38_Coefs = List[Float64](
    0, 0, 0, 0, 1 / 3, 0, 0, 0, -1 / 3, 1, 0, 0, 1, -1, 1, 0
)
alias RK38_Weights = List[Float64](1 / 8, 3 / 8, 3 / 8, 1 / 8)
alias RK38_Nodes = List[Float64](0, 1 / 3, 2 / 3, 1)

alias MidPoint_Coefs = List[Float64](0, 0, 1 / 2, 0)
alias MidPoint_Weights = List[Float64](0, 1)
alias MidPoint_Nodes = List[Float64](0, 1 / 2)

alias Heun_Coefs = List[Float64](0, 0, 1, 0)
alias Heun_Weights = List[Float64](1 / 2, 1 / 2)
alias Heun_Nodes = List[Float64](0, 1)

alias Ralston_Coefs = List[Float64](0, 0, 2 / 3, 0)
alias Ralston_Weights = List[Float64](1 / 4, 3 / 4)
alias Ralston_Nodes = List[Float64](0, 2 / 3)

alias Fehlberg45_Coefs = List[Float64](
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
alias Fehlberg4_Weights = List[Float64](
    25 / 216,
    0,
    1408 / 2565,
    2197 / 4104,
    -1 / 5,
    0,
)
alias Fehlberg5_Weights = List[Float64](
    16 / 135, 0, 6656 / 12825, 28561 / 56430, -9 / 50, 2 / 55
)
alias Fehlberg45_Nodes = List[Float64](0, 1 / 4, 3 / 8, 12 / 13, 1, 1 / 2)


fn zeros[n: Int]() -> List[Float64]:
    var res = List[Float64](n)
    for _ in range(n):
        res.append(0)
    return res


# For now...
@always_inline
fn dot_prod[w: List[Float64]](k: List[Float64]) -> Float64:
    var res: Float64 = 0
    for i in range(w.size):
        res += w[i] * k[i]
    return res


@always_inline
fn dot_prod_row[
    rows: Int, c: List[Float64]
](k: List[Float64], row: Int) -> Float64:
    var res: Float64 = 0
    for i in range(rows):
        res += c[i + row * rows] * k[i]
    return res


fn diffeq_steps[
    coefs: List[Float64],
    nodes: List[Float64],
](
    t: Float64,
    dt: Float64,
    s: Float64,
    diff: fn (Float64, Float64, List[Float64]) -> Float64,
    pars: List[Float64],
    inout k: List[Float64],
):
    for i in range(nodes.size):
        var node = t + nodes[i] * dt
        var s_proj = s + dot_prod_row[nodes.size, coefs](k, i)
        k[i] = diff(node, s_proj, pars)


fn diffeq_integrate[
    coefs: List[Float64],
    weights: List[Float64],
    nodes: List[Float64],
](
    steps: Int,
    dt: Float64,
    init_value: Float64,
    diff: fn (Float64, Float64, List[Float64]) -> Float64,
    pars: List[Float64],
    t0: Float64 = 0,
) -> Tuple[List[Float64], List[Float64]]:
    var times = List[Float64]()
    var values = List[Float64]()
    times.append(t0)
    values.append(init_value)
    var t = t0
    var value = init_value
    var k = zeros[nodes.size]()
    for _ in range(steps):
        diffeq_steps[coefs, nodes](t, dt, value, diff, pars, k)
        value += dot_prod[weights](k) * dt
        t += dt
        times.append(t)
        values.append(value)
    return (times, values)


fn err_est[
    low: List[Float64], high: List[Float64]
](k: List[Float64]) -> Float64:
    var res: Float64 = 0
    for i in range(low.size):
        res += k[i] * abs(high[i] - low[i])
    return res


fn diffeq_integrate_adaptive[
    coefs: List[Float64],
    weights_high: List[Float64],
    weights_low: List[Float64],
    nodes: List[Float64],
](
    stop_at: Float64,
    init_dt: Float64,
    init_value: Float64,
    diff: fn (Float64, Float64, List[Float64]) -> Float64,
    pars: List[Float64],
    t0: Float64 = 0,
    tol: Float64 = 1e-6,
) -> Tuple[List[Float64], List[Float64]]:
    alias p: Float64 = nodes.size - 2
    var times = List[Float64]()
    var values = List[Float64]()
    times.append(t0)
    values.append(init_value)
    var t = t0
    var delt = init_dt
    var value = init_value
    var k = zeros[nodes.size]()
    while t < stop_at:
        if t + delt == t:
            print("Step size too small. Exiting.")
            break
        diffeq_steps[coefs, nodes](t, delt, value, diff, pars, k)
        var next = value + dot_prod[weights_low](k) * delt
        var err = err_est[weights_low, weights_high](k) * delt
        if err < tol:
            t += min(delt, stop_at - t)
            value = next
            times.append(t)
            values.append(value)
        var s = (tol / err / 2) ** (1 / p)
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
