from __future__ import annotations
from itertools import combinations
from typing import List, Tuple

Chord = Tuple[int, int]


def chords(n: int) -> List[Chord]:
    """All chords (i,j), i<j, of the convex n-gon."""
    return [(i, j) for i in range(n) for j in range(i + 1, n)]


def cross(x: Chord, y: Chord) -> bool:
    """Strict interleaving test = straight-line crossing in convex position."""
    a, b = x
    c, d = y
    return (a < c < b < d) or (c < a < d < b)


def is_plane(graph: Tuple[Chord, ...]) -> bool:
    """No two chords cross."""
    return all(not cross(graph[i], graph[j])
               for i in range(len(graph)) for j in range(i + 1, len(graph)))


def num_plane(n: int) -> int:
    """N(n): exact number of plane graphs on n convex points."""
    cs = chords(n)
    return sum(1 for k in range(len(cs) + 1)
               for s in combinations(cs, k) if is_plane(s))
