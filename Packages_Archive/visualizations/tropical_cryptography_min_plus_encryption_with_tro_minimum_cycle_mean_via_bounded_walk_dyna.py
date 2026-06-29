from typing import List, Optional

Matrix = List[List[float]]
INF = float("inf")


def minimum_cycle_mean(a: Matrix, max_len: Optional[int] = None) -> float:
    """Minimum cycle mean min_C weight(C)/length(C): the limit of gmin(A^m)/m.

    Dynamic program over walks of bounded length (Karp-style). O(n^3) for n vertices.
    """
    n = len(a)
    if max_len is None:
        max_len = n
    best = INF
    for start in range(n):
        dist = [[INF] * n for _ in range(max_len + 1)]
        dist[0][start] = 0.0
        for length in range(1, max_len + 1):
            for u in range(n):
                if dist[length - 1][u] == INF:
                    continue
                for v in range(n):
                    cand = dist[length - 1][u] + a[u][v]
                    if cand < dist[length][v]:
                        dist[length][v] = cand
        for length in range(1, max_len + 1):
            if dist[length][start] < INF:
                best = min(best, dist[length][start] / length)
    return best
