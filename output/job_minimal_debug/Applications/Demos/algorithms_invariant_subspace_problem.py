"""
Invariant Subspace Problem: Algorithms and Computational Tools

Type-hinted implementations for numerical exploration of invariant subspaces
of bounded linear operators on Hilbert spaces (truncated to finite dimensions).
"""

from typing import List, Tuple, Optional
import numpy as np
from numpy.typing import NDArray


def eigenspace_projection(
    T: NDArray[np.complex128], mu: complex, tol: float = 1e-10
) -> NDArray[np.complex128]:
    """Compute the orthogonal projection onto the eigenspace of T for eigenvalue mu.

    Args:
        T: Square matrix (n x n) representing the operator.
        mu: The eigenvalue.
        tol: Tolerance for eigenvalue matching.

    Returns:
        Orthogonal projection matrix onto the mu-eigenspace.
    """
    n = T.shape[0]
    eigenvalues, eigenvectors = np.linalg.eig(T)
    # Select eigenvectors corresponding to mu
    mask = np.abs(eigenvalues - mu) < tol
    if not np.any(mask):
        return np.zeros((n, n), dtype=complex)
    V = eigenvectors[:, mask]
    # Orthogonalize via QR
    Q, _ = np.linalg.qr(V, mode='reduced')
    return Q @ Q.conj().T


def find_invariant_subspace(
    T: NDArray[np.complex128],
) -> Tuple[Optional[NDArray[np.complex128]], str]:
    """Attempt to find a nontrivial closed invariant subspace for T.

    Strategy: Try eigenspaces first, then kernel, then cyclic subspaces.

    Args:
        T: Square matrix (n x n).

    Returns:
        Tuple of (basis_matrix_or_None, method_description).
    """
    n = T.shape[0]
    if n <= 1:
        return None, "Space too small for nontrivial invariant subspace"

    eigenvalues, eigenvectors = np.linalg.eig(T)

    # Strategy 1: Eigenspace for each eigenvalue
    for i, mu in enumerate(eigenvalues):
        P = eigenspace_projection(T, mu)
        rank = int(np.round(np.trace(P).real))
        if 0 < rank < n:
            return P, f"Eigenspace for mu={mu:.4f} (dim={rank})"

    # Strategy 2: Kernel
    _, s, _ = np.linalg.svd(T)
    kernel_dim = np.sum(s < 1e-10)
    if 0 < kernel_dim < n:
        # Compute kernel basis
        _, _, Vh = np.linalg.svd(T)
        K = Vh[-int(kernel_dim):].conj().T
        P = K @ K.conj().T
        return P, f"Kernel (dim={int(kernel_dim)})"

    # Strategy 3: Cyclic subspace from random vector
    x = np.random.randn(n) + 1j * np.random.randn(n)
    x = x / np.linalg.norm(x)
    orbit = [x]
    for k in range(1, n):
        v = np.linalg.matrix_power(T, k) @ x
        orbit.append(v)
    V = np.column_stack(orbit)
    Q, R = np.linalg.qr(V)
    rank = np.sum(np.abs(np.diag(R)) > 1e-10)
    if 0 < rank < n:
        Q_trunc = Q[:, :rank]
        P = Q_trunc @ Q_trunc.conj().T
        return P, f"Cyclic subspace (dim={rank})"

    return None, "No nontrivial invariant subspace found"


