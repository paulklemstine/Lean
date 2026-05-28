"""
Algorithms for Lorentzian Stability Radius Computation
for Uniform Matroid Families U_{r,n}.

The uniform matroid U_{r,n} has basis generating polynomial e_r(x_1,...,x_n),
the r-th elementary symmetric polynomial. The Lorentzian property is detected
via quadratic leaf Hessians, which for uniform matroids are all permutation-
equivalent to the matrix J - I (all-ones minus identity) of appropriate size.

This module implements:
1. Canonical leaf Hessian computation
2. Spectral gap extraction
3. Stability radius estimation via binary search
4. Perturbation family construction for instability witnesses
"""

import numpy as np
from typing import Tuple, Dict, List, Optional
from math import comb


def leaf_hessian(m: int) -> np.ndarray:
    """
    Compute the canonical quadratic leaf Hessian for the uniform matroid.

    For U_{r,n}, after taking r-2 partial derivatives, the quadratic leaf
    is e_2 on m = n - r + 2 remaining variables. Its Hessian is J - I:
    diagonal entries 0, off-diagonal entries 1.

    Parameters
    ----------
    m : int
        Number of remaining variables (m = n - r + 2).

    Returns
    -------
    np.ndarray
        The m x m Hessian matrix J - I.

    Examples
    --------
    >>> leaf_hessian(3)
    array([[0., 1., 1.],
           [1., 0., 1.],
           [1., 1., 0.]])
    """
    return np.ones((m, m)) - np.eye(m)


def leaf_eigenvalues(m: int) -> Tuple[float, float, int, int]:
    """
    Compute the exact eigenvalues of the canonical leaf Hessian J - I.

    The matrix J - I on m variables has:
    - Eigenvalue (m-1) with multiplicity 1 (eigenvector: all-ones)
    - Eigenvalue -1 with multiplicity (m-1) (eigenvectors: orthogonal to all-ones)

    Parameters
    ----------
    m : int
        Matrix dimension.

    Returns
    -------
    tuple
        (lambda_pos, lambda_neg, mult_pos, mult_neg)
        Positive eigenvalue, negative eigenvalue, and their multiplicities.
    """
    return (m - 1, -1, 1, m - 1)


def spectral_gap(m: int) -> float:
    """
    Compute the spectral gap (absolute value of the negative eigenvalue).

    For J - I, this is always 1, regardless of m.

    Parameters
    ----------
    m : int
        Number of variables.

    Returns
    -------
    float
        The spectral gap = 1.
    """
    return 1.0


def normalized_spectral_gap(m: int) -> float:
    """
    Compute the normalized spectral gap: |lambda_neg| / lambda_pos = 1/(m-1).

    This measures how far the Hessian is from having a second positive eigenvalue,
    relative to the magnitude of the positive eigenvalue.

    Parameters
    ----------
    m : int
        Number of variables (must be >= 2).

    Returns
    -------
    float
        The normalized gap 1/(m-1).
    """
    if m <= 1:
        return float('inf')
    return 1.0 / (m - 1)


def stability_constant(m: int) -> float:
    """
    Compute the stability constant C_m such that entrywise perturbations
    bounded by C_m / m preserve the Lorentzian property.

    From the theorem: QuadFormBound E (m * B) when entries bounded by B.
    Combined with gap = 1, stability requires m * B < 1, i.e., B < 1/m.

    Parameters
    ----------
    m : int
        Number of variables.

    Returns
    -------
    float
        The stability constant 1/m.
    """
    if m == 0:
        return float('inf')
    return 1.0 / m


def uniform_matroid_params(n: int, r: int) -> Dict[str, float]:
    """
    Compute all Lorentzian stability parameters for U_{r,n}.

    Parameters
    ----------
    n : int
        Ground set size.
    r : int
        Rank (2 <= r <= n).

    Returns
    -------
    dict
        Dictionary with keys: m (leaf dimension), gap, normalized_gap,
        stability_const, n_choose_r, predicted_radius.
    """
    m = n - r + 2
    gap = spectral_gap(m)
    norm_gap = normalized_spectral_gap(m)
    stab_const = stability_constant(m)
    n_choose_r = comb(n, r)

    return {
        'n': n,
        'r': r,
        'm': m,
        'gap': gap,
        'normalized_gap': norm_gap,
        'stability_constant': stab_const,
        'n_choose_r': n_choose_r,
        'predicted_radius': stab_const,
    }


