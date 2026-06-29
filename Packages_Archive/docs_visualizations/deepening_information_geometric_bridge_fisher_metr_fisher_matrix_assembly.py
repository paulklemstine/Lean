from typing import List, Sequence

def fisher_matrix(p: Sequence[float],
                  score: Sequence[Sequence[float]]) -> List[List[float]]:
    """Fisher information matrix G[i][j] = sum_x p[x]*s[x][i]*s[x][j]."""
    n = len(p)
    d = len(score[0]) if n else 0
    G = [[0.0 for _ in range(d)] for _ in range(d)]
    for x in range(n):
        for i in range(d):
            for j in range(d):
                G[i][j] += p[x] * score[x][i] * score[x][j]
    return G