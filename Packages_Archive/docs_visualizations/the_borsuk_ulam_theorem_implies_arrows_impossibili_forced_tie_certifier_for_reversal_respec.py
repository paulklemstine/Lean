from typing import Callable, Optional, Tuple
import math

PI = math.pi
TWO_PI = 2.0 * math.pi

def certify_forced_tie(
    swf: Callable[[float], float], samples: int = 4096, tol: float = 1e-6
) -> Optional[Tuple[float, float]]:
    """Forced-tie certifier for a continuous reversal-respecting SWF.

    Confirms reversal symmetry swf(theta+pi) = -swf(theta) on a sample grid, then
    returns a profile theta where the social margin (numerically) vanishes,
    certifying the impossibility theorem. Returns None if reversal symmetry fails
    (so the theorem's hypothesis is not met)."""
    for k in range(samples):
        t = TWO_PI * k / samples
        if abs(swf(t + PI) + swf(t)) > 1e-6:
            return None  # not reversal-respecting; hypothesis unmet
    g = lambda t: swf(t) - swf(t + PI)
    a, b = 0.0, PI
    ga = g(a)
    for _ in range(200):
        m = 0.5 * (a + b)
        gm = g(m)
        if abs(gm) <= tol or 0.5 * (b - a) <= tol:
            return m, swf(m)
        if ga * gm <= 0:
            b = m
        else:
            a, ga = m, gm
    m = 0.5 * (a + b)
    return m, swf(m)
