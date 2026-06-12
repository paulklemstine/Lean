from typing import List, Sequence

def fisher_matrix(p: Sequence[float], score: Sequence[Sequence[float]]) -> List[List[float]]:
    """Build the Fisher information matrix from probabilities and a score table.

    G[i][j] = sum_x p[x] * score[x][i] * score[x][j].
    Complexity: O(n * d^2).
    """
    n = len(p)
    d = len(score[0]) if n > 0 else 0
    G: List[List[float]] = [[0.0]*d for _ in range(d)]
    for x in range(n):
        px = p[x]
        sx = score[x]
        for i in range(d):
            psi = px * sx[i]
            for j in range(d):
                G[i][j] += psi * sx[j]
    return G
