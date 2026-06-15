from typing import List, Sequence

def congruence(J: Sequence[Sequence[float]],
               G: Sequence[Sequence[float]]) -> List[List[float]]:
    """Compute G'[a][b] = sum_{i,j} J[a][i] G[i][j] J[b][j]."""
    d = len(G)
    out = [[0.0 for _ in range(d)] for _ in range(d)]
    for a in range(d):
        for b in range(d):
            out[a][b] = sum(J[a][i]*G[i][j]*J[b][j]
                            for i in range(d) for j in range(d))
    return out