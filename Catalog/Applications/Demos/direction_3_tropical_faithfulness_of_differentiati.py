#!/usr/bin/env python3
"""
Applications of Tropical Faithfulness of Differentiation

Demonstrates real-world applications:
1. Sparse polynomial derivative computation shortcuts
2. Newton polytope prediction for algebraic geometry
3. Tropical sensitivity analysis
4. Hessian structure prediction

These applications show how the certificate enables certified
shortcuts in symbolic computation, geometry, and optimization.
"""

import random
from typing import Dict, Tuple, Set, List

Exponent = Tuple[int, ...]
Polynomial = Dict[Exponent, float]


def partial_derivative(poly: Polynomial, var: int, n_vars: int) -> Polynomial:
    result: Polynomial = {}
    for exp, coeff in poly.items():
        e = list(exp)
        if e[var] >= 1:
            new_coeff = coeff * e[var]
            e[var] -= 1
            result[tuple(e)] = result.get(tuple(e), 0) + new_coeff
    return {k: v for k, v in result.items() if abs(v) > 1e-12}


def mixed_partial(poly: Polynomial, i: int, j: int, n_vars: int) -> Polynomial:
    return partial_derivative(partial_derivative(poly, j, n_vars), i, n_vars)


def mixed_shadow(supp: Set[Exponent], i: int, j: int, n_vars: int) -> Set[Exponent]:
    shadow = set()
    for alpha in supp:
        beta = list(alpha)
        beta[i] -= 1
        beta[j] -= 1
        if all(b >= 0 for b in beta):
            shadow.add(tuple(beta))
    return shadow


def support_function(supp: Set[Exponent], w: Tuple[float, ...]) -> float:
    if not supp:
        return float('-inf')
    return max(sum(w[k] * a[k] for k in range(len(w))) for a in supp)


# ──────────────────────────────────────────────────────────────────
# Application 1: Certified Derivative Support Shortcut
# ──────────────────────────────────────────────────────────────────

def app_certified_derivative_shortcut():
    """
    In sparse polynomial computation, determining the support of a
    derivative is often needed before computing exact coefficients
    (e.g., for memory allocation, sparsity prediction, or algorithm
    selection).

    The tropical faithfulness theorem guarantees that in char 0,
    the support of ∂ᵢ∂ⱼp can be computed from supp(p) alone,
    WITHOUT computing any coefficients. This gives an O(|supp|)
    shortcut vs O(|supp| · coefficient_arithmetic).
    """
    print("=" * 70)
    print("APPLICATION 1: Certified Derivative Support Shortcut")
    print("=" * 70)

    # Large sparse polynomial in 3 variables
    n_vars = 3
    random.seed(123)
    poly = {}
    for _ in range(50):
        exp = tuple(random.randint(0, 10) for _ in range(n_vars))
        poly[exp] = random.uniform(-10, 10)
    poly = {k: v for k, v in poly.items() if abs(v) > 1e-12}

    print(f"\nPolynomial with {len(poly)} terms in {n_vars} variables")

    # Method 1: Full computation
    for i in range(n_vars):
        for j in range(n_vars):
            mp = mixed_partial(poly, i, j, n_vars)
            actual_supp = set(mp.keys())

            # Method 2: Shadow shortcut
            predicted_supp = mixed_shadow(set(poly.keys()), i, j, n_vars)

            assert actual_supp == predicted_supp, \
                f"Mismatch for ({i},{j})!"

    print("✓ All 9 mixed partial supports predicted correctly from shadow")
    print("  No coefficient arithmetic needed for support prediction!")
    print(f"  Savings: avoided {len(poly)} multiplications per derivative")


# ──────────────────────────────────────────────────────────────────
# Application 2: Newton Polytope Dynamics
# ──────────────────────────────────────────────────────────────────

def app_newton_polytope_dynamics():
    """
    In algebraic geometry, Newton polytopes encode the combinatorial
    structure of polynomials. Understanding how differentiation affects
    Newton polytopes is crucial for discriminant computation, resultant
    estimation, and tropical intersection theory.

    The shadow theorem provides an exact rule for computing the Newton
    polytope of a derivative from the Newton polytope of the original.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Newton Polytope Dynamics under Differentiation")
    print("=" * 70)

    # A polynomial whose Newton polytope is a hexagon
    poly = {
        (4, 0): 1, (3, 1): 1, (2, 2): 1,
        (1, 3): 1, (0, 4): 1, (2, 0): 1,
        (0, 2): 1, (1, 1): 1,
    }
    n_vars = 2

    print("\np with Newton polytope (octagonal shape)")
    print(f"supp(p) = {sorted(poly.keys())}")

    for i in range(n_vars):
        for j in range(n_vars):
            shadow = mixed_shadow(set(poly.keys()), i, j, n_vars)
            mp = mixed_partial(poly, i, j, n_vars)
            actual = set(mp.keys())

            print(f"\n∂_{i}∂_{j}:")
            print(f"  Shadow (predicted): {sorted(shadow)}")
            print(f"  Actual support:     {sorted(actual)}")
            print(f"  Match: {'✓' if shadow == actual else '✗'}")


# ──────────────────────────────────────────────────────────────────
# Application 3: Tropical Sensitivity Analysis
# ──────────────────────────────────────────────────────────────────

def app_tropical_sensitivity():
    """
    In tropical optimization, a polynomial p defines a piecewise-linear
    function trop(p)(w) = max{⟨w, α⟩ + val(cα) : α ∈ supp(p)}.

    The derivative ∂ᵢ∂ⱼp has tropical function:
    trop(∂ᵢ∂ⱼp)(w) = max{⟨w, β⟩ + val(coeff) : β ∈ supp(∂ᵢ∂ⱼp)}

    By the support function shift theorem:
    trop(∂ᵢ∂ⱼp)(w) = trop(p)(w) - wᵢ - wⱼ + correction

    This enables tropical sensitivity analysis: how does the tropical
    optimum change under differentiation?
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Tropical Sensitivity Analysis")
    print("=" * 70)

    poly = {(3, 2): 1, (2, 3): 2, (1, 1): 3, (4, 0): 1}
    n_vars = 2
    supp_p = set(poly.keys())

    print(f"\np with support {sorted(supp_p)}")

    directions = [(1, 0), (0, 1), (1, 1), (2, 1), (1, 3)]
    i, j = 0, 1
    shadow = mixed_shadow(supp_p, i, j, n_vars)

    print(f"\nTropical sensitivity for ∂₀∂₁ (shadow = {sorted(shadow)}):")
    print(f"{'Direction w':>15} | {'h(p,w)':>8} | {'h(∂₀∂₁p,w)':>12} | "
          f"{'h(p,w)-w₀-w₁':>14} | {'Shift OK':>8}")
    print("-" * 70)

    for w in directions:
        h_p = support_function(supp_p, w)
        h_deriv = support_function(shadow, w)
        predicted = h_p - w[0] - w[1]
        match = abs(h_deriv - predicted) < 1e-10
        print(f"{str(w):>15} | {h_p:>8.1f} | {h_deriv:>12.1f} | "
              f"{predicted:>14.1f} | {'✓' if match else '✗':>8}")


