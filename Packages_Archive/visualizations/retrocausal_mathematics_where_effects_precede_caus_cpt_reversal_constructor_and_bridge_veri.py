from __future__ import annotations
from itertools import product
from typing import Callable, Dict, FrozenSet, List, Sequence


def cpt_reversal(universe: FrozenSet[int], theta: Callable[[int], int],
                 S: FrozenSet[int]) -> FrozenSet[int]:
    """cptReversal S = theta^{-1}(S^c) = { v in V : theta(v) not in S }.
    This is the composite C (complement) then T (time reflection)."""
    return frozenset(v for v in universe if theta(v) not in S)


def all_subsets(universe: Sequence[int]) -> List[FrozenSet[int]]:
    out: List[FrozenSet[int]] = []
    for bits in product((False, True), repeat=len(universe)):
        out.append(frozenset(u for u, b in zip(universe, bits) if b))
    return out


def verify_cpt_bridge(universe: FrozenSet[int],
                      theta: Callable[[int], int]) -> Dict[str, bool]:
    """Given a configuration space V and an involution theta (theta o theta = id),
    verify that cptReversal is an order-reversing involution satisfying the De Morgan
    and pole-swap laws -- i.e. that Set V is a retrocausal Heyting algebra."""
    assert all(theta(theta(v)) == v for v in universe), "theta must be an involution"
    subs = all_subsets(sorted(universe))
    rev = lambda S: cpt_reversal(universe, theta, S)
    return {
        "involutive": all(rev(rev(S)) == S for S in subs),
        "antitone": all((not S <= T) or (rev(T) <= rev(S))
                        for S in subs for T in subs),
        "de_morgan": all(rev(S | T) == (rev(S) & rev(T)) and
                         rev(S & T) == (rev(S) | rev(T))
                         for S in subs for T in subs),
        "pole_swap": rev(frozenset()) == universe and rev(universe) == frozenset(),
    }
