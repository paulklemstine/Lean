from __future__ import annotations
from typing import Sequence, Tuple

def tsha(h: Sequence[float], m: Sequence[float]) -> float:
    """Single-key tropical hash min_i (m_i + h_i) in O(k)."""
    return min(mi + hi for mi, hi in zip(m, h))

def tsha2(h: Sequence[float], hp: Sequence[float],
          m: Sequence[float]) -> Tuple[float, float]:
    """Two-key tropical hash, O(k)."""
    return tsha(h, m), tsha(hp, m)
