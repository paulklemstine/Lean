"""
Algorithms for Quantum DPP Entanglement via Lorentzian Geometry.

Implements the core computational pipeline:
1. Binary entropy and fermionic entropy computation
2. DPP partition polynomial evaluation
3. Hessian signature computation at derivative leaves
4. Lorentzian entanglement witness extraction
5. Balanced bipartition enumeration and entropy profiling

All algorithms mirror the formally verified Lean definitions in
Pythagorean/QuantumDPPEntanglement.lean.
"""

import numpy as np
from itertools import combinations
from typing import List, Tuple, Dict, Optional
import warnings


def binary_entropy(x: float) -> float:
    """Binary Shannon entropy h(x) = -x log(x) - (1-x) log(1-x).

    Handles boundary cases h(0) = h(1) = 0 via the convention 0 log 0 = 0.

    >>> abs(binary_entropy(0.5) - np.log(2)) < 1e-10
    True
    >>> binary_entropy(0.0)
    0.0
    >>> binary_entropy(1.0)
    0.0
    """
    if x <= 0 or x >= 1:
        return 0.0
    return -x * np.log(x) - (1 - x) * np.log(1 - x)


def fermionic_entropy(eigenvalues: np.ndarray) -> float:
    """Fermionic entanglement entropy S = sum_i h(lambda_i).

    Args:
        eigenvalues: Array of eigenvalues in [0, 1] (single-particle
            entanglement spectrum).

    Returns:
        The fermionic entropy as a nonnegative real number.

    >>> fermionic_entropy(np.array([0.5, 0.5]))
    1.3862943611198906
    """
    return sum(binary_entropy(lam) for lam in eigenvalues)


def fermionic_entropy_diag(p: np.ndarray, A: List[int]) -> float:
    """Fermionic entropy for a diagonal kernel diag(p) restricted to subset A.

    This directly mirrors QDE.fermionicEntropyDiag in the Lean formalization.

    Args:
        p: Diagonal entries (occupation probabilities) in [0, 1].
        A: List of indices forming the subsystem.

    Returns:
        sum_{i in A} h(p_i).
    """
    return sum(binary_entropy(p[i]) for i in A)


def principal_submatrix(K: np.ndarray, A: List[int]) -> np.ndarray:
    """Extract the principal submatrix K_A.

    Args:
        K: n×n symmetric matrix.
        A: List of indices.

    Returns:
        |A|×|A| matrix K[A, A].
    """
    idx = np.array(A)
    return K[np.ix_(idx, idx)]


def fermionic_entropy_matrix(K: np.ndarray, A: List[int]) -> float:
    """Fermionic entropy for a general kernel K restricted to subset A.

    Computes S_A(K) = sum_i h(lambda_i(K_A)) where K_A is the principal
    submatrix and lambda_i are its eigenvalues.

    Args:
        K: n×n symmetric PSD contraction matrix.
        A: List of indices forming the subsystem.

    Returns:
        The fermionic entropy S_A(K).
    """
    if len(A) == 0:
        return 0.0
    K_A = principal_submatrix(K, A)
    eigenvalues = np.linalg.eigvalsh(K_A)
    eigenvalues = np.clip(eigenvalues, 0.0, 1.0)
    return fermionic_entropy(eigenvalues)


def two_by_two_principal_minor(K: np.ndarray, i: int, j: int) -> float:
    """Compute the 2×2 principal minor det(K_{i,j}).

    Returns K[i,i]*K[j,j] - K[i,j]*K[j,i].
    """
    return K[i, i] * K[j, j] - K[i, j] * K[j, i]


def leaf_curvature_pair_witness(K: np.ndarray, i: int, j: int) -> float:
    """Leaf curvature pair witness: K[i,j]^2."""
    return K[i, j] ** 2


def pos_index_2x2(a: float, b: float, c: float) -> int:
    """Number of positive eigenvalues of [[a, b], [b, c]].

    Mirrors QDE.posIndex2x2 in the Lean formalization.

    Args:
        a, b, c: Entries of the symmetric matrix [[a,b],[b,c]].

    Returns:
        Count of positive eigenvalues (0, 1, or 2).
    """
    det = a * c - b ** 2
    tr = a + c
    if det > 1e-15:
        return 2 if tr > 0 else 0
    elif det < -1e-15:
        return 1
    else:
        return 1 if tr > 1e-15 else 0


