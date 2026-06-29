from __future__ import annotations
from itertools import product
from typing import Tuple

def mu(m: int) -> int:
    if m == 1: return 1
    res, d, x = 1, 2, m
    while d * d <= x:
        if x % d == 0:
            e = 0
            while x % d == 0: x //= d; e += 1
            if e > 1: return 0
            res = -res
        d += 1
    if x > 1: res = -res
    return res

def num_irreducible_monic(n: int, q: int) -> int:
    return sum(mu(d) * q ** (n // d) for d in range(1, n + 1)
               if n % d == 0) // n

def gl_order(n: int, q: int) -> int:
    prod = 1
    for k in range(n): prod *= (q ** n - q ** k)
    return prod

def closed_form_density(n: int, q: int) -> float:
    irr = num_irreducible_monic(n, q)
    certified = irr * gl_order(n, q) // (q ** n - 1)
    return certified / gl_order(n, q)

# Exact enumeration (requires verify_certificate from the verification
# algorithm) for small (n, q):
def exact_density(n: int, p: int, verify) -> Tuple[int, int]:
    total = certified = 0
    for ent in product(range(p), repeat=n * n):
        M = tuple(tuple(ent[i * n + j] for j in range(n))
                  for i in range(n))
        if not verify.__globals__['det_mod'](M, p): continue
        total += 1
        if verify(M, p): certified += 1
    return certified, total
