from __future__ import annotations

import math
from typing import Tuple


def mono_naive_eval(x: float, n: int) -> float:
    """Evaluate x^n by repeated multiplication (the depth-n representation)."""
    acc = 1.0
    for _ in range(n):
        acc *= x
    return acc


def mono_explog_eval(x: float, n: int) -> float:
    """Evaluate x^n as exp(n * log x) on (0, infinity) (the depth-3 representation)."""
    return math.exp(n * math.log(x))


def representation_depths(n: int) -> Tuple[int, int]:
    """Return (depth of naive product, depth of exp/log form) for x^n.

    The naive right-nested product has depth n; the exp/log form exp(n * log x)
    has the constant depth 3 for every n. The depth gap is therefore n - 3.
    """
    return n, 3


def depth_gap(n: int) -> int:
    """Unbounded depth gap n - 3 between the two exact representations of x^n."""
    naive, explog = representation_depths(n)
    return naive - explog
