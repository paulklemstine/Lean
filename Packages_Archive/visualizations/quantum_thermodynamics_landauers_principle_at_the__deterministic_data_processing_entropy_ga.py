from __future__ import annotations
import math
from typing import Callable, Dict, Hashable, List, Sequence, Tuple


def shannon_entropy(p: Sequence[float]) -> float:
    """H(p) = sum -p ln p with 0 ln 0 = 0."""
    return sum((-pi * math.log(pi)) for pi in p if pi > 0.0)


def pushforward(states: Sequence[Hashable], p: Sequence[float],
                f: Callable[[Hashable], Hashable]) -> Tuple[List[Hashable], List[float]]:
    """Image measure f_* p: weight of y is the total weight of its fiber."""
    w: Dict[Hashable, float] = {}
    for s, ps in zip(states, p):
        y = f(s)
        w[y] = w.get(y, 0.0) + ps
    keys = list(w.keys())
    return keys, [w[y] for y in keys]


def data_processing_gap(states: Sequence[Hashable], p: Sequence[float],
                        f: Callable[[Hashable], Hashable]) -> float:
    """Entropy drop H(p) - H(f_* p) >= 0; zero iff f is injective on supp p."""
    _, q = pushforward(states, p, f)
    return shannon_entropy(p) - shannon_entropy(q)
