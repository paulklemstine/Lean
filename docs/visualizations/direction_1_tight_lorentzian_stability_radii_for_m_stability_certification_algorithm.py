"""
Algorithms for Lorentzian Stability Analysis of Uniform Matroid Polynomials.

This module implements the spectral analysis of the uniform leaf Hessian (J - I),
computing eigenvalues, spectral gaps, and stability radii for the uniform matroid
generating polynomial U_{r,n}.

The key mathematical objects:
- The uniform leaf Hessian is J - I (all-ones minus identity) on m = n - r + 2 variables
- Its eigenvalues are (m-1) with multiplicity 1 and (-1) with multiplicity (m-1)
- The Lorentzian spectral gap is 1 (magnitude of the negative eigenvalue)
- The stability radius in operator norm is 1, in entry norm is 1/m^2
"""

import numpy as np
from math import comb
from typing import Tuple, List, Optional


def uniform_leaf_hessian(m: int) -> np.ndarray:
    """
    Construct the canonical leaf Hessian for the uniform matroid U_{r,n}.

    This is the matrix J - I on m variables, where J is the all-ones matrix
    and I is the identity. Equivalently, it's the adjacency matrix of K_m.

    Parameters
    ----------
    m : int
        Number of remaining variables (= n - r + 2 for U_{r,n})

    Returns
    -------
    np.ndarray
        The m x m matrix with 0 on diagonal and 1 off-diagonal

    Examples
    --------
    >>> uniform_leaf_hessian(3)
    array([[0., 1., 1.],
           [1., 0., 1.],
           [1., 1., 0.]])
    """
    return np.ones((m, m)) - np.eye(m)


def leaf_eigenvalues(m: int) -> Tuple[float, float, int, int]:
    """
    Compute the exact eigenvalues of the uniform leaf Hessian.

    The matrix J - I on m variables has exactly two distinct eigenvalues:
    - (m-1) with multiplicity 1 (eigenvector: all-ones)
    - (-1) with multiplicity (m-1) (eigenvectors: orthogonal complement of all-ones)

    Parameters
    ----------
    m : int
        Matrix dimension

    Returns
    -------
    Tuple[float, float, int, int]
        (positive_eigenvalue, negative_eigenvalue, pos_multiplicity, neg_multiplicity)

    Examples
    --------
    >>> leaf_eigenvalues(4)
    (3.0, -1.0, 1, 3)
    """
    return (float(m - 1), -1.0, 1, m - 1)


def lorentzian_spectral_gap(m: int) -> float:
    """
    Compute the Lorentzian spectral gap of the uniform leaf Hessian.

    The gap is the magnitude of the negative eigenvalue, which is always 1
    for the uniform matroid. This gap controls the stability radius.

    Parameters
    ----------
    m : int
        Matrix dimension

    Returns
    -------
    float
        The spectral gap (always 1.0 for uniform matroids)
    """
    return 1.0


def quadratic_form_decomposition(v: np.ndarray) -> Tuple[float, float, float]:
    """
    Decompose the quadratic form Q(v) = (sum v_i)^2 - sum v_i^2.

    Parameters
    ----------
    v : np.ndarray
        Input vector

    Returns
    -------
    Tuple[float, float, float]
        (Q_value, sum_squared, norm_squared) where Q = sum_squared - norm_squared
    """
    s = float(np.sum(v))
    n = float(np.sum(v ** 2))
    return (s ** 2 - n, s ** 2, n)


def stability_radius_operator_norm(m: int) -> float:
    """
    Compute the stability radius in operator (quadratic form) norm.

    The stability radius is the spectral gap: any perturbation E with
    |Q_E(v)| < gap * ||v||^2 for all v preserves Lorentzianity.

    Parameters
    ----------
    m : int
        Matrix dimension

    Returns
    -------
    float
        The stability radius (always 1.0 for uniform matroids)
    """
    return lorentzian_spectral_gap(m)


def stability_radius_entry_norm(m: int) -> float:
    """
    Compute the stability radius in entry (sup) norm.

    The entry-to-quadratic-form bound gives: |E_ij| <= B implies
    |Q_E(v)| <= m^2 * B * ||v||^2. For stability we need m^2 * B < gap = 1,
    so B < 1/m^2.

    Parameters
    ----------
    m : int
        Matrix dimension

    Returns
    -------
    float
        The entry-norm stability radius = 1/m^2
    """
    return 1.0 / (m ** 2)


def uniform_matroid_leaf_dimension(n: int, r: int) -> int:
    """
    Compute the leaf dimension m = n - r + 2 for U_{r,n}.

    After taking r-2 partial derivatives of e_r(x_1,...,x_n),
    the remaining quadratic polynomial lives on m = n - r + 2 variables.

    Parameters
    ----------
    n : int
        Number of variables
    r : int
        Degree (rank of uniform matroid)

    Returns
    -------
    int
        The leaf dimension m
    """
    return n - r + 2


def normalized_stability_gap(n: int, r: int) -> float:
    """
    Compute the normalized stability gap for U_{r,n}.

    This is the spectral gap divided by the binomial coefficient C(n,r),
    giving a scale-independent measure of stability.

    Parameters
    ----------
    n : int
        Number of variables
    r : int
        Degree

    Returns
    -------
    float
        Normalized gap = 1 / C(n,r)
    """
    return 1.0 / comb(n, r)


