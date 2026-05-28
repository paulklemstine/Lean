"""
Algorithms for computing Lorentzian stability radii of uniform matroids.

The uniform matroid U_{r,n} has basis generating polynomial e_r(x_1,...,x_n).
Every quadratic leaf is a scalar multiple of e_2 on m = n-r+2 variables.
The Hessian of e_2 is J - I (all-ones minus identity), with eigenvalues
m-1 (multiplicity 1) and -1 (multiplicity m-1).

The spectral stability radius in the entry-norm topology is 1/m.
"""

import numpy as np
from typing import Tuple, Optional
from math import comb


def leaf_hessian(m: int) -> np.ndarray:
    """Construct the canonical quadratic leaf Hessian J - I for dimension m.
    
    This is the adjacency matrix of the complete graph K_m:
    diagonal entries 0, off-diagonal entries 1.
    
    Args:
        m: dimension (number of remaining variables after r-2 derivatives)
    
    Returns:
        m x m numpy array representing J - I
        
    Time complexity: O(m^2)
    Space complexity: O(m^2)
    """
    return np.ones((m, m)) - np.eye(m)


def leaf_eigenvalues(m: int) -> Tuple[float, float, int, int]:
    """Compute the exact eigenvalues of the leaf Hessian J - I.
    
    The matrix J - I has exactly two distinct eigenvalues:
    - m-1 with multiplicity 1 (trivial representation of S_m)
    - -1 with multiplicity m-1 (standard representation of S_m)
    
    Args:
        m: dimension
    
    Returns:
        (positive_eigenvalue, negative_eigenvalue, 
         positive_multiplicity, negative_multiplicity)
    
    Time complexity: O(1)
    """
    return (m - 1, -1, 1, m - 1)


def spectral_gap(m: int) -> float:
    """Compute the spectral gap of the leaf Hessian.
    
    The gap is the distance from the negative eigenvalue (-1) to the
    signature boundary (0), which is exactly 1.
    
    Args:
        m: dimension
    
    Returns:
        The spectral gap (always 1 for uniform matroids)
    
    Time complexity: O(1)
    """
    return 1.0


def stability_radius_entry_norm(m: int) -> float:
    """Compute the stability radius in the entry-norm topology.
    
    The stability radius is 1/(2m): entry perturbations bounded by 1/(2m)
    preserve the Lorentzian signature, while perturbations larger than 1
    can break it.
    
    The factor 1/(2m) comes from converting entry-norm to quadratic-form-norm:
    |Q_E(v)| ≤ m * max|E_ij| * ||v||^2, so max|E_ij| < 1/m suffices.
    The factor of 2 is a safety margin from the proof.
    
    Args:
        m: leaf dimension
    
    Returns:
        Lower bound on stability radius
    
    Time complexity: O(1)
    """
    if m == 0:
        return float('inf')
    return 1.0 / (2 * m)


def stability_radius_quadform_norm(m: int) -> float:
    """Compute the stability radius in the quadratic-form-norm topology.
    
    If the perturbation E satisfies |Q_E(v)| ≤ δ * ||v||^2 for all v,
    then δ < 1 suffices to preserve Lorentzianity.
    
    Args:
        m: leaf dimension
    
    Returns:
        The stability radius in quadratic-form-norm (always 1)
    
    Time complexity: O(1)
    """
    return 1.0


def uniform_matroid_leaf_dimension(n: int, r: int) -> int:
    """Compute the leaf dimension m = n - r + 2.
    
    After taking r-2 partial derivatives of e_r(x_1,...,x_n),
    the remaining quadratic polynomial is in m = n - r + 2 variables.
    
    Args:
        n: total number of variables
        r: rank of uniform matroid (degree of e_r)
    
    Returns:
        Leaf dimension m
    """
    return n - r + 2


def check_lorentzian_signature(H: np.ndarray, tol: float = 1e-10) -> bool:
    """Check if a symmetric matrix has Lorentzian signature.
    
    A matrix has Lorentzian signature if it has at most one positive eigenvalue.
    
    Args:
        H: symmetric matrix
        tol: tolerance for eigenvalue sign determination
    
    Returns:
        True if H has at most one positive eigenvalue
    
    Time complexity: O(n^3) for eigenvalue computation
    """
    eigenvalues = np.linalg.eigvalsh(H)
    n_positive = np.sum(eigenvalues > tol)
    return n_positive <= 1


def perturbed_hessian(m: int, perturbation: np.ndarray) -> np.ndarray:
    """Compute the perturbed leaf Hessian H + E.
    
    Args:
        m: dimension
        perturbation: m x m perturbation matrix
    
    Returns:
        Perturbed Hessian matrix
    """
    return leaf_hessian(m) + perturbation


