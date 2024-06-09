# numojo 
Numerics for Mojo

## Random number generators

I ported some of the xo(ro)shiro family of random number generators to Mojo. I use these in my research (especially Xoshiro256pp) as they are fast and have good statistical properties. You can read about these generators [here](https://prng.di.unimi.it/). I tested the output of the Mojo versions against the C-code provided on that site.

Here is the output (slightly edited) from running the bench script.

| Library  | Function    | Time (ns) |
| -------- | ----------- | --------- |
| Standard | random_ui64 | 19.4 |
| Standard | random_si64 | 19.4 |
| Standard | random_float64 | 9.1 |
| Standard | randn_float64 | 34.4 |
| Numojo | splitmix | 0.74 |
| Numojo | xoroshiro128p | 4.3 |
| Numojo | xoroshiro128pp | 4.6 |
| Numojo | xoroshiro128ss | 4.8 |
| Numojo | xoshiro256p | 0.94 |
| Numojo | xoshiro256pp | 1.0 |
| Numojo | xoshiro256ss | 1.2 |
| Numojo | xoshiro256ppp4 | 1.4 |

The last row is generating 4 independent streams in parallel using SIMD operations. It is not an especially fair comparison between the Mojo library and these generators as the library functions scale the output. Nonetheless, these generators appear to be about 3x faster than the one used by Mojo. Note that the generator in the standard library is not documented and is part of a currently closed-source runtime component.

## ODE Integration

I added some basic routines for ODE integration. This will need lots of work to generalize.

## Linear algebra

I started some basic, fixed-sized, stack-allocated vector and matrix types to support multi-dimensional ODE systems. All operations should be inlined and unrolled at compile time. I'll be curious to see if the compiler can optimize away the temporaries. If so, these should be quite fast. 


