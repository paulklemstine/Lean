from __future__ import annotations
import math
from collections import Counter
from typing import Hashable, Sequence


def functorial_entropy(images: Sequence[Hashable], base: float = 2.0) -> float:
    """H(F) = sum_d (c_d/n) log(c_d), the conditional entropy of a uniform
    domain object given its image. O(n) time, O(|image|) space."""
    n = len(images)
    if n == 0:
        return 0.0
    total = 0.0
    for c_d in Counter(images).values():
        if c_d > 0:
            total += (c_d / n) * math.log(c_d, base)
    return total
