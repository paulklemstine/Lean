#!/usr/bin/env python3
"""
Algorithms for DPP-Lorentzian Analysis
=======================================

Implements certified algorithms for:
1. Principal minor computation and partition function evaluation
2. Pairwise negative dependence certification
3. Lorentzian signature recognition via Hessian eigenvalue test
4. Spectral decomposition and eigenvalue statistics
"""

import numpy as np
from itertools import combinations
from typing import List, Tuple, Dict, Optional


def compute_all_principal_minors(K: np.ndarray) -> Dict[Tuple[int, ...], float]:
    """
    Compute all principal minors of K.

    Args:
        K: n×n matrix

    Returns:
        Dictionary mapping subsets (as sorted tuples) to their principal minor values.

    Time complexity: O(2^n · n^3) — exponential in n, polynomial per minor.
    Space complexity: O(2^n) for storing all minors.
    """
    n = K.shape[0]
    minors = {}
    for k in range(n + 1):
        for S in combinations(range(n), k):
            if len(S) == 0:
                minors[S] = 1.0
            else:
                idx = list(S)
                minors[S] = np.linalg.det(K[np.ix_(idx, idx)])
    return minors


def partition_function_value(K: np.ndarray, x: np.ndarray) -> float:
    """
    Evaluate the DPP partition function Z_K(x) = det(I + diag(x) K).

    This is the efficient method using a single determinant computation
    rather than summing over all 2^n subsets.

    Args:
        K: n×n PSD matrix (kernel)
        x: n-vector of evaluation points

    Returns:
        Z_K(x) = det(I + diag(x) K)

    Time complexity: O(n^3)
    Space complexity: O(n^2)
    """
    n = K.shape[0]
    return np.linalg.det(np.eye(n) + np.diag(x) @ K)


def elementary_symmetric_from_minors(
    minors: Dict[Tuple[int, ...], float], n: int
) -> List[float]:
    """
    Compute elementary symmetric polynomials e_k(K) = sum of k×k principal minors.

    These are the coefficients of the uniform specialization:
    det(I + tK) = sum_k e_k(K) t^k.

    Args:
        minors: dictionary of principal minors
        n: matrix dimension

    Returns:
        List [e_0, e_1, ..., e_n] where e_k = sum of |S|=k minors.
    """
    e = [0.0] * (n + 1)
    for S, val in minors.items():
        e[len(S)] += val
    return e


def certify_pairwise_negative_dependence(K: np.ndarray, tol: float = 1e-10) -> dict:
    """
    Certify that K satisfies pairwise negative dependence.

    For PSD K, this checks:
    (a) 0 ≤ K_ii * K_jj - K_ij² for all i ≠ j (Fischer lower bound)
    (b) K_ii * K_jj - K_ij² ≤ K_ii * K_jj for all i ≠ j (upper bound, trivial)

    The Fischer lower bound is equivalent to nonnegativity of 2×2 principal minors.

    Args:
        K: n×n matrix
        tol: numerical tolerance

    Returns:
        Dict with certification result, violations (if any), and statistics.

    Time complexity: O(n^2)
    Space complexity: O(n^2) for storing pair data.
    """
    n = K.shape[0]

    # Check symmetry
    sym_error = np.max(np.abs(K - K.T))

    # Check PSD (all eigenvalues ≥ 0)
    eigenvalues = np.linalg.eigvalsh(K)
    is_psd = np.all(eigenvalues >= -tol)

    violations_lower = []
    violations_upper = []
    ratios = []

    for i in range(n):
        for j in range(i + 1, n):
            pw = K[i, i] * K[j, j] - K[i, j] * K[j, i]
            prod = K[i, i] * K[j, j]

            # Lower bound: pw ≥ 0
            if pw < -tol:
                violations_lower.append((i, j, pw))

            # Upper bound: pw ≤ prod (equivalent to K[i,j]² ≥ 0, always true)
            if pw > prod + tol:
                violations_upper.append((i, j, pw, prod))

            if prod > tol:
                ratios.append(pw / prod)

    certified = len(violations_lower) == 0 and len(violations_upper) == 0

    return {
        "certified": certified,
        "is_psd": is_psd,
        "symmetry_error": sym_error,
        "min_eigenvalue": float(eigenvalues.min()),
        "violations_lower": violations_lower,
        "violations_upper": violations_upper,
        "num_pairs": n * (n - 1) // 2,
        "correlation_ratios": ratios,
        "min_ratio": min(ratios) if ratios else None,
        "max_ratio": max(ratios) if ratios else None,
        "mean_ratio": float(np.mean(ratios)) if ratios else None,
    }


