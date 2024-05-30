from random import *
from benchmark import *
from numojo.xoshiro import *
from numojo.splitmix import *
from numojo.xoroshiro import *


fn bench_rand_ui64():
    seed()

    fn doit():
        for i in range(1e6):
            var x = random_ui64(0, 1e9)

    var report = run[doit]()
    print("\nBenchmarking 1e6 calls to random_ui64")
    report.print("ms")


fn bench_rand_si64():
    seed()

    fn doit():
        for i in range(1e6):
            var x = random_si64(0, 1e9)

    var report = run[doit]()
    print("\nBenchmarking 1e6 calls to random_si64")
    report.print("ms")


fn bench_random_float64():
    seed()

    fn doit():
        for i in range(1e6):
            var x = random_float64()

    var report = run[doit]()
    print("\nBenchmarking 1e6 calls to random_float64")
    report.print("ms")


fn bench_randn_float64():
    seed()

    fn doit():
        for i in range(1e6):
            var x = randn_float64()

    var report = run[doit]()
    print("\nBenchmarking 1e6 calls to randn_float64")
    report.print("ms")


fn bench_splitmix():
    var rng = SplitMix()

    fn doit() capturing:
        for i in range(1e6):
            var x = rng.next()
            keep(x)

    var report = run[doit]()
    print("\nBenchmarking 1e6 calls to splitmix")
    report.print("ms")


fn bench_xoroshiro128plus():
    var rng = Xoroshiro128plus()

    fn doit() capturing:
        for i in range(1e6):
            var x = rng.next()
            keep(x)

    var report = run[doit]()
    print("\nBenchmarking 1e6 calls to xoroshiro128plus")
    report.print("ms")


fn bench_xoroshiro128plusplus():
    var rng = Xoroshiro128plusplus()

    fn doit() capturing:
        for i in range(1e6):
            var x = rng.next()
            keep(x)

    var report = run[doit]()
    print("\nBenchmarking 1e6 calls to xoroshiro128plusplus")
    report.print("ms")


fn bench_xoroshiro128starstar():
    var rng = Xoroshiro128starstar()

    fn doit() capturing:
        for i in range(1e6):
            var x = rng.next()
            keep(x)

    var report = run[doit]()
    print("\nBenchmarking 1e6 calls to xoroshiro128starstar")
    report.print("ms")


fn bench_xoshiro256plus():
    var rng = Xoshiro256plus()

    fn doit() capturing:
        for i in range(1e6):
            var x = rng.next()
            keep(x)

    var report = run[doit]()
    print("\nBenchmarking 1e6 calls to xoshiro256plus")
    report.print("ms")


fn bench_xoshiro256plusplus():
    var rng = Xoshiro256plusplus()

    fn doit() capturing:
        for i in range(1e6):
            var x = rng.next()
            keep(x)

    var report = run[doit]()
    print("\nBenchmarking 1e6 calls to xoshiro256plusplus")
    report.print("ms")


fn bench_xoshiro256starstar():
    var rng = Xoshiro256starstar()

    fn doit() capturing:
        for i in range(1e6):
            var x = rng.next()
            keep(x)

    var report = run[doit]()
    print("\nBenchmarking 1e6 calls to xoshiro256starstar")
    report.print("ms")


fn main():
    bench_rand_ui64()
    bench_rand_si64()
    bench_random_float64()
    bench_randn_float64()
    bench_splitmix()
    bench_xoroshiro128plus()
    bench_xoroshiro128plusplus()
    bench_xoroshiro128starstar()
    bench_xoshiro256plus()
    bench_xoshiro256plusplus()
    bench_xoshiro256starstar()
