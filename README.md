# MojoSci 
The goal of this project is to provide a set of libraries for Mojo that will facilitate education, modeling, data analysis, and statistics. Right now, it is mostly comoposed of simple elements that I use in my work and wanted to begin moving to Mojo. Some operating principles are:

1. Write simple, readable code that is maintainable and teachable.
2. Provide both compile-time and run-time interfaces when it makes sense to do so.
3. Keep it simple and let the compiler do the heavy lifting; optimize later using benchmark results.

## Random number generators

I ported some of the xo(ro)shiro family of random number generators to Mojo. I use these in my research (especially Xoshiro256pp) as they are fast and have good statistical properties. You can read about these generators [here](https://prng.di.unimi.it/). I tested the output of the Mojo versions against the C-code provided on that site.

Here is the output (slightly edited) from running the bench script.

| Library  | Function    | Time (ns) |
| -------- | ----------- | --------- |
| Standard | random_ui64 | 19.8 |
| Standard | random_si64 | 19.8 |
| Standard | random_float64 | 9.3 |
| Standard | randn_float64 | 34.7 |
| MojoSci | splitmix | 0.75 |
| MojoSci | xoroshiro128p | 1.26 |
| MojoSci | xoroshiro128pp | 1.34 |
| MojoSci | xoroshiro128ss | 1.51 |
| MojoSci | xoshiro256p | 0.96 |
| MojoSci | xoshiro256pp | 1.07 |
| MojoSci | xoshiro256ss | 1.25 |
| MojoSci | xoshiro256pp x 4 | 1.44 |
| MojoSci | xoshiro256pp x 16 | 5.93 |

On my laptop, the Xoshiro Plus Plus generates 64 Gbps of pseudo-entropy. Using SIMD arithmetic and parallel generators, it generates 178 Gbps with 4 parallel generators and 173 Gbps with 16 parallel generators. The number of parallel generators is set at compile-time. The parallel generators use a single seed and are split from the first generator using the long_jump function. Then ensures independent, non-overlapping sequences. See the website link above for more details.

## ODE Integration

I added some basic routines for ODE integration. This will need lots of work to generalize.

## Linear algebra

I started some basic, fixed-sized, stack-allocated vector and matrix types to support multi-dimensional ODE systems. All operations should be inlined and unrolled at compile time. I'll be curious to see if the compiler can optimize away the temporaries. If so, these should be quite fast. 


