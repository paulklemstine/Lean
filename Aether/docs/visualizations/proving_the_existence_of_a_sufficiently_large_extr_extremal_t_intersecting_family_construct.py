from __future__ import annotations
from itertools import permutations
from math import factorial
from typing import List, Tuple

Perm = Tuple[int, ...]

def prefix_stabilizer(t: int, m: int) -> List[Perm]:
    """The t-intersecting family of size m! = (n-t)! fixing the first t points."""
    family = [tuple(range(t)) + tail for tail in permutations(range(t, t + m))]
    assert len(family) == factorial(m)
    return family
