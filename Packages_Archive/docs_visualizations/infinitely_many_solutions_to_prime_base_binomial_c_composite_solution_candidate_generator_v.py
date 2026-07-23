from math import comb
from typing import Dict, List, Tuple

def factorize(n: int, bound: int = 10_000_000) -> Dict[int, int]:
    n, f, d = abs(n), {}, 2
    while d <= bound and d * d <= n:
        while n % d == 0:
            f[d] = f.get(d, 0) + 1
            n //= d
        d += 1 if d == 2 else 2
    if n > 1:
        f[n] = f.get(n, 0) + 1
    return f

def digit_sum(n: int, q: int) -> int:
    s = 0
    while n > 0:
        s += n % q
        n //= q
    return s

def A_value(q: int, t: int) -> int:
    return comb(q ** (t + 1), q ** t) - q ** (q ** t)

def composite_candidates(q: int, t: int) -> List[Tuple[int, int]]:
    """Primes p != q dividing A_t that clear the digit-sum gate, with n = q^t p."""
    residual = A_value(q, t) // q
    out: List[Tuple[int, int]] = []
    for p in factorize(residual):
        if p != q and digit_sum((q - 1) * p, q) >= (q - 1) * t:
            out.append((p, q ** t * p))
    return out
