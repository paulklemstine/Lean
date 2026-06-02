def find_zero_divisor_witness(x):
    if x.norm() != 0: return None
    return MoebiusInt(1, -1) if x.re == x.im else MoebiusInt(1, 1)