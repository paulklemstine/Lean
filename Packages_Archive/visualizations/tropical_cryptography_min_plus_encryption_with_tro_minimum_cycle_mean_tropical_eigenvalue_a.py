from typing import List
INF = float('inf')
Matrix = List[List[float]]

def min_cycle_mean(A: Matrix) -> float:
    n = len(A); best = INF
    def walk(s, u, length, w, seen):
        nonlocal best
        for x in range(n):
            e = A[u][x]
            if e == INF: continue
            if x == s: best = min(best, (w + e) / (length + 1))
            elif x not in seen:
                seen.add(x); walk(s, x, length + 1, w + e, seen); seen.discard(x)
    for s in range(n): walk(s, s, 0, 0.0, {s})
    return best
