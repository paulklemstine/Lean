from __future__ import annotations
from itertools import product
from typing import Iterator, List, Tuple

Elem = Tuple[int, bool, int]  # (col, side: False='a'/True='b', idx)

def enumerate_cycles(w: int, m: int) -> Iterator[List[Tuple[Elem, Elem]]]:
    """Yield all m^{2w} strict alternating cycles of Crown(w, m)."""
    funcs: List[Tuple[int, ...]] = list(product(range(m), repeat=w))
    for u in funcs:           # m^w lower-clone selections
        for v in funcs:       # m^w upper-clone selections
            cycle: List[Tuple[Elem, Elem]] = [
                ((t, False, u[t]), (t, True, v[t])) for t in range(w)
            ]
            yield cycle

def count_cycles(w: int, m: int) -> int:
    """Number of strict alternating cycles produced = m^{2w}."""
    return sum(1 for _ in enumerate_cycles(w, m))