def lorentzian_hessian_test(K: np.ndarray, d: int = 2, tol: float = 1e-10) -> dict:
    """
    Test Lorentzianity of the degree-d homogeneous component via Hessian signature.

    For d=2, the Hessian of the degree-2 component has entries H_{ij} = 2·det(K_{ij})
    (for i ≠ j) and H_{ii} = 0 (multiaffine). Lorentzianity requires at most one
    positive eigenvalue.

    For d > 2, we would need to check all (d-2)-fold directional derivatives.

    Pseudocode:
        1. Extract degree-d coefficients c_S for all |S| = d
        2. If d = 2: build Hessian H, compute eigenvalues, check ≤ 1 positive
        3. If d > 2: for each (d-2)-multi-index α, compute iterated derivative,
           build Hessian of resulting degree-2 poly, check signature

    Args:
        K: n×n PSD matrix
        d: degree of homogeneous component to test
        tol: numerical tolerance

    Returns:
        Dict with test results.

    Time complexity: O(n^d) for extracting coefficients, O(n^3) for eigenvalue check.
    """
    n = K.shape[0]
    if d > n:
        return {"is_lorentzian": True, "reason": "Zero polynomial (d > n)"}

    # Extract degree-d coefficients
    coeffs = {}
    for S in combinations(range(n), d):
        minor = np.linalg.det(K[np.ix_(list(S), list(S))]) if S else 1.0
        coeffs[S] = minor

    all_nonneg = all(c >= -tol for c in coeffs.values())

    if d == 0:
        return {"is_lorentzian": True, "all_nonneg": True, "reason": "Constant"}
    if d == 1:
        return {"is_lorentzian": all_nonneg, "all_nonneg": all_nonneg,
                "reason": "Degree 1, Lorentzian iff nonneg coeffs"}

    if d == 2:
        # Build Hessian
        H = np.zeros((n, n))
        for (i, j), c in coeffs.items():
            H[i, j] = c
            H[j, i] = c
        eigs = np.sort(np.linalg.eigvalsh(H))
        num_pos = int(np.sum(eigs > tol))
        is_lor = num_pos <= 1 and all_nonneg
        return {
            "is_lorentzian": is_lor,
            "all_nonneg": all_nonneg,
            "hessian_eigenvalues": eigs.tolist(),
            "num_positive_eigenvalues": num_pos,
        }

    # d > 2: check all (d-2)-fold derivatives
    # This is O(n^{d-2}) Hessian checks
    all_lorentzian = True
    num_leaves = 0
    for alpha in combinations(range(n), d - 2):
        num_leaves += 1
        # After differentiating by variables in alpha, the remaining
        # degree-2 polynomial has coefficients related to (d-2+2)-minors
        # containing all indices in alpha plus two more.
        H_leaf = np.zeros((n, n))
        for i in range(n):
            for j in range(i, n):
                S = tuple(sorted(set(alpha) | {i, j}))
                if len(S) == d:
                    c = coeffs.get(S, 0.0)
                    # Coefficient is c times the multinomial factor
                    H_leaf[i, j] += c
                    if i != j:
                        H_leaf[j, i] += c
        eigs = np.linalg.eigvalsh(H_leaf)
        if np.sum(eigs > tol) > 1:
            all_lorentzian = False

    return {
        "is_lorentzian": all_lorentzian and all_nonneg,
        "all_nonneg": all_nonneg,
        "num_leaves_checked": num_leaves,
        "degree": d,
    }


def spectral_statistics(K: np.ndarray) -> dict:
    """
    Compute spectral statistics connecting DPP theory to random matrix theory.

    The key identity: det(I + tK) = ∑_k e_k(K) t^k = ∏_i (1 + λ_i t)
    where e_k are elementary symmetric polynomials of eigenvalues.

    Args:
        K: n×n symmetric matrix

    Returns:
        Dict with eigenvalues, elementary symmetric polynomials,
        and partition function values.
    """
    n = K.shape[0]
    eigenvalues = np.sort(np.linalg.eigvalsh(K))

    # Elementary symmetric polynomials from eigenvalues
    # e_k = sum of products of k distinct eigenvalues
    e_from_eigs = [0.0] * (n + 1)
    e_from_eigs[0] = 1.0
    for k in range(1, n + 1):
        for combo in combinations(range(n), k):
            e_from_eigs[k] += np.prod([eigenvalues[i] for i in combo])

    # Elementary symmetric polynomials from principal minors
    minors = compute_all_principal_minors(K)
    e_from_minors = elementary_symmetric_from_minors(minors, n)

    return {
        "eigenvalues": eigenvalues.tolist(),
        "e_k_from_eigenvalues": e_from_eigs,
        "e_k_from_minors": e_from_minors,
        "det_I_plus_K": float(np.prod(1 + eigenvalues)),
        "trace": float(np.sum(eigenvalues)),
        "det_K": float(np.prod(eigenvalues)),
    }


if __name__ == "__main__":
    print("=== Algorithm Tests ===\n")

    # Test 1: Principal minor computation
    K = np.array([[2, 1], [1, 3]], dtype=float)
    minors = compute_all_principal_minors(K)
    print("K =", K.tolist())
    print("Principal minors:", minors)
    print()

    # Test 2: Certification
    n = 5
    A = np.random.default_rng(42).standard_normal((n, n))
    K = A.T @ A
    result = certify_pairwise_negative_dependence(K)
    print(f"Certification for {n}×{n} PSD matrix:")
    print(f"  Certified: {result['certified']}")
    print(f"  Min correlation ratio: {result['min_ratio']:.4f}")
    print(f"  Max correlation ratio: {result['max_ratio']:.4f}")
    print()

    # Test 3: Lorentzian test
    result = lorentzian_hessian_test(K, d=2)
    print(f"Lorentzian test (d=2): {result['is_lorentzian']}")
    print(f"  Hessian eigenvalues: {[round(e, 4) for e in result['hessian_eigenvalues']]}")
    print()

    # Test 4: Spectral statistics
    stats = spectral_statistics(K)
    print("Spectral statistics:")
    print(f"  Eigenvalues: {[round(e, 4) for e in stats['eigenvalues']]}")
    print(f"  e_k from eigenvalues: {[round(e, 4) for e in stats['e_k_from_eigenvalues']]}")
    print(f"  e_k from minors:      {[round(e, 4) for e in stats['e_k_from_minors']]}")
    print(f"  Match: {all(abs(a - b) < 1e-6 for a, b in zip(stats['e_k_from_eigenvalues'], stats['e_k_from_minors']))}")
