from itertools import permutations
from typing import List, Tuple

Perm = Tuple[int, int, int]


def reveal_bijection(a: int, b: int) -> List[Tuple[Tuple[int, int], Perm]]:
    """Enumerate the perfect-HVZK bijection pi |-> (pi(a), pi(b)).

    For a challenged edge with distinct endpoint colours a != b, this maps each
    of the 6 colour permutations to a distinct ordered pair of distinct colours,
    covering all 6 such pairs exactly once. Hence a uniformly random permutation
    yields a uniformly random distinct pair, independent of a and b.
    """
    assert a != b, "endpoint colours must be distinct"
    out: List[Tuple[Tuple[int, int], Perm]] = []
    for pi in permutations((0, 1, 2)):
        out.append(((pi[a], pi[b]), pi))
    return out
