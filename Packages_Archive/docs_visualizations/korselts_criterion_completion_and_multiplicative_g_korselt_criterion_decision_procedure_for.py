from math import gcd
from typing import Dict

def factorize(n: int) -> Dict[int, int]:
    """Prime factorization of n as {prime: exponent}."""
    factors: Dict[int, int] = {}
    d, m = 2, n
    while d * d <= m:
        while m % d == 0:
            factors[d] = factors.get(d, 0) + 1
            m //= d
        d += 1
    if m > 1:
        factors[m] = factors.get(m, 0) + 1
    return factors

def is_korselt(n: int) -> bool:
    """Decide Korselt's criterion: n squarefree and (p-1) | (n-1) for all p | n.
    Returns True iff n is a Carmichael number."""
    f = factorize(n)
    if n <= 1 or f == {n: 1}:          # prime or unit: not a Carmichael number
        return False
    if any(e > 1 for e in f.values()): # not squarefree
        return False
    return all((n - 1) % (p - 1) == 0 for p in f)
