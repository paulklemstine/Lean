#!/usr/bin/env python3
"""
Algorithms for Lorentzian Recognition Complexity Analysis

Implements the key algorithms from the research:
1. Multiindex enumeration and counting
2. Derivative tree traversal
3. Hessian eigenvalue checking
4. SAT-to-polynomial encoding
5. Certificate complexity analysis

All algorithms include docstrings, type hints, and example usage.
"""

import numpy as np
from itertools import combinations_with_replacement
from typing import List, Tuple, Dict, Optional, Set
import math


# ============================================================
# Algorithm 1: Multiindex Enumeration
# ============================================================

def enumerate_multiindices(n: int, d: int) -> List[Tuple[int, ...]]:
    """
    Enumerate all multiindices α ∈ ℕ^n with |α| = d.

    Uses the stars-and-bars bijection: each multiindex corresponds
    to a way of distributing d identical objects into n distinct bins.

    Time complexity: O(C(n+d-1, d))
    Space complexity: O(C(n+d-1, d) * n)

    Args:
        n: Number of variables
        d: Weight (degree)

    Returns:
        List of tuples, each representing a multiindex

    Example:
        >>> enumerate_multiindices(3, 2)
        [(2, 0, 0), (1, 1, 0), (1, 0, 1), (0, 2, 0), (0, 1, 1), (0, 0, 2)]
    """
    result = []
    for combo in combinations_with_replacement(range(n), d):
        alpha = [0] * n
        for v in combo:
            alpha[v] += 1
        result.append(tuple(alpha))
    return result


def multiindex_count_exact(n: int, d: int) -> int:
    """
    Exact count of multiindices: C(n + d - 1, d).

    This is the stars-and-bars formula. The formal development proves
    this count is ≥ 2^k when n ≥ k+1 (multiindex_count_ge_two_pow).

    Time complexity: O(min(n, d))

    Args:
        n: Number of variables
        d: Weight

    Returns:
        The binomial coefficient C(n + d - 1, d)
    """
    return math.comb(n + d - 1, d)


# ============================================================
# Algorithm 2: Derivative Tree Traversal
# ============================================================

class DerivativeTree:
    """
    Represents the recursive derivative tree for Lorentzian recognition.

    For a homogeneous polynomial of degree d in n variables, the recognition
    tree has:
    - Root: the original polynomial
    - Internal nodes: partial derivatives
    - Leaves: quadratic polynomials (degree 2)
    - Each leaf requires a Hessian eigenvalue check

    The number of leaves = C(n + d - 3, d - 2) for d ≥ 2.
    """

    def __init__(self, n: int, d: int):
        """
        Initialize the derivative tree.

        Args:
            n: Number of variables
            d: Degree of the polynomial
        """
        self.n = n
        self.d = d
        self.leaves = enumerate_multiindices(n, max(0, d - 2)) if d >= 2 else [()]

    @property
    def leaf_count(self) -> int:
        """Number of quadratic leaves."""
        return len(self.leaves)

    @property
    def upper_bound(self) -> int:
        """Upper bound n^(d-2) from catalog."""
        if self.d < 2:
            return 1
        return self.n ** (self.d - 2)

    @property
    def lower_bound(self) -> int:
        """Lower bound 2^(d-2) when n > d-2."""
        if self.d < 2:
            return 1
        k = self.d - 2
        if self.n > k:
            return 2 ** k
        return 1

    def traverse(self, max_display: int = 10) -> List[Dict]:
        """
        Traverse the derivative tree and return leaf information.

        Args:
            max_display: Maximum number of leaves to display

        Returns:
            List of dicts with leaf multiindex and derivative sequence
        """
        results = []
        for i, alpha in enumerate(self.leaves[:max_display]):
            results.append({
                'index': i,
                'multiindex': alpha,
                'derivative_order': sum(alpha),
                'remaining_degree': 2,
            })
        return results


# ============================================================
# Algorithm 3: Hessian Eigenvalue Checker
# ============================================================

