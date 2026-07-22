from typing import Tuple

def balla_ceiling(d: int) -> Tuple[int, str]:
    """Return (max(28, 2(d-1)), regime) for the arccos(1/3) bound."""
    linear = 2 * (d - 1)
    bound = max(28, linear)
    regime = 'plateau (28)' if linear <= 28 else 'linear 2(d-1)'
    return bound, regime
