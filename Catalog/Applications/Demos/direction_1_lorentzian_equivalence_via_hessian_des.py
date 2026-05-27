"""
Applications of Hessian Descent Certificates

Demonstrates real-world applications of the Lorentzian-coefficient inequality
framework:
1. Matroid-theoretic applications via exchange support
2. Statistical physics: negative dependence for partition functions
3. Log-concavity certification for combinatorial sequences
"""

from __future__ import annotations
import numpy as np
from typing import Dict, Tuple, List, Optional


# ─── Inline utilities ─────────────────────────────────────────────────

def multi_indices(n: int, d: int) -> List[Tuple[int, ...]]:
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
    return tuple(1 if j == i else 0 for j in range(n))


def add_tuples(*tuples: Tuple[int, ...]) -> Tuple[int, ...]:
    return tuple(sum(x) for x in zip(*tuples))


class HomogeneousPolynomial:
    def __init__(self, n: int, d: int, coeffs: Dict[Tuple[int, ...], float]):
        self.n = n
        self.d = d
        self.coeffs = {k: v for k, v in coeffs.items() if abs(v) > 1e-15}

    def coeff(self, alpha: Tuple[int, ...]) -> float:
        return self.coeffs.get(alpha, 0.0)

    def support(self) -> List[Tuple[int, ...]]:
        return list(self.coeffs.keys())

    def partial_derivative(self, var: int) -> 'HomogeneousPolynomial':
        if self.d == 0:
            return HomogeneousPolynomial(self.n, 0, {})
        new_coeffs: Dict[Tuple[int, ...], float] = {}
        for alpha, c in self.coeffs.items():
            if alpha[var] > 0:
                new_alpha = list(alpha)
                factor = new_alpha[var]
                new_alpha[var] -= 1
                t = tuple(new_alpha)
                new_coeffs[t] = new_coeffs.get(t, 0.0) + c * factor
        return HomogeneousPolynomial(self.n, max(0, self.d - 1), new_coeffs)

    def iterated_derivative(self, alpha: Tuple[int, ...]) -> 'HomogeneousPolynomial':
        result = self
        for var in range(self.n):
            for _ in range(alpha[var]):
                result = result.partial_derivative(var)
        return result

    def hessian_matrix(self) -> np.ndarray:
        H = np.zeros((self.n, self.n))
        for i in range(self.n):
            for j in range(self.n):
                df_ij = self.partial_derivative(j).partial_derivative(i)
                zero_idx = tuple(0 for _ in range(self.n))
                H[i, j] = df_ij.coeff(zero_idx)
        return H


# ─── Application 1: Matroid Basis Generating Polynomials ──────────────

def matroid_basis_polynomial(bases: List[Tuple[int, ...]], n: int) -> HomogeneousPolynomial:
    """Construct the basis generating polynomial of a matroid.

    Given a matroid on ground set [n] with basis set B, the basis
    generating polynomial is f(x) = sum_{B in bases} prod_{i in B} x_i.

    This polynomial is always Lorentzian (Brändén-Huh).

    Args:
        bases: List of bases, each as a tuple of elements.
        n: Size of ground set.

    Returns:
        The basis generating polynomial.
    """
    d = len(bases[0]) if bases else 0
    coeffs: Dict[Tuple[int, ...], float] = {}
    for basis in bases:
        alpha = [0] * n
        for elem in basis:
            alpha[elem] += 1
        alpha_t = tuple(alpha)
        coeffs[alpha_t] = coeffs.get(alpha_t, 0.0) + 1.0
    return HomogeneousPolynomial(n, d, coeffs)


def check_exchange_support(poly: HomogeneousPolynomial, tol: float = 1e-15) -> bool:
    supp = poly.support()
    for alpha in supp:
        for beta in supp:
            for i in range(poly.n):
                if alpha[i] > beta[i]:
                    found = False
                    for j in range(poly.n):
                        if beta[j] > alpha[j]:
                            ex = list(alpha)
                            ex[i] -= 1
                            ex[j] += 1
                            if abs(poly.coeff(tuple(ex))) > tol:
                                found = True
                                break
                    if not found:
                        return False
    return True


def demo_matroid_application():
    """Demonstrate matroid basis polynomial is Lorentzian."""
    print("APPLICATION 1: Matroid Basis Generating Polynomials")
    print("=" * 55)
    print()

    # Uniform matroid U(2,4): all 2-element subsets of {0,1,2,3}
    from itertools import combinations
    bases = list(combinations(range(4), 2))
    n = 4
    print(f"Uniform matroid U(2,4):")
    print(f"  Bases: {bases}")

    f = matroid_basis_polynomial(bases, n)
    print(f"  Support size: {len(f.support())}")
    print(f"  Exchange support: {check_exchange_support(f)}")

    # Check quadratic leaves
    H = f.hessian_matrix()
    eigenvalues = np.linalg.eigvalsh(H)
    print(f"  Hessian eigenvalues: {np.round(eigenvalues, 3)}")
    print(f"  At most one positive: {np.sum(eigenvalues > 1e-10) <= 1}")
    print()

    # Graphic matroid of K4
    edges = [(0,1), (0,2), (0,3), (1,2), (1,3), (2,3)]
    n_edges = len(edges)
    # Spanning trees of K4 (complete graph on 4 vertices)
    spanning_trees = [
        (0,1,2), (0,1,3), (0,1,4), (0,1,5),
        (0,2,3), (0,2,4), (0,2,5),
        (0,3,4), (0,3,5), (0,4,5),
        (1,2,3), (1,2,4), (1,2,5),
        (1,3,4), (1,3,5),
        (2,3,4),
    ]
    print(f"Graphic matroid of K4:")
    f2 = matroid_basis_polynomial(spanning_trees, n_edges)
    print(f"  Number of bases (spanning trees): {len(spanning_trees)}")
    print(f"  Support size: {len(f2.support())}")
    print(f"  Exchange support: {check_exchange_support(f2)}")
    print()


