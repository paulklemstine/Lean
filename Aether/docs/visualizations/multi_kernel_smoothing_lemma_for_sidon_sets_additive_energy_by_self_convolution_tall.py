from __future__ import annotations
from collections import Counter
from typing import Dict, Sequence


def self_convolution(s: Sequence[int]) -> Dict[int, int]:
    """Self-convolution kernel r_s(x) = #{(a,b) in s x s : a+b = x}."""
    counts: Counter[int] = Counter()
    for a in s:
        for b in s:
            counts[a + b] += 1
    return dict(counts)


def additive_energy(s: Sequence[int]) -> int:
    """E[s] = sum_x r_s(x)^2 in O(n^2) time and space."""
    return sum(r * r for r in self_convolution(s).values())
