"""
Algorithms for Hessian Descent Certificate Checking

Implements the coefficient-level certificate verification for Lorentzian polynomials,
translating the spectral condition on Hessian matrices into discrete coefficient inequalities.

The central algorithm checks:
1. Mixed directional log-concavity: c(m+2e_i)*c(m+2e_j) <= c(m+e_i+e_j)^2
2. Axis directional log-concavity: c(m+2e_i)*c(m) <= c(m+e_i)^2
3. Exchange-closed support: matroid-style basis exchange

References:
    Brändén-Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
    Murota, "Discrete Convex Analysis", SIAM, 2003
"""

from __future__ import annotations
import numpy as np
from itertools import combinations_with_replacement, product
from typing import Dict, Tuple, List, Optional
from collections import defaultdict


# ─── Multi-index Utilities ────────────────────────────────────────────

def multi_indices(n: int, d: int) -> List[Tuple[int, ...]]:
    """Generate all multi-indices alpha in N^n with |alpha| = d."""
    if n == 0:
        return [()] if d == 0 else []
    if n == 1:
        return [(d,)]
    result = []
    for k in range(d + 1):
        for rest in multi_indices(n - 1, d - k):
            result.append((k,) + rest)
    return result


def unit_vector(n: int, i: int) -> Tuple[int, ...]:
    """Return the i-th standard basis vector e_i in N^n."""
    return tuple(1 if j == i else 0 for j in range(n))


def add_tuples(*tuples: Tuple[int, ...]) -> Tuple[int, ...]:
    """Coordinate-wise addition of multi-indices."""
    return tuple(sum(x) for x in zip(*tuples))


def sub_tuples(a: Tuple[int, ...], b: Tuple[int, ...]) -> Optional[Tuple[int, ...]]:
    """Coordinate-wise subtraction; returns None if result has negative entries."""
    result = tuple(ai - bi for ai, bi in zip(a, b))
    if any(x < 0 for x in result):
        return None
    return result


# ─── Polynomial Representation ────────────────────────────────────────

class HomogeneousPolynomial:
    """A homogeneous polynomial of degree d in n variables.

    Represented as a dictionary from multi-index tuples to real coefficients.
    Only nonzero coefficients are stored.

    Attributes:
        n: Number of variables.
        d: Degree of homogeneity.
        coeffs: Dictionary mapping multi-indices to coefficients.
    """

    def __init__(self, n: int, d: int, coeffs: Dict[Tuple[int, ...], float]):
        self.n = n
        self.d = d
        self.coeffs = {k: v for k, v in coeffs.items() if abs(v) > 1e-15}

    def coeff(self, alpha: Tuple[int, ...]) -> float:
        """Get coefficient at multi-index alpha."""
        return self.coeffs.get(alpha, 0.0)

    def support(self) -> List[Tuple[int, ...]]:
        """Return the support (multi-indices with nonzero coefficient)."""
        return list(self.coeffs.keys())

    def has_positive_coefficients(self) -> bool:
        """Check if all coefficients in support are positive."""
        return all(v > 0 for v in self.coeffs.values())

    def partial_derivative(self, var: int) -> 'HomogeneousPolynomial':
        """Compute ∂f/∂x_var."""
        if self.d == 0:
            return HomogeneousPolynomial(self.n, 0, {})
        new_coeffs: Dict[Tuple[int, ...], float] = {}
        for alpha, c in self.coeffs.items():
            if alpha[var] > 0:
                new_alpha = list(alpha)
                factor = new_alpha[var]
                new_alpha[var] -= 1
                new_alpha_t = tuple(new_alpha)
                new_coeffs[new_alpha_t] = new_coeffs.get(new_alpha_t, 0.0) + c * factor
        return HomogeneousPolynomial(self.n, max(0, self.d - 1), new_coeffs)

    def iterated_derivative(self, alpha: Tuple[int, ...]) -> 'HomogeneousPolynomial':
        """Compute the iterated partial derivative ∂^alpha f."""
        result = self
        for var in range(self.n):
            for _ in range(alpha[var]):
                result = result.partial_derivative(var)
        return result

    def hessian_matrix(self) -> np.ndarray:
        """Compute the Hessian matrix (constant term of ∂²f/∂x_i∂x_j)."""
        H = np.zeros((self.n, self.n))
        for i in range(self.n):
            for j in range(self.n):
                df_ij = self.partial_derivative(j).partial_derivative(i)
                zero_idx = tuple(0 for _ in range(self.n))
                H[i, j] = df_ij.coeff(zero_idx)
        return H

    def evaluate(self, x: np.ndarray) -> float:
        """Evaluate the polynomial at point x."""
        result = 0.0
        for alpha, c in self.coeffs.items():
            term = c
            for var, exp in enumerate(alpha):
                term *= x[var] ** exp
            result += term
        return result

    @staticmethod
    def random_positive(n: int, d: int, seed: Optional[int] = None) -> 'HomogeneousPolynomial':
        """Generate a random homogeneous polynomial with positive coefficients."""
        rng = np.random.default_rng(seed)
        indices = multi_indices(n, d)
        coeffs = {idx: rng.uniform(0.1, 5.0) for idx in indices}
        return HomogeneousPolynomial(n, d, coeffs)

    def __repr__(self) -> str:
        terms = []
        for alpha, c in sorted(self.coeffs.items()):
            var_parts = []
            for i, a in enumerate(alpha):
                if a > 0:
                    var_parts.append(f"x{i}^{a}" if a > 1 else f"x{i}")
            term = f"{c:.4f}" + ("*" + "*".join(var_parts) if var_parts else "")
            terms.append(term)
        return " + ".join(terms) if terms else "0"


