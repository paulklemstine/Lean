"""
Certified Fermion Sampling — Algorithms
=========================================

Core algorithms for certified fermion sampling under noise.
Implements the mathematical framework proven in Lean 4.

Time complexity:  O(n²) per noise application, O(n²d) total
Space complexity: O(n²) for the correlation matrix
"""

import numpy as np
from typing import Tuple, Optional, Dict, List
from dataclasses import dataclass


@dataclass
class FermionCorrelationCertificate:
    """Certificate for fermion sampling quality.

    Attributes:
        ideal_kernel: The ideal (noiseless) correlation matrix K
        noisy_kernel: The noisy correlation matrix K'
        depth: Circuit depth d
        noise_rate: Noise rate per gate ε
        entry_bound: Maximum entry magnitude M
        is_symmetric: Whether both kernels are symmetric
        max_entry_diff: Actual ‖K - K'‖_max
        certified_defect_bound: Certified bound on defect perturbation
        neg_dep_margin: Negative dependence margin of ideal kernel
        max_certified_depth: Maximum depth preserving negative dependence
    """
    ideal_kernel: np.ndarray
    noisy_kernel: np.ndarray
    depth: int
    noise_rate: float
    entry_bound: float
    is_symmetric: bool
    max_entry_diff: float
    certified_defect_bound: float
    neg_dep_margin: float
    max_certified_depth: float


def depolarizing_channel(K: np.ndarray, eps: float) -> np.ndarray:
    """Apply depolarizing channel to correlation matrix.

    Maps K → (1-ε)K + ε(I/2), contracting eigenvalues toward 1/2.

    Args:
        K: n×n correlation matrix
        eps: Noise rate in [0, 1]

    Returns:
        Noisy correlation matrix K'

    Time: O(n²)
    Space: O(n²)
    """
    n = K.shape[0]
    return (1 - eps) * K + eps * np.eye(n) / 2


def simulate_noisy_circuit(K: np.ndarray, depth: int, eps: float) -> np.ndarray:
    """Simulate a noisy quantum circuit by applying d layers of depolarizing noise.

    Args:
        K: Initial correlation matrix
        depth: Number of gate layers
        eps: Noise rate per layer

    Returns:
        Final noisy correlation matrix

    Time: O(n²·d)
    Space: O(n²)
    """
    K_noisy = K.copy()
    for _ in range(depth):
        K_noisy = depolarizing_channel(K_noisy, eps)
    return K_noisy


def pairwise_neg_dep_defect(K: np.ndarray, i: int, j: int) -> float:
    """Compute pairwise negative dependence defect.

    defect(K, i, j) = (K_ii·K_jj - K_ij·K_ji) - K_ii·K_jj = -K_ij·K_ji

    For symmetric K: defect = -(K_ij)²

    Args:
        K: Correlation matrix
        i, j: Index pair

    Returns:
        Defect value (≤ 0 for valid DPP kernels)
    """
    return (K[i, i] * K[j, j] - K[i, j] * K[j, i]) - K[i, i] * K[j, j]


def compute_neg_dep_margin(K: np.ndarray) -> float:
    """Compute the negative dependence margin of a correlation matrix.

    margin = min_{i<j} (-defect(K, i, j)) = min_{i<j} K_ij · K_ji

    Args:
        K: Correlation matrix

    Returns:
        Negative dependence margin δ > 0 iff K satisfies neg dep
    """
    n = K.shape[0]
    margin = float('inf')
    for i in range(n):
        for j in range(i + 1, n):
            defect = pairwise_neg_dep_defect(K, i, j)
            margin = min(margin, -defect)
    return margin


