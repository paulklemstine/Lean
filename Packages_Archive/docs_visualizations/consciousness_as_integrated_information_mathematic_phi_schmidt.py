import numpy as np


def phi_schmidt(coeff_matrix: np.ndarray) -> int:
    """Bipartite quantum Phi: Schmidt rank (matrix rank of the reshaped
    amplitude matrix) minus one. Phi = 0 iff the state is separable."""
    return max(int(np.linalg.matrix_rank(coeff_matrix)) - 1, 0)
