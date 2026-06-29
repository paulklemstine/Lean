import math
def brute_force_floor(key_bits: int, kB: float = 1.380649e-23, T: float = 300.0) -> float:
    return (2 ** key_bits) * kB * T * math.log(2.0)