# ─── Application 2: Negative Dependence ───────────────────────────────

def demo_negative_dependence():
    """Demonstrate negative dependence via coefficient inequalities."""
    print("APPLICATION 2: Negative Dependence in Partition Functions")
    print("=" * 55)
    print()

    print("For a Lorentzian polynomial f = sum c_alpha x^alpha,")
    print("the normalized coefficients p_alpha = c_alpha / sum(c_beta)")
    print("form a 'negatively dependent' distribution:")
    print("  P(i AND j active) * P(neither) <= P(i active) * P(j active)")
    print()

    # Use product of linear forms (guaranteed Lorentzian)
    rng = np.random.default_rng(42)
    n, d = 3, 4
    coeffs: Dict[Tuple[int, ...], float] = {tuple(0 for _ in range(n)): 1.0}
    for _ in range(d):
        linear_coeffs = rng.uniform(0.5, 3.0, size=n)
        new_coeffs: Dict[Tuple[int, ...], float] = {}
        for alpha, c in coeffs.items():
            for var in range(n):
                new_alpha = list(alpha)
                new_alpha[var] += 1
                t = tuple(new_alpha)
                new_coeffs[t] = new_coeffs.get(t, 0.0) + c * linear_coeffs[var]
        coeffs = new_coeffs

    f = HomogeneousPolynomial(n, d, coeffs)
    total = sum(f.coeffs.values())

    print(f"Lorentzian polynomial (n={n}, d={d}):")
    print(f"  Total coefficient mass: {total:.4f}")
    print()

    # Check pairwise negative dependence
    for i in range(n):
        for j in range(i + 1, n):
            # Marginals
            p_i = sum(c for alpha, c in f.coeffs.items() if alpha[i] > 0) / total
            p_j = sum(c for alpha, c in f.coeffs.items() if alpha[j] > 0) / total
            p_ij = sum(c for alpha, c in f.coeffs.items()
                       if alpha[i] > 0 and alpha[j] > 0) / total
            print(f"  Variables {i},{j}: P(i)={p_i:.4f}, P(j)={p_j:.4f}, "
                  f"P(i∧j)={p_ij:.4f}, P(i)*P(j)={p_i*p_j:.4f}")
            print(f"    Negative dependence (P(i∧j) ≤ P(i)*P(j)): "
                  f"{'YES' if p_ij <= p_i * p_j + 1e-10 else 'NO'}")
    print()


# ─── Application 3: Log-Concavity Certification ──────────────────────

def demo_log_concavity_certification():
    """Demonstrate log-concavity certification via coefficient inequalities."""
    print("APPLICATION 3: Log-Concavity Certification")
    print("=" * 55)
    print()

    print("The mixed coefficient inequality for Lorentzian polynomials")
    print("specializes to ultra-log-concavity for univariate slices:")
    print("  a_k^2 >= a_{k-1} * a_{k+1}")
    print()

    # Binomial coefficients (coefficients of (x+y)^d)
    from math import comb
    for d in [4, 6, 8, 10]:
        seq = [comb(d, k) for k in range(d + 1)]
        is_lc = all(seq[k] ** 2 >= seq[k - 1] * seq[k + 1]
                     for k in range(1, d))
        ratios = [seq[k] ** 2 / (seq[k - 1] * seq[k + 1])
                  for k in range(1, d)]
        min_ratio = min(ratios)
        print(f"  Binomial C({d},k): log-concave={is_lc}, "
              f"min ratio a_k^2/(a_{{k-1}}a_{{k+1}})={min_ratio:.4f}")

    print()

    # Chromatic polynomial coefficients
    print("  Stirling numbers S(n,k) (log-concave in k):")
    for n_val in [5, 7, 10]:
        # Compute Stirling numbers of second kind
        S = [[0] * (n_val + 1) for _ in range(n_val + 1)]
        S[0][0] = 1
        for nn in range(1, n_val + 1):
            for kk in range(1, nn + 1):
                S[nn][kk] = kk * S[nn - 1][kk] + S[nn - 1][kk - 1]
        seq = [S[n_val][k] for k in range(1, n_val + 1)]
        is_lc = all(seq[k] ** 2 >= seq[k - 1] * seq[k + 1]
                     for k in range(1, len(seq) - 1))
        print(f"    S({n_val},k): {seq}, log-concave={is_lc}")
    print()


# ─── Main ─────────────────────────────────────────────────────────────

if __name__ == "__main__":
    demo_matroid_application()
    demo_negative_dependence()
    demo_log_concavity_certification()


#!/usr/bin/env python3
"""
Hessian Descent Certificate Demo

Demonstrates the Lorentzian-Hessian Descent equivalence program by:
1. Generating Lorentzian polynomials (products of linear forms)
2. Verifying the forward direction: Lorentzian => coefficient inequalities
3. Testing random polynomials for the converse direction
4. Searching for counterexamples to the converse conjecture

Usage:
    python demo.py                  # Run all demos
    python demo.py --forward        # Forward verification only
    python demo.py --search         # Counterexample search only
    python demo.py --summary        # Summary statistics
"""

