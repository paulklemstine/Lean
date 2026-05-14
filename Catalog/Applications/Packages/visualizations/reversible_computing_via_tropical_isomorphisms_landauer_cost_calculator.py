import math
def landauer_cost(n_bits, kB=1.380649e-23, T=300.0):
    return kB * T * n_bits * math.log(2)