#!/usr/bin/env python3
"""
algorithms.py — Algorithms for Mahler Measure Computation and Analysis

Implements the key algorithms from the research paper:
1. Mahler measure computation via root-factorization
2. Mahler measure computation via numerical circle integration
3. Companion matrix construction and spectral entropy
4. Cyclotomic polynomial detection
5. Exhaustive search for small Mahler measures

All functions include type hints, docstrings, and example usage.
"""

import numpy as np
from typing import List, Tuple, Optional, Set
from dataclasses import dataclass
import itertools


@dataclass
class MahlerMeasureResult:
    """Result of a Mahler measure computation."""
    mahler_measure: float
    log_mahler_measure: float
    roots: np.ndarray
    roots_outside_unit_circle: List[complex]
    method: str


def compute_mahler_measure_roots(
    coefficients: List[int],
    ascending: bool = True
) -> MahlerMeasureResult:
    """
    Compute Mahler measure via root-factorization formula.
    
    For P(X) = a_d X^d + ... + a_0 with roots α_1, ..., α_d:
      M(P) = |a_d| * ∏_i max(1, |α_i|)
      log M(P) = log|a_d| + ∑_i max(0, log|α_i|)
    
    Complexity: O(d^3) for root-finding via eigenvalue method.
    
    Args:
        coefficients: polynomial coefficients
        ascending: if True, [a_0, a_1, ..., a_d]; if False, [a_d, ..., a_0]
    
    Returns:
        MahlerMeasureResult with all computed quantities
    
    Example:
        >>> result = compute_mahler_measure_roots([2, -3, 1])  # X^2 - 3X + 2
        >>> abs(result.mahler_measure - 2.0) < 1e-10
        True
    """
    coeffs = list(coefficients)
    if ascending:
        coeffs_desc = coeffs[::-1]
    else:
        coeffs_desc = coeffs
    
    if len(coeffs_desc) < 2:
        return MahlerMeasureResult(
            mahler_measure=abs(coeffs_desc[0]) if coeffs_desc else 0,
            log_mahler_measure=np.log(abs(coeffs_desc[0])) if coeffs_desc and coeffs_desc[0] != 0 else 0,
            roots=np.array([]),
            roots_outside_unit_circle=[],
            method="root-factorization"
        )
    
    roots = np.roots(coeffs_desc)
    leading = coeffs_desc[0]
    
    M = abs(leading)
    for r in roots:
        M *= max(1.0, abs(r))
    
    outside = [r for r in roots if abs(r) > 1.0 + 1e-10]
    log_M = np.log(M) if M > 0 else float('-inf')
    
    return MahlerMeasureResult(
        mahler_measure=M,
        log_mahler_measure=log_M,
        roots=roots,
        roots_outside_unit_circle=outside,
        method="root-factorization"
    )


def compute_mahler_measure_integral(
    coefficients: List[int],
    ascending: bool = True,
    num_points: int = 100000
) -> MahlerMeasureResult:
    """
    Compute Mahler measure via numerical circle integration (Jensen's formula).
    
      log M(P) = (1/2π) ∫_0^{2π} log|P(e^{it})| dt
    
    Uses the trapezoidal rule, which is exponentially accurate for smooth
    periodic integrands without zeros on the unit circle.
    
    Complexity: O(d * N) where d = degree, N = num_points.
    
    Args:
        coefficients: polynomial coefficients
        ascending: if True, [a_0, a_1, ..., a_d]; if False, [a_d, ..., a_0]
        num_points: number of quadrature points on the circle
    
    Returns:
        MahlerMeasureResult
    
    Example:
        >>> result = compute_mahler_measure_integral([-2, 0, 0, 1])  # X^3 - 2
        >>> abs(result.mahler_measure - 2.0) < 1e-6
        True
    """
    coeffs = list(coefficients)
    if ascending:
        coeffs_desc = coeffs[::-1]
    else:
        coeffs_desc = coeffs
    
    t = np.linspace(0, 2 * np.pi, num_points, endpoint=False)
    z = np.exp(1j * t)
    values = np.polyval(coeffs_desc, z)
    log_abs = np.log(np.maximum(np.abs(values), 1e-300))
    log_M = np.mean(log_abs)
    M = np.exp(log_M)
    
    roots = np.roots(coeffs_desc) if len(coeffs_desc) > 1 else np.array([])
    outside = [r for r in roots if abs(r) > 1.0 + 1e-10]
    
    return MahlerMeasureResult(
        mahler_measure=M,
        log_mahler_measure=log_M,
        roots=roots,
        roots_outside_unit_circle=outside,
        method="circle-integral"
    )