# ──────────────────────────────────────────────────────────────────
# Application 4: Hessian Structure Prediction
# ──────────────────────────────────────────────────────────────────

def app_hessian_prediction():
    """
    The Hessian matrix H(p) = (∂ᵢ∂ⱼp)ᵢⱼ is fundamental in optimization
    and algebraic geometry. Predicting its sparsity structure without
    computing it saves significant time in large-scale problems.

    The tropical faithfulness theorem enables exact Hessian sparsity
    prediction: the (i,j)-entry of H(p) has support equal to
    shadow(supp(p), i, j).
    """
    print("\n" + "=" * 70)
    print("APPLICATION 4: Hessian Sparsity Prediction")
    print("=" * 70)

    # 3-variable polynomial
    poly = {
        (3, 0, 0): 1, (0, 3, 0): 2, (0, 0, 3): -1,
        (2, 1, 0): 3, (1, 0, 2): -2, (0, 2, 1): 1,
        (1, 1, 1): 4,
    }
    n_vars = 3

    print(f"\np in K[x, y, z] with {len(poly)} terms")
    print(f"Support: {sorted(poly.keys())}")

    total_terms = 0
    print("\nHessian sparsity pattern (# terms per entry):")
    print(f"{'':>5}", end="")
    for j in range(n_vars):
        print(f"{'∂'+str(j):>8}", end="")
    print()

    for i in range(n_vars):
        print(f"{'∂'+str(i):>5}", end="")
        for j in range(n_vars):
            shadow = mixed_shadow(set(poly.keys()), i, j, n_vars)
            mp = mixed_partial(poly, i, j, n_vars)
            actual = set(mp.keys())
            assert shadow == actual
            n_terms = len(shadow)
            total_terms += n_terms
            print(f"{n_terms:>8}", end="")
        print()

    print(f"\nTotal Hessian nonzeros: {total_terms}")
    print("All predicted exactly from support shadow ✓")


def main():
    app_certified_derivative_shortcut()
    app_newton_polytope_dynamics()
    app_tropical_sensitivity()
    app_hessian_prediction()

    print("\n" + "=" * 70)
    print("All applications demonstrated successfully!")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Tropical Faithfulness of Differentiation — Interactive Demo

Demonstrates:
1. Mixed partial derivative support computation
2. Mixed shadow (combinatorial prediction)
3. Comparison: equality (faithful) vs strict inclusion (cancellation)
4. Explicit certificate-positive and certificate-negative examples
5. Newton polytope visualization data

