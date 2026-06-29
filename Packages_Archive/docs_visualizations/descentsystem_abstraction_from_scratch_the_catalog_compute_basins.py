from typing import Callable, Dict, Hashable, List, Sequence

State = Hashable

def compute_basins(states: Sequence[State],
                   step: Callable[[State], State],
                   energy: Callable[[State], int]) -> Dict[State, List[State]]:
    """Bucket states by limit point. Keys are fixed points; values are basins."""
    def limit_point(s: State) -> State:
        for _ in range(energy(s)):
            t = step(s)
            if t == s:
                return s
            s = t
        return s
    buckets: Dict[State, List[State]] = {}
    for s in states:
        buckets.setdefault(limit_point(s), []).append(s)
    return buckets