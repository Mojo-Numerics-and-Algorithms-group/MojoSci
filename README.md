# numojo
Numerics for Mojo

## Random number generators

I ported some of the xo(ro)shiro family of random number generators to Mojo. I use these in my research (especially Xoshiro256pp) as they are fast and have good statistical properties. You can read about these generators (here)[https://prng.di.unimi.it/].

Here is the output from running the bench script.

Benchmarking 1e6 calls to random_ui64
---------------------
Benchmark Report (ms)
---------------------
Mean: 33.301985915492956
Total: 2364.4409999999998
Iters: 71
Warmup Mean: 33.314
Warmup Total: 66.628
Warmup Iters: 2
Fastest Mean: 33.301985915492956
Slowest Mean: 33.301985915492956


Benchmarking 1e6 calls to random_si64
---------------------
Benchmark Report (ms)
---------------------
Mean: 33.324732394366201
Total: 2366.056
Iters: 71
Warmup Mean: 33.329999999999998
Warmup Total: 66.659999999999997
Warmup Iters: 2
Fastest Mean: 33.324732394366194
Slowest Mean: 33.324732394366194


Benchmarking 1e6 calls to random_float64
---------------------
Benchmark Report (ms)
---------------------
Mean: 16.177412162162163
Total: 2394.2570000000001
Iters: 148
Warmup Mean: 16.224
Warmup Total: 32.448
Warmup Iters: 2
Fastest Mean: 16.177412162162163
Slowest Mean: 16.177412162162163


Benchmarking 1e6 calls to randn_float64
---------------------
Benchmark Report (ms)
---------------------
Mean: 59.606749999999998
Total: 2384.27
Iters: 40
Warmup Mean: 59.765000000000001
Warmup Total: 119.53
Warmup Iters: 2
Fastest Mean: 59.606749999999998
Slowest Mean: 59.606749999999998


Benchmarking 1e6 calls to splitmix
---------------------
Benchmark Report (ms)
---------------------
Mean: 1.2979610178668111
Total: 2397.3339999999998
Iters: 1847
Warmup Mean: 1.2965
Warmup Total: 2.593
Warmup Iters: 2
Fastest Mean: 1.2979610178668111
Slowest Mean: 1.2979610178668111


Benchmarking 1e6 calls to xoroshiro128plus
---------------------
Benchmark Report (ms)
---------------------
Mean: 7.7086955128205119
Total: 2405.1129999999998
Iters: 312
Warmup Mean: 7.6909999999999998
Warmup Total: 15.382
Warmup Iters: 2
Fastest Mean: 7.7086955128205128
Slowest Mean: 7.7086955128205128


Benchmarking 1e6 calls to xoroshiro128plusplus
---------------------
Benchmark Report (ms)
---------------------
Mean: 8.0500872483221482
Total: 2398.9259999999999
Iters: 298
Warmup Mean: 8.0779999999999994
Warmup Total: 16.155999999999999
Warmup Iters: 2
Fastest Mean: 8.0500872483221482
Slowest Mean: 8.0500872483221482


Benchmarking 1e6 calls to xoroshiro128starstar
---------------------
Benchmark Report (ms)
---------------------
Mean: 8.4979184397163117
Total: 2396.413
Iters: 282
Warmup Mean: 8.4930000000000003
Warmup Total: 16.986000000000001
Warmup Iters: 2
Fastest Mean: 8.4979184397163117
Slowest Mean: 8.4979184397163117


Benchmarking 1e6 calls to xoshiro256plus
---------------------
Benchmark Report (ms)
---------------------
Mean: 9.14602
Total: 1829.204
Iters: 200
Warmup Mean: 9.1479999999999997
Warmup Total: 18.295999999999999
Warmup Iters: 2
Fastest Mean: 9.14602
Slowest Mean: 9.14602


Benchmarking 1e6 calls to xoshiro256plusplus
---------------------
Benchmark Report (ms)
---------------------
Mean: 9.0034436090225576
Total: 2394.9160000000002
Iters: 266
Warmup Mean: 9.0380000000000003
Warmup Total: 18.076000000000001
Warmup Iters: 2
Fastest Mean: 9.0034436090225558
Slowest Mean: 9.0034436090225558


Benchmarking 1e6 calls to xoshiro256starstar
---------------------
Benchmark Report (ms)
---------------------
Mean: 9.0551401515151504
Total: 2390.5569999999998
Iters: 264
Warmup Mean: 9.0594999999999999
Warmup Total: 18.119
Warmup Iters: 2
Fastest Mean: 9.0551401515151522
Slowest Mean: 9.0551401515151522

It is not an especially fair comparison between the Mojo library and these generators as the library functions scale the output. Nonetheless, these generators appear to be about 3x faster than the one used by Mojo. Note that the generator in the standard library is not documented and is part of a currently closed-source runtime component.

