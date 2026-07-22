from __future__ import annotations
import math
from collections import Counter
from typing import Hashable, Optional, Sequence


def uniform_fiber_entropy(images: Sequence[Hashable],
                          base: float = 2.0) -> Optional[float]:
    """If every nonempty fiber of F has a common size k, return log_base(k)
    (the closed-form loss); otherwise return None. Also equals log(n/m) when
    F is surjective onto its m-element image."""
    counts = list(Counter(images).values())
    if not counts:
        return 0.0
    k = counts[0]
    if any(c != k for c in counts):
        return None
    return math.log(k, base)
