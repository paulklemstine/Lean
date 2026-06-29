#!/usr/bin/env python3
"""
algorithms.py — Algorithms for Lorentzian Polynomial Verification

Implements:
1. LorentzianCheck: Verify if a polynomial is Lorentzian
2. NewtonInequalityVerifier: Check Newton's inequalities
3. MConvexityChecker: Verify M-convexity of polynomial support
4. HessianAnalyzer: Compute and analyze Hessian eigenvalues
"""

import numpy as np
from itertools import combinations, product
from functools import reduce
from math import comb, factorial
from typing import List, Tuple, Dict, Optional, Set


# ─── Data Structures ───────────────────────────────────────────────────────

class HomogeneousPolynomial:
    """A homogeneous polynomial in n variables of degree d.

    Stored as a dictionary mapping multi-indices (tuples) to coefficients.

    Example:
        # f(x₀, x₁) = 3x₀² + 2x₀x₁ + x₁²
        f = HomogeneousPolynomial(n=2, d=2)
        f.set_coeff((2, 0), 3.0)
        f.set_coeff((1, 1), 2.0)
        f.set_coeff((0, 2), 1.0)
    """

    def __init__(self, n: int, d: int):
        self.n = n
        self.d = d
        self.coeffs: Dict[Tuple[int, ...], float] = {}

    def set_coeff(self, alpha: Tuple[int, ...], value: float) -> None:
        """Set coefficient of monomial x^α."""
        assert len(alpha) == self.n
        assert sum(alpha) == self.d
        if abs(value) > 1e-15:
            self.coeffs[alpha] = value
        elif alpha in self.coeffs:
            del self.coeffs[alpha]

    def get_coeff(self, alpha: Tuple[int, ...]) -> float:
        """Get coefficient of monomial x^α."""
        return self.coeffs.get(alpha, 0.0)

    def support(self) -> Set[Tuple[int, ...]]:
        """Return the support (set of monomials with nonzero coefficients)."""
        return set(self.coeffs.keys())

    @staticmethod
    def from_esp(w: np.ndarray) -> 'HomogeneousPolynomial':
        """Create the bivariate homogenization ∏(x₀ + wᵢx₁).

        This is ∑_k e_k(w) x₀^{m-k} x₁^k.

        Args:
            w: Array of nonneg weights.

        Returns:
            HomogeneousPolynomial of degree m in 2 variables.
        """
        m = len(w)
        f = HomogeneousPolynomial(n=2, d=m)
        coeffs = _generating_poly_coeffs(w)
        for k in range(m + 1):
            if abs(coeffs[k]) > 1e-15:
                f.set_coeff((m - k, k), coeffs[k])
        return f


def _generating_poly_coeffs(w: np.ndarray) -> np.ndarray:
    """Compute coefficients of ∏(1 + wᵢX)."""
    coeffs = np.array([1.0])
    for wi in w:
        new_coeffs = np.zeros(len(coeffs) + 1)
        new_coeffs[:len(coeffs)] += coeffs
        new_coeffs[1:len(coeffs)+1] += wi * coeffs
        coeffs = new_coeffs
    return coeffs


# ─── M-Convexity Checker ──────────────────────────────────────────────────

class MConvexityChecker:
    """Check M-convexity of the support of a homogeneous polynomial.

    A set S ⊂ ℤⁿ is M-convex if for any α, β ∈ S and any i with αᵢ > βᵢ,
    there exists j with αⱼ < βⱼ such that α - eᵢ + eⱼ ∈ S.

    Time complexity: O(|S|² · n²) where |S| is the support size.
    Space complexity: O(|S| · n).
    """

    @staticmethod
    def is_m_convex(support: Set[Tuple[int, ...]]) -> Tuple[bool, Optional[str]]:
        """Check if a set of integer vectors is M-convex.

        Args:
            support: Set of integer tuples (multi-indices).

        Returns:
            (is_m_convex, reason) where reason explains a violation if found.
        """
        support_list = list(support)
        if len(support_list) == 0:
            return True, None

        n = len(support_list[0])

        for alpha in support_list:
            for beta in support_list:
                if alpha == beta:
                    continue
                # Check same total degree
                if sum(alpha) != sum(beta):
                    continue
                # For each i with α_i > β_i
                for i in range(n):
                    if alpha[i] > beta[i]:
                        # Need j with α_j < β_j and α - eᵢ + eⱼ ∈ S
                        found = False
                        for j in range(n):
                            if alpha[j] < beta[j]:
                                swapped = list(alpha)
                                swapped[i] -= 1
                                swapped[j] += 1
                                if tuple(swapped) in support:
                                    found = True
                                    break
                        if not found:
                            return False, (
                                f"Violation: α={alpha}, β={beta}, i={i}: "
                                f"no valid exchange found"
                            )

        return True, None


