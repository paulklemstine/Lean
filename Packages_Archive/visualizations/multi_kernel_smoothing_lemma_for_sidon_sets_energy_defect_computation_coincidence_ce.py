from __future__ import annotations
from collections import Counter
from typing import Sequence


def energy_defect(s: Sequence[int]) -> int:
    """Non-negative defect D(s) = E[s] - (2n^2 - n).

    By the two-kernel decomposition, D(s) equals the number of energy
    quadruples outside the diagonal and swap kernels, i.e. the count of
    non-trivial additive coincidences. D(s) = 0 iff s is Sidon.
    """
    us = sorted(set(s))
    n = len(us)
    c: Counter[int] = Counter()
    for a in us:
        for b in us:
            c[a + b] += 1
    energy = sum(r * r for r in c.values())
    return energy - (2 * n * n - n)
