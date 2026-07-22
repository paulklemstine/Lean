from __future__ import annotations
from typing import List

def prime_cycle_counts(adjacency: List[List[float]], max_len: int) -> List[int]:
    """Count primitive non-backtracking closed cycles by length using the
    Hashimoto (non-backtracking) edge operator B and Mobius inversion.

    trace(B^m) counts closed non-backtracking walks of length m; a primitive of
    length d contributes d such walks at every multiple of d, so
        sum_{d | m} d * Prim(d) = trace(B^m).
    """
    edges = [(i, j) for i in range(len(adjacency))
             for j in range(len(adjacency)) if adjacency[i][j]]
    m = len(edges)
    B = [[1 if (edges[a][1] == edges[b][0] and edges[b][1] != edges[a][0]) else 0
          for b in range(m)] for a in range(m)]

    def matmul(X, Y):
        return [[sum(X[r][t] * Y[t][c] for t in range(m)) for c in range(m)]
                for r in range(m)]

    power = [[1 if r == c else 0 for c in range(m)] for r in range(m)]
    traces: List[int] = []
    for _ in range(max_len):
        power = matmul(power, B)
        traces.append(sum(power[i][i] for i in range(m)))

    prim = [0] * (max_len + 1)
    for k in range(1, max_len + 1):
        total = traces[k - 1]
        for d in range(1, k):
            if k % d == 0:
                total -= d * prim[d]
        prim[k] = total // k
    return prim[1:]
