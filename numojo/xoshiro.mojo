# Copyright Timothy H. Keitt 2024
# Adapted from https://prng.di.unimi.it/
# https://github.com/keittlab/numojo


from time import now


struct SplitMix:
    var seed: UInt64
    var state: UInt64

    fn __init__(inout self):
        self.seed = now()
        self.state = self.seed

    fn __init__(inout self, seed: UInt64):
        self.seed = seed
        self.state = seed

    fn get_seed(self) -> UInt64:
        return self.seed

    fn step(inout self: SplitMix):
        self.state += 0x9E3779B97F4A7C15

    fn next(inout self: SplitMix) -> UInt64:
        self.step()
        var z = self.state
        z = (z ^ (z >> 30)) * 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) * 0x94D049BB133111EB
        return z ^ (z >> 31)

    fn reset(inout self: SplitMix):
        self.state = self.seed

    fn fill[k: Int](inout self: SplitMix, inout other: SIMD[DType.uint64, k]):
        for i in range(k):
            other[i] = self.next()


fn rotate_left[k: UInt64](x: UInt64) -> UInt64:
    constrained[k < 64, "Invalid rotation"]()
    return x << k | x >> 64 - k


struct Xoshiro256Engine:
    var state: SIMD[DType.uint64, 4]
    var seed: UInt64

    fn __init__(inout self):
        self.state = 0
        self.seed = now()
        var seedr = SplitMix(self.seed)
        seedr.fill(self.state)

    fn __init__(inout self, seed: UInt64):
        self.state = 0
        self.seed = seed
        var seedr = SplitMix(seed)
        seedr.fill(self.state)

    fn get_seed(self) -> UInt64:
        return self.seed

    fn step(inout self):
        var t = self.state[1] << 17
        self.state[2] ^= self.state[0]
        self.state[3] ^= self.state[1]
        self.state[1] ^= self.state[2]
        self.state[0] ^= self.state[3]
        self.state[2] ^= t
        self.state[3] = rotate_left[45](self.state[3])

    fn jump(inout self):
        var res: SIMD[DType.uint64, 4] = 0
        var coefs = SIMD[DType.uint64, 4](
            0x180EC6D33CFD0ABA,
            0xD5A61266F0C9392C,
            0xA9582618E03FC9AA,
            0x39ABDC4529B1661C,
        )
        for i in range(4):
            for j in range(64):
                if coefs[i] & (1 << j):
                    res ^= self.state
                self.step()
        self.state = res

    fn long_jump(inout self):
        var res: SIMD[DType.uint64, 4] = 0
        var coefs = SIMD[DType.uint64, 4](
            0x76E15D3EFEFDCBBF,
            0xC5004E441C522FB3,
            0x77710069854EE241,
            0x39109BB02ACBE635,
        )
        for i in range(4):
            for j in range(64):
                if coefs[i] & (1 << j):
                    res ^= self.state
                self.step()
        self.state = res

    fn scramble_plus(self) -> UInt64:
        return self.state[0] + self.state[3]

    fn scramble_plus_plus(self) -> UInt64:
        return rotate_left[23](self.scramble_plus()) + self.state[0]

    fn scramble_star(self) -> UInt64:
        return self.state[1] * 5

    fn scramble_star_star(self) -> UInt64:
        return rotate_left[7](self.scramble_star()) * 9

    fn reset(inout self):
        var seedr = SplitMix(self.seed)
        seedr.fill(self.state)


struct Xoshiro256p:
    var eng: Xoshiro256Engine

    fn __init__(inout self):
        self.eng = Xoshiro256Engine()

    fn __init__(inout self, seed: UInt64):
        self.eng = Xoshiro256Engine(seed)

    fn get_seed(self) -> UInt64:
        return self.eng.get_seed()

    fn step(inout self):
        self.eng.step()

    fn jump(inout self):
        self.eng.jump()

    fn long_jump(inout self):
        self.eng.long_jump()

    fn next(inout self) -> UInt64:
        var res = self.eng.scramble_plus()
        self.eng.step()
        return res

    fn reset(inout self):
        self.eng.reset()


struct Xoshiro256pp:
    var eng: Xoshiro256Engine

    fn __init__(inout self):
        self.eng = Xoshiro256Engine()

    fn __init__(inout self, seed: UInt64):
        self.eng = Xoshiro256Engine(seed)

    fn get_seed(self) -> UInt64:
        return self.eng.get_seed()

    fn step(inout self):
        self.eng.step()

    fn jump(inout self):
        self.eng.jump()

    fn long_jump(inout self):
        self.eng.long_jump()

    fn next(inout self) -> UInt64:
        var res = self.eng.scramble_plus_plus()
        self.eng.step()
        return res

    fn reset(inout self):
        self.eng.reset()