Run: python demo.py
"""

from itertools import product
from collections import defaultdict
import random

# ──────────────────────────────────────────────────────────────────
# Core polynomial representation: sparse dict { exponent_tuple: coeff }
# ──────────────────────────────────────────────────────────────────

def pderiv(poly, var_idx, n_vars):
    """Partial derivative of a sparse polynomial w.r.t. variable var_idx."""
    result = {}
    for exp, coeff in poly.items():
        e = list(exp)
        if e[var_idx] >= 1:
            new_coeff = coeff * e[var_idx]
            e[var_idx] -= 1
            new_exp = tuple(e)
            result[new_exp] = result.get(new_exp, 0) + new_coeff
    # Remove zero coefficients
    return {k: v for k, v in result.items() if abs(v) > 1e-12}


def mixed_partial(poly, i, j, n_vars):
    """Compute ∂ᵢ(∂ⱼ poly)."""
    return pderiv(pderiv(poly, j, n_vars), i, n_vars)


def support(poly):
    """Return the support (set of exponent tuples with nonzero coefficients)."""
    return set(k for k, v in poly.items() if abs(v) > 1e-12)


def mixed_shadow(supp, i, j, n_vars):
    """Compute the mixed shadow: {β : β + eᵢ + eⱼ ∈ S}."""
    ei = [0] * n_vars; ei[i] = 1
    ej = [0] * n_vars; ej[j] = 1
    shadow = set()
    for alpha in supp:
        beta = list(alpha)
        beta[i] -= 1
        beta[j] -= 1
        if all(b >= 0 for b in beta):
            shadow.add(tuple(beta))
    return shadow


def aggregate_mixed_partial(poly, weights, n_vars):
    """Compute ∑ᵢⱼ w(i,j) · ∂ᵢ∂ⱼ poly."""
    result = {}
    for i in range(n_vars):
        for j in range(n_vars):
            w = weights[i][j]
            if abs(w) < 1e-12:
                continue
            mp = mixed_partial(poly, i, j, n_vars)
            for exp, coeff in mp.items():
                result[exp] = result.get(exp, 0) + w * coeff
    return {k: v for k, v in result.items() if abs(v) > 1e-12}


def aggregate_shadow(supp, weights, n_vars):
    """Union of mixed shadows over nonzero weights."""
    shadow = set()
    for i in range(n_vars):
        for j in range(n_vars):
            if abs(weights[i][j]) > 1e-12:
                shadow |= mixed_shadow(supp, i, j, n_vars)
    return shadow


def convex_hull_2d(points):
    """Compute 2D convex hull using Graham scan."""
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


def newton_polytope(poly):
    """Return vertices of the Newton polytope (2D convex hull of support)."""
    s = support(poly)
    if not s:
        return []
    return convex_hull_2d(list(s))


# ──────────────────────────────────────────────────────────────────
# Example 1: Individual mixed partial — always faithful in char 0
# ──────────────────────────────────────────────────────────────────

def demo_individual_faithfulness():
    print("=" * 70)
    print("DEMO 1: Individual Mixed Partial — Always Faithful (Char 0)")
    print("=" * 70)

    # p = 3x²y + 2xy² + x³ + y³
    poly = {
        (2, 1): 3,
        (1, 2): 2,
        (3, 0): 1,
        (0, 3): 1,
    }
    n_vars = 2
    i, j = 0, 1

    print(f"\np = 3·x²y + 2·xy² + x³ + y³")
    print(f"supp(p) = {sorted(support(poly))}")

    mp = mixed_partial(poly, i, j, n_vars)
    shadow = mixed_shadow(support(poly), i, j, n_vars)
    actual = support(mp)

    print(f"\n∂₀∂₁ p (mixed partial):")
    for exp, coeff in sorted(mp.items()):
        print(f"  coeff at {exp} = {coeff}")
    print(f"\nsupp(∂₀∂₁ p) = {sorted(actual)}")
    print(f"mixedShadow(supp p, 0, 1) = {sorted(shadow)}")
    print(f"\n✓ EQUAL: {actual == shadow}")
    print("  (This always holds for individual mixed partials in char 0)")
    return actual == shadow


# ──────────────────────────────────────────────────────────────────
# Example 2: Aggregate operator — cancellation possible
# ──────────────────────────────────────────────────────────────────

def demo_aggregate_cancellation():
    print("\n" + "=" * 70)
    print("DEMO 2: Aggregate Operator — Cancellation (Strict Inclusion)")
    print("=" * 70)

    # p = x²y + xy²
    poly = {(2, 1): 1, (1, 2): 1}
    n_vars = 2

    # Antisymmetric weights: w(0,1) = 1, w(1,0) = -1, others = 0
    weights = [[0, 1], [-1, 0]]

    print(f"\np = x²y + xy²")
    print(f"Weights: w(0,1)=1, w(1,0)=-1 (antisymmetric)")

    agg = aggregate_mixed_partial(poly, weights, n_vars)
    shadow = aggregate_shadow(support(poly), weights, n_vars)
    actual = support(agg)

    print(f"\nAggregate ∑ w(i,j)·∂ᵢ∂ⱼ p = ∂₀∂₁p - ∂₁∂₀p = 0")
    print(f"  (because mixed partials commute!)")
    print(f"\nsupp(aggregate) = {sorted(actual)} (empty!)")
    print(f"aggregateShadow = {sorted(shadow)} (nonempty!)")
    print(f"\n✗ STRICT INCLUSION: actual ⊊ shadow")
    print("  The shadow predicts monomials that cancel away!")
    return actual != shadow


# ──────────────────────────────────────────────────────────────────
# Example 3: Random polynomial testing
# ──────────────────────────────────────────────────────────────────

def demo_random_testing(n_trials=200):
    print("\n" + "=" * 70)
    print(f"DEMO 3: Random Testing ({n_trials} trials)")
    print("=" * 70)

    n_vars = 2
    max_degree = 5
    individual_faithful = 0
    individual_total = 0
    aggregate_strict = 0
    aggregate_total = 0

    for trial in range(n_trials):
        # Generate random sparse polynomial
        n_terms = random.randint(2, 8)
        poly = {}
        for _ in range(n_terms):
            exp = tuple(random.randint(0, max_degree) for _ in range(n_vars))
            poly[exp] = random.choice([-3, -2, -1, 1, 2, 3])

        if not support(poly):
            continue

        # Test individual mixed partials
        for i in range(n_vars):
            for j in range(n_vars):
                mp = mixed_partial(poly, i, j, n_vars)
                shadow = mixed_shadow(support(poly), i, j, n_vars)
                actual = support(mp)
                individual_total += 1
                if actual == shadow:
                    individual_faithful += 1

        # Test aggregate with random weights
        weights = [[random.choice([-2, -1, 0, 1, 2]) for _ in range(n_vars)]
                   for _ in range(n_vars)]
        agg = aggregate_mixed_partial(poly, weights, n_vars)
        shadow = aggregate_shadow(support(poly), weights, n_vars)
        actual = support(agg)

        aggregate_total += 1
        if actual != shadow and shadow:
            aggregate_strict += 1

    print(f"\nIndividual mixed partials:")
    print(f"  Faithful: {individual_faithful}/{individual_total} "
          f"({100*individual_faithful/max(individual_total,1):.1f}%)")
    print(f"  ← Always 100%! (Theorem 1)")

    print(f"\nAggregate operators:")
    print(f"  Strict inclusion: {aggregate_strict}/{aggregate_total} "
          f"({100*aggregate_strict/max(aggregate_total,1):.1f}%)")
    print(f"  ← Positive rate (Theorem 4)")


# ──────────────────────────────────────────────────────────────────
# Example 4: Newton polytope comparison
# ──────────────────────────────────────────────────────────────────

def demo_newton_polytope():
    print("\n" + "=" * 70)
    print("DEMO 4: Newton Polytope Comparison")
    print("=" * 70)

    # p = x³y + 2x²y² + xy³ + x²y + xy²
    poly = {
        (3, 1): 1, (2, 2): 2, (1, 3): 1,
        (2, 1): 1, (1, 2): 1,
    }
    n_vars = 2
    i, j = 0, 1

    mp = mixed_partial(poly, i, j, n_vars)
    shadow_set = mixed_shadow(support(poly), i, j, n_vars)

    print(f"\np = x³y + 2x²y² + xy³ + x²y + xy²")
    print(f"\nsupp(p)         = {sorted(support(poly))}")
    print(f"supp(∂₀∂₁ p)   = {sorted(support(mp))}")
    print(f"mixedShadow     = {sorted(shadow_set)}")
    print(f"Support equal:    {support(mp) == shadow_set}")

    hull_p = newton_polytope(poly)
    hull_mp = newton_polytope(mp)

    # Construct shadow polynomial for Newton polytope
    shadow_poly = {exp: 1 for exp in shadow_set}
    hull_shadow = newton_polytope(shadow_poly)

    print(f"\nNewton polytope vertices:")
    print(f"  Newt(p):        {hull_p}")
    print(f"  Newt(∂₀∂₁ p):  {hull_mp}")
    print(f"  Newt(shadow):   {hull_shadow}")
    print(f"  Newt(∂₀∂₁p) = Newt(shadow): {hull_mp == hull_shadow}")


# ──────────────────────────────────────────────────────────────────
# Example 5: Support function shift demonstration
# ──────────────────────────────────────────────────────────────────

def demo_support_function():
    print("\n" + "=" * 70)
    print("DEMO 5: Support Function Shift (Cross-Domain Bridge)")
    print("=" * 70)

    # p = x³y² + x²y³ + xy
    poly = {(3, 2): 1, (2, 3): 1, (1, 1): 1}
    n_vars = 2
    i, j = 0, 1

    supp_p = support(poly)
    shadow = mixed_shadow(supp_p, i, j, n_vars)

    print(f"\np = x³y² + x²y³ + xy")
    print(f"supp(p)     = {sorted(supp_p)}")
    print(f"shadow(0,1) = {sorted(shadow)}")

    # Test support function h_S(w) = max{⟨w, α⟩ : α ∈ S}
    test_directions = [(1, 0), (0, 1), (1, 1), (2, 1), (1, 2)]

    print(f"\nSupport function comparison:")
    print(f"{'w':>10} | {'h_S(w)':>8} | {'h_shadow(w)':>12} | {'h_S(w)-(w₀+w₁)':>16} | {'Equal?':>7}")
    print("-" * 65)

    for w in test_directions:
        h_S = max(sum(w[k] * a[k] for k in range(n_vars)) for a in supp_p)
        h_sh = max(sum(w[k] * a[k] for k in range(n_vars)) for a in shadow) if shadow else float('-inf')
        shifted = h_S - (w[i] + w[j])
        eq = abs(h_sh - shifted) < 1e-10
        print(f"{str(w):>10} | {h_S:>8.1f} | {h_sh:>12.1f} | {shifted:>16.1f} | {'✓' if eq else '✗':>7}")

    print("\n  h_shadow(w) = h_S(w) - (w₀ + w₁)  ← Theorem 5!")


# ──────────────────────────────────────────────────────────────────
# Example 6: Catastrophic cancellation showcase
# ──────────────────────────────────────────────────────────────────

def demo_catastrophic_cancellation():
    print("\n" + "=" * 70)
    print("DEMO 6: Catastrophic Cancellation Showcase")
    print("=" * 70)

    # p = ax²y + bxy² where a = -b
    # ∂₀∂₁ p = 2ax + 2by = 2(a+b)... wait, let me compute properly
    # ∂₁(x²y) = x², ∂₀(x²) = 2x. So ∂₀∂₁(x²y) = 2x
    # ∂₁(xy²) = 2xy, ∂₀(2xy) = 2y. So ∂₀∂₁(xy²) = 2y
    # Sum ∂₀∂₁ p = 2ax + 2by, never cancels for individual (i,j)

    # For aggregate: ∂₀∂₁ + ∂₁∂₀ = 2·∂₀∂₁ (commute), no cancellation
    # Need: different directions to cancel

    # Better example: p = x²y - xy²
    # ∂₀∂₁(x²y) = 2x, ∂₀∂₁(-xy²) = -2y
    # ∂₁∂₀(x²y) = 2x, ∂₁∂₀(-xy²) = -2y
    # Aggregate w(0,0)·∂₀² + w(1,1)·∂₁² with specific weights

    # Actually simpler: use Laplacian ∂₀² + ∂₁²
    # p = x²y - xy²
    # ∂₀²(x²y) = 2y, ∂₀²(-xy²) = 0. So ∂₀² p = 2y
    # ∂₁²(x²y) = 0, ∂₁²(-xy²) = -2x. So ∂₁² p = -2x
    # Laplacian = 2y - 2x. Shadow has {(0,1), (1,0)} → both present. No cancellation.

    # For real cancellation: p = x² + y²
    # ∂₀∂₁ p = 0 (no mixed terms). Shadow of (0,1) pair from {(2,0),(0,2)} is empty.
    # Not interesting.

    # Best demo: aggregate with carefully chosen polynomial
    # p = x²y + xy², weights = [[0,1],[-1,0]]
    poly = {(2, 1): 1, (1, 2): 1}
    n_vars = 2
    weights = [[0, 1], [-1, 0]]

    print(f"\np = x²y + xy²")
    print(f"Antisymmetric weights: w(0,1) = 1, w(1,0) = -1")

    # Individual mixed partials
    mp01 = mixed_partial(poly, 0, 1, n_vars)
    mp10 = mixed_partial(poly, 1, 0, n_vars)
    print(f"\n∂₀∂₁ p = {dict(sorted(mp01.items()))}")
    print(f"∂₁∂₀ p = {dict(sorted(mp10.items()))}")
    print(f"These are EQUAL (commutativity)!")

    agg = aggregate_mixed_partial(poly, weights, n_vars)
    shadow = aggregate_shadow(support(poly), weights, n_vars)

    print(f"\nAggregate = 1·∂₀∂₁p + (-1)·∂₁∂₀p = 0")
    print(f"supp(aggregate) = {sorted(support(agg))} ← EMPTY!")
    print(f"aggregate shadow = {sorted(shadow)} ← NONEMPTY!")
    print(f"\n⚠ CATASTROPHIC CANCELLATION:")
    print(f"  The shadow predicts {len(shadow)} exponents, but ALL cancel.")
    print(f"  Certificate FAILS. Shadow is strict over-approximation.")


def main():
    random.seed(42)

    demo_individual_faithfulness()
    demo_aggregate_cancellation()
    demo_random_testing()
    demo_newton_polytope()
    demo_support_function()
    demo_catastrophic_cancellation()

    print("\n" + "=" * 70)
    print("SUMMARY")
    print("=" * 70)
    print("""
