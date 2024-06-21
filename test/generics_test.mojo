trait TestTrait:
    fn test[n: Int](self) -> SIMD[DType.uint64, n]:
        pass


struct TestStruct[m: Int](TestTrait):
    var mem: SIMD[DType.uint64, m]

    fn __init__(inout self):
        self.mem = SIMD[DType.uint64, m](0)

    fn test[n: Int](self) -> SIMD[DType.uint64, n]:
        return self.mem


fn main():
    var x = TestStruct[2]()
    print(x.test[2]())
