from typing import Dict

def prime_factorization(n: int) -> Dict[int, int]:
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

def totient(n: int) -> int:
    if n == 1:
        return 1
    result = 1
    for p, e in prime_factorization(n).items():
        result *= p ** (e - 1) * (p - 1)
    return result

def certify_collision(n: int) -> bool:
    return totient(n) == totient(n + 1)
