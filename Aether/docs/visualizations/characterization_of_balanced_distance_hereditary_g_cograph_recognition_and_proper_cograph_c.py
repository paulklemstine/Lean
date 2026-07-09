from itertools import combinations, permutations
from typing import List, Sequence, Set, Tuple, FrozenSet

def _adj(E: Set[FrozenSet[int]], u: int, v: int) -> bool:
    return frozenset((u, v)) in E

def _has_pattern(E: Set[FrozenSet[int]], quad: Sequence[int], pattern) -> bool:
    for p in permutations(quad):
        if all(_adj(E, p[a], p[b]) == pattern(a, b)
               for a, b in combinations(range(4), 2)):
            return True
    return False

def _p4(a: int, b: int) -> bool:
    return abs(a - b) == 1

def _c4(a: int, b: int) -> bool:
    return abs(a - b) == 1 or abs(a - b) == 3

def recognize(vertices: List[int], edges: List[Tuple[int, int]]) -> Tuple[bool, bool]:
    E: Set[FrozenSet[int]] = {frozenset(e) for e in edges}
    is_cograph = not any(_has_pattern(E, q, _p4) for q in combinations(vertices, 4))
    is_proper = is_cograph and any(_has_pattern(E, q, _c4) for q in combinations(vertices, 4))
    return (is_cograph, is_proper)

if __name__ == "__main__":
    oct_edges = [(i, j) for i, j in combinations(range(6), 2) if i // 2 != j // 2]
    print("octahedron (is_cograph, is_proper):", recognize(list(range(6)), oct_edges))
    path_edges = [(0, 1), (1, 2), (2, 3)]
    print("P4 (is_cograph, is_proper):", recognize([0, 1, 2, 3], path_edges))
