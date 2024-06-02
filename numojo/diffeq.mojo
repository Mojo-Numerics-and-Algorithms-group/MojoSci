from collections import List

# Eventually struct, matrix, or tensor type
alias RK4_Coefs = SIMD[DType.float64, 16](
    0, 0, 0, 0, 1 / 2, 0, 0, 0, 0, 1 / 2, 0, 0, 0, 0, 1, 0
)
alias RK4_Weights = SIMD[DType.float64, 4](1 / 6, 1 / 3, 1 / 3, 1 / 6)
alias RK4_Nodes = SIMD[DType.float64, 4](0, 1 / 2, 1 / 2, 1)

alias RK38_Coefs = SIMD[DType.float64, 16](
    0, 0, 0, 0, 1 / 3, 0, 0, 0, -1 / 3, 1, 0, 0, 1, -1, 1, 0
)
alias RK38_Weights = SIMD[DType.float64, 4](1 / 8, 3 / 8, 3 / 8, 1 / 8)
alias RK38_Nodes = SIMD[DType.float64, 4](0, 1 / 3, 2 / 3, 1)

alias MidPoint_Coefs = SIMD[DType.float64, 4](0, 0, 1 / 2, 0)
alias MidPoint_Weights = SIMD[DType.float64, 2](0, 1)
alias MidPoint_Nodes = SIMD[DType.float64, 2](0, 1 / 2)

alias Heun_Coefs = SIMD[DType.float64, 4](0, 0, 1, 0)
alias Heun_Weights = SIMD[DType.float64, 2](1 / 2, 1 / 2)
alias Heun_Nodes = SIMD[DType.float64, 2](0, 1)

alias Ralston_Coefs = SIMD[DType.float64, 4](0, 0, 2 / 3, 0)
alias Ralston_Weights = SIMD[DType.float64, 2](1 / 4, 3 / 4)
alias Ralston_Nodes = SIMD[DType.float64, 2](0, 2 / 3)

alias Fehlberg45_Coefs = SIMD[DType.float64, 36](
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
alias Fehlberg4_Weights = SIMD[DType.float64, 6](
    25 / 216,
    0,
    1408 / 2565,
    2197 / 4104,
    -1 / 5,
    0,
)
alias Fehlberg5_Weights = SIMD[DType.float64, 6](
    16 / 135, 0, 6656 / 12825, 28561 / 56430, -9 / 50, 2 / 55
)
alias Fehlberg45_Nodes = SIMD[DType.float64, 6](
    0, 1 / 4, 3 / 8, 12 / 13, 1, 1 / 2
)


# For now...
fn get_row[
    order: Int, x: SIMD[DType.float64, order * order]
](row: Int) -> SIMD[DType.float64, order]:
    var res: SIMD[DType.float64, order] = 0
    for i in range(order):
        res[i] = x[i + row * order]
    return res


fn diffeq_steps[
    order: Int,
    coefs: SIMD[DType.float64, order * order],
    nodes: SIMD[DType.float64, order],
](
    t: Float64,
    dt: Float64,
    s: Float64,
    diff: fn (Float64, Float64, SIMD[DType.float64]) -> Float64,
    pars: SIMD[DType.float64],
    inout k: SIMD[DType.float64, order],
):
    for i in range(order):
        var node = t + nodes[i] * dt
        var c = get_row[order, coefs](i)
        var s_proj = s + (k * c).reduce_add()
        k[i] = diff(node, s_proj, pars)


fn diffeq_integrate[
    order: Int,
    coefs: SIMD[DType.float64, order * order],
    weights: SIMD[DType.float64, order],
    nodes: SIMD[DType.float64, order],
](
    steps: Int,
    dt: Float64,
    init_value: Float64,
    diff: fn (Float64, Float64, SIMD[DType.float64]) -> Float64,
    pars: SIMD[DType.float64],
    t0: Float64 = 0,
) -> Tuple[List[Float64], List[Float64]]:
    var times = List[Float64]()
    var values = List[Float64]()
    times.append(t0)
    values.append(init_value)
    var t = t0
    var value = init_value
    var k: SIMD[DType.float64, order] = 0
    for _ in range(steps):
        diffeq_steps[order, coefs, nodes](t, dt, value, diff, pars, k)
        value += (weights * k).reduce_add()
        t += dt
        times.append(t)
        values.append(value)
    return (times, values)


fn diffeq_integrate_adaptive[
    order: Int,
    coefs: SIMD[DType.float64, order * order],
    weights_high: SIMD[DType.float64, order],
    weights_low: SIMD[DType.float64, order],
    nodes: SIMD[DType.float64, order],
](
    steps: Int,
    dt: Float64,
    init_value: Float64,
    diff: fn (Float64, Float64, SIMD[DType.float64]) -> Float64,
    pars: SIMD[DType.float64],
    t0: Float64 = 0,
    tol: Float64 = 1e-6,
) -> Tuple[List[Float64], List[Float64]]:
    var times = List[Float64]()
    var values = List[Float64]()
    times.append(t0)
    values.append(init_value)
    var t = t0
    var delt = dt
    var value = init_value
    var k: SIMD[DType.float64, order] = 0
    for _ in range(steps):
        diffeq_steps[order, coefs, nodes](t, delt, value, diff, pars, k)
        var z = value + (weights_high * k).reduce_add()
        value += (weights_low * k).reduce_add()
        t += delt
        times.append(t)
        values.append(value)
        var s = (tol / abs(z - value) / 2) ** 1 / 4
        delt *= s
    return (times, values)


fn rk4_integrate(
    steps: Int,
    dt: Float64,
    init_value: Float64,
    diff: fn (Float64, Float64, SIMD[DType.float64]) -> Float64,
    pars: SIMD[DType.float64],
    t0: Float64 = 0,
) -> Tuple[List[Float64], List[Float64]]:
    return diffeq_integrate[
        4,
        RK4_Coefs,
        RK4_Weights,
        RK4_Nodes,
    ](steps, dt, init_value, diff, pars, t0)


fn euler_integrate(
    steps: Int,
    dt: Float64,
    init_value: Float64,
    diff: fn (Float64, Float64, SIMD[DType.float64]) -> Float64,
    pars: SIMD[DType.float64],
    t0: Float64 = 0,
) -> Tuple[List[Float64], List[Float64]]:
    return diffeq_integrate[1, 1, 1, 0](steps, dt, init_value, diff, pars, t0)


fn fehlberg45_integrate(
    steps: Int,
    dt: Float64,
    init_value: Float64,
    diff: fn (Float64, Float64, SIMD[DType.float64]) -> Float64,
    pars: SIMD[DType.float64],
    t0: Float64 = 0,
    tol: Float64 = 1e-6,
) -> Tuple[List[Float64], List[Float64]]:
    return diffeq_integrate_adaptive[
        6,
        Fehlberg45_Coefs,
        Fehlberg5_Weights,
        Fehlberg4_Weights,
        Fehlberg45_Nodes,
    ](steps, dt, init_value, diff, pars, t0, tol)


fn logis(t: Float64, s: Float64, pars: SIMD[DType.float64]) -> Float64:
    return pars[0] * s * (1 - s / pars[1])


fn main():
    var pars = SIMD[DType.float64](0.1, 10)
    var res = rk4_integrate(100, 0.1, 0.1, logis, pars)
    var times = res[0]
    var values = res[1]
    for i in range(times.size):
        print(times[i], values[i])
