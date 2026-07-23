from typing import Dict, List, Sequence, Set, Tuple


def h0_barcode(vertices: Sequence[int],
               filtration: List[Tuple[float, Tuple[int, int]]]
               ) -> List[Tuple[float, float]]:
    """Compute the H_0 persistence barcode of an edge filtration.

    `filtration` is a list of (threshold, edge) pairs sorted by threshold.
    Each vertex's component is "born" at threshold 0; when two components
    merge at threshold t (a union that actually joins two distinct roots),
    the younger component "dies" at t. By H_0 persistence the number of
    live components is monotone non-increasing. Returns a list of
    (birth, death) bars; the longest bar is the survival time of the
    dominant component (its death is +inf).
    """
    parent: Dict[int, int] = {v: v for v in vertices}
    birth: Dict[int, float] = {v: 0.0 for v in vertices}

    def find(x: int) -> int:
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    bars: List[Tuple[float, float]] = []
    for t, (a, b) in sorted(filtration, key=lambda p: p[0]):
        ra, rb = find(a), find(b)
        if ra != rb:
            # the younger root dies; the older survives (elder rule)
            young, old = (ra, rb) if birth[ra] >= birth[rb] else (rb, ra)
            bars.append((birth[young], t))
            parent[young] = old
    # survivors: their bars extend to +inf
    roots = {find(v) for v in vertices}
    for r in roots:
        bars.append((birth[r], float("inf")))
    return bars
