import math
from typing import Callable, Dict, Hashable, Sequence

def shannon_entropy(p: Sequence[float]) -> float:
    return -sum(px * math.log(px) for px in p if px > 0.0)

def landauer_work(f: Callable[[Hashable], Hashable],
                  support: Sequence[Hashable], p: Sequence[float],
                  k: float = 1.380649e-23, T: float = 300.0) -> float:
    img: Dict[Hashable, float] = {}
    for x, px in zip(support, p):
        img[f(x)] = img.get(f(x), 0.0) + px
    return k * T * (shannon_entropy(p) - shannon_entropy(list(img.values())))
