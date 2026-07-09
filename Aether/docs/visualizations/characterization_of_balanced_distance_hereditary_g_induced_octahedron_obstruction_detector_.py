from itertools import combinations
from typing import Dict, List, Optional, Sequence, Set, Tuple, FrozenSet

Adj = Set[FrozenSet[int]]

def adjacent(adj: Adj, u: int, v: int) -> bool:
    return frozenset((u, v)) in adj

def _three_pairings(s: Sequence[int]):
    a = s[0]
    rest = list(s[1:])
    for i in range(len(rest)):
        p0 = (a, rest[i])
        remain = rest[:i] + rest[i+1:]
        b = remain[0]
        for j in range(1, len(remain)):
            p1 = (b, remain[j])
            last = [x for k, x in enumerate(remain) if k not in (0, j)]
            p2 = (last[0], last[1])
            yield (p0, p1, p2)

def induces_octahedron(adj: Adj, pairs: Tuple[Tuple[int, int], ...]) -> bool:
    for a, b in pairs:
        if adjacent(adj, a, b):
            return False
    verts = [v for pr in pairs for v in pr]
    part = {v: k for k, pr in enumerate(pairs) for v in pr}
    for u, w in combinations(verts, 2):
        if part[u] != part[w] and not adjacent(adj, u, w):
            return False
    return True

def is_balanced(vertices: List[int], edges: List[Tuple[int, int]]
                ) -> Tuple[bool, Optional[Tuple[Tuple[int, int], ...]]]:
    adj: Adj = {frozenset(e) for e in edges}
    for s in combinations(vertices, 6):
        for pairs in _three_pairings(s):
            if induces_octahedron(adj, pairs):
                return (False, pairs)
    return (True, None)

if __name__ == "__main__":
    # octahedron itself: unbalanced
    oct_edges = [(i, j) for i, j in combinations(range(6), 2) if i // 2 != j // 2]
    print(is_balanced(list(range(6)), oct_edges))
    # complete graph K5: balanced (no non-edges -> no octahedron)
    k5 = [(i, j) for i, j in combinations(range(5), 2)]
    print(is_balanced(list(range(5)), k5))