Key findings demonstrated:
1. Individual mixed partials are ALWAYS tropically faithful (char 0)
2. Aggregate operators can have strict shadow over-approximation
3. The non-cancellation certificate exactly characterizes faithfulness
4. Newton polytopes inherit the support-level equality/inclusion
5. Support functions shift linearly under shadow translation
6. Commutativity of mixed partials enables systematic cancellation
""")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Certificate Satisfaction Landscape

Visualizes the non-cancellation certificate landscape across random
polynomial families, showing:
- Certificate satisfaction rate vs polynomial density
- Support equality rate for individual vs aggregate operators
- Phase transition behavior

CRITICAL: This script is fully self-contained. No local imports.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import random


def partial_derivative(poly, var_idx, n_vars):
    result = {}
    for exp, coeff in poly.items():
        e = list(exp)
        if e[var_idx] >= 1:
            new_coeff = coeff * e[var_idx]
            e[var_idx] -= 1
            new_exp = tuple(e)
            result[new_exp] = result.get(new_exp, 0) + new_coeff
    return {k: v for k, v in result.items() if abs(v) > 1e-12}


def mixed_partial(poly, i, j, n_vars):
    return partial_derivative(partial_derivative(poly, j, n_vars), i, n_vars)


def mixed_shadow(supp, i, j, n_vars):
    shadow = set()
    for alpha in supp:
        beta = list(alpha)
        beta[i] -= 1
        beta[j] -= 1
        if all(b >= 0 for b in beta):
            shadow.add(tuple(beta))
    return shadow


def aggregate_mixed_partial(poly, weights, n_vars):
    result = {}
    for i in range(n_vars):
        for j in range(n_vars):
            w = weights[i][j]
            if abs(w) < 1e-12:
                continue
            mp = mixed_partial(poly, i, j, n_vars)
            for exp, coeff in mp.items():
                result[exp] = result.get(exp, 0) + w * coeff
    return {k: v for k, v in result.items() if abs(v) > 1e-12}


random.seed(42)
n_vars = 2
max_degree = 6

fig, axes = plt.subplots(2, 2, figsize=(14, 12))

# Panel 1: Individual faithfulness rate vs number of terms
ax = axes[0][0]
term_counts = range(1, 20)
faithfulness_rates = []

for n_terms in term_counts:
    faithful = 0
    total = 0
    for trial in range(100):
        poly = {}
        for _ in range(n_terms):
            exp = (random.randint(0, max_degree), random.randint(0, max_degree))
            poly[exp] = random.choice([-3, -2, -1, 1, 2, 3])
        if not poly:
            continue

        for i in range(n_vars):
            for j in range(n_vars):
                mp = mixed_partial(poly, i, j, n_vars)
                shadow = mixed_shadow(set(poly.keys()), i, j, n_vars)
                actual = set(mp.keys())
                total += 1
                if actual == shadow:
                    faithful += 1

    rate = faithful / max(total, 1)
    faithfulness_rates.append(rate)

ax.plot(list(term_counts), faithfulness_rates, 'o-', color='#4CAF50', linewidth=2, markersize=6)
ax.axhline(y=1.0, color='#4CAF50', linestyle='--', alpha=0.5)
ax.set_xlabel('Number of terms in polynomial', fontsize=11)
ax.set_ylabel('Faithfulness rate', fontsize=11)
ax.set_title('Individual ∂ᵢ∂ⱼ: Always Faithful', fontsize=13, fontweight='bold')
ax.set_ylim(0.95, 1.05)
ax.grid(True, alpha=0.3)
ax.text(0.5, 0.3, '100% faithful\n(Theorem 1)', transform=ax.transAxes,
        ha='center', fontsize=14, color='#4CAF50', fontweight='bold')

# Panel 2: Aggregate strict inclusion rate vs number of terms
ax = axes[0][1]
strict_rates = []

for n_terms in term_counts:
    strict = 0
    total = 0
    for trial in range(100):
        poly = {}
        for _ in range(n_terms):
            exp = (random.randint(0, max_degree), random.randint(0, max_degree))
            poly[exp] = random.choice([-3, -2, -1, 1, 2, 3])
        if not poly:
            continue

        # Random weights
        weights = [[random.choice([-2, -1, 0, 1, 2]) for _ in range(n_vars)]
                   for _ in range(n_vars)]
        agg = aggregate_mixed_partial(poly, weights, n_vars)
        shadow_set = set()
        for i in range(n_vars):
            for j in range(n_vars):
                if abs(weights[i][j]) > 1e-12:
                    shadow_set |= mixed_shadow(set(poly.keys()), i, j, n_vars)

        actual = set(agg.keys())
        total += 1
        if actual != shadow_set and shadow_set:
            strict += 1

    rate = strict / max(total, 1)
    strict_rates.append(rate)

ax.plot(list(term_counts), strict_rates, 'o-', color='#F44336', linewidth=2, markersize=6)
ax.set_xlabel('Number of terms in polynomial', fontsize=11)
ax.set_ylabel('Strict inclusion rate', fontsize=11)
ax.set_title('Aggregate: Cancellation Frequency', fontsize=13, fontweight='bold')
ax.grid(True, alpha=0.3)
ax.text(0.5, 0.85, 'Certificate\nfailure rate', transform=ax.transAxes,
        ha='center', fontsize=12, color='#F44336')

# Panel 3: Heatmap of shadow size vs actual support size
ax = axes[1][0]
shadow_sizes = []
actual_sizes = []

for trial in range(500):
    n_terms = random.randint(2, 15)
    poly = {}
    for _ in range(n_terms):
        exp = (random.randint(0, max_degree), random.randint(0, max_degree))
        poly[exp] = random.choice([-3, -2, -1, 1, 2, 3])
    if not poly:
        continue

    weights = [[random.choice([-2, -1, 0, 1, 2]) for _ in range(n_vars)]
               for _ in range(n_vars)]
    agg = aggregate_mixed_partial(poly, weights, n_vars)
    shadow_set = set()
    for i in range(n_vars):
        for j in range(n_vars):
            if abs(weights[i][j]) > 1e-12:
                shadow_set |= mixed_shadow(set(poly.keys()), i, j, n_vars)

    if shadow_set:
        shadow_sizes.append(len(shadow_set))
        actual_sizes.append(len(set(agg.keys())))

ax.scatter(shadow_sizes, actual_sizes, alpha=0.3, s=20, color='#9C27B0')
max_val = max(max(shadow_sizes, default=1), max(actual_sizes, default=1))
ax.plot([0, max_val], [0, max_val], '--', color='#4CAF50', linewidth=2, label='y = x (faithful)')
ax.set_xlabel('Shadow size (predicted)', fontsize=11)
ax.set_ylabel('Actual support size', fontsize=11)
ax.set_title('Shadow vs Actual Support (Aggregate)', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 4: Certificate satisfaction by weight structure
ax = axes[1][1]
categories = ['Identity\n(I)', 'Symmetric\n(wᵢⱼ=wⱼᵢ)', 'Antisymmetric\n(wᵢⱼ=-wⱼᵢ)', 'Random']
cert_rates = []

for cat_idx, category in enumerate(categories):
    holds = 0
    total = 0
    for trial in range(200):
        n_terms = random.randint(3, 10)
        poly = {}
        for _ in range(n_terms):
            exp = (random.randint(0, max_degree), random.randint(0, max_degree))
            poly[exp] = random.choice([-3, -2, -1, 1, 2, 3])
        if not poly:
            continue

        if cat_idx == 0:  # Identity
            weights = [[1 if i == j else 0 for j in range(n_vars)] for i in range(n_vars)]
        elif cat_idx == 1:  # Symmetric
            w01 = random.choice([-2, -1, 1, 2])
            weights = [[random.choice([0, 1, 2]), w01], [w01, random.choice([0, 1, 2])]]
        elif cat_idx == 2:  # Antisymmetric
            w01 = random.choice([-2, -1, 1, 2])
            weights = [[0, w01], [-w01, 0]]
        else:  # Random
            weights = [[random.choice([-2, -1, 0, 1, 2]) for _ in range(n_vars)]
                       for _ in range(n_vars)]

        agg = aggregate_mixed_partial(poly, weights, n_vars)
        shadow_set = set()
        for i in range(n_vars):
            for j in range(n_vars):
                if abs(weights[i][j]) > 1e-12:
                    shadow_set |= mixed_shadow(set(poly.keys()), i, j, n_vars)

        actual = set(agg.keys())
        total += 1
        if actual == shadow_set or not shadow_set:
            holds += 1

    cert_rates.append(holds / max(total, 1))

colors = ['#4CAF50', '#2196F3', '#F44336', '#FF9800']
bars = ax.bar(categories, cert_rates, color=colors, alpha=0.7, edgecolor='black')
ax.set_ylabel('Certificate satisfaction rate', fontsize=11)
ax.set_title('Certificate Rate by Weight Structure', fontsize=13, fontweight='bold')
ax.set_ylim(0, 1.1)
ax.grid(True, alpha=0.3, axis='y')

for bar, rate in zip(bars, cert_rates):
    ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.02,
            f'{rate:.0%}', ha='center', fontsize=11, fontweight='bold')

plt.suptitle('Tropical Faithfulness of Differentiation — Certificate Landscape',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_certificate_landscape.png', dpi=150, bbox_inches='tight')
print("Saved viz_certificate_landscape.png")


#!/usr/bin/env python3
"""
Visualization: Support Function Shift under Shadow Translation

