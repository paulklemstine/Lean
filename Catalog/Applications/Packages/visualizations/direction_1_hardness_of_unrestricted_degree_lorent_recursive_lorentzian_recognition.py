#!/usr/bin/env python3
"""
algorithms.py — Algorithms for Lorentzian recognition complexity analysis.

Implements:
1. Derivative tree enumeration for multivariate polynomials
2. Quadratic leaf counting and Hessian extraction
3. Lorentzian signature testing via eigenvalue analysis
4. SAT-to-polynomial reduction
5. Certificate complexity computation

All algorithms include complexity analysis and example usage.
"""

import numpy as np
from math import comb, factorial
from typing import List, Tuple, Dict, Set, Optional, Callable
from itertools import product as iproduct
from functools import reduce


# ─────────────────────────────────────────────────────────────────────
# Algorithm 1: Multiindex Enumeration
# ─────────────────────────────────────────────────────────────────────

def enumerate_multiindices(n: int, d: int) -> List[Tuple[int, ...]]:
    """Enumerate all multiindices α ∈ ℕⁿ with |α| = d.
    
    Uses a recursive generating algorithm based on stars-and-bars.
    
    Time complexity: O(C(n+d-1, d)) — proportional to the output size.
    Space complexity: O(n · d) for the recursion stack.
    
    Args:
        n: Number of variables
        d: Weight (total degree)
    
    Returns:
        List of all multiindices as tuples.
    
    Example:
        >>> enumerate_multiindices(2, 3)
        [(3, 0), (2, 1), (1, 2), (0, 3)]
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
    """Count multiindices of weight d in n variables.
    
    Equals C(n + d - 1, d) by stars-and-bars.
    
    Time complexity: O(min(n, d)) for the binomial coefficient.
    
    Example:
        >>> multiindex_count(3, 4)
        15
    """
    if n == 0:
        return 1 if d == 0 else 0
    return comb(n + d - 1, d)


# ─────────────────────────────────────────────────────────────────────
# Algorithm 2: Polynomial Representation and Derivatives
# ─────────────────────────────────────────────────────────────────────

class MvPolynomial:
    """Sparse multivariate polynomial over ℝ.
    
    Represented as a dictionary mapping exponent tuples to coefficients.
    """
    
    def __init__(self, n_vars: int, terms: Optional[Dict[tuple, float]] = None):
        self.n_vars = n_vars
        self.terms = terms or {}
    
    def add_term(self, exponent: tuple, coeff: float):
        """Add a term c · x^α to the polynomial."""
        if len(exponent) != self.n_vars:
            raise ValueError(f"Exponent has {len(exponent)} components, expected {self.n_vars}")
        key = exponent
        self.terms[key] = self.terms.get(key, 0.0) + coeff
        if abs(self.terms[key]) < 1e-15:
            del self.terms[key]
    
    def degree(self) -> int:
        """Maximum total degree of any term."""
        if not self.terms:
            return -1
        return max(sum(e) for e in self.terms.keys())
    
    def partial_derivative(self, var_idx: int) -> 'MvPolynomial':
        """Compute ∂f/∂x_{var_idx}.
        
        Time complexity: O(|terms|).
        """
        result = MvPolynomial(self.n_vars)
        for exponent, coeff in self.terms.items():
            if exponent[var_idx] > 0:
                new_exp = list(exponent)
                new_coeff = coeff * exponent[var_idx]
                new_exp[var_idx] -= 1
                result.add_term(tuple(new_exp), new_coeff)
        return result
    
    def iterated_partial_derivative(self, alpha: tuple) -> 'MvPolynomial':
        """Compute ∂^|α| f / (∂x_0^{α_0} · ... · ∂x_{n-1}^{α_{n-1}}).
        
        Time complexity: O(|α| · |terms|).
        """
        result = MvPolynomial(self.n_vars, dict(self.terms))
        for var_idx in range(self.n_vars):
            for _ in range(alpha[var_idx]):
                result = result.partial_derivative(var_idx)
        return result
    
    def evaluate(self, point: List[float]) -> float:
        """Evaluate the polynomial at a point."""
        total = 0.0
        for exponent, coeff in self.terms.items():
            term = coeff
            for i, e in enumerate(exponent):
                term *= point[i] ** e
            total += term
        return total
    
    def hessian_matrix(self) -> np.ndarray:
        """Extract the Hessian matrix (matrix of second partial derivatives).
        
        For a degree-2 polynomial, this captures all information.
        Returns the matrix H where H[i,j] = coefficient of x_i x_j
        in the second derivative.
        
        Time complexity: O(n² · |terms|).
        """
        n = self.n_vars
        H = np.zeros((n, n))
        for i in range(n):
            for j in range(n):
                df = self.partial_derivative(i).partial_derivative(j)
                # Extract constant term
                zero_exp = tuple([0] * n)
                H[i, j] = df.terms.get(zero_exp, 0.0)
        return H
    
    def is_homogeneous(self, d: int) -> bool:
        """Check if the polynomial is homogeneous of degree d."""
        return all(sum(e) == d for e in self.terms.keys())
    
    def has_nonneg_coefficients(self) -> bool:
        """Check if all coefficients are nonnegative."""
        return all(c >= -1e-15 for c in self.terms.values())
    
    def __repr__(self):
        if not self.terms:
            return "0"
        parts = []
        for exp, coeff in sorted(self.terms.items(), key=lambda x: (-sum(x[0]), x[0])):
            vars_str = " · ".join(
                f"x{i}^{e}" if e > 1 else f"x{i}"
                for i, e in enumerate(exp) if e > 0
            )
            if not vars_str:
                vars_str = "1"
            parts.append(f"{coeff:.0f}·{vars_str}" if coeff != 1 else vars_str)
        return " + ".join(parts[:10]) + ("..." if len(parts) > 10 else "")


# ─────────────────────────────────────────────────────────────────────
# Algorithm 3: Recursive Lorentzian Recognition
# ─────────────────────────────────────────────────────────────────────

def is_lorentzian_signature(A: np.ndarray, tol: float = 1e-8) -> bool:
    """Test if a symmetric matrix has Lorentzian signature.
    
    A symmetric matrix has Lorentzian signature if it has at most one
    positive eigenvalue.
    
    Time complexity: O(n³) for eigenvalue decomposition.
    
    Args:
        A: Symmetric matrix
        tol: Tolerance for eigenvalue sign determination
    
    Returns:
        True if A has at most one positive eigenvalue.
    """
    eigenvalues = np.linalg.eigvalsh(A)
    n_positive = np.sum(eigenvalues > tol)
    return n_positive <= 1


def recursive_lorentzian_check(poly: MvPolynomial, degree: int,
                                verbose: bool = False) -> Tuple[bool, int]:
    """Recursively check if a polynomial is Lorentzian.
    
    Implements the recursive descent: for each multiindex α with |α| = d-2,
    compute the iterated derivative ∂^α f and check that its Hessian has
    Lorentzian signature.
    
    Time complexity: O(C(n+d-3, d-2) · n² · |terms|) — the product of
    leaf count, Hessian size, and derivative cost.
    
    Args:
        poly: Multivariate polynomial to check
        degree: Expected homogeneous degree
        verbose: Print details of each leaf check
    
    Returns:
        (is_lorentzian, num_leaves_checked)
    """
    n = poly.n_vars
    
    # Check nonnegative coefficients
    if not poly.has_nonneg_coefficients():
        return False, 0
    
    # Check homogeneity
    if not poly.is_homogeneous(degree):
        return False, 0
    
    if degree < 2:
        return True, 1
    
    # Enumerate all multiindices of weight d-2
    multiindices = enumerate_multiindices(n, degree - 2)
    leaves_checked = 0
    
    for alpha in multiindices:
        # Compute iterated derivative
        deriv = poly.iterated_partial_derivative(alpha)
        
        # Extract Hessian
        H = deriv.hessian_matrix()
        
        # Check Lorentzian signature
        is_lor = is_lorentzian_signature(H)
        leaves_checked += 1
        
        if verbose:
            evals = np.sort(np.linalg.eigvalsh(H))[::-1]
            status = "✓" if is_lor else "✗"
            print(f"  α={alpha}: eigenvalues={np.round(evals, 3)}, Lorentzian={status}")
        
        if not is_lor:
            return False, leaves_checked
    
    return True, leaves_checked


# ─────────────────────────────────────────────────────────────────────
# Algorithm 4: SAT-to-Polynomial Encoding
# ─────────────────────────────────────────────────────────────────────

def cnf_to_polynomial(num_vars: int,
                       clauses: List[List[Tuple[int, bool]]],
                       homogenize: bool = True) -> MvPolynomial:
    """Encode a CNF formula as a multivariate polynomial.
    
    For each clause C_j = (l_1 ∨ ... ∨ l_k), we construct the product
    ∏_{i∈vars(C_j)} t_i where t_i = x_{2i} if x_i ∈ C_j (positive literal)
    and t_i = x_{2i+1} if ¬x_i ∈ C_j (negative literal).
    
    The encoding polynomial is the sum of all clause products.
    
    If homogenize=True, we multiply each clause product by slack variables
    to make all terms the same total degree.
    
    Time complexity: O(m · 2^k) where m = number of clauses, k = max clause size.
    
    Args:
        num_vars: Number of Boolean variables
        clauses: List of clauses as (var_index, polarity) pairs
        homogenize: Whether to homogenize the polynomial
    
    Returns:
        MvPolynomial encoding the formula
    """
    n = num_vars
    # Use 2n variables: x_0, y_0, x_1, y_1, ..., x_{n-1}, y_{n-1}
    # Plus possibly a homogenizing variable
    n_poly_vars = 2 * n + (1 if homogenize else 0)
    poly = MvPolynomial(n_poly_vars)
    
    max_clause_size = max(len(c) for c in clauses) if clauses else 0
    
    for clause in clauses:
        # Build the monomial for this clause
        exponent = [0] * n_poly_vars
        for var_idx, polarity in clause:
            if polarity:
                exponent[2 * var_idx] += 1
            else:
                exponent[2 * var_idx + 1] += 1
        
        # Homogenize by adding slack variable powers
        if homogenize and len(clause) < max_clause_size:
            exponent[-1] = max_clause_size - len(clause)
        
        poly.add_term(tuple(exponent), 1.0)
    
    return poly


# ─────────────────────────────────────────────────────────────────────
# Algorithm 5: Certificate Complexity Analysis
# ─────────────────────────────────────────────────────────────────────

def certificate_complexity_bounds(n: int, d: int) -> Dict[str, int]:
    """Compute certificate complexity bounds for Lorentzian recognition.
    
    Returns the exact stars-and-bars count, the polynomial upper bound n^(d-2),
    and the exponential lower bound 2^(d-2) (when applicable).
    
    Time complexity: O(1) for each bound computation.
    
    Args:
        n: Number of variables
        d: Polynomial degree
    
    Returns:
        Dictionary with 'exact', 'upper_bound', 'lower_bound', 'regime' keys.
    """
    if d < 2:
        return {
            'exact': 1,
            'upper_bound': 1,
            'lower_bound': 1,
            'regime': 'trivial'
        }
    
    k = d - 2
    exact = comb(n + k - 1, k) if n > 0 else (1 if k == 0 else 0)
    upper = n ** k if n > 0 else 0
    lower = 2 ** k if 2 * k <= n else max(1, k + 1)
    
    # Determine regime
    if 2 * k <= n:
        regime = 'exponential' if k > 10 else 'moderate'
    else:
        regime = 'polynomial'
    
    return {
        'exact': exact,
        'upper_bound': upper,
        'lower_bound': lower,
        'regime': regime
    }


# ─────────────────────────────────────────────────────────────────────
# Example usage
# ─────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=== Multiindex Enumeration ===")
    for n, d in [(2, 3), (3, 2), (4, 1)]:
        indices = enumerate_multiindices(n, d)
        print(f"  n={n}, d={d}: {len(indices)} multiindices")
        if len(indices) <= 10:
            for idx in indices:
                print(f"    {idx}")
    
    print("\n=== Polynomial Derivative Tree ===")
    # Create x^3 + y^3 + 3xy(x+y) = (x+y)^3 - known Lorentzian
    p = MvPolynomial(2)
    p.add_term((3, 0), 1.0)  # x^3
    p.add_term((0, 3), 1.0)  # y^3
    p.add_term((2, 1), 3.0)  # 3x^2y
    p.add_term((1, 2), 3.0)  # 3xy^2
    print(f"  Polynomial: {p}")
    print(f"  Degree: {p.degree()}")
    print(f"  Homogeneous: {p.is_homogeneous(3)}")
    print(f"  Nonneg coefficients: {p.has_nonneg_coefficients()}")
    
    is_lor, leaves = recursive_lorentzian_check(p, 3, verbose=True)
    print(f"  Lorentzian: {is_lor} ({leaves} leaves checked)")
    
    print("\n=== Certificate Complexity ===")
    for d in [4, 6, 8, 10, 15, 20]:
        n = 2 * d
        bounds = certificate_complexity_bounds(n, d)
        print(f"  d={d}, n={n}: exact={bounds['exact']:,}, "
              f"upper={bounds['upper_bound']:,}, "
              f"lower={bounds['lower_bound']:,}, "
              f"regime={bounds['regime']}")
    
    print("\n=== SAT Encoding ===")
    # Encode a simple 2-SAT instance
    clauses = [
        [(0, True), (1, True)],
        [(0, False), (1, False)],
    ]
    poly = cnf_to_polynomial(2, clauses, homogenize=True)
    print(f"  Formula: (x0 ∨ x1) ∧ (¬x0 ∨ ¬x1)")
    print(f"  Encoding: {poly}")
    print(f"  Degree: {poly.degree()}")
