from __future__ import annotations
from typing import Dict, Tuple, List

Poly = Dict[int, int]


def refined_compare(x: Poly, y: Poly) -> str:
    """Compare two virtual graded spaces by a refinement of chi.

    First compare Euler characteristics; if equal, compare the full sorted
    coefficient vector (the Poincare series), which is injective and recovers
    both chi and the dimension. Returns 'equal', 'chi-differ', or
    'chi-collision-refined' when chi agrees but the spaces differ.
    """
    def cx(p: Poly) -> int:
        return sum(a if d % 2 == 0 else -a for d, a in p.items())

    def series(p: Poly) -> List[Tuple[int, int]]:
        return sorted((d, a) for d, a in p.items() if a)

    if cx(x) != cx(y):
        return "chi-differ"
    return "equal" if series(x) == series(y) else "chi-collision-refined"
