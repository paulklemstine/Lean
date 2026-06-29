from itertools import combinations
from typing import Dict, List, Optional, Tuple

Edge = Tuple[int, int, int]

def spans(edges: List[Edge], n: int) -> bool:
    adj: Dict[int, List[int]] = {i: [] for i in range(n)}
    for (u, v, _) in edges:
        if u < n and v < n:
            adj[u].append(v); adj[v].append(u)
    seen, stack = {0}, [0]
    while stack:
        x = stack.pop()
        for y in adj[x]:
            if y not in seen:
                seen.add(y); stack.append(y)
    return len(seen) == n

def min_spanning_weight(edges: List[Edge], n: int) -> Optional[int]:
    """Brute-force optimality certificate over all 2^m edge subsets."""
    best: Optional[int] = None
    for k in range(len(edges) + 1):
        for combo in combinations(edges, k):
            sub = list(combo)
            if spans(sub, n):
                w = sum(e[2] for e in sub)
                best = w if best is None or w < best else best
    return best
