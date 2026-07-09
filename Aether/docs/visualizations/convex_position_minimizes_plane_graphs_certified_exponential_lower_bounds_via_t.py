from __future__ import annotations
from typing import List, Tuple

Chord = Tuple[int, int]


def star(n: int) -> List[Chord]:
    """Star at vertex 0: n-1 chords, plane; certifies N(n) >= 2^(n-1)."""
    return [(0, j) for j in range(1, n)]


def fan(n: int) -> List[Chord]:
    """Fan triangulation from 0: 2n-3 edges, plane; certifies N(n) >= 2^(2n-3)."""
    return sorted(set((0, j) for j in range(1, n)) |
                  set((k, k + 1) for k in range(n - 1)))


def doubling_bound(num_edges: int) -> int:
    """Doubling principle: a plane graph with E edges certifies 2^E plane graphs."""
    return 2 ** num_edges


def convex_floor(n: int, h: int) -> int:
    """Triangulation-subset floor L(n,h) = 2^(3n-3-h)."""
    return doubling_bound(3 * n - 3 - h)
