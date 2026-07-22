from __future__ import annotations
from typing import Callable, Optional

def monitor(step: Callable[[int], Optional[int]], start: int, horizon: int) -> str:
    state = start
    for n in range(horizon + 1):
        nxt = step(state)
        if nxt is None:
            return f"halt observed at stage {n}"
        if n < horizon:
            state = nxt
    return f"survived {horizon} steps; no infinite claim made"

def delayed(delay: int) -> Callable[[int], Optional[int]]:
    return lambda n: None if n >= delay else n + 1

if __name__ == "__main__":
    for bound in (5, 10, 25):
        print(monitor(delayed(11), 0, bound))
