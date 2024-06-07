from benchmark import *
from numojo.linalg import *


fn bench_mat_mat_mult[rows: Int, cols: Int]() -> Report:
    fn doit():
        var x = Mat[rows, cols](3)
        var y = Mat[cols, rows](5)
        var z = x @ y
        keep(z)

    return run[doit](max_runtime_secs=5)


fn main():
    bench_mat_mat_mult[3, 3]().print("ns")
    bench_mat_mat_mult[8, 8]().print("ns")
    bench_mat_mat_mult[16, 16]().print("ns")
