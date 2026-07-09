from __future__ import annotations
from typing import FrozenSet, List, Set

Frame = FrozenSet[int]

def incoherence_index(n: int, frame: Frame) -> int:
    """Shortest non-empty zero-sum sequence length over `frame` in Z/nZ (0 if none).

    Breadth-first search on the residue graph with vertices {0,...,n-1} and an
    edge s -> (s + a) mod n for each atom a in the frame. The incoherence index
    is the length of the shortest non-trivial closed walk through 0.
    Complexity: O(n * |frame|) time, O(n) space.
    """
    atoms: List[int] = sorted((a % n) for a in frame)
    if not atoms:
        return 0
    if any(a == 0 for a in atoms):
        return 1
    frontier: Set[int] = set(atoms)
    if 0 in frontier:
        return 1
    visited: Set[int] = set(frontier)
    length: int = 1
    while frontier and length <= n:
        nxt: Set[int] = set()
        for s in frontier:
            for a in atoms:
                t = (s + a) % n
                if t == 0:
                    return length + 1
                if t not in visited:
                    visited.add(t)
                    nxt.add(t)
        frontier = nxt
        length += 1
    return 0
