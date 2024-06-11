from benchmark import *
from numojo.linalg import *
from numojo.splitmix import *

# from python import numpy as np


fn bench_mat_mat_mult[rows: Int, cols: Int]() raises -> Report:
    var rng = SplitMix()
    var x = StaticMat[rows, cols](0)
    var y = StaticMat[cols, rows](0)
    for i in range(rows):
        for j in range(cols):
            x[i, j] = rng.next()
            y[j, i] = rng.next()

    fn doit() capturing:
        var z = x @ y
        keep(z)

    return run[doit](max_runtime_secs=5)


fn bench_mat_mat_mult_np[rows: Int, cols: Int]() raises -> Report:
    var rng = SplitMix()
    var x = StaticMat[rows, cols](0)
    var y = StaticMat[cols, rows](0)
    for i in range(rows):
        for j in range(cols):
            x[i, j] = rng.next()
            y[j, i] = rng.next()

    fn doit() capturing:
        var z = x @ y
        keep(z)

    return run[doit](max_runtime_secs=5)


fn main() raises:
    bench_mat_mat_mult[3, 3]().print("ns")
    bench_mat_mat_mult[8, 8]().print("ns")
    bench_mat_mat_mult[16, 16]().print("ns")
