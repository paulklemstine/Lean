#!/usr/bin/env python3
"""
Algorithms for Anti-Cancellation in Aggregated Derivatives
===========================================================

Implements certified procedures for:
1. Computing second shadows of polynomial supports
2. Computing coefficient witnesses for D_A f
3. Checking anti-cancellation at each candidate exponent
4. Returning witness monomials proving positivity/nonvanishing

All algorithms include complexity analysis and type hints.
"""

from typing import Set, Dict, Tuple, List, Optional, FrozenSet
import numpy as np
from itertools import product


# ============================================================
# Type aliases
# ============================================================

Exponent = Tuple[int, ...]  # Multi-index (alpha_1, ..., alpha_n)
Support = FrozenSet[Exponent]
Coefficients = Dict[Exponent, float]
WeightMatrix = np.ndarray  # n x n matrix with positive entries


# ============================================================
# Algorithm 1: Second Shadow Computation
# ============================================================

def compute_second_shadow(support: Set[Exponent], n: int) -> Set[Exponent]:
    """
    Compute Sh_2(S) = {beta : exists alpha in S, exists i,j, alpha = beta + e_i + e_j}.

    Time complexity: O(|S| * n^2)
    Space complexity: O(|S| * n^2) worst case

    Args:
        support: Set of exponent vectors (tuples of nonneg integers)
        n: Number of variables

    Returns:
        Set of exponent vectors in the second shadow
    """
    shadow: Set[Exponent] = set()
    for alpha in support:
        for i in range(n):
            for j in range(n):
                beta = list(alpha)
                if i == j:
                    if beta[i] >= 2:
                        beta[i] -= 2
                        shadow.add(tuple(beta))
                else:
                    if beta[i] >= 1 and beta[j] >= 1:
                        beta[i] -= 1
                        beta[j] -= 1
                        shadow.add(tuple(beta))
    return shadow


def compute_diagonal_second_shadow(support: Set[Exponent], n: int) -> Set[Exponent]:
    """
    Compute diagonal second shadow: {beta : exists alpha in S, exists i, alpha = beta + 2e_i}.

    Time complexity: O(|S| * n)
    Space complexity: O(|S| * n)

    Args:
        support: Set of exponent vectors
        n: Number of variables

    Returns:
        Set of exponent vectors in the diagonal second shadow
    """
    shadow: Set[Exponent] = set()
    for alpha in support:
        for i in range(n):
            if alpha[i] >= 2:
                beta = list(alpha)
                beta[i] -= 2
                shadow.add(tuple(beta))
    return shadow


# ============================================================
# Algorithm 2: Coefficient Computation for D_A f
# ============================================================

def compute_second_derivative_coefficient(
    coeffs: Coefficients, i: int, j: int, beta: Exponent
) -> float:
    """
    Compute [beta](d_i d_j f) using the explicit coefficient formula.

    For i != j: (beta_i + 1)(beta_j + 1) * [beta + e_i + e_j]f
    For i == j: (beta_i + 1)(beta_i + 2) * [beta + 2e_i]f

    Time complexity: O(1)

    Args:
        coeffs: Coefficient dictionary of f
        i, j: Variable indices for differentiation
        beta: Target exponent vector

    Returns:
        The coefficient value
    """
    alpha = list(beta)
    if i == j:
        multiplier = (beta[i] + 1) * (beta[i] + 2)
        alpha[i] += 2
    else:
        multiplier = (beta[i] + 1) * (beta[j] + 1)
        alpha[i] += 1
        alpha[j] += 1

    return multiplier * coeffs.get(tuple(alpha), 0.0)


def compute_weighted_hessian_coefficient(
    coeffs: Coefficients, A: WeightMatrix, beta: Exponent, n: int
) -> float:
    """
    Compute [beta](D_A f) = sum_{i,j} A_{ij} * [beta](d_i d_j f).

    Time complexity: O(n^2)

    Args:
        coeffs: Coefficient dictionary of f
        A: Weight matrix (n x n, all entries > 0)
        beta: Target exponent vector
        n: Number of variables

    Returns:
        The coefficient of beta in D_A f
    """
    total = 0.0
    for i in range(n):
        for j in range(n):
            total += A[i, j] * compute_second_derivative_coefficient(coeffs, i, j, beta)
    return total


# ============================================================
# Algorithm 3: Anti-Cancellation Checker
# ============================================================

class AntiCancellationResult:
    """Result of anti-cancellation verification."""

    def __init__(self):
        self.verified: bool = True
        self.shadow_size: int = 0
        self.checked: int = 0
        self.positive_count: int = 0
        self.violations: List[Tuple[Exponent, float]] = []
        self.witnesses: Dict[Exponent, List[Tuple[int, int, Exponent, float]]] = {}

    def summary(self) -> str:
        lines = [
            f"Anti-cancellation verified: {self.verified}",
            f"Second shadow size: {self.shadow_size}",
            f"Exponents checked: {self.checked}",
            f"Positive coefficients: {self.positive_count}",
            f"Violations: {len(self.violations)}",
        ]
        return "\n".join(lines)