struct Xoshiro256ss:
    var eng: Xoshiro256Engine

    fn __init__(inout self):
        self.eng = Xoshiro256Engine()

    fn __init__(inout self, seed: UInt64):
        self.eng = Xoshiro256Engine(seed)

    fn get_seed(self) -> UInt64:
        return self.eng.get_seed()

    fn step(inout self):
        self.eng.step()

    fn jump(inout self):
        self.eng.jump()

    fn long_jump(inout self):
        self.eng.long_jump()

    fn next(inout self) -> UInt64:
        var res = self.eng.scramble_star_star()
        self.eng.step()
        return res

    fn reset(inout self):
        self.eng.reset()


struct Xoshiro128Engine:
    var state: SIMD[DType.uint64, 2]
    var seed: UInt64

    fn __init__(inout self):
        self.state = 0
        self.seed = now()
        var seedr = SplitMix(self.seed)
        seedr.fill(self.state)

    fn __init__(inout self, seed: UInt64):
        self.state = 0
        self.seed = seed
        var seedr = SplitMix(seed)
        seedr.fill(self.state)

    fn get_seed(self) -> UInt64:
        return self.seed

    fn step(inout self):
        self.state[1] ^= self.state[0]
        self.state[0] = (
            rotate_left[24](self.state[0])
            ^ self.state[1]
            ^ (self.state[1] << 16)
        )
        self.state[1] = rotate_left[37](self.state[1])

    fn jump(inout self):
        var res: SIMD[DType.uint64, 2] = 0
        var coefs = SIMD[DType.uint64, 2](
            0xDF900294D8F554A5, 0x170865DF4B3201FC
        )
        for i in range(2):
            for j in range(64):
                if coefs[i] & (1 << j):
                    res ^= self.state
                self.step()
        self.state = res

    fn long_jump(inout self):
        var res: SIMD[DType.uint64, 2] = 0
        var coefs = SIMD[DType.uint64, 2](
            0xD2A98B26625EEE7B, 0xDDDF9B1090AA7AC1
        )
        for i in range(2):
            for j in range(64):
                if coefs[i] & (1 << j):
                    res ^= self.state
                self.step()
        self.state = res

    fn scramble_plus(self) -> UInt64:
        return self.state[0] + self.state[1]

    fn scramble_plus_plus(self) -> UInt64:
        return rotate_left[17](self.scramble_plus()) + self.state[0]

    fn scramble_star(self) -> UInt64:
        return self.state[1] * 5

    fn scramble_star_star(self) -> UInt64:
        return rotate_left[7](self.scramble_star()) * 9

    fn reset(inout self):
        var seedr = SplitMix(self.seed)
        seedr.fill(self.state)


struct Xoshiro128p:
    var eng: Xoshiro128Engine

    fn __init__(inout self):
        self.eng = Xoshiro128Engine()

    fn __init__(inout self, seed: UInt64):
        self.eng = Xoshiro128Engine(seed)

    fn get_seed(self) -> UInt64:
        return self.eng.get_seed()

    fn step(inout self):
        self.eng.step()

    fn jump(inout self):
        self.eng.jump()

    fn long_jump(inout self):
        self.eng.long_jump()

    fn next(inout self) -> UInt64:
        var res = self.eng.scramble_plus()
        self.eng.step()
        return res

    fn reset(inout self):
        self.eng.reset()


struct Xoshiro128pp:
    var eng: Xoshiro128Engine

    fn __init__(inout self):
        self.eng = Xoshiro128Engine()

    fn __init__(inout self, seed: UInt64):
        self.eng = Xoshiro128Engine(seed)

    fn get_seed(self) -> UInt64:
        return self.eng.get_seed()

    fn step(inout self):
        self.eng.step()

    fn jump(inout self):
        self.eng.jump()

    fn long_jump(inout self):
        self.eng.long_jump()

    fn next(inout self) -> UInt64:
        var res = self.eng.scramble_plus_plus()
        self.eng.step()
        return res

    fn reset(inout self):
        self.eng.reset()


struct Xoshiro128ss:
    var eng: Xoshiro128Engine

    fn __init__(inout self):
        self.eng = Xoshiro128Engine()

    fn __init__(inout self, seed: UInt64):
        self.eng = Xoshiro128Engine(seed)

    fn get_seed(self) -> UInt64:
        return self.eng.get_seed()

    fn step(inout self):
        self.eng.step()

    fn jump(inout self):
        self.eng.jump()

    fn long_jump(inout self):
        self.eng.long_jump()

    fn next(inout self) -> UInt64:
        var res = self.eng.scramble_star_star()
        self.eng.step()
        return res

    fn reset(inout self):
        self.eng.reset()
