import itertools
from typing import Dict, Iterable, List, Sequence


def prime_factors(n: int) -> List[int]:
    factors: List[int] = []
    d, m = 2, n
    while d * d <= m:
        if m % d == 0:
            factors.append(d)
            while m % d == 0:
                m //= d
        d += 1 if d == 2 else 2
    if m > 1:
        factors.append(m)
    return factors


def is_squarefree(n: int) -> bool:
    m, d = n, 2
    while d * d <= m:
        if m % (d * d) == 0:
            return False
        if m % d == 0:
            m //= d
        else:
            d += 1 if d == 2 else 2
    return n >= 1


def f_value(n: int, signs: Dict[int, int]) -> int:
    if not is_squarefree(n):
        return 0
    prod = 1
    for p in prime_factors(n):
        prod *= signs[p]
    return prod


def exact_variance(A: Sequence[int]) -> float:
    """Exact variance of sum_{n in A} f(n) over all 2^{|P|} sign patterns."""
    primes = sorted({p for n in A for p in prime_factors(n)})
    total = total_sq = 0.0
    count = 0
    for pattern in itertools.product((-1, 1), repeat=len(primes)):
        signs = dict(zip(primes, pattern))
        s = sum(f_value(n, signs) for n in A)
        total += s
        total_sq += s * s
        count += 1
    mean = total / count
    return total_sq / count - mean * mean
