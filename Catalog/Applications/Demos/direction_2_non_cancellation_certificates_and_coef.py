#!/usr/bin/env python3
"""
Applications of Non-Cancellation Certificates

This module demonstrates real-world applications:
1. Certified Hessian sparsity prediction for optimization
2. Sparse polynomial identity testing
3. Support-aware symbolic differentiation
4. Arithmetic complexity lower bounds
"""

from fractions import Fraction
from typing import Dict, Set, Tuple, List
from itertools import product as cartesian_product
import random

# ─────────────────────────────────────────────────────────
# Inline utilities (self-contained)
# ─────────────────────────────────────────────────────────

Exponent = Tuple[int, ...]
CoefficientMap = Dict[Exponent, Fraction]


def _compute_shadow(support: Set[Exponent], n: int) -> Set[Exponent]:
    shadow = set()
    for alpha in support:
        for i in range(n):
            if alpha[i] < 1:
                continue
            mid = list(alpha)
            mid[i] -= 1
            for j in range(n):
                if mid[j] < 1:
                    continue
                beta = list(mid)
                beta[j] -= 1
                shadow.add(tuple(beta))
    return shadow


def _quad_leaf(support: Set[Exponent], n: int, i: int, j: int) -> Set[Exponent]:
    result = set()
    for alpha in support:
        if alpha[i] < 1:
            continue
        mid = list(alpha)
        mid[i] -= 1
        if mid[j] < 1:
            continue
        mid[j] -= 1
        result.add(tuple(mid))
    return result


def _is_shadow_closed(support: Set[Exponent], n: int) -> bool:
    return _compute_shadow(support, n).issubset(support)


def _symbolic_diff(coeffs: CoefficientMap, n: int, i: int) -> CoefficientMap:
    result = {}
    for alpha, c in coeffs.items():
        if c == 0 or alpha[i] < 1:
            continue
        new_alpha = list(alpha)
        new_alpha[i] -= 1
        key = tuple(new_alpha)
        result[key] = result.get(key, Fraction(0)) + c * alpha[i]
    return {k: v for k, v in result.items() if v != 0}


# ─────────────────────────────────────────────────────────
# Application 1: Certified Hessian Sparsity Prediction
# ─────────────────────────────────────────────────────────

def predict_hessian_sparsity(support: Set[Exponent], n_vars: int) -> Dict:
    """
    Predict the sparsity pattern of the full Hessian matrix without
    computing any derivatives.

    Over characteristic zero, this prediction is exact (Theorem 1).
    This is useful for:
    - Pre-allocating sparse matrix storage
    - Choosing optimization algorithms based on Hessian structure
    - Estimating computational cost of second-order methods

    Parameters
    ----------
    support : Set[Exponent]
        The support of the objective polynomial.
    n_vars : int
        Number of variables.

    Returns
    -------
    Dict
        Sparsity prediction with per-entry and aggregate statistics.
    """
    total_nonzeros = 0
    per_entry = {}
    nonzero_entries = []

    for i in range(n_vars):
        for j in range(n_vars):
            leaf = _quad_leaf(support, n_vars, i, j)
            per_entry[(i, j)] = len(leaf)
            total_nonzeros += len(leaf)
            if len(leaf) > 0:
                nonzero_entries.append((i, j))

    n_entries = n_vars * n_vars
    sparsity_ratio = 1 - (len(nonzero_entries) / n_entries) if n_entries > 0 else 0

    return {
        'total_nonzero_coefficients': total_nonzeros,
        'nonzero_entries': nonzero_entries,
        'n_nonzero_entries': len(nonzero_entries),
        'matrix_sparsity': sparsity_ratio,
        'per_entry_counts': per_entry,
        'shadow_lower_bound': len(_compute_shadow(support, n_vars)),
    }


# ─────────────────────────────────────────────────────────
# Application 2: Sparse Polynomial Identity Testing
# ─────────────────────────────────────────────────────────

def fast_derivative_identity_test(poly1: CoefficientMap, poly2: CoefficientMap,
                                   n_vars: int) -> Dict:
    """
    Test whether two polynomials have identical second-order behavior
    by comparing their support shadows.

    Over characteristic zero, if two polynomials have the same support,
    they have the same Hessian sparsity pattern. If their supports differ,
    the shadow comparison can quickly identify which derivative entries
    will differ — without computing any derivatives.

    Parameters
    ----------
    poly1, poly2 : CoefficientMap
        Two polynomials to compare.
    n_vars : int
        Number of variables.

    Returns
    -------
    Dict
        Comparison results.
    """
    S1 = {m for m, c in poly1.items() if c != 0}
    S2 = {m for m, c in poly2.items() if c != 0}

    shadow1 = _compute_shadow(S1, n_vars)
    shadow2 = _compute_shadow(S2, n_vars)

    same_support = (S1 == S2)
    same_shadow = (shadow1 == shadow2)

    differing_pairs = []
    if not same_shadow:
        for i in range(n_vars):
            for j in range(n_vars):
                ql1 = _quad_leaf(S1, n_vars, i, j)
                ql2 = _quad_leaf(S2, n_vars, i, j)
                if ql1 != ql2:
                    differing_pairs.append((i, j))

    return {
        'same_support': same_support,
        'same_shadow': same_shadow,
        'same_hessian_sparsity': same_shadow,  # Theorem 1
        'differing_derivative_pairs': differing_pairs,
        'support1_size': len(S1),
        'support2_size': len(S2),
        'shadow1_size': len(shadow1),
        'shadow2_size': len(shadow2),
    }


