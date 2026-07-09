from __future__ import annotations
from typing import Dict, FrozenSet, List, Optional, Tuple

Semicube = Tuple[int, bool]
Vertex = FrozenSet[int]


def _fold(fam: List[Semicube]) -> Optional[Dict[int, bool]]:
    a: Dict[int, bool] = {}
    for i, b in fam:
        if i in a and a[i] != b:
            return None
        a[i] = b
    return a


def product_consistency(boundaries: List[int],
                        family: List[Semicube]
                        ) -> Tuple[bool, Optional[Vertex]]:
    """Solve a semicube family over a product Q(n_1) x ... x Q(n_k).

    `boundaries` gives the cumulative coordinate offsets of the factors.
    Each factor is folded independently; cross-factor pairs are ignored
    because they never obstruct. Returns (feasible, canonical witness)."""
    buckets: Dict[int, List[Semicube]] = {}
    for i, b in family:
        f = max(t for t in range(len(boundaries)) if boundaries[t] <= i)
        buckets.setdefault(f, []).append((i, b))
    witness: set[int] = set()
    for fam in buckets.values():
        a = _fold(fam)
        if a is None:
            return False, None
        witness |= {i for i, b in a.items() if b}
    return True, frozenset(witness)