def compute_hessian_from_matrix(A: np.ndarray) -> np.ndarray:
    """
    Compute the Hessian of P_A(x) = Σ A[i,j] x_i x_j.

    By the Hessian Spectral Encoding theorem (hessian_recovers_matrix):
    H(i,j) = A(i,j) + A(j,i)

    For symmetric A: H = 2A.

    Time complexity: O(n²)

    Args:
        A: Square matrix

    Returns:
        Hessian matrix H = A + A^T
    """
    return A + A.T


def check_lorentzian_signature(H: np.ndarray, tol: float = 1e-10) -> Tuple[bool, np.ndarray]:
    """
    Check if a symmetric matrix has Lorentzian signature
    (at most one positive eigenvalue).

    Time complexity: O(n³) for eigenvalue decomposition

    Args:
        H: Symmetric matrix
        tol: Tolerance for eigenvalue sign determination

    Returns:
        (is_lorentzian, eigenvalues)
    """
    eigenvalues = np.linalg.eigvalsh(H)
    n_positive = np.sum(eigenvalues > tol)
    return n_positive <= 1, eigenvalues


def check_all_leaves_lorentzian(
    coefficient_tensor: Dict[Tuple[int, ...], float],
    n: int,
    d: int,
    max_check: int = 1000
) -> Tuple[bool, int, Optional[Tuple[int, ...]]]:
    """
    Check Lorentzian condition at all quadratic leaves.

    For each multiindex α with |α| = d-2, compute the Hessian of
    the (d-2)-th derivative ∂^α f and check Lorentzian signature.

    Args:
        coefficient_tensor: Maps multiindices to coefficients
        n: Number of variables
        d: Degree
        max_check: Maximum leaves to check

    Returns:
        (all_lorentzian, leaves_checked, first_violation)
    """
    if d < 2:
        return True, 0, None

    leaves = enumerate_multiindices(n, d - 2)
    checked = 0

    for alpha in leaves[:max_check]:
        # For a monomial x^β, ∂^α(x^β) = (β!/( β-α)!) x^(β-α) if β ≥ α
        # The resulting quadratic's Hessian can be computed from coefficients
        H = np.zeros((n, n))

        for beta, coeff in coefficient_tensor.items():
            # Check if beta ≥ alpha componentwise
            if all(beta[k] >= alpha[k] for k in range(n)):
                gamma = tuple(beta[k] - alpha[k] for k in range(n))
                if sum(gamma) == 2:
                    # gamma has exactly two nonzero entries (or one entry = 2)
                    # Find the quadratic contribution
                    deriv_factor = 1
                    for k in range(n):
                        for j in range(alpha[k]):
                            deriv_factor *= (beta[k] - j)

                    for ii in range(n):
                        for jj in range(n):
                            if gamma[ii] >= 1 and gamma[jj] >= 1:
                                if ii == jj and gamma[ii] == 2:
                                    H[ii][jj] += coeff * deriv_factor * 2
                                elif ii != jj and gamma[ii] >= 1 and gamma[jj] >= 1:
                                    H[ii][jj] += coeff * deriv_factor

        is_lor, _ = check_lorentzian_signature(H)
        checked += 1

        if not is_lor:
            return False, checked, alpha

    return True, checked, None


# ============================================================
# Algorithm 4: SAT-to-Polynomial Encoding
# ============================================================

class CNFFormula:
    """CNF formula representation."""

    def __init__(self, n_vars: int, clauses: List[List[Tuple[int, bool]]]):
        self.n_vars = n_vars
        self.clauses = clauses

    def is_satisfied_by(self, assignment: Tuple[bool, ...]) -> bool:
        for clause in self.clauses:
            if not any(assignment[v] == p for v, p in clause):
                return False
        return True

    def brute_force_sat(self) -> Tuple[bool, Optional[Tuple[bool, ...]]]:
        from itertools import product
        for a in product([False, True], repeat=self.n_vars):
            if self.is_satisfied_by(a):
                return True, a
        return False, None

    def obstruction_count(self) -> Dict[Tuple[bool, ...], int]:
        """Count falsified clauses per assignment."""
        from itertools import product
        result = {}
        for a in product([False, True], repeat=self.n_vars):
            count = sum(1 for c in self.clauses
                       if not any(a[v] == p for v, p in c))
            result[a] = count
        return result