def certify_fermion_sampling(
    K: np.ndarray,
    depth: int,
    eps: float,
    symmetric: bool = True
) -> FermionCorrelationCertificate:
    """Certify the quality of noisy fermion sampling.

    Given an ideal kernel K and noise parameters, computes the noisy
    kernel and provides certified quality bounds.

    Algorithm:
        1. Simulate noisy circuit: K' = D_eps^d(K)
        2. Compute ‖K - K'‖_max
        3. Compute certified defect bound (4·d·eps or 2·d·eps)
        4. Compute negative dependence margin
        5. Compute maximum certified depth

    Args:
        K: Ideal correlation matrix (n×n, PSD, eigenvalues in [0,1])
        depth: Circuit depth
        eps: Noise rate per gate
        symmetric: Whether to use the tighter symmetric bound

    Returns:
        FermionCorrelationCertificate with all quality metrics

    Time: O(n²·d)
    Space: O(n²)
    """
    # Step 1: Simulate noisy circuit
    K_noisy = simulate_noisy_circuit(K, depth, eps)

    # Step 2: Compute actual entry difference
    max_diff = np.abs(K - K_noisy).max()

    # Step 3: Certified defect bound
    constant = 2.0 if symmetric else 4.0
    certified_bound = constant * depth * eps

    # Step 4: Negative dependence margin
    margin = compute_neg_dep_margin(K)

    # Step 5: Maximum certified depth
    if eps > 0 and margin > 0:
        max_depth = margin / (constant * eps)
    else:
        max_depth = float('inf')

    entry_bound = max(np.abs(K).max(), np.abs(K_noisy).max())

    return FermionCorrelationCertificate(
        ideal_kernel=K,
        noisy_kernel=K_noisy,
        depth=depth,
        noise_rate=eps,
        entry_bound=entry_bound,
        is_symmetric=symmetric,
        max_entry_diff=max_diff,
        certified_defect_bound=certified_bound,
        neg_dep_margin=margin,
        max_certified_depth=max_depth,
    )


def make_slater_determinant(n: int, k: int, seed: int = 42) -> np.ndarray:
    """Create a rank-k Slater determinant correlation matrix.

    K = U_k @ U_k^T where U_k is the first k columns of a random
    orthogonal matrix. Eigenvalues are k ones and n-k zeros.

    Args:
        n: Matrix dimension
        k: Number of occupied modes (filling)
        seed: Random seed

    Returns:
        n×n correlation matrix with rank k

    Time: O(n²·k)
    Space: O(n²)
    """
    rng = np.random.default_rng(seed)
    Q, _ = np.linalg.qr(rng.standard_normal((n, n)))
    U_k = Q[:, :k]
    return U_k @ U_k.T


def noise_threshold_analysis(
    K: np.ndarray,
    eps_range: np.ndarray,
    depth_range: np.ndarray
) -> Dict[str, np.ndarray]:
    """Analyze noise thresholds across parameter space.

    For each (eps, depth) pair, determines whether negative dependence
    is certified to be preserved.

    Args:
        K: Ideal correlation matrix
        eps_range: Array of noise rates to test
        depth_range: Array of depths to test

    Returns:
        Dictionary with 'certified' (boolean grid), 'actual_preserved'
        (boolean grid), and 'margin' (float)
    """
    margin = compute_neg_dep_margin(K)
    n_eps = len(eps_range)
    n_depth = len(depth_range)

    certified = np.zeros((n_eps, n_depth), dtype=bool)
    actual_preserved = np.zeros((n_eps, n_depth), dtype=bool)

    for ie, eps in enumerate(eps_range):
        for id_, d in enumerate(depth_range):
            # Certified check: 2*d*eps < margin (symmetric case)
            certified[ie, id_] = 2 * d * eps < margin

            # Actual check via simulation
            K_noisy = simulate_noisy_circuit(K, int(d), eps)
            all_neg = True
            for i in range(K.shape[0]):
                for j in range(i + 1, K.shape[0]):
                    if pairwise_neg_dep_defect(K_noisy, i, j) >= 0:
                        all_neg = False
                        break
                if not all_neg:
                    break
            actual_preserved[ie, id_] = all_neg

    return {
        'certified': certified,
        'actual_preserved': actual_preserved,
        'margin': margin,
        'eps_range': eps_range,
        'depth_range': depth_range,
    }


if __name__ == "__main__":
    # Example usage
    n = 8
    k = 4  # Half-filling
    K = make_slater_determinant(n, k)

    print("Fermion Correlation Matrix Properties:")
    eigvals = np.linalg.eigvalsh(K)
    print(f"  Eigenvalues: {np.round(eigvals, 4)}")
    print(f"  Rank: {np.linalg.matrix_rank(K)}")
    print(f"  Symmetric: {np.allclose(K, K.T)}")

    cert = certify_fermion_sampling(K, depth=10, eps=0.01)
    print(f"\nCertification Results:")
    print(f"  Max entry difference: {cert.max_entry_diff:.6f}")
    print(f"  Certified defect bound: {cert.certified_defect_bound:.6f}")
    print(f"  Neg dep margin: {cert.neg_dep_margin:.6f}")
    print(f"  Max certified depth: {cert.max_certified_depth:.1f}")
    print(f"  Is certified: {cert.certified_defect_bound < cert.neg_dep_margin}")
