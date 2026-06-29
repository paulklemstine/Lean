from __future__ import annotations
from typing import Callable, Hashable, List, Optional, Set

Config = Hashable
SelfMap = Callable[[Config], Config]


def reaches_bad_bounded(f: SelfMap, x: Config, bad: Set[Config],
                        card: int) -> Optional[int]:
    """
    Decide whether a TOTAL machine ever enters the bad region `bad`, starting
    from x, by simulating at most `card` = card(P x S) steps (Theorem 4.2:
    'ever reaches bad' iff 'reaches bad within card steps'). Returns the first
    witnessing step n (n <= card) or None if forever safe.
    Time O(card * (cost(f) + cost(membership))).
    """
    cur = x
    for n in range(card + 1):
        if cur in bad:
            return n
        cur = f(cur)
    return None


def maximal_safe_invariant(f: SelfMap, universe: List[Config],
                           bad: Set[Config]) -> Set[Config]:
    """
    Largest forward-invariant subset of the safe states (universe \\ bad):
    a state survives iff its whole forward orbit avoids `bad`. By Theorem 3.9
    this is empty whenever f is strongly connected and bad is nonempty.
    Time O(card^2 * cost(f)) (naive); O(card) per start via orbit confinement.
    """
    survivors: Set[Config] = set()
    N = len(universe)
    for x in set(universe) - bad:
        cur, ok = x, True
        for _ in range(N + 1):
            if cur in bad:
                ok = False
                break
            cur = f(cur)
        if ok:
            survivors.add(x)
    return survivors
