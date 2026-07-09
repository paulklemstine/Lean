from __future__ import annotations
from typing import Callable, Hashable, Sequence, Tuple

def task_solvable(group: Sequence[Hashable],
                  points: Sequence[Hashable],
                  act: Callable[[Hashable, Hashable], Hashable]
                  ) -> Tuple[bool, int, int]:
    """Decide the symmetric distinguishing task via the dichotomy.

    An invariant injective function exists iff the action is trivial, iff
    every orbit is a singleton.  Returns (solvable, n_orbits, n_points).
    Complexity: O(|group| * |points|).
    """
    seen: set = set()
    n_orbits = 0
    for x in points:
        if x in seen:
            continue
        orb = frozenset(act(g, x) for g in group)
        seen |= orb
        n_orbits += 1
    n_points = len(list(points))
    return (n_orbits == n_points, n_orbits, n_points)
