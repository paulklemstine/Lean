"""Exact win-probability solver for the random-elimination Werewolf model."""

from __future__ import annotations

from fractions import Fraction
from functools import lru_cache
from typing import Dict, Tuple


@lru_cache(maxsize=None)
def win_prob(v: int, w: int) -> Fraction:
    """Exact villager win probability from state (v villagers, w werewolves).

    Complexity: each distinct state (v, w) is solved once and memoized; every
    recursive call strictly decreases v + w, so the number of evaluated states
    is O(v * w) and total work is O(v * w) exact rational operations.
    """
    if w == 0:                       # all werewolves gone -> villagers win
        return Fraction(1, 1)
    if v <= w:                       # werewolves at majority -> villagers lose
        return Fraction(0, 1)
    total = v + w
    # Day vote hits a werewolf (prob w/total):
    after_wolf = Fraction(1, 1) if w == 1 else win_prob(v - 1, w - 1)
    branch_wolf = Fraction(w, total) * after_wolf
    # Day vote hits a villager (prob v/total); night kill costs a second villager:
    after_villager = Fraction(0, 1) if v <= w + 2 else win_prob(v - 2, w)
    branch_villager = Fraction(v, total) * after_villager
    return branch_wolf + branch_villager


def parity_defect(v: int, w: int) -> Fraction:
    """D(v, w) = P(v, w) / P(v+1, w); > 1 exactly when adding a villager hurts."""
    denom = win_prob(v + 1, w)
    return Fraction(0, 1) if denom == 0 else win_prob(v, w) / denom


def solve_table(max_v: int, max_w: int) -> Dict[Tuple[int, int], Fraction]:
    """Return the exact win-probability table for all states up to (max_v, max_w)."""
    return {(v, w): win_prob(v, w)
            for v in range(max_v + 1)
            for w in range(max_w + 1)}


if __name__ == "__main__":
    for (v, w) in [(2, 1), (3, 1), (4, 1), (5, 1), (3, 2), (4, 2)]:
        print(f"P({v},{w}) = {win_prob(v, w)}   D({v},{w}) = {parity_defect(v, w)}")
