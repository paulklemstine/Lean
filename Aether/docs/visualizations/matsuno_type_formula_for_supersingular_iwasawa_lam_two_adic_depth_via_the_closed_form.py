from __future__ import annotations


def v2(n: int) -> int:
    """2-adic valuation of a positive integer."""
    if n <= 0:
        raise ValueError("v2 requires a positive integer")
    c = 0
    while n % 2 == 0:
        n //= 2
        c += 1
    return c


def two_adic_depth(ell: int) -> int:
    """Compute n_ell = v2(ell-1) + v2(ell+1) - 3 for odd ell >= 3."""
    if ell % 2 == 0 or ell < 3:
        raise ValueError("depth closed form requires odd ell >= 3")
    return v2(ell - 1) + v2(ell + 1) - 3
