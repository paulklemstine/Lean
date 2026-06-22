from __future__ import annotations
from typing import Iterator

def enumerate_types(g: int) -> Iterator[tuple[int, int, int, int]]:
    """Enumerate every legal combinatorial type (v0, vp, e, w) of genus g.

    By the finiteness theorem every legal vector lies in the finite box
    [0, 2g] x [0, 2g] x [0, 3g] x [0, g]; iterate and filter by the three laws.
    """
    for v0 in range(0, 2 * g + 1):
        for vp in range(0, 2 * g + 1):
            for e in range(0, 3 * g + 1):
                for w in range(0, g + 1):
                    v = v0 + vp
                    if (g + v == e + 1 + w          # (G) genus formula
                            and 3 * v <= 2 * w + 2 * e   # (S) stability
                            and v <= e + 1               # (C) connectedness
                            and vp <= w):                # (P) weight positivity
                        yield (v0, vp, e, w)
