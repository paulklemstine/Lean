from math import isqrt
from typing import List

def divisors(n: int) -> List[int]:
    s, l = [], []
    for i in range(1, isqrt(n) + 1):
        if n % i == 0:
            s.append(i)
            if i != n // i:
                l.append(n // i)
    return s + l[::-1]

def sigma(n: int) -> int:
    return sum(divisors(n))

def monotonicity_certificate(d: int, n: int) -> str:
    """Certify A(d) (<=/<) A(n) for d | n using only integer arithmetic.

    Relies on sigma_one_cross_le / sigma_one_cross_lt: for d | n,
    sigma(d)*n <= sigma(n)*d, strict when d < n.
    """
    if n % d != 0:
        return f"{d} does not divide {n}"
    lhs, rhs = sigma(d) * n, sigma(n) * d
    if d < n:
        ok = lhs < rhs
        return f"A({d}) < A({n}): sigma(d)*n={lhs} < sigma(n)*d={rhs} -> {ok}"
    ok = lhs <= rhs
    return f"A({d}) <= A({n}): sigma(d)*n={lhs} <= sigma(n)*d={rhs} -> {ok}"
