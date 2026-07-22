from math import ceil, log, log1p

def minimum_repetitions(m: int, epsilon: float) -> int:
    if m <= 0 or not 0.0 < epsilon < 1.0:
        raise ValueError("Require m > 0 and 0 < epsilon < 1")
    return ceil(log(epsilon) / log1p(-(2.0 ** -m)))
