from typing import Dict

def factorize(n: int) -> Dict[int, int]:
    factors: Dict[int, int] = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1
    if n > 1:
        factors[n] = factors.get(n, 0) + 1
    return factors

def ilog(p: int, m: int) -> int:
    if m < 1:
        return 0
    e = 0
    while p ** (e + 1) <= m:
        e += 1
    return e

def corrected_formula(k: int) -> int:
    n = k + 1
    best = 1
    for p, a in factorize(n).items():
        m = n // (p ** a)
        best = max(best, p ** max(0, a - ilog(p, m)))
    return best
