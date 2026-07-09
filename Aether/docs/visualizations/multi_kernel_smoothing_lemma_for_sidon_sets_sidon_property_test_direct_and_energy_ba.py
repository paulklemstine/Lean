from __future__ import annotations
from itertools import combinations
from typing import Sequence


def is_sidon(s: Sequence[int]) -> bool:
    """Test the Sidon (B_2) property in O(n^2) time.

    A set is Sidon iff all its pairwise sums a+b (a <= b) are distinct.
    """
    us = sorted(set(s))
    sums = [a + b for a, b in combinations(us, 2)] + [2 * a for a in us]
    return len(sums) == len(set(sums))


def is_sidon_via_energy(s: Sequence[int]) -> bool:
    """Equivalent test via the characterisation theorem: E[s] = 2n^2 - n."""
    from collections import Counter
    us = sorted(set(s))
    n = len(us)
    c: Counter[int] = Counter()
    for a in us:
        for b in us:
            c[a + b] += 1
    energy = sum(r * r for r in c.values())
    return energy == 2 * n * n - n
