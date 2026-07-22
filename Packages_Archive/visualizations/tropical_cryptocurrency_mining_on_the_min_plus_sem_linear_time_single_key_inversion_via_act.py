from __future__ import annotations
from typing import List, Optional, Sequence

def invert_single(h: Sequence[float], y: float,
                  lower: Sequence[float],
                  upper: Sequence[float]) -> Optional[List[float]]:
    """Find m with min_i(m_i+h_i)=y and lower_i<=m_i<=upper_i, or None."""
    k = len(h)
    active = [i for i in range(k) if lower[i] + h[i] <= y <= upper[i] + h[i]]
    if not active:
        return None
    if any(upper[i] + h[i] < y for i in range(k)):
        return None
    a = active[0]
    m = [0.0] * k
    m[a] = y - h[a]
    for i in range(k):
        if i == a:
            continue
        m[i] = min(max(y - h[i], lower[i]), upper[i])
    return m
