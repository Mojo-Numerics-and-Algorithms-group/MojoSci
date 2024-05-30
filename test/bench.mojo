import benchmark
import numojo.xoshiro


fn xos256pp():
    rng.next()


var report = benchmark[xos256pp]()

report.print()
