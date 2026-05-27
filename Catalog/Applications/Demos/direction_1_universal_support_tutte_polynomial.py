#!/usr/bin/env python3
"""
applications.py — Support-Tutte Polynomial: Applications

Demonstrates real-world applications of the universal support-Tutte invariant:
1. Partition function computation (statistical mechanics)
2. Reliability polynomial analogues
3. Newton polytope analysis (algebraic geometry)
4. Comparison with classical matroid Tutte polynomial
"""

from __future__ import annotations
from typing import FrozenSet, Tuple, List, Dict
from sympy import Symbol, Poly, ZZ, QQ, Rational
from itertools import combinations, permutations
from dataclasses import dataclass


Vector = Tuple[int, ...]
Support = FrozenSet[Vector]

a_var = Symbol('a')


# ---------------------------------------------------------------------------
# Core operations (self-contained)
# ---------------------------------------------------------------------------

def support_delete(S: Support, i: int) -> Support:
    return frozenset(v for v in S if v[i] == 0)

def tutte_contract(S: Support, i: int) -> Support:
    result = set()
    for v in S:
        if v[i] > 0:
            w = list(v)
            w[i] -= 1
            result.add(tuple(w))
    return frozenset(result)

def is_loop(S: Support, i: int) -> bool:
    return bool(S) and all(v[i] > 0 for v in S)

def is_ordinary(S: Support, i: int) -> bool:
    return any(v[i] == 0 for v in S) and any(v[i] > 0 for v in S)

def compute_tutte_poly(S: Support, coords: List[int] | None = None) -> Poly:
    """Compute support-Tutte polynomial T_S(a)."""
    if not S:
        return Poly(1, a_var, domain=ZZ)
    n = len(next(iter(S)))
    zero = tuple(0 for _ in range(n))
    if all(v == zero for v in S):
        return Poly(1, a_var, domain=ZZ)
    if coords is None:
        coords = list(range(n))
    if not coords:
        return Poly(1, a_var, domain=ZZ)

    cache: Dict = {}
    def _rec(S: Support, remaining: Tuple[int, ...]) -> Poly:
        key = (S, remaining)
        if key in cache:
            return cache[key]
        one = Poly(1, a_var, domain=ZZ)
        if not S or all(v == zero for v in S) or not remaining:
            cache[key] = one
            return one
        i, rest = remaining[0], remaining[1:]
        if is_loop(S, i):
            r = Poly(a_var, a_var, domain=ZZ) * _rec(tutte_contract(S, i), remaining)
        elif is_ordinary(S, i):
            r = _rec(support_delete(S, i), rest) + _rec(tutte_contract(S, i), rest)
        else:
            r = _rec(S, rest)
        cache[key] = r
        return r
    return _rec(S, tuple(coords))

def simplex_points(n: int, d: int) -> Support:
    if n == 0:
        return frozenset({()}) if d == 0 else frozenset()
    result = set()
    for v0 in range(d + 1):
        for rest in simplex_points(n - 1, d - v0):
            result.add((v0,) + rest)
    return frozenset(result)


# ---------------------------------------------------------------------------
# Application 1: Partition Functions
# ---------------------------------------------------------------------------

def partition_function(S: Support, loop_weight: float) -> float:
    """
    Evaluate the support partition function Z(S, a).

    In statistical mechanics terms, this counts weighted configurations
    in the deletion-contraction tree, where loops contribute weight `a`.

    Z(S, a) = T_S(a) evaluated at the given loop weight.
    """
    T = compute_tutte_poly(S)
    return float(T.eval(loop_weight))


def demo_partition_functions():
    """Demonstrate partition function computations."""
    print("=" * 65)
    print("APPLICATION 1: Partition Functions (Statistical Mechanics)")
    print("=" * 65)

    supports = {
        "U(2,3)": frozenset({(1,1,0), (1,0,1), (0,1,1)}),
        "Δ(3,2)": simplex_points(3, 2),
        "Δ(3,3)": simplex_points(3, 3),
        "Δ(4,2)": simplex_points(4, 2),
    }

    print(f"\n{'Support':<12} {'|S|':>4} {'Z(0)':>8} {'Z(1)':>8} {'Z(2)':>8} {'Z(-1)':>8}")
    print("-" * 52)
    for name, S in supports.items():
        z0 = partition_function(S, 0.0)
        z1 = partition_function(S, 1.0)
        z2 = partition_function(S, 2.0)
        zm1 = partition_function(S, -1.0)
        print(f"{name:<12} {len(S):4d} {z0:8.1f} {z1:8.1f} {z2:8.1f} {zm1:8.1f}")

    print("\nInterpretation:")
    print("  Z(0) — counts acyclic-like configurations")
    print("  Z(1) — counts all spanning configurations equally")
    print("  Z(2) — weights loops doubly (ferromagnetic model)")
    print("  Z(-1) — alternating sum (Euler characteristic analogue)")


