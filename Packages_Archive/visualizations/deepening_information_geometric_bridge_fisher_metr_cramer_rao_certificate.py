from typing import Dict, Sequence

def fisher_matrix(p: Sequence[float],
                  score: Sequence[Sequence[float]]):
    n = len(p); d = len(score[0]) if n else 0
    G = [[0.0]*d for _ in range(d)]
    for x in range(n):
        for i in range(d):
            for j in range(d):
                G[i][j] += p[x]*score[x][i]*score[x][j]
    return G

def cramer_rao_certificate(p: Sequence[float],
                           score: Sequence[Sequence[float]],
                           T: Sequence[float], i: int = 0) -> Dict[str, float]:
    """Single-parameter Cramer-Rao certificate for statistic T."""
    psi = sum(p[x]*T[x] for x in range(len(p)))
    psi_prime = sum(p[x]*(T[x]-psi)*score[x][i] for x in range(len(p)))
    var = sum(p[x]*(T[x]-psi)**2 for x in range(len(p)))
    Gii = fisher_matrix(p, score)[i][i]
    bound = psi_prime**2 / Gii if Gii > 0 else float('inf')
    return {'psi': psi, 'psi_prime': psi_prime, 'variance': var,
            'fisher': Gii, 'cr_bound': bound, 'slack': var - bound}