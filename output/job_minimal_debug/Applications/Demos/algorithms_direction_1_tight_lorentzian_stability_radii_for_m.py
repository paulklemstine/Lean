"""
algorithms.py — Core algorithms for Lorentzian Stability Radii of Uniform Matroids

Implements the spectral theory of the canonical leaf Hessian J - I and
computes stability radii for the uniform matroid family U_{r,n}.
"""

import numpy as np
from math import comb
from typing import Tuple, Optional


def leaf_hessian(m: int) -> np.ndarray:
    """
    Construct the canonical quadratic leaf Hessian for the uniform matroid.

    The Hessian of e₂(x₁,…,xₘ) is J - I, where J is the all-ones matrix
    and I is the identity matrix.

    Parameters
    ----------
    m : int
        Number of remaining variables (m = n - r + 2 for U_{r,n}).

    Returns
    -------
    np.ndarray
        The m × m matrix with 0 on the diagonal and 1 off-diagonal.

    Examples
    --------
    >>> leaf_hessian(3)
    array([[0., 1., 1.],
           [1., 0., 1.],
           [1., 1., 0.]])
    """
    return np.ones((m, m)) - np.eye(m)


def quadratic_form(A: np.ndarray, v: np.ndarray) -> float:
    """
    Compute the quadratic form Q_A(v) = v^T A v.

    Parameters
    ----------
    A : np.ndarray
        Symmetric matrix.
    v : np.ndarray
        Vector.

    Returns
    -------
    float
        The value v^T A v.
    """
    return float(v @ A @ v)


def leaf_eigengap(m: int) -> dict:
    """
    Compute the exact spectral data of the leaf Hessian J - I on m variables.

    The eigenvalues of J - I are:
    - λ₁ = m - 1 (multiplicity 1, eigenvector: all-ones)
    - λ₂ = -1    (multiplicity m - 1, eigenvectors: orthogonal to all-ones)

    The spectral gap is |λ₂| = 1, which is the Lorentzian stability gap.

    Parameters
    ----------
    m : int
        Number of variables.

    Returns
    -------
    dict
        Dictionary with keys:
        - 'positive_eigenvalue': m - 1
        - 'negative_eigenvalue': -1
        - 'positive_multiplicity': 1
        - 'negative_multiplicity': m - 1
        - 'spectral_gap': 1 (absolute gap)
        - 'normalized_gap': 1 / (m - 1) (ratio |λ₂| / λ₁)
    """
    return {
        'positive_eigenvalue': m - 1,
        'negative_eigenvalue': -1,
        'positive_multiplicity': 1,
        'negative_multiplicity': m - 1,
        'spectral_gap': 1,
        'normalized_gap': 1.0 / (m - 1) if m > 1 else float('inf'),
    }


def canonical_leaf_gap(n: int, r: int) -> float:
    """
    The canonical leaf gap for the uniform matroid U_{r,n}.

    For U_{r,n}, the quadratic leaf has m = n - r + 2 variables,
    and the spectral gap of J - I is always 1.

    Parameters
    ----------
    n : int
        Ground set size.
    r : int
        Rank.

    Returns
    -------
    float
        The canonical leaf gap (always 1.0).
    """
    return 1.0


def stability_radius_entry_bound(m: int) -> float:
    """
    The entry-wise stability radius: maximum entry perturbation ε such that
    leafHessian(m) + E remains Lorentzian whenever |E_{ij}| ≤ ε.

    Proved lower bound: ε = 1/m² guarantees Lorentzianity.

    Parameters
    ----------
    m : int
        Number of variables in the quadratic leaf.

    Returns
    -------
    float
        The certified stability radius 1/m².
    """
    if m == 0:
        return float('inf')
    return 1.0 / (m * m)


def stability_radius_quadform_bound(m: int) -> float:
    """
    The quadratic-form stability radius: maximum δ such that
    |Q_E(v)| ≤ δ·‖v‖² for all v guarantees Lorentzianity.

    The exact threshold is δ = 1 (the spectral gap).

    Parameters
    ----------
    m : int
        Number of variables.

    Returns
    -------
    float
        The stability radius (always 1.0, the spectral gap).
    """
    return 1.0


def check_lorentzian_signature(A: np.ndarray) -> Tuple[bool, Optional[np.ndarray]]:
    """
    Check whether a symmetric matrix has at most one positive eigenvalue
    (Lorentzian signature condition).

    Parameters
    ----------
    A : np.ndarray
        Symmetric matrix.

    Returns
    -------
    Tuple[bool, Optional[np.ndarray]]
        (is_lorentzian, eigenvalues) where is_lorentzian is True if at most
        one eigenvalue is positive.
    """
    eigenvalues = np.linalg.eigvalsh(A)
    n_positive = np.sum(eigenvalues > 1e-10)
    return n_positive <= 1, eigenvalues


