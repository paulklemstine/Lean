from math import gcd
from functools import reduce
from typing import Dict, List

def factorize(n: int) -> Dict[int, int]:
    factors: Dict[int, int] = {}
    d, m = 2, n
    while d * d <= m:
        while m % d == 0:
            factors[d] = factors.get(d, 0) + 1
            m //= d
        d += 1 if d == 2 else 2
    if m > 1:
        factors[m] = factors.get(m, 0) + 1
    return factors

def lcm(a: int, b: int) -> int:
    return a // gcd(a, b) * b

def carmichael_lambda_squarefree(n: int) -> int:
    """lambda(n) = lcm of (p-1) over primes p | n (n assumed squarefree)."""
    primes: List[int] = list(factorize(n).keys())
    return reduce(lcm, (p - 1 for p in primes), 1)

def is_carmichael_via_lambda(n: int) -> bool:
    """n is Carmichael iff lambda(n) | (n-1) and n is squarefree composite."""
    factors = factorize(n)
    if len(factors) < 2 or any(e > 1 for e in factors.values()):
        return False
    return (n - 1) % carmichael_lambda_squarefree(n) == 0
