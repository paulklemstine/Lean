from __future__ import annotations
from fractions import Fraction
from math import comb

def order_three_surplus(q: int) -> Fraction:
    """Closed-form, always-positive order-three slowness surplus.

    Collinear triples are avoided by q^2-2q lines, generic triples by (q-1)^2;
    their weighted mean equals the uniform value, and the convexity of
    t -> 1/(1-t) (Jensen) makes the plane's contribution strictly larger.
    """
    n: int = q * q + q + 1
    p_coll = Fraction(q * q - 2 * q, n)
    p_gen = Fraction((q - 1) ** 2, n)
    p_u = Fraction(comb(n - 3, q + 1), comb(n, q + 1))
    n_coll = n * comb(q + 1, 3)
    n_gen = comb(n, 3) - n_coll
    plane = n_coll / (1 - p_coll) + n_gen / (1 - p_gen)
    unif = Fraction(comb(n, 3)) / (1 - p_u)
    return plane - unif
