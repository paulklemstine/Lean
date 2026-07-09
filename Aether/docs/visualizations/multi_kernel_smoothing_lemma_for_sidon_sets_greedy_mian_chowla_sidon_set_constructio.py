from __future__ import annotations
from typing import List, Set


def greedy_sidon(k: int) -> List[int]:
    """Greedy (Mian-Chowla) construction of a Sidon set of size k in [0, ...).

    Starting from the empty set, repeatedly append the smallest positive integer
    whose inclusion introduces no repeated difference. The output satisfies
    |s - s| = k^2 - k + 1 by construction.
    """
    s: List[int] = []
    diffs: Set[int] = set()
    candidate = 0
    while len(s) < k:
        candidate += 1
        new_diffs = set()
        ok = True
        for y in s:
            d = candidate - y
            if d in diffs or -d in diffs or d in new_diffs or -d in new_diffs:
                ok = False
                break
            new_diffs.add(d)
            new_diffs.add(-d)
        if ok:
            s.append(candidate)
            diffs |= new_diffs
    return s