# ─────────────────────────────────────────────────────────
# Application 3: Support-Aware Symbolic Differentiation
# ─────────────────────────────────────────────────────────

def optimized_hessian_computation(coeffs: CoefficientMap,
                                   n_vars: int) -> Dict:
    """
    Compute Hessian entries using support-shadow pre-filtering.

    Instead of blindly differentiating all terms twice, first predict
    which (i,j) entries will be nonzero, then compute only those.

    Parameters
    ----------
    coeffs : CoefficientMap
        The polynomial.
    n_vars : int
        Number of variables.

    Returns
    -------
    Dict
        Hessian computation with optimization statistics.
    """
    support = {m for m, c in coeffs.items() if c != 0}

    # Phase 1: Predict which entries are nonzero (free)
    nonzero_pairs = []
    zero_pairs = []
    for i in range(n_vars):
        for j in range(n_vars):
            leaf = _quad_leaf(support, n_vars, i, j)
            if leaf:
                nonzero_pairs.append((i, j))
            else:
                zero_pairs.append((i, j))

    # Phase 2: Compute only nonzero entries
    hessian = {}
    for i, j in nonzero_pairs:
        dj = _symbolic_diff(coeffs, n_vars, j)
        dij = _symbolic_diff(dj, n_vars, i)
        hessian[(i, j)] = dij

    total = n_vars * n_vars
    computed = len(nonzero_pairs)
    skipped = len(zero_pairs)
    savings = skipped / total if total > 0 else 0

    return {
        'hessian': hessian,
        'computed_entries': computed,
        'skipped_entries': skipped,
        'computational_savings': f"{savings:.1%}",
    }


# ─────────────────────────────────────────────────────────
# Application 4: Arithmetic Complexity Lower Bounds
# ─────────────────────────────────────────────────────────

def compute_complexity_certificate(coeffs: CoefficientMap,
                                    n_vars: int) -> Dict:
    """
    Compute a certified lower bound on arithmetic complexity.

    The shadow lower bound |Sh₂(S)| provides a lower bound on the
    number of distinct second-order operations needed. Under the
    non-cancellation certificate, this bound applies to actual
    arithmetic circuits, not just support skeletons.

    Parameters
    ----------
    coeffs : CoefficientMap
        The polynomial.
    n_vars : int
        Number of variables.

    Returns
    -------
    Dict
        Complexity certificate with bounds and verification.
    """
    support = {m for m, c in coeffs.items() if c != 0}

    shadow = _compute_shadow(support, n_vars)
    shadow_lb = len(shadow)

    # Check non-cancellation certificate
    cert_holds = True
    failing_exponent = None
    for beta in shadow:
        if coeffs.get(beta, Fraction(0)) == 0:
            cert_holds = False
            failing_exponent = beta
            break

    # Check shadow closure
    closed = shadow.issubset(support)

    # Compute ancestor set
    ancestors = set()
    for alpha in support:
        is_ancestor = False
        for i in range(n_vars):
            if alpha[i] < 1:
                continue
            mid = list(alpha)
            mid[i] -= 1
            for j in range(n_vars):
                if mid[j] >= 1:
                    is_ancestor = True
                    break
            if is_ancestor:
                break
        if is_ancestor:
            ancestors.add(alpha)

    return {
        'support_size': len(support),
        'shadow_lower_bound': shadow_lb,
        'ancestor_count': len(ancestors),
        'certificate_holds': cert_holds,
        'shadow_closed': closed,
        'failing_exponent': failing_exponent,
        'bound_type': 'genuine arithmetic' if cert_holds else 'support-only',
        'summary': (
            f"Lower bound: {shadow_lb} (applies to "
            f"{'actual circuits' if cert_holds else 'support circuits only'})"
        ),
    }


# ─────────────────────────────────────────────────────────
# Example Runs
# ─────────────────────────────────────────────────────────

def _example_poly(n_vars, max_deg, seed=42):
    """Generate example polynomial."""
    random.seed(seed)
    coeffs = {}
    for degs in cartesian_product(range(max_deg + 1), repeat=n_vars):
        if sum(degs) <= max_deg:
            coeffs[degs] = Fraction(random.randint(-5, 5))
    return {k: v for k, v in coeffs.items() if v != 0}


