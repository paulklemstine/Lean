from __future__ import annotations
from typing import Tuple


def cycle_max_density(k: int) -> Tuple[float, str]:
    """Return (m_2(C_k), maximizer) by enumerating subgraph shapes."""
    best: float = (k - 1) / (k - 2)
    argmax: str = "whole cycle"
    for v in range(3, k + 1):
        for c in range(1, v):
            e: int = v - c
            if e < 1:
                continue
            d: float = (e - 1) / (v - 2)
            if d > best:
                best, argmax = d, f"forest v={v}, {c} paths"
    return best, argmax