from __future__ import annotations
import numpy as np
from itertools import product as cartesian_product
from typing import Dict, Tuple, List, Optional
import sys
import time


# ─── Inline all needed functions ──────────────────────────────────────

def multi_indices(n: int, d: int) -> List[Tuple[int, ...]]:
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
    return tuple(1 if j == i else 0 for j in range(n))


def add_tuples(*tuples: Tuple[int, ...]) -> Tuple[int, ...]:
    return tuple(sum(x) for x in zip(*tuples))


class HomogeneousPolynomial:
    def __init__(self, n: int, d: int, coeffs: Dict[Tuple[int, ...], float]):
        self.n = n
        self.d = d
        self.coeffs = {k: v for k, v in coeffs.items() if abs(v) > 1e-15}

    def coeff(self, alpha: Tuple[int, ...]) -> float:
        return self.coeffs.get(alpha, 0.0)

    def support(self) -> List[Tuple[int, ...]]:
        return list(self.coeffs.keys())

    def has_positive_coefficients(self) -> bool:
        return all(v > 0 for v in self.coeffs.values())

    def partial_derivative(self, var: int) -> 'HomogeneousPolynomial':
        if self.d == 0:
            return HomogeneousPolynomial(self.n, 0, {})
        new_coeffs: Dict[Tuple[int, ...], float] = {}
        for alpha, c in self.coeffs.items():
            if alpha[var] > 0:
                new_alpha = list(alpha)
                factor = new_alpha[var]
                new_alpha[var] -= 1
                t = tuple(new_alpha)
                new_coeffs[t] = new_coeffs.get(t, 0.0) + c * factor
        return HomogeneousPolynomial(self.n, max(0, self.d - 1), new_coeffs)

    def iterated_derivative(self, alpha: Tuple[int, ...]) -> 'HomogeneousPolynomial':
        result = self
        for var in range(self.n):
            for _ in range(alpha[var]):
                result = result.partial_derivative(var)
        return result

    def hessian_matrix(self) -> np.ndarray:
        H = np.zeros((self.n, self.n))
        for i in range(self.n):
            for j in range(self.n):
                df_ij = self.partial_derivative(j).partial_derivative(i)
                zero_idx = tuple(0 for _ in range(self.n))
                H[i, j] = df_ij.coeff(zero_idx)
        return H

    @staticmethod
    def random_positive(n: int, d: int, seed: Optional[int] = None) -> 'HomogeneousPolynomial':
        rng = np.random.default_rng(seed)
        indices = multi_indices(n, d)
        coeffs = {idx: rng.uniform(0.1, 5.0) for idx in indices}
        return HomogeneousPolynomial(n, d, coeffs)


def product_of_linear_forms(n: int, d: int, seed: Optional[int] = None) -> HomogeneousPolynomial:
    rng = np.random.default_rng(seed)
    coeffs: Dict[Tuple[int, ...], float] = {tuple(0 for _ in range(n)): 1.0}
    for _ in range(d):
        linear_coeffs = rng.uniform(0.5, 3.0, size=n)
        new_coeffs: Dict[Tuple[int, ...], float] = {}
        for alpha, c in coeffs.items():
            for var in range(n):
                new_alpha = list(alpha)
                new_alpha[var] += 1
                t = tuple(new_alpha)
                new_coeffs[t] = new_coeffs.get(t, 0.0) + c * linear_coeffs[var]
        coeffs = new_coeffs
    return HomogeneousPolynomial(n, d, coeffs)


def check_mixed_log_concavity(poly: HomogeneousPolynomial, tol: float = 1e-10) -> Tuple[bool, List[str]]:
    if poly.d < 2:
        return True, []
    violations = []
    for m in multi_indices(poly.n, poly.d - 2):
        for i in range(poly.n):
            for j in range(i, poly.n):
                ei = unit_vector(poly.n, i)
                ej = unit_vector(poly.n, j)
                c_ii = poly.coeff(add_tuples(m, ei, ei))
                c_jj = poly.coeff(add_tuples(m, ej, ej))
                c_ij = poly.coeff(add_tuples(m, ei, ej))
                if c_ii * c_jj > c_ij ** 2 + tol:
                    violations.append(f"m={m}, i={i}, j={j}")
    return len(violations) == 0, violations


def check_axis_log_concavity(poly: HomogeneousPolynomial, tol: float = 1e-10) -> Tuple[bool, List[str]]:
    if poly.d < 2:
        return True, []
    violations = []
    for m in multi_indices(poly.n, poly.d - 2):
        for i in range(poly.n):
            ei = unit_vector(poly.n, i)
            c_2i = poly.coeff(add_tuples(m, ei, ei))
            c_0 = poly.coeff(m)
            c_i = poly.coeff(add_tuples(m, ei))
            if c_2i * c_0 > c_i ** 2 + tol:
                violations.append(f"m={m}, i={i}")
    return len(violations) == 0, violations


def check_exchange_support(poly: HomogeneousPolynomial, tol: float = 1e-15) -> Tuple[bool, List[str]]:
    violations = []
    supp = poly.support()
    for alpha in supp:
        for beta in supp:
            for i in range(poly.n):
                if alpha[i] > beta[i]:
                    found = False
                    for j in range(poly.n):
                        if beta[j] > alpha[j]:
                            ex = list(alpha)
                            ex[i] -= 1
                            ex[j] += 1
                            if abs(poly.coeff(tuple(ex))) > tol:
                                found = True
                                break
                    if not found:
                        violations.append(f"α={alpha}, β={beta}, i={i}")
    return len(violations) == 0, violations


