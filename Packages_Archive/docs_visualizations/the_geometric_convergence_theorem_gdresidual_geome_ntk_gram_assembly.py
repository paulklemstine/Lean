from typing import List

Matrix = List[List[float]]

def ntk_gram_assembly(phi: Matrix) -> Matrix:
    """K_{ij} = <phi_i, phi_j> = (phi phi^T)_{ij}; symmetric PSD by construction."""
    n = len(phi)
    p = len(phi[0]) if n else 0
    K: Matrix = [[0.0] * n for _ in range(n)]
    for i in range(n):
        for j in range(i, n):
            s = 0.0
            for k in range(p):
                s += phi[i][k] * phi[j][k]
            K[i][j] = s
            K[j][i] = s
    return K
