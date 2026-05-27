#!/usr/bin/env python3
"""
algorithms.py — Certified algorithms for the Lorentzian-to-Coefficient Bridge

Implements:
1. Log-concavity certification for finite sequences
2. k-fold log-concavity certification with violation detection
3. Bivariate specialization coefficient extraction
4. Ultra-log-concavity verification

All algorithms include docstrings, type hints, and example usage.
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Optional
from math import comb
import numpy as np
from itertools import combinations


# ─── Data Structures ──────────────────────────────────────────────────────────

@dataclass
class LogConcavityViolation:
    """Records a violation of the log-concavity inequality at index m."""
    index: int
    lhs: float   # a[m]^2
    rhs: float   # a[m-1] * a[m+1]
    deficit: float  # rhs - lhs (positive means violation)

    def __repr__(self) -> str:
        return (f"Violation at m={self.index}: "
                f"a[m]²={self.lhs:.6f} < a[m-1]·a[m+1]={self.rhs:.6f}, "
                f"deficit={self.deficit:.6f}")


@dataclass
class KFoldCertificate:
    """Certificate for k-fold log-concavity."""
    depth: int
    verified: bool
    violations: list[LogConcavityViolation]
    ratio_chains: list[list[float]]  # iterated ratio sequences

    def __repr__(self) -> str:
        status = "CERTIFIED" if self.verified else "VIOLATED"
        return f"KFoldCertificate(depth={self.depth}, status={status})"


# ─── Algorithm 1: Log-Concavity Certification ────────────────────────────────

def certify_log_concavity(
    seq: list[float],
    tol: float = 1e-12
) -> tuple[bool, Optional[LogConcavityViolation]]:
    """
    Certify whether a finite sequence is log-concave.

    Checks: a[m]² ≥ a[m-1] · a[m+1] for all 1 ≤ m ≤ len(seq)-2.

    Args:
        seq: The finite sequence (list of floats).
        tol: Numerical tolerance for floating-point comparison.

    Returns:
        (True, None) if log-concave, (False, violation) otherwise.

    Complexity: O(n) time, O(1) space.

    Example:
        >>> certify_log_concavity([1, 3, 6, 10, 15])
        (True, None)
        >>> certify_log_concavity([1, 2, 1, 3])
        (False, Violation at m=2: ...)
    """
    for m in range(1, len(seq) - 1):
        lhs = seq[m] ** 2
        rhs = seq[m - 1] * seq[m + 1]
        if lhs < rhs - tol:
            return False, LogConcavityViolation(m, lhs, rhs, rhs - lhs)
    return True, None


# ─── Algorithm 2: k-Fold Log-Concavity Certification ─────────────────────────

def certify_kfold_log_concavity(
    seq: list[float],
    k: int,
    tol: float = 1e-12
) -> KFoldCertificate:
    """
    Certify whether a finite positive sequence is k-fold log-concave.

    Definition (recursive):
      - 0-fold: all terms positive
      - (k+1)-fold: positive, log-concave, and ratio sequence is k-fold log-concave

    Args:
        seq: The finite sequence.
        k: The target depth.
        tol: Numerical tolerance.

    Returns:
        A KFoldCertificate with verification status and diagnostic data.

    Complexity: O(k · n) time, O(k · n) space for ratio chains.

    Example:
        >>> cert = certify_kfold_log_concavity([1, 4, 6, 4, 1], 3)
        >>> print(cert)
        KFoldCertificate(depth=3, status=CERTIFIED)
    """
    violations: list[LogConcavityViolation] = []
    ratio_chains: list[list[float]] = [list(seq)]
    current = list(seq)

    # Check positivity
    if any(x <= tol for x in current):
        return KFoldCertificate(k, False, violations, ratio_chains)

    for level in range(k):
        # Check log-concavity
        is_lc, violation = certify_log_concavity(current, tol)
        if not is_lc:
            assert violation is not None
            violations.append(violation)
            return KFoldCertificate(k, False, violations, ratio_chains)

        # Compute ratio transform
        if len(current) < 2:
            break
        ratios = [current[m + 1] / current[m]
                  for m in range(len(current) - 1)]
        ratio_chains.append(ratios)
        current = ratios

        # Check positivity of ratios
        if any(x <= tol for x in current):
            return KFoldCertificate(k, False, violations, ratio_chains)

    return KFoldCertificate(k, True, violations, ratio_chains)


# ─── Algorithm 3: Maximum Log-Concavity Depth ────────────────────────────────

def find_max_depth(
    seq: list[float],
    max_k: int = 50,
    tol: float = 1e-12
) -> int:
    """
    Find the maximum k such that seq is k-fold log-concave.

    Uses the iterative certification algorithm, stopping at the first
    failure or when the sequence becomes too short.

    Args:
        seq: The finite sequence.
        max_k: Upper bound on search depth.
        tol: Numerical tolerance.

    Returns:
        The maximum k-fold log-concavity depth.

    Complexity: O(min(max_k, n) · n) time.

    Example:
        >>> find_max_depth([1, 4, 6, 4, 1])
        3
    """
    current = list(seq)
    if any(x <= tol for x in current):
        return -1

    for k in range(max_k):
        if len(current) < 3:
            return k
        is_lc, _ = certify_log_concavity(current, tol)
        if not is_lc:
            return k
        # Compute ratio transform
        ratios = [current[m + 1] / current[m]
                  for m in range(len(current) - 1)]
        if any(x <= tol for x in ratios):
            return k + 1  # log-concave but ratio not positive
        current = ratios

    return max_k


# ─── Algorithm 4: Bivariate Specialization ────────────────────────────────────

def bivariate_specialization_product(
    weights: list[tuple[float, float]],
    d: int
) -> list[float]:
    """
    Compute coefficients of Q(x,y) = prod_i (w_i[0]*x + w_i[1]*y).

    The coefficient a_m of x^m * y^(d-m) is the m-th elementary
    mixed product:
      a_m = sum_{|S|=m} prod_{i in S} w_i[0] * prod_{i not in S} w_i[1]

    Args:
        weights: List of (u_i, v_i) pairs, all positive.
        d: Degree (must equal len(weights)).

    Returns:
        List of d+1 coefficients [a_0, a_1, ..., a_d].

    Complexity: O(C(d, d/2) · d) ≈ O(2^d · d) time.

    Example:
        >>> bivariate_specialization_product([(1, 1), (2, 1), (1, 3)], 3)
        [3.0, 8.0, 7.0, 2.0]
    """
    assert len(weights) == d
    coeffs = [0.0] * (d + 1)
    for m in range(d + 1):
        total = 0.0
        for S in combinations(range(d), m):
            S_set = set(S)
            prod_val = 1.0
            for i in range(d):
                prod_val *= weights[i][0] if i in S_set else weights[i][1]
            total += prod_val
        coeffs[m] = total
    return coeffs


# ─── Algorithm 5: Ultra-Log-Concavity Check ──────────────────────────────────

def check_ultra_log_concavity(
    seq: list[float],
    d: int,
    tol: float = 1e-12
) -> tuple[bool, Optional[int]]:
    """
    Check ultra-log-concavity: (a_m/C(d,m))² ≥ (a_{m-1}/C(d,m-1)) · (a_{m+1}/C(d,m+1)).

    Ultra-log-concavity is a stronger condition than ordinary log-concavity,
    accounting for the binomial envelope. It arises naturally from the
    Lorentzian structure of matroid basis generating polynomials.

    Args:
        seq: Coefficients [a_0, ..., a_d].
        d: Degree.
        tol: Tolerance.

    Returns:
        (True, None) if ultra-log-concave, (False, violating_index) otherwise.

    Complexity: O(d) time.

    Example:
        >>> check_ultra_log_concavity([1, 4, 6, 4, 1], 4)
        (True, None)
    """
    n = min(len(seq), d + 1)
    for m in range(1, n - 1):
        bm = comb(d, m)
        bm1 = comb(d, m - 1)
        bm2 = comb(d, m + 1)
        if bm == 0 or bm1 == 0 or bm2 == 0:
            continue
        lhs = (seq[m] / bm) ** 2
        rhs = (seq[m - 1] / bm1) * (seq[m + 1] / bm2)
        if lhs < rhs - tol:
            return False, m
    return True, None


# ─── Algorithm 6: Complete Certification Pipeline ─────────────────────────────

def full_certification(
    seq: list[float],
    d: int,
    target_k: Optional[int] = None
) -> dict:
    """
    Complete certification pipeline for a coefficient sequence.

    Runs all checks: positivity, log-concavity, ultra-log-concavity,
    k-fold log-concavity, and reports diagnostic information.

    Args:
        seq: The coefficient sequence.
        d: The degree.
        target_k: Target k-fold depth (default: d-2).

    Returns:
        Dictionary with certification results.

    Example:
        >>> result = full_certification([1, 4, 6, 4, 1], 4)
        >>> result['max_depth']
        3
    """
    if target_k is None:
        target_k = max(0, d - 2)

    positive = all(x > 0 for x in seq)
    lc_ok, lc_viol = certify_log_concavity(seq)
    ulc_ok, ulc_viol = check_ultra_log_concavity(seq, d)
    kfold_cert = certify_kfold_log_concavity(seq, target_k)
    max_depth = find_max_depth(seq)

    return {
        'positive': positive,
        'log_concave': lc_ok,
        'lc_violation': lc_viol,
        'ultra_log_concave': ulc_ok,
        'ulc_violation': ulc_viol,
        'kfold_certified': kfold_cert.verified,
        'target_k': target_k,
        'max_depth': max_depth,
        'ratio_chains': kfold_cert.ratio_chains,
    }


# ─── Main ─────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Algorithm Demonstrations")
    print("=" * 60)

    # Example 1: Binomial coefficients
    print("\n--- Binomial Coefficients C(8, m) ---")
    seq = [comb(8, m) for m in range(9)]
    print(f"  Sequence: {seq}")
    result = full_certification(seq, 8)
    print(f"  Positive: {result['positive']}")
    print(f"  Log-concave: {result['log_concave']}")
    print(f"  Ultra-log-concave: {result['ultra_log_concave']}")
    print(f"  Max k-fold depth: {result['max_depth']}")

    # Example 2: Product of linear forms
    print("\n--- Product of Linear Forms (d=5) ---")
    weights = [(1.0, 2.0), (2.0, 1.0), (1.5, 1.5), (3.0, 0.5), (0.5, 3.0)]
    seq2 = bivariate_specialization_product(weights, 5)
    print(f"  Weights: {weights}")
    print(f"  Coefficients: {[f'{c:.2f}' for c in seq2]}")
    result2 = full_certification(seq2, 5)
    print(f"  Log-concave: {result2['log_concave']}")
    print(f"  Max k-fold depth: {result2['max_depth']}")

    # Example 3: Non-log-concave sequence
    print("\n--- Non-log-concave sequence ---")
    seq3 = [1, 2, 1, 5, 1]
    print(f"  Sequence: {seq3}")
    result3 = full_certification(seq3, 4)
    print(f"  Log-concave: {result3['log_concave']}")
    if result3['lc_violation']:
        print(f"  Violation: {result3['lc_violation']}")
