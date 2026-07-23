from __future__ import annotations
from typing import Callable, Sequence

SetR = Callable[[float], bool]


def consensus_open_at(U: SetR, x: float, observers: Sequence[Callable[[SetR, float], bool]]) -> bool:
    """A set is consensus-open at x iff every observer sees it open at x."""
    return all(obs(U, x) for obs in observers)
