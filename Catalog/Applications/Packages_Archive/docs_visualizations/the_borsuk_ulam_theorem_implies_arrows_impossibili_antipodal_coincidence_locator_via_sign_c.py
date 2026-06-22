from typing import Callable, Tuple
import math

PI = math.pi

def find_antipodal_coincidence(
    f: Callable[[float], float], tol: float = 1e-12, max_iter: int = 200
) -> Tuple[float, float]:
    """Bisection locator for a Borsuk-Ulam antipodal coincidence on the circle.

    Given a continuous 2*pi-periodic f, returns (theta, residual) with
    |f(theta) - f(theta + pi)| <= residual ~ tol. Uses g(theta) = f(theta) -
    f(theta + pi), which satisfies g(pi) = -g(0), guaranteeing a sign change."""
    g = lambda t: f(t) - f(t + PI)
    a, b = 0.0, PI
    ga, gb = g(a), g(b)
    if abs(ga) <= tol:
        return a, abs(ga)
    if abs(gb) <= tol:
        return b, abs(gb)
    if ga * gb > 0:
        raise ValueError("no sign change; f may not be 2*pi-periodic")
    for _ in range(max_iter):
        m = 0.5 * (a + b)
        gm = g(m)
        if abs(gm) <= tol or 0.5 * (b - a) <= tol:
            return m, abs(gm)
        if ga * gm <= 0:
            b, gb = m, gm
        else:
            a, ga = m, gm
    m = 0.5 * (a + b)
    return m, abs(g(m))
