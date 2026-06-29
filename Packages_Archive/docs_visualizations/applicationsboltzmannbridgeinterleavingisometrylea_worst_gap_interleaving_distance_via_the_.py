from itertools import combinations
from typing import Callable, FrozenSet, Sequence, TypeVar

V = TypeVar("V")
Simplex = FrozenSet[V]
Weight = Callable[[Simplex], float]


def interleaving_distance(
    wf: Weight, wg: Weight, simplices: Sequence[Simplex]
) -> float:
    """Exact interleaving distance via the isometry formula:
        d(F, G) = max_sigma |w_F(sigma) - w_G(sigma)|.
    O(|simplices|) weight evaluations; the infimum over shifts is attained here."""
    return max((abs(wf(s) - wg(s)) for s in simplices), default=0.0)


def is_interleaved(
    wf: Weight, wg: Weight, delta: float, simplices: Sequence[Simplex]
) -> bool:
    """Decide delta-interleaving (interleaved_iff_weightCloseBy):
        delta >= 0 and every weight gap <= delta."""
    return delta >= 0.0 and interleaving_distance(wf, wg, simplices) <= delta
