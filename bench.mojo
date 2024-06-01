from random import *
from benchmark import *
from numojo.xoshiro import *
from numojo.splitmix import *
from numojo.xoroshiro import *


fn bench_rand_ui64() -> Report:
    seed()

    fn doit():
        var x: UInt64 = 0
        for i in range(1e6):
            x = random_ui64(0, 1e9)
            keep(x)

    return run[doit]()


fn bench_rand_si64() -> Report:
    seed()

    fn doit():
        var x: Int64 = 0
        for i in range(1e6):
            x = random_si64(0, 1e9)
            keep(x)

    return run[doit]()


fn bench_random_float64() -> Report:
    seed()

    fn doit():
        var x: Float64 = 0
        for i in range(1e6):
            x = random_float64()
            keep(x)

    return run[doit]()


fn bench_randn_float64() -> Report:
    seed()

    fn doit():
        var x: Float64 = 0
        for i in range(1e6):
            x = randn_float64()
            keep(x)

    return run[doit]()


fn bench_splitmix() -> Report:
    var rng = SplitMix()

    fn doit() capturing:
        var x: UInt64 = 0
        for i in range(1e6):
            x = rng.next()
            keep(x)

    return run[doit]()


fn bench_xoroshiro128plus() -> Report:
    var rng = Xoroshiro128plus()

    fn doit() capturing:
        var x: UInt64 = 0
        for i in range(1e6):
            x = rng.next()
            keep(x)

    return run[doit]()


fn bench_xoroshiro128plusplus() -> Report:
    var rng = Xoroshiro128plusplus()

    fn doit() capturing:
        var x: UInt64 = 0
        for i in range(1e6):
            x = rng.next()
            keep(x)

    return run[doit]()


fn bench_xoroshiro128starstar() -> Report:
    var rng = Xoroshiro128starstar()

    fn doit() capturing:
        var x: UInt64 = 0
        for i in range(1e6):
            x = rng.next()
            keep(x)

    return run[doit]()


fn bench_xoshiro256plus() -> Report:
    var rng = Xoshiro256plus()

    fn doit() capturing:
        var x: UInt64 = 0
        for i in range(1e6):
            x = rng.next()
            keep(x)

    return run[doit]()


fn bench_xoshiro256plusplus() -> Report:
    var rng = Xoshiro256plusplus()

    fn doit() capturing:
        var x: UInt64 = 0
        for i in range(1e6):
            x = rng.next()
            keep(x)

    return run[doit]()


fn bench_xoshiro256starstar() -> Report:
    var rng = Xoshiro256starstar()

    fn doit() capturing:
        var x: UInt64 = 0
        for i in range(1e6):
            x = rng.next()
            keep(x)

    return run[doit]()


fn main():
    print("| Library  | Function    | Time (ns) |")
    print("| -------- | ----------- | --------- |")
    print("| Standard | random_ui64 |", bench_rand_si64().mean("ns") / 1e6, "|")
    print("| Standard | random_si64 |", bench_rand_si64().mean("ns") / 1e6, "|")
    print(
        "| Standard | random_float64 |",
        bench_random_float64().mean("ns") / 1e6,
        "|",
    )
    print(
        "| Standard | randn_float64 |",
        bench_randn_float64().mean("ns") / 1e6,
        "|",
    )
    print("| Numojo | splitmix |", bench_splitmix().mean("ns") / 1e6, "|")
    print(
        "| Numojo | xoroshiro128p |",
        bench_xoroshiro128plus().mean("ns") / 1e6,
        "|",
    )
    print(
        "| Numojo | xoroshiro128pp |",
        bench_xoroshiro128plusplus().mean("ns") / 1e6,
        "|",
    )
    print(
        "| Numojo | xoroshiro128ss |",
        bench_xoroshiro128starstar().mean("ns") / 1e6,
        "|",
    )
    print(
        "| Numojo | xoshiro256p |",
        bench_xoshiro256plus().mean("ns") / 1e6,
        "|",
    )
    print(
        "| Numojo | xoshiro256pp |",
        bench_xoshiro256plusplus().mean("ns") / 1e6,
        "|",
    )
    print(
        "| Numojo | xoshiro256ss |",
        bench_xoshiro256starstar().mean("ns") / 1e6,
        "|",
    )
