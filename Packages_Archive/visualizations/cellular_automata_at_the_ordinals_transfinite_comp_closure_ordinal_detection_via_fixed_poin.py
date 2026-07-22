from typing import Set

def spread(config: Set[int]) -> Set[int]:
    return {0} | {n + 1 for n in config}

def closure_ordinal_is_omega(bound: int) -> bool:
    """Detect that the closure ordinal of the spreading automaton is omega.

    Verifies (up to cells < bound) that: (a) no finite stage is a fixed point
    (each strictly grows), and (b) the union of all finite stages IS a fixed
    point equal to the full line.  Returns True iff both hold, i.e. the least
    fixed point is first reached at the limit stage omega.

    Complexity: O(bound^2) set operations.
    """
    prev: Set[int] = set()
    stages = [prev]
    for _ in range(bound):
        prev = spread(prev)
        stages.append(prev)
    # (a) strict growth at every finite step
    finite_strict = all(
        {c for c in stages[i] if c < bound} != {c for c in stages[i + 1] if c < bound}
        for i in range(bound)
    )
    # (b) union at omega is the full line and a fixed point
    omega = set()
    for s in stages:
        omega |= s
    omega = {c for c in omega if c < bound}
    full = set(range(bound))
    omega_fixed = omega == full == {c for c in spread(full) if c < bound}
    return finite_strict and omega_fixed