if __name__ == "__main__":
    print("=" * 60)
    print("Application 1: Hessian Sparsity Prediction")
    print("=" * 60)

    p = _example_poly(3, 3)
    result = predict_hessian_sparsity({k for k in p}, 3)
    print(f"Support size: {len(p)}")
    print(f"Total nonzero Hessian coefficients: {result['total_nonzero_coefficients']}")
    print(f"Nonzero Hessian entries: {result['n_nonzero_entries']}/{9}")
    print(f"Matrix sparsity: {result['matrix_sparsity']:.1%}")
    print(f"Shadow lower bound: {result['shadow_lower_bound']}")

    print("\n" + "=" * 60)
    print("Application 2: Polynomial Identity Testing")
    print("=" * 60)

    p1 = {(2, 1): Fraction(3), (1, 2): Fraction(2), (0, 0): Fraction(1)}
    p2 = {(2, 1): Fraction(7), (1, 2): Fraction(-1), (0, 0): Fraction(5)}
    result = fast_derivative_identity_test(p1, p2, 2)
    print(f"Same support: {result['same_support']}")
    print(f"Same Hessian sparsity: {result['same_hessian_sparsity']}")

    p3 = {(2, 1): Fraction(3), (1, 0): Fraction(1)}
    result2 = fast_derivative_identity_test(p1, p3, 2)
    print(f"\nDifferent support comparison:")
    print(f"Same shadow: {result2['same_shadow']}")
    print(f"Differing pairs: {result2['differing_derivative_pairs']}")

    print("\n" + "=" * 60)
    print("Application 3: Optimized Hessian Computation")
    print("=" * 60)

    # Sparse 5-variable polynomial
    sparse_p = {
        (3, 0, 0, 0, 0): Fraction(1),
        (0, 0, 0, 0, 3): Fraction(2),
        (1, 1, 1, 0, 0): Fraction(-1),
    }
    result = optimized_hessian_computation(sparse_p, 5)
    print(f"Computed entries: {result['computed_entries']}/{25}")
    print(f"Skipped entries: {result['skipped_entries']}")
    print(f"Computational savings: {result['computational_savings']}")

    print("\n" + "=" * 60)
    print("Application 4: Complexity Lower Bounds")
    print("=" * 60)

    # Dense polynomial (shadow-closed)
    dense = _example_poly(2, 3, seed=123)
    cert = compute_complexity_certificate(dense, 2)
    print(f"Dense polynomial:")
    print(f"  {cert['summary']}")
    print(f"  Certificate: {cert['certificate_holds']}")
    print(f"  Shadow-closed: {cert['shadow_closed']}")

    # Sparse polynomial (not shadow-closed)
    sparse = {(4, 0): Fraction(1), (0, 4): Fraction(1)}
    cert2 = compute_complexity_certificate(sparse, 2)
    print(f"\nSparse polynomial x⁴ + y⁴:")
    print(f"  {cert2['summary']}")
    print(f"  Certificate: {cert2['certificate_holds']}")
    print(f"  Shadow-closed: {cert2['shadow_closed']}")


#!/usr/bin/env python3
"""
Demo: Non-Cancellation Certificates for Sparse Polynomials

This script demonstrates the core mathematical results:
1. Computing the quadratic shadow of a polynomial's support
2. Checking the non-cancellation certificate
3. Computing actual Hessian supports and comparing to predictions
4. Testing characteristic-zero vs finite-field behavior

Usage:
    python demo.py
"""

from itertools import product
from fractions import Fraction
from collections import defaultdict
import random

# ─────────────────────────────────────────────────────────
# Core Data Structures
# ─────────────────────────────────────────────────────────

class Monomial:
    """An exponent vector represented as a tuple of non-negative integers."""
    def __init__(self, exponents):
        self.exp = tuple(exponents)
        self.n = len(self.exp)
    
    def __getitem__(self, i):
        return self.exp[i]
    
    def __eq__(self, other):
        return self.exp == other.exp
    
    def __hash__(self):
        return hash(self.exp)
    
    def __repr__(self):
        parts = []
        for i, e in enumerate(self.exp):
            if e > 0:
                parts.append(f"x{i}^{e}" if e > 1 else f"x{i}")
        return " · ".join(parts) if parts else "1"
    
    def add_unit(self, i):
        """Return self + e_i."""
        lst = list(self.exp)
        lst[i] += 1
        return Monomial(lst)
    
    def sub_unit(self, i):
        """Return self - e_i if self[i] >= 1, else None."""
        if self.exp[i] < 1:
            return None
        lst = list(self.exp)
        lst[i] -= 1
        return Monomial(lst)
    
    def total_degree(self):
        return sum(self.exp)


class SparsePolynomial:
    """A sparse multivariate polynomial with rational coefficients."""
    def __init__(self, n_vars, terms=None):
        self.n = n_vars
        self.terms = {}  # Monomial -> Fraction
        if terms:
            for m, c in terms.items():
                if c != 0:
                    self.terms[m] = Fraction(c)
    
    def support(self):
        return set(m for m, c in self.terms.items() if c != 0)
    
    def coeff(self, m):
        return self.terms.get(m, Fraction(0))
    
    def pderiv(self, i):
        """Compute ∂/∂x_i of self."""
        result = SparsePolynomial(self.n)
        for m, c in self.terms.items():
            if m[i] > 0:
                new_m = m.sub_unit(i)
                result.terms[new_m] = result.terms.get(new_m, Fraction(0)) + c * m[i]
        # Clean zeros
        result.terms = {m: c for m, c in result.terms.items() if c != 0}
        return result
    
    def __repr__(self):
        if not self.terms:
            return "0"
        parts = []
        for m, c in sorted(self.terms.items(), key=lambda x: (-x[0].total_degree(), x[0].exp)):
            if c == 1:
                parts.append(str(m))
            elif c == -1:
                parts.append(f"-{m}")
            else:
                parts.append(f"{c}·{m}")
        return " + ".join(parts)


# ─────────────────────────────────────────────────────────
# Shadow Computations
# ─────────────────────────────────────────────────────────

def quadratic_shadow(support_set, n_vars):
    """Compute the quadratic shadow: all β such that β + e_i + e_j ∈ S for some i, j."""
    shadow = set()
    for alpha in support_set:
        for i in range(n_vars):
            m1 = alpha.sub_unit(i)
            if m1 is None:
                continue
            for j in range(n_vars):
                m2 = m1.sub_unit(j)
                if m2 is not None:
                    shadow.add(m2)
    return shadow