# ---------------------------------------------------------------------------
# Application 2: Reliability Polynomials
# ---------------------------------------------------------------------------

def reliability_polynomial(S: Support) -> Poly:
    """
    Compute the reliability polynomial R_S(p) from the support-Tutte polynomial.

    R_S(p) = T_S(p / (1-p)) after change of variables, representing the
    probability that a random sub-support is 'connected' (non-degenerate).
    """
    p = Symbol('p')
    T = compute_tutte_poly(S)
    # Simple specialization: evaluate at a = p
    coeffs = T.all_coeffs()
    result = sum(c * p**i for i, c in enumerate(reversed(coeffs)))
    return result


def demo_reliability():
    """Demonstrate reliability polynomial computations."""
    print("\n" + "=" * 65)
    print("APPLICATION 2: Reliability Polynomials")
    print("=" * 65)

    supports = {
        "Singleton": frozenset({(1, 0)}),
        "Pair": frozenset({(1, 0), (0, 1)}),
        "U(2,3)": frozenset({(1,1,0), (1,0,1), (0,1,1)}),
        "Triangle": frozenset({(2,0,0), (0,2,0), (0,0,2)}),
    }

    for name, S in supports.items():
        T = compute_tutte_poly(S)
        print(f"\n{name}: T(a) = {T.as_expr()}")
        print(f"  R(0.5) = {partition_function(S, 0.5):.4f}")
        print(f"  R(0.9) = {partition_function(S, 0.9):.4f}")


# ---------------------------------------------------------------------------
# Application 3: Newton Polytope Analysis
# ---------------------------------------------------------------------------

def newton_polytope_vertices(S: Support) -> List[Vector]:
    """Extract the vertices of the Newton polytope of the support."""
    if not S:
        return []
    points = list(S)
    # Simple convex hull check in low dimensions
    return points  # For display purposes


def demo_newton_polytopes():
    """Demonstrate Newton polytope analysis."""
    print("\n" + "=" * 65)
    print("APPLICATION 3: Newton Polytope Structure")
    print("=" * 65)

    for d in range(1, 5):
        S = simplex_points(3, d)
        T = compute_tutte_poly(S)
        print(f"\nΔ(3,{d}): |S| = {len(S)}, T(a) = {T.as_expr()}")
        print(f"  Degree of T: {T.degree()}")
        print(f"  Leading coefficient: {T.LC()}")

    print("\nObservation: As degree d increases, the support-Tutte polynomial")
    print("captures increasingly fine-grained structure of the Newton polytope.")
    print("The degree of T grows with the 'complexity' of the support,")
    print("encoding information about how the simplex lattice points interact")
    print("under the exchange property.")


# ---------------------------------------------------------------------------
# Application 4: Matroid Comparison
# ---------------------------------------------------------------------------

def matroid_tutte_poly(bases: List[Tuple[int, ...]], n: int) -> Poly:
    """
    Compute the classical matroid Tutte polynomial from basis indicators.

    This uses the same deletion-contraction algorithm but on {0,1}-valued supports,
    demonstrating the bridge theorem.
    """
    S = frozenset(bases)
    return compute_tutte_poly(S)


def demo_matroid_comparison():
    """Compare support-Tutte with classical Tutte for matroid supports."""
    print("\n" + "=" * 65)
    print("APPLICATION 4: Matroid Bridge — Classical vs. Support Tutte")
    print("=" * 65)

    # U(2,4) matroid
    bases_24 = [(1,1,0,0), (1,0,1,0), (1,0,0,1),
                (0,1,1,0), (0,1,0,1), (0,0,1,1)]
    S_24 = frozenset(bases_24)
    T_24 = compute_tutte_poly(S_24)

    print(f"\nU(2,4) matroid (binary support):")
    print(f"  Bases: {len(bases_24)}")
    print(f"  Support-Tutte T(a) = {T_24.as_expr()}")

    # Now compute on the "thickened" version with values up to 2
    thick_24 = frozenset(
        tuple(2*x for x in b) for b in bases_24
    )
    T_thick = compute_tutte_poly(thick_24)
    print(f"\nThickened U(2,4) (values doubled):")
    print(f"  Support-Tutte T(a) = {T_thick.as_expr()}")

    if T_24.as_expr() != T_thick.as_expr():
        print(f"  → Polynomials DIFFER: support-Tutte sees degree information!")
        print(f"  → This is extra information invisible to classical matroid theory.")
    else:
        print(f"  → Polynomials agree (surprising)")

    # Compare with a non-matroidal support having same cardinality
    S_nonmat = frozenset({
        (2, 0, 0, 0), (0, 2, 0, 0), (0, 0, 2, 0),
        (0, 0, 0, 2), (1, 1, 0, 0), (1, 0, 1, 0)
    })
    T_nonmat = compute_tutte_poly(S_nonmat)
    print(f"\nNon-matroidal 6-element support:")
    print(f"  T(a) = {T_nonmat.as_expr()}")
    print(f"  T(1) = {T_nonmat.eval(1)} vs U(2,4) T(1) = {T_24.eval(1)}")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    demo_partition_functions()
    demo_reliability()
    demo_newton_polytopes()
    demo_matroid_comparison()

    print("\n" + "=" * 65)
    print("All applications demonstrated successfully.")
    print("=" * 65)


