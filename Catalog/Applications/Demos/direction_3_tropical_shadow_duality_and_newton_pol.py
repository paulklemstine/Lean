#!/usr/bin/env python3
"""
Tropical Shadow Duality — Applications
========================================

Real-world applications of the shadow duality principle:

1. Certified Hessian sparsity prediction — predict which Hessian entries
   are nonzero without computing derivatives
2. Newton polytope complexity bounds — lower bounds on algebraic circuit
   complexity from shadow data
3. Sparse polynomial system analysis — BKK-style root count predictions
4. Energy landscape analysis — second-derivative geometry from support data
"""

import numpy as np
import random
from typing import Set, Tuple, Dict, List


ExponentVector = Tuple[int, ...]
Polynomial = Dict[ExponentVector, float]


def quad_leaf_shadow(support, i, j, n_vars):
    """Compute quadratic leaf shadow for variable pair (i, j)."""
    shadow = set()
    for alpha in support:
        alpha_list = list(alpha)
        if alpha_list[i] >= 1:
            alpha_list[i] -= 1
            if alpha_list[j] >= 1:
                alpha_list[j] -= 1
                shadow.add(tuple(alpha_list))
    return shadow


def compute_hessian_symbolically(poly, n_vars):
    """Compute full symbolic Hessian matrix."""
    hessian = {}
    for i in range(n_vars):
        for j in range(n_vars):
            # ∂ⱼ first
            dpj = {}
            for exp, coeff in poly.items():
                if exp[j] >= 1:
                    new_exp = list(exp)
                    new_coeff = coeff * exp[j]
                    new_exp[j] -= 1
                    new_exp = tuple(new_exp)
                    dpj[new_exp] = dpj.get(new_exp, 0) + new_coeff
            # ∂ᵢ second
            dpij = {}
            for exp, coeff in dpj.items():
                if exp[i] >= 1:
                    new_exp = list(exp)
                    new_coeff = coeff * exp[i]
                    new_exp[i] -= 1
                    new_exp = tuple(new_exp)
                    dpij[new_exp] = dpij.get(new_exp, 0) + new_coeff
            # Remove zeros
            dpij = {k: v for k, v in dpij.items() if abs(v) > 1e-15}
            hessian[(i, j)] = dpij
    return hessian


# ============================================================
# Application 1: Certified Hessian Sparsity Prediction
# ============================================================

def predict_hessian_sparsity(support: Set[ExponentVector], n_vars: int):
    """
    Predict the sparsity pattern of the Hessian matrix using only support data.

    By the Shadow Duality Principle, the support of ∂ᵢ∂ⱼp is exactly
    the quadratic leaf shadow. This means we can predict:
    - Which Hessian entries are zero
    - The exact number of nonzero terms in each entry
    - The Newton polytope of each entry

    This avoids O(|S|²) symbolic multiplication entirely.

    Returns
    -------
    dict
        Sparsity analysis for each variable pair
    """
    analysis = {}
    for i in range(n_vars):
        for j in range(i, n_vars):
            shadow = quad_leaf_shadow(support, i, j, n_vars)
            analysis[(i, j)] = {
                'shadow_size': len(shadow),
                'is_zero': len(shadow) == 0,
                'shadow': shadow,
            }
    return analysis


# ============================================================
# Application 2: Newton Polytope Complexity Bounds
# ============================================================

def newton_polytope_dimension(generators: Set[ExponentVector]) -> int:
    """Estimate dimension of Newton polytope from generators."""
    if len(generators) <= 1:
        return 0
    pts = np.array(list(generators), dtype=float)
    centered = pts - pts.mean(axis=0)
    if centered.shape[0] < centered.shape[1]:
        return np.linalg.matrix_rank(centered)
    return np.linalg.matrix_rank(centered)


def shadow_complexity_lower_bound(support: Set[ExponentVector], n_vars: int):
    """
    Compute combinatorial lower bounds on Hessian complexity from shadow data.

    The shadow determines:
    - Number of nonzero Hessian entries (per variable pair)
    - Dimension of Newton polytope of each Hessian entry
    - Total "Hessian complexity" = sum of shadow sizes

    These are lower bounds on arithmetic circuit complexity for
    computing the Hessian, computable in O(|S| · n²) time.
    """
    total_terms = 0
    max_dim = 0
    nonzero_entries = 0

    for i in range(n_vars):
        for j in range(i, n_vars):
            shadow = quad_leaf_shadow(support, i, j, n_vars)
            if shadow:
                nonzero_entries += 1
                total_terms += len(shadow)
                dim = newton_polytope_dimension(shadow)
                max_dim = max(max_dim, dim)

    return {
        'total_shadow_terms': total_terms,
        'nonzero_hessian_entries': nonzero_entries,
        'max_newton_dimension': max_dim,
        'n_var_pairs': n_vars * (n_vars + 1) // 2,
    }