Visualizes Theorem 5: the support function of the mixed shadow equals
the support function of the original set shifted by -(wᵢ + wⱼ).

Shows support functions as polar plots (or directional bar charts)
and demonstrates the exact linear shift relationship.

CRITICAL: This script is fully self-contained. No local imports.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import math


def mixed_shadow(supp, i, j, n_vars):
    shadow = set()
    for alpha in supp:
        beta = list(alpha)
        beta[i] -= 1
        beta[j] -= 1
        if all(b >= 0 for b in beta):
            shadow.add(tuple(beta))
    return shadow


def support_function(supp, w):
    if not supp:
        return float('-inf')
    return max(sum(w[k] * a[k] for k in range(len(w))) for a in supp)


# Setup
supp_p = {(3, 2), (2, 3), (1, 1), (4, 1), (2, 2)}
shadow = mixed_shadow(supp_p, 0, 1, 2)

# Generate directions on unit circle
n_dirs = 72
angles = [2 * math.pi * k / n_dirs for k in range(n_dirs)]
directions = [(math.cos(a), math.sin(a)) for a in angles]
# Only use non-negative directions for the shift theorem
pos_directions = [(max(0.01, math.cos(a)), max(0.01, math.sin(a))) for a in angles]

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Panel 1: Support set and shadow
ax = axes[0]
ax.set_title('Support Set and Mixed Shadow', fontsize=13, fontweight='bold')