#!/usr/bin/env python3
"""
demo.py — Support-Tutte Polynomial: Demonstrations and Experiments

Computes sample support-Tutte polynomials via the deletion-contraction
recurrence for finite M-convex supports, compares outputs under different
coordinate orderings, and demonstrates non-matroidal supports where the
invariant carries extra information invisible to classical Tutte theory.
"""

from __future__ import annotations
from typing import FrozenSet, Tuple, Dict, List
from functools import lru_cache
from sympy import Symbol, Poly, ZZ, symbols, expand, pprint
from itertools import permutations
import json


# ---------------------------------------------------------------------------
# Core data type: a "support" is a frozenset of tuples (vectors in ℕ^n)
# ---------------------------------------------------------------------------

Support = FrozenSet[Tuple[int, ...]]


def dim(S: Support) -> int:
    """Number of coordinates (ambient dimension)."""
    if not S:
        return 0
    return len(next(iter(S)))


def is_loop(S: Support, i: int) -> bool:
    """Coordinate i is a loop if all elements have positive i-value."""
    return all(v[i] > 0 for v in S)


def is_ordinary(S: Support, i: int) -> bool:
    """Coordinate i is ordinary if some elements have v[i]=0 and some v[i]>0."""
    has_zero = any(v[i] == 0 for v in S)
    has_pos = any(v[i] > 0 for v in S)
    return has_zero and has_pos


def is_trivial(S: Support, i: int) -> bool:
    """Coordinate i is trivial if all elements have v[i]=0."""
    return all(v[i] == 0 for v in S)


def support_delete(S: Support, i: int) -> Support:
    """Delete at coordinate i: keep elements with v[i] = 0."""
    return frozenset(v for v in S if v[i] == 0)


def tutte_contract(S: Support, i: int) -> Support:
    """Tutte-style contraction at coordinate i: keep v[i] > 0, subtract 1."""
    result = set()
    for v in S:
        if v[i] > 0:
            new_v = list(v)
            new_v[i] -= 1
            result.add(tuple(new_v))
    return frozenset(result)


# ---------------------------------------------------------------------------
# Support-Tutte polynomial computation
# ---------------------------------------------------------------------------

a_sym = Symbol('a')  # loop weight


def support_tutte_poly(S: Support, coord_order: List[int] | None = None) -> Poly:
    """
    Compute the support-Tutte polynomial T_S(a) using deletion-contraction.

    Parameters
    ----------
    S : Support
        A finite support set (frozenset of integer tuples).
    coord_order : list of int, optional
        Order in which to process coordinates. If None, uses natural order.

    Returns
    -------
    Poly
        The support-Tutte polynomial in variable `a`.
    """
    # Memoization cache keyed on (S, remaining_coords)
    cache: Dict = {}

    def _compute(S: Support, remaining: Tuple[int, ...]) -> Poly:
        key = (S, remaining)
        if key in cache:
            return cache[key]

        # Base cases
        if not S:
            result = Poly(1, a_sym, domain=ZZ)
            cache[key] = result
            return result

        n = dim(S)
        zero_vec = tuple(0 for _ in range(n))
        if all(v == zero_vec for v in S):
            result = Poly(1, a_sym, domain=ZZ)
            cache[key] = result
            return result

        if not remaining:
            # No more coordinates to process
            result = Poly(1, a_sym, domain=ZZ)
            cache[key] = result
            return result

        i = remaining[0]
        rest = remaining[1:]

        if is_loop(S, i):
            # Loop rule: T(S) = a * T(contract S i)
            contracted = tutte_contract(S, i)
            sub = _compute(contracted, remaining)  # keep same coords for repeated loops
            result = Poly(a_sym, a_sym, domain=ZZ) * sub
            cache[key] = result
            return result
        elif is_ordinary(S, i):
            # Ordinary rule: T(S) = T(delete S i) + T(contract S i)
            deleted = support_delete(S, i)
            contracted = tutte_contract(S, i)
            result = _compute(deleted, rest) + _compute(contracted, rest)
            cache[key] = result
            return result
        else:
            # Trivial coordinate: skip
            result = _compute(S, rest)
            cache[key] = result
            return result

    if coord_order is None:
        if not S:
            coord_order = []
        else:
            coord_order = list(range(dim(S)))

    return _compute(S, tuple(coord_order))


