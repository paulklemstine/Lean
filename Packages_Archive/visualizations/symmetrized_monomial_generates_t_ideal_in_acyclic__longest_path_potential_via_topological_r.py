from typing import Dict, List, Tuple


def topological_potential(n: int, edges: List[Tuple[int, int]]) -> Dict[int, int]:
    """Longest-path potential r : V -> N (strictly increasing along arrows).

    Runs Kahn's algorithm while relaxing r(w) = max(r(w), r(u) + 1) along
    each arrow u -> w. Returns a potential bounded by n; raises if cyclic.
    Complexity O(|V| + |E|).
    """
    succ: Dict[int, List[int]] = {v: [] for v in range(n)}
    indeg: List[int] = [0] * n
    for a, b in edges:
        succ[a].append(b)
        indeg[b] += 1
    queue: List[int] = [v for v in range(n) if indeg[v] == 0]
    r: Dict[int, int] = {v: 0 for v in range(n)}
    visited: int = 0
    while queue:
        u = queue.pop()
        visited += 1
        for w in succ[u]:
            if r[u] + 1 > r[w]:
                r[w] = r[u] + 1
            indeg[w] -= 1
            if indeg[w] == 0:
                queue.append(w)
    if visited != n:
        raise ValueError("quiver is not acyclic")
    return r
