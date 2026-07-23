from typing import List

Matrix = List[List[float]]

def connectivity_threshold(dmat: Matrix) -> float:
    """Largest MST edge = single-linkage bottleneck (Prim, O(n^2))."""
    n: int = len(dmat)
    if n <= 1:
        return 0.0
    in_tree: List[bool] = [False] * n
    in_tree[0] = True
    best: List[float] = [dmat[0][j] for j in range(n)]
    bottleneck: float = 0.0
    for _ in range(n - 1):
        u: int = min((j for j in range(n) if not in_tree[j]),
                     key=lambda j: best[j])
        bottleneck = max(bottleneck, best[u])
        in_tree[u] = True
        for j in range(n):
            if not in_tree[j] and dmat[u][j] < best[j]:
                best[j] = dmat[u][j]
    return bottleneck
