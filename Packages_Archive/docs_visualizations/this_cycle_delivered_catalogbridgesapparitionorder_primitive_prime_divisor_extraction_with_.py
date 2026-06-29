from __future__ import annotations
from typing import Dict, List, Optional


def factorize(n: int) -> Dict[int, int]:
    factors: Dict[int, int] = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1 if d == 2 else 2
    if n > 1:
        factors[n] = factors.get(n, 0) + 1
    return factors


def gcd(a: int, b: int) -> int:
    while b:
        a, b = b, a % b
    return abs(a)


def mult_order(b: int, p: int) -> Optional[int]:
    b %= p
    if gcd(b, p) != 1:
        return None
    order = p - 1
    for q in factorize(p - 1):
        while order % q == 0 and pow(b, order // q, p) == 1:
            order //= q
    return order


def primitive_divisors(b: int, n: int) -> List[int]:
    """
    Primitive prime divisors of b**n - 1 : those primes p whose entry point
    is exactly n. By Fermat descent every such p satisfies p = 1 (mod n),
    a constraint that can prune a dedicated search. Here we read them off
    the factorization and confirm the congruence.
    """
    result: List[int] = []
    for p in sorted(factorize(b ** n - 1)):
        if p == b or b % p == 0:
            continue
        if mult_order(b, p) == n:        # primitive  <=>  entry point = n
            assert p % n == 1            # Corollary: p = 1 (mod n)
            result.append(p)
    return result
