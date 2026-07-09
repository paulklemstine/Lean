from math import gcd
from typing import Tuple

Point = Tuple[int, int]

def g_smul(x: int, p: Point, n: int) -> Point:
    return ((x * p[0]) % n, (x * p[1]) % n)

def weil_pairing(p: Point, q: Point, n: int) -> int:
    a, b = p; c, d = q
    return (a * d - b * c) % n

def mov_recover(g: Point, h: Point, X: Point, n: int) -> int:
    """Recover x with X = x*g by transporting the discrete log into mu_n.

    Pairs against an INDEPENDENT point h (the determinant pairing is alternating,
    so e(g, g) is trivial). With base = e(g, h) and target = e(X, h) = base * x
    mod n, the secret is recovered modulo ord(base) = n / gcd(base, n).
    """
    base = weil_pairing(g, h, n)
    target = weil_pairing(X, h, n)
    order = n // gcd(base, n) if base != 0 else 1
    for k in range(order):
        if (base * k) % n == target:
            return k
    return -1