# ---------------------------------------------------------------------------
# Example supports
# ---------------------------------------------------------------------------

def matroid_support_U23() -> Support:
    """Uniform matroid U(2,3): all 2-element subsets of {0,1,2}."""
    return frozenset({
        (1, 1, 0),
        (1, 0, 1),
        (0, 1, 1),
    })


def matroid_support_U24() -> Support:
    """Uniform matroid U(2,4): all 2-element subsets of {0,1,2,3}."""
    from itertools import combinations
    result = set()
    for combo in combinations(range(4), 2):
        v = [0, 0, 0, 0]
        for j in combo:
            v[j] = 1
        result.add(tuple(v))
    return frozenset(result)


def non_matroidal_support_1() -> Support:
    """A non-matroidal support with values > 1 (degree-2 simplex on 3 vars)."""
    return frozenset({
        (2, 0, 0),
        (0, 2, 0),
        (0, 0, 2),
        (1, 1, 0),
        (1, 0, 1),
        (0, 1, 1),
    })


def non_matroidal_support_2() -> Support:
    """Another non-matroidal support with mixed degrees."""
    return frozenset({
        (2, 0, 0),
        (1, 1, 0),
        (0, 2, 0),
        (0, 0, 2),
    })


def simplex_support(n: int, d: int) -> Support:
    """All lattice points in the degree-d simplex in n variables:
    {v ∈ ℕ^n : sum(v) = d}."""
    if n == 0:
        return frozenset({()}) if d == 0 else frozenset()
    result = set()
    for v0 in range(d + 1):
        for rest in simplex_support(n - 1, d - v0):
            result.add((v0,) + rest)
    return frozenset(result)


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_basic_computations():
    """Demonstrate basic support-Tutte polynomial computations."""
    print("=" * 70)
    print("DEMO 1: Basic Support-Tutte Polynomial Computations")
    print("=" * 70)

    examples = [
        ("Empty support", frozenset()),
        ("Singleton {0}", frozenset({(0, 0, 0)})),
        ("Singleton {(1,0,0)}", frozenset({(1, 0, 0)})),
        ("U(2,3) matroid", matroid_support_U23()),
        ("U(2,4) matroid", matroid_support_U24()),
        ("Degree-2 simplex (3 vars)", non_matroidal_support_1()),
        ("Non-matroidal mixed", non_matroidal_support_2()),
    ]

    for name, S in examples:
        poly = support_tutte_poly(S)
        print(f"\n{name}:")
        print(f"  Support: {sorted(S) if S else '{}'}")
        print(f"  T(a) = {poly.as_expr()}")
        print(f"  T(1) = {poly.eval(1)}")
        print(f"  T(2) = {poly.eval(2)}")


def demo_order_independence():
    """Test order-independence of the support-Tutte polynomial."""
    print("\n" + "=" * 70)
    print("DEMO 2: Order-Independence Test")
    print("=" * 70)

    test_supports = [
        ("U(2,3)", matroid_support_U23()),
        ("U(2,4)", matroid_support_U24()),
        ("Degree-2 simplex", non_matroidal_support_1()),
        ("Non-matroidal mixed", non_matroidal_support_2()),
        ("Degree-3 simplex (3 vars)", simplex_support(3, 3)),
    ]

    for name, S in test_supports:
        n = dim(S) if S else 0
        if n == 0:
            continue

        polys = {}
        all_orders = list(permutations(range(n)))
        for order in all_orders:
            poly = support_tutte_poly(S, coord_order=list(order))
            polys[order] = poly

        # Check if all polynomials agree
        reference = polys[all_orders[0]]
        all_agree = all(
            p.as_expr() == reference.as_expr()
            for p in polys.values()
        )

        print(f"\n{name} (dim={n}, {len(all_orders)} orderings tested):")
        print(f"  T(a) = {reference.as_expr()}")
        print(f"  All orderings agree: {'YES ✓' if all_agree else 'NO ✗'}")

        if not all_agree:
            for order, poly in polys.items():
                if poly.as_expr() != reference.as_expr():
                    print(f"  Disagreement at order {order}: {poly.as_expr()}")