def spectral_decomposition_depth(
    T: NDArray[np.complex128], max_commutants: int = 100
) -> int:
    """Estimate the spectral decomposition depth of T.

    Searches for compact (finite-rank) operators commuting with T that have
    distinct nonzero eigenvalues.

    Args:
        T: Square matrix (n x n).
        max_commutants: Number of random compact commutants to try.

    Returns:
        Lower bound on spectral decomposition depth.
    """
    n = T.shape[0]
    best_depth = 0

    for _ in range(max_commutants):
        # Generate random low-rank matrix
        rank = np.random.randint(1, max(2, n // 2))
        A = np.random.randn(n, rank) + 1j * np.random.randn(n, rank)
        B = np.random.randn(rank, n) + 1j * np.random.randn(rank, n)
        K_init = A @ B

        # Project onto commutant: solve TK = KT via Sylvester equation
        # K_comm = solution to T @ K - K @ T = 0 closest to K_init
        # Use iterative projection
        K = K_init.copy()
        for _ in range(50):
            commutator = T @ K - K @ T
            K = K - 0.1 * commutator

        # Check commutation quality
        comm_norm = np.linalg.norm(T @ K - K @ T) / max(np.linalg.norm(K), 1e-15)
        if comm_norm > 1e-6:
            continue

        # Count distinct nonzero eigenvalues
        eigs = np.linalg.eigvals(K)
        nonzero_eigs = eigs[np.abs(eigs) > 1e-8]
        if len(nonzero_eigs) == 0:
            continue

        # Cluster eigenvalues
        clusters: List[complex] = []
        for e in nonzero_eigs:
            if all(abs(e - c) > 1e-6 for c in clusters):
                clusters.append(e)

        best_depth = max(best_depth, len(clusters))

    return best_depth


def is_hyperinvariant(
    T: NDArray[np.complex128],
    P: NDArray[np.complex128],
    num_tests: int = 100,
    tol: float = 1e-8,
) -> bool:
    """Test whether a subspace (given by projection P) is hyperinvariant for T.

    Checks that P S P = S P for random operators S commuting with T.

    Args:
        T: The operator matrix.
        P: Orthogonal projection onto the candidate subspace.
        num_tests: Number of random commutants to test.
        tol: Tolerance for invariance check.

    Returns:
        True if the subspace appears hyperinvariant.
    """
    n = T.shape[0]
    for _ in range(num_tests):
        # Generate random matrix and project to commutant
        S = np.random.randn(n, n) + 1j * np.random.randn(n, n)
        for _ in range(100):
            comm = T @ S - S @ T
            S = S - 0.1 * comm

        if np.linalg.norm(T @ S - S @ T) / max(np.linalg.norm(S), 1e-15) > 1e-6:
            continue

        # Check invariance: P S (I - P) should be zero
        residual = P @ S @ (np.eye(n) - P)
        if np.linalg.norm(residual) > tol * np.linalg.norm(S):
            return False

    return True


def weighted_shift_matrix(weights: List[complex], n: int) -> NDArray[np.complex128]:
    """Construct a weighted shift operator truncated to n dimensions.

    The weighted shift S_w maps e_k -> w_k * e_{k+1} for k < n-1.

    Args:
        weights: Weight sequence (at least n-1 elements, or cycled).
        n: Matrix dimension.

    Returns:
        n x n matrix for the weighted shift.
    """
    T = np.zeros((n, n), dtype=complex)
    for k in range(n - 1):
        w = weights[k % len(weights)]
        T[k + 1, k] = w
    return T


def test_cyclic_vector(
    T: NDArray[np.complex128], x: NDArray[np.complex128], tol: float = 1e-8
) -> Tuple[bool, int]:
    """Test whether x is a cyclic vector for T.

    Checks if span{x, Tx, T^2 x, ...} = entire space.

    Args:
        T: Square matrix.
        x: Test vector.
        tol: Tolerance for rank computation.

    Returns:
        (is_cyclic, dimension_of_cyclic_subspace).
    """
    n = T.shape[0]
    vectors = [x]
    for k in range(1, n):
        vectors.append(np.linalg.matrix_power(T, k) @ x)
    V = np.column_stack(vectors)
    _, s, _ = np.linalg.svd(V)
    rank = int(np.sum(s > tol))
    return rank == n, rank


def compute_reducing_subspace(
    T: NDArray[np.complex128], tol: float = 1e-8
) -> Optional[NDArray[np.complex128]]:
    """Find a reducing subspace for T (invariant for both T and T*).

    For normal operators, every invariant subspace is reducing.

    Args:
        T: Square matrix.
        tol: Tolerance.

    Returns:
        Projection onto reducing subspace, or None.
    """
    n = T.shape[0]
    T_adj = T.conj().T

    # For normal operators, eigenspaces are reducing
    eigenvalues, eigenvectors = np.linalg.eig(T)

    # Group eigenvalues into clusters
    clusters: List[List[int]] = []
    assigned = set()
    for i in range(n):
        if i in assigned:
            continue
        cluster = [i]
        assigned.add(i)
        for j in range(i + 1, n):
            if j not in assigned and abs(eigenvalues[i] - eigenvalues[j]) < tol:
                cluster.append(j)
                assigned.add(j)
        clusters.append(cluster)

    # Find a cluster that gives a proper subspace
    for cluster in clusters:
        if 0 < len(cluster) < n:
            V = eigenvectors[:, cluster]
            Q, _ = np.linalg.qr(V, mode='reduced')
            P = Q @ Q.conj().T

            # Verify reducing: check both T and T* invariance
            res_T = np.linalg.norm(P @ T @ (np.eye(n) - P))
            res_Tadj = np.linalg.norm(P @ T_adj @ (np.eye(n) - P))

            if res_T < tol and res_Tadj < tol:
                return P

    return None
