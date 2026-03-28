"""
Tropical Tensor Products and Entanglement
==========================================

Implements tropical tensor algebra:
    - Tropical tensor product: (a ⊗_T b)_{ij} = a_i + b_j (outer sum)
    - Tropical matrix rank (Barvinok rank): min # of outer-sum terms
    - Tropical entanglement: rank > 1 means entangled
    - Tropical partial trace
    - Tropical Schmidt decomposition (tropical SVD)
"""

import numpy as np
from typing import Tuple, List, Optional
from qtlib.semiring import TROP_NEG_INF, trop_add, trop_mul, trop_outer_sum, trop_matmul


class TropicalTensor:
    """An n-dimensional tropical tensor (max-plus array).

    Operations use tropical semiring arithmetic:
        addition = max, multiplication = plus.

    Parameters
    ----------
    data : np.ndarray
        The tensor values. -∞ represents the tropical zero.
    """

    def __init__(self, data: np.ndarray):
        self.data = np.asarray(data, dtype=float)
        self.shape = self.data.shape
        self.ndim = self.data.ndim

    def __repr__(self):
        return f"TropicalTensor(shape={self.shape})"

    def __add__(self, other: 'TropicalTensor') -> 'TropicalTensor':
        """Tropical addition: elementwise max"""
        return TropicalTensor(np.maximum(self.data, other.data))

    def __matmul__(self, other: 'TropicalTensor') -> 'TropicalTensor':
        """Tropical matrix multiplication: max_j(A_{ij} + B_{jk})"""
        return TropicalTensor(trop_matmul(self.data, other.data))

    def tropical_trace(self) -> float:
        """Tropical trace: max of diagonal elements = max_i A_{ii}"""
        assert self.ndim == 2 and self.shape[0] == self.shape[1]
        return float(np.max(np.diag(self.data)))

    def tropical_transpose(self) -> 'TropicalTensor':
        """Transpose"""
        return TropicalTensor(self.data.T)

    def tropical_norm(self) -> float:
        """Tropical norm: max of all elements"""
        return float(np.max(self.data))

    @staticmethod
    def tropical_identity(n: int) -> 'TropicalTensor':
        """Tropical identity matrix: I_{ii} = 0, I_{ij} = -∞ for i≠j"""
        data = np.full((n, n), TROP_NEG_INF)
        np.fill_diagonal(data, 0.0)
        return TropicalTensor(data)

    @staticmethod
    def tropical_zero_matrix(m: int, n: int) -> 'TropicalTensor':
        """Tropical zero matrix: all entries = -∞"""
        return TropicalTensor(np.full((m, n), TROP_NEG_INF))


def tropical_tensor_product(a: np.ndarray, b: np.ndarray) -> np.ndarray:
    """Tropical tensor product (outer sum): C_{ij} = a_i + b_j

    In quantum mechanics, the tensor product of states gives the joint state.
    In tropical mechanics, this becomes the outer sum.

    Parameters
    ----------
    a : array of shape (m,)
    b : array of shape (n,)

    Returns
    -------
    C : array of shape (m, n) where C_{ij} = a_i + b_j
    """
    return trop_outer_sum(np.asarray(a), np.asarray(b))


def tropical_rank(M: np.ndarray, max_rank: int = None, tol: float = 1e-6) -> int:
    """Compute the tropical rank (Barvinok rank) of a matrix.

    The tropical rank is the minimum number k such that M can be written as:
        M = max(a¹ᵢ + b¹ⱼ, a²ᵢ + b²ⱼ, ..., aᵏᵢ + bᵏⱼ)

    i.e., the tropical sum of k rank-1 (outer sum) terms.

    This is NP-hard in general. We use a greedy heuristic:
    repeatedly subtract the best rank-1 approximation.

    Parameters
    ----------
    M : array of shape (m, n)
    max_rank : int, optional
        Maximum rank to check (default: min(m, n))
    tol : float
        Tolerance for considering the residual as -∞

    Returns
    -------
    rank : int
        Estimated tropical rank
    """
    M = np.asarray(M, dtype=float)
    m, n = M.shape
    if max_rank is None:
        max_rank = min(m, n)

    residual = M.copy()
    rank = 0

    for _ in range(max_rank):
        # Check if residual is all -∞
        if np.all(residual <= TROP_NEG_INF + 1e10):
            break

        # Find best rank-1 approximation: a_i + b_j ≈ M_{ij}
        # Heuristic: use row and column medians
        valid = residual > TROP_NEG_INF + 1e10
        if not np.any(valid):
            break

        # Use the row with most valid entries
        best_row = np.argmax(np.sum(valid, axis=1))
        b = residual[best_row, :].copy()

        # Compute a_i = median_j(M_{ij} - b_j) for valid entries
        a = np.full(m, TROP_NEG_INF)
        for i in range(m):
            diffs = []
            for j in range(n):
                if valid[i, j] and b[j] > TROP_NEG_INF + 1e10:
                    diffs.append(residual[i, j] - b[j])
            if diffs:
                a[i] = np.median(diffs)

        # Compute rank-1 approximation
        approx = trop_outer_sum(a, b)

        # "Subtract" in tropical sense: set matched entries to -∞
        matched = np.abs(residual - approx) < tol
        covered = np.logical_and(matched, valid)
        if np.any(covered):
            residual[covered] = TROP_NEG_INF
            rank += 1
        else:
            # Greedy step didn't help; increment rank for remaining
            rank += 1
            break

    if np.any(residual > TROP_NEG_INF + 1e10):
        rank = max_rank  # Could not decompose fully

    return max(1, rank)


