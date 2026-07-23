from collections import deque
from itertools import combinations
from typing import Dict, List, Tuple

Edge = Tuple[int, int]
BitVec = Tuple[int, ...]


def hamming_distance(x: BitVec, y: BitVec) -> int:
    return sum(1 for a, b in zip(x, y) if a != b)


def total_contraction_defect(
    n: int, edges: List[Edge], label: Dict[int, BitVec]
) -> int:
    """Sum over unordered vertex pairs of (d_G - Hamming(label)). By the
    No-Stretching Theorem every summand is >= 0, so the total is a nonnegative
    measure of how far the (edge-gentle) labeling is from isometric."""
    adj: Dict[int, List[int]] = {v: [] for v in range(n)}
    for u, v in edges:
        adj[u].append(v)
        adj[v].append(u)

    def bfs(src: int) -> Dict[int, int]:
        dist = {src: 0}
        q: deque[int] = deque([src])
        while q:
            u = q.popleft()
            for w in adj[u]:
                if w not in dist:
                    dist[w] = dist[u] + 1
                    q.append(w)
        return dist

    dmat = {v: bfs(v) for v in range(n)}
    total = 0
    for u, v in combinations(range(n), 2):
        total += dmat[u][v] - hamming_distance(label[u], label[v])
    return total