def quad_leaf_set(support_set, n_vars, i, j):
    """Per-pair shadow: {β | β + e_i + e_j ∈ S}."""
    result = set()
    for alpha in support_set:
        m1 = alpha.sub_unit(i)
        if m1 is None:
            continue
        m2 = m1.sub_unit(j)
        if m2 is not None:
            result.add(m2)
    return result


def is_shadow_closed(support_set, n_vars):
    """Check if QuadraticShadow(S) ⊆ S."""
    shadow = quadratic_shadow(support_set, n_vars)
    return shadow.issubset(support_set)


def check_non_cancellation_cert(poly):
    """Check whether a polynomial satisfies the non-cancellation certificate."""
    S = poly.support()
    shadow = quadratic_shadow(S, poly.n)
    for beta in shadow:
        if poly.coeff(beta) == 0:
            return False, beta
    return True, None


# ─────────────────────────────────────────────────────────
# Hessian Support Computation
# ─────────────────────────────────────────────────────────

def hessian_support(poly, i, j):
    """Compute support of ∂_i ∂_j p."""
    dj = poly.pderiv(j)
    dij = dj.pderiv(i)
    return dij.support()


def compare_predicted_vs_actual(poly):
    """Compare predicted (shadow) vs actual Hessian supports for all (i,j)."""
    S = poly.support()
    all_match = True
    details = []
    
    for i in range(poly.n):
        for j in range(poly.n):
            predicted = quad_leaf_set(S, poly.n, i, j)
            actual = hessian_support(poly, i, j)
            match = (predicted == actual)
            if not match:
                all_match = False
            details.append({
                'i': i, 'j': j,
                'predicted_size': len(predicted),
                'actual_size': len(actual),
                'match': match,
                'missing': predicted - actual,
                'extra': actual - predicted
            })
    
    return all_match, details


# ─────────────────────────────────────────────────────────
# Random Polynomial Generation
# ─────────────────────────────────────────────────────────

def random_sparse_poly(n_vars, n_terms, max_degree=5, coeff_range=10):
    """Generate a random sparse polynomial with nonzero rational coefficients."""
    terms = {}
    attempts = 0
    while len(terms) < n_terms and attempts < 1000:
        exp = tuple(random.randint(0, max_degree) for _ in range(n_vars))
        m = Monomial(exp)
        if m not in terms:
            c = random.randint(1, coeff_range) * random.choice([-1, 1])
            terms[m] = Fraction(c)
        attempts += 1
    return SparsePolynomial(n_vars, terms)


def random_shadow_closed_poly(n_vars, max_degree=3, coeff_range=10):
    """Generate a polynomial whose support is shadow-closed.
    Strategy: use all monomials up to a given degree (a 'fat' support)."""
    terms = {}
    for deg_tuple in product(range(max_degree + 1), repeat=n_vars):
        if sum(deg_tuple) <= max_degree:
            m = Monomial(deg_tuple)
            c = random.randint(1, coeff_range) * random.choice([-1, 1])
            terms[m] = Fraction(c)
    return SparsePolynomial(n_vars, terms)


# ─────────────────────────────────────────────────────────
# Finite Field Simulation
# ─────────────────────────────────────────────────────────

def hessian_scalar(beta, i, j):
    """Compute the scalar factor from second differentiation."""
    # The scalar is ((beta + e_j)[i] + 1) * (beta[j] + 1)
    # For the derivative ∂_i(∂_j f), the coefficient of X^beta in the result
    # is coeff(beta + e_i + e_j, f) * (beta[j] + 1) * ((beta + e_j)[i] + 1)
    beta_plus_ej_i = beta[i] + (1 if i == j else 0)
    return (beta_plus_ej_i + 1) * (beta[j] + 1)


def check_finite_field_cancellation(poly, p):
    """Check if hessian scalars vanish mod p, causing spurious cancellations."""
    S = poly.support()
    cancellations = []
    
    for alpha in S:
        for i in range(poly.n):
            beta_1 = alpha.sub_unit(i)
            if beta_1 is None:
                continue
            for j in range(poly.n):
                beta = beta_1.sub_unit(j)
                if beta is None:
                    continue
                scalar = hessian_scalar(beta, i, j)
                if scalar % p == 0:
                    cancellations.append({
                        'alpha': alpha, 'beta': beta,
                        'i': i, 'j': j,
                        'scalar': scalar,
                        'p': p
                    })
    
    return cancellations


# ─────────────────────────────────────────────────────────
# Complexity Measures
# ─────────────────────────────────────────────────────────

def shadow_lower_bound(support_set, n_vars):
    """Compute the shadow lower bound: |QuadraticShadow(S)|."""
    return len(quadratic_shadow(support_set, n_vars))


def hessian_entry_count(poly):
    """Total number of nonzero Hessian entries across all (i,j)."""
    count = 0
    for i in range(poly.n):
        for j in range(poly.n):
            count += len(hessian_support(poly, i, j))
    return count


def shadow_hessian_count(support_set, n_vars):
    """Shadow-predicted total Hessian entry count."""
    count = 0
    for i in range(n_vars):
        for j in range(n_vars):
            count += len(quad_leaf_set(support_set, n_vars, i, j))
    return count