def check_all_quadratic_leaves(poly: HomogeneousPolynomial) -> Tuple[bool, List[str]]:
    if poly.d < 2:
        return True, []
    violations = []
    for alpha in multi_indices(poly.n, poly.d - 2):
        leaf = poly.iterated_derivative(alpha)
        H = leaf.hessian_matrix()
        eigenvalues = np.linalg.eigvalsh(H)
        num_pos = np.sum(eigenvalues > 1e-10)
        if num_pos > 1:
            violations.append(f"α={alpha}: {num_pos} positive eigenvalues")
    return len(violations) == 0, violations


# ─── Demo Functions ───────────────────────────────────────────────────

def demo_forward_verification():
    """Mode 1: Forward verification — Lorentzian implies certificate."""
    print("=" * 70)
    print("FORWARD VERIFICATION: Lorentzian => Coefficient Certificate")
    print("=" * 70)
    print()

    test_cases = [
        ("Product of linear forms (n=2, d=3)", 2, 3),
        ("Product of linear forms (n=3, d=3)", 3, 3),
        ("Product of linear forms (n=3, d=4)", 3, 4),
        ("Product of linear forms (n=4, d=3)", 4, 3),
        ("Product of linear forms (n=2, d=6)", 2, 6),
    ]

    all_passed = True
    for name, n, d in test_cases:
        print(f"Testing: {name}")
        f = product_of_linear_forms(n, d, seed=42)

        mixed_ok, mixed_v = check_mixed_log_concavity(f)
        axis_ok, axis_v = check_axis_log_concavity(f)
        exch_ok, exch_v = check_exchange_support(f)
        spec_ok, spec_v = check_all_quadratic_leaves(f)

        cert_ok = mixed_ok and axis_ok and exch_ok
        print(f"  Spectral (ground truth):     {'PASS' if spec_ok else 'FAIL'}")
        print(f"  Mixed log-concavity:         {'PASS' if mixed_ok else 'FAIL'}")
        print(f"  Axis log-concavity:          {'PASS' if axis_ok else 'FAIL'}")
        print(f"  Exchange support:            {'PASS' if exch_ok else 'FAIL'}")
        print(f"  Certificate (all 3):         {'PASS' if cert_ok else 'FAIL'}")

        if not cert_ok:
            all_passed = False
            if mixed_v:
                print(f"    Mixed violations: {mixed_v[:2]}")
            if axis_v:
                print(f"    Axis violations: {axis_v[:2]}")
            if exch_v:
                print(f"    Exchange violations: {exch_v[:2]}")
        print()

    print(f"Overall forward direction: {'ALL PASSED' if all_passed else 'SOME FAILED'}")
    print()


