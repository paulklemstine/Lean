from __future__ import annotations


def first_moment(n: int, k: int, m: int, q: int = 2) -> int:
    """Exact annealed first moment q^n * ((nq)^k - (n(q-1))^k)^m.

    Uses Python big integers, so the result is exact for all inputs.
    """
    s: int = (n * q) ** k - (n * (q - 1)) ** k
    return (q ** n) * s ** m