# ─────────────────────────────────────────────────────────
# Demo Execution
# ─────────────────────────────────────────────────────────

def demo_basic():
    """Demo 1: Basic shadow computation and certificate check."""
    print("=" * 70)
    print("DEMO 1: Basic Shadow Computation and Certificate Check")
    print("=" * 70)
    
    # p = 3x^2y + 2xy^2 + x + y + 1
    n = 2
    terms = {
        Monomial((2, 1)): 3,
        Monomial((1, 2)): 2,
        Monomial((1, 0)): 1,
        Monomial((0, 1)): 1,
        Monomial((0, 0)): 1,
    }
    p = SparsePolynomial(n, terms)
    
    print(f"\nPolynomial p = {p}")
    print(f"Support = {p.support()}")
    
    S = p.support()
    shadow = quadratic_shadow(S, n)
    print(f"\nQuadratic Shadow = {shadow}")
    print(f"Shadow size = {len(shadow)}")
    
    cert_ok, witness = check_non_cancellation_cert(p)
    print(f"\nNon-cancellation certificate: {'PASS' if cert_ok else 'FAIL'}")
    if not cert_ok:
        print(f"  Failed at exponent {witness}")
    
    is_closed = is_shadow_closed(S, n)
    print(f"Shadow-closed: {is_closed}")
    
    all_match, details = compare_predicted_vs_actual(p)
    print(f"\nPredicted vs Actual Hessian supports: {'ALL MATCH' if all_match else 'MISMATCH'}")
    for d in details:
        status = "✓" if d['match'] else "✗"
        print(f"  ∂_{d['i']}∂_{d['j']}: predicted={d['predicted_size']}, "
              f"actual={d['actual_size']} {status}")


def demo_shadow_closed():
    """Demo 2: Shadow-closed polynomial with certificate."""
    print("\n" + "=" * 70)
    print("DEMO 2: Shadow-Closed Polynomial (Dense Support)")
    print("=" * 70)
    
    # Dense polynomial: all monomials up to degree 3 in 2 variables
    p = random_shadow_closed_poly(2, max_degree=3)
    
    print(f"\nPolynomial p (all monomials up to degree 3, random coefficients)")
    print(f"Support size = {len(p.support())}")
    
    S = p.support()
    shadow = quadratic_shadow(S, p.n)
    print(f"Shadow size = {len(shadow)}")
    print(f"Shadow-closed: {is_shadow_closed(S, p.n)}")
    
    cert_ok, _ = check_non_cancellation_cert(p)
    print(f"Certificate: {'PASS' if cert_ok else 'FAIL'}")
    
    all_match, details = compare_predicted_vs_actual(p)
    print(f"All Hessian supports match predictions: {all_match}")
    
    # Complexity measures
    actual = hessian_entry_count(p)
    predicted = shadow_hessian_count(S, p.n)
    print(f"\nHessian entry count: actual={actual}, predicted={predicted}, "
          f"match={actual == predicted}")


def demo_sparse_failure():
    """Demo 3: Sparse polynomial where certificate fails."""
    print("\n" + "=" * 70)
    print("DEMO 3: Sparse Polynomial — Certificate May Fail")
    print("=" * 70)
    
    # p = x^3 + y^3 — shadow includes (1,0) and (0,1) which are NOT in support
    n = 2
    terms = {
        Monomial((3, 0)): 1,
        Monomial((0, 3)): 1,
    }
    p = SparsePolynomial(n, terms)
    
    print(f"\nPolynomial p = {p}")
    print(f"Support = {p.support()}")
    
    S = p.support()
    shadow = quadratic_shadow(S, n)
    print(f"Shadow = {shadow}")
    print(f"Shadow-closed: {is_shadow_closed(S, n)}")
    
    cert_ok, witness = check_non_cancellation_cert(p)
    print(f"Certificate: {'PASS' if cert_ok else 'FAIL'}")
    if not cert_ok:
        print(f"  Fails at: {witness} (shadow element not in support)")
    
    all_match, details = compare_predicted_vs_actual(p)
    print(f"\nHessian supports still match predictions: {all_match}")
    print("  (Individual ∂_i∂_j never cancel — the theorem!)")


def demo_finite_field():
    """Demo 4: Characteristic-zero vs finite field."""
    print("\n" + "=" * 70)
    print("DEMO 4: Characteristic Zero vs Finite Field Contrast")
    print("=" * 70)
    
    # p = x^4 + y^4 + x^2*y^2
    n = 2
    terms = {
        Monomial((4, 0)): 1,
        Monomial((0, 4)): 1,
        Monomial((2, 2)): 1,
    }
    p = SparsePolynomial(n, terms)
    
    print(f"\nPolynomial p = {p}")
    
    # Over Q: all hessian scalars are nonzero
    print("\nOver ℚ (characteristic 0):")
    S = p.support()
    for alpha in sorted(S, key=lambda m: m.exp):
        for i in range(n):
            beta_1 = alpha.sub_unit(i)
            if beta_1 is None:
                continue
            for j in range(n):
                beta = beta_1.sub_unit(j)
                if beta is None:
                    continue
                scalar = hessian_scalar(beta, i, j)
                print(f"  α={alpha}, β={beta}, (i,j)=({i},{j}): "
                      f"scalar={scalar} {'≠ 0 ✓' if scalar != 0 else '= 0 ✗'}")
    
    # Over F_2 and F_3: some scalars vanish
    for p_char in [2, 3, 5]:
        cancellations = check_finite_field_cancellation(p, p_char)
        print(f"\nOver F_{p_char} (characteristic {p_char}):")
        if cancellations:
            for c in cancellations[:3]:  # Show first 3
                print(f"  CANCELLATION: scalar={c['scalar']} ≡ 0 mod {p_char} "
                      f"at α={c['alpha']}, β={c['beta']}")
            if len(cancellations) > 3:
                print(f"  ... and {len(cancellations) - 3} more")
        else:
            print("  No spurious cancellations")