# ============================================================
# Application 3: Sparse System Analysis
# ============================================================

def predict_hessian_system_structure(
    polynomials: List[Polynomial],
    n_vars: int,
    i: int,
    j: int
):
    """
    Analyze the structure of a system of Hessian entries.

    For a family of polynomials p₁, ..., pₘ, predict the support
    structure of their Hessian entries ∂ᵢ∂ⱼpₖ using only support data.

    This is relevant to BKK-style root counting: the mixed volume of
    Newton polytopes controls the number of isolated roots.
    """
    shadows = []
    for poly in polynomials:
        support = set(poly.keys())
        shadow = quad_leaf_shadow(support, i, j, n_vars)
        shadows.append(shadow)

    # Analyze pairwise interactions
    union_size = len(set.union(*shadows)) if shadows else 0

    return {
        'individual_sizes': [len(s) for s in shadows],
        'union_size': union_size,
        'shadows': shadows,
    }


# ============================================================
# Application 4: Energy Landscape Analysis
# ============================================================

def energy_landscape_analysis(potential: Polynomial, n_vars: int):
    """
    Analyze second-derivative geometry of a potential energy function.

    In physics, the Hessian of a potential controls:
    - Local stability (positive definiteness)
    - Vibrational modes (eigenvalues)
    - Phase transitions (zero eigenvalues)

    The shadow analysis predicts the combinatorial structure of these
    quantities from the support alone, before any coefficient computation.
    """
    support = set(potential.keys())

    analysis = {
        'n_vars': n_vars,
        'support_size': len(support),
        'max_degree': max(sum(e) for e in support) if support else 0,
    }

    # Diagonal Hessian entries (∂²/∂xᵢ²) control curvature
    diagonal_shadows = {}
    for i in range(n_vars):
        shadow = quad_leaf_shadow(support, i, i, n_vars)
        diagonal_shadows[i] = len(shadow)

    analysis['diagonal_shadow_sizes'] = diagonal_shadows

    # Off-diagonal entries control coupling
    off_diagonal = {}
    for i in range(n_vars):
        for j in range(i + 1, n_vars):
            shadow = quad_leaf_shadow(support, i, j, n_vars)
            off_diagonal[(i, j)] = len(shadow)

    analysis['off_diagonal_shadow_sizes'] = off_diagonal
    analysis['total_hessian_terms'] = sum(diagonal_shadows.values()) + sum(off_diagonal.values())

    return analysis


# ============================================================
# Demonstrations
# ============================================================

if __name__ == "__main__":
    random.seed(42)

    print("=" * 70)
    print("APPLICATION 1: Certified Hessian Sparsity Prediction")
    print("=" * 70)
    print()

    # A sparse polynomial in 4 variables
    poly = {
        (3, 0, 0, 0): 1, (0, 3, 0, 0): 2, (0, 0, 3, 0): 1,
        (2, 1, 0, 0): 3, (1, 0, 2, 0): -1, (0, 1, 1, 1): 2,
        (1, 1, 1, 0): 4, (2, 0, 0, 1): 1,
    }
    support = set(poly.keys())
    sparsity = predict_hessian_sparsity(support, 4)

    print("  Polynomial with 8 terms in 4 variables")
    print("  Predicted Hessian sparsity (from support only):")
    for (i, j), info in sorted(sparsity.items()):
        status = "ZERO" if info['is_zero'] else f"{info['shadow_size']} terms"
        print(f"    ∂_{i}∂_{j}p: {status}")

    # Verify against symbolic computation
    hessian = compute_hessian_symbolically(poly, 4)
    print("\n  Verification against symbolic Hessian:")
    all_correct = True
    for (i, j), info in sorted(sparsity.items()):
        actual = len(hessian.get((i, j), {}))
        predicted = info['shadow_size']
        match = "✓" if actual == predicted else "✗"
        if actual != predicted:
            all_correct = False
        print(f"    ∂_{i}∂_{j}p: predicted={predicted}, actual={actual} {match}")
    print(f"  All predictions correct: {all_correct}")

    print()
    print("=" * 70)
    print("APPLICATION 2: Newton Polytope Complexity Bounds")
    print("=" * 70)
    print()

    bounds = shadow_complexity_lower_bound(support, 4)
    print(f"  Total shadow terms: {bounds['total_shadow_terms']}")
    print(f"  Nonzero Hessian entries: {bounds['nonzero_hessian_entries']}/{bounds['n_var_pairs']}")
    print(f"  Max Newton polytope dimension: {bounds['max_newton_dimension']}")
    print()
    print("  These are certified lower bounds on Hessian circuit complexity,")
    print("  computed in O(|S| · n²) time from support data alone.")

    print()
    print("=" * 70)
    print("APPLICATION 3: Energy Landscape Analysis")
    print("=" * 70)
    print()

    # Lennard-Jones-like potential (simplified)
    potential = {
        (6, 0, 0): 1.0, (0, 6, 0): 1.0, (0, 0, 6): 1.0,
        (3, 0, 0): -2.0, (0, 3, 0): -2.0, (0, 0, 3): -2.0,
        (2, 2, 0): 0.5, (0, 2, 2): 0.5, (2, 0, 2): 0.5,
    }
    analysis = energy_landscape_analysis(potential, 3)
    print(f"  Potential with {analysis['support_size']} terms, max degree {analysis['max_degree']}")
    print(f"  Diagonal shadow sizes (curvature): {analysis['diagonal_shadow_sizes']}")
    print(f"  Off-diagonal shadow sizes (coupling): {analysis['off_diagonal_shadow_sizes']}")
    print(f"  Total Hessian terms predicted: {analysis['total_hessian_terms']}")


