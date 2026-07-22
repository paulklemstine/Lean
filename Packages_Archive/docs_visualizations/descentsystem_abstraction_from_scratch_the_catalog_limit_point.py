from typing import Callable, Hashable

State = Hashable

def limit_point(step: Callable[[State], State],
                energy: Callable[[State], int],
                s: State) -> State:
    """Return step^[energy(s)](s); always a fixed point (descent engine theorem)."""
    for _ in range(energy(s)):
        t = step(s)
        if t == s:
            return s
        s = t
    return s