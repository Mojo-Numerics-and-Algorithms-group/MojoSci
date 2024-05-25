fn rotate_left[k: UInt64](x: UInt64) -> UInt64:
    constrained[k < 64, "Invalid rotation"]()
    return (x << k | x >> 64 - k)

alias XoshiroState256 = SIMD[DType.uint64, 4]

fn scramble_plus(x: XoshiroState256) -> UInt64:
    return x[0] + x[3]

fn scramble_plus_plus(x: XoshiroState256) -> UInt64:
    return rotate_left[23](scramble_plus(x)) + x[0]

fn scramble_star(x: XoshiroState256) -> UInt64:
    return x[1] * 5

fn scramble_star_star(x: XoshiroState256) -> UInt64:
    return rotate_left[7](scramble_star(x)) * 9

fn step(inout x: XoshiroState256):
    var t = x[1] << 17
    x[2] ^= x[0]
    x[3] ^= x[1]
    x[1] ^= x[2]
    x[0] ^= x[3]
    x[2] ^= t
    x[3] = rotate_left[45](x[3])

fn jump(inout x: XoshiroState256):
    var res: XoshiroState256 = 0
    for i in range(64):
        if 0x180ec6d33cfd0aba & (1 << i):
            res ^= x
        step(x)
    for i in range(64):
        if 0xd5a61266f0c9392c & (1 << i):
            res ^= x
        step(x)
    for i in range(64):
        if 0xa9582618e03fc9aa & (1 << i):
            res ^= x
        step(x)
    for i in range(64):
        if 0x39abdc4529b1661c & (1 << i):
            res ^= x
        step(x)
    x = res

fn long_jump(inout x: XoshiroState256):
    var res: XoshiroState256 = 0
    for i in range(64):
        if 0x76e15d3efefdcbbf & (1 << i):
            res ^= x
        step(x)
    for i in range(64):
        if 0xc5004e441c522fb3 & (1 << i):
            res ^= x
        step(x)
    for i in range(64):
        if 0x77710069854ee241 & (1 << i):
            res ^= x
        step(x)
    for i in range(64):
        if 0x39109bb02acbe635 & (1 << i):
            res ^= x
        step(x)
    x = res

fn xoshiro256p(inout x: XoshiroState256) -> UInt64:
    var res = scramble_plus(x)
    step(x)
    return res

fn xoshiro256pp(inout x: XoshiroState256) -> UInt64:
    var res = scramble_plus_plus(x)
    step(x)
    return res

fn xoshiro256ss(inout x: XoshiroState256) -> UInt64:
    var res = scramble_star_star(x)
    step(x)
    return res