def encode_cnf_as_polynomial_coefficients(
    phi: CNFFormula
) -> Dict[Tuple[int, ...], float]:
    """
    Encode a CNF formula as polynomial coefficients.

    Creates a polynomial whose derivative structure mirrors
    the clause structure of the formula.

    The encoding uses slack variables to make the polynomial homogeneous.

    Args:
        phi: CNF formula

    Returns:
        Dictionary mapping multiindices to coefficients
    """
    n = phi.n_vars
    m = len(phi.clauses)
    total_vars = n + m + 1  # original + clause slack + homogenizing

    coeffs: Dict[Tuple[int, ...], float] = {}

    # For each clause, add a contribution
    for c_idx, clause in enumerate(phi.clauses):
        for var, pol in clause:
            alpha = [0] * total_vars
            alpha[var] = 1 if pol else 0
            alpha[n + c_idx] = 1  # clause slack variable
            alpha[-1] = max(0, m + 2 - sum(alpha))  # homogenize
            key = tuple(alpha)
            coeffs[key] = coeffs.get(key, 0) + 1.0

    return coeffs


# ============================================================
# Algorithm 5: Certificate Complexity Analysis
# ============================================================

def certificate_complexity_analysis(max_n: int = 20) -> List[Dict]:
    """
    Analyze certificate complexity across different regimes.

    Returns a table of certificate sizes for various (n, d) pairs.

    Args:
        max_n: Maximum number of variables to analyze

    Returns:
        List of analysis results
    """
    results = []

    for n in range(2, max_n + 1):
        for regime in ['fixed_d3', 'balanced', 'high_degree']:
            if regime == 'fixed_d3':
                d = 3
            elif regime == 'balanced':
                d = n
            else:
                d = 2 * n

            cert_size = multiindex_count_exact(n, max(0, d - 2))
            upper = n ** max(0, d - 2) if d >= 2 else 1
            lower = 2 ** max(0, d - 2) if n > max(0, d - 2) else 1

            results.append({
                'n': n,
                'd': d,
                'regime': regime,
                'certificate_size': cert_size,
                'upper_bound': upper,
                'lower_bound': lower,
                'log2_size': math.log2(cert_size) if cert_size > 0 else 0,
            })

    return results


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("Lorentzian Recognition: Algorithm Demonstrations")
    print("=" * 60)

    # Multiindex enumeration
    print("\n--- Multiindices of weight 3 in 3 variables ---")
    indices = enumerate_multiindices(3, 3)
    print(f"Count: {len(indices)} = C(3+3-1, 3) = C(5,3) = {math.comb(5,3)}")
    for idx in indices:
        print(f"  {idx}")

    # Derivative tree
    print("\n--- Derivative Tree (n=4, d=6) ---")
    tree = DerivativeTree(4, 6)
    print(f"Leaf count: {tree.leaf_count}")
    print(f"Upper bound: {tree.upper_bound}")
    print(f"Lower bound: {tree.lower_bound}")
    for leaf in tree.traverse(5):
        print(f"  Leaf {leaf['index']}: α = {leaf['multiindex']}")

    # Hessian encoding
    print("\n--- Hessian Encoding ---")
    A = np.array([[1.0, 0.5], [0.5, -2.0]])
    H = compute_hessian_from_matrix(A)
    is_lor, eigs = check_lorentzian_signature(H)
    print(f"A = {A.tolist()}")
    print(f"H = A + A^T = {H.tolist()}")
    print(f"Eigenvalues: {eigs}")
    print(f"Lorentzian: {is_lor}")

    # Certificate analysis
    print("\n--- Certificate Complexity Summary ---")
    results = certificate_complexity_analysis(10)
    balanced = [r for r in results if r['regime'] == 'balanced']
    print(f"{'n':>4} | {'d':>4} | {'Cert Size':>12} | {'log2':>8}")
    for r in balanced:
        print(f"{r['n']:>4} | {r['d']:>4} | {r['certificate_size']:>12} | {r['log2_size']:>8.2f}")
