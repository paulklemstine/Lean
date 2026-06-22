from __future__ import annotations
from typing import Callable, Hashable, List, Set, Tuple

State = Hashable

def reachable_fixed_point(
    k: int,
    states: Tuple[State, ...],
    q0: State,
    step: Callable[[State, int], State],
) -> Tuple[Set[State], int]:
    """Compute reachSet(M) = reach(|Q|) by breadth-first expansion.

    Returns (reachable_states, rounds_used). Terminates in <= |Q| rounds
    by the pigeonhole bound (Theorem 10, exists_reach_stable)."""
    current: Set[State] = {q0}
    rounds = 0
    for _ in range(len(states)):
        nxt: Set[State] = set(current)
        for q in current:
            for c in range(k):
                nxt.add(step(q, c))
        rounds += 1
        if nxt == current:          # reach(n+1) == reach(n): fixed point
            return current, rounds - 1
        current = nxt
    return current, rounds
