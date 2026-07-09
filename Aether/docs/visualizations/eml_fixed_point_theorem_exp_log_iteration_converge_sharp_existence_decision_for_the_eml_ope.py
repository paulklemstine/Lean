from __future__ import annotations
import math

def eml_existence_decision(a: float, c: float) -> str:
    """Decide existence of a fixed point of f(x)=exp(a)*log(x+c) (b=1) on the
    natural domain x + c > 0, using the SHARP law c >= exp(a)*(1 - a).

    Returns 'supercritical' (exists, with strict contraction available when
    c > threshold), 'critical' (a single neutral fixed point, f'=1), or
    'subcritical' (provably no fixed point).
    """
    threshold = math.exp(a) * (1.0 - a)
    if c < threshold:
        return "subcritical"
    if math.isclose(c, threshold, rel_tol=1e-15, abs_tol=1e-15):
        return "critical"
    return "supercritical"
