from __future__ import annotations
from typing import Tuple

Vec3 = Tuple[int, int, int]


def circle(r: float) -> float:
    """Class of r in R/Z, normalized to [0, 1)."""
    return r - float(int(r // 1))


def geodesic_closure_check(n: Vec3, samples: int = 64, eps: float = 1e-12
                           ) -> Tuple[bool, bool]:
    """Return (is_closed, is_nonconstant) for the integer geodesic gamma_n.

    is_closed:      gamma_n(t+1) == gamma_n(t) at all sample times (period one).
    is_nonconstant: the half-period point differs from the start (genuine wrap).
    Complexity: O(samples).
    """
    def g(t: float) -> Tuple[float, float, float]:
        return (circle(t * n[0]), circle(t * n[1]), circle(t * n[2]))

    def eq(a, b) -> bool:
        return all(min(abs(x - y), 1 - abs(x - y)) < eps for x, y in zip(a, b))

    is_closed = all(eq(g(k / samples), g(k / samples + 1.0))
                    for k in range(samples))
    is_nonconstant = False
    for i, ni in enumerate(n):
        if ni != 0:
            is_nonconstant = not eq(g(1.0 / (2.0 * ni)), g(0.0))
            break
    return is_closed, is_nonconstant
