from typing import Dict

def is_prime(n: int) -> bool:
    if n < 2: return False
    if n % 2 == 0: return n == 2
    d = 3
    while d * d <= n:
        if n % d == 0: return False
        d += 2
    return True

def factorize(n: int) -> Dict[int, int]:
    factors: Dict[int, int] = {}
    m, d = n, 2
    while d * d <= m:
        while m % d == 0:
            factors[d] = factors.get(d, 0) + 1
            m //= d
        d += 1 if d == 2 else 2
    if m > 1:
        factors[m] = factors.get(m, 0) + 1
    return factors

def is_korselt(n: int) -> bool:
    """Decide whether n is a Carmichael number via Korselt's criterion."""
    if n <= 1 or is_prime(n):
        return False
    factors = factorize(n)
    if any(e > 1 for e in factors.values()):
        return False
    return all((n - 1) % (p - 1) == 0 for p in factors)
