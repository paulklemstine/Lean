from __future__ import annotations
from typing import Dict, Tuple

Key = Tuple[Tuple[int, float], ...]
TSeries = Dict[Key, float]

def agree_to_all_orders(a: TSeries, b: TSeries) -> bool:
    """
    Decide whether two transseries agree to all orders. By the asymptotic comparison
    theorem (agreeToAllOrders_iff_eq) this holds iff a == b, i.e. iff a - b is zero.
    """
    diff: TSeries = dict(a)
    for k, c in b.items():
        diff[k] = diff.get(k, 0.0) - c
    return all(c == 0.0 for c in diff.values())
