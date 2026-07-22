from __future__ import annotations
import math
from collections import Counter
from typing import Callable, Hashable, Sequence


def functorial_entropy(images: Sequence[Hashable], base: float = 2.0) -> float:
    n = len(images)
    if n == 0:
        return 0.0
    return sum((c / n) * math.log(c, base)
               for c in Counter(images).values() if c > 0)


def data_processing_gap(domain: Sequence[Hashable],
                        f: Callable[[Hashable], Hashable],
                        g: Callable[[Hashable], Hashable],
                        base: float = 2.0) -> float:
    """Return H(g o f) - H(f) >= 0, the extra information discarded by the
    second stage g. Nonnegativity is the data-processing inequality."""
    img_f = [f(a) for a in domain]
    img_gf = [g(f(a)) for a in domain]
    return functorial_entropy(img_gf, base) - functorial_entropy(img_f, base)
