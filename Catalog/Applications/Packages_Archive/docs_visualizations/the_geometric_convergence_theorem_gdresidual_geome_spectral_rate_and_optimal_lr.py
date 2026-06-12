import math
from typing import List, Tuple

Matrix = List[List[float]]

def sym_eigenvalues(A: Matrix, sweeps: int = 100) -> List[float]:
    n = len(A)
    M = [row[:] for row in A]
    for _ in range(sweeps):
        off = 0.0
        p, q = 0, 1
        for i in range(n):
            for j in range(i + 1, n):
                if abs(M[i][j]) > off:
                    off = abs(M[i][j]); p, q = i, j
        if off < 1e-14:
            break
        app, aqq, apq = M[p][p], M[q][q], M[p][q]
        theta = (aqq - app) / (2.0 * apq)
        t = math.copysign(1.0, theta) / (abs(theta) + math.sqrt(theta * theta + 1.0))
        c = 1.0 / math.sqrt(t * t + 1.0)
        s = t * c
        for k in range(n):
            kp, kq = M[k][p], M[k][q]
            M[k][p] = c * kp - s * kq; M[k][q] = s * kp + c * kq
        for k in range(n):
            pk, qk = M[p][k], M[q][k]
            M[p][k] = c * pk - s * qk; M[q][k] = s * pk + c * qk
    return sorted((M[i][i] for i in range(n)), reverse=True)

def spectral_rate_and_optimal_lr(K: Matrix) -> Tuple[float, float, float, float]:
    """Returns (mu, L, eta_star, optimal_contraction)."""
    eigs = sym_eigenvalues(K)
    L, mu = eigs[0], eigs[-1]
    eta_star = 2.0 / (mu + L)
    rate = (L - mu) / (L + mu)
    return mu, L, eta_star, rate