# ─── Certificate Checking ─────────────────────────────────────────────

def check_mixed_directional_log_concavity(
    poly: HomogeneousPolynomial, tol: float = 1e-10
) -> Tuple[bool, List[str]]:
    """Check mixed directional log-concavity on coefficients.

    For every m with |m| = d-2 and every pair i, j:
        c(m + 2e_i) * c(m + 2e_j) <= c(m + e_i + e_j)^2

    Args:
        poly: Homogeneous polynomial to check.
        tol: Numerical tolerance.

    Returns:
        (passed, violations): Boolean and list of violation descriptions.

    Time complexity: O(N * n^2) where N = |{m : |m| = d-2}|, n = num vars.
    Space complexity: O(N * n^2) for storing results.
    """
    if poly.d < 2:
        return True, []

    violations = []
    leaf_indices = multi_indices(poly.n, poly.d - 2)

    for m in leaf_indices:
        for i in range(poly.n):
            for j in range(i, poly.n):
                ei = unit_vector(poly.n, i)
                ej = unit_vector(poly.n, j)

                # c(m + 2e_i)
                c_ii = poly.coeff(add_tuples(m, ei, ei))
                # c(m + 2e_j)
                c_jj = poly.coeff(add_tuples(m, ej, ej))
                # c(m + e_i + e_j)
                c_ij = poly.coeff(add_tuples(m, ei, ej))

                lhs = c_ii * c_jj
                rhs = c_ij ** 2

                if lhs > rhs + tol:
                    violations.append(
                        f"m={m}, i={i}, j={j}: "
                        f"c(m+2e{i})*c(m+2e{j})={lhs:.6f} > c(m+e{i}+e{j})^2={rhs:.6f}"
                    )

    return len(violations) == 0, violations


def check_axis_directional_log_concavity(
    poly: HomogeneousPolynomial, tol: float = 1e-10
) -> Tuple[bool, List[str]]:
    """Check axis directional log-concavity on coefficients.

    For every m with |m| = d-2 and every direction i:
        c(m + 2e_i) * c(m) <= c(m + e_i)^2

    Time complexity: O(N * n) where N = |{m : |m| = d-2}|.
    """
    if poly.d < 2:
        return True, []

    violations = []
    leaf_indices = multi_indices(poly.n, poly.d - 2)

    for m in leaf_indices:
        for i in range(poly.n):
            ei = unit_vector(poly.n, i)
            c_2i = poly.coeff(add_tuples(m, ei, ei))
            c_0 = poly.coeff(m)
            c_i = poly.coeff(add_tuples(m, ei))

            lhs = c_2i * c_0
            rhs = c_i ** 2

            if lhs > rhs + tol:
                violations.append(
                    f"m={m}, i={i}: c(m+2e{i})*c(m)={lhs:.6f} > c(m+e{i})^2={rhs:.6f}"
                )

    return len(violations) == 0, violations


def check_exchange_support(
    poly: HomogeneousPolynomial, tol: float = 1e-15
) -> Tuple[bool, List[str]]:
    """Check exchange-closed support property.

    For every α, β in support with same degree, if α_i > β_i for some i,
    then there exists j with β_j > α_j and c(α + e_j - e_i) ≠ 0.

    Time complexity: O(|supp|^2 * n^2).
    """
    violations = []
    supp = poly.support()

    for alpha in supp:
        for beta in supp:
            for i in range(poly.n):
                if alpha[i] > beta[i]:
                    found = False
                    for j in range(poly.n):
                        if beta[j] > alpha[j]:
                            exchanged = list(alpha)
                            exchanged[i] -= 1
                            exchanged[j] += 1
                            if abs(poly.coeff(tuple(exchanged))) > tol:
                                found = True
                                break
                    if not found:
                        violations.append(
                            f"α={alpha}, β={beta}, i={i}: no valid exchange partner"
                        )

    return len(violations) == 0, violations


def check_hessian_signature(poly: HomogeneousPolynomial) -> Tuple[bool, int]:
    """Check if the Hessian has at most one positive eigenvalue.

    Returns:
        (passed, num_positive_eigenvalues).
    """
    H = poly.hessian_matrix()
    eigenvalues = np.linalg.eigvalsh(H)
    num_positive = np.sum(eigenvalues > 1e-10)
    return num_positive <= 1, int(num_positive)