def construct_instability_witness(m: int, t: float) -> np.ndarray:
    """
    Construct an explicit perturbation that breaks Lorentzianity.

    The perturbation E = t * I (scalar matrix) added to J - I gives
    a matrix with eigenvalues (m-1+t) and (t-1). When t > 1, all
    eigenvalues are positive, so the matrix is positive definite and
    cannot have at most one positive eigenvalue.

    Parameters
    ----------
    m : int
        Matrix dimension.
    t : float
        Perturbation magnitude (t > 1 breaks Lorentzianity).

    Returns
    -------
    np.ndarray
        The perturbation matrix t * I.
    """
    return t * np.eye(m)


def verify_lorentzian_signature(H: np.ndarray, tol: float = 1e-10) -> bool:
    """
    Check if a symmetric matrix has at most one positive eigenvalue.

    Parameters
    ----------
    H : np.ndarray
        Symmetric matrix.
    tol : float
        Tolerance for eigenvalue sign determination.

    Returns
    -------
    bool
        True if H has at most one positive eigenvalue.
    """
    eigenvalues = np.linalg.eigvalsh(H)
    n_positive = np.sum(eigenvalues > tol)
    return n_positive <= 1


def binary_search_stability_radius(m: int, n_trials: int = 1000,
                                    tol: float = 1e-6,
                                    max_iter: int = 50) -> float:
    """
    Estimate the stability radius via binary search over perturbation magnitudes.

    For each perturbation magnitude, randomly samples perturbation matrices
    and checks if the Lorentzian property is preserved.

    Parameters
    ----------
    m : int
        Matrix dimension.
    n_trials : int
        Number of random perturbations per magnitude level.
    tol : float
        Binary search tolerance.
    max_iter : int
        Maximum binary search iterations.

    Returns
    -------
    float
        Estimated maximum entrywise perturbation bound preserving Lorentzianity.
    """
    H = leaf_hessian(m)
    lo, hi = 0.0, 2.0 / m  # Search between 0 and 2/m

    for _ in range(max_iter):
        if hi - lo < tol:
            break
        mid = (lo + hi) / 2
        all_stable = True
        for _ in range(n_trials):
            E = np.random.uniform(-mid, mid, (m, m))
            E = (E + E.T) / 2  # Symmetrize
            if not verify_lorentzian_signature(H + E):
                all_stable = False
                break
        if all_stable:
            lo = mid
        else:
            hi = mid

    return (lo + hi) / 2


def compute_radius_ratios(max_n: int = 15) -> List[Dict]:
    """
    Compute the ratio between empirical and predicted stability radii
    for all valid (n, r) pairs with n <= max_n.

    Parameters
    ----------
    max_n : int
        Maximum ground set size.

    Returns
    -------
    list
        List of dicts with n, r, m, predicted, empirical, ratio.
    """
    results = []
    for n in range(4, max_n + 1):
        for r in range(2, n - 1):
            m = n - r + 2
            if m < 2:
                continue
            predicted = stability_constant(m)
            empirical = binary_search_stability_radius(m, n_trials=200, tol=1e-4)
            ratio = empirical / predicted if predicted > 0 else float('inf')
            results.append({
                'n': n, 'r': r, 'm': m,
                'predicted': predicted,
                'empirical': empirical,
                'ratio': ratio
            })
    return results


if __name__ == '__main__':
    # Quick demonstration
    print("=== Uniform Matroid Lorentzian Stability Parameters ===\n")
    for n in range(4, 10):
        for r in range(2, n - 1):
            params = uniform_matroid_params(n, r)
            print(f"U_{{{r},{n}}}: m={params['m']}, gap={params['gap']}, "
                  f"C_m=1/{params['m']}, C(n,r)={params['n_choose_r']}")
    print()

    # Verify eigenvalue structure
    for m in range(2, 8):
        H = leaf_hessian(m)
        eigs = np.sort(np.linalg.eigvalsh(H))
        lam_pos, lam_neg, _, _ = leaf_eigenvalues(m)
        print(f"m={m}: eigenvalues = {eigs.round(6)}, "
              f"predicted: {lam_neg} (mult {m-1}), {lam_pos} (mult 1)")
