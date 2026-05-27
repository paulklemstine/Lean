"""
Certified DPP Sampling Algorithms

Implements the certificate-checking pipeline for approximate DPP sampling,
including spectral perturbation bounds, negative dependence defect computation,
and Lorentzian/Hessian signature analysis.

The key algorithms formalized here correspond to the Lean theorems:
- det2_perturb_bound → certified_det2_perturb()
- certified_approx_dpp_sound → certified_neg_dep_defect()
- dpp_covariance_quadform_identity → covariance_quadratic_form()
- dpp_susceptibility_nonneg_bound → susceptibility_bound()
"""

import numpy as np
from typing import Tuple, Dict, Optional
from itertools import combinations


def make_psd_contraction(n: int, seed: int = 42) -> np.ndarray:
    """Generate a random symmetric PSD contraction kernel (eigenvalues in [0,1]).

    Args:
        n: Dimension of the kernel matrix.
        seed: Random seed for reproducibility.

    Returns:
        n×n symmetric PSD matrix with eigenvalues in [0,1].

    Example:
        >>> K = make_psd_contraction(4, seed=0)
        >>> eigvals = np.linalg.eigvalsh(K)
        >>> assert np.all(eigvals >= -1e-10) and np.all(eigvals <= 1 + 1e-10)
    """
    rng = np.random.RandomState(seed)
    A = rng.randn(n, n)
    K = A @ A.T / (2 * n)
    eigvals, eigvecs = np.linalg.eigh(K)
    # Clip eigenvalues to [0, 1]
    eigvals = np.clip(eigvals, 0, 1)
    K = eigvecs @ np.diag(eigvals) @ eigvecs.T
    # Ensure exact symmetry
    K = (K + K.T) / 2
    return K


def dpp_pair_incl(K: np.ndarray, i: int, j: int) -> float:
    """Compute pairwise inclusion probability: det(K_{i,j}) = K_ii*K_jj - K_ij*K_ji.

    Args:
        K: Kernel matrix.
        i, j: Indices.

    Returns:
        The 2×2 principal minor determinant.
    """
    return K[i, i] * K[j, j] - K[i, j] * K[j, i]


def dpp_single_incl(K: np.ndarray, i: int) -> float:
    """Compute singleton inclusion probability: K_ii.

    Args:
        K: Kernel matrix.
        i: Index.

    Returns:
        The diagonal entry K_ii.
    """
    return K[i, i]


def certified_det2_perturb(
    K: np.ndarray, K_prime: np.ndarray, eta: float, i: int, j: int
) -> Dict[str, float]:
    """Compute the certified perturbation bound for a 2×2 principal minor.

    Implements the bound from det2_perturb_bound:
    |det(K_{i,j}) - det(K'_{i,j})| ≤ (|K_jj| + |K'_ii| + |K_ij| + |K'_ji|) * η

    Args:
        K: Original kernel matrix.
        K_prime: Approximate kernel matrix.
        eta: Entry-wise error bound.
        i, j: Indices for the 2×2 submatrix.

    Returns:
        Dictionary with actual_diff, certified_bound, and is_certified.
    """
    actual_diff = abs(dpp_pair_incl(K, i, j) - dpp_pair_incl(K_prime, i, j))
    certified_bound = (abs(K[j, j]) + abs(K_prime[i, i]) +
                       abs(K[i, j]) + abs(K_prime[j, i])) * eta
    return {
        "actual_diff": actual_diff,
        "certified_bound": certified_bound,
        "is_certified": actual_diff <= certified_bound + 1e-12,
    }


def certified_neg_dep_defect(
    K: np.ndarray, K_prime: np.ndarray, eta: float
) -> Dict[str, float]:
    """Compute the certified negative dependence defect for an approximate kernel.

    Implements certified_approx_dpp_sound:
    dppPairIncl(K', i, j) ≤ dppSingleIncl(K', i) * dppSingleIncl(K', j) + 6*M*η

    Args:
        K: Exact symmetric kernel (with exact negative dependence).
        K_prime: Approximate kernel.
        eta: Entry-wise error bound.

    Returns:
        Dictionary with M, certified_defect_bound, max_actual_defect, and all_certified.
    """
    n = K.shape[0]
    M = max(np.max(np.abs(K)), np.max(np.abs(K_prime)))
    certified_bound = 6 * M * eta

    max_actual_defect = 0.0
    for i in range(n):
        for j in range(n):
            if i != j:
                pair = dpp_pair_incl(K_prime, i, j)
                prod = dpp_single_incl(K_prime, i) * dpp_single_incl(K_prime, j)
                defect = pair - prod
                max_actual_defect = max(max_actual_defect, defect)

    return {
        "M": M,
        "eta": eta,
        "certified_defect_bound": certified_bound,
        "max_actual_defect": max_actual_defect,
        "all_certified": max_actual_defect <= certified_bound + 1e-12,
    }