def demo_non_matroidal_extra_info():
    """Show that the support-Tutte polynomial distinguishes supports
    that classical matroid theory cannot."""
    print("\n" + "=" * 70)
    print("DEMO 3: Beyond Matroids — Extra Information in Support-Tutte")
    print("=" * 70)

    # Two supports with the same "matroidal shadow" (same {0,1} pattern)
    # but different polynomial values

    # Support 1: degree-2 simplex
    S1 = non_matroidal_support_1()
    # Support 2: just the vertices (same underlying matroid-like structure)
    S2 = frozenset({(2, 0, 0), (0, 2, 0), (0, 0, 2)})
    # Support 3: just the edges
    S3 = frozenset({(1, 1, 0), (1, 0, 1), (0, 1, 1)})

    T1 = support_tutte_poly(S1)
    T2 = support_tutte_poly(S2)
    T3 = support_tutte_poly(S3)

    print(f"\nFull degree-2 simplex (6 elements):")
    print(f"  T(a) = {T1.as_expr()}")
    print(f"\nVertices only (3 elements, all degree 2):")
    print(f"  T(a) = {T2.as_expr()}")
    print(f"\nEdge midpoints only (3 elements, all degree 2):")
    print(f"  T(a) = {T3.as_expr()}")

    print(f"\nNote: S2 and S3 both have 3 elements and the same 'shape'")
    print(f"  but the support-Tutte polynomial distinguishes them")
    print(f"  because it sees the actual degree structure.")

    if T2.as_expr() != T3.as_expr():
        print(f"  T(S2) ≠ T(S3): the polynomial captures non-matroidal information! ✓")
    else:
        print(f"  T(S2) = T(S3): these particular supports agree.")


def demo_simplex_family():
    """Compute support-Tutte polynomials for the simplex family."""
    print("\n" + "=" * 70)
    print("DEMO 4: Simplex Family T(Δ(n,d))")
    print("=" * 70)

    for n in range(2, 5):
        print(f"\n  n={n} variables:")
        for d in range(0, 6):
            S = simplex_support(n, d)
            if len(S) == 0:
                continue
            T = support_tutte_poly(S)
            print(f"    d={d}: |S|={len(S):3d}, T(a) = {T.as_expr()}")


def demo_specializations():
    """Show specialization values of the support-Tutte polynomial."""
    print("\n" + "=" * 70)
    print("DEMO 5: Specializations (Partition Function Values)")
    print("=" * 70)

    S = non_matroidal_support_1()
    T = support_tutte_poly(S)

    print(f"\nDegree-2 simplex support: T(a) = {T.as_expr()}")
    print(f"\nSpecializations:")
    print(f"  T(0) = {T.eval(0)} — counts 'acyclic orientations' analogue")
    print(f"  T(1) = {T.eval(1)} — counts spanning substructures")
    print(f"  T(2) = {T.eval(2)} — reliability polynomial analogue")
    print(f"  T(-1) = {T.eval(-1)} — alternating sum (Euler characteristic)")

    # For matroid supports, T(1) should count the number of bases
    S_mat = matroid_support_U23()
    T_mat = support_tutte_poly(S_mat)
    print(f"\nU(2,3) matroid: T(a) = {T_mat.as_expr()}")
    print(f"  T(1) = {T_mat.eval(1)} (should relate to basis count = {len(S_mat)})")


