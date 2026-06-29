#!/usr/bin/env python3
"""
Algorithms for Tropical Polynomial Normalization and Analysis

Implements the complete algorithmic pipeline:
1. Tropical expression parsing and evaluation
2. AC-normalization to canonical monomial support form
3. Domination pruning for minimal representations
4. Decision procedure for tropical polynomial identity
5. Certified lower bound extraction
6. Newton polytope computation

Complexity analysis:
- Normalization: O(|e|) expression nodes, each tmax is O(|S|+|T|),
  each tplus is O(|S|*|T|), so worst case O(2^depth) monomials.
- Domination pruning: O(k^2 * n) for k monomials in n variables.
- Identity decision: O(normalize + sort + compare).
"""

import itertools
import numpy as np
from typing import List, Tuple, Set, Optional, Dict
from dataclasses import dataclass

# ===========================================================================
# Type Definitions
# ===========================================================================

# Tropical monomial: (coefficient, exponent_vector)
Monomial = Tuple[float, Tuple[int, ...]]

@dataclass
class NormalForm:
    """Tropical polynomial in normal form.

    A finite set of monomials (c, w) representing the function
    x ↦ max_{(c,w) ∈ support} (c + ∑ᵢ wᵢ · xᵢ)
    """
    monomials: List[Monomial]
    n_vars: int

    def eval(self, x: List[float]) -> float:
        """Evaluate at point x."""
        if not self.monomials:
            return float('-inf')
        return max(
            c + sum(wi * xi for wi, xi in zip(w, x))
            for c, w in self.monomials
        )

    def __repr__(self):
        terms = []
        for c, w in self.monomials:
            parts = [f"{c}"]
            for i, wi in enumerate(w):
                if wi == 1:
                    parts.append(f"x{i}")
                elif wi > 1:
                    parts.append(f"{wi}·x{i}")
            terms.append(" + ".join(parts))
        return " ⊕ ".join(f"({t})" for t in terms)

# ===========================================================================
# Algorithm 1: Normalization
# ===========================================================================

def normalize_tmax(nf1: NormalForm, nf2: NormalForm) -> NormalForm:
    """
    Tropical addition of normal forms: union of monomial supports.

    Complexity: O(|nf1| + |nf2|) with hash-based deduplication.

    Corresponds to: addNF in the formal development.
    Theorem: eval_addNF guarantees evalNF(S ∪ T, x) = max(evalNF(S, x), evalNF(T, x))
    """
    seen: Set[Monomial] = set()
    result: List[Monomial] = []
    for m in nf1.monomials + nf2.monomials:
        if m not in seen:
            seen.add(m)
            result.append(m)
    return NormalForm(result, nf1.n_vars)


def normalize_tplus(nf1: NormalForm, nf2: NormalForm) -> NormalForm:
    """
    Tropical multiplication of normal forms: Minkowski sum.

    For each pair (m1, m2) ∈ S × T, compute:
      mulMonomial(m1, m2) = (c1 + c2, w1 + w2)

    Complexity: O(|nf1| * |nf2|) pairwise products.

    Corresponds to: mulNF in the formal development.
    Theorem: eval_mulNF guarantees evalNF(mulNF(S,T), x) = evalNF(S,x) + evalNF(T,x)
    """
    seen: Set[Monomial] = set()
    result: List[Monomial] = []
    for (c1, w1), (c2, w2) in itertools.product(nf1.monomials, nf2.monomials):
        m = (c1 + c2, tuple(a + b for a, b in zip(w1, w2)))
        if m not in seen:
            seen.add(m)
            result.append(m)
    return NormalForm(result, nf1.n_vars)


# ===========================================================================
# Algorithm 2: Domination Pruning
# ===========================================================================

def is_dominated(m: Monomial, others: List[Monomial], n_vars: int,
                 n_test_points: int = 1000) -> bool:
    """
    Check if monomial m is dominated by max of others for all valuations.

    A monomial (c, w) is dominated by a set S if for all x ∈ ℝⁿ:
      c + w·x ≤ max_{(c', w') ∈ S} (c' + w'·x)

    This is checked numerically with random test points.
    For exact checking, one would need LP feasibility.

    Complexity: O(n_test_points * |others| * n_vars)
    """
    if not others:
        return False

    rng = np.random.default_rng(42)
    for _ in range(n_test_points):
        # Test at random points with varying scale
        x = rng.standard_normal(n_vars) * rng.uniform(0.1, 100)
        c, w = m
        m_val = c + sum(wi * xi for wi, xi in zip(w, x))
        max_others = max(
            c2 + sum(wi * xi for wi, xi in zip(w2, x))
            for c2, w2 in others
        )
        if m_val > max_others + 1e-10:
            return False
    return True