def covariance_quadratic_form(K: np.ndarray, a: np.ndarray) -> float:
    """Compute the DPP covariance quadratic form Q(a).

    Q(a) = ∑_i ∑_j a_i * a_j * (dppPairIncl(K,i,j) - K_ii * K_jj)
         = -∑_i ∑_j a_i * a_j * K_ij * K_ji   (for symmetric K)

    Args:
        K: Symmetric kernel matrix.
        a: Weight vector.

    Returns:
        The covariance quadratic form value.
    """
    n = K.shape[0]
    result = 0.0
    for i in range(n):
        for j in range(n):
            cov = dpp_pair_incl(K, i, j) - dpp_single_incl(K, i) * dpp_single_incl(K, j)
            result += a[i] * a[j] * cov
    return result


def susceptibility_check(K: np.ndarray, a: np.ndarray) -> Dict[str, float]:
    """Check the susceptibility inequality Q(a) ≤ 0 for nonneg a.

    Args:
        K: Symmetric kernel matrix.
        a: Nonneg weight vector.

    Returns:
        Dictionary with Q_value, is_nonpositive, and hadamard_sum.
    """
    Q = covariance_quadratic_form(K, a)
    hadamard_sum = sum(
        a[i] * a[j] * K[i, j] * K[j, i]
        for i in range(K.shape[0])
        for j in range(K.shape[0])
    )
    return {
        "Q_value": Q,
        "is_nonpositive": Q <= 1e-12,
        "hadamard_sum": hadamard_sum,
        "neg_hadamard": -hadamard_sum,
    }


def hessian_signature_check(K: np.ndarray) -> Dict[str, object]:
    """Compute the Hessian signature of the DPP generating polynomial at x=1.

    For the generating polynomial Z_K(x) = det(I + diag(x)K), the Hessian
    at x=1 encodes the pairwise inclusion structure.

    For symmetric PSD K, the Hessian restricted to the orthogonal complement
    of the all-ones direction should be negative semidefinite (Lorentzian condition).

    Args:
        K: Symmetric PSD kernel matrix.

    Returns:
        Dictionary with eigenvalues, num_positive, signature_defect, and is_lorentzian.
    """
    n = K.shape[0]
    # Hessian H_{ij} = ∂_i∂_j Z_K(1) / Z_K(1)
    # For DPP marginal kernel: H_{ij} = K_ii*K_jj - K_ij^2 (pair incl) for i≠j
    # H_{ii} = 0 (multiaffine)
    H = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            if i != j:
                H[i, j] = dpp_pair_incl(K, i, j)

    eigvals = np.linalg.eigvalsh(H)
    num_positive = np.sum(eigvals > 1e-10)
    # Signature defect: number of positive eigenvalues beyond 1
    signature_defect = max(0, num_positive - 1)
    max_positive_on_orth = 0.0

    # Project onto orthogonal complement of all-ones
    ones = np.ones(n) / np.sqrt(n)
    P = np.eye(n) - np.outer(ones, ones)
    H_restricted = P @ H @ P
    eigvals_restricted = np.linalg.eigvalsh(H_restricted)
    max_positive_on_orth = max(0, np.max(eigvals_restricted))

    return {
        "eigenvalues": eigvals,
        "num_positive": int(num_positive),
        "signature_defect": signature_defect,
        "max_positive_on_orthogonal": max_positive_on_orth,
        "is_lorentzian": signature_defect <= 1,
    }


