from __future__ import annotations
from typing import Dict, FrozenSet, List, Set, Tuple

Poly = Dict[tuple, int]
Pair = Tuple[frozenset, frozenset]   # unordered pair of poly fingerprints


def _fp(p: Poly) -> frozenset:
    """Canonical fingerprint of a polynomial (its set of nonzero terms)."""
    return frozenset((m, c) for m, c in p.items() if c != 0)


def contraction_glue(
    C_relations: List[Tuple[Poly, Poly]],
    phi: Dict[int, Poly],
    eval_xy,
) -> Set[Pair]:
    """The generating glued pairs of Contr_phi(C): images of C's relations under
    evalXY(phi). (Equality closure under ring ops is not materialised here; this
    captures the *generators* used in the meet computation.)"""
    glued: Set[Pair] = set()
    for F, G in C_relations:
        f, g = eval_xy(phi, F), eval_xy(phi, G)
        fa, ga = _fp(f), _fp(g)
        if fa != ga:
            glued.add(frozenset({fa, ga}))
    return glued


def spectral_meet(
    C_relations: List[Tuple[Poly, Poly]],
    battery: List[Dict[int, Poly]],
    eval_xy,
) -> Set[Pair]:
    """ElimEval(C) restricted to a finite battery: the *meet* (intersection) of
    the glued-pair sets of the contractions Contr_phi(C). Under the Finite
    Witness Theorem (7.3) this reconstructs Elim(C)'s identifications."""
    sets = [contraction_glue(C_relations, phi, eval_xy) for phi in battery]
    if not sets:
        return set()
    out = set(sets[0])
    for s in sets[1:]:
        out &= s
    return out
