import math
from typing import Callable, List, Sequence

def fisher_via_kl_curvature(p_of: Callable[[float], List[float]], theta: float,
                            h: float = 1e-4) -> float:
    """Estimate the (scalar) Fisher information as the curvature of KL.

    Numerically computes d^2/dt^2 KL(p(theta) || p(t)) at t = theta, which by the
    two-forms identity equals the Fisher information G(theta). Complexity O(n) per
    KL evaluation; three evaluations for the central second difference.
    """
    p0 = p_of(theta)
    def kl_to(t: float) -> float:
        pt = p_of(t)
        return sum(a*math.log(a/b) for a, b in zip(p0, pt))
    return (kl_to(theta+h) - 2.0*kl_to(theta) + kl_to(theta-h))/(h*h)