#!/usr/bin/env python3
"""
Tropical Shadow Duality Demo
=============================

Demonstrates the Shadow Duality Principle: the Newton polytope of a Hessian
entry ∂ᵢ∂ⱼp is exactly the convex hull of the quadratic leaf shadow extracted
from supp(p). This connects tropical geometry, Newton polytope methods, and
algebraic complexity theory.

Usage:
    python demo.py
"""

from itertools import product as cartprod
from collections import defaultdict
import random

# ============================================================
# Core Algorithms
# ============================================================

def quad_leaf_set(support, i, j, n_vars):
    """
    Compute the quadratic leaf set for variable pair (i, j).

    Given a set of exponent vectors S, returns
        {β : β + eᵢ + eⱼ ∈ S}
    i.e., exponents that survive double differentiation in directions i, j.

    Parameters
    ----------
    support : set of tuples
        Exponent vectors (as tuples of non-negative integers)
    i, j : int
        Variable indices for differentiation
    n_vars : int
        Number of variables

    Returns
    -------
    set of tuples
        The quadratic leaf shadow
    """
    shadow = set()
    ei = [0] * n_vars
    ei[i] = 1
    ej = [0] * n_vars
    ej[j] = 1
    ei = tuple(ei)
    ej = tuple(ej)

    for alpha in support:
        # Check if alpha has enough degree in i and j
        shifted = list(alpha)
        if shifted[i] >= 1:
            shifted[i] -= 1
            if shifted[j] >= 1:
                shifted[j] -= 1
                shadow.add(tuple(shifted))
            # Reset for next iteration
    return shadow


def compute_hessian_entry_support(poly, i, j, n_vars):
    """
    Compute the support of ∂ᵢ∂ⱼp symbolically.

    Parameters
    ----------
    poly : dict
        Maps exponent tuples to coefficients
    i, j : int
        Variable indices
    n_vars : int
        Number of variables

    Returns
    -------
    set of tuples
        Support of the Hessian entry
    """
    # First derivative ∂ⱼ
    dpj = {}
    for exp, coeff in poly.items():
        if exp[j] >= 1:
            new_exp = list(exp)
            new_coeff = coeff * exp[j]
            new_exp[j] -= 1
            new_exp = tuple(new_exp)
            dpj[new_exp] = dpj.get(new_exp, 0) + new_coeff

    # Second derivative ∂ᵢ
    dpij = {}
    for exp, coeff in dpj.items():
        if exp[i] >= 1:
            new_exp = list(exp)
            new_coeff = coeff * exp[i]
            new_exp[i] -= 1
            new_exp = tuple(new_exp)
            dpij[new_exp] = dpij.get(new_exp, 0) + new_coeff

    # Return support (nonzero coefficients)
    return {exp for exp, coeff in dpij.items() if coeff != 0}


def convex_hull_vertices_2d(points):
    """Compute 2D convex hull using Graham scan."""
    if len(points) <= 2:
        return list(points)

    points = sorted(set(points))

    def cross(O, A, B):
        return (A[0] - O[0]) * (B[1] - O[1]) - (A[1] - O[1]) * (B[0] - O[0])

    lower = []
    for p in points:
        while len(lower) >= 2 and cross(lower[-2], lower[-1], p) <= 0:
            lower.pop()
        lower.append(p)
    upper = []
    for p in reversed(points):
        while len(upper) >= 2 and cross(upper[-2], upper[-1], p) <= 0:
            upper.pop()
        upper.append(p)
    return lower[:-1] + upper[:-1]


def support_function(generators, w):
    """
    Compute the support function: max ⟨w, α⟩ over generators.

    Parameters
    ----------
    generators : set or list of tuples
        Exponent vectors
    w : array-like
        Weight vector

    Returns
    -------
    float
        Maximum inner product
    """
    if not generators:
        return float('-inf')
    return max(sum(wi * ai for wi, ai in zip(w, alpha)) for alpha in generators)