def hessian_pos_index_at_leaf_diagonal(p: np.ndarray, i: int, j: int) -> int:
    """Hessian positive index at degree-2 derivative leaf for diagonal kernel.

    For diag(p), the leaf Hessian at (i,j) is [[0, p_i*p_j*c], [same, 0]].
    Positive index is 1 if p_i*p_j > 0, else 0.

    Mirrors QDE.hessianPosIndexAtLeaf.
    """
    return pos_index_2x2(0, p[i] * p[j], 0)


def dpp_partition_polynomial_coeff(K: np.ndarray, S: List[int]) -> float:
    """Coefficient of prod_{i in S} x_i in Z_K = det(I + diag(x) K).

    This equals det(K_S), the principal minor indexed by S.
    """
    if len(S) == 0:
        return 1.0
    return np.linalg.det(principal_submatrix(K, S))


def dpp_partition_polynomial_eval(K: np.ndarray, x: np.ndarray) -> float:
    """Evaluate Z_K(x) = det(I + diag(x) K)."""
    n = K.shape[0]
    return np.linalg.det(np.eye(n) + np.diag(x) @ K)


def balanced_bipartitions(n: int) -> List[List[int]]:
    """Enumerate all balanced bipartitions of [n] (subsets of size n//2).

    Mirrors QDE.balancedBipartitions.
    """
    return [list(c) for c in combinations(range(n), n // 2)]


def leaf_signature_profile(K: np.ndarray) -> Dict[Tuple[int, int], int]:
    """Compute the leaf signature profile for all pairs.

    For each pair (i,j), compute the Hessian positive index of the
    degree-2 derivative leaf of Z_K.

    For a general kernel, the degree-2 leaf at (i,j) (obtained by
    differentiating all variables except x_i, x_j) gives a quadratic
    whose Hessian encodes the correlation structure.
    """
    n = K.shape[0]
    profile = {}
    for i in range(n):
        for j in range(i + 1, n):
            # For general K, the Hessian of the degree-2 leaf at (i,j)
            # relates to the 2×2 principal minor structure
            minor = two_by_two_principal_minor(K, i, j)
            # The Hessian is related to [[K_ii, K_ij], [K_ji, K_jj]]
            # but as a curvature measure we look at the off-diagonal
            profile[(i, j)] = pos_index_2x2(0, K[i, j], 0)
    return profile


def lorentzian_entanglement_witness(K: np.ndarray) -> float:
    """Compute the Lorentzian entanglement witness.

    Returns the maximum leaf curvature over all pairs:
    max_{i,j} K[i,j]^2.
    """
    n = K.shape[0]
    max_curv = 0.0
    for i in range(n):
        for j in range(i + 1, n):
            curv = leaf_curvature_pair_witness(K, i, j)
            max_curv = max(max_curv, curv)
    return max_curv


def min_balanced_entropy(K: np.ndarray) -> float:
    """Minimum fermionic entropy over all balanced bipartitions.

    Args:
        K: n×n symmetric PSD contraction matrix.

    Returns:
        min_{A in B_n} S_A(K).
    """
    n = K.shape[0]
    bipartitions = balanced_bipartitions(n)
    if not bipartitions:
        return 0.0
    return min(fermionic_entropy_matrix(K, A) for A in bipartitions)


def max_leaf_pos_index(K: np.ndarray) -> int:
    """Maximum Hessian positive index over all degree-2 derivative leaves.

    For a general kernel, estimates the positive index from the
    off-diagonal structure.
    """
    profile = leaf_signature_profile(K)
    if not profile:
        return 0
    return max(profile.values())


def random_psd_contraction(n: int, rng: Optional[np.random.Generator] = None) -> np.ndarray:
    """Generate a random PSD contraction matrix (eigenvalues in [0,1]).

    Args:
        n: Matrix dimension.
        rng: Random number generator.

    Returns:
        n×n symmetric PSD matrix with eigenvalues in [0, 1].
    """
    if rng is None:
        rng = np.random.default_rng()
    # Random orthogonal matrix
    A = rng.standard_normal((n, n))
    Q, _ = np.linalg.qr(A)
    # Random eigenvalues in [0, 1]
    eigenvalues = rng.uniform(0, 1, n)
    return Q @ np.diag(eigenvalues) @ Q.T


def projection_kernel(n: int, k: int,
                      rng: Optional[np.random.Generator] = None) -> np.ndarray:
    """Generate a rank-k projection kernel.

    Args:
        n: Matrix dimension.
        k: Rank of the projection.
        rng: Random number generator.

    Returns:
        n×n rank-k projection matrix (eigenvalues in {0, 1}).
    """
    if rng is None:
        rng = np.random.default_rng()
    A = rng.standard_normal((n, k))
    Q, _ = np.linalg.qr(A)
    return Q @ Q.T


def diagonal_kernel(p: np.ndarray) -> np.ndarray:
    """Create a diagonal kernel from occupation probabilities."""
    return np.diag(p)


def toeplitz_kernel(n: int, rho: float) -> np.ndarray:
    """Create a Toeplitz correlation kernel K[i,j] = rho^|i-j| * scale.

    Scaled so eigenvalues lie in [0, 1].
    """
    K = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            K[i, j] = rho ** abs(i - j)
    # Scale to ensure eigenvalues in [0, 1]
    max_eig = np.max(np.linalg.eigvalsh(K))
    if max_eig > 0:
        K /= max_eig
    return K


def entropy_witness_correlation(
    n: int,
    num_samples: int = 100,
    kernel_type: str = "random",
    seed: int = 42
) -> Dict[str, np.ndarray]:
    """Compute correlation between min entropy and max leaf signature.

    Args:
        n: Matrix dimension.
        num_samples: Number of random kernels to sample.
        kernel_type: One of "random", "projection", "diagonal", "toeplitz".
        seed: Random seed.

    Returns:
        Dictionary with 'min_entropy', 'max_leaf_index', 'witness' arrays.
    """
    rng = np.random.default_rng(seed)
    min_entropies = np.zeros(num_samples)
    max_indices = np.zeros(num_samples)
    witnesses = np.zeros(num_samples)

    for s in range(num_samples):
        if kernel_type == "random":
            K = random_psd_contraction(n, rng)
        elif kernel_type == "projection":
            k = rng.integers(1, n)
            K = projection_kernel(n, k, rng)
        elif kernel_type == "diagonal":
            p = rng.uniform(0, 1, n)
            K = diagonal_kernel(p)
        elif kernel_type == "toeplitz":
            rho = rng.uniform(0.1, 0.99)
            K = toeplitz_kernel(n, rho)
        else:
            raise ValueError(f"Unknown kernel type: {kernel_type}")

        min_entropies[s] = min_balanced_entropy(K)
        max_indices[s] = max_leaf_pos_index(K)
        witnesses[s] = lorentzian_entanglement_witness(K)

    return {
        'min_entropy': min_entropies,
        'max_leaf_index': max_indices,
        'witness': witnesses,
    }


if __name__ == "__main__":
    # Quick demonstration
    n = 4
    print(f"=== Quantum DPP Entanglement Algorithms (n={n}) ===\n")

    # Diagonal kernel
    p = np.array([0.3, 0.7, 0.1, 0.9])
    K_diag = diagonal_kernel(p)
    print("Diagonal kernel p =", p)
    print(f"  Total entropy: {fermionic_entropy(p):.4f}")
    for A in balanced_bipartitions(n):
        S = fermionic_entropy_diag(p, A)
        print(f"  S_{A} = {S:.4f}")

    print()

    # Random PSD contraction
    K = random_psd_contraction(n, np.random.default_rng(42))
    print("Random PSD contraction eigenvalues:", np.sort(np.linalg.eigvalsh(K)))
    print(f"  Min balanced entropy: {min_balanced_entropy(K):.4f}")
    print(f"  Max leaf pos index: {max_leaf_pos_index(K)}")
    print(f"  Lorentzian witness: {lorentzian_entanglement_witness(K):.6f}")

    print()

    # Correlation study
    print("=== Correlation Study (n=4, 50 samples) ===")
    results = entropy_witness_correlation(4, 50, "random", 42)
    corr = np.corrcoef(results['min_entropy'], results['witness'])[0, 1]
    print(f"  Correlation(min_entropy, witness): {corr:.4f}")
