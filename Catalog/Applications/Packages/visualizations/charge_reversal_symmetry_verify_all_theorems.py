#!/usr/bin/env python3
"""
Algorithms for Charge-Reversal Symmetry in Tropical Matrix Geometry

Implements core algorithms for:
1. Charged weight computation
2. Tropical matrix distance
3. Tropical spectral analysis
4. Charge-reversal duality transformations
"""

import numpy as np
from typing import Tuple, List, Optional

# ============================================================
# Algorithm 1: Charged Weight Matrix
# ============================================================

def charged_weight(W: np.ndarray, A: np.ndarray, q: float) -> np.ndarray:
    """
    Compute the charged weight matrix.

    Algorithm:
        1. Compute antisymmetric part: S[i,j] = A[i,j] - A[j,i]
        2. Scale by charge: q * S
        3. Add to base: W + q * S

    Time complexity: O(n^2)
    Space complexity: O(n^2)

    Parameters
    ----------
    W : np.ndarray of shape (n, n)
        Base weight matrix.
    A : np.ndarray of shape (n, n)
        Perturbation matrix (will be antisymmetrized).
    q : float
        Charge parameter.

    Returns
    -------
    np.ndarray of shape (n, n)
        The charged weight matrix.

    Examples
    --------
    >>> W = np.array([[1.0, 2.0], [3.0, 4.0]])
    >>> A = np.array([[0.0, 1.0], [0.0, 0.0]])
    >>> charged_weight(W, A, 1.0)
    array([[1., 3.],
           [2., 4.]])
    """
    antisymm = A - A.T
    return W + q * antisymm


def charge_reverse(W: np.ndarray, A: np.ndarray, q: float) -> np.ndarray:
    """
    Apply charge reversal: compute chargedWeight(W, A, -q).
    
    By the core theorem, this equals chargedWeight(W^T, A, q)^T
    when computed via the general identity.
    
    Time complexity: O(n^2)
    """
    return charged_weight(W, A, -q)


# ============================================================
# Algorithm 2: Tropical Matrix Distance
# ============================================================

def trop_mat_dist(M: np.ndarray, N: np.ndarray) -> float:
    """
    Compute the tropical (L-infinity / Chebyshev) distance between matrices.

    Algorithm:
        tropMatDist(M, N) = max_{i,j} |M[i,j] - N[i,j]|

    Time complexity: O(n^2)
    Space complexity: O(n^2) for the difference matrix

    Parameters
    ----------
    M, N : np.ndarray of shape (n, n)
        Input matrices.

    Returns
    -------
    float
        The tropical distance.

    Properties (proven in Lean):
        - Non-negative
        - Symmetric: tropMatDist(M, N) = tropMatDist(N, M)
        - Transpose-invariant: tropMatDist(M^T, N^T) = tropMatDist(M, N)
    """
    return float(np.max(np.abs(M - N)))


# ============================================================
# Algorithm 3: Tropical Spectral Radius
# ============================================================

def trop_spec_radius(M: np.ndarray) -> float:
    """
    Compute the tropical spectral radius (maximum diagonal entry).

    Algorithm:
        tropSpecRadius(M) = max_i M[i,i]

    Time complexity: O(n)

    Properties (proven in Lean):
        - Transpose-invariant: tropSpecRadius(M^T) = tropSpecRadius(M)
        - Charge-invariant: tropSpecRadius(chargedWeight(W, A, q)) = tropSpecRadius(W)
    """
    return float(np.max(np.diag(M)))


# ============================================================
# Algorithm 4: Antisymmetric Decomposition
# ============================================================

def decompose_matrix(M: np.ndarray) -> Tuple[np.ndarray, np.ndarray]:
    """
    Decompose a matrix into symmetric and antisymmetric parts.

    M = S + K where S = (M + M^T)/2 is symmetric, K = (M - M^T)/2 is antisymmetric.

    This decomposition is fundamental to understanding charge-reversal symmetry:
    the symmetric part is charge-invariant, while the antisymmetric part
    flips sign under charge reversal.

    Time complexity: O(n^2)

    Returns
    -------
    (S, K) : tuple of np.ndarray
        S is the symmetric part, K is the antisymmetric part.
    """
    S = (M + M.T) / 2
    K = (M - M.T) / 2
    return S, K


# ============================================================
# Algorithm 5: Charge-Reversal Orbit
# ============================================================

def charge_orbit(W: np.ndarray, A: np.ndarray, q_values: List[float]) -> List[np.ndarray]:
    """
    Compute the orbit of a matrix under varying charge.

    For each q in q_values, computes chargedWeight(W, A, q).
    By the involution theorem, the orbit at q and -q are related by transpose.

    Time complexity: O(k * n^2) where k = len(q_values)

    Parameters
    ----------
    W : np.ndarray
        Base weight matrix.
    A : np.ndarray
        Perturbation matrix.
    q_values : list of float
        Charge values to compute.

    Returns
    -------
    list of np.ndarray
        The orbit matrices.
    """
    return [charged_weight(W, A, q) for q in q_values]


