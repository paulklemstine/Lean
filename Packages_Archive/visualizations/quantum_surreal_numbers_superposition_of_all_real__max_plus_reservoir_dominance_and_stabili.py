from __future__ import annotations
from typing import Sequence

def select(reservoir: float, visible: Sequence[float], penalty: float) -> tuple[float, str, float]:
    if penalty >= 0:
        raise ValueError("penalty must be negative")
    best = max((x + penalty for x in visible), default=float("-inf"))
    margin = reservoir - best
    return (reservoir, "reservoir", margin) if margin >= 0 else (best, "visible", margin)

print(select(3.0, [2.0, 4.0, 1.0], -2.0))
print(select(3.0, [2.0, 6.5, 1.0], -2.0))