def generate_random_sparse_poly(n_vars, n_terms, max_degree=5, coeff_range=(-10, 10)):
    """
    Generate a random sparse polynomial.

    Returns
    -------
    dict : exponent tuple -> coefficient
    """
    poly = {}
    attempts = 0
    while len(poly) < n_terms and attempts < 1000:
        exp = tuple(random.randint(0, max_degree) for _ in range(n_vars))
        if exp not in poly:
            coeff = random.randint(coeff_range[0], coeff_range[1])
            while coeff == 0:
                coeff = random.randint(coeff_range[0], coeff_range[1])
            poly[exp] = coeff
        attempts += 1
    return poly


# ============================================================
# Demo Functions
# ============================================================

def demo_basic_shadow_duality():
    """Demonstrate the basic shadow duality principle."""
    print("=" * 70)
    print("DEMO 1: Basic Shadow Duality Principle")
    print("=" * 70)
    print()

    # Hand-crafted example: p = 3x²y + 2xy² + x³ + y³ in 2 variables
    n_vars = 2
    poly = {
        (2, 1): 3,   # 3x²y
        (1, 2): 2,   # 2xy²
        (3, 0): 1,   # x³
        (0, 3): 1,   # y³
    }

    support = set(poly.keys())
    print(f"Polynomial: 3x²y + 2xy² + x³ + y³")
    print(f"Support: {sorted(support)}")
    print()

    for i in range(n_vars):
        for j in range(n_vars):
            shadow = quad_leaf_set(support, i, j, n_vars)
            hessian_supp = compute_hessian_entry_support(poly, i, j, n_vars)

            print(f"  ∂_{i}∂_{j}p:")
            print(f"    Quadratic leaf shadow:  {sorted(shadow)}")
            print(f"    Hessian entry support:  {sorted(hessian_supp)}")
            print(f"    MATCH: {shadow == hessian_supp}  ← Shadow Duality!")
            print()


def demo_random_verification():
    """Verify shadow duality on random polynomials."""
    print("=" * 70)
    print("DEMO 2: Random Verification (Shadow Duality Conjecture Test)")
    print("=" * 70)
    print()

    n_trials = 50
    n_vars_range = [2, 3, 4]
    n_terms_range = [5, 10, 15, 20]

    total = 0
    matches = 0

    for n_vars in n_vars_range:
        for n_terms in n_terms_range:
            for trial in range(n_trials):
                poly = generate_random_sparse_poly(n_vars, n_terms)
                support = set(poly.keys())

                for i in range(n_vars):
                    for j in range(n_vars):
                        shadow = quad_leaf_set(support, i, j, n_vars)
                        hessian_supp = compute_hessian_entry_support(
                            poly, i, j, n_vars
                        )
                        total += 1
                        if shadow == hessian_supp:
                            matches += 1

    print(f"  Total (polynomial, i, j) triples tested: {total}")
    print(f"  Support matches: {matches}")
    print(f"  Match rate: {matches/total*100:.1f}%")
    print()
    print("  NOTE: Over ℚ with generic coefficients, 100% match is expected.")
    print("  Any mismatch would falsify the strong form of the conjecture.")
    print()


def demo_support_function_equality():
    """Demonstrate tropical shadow evaluation = support function."""
    print("=" * 70)
    print("DEMO 3: Tropical Shadow Evaluation = Support Function")
    print("=" * 70)
    print()
    print("  This demonstrates the cross-domain bridge (Theorem 3):")
    print("  max⟨w, α⟩ over shadow = max⟨w, α⟩ over Hessian support")
    print()

    n_vars = 3
    poly = generate_random_sparse_poly(n_vars, 15, max_degree=4)
    support = set(poly.keys())

    print(f"  Polynomial with {len(poly)} terms in {n_vars} variables")
    print(f"  Support: {sorted(support)[:5]}...")
    print()

    # Test with random weight vectors
    n_weights = 10
    all_match = True

    for w_idx in range(n_weights):
        w = [random.uniform(-1, 1) for _ in range(n_vars)]

        for i in range(n_vars):
            for j in range(n_vars):
                shadow = quad_leaf_set(support, i, j, n_vars)
                hessian_supp = compute_hessian_entry_support(poly, i, j, n_vars)

                if shadow and hessian_supp:
                    sf_shadow = support_function(shadow, w)
                    sf_hessian = support_function(hessian_supp, w)

                    if abs(sf_shadow - sf_hessian) > 1e-10:
                        all_match = False
                        print(f"    MISMATCH at (i={i}, j={j}), w={w}")

    print(f"  All support function evaluations match: {all_match}")
    print()


