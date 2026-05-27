#!/usr/bin/env python3
"""
algorithms.py — Certified algorithms for Lorentzian-to-coefficient bridge.

Implements:
  1. Bivariate specialization coefficient extraction
  2. Log-concavity certification (with violation witnesses)
  3. k-fold log-concavity depth computation
  4. Ratio transform iteration
  5. Newton inequality profiling
"""

from fractions import Fraction
from typing import List, Optional, Tuple, Union
import math


# ────────────────────────────────────────────────────────────────────
# Algorithm 1: Bivariate Specialization Extraction
# ────────────────────────────────────────────────────────────────────

def extract_bivariate_coefficients(
    polynomial_coeffs: dict,  # {(e1,...,en): coeff}
    u: list,  # direction vector 1
    v: list,  # direction vector 2
    degree: int
) -> List[float]:
    """
    Extract bivariate specialization coefficients from a multivariate
    homogeneous polynomial P by substituting x_i = u_i * s + v_i * t.

    Returns [a_0, a_1, ..., a_d] where P(u*s + v*t) = sum a_m s^m t^{d-m}.

    Time complexity: O(|supp(P)| * d)
    Space complexity: O(d)
    """
    n = len(u)
    coeffs = [0.0] * (degree + 1)

    for exponent, c in polynomial_coeffs.items():
        if len(exponent) != n:
            continue
        # For monomial x^alpha, substituting x_i = u_i*s + v_i*t:
        # Π_i (u_i*s + v_i*t)^{alpha_i} = Σ_m (Π_i C(alpha_i, k_i) u_i^k_i v_i^{alpha_i-k_i}) s^m t^{d-m}
        # where m = Σ k_i
        # Use dynamic programming over variables
        current = {0: 1.0}  # {power_of_s: coefficient}
        for i, ai in enumerate(exponent):
            new_current = {}
            for existing_power, existing_coeff in current.items():
                for ki in range(ai + 1):
                    power_s = existing_power + ki
                    binom = math.comb(ai, ki)
                    contribution = existing_coeff * binom * (u[i] ** ki) * (v[i] ** (ai - ki))
                    new_current[power_s] = new_current.get(power_s, 0.0) + contribution
            current = new_current

        for power_s, contribution in current.items():
            if 0 <= power_s <= degree:
                coeffs[power_s] += c * contribution

    return coeffs


# ────────────────────────────────────────────────────────────────────
# Algorithm 2: Log-Concavity Certification
# ────────────────────────────────────────────────────────────────────

class NewtonViolation:
    """Witness of a Newton inequality violation at index m."""
    def __init__(self, index: int, lhs: float, rhs: float):
        self.index = index
        self.lhs = lhs  # a_m^2
        self.rhs = rhs  # a_{m-1} * a_{m+1}

    def __repr__(self):
        return f"NewtonViolation(m={self.index}, a_m²={self.lhs:.6e}, a_{{m-1}}·a_{{m+1}}={self.rhs:.6e})"


def certify_log_concavity(
    seq: List[float],
    tolerance: float = 1e-12
) -> Tuple[bool, Optional[NewtonViolation]]:
    """
    Certify whether a sequence is log-concave.

    Returns (True, None) if log-concave, or (False, violation) with a
    concrete violating index.

    Time complexity: O(n)
    Space complexity: O(1)
    """
    for m in range(1, len(seq) - 1):
        lhs = seq[m] ** 2
        rhs = seq[m - 1] * seq[m + 1]
        if lhs < rhs - tolerance:
            return False, NewtonViolation(m, lhs, rhs)
    return True, None


# ────────────────────────────────────────────────────────────────────
# Algorithm 3: k-Fold Log-Concavity Depth Computation
# ────────────────────────────────────────────────────────────────────

def compute_kfold_depth(
    seq: List[float],
    max_depth: int = 50,
    tolerance: float = 1e-12
) -> int:
    """
    Compute the maximum k such that seq is k-fold log-concave.

    Algorithm:
      1. Check positivity (k=0)
      2. Check log-concavity and compute ratio transform
      3. Recurse on ratio transform
      4. Stop when log-concavity fails or sequence too short

    Time complexity: O(n * min(k, n))
    Space complexity: O(n)

    Returns the maximum depth k >= 0.
    """
    if any(x <= tolerance for x in seq):
        return -1  # not positive

    current = list(seq)
    for k in range(max_depth):
        if len(current) < 3:
            return k  # trivially log-concave (length < 3)

        is_lc, violation = certify_log_concavity(current, tolerance)
        if not is_lc:
            return k  # fails log-concavity at this level

        # Compute ratio transform
        ratio = [current[m + 1] / current[m] for m in range(len(current) - 1)]
        if any(r <= tolerance for r in ratio):
            return k + 1  # log-concave but ratio not positive

        current = ratio

    return max_depth


# ────────────────────────────────────────────────────────────────────
# Algorithm 4: Ratio Transform Iteration
# ────────────────────────────────────────────────────────────────────

def iterate_ratio_transforms(
    seq: List[float],
    levels: int
) -> List[List[float]]:
    """
    Compute iterated ratio transforms up to the given number of levels.

    Returns a list [seq, ratio_1, ratio_2, ..., ratio_levels].

    Time complexity: O(n * levels)
    Space complexity: O(n * levels)
    """
    result = [list(seq)]
    current = list(seq)
    for _ in range(levels):
        if len(current) < 2:
            break
        if any(x == 0 for x in current):
            break
        ratio = [current[m + 1] / current[m] for m in range(len(current) - 1)]
        result.append(ratio)
        current = ratio
    return result


