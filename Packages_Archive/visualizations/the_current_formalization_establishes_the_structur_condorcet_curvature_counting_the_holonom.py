from itertools import product
from typing import List, Tuple

Ranking = Tuple[int, ...]
Profile = List[Ranking]


def prefers(r: Ranking, a: int, b: int) -> bool:
    """Voter `r` prefers `a` to `b` iff `a` has the lower rank."""
    return r.index(a) < r.index(b)


def support_count(profile: Profile, a: int, b: int) -> int:
    """Number of voters preferring `a` to `b`."""
    return sum(1 for r in profile if prefers(r, a, b))


def majority_beats(profile: Profile, a: int, b: int) -> bool:
    """`a` beats `b` by strict majority."""
    return support_count(profile, a, b) > support_count(profile, b, a)


def condorcet_curvature(profile: Profile, n: int) -> int:
    """Number of directed majority 3-cycles: the discrete curvature scalar.
    0 == flat (transitive majority), > 0 == curved (Condorcet cycle present)."""
    return sum(
        1
        for a, b, c in product(range(n), repeat=3)
        if majority_beats(profile, a, b)
        and majority_beats(profile, b, c)
        and majority_beats(profile, c, a)
    )
