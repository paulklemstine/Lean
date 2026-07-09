from itertools import combinations
from typing import FrozenSet, Iterable, Set

Vertex = FrozenSet[int]


def is_daisy_cube(family: Iterable[Vertex]) -> bool:
    """Recognize a daisy cube via the fixed-point/down-closure test.

    By the fixed-point characterization (isDaisy_iff_downClosure_le), a family
    is a daisy cube iff it is down-closed; it suffices to check that removing any
    single element of any member keeps the result inside the family.
    Complexity: O(|family| * n) with a hash set, where n bounds member size.
    """
    fam: Set[Vertex] = set(family)
    for a in fam:
        for x in a:
            if (a - {x}) not in fam:
                return False
    return True
