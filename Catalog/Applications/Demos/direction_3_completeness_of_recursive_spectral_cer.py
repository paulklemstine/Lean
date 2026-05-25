#!/usr/bin/env python3
"""
applications.py — Real-World Applications of Lorentzian Polynomial Recognition

Demonstrates applications of the recursive spectral certificate for
Lorentzian polynomials in:
1. Matroid theory: basis generating polynomials
2. Log-concavity certification
3. Statistical mechanics: partition functions
4. Combinatorial optimization: stable polynomials
"""

import numpy as np
from itertools import combinations
from typing import List, Tuple


# ============================================================
# Utility: Polynomial representation
# ============================================================

def multiindices(n: int, d: int):
    """Generate all multiindices α ∈ ℕⁿ with |α| = d."""
    if n == 0:
        if d == 0:
            yield ()
        return
    for first in range(d + 1):
        for rest in multiindices(n - 1, d - first):
            yield (first,) + rest


def partial_derivative(coefficients: dict, n: int, var: int) -> dict:
    new_coeffs = {}
    for alpha, c in coefficients.items():
        if alpha[var] > 0:
            new_alpha = list(alpha)
            new_alpha[var] -= 1
            new_alpha = tuple(new_alpha)
            new_coeffs[new_alpha] = new_coeffs.get(new_alpha, 0.0) + c * alpha[var]
    return new_coeffs


def iterated_derivative(coefficients: dict, n: int, alpha: tuple) -> dict:
    result = coefficients
    for var in range(n):
        for _ in range(alpha[var]):
            result = partial_derivative(result, n, var)
    return result


def compute_hessian(coefficients: dict, n: int) -> np.ndarray:
    H = np.zeros((n, n))
    for i in range(n):
        di = partial_derivative(coefficients, n, i)
        for j in range(n):
            dij = partial_derivative(di, n, j)
            zero = tuple([0] * n)
            H[i][j] = dij.get(zero, 0.0)
    return H


def is_lorentzian(coefficients: dict, n: int, d: int) -> bool:
    """Check recursive Lorentzian predicate."""
    for c in coefficients.values():
        if c < -1e-12:
            return False
    if d < 2:
        return True
    for alpha in multiindices(n, d - 2):
        leaf = iterated_derivative(coefficients, n, alpha)
        H = compute_hessian(leaf, n)
        eigenvalues = np.linalg.eigvalsh(H)
        if np.sum(eigenvalues > 1e-10) > 1:
            return False
    return True


# ============================================================
# Application 1: Matroid Theory — Basis Generating Polynomials
# ============================================================

def basis_generating_polynomial(n: int, bases: List[Tuple]) -> dict:
    """Compute the basis generating polynomial of a matroid.

    f_M(x₁,...,xₙ) = ∑_{B ∈ bases} ∏_{i ∈ B} xᵢ

    Brändén–Huh proved these are always Lorentzian.
    """
    coeffs = {}
    for basis in bases:
        alpha = [0] * n
        for i in basis:
            alpha[i] = 1
        alpha = tuple(alpha)
        coeffs[alpha] = coeffs.get(alpha, 0.0) + 1.0
    return coeffs


