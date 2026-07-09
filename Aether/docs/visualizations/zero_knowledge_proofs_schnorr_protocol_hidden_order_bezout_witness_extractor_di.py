from typing import Tuple

def ext_gcd(a: int, b: int) -> Tuple[int, int, int]:
    """Extended Euclid: returns (g, x, y) with a*x + b*y = g = gcd(a, b)."""
    if b == 0:
        return (a, 1, 0)
    g, x1, y1 = ext_gcd(b, a % b)
    return (g, y1, x1 - (a // b) * y1)

def bezout_extract(s1: int, s2: int, c1: int, c2: int,
                   u: int, ell: int) -> int:
    """Hidden-order special-soundness extractor (no division).

    Inputs: two accepting integer-challenge transcripts sharing a commitment,
    plus a special preimage with phi(u) = ell * Y and gcd(ell, c1 - c2) = 1.
    Returns an integer x with phi(x) = Y, computed as
        x = a*u + b*(s1 - s2),   where  a*ell + b*(c1 - c2) = 1
    via the extended Euclidean algorithm. No inverse of (c1 - c2) is formed,
    so this works in groups of unknown order (RSA, class groups).
    """
    d = c1 - c2
    g, a, b = ext_gcd(ell, d)
    if g != 1:
        raise ValueError("ell must be coprime to (c1 - c2)")
    return a * u + b * (s1 - s2)