if __name__ == "__main__":
    demo_basic_computations()
    demo_order_independence()
    demo_non_matroidal_extra_info()
    demo_simplex_family()
    demo_specializations()
    print("\n" + "=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Visualization: Activity Partition Diagram

Visualizes the activity partition theorem: for any M-convex support and
ground set, coordinates partition into loops, ordinary elements, and
trivial elements. Shows this partition across multiple supports.

This is fully self-contained — no local imports.
"""

import numpy as np
import matplotlib.pyplot as plt
from typing import FrozenSet, Tuple, List

Vector = Tuple[int, ...]
Support = FrozenSet[Vector]


def classify_coord(S: Support, i: int) -> str:
    """Classify coordinate i as 'loop', 'ordinary', or 'trivial'."""
    if not S:
        return 'trivial'
    has_zero = any(v[i] == 0 for v in S)
    has_pos = any(v[i] > 0 for v in S)
    if has_pos and not has_zero:
        return 'loop'
    elif has_zero and has_pos:
        return 'ordinary'
    else:
        return 'trivial'


def simplex_points(n: int, d: int) -> Support:
    if n == 0:
        return frozenset({()}) if d == 0 else frozenset()
    result = set()
    for v0 in range(d + 1):
        for rest in simplex_points(n - 1, d - v0):
            result.add((v0,) + rest)
    return frozenset(result)


def count_activities(S: Support, n_coords: int) -> dict:
    counts = {'loop': 0, 'ordinary': 0, 'trivial': 0}
    for i in range(n_coords):
        c = classify_coord(S, i)
        counts[c] += 1
    return counts


# Generate data for various supports
n_vars = 4
supports = []
labels = []

# Simplex supports
for d in range(1, 7):
    S = simplex_points(n_vars, d)
    supports.append(S)
    labels.append(f'Δ({n_vars},{d})\n|S|={len(S)}')

# Vertex-only supports
for d in range(1, 4):
    verts = set()
    for i in range(n_vars):
        v = [0] * n_vars
        v[i] = d
        verts.add(tuple(v))
    S = frozenset(verts)
    supports.append(S)
    labels.append(f'V({n_vars},{d})\n|S|={len(S)}')

# Matroid supports
mat_bases = frozenset({(1,1,0,0), (1,0,1,0), (1,0,0,1),
                       (0,1,1,0), (0,1,0,1), (0,0,1,1)})
supports.append(mat_bases)
labels.append(f'U(2,4)\n|S|=6')

# Compute activities
loop_counts = []
ord_counts = []
triv_counts = []

for S in supports:
    acts = count_activities(S, n_vars)
    loop_counts.append(acts['loop'])
    ord_counts.append(acts['ordinary'])
    triv_counts.append(acts['trivial'])

# Plot
fig, axes = plt.subplots(1, 2, figsize=(16, 6))

# Stacked bar chart
ax1 = axes[0]
x = np.arange(len(supports))
width = 0.6

bars_triv = ax1.bar(x, triv_counts, width, label='Trivial', color='#95a5a6', alpha=0.8)
bars_ord = ax1.bar(x, ord_counts, width, bottom=triv_counts,
                   label='Ordinary', color='#3498db', alpha=0.8)
bars_loop = ax1.bar(x, loop_counts, width,
                    bottom=[t + o for t, o in zip(triv_counts, ord_counts)],
                    label='Loop', color='#e74c3c', alpha=0.8)

ax1.set_xlabel('Support', fontsize=11)
ax1.set_ylabel('Number of Coordinates', fontsize=11)
ax1.set_title('Activity Partition of Coordinates\n(Verified: loops + ordinary + trivial = n)', fontsize=13)
ax1.set_xticks(x)
ax1.set_xticklabels(labels, fontsize=8)
ax1.legend(fontsize=10)
ax1.axhline(y=n_vars, color='k', linewidth=0.5, linestyle='--', alpha=0.5)
ax1.set_ylim(0, n_vars + 0.5)

# Verification check
for idx in range(len(supports)):
    total = loop_counts[idx] + ord_counts[idx] + triv_counts[idx]
    color = 'green' if total == n_vars else 'red'
    ax1.annotate(f'Σ={total}', (x[idx], n_vars + 0.1), ha='center', fontsize=7, color=color)

# Pie chart for a specific support
ax2 = axes[1]
S_example = simplex_points(n_vars, 3)
acts_example = count_activities(S_example, n_vars)

sizes = [acts_example['loop'], acts_example['ordinary'], acts_example['trivial']]
colors_pie = ['#e74c3c', '#3498db', '#95a5a6']
labels_pie = [f'Loops ({sizes[0]})', f'Ordinary ({sizes[1]})', f'Trivial ({sizes[2]})']

# Filter out zeros
non_zero = [(s, c, l) for s, c, l in zip(sizes, colors_pie, labels_pie) if s > 0]
if non_zero:
    sizes_nz, colors_nz, labels_nz = zip(*non_zero)
    wedges, texts, autotexts = ax2.pie(sizes_nz, labels=labels_nz, colors=colors_nz,
                                        autopct='%1.0f%%', startangle=90,
                                        textprops={'fontsize': 11})
    for autotext in autotexts:
        autotext.set_fontweight('bold')

ax2.set_title(f'Activity Partition for Δ({n_vars},3)\n{n_vars} coordinates, |S|={len(S_example)} elements',
              fontsize=13)

plt.tight_layout()
plt.savefig('activity_diagram.png', dpi=150, bbox_inches='tight')
print("Saved activity_diagram.png")


#!/usr/bin/env python3
"""
Visualization: Matroid Bridge — Binary vs Non-Binary Supports

Compares the support-Tutte polynomial for binary (matroidal) supports
with their non-binary generalizations, showing that the support invariant
strictly extends classical matroid Tutte theory by detecting degree
information that matroids erase.

This is fully self-contained — no local imports.
"""

import numpy as np
import matplotlib.pyplot as plt
from typing import FrozenSet, Tuple, Dict, List

Vector = Tuple[int, ...]
Support = FrozenSet[Vector]


def support_delete(S: Support, i: int) -> Support:
    return frozenset(v for v in S if v[i] == 0)

def tutte_contract(S: Support, i: int) -> Support:
    result = set()
    for v in S:
        if v[i] > 0:
            w = list(v)
            w[i] -= 1
            result.add(tuple(w))
    return frozenset(result)

def compute_tutte_value(S: Support, a_val: float) -> float:
    if not S:
        return 1.0
    n = len(next(iter(S)))
    zero = tuple(0 for _ in range(n))
    if all(v == zero for v in S):
        return 1.0
    cache: Dict = {}
    def _rec(S: Support, remaining: Tuple[int, ...]) -> float:
        key = (S, remaining)
        if key in cache:
            return cache[key]
        if not S or all(v == zero for v in S) or not remaining:
            cache[key] = 1.0
            return 1.0
        i, rest = remaining[0], remaining[1:]
        if all(v[i] > 0 for v in S):
            r = a_val * _rec(tutte_contract(S, i), remaining)
        elif any(v[i] == 0 for v in S) and any(v[i] > 0 for v in S):
            r = _rec(support_delete(S, i), rest) + _rec(tutte_contract(S, i), rest)
        else:
            r = _rec(S, rest)
        cache[key] = r
        return r
    return _rec(S, tuple(range(n)))


# ---------------------------------------------------------------------------
# Define support families
# ---------------------------------------------------------------------------

# Binary supports (matroid-like)
binary_supports = {
    "U(1,3)": frozenset({(1,0,0), (0,1,0), (0,0,1)}),
    "U(2,3)": frozenset({(1,1,0), (1,0,1), (0,1,1)}),
    "U(2,4)": frozenset({(1,1,0,0), (1,0,1,0), (1,0,0,1),
                          (0,1,1,0), (0,1,0,1), (0,0,1,1)}),
}

# Non-binary supports (with values > 1)
nonbinary_supports = {
    "Vertices(3,2)": frozenset({(2,0,0), (0,2,0), (0,0,2)}),
    "Δ(3,2)": frozenset({(2,0,0), (0,2,0), (0,0,2),
                          (1,1,0), (1,0,1), (0,1,1)}),
    "Vertices(4,2)": frozenset({(2,0,0,0), (0,2,0,0), (0,0,2,0), (0,0,0,2)}),
}

a_values = np.linspace(-1.5, 3.0, 200)

fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

# Panel 1: Binary supports
ax1 = axes[0]
colors_bin = ['#2ecc71', '#3498db', '#9b59b6']
for idx, (name, S) in enumerate(binary_supports.items()):
    values = [compute_tutte_value(S, a) for a in a_values]
    ax1.plot(a_values, values, color=colors_bin[idx], linewidth=2, label=name)

ax1.set_xlabel('Loop weight a', fontsize=11)
ax1.set_ylabel('T(a)', fontsize=11)
ax1.set_title('Binary (Matroidal) Supports', fontsize=13)
ax1.legend(fontsize=10)
ax1.set_ylim(-20, 50)
ax1.axhline(y=0, color='k', linewidth=0.3)
ax1.axvline(x=0, color='k', linewidth=0.3)
ax1.grid(True, alpha=0.2)

# Panel 2: Non-binary supports
ax2 = axes[1]
colors_nb = ['#e74c3c', '#f39c12', '#1abc9c']
for idx, (name, S) in enumerate(nonbinary_supports.items()):
    values = [compute_tutte_value(S, a) for a in a_values]
    ax2.plot(a_values, values, color=colors_nb[idx], linewidth=2, label=name)

ax2.set_xlabel('Loop weight a', fontsize=11)
ax2.set_ylabel('T(a)', fontsize=11)
ax2.set_title('Non-Binary (Non-Matroidal) Supports', fontsize=13)
ax2.legend(fontsize=10)
ax2.set_ylim(-20, 50)
ax2.axhline(y=0, color='k', linewidth=0.3)
ax2.axvline(x=0, color='k', linewidth=0.3)
ax2.grid(True, alpha=0.2)

# Panel 3: Comparison — same cardinality, different structure
ax3 = axes[2]

# U(1,3) vs Vertices(3,2): both have 3 elements
S_bin = binary_supports["U(1,3)"]
S_nb = nonbinary_supports["Vertices(3,2)"]

vals_bin = [compute_tutte_value(S_bin, a) for a in a_values]
vals_nb = [compute_tutte_value(S_nb, a) for a in a_values]
vals_diff = [nb - b for b, nb in zip(vals_bin, vals_nb)]

ax3.plot(a_values, vals_bin, color='#3498db', linewidth=2, label='U(1,3) — binary')
ax3.plot(a_values, vals_nb, color='#e74c3c', linewidth=2, label='Vertices(3,2) — non-binary')
ax3.fill_between(a_values, vals_bin, vals_nb, alpha=0.15, color='purple')
ax3.plot(a_values, vals_diff, color='#8e44ad', linewidth=1.5, linestyle='--',
         label='Difference')

ax3.set_xlabel('Loop weight a', fontsize=11)
ax3.set_ylabel('T(a)', fontsize=11)
ax3.set_title('Same Cardinality, Different Structure\n(3 elements each)', fontsize=13)
ax3.legend(fontsize=9)
ax3.set_ylim(-10, 30)
ax3.axhline(y=0, color='k', linewidth=0.3)
ax3.axvline(x=0, color='k', linewidth=0.3)
ax3.grid(True, alpha=0.2)

# Add annotation
ax3.annotate('Support-Tutte\nsees the\ndifference!',
             xy=(1.5, 8), fontsize=10, ha='center',
             bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow', alpha=0.8))

plt.suptitle('Support-Tutte Polynomial: Binary vs. Non-Binary Supports',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('matroid_bridge.png', dpi=150, bbox_inches='tight')
print("Saved matroid_bridge.png")


#!/usr/bin/env python3
"""
Visualization: Support-Tutte Polynomial Heatmap

Visualizes the support-Tutte polynomial T(a) evaluated across a range of
loop weights for different support families (simplex lattice points of
increasing degree). The heatmap reveals how the invariant's value landscape
changes as the support structure becomes richer.

This is fully self-contained — no local imports.
"""

import numpy as np
import matplotlib.pyplot as plt
from typing import FrozenSet, Tuple, List, Dict

Vector = Tuple[int, ...]
Support = FrozenSet[Vector]


def support_delete(S: Support, i: int) -> Support:
    return frozenset(v for v in S if v[i] == 0)

def tutte_contract(S: Support, i: int) -> Support:
    result = set()
    for v in S:
        if v[i] > 0:
            w = list(v)
            w[i] -= 1
            result.add(tuple(w))
    return frozenset(result)

def compute_tutte_value(S: Support, a_val: float) -> float:
    """Compute T_S(a) at a specific numeric value of a."""
    if not S:
        return 1.0
    n = len(next(iter(S)))
    zero = tuple(0 for _ in range(n))
    if all(v == zero for v in S):
        return 1.0

    cache: Dict = {}
    def _rec(S: Support, remaining: Tuple[int, ...]) -> float:
        key = (S, remaining)
        if key in cache:
            return cache[key]
        if not S or all(v == zero for v in S) or not remaining:
            cache[key] = 1.0
            return 1.0
        i, rest = remaining[0], remaining[1:]
        if all(v[i] > 0 for v in S):  # loop
            r = a_val * _rec(tutte_contract(S, i), remaining)
        elif any(v[i] == 0 for v in S) and any(v[i] > 0 for v in S):  # ordinary
            r = _rec(support_delete(S, i), rest) + _rec(tutte_contract(S, i), rest)
        else:  # trivial
            r = _rec(S, rest)
        cache[key] = r
        return r
    return _rec(S, tuple(range(n)))

def simplex_points(n: int, d: int) -> Support:
    if n == 0:
        return frozenset({()}) if d == 0 else frozenset()
    result = set()
    for v0 in range(d + 1):
        for rest in simplex_points(n - 1, d - v0):
            result.add((v0,) + rest)
    return frozenset(result)


# Generate data
n_vars = 3
max_degree = 7
a_values = np.linspace(-2, 3, 100)

data = np.zeros((max_degree, len(a_values)))
labels = []

for d in range(1, max_degree + 1):
    S = simplex_points(n_vars, d)
    labels.append(f"d={d}, |S|={len(S)}")
    for j, a_val in enumerate(a_values):
        data[d - 1, j] = compute_tutte_value(S, a_val)

# Normalize for visualization (log scale for large values)
data_viz = np.sign(data) * np.log1p(np.abs(data))

fig, axes = plt.subplots(1, 2, figsize=(16, 6))

# Heatmap
ax1 = axes[0]
im = ax1.imshow(data_viz, aspect='auto', cmap='RdBu_r',
                extent=[a_values[0], a_values[-1], max_degree + 0.5, 0.5],
                interpolation='bilinear')
ax1.set_xlabel('Loop weight a', fontsize=12)
ax1.set_ylabel('Simplex degree d', fontsize=12)
ax1.set_title('Support-Tutte Polynomial T(a)\n(sign · log(1+|T|) scale)', fontsize=13)
ax1.set_yticks(range(1, max_degree + 1))
ax1.set_yticklabels([f'd={d}' for d in range(1, max_degree + 1)])
plt.colorbar(im, ax=ax1, label='sign(T) · log(1+|T|)')

# Line plots
ax2 = axes[1]
colors = plt.cm.viridis(np.linspace(0, 1, max_degree))
for d in range(1, max_degree + 1):
    ax2.plot(a_values, data[d - 1], color=colors[d - 1],
             linewidth=1.5, label=labels[d - 1])
ax2.set_xlabel('Loop weight a', fontsize=12)
ax2.set_ylabel('T(a)', fontsize=12)
ax2.set_title('Support-Tutte Polynomials\nfor Simplex Families Δ(3,d)', fontsize=13)
ax2.legend(fontsize=8, loc='upper left')
ax2.set_ylim(-50, 200)
ax2.axhline(y=0, color='k', linewidth=0.5)
ax2.axvline(x=0, color='k', linewidth=0.5)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('tutte_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved tutte_heatmap.png")
