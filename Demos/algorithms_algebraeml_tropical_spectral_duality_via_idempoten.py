"""
Tropical Spectral Duality: Core Algorithms

Implements the tropical spectral extraction algorithm for max-plus linear systems.
Provides eigenfunctional computation, observable quotient construction, and
minimal separating subfamily extraction.
"""

import numpy as np
from typing import List, Tuple, Optional
from dataclasses import dataclass


# Tropical arithmetic constants
NEG_INF = float('-inf')


def trop_add(a: float, b: float) -> float:
    """Tropical addition: max(a, b)."""
    return max(a, b)


def trop_mul(a: float, b: float) -> float:
    """Tropical multiplication: a + b (classical)."""
    if a == NEG_INF or b == NEG_INF:
        return NEG_INF
    return a + b


def trop_matvec(A: np.ndarray, x: np.ndarray) -> np.ndarray:
    """Tropical matrix-vector product: (A ⊗ x)_i = max_j (A_ij + x_j)."""
    n = A.shape[0]
    result = np.full(n, NEG_INF)
    for i in range(n):
        for j in range(A.shape[1]):
            result[i] = trop_add(result[i], trop_mul(A[i, j], x[j]))
    return result


def trop_matmul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Tropical matrix multiplication."""
    n, m = A.shape[0], B.shape[1]
    k = A.shape[1]
    C = np.full((n, m), NEG_INF)
    for i in range(n):
        for j in range(m):
            for l in range(k):
                C[i, j] = trop_add(C[i, j], trop_mul(A[i, l], B[l, j]))
    return C


def trop_matpow(A: np.ndarray, k: int) -> np.ndarray:
    """Tropical matrix power A^k."""
    n = A.shape[0]
    if k == 0:
        # Tropical identity: 0 on diagonal, -inf elsewhere
        I = np.full((n, n), NEG_INF)
        np.fill_diagonal(I, 0.0)
        return I
    result = A.copy()
    for _ in range(k - 1):
        result = trop_matmul(result, A)
    return result


@dataclass
class TropicalEigenpair:
    """A tropical eigenpair: left eigenvector (eigenfunctional) and eigenvalue."""
    eigenfunctional: np.ndarray  # Left eigenvector v such that v ⊗ A = λ ⊗ v
    eigenvalue: float            # Tropical eigenvalue λ


def max_cycle_mean(A: np.ndarray) -> float:
    """
    Compute the maximum cycle mean of a tropical matrix A.

    The maximum cycle mean is the tropical eigenvalue:
    λ = max over all cycles c of (sum of weights on c) / (length of c).

    Uses the Karp algorithm: O(n^3).

    Args:
        A: n×n matrix with entries in R ∪ {-∞}

    Returns:
        The maximum cycle mean (tropical eigenvalue)
    """
    n = A.shape[0]
    # Compute A^k for k = 0, ..., n
    powers = [trop_matpow(A, k) for k in range(n + 1)]

    # Karp's formula: λ = max_j min_k (A^n[j,j] - A^k[j,j]) / (n - k)
    best = NEG_INF
    for j in range(n):
        if powers[n][j, j] == NEG_INF:
            continue
        worst_for_j = float('inf')
        for k in range(n):
            if powers[k][j, j] == NEG_INF:
                continue
            val = (powers[n][j, j] - powers[k][j, j]) / (n - k)
            worst_for_j = min(worst_for_j, val)
        if worst_for_j != float('inf'):
            best = max(best, worst_for_j)

    return best


def critical_graph(A: np.ndarray, lam: float) -> List[Tuple[int, int]]:
    """
    Compute the critical graph of A with eigenvalue λ.

    The critical graph consists of edges (i, j) where A[i,j] + v[j] = λ + v[i]
    for some tropical eigenvector v.

    Args:
        A: n×n tropical matrix
        lam: tropical eigenvalue

    Returns:
        List of edges (i, j) in the critical graph
    """
    n = A.shape[0]
    # Normalize: B = A - λI (tropically: B[i,j] = A[i,j] - λ * δ_{ij})
    B = A.copy()
    for i in range(n):
        B[i, i] = trop_add(B[i, i], 0.0)  # Ensure diagonal has at least 0 after normalization

    # An edge (i,j) is critical if it lies on a cycle with mean exactly λ
    edges = []
    # Compute B_λ = A - λ (subtract λ from all entries)
    B_lam = A - lam
    # B_lam^* (Kleene star) gives shortest paths
    # Edge (i,j) is critical if B_lam[i,j] + (B_lam^+)[j,i] = 0
    B_plus = trop_matpow(B_lam, 1)
    for k in range(2, n + 1):
        B_plus_k = trop_matpow(B_lam, k)
        for i in range(n):
            for j in range(n):
                B_plus[i, j] = trop_add(B_plus[i, j], B_plus_k[i, j])

    for i in range(n):
        for j in range(n):
            if A[i, j] != NEG_INF:
                cycle_weight = trop_mul(B_lam[i, j], B_plus[j, i])
                if abs(cycle_weight - 0.0) < 1e-10 or cycle_weight >= -1e-10:
                    edges.append((i, j))
    return edges


def compute_tropical_eigenvectors(A: np.ndarray, lam: float) -> List[np.ndarray]:
    """
    Compute left tropical eigenvectors for eigenvalue λ.

    A left eigenvector v satisfies: v ⊗ A = λ ⊗ v
    (i.e., max_i (v_i + A[i,j]) = λ + v_j for all j)

    Args:
        A: n×n tropical matrix
        lam: tropical eigenvalue

    Returns:
        List of tropical left eigenvectors
    """
    n = A.shape[0]
    # Normalize: compute (A - λ)^* applied to unit vectors
    B = A - lam  # Subtract λ from all entries

    # Kleene star B^* = I ⊕ B ⊕ B^2 ⊕ ...
    B_star = np.full((n, n), NEG_INF)
    np.fill_diagonal(B_star, 0.0)
    B_pow = np.full((n, n), NEG_INF)
    np.fill_diagonal(B_pow, 0.0)

    for _ in range(n):
        B_pow = trop_matmul(B_pow, B)
        for i in range(n):
            for j in range(n):
                B_star[i, j] = trop_add(B_star[i, j], B_pow[i, j])

    # Each row of B_star^T gives a candidate left eigenvector
    eigenvectors = []
    for i in range(n):
        v = B_star[:, i].copy()  # Column i = left eigenvector candidate
        # Verify: v ⊗ A should equal λ ⊗ v
        vA = np.array([max(trop_mul(v[k], A[k, j]) for k in range(n)) for j in range(n)])
        lam_v = v + lam
        if np.allclose(vA[vA != NEG_INF], lam_v[vA != NEG_INF], atol=1e-10):
            eigenvectors.append(v)

    return eigenvectors


@dataclass
class SpectralDecomposition:
    """Result of tropical spectral decomposition."""
    eigenpairs: List[TropicalEigenpair]
    observer_dimension: int
    observation_matrix: np.ndarray  # n × k matrix where rows are eigenfunctionals


def tropical_spectral_decomposition(A: np.ndarray) -> SpectralDecomposition:
    """
    Compute the tropical spectral decomposition of a matrix A.

    This implements the main algorithm:
    1. Find the tropical eigenvalue (max cycle mean)
    2. Compute eigenfunctionals (left eigenvectors)
    3. Select a minimal separating family

    Args:
        A: n×n tropical matrix

    Returns:
        SpectralDecomposition with eigenpairs, observer dimension, observation matrix
    """
    n = A.shape[0]
    lam = max_cycle_mean(A)

    if lam == NEG_INF:
        return SpectralDecomposition([], 0, np.array([]))

    eigenvectors = compute_tropical_eigenvectors(A, lam)

    # Build eigenpairs
    eigenpairs = [TropicalEigenpair(v, lam) for v in eigenvectors]

    # Select minimal separating subfamily (greedy)
    if len(eigenpairs) == 0:
        return SpectralDecomposition([], 0, np.array([]))

    selected = select_minimal_separating(eigenpairs, n)

    obs_matrix = np.vstack([ep.eigenfunctional for ep in selected])

    return SpectralDecomposition(
        eigenpairs=selected,
        observer_dimension=len(selected),
        observation_matrix=obs_matrix
    )


def select_minimal_separating(
    eigenpairs: List[TropicalEigenpair],
    n: int
) -> List[TropicalEigenpair]:
    """
    Greedily select a minimal separating subfamily from eigenpairs.

    Args:
        eigenpairs: candidate eigenfunctionals
        n: state space dimension

    Returns:
        Minimal subset that separates all distinguishable state pairs
    """
    if not eigenpairs:
        return []

    selected: List[TropicalEigenpair] = []
    # Track which pairs of standard basis vectors are separated
    separated = set()

    for ep in eigenpairs:
        v = ep.eigenfunctional
        new_separations = False
        for i in range(n):
            for j in range(i + 1, n):
                if (i, j) not in separated and abs(v[i] - v[j]) > 1e-10:
                    separated.add((i, j))
                    new_separations = True
        if new_separations:
            selected.append(ep)

    return selected


def verify_eigenfunctional(
    A: np.ndarray,
    v: np.ndarray,
    lam: float,
    tol: float = 1e-10
) -> bool:
    """
    Verify that v is a left tropical eigenvector of A with eigenvalue λ.

    Checks: max_i (v_i + A[i,j]) = λ + v_j for all j.

    Args:
        A: n×n tropical matrix
        v: candidate left eigenvector
        lam: candidate eigenvalue
        tol: tolerance for floating-point comparison

    Returns:
        True if v is a valid eigenvector
    """
    n = A.shape[0]
    for j in range(n):
        lhs = max(trop_mul(v[i], A[i, j]) for i in range(n))
        rhs = trop_mul(lam, v[j])
        if abs(lhs - rhs) > tol and not (lhs == NEG_INF and rhs == NEG_INF):
            return False
    return True


def observation_map(
    x: np.ndarray,
    eigenfunctionals: List[np.ndarray]
) -> np.ndarray:
    """
    Apply the observation map: Obs(x) = (φ_1(x), ..., φ_n(x)).

    Each φ_i(x) = max_j (v_i[j] + x[j]).

    Args:
        x: state vector
        eigenfunctionals: list of eigenfunctional vectors

    Returns:
        Observation vector in S^n
    """
    result = np.zeros(len(eigenfunctionals))
    for i, v in enumerate(eigenfunctionals):
        result[i] = max(trop_mul(v[j], x[j]) for j in range(len(x)))
    return result


def verify_conjugate_scaling(
    A: np.ndarray,
    x: np.ndarray,
    eigenpairs: List[TropicalEigenpair],
    tol: float = 1e-10
) -> bool:
    """
    Verify that Obs(Tx) = λ * Obs(x) coordinatewise.

    Args:
        A: transition matrix
        x: state vector
        eigenpairs: eigenfunctional-eigenvalue pairs
        tol: tolerance

    Returns:
        True if conjugate scaling holds
    """
    Tx = trop_matvec(A, x)
    obs_x = observation_map(x, [ep.eigenfunctional for ep in eigenpairs])
    obs_Tx = observation_map(Tx, [ep.eigenfunctional for ep in eigenpairs])

    for i, ep in enumerate(eigenpairs):
        expected = trop_mul(ep.eigenvalue, obs_x[i])
        if abs(obs_Tx[i] - expected) > tol and not (obs_Tx[i] == NEG_INF and expected == NEG_INF):
            return False
    return True


if __name__ == "__main__":
    # Example: 3x3 max-plus matrix
    A = np.array([
        [2, 1, NEG_INF],
        [NEG_INF, 1, 3],
        [1, NEG_INF, 2]
    ])

    print("Tropical matrix A:")
    print(A)

    lam = max_cycle_mean(A)
    print(f"\nTropical eigenvalue (max cycle mean): {lam}")

    decomp = tropical_spectral_decomposition(A)
    print(f"\nObserver dimension: {decomp.observer_dimension}")
    print(f"Number of eigenpairs: {len(decomp.eigenpairs)}")

    for i, ep in enumerate(decomp.eigenpairs):
        print(f"\nEigenpair {i+1}:")
        print(f"  Eigenfunctional: {ep.eigenfunctional}")
        print(f"  Eigenvalue: {ep.eigenvalue}")
        valid = verify_eigenfunctional(A, ep.eigenfunctional, ep.eigenvalue)
        print(f"  Valid: {valid}")

    # Test conjugate scaling
    x = np.array([1.0, 2.0, 0.0])
    print(f"\nTest state x = {x}")
    valid = verify_conjugate_scaling(A, x, decomp.eigenpairs)
    print(f"Conjugate scaling verified: {valid}")
