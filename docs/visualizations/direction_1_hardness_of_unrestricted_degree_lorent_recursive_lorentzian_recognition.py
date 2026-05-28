#!/usr/bin/env python3
"""
Algorithms for Lorentzian Polynomial Recognition and Complexity Analysis

Implements:
1. Multiindex enumeration and counting
2. Derivative tree construction
3. Hessian computation and Lorentzian signature checking
4. Certificate complexity computation
5. CNF-to-polynomial encoding (experimental)

All algorithms include complexity analysis and example usage.
"""

import numpy as np
from math import comb
from typing import List, Tuple, Dict, Optional, Set
from itertools import product as iter_product
from functools import lru_cache


# ============================================================
# Algorithm 1: Multiindex Enumeration
# ============================================================
# Pseudocode:
#   ENUMERATE-MULTIINDICES(n, d):
#     if n == 0: return {()} if d == 0 else {}
#     if n == 1: return {(d,)}
#     result = {}
#     for k = 0 to d:
#       for α' in ENUMERATE-MULTIINDICES(n-1, d-k):
#         result.add((k,) + α')
#     return result
#
# Time: O(|output|) = O(C(n+d-1, d))
# Space: O(n * d) for recursion stack

def enumerate_multiindices(n: int, d: int) -> List[Tuple[int, ...]]:
    """
    Enumerate all multiindices α ∈ ℕ^n with |α| = d.

    Args:
        n: Number of variables
        d: Total weight

    Returns:
        List of all multiindices as tuples

    Complexity:
        Time: O(C(n+d-1, d)) — proportional to output size
        Space: O(n*d) stack depth

    Example:
        >>> enumerate_multiindices(2, 3)
        [(0, 3), (1, 2), (2, 1), (3, 0)]
    """
    if n == 0:
        return [()] if d == 0 else []
    if n == 1:
        return [(d,)]
    result = []
    for k in range(d + 1):
        for rest in enumerate_multiindices(n - 1, d - k):
            result.append((k,) + rest)
    return result


def multiindex_count(n: int, d: int) -> int:
    """
    Count multiindices of weight d in n variables.
    Uses the stars-and-bars formula: C(n+d-1, d).

    Time: O(min(n, d))
    """
    if n == 0:
        return 1 if d == 0 else 0
    return comb(n + d - 1, d)


# ============================================================
# Algorithm 2: Polynomial Representation and Derivatives
# ============================================================

class HomogeneousPolynomial:
    """
    A homogeneous polynomial represented as a dict from multiindices to coefficients.

    Supports:
    - Partial differentiation
    - Hessian computation
    - Degree and variable count queries
    """

    def __init__(self, n: int, d: int, coeffs: Dict[Tuple[int, ...], float]):
        """
        Args:
            n: Number of variables
            d: Degree
            coeffs: Map from multiindex (tuple of n ints summing to d) to coefficient
        """
        self.n = n
        self.d = d
        self.coeffs = {k: v for k, v in coeffs.items() if abs(v) > 1e-15}

    def partial_derivative(self, var: int) -> 'HomogeneousPolynomial':
        """
        Compute ∂f/∂x_var.

        Time: O(|support|)
        """
        new_coeffs = {}
        for alpha, coeff in self.coeffs.items():
            if alpha[var] > 0:
                new_alpha = list(alpha)
                new_coeff = coeff * alpha[var]
                new_alpha[var] -= 1
                new_coeffs[tuple(new_alpha)] = new_coeffs.get(tuple(new_alpha), 0) + new_coeff
        return HomogeneousPolynomial(self.n, max(self.d - 1, 0), new_coeffs)

    def iterated_derivative(self, alpha: Tuple[int, ...]) -> 'HomogeneousPolynomial':
        """
        Compute the iterated partial derivative ∂^|α|f / ∂x₀^α₀ ∂x₁^α₁ ...

        Time: O(|α| * |support|)
        """
        result = self
        for var in range(self.n):
            for _ in range(alpha[var]):
                result = result.partial_derivative(var)
        return result

    def hessian_matrix(self) -> np.ndarray:
        """
        Compute the Hessian matrix at the origin.
        For a quadratic f = Σ aᵢⱼ xᵢxⱼ, H[i][j] = coeff of ∂²f/∂xᵢ∂xⱼ evaluated at 0.

        Time: O(n² * |support|)
        """
        H = np.zeros((self.n, self.n))
        for i in range(self.n):
            fi = self.partial_derivative(i)
            for j in range(self.n):
                fij = fi.partial_derivative(j)
                # Constant term of fij
                zero_idx = tuple([0] * self.n)
                H[i][j] = fij.coeffs.get(zero_idx, 0.0)
        return H

    def has_nonneg_coefficients(self) -> bool:
        """Check if all coefficients are nonneg."""
        return all(c >= -1e-15 for c in self.coeffs.values())

    def evaluate(self, x: np.ndarray) -> float:
        """Evaluate the polynomial at point x."""
        result = 0.0
        for alpha, coeff in self.coeffs.items():
            term = coeff
            for i, a in enumerate(alpha):
                term *= x[i] ** a
            result += term
        return result

    def __repr__(self):
        terms = []
        for alpha, coeff in sorted(self.coeffs.items()):
            if abs(coeff) < 1e-15:
                continue
            vars_str = "".join(f"x{i}^{a}" if a > 1 else f"x{i}" if a == 1 else ""
                               for i, a in enumerate(alpha))
            terms.append(f"{coeff:.0f}·{vars_str}" if vars_str else f"{coeff:.0f}")
        return " + ".join(terms) if terms else "0"


