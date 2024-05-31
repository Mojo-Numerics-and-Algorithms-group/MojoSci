# numojo
Numerics for Mojo

## Random number generators

I ported some of the xo(ro)shiro family of random number generators to Mojo. I use these in my research (especially Xoshiro256pp) as they are fast and have good statistical properties. You can read about these generators [here](https://prng.di.unimi.it/).

Here is the output from running the bench script.

| Library  | Function    | Time (ns) |
| ======== | =========== | ========= |
| Standard | random_ui64 | 33.371746478873241 |
| Standard | random_si64 | 33.311180555555559 |
| Standard | random_float64 | 16.179648648648648 |
| Standard | randn_float64 | 59.552500000000002 |
| Numojo | splitmix | 1.2969949999999999 |
| Numojo | xoroshiro128p | 7.7168360128617364 |
| Numojo | xoroshiro128pp | 7.6971382636655949 |
| Numojo | xoroshiro128ss | 7.6957556270096461 |
| Numojo | xoroshiro256p | 8.7401496350364969 |
| Numojo | xoroshiro256pp | 8.7429452554744511 |
| Numojo | xoroshiro256ss | 8.7057127272727257 |

It is not an especially fair comparison between the Mojo library and these generators as the library functions scale the output. Nonetheless, these generators appear to be about 3x faster than the one used by Mojo. Note that the generator in the standard library is not documented and is part of a currently closed-source runtime component.

