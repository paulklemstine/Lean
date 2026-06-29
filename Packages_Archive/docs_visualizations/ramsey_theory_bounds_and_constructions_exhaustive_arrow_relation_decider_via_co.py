from itertools import combinations
from typing import FrozenSet, Tuple

def arrows(n: int, s: int, t: int) -> bool:
    """Decide n -> (s, t) by checking ALL colourings of K_n."""
    edges = list(combinations(range(n), 2))
    def red_clique(red: FrozenSet[Tuple[int, int]], verts) -> bool:
        return all((min(a, b), max(a, b)) in red for a, b in combinations(verts, 2))
    def blue_clique(red: FrozenSet[Tuple[int, int]], verts) -> bool:
        return all((min(a, b), max(a, b)) not in red for a, b in combinations(verts, 2))
    for mask in range(1 << len(edges)):
        red = frozenset(edges[i] for i in range(len(edges)) if (mask >> i) & 1)
        hr = any(red_clique(red, c) for c in combinations(range(n), s))
        hb = any(blue_clique(red, c) for c in combinations(range(n), t))
        if not (hr or hb):
            return False
    return True

assert arrows(6, 3, 3) is True
assert arrows(5, 3, 3) is False