# ============================================================
# Algorithm 3: Lorentzian Recognition via Derivative Tree
# ============================================================
# Pseudocode:
#   IS-RECURSIVELY-LORENTZIAN(f, n, d):
#     if not f.has_nonneg_coefficients(): return False
#     if d < 2: return True
#     for each α with |α| = d-2:
#       g = iterated_derivative(f, α)  // quadratic
#       H = hessian(g)
#       eigenvalues = eigenvalues(H)
#       if count(eigenvalues > 0) > 1: return False
#     return True
#
# Time: O(C(n+d-3, d-2) * n² * |support|)
# Space: O(n²) for Hessian

def is_lorentzian_quadratic(H: np.ndarray, tol: float = 1e-10) -> bool:
    """
    Check if a symmetric matrix has at most one positive eigenvalue.

    Time: O(n³) for eigenvalue computation
    """
    eigenvalues = np.linalg.eigvalsh(H)
    return np.sum(eigenvalues > tol) <= 1


def check_lorentzian_recursive(f: HomogeneousPolynomial) -> Tuple[bool, List[str]]:
    """
    Check if a polynomial is recursively Lorentzian.

    Returns:
        (is_lorentzian, list of obstruction descriptions)

    Complexity:
        Time: O(C(n+d-3, d-2) * (n² * |support| + n³))
        Space: O(n²)
    """
    if not f.has_nonneg_coefficients():
        return False, ["Negative coefficient found"]

    if f.d < 2:
        return True, []

    obstructions = []
    multiindices = enumerate_multiindices(f.n, f.d - 2)

    for alpha in multiindices:
        g = f.iterated_derivative(alpha)
        H = g.hessian_matrix()
        if not is_lorentzian_quadratic(H):
            eigenvalues = np.sort(np.linalg.eigvalsh(H))[::-1]
            obstructions.append(
                f"α={alpha}: eigenvalues={eigenvalues}, "
                f"{np.sum(eigenvalues > 1e-10)} positive"
            )

    return len(obstructions) == 0, obstructions


# ============================================================
# Algorithm 4: Certificate Complexity Computation
# ============================================================

def certificate_complexity(n: int, d: int) -> int:
    """
    Compute the certificate complexity (number of quadratic leaves).

    Time: O(min(n, d-2))
    """
    if d < 2:
        return 1
    return multiindex_count(n, d - 2)


def certificate_complexity_table(max_n: int = 15, max_d: int = 15) -> None:
    """Print a table of certificate complexities."""
    print(f"\nCertificate Complexity Table (n × d):")
    print(f"{'n\\d':>4}", end="")
    for d in range(2, max_d + 1):
        print(f"{d:>8}", end="")
    print()
    for n in range(1, max_n + 1):
        print(f"{n:4d}", end="")
        for d in range(2, max_d + 1):
            cc = certificate_complexity(n, d)
            if cc < 10**6:
                print(f"{cc:8d}", end="")
            else:
                print(f"{'>' + str(int(np.log2(cc)))+'b':>8}", end="")
        print()


