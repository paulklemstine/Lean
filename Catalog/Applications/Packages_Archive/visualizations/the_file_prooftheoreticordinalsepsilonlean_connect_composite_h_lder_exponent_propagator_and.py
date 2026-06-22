from typing import List, Sequence, Tuple

def compose_exponents(forward: Sequence[float], inverse: Sequence[float]) -> Tuple[float, float]:
    """Theorem 7.1: composite forward Holder exponent = product of forward exponents;
    composite inverse exponent = product of inverse exponents."""
    fwd, inv = 1.0, 1.0
    for r in forward:
        fwd *= r
    for r in inverse:
        inv *= r
    return fwd, inv

def dimension_window(dim_source: float, fwd_exp: float, inv_exp: float) -> Tuple[float, float]:
    """Two-sided dimension window for the composite image (Theorem 7.1):
        lower = dim_source * inv_exp,   upper = dim_source / fwd_exp.
    With all exponents = 1 the window collapses to {dim_source} (Theorem 6.1)."""
    return dim_source * inv_exp, dim_source / fwd_exp