def tropical_entanglement(M: np.ndarray) -> dict:
    """Measure tropical entanglement of a bipartite tropical state.

    A tropical state matrix M is "separable" (unentangled) if it has
    tropical rank 1, i.e., M_{ij} = a_i + b_j for some vectors a, b.

    Parameters
    ----------
    M : array of shape (m, n)
        Tropical state matrix of a bipartite system

    Returns
    -------
    dict with keys:
        'rank': estimated tropical rank
        'is_entangled': True if rank > 1
        'entanglement_measure': log(rank) (tropical analogue of entanglement entropy)
        'best_separable': best rank-1 approximation
    """
    M = np.asarray(M, dtype=float)
    rank = tropical_rank(M)

    # Best rank-1 approximation
    row_means = np.array([np.max(M[i, :]) for i in range(M.shape[0])])
    col_means = np.array([np.max(M[:, j]) for j in range(M.shape[1])])
    # Adjust to minimize tropical distance
    total = np.max(M)
    a = row_means - total / 2
    b = col_means - total / 2
    best_sep = trop_outer_sum(a, b)

    return {
        'rank': rank,
        'is_entangled': rank > 1,
        'entanglement_measure': np.log(max(1, rank)),
        'best_separable': best_sep,
    }


def tropical_partial_trace(M: np.ndarray, dims: Tuple[int, int],
                           trace_system: int = 1) -> np.ndarray:
    """Tropical partial trace: max over the traced-out system.

    For a bipartite state M of shape (d1*d2,) reshaped to (d1, d2):
        Tr_2(M)_i = max_j M_{ij}    (trace out system 2)
        Tr_1(M)_j = max_i M_{ij}    (trace out system 1)

    This is the tropical analogue of the quantum partial trace.

    Parameters
    ----------
    M : array of shape (d1, d2) or (d1*d2,)
    dims : tuple (d1, d2)
    trace_system : int (1 or 2)
        Which system to trace out

    Returns
    -------
    reduced : array of shape (d_remaining,)
    """
    d1, d2 = dims
    if M.ndim == 1:
        M = M.reshape(d1, d2)

    if trace_system == 2:
        return np.max(M, axis=1)  # max over columns
    else:
        return np.max(M, axis=0)  # max over rows


def tropical_schmidt_decomposition(M: np.ndarray, k: int = None) -> dict:
    """Tropical Schmidt decomposition via tropical SVD.

    Decomposes M ≈ max_{r=1}^{k} (u^r_i + σ_r + v^r_j)

    where σ_1 ≥ σ_2 ≥ ... are the tropical singular values.

    Uses standard SVD on exp(M) and takes logarithms (Viro's method).

    Parameters
    ----------
    M : array of shape (m, n)
    k : int, optional
        Number of terms (default: min(m, n))

    Returns
    -------
    dict with keys:
        'singular_values': tropical singular values σ_r
        'left_vectors': array of shape (k, m)
        'right_vectors': array of shape (k, n)
        'rank': number of significant terms
    """
    M = np.asarray(M, dtype=float)
    m, n = M.shape
    if k is None:
        k = min(m, n)

    # Shift for numerical stability
    shift = np.max(M)
    M_shifted = M - shift

    # Use exp → SVD → log (Viro's correspondence)
    exp_M = np.exp(M_shifted)
    U, S, Vt = np.linalg.svd(exp_M, full_matrices=False)

    # Take logs (with protection against zeros)
    S = S[:k]
    trop_sigmas = np.log(S + 1e-300) + shift
    trop_U = np.log(np.abs(U[:, :k]) + 1e-300)
    trop_V = np.log(np.abs(Vt[:k, :]) + 1e-300)

    # Determine significant rank
    threshold = trop_sigmas[0] - 20  # 20 orders of magnitude
    rank = int(np.sum(trop_sigmas > threshold))

    return {
        'singular_values': trop_sigmas,
        'left_vectors': trop_U.T,
        'right_vectors': trop_V,
        'rank': rank,
    }
