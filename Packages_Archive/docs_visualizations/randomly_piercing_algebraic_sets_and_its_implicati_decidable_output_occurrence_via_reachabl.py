from __future__ import annotations
from typing import Callable, Hashable, Tuple

State = Hashable

def output_occurs(
    k: int,
    states: Tuple[State, ...],
    q0: State,
    step: Callable[[State, int], State],
    out: Callable[[State], object],
    target: object,
) -> bool:
    """Decide  exists w. eval(M, w) == target  (Theorem 14, decidableOccurs).

    Sound because eval ranges exactly over out(reachSet); complete because the
    reachable set is computed to a fixed point."""
    current = {q0}
    for _ in range(len(states)):
        nxt = set(current)
        for q in current:
            for c in range(k):
                nxt.add(step(q, c))
        if nxt == current:
            break
        current = nxt
    return any(out(q) == target for q in current)
