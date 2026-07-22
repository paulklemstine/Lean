from typing import Sequence
Edge = tuple[int, int]

def is_k_colorable(n: int, edges: Sequence[Edge], k: int) -> bool:
    neighbors = [set() for _ in range(n)]
    for u, v in edges:
        neighbors[u].add(v); neighbors[v].add(u)
    order = sorted(range(n), key=lambda v: len(neighbors[v]), reverse=True)
    colors = [-1] * n
    def visit(i: int) -> bool:
        if i == n: return True
        v = order[i]
        forbidden = {colors[w] for w in neighbors[v] if colors[w] >= 0}
        for color in range(k):
            if color not in forbidden:
                colors[v] = color
                if visit(i + 1): return True
        colors[v] = -1
        return False
    return visit(0)
