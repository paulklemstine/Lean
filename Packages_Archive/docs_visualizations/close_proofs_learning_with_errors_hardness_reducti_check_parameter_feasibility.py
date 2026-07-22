from __future__ import annotations
import math

def check_parameter_feasibility(alpha: float, q: int, n: int) -> bool:
    """Regev feasibility constraint linking noise rate, modulus,
    and dimension: alpha * q >= 2 * sqrt(n)."""
    return alpha * q >= 2.0 * math.sqrt(n)
