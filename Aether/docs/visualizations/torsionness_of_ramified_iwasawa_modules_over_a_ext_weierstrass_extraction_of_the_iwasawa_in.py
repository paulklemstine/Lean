from typing import List, Tuple

Poly = List[int]

def p_val(x: int, p: int, cap: int) -> int:
    """p-adic valuation of x capped at `cap` (0 -> cap)."""
    if x % (p ** cap) == 0:
        return cap
    v = 0
    while x % p == 0:
        x //= p
        v += 1
    return v

def weierstrass_invariants(coeffs: Poly, p: int, cap: int) -> Tuple[int, int]:
    """Given g = sum a_i T^i in Z_p[[T]] (low-degree-first, precision p^cap),
    return (mu, lambda) where g = p^mu * unit * P, P distinguished of degree lambda.
        mu     = min_i v_p(a_i)
        lambda = least i with v_p(a_i) == mu
    """
    vals = [p_val(c, p, cap) for c in coeffs]
    mu = min(vals)
    lam = next(i for i, v in enumerate(vals) if v == mu)
    return mu, lam
