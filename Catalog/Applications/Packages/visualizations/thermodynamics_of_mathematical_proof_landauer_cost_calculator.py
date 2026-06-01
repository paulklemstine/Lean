def landauer_cost(kB, T, erasure_bits):
    import math
    return kB * T * erasure_bits * math.log(2)