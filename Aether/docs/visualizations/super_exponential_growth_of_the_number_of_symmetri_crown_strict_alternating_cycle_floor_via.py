from __future__ import annotations
from itertools import product
from typing import Iterator


def crown_alt_cycles(w: int, m: int) -> Iterator[tuple[tuple[int, int], ...]]:
    """Enumerate the certified family of strict alternating cycles of Crown(w,m).

    Each independent pair of clone-assignments u,v : range(w) -> range(m) yields a
    distinct cycle cyc(u,v) (clone u[t] on the a-side, v[t] on the b-side of
    column t). There are m^w * m^w = m^(2w) of them, giving the lower bound
    m^(2w) <= crownAltCount(w,m). FIXED arity 2w => polynomial, not super-exp.
    """
    for u in product(range(m), repeat=w):
        for v in product(range(m), repeat=w):
            yield tuple((u[t], v[t]) for t in range(w))


def crown_floor(w: int, m: int) -> int:
    return m ** (2 * w)
