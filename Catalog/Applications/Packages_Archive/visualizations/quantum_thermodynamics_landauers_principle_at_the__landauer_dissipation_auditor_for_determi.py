import math
from collections import defaultdict
from typing import Callable, Dict, Hashable

def shannon_entropy(p: Dict[Hashable, float]) -> float:
    return -sum(px * math.log(px) for px in p.values() if px > 0.0)

def landauer_work(f: Callable[[Hashable], Hashable],
                  p: Dict[Hashable, float], k: float, T: float) -> float:
    """W = kT(H(p) - H(f_*p)); always >= 0, and = 0 iff f is injective."""
    out: Dict[Hashable, float] = defaultdict(float)
    for x, px in p.items():
        out[f(x)] += px
    return k * T * (shannon_entropy(p) - shannon_entropy(dict(out)))
