# numojo
Numerics for Mojo

## Random number generators

I ported some of the xo(ro)shiro family of random number generators to Mojo. I use these in my research (especially Xoshiro256pp) as they are fast and have good statistical properties. You can read about these generators [here](https://prng.di.unimi.it/). I tested the output of the Mojo versions against the C-code provided on that site.

Here is the output (slightly edited) from running the bench script.

| Library  | Function    | Time (ns) |
| -------- | ----------- | --------- |
| Standard | random_ui64 | 33.4 |
| Standard | random_si64 | 33.3 |
| Standard | random_float64 | 16.2 |
| Standard | randn_float64 | 59.6 |
| Numojo | splitmix | 1.3 |
| Numojo | xoroshiro128p | 7.7 |
| Numojo | xoroshiro128pp | 7.7 |
| Numojo | xoroshiro128ss | 7.7 |
| Numojo | xoshiro256p | 8.7 |
| Numojo | xoshiro256pp | 8.7 |
| Numojo | xoshiro256ss | 8.7 |

It is not an especially fair comparison between the Mojo library and these generators as the library functions scale the output. Nonetheless, these generators appear to be about 3x faster than the one used by Mojo. Note that the generator in the standard library is not documented and is part of a currently closed-source runtime component.

