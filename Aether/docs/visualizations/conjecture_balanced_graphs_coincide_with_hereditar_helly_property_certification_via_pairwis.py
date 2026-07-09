from __future__ import annotations
from itertools import combinations
from typing import Dict, FrozenSet, List, Set, Tuple

Graph = Dict[int, Set[int]]
Clique = FrozenSet[int]


def is_clique(graph: Graph, s: Set[int]) -> bool:
    """Return True iff all distinct pairs in s are adjacent."""
    return all(v in graph[u] for u, v in combinations(sorted(s), 2))


def maximal_cliques(graph: Graph) -> List[Clique]:
    """Enumerate maximal cliques by brute force (small graphs only)."""
    verts = sorted(graph)
    found: List[Set[int]] = []
    for r in range(1, len(verts) + 1):
        for combo in combinations(verts, r):
            s = set(combo)
            if is_clique(graph, s):
                found.append(s)
    return [frozenset(s) for s in found if not any(s < t for t in found)]


def is_clique_helly(graph: Graph) -> Tuple[bool, List[Clique]]:
    """Test the Helly property for maximal cliques.

    Returns (True, []) if clique-Helly, else (False, witness family) where
    the witness pairwise-intersects but has empty common intersection.
    """
    maximal = maximal_cliques(graph)
    for r in range(2, len(maximal) + 1):
        for fam in combinations(maximal, r):
            fam = list(fam)
            if all(len(a & b) > 0 for a, b in combinations(fam, 2)):
                core = set(fam[0])
                for c in fam[1:]:
                    core &= c
                if not core:
                    return False, fam
    return True, []