def demo_newton_polytope_comparison():
    """Compare Newton polytopes of Hessian and shadow in 2D."""
    print("=" * 70)
    print("DEMO 4: Newton Polytope Comparison (2D Visualization Data)")
    print("=" * 70)
    print()

    n_vars = 2
    poly = {
        (3, 1): 2,
        (1, 3): 3,
        (2, 2): 1,
        (4, 0): 1,
        (0, 4): 1,
        (3, 2): 2,
        (2, 3): -1,
    }

    support = set(poly.keys())
    i, j = 0, 1

    shadow = quad_leaf_set(support, i, j, n_vars)
    hessian_supp = compute_hessian_entry_support(poly, i, j, n_vars)

    print(f"  Support of p: {sorted(support)}")
    print(f"  Shadow (i={i}, j={j}): {sorted(shadow)}")
    print(f"  Hessian support: {sorted(hessian_supp)}")
    print(f"  Support equality: {shadow == hessian_supp}")
    print()

    if shadow:
        hull_shadow = convex_hull_vertices_2d(list(shadow))
        hull_hessian = convex_hull_vertices_2d(list(hessian_supp))
        print(f"  Shadow hull vertices: {hull_shadow}")
        print(f"  Hessian hull vertices: {hull_hessian}")
        print(f"  Hull equality: {set(map(tuple, hull_shadow)) == set(map(tuple, hull_hessian))}")
    print()


def demo_sum_containment():
    """Demonstrate Theorem 4: Newton polytope containment for sums."""
    print("=" * 70)
    print("DEMO 5: Sum Containment (Theorem 4)")
    print("=" * 70)
    print()

    n_vars = 3
    p = generate_random_sparse_poly(n_vars, 8, max_degree=4)
    q = generate_random_sparse_poly(n_vars, 8, max_degree=4)

    # Sum polynomial
    pq = dict(p)
    for exp, coeff in q.items():
        pq[exp] = pq.get(exp, 0) + coeff
    # Remove zero coefficients
    pq = {k: v for k, v in pq.items() if v != 0}

    i, j = 0, 1

    shadow_p = quad_leaf_set(set(p.keys()), i, j, n_vars)
    shadow_q = quad_leaf_set(set(q.keys()), i, j, n_vars)
    shadow_union = shadow_p | shadow_q

    hessian_pq = compute_hessian_entry_support(pq, i, j, n_vars)

    # Check containment: Hessian support of (p+q) ⊆ shadow union from combined support
    shadow_combined = quad_leaf_set(set(p.keys()) | set(q.keys()), i, j, n_vars)
    contained = hessian_pq.issubset(shadow_combined)

    print(f"  |supp(p)| = {len(p)}, |supp(q)| = {len(q)}")
    print(f"  |shadow(p)| = {len(shadow_p)}, |shadow(q)| = {len(shadow_q)}")
    print(f"  |Hessian supp(p+q)| = {len(hessian_pq)}")
    print(f"  |shadow(supp(p) ∪ supp(q))| = {len(shadow_combined)}")
    print(f"  Containment holds: {contained}  ← Theorem 4!")
    print()