def verify_charge_reversal_identity(
    W: np.ndarray, A: np.ndarray, q: float, tol: float = 1e-12
) -> dict:
    """
    Verify all charge-reversal identities numerically.

    Returns a dictionary with verification results for each theorem.

    Time complexity: O(n^2)
    """
    n = W.shape[0]
    cw_q = charged_weight(W, A, q)
    cw_neg = charged_weight(W, A, -q)
    cw_wt_neg = charged_weight(W.T, A, -q)

    results = {}

    # Theorem 1: (cw(W,A,q))^T = cw(W^T, A, -q)
    err1 = np.max(np.abs(cw_q.T - cw_wt_neg))
    results["core_identity"] = {"error": err1, "passed": err1 < tol}

    # Theorem 2 (if W symmetric): (cw(W,A,q))^T = cw(W, A, -q)
    is_symm = np.allclose(W, W.T, atol=tol)
    if is_symm:
        err2 = np.max(np.abs(cw_q.T - cw_neg))
        results["symmetric_identity"] = {"error": err2, "passed": err2 < tol}

    # Theorem 3: cw(W, A, --q) = cw(W, A, q)
    cw_neg_neg = charged_weight(W, A, -(-q))
    err3 = np.max(np.abs(cw_neg_neg - cw_q))
    results["involutivity"] = {"error": err3, "passed": err3 < tol}

    # Theorem 4: diagonal invariance
    diag_err = max(abs(cw_q[i, i] - W[i, i]) for i in range(n))
    results["diagonal_invariance"] = {"error": diag_err, "passed": diag_err < tol}

    # Theorem 5: spectral radius invariance
    sr_q = trop_spec_radius(cw_q)
    sr_w = trop_spec_radius(W)
    err5 = abs(sr_q - sr_w)
    results["spectral_invariance"] = {"error": err5, "passed": err5 < tol}

    return results


# ============================================================
# Algorithm 6: Tropical Distance Under Duality
# ============================================================

def dual_distance_comparison(
    W: np.ndarray, A: np.ndarray, B: np.ndarray, q: float
) -> Tuple[float, float, float]:
    """
    Compare tropical distances in charge-q and charge-(-q) geometries.

    Returns (d_q, d_neg_q, |d_q - d_neg_q|).

    For symmetric W, the difference should be zero (proven in Lean).

    Time complexity: O(n^2)
    """
    cw_A_q = charged_weight(W, A, q)
    cw_B_q = charged_weight(W, B, q)
    cw_A_neg = charged_weight(W, A, -q)
    cw_B_neg = charged_weight(W, B, -q)

    d_q = trop_mat_dist(cw_A_q, cw_B_q)
    d_neg = trop_mat_dist(cw_A_neg, cw_B_neg)

    return d_q, d_neg, abs(d_q - d_neg)


if __name__ == "__main__":
    print("Charge-Reversal Symmetry: Algorithm Verification")
    print("=" * 50)

    np.random.seed(42)
    n = 4

    # Symmetric base weight
    W_raw = np.random.randn(n, n)
    W_symm = (W_raw + W_raw.T) / 2
    A = np.random.randn(n, n)
    B = np.random.randn(n, n)

    q = 2.5

    print(f"\nMatrix size: {n}x{n}, charge q = {q}")
    print(f"W is symmetric: {np.allclose(W_symm, W_symm.T)}")

    print("\n--- Verification Results ---")
    results = verify_charge_reversal_identity(W_symm, A, q)
    for name, res in results.items():
        status = "PASS" if res["passed"] else "FAIL"
        print(f"  {name:25s}: error = {res['error']:.2e}  [{status}]")

    print("\n--- Dual Distance Comparison ---")
    d_q, d_neg, diff = dual_distance_comparison(W_symm, A, B, q)
    print(f"  d(q={q})  = {d_q:.8f}")
    print(f"  d(q={-q}) = {d_neg:.8f}")
    print(f"  |diff|    = {diff:.2e}  [{'PASS' if diff < 1e-12 else 'FAIL'}]")

    print("\n--- Non-symmetric W test ---")
    W_nonsymm = np.random.randn(n, n)
    results2 = verify_charge_reversal_identity(W_nonsymm, A, q)
    for name, res in results2.items():
        status = "PASS" if res["passed"] else "FAIL"
        print(f"  {name:25s}: error = {res['error']:.2e}  [{status}]")