def demo_converse_search():
    """Mode 2: Search for counterexamples to the converse conjecture."""
    print("=" * 70)
    print("CONVERSE COUNTEREXAMPLE SEARCH")
    print("=" * 70)
    print()
    print("Testing: certificate conditions => spectral (Lorentzian)")
    print("Looking for polynomials that satisfy the coefficient certificate")
    print("but fail the spectral condition.")
    print()

    counterexamples = []
    total_tested = 0
    total_cert_pass = 0

    for n in range(2, 5):
        for d in range(2, min(7, 2 + 5 // n)):
            num_tests = 200
            for seed in range(num_tests):
                total_tested += 1
                f = HomogeneousPolynomial.random_positive(n, d, seed=seed + 1000 * n + 10000 * d)

                mixed_ok, _ = check_mixed_log_concavity(f)
                if not mixed_ok:
                    continue

                axis_ok, _ = check_axis_log_concavity(f)
                exch_ok, _ = check_exchange_support(f)

                if not (axis_ok and exch_ok):
                    continue

                total_cert_pass += 1

                spec_ok, spec_v = check_all_quadratic_leaves(f)
                if not spec_ok:
                    counterexamples.append({
                        "n": n, "d": d, "seed": seed,
                        "spectral_violations": spec_v
                    })

    print(f"Total polynomials tested:          {total_tested}")
    print(f"Passed certificate conditions:     {total_cert_pass}")
    print(f"Of those, failed spectral:         {len(counterexamples)}")
    print()

    if counterexamples:
        print("COUNTEREXAMPLES FOUND:")
        for i, ce in enumerate(counterexamples[:5]):
            print(f"  #{i+1}: n={ce['n']}, d={ce['d']}, seed={ce['seed']}")
            for v in ce['spectral_violations'][:2]:
                print(f"    {v}")
    else:
        print("NO COUNTEREXAMPLES FOUND — conjecture consistent!")
    print()


def demo_summary_statistics():
    """Mode 3: Summary statistics across parameter ranges."""
    print("=" * 70)
    print("SUMMARY: Certificate vs Spectral Condition")
    print("=" * 70)
    print()
    print(f"{'n':>3} {'d':>3} {'tested':>8} {'Lor':>6} {'cert':>6} {'cert∧¬Lor':>10} {'Lor∧¬cert':>10}")
    print("-" * 55)

    for n in range(2, 5):
        for d in range(2, min(6, 2 + 5 // n)):
            num_tests = 100
            n_lorentzian = 0
            n_cert = 0
            n_cert_not_lor = 0
            n_lor_not_cert = 0

            for seed in range(num_tests):
                f = HomogeneousPolynomial.random_positive(n, d, seed=seed + 7777 * n + 3333 * d)

                mixed_ok, _ = check_mixed_log_concavity(f)
                axis_ok, _ = check_axis_log_concavity(f)
                exch_ok, _ = check_exchange_support(f)
                spec_ok, _ = check_all_quadratic_leaves(f)

                cert_ok = mixed_ok and axis_ok and exch_ok

                if spec_ok:
                    n_lorentzian += 1
                if cert_ok:
                    n_cert += 1
                if cert_ok and not spec_ok:
                    n_cert_not_lor += 1
                if spec_ok and not cert_ok:
                    n_lor_not_cert += 1

            print(f"{n:>3} {d:>3} {num_tests:>8} {n_lorentzian:>6} {n_cert:>6} "
                  f"{n_cert_not_lor:>10} {n_lor_not_cert:>10}")

    print()
    print("Legend:")
    print("  Lor: passes spectral Lorentzian test")
    print("  cert: passes all certificate conditions")
    print("  cert∧¬Lor: certificate passes but NOT Lorentzian (converse failure)")
    print("  Lor∧¬cert: Lorentzian but certificate FAILS (forward failure — should be 0)")
    print()


def demo_2x2_principal_minor():
    """Demonstrate the 2×2 principal minor lemma."""
    print("=" * 70)
    print("2×2 PRINCIPAL MINOR LEMMA DEMONSTRATION")
    print("=" * 70)
    print()
    print("For any symmetric matrix A with nonneg diagonal and at most one")
    print("positive eigenvalue: A(i,i)*A(j,j) ≤ A(i,j)²")
    print()

    rng = np.random.default_rng(42)
    n_tests = 1000
    n_qualifying = 0
    n_passed = 0

    for _ in range(n_tests):
        n = rng.integers(2, 6)
        # Generate random symmetric matrix with nonneg diagonal
        M = rng.standard_normal((n, n))
        A = (M + M.T) / 2  # Symmetrize
        for i in range(n):
            A[i, i] = abs(A[i, i])  # Nonneg diagonal

        eigenvalues = np.linalg.eigvalsh(A)
        num_pos = np.sum(eigenvalues > 1e-10)

        # Only test matrices that actually have at most one positive eigenvalue
        if num_pos <= 1:
            n_qualifying += 1
            all_ok = True
            for i in range(n):
                for j in range(n):
                    if A[i, i] * A[j, j] > A[i, j] ** 2 + 1e-8:
                        all_ok = False
                        break
            if all_ok:
                n_passed += 1

    print(f"Of {n_tests} random matrices, {n_qualifying} had at most one positive")
    print(f"eigenvalue AND nonneg diagonal.")
    print(f"Of those, all passed minor lemma: {n_passed}/{n_qualifying} "
          f"({'YES' if n_passed == n_qualifying else 'counterexample found!'})")
    if n_passed < n_qualifying:
        print(f"NOTE: {n_qualifying - n_passed} failures are likely numerical precision issues")
    print()


# ─── Main Entry Point ─────────────────────────────────────────────────

def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else "--all"

    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Hessian Descent Certificate — Computational Demo      ║")
    print("║  Lorentzian Polynomials via Coefficient Inequalities    ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    start = time.time()

    if mode == "--forward":
        demo_forward_verification()
    elif mode == "--search":
        demo_converse_search()
    elif mode == "--summary":
        demo_summary_statistics()
    elif mode == "--minor":
        demo_2x2_principal_minor()
    else:
        demo_2x2_principal_minor()
        demo_forward_verification()
        demo_converse_search()
        demo_summary_statistics()

    elapsed = time.time() - start
    print(f"Total time: {elapsed:.2f}s")


if __name__ == "__main__":
    main()


"""
Visualization: Coefficient Landscape of Lorentzian Polynomials

Visualizes how the coefficient inequalities create a geometric landscape:
- Heatmap of coefficient ratios for Lorentzian vs non-Lorentzian polynomials
- The "descent" structure from degree d down to degree 2
"""

import numpy as np
import matplotlib.pyplot as plt


def multi_indices(n: int, d: int):
    if n == 0:
        return [()] if d == 0 else []
    if n == 1:
        return [(d,)]
    result = []
    for k in range(d + 1):
        for rest in multi_indices(n - 1, d - k):
            result.append((k,) + rest)
    return result


def product_of_linear_forms(n, d, seed=None):
    rng = np.random.default_rng(seed)
    coeffs = {tuple(0 for _ in range(n)): 1.0}
    for _ in range(d):
        lc = rng.uniform(0.5, 3.0, size=n)
        new_coeffs = {}
        for alpha, c in coeffs.items():
            for var in range(n):
                na = list(alpha)
                na[var] += 1
                t = tuple(na)
                new_coeffs[t] = new_coeffs.get(t, 0.0) + c * lc[var]
        coeffs = new_coeffs
    return coeffs, n, d


def compute_minor_ratios(coeffs, n, d):
    """Compute all mixed log-concavity ratios c(m+2ei)*c(m+2ej)/c(m+ei+ej)^2."""
    ratios = []
    if d < 2:
        return ratios
    for m in multi_indices(n, d - 2):
        for i in range(n):
            for j in range(i, n):
                ei = tuple(1 if k == i else 0 for k in range(n))
                ej = tuple(1 if k == j else 0 for k in range(n))
                m_ii = tuple(mk + 2*eik for mk, eik in zip(m, ei))
                m_jj = tuple(mk + 2*ejk for mk, ejk in zip(m, ej))
                m_ij = tuple(mk + eik + ejk for mk, eik, ejk in zip(m, ei, ej))
                c_ii = coeffs.get(m_ii, 0)
                c_jj = coeffs.get(m_jj, 0)
                c_ij = coeffs.get(m_ij, 0)
                if abs(c_ij) > 1e-15:
                    ratio = c_ii * c_jj / (c_ij**2)
                    ratios.append(ratio)
    return ratios


fig, axes = plt.subplots(2, 2, figsize=(14, 11))

# Panel 1: Coefficient ratio histogram for Lorentzian polynomials
ax = axes[0, 0]
all_ratios_lor = []
for seed in range(50):
    coeffs, n, d = product_of_linear_forms(3, 4, seed=seed)
    ratios = compute_minor_ratios(coeffs, n, d)
    all_ratios_lor.extend(ratios)

all_ratios_rand = []
for seed in range(50):
    rng = np.random.default_rng(seed + 1000)
    indices = multi_indices(3, 4)
    coeffs = {idx: rng.uniform(0.1, 5.0) for idx in indices}
    ratios = compute_minor_ratios(coeffs, 3, 4)
    all_ratios_rand.extend(ratios)

ax.hist(all_ratios_lor, bins=50, range=(0, 3), alpha=0.6, color='#2ecc71',
        label='Lorentzian', density=True)
ax.hist(all_ratios_rand, bins=50, range=(0, 3), alpha=0.6, color='#e74c3c',
        label='Random', density=True)
ax.axvline(x=1, color='black', linestyle='--', linewidth=1.5,
           label='Boundary ($r = 1$)')
ax.set_xlabel('Ratio $c(m+2e_i)c(m+2e_j) / c(m+e_i+e_j)^2$', fontsize=11)
ax.set_ylabel('Density', fontsize=11)
ax.set_title('Coefficient ratio distribution (n=3, d=4)', fontsize=12)
ax.legend(fontsize=10)

# Panel 2: Heatmap of coefficient matrix for a Lorentzian polynomial
ax = axes[0, 1]
coeffs, n, d = product_of_linear_forms(3, 4, seed=42)
indices = sorted(multi_indices(3, 4))
n_idx = len(indices)
idx_map = {idx: i for i, idx in enumerate(indices)}

coeff_vals = np.array([coeffs.get(idx, 0) for idx in indices])
coeff_vals = coeff_vals / np.max(coeff_vals)

# Create ratio matrix
ratio_matrix = np.ones((n_idx, n_idx))
for i_idx in range(n_idx):
    for j_idx in range(n_idx):
        c_i = coeffs.get(indices[i_idx], 0)
        c_j = coeffs.get(indices[j_idx], 0)
        # For visualization: compute product of coefficients
        ratio_matrix[i_idx, j_idx] = np.sqrt(c_i * c_j) if c_i > 0 and c_j > 0 else 0

ratio_matrix = ratio_matrix / np.max(ratio_matrix) if np.max(ratio_matrix) > 0 else ratio_matrix

im = ax.imshow(ratio_matrix, cmap='YlOrRd', aspect='auto')
ax.set_xlabel('Multi-index (lexicographic order)', fontsize=11)
ax.set_ylabel('Multi-index', fontsize=11)
ax.set_title('Coefficient correlation matrix\n(Lorentzian, n=3, d=4)', fontsize=12)
plt.colorbar(im, ax=ax, shrink=0.8)

# Panel 3: Descent structure — how ratios change across derivative levels
ax = axes[1, 0]
coeffs_orig, n, d = product_of_linear_forms(3, 5, seed=42)

class SimplePoly:
    def __init__(self, coeffs, n, d):
        self.coeffs = coeffs
        self.n = n
        self.d = d

    def partial_derivative(self, var):
        new_coeffs = {}
        for alpha, c in self.coeffs.items():
            if alpha[var] > 0:
                na = list(alpha)
                f = na[var]
                na[var] -= 1
                t = tuple(na)
                new_coeffs[t] = new_coeffs.get(t, 0.0) + c * f
        return SimplePoly(new_coeffs, self.n, max(0, self.d - 1))

levels = []
current = SimplePoly(coeffs_orig, n, d)
for level in range(d - 1):
    ratios = compute_minor_ratios(current.coeffs, current.n, current.d)
    if ratios:
        levels.append((level, ratios))
    if current.d > 0:
        current = current.partial_derivative(0)  # Differentiate w.r.t. x_0

positions = []
data = []
labels = []
for level, ratios in levels:
    positions.append(level)
    data.append(ratios)
    labels.append(f'Level {level}\n(deg {d - level})')

if data:
    bp = ax.boxplot(data, positions=positions, widths=0.5,
                    patch_artist=True,
                    boxprops=dict(facecolor='#3498db', alpha=0.6),
                    medianprops=dict(color='darkblue', linewidth=2))
    ax.axhline(y=1, color='red', linestyle='--', linewidth=1.5,
               label='Log-concavity boundary')
    ax.set_xlabel('Derivative level', fontsize=11)
    ax.set_ylabel('Coefficient ratio', fontsize=11)
    ax.set_title('Ratio descent across derivative levels\n(n=3, d=5)', fontsize=12)
    ax.set_xticks(positions)
    ax.set_xticklabels(labels, fontsize=9)
    ax.legend(fontsize=10)

# Panel 4: Support exchange connectivity
ax = axes[1, 1]
from itertools import combinations
n_viz = 4
d_viz = 2
indices = multi_indices(n_viz, d_viz)
n_nodes = len(indices)

# Draw support exchange graph
node_positions = {}
for i, idx in enumerate(indices):
    angle = 2 * np.pi * i / n_nodes
    node_positions[idx] = (np.cos(angle), np.sin(angle))

# Draw edges: connect α to β if they differ by a single exchange
edges = []
for alpha in indices:
    for beta in indices:
        for i_var in range(n_viz):
            if alpha[i_var] > beta[i_var]:
                for j_var in range(n_viz):
                    if beta[j_var] > alpha[j_var]:
                        exchanged = list(alpha)
                        exchanged[i_var] -= 1
                        exchanged[j_var] += 1
                        if tuple(exchanged) in node_positions:
                            edges.append((alpha, tuple(exchanged)))

# Draw edges
for a, b in edges:
    ax.plot([node_positions[a][0], node_positions[b][0]],
            [node_positions[a][1], node_positions[b][1]],
            'gray', alpha=0.3, linewidth=0.5)

# Draw nodes
for idx, (x, y) in node_positions.items():
    ax.plot(x, y, 'o', markersize=12, color='#3498db', zorder=5)
    label = ''.join(str(v) for v in idx)
    ax.annotate(label, (x, y), textcoords="offset points",
                xytext=(0, -18), ha='center', fontsize=8)

ax.set_xlim(-1.5, 1.5)
ax.set_ylim(-1.5, 1.5)
ax.set_aspect('equal')
ax.set_title(f'Exchange support graph\n(n={n_viz}, d={d_viz})', fontsize=12)
ax.axis('off')

plt.suptitle('Hessian Descent: Coefficient Landscape of Lorentzian Polynomials',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_coefficient_landscape.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_coefficient_landscape.png")


"""
Visualization: 2×2 Principal Minor Lemma for Lorentzian Matrices

Visualizes the key theorem that matrices with at most one positive eigenvalue
have all 2×2 principal minors nonpositive. Shows the boundary between
Lorentzian and non-Lorentzian regions in the (a, c, b) parameter space
for 2×2 symmetric matrices [[a, b], [b, c]].
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import LinearSegmentedColormap

# Generate the parameter space for 2×2 symmetric matrix [[a, b], [b, c]]
# Fix a = 1 and vary b, c to show the region where at most one positive eigenvalue

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Phase diagram in (b, c) space with a = 1
ax = axes[0]
b_range = np.linspace(-3, 3, 300)
c_range = np.linspace(-3, 3, 300)
B, C = np.meshgrid(b_range, c_range)
a = 1.0

# Eigenvalues of [[a, b], [b, c]]
tr = a + C
det = a * C - B**2
disc = np.sqrt(np.maximum((a - C)**2 + 4*B**2, 0))
lam1 = (tr + disc) / 2  # larger eigenvalue
lam2 = (tr - disc) / 2  # smaller eigenvalue

num_pos = (lam1 > 1e-10).astype(int) + (lam2 > 1e-10).astype(int)

colors = ['#2ecc71', '#f39c12', '#e74c3c']  # 0, 1, 2 positive eigenvalues
cmap = LinearSegmentedColormap.from_list('eig', colors, N=3)

im = ax.contourf(B, C, num_pos, levels=[-0.5, 0.5, 1.5, 2.5],
                  colors=colors, alpha=0.7)
# Draw the minor condition boundary: ac = b^2, i.e., c = b^2
b_curve = np.linspace(-3, 3, 500)
c_curve = b_curve**2 / a
ax.plot(b_curve, c_curve, 'k-', linewidth=2, label='$ac = b^2$ (minor boundary)')
ax.set_xlabel('$b$', fontsize=12)
ax.set_ylabel('$c$', fontsize=12)
ax.set_title('Eigenvalue phases ($a = 1$)', fontsize=13)
ax.legend(loc='upper left', fontsize=9)
ax.set_xlim(-3, 3)
ax.set_ylim(-3, 3)

# Add text labels
ax.text(0, 2.5, '2 pos.', fontsize=10, ha='center', color='darkred', weight='bold')
ax.text(0, -1.5, '0 pos.', fontsize=10, ha='center', color='darkgreen', weight='bold')
ax.text(2.5, -0.5, '1 pos.', fontsize=10, ha='center', color='#8B6914', weight='bold')

# Panel 2: The minor ratio A(i,i)*A(j,j)/A(i,j)^2 for random Lorentzian matrices
ax = axes[1]
rng = np.random.default_rng(42)
ratios_lor = []
ratios_nonlor = []

for _ in range(2000):
    n = rng.integers(3, 7)
    M = rng.standard_normal((n, n))
    A = -M @ M.T  # NSD
    v = rng.uniform(0.1, 3, size=n)
    lam = rng.uniform(0, 5)
    A = A + lam * np.outer(v, v)

    eigenvalues = np.linalg.eigvalsh(A)
    num_pos_eig = np.sum(eigenvalues > 1e-10)

    for i in range(n):
        for j in range(i + 1, n):
            if abs(A[i, j]) > 1e-10:
                ratio = A[i, i] * A[j, j] / (A[i, j]**2)
                if num_pos_eig <= 1:
                    ratios_lor.append(ratio)
                else:
                    ratios_nonlor.append(min(ratio, 5))

ratios_lor = [min(r, 5) for r in ratios_lor]
ratios_nonlor = [min(r, 5) for r in ratios_nonlor]

ax.hist(ratios_lor, bins=50, range=(-5, 5), alpha=0.6, color='#2ecc71',
        label='≤ 1 pos. eigenvalue', density=True)
ax.hist(ratios_nonlor, bins=50, range=(-5, 5), alpha=0.6, color='#e74c3c',
        label='> 1 pos. eigenvalue', density=True)
ax.axvline(x=1, color='black', linestyle='--', linewidth=1.5, label='$A_{ii}A_{jj} = A_{ij}^2$')
ax.set_xlabel('$A_{ii} A_{jj} / A_{ij}^2$', fontsize=12)
ax.set_ylabel('Density', fontsize=12)
ax.set_title('Principal minor ratio distribution', fontsize=13)
ax.legend(fontsize=9)
ax.set_xlim(-5, 5)

# Panel 3: Certificate pass rate vs Lorentzian for random polynomials
ax = axes[2]

def check_polynomial(n, d, seed):
    """Check certificate and spectral conditions for a random polynomial."""
    rng_local = np.random.default_rng(seed)
    indices = []
    def gen_mi(nn, dd):
        if nn == 0:
            return [()] if dd == 0 else []
        if nn == 1:
            return [(dd,)]
        res = []
        for k in range(dd + 1):
            for rest in gen_mi(nn - 1, dd - k):
                res.append((k,) + rest)
        return res

    indices = gen_mi(n, d)
    coeffs = {idx: rng_local.uniform(0.1, 5.0) for idx in indices}

    # Check mixed log-concavity
    mixed_ok = True
    if d >= 2:
        leaf_indices = gen_mi(n, d - 2)
        for m in leaf_indices:
            for i in range(n):
                for j in range(i, n):
                    ei = tuple(1 if k == i else 0 for k in range(n))
                    ej = tuple(1 if k == j else 0 for k in range(n))
                    m_ii = tuple(mk + 2 * eik for mk, eik in zip(m, ei))
                    m_jj = tuple(mk + 2 * ejk for mk, ejk in zip(m, ej))
                    m_ij = tuple(mk + eik + ejk for mk, eik, ejk in zip(m, ei, ej))
                    c_ii = coeffs.get(m_ii, 0)
                    c_jj = coeffs.get(m_jj, 0)
                    c_ij = coeffs.get(m_ij, 0)
                    if c_ii * c_jj > c_ij**2 + 1e-10:
                        mixed_ok = False
                        break
                if not mixed_ok:
                    break
            if not mixed_ok:
                break

    # Check spectral condition (simplified for small cases)
    spectral_ok = True
    if d >= 2:
        leaf_indices = gen_mi(n, d - 2)
        for alpha in leaf_indices[:20]:  # Check first 20 leaves
            # Compute iterated derivative
            from collections import defaultdict
            current = dict(coeffs)
            for var in range(n):
                for _ in range(alpha[var]):
                    new_current = defaultdict(float)
                    for idx, c in current.items():
                        if idx[var] > 0:
                            new_idx = list(idx)
                            factor = new_idx[var]
                            new_idx[var] -= 1
                            new_current[tuple(new_idx)] += c * factor
                    current = dict(new_current)
            # Compute Hessian
            H = np.zeros((n, n))
            for i_h in range(n):
                for j_h in range(n):
                    target = [0] * n
                    target[i_h] += 1
                    target[j_h] += 1
                    target_t = tuple(target)
                    c_val = current.get(target_t, 0)
                    factor = 1
                    if i_h == j_h:
                        factor = 2
                    elif target_t in current:
                        factor = 1
                    H[i_h, j_h] = c_val * factor if i_h == j_h else c_val
            eigenvalues = np.linalg.eigvalsh(H)
            if np.sum(eigenvalues > 1e-10) > 1:
                spectral_ok = False
                break

    return mixed_ok, spectral_ok

params = [(2, 2), (2, 3), (2, 4), (3, 2), (3, 3), (4, 2)]
param_labels = [f"n={n},d={d}" for n, d in params]
cert_rates = []
lor_rates = []
agreement_rates = []

for n, d in params:
    n_tests = 100
    n_mixed = 0
    n_spec = 0
    n_agree = 0
    for seed in range(n_tests):
        m_ok, s_ok = check_polynomial(n, d, seed + 9999)
        if m_ok:
            n_mixed += 1
        if s_ok:
            n_spec += 1
        if m_ok == s_ok:
            n_agree += 1
    cert_rates.append(n_mixed / n_tests * 100)
    lor_rates.append(n_spec / n_tests * 100)
    agreement_rates.append(n_agree / n_tests * 100)

x = np.arange(len(params))
width = 0.3
ax.bar(x - width, cert_rates, width, label='Certificate pass rate', color='#3498db', alpha=0.8)
ax.bar(x, lor_rates, width, label='Lorentzian (spectral)', color='#2ecc71', alpha=0.8)
ax.bar(x + width, agreement_rates, width, label='Agreement rate', color='#9b59b6', alpha=0.8)
ax.set_xlabel('Parameters', fontsize=12)
ax.set_ylabel('Rate (%)', fontsize=12)
ax.set_title('Certificate vs Spectral condition', fontsize=13)
ax.set_xticks(x)
ax.set_xticklabels(param_labels, fontsize=9, rotation=20)
ax.legend(fontsize=9)
ax.set_ylim(0, 105)

plt.tight_layout()
plt.savefig('viz_hessian_minor.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_hessian_minor.png")
