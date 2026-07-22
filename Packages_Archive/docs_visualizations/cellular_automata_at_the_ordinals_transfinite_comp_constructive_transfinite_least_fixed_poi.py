from typing import Callable, FrozenSet, List

Config = FrozenSet[int]

def transfinite_lfp_iteration(
    step: Callable[[Config], Config],
    ground: List[int],
    limit_rounds: int,
) -> Config:
    """Constructive least-fixed-point iteration for a monotone rule, following
    the successor/limit schema of transfinite ordinal computation, restricted
    to the finite ground set `ground`.

    Schema (Knaster-Tarski, constructive form):
      g(0)          = bottom (empty)
      g(beta+1)     = step(g(beta))                 [successor stage]
      g(limit)      = union of all earlier g(gamma) [limit stage / ITTM liminf]

    We iterate successors until a fixed point is reached, taking a union at the
    simulated limit stage.  For a monotone `step` on the finite lattice
    P(ground) this returns the least fixed point.

    Complexity: at most |ground| successor steps between limit stages; each
    step costs O(|ground|).
    """
    ground_set = frozenset(ground)
    current: Config = frozenset()
    for _ in range(limit_rounds):
        prev = current
        for _ in range(len(ground) + 1):
            nxt = step(current) & ground_set
            if nxt == current:
                break
            current = nxt
        # limit stage: union with everything so far (monotone => union of past)
        current = (current | prev) & ground_set
        if current == prev:
            break
    return current