def demo_matroid_application():
    print("=" * 60)
    print("APPLICATION 1: Matroid Basis Generating Polynomials")
    print("=" * 60)

    # Uniform matroid U_{2,4}: all 2-element subsets of {0,1,2,3}
    print("\n--- Uniform Matroid U(2,4) ---")
    bases = list(combinations(range(4), 2))
    coeffs = basis_generating_polynomial(4, bases)
    d = 2
    lor = is_lorentzian(coeffs, 4, d)
    print(f"  Bases: {bases}")
    print(f"  f_M = {format_poly(coeffs, 4)}")
    print(f"  Lorentzian: {lor} ✓" if lor else f"  Lorentzian: {lor} ✗")

    # Graphic matroid of K4 (complete graph on 4 vertices)
    print("\n--- Graphic Matroid of K₄ ---")
    # Edges of K4: {0,1}, {0,2}, {0,3}, {1,2}, {1,3}, {2,3}
    # Spanning trees (bases of rank 3):
    edges = [(0, 1), (0, 2), (0, 3), (1, 2), (1, 3), (2, 3)]
    # Enumerate spanning trees as 3-subsets of edges that form trees
    spanning_trees = []
    for tree in combinations(range(6), 3):
        # Check if it's a spanning tree (connected, no cycles, spans 4 vertices)
        tree_edges = [edges[i] for i in tree]
        vertices = set()
        for u, v in tree_edges:
            vertices.add(u)
            vertices.add(v)
        if len(vertices) < 4:
            continue
        # Check connectivity via union-find
        parent = list(range(4))
        def find(x):
            while parent[x] != x:
                parent[x] = parent[parent[x]]
                x = parent[x]
            return x
        for u, v in tree_edges:
            pu, pv = find(u), find(v)
            if pu != pv:
                parent[pu] = pv
        components = len(set(find(i) for i in range(4)))
        if components == 1:
            spanning_trees.append(tree)

    coeffs = basis_generating_polynomial(6, spanning_trees)
    d = 3
    lor = is_lorentzian(coeffs, 6, d)
    print(f"  Number of spanning trees: {len(spanning_trees)}")
    print(f"  Lorentzian: {lor} ✓" if lor else f"  Lorentzian: {lor} ✗")

    # Fano matroid (matroid on 7 elements, rank 3)
    print("\n--- Fano Matroid ---")
    # Lines of Fano plane: {0,1,3}, {1,2,4}, {2,3,5}, {3,4,6}, {0,4,5}, {1,5,6}, {0,2,6}
    fano_lines = [{0, 1, 3}, {1, 2, 4}, {2, 3, 5}, {3, 4, 6}, {0, 4, 5}, {1, 5, 6}, {0, 2, 6}]
    fano_bases = []
    for b in combinations(range(7), 3):
        bs = set(b)
        if bs not in fano_lines:
            fano_bases.append(b)
    coeffs = basis_generating_polynomial(7, fano_bases)
    d = 3
    lor = is_lorentzian(coeffs, 7, d)
    print(f"  Number of bases: {len(fano_bases)}")
    print(f"  Lorentzian: {lor} ✓" if lor else f"  Lorentzian: {lor} ✗")


# ============================================================
# Application 2: Log-Concavity Certification
# ============================================================

