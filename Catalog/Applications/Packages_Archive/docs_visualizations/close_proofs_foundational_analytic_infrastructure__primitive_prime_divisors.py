from typing import List

def fib(k: int) -> int:
    a, b = 0, 1
    for _ in range(k):
        a, b = b, a + b
    return a

def prime_factors(n: int) -> List[int]:
    factors: List[int] = []
    d, m = 2, n
    while d * d <= m:
        if m % d == 0:
            factors.append(d)
            while m % d == 0:
                m //= d
        d += 1
    if m > 1:
        factors.append(m)
    return factors

def entry_point(p: int) -> int:
    if p == 1:
        return 1
    a, b = 0, 1
    k = 1
    while True:
        if b % p == 0:
            return k
        a, b = b, (a + b) % p
        k += 1

def primitive_prime_divisors(n: int) -> List[int]:
    """Primes p with entry_point(p) == n among the prime factors of F_n.

    By the characterization Prim(p, n) <=> entry_point(p) == n, this is exact."""
    fn = fib(n)
    if fn <= 1:
        return []
    return [p for p in prime_factors(fn) if entry_point(p) == n]
