# Copyright Timothy H. Keitt 2024
# Adapted from https://prng.di.unimi.it/
# https://github.com/keittlab/numojo

alias SplitMixState = UInt64

fn step(inout x: SplitMixState):
    x += 0x9e3779b97f4a7c15

fn splitmix(inout x: SplitMixState) -> UInt64:
    step(x)
    var z = x
    z = (z ^ (z >> 30)) * 0xbf58476d1ce4e5b9
    z = (z ^ (z >> 27)) * 0x94d049bb133111eb
    return z ^ (z >> 31)

fn seed_with_splitmix[k: Int](seed: SplitMixState) -> SIMD[DType.uint64, k]:
    var res: SIMD[DType.uint64, k] = 0
    var state = seed
    for i in range(k):
        res[i] = splitmix(state)
    return res

fn rotate_left[k: UInt64](x: UInt64) -> UInt64:
    constrained[k < 64, "Invalid rotation"]()
    return (x << k | x >> 64 - k)

alias XoshiroState256 = SIMD[DType.uint64, 4]

fn seed256(seed: SplitMixState) -> XoshiroState256:
    return seed_with_splitmix[4](seed)

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
    var coefs = XoshiroState256(0x180ec6d33cfd0aba,
                                0xd5a61266f0c9392c,
                                0xa9582618e03fc9aa,
                                0x39abdc4529b1661c)
    for i in range(4):
        for j in range(64):
            if coefs[i] & (1 << j):
                res ^= x
            step(x)
    x = res

fn long_jump(inout x: XoshiroState256):
    var res: XoshiroState256 = 0
    var coefs = XoshiroState256(0x76e15d3efefdcbbf,
                                0xc5004e441c522fb3,
                                0x77710069854ee241,
                                0x39109bb02acbe635)
    for i in range(4):
        for j in range(64):
            if coefs[i] & (1 << j):
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

alias XoshiroState128 = SIMD[DType.uint64, 2]

fn seed128(seed: SplitMixState) -> XoshiroState128:
    return seed_with_splitmix[2](seed)

fn scramble_plus(x: XoshiroState128) -> UInt64:
    return x[0] + x[1]

fn scramble_plus_plus(x: XoshiroState128) -> UInt64:
    return rotate_left[17](scramble_plus(x)) + x[0]

fn scramble_star(x: XoshiroState128) -> UInt64:
    return x[1] * 5

fn scramble_star_star(x: XoshiroState128) -> UInt64:
    return rotate_left[7](scramble_star(x)) * 9

fn step(inout x: XoshiroState128):
    x[1] ^= x[0]
    x[0] = rotate_left[24](x[0]) ^ x[1] ^ (x[1] << 16)
    x[1] = rotate_left[37](x[1])

fn jump(inout x: XoshiroState128):
    var res: XoshiroState128 = 0
    var coefs = XoshiroState128(0xdf900294d8f554a5,
                                0x170865df4b3201fc)
    for i in range(2):
        for j in range(64):
            if coefs[i] & (1 << j):
                res ^= x
            step(x)
    x = res

fn long_jump(inout x: XoshiroState128):
    var res: XoshiroState128 = 0
    var coefs = XoshiroState128(0xd2a98b26625eee7b,
                                0xdddf9b1090aa7ac1)
    for i in range(2):
        for j in range(64):
            if coefs[i] & (1 << j):
                res ^= x
            step(x)
    x = res


fn xoshiro128p(inout x: XoshiroState128) -> UInt64:
    var res = scramble_plus(x)
    step(x)
    return res

fn xoshiro128pp(inout x: XoshiroState128) -> UInt64:
    var res = scramble_plus_plus(x)
    step(x)
    return res

fn xoshiro128ss(inout x: XoshiroState128) -> UInt64:
    var res = scramble_star_star(x)
    step(x)
    return res


