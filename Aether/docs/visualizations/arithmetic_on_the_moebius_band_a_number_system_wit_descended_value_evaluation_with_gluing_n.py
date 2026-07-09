from typing import Tuple

def moebius_value(x: float, y: float, normalize: bool = True) -> float:
    """Evaluate the descended value map on a representative (x, y).

    If normalize is True, boundary representatives are first mapped to a
    canonical fibre via the gluing (0, y) ~ (1, -y); the result is unchanged
    because phi is constant on classes.
    """
    if normalize:
        if x == 0.0:
            x, y = 1.0, -y
    return y * (2.0 * x - 1.0)

def check_well_defined(y: float) -> bool:
    """Confirm phi(0, y) == phi(1, -y) for a given height."""
    return abs(moebius_value(0.0, y, normalize=False)
               - moebius_value(1.0, -y, normalize=False)) < 1e-12
