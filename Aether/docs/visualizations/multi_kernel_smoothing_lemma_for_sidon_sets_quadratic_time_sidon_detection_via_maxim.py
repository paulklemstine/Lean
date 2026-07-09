from __future__ import annotations
from typing import Iterable, Set


def sidon_test(s: Iterable[int]) -> bool:
    """O(k^2) Sidon test via the maximal-difference-set characterization.

    Returns True iff |s - s| = k^2 - k + 1, which holds iff s is Sidon.
    """
    elems: Set[int] = set(s)
    k = len(elems)
    if k == 0:
        return True  # empty set is vacuously Sidon
    diffs: Set[int] = set()
    for a in elems:
        for b in elems:
            diffs.add(a - b)
    return len(diffs) == k * k - k + 1


def sidon_test_early(s: Iterable[int]) -> bool:
    """Early-terminating variant: fail on first nonzero-difference collision."""
    elems = sorted(set(s))
    seen: Set[int] = set()
    for i in range(len(elems)):
        for j in range(i + 1, len(elems)):
            d = elems[j] - elems[i]
            if d in seen:
                return False
            seen.add(d)
    return True