# ─── Hessian Analyzer ──────────────────────────────────────────────────────

class HessianAnalyzer:
    """Compute and analyze Hessian quadratic forms of partial derivatives.

    For a homogeneous polynomial f of degree d, and a multi-index α with
    |α| = d-2, computes the Hessian matrix of the quadratic form ∂^α f.

    Time complexity: O(n² · |S|) per Hessian computation.
    """

    @staticmethod
    def compute_hessian(f: HomogeneousPolynomial,
                       alpha: Tuple[int, ...]) -> np.ndarray:
        """Compute the Hessian matrix of ∂^α f.

        After applying ∂^α, the result is a quadratic form. The Hessian
        entry H[i][j] is the coefficient of xᵢxⱼ (times combinatorial factors).

        Args:
            f: Homogeneous polynomial.
            alpha: Multi-index with |α| = d-2.

        Returns:
            n×n symmetric Hessian matrix.
        """
        n = f.n
        H = np.zeros((n, n))

        for i in range(n):
            for j in range(i, n):
                # The coefficient of xᵢxⱼ in ∂^α f
                beta = list(alpha)
                beta[i] += 1
                beta[j] += 1
                beta_tuple = tuple(beta)

                c = f.get_coeff(beta_tuple)
                if abs(c) < 1e-15:
                    continue

                # Multinomial factor from differentiation
                factor = 1.0
                for k in range(n):
                    top = beta[k]
                    bot = alpha[k]
                    factor *= factorial(top) / factorial(bot)

                H[i, j] = c * factor
                H[j, i] = H[i, j]

        return H

    @staticmethod
    def has_at_most_one_positive_eigenvalue(H: np.ndarray,
                                            tol: float = 1e-10) -> bool:
        """Check if a symmetric matrix has at most one positive eigenvalue."""
        eigenvalues = np.linalg.eigvalsh(H)
        n_positive = sum(1 for ev in eigenvalues if ev > tol)
        return n_positive <= 1

    @staticmethod
    def spectral_gap(H: np.ndarray, tol: float = 1e-10) -> float:
        """Compute the spectral gap: λ_max - λ₂⁺."""
        eigenvalues = sorted(np.linalg.eigvalsh(H), reverse=True)
        positive = [ev for ev in eigenvalues if ev > tol]
        if len(positive) <= 1:
            return positive[0] if positive else 0.0
        return positive[0] - positive[1]


# ─── Lorentzian Checker ───────────────────────────────────────────────────

class LorentzianChecker:
    """Verify whether a homogeneous polynomial is Lorentzian.

    A degree-d homogeneous polynomial f is Lorentzian if:
    1. All coefficients are nonnegative
    2. Support is M-convex
    3. For every α with |α| = d-2, the Hessian has ≤ 1 positive eigenvalue

    Time complexity: O(|S|² · n² + C(n+d-2, d-2) · n²)
    Space complexity: O(n² + |S| · n)
    """

    @staticmethod
    def check(f: HomogeneousPolynomial,
             verbose: bool = False) -> Tuple[bool, List[str]]:
        """Check if a polynomial is Lorentzian.

        Args:
            f: Homogeneous polynomial to check.
            verbose: Print detailed diagnostics.

        Returns:
            (is_lorentzian, list_of_issues)
        """
        issues = []

        # Check 1: Nonneg coefficients
        for alpha, c in f.coeffs.items():
            if c < -1e-15:
                issues.append(f"Negative coefficient at {alpha}: {c}")
        if verbose and not issues:
            print("  ✓ All coefficients nonnegative")

        # Check 2: M-convexity
        is_m, reason = MConvexityChecker.is_m_convex(f.support())
        if not is_m:
            issues.append(f"M-convexity violated: {reason}")
        if verbose and is_m:
            print("  ✓ Support is M-convex")

        # Check 3: Hessian condition (for d ≥ 2)
        if f.d >= 2:
            alphas = _multi_indices(f.n, f.d - 2)
            hessian_ok = True
            for alpha in alphas:
                H = HessianAnalyzer.compute_hessian(f, alpha)
                if not HessianAnalyzer.has_at_most_one_positive_eigenvalue(H):
                    issues.append(
                        f"Hessian at α={alpha} has >1 positive eigenvalue"
                    )
                    hessian_ok = False
            if verbose and hessian_ok:
                print(f"  ✓ All {len(alphas)} Hessian forms have ≤ 1 positive eigenvalue")

        is_lorentzian = len(issues) == 0
        if verbose:
            print(f"  Result: {'LORENTZIAN' if is_lorentzian else 'NOT LORENTZIAN'}")

        return is_lorentzian, issues


