from __future__ import annotations
from typing import Iterable, Set


def sidon_deficit(s: Iterable[int]) -> int:
    """Deficit D(s) = (k^2 - k + 1) - |s - s|; equals 0 iff s is Sidon.

    Runs in O(k^2) time and space and quantifies distance to the Sidon property.
    """
    elems: Set[int] = set(s)
    k = len(elems)
    diffs: Set[int] = {a - b for a in elems for b in elems}
    return (k * k - k + 1) - len(diffs)