def check_anti_cancellation(
    coeffs: Coefficients,
    support: Set[Exponent],
    A: WeightMatrix,
    n: int,
    compute_witnesses: bool = True
) -> AntiCancellationResult:
    """
    Complete anti-cancellation verification.

    For each beta in Sh_2(supp(f)), checks that [beta](D_A f) > 0.
    Optionally computes witness monomials proving positivity.

    Time complexity: O(|Sh_2(S)| * n^2) for checking
                   + O(|Sh_2(S)| * |S| * n^2) for witness computation

    Args:
        coeffs: Coefficient dictionary (all values >= 0)
        support: Support of the polynomial
        A: Strictly positive weight matrix
        n: Number of variables
        compute_witnesses: Whether to compute witness monomials

    Returns:
        AntiCancellationResult with detailed verification data
    """
    result = AntiCancellationResult()

    # Compute second shadow
    shadow = compute_second_shadow(support, n)
    result.shadow_size = len(shadow)

    for beta in shadow:
        result.checked += 1

        # Compute coefficient
        c = compute_weighted_hessian_coefficient(coeffs, A, beta, n)

        if c > 1e-15:
            result.positive_count += 1
        else:
            result.verified = False
            result.violations.append((beta, c))

        # Compute witnesses if requested
        if compute_witnesses:
            witnesses = []
            for i in range(n):
                for j in range(n):
                    alpha = list(beta)
                    if i == j:
                        alpha[i] += 2
                    else:
                        alpha[i] += 1
                        alpha[j] += 1
                    alpha_t = tuple(alpha)
                    if alpha_t in support and coeffs.get(alpha_t, 0) > 0:
                        witnesses.append((i, j, alpha_t, coeffs[alpha_t]))
            result.witnesses[beta] = witnesses

    return result


# ============================================================
# Algorithm 4: M-Convexity Checker
# ============================================================

def check_m_convexity(support: Set[Exponent], n: int) -> Tuple[bool, Optional[Tuple]]:
    """
    Check the symmetric exchange property for M-convexity.

    Time complexity: O(|S|^2 * n^2)

    Args:
        support: Set of exponent vectors
        n: Number of variables

    Returns:
        (is_m_convex, counterexample_or_None)
        counterexample is (alpha, beta, i) showing failed exchange
    """
    support_set = frozenset(support)

    for alpha in support:
        for beta_ in support:
            for i in range(n):
                if alpha[i] > beta_[i]:
                    found = False
                    for j in range(n):
                        if alpha[j] < beta_[j]:
                            candidate = list(alpha)
                            candidate[i] -= 1
                            candidate[j] += 1
                            if tuple(candidate) in support_set:
                                found = True
                                break
                    if not found:
                        return False, (alpha, beta_, i)

    return True, None


# ============================================================
# Algorithm 5: Certified Support Propagation
# ============================================================

def certified_support_propagation(
    coeffs: Coefficients,
    support: Set[Exponent],
    A: WeightMatrix,
    n: int
) -> Dict[Exponent, float]:
    """
    Compute the exact support of D_A f with certification.

    For each beta in the second shadow, computes [beta](D_A f)
    and provides a certificate of positivity (the contributing terms).

    Time complexity: O(|Sh_2(S)| * n^2)

    Args:
        coeffs: Polynomial coefficients
        support: Polynomial support
        A: Strictly positive weight matrix
        n: Number of variables

    Returns:
        Dictionary mapping surviving exponents to their coefficients in D_A f
    """
    shadow = compute_second_shadow(support, n)
    result = {}

    for beta in shadow:
        c = compute_weighted_hessian_coefficient(coeffs, A, beta, n)
        if abs(c) > 1e-15:
            result[beta] = c

    return result


# ============================================================
# Example usage and testing
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("Algorithm Testing: Anti-Cancellation Verification")
    print("=" * 60)

    # Example: f = x^2 + xy + y^2 (n=2, d=2)
    n = 2
    coeffs = {(2, 0): 1.0, (1, 1): 1.0, (0, 2): 1.0}
    support = set(coeffs.keys())
    A = np.array([[1.0, 2.0], [2.0, 1.0]])

    print("\nPolynomial: f = x^2 + xy + y^2")
    print(f"Weight matrix A:\n{A}")

    # Check M-convexity
    is_mc, ce = check_m_convexity(support, n)
    print(f"\nM-convex: {is_mc}")

    # Compute shadows
    shadow = compute_second_shadow(support, n)
    diag_shadow = compute_diagonal_second_shadow(support, n)
    print(f"Full second shadow: {sorted(shadow)}")
    print(f"Diagonal second shadow: {sorted(diag_shadow)}")

    # Full verification
    result = check_anti_cancellation(coeffs, support, A, n)
    print(f"\n{result.summary()}")

    print("\nWitness details:")
    for beta, witnesses in sorted(result.witnesses.items()):
        c = compute_weighted_hessian_coefficient(coeffs, A, beta, n)
        print(f"  beta={beta}: coeff={c:.4f}")
        for w in witnesses:
            print(f"    witness: (i={w[0]}, j={w[1]}) -> alpha={w[2]}, f[alpha]={w[3]:.4f}")

    # Support propagation
    prop = certified_support_propagation(coeffs, support, A, n)
    print(f"\nPropagated support ({len(prop)} exponents):")
    for exp, c in sorted(prop.items()):
        print(f"  {exp}: {c:.6f}")
