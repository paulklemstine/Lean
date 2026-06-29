from collections import defaultdict
from typing import Callable, Dict, Hashable

def pushforward(f: Callable[[Hashable], Hashable],
                p: Dict[Hashable, float]) -> Dict[Hashable, float]:
    """(f_*p)(y) = sum_{x : f(x)=y} p(x). O(|domain|) time."""
    out: Dict[Hashable, float] = defaultdict(float)
    for x, px in p.items():
        out[f(x)] += px
    return dict(out)