def find_empirical_stability_radius(m: int, n_samples: int = 1000,
                                     tol: float = 1e-6) -> float:
    """
    Find the empirical stability radius by binary search.

    Searches for the maximum perturbation magnitude ε such that
    leafHessian(m) + E remains Lorentzian for random perturbations
    with entries bounded by ε.

    Parameters
    ----------
    m : int
        Number of variables.
    n_samples : int
        Number of random perturbation samples per magnitude.
    tol : float
        Tolerance for binary search.

    Returns
    -------
    float
        Estimated empirical stability radius.
    """
    if m <= 1:
        return float('inf')

    lo, hi = 0.0, 2.0 / m  # Search range

    while hi - lo > tol:
        mid = (lo + hi) / 2
        all_lorentzian = True

        for _ in range(n_samples):
            E = np.random.uniform(-mid, mid, (m, m))
            E = (E + E.T) / 2  # Symmetrize
            A_perturbed = leaf_hessian(m) + E
            is_lor, _ = check_lorentzian_signature(A_perturbed)
            if not is_lor:
                all_lorentzian = False
                break

        if all_lorentzian:
            lo = mid
        else:
            hi = mid

    return lo


def find_critical_perturbation(m: int) -> Tuple[np.ndarray, float]:
    """
    Construct the canonical instability perturbation.

    The perturbation E = t·I with t > 1 breaks Lorentzianity because
    leafHessian(m) + t·I = (t-1)I + J, which has all positive eigenvalues:
    - eigenvalue t + m - 1 (multiplicity 1)
    - eigenvalue t - 1 > 0 (multiplicity m - 1)

    Parameters
    ----------
    m : int
        Number of variables.

    Returns
    -------
    Tuple[np.ndarray, float]
        (E, threshold) where E is the critical perturbation direction
        and threshold is the critical magnitude.
    """
    E = np.eye(m)
    threshold = 1.0  # The spectral gap
    return E, threshold


def compute_uniform_matroid_table(max_n: int = 15) -> list:
    """
    Compute the stability data for all valid uniform matroids U_{r,n}
    with n ≤ max_n and 2 ≤ r ≤ n - 2.

    Parameters
    ----------
    max_n : int
        Maximum ground set size.

    Returns
    -------
    list of dict
        Each dict contains: n, r, m (leaf vars), spectral_gap,
        entry_radius, normalized_gap, binom_n_r.
    """
    results = []
    for n in range(4, max_n + 1):
        for r in range(2, n - 1):
            m = n - r + 2
            gap_data = leaf_eigengap(m)
            results.append({
                'n': n,
                'r': r,
                'm': m,
                'spectral_gap': gap_data['spectral_gap'],
                'entry_radius': stability_radius_entry_bound(m),
                'normalized_gap': gap_data['normalized_gap'],
                'binom_n_r': comb(n, r),
                'predicted_scale': 1.0 / comb(n, r),
            })
    return results


def quadratic_form_decomposition(m: int, v: np.ndarray) -> dict:
    """
    Decompose Q_{J-I}(v) = (∑ vᵢ)² - ∑ vᵢ² into its two components.

    This reflects the spectral decomposition: the first term comes from
    the trivial representation (eigenvalue m-1) and the second from
    the standard representation (eigenvalue -1).

    Parameters
    ----------
    m : int
        Number of variables.
    v : np.ndarray
        Vector of length m.

    Returns
    -------
    dict
        Dictionary with 'sum_squared', 'norm_squared', 'quadform', and
        'trivial_component', 'standard_component'.
    """
    s = np.sum(v)
    sum_sq = s ** 2
    norm_sq = np.sum(v ** 2)
    qf = sum_sq - norm_sq

    # Projection onto trivial (all-ones) direction
    trivial_proj = s / m * np.ones(m)
    standard_proj = v - trivial_proj

    trivial_component = quadratic_form(leaf_hessian(m), trivial_proj)
    standard_component = quadratic_form(leaf_hessian(m), standard_proj)

    return {
        'sum_squared': sum_sq,
        'norm_squared': norm_sq,
        'quadform': qf,
        'trivial_component': trivial_component,
        'standard_component': standard_component,
    }


if __name__ == '__main__':
    print("=== Lorentzian Stability Radii: Algorithm Demonstrations ===\n")

    # Example 1: Leaf Hessian for m=4
    m = 4
    H = leaf_hessian(m)
    print(f"Leaf Hessian for m={m}:")
    print(H)
    print()

    # Example 2: Spectral data
    data = leaf_eigengap(m)
    print(f"Spectral data for m={m}:")
    for k, v in data.items():
        print(f"  {k}: {v}")
    print()

    # Example 3: Quadratic form decomposition
    v = np.array([1.0, -1.0, 0.5, 0.5])
    decomp = quadratic_form_decomposition(m, v)
    print(f"Quadratic form decomposition for v={v}:")
    for k, val in decomp.items():
        print(f"  {k}: {val:.4f}")
    print()

    # Example 4: Stability check
    print("Stability radius table (n ≤ 8):")
    print(f"{'n':>3} {'r':>3} {'m':>3} {'gap':>6} {'entry_rad':>10} {'binom':>6}")
    for row in compute_uniform_matroid_table(8):
        print(f"{row['n']:3d} {row['r']:3d} {row['m']:3d} {row['spectral_gap']:6.2f} "
              f"{row['entry_radius']:10.6f} {row['binom_n_r']:6d}")
