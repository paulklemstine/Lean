from typing import Callable

def audit(invariant_value: complex, weighted_value: complex,
          factor: complex, tolerance: float = 1e-10) -> bool:
    if abs(invariant_value) <= tolerance:
        raise ValueError("choose a point where the product is nonzero")
    if abs(weighted_value - invariant_value) > tolerance:
        return False
    return abs(factor - 1) <= tolerance
