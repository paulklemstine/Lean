def landauer_capacity(energy: float, temp: float = 300.0, b: int = 2) -> tuple:
    import math
    k_B = 1.380649e-23
    max_len = int(energy / (k_B * temp * math.log(b)))
    return (max_len, 2 * b ** max_len)