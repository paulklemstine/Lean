import math

def cramer_sum(N: int) -> float:
    """Expected number of Cramer random primes in [2, N]."""
    s: float = 0.0
    for n in range(2, N + 1):
        s += 1.0 / math.log(n)
    return s
