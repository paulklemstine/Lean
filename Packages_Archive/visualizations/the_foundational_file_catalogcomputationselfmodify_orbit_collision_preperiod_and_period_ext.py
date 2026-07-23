from __future__ import annotations
from typing import Callable, Dict, Hashable, Tuple

Config = Hashable
SelfMap = Callable[[Config], Config]


def orbit_collision_floyd(f: SelfMap, x: Config) -> Tuple[int, int]:
    """
    Floyd cycle detection for a finite self-map f from start x.

    Returns (mu, lam): mu = preperiod (tail) length, lam = cycle period,
    so f^[mu](x) is the first periodic point and f^[mu+lam](x) == f^[mu](x).
    Time O((mu+lam)*cost(f)), O(1) extra space. Guaranteed to terminate on a
    finite space by the iterate-collision (pigeonhole) theorem.
    """
    tortoise, hare = f(x), f(f(x))
    while tortoise != hare:                 # find a meeting point in the cycle
        tortoise, hare = f(tortoise), f(hare)
    mu = 0                                   # locate cycle entry (preperiod)
    tortoise = x
    while tortoise != hare:
        tortoise, hare = f(tortoise), f(hare)
        mu += 1
    lam = 1                                   # measure period
    hare = f(tortoise)
    while tortoise != hare:
        hare = f(hare)
        lam += 1
    return mu, lam


def orbit_collision_table(f: SelfMap, x: Config, card: int) -> Tuple[int, int]:
    """
    Hash-table variant: record first-occurrence index of each configuration.
    Returns (i, j) with i < j <= card and f^[i](x) == f^[j](x) (Theorem 3.4).
    Time and space O(card).
    """
    seen: Dict[Config, int] = {}
    cur = x
    for k in range(card + 1):
        if cur in seen:
            return seen[cur], k
        seen[cur] = k
        cur = f(cur)
    raise RuntimeError("pigeonhole guarantees a collision within card+1 steps")