def _multi_indices(n: int, d: int) -> List[Tuple[int, ...]]:
    """Generate all multi-indices α ∈ ℕⁿ with |α| = d."""
    if n == 0:
        return [()] if d == 0 else []
    if n == 1:
        return [(d,)]
    result = []
    for first in range(d + 1):
        for rest in _multi_indices(n - 1, d - first):
            result.append((first,) + rest)
    return result


# ─── Newton's Inequality Verifier ─────────────────────────────────────────

class NewtonInequalityVerifier:
    """Verify Newton's inequality for elementary symmetric polynomials.

    For weights w₁,...,wₘ ≥ 0, checks:
        e_k(w)² ≥ e_{k-1}(w) · e_{k+1}(w)  for all 1 ≤ k ≤ m-1

    Time complexity: O(m · 2^m) for exact computation,
                     O(m²) using the generating polynomial.
    Space complexity: O(m).
    """

    @staticmethod
    def verify(w: np.ndarray,
              tol: float = 1e-10) -> Tuple[bool, List[Dict]]:
        """Verify Newton's inequality for all valid k.

        Returns:
            (all_satisfied, detailed_results)
        """
        m = len(w)
        coeffs = _generating_poly_coeffs(w)
        results = []

        for k in range(1, m):
            lhs = coeffs[k] ** 2
            rhs = coeffs[k-1] * coeffs[k+1]
            margin = lhs - rhs
            results.append({
                'k': k,
                'e_k': coeffs[k],
                'lhs': lhs,
                'rhs': rhs,
                'margin': margin,
                'satisfied': margin >= -tol
            })

        all_ok = all(r['satisfied'] for r in results)
        return all_ok, results


# ─── Example Usage ─────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Lorentzian Polynomial Verification Algorithms")
    print("=" * 50)

    # Example 1: Check that ∏(x₀ + wᵢx₁) is Lorentzian
    w = np.array([1.0, 2.0, 3.0])
    print(f"\n1. Checking if ∏(x₀ + wᵢx₁) is Lorentzian for w = {w}")
    f = HomogeneousPolynomial.from_esp(w)
    print(f"   Polynomial: Σ e_k x₀^{{m-k}} x₁^k")
    print(f"   Support: {sorted(f.support())}")
    is_lor, issues = LorentzianChecker.check(f, verbose=True)

    # Example 2: Newton's inequality
    print(f"\n2. Newton's inequality for w = {w}")
    ok, results = NewtonInequalityVerifier.verify(w)
    for r in results:
        print(f"   k={r['k']}: e_k²={r['lhs']:.4f}, "
              f"e_{{k-1}}·e_{{k+1}}={r['rhs']:.4f}, "
              f"margin={r['margin']:.4f} {'✓' if r['satisfied'] else '✗'}")

    # Example 3: M-convexity check
    print(f"\n3. M-convexity check")
    support = {(3, 0), (2, 1), (1, 2), (0, 3)}
    is_m, _ = MConvexityChecker.is_m_convex(support)
    print(f"   Support {sorted(support)}: M-convex = {is_m}")

    # Non-M-convex example
    support2 = {(2, 0, 0), (0, 0, 2)}  # Missing (1, 1, 0) etc.
    is_m2, reason2 = MConvexityChecker.is_m_convex(support2)
    print(f"   Support {sorted(support2)}: M-convex = {is_m2}")
    if reason2:
        print(f"   Reason: {reason2}")

    # Example 4: Spectral gap
    print(f"\n4. Spectral gap analysis for w = {w}")
    f2 = HomogeneousPolynomial.from_esp(w)
    for alpha in _multi_indices(2, len(w) - 2):
        H = HessianAnalyzer.compute_hessian(f2, alpha)
        gap = HessianAnalyzer.spectral_gap(H)
        eigenvalues = np.linalg.eigvalsh(H)
        print(f"   α={alpha}: eigenvalues={np.round(eigenvalues, 4)}, gap={gap:.4f}")