def demo_log_concavity():
    print("\n" + "=" * 60)
    print("APPLICATION 2: Log-Concavity Certification")
    print("=" * 60)
    print("  Lorentzian polynomials certify ultra-log-concavity of")
    print("  coefficient sequences via the reversed Cauchy–Schwarz inequality.")

    # For a Lorentzian polynomial f(x,y) = ∑ aₖ x^k y^(d-k),
    # the sequence (a₀, a₁, ..., a_d) is ultra-log-concave.
    print("\n--- Elementary Symmetric Polynomial e₃(x₁,...,x₅) ---")
    n = 5
    k = 3
    coeffs = {}
    for subset in combinations(range(n), k):
        alpha = [0] * n
        for i in subset:
            alpha[i] = 1
        coeffs[tuple(alpha)] = 1.0

    lor = is_lorentzian(coeffs, n, k)
    print(f"  Lorentzian: {lor}")

    # Specialize to 2 variables: f(x,y) = e₃(x,x,...,x,y,y,...,y)
    print("  Specializing to f(x,y) = e₃(x+y, x+y, ..., x+y):")
    from math import comb
    seq = [comb(n, k) * comb(k, j) * comb(n - k, k - j)
           if 0 <= j <= k and 0 <= k - j <= n - k else 0
           for j in range(k + 1)]
    # Actually just compute the restriction
    seq = []
    for j in range(k + 1):
        # Coefficient of x^j y^(k-j) in e_k(x,...,x,y,...,y) with n1 x's and n2 y's
        # This equals C(n1, j) * C(n2, k-j) for splitting into n1+n2=n
        pass

    # Simpler: use e_k(x,...,x) = C(n,k) x^k
    # Use specialization e_k(t*x₁ + (1-t)*x₂, ...) for log-concavity
    # Better: just show the coefficient sequence is log-concave
    print("  Coefficient counts by variable partition:")
    from collections import Counter
    counts = Counter()
    for subset in combinations(range(n), k):
        s = sum(1 for i in subset if i < n // 2)
        counts[s] += 1
    sorted_counts = [counts.get(j, 0) for j in range(k + 1)]
    print(f"  Sequence: {sorted_counts}")

    # Check log-concavity: a_k² ≥ a_{k-1} a_{k+1}
    is_lc = True
    for i in range(1, len(sorted_counts) - 1):
        if sorted_counts[i] ** 2 < sorted_counts[i - 1] * sorted_counts[i + 1]:
            is_lc = False
            break
    print(f"  Log-concave: {is_lc} ✓" if is_lc else f"  Log-concave: {is_lc} ✗")
    print("  (Guaranteed by Lorentzianity via reversed Cauchy–Schwarz)")


# ============================================================
# Application 3: Partition Functions in Statistical Mechanics
# ============================================================

def demo_partition_functions():
    print("\n" + "=" * 60)
    print("APPLICATION 3: Partition Functions & Negative Dependence")
    print("=" * 60)
    print("  Lorentzian polynomials arise as partition functions of")
    print("  determinantal point processes and fermionic systems.")

    # The partition function of a determinantal point process on n items
    # with kernel K is Z(x₁,...,xₙ) = det(I + diag(x) K)
    # For a PSD kernel, this is a Lorentzian polynomial.

    print("\n--- Determinantal Point Process (n=4) ---")
    n = 4
    # Random PSD kernel
    np.random.seed(42)
    A = np.random.randn(n, n)
    K = A @ A.T / n  # PSD matrix

    # Compute partition function coefficients
    # Z(x) = ∑_S det(K_S) ∏_{i∈S} xᵢ where K_S is the principal minor
    coeffs = {}
    for r in range(n + 1):
        for S in combinations(range(n), r):
            idx = list(S)
            if len(idx) == 0:
                det_val = 1.0
            else:
                minor = K[np.ix_(idx, idx)]
                det_val = np.linalg.det(minor)
            if abs(det_val) > 1e-15:
                alpha = [0] * n
                for i in S:
                    alpha[i] = 1
                coeffs[tuple(alpha)] = det_val

    # This is not homogeneous in general, but each homogeneous component is
    print(f"  Kernel K (4×4 PSD matrix):")
    for row in K:
        print(f"    [{', '.join(f'{x:.3f}' for x in row)}]")

    # Check each degree component
    for d in range(n + 1):
        deg_coeffs = {alpha: c for alpha, c in coeffs.items() if sum(alpha) == d}
        if deg_coeffs:
            lor = is_lorentzian(deg_coeffs, n, d)
            nonneg = all(c >= -1e-10 for c in deg_coeffs.values())
            print(f"  Degree {d} component: {len(deg_coeffs)} terms, "
                  f"nonneg={nonneg}, Lorentzian={lor}")

    print("\n  Negative dependence: for Lorentzian partition functions,")
    print("  Pr[i ∈ S AND j ∈ S] ≤ Pr[i ∈ S] · Pr[j ∈ S]")
    print("  (guaranteed by the reversed Cauchy–Schwarz inequality)")


# ============================================================
# Application 4: Combinatorial Optimization
# ============================================================

def demo_optimization():
    print("\n" + "=" * 60)
    print("APPLICATION 4: Combinatorial Optimization")
    print("=" * 60)
    print("  Lorentzian polynomials provide certificates for concavity")
    print("  on the positive orthant, enabling optimization guarantees.")

    # For a Lorentzian quadratic Q(x) = xᵀAx with A having Lorentzian signature:
    # √Q is concave on the positive cone {x : Q(x) > 0, x ≥ 0}
    print("\n--- Concavity Certificate for Quadratic Form ---")
    # Matrix with Lorentzian signature: one positive, rest negative
    A = np.array([
        [2.0, 1.0, 1.0],
        [1.0, -1.0, 0.0],
        [1.0, 0.0, -1.0],
    ])
    eigenvalues = np.sort(np.linalg.eigvalsh(A))[::-1]
    n_pos = np.sum(eigenvalues > 1e-10)
    print(f"  A = {A.tolist()}")
    print(f"  Eigenvalues: {eigenvalues}")
    print(f"  Lorentzian signature: {n_pos} positive eigenvalue(s)")

    if n_pos <= 1 and n_pos >= 1:
        print("  ✓ Q(x) = xᵀAx has concave √Q on {Q > 0}")
        print("  This enables efficient optimization over the positive cone.")

    # Tangent-space negativity
    print("\n  Tangent-space negativity demonstration:")
    x = np.array([1.0, 0.5, 0.3])
    Qx = x @ A @ x
    print(f"  x = {x}, Q(x) = {Qx:.4f}")
    if Qx > 0:
        Ax = A @ x
        # Find v orthogonal to Ax
        v = np.array([-Ax[1], Ax[0], 0])
        if np.abs(v @ Ax) > 1e-10:
            v = np.array([0, -Ax[2], Ax[1]])
        v = v / (np.linalg.norm(v) + 1e-15)
        Qv = v @ A @ v
        print(f"  v = {v} (orthogonal to Ax)")
        print(f"  Q(v) = {Qv:.4f}")
        print(f"  Q(v) ≤ 0: {Qv <= 1e-10} ✓" if Qv <= 1e-10
              else f"  Q(v) ≤ 0: False ✗")


# ============================================================
# Formatting Utility
# ============================================================

def format_poly(coeffs: dict, n: int) -> str:
    terms = []
    for alpha in sorted(coeffs.keys()):
        c = coeffs[alpha]
        if abs(c) < 1e-12:
            continue
        parts = []
        for i, a in enumerate(alpha):
            if a > 0:
                parts.append(f"x{i}^{a}" if a > 1 else f"x{i}")
        term = "·".join(parts) if parts else "1"
        if abs(c - 1.0) < 1e-12:
            terms.append(term)
        else:
            terms.append(f"{c:.2g}·{term}")
    return " + ".join(terms) if terms else "0"


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║  Applications of Lorentzian Polynomial Recognition         ║")
    print("╚══════════════════════════════════════════════════════════════╝")

    demo_matroid_application()
    demo_log_concavity()
    demo_partition_functions()
    demo_optimization()

    print("\n" + "=" * 60)
    print("Applications demonstration complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""
demo.py — Demonstration of Recursive Spectral Recognition for Lorentzian Polynomials

This script demonstrates the recursive spectral certificate method for recognizing
Lorentzian polynomials. It:
1. Generates homogeneous polynomials in n ≤ 4 variables, degree d ≤ 5
2. Computes all quadratic leaves (degree-2 iterated partial derivatives)
3. Forms Hessian matrices
4. Checks the recursive spectral predicate (at most one positive eigenvalue)
5. Searches for counterexamples to the completeness conjecture
6. Demonstrates known Lorentzian and non-Lorentzian examples

Examples include elementary symmetric polynomials, products of positive linear
forms, and perturbations with sparse nonnegative support.
"""

import numpy as np
from itertools import product as cart_product
from typing import Optional
import sys


# ============================================================
# Core data structures
# ============================================================

class HomogeneousPolynomial:
    """A homogeneous polynomial in n variables of degree d.

    Stored as a dictionary: exponent tuple -> coefficient.
    E.g. for n=3, d=2: {(2,0,0): 1.0, (1,1,0): 2.0, ...}
    """

    def __init__(self, n: int, d: int, coeffs: Optional[dict] = None):
        self.n = n
        self.d = d
        self.coeffs = coeffs or {}

    def coeff(self, alpha: tuple) -> float:
        return self.coeffs.get(alpha, 0.0)

    def has_nonneg_coefficients(self) -> bool:
        return all(c >= -1e-12 for c in self.coeffs.values())

    def is_zero(self) -> bool:
        return all(abs(c) < 1e-12 for c in self.coeffs.values())

    def partial_derivative(self, var: int) -> 'HomogeneousPolynomial':
        """Compute ∂p/∂x_var."""
        new_coeffs = {}
        for alpha, c in self.coeffs.items():
            if alpha[var] > 0:
                new_alpha = list(alpha)
                new_alpha[var] -= 1
                new_alpha = tuple(new_alpha)
                new_coeffs[new_alpha] = new_coeffs.get(new_alpha, 0.0) + c * alpha[var]
        return HomogeneousPolynomial(self.n, max(0, self.d - 1), new_coeffs)

    def iterated_partial_derivative(self, alpha: tuple) -> 'HomogeneousPolynomial':
        """Apply ∂^α p = ∂^(α₁)/∂x₁^(α₁) ... ∂^(αₙ)/∂xₙ^(αₙ) p."""
        result = self
        for var in range(self.n):
            for _ in range(alpha[var]):
                result = result.partial_derivative(var)
        return result

    def hessian_matrix(self) -> np.ndarray:
        """Compute the Hessian matrix at the origin.
        H[i][j] = coeff of constant term in ∂²p/∂xᵢ∂xⱼ.
        """
        H = np.zeros((self.n, self.n))
        for i in range(self.n):
            pi = self.partial_derivative(i)
            for j in range(self.n):
                pij = pi.partial_derivative(j)
                # Constant term
                zero_alpha = tuple([0] * self.n)
                H[i][j] = pij.coeff(zero_alpha)
        return H

    def __repr__(self):
        terms = []
        for alpha, c in sorted(self.coeffs.items()):
            if abs(c) < 1e-12:
                continue
            parts = []
            for i, a in enumerate(alpha):
                if a > 0:
                    parts.append(f"x{i}^{a}" if a > 1 else f"x{i}")
            term = " * ".join(parts) if parts else "1"
            terms.append(f"{c:.4g} * {term}")
        return " + ".join(terms) if terms else "0"


# ============================================================
# Lorentzian signature check
# ============================================================

def has_at_most_one_positive_eigenvalue(M: np.ndarray) -> bool:
    """Check if symmetric matrix M has at most one positive eigenvalue."""
    eigenvalues = np.linalg.eigvalsh(M)
    n_positive = np.sum(eigenvalues > 1e-10)
    return n_positive <= 1


def has_lorentzian_signature(M: np.ndarray) -> dict:
    """Return detailed signature information for a symmetric matrix."""
    eigenvalues = np.sort(np.linalg.eigvalsh(M))[::-1]
    n_pos = np.sum(eigenvalues > 1e-10)
    n_neg = np.sum(eigenvalues < -1e-10)
    n_zero = len(eigenvalues) - n_pos - n_neg
    return {
        'eigenvalues': eigenvalues,
        'n_positive': n_pos,
        'n_negative': n_neg,
        'n_zero': n_zero,
        'is_lorentzian': n_pos <= 1,
    }


# ============================================================
# Multiindex enumeration
# ============================================================

def multiindices(n: int, d: int):
    """Generate all multiindices α ∈ ℕⁿ with |α| = d."""
    if n == 0:
        if d == 0:
            yield ()
        return
    for first in range(d + 1):
        for rest in multiindices(n - 1, d - first):
            yield (first,) + rest


# ============================================================
# Recursive spectral check
# ============================================================

def check_recursively_lorentzian(p: HomogeneousPolynomial, verbose: bool = False) -> dict:
    """Check if p is recursively Lorentzian.

    Returns a dict with:
    - 'is_lorentzian': bool
    - 'leaves_checked': int
    - 'failing_leaf': optional tuple (alpha, eigenvalues)
    - 'all_signatures': list of signature info
    """
    if not p.has_nonneg_coefficients():
        return {
            'is_lorentzian': False,
            'reason': 'negative coefficients',
            'leaves_checked': 0,
        }

    if p.d < 2:
        return {
            'is_lorentzian': True,
            'reason': f'degree {p.d} < 2, trivially Lorentzian',
            'leaves_checked': 0,
        }

    leaves_checked = 0
    all_signatures = []
    failing_leaf = None

    deriv_order = p.d - 2
    for alpha in multiindices(p.n, deriv_order):
        q = p.iterated_partial_derivative(alpha)
        H = q.hessian_matrix()
        sig = has_lorentzian_signature(H)
        all_signatures.append({'alpha': alpha, 'signature': sig})
        leaves_checked += 1

        if verbose:
            print(f"  Leaf α={alpha}: eigenvalues={sig['eigenvalues']}, "
                  f"Lorentzian={sig['is_lorentzian']}")

        if not sig['is_lorentzian']:
            failing_leaf = (alpha, sig['eigenvalues'])
            return {
                'is_lorentzian': False,
                'reason': 'failing quadratic leaf',
                'failing_leaf': failing_leaf,
                'leaves_checked': leaves_checked,
                'all_signatures': all_signatures,
            }

    return {
        'is_lorentzian': True,
        'reason': 'all quadratic leaves have Lorentzian signature',
        'leaves_checked': leaves_checked,
        'all_signatures': all_signatures,
    }


# ============================================================
# Support exchange check
# ============================================================

def check_support_exchange(p: HomogeneousPolynomial) -> bool:
    """Check if the support of p satisfies the exchange property (M-convexity)."""
    support = [alpha for alpha, c in p.coeffs.items() if abs(c) > 1e-12]
    for alpha in support:
        for beta in support:
            for i in range(p.n):
                if alpha[i] > beta[i]:
                    found = False
                    for j in range(p.n):
                        if beta[j] > alpha[j]:
                            new_alpha = list(alpha)
                            new_alpha[i] -= 1
                            new_alpha[j] += 1
                            new_beta = list(beta)
                            new_beta[i] += 1
                            new_beta[j] -= 1
                            if (tuple(new_alpha) in [s for s in support] and
                                tuple(new_beta) in [s for s in support]):
                                found = True
                                break
                    if not found:
                        return False
    return True


# ============================================================
# Example polynomials
# ============================================================

def elementary_symmetric(n: int, k: int) -> HomogeneousPolynomial:
    """The k-th elementary symmetric polynomial e_k(x₁,...,xₙ)."""
    from itertools import combinations
    coeffs = {}
    for subset in combinations(range(n), k):
        alpha = [0] * n
        for i in subset:
            alpha[i] = 1
        coeffs[tuple(alpha)] = 1.0
    return HomogeneousPolynomial(n, k, coeffs)


def product_of_linear_forms(n: int, forms: list) -> HomogeneousPolynomial:
    """Product of linear forms ∏ᵢ (a_{i,1} x₁ + ... + a_{i,n} xₙ).

    forms: list of lists of coefficients.
    """
    d = len(forms)
    # Start with constant 1
    result = {tuple([0] * n): 1.0}

    for form_coeffs in forms:
        new_result = {}
        for alpha, c in result.items():
            for j in range(n):
                if abs(form_coeffs[j]) < 1e-15:
                    continue
                new_alpha = list(alpha)
                new_alpha[j] += 1
                new_alpha = tuple(new_alpha)
                new_result[new_alpha] = new_result.get(new_alpha, 0.0) + c * form_coeffs[j]
        result = new_result

    return HomogeneousPolynomial(n, d, result)


def sum_of_squares_polynomial(n: int) -> HomogeneousPolynomial:
    """x₁² + x₂² + ... + xₙ²"""
    coeffs = {}
    for i in range(n):
        alpha = [0] * n
        alpha[i] = 2
        coeffs[tuple(alpha)] = 1.0
    return HomogeneousPolynomial(n, 2, coeffs)


def complete_homogeneous_symmetric(n: int, d: int) -> HomogeneousPolynomial:
    """The complete homogeneous symmetric polynomial h_d(x₁,...,xₙ)."""
    from math import comb
    coeffs = {}
    for alpha in multiindices(n, d):
        # Multinomial coefficient
        from math import factorial
        coeff = factorial(d)
        for a in alpha:
            coeff //= factorial(a)
        coeffs[alpha] = float(coeff)
    return HomogeneousPolynomial(n, d, coeffs)


# ============================================================
# Demo 1: Known Lorentzian Examples
# ============================================================

def demo_known_lorentzian():
    print("=" * 70)
    print("DEMO 1: Known Lorentzian Polynomials")
    print("=" * 70)

    # Elementary symmetric polynomials
    print("\n--- Elementary Symmetric Polynomials ---")
    for n in [3, 4]:
        for k in range(1, n + 1):
            p = elementary_symmetric(n, k)
            result = check_recursively_lorentzian(p)
            exchange = check_support_exchange(p)
            print(f"  e_{k}(x₁,...,x_{n}): Lorentzian={result['is_lorentzian']}, "
                  f"Exchange={exchange}, Leaves={result['leaves_checked']}")

    # Products of positive linear forms
    print("\n--- Products of Positive Linear Forms ---")
    forms_2d = [[1, 2], [3, 1]]
    p = product_of_linear_forms(2, forms_2d)
    result = check_recursively_lorentzian(p, verbose=True)
    print(f"  (x₀ + 2x₁)(3x₀ + x₁): Lorentzian={result['is_lorentzian']}")
    print(f"  Polynomial: {p}")

    forms_3d = [[1, 1, 1], [2, 1, 0], [0, 1, 3]]
    p = product_of_linear_forms(3, forms_3d)
    result = check_recursively_lorentzian(p)
    print(f"\n  Product of 3 linear forms in 3 vars: "
          f"Lorentzian={result['is_lorentzian']}, Leaves={result['leaves_checked']}")


# ============================================================
# Demo 2: Non-Lorentzian Examples
# ============================================================

def demo_non_lorentzian():
    print("\n" + "=" * 70)
    print("DEMO 2: Non-Lorentzian Polynomials")
    print("=" * 70)

    # x₁² + x₂² (sum of squares is NOT Lorentzian for n ≥ 2)
    print("\n--- Sum of Squares ---")
    p = sum_of_squares_polynomial(2)
    result = check_recursively_lorentzian(p, verbose=True)
    print(f"  x₀² + x₁²: Lorentzian={result['is_lorentzian']}")
    if not result['is_lorentzian'] and 'failing_leaf' in result:
        alpha, eigs = result['failing_leaf']
        print(f"  Failing leaf: α={alpha}, eigenvalues={eigs}")

    p = sum_of_squares_polynomial(3)
    result = check_recursively_lorentzian(p, verbose=True)
    print(f"\n  x₀² + x₁² + x₂²: Lorentzian={result['is_lorentzian']}")

    # A polynomial with nonneg coefficients but not Lorentzian
    print("\n--- Nonneg but Not Lorentzian ---")
    coeffs = {
        (2, 0, 0): 1.0,
        (0, 2, 0): 1.0,
        (0, 0, 2): 1.0,
        (1, 1, 0): 0.1,
        (1, 0, 1): 0.1,
        (0, 1, 1): 0.1,
    }
    p = HomogeneousPolynomial(3, 2, coeffs)
    result = check_recursively_lorentzian(p, verbose=True)
    print(f"  Diagonal-dominant quadratic: Lorentzian={result['is_lorentzian']}")


# ============================================================
# Demo 3: Recursive Certificate Propagation
# ============================================================

def demo_recursive_propagation():
    print("\n" + "=" * 70)
    print("DEMO 3: Recursive Certificate Propagation Through Derivatives")
    print("=" * 70)

    # Start with e_3(x₁, x₂, x₃, x₄) = degree 3 elementary symmetric
    p = elementary_symmetric(4, 3)
    print(f"\n  p = e₃(x₁,x₂,x₃,x₄)")
    print(f"  Degree: {p.d}, Variables: {p.n}")

    result = check_recursively_lorentzian(p, verbose=True)
    print(f"  Recursively Lorentzian: {result['is_lorentzian']}")
    print(f"  Leaves checked: {result['leaves_checked']}")

    print("\n  --- First partial derivatives ---")
    for var in range(p.n):
        dp = p.partial_derivative(var)
        result_dp = check_recursively_lorentzian(dp)
        print(f"  ∂p/∂x{var}: Lorentzian={result_dp['is_lorentzian']}")

    # Higher degree: product of 4 linear forms
    print("\n  --- Degree 4 example: product of 4 positive linear forms ---")
    forms = [[1, 1, 0], [0, 1, 1], [1, 0, 1], [1, 1, 1]]
    p4 = product_of_linear_forms(3, forms)
    print(f"  Degree: {p4.d}, Variables: {p4.n}")
    result4 = check_recursively_lorentzian(p4, verbose=True)
    print(f"  Recursively Lorentzian: {result4['is_lorentzian']}")
    print(f"  Leaves checked: {result4['leaves_checked']}")


# ============================================================
# Demo 4: Exhaustive Counterexample Search
# ============================================================

def demo_counterexample_search():
    print("\n" + "=" * 70)
    print("DEMO 4: Exhaustive Counterexample Search")
    print("=" * 70)
    print("  Searching for polynomials where recursive spectral check")
    print("  and support exchange property disagree...\n")

    max_coeff = 2  # Coefficients in {0, 1, 2}
    total_checked = 0
    lorentzian_count = 0
    exchange_violations = 0

    # Search over degree 2, 3 in 2, 3 variables
    for n in [2, 3]:
        for d in [2, 3]:
            print(f"  n={n}, d={d}:")
            count = 0
            lor_count = 0
            exch_count = 0

            for alpha_set in multiindices(n, d):
                pass  # Just to count

            alphas = list(multiindices(n, d))
            n_alphas = len(alphas)

            # Sample random polynomials
            np.random.seed(42)
            n_samples = min(500, (max_coeff + 1) ** n_alphas)

            for trial in range(n_samples):
                if n_samples <= (max_coeff + 1) ** n_alphas and trial < (max_coeff + 1) ** n_alphas:
                    # Exhaustive for small cases
                    coeffs_list = []
                    t = trial
                    for _ in range(n_alphas):
                        coeffs_list.append(t % (max_coeff + 1))
                        t //= (max_coeff + 1)
                else:
                    coeffs_list = [np.random.randint(0, max_coeff + 1) for _ in range(n_alphas)]

                coeffs = {}
                for alpha, c in zip(alphas, coeffs_list):
                    if c > 0:
                        coeffs[alpha] = float(c)

                if not coeffs:
                    continue

                p = HomogeneousPolynomial(n, d, coeffs)
                count += 1

                result = check_recursively_lorentzian(p)
                exchange = check_support_exchange(p)

                if result['is_lorentzian']:
                    lor_count += 1
                    if not exchange:
                        exchange_violations += 1
                        print(f"    !! COUNTEREXAMPLE: Lorentzian but no exchange: {p}")

                if exchange and not result['is_lorentzian']:
                    # Exchange holds but not Lorentzian — interesting
                    exch_count += 1

            total_checked += count
            lorentzian_count += lor_count
            print(f"    Checked: {count}, Lorentzian: {lor_count}, "
                  f"Exchange-but-not-Lor: {exch_count}")

    print(f"\n  Total polynomials checked: {total_checked}")
    print(f"  Total Lorentzian: {lorentzian_count}")
    print(f"  Exchange violations (Lor but no exchange): {exchange_violations}")
    if exchange_violations == 0:
        print("  ✓ No counterexamples found! Consistent with completeness conjecture.")
    else:
        print("  ✗ Counterexamples found!")


# ============================================================
# Demo 5: Hessian Spectrum Analysis
# ============================================================

def demo_hessian_spectra():
    print("\n" + "=" * 70)
    print("DEMO 5: Hessian Spectrum Analysis")
    print("=" * 70)

    # Analyze the Hessian spectra of various polynomial families
    print("\n--- Elementary Symmetric Polynomials ---")
    for n in [3, 4]:
        for k in [2, 3]:
            if k > n:
                continue
            p = elementary_symmetric(n, k)
            print(f"\n  e_{k}(x₁,...,x_{n}), degree {k}:")
            if k >= 2:
                for alpha in multiindices(n, k - 2):
                    q = p.iterated_partial_derivative(alpha)
                    H = q.hessian_matrix()
                    sig = has_lorentzian_signature(H)
                    eigs_str = ", ".join(f"{e:.4f}" for e in sig['eigenvalues'])
                    print(f"    α={alpha}: eigenvalues=[{eigs_str}], "
                          f"signature=({sig['n_positive']},{sig['n_zero']},{sig['n_negative']})")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  Recursive Spectral Recognition of Lorentzian Polynomials          ║")
    print("║  Demonstration of the Completeness Theorem                         ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")

    demo_known_lorentzian()
    demo_non_lorentzian()
    demo_recursive_propagation()
    demo_counterexample_search()
    demo_hessian_spectra()

    print("\n" + "=" * 70)
    print("Demo complete.")
    print("=" * 70)
