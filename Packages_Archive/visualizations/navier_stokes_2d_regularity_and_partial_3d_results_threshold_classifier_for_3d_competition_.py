from typing import Tuple

def classify_competition(a: float, c: float, z0: float
                         ) -> Tuple[str, float]:
    """Classify a 3D competition trajectory Z' <= -a Z + C Z^2.

    Returns a (status, value) pair where status is one of
    'global', 'global_conditional', 'finite_lifespan'.
    """
    threshold: float = a / c
    if z0 < threshold:
        return ('global', z0)
    if z0 == threshold:
        return ('global_conditional', z0)
    lifespan: float = 1.0 / (2.0 * c * z0 ** 2)
    return ('finite_lifespan', lifespan)
