from typing import List

def boundary_crossings(a: float, b: float, x0: float, y0: float,
                       eps: float = 1e-15) -> List[float]:
    """Return the parameters t at which the straight coordinate line
    gamma(t) = (x0 + t*a, y0 + t*b) meets the Split-Geometry phase boundary
    {x^2 = y^2}. These are the roots of the quadratic

        (a^2 - b^2) t^2 + 2 (x0*a - y0*b) t + (x0^2 - y0^2) = 0.

    When a^2 != b^2 (line not parallel to a diagonal) there are at most two
    roots, realizing the crossing-rigidity theorem."""
    A = a * a - b * b
    B = 2.0 * (x0 * a - y0 * b)
    C = x0 * x0 - y0 * y0
    if abs(A) < eps:                 # degenerate: parallel to a diagonal
        if abs(B) < eps:
            return []                # no isolated crossing
        return [-C / B]              # linear equation, single crossing
    disc = B * B - 4.0 * A * C
    if disc < 0.0:
        return []                    # line stays in one phase
    root = disc ** 0.5
    r1 = (-B + root) / (2.0 * A)
    r2 = (-B - root) / (2.0 * A)
    return sorted({r1, r2})
