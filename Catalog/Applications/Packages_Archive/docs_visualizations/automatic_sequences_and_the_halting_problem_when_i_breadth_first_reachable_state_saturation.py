from typing import Callable, Hashable, Set, Tuple

def expand(k: int, step: Callable[[Hashable, int], Hashable],
           s: Set[Hashable]) -> Set[Hashable]:
    """Add every state one transition away from the current set s."""
    out: Set[Hashable] = set(s)
    for q in s:
        for c in range(k):
            out.add(step(q, c))
    return out

def reachable_set(k: int, q0: Hashable,
                  step: Callable[[Hashable, int], Hashable]
                  ) -> Tuple[Set[Hashable], int]:
    """Breadth-first reachable-state computation.

    Returns (reachable_states, rounds_to_stabilize); rounds <= |Q|.
    """
    current: Set[Hashable] = {q0}
    rounds = 0
    while True:
        nxt = expand(k, step, current)
        rounds += 1
        if nxt == current:
            return current, rounds - 1
        current = nxt