def find_instability_threshold(m: int, n_samples: int = 1000,
                                 n_bisection: int = 50) -> float:
    """Find the empirical instability threshold via binary search.
    
    For each perturbation scale t, generate random perturbation matrices
    with entries in [-t, t] and check if the Lorentzian signature is preserved.
    Use binary search to find the critical threshold.
    
    Args:
        m: leaf dimension
        n_samples: number of random samples per scale
        n_bisection: number of bisection steps
    
    Returns:
        Empirical instability threshold
    
    Time complexity: O(n_bisection * n_samples * m^3)
    """
    np.random.seed(42)
    
    lo, hi = 0.0, 2.0
    
    for _ in range(n_bisection):
        mid = (lo + hi) / 2
        all_stable = True
        
        for _ in range(n_samples):
            E = np.random.uniform(-mid, mid, (m, m))
            E = (E + E.T) / 2  # symmetrize
            
            H_perturbed = leaf_hessian(m) + E
            if not check_lorentzian_signature(H_perturbed):
                all_stable = False
                break
        
        if all_stable:
            lo = mid
        else:
            hi = mid
    
    return (lo + hi) / 2


def compute_all_stability_data(max_n: int = 15) -> list:
    """Compute stability data for all uniform matroids U_{r,n} with n ≤ max_n.
    
    For each valid (n, r) with 2 ≤ r ≤ n-2, compute:
    - Leaf dimension m = n - r + 2
    - Spectral gap (always 1)
    - Theoretical stability radius 1/(2m)
    - Binomial coefficient C(n,r)
    - Predicted radius scale 1/C(n,r) * gap
    
    Args:
        max_n: maximum n value
    
    Returns:
        List of dicts with stability data
    """
    results = []
    for n in range(4, max_n + 1):
        for r in range(2, n - 1):
            m = n - r + 2
            gap = spectral_gap(m)
            radius = stability_radius_entry_norm(m)
            binom = comb(n, r)
            
            results.append({
                'n': n,
                'r': r,
                'm': m,
                'gap': gap,
                'radius_lower': radius,
                'binom': binom,
                'predicted_scale': gap / binom,
                'normalized_radius': radius * binom,
            })
    
    return results


def quadratic_form_value(H: np.ndarray, v: np.ndarray) -> float:
    """Compute the quadratic form Q_H(v) = v^T H v.
    
    Args:
        H: symmetric matrix
        v: vector
    
    Returns:
        Q_H(v) = v^T H v
    """
    return float(v @ H @ v)


def rayleigh_quotient_on_orthogonal(H: np.ndarray, w: np.ndarray,
                                      n_samples: int = 10000) -> Tuple[float, float]:
    """Compute min and max Rayleigh quotient Q(v)/||v||^2 on w-orthogonal complement.
    
    Args:
        H: symmetric matrix
        w: direction vector
        n_samples: number of random samples
    
    Returns:
        (min_ratio, max_ratio) of Q(v)/||v||^2 for random v ⊥ w
    """
    m = H.shape[0]
    w_normalized = w / np.linalg.norm(w)
    
    min_ratio = float('inf')
    max_ratio = float('-inf')
    
    for _ in range(n_samples):
        v = np.random.randn(m)
        # Project out w component
        v = v - np.dot(v, w_normalized) * w_normalized
        norm_sq = np.dot(v, v)
        if norm_sq < 1e-12:
            continue
        ratio = quadratic_form_value(H, v) / norm_sq
        min_ratio = min(min_ratio, ratio)
        max_ratio = max(max_ratio, ratio)
    
    return min_ratio, max_ratio


if __name__ == "__main__":
    # Example usage
    print("=== Uniform Matroid Lorentzian Stability ===\n")
    
    for m in [3, 4, 5, 10]:
        H = leaf_hessian(m)
        pos_ev, neg_ev, pos_mult, neg_mult = leaf_eigenvalues(m)
        gap = spectral_gap(m)
        radius = stability_radius_entry_norm(m)
        
        print(f"m = {m}:")
        print(f"  Eigenvalues: {pos_ev} (×{pos_mult}), {neg_ev} (×{neg_mult})")
        print(f"  Spectral gap: {gap}")
        print(f"  Entry-norm stability radius: {radius:.4f}")
        print(f"  Lorentzian: {check_lorentzian_signature(H)}")
        print()
    
    print("\n=== Stability Data for n ≤ 10 ===\n")
    data = compute_all_stability_data(10)
    print(f"{'n':>3} {'r':>3} {'m':>3} {'C(n,r)':>8} {'gap':>5} {'radius':>8} {'norm_rad':>10}")
    for d in data:
        print(f"{d['n']:3d} {d['r']:3d} {d['m']:3d} {d['binom']:8d} {d['gap']:5.1f} {d['radius_lower']:8.4f} {d['normalized_radius']:10.4f}")