def demo_random_tests():
    """Demo 5: Statistical test of the main theorem."""
    print("\n" + "=" * 70)
    print("DEMO 5: Statistical Verification — Random Polynomials")
    print("=" * 70)
    
    n_tests = 50
    n_vars = 3
    all_match_count = 0
    cert_pass_count = 0
    
    for trial in range(n_tests):
        p = random_sparse_poly(n_vars, n_terms=random.randint(3, 15),
                               max_degree=4, coeff_range=20)
        
        all_match, _ = compare_predicted_vs_actual(p)
        if all_match:
            all_match_count += 1
        
        cert_ok, _ = check_non_cancellation_cert(p)
        if cert_ok:
            cert_pass_count += 1
    
    print(f"\nRan {n_tests} random polynomials in {n_vars} variables:")
    print(f"  Hessian supports match shadow predictions: "
          f"{all_match_count}/{n_tests} ({100*all_match_count/n_tests:.0f}%)")
    print(f"  Non-cancellation certificate passes: "
          f"{cert_pass_count}/{n_tests} ({100*cert_pass_count/n_tests:.0f}%)")
    print(f"\n  Key insight: individual ∂_i∂_j ALWAYS match (100%),")
    print(f"  regardless of whether the certificate holds!")
    print(f"  The certificate is about aggregate/shadow-closed properties,")
    print(f"  not individual derivative supports.")


def demo_complexity_measures():
    """Demo 6: Shadow lower bound equals actual Hessian complexity."""
    print("\n" + "=" * 70)
    print("DEMO 6: Complexity Measures — Shadow = Actual")
    print("=" * 70)
    
    for n_vars in [2, 3]:
        for max_deg in [2, 3, 4]:
            p = random_sparse_poly(n_vars, n_terms=8, max_degree=max_deg)
            S = p.support()
            
            actual = hessian_entry_count(p)
            predicted = shadow_hessian_count(S, n_vars)
            shadow_lb = shadow_lower_bound(S, n_vars)
            
            print(f"\n  n={n_vars}, max_deg={max_deg}, |S|={len(S)}:")
            print(f"    Hessian entry count: actual={actual}, predicted={predicted}, "
                  f"match={actual == predicted}")
            print(f"    Shadow lower bound: {shadow_lb}")