def exact_dpp_marginals(K: np.ndarray) -> Tuple[np.ndarray, np.ndarray]:
    """Compute exact DPP marginals by exhaustive enumeration.

    Only practical for small n (≤ 16).

    Args:
        K: Symmetric PSD kernel matrix.

    Returns:
        Tuple of (singleton_marginals, pairwise_marginals).
    """
    n = K.shape[0]
    if n > 16:
        raise ValueError(f"n={n} too large for exhaustive enumeration")

    # Compute all subset probabilities
    total_weight = 0.0
    singleton_weights = np.zeros(n)
    pairwise_weights = np.zeros((n, n))

    for size in range(n + 1):
        for subset in combinations(range(n), size):
            if len(subset) == 0:
                weight = 1.0
            else:
                sub_indices = list(subset)
                sub_matrix = K[np.ix_(sub_indices, sub_indices)]
                weight = np.linalg.det(sub_matrix)
                weight = max(weight, 0)  # Numerical stability

            total_weight += weight
            for i in subset:
                singleton_weights[i] += weight
            for i, j in combinations(subset, 2):
                pairwise_weights[i, j] += weight
                pairwise_weights[j, i] += weight

    # Normalize
    singleton_marginals = singleton_weights / total_weight
    pairwise_marginals = pairwise_weights / total_weight

    return singleton_marginals, pairwise_marginals


def full_certification_pipeline(
    K: np.ndarray, eta: float = 0.01, seed: int = 42
) -> Dict[str, object]:
    """Run the full certified DPP approximation pipeline.

    1. Generate a perturbation K' = K + noise.
    2. Check entry-wise error bound.
    3. Compute certified negative dependence defect.
    4. Check Hessian signature (Lorentzian certificate).
    5. Verify susceptibility inequality.

    Args:
        K: Exact symmetric PSD contraction kernel.
        eta: Target perturbation magnitude.
        seed: Random seed.

    Returns:
        Dictionary with all certification results.
    """
    n = K.shape[0]
    rng = np.random.RandomState(seed)

    # Generate perturbation
    noise = rng.uniform(-eta, eta, size=(n, n))
    noise = (noise + noise.T) / 2  # Keep symmetric
    K_prime = K + noise

    # Compute actual entry-wise error
    actual_eta = np.max(np.abs(K - K_prime))

    # Certificate 1: Negative dependence defect
    neg_dep = certified_neg_dep_defect(K, K_prime, actual_eta)

    # Certificate 2: Hessian signature
    hessian_K = hessian_signature_check(K)
    hessian_K_prime = hessian_signature_check(K_prime)

    # Certificate 3: Susceptibility for uniform weights
    a_uniform = np.ones(n)
    susc_K = susceptibility_check(K, a_uniform)
    susc_K_prime = susceptibility_check(K_prime, a_uniform)

    # Certificate 4: Pairwise bounds
    pairwise_bounds = {}
    for i in range(min(n, 4)):
        for j in range(i + 1, min(n, 4)):
            key = f"({i},{j})"
            pairwise_bounds[key] = certified_det2_perturb(K, K_prime, actual_eta, i, j)

    return {
        "n": n,
        "actual_eta": actual_eta,
        "target_eta": eta,
        "neg_dep_certificate": neg_dep,
        "hessian_K": hessian_K,
        "hessian_K_prime": hessian_K_prime,
        "susceptibility_K": susc_K,
        "susceptibility_K_prime": susc_K_prime,
        "pairwise_bounds": pairwise_bounds,
    }


if __name__ == "__main__":
    # Example usage
    print("=" * 60)
    print("Certified DPP Sampling — Algorithm Demonstration")
    print("=" * 60)

    for n in [4, 6, 8]:
        print(f"\n--- n = {n} ---")
        K = make_psd_contraction(n, seed=42)
        results = full_certification_pipeline(K, eta=0.01)

        print(f"Entry-wise error η = {results['actual_eta']:.6f}")
        cert = results["neg_dep_certificate"]
        print(f"Max entry magnitude M = {cert['M']:.4f}")
        print(f"Certified ND defect bound = {cert['certified_defect_bound']:.6f}")
        print(f"Actual max ND defect = {cert['max_actual_defect']:.6f}")
        print(f"All pairs certified: {cert['all_certified']}")

        hess = results["hessian_K"]
        print(f"Hessian signature defect (exact K) = {hess['signature_defect']}")
        print(f"Lorentzian: {hess['is_lorentzian']}")