def build_companion_matrix(
    coefficients: List[int],
    ascending: bool = True
) -> np.ndarray:
    """
    Build the companion matrix of a monic polynomial.
    
    For P(X) = X^d + a_{d-1}X^{d-1} + ... + a_0, the companion matrix is:
      C[i+1, i] = 1  (subdiagonal)
      C[i, d-1] = -a_i  (last column)
    
    The eigenvalues of C are exactly the roots of P, making the
    companion matrix the bridge between polynomial arithmetic and
    spectral theory.
    
    Complexity: O(d^2) construction, O(d^3) eigenvalue computation.
    
    Args:
        coefficients: [a_0, ..., a_d] with a_d = 1
        ascending: coefficient order
    
    Returns:
        d×d companion matrix as numpy array
    
    Example:
        >>> C = build_companion_matrix([-2, 0, 1])  # X^2 - 2
        >>> eigenvalues = np.linalg.eigvals(C)
        >>> sorted(abs(eigenvalues))  # [√2, √2]
    """
    coeffs = list(coefficients) if ascending else list(reversed(coefficients))
    d = len(coeffs) - 1
    
    assert abs(coeffs[-1]) == 1, "Polynomial must be monic (leading coeff = ±1)"
    
    C = np.zeros((d, d))
    for i in range(d - 1):
        C[i + 1, i] = 1.0
    for i in range(d):
        C[i, d - 1] = -float(coeffs[i]) / float(coeffs[-1])
    
    return C


def compute_spectral_entropy(matrix: np.ndarray) -> float:
    """
    Compute the spectral entropy of a square matrix.
    
      h(A) = ∑_λ max(0, log|λ|)
    
    where the sum runs over all eigenvalues λ of A (counted with multiplicity).
    
    For the companion matrix of a monic polynomial P, this equals log M(P).
    This is the algebraic entropy of the linear dynamical system x ↦ Ax
    on the torus ℝ^d/ℤ^d.
    
    Complexity: O(n^3) for eigenvalue computation.
    
    Args:
        matrix: square numpy array
    
    Returns:
        spectral entropy value
    
    Example:
        >>> C = build_companion_matrix([1, 1, 0, -1, -1, -1, -1, -1, 0, 1, 1])
        >>> h = compute_spectral_entropy(C)
        >>> abs(h - 0.16235) < 0.001  # Lehmer's constant
        True
    """
    eigenvalues = np.linalg.eigvals(matrix)
    return sum(max(0, np.log(abs(lam))) for lam in eigenvalues)


def is_cyclotomic_candidate(
    coefficients: List[int],
    ascending: bool = True,
    tolerance: float = 1e-8
) -> Tuple[bool, Optional[int]]:
    """
    Test whether a polynomial is likely cyclotomic by checking:
    1. All roots lie on the unit circle (|α| = 1)
    2. Mahler measure equals 1
    3. All roots are roots of unity
    
    Args:
        coefficients: polynomial coefficients
        ascending: coefficient order
        tolerance: numerical tolerance
    
    Returns:
        (is_cyclotomic, suggested_n) where n is the candidate order
    
    Example:
        >>> is_cyclotomic_candidate([1, 1, 1, 1, 1])  # Φ_5
        (True, 5)
    """
    result = compute_mahler_measure_roots(coefficients, ascending)
    
    # Check M = 1
    if abs(result.mahler_measure - 1.0) > tolerance:
        return False, None
    
    # Check all roots on unit circle
    for r in result.roots:
        if abs(abs(r) - 1.0) > tolerance:
            return False, None
    
    # Find minimal n such that all roots are n-th roots of unity
    for n in range(1, 1000):
        all_unity = True
        for r in result.roots:
            if abs(r**n - 1.0) > tolerance * 10:
                all_unity = False
                break
        if all_unity:
            return True, n
    
    return False, None


def search_small_mahler_measures(
    max_degree: int = 8,
    coeff_bound: int = 1,
    top_k: int = 20,
    monic_only: bool = True
) -> List[Tuple[float, float, List[int], int]]:
    """
    Exhaustive search for monic integer polynomials with small Mahler measure > 1.
    
    Enumerates all monic polynomials of degree ≤ max_degree with coefficients
    in [-coeff_bound, coeff_bound], computes their Mahler measures, and returns
    the top_k smallest values > 1.
    
    Complexity: O((2B+1)^d * d^3) per degree d, coefficient bound B.
    
    Args:
        max_degree: maximum polynomial degree
        coeff_bound: coefficient range [-B, B]
        top_k: number of smallest results to return
        monic_only: only search monic polynomials
    
    Returns:
        List of (M, log_M, coefficients, degree) sorted by M
    
    Example:
        >>> results = search_small_mahler_measures(max_degree=4, top_k=5)
        >>> all(r[0] > 1.0 for r in results)
        True
    """
    results = []
    coeff_range = list(range(-coeff_bound, coeff_bound + 1))
    
    for degree in range(2, max_degree + 1):
        # Enumerate lower coefficients
        for lower_coeffs in itertools.product(coeff_range, repeat=degree):
            coeffs_asc = list(lower_coeffs) + [1]  # monic
            
            try:
                result = compute_mahler_measure_roots(coeffs_asc)
                M = result.mahler_measure
                if M > 1.0 + 1e-10:
                    results.append((M, result.log_mahler_measure, coeffs_asc, degree))
            except Exception:
                pass
    
    results.sort(key=lambda x: x[0])
    return results[:top_k]