if __name__ == "__main__":
    random.seed(42)
    
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║  Non-Cancellation Certificates for Sparse Polynomials          ║")
    print("║  Bridging Combinatorial Shadows to Arithmetic Complexity       ║")
    print("╚══════════════════════════════════════════════════════════════════╝")
    
    demo_basic()
    demo_shadow_closed()
    demo_sparse_failure()
    demo_finite_field()
    demo_random_tests()
    demo_complexity_measures()
    
    print("\n" + "=" * 70)
    print("All demos complete.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Visualization 2: Characteristic Zero vs Finite Field Contrast

Shows how derivative scalar factors behave across different characteristics.
Over ℚ (characteristic 0), all scalars are nonzero — the support prediction
is always exact. Over F_p, some scalars vanish mod p, creating spurious
cancellations that break the prediction.

This visualizes the deep reason why the non-cancellation bridge works in
characteristic zero but fails over finite fields.
"""
import matplotlib.pyplot as plt
import numpy as np


def hessian_scalar(beta, i, j):
    """Compute the derivative scalar factor."""
    beta_j_plus_1 = beta[j] + 1
    beta_plus_ej_i = beta[i] + (1 if i == j else 0)
    return (beta_plus_ej_i + 1) * beta_j_plus_1


# Generate a range of 2-variable exponents
max_exp = 8
betas = []
scalars_diag = []  # i = j = 0
scalars_off = []   # i = 0, j = 1

for a in range(max_exp):
    for b in range(max_exp):
        beta = (a, b)
        betas.append(beta)
        scalars_diag.append(hessian_scalar(beta, 0, 0))  # ∂₀∂₀
        scalars_off.append(hessian_scalar(beta, 0, 1))    # ∂₀∂₁

# Check which scalars vanish mod p for various primes
primes = [2, 3, 5, 7]

fig, axes = plt.subplots(2, 2, figsize=(14, 12))

for idx, p in enumerate(primes):
    ax = axes[idx // 2][idx % 2]

    # Create matrix: color by whether scalar vanishes mod p
    diag_matrix = np.zeros((max_exp, max_exp))
    off_matrix = np.zeros((max_exp, max_exp))

    for a in range(max_exp):
        for b in range(max_exp):
            beta = (a, b)
            s_diag = hessian_scalar(beta, 0, 0)
            s_off = hessian_scalar(beta, 0, 1)

            # 0 = nonzero mod p, 1 = zero mod p (cancellation!)
            if s_diag % p == 0:
                diag_matrix[a, b] = 2  # diagonal cancellation
            if s_off % p == 0:
                off_matrix[a, b] = 1   # off-diagonal cancellation

    combined = np.maximum(diag_matrix, off_matrix)

    cmap = plt.cm.colors.ListedColormap(['#2ecc71', '#f39c12', '#e74c3c'])
    bounds = [0, 0.5, 1.5, 2.5]
    norm = plt.cm.colors.BoundaryNorm(bounds, cmap.N)

    im = ax.imshow(combined, cmap=cmap, norm=norm, origin='lower', aspect='equal')
    ax.set_title(f"Characteristic p = {p}", fontsize=13, fontweight='bold')
    ax.set_xlabel("β₁ (exponent of x₁)", fontsize=11)
    ax.set_ylabel("β₀ (exponent of x₀)", fontsize=11)
    ax.set_xticks(range(max_exp))
    ax.set_yticks(range(max_exp))

    # Count cancellations
    n_cancel = int(np.sum(combined > 0))
    n_total = max_exp * max_exp
    ax.text(0.5, -0.12,
            f"Cancellations: {n_cancel}/{n_total} "
            f"({100*n_cancel/n_total:.0f}%)",
            transform=ax.transAxes, ha='center', fontsize=10)

# Add legend
from matplotlib.patches import Patch
legend_elements = [
    Patch(facecolor='#2ecc71', label='No cancellation (scalar ≢ 0 mod p)'),
    Patch(facecolor='#f39c12', label='Off-diagonal cancel (∂₀∂₁ scalar ≡ 0)'),
    Patch(facecolor='#e74c3c', label='Diagonal cancel (∂₀² scalar ≡ 0)'),
]

fig.legend(handles=legend_elements, loc='lower center', ncol=3,
           fontsize=11, bbox_to_anchor=(0.5, -0.02))

plt.suptitle("Derivative Scalar Cancellations by Characteristic\n"
             "Green = safe (char 0 is always all green), Red/Orange = spurious cancellation",
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig("viz_char_contrast.png", dpi=150, bbox_inches='tight')
print("Saved viz_char_contrast.png")


#!/usr/bin/env python3
"""
Visualization 3: Shadow Growth and Complexity Lower Bounds

Shows how the shadow lower bound grows as the support of a polynomial
increases. Compares sparse vs dense supports and illustrates why the
shadow-based complexity measure captures genuine arithmetic structure.
"""
import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations_with_replacement, product as cartesian_product
import random


def compute_shadow(support, n_vars):
    shadow = set()
    for alpha in support:
        for i in range(n_vars):
            if alpha[i] < 1:
                continue
            mid = list(alpha)
            mid[i] -= 1
            for j in range(n_vars):
                if mid[j] < 1:
                    continue
                beta = list(mid)
                beta[j] -= 1
                shadow.add(tuple(beta))
    return shadow


def is_shadow_closed(support, n_vars):
    return compute_shadow(support, n_vars).issubset(support)


# ─── Data Generation ─────────────────────────────────────

n_vars = 3
random.seed(42)

# Track data for plotting
dense_sizes = []
dense_shadows = []
dense_closed = []

sparse_sizes = []
sparse_shadows = []
sparse_closed = []

# Dense supports: all monomials up to degree d
for max_deg in range(1, 8):
    support = set()
    for degs in cartesian_product(range(max_deg + 1), repeat=n_vars):
        if sum(degs) <= max_deg:
            support.add(degs)
    shadow = compute_shadow(support, n_vars)
    dense_sizes.append(len(support))
    dense_shadows.append(len(shadow))
    dense_closed.append(is_shadow_closed(support, n_vars))

# Sparse random supports of increasing size
all_monomials = []
for degs in cartesian_product(range(8), repeat=n_vars):
    if sum(degs) <= 7:
        all_monomials.append(degs)

for n_terms in range(3, 50, 3):
    trials = []
    for _ in range(10):
        support = set(random.sample(all_monomials, min(n_terms, len(all_monomials))))
        shadow = compute_shadow(support, n_vars)
        trials.append((len(support), len(shadow), is_shadow_closed(support, n_vars)))
    avg_size = np.mean([t[0] for t in trials])
    avg_shadow = np.mean([t[1] for t in trials])
    frac_closed = np.mean([t[2] for t in trials])
    sparse_sizes.append(avg_size)
    sparse_shadows.append(avg_shadow)
    sparse_closed.append(frac_closed)


# ─── Plotting ────────────────────────────────────────────

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Panel 1: Shadow size vs support size
ax1.plot(dense_sizes, dense_shadows, 'o-', color='#2c3e50', linewidth=2,
         markersize=8, label='Dense (degree ≤ d)', zorder=5)
ax1.plot(sparse_sizes, sparse_shadows, 's--', color='#e74c3c', linewidth=1.5,
         markersize=6, label='Sparse (random, avg)', alpha=0.8)

# Reference line
max_x = max(max(dense_sizes), max(sparse_sizes))
ax1.plot([0, max_x], [0, max_x], ':', color='gray', alpha=0.5, label='|Sh₂| = |S|')

ax1.set_xlabel("Support Size |S|", fontsize=12)
ax1.set_ylabel("Shadow Size |Sh₂(S)|", fontsize=12)
ax1.set_title("Shadow Growth: Dense vs Sparse Supports\n(3 variables)",
              fontsize=13, fontweight='bold')
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

# Panel 2: Shadow closure fraction
# For dense supports, closure is always true
ax2.bar(range(len(dense_sizes)),
        [1.0 if c else 0.0 for c in dense_closed],
        alpha=0.7, color='#2c3e50', label='Dense supports')

# For sparse supports, show fraction
ax2_twin = ax2.twinx()
ax2_twin.plot(range(len(sparse_closed)), sparse_closed,
              's-', color='#e74c3c', linewidth=2, markersize=6,
              label='Sparse (fraction closed)')
ax2_twin.set_ylabel("Fraction shadow-closed (sparse)", fontsize=11, color='#e74c3c')
ax2_twin.set_ylim(-0.05, 1.05)
ax2_twin.tick_params(axis='y', labelcolor='#e74c3c')

ax2.set_xlabel("Configuration index", fontsize=12)
ax2.set_ylabel("Shadow-closed? (dense)", fontsize=11, color='#2c3e50')
ax2.set_title("Shadow Closure: Dense Supports Are Always Closed\n"
              "Sparse Supports Become Closed as They Densify",
              fontsize=13, fontweight='bold')
ax2.set_ylim(-0.05, 1.3)

# Combined legend
lines1, labels1 = ax2.get_legend_handles_labels()
lines2, labels2 = ax2_twin.get_legend_handles_labels()
ax2.legend(lines1 + lines2, labels1 + labels2, fontsize=10, loc='upper left')
ax2.grid(True, alpha=0.3)

plt.suptitle("Non-Cancellation Certificate: Shadow Growth and Closure Properties",
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig("viz_shadow_growth.png", dpi=150, bbox_inches='tight')
print("Saved viz_shadow_growth.png")


#!/usr/bin/env python3
"""
Visualization 1: Hessian Shadow Heatmap

Visualizes the quadratic shadow of a polynomial's support as a heatmap.
For a 2-variable polynomial, shows which (i,j) Hessian entries have
nonzero support, and the predicted support sizes.

This demonstrates the core theorem: over characteristic zero, the
shadow prediction is exact — no cancellations occur.
"""
import matplotlib.pyplot as plt
import numpy as np
from itertools import product as cartesian_product


def compute_quad_leaf(support, n_vars, i, j):
    result = set()
    for alpha in support:
        if alpha[i] < 1:
            continue
        mid = list(alpha)
        mid[i] -= 1
        if mid[j] < 1:
            continue
        mid[j] -= 1
        result.add(tuple(mid))
    return result


def compute_shadow(support, n_vars):
    shadow = set()
    for alpha in support:
        for i in range(n_vars):
            if alpha[i] < 1:
                continue
            mid = list(alpha)
            mid[i] -= 1
            for j in range(n_vars):
                if mid[j] < 1:
                    continue
                beta = list(mid)
                beta[j] -= 1
                shadow.add(tuple(beta))
    return shadow


# Generate example supports
n_vars = 4
max_deg = 5

# Sparse support
sparse_support = {(5, 0, 0, 0), (0, 5, 0, 0), (0, 0, 5, 0), (0, 0, 0, 5),
                  (2, 2, 1, 0), (1, 0, 2, 2), (0, 1, 1, 3)}

# Dense support (all monomials up to degree 3)
dense_support = set()
for degs in cartesian_product(range(4), repeat=n_vars):
    if sum(degs) <= 3:
        dense_support.add(degs)

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

for idx, (support, title) in enumerate([
    (sparse_support, "Sparse Support (7 monomials)"),
    (dense_support, f"Dense Support ({len(dense_support)} monomials)")
]):
    # Compute per-pair leaf sizes
    matrix = np.zeros((n_vars, n_vars))
    for i in range(n_vars):
        for j in range(n_vars):
            leaf = compute_quad_leaf(support, n_vars, i, j)
            matrix[i, j] = len(leaf)

    ax = axes[idx]
    im = ax.imshow(matrix, cmap='YlOrRd', aspect='equal')
    ax.set_title(title, fontsize=13, fontweight='bold')
    ax.set_xlabel("Variable j (∂ⱼ)", fontsize=11)
    ax.set_ylabel("Variable i (∂ᵢ)", fontsize=11)
    ax.set_xticks(range(n_vars))
    ax.set_yticks(range(n_vars))
    ax.set_xticklabels([f"x{k}" for k in range(n_vars)])
    ax.set_yticklabels([f"x{k}" for k in range(n_vars)])

    # Annotate cells
    for i in range(n_vars):
        for j in range(n_vars):
            val = int(matrix[i, j])
            color = 'white' if val > matrix.max() * 0.6 else 'black'
            ax.text(j, i, str(val), ha='center', va='center',
                    fontsize=12, fontweight='bold', color=color)

    plt.colorbar(im, ax=ax, label='# nonzero coefficients')

    # Shadow stats
    shadow = compute_shadow(support, n_vars)
    total = int(matrix.sum())
    ax.text(0.5, -0.15, f"|Sh₂(S)| = {len(shadow)}, total entries = {total}",
            transform=ax.transAxes, ha='center', fontsize=10,
            style='italic')

plt.suptitle("Hessian Shadow Structure: Predicted Support Sizes\n"
             "(Over ℚ, these predictions are exact — Theorem 1)",
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig("viz_shadow_heatmap.png", dpi=150, bbox_inches='tight')
print("Saved viz_shadow_heatmap.png")