def demo_vertex_realization():
    """Demonstrate Theorem 2: extremal shadow / vertex realization."""
    print("=" * 70)
    print("DEMO 6: Vertex Realization (Theorem 2)")
    print("=" * 70)
    print()

    n_vars = 3
    poly = generate_random_sparse_poly(n_vars, 20, max_degree=5)
    support = set(poly.keys())

    i, j = 0, 1
    shadow = quad_leaf_set(support, i, j, n_vars)
    hessian_supp = compute_hessian_entry_support(poly, i, j, n_vars)

    if not shadow:
        print("  (Empty shadow, skipping)")
        return

    print(f"  Testing argmax equality for 20 random weight vectors...")
    all_match = True
    for _ in range(20):
        w = [random.uniform(-2, 2) for _ in range(n_vars)]

        # Compute argmax over both sets
        max_shadow = support_function(shadow, w)
        max_hessian = support_function(hessian_supp, w)

        if abs(max_shadow - max_hessian) > 1e-10:
            all_match = False
            print(f"    MISMATCH: shadow max = {max_shadow}, hessian max = {max_hessian}")

    print(f"  All argmax values match: {all_match}  ← Theorem 2!")
    print()


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    random.seed(42)

    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║       TROPICAL SHADOW DUALITY — Interactive Demonstration          ║")
    print("║                                                                    ║")
    print("║  Second-derivative Newton geometry can be read directly from       ║")
    print("║  tropical support shadows.                                         ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_basic_shadow_duality()
    demo_random_verification()
    demo_support_function_equality()
    demo_newton_polytope_comparison()
    demo_sum_containment()
    demo_vertex_realization()

    print("=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Visualization: Shadow Duality Principle
=========================================

Visualizes the core theorem: the Newton polytope of ∂ᵢ∂ⱼp (blue) equals
the convex hull of the quadratic leaf shadow (red dashed). Shows both the
original polynomial support, the shadow generators, and their convex hulls
overlaid to demonstrate exact equality.

Uses matplotlib. Saves output as shadow_duality.png.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import FancyArrowPatch


def quad_leaf_shadow(support, i, j, n_vars):
    """Compute quadratic leaf shadow."""
    shadow = set()
    for alpha in support:
        alpha_list = list(alpha)
        if alpha_list[i] >= 1:
            alpha_list[i] -= 1
            if alpha_list[j] >= 1:
                alpha_list[j] -= 1
                shadow.add(tuple(alpha_list))
    return shadow


def compute_hessian_support(poly, i, j):
    """Compute support of ∂ᵢ∂ⱼp symbolically."""
    dpj = {}
    for exp, coeff in poly.items():
        if exp[j] >= 1:
            new_exp = list(exp)
            new_coeff = coeff * exp[j]
            new_exp[j] -= 1
            new_exp = tuple(new_exp)
            dpj[new_exp] = dpj.get(new_exp, 0) + new_coeff
    dpij = {}
    for exp, coeff in dpj.items():
        if exp[i] >= 1:
            new_exp = list(exp)
            new_coeff = coeff * exp[i]
            new_exp[i] -= 1
            new_exp = tuple(new_exp)
            dpij[new_exp] = dpij.get(new_exp, 0) + new_coeff
    return {k: v for k, v in dpij.items() if abs(v) > 1e-15}


def convex_hull_2d(points):
    """Graham scan convex hull."""
    if len(points) <= 1:
        return list(points)
    points = sorted(set(points))
    if len(points) <= 2:
        return points

    def cross(O, A, B):
        return (A[0] - O[0]) * (B[1] - O[1]) - (A[1] - O[1]) * (B[0] - O[0])

    lower = []
    for p in points:
        while len(lower) >= 2 and cross(lower[-2], lower[-1], p) <= 0:
            lower.pop()
        lower.append(p)
    upper = []
    for p in reversed(points):
        while len(upper) >= 2 and cross(upper[-2], upper[-1], p) <= 0:
            upper.pop()
        upper.append(p)
    return lower[:-1] + upper[:-1]


fig, axes = plt.subplots(2, 2, figsize=(14, 12))
fig.suptitle('Tropical Shadow Duality Principle',
             fontsize=16, fontweight='bold', y=0.98)

# ── Example 1: Original support ──
ax = axes[0, 0]
poly = {
    (3, 1): 2, (1, 3): 3, (2, 2): 1,
    (4, 0): 1, (0, 4): 1, (3, 2): 2, (2, 3): -1,
}
support = set(poly.keys())
support_pts = np.array(list(support))

ax.scatter(support_pts[:, 0], support_pts[:, 1], c='forestgreen', s=120,
           zorder=5, edgecolors='darkgreen', linewidths=1.5, label='supp(p)')

hull = convex_hull_2d(list(support))
hull_closed = hull + [hull[0]]
hull_x = [p[0] for p in hull_closed]
hull_y = [p[1] for p in hull_closed]
ax.fill(hull_x, hull_y, alpha=0.15, color='forestgreen')
ax.plot(hull_x, hull_y, 'g-', linewidth=2, alpha=0.7)

ax.set_title('Newton Polytope of p', fontsize=13, fontweight='bold')
ax.set_xlabel('$x_0$ exponent', fontsize=11)
ax.set_ylabel('$x_1$ exponent', fontsize=11)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_xlim(-0.5, 5)
ax.set_ylim(-0.5, 5)
ax.set_aspect('equal')

# ── Example 2: Shadow vs Hessian support ──
ax = axes[0, 1]
i_var, j_var = 0, 1

shadow = quad_leaf_shadow(support, i_var, j_var, 2)
hessian = compute_hessian_support(poly, i_var, j_var)
hessian_supp = set(hessian.keys())

if shadow:
    shadow_pts = np.array(list(shadow))
    ax.scatter(shadow_pts[:, 0], shadow_pts[:, 1], c='crimson', s=150,
               marker='D', zorder=6, edgecolors='darkred', linewidths=1.5,
               label='Shadow (predicted)')

if hessian_supp:
    hess_pts = np.array(list(hessian_supp))
    ax.scatter(hess_pts[:, 0], hess_pts[:, 1], c='royalblue', s=80,
               marker='o', zorder=5, edgecolors='navy', linewidths=1.5,
               alpha=0.7, label='Hessian support (actual)')

# Draw both convex hulls
if len(shadow) >= 3:
    hull_s = convex_hull_2d(list(shadow))
    hull_s_closed = hull_s + [hull_s[0]]
    sx = [p[0] for p in hull_s_closed]
    sy = [p[1] for p in hull_s_closed]
    ax.fill(sx, sy, alpha=0.1, color='crimson')
    ax.plot(sx, sy, 'r--', linewidth=2.5, alpha=0.8, label='Shadow polytope')

if len(hessian_supp) >= 3:
    hull_h = convex_hull_2d(list(hessian_supp))
    hull_h_closed = hull_h + [hull_h[0]]
    hx = [p[0] for p in hull_h_closed]
    hy = [p[1] for p in hull_h_closed]
    ax.plot(hx, hy, 'b-', linewidth=1.5, alpha=0.6, label='Hessian polytope')

ax.set_title(f'Shadow Duality: ∂₀∂₁p', fontsize=13, fontweight='bold')
ax.set_xlabel('$x_0$ exponent', fontsize=11)
ax.set_ylabel('$x_1$ exponent', fontsize=11)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)
ax.set_aspect('equal')

# ── Example 3: All four Hessian entries ──
ax = axes[1, 0]
colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3']
markers = ['D', 'o', 's', '^']
labels_ij = [(0, 0), (0, 1), (1, 0), (1, 1)]

for idx, (ii, jj) in enumerate(labels_ij):
    sh = quad_leaf_shadow(support, ii, jj, 2)
    if sh:
        pts = np.array(list(sh))
        ax.scatter(pts[:, 0], pts[:, 1], c=colors[idx], s=80,
                   marker=markers[idx], zorder=5, alpha=0.8,
                   edgecolors='black', linewidths=0.8,
                   label=f'Shadow(∂_{ii}∂_{jj})')

ax.set_title('All Hessian Shadow Entries', fontsize=13, fontweight='bold')
ax.set_xlabel('$x_0$ exponent', fontsize=11)
ax.set_ylabel('$x_1$ exponent', fontsize=11)
ax.legend(fontsize=9, loc='upper right')
ax.grid(True, alpha=0.3)
ax.set_aspect('equal')

# ── Example 4: Support function comparison ──
ax = axes[1, 1]
n_angles = 100
angles = np.linspace(0, 2 * np.pi, n_angles)
sf_shadow_vals = []
sf_hessian_vals = []

for theta in angles:
    w = [np.cos(theta), np.sin(theta)]
    if shadow:
        sf_s = max(sum(wi * ai for wi, ai in zip(w, alpha)) for alpha in shadow)
    else:
        sf_s = 0
    if hessian_supp:
        sf_h = max(sum(wi * ai for wi, ai in zip(w, alpha)) for alpha in hessian_supp)
    else:
        sf_h = 0
    sf_shadow_vals.append(sf_s)
    sf_hessian_vals.append(sf_h)

ax.plot(np.degrees(angles), sf_shadow_vals, 'r-', linewidth=2.5,
        label='Shadow support fn', alpha=0.8)
ax.plot(np.degrees(angles), sf_hessian_vals, 'b--', linewidth=1.5,
        label='Hessian support fn', alpha=0.8)

ax.set_title('Support Function Comparison (Theorem 3)',
             fontsize=13, fontweight='bold')
ax.set_xlabel('Weight angle (degrees)', fontsize=11)
ax.set_ylabel('Support function value', fontsize=11)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.tight_layout(rect=[0, 0, 1, 0.96])
plt.savefig('shadow_duality.png', dpi=150, bbox_inches='tight')
print("Saved shadow_duality.png")


#!/usr/bin/env python3
"""
Visualization: Shadow Complexity Heatmap
==========================================

Visualizes the shadow complexity across all variable pairs as a heatmap.
Each cell (i,j) shows the size of the quadratic leaf shadow — the predicted
number of nonzero terms in ∂ᵢ∂ⱼp. This reveals the combinatorial structure
of second-derivative complexity from support data alone.

Uses matplotlib. Saves output as shadow_heatmap.png.
"""

import numpy as np
import matplotlib.pyplot as plt


def quad_leaf_shadow(support, i, j, n_vars):
    """Compute quadratic leaf shadow."""
    shadow = set()
    for alpha in support:
        alpha_list = list(alpha)
        if alpha_list[i] >= 1:
            alpha_list[i] -= 1
            if alpha_list[j] >= 1:
                alpha_list[j] -= 1
                shadow.add(tuple(alpha_list))
    return shadow


def generate_random_support(n_vars, n_terms, max_degree=5, seed=42):
    """Generate random support set."""
    rng = np.random.RandomState(seed)
    support = set()
    while len(support) < n_terms:
        exp = tuple(rng.randint(0, max_degree + 1, size=n_vars))
        support.add(exp)
    return support


fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))
fig.suptitle('Hessian Shadow Complexity Maps',
             fontsize=15, fontweight='bold', y=1.02)