for x in range(6):
    for y in range(5):
        ax.plot(x, y, '.', color='#e0e0e0', markersize=3)

for pt in supp_p:
    ax.plot(pt[0], pt[1], 's', color='#2196F3', markersize=16, alpha=0.7, zorder=3)
for pt in shadow:
    ax.plot(pt[0], pt[1], 'D', color='#FF9800', markersize=13, alpha=0.7, zorder=3)
    # Arrow to ancestor
    ancestor = (pt[0] + 1, pt[1] + 1)
    if ancestor in supp_p:
        ax.annotate('', xy=ancestor, xytext=pt,
                    arrowprops=dict(arrowstyle='->', color='gray', alpha=0.4, lw=1.5))

ax.set_xlabel('x exponent', fontsize=11)
ax.set_ylabel('y exponent', fontsize=11)
ax.set_xlim(-0.5, 5.5)
ax.set_ylim(-0.5, 4.5)
ax.set_aspect('equal')
ax.legend(['', 'supp(p)', 'shadow(0,1)'], fontsize=10)

# Panel 2: Support functions
ax = axes[1]
ax.set_title('Support Functions h_S(w) and h_shadow(w)', fontsize=13, fontweight='bold')

h_S_vals = [support_function(supp_p, d) for d in pos_directions]
h_shadow_vals = [support_function(shadow, d) for d in pos_directions]
shift_vals = [h_S - (d[0] + d[1]) for h_S, d in zip(h_S_vals, pos_directions)]