# ============================================================
# Algorithm 5: CNF to Polynomial Encoding (Experimental)
# ============================================================

def cnf_to_polynomial(num_vars: int, clauses: List[List[Tuple[int, bool]]],
                      degree: Optional[int] = None) -> HomogeneousPolynomial:
    """
    Encode a CNF formula as a homogeneous polynomial.

    Strategy: For each clause C, create a monomial product of literal terms.
    A positive literal x_i contributes x_i; a negative literal ¬x_i contributes (1-x_i).
    The result is then homogenized to degree d using a slack variable.

    This is an experimental encoding for exploring the SAT-Lorentzian connection.

    Args:
        num_vars: Number of Boolean variables
        clauses: List of clauses
        degree: Target degree (default: num_vars + 2)

    Returns:
        HomogeneousPolynomial with num_vars + 1 variables (last is slack)
    """
    n = num_vars + 1  # +1 for homogenization variable
    if degree is None:
        degree = num_vars + 2

    coeffs: Dict[Tuple[int, ...], float] = {}

    for clause in clauses:
        # Each clause contributes a sum of literal monomials
        for lit_var, lit_pol in clause:
            alpha = [0] * n
            if lit_pol:  # positive literal: x_i * slack^(d-1)
                alpha[lit_var] = 1
                alpha[-1] = degree - 1
            else:  # negative literal: slack^d (represents "not x_i")
                alpha[-1] = degree
            key = tuple(alpha)
            coeffs[key] = coeffs.get(key, 0) + 1.0

    # Add a base polynomial for stability
    for i in range(n):
        alpha = [0] * n
        alpha[i] = degree
        key = tuple(alpha)
        coeffs[key] = coeffs.get(key, 0) + 1.0

    return HomogeneousPolynomial(n, degree, coeffs)


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("Algorithms for Lorentzian Recognition")
    print("=" * 60)

    # Example 1: Simple quadratic
    print("\n--- Example 1: x0² + 2x0x1 + x1² (Lorentzian) ---")
    f1 = HomogeneousPolynomial(2, 2, {(2, 0): 1, (1, 1): 2, (0, 2): 1})
    print(f"Polynomial: {f1}")
    H1 = f1.hessian_matrix()
    print(f"Hessian: {H1}")
    is_lor1, obs1 = check_lorentzian_recursive(f1)
    print(f"Lorentzian: {is_lor1}")

    # Example 2: x0² + x1² (NOT Lorentzian)
    print("\n--- Example 2: x0² + x1² (Not Lorentzian) ---")
    f2 = HomogeneousPolynomial(2, 2, {(2, 0): 1, (0, 2): 1})
    print(f"Polynomial: {f2}")
    H2 = f2.hessian_matrix()
    print(f"Hessian: {H2}")
    is_lor2, obs2 = check_lorentzian_recursive(f2)
    print(f"Lorentzian: {is_lor2}")
    for o in obs2:
        print(f"  Obstruction: {o}")

    # Example 3: Higher degree
    print("\n--- Example 3: x0³ + 3x0²x1 + 3x0x1² + x1³ = (x0+x1)³ ---")
    f3 = HomogeneousPolynomial(2, 3, {(3, 0): 1, (2, 1): 3, (1, 2): 3, (0, 3): 1})
    is_lor3, obs3 = check_lorentzian_recursive(f3)
    print(f"Polynomial: {f3}")
    print(f"Lorentzian: {is_lor3}")

    # Example 4: Certificate complexity
    print("\n--- Certificate Complexity ---")
    certificate_complexity_table(10, 10)

    # Example 5: CNF encoding
    print("\n--- CNF-to-Polynomial Encoding (Experimental) ---")
    clauses = [[(0, True), (1, False)], [(1, True), (2, True)]]
    p_phi = cnf_to_polynomial(3, clauses, degree=4)
    print(f"CNF: (x0 ∨ ¬x1) ∧ (x1 ∨ x2)")
    print(f"Encoded polynomial: {p_phi}")
    is_lor_phi, obs_phi = check_lorentzian_recursive(p_phi)
    print(f"Lorentzian: {is_lor_phi}")