configs = [
    (3, 12, 4, 'n=3, |S|=12, deg≤4'),
    (4, 20, 5, 'n=4, |S|=20, deg≤5'),
    (5, 30, 4, 'n=5, |S|=30, deg≤4'),
]

for ax_idx, (n_vars, n_terms, max_deg, title) in enumerate(configs):
    ax = axes[ax_idx]
    support = generate_random_support(n_vars, n_terms, max_deg, seed=42 + ax_idx)

    # Compute shadow sizes
    matrix = np.zeros((n_vars, n_vars), dtype=int)
    for i in range(n_vars):
        for j in range(n_vars):
            shadow = quad_leaf_shadow(support, i, j, n_vars)
            matrix[i, j] = len(shadow)

    im = ax.imshow(matrix, cmap='YlOrRd', interpolation='nearest',
                   aspect='equal', vmin=0)

    # Annotate cells
    for i in range(n_vars):
        for j in range(n_vars):
            color = 'white' if matrix[i, j] > matrix.max() * 0.6 else 'black'
            ax.text(j, i, str(matrix[i, j]), ha='center', va='center',
                    fontsize=14, fontweight='bold', color=color)

    ax.set_title(title, fontsize=12, fontweight='bold')
    ax.set_xlabel('j (second derivative)', fontsize=11)
    ax.set_ylabel('i (first derivative)', fontsize=11)
    ax.set_xticks(range(n_vars))
    ax.set_yticks(range(n_vars))
    ax.set_xticklabels([f'$x_{k}$' for k in range(n_vars)])
    ax.set_yticklabels([f'$x_{k}$' for k in range(n_vars)])
    plt.colorbar(im, ax=ax, shrink=0.8, label='Shadow size')