angle_deg = [a * 180 / math.pi for a in angles]

ax.plot(angle_deg, h_S_vals, '-', color='#2196F3', linewidth=2, label='h_S(w)')
ax.plot(angle_deg, h_shadow_vals, '--', color='#FF9800', linewidth=2, label='h_shadow(w)')
ax.plot(angle_deg, shift_vals, ':', color='#4CAF50', linewidth=2, label='h_S(w) − (w₀+w₁)')

ax.set_xlabel('Direction angle (degrees)', fontsize=11)
ax.set_ylabel('Support function value', fontsize=11)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 3: Difference plot (should be zero for admissible directions)
ax = axes[2]
ax.set_title('Shift Theorem Verification\nh_shadow(w) − [h_S(w) − (w₀+w₁)]',
             fontsize=13, fontweight='bold')

diffs = [h_sh - sh for h_sh, sh in zip(h_shadow_vals, shift_vals)]

# Color by whether shift holds
colors = ['#4CAF50' if abs(d) < 0.01 else '#F44336' for d in diffs]
ax.bar(range(len(diffs)), diffs, color=colors, alpha=0.7, width=1.0)
ax.axhline(y=0, color='black', linewidth=0.5)
ax.set_xlabel('Direction index', fontsize=11)
ax.set_ylabel('Difference', fontsize=11)