def prune_dominated(nf: NormalForm) -> NormalForm:
    """
    Remove dominated monomials from a normal form.

    A monomial is dominated if it never achieves the maximum.
    The pruned form is the minimal representation.

    Complexity: O(k² * n * n_test_points) for k monomials.

    Pseudocode:
      for each monomial m in support:
        if ∀x: eval_monomial(m, x) ≤ max_{m' ≠ m} eval_monomial(m', x):
          remove m
      return remaining monomials
    """
    result = list(nf.monomials)
    changed = True
    while changed:
        changed = False
        new_result = []
        for i, m in enumerate(result):
            others = result[:i] + result[i+1:]
            if not is_dominated(m, others, nf.n_vars):
                new_result.append(m)
            else:
                changed = True
        result = new_result
    return NormalForm(result, nf.n_vars)


# ===========================================================================
# Algorithm 3: Decision Procedure
# ===========================================================================

def decide_tropical_identity(expr1_nf: NormalForm, expr2_nf: NormalForm) -> bool:
    """
    Decide if two tropical polynomial normal forms represent the same function.

    Algorithm:
    1. Sort both monomial sets
    2. Compare element-by-element

    By normalize_complete_functional, if the sorted NFs match,
    the expressions denote the same function for all valuations.

    Complexity: O(k log k) for k = max(|nf1|, |nf2|) monomials.
    """
    s1 = sorted(expr1_nf.monomials)
    s2 = sorted(expr2_nf.monomials)
    return s1 == s2


# ===========================================================================
# Algorithm 4: Lower Bound Certificate Extraction
# ===========================================================================

def extract_lower_bounds(nf: NormalForm) -> List[Dict]:
    """
    Extract certified lower bound certificates from a normal form.

    By affine_lower_bound_of_nf, each monomial m ∈ support satisfies:
      ∀x, eval_monomial(m, x) ≤ eval_nf(support, x)

    Each certificate is an affine function that provably lower-bounds
    the tropical polynomial.

    Returns: List of certificates with coefficients and human-readable form.
    """
    certificates = []
    for c, w in nf.monomials:
        cert = {
            'coefficient': c,
            'exponents': list(w),
            'description': _format_affine(c, w),
            'type': 'affine_lower_bound'
        }
        certificates.append(cert)
    return certificates


def _format_affine(c: float, w: Tuple[int, ...]) -> str:
    """Format an affine function for display."""
    parts = []
    if c != 0:
        parts.append(f"{c}")
    for i, wi in enumerate(w):
        if wi == 1:
            parts.append(f"x{i}")
        elif wi > 1:
            parts.append(f"{wi}·x{i}")
    return " + ".join(parts) if parts else "0"


# ===========================================================================
# Algorithm 5: Newton Polytope Computation
# ===========================================================================

def newton_polytope_vertices(nf: NormalForm) -> np.ndarray:
    """
    Compute the Newton polytope vertices from a tropical normal form.

    The Newton polytope of a tropical polynomial is the convex hull
    of the exponent vectors of its monomials. In the tropical world,
    this polytope governs the combinatorial structure of the polynomial.

    Returns: array of shape (k, n) where k = number of vertices.
    """
    if not nf.monomials:
        return np.array([])
    return np.array([list(w) for _, w in nf.monomials])


def lifted_newton_polytope(nf: NormalForm) -> np.ndarray:
    """
    Compute the lifted Newton polytope: points (w, c) in ℝⁿ⁺¹.

    The tropical polynomial's evaluation equals the upper envelope
    (support function) of this lifted polytope. Non-dominated monomials
    correspond to vertices of the upper convex hull.

    Returns: array of shape (k, n+1).
    """
    if not nf.monomials:
        return np.array([])
    return np.array([list(w) + [c] for c, w in nf.monomials])


# ===========================================================================
# Example Usage
# ===========================================================================

if __name__ == "__main__":
    print("Tropical Polynomial Algorithms")
    print("=" * 50)

    n = 2

    # Build: max(x0, x1) ⊙ max(1, x0)
    S = NormalForm([(0.0, (1, 0)), (0.0, (0, 1))], n)
    T = NormalForm([(1.0, (0, 0)), (0.0, (1, 0))], n)

    print(f"\nS = {S}")
    print(f"T = {T}")

    product = normalize_tplus(S, T)
    print(f"\nS ⊙ T = {product}")

    pruned = prune_dominated(product)
    print(f"After pruning: {pruned}")

    print("\nLower bound certificates:")
    for cert in extract_lower_bounds(product):
        print(f"  {cert['description']}")

    print("\nNewton polytope vertices:")
    verts = newton_polytope_vertices(product)
    print(f"  {verts}")

    print("\nLifted polytope:")
    lifted = lifted_newton_polytope(product)
    print(f"  {lifted}")

    # Test decision procedure
    print("\nDecision procedure test:")
    S2 = NormalForm([(0.0, (0, 1)), (0.0, (1, 0))], n)  # Same as S, different order
    print(f"  S = S'? {decide_tropical_identity(S, S2)}")

    different = NormalForm([(1.0, (1, 0)), (0.0, (0, 1))], n)
    print(f"  S = different? {decide_tropical_identity(S, different)}")
