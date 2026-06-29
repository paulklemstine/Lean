from __future__ import annotations
from typing import FrozenSet, List, Sequence, Set


def zariski_closed(spec: List[FrozenSet[int]], S: Set[int]) -> Set[int]:
    """V(S): indices of spectrum points at which every element of S vanishes."""
    return {i for i, Z in enumerate(spec) if all(s in Z for s in S)}


def theory_of(spec: List[FrozenSet[int]], X: Set[int],
              carrier: Sequence[int]) -> Set[int]:
    """Th(X): elements vanishing at every selected point."""
    return {a for a in carrier if all(a in spec[i] for i in X)}


def radical(spec: List[FrozenSet[int]], T: Set[int],
            carrier: Sequence[int]) -> Set[int]:
    """Algorithm C: the Galois closure rad(T) = Th(V(T)).

    Idempotent (rad . rad = rad); its fixed points are exactly the
    intersections of prime zero classes Z(P) over P in V(T)."""
    return theory_of(spec, zariski_closed(spec, T), carrier)


def is_radical_fixed(spec: List[FrozenSet[int]], T: Set[int],
                     carrier: Sequence[int]) -> bool:
    """True iff rad(T) = T, equivalently T is an intersection of prime theories."""
    return radical(spec, T, carrier) == set(T)