def check_all_quadratic_leaves(poly: HomogeneousPolynomial) -> Tuple[bool, List[str]]:
    """Check that all degree-2 derivative leaves have Lorentzian Hessian.

    This is the recursive Lorentzian condition: for each multi-index α
    with |α| = d-2, the iterated derivative ∂^α f has Hessian with
    at most one positive eigenvalue.

    Time complexity: O(C(n+d-3, d-2) * n^3) where n^3 is for eigenvalue computation.
    """
    if poly.d < 2:
        return True, []

    violations = []
    leaf_indices = multi_indices(poly.n, poly.d - 2)

    for alpha in leaf_indices:
        leaf = poly.iterated_derivative(alpha)
        passed, num_pos = check_hessian_signature(leaf)
        if not passed:
            violations.append(
                f"α={alpha}: leaf has {num_pos} positive eigenvalues"
            )

    return len(violations) == 0, violations


def check_hessian_descent_certificate(
    poly: HomogeneousPolynomial, tol: float = 1e-10
) -> Dict[str, Tuple[bool, List[str]]]:
    """Full Hessian descent certificate check.

    Checks all three conditions:
    1. Mixed directional log-concavity
    2. Axis directional log-concavity
    3. Exchange-closed support

    Also checks the spectral condition for comparison.

    Args:
        poly: Homogeneous polynomial with positive coefficients.
        tol: Numerical tolerance.

    Returns:
        Dictionary with check names mapping to (passed, violations/info).

    Time complexity: O(N*n^2 + |supp|^2*n^2 + N*n^3)
        where N = number of degree-(d-2) multi-indices.
    Space complexity: O(N*n^2).
    """
    results = {}

    results["positive_coefficients"] = (
        poly.has_positive_coefficients(),
        [] if poly.has_positive_coefficients() else ["Has non-positive coefficients"]
    )

    results["mixed_log_concavity"] = check_mixed_directional_log_concavity(poly, tol)
    results["axis_log_concavity"] = check_axis_directional_log_concavity(poly, tol)
    results["exchange_support"] = check_exchange_support(poly, tol)
    results["spectral_condition"] = check_all_quadratic_leaves(poly)

    return results


# ─── Lorentzian Polynomial Generators ─────────────────────────────────

def product_of_linear_forms(n: int, d: int, seed: Optional[int] = None) -> HomogeneousPolynomial:
    """Generate a Lorentzian polynomial as a product of linear forms.

    Products of linear forms with positive coefficients are always Lorentzian.
    This provides ground truth for testing.

    Args:
        n: Number of variables.
        d: Degree.
        seed: Random seed.

    Returns:
        Homogeneous polynomial that is guaranteed Lorentzian.
    """
    rng = np.random.default_rng(seed)
    # Start with the polynomial 1
    coeffs: Dict[Tuple[int, ...], float] = {tuple(0 for _ in range(n)): 1.0}

    for _ in range(d):
        # Random linear form with positive coefficients
        linear_coeffs = rng.uniform(0.5, 3.0, size=n)
        new_coeffs: Dict[Tuple[int, ...], float] = {}
        for alpha, c in coeffs.items():
            for var in range(n):
                new_alpha = list(alpha)
                new_alpha[var] += 1
                new_alpha_t = tuple(new_alpha)
                new_coeffs[new_alpha_t] = new_coeffs.get(new_alpha_t, 0.0) + c * linear_coeffs[var]
        coeffs = new_coeffs

    return HomogeneousPolynomial(n, d, coeffs)


def elementary_symmetric(n: int, d: int) -> HomogeneousPolynomial:
    """The d-th elementary symmetric polynomial in n variables.

    e_d(x_1, ..., x_n) = sum_{|S|=d} prod_{i in S} x_i

    Elementary symmetric polynomials are Lorentzian.
    """
    coeffs: Dict[Tuple[int, ...], float] = {}
    for subset in combinations_with_replacement(range(n), d):
        alpha = [0] * n
        for var in subset:
            alpha[var] += 1
        alpha_t = tuple(alpha)
        if max(alpha) <= 1:  # multi-affine condition
            coeffs[alpha_t] = 1.0
    return HomogeneousPolynomial(n, d, coeffs)


if __name__ == "__main__":
    print("=== Algorithms Module ===")
    print("\nExample: Product of linear forms (n=3, d=3)")
    f = product_of_linear_forms(3, 3, seed=42)
    print(f"Polynomial: {f}")
    results = check_hessian_descent_certificate(f)
    for name, (passed, info) in results.items():
        status = "PASS" if passed else "FAIL"
        print(f"  {name}: {status}")
        if not passed and info:
            for v in info[:3]:
                print(f"    {v}")

    print("\nExample: Random polynomial (n=3, d=3)")
    g = HomogeneousPolynomial.random_positive(3, 3, seed=17)
    print(f"Polynomial: {g}")
    results = check_hessian_descent_certificate(g)
    for name, (passed, info) in results.items():
        status = "PASS" if passed else "FAIL"
        print(f"  {name}: {status}")
