from typing import Callable, Dict, Hashable, Sequence

def pushforward(f: Callable[[Hashable], Hashable],
                support: Sequence[Hashable],
                p: Sequence[float]) -> Dict[Hashable, float]:
    img: Dict[Hashable, float] = {}
    for x, px in zip(support, p):
        y = f(x)
        img[y] = img.get(y, 0.0) + px
    return img
