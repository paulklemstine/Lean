from __future__ import annotations
from typing import Sequence, Tuple

ORDER = 16

def series_mul(a: Tuple[float, ...], b: Tuple[float, ...]) -> Tuple[float, ...]:
    out = [0.0] * ORDER
    for i, x in enumerate(a):
        if x:
            for j, y in enumerate(b):
                if i + j < ORDER:
                    out[i + j] += x * y
    return tuple(out)

def valuation(a: Tuple[float, ...], tol: float = 1e-12) -> int:
    for i, c in enumerate(a):
        if abs(c) > tol:
            return i
    return ORDER

def visibility_level(amplitude_k: Tuple[float, ...],
                     total_weight: Tuple[float, ...],
                     max_depth: int) -> int:
    """Least eps-order at which branch k becomes visible (max_depth+1 => hidden)."""
    z0 = total_weight[0]
    if abs(z0) < 1e-15:
        raise ValueError("total weight not appreciable")
    # w_k = alpha_k^2 / Z; its valuation equals val(alpha_k^2) since Z is appreciable.
    v = valuation(series_mul(amplitude_k, amplitude_k))
    return v if v <= max_depth else max_depth + 1
