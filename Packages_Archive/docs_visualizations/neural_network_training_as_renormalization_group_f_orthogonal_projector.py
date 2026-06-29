from typing import List
import numpy as np

def orthogonal_projector(basis: List[List[float]]) -> np.ndarray:
    """
    Build the idempotent, self-adjoint coarse-graining operator P that projects
    orthogonally onto span(basis) (the 'relevant' subspace).

    P = Q @ Q.T where Q has orthonormal columns spanning the relevant subspace,
    obtained by QR factorization (Gram-Schmidt). By construction
        P @ P = Q (Q.T Q) Q.T = Q Q.T = P   (idempotent)
        P.T   = P                            (self-adjoint).
    """
    A = np.array(basis, dtype=float).T          # columns = basis vectors
    Q, _ = np.linalg.qr(A)                       # orthonormal columns
    return Q @ Q.T