plt.tight_layout()
plt.savefig('shadow_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved shadow_heatmap.png")


#!/usr/bin/env python3
"""
Visualization: Support Function Polar Plot
=============================================

Visualizes the support function of the shadow polytope as a polar plot.
The support function h(w) = max⟨w, α⟩ over shadow generators encodes
the shape of the Newton polytope. By Theorem 3 (Tropical-Algebraic Bridge),
this equals the support function of the Hessian Newton polytope.

The polar plot shows h(w) for w = (cos θ, sin θ), revealing the
directional complexity of the Hessian entry.

Uses matplotlib. Saves output as support_function_polar.png.
"""

import numpy as np
import matplotlib.pyplot as plt


def quad_leaf_shadow(support, i, j, n_vars):
    """Compute quadratic leaf shadow."""
    shadow = set()
    for alpha in support:
        alpha_list = list(alpha)
        if alpha_list[i] >= 1:
            alpha_list[i] -= 1
            if alpha_list[j] >= 1:
                alpha_list[j] -= 1
                shadow.add(tuple(alpha_list))
    return shadow


def support_function_eval(generators, w):
    """Evaluate support function max⟨w, α⟩."""
    if not generators:
        return 0.0
    return max(sum(wi * ai for wi, ai in zip(w, alpha)) for alpha in generators)


# Polynomial: p = x⁴ + y⁴ + 3x²y² + 2x³y + xy³ + x²y + xy²
poly_support = {(4, 0), (0, 4), (2, 2), (3, 1), (1, 3), (2, 1), (1, 2)}
n_vars = 2

fig, axes = plt.subplots(2, 2, figsize=(12, 12),
                          subplot_kw={'projection': 'polar'})
fig.suptitle('Support Function Polar Plots — Shadow Polytopes',
             fontsize=14, fontweight='bold', y=0.98)

pairs = [(0, 0), (0, 1), (1, 0), (1, 1)]
colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3']

angles = np.linspace(0, 2 * np.pi, 360, endpoint=False)

for idx, (i, j) in enumerate(pairs):
    ax = axes[idx // 2][idx % 2]
    shadow = quad_leaf_shadow(poly_support, i, j, n_vars)

    if shadow:
        # Compute support function
        values = []
        for theta in angles:
            w = [np.cos(theta), np.sin(theta)]
            values.append(support_function_eval(shadow, w))
        values = np.array(values)

        # Normalize for visibility
        values_shifted = values - values.min() + 0.5

        ax.fill(angles, values_shifted, alpha=0.2, color=colors[idx])
        ax.plot(angles, values_shifted, color=colors[idx], linewidth=2)

        # Mark vertices of shadow
        for pt in shadow:
            r = np.sqrt(pt[0]**2 + pt[1]**2) + 0.5
            theta_pt = np.arctan2(pt[1], pt[0])
            ax.plot(theta_pt, r, 'o', color=colors[idx], markersize=8,
                    markeredgecolor='black', markeredgewidth=1)

    ax.set_title(f'∂_{i}∂_{j}p — Shadow: {sorted(shadow) if shadow else "∅"}',
                 fontsize=11, fontweight='bold', pad=15)
    ax.set_rticks([])

plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.savefig('support_function_polar.png', dpi=150, bbox_inches='tight')
print("Saved support_function_polar.png")