# ────────────────────────────────────────────────────────────────────
# Algorithm 5: Newton Inequality Profile
# ────────────────────────────────────────────────────────────────────

def newton_profile(seq: List[float]) -> List[float]:
    """
    Compute the Newton inequality ratio a_m² / (a_{m-1} * a_{m+1})
    for each interior index m.

    For a log-concave sequence, all ratios are >= 1.
    For a Lorentzian specialization, the ratios satisfy additional
    structural constraints.

    Time complexity: O(n)
    Space complexity: O(n)
    """
    ratios = []
    for m in range(1, len(seq) - 1):
        denom = seq[m - 1] * seq[m + 1]
        if denom > 0:
            ratios.append(seq[m] ** 2 / denom)
        else:
            ratios.append(float('inf'))
    return ratios


# ────────────────────────────────────────────────────────────────────
# Algorithm 6: Certified k-Fold Log-Concavity
# ────────────────────────────────────────────────────────────────────

def certify_kfold_log_concavity(
    seq: List[float],
    target_depth: int,
    tolerance: float = 1e-12
) -> Union[bool, Tuple[int, NewtonViolation]]:
    """
    Certify that a sequence is k-fold log-concave at the target depth.

    Returns True if certified, or (level, violation) if a violation is found.

    This is the computational counterpart of the formal theorem
    `recursiveHessianLorentzian_implies_kFoldLogConcave`.

    Time complexity: O(n * k)
    Space complexity: O(n)
    """
    if any(x <= tolerance for x in seq):
        return (0, NewtonViolation(0, 0, 0))

    current = list(seq)
    for level in range(target_depth):
        if len(current) < 3:
            return True  # trivially true

        is_lc, violation = certify_log_concavity(current, tolerance)
        if not is_lc:
            return (level, violation)

        ratio = [current[m + 1] / current[m] for m in range(len(current) - 1)]
        if any(r <= tolerance for r in ratio):
            return True if level + 1 >= target_depth else (level + 1, NewtonViolation(0, 0, 0))

        current = ratio

    return True


# ────────────────────────────────────────────────────────────────────
# Algorithm 7: Product of Linear Forms Generator
# ────────────────────────────────────────────────────────────────────

def product_of_linear_forms(degree: int, weights: Optional[List[float]] = None) -> List[float]:
    """
    Generate coefficients of a product of positive linear forms.

    P(x,y) = Π_{i=1}^d (w_i * x + (1-w_i) * y)

    This polynomial is Lorentzian (as a limit of products of linear forms
    with positive coefficients), and its bivariate coefficients inherit
    all the log-concavity properties guaranteed by the bridge theorem.

    Time complexity: O(d²)
    Space complexity: O(d)
    """
    if weights is None:
        weights = [(i + 1) / (degree + 1) for i in range(degree)]

    coeffs = [1.0]
    for w in weights:
        new_coeffs = [0.0] * (len(coeffs) + 1)
        for i, c in enumerate(coeffs):
            new_coeffs[i] += c * (1 - w)
            new_coeffs[i + 1] += c * w
        coeffs = new_coeffs
    return coeffs


# ────────────────────────────────────────────────────────────────────
# Example Usage
# ────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 60)
    print("  Algorithm Demonstrations")
    print("=" * 60)
    print()

    # Demo: Product of linear forms
    d = 6
    coeffs = product_of_linear_forms(d)
    print(f"Product of {d} linear forms:")
    print(f"  Coefficients: {[round(c, 6) for c in coeffs]}")

    # Certify log-concavity
    is_lc, violation = certify_log_concavity(coeffs)
    print(f"  Log-concave: {is_lc}")

    # Compute k-fold depth
    depth = compute_kfold_depth(coeffs)
    print(f"  k-fold depth: {depth}")

    # Newton profile
    profile = newton_profile(coeffs)
    print(f"  Newton ratios: {[round(r, 4) for r in profile]}")

    # Iterated transforms
    transforms = iterate_ratio_transforms(coeffs, 4)
    for i, t in enumerate(transforms):
        print(f"  Level {i}: {[round(x, 4) for x in t]}")

    # Certification
    result = certify_kfold_log_concavity(coeffs, 3)
    print(f"  3-fold certified: {result}")
    print()

    # Demo: Binomial coefficients
    d = 10
    coeffs = [float(math.comb(d, m)) for m in range(d + 1)]
    depth = compute_kfold_depth(coeffs)
    print(f"Binomial C({d}, m):")
    print(f"  Coefficients: {[int(c) for c in coeffs]}")
    print(f"  k-fold depth: {depth}")
    print()

    # Demo: Bivariate specialization extraction
    # (x1 + x2)^2 = x1^2 + 2x1x2 + x2^2
    poly = {(2, 0): 1.0, (1, 1): 2.0, (0, 2): 1.0}
    u = [1.0, 0.0]
    v = [0.0, 1.0]
    coeffs = extract_bivariate_coefficients(poly, u, v, 2)
    print(f"Bivariate extraction of (x1+x2)^2 along standard axes:")
    print(f"  Coefficients: {coeffs}")
    print()
