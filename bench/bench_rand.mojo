from random import *
from benchmark import *
from numojo.xoshiro import *
from numojo.splitmix import *
from numojo.xoroshiro import *


fn bench_rand_ui64() -> Report:
    seed()

    fn doit():
        var x = random_ui64(0, 1e9)
        keep(x)

    return run[doit]()


fn bench_rand_si64() -> Report:
    seed()

    fn doit():
        var x = random_si64(0, 1e9)
        keep(x)

    return run[doit]()


fn bench_random_float64() -> Report:
    seed()

    fn doit():
        var x = random_float64()
        keep(x)

    return run[doit]()


fn bench_randn_float64() -> Report:
    seed()

    fn doit():
        var x = randn_float64()
        keep(x)

    return run[doit]()


fn bench_splitmix() -> Report:
    var rng = SplitMix()

    fn doit() capturing:
        var x = rng.next()
        keep(x)

    return run[doit]()


fn bench_xoroshiro128plus() -> Report:
    var rng = Xoroshiro128Plus()

    fn doit() capturing:
        var x = rng.next()
        keep(x)

    return run[doit]()


fn bench_xoroshiro128plusplus() -> Report:
    var rng = Xoroshiro128PlusPlus()

    fn doit() capturing:
        var x = rng.next()
        keep(x)

    return run[doit]()


fn bench_xoroshiro128starstar() -> Report:
    var rng = Xoroshiro128StarStar()

    fn doit() capturing:
        var x = rng.next()
        keep(x)

    return run[doit]()


fn bench_xoshiro256plus() -> Report:
    var rng = Xoshiro256Plus()

    fn doit() capturing:
        var x = rng.next()
        keep(x)

    return run[doit]()


fn bench_xoshiro256plusplus() -> Report:
    var rng = Xoshiro256PlusPlus()

    fn doit() capturing:
        var x = rng.next()
        keep(x)

    return run[doit]()


fn bench_xoshiro256starstar() -> Report:
    var rng = Xoshiro256StarStar()

    fn doit() capturing:
        var x = rng.next()
        keep(x)

    return run[doit]()


fn bench_xoshiro256plusplussimd4() -> Report:
    var rng = Xoshiro256PlusPlusSIMD[4]()

    fn doit() capturing:
        var x = rng.next()
        keep(x)

    return run[doit]()


fn bench_xoshiro256plusplussimd16() -> Report:
    var rng = Xoshiro256PlusPlusSIMD[16]()

    fn doit() capturing:
        var x = rng.next()
        keep(x)

    return run[doit]()


fn main():
    print("| Library  | Function    | Time (ns) |")
    print("| -------- | ----------- | --------- |")
    print("| Standard | random_ui64 |", bench_rand_si64().mean("ns"), "|")
    print("| Standard | random_si64 |", bench_rand_si64().mean("ns"), "|")
    print(
        "| Standard | random_float64 |",
        bench_random_float64().mean("ns"),
        "|",
    )
    print(
        "| Standard | randn_float64 |",
        bench_randn_float64().mean("ns"),
        "|",
    )
    print("| Numojo | splitmix |", bench_splitmix().mean("ns"), "|")
    print(
        "| Numojo | xoroshiro128p |",
        bench_xoroshiro128plus().mean("ns"),
        "|",
    )
    print(
        "| Numojo | xoroshiro128pp |",
        bench_xoroshiro128plusplus().mean("ns"),
        "|",
    )
    print(
        "| Numojo | xoroshiro128ss |",
        bench_xoroshiro128starstar().mean("ns"),
        "|",
    )
    print(
        "| Numojo | xoshiro256p |",
        bench_xoshiro256plus().mean("ns"),
        "|",
    )
    print(
        "| Numojo | xoshiro256pp |",
        bench_xoshiro256plusplus().mean("ns"),
        "|",
    )
    print(
        "| Numojo | xoshiro256ss |",
        bench_xoshiro256starstar().mean("ns"),
        "|",
    )
    print(
        "| Numojo | xoshiro256pp x 4 |",
        bench_xoshiro256plusplussimd4().mean("ns"),
        "|",
    )
    print(
        "| Numojo | xoshiro256pp x 16 |",
        bench_xoshiro256plusplussimd16().mean("ns"),
        "|",
    )
