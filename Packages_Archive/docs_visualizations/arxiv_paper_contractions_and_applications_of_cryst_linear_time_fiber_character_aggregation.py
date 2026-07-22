from collections import defaultdict
from typing import Callable, Hashable, Iterable, Mapping, TypeVar
V=TypeVar("V",bound=Hashable); Q=TypeVar("Q",bound=Hashable)
def characters(vertices: Iterable[V], q: Callable[[V],Q], w: Mapping[V,int]) -> dict[Q,int]:
    out: dict[Q,int] = defaultdict(int)
    for x in vertices: out[q(x)] += w[x]
    return dict(out)
