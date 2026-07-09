from __future__ import annotations
import math

def threshold_const(k: int) -> float:
    """Sharp constant c_k = ((k-1)(2(k-1)/k)^(k-2))^(1/(k-1)).

    Evaluated in log-space to avoid overflow/underflow for large k.
    """
    if k < 4:
        raise ValueError("k must be >= 4")
    log_c = (math.log(k - 1) + (k - 2) * math.log(2 * (k - 1) / k)) / (k - 1)
    return math.exp(log_c)

if __name__ == '__main__':
    for k in (4,5,13,1000):
        print(k, round(threshold_const(k),6))