def verify_lorentzian_signature(A: np.ndarray, tol: float = 1e-10) -> bool:
    """
    Check if a symmetric matrix has at most one positive eigenvalue.

    Parameters
    ----------
    A : np.ndarray
        Symmetric matrix
    tol : float
        Tolerance for eigenvalue sign determination

    Returns
    -------
    bool
        True if A has at most one positive eigenvalue
    """
    eigenvalues = np.linalg.eigvalsh(A)
    n_positive = np.sum(eigenvalues > tol)
    return n_positive <= 1


def find_instability_threshold(m: int, perturbation_type: str = "identity",
                                n_steps: int = 1000) -> float:
    """
    Binary search for the perturbation threshold where Lorentzianity breaks.

    Parameters
    ----------
    m : int
        Matrix dimension
    perturbation_type : str
        Type of perturbation: "identity" (t*I), "diagonal" (t*e_11), or "random"
    n_steps : int
        Number of binary search steps

    Returns
    -------
    float
        The approximate threshold value of t where Lorentzianity is lost
    """
    H = uniform_leaf_hessian(m)

    if perturbation_type == "identity":
        E = np.eye(m)
    elif perturbation_type == "diagonal":
        E = np.zeros((m, m))
        E[0, 0] = 1.0
    elif perturbation_type == "random":
        np.random.seed(42)
        E = np.random.randn(m, m)
        E = (E + E.T) / 2  # Symmetrize
        E /= np.max(np.abs(E))  # Normalize
    else:
        raise ValueError(f"Unknown perturbation type: {perturbation_type}")

    lo, hi = 0.0, 10.0 * m
    for _ in range(n_steps):
        mid = (lo + hi) / 2
        if verify_lorentzian_signature(H + mid * E):
            lo = mid
        else:
            hi = mid

    return (lo + hi) / 2


def compute_stability_table(max_n: int = 15) -> List[dict]:
    """
    Compute stability data for all valid (n, r) with n <= max_n.

    For each (n, r) with 2 <= r <= n-2, computes:
    - Leaf dimension m = n - r + 2
    - Spectral gap (always 1)
    - Entry-norm stability radius (1/m^2)
    - Empirical threshold for identity perturbation
    - Ratio of empirical to predicted

    Parameters
    ----------
    max_n : int
        Maximum value of n

    Returns
    -------
    List[dict]
        Table of stability data
    """
    results = []
    for n in range(4, max_n + 1):
        for r in range(2, n - 1):
            m = uniform_matroid_leaf_dimension(n, r)
            gap = lorentzian_spectral_gap(m)
            entry_radius = stability_radius_entry_norm(m)
            empirical = find_instability_threshold(m, "identity", n_steps=100)

            results.append({
                'n': n,
                'r': r,
                'm': m,
                'binomial': comb(n, r),
                'spectral_gap': gap,
                'entry_radius': entry_radius,
                'empirical_identity': empirical,
                'ratio_identity': empirical / gap if gap > 0 else float('inf'),
                'normalized_gap': normalized_stability_gap(n, r),
            })

    return results


def spectral_margin_report(n: int, r: int) -> dict:
    """
    Generate a complete spectral margin report for U_{r,n}.

    Parameters
    ----------
    n : int
        Number of variables
    r : int
        Degree

    Returns
    -------
    dict
        Complete spectral analysis
    """
    m = uniform_matroid_leaf_dimension(n, r)
    pos_eig, neg_eig, pos_mult, neg_mult = leaf_eigenvalues(m)
    H = uniform_leaf_hessian(m)

    # Verify eigenvalues numerically
    numerical_eigs = sorted(np.linalg.eigvalsh(H))

    return {
        'n': n,
        'r': r,
        'm': m,
        'positive_eigenvalue': pos_eig,
        'negative_eigenvalue': neg_eig,
        'pos_multiplicity': pos_mult,
        'neg_multiplicity': neg_mult,
        'spectral_gap': lorentzian_spectral_gap(m),
        'spectral_ratio': pos_eig / abs(neg_eig),
        'operator_norm_radius': stability_radius_operator_norm(m),
        'entry_norm_radius': stability_radius_entry_norm(m),
        'normalized_gap': normalized_stability_gap(n, r),
        'numerical_eigenvalues': numerical_eigs,
        'is_lorentzian': verify_lorentzian_signature(H),
        'hessian_structure': f"{pos_eig:.0f} * (J/m) + {neg_eig:.0f} * (I - J/m)",
    }


if __name__ == "__main__":
    # Example usage
    print("=== Spectral Margin Report for U_{3,6} ===")
    report = spectral_margin_report(6, 3)
    for key, value in report.items():
        print(f"  {key}: {value}")

    print("\n=== Stability Table (n ≤ 10) ===")
    table = compute_stability_table(10)
    print(f"{'n':>3} {'r':>3} {'m':>3} {'C(n,r)':>8} {'gap':>6} {'entry_rad':>10} {'empirical':>10} {'ratio':>8}")
    for row in table:
        print(f"{row['n']:>3} {row['r']:>3} {row['m']:>3} {row['binomial']:>8} "
              f"{row['spectral_gap']:>6.2f} {row['entry_radius']:>10.6f} "
              f"{row['empirical_identity']:>10.6f} {row['ratio_identity']:>8.4f}")
