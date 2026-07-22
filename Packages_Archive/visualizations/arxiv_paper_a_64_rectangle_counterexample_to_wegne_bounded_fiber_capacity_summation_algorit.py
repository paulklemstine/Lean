from __future__ import annotations
from collections.abc import Hashable, Mapping
from typing import TypeVar
Q = TypeVar("Q", bound=Hashable)

def capacity_bound(capacities: Mapping[Q, int]) -> int:
    if any(c < 0 for c in capacities.values()): raise ValueError("negative capacity")
    return sum(capacities.values())

if __name__ == "__main__":
    cells = {(p, q): 1 for p in range(4) for q in range(4)}
    print(capacity_bound(cells))
