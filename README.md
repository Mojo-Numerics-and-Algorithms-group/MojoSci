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

I have finished the first phase of the code for integrating differential equations. It is remarkable to me how Mojo + metaprogramming facilitates simple, yet efficient code. Here is an example.
```mojo
@value
struct Lorenz(DESys):
    var p1: Float64
    var p2: Float64
    var p3: Float64

    fn __init__(inout self, p1: Float64, p2: Float64, p3: Float64):
        self.p1 = p1
        self.p2 = p2
        self.p3 = p3

    @always_inline
    fn deriv[n: Int](self, t: Float64, s: ColVec[n]) -> ColVec[n]:
        return ColVec[n](
            self.p1 * (s.get[1]() - s.get[0]()),
            s.get[0]() * (self.p2 - s.get[2]()) - s.get[1](),
            s.get[0]() * s.get[1]() - self.p3 * s.get[2](),
        )

    @staticmethod
    fn ndim() -> Int:
        return 3

fn main() raises:
    var grad = Lorenz(10, 28, 8 / 3)
    var s0 = ColVec[3](2.0, 1.0, 1.0)
    var stepper = RKStepper[RK45](grad, s0, dt = 1)
    for _ in range(30):
        print("t =", stepper.t, end=": ")
        for i in range(3):
            print(stepper.state[i], end=" ")
        print()
        stepper.step()
```
A really nice aspect of this is that the integration strategies are separated from the stepper. The `RK45` type fulfills the [`RKStrategy` traits](https://github.com/Mojo-Numerics-and-Algorithms-group/MojoSci/blob/main/src/diffeq/rkstrategy.mojo) and provides all the necessary information (the Butcher Tableau) for the Dormand-Prince adaptive integraiton method. You can easily add new strategies by creating a new type fulfilling the `RKStrategy` traits.

I still need to write traits for an observer/recorder type that will manage the outer loop and log the output. 

## Linear algebra

I started some basic, fixed-sized, stack-allocated vector and matrix types to support multi-dimensional ODE systems. All operations should be inlined and unrolled at compile time. I'll be curious to see if the compiler can optimize away the temporaries. If so, these should be quite fast. 


