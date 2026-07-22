from typing import Tuple

Point = Tuple[int, int]  # an element of (Z/nZ)^2

def weil_pairing(p: Point, q: Point, n: int) -> int:
    """Evaluate the Weil determinant pairing e(p, q) on E[n] = (Z/nZ)^2.

    Returns the exponent of a fixed primitive n-th root of unity zeta, i.e.
    e(p, q) = zeta ^ (a*d - b*c) is represented by (a*d - b*c) mod n.
    Bilinear in each argument and alternating: e(p, p) = 0.
    """
    a, b = p
    c, d = q
    return (a * d - b * c) % n
