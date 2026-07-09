from math import gcd
from functools import reduce
from itertools import product
from typing import Sequence

def vec_gcd(w: Sequence[int]) -> int:
    return reduce(gcd, (abs(c) for c in w), 0)

def primitive_residue_density(n: int, k: int) -> float:
    """delta_k(n): fraction of residue vectors mod n that are primitive.
    Multiplicative in n; delta_k(p^e) = 1 - p^{-k}."""
    count = sum(1 for v in product(range(n), repeat=k) if gcd(vec_gcd(v), n) == 1)
    return count / (n ** k)

def primitive_density_via_factorization(n: int, k: int) -> float:
    """Closed form delta_k(n) = prod_{p | n} (1 - p^{-k}) using distinct prime factors."""
    result = 1.0
    m, p = n, 2
    seen: set[int] = set()
    while m > 1 and p * p <= m:
        if m % p == 0:
            seen.add(p)
            while m % p == 0:
                m //= p
        p += 1
    if m > 1:
        seen.add(m)
    for q in seen:
        result *= (1 - q ** (-k))
    return result