def check_reciprocal_symmetry(coefficients: List[int]) -> bool:
    """
    Check if a polynomial is reciprocal (palindromic):
    P(X) = X^d * P(1/X), equivalently a_i = a_{d-i}.
    
    Reciprocal polynomials appear frequently among candidates
    for small Mahler measure, and Lehmer's polynomial is reciprocal.
    
    Args:
        coefficients: polynomial coefficients in ascending order
    
    Returns:
        True if the polynomial is reciprocal
    
    Example:
        >>> check_reciprocal_symmetry([1, 1, 0, -1, -1, -1, -1, -1, 0, 1, 1])
        True  # Lehmer's polynomial
    """
    n = len(coefficients)
    return all(coefficients[i] == coefficients[n - 1 - i] for i in range(n // 2 + 1))


# ═══════════════════════════════════════════════════════════════════════
# Example usage and verification
# ═══════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("Algorithms for Mahler Measure — Verification Suite")
    print("=" * 60)
    print()
    
    # Verify root-factorization and integral methods agree
    test_cases = [
        ("X² - 2", [-2, 0, 1]),
        ("X² - 3X + 2", [2, -3, 1]),
        ("X³ - 1", [-1, 0, 0, 1]),
        ("X⁴ + 1", [1, 0, 0, 0, 1]),
        ("Lehmer", [1, 1, 0, -1, -1, -1, -1, -1, 0, 1, 1]),
    ]
    
    print("Method comparison (root-factorization vs circle integral):")
    print(f"  {'Polynomial':<15s}  {'M (roots)':>12s}  {'M (integral)':>12s}  {'Δ':>10s}")
    print(f"  {'-'*15}  {'-'*12}  {'-'*12}  {'-'*10}")
    
    for name, coeffs in test_cases:
        r1 = compute_mahler_measure_roots(coeffs)
        r2 = compute_mahler_measure_integral(coeffs)
        delta = abs(r1.mahler_measure - r2.mahler_measure)
        print(f"  {name:<15s}  {r1.mahler_measure:12.8f}  {r2.mahler_measure:12.8f}  {delta:10.2e}")
    
    print()
    
    # Verify spectral entropy bridge
    print("Spectral entropy bridge verification:")
    print(f"  {'Polynomial':<15s}  {'log M':>12s}  {'h(C)':>12s}  {'Δ':>10s}")
    print(f"  {'-'*15}  {'-'*12}  {'-'*12}  {'-'*10}")
    
    for name, coeffs in test_cases:
        r = compute_mahler_measure_roots(coeffs)
        C = build_companion_matrix(coeffs)
        h = compute_spectral_entropy(C)
        delta = abs(r.log_mahler_measure - h)
        print(f"  {name:<15s}  {r.log_mahler_measure:12.8f}  {h:12.8f}  {delta:10.2e}")
    
    print()
    
    # Cyclotomic detection
    print("Cyclotomic polynomial detection:")
    cyclo_tests = [
        ("X-1", [-1, 1]),
        ("X+1", [1, 1]),
        ("X²+X+1", [1, 1, 1]),
        ("X⁴+X³+X²+X+1", [1, 1, 1, 1, 1]),
        ("Lehmer", [1, 1, 0, -1, -1, -1, -1, -1, 0, 1, 1]),
    ]
    for name, coeffs in cyclo_tests:
        is_cyc, n = is_cyclotomic_candidate(coeffs)
        print(f"  {name:<20s}: cyclotomic = {is_cyc}, n = {n}")
    
    print()
    
    # Reciprocal symmetry check
    print("Reciprocal symmetry:")
    print(f"  Lehmer's polynomial: {check_reciprocal_symmetry([1,1,0,-1,-1,-1,-1,-1,0,1,1])}")
    print(f"  X² - 3X + 2:        {check_reciprocal_symmetry([2, -3, 1])}")
    print(f"  X² - 2:             {check_reciprocal_symmetry([-2, 0, 1])}")
    
    print()
    
    # Small Mahler measure search
    print("Exhaustive search for smallest Mahler measures (degree ≤ 6):")
    results = search_small_mahler_measures(max_degree=6, coeff_bound=1, top_k=10)
    for i, (M, log_M, coeffs, deg) in enumerate(results):
        recip = "R" if check_reciprocal_symmetry(coeffs) else " "
        print(f"  {i+1:2d}. M={M:.10f}  log M={log_M:.8f}  deg={deg}  "
              f"[{recip}]  coeffs={coeffs}")