n_match = sum(1 for d in diffs if abs(d) < 0.01)
ax.text(0.5, 0.95, f'Exact match: {n_match}/{len(diffs)} directions',
        transform=ax.transAxes, ha='center', va='top', fontsize=11,
        bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

plt.tight_layout()
plt.savefig('viz_support_function.png', dpi=150, bbox_inches='tight')
print("Saved viz_support_function.png")


#!/usr/bin/env python3
"""
Visualization: Support Sets and Mixed Shadows

Visualizes the core theorem: the support of ∂ᵢ∂ⱼp equals the mixed shadow
of supp(p). Shows the original support, the shadow, and the derivative
support as overlaid lattice point plots.

CRITICAL: This script is fully self-contained. No local imports.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import random


def partial_derivative(poly, var_idx, n_vars):
    result = {}
    for exp, coeff in poly.items():
        e = list(exp)
        if e[var_idx] >= 1:
            new_coeff = coeff * e[var_idx]
            e[var_idx] -= 1
            new_exp = tuple(e)
            result[new_exp] = result.get(new_exp, 0) + new_coeff
    return {k: v for k, v in result.items() if abs(v) > 1e-12}


def mixed_partial(poly, i, j, n_vars):
    return partial_derivative(partial_derivative(poly, j, n_vars), i, n_vars)


def mixed_shadow(supp, i, j, n_vars):
    shadow = set()
    for alpha in supp:
        beta = list(alpha)
        beta[i] -= 1
        beta[j] -= 1
        if all(b >= 0 for b in beta):
            shadow.add(tuple(beta))
    return shadow


def convex_hull_2d(points):
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


fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Example 1: Faithful individual partial
poly1 = {(3, 1): 2, (2, 2): -1, (1, 3): 3, (2, 1): 1, (1, 2): -2}
supp1 = set(poly1.keys())
shadow1 = mixed_shadow(supp1, 0, 1, 2)
mp1 = mixed_partial(poly1, 0, 1, 2)
deriv_supp1 = set(mp1.keys())

ax = axes[0]
ax.set_title('Theorem 1: Individual ∂₀∂₁ (Always Faithful)', fontsize=12, fontweight='bold')

# Plot grid
for x in range(5):
    for y in range(5):
        ax.plot(x, y, '.', color='#e0e0e0', markersize=4)

# Original support
for pt in supp1:
    ax.plot(pt[0], pt[1], 's', color='#2196F3', markersize=18, alpha=0.6, zorder=2)

# Shadow (predicted)
for pt in shadow1:
    ax.plot(pt[0], pt[1], 'D', color='#FF9800', markersize=14, alpha=0.7, zorder=3)

# Actual derivative support
for pt in deriv_supp1:
    ax.plot(pt[0], pt[1], 'o', color='#4CAF50', markersize=10, zorder=4)

# Draw arrows from shadow to ancestors
for pt in shadow1:
    ancestor = (pt[0] + 1, pt[1] + 1)
    if ancestor in supp1:
        ax.annotate('', xy=ancestor, xytext=pt,
                    arrowprops=dict(arrowstyle='->', color='gray', alpha=0.5))

ax.set_xlabel('x exponent')
ax.set_ylabel('y exponent')
ax.set_xlim(-0.5, 4.5)
ax.set_ylim(-0.5, 4.5)
ax.set_aspect('equal')
legend_elements = [
    mpatches.Patch(color='#2196F3', alpha=0.6),
    mpatches.Patch(color='#FF9800', alpha=0.7),
    mpatches.Patch(color='#4CAF50'),
]
ax.legend(legend_elements, ['supp(p)', 'Shadow (predicted)', 'supp(∂₀∂₁p) = Shadow ✓'],
          loc='upper right', fontsize=9)

# Example 2: Newton polytope comparison
poly2 = {(4, 0): 1, (3, 1): 2, (2, 2): -1, (1, 3): 1, (0, 4): 3, (2, 1): 1, (1, 2): -1}
supp2 = set(poly2.keys())
shadow2 = mixed_shadow(supp2, 0, 1, 2)

ax = axes[1]
ax.set_title('Newton Polytope: p vs ∂₀∂₁p', fontsize=12, fontweight='bold')

for x in range(5):
    for y in range(5):
        ax.plot(x, y, '.', color='#e0e0e0', markersize=4)

# Hull of original
hull_pts = convex_hull_2d(list(supp2))
if hull_pts:
    hull_closed = hull_pts + [hull_pts[0]]
    ax.fill([p[0] for p in hull_closed], [p[1] for p in hull_closed],
            alpha=0.15, color='#2196F3')
    ax.plot([p[0] for p in hull_closed], [p[1] for p in hull_closed],
            '-', color='#2196F3', linewidth=2, alpha=0.8)

# Hull of shadow
hull_shadow = convex_hull_2d(list(shadow2))
if hull_shadow:
    hull_s_closed = hull_shadow + [hull_shadow[0]]
    ax.fill([p[0] for p in hull_s_closed], [p[1] for p in hull_s_closed],
            alpha=0.15, color='#FF9800')
    ax.plot([p[0] for p in hull_s_closed], [p[1] for p in hull_s_closed],
            '--', color='#FF9800', linewidth=2, alpha=0.8)

for pt in supp2:
    ax.plot(pt[0], pt[1], 's', color='#2196F3', markersize=12, zorder=5)
for pt in shadow2:
    ax.plot(pt[0], pt[1], 'D', color='#FF9800', markersize=10, zorder=5)

ax.set_xlabel('x exponent')
ax.set_ylabel('y exponent')
ax.set_xlim(-0.5, 4.5)
ax.set_ylim(-0.5, 4.5)
ax.set_aspect('equal')
legend_elements2 = [
    mpatches.Patch(color='#2196F3', alpha=0.3),
    mpatches.Patch(color='#FF9800', alpha=0.3),
]
ax.legend(legend_elements2, ['Newt(p)', 'Newt(∂₀∂₁p) = Shadow Polytope'],
          loc='upper right', fontsize=9)

# Example 3: Aggregate with cancellation
poly3 = {(2, 1): 1, (1, 2): 1}
supp3 = set(poly3.keys())

# Antisymmetric: ∂₀∂₁ - ∂₁∂₀ = 0
shadow_01 = mixed_shadow(supp3, 0, 1, 2)
shadow_10 = mixed_shadow(supp3, 1, 0, 2)
agg_shadow = shadow_01 | shadow_10

ax = axes[2]
ax.set_title('Theorem 4: Aggregate Cancellation\n(∂₀∂₁ − ∂₁∂₀ = 0)', fontsize=12, fontweight='bold')

for x in range(4):
    for y in range(4):
        ax.plot(x, y, '.', color='#e0e0e0', markersize=4)

for pt in supp3:
    ax.plot(pt[0], pt[1], 's', color='#2196F3', markersize=18, alpha=0.6, zorder=2)

for pt in agg_shadow:
    ax.plot(pt[0], pt[1], 'D', color='#FF9800', markersize=14, alpha=0.7, zorder=3)
    # Red X to show absence
    ax.plot(pt[0], pt[1], 'x', color='#F44336', markersize=20, markeredgewidth=3, zorder=5)

ax.set_xlabel('x exponent')
ax.set_ylabel('y exponent')
ax.set_xlim(-0.5, 3.5)
ax.set_ylim(-0.5, 3.5)
ax.set_aspect('equal')
legend_elements3 = [
    mpatches.Patch(color='#2196F3', alpha=0.6),
    mpatches.Patch(color='#FF9800', alpha=0.7),
    plt.Line2D([0], [0], marker='x', color='#F44336', linestyle='None',
               markersize=10, markeredgewidth=3),
]
ax.legend(legend_elements3, ['supp(p)', 'Shadow (predicted)', 'Cancelled! (not in supp)'],
          loc='upper right', fontsize=9)

plt.tight_layout()
plt.savefig('viz_support_shadow.png', dpi=150, bbox_inches='tight')
print("Saved viz_support_shadow.png")
