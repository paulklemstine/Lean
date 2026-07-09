from __future__ import annotations
from typing import Dict, List, Tuple


def divisors(n: int) -> List[int]:
    return [d for d in range(1, n + 1) if n % d == 0]


def anabelomorphic_classes_in_degree(p: int, N: int
                                     ) -> Dict[int, List[Tuple[int, int]]]:
    """Enumerate the residue-anabelomorphic classes realizable by degree-N
    extensions of Q_p.

    Ranging over factorizations N = e * f (ramification index e, residue
    degree f), each contributes a residue torus of order p^f - 1. Data are
    residue-anabelomorphic iff their torus orders agree, so the classes are
    indexed by the distinct values p^f - 1 as f ranges over divisors of N.
    The count of classes equals the number of distinct divisors f of N,
    directly measuring degree non-rigidity (a value > 1 means non-rigid).
    Complexity O(N) to enumerate divisors plus O(log N) arithmetic each.
    """
    classes: Dict[int, List[Tuple[int, int]]] = {}
    for f in divisors(N):
        e = N // f
        order = p ** f - 1
        classes.setdefault(order, []).append((e, f))
    return classes


def is_degree_rigid(p: int, N: int) -> bool:
    """True iff characteristic p together with total degree N determines the
    residue torus uniquely (i.e. N has a single divisor realizable as f)."""
    return len(anabelomorphic_classes_in_degree(p, N)) == 1
