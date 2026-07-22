from typing import List
Matrix = List[List[float]]

def ratio_orbit(base_ratio: float, steps: int) -> List[float]:
    """Sidorenko ratios under iterated self-tensoring: R, R^2, R^4, ..., R^(2^steps).

    By spectral transfer the ratio is multiplicative, so self-tensoring squares it.
    The exponentially large tensor powers are NEVER materialized: the whole orbit is
    computed by repeated squaring of a single scalar, cost O(steps).
    """
    orbit: List[float] = [base_ratio]
    r = base_ratio
    for _ in range(steps):
        r = r * r
        orbit.append(r)
    return orbit

def fixed_point_class(base_ratio: float, tol: float = 1e-12) -> str:
    """Classify the limit of the orbit: 0 (deficit), 1 (extremal), or +inf (surplus)."""
    if abs(base_ratio - 1.0) <= tol:
        return "fixed point 1 (sharp / quasirandom)"
    if base_ratio < 1.0:
        return "attracted to 0 (violation compounds)"
    return "repelled to +infinity (surplus explodes)"
