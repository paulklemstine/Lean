from math import gcd
from typing import Dict

def lcm(x: int, y: int) -> int:
    return x // gcd(x, y) * y

def factorize(m: int) -> Dict[int, int]:
    f: Dict[int, int] = {}
    d, n = 2, m
    while d * d <= n:
        while n % d == 0:
            f[d] = f.get(d, 0) + 1
            n //= d
        d += 1
    if n > 1:
        f[n] = f.get(n, 0) + 1
    return f

def pisano_period_factored(m: int, prime_power_period) -> int:
    """pi(m) = lcm over prime powers p^e || m of pi(p^e)   (Corollary 5.2).
    `prime_power_period(q)` returns pi(q) for a prime power q."""
    if m == 1:
        return 1
    result = 1
    for p, e in factorize(m).items():
        result = lcm(result, prime_power_period(p ** e))
    return result
