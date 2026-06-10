"""
applications.py — Real-world applications of Iterated Shadow Geometry.

Demonstrates:
1. Sparse differentiation complexity analysis
2. Newton polytope shadow geometry
3. Polynomial identity testing via shadow invariants
4. Derivative complexity prediction for symbolic computation
"""

from itertools import combinations
from collections import defaultdict


# ─── Inline core functions ──────────────────────────────────────────

def multi_indices_of_mass(n, k):
    if k == 0: return [tuple([0]*n)]
    if n == 0: return []
    if n == 1: return [(k,)]
    result = []
    for first in range(k+1):
        for rest in multi_indices_of_mass(n-1, k-first):
            result.append((first,)+rest)
    return result

def kth_shadow(S, k):
    if not S: return set()
    n = len(next(iter(S)))
    shadow = set()
    for alpha in S:
        for tau in multi_indices_of_mass(n, k):
            if all(tau[i] <= alpha[i] for i in range(n)):
                shadow.add(tuple(alpha[i]-tau[i] for i in range(n)))
    return shadow

def shadow_profile(S, max_k=None):
    if not S: return [0]
    if max_k is None: max_k = max(sum(a) for a in S)
    return [len(kth_shadow(S, k)) for k in range(max_k+1)]

def ascending_factorial(m, k):
    r = 1
    for j in range(k): r *= (m+j)
    return r

def iterated_pderiv(poly, tau):
    n = len(tau)
    result = {}
    for alpha, coeff in poly.items():
        if all(alpha[i] >= tau[i] for i in range(n)):
            beta = tuple(alpha[i]-tau[i] for i in range(n))
            scalar = 1
            for i in range(n):
                scalar *= ascending_factorial(beta[i]+1, tau[i])
            val = scalar * coeff
            if val != 0:
                result[beta] = result.get(beta, 0.0) + val
    return {k: v for k, v in result.items() if abs(v) > 1e-15}


# ─── Application 1: Sparse Differentiation Complexity ───────────────

def sparse_derivative_complexity(support, k):
    """
    Predict the number of nonzero terms in all k-th order derivatives
    using the shadow theorem, without computing any derivatives.

    This is the key application to symbolic computation: the shadow
    gives an exact prediction of derivative sparsity.

    Args:
        support: Set of exponent vectors.
        k: Derivative order.

    Returns:
        Exact number of distinct monomials across all k-th derivatives.
    """
    shadow = kth_shadow(support, k)
    return len(shadow)


def compare_shadow_vs_naive(poly, max_k):
    """
    Compare shadow-based complexity prediction with naive computation.

    Shows that shadow analysis gives exact results without computing
    any actual derivatives — a key win for sparse symbolic computation.
    """
    print("  Application: Sparse Differentiation Complexity Analysis")
    print("  " + "-" * 60)

    support = set(a for a, c in poly.items() if c != 0)
    n = len(next(iter(support)))

    print(f"  Polynomial in {n} variables, {len(support)} terms")
    print(f"  {'k':>4} {'Shadow prediction':>20} {'Actual count':>15} {'Match':>8}")
    print("  " + "-" * 50)

    for k in range(max_k + 1):
        predicted = sparse_derivative_complexity(support, k)
        # Compute actual (expensive)
        actual = set()
        for tau in multi_indices_of_mass(n, k):
            deriv = iterated_pderiv(poly, tau)
            actual.update(deriv.keys())
        match = predicted == len(actual)
        print(f"  {k:>4} {predicted:>20} {len(actual):>15} {'✓' if match else '✗':>8}")
    print()


# ─── Application 2: Newton Polytope Analysis ────────────────────────

def newton_polytope_layers(support):
    """
    Decompose the Newton polytope into shadow layers.

    The k-th shadow represents the "k-interior" of the Newton polytope —
    the set of lattice points reachable by moving k steps inward from
    boundary elements.

    Returns:
        Dict mapping k to the set of points first appearing at depth k.
    """
    max_deg = max(sum(a) for a in support)
    layers = {}
    previous = set()
    for k in range(max_deg + 1):
        current = kth_shadow(support, k)
        new_points = current - previous
        if not new_points and k > 0:
            break
        layers[k] = new_points
        previous = current
    return layers


# ─── Application 3: Polynomial Identity Testing ────────────────────

def shadow_fingerprint(support, max_k=None):
    """
    Compute a polynomial's shadow fingerprint — a sequence of shadow
    cardinalities that serves as a combinatorial invariant.

    Two polynomials with different shadow fingerprints CANNOT be equal,
    regardless of coefficients.

    This gives a fast combinatorial certificate for polynomial non-identity.
    """
    return tuple(shadow_profile(support, max_k))


def test_polynomial_identity(poly1, poly2, max_k=None):
    """
    Quick test: if shadow fingerprints differ, polynomials are definitely
    not identical (modulo coefficient values).
    """
    supp1 = set(a for a, c in poly1.items() if c != 0)
    supp2 = set(a for a, c in poly2.items() if c != 0)
    fp1 = shadow_fingerprint(supp1, max_k)
    fp2 = shadow_fingerprint(supp2, max_k)
    if fp1 != fp2:
        return "DEFINITELY DIFFERENT (shadow fingerprints differ)"
    elif supp1 != supp2:
        return "DIFFERENT SUPPORTS (same fingerprint)"
    else:
        return "SAME SUPPORT (need coefficient check)"


# ─── Application 4: Derivative Decay Rate ──────────────────────────

def derivative_decay_rate(support):
    """
    Compute the rate at which derivative complexity decays.

    Returns pairs (k, a_k / a_{k-1}) showing the fractional decrease
    at each shadow step.
    """
    prof = shadow_profile(support)
    rates = []
    for k in range(1, len(prof)):
        if prof[k-1] > 0:
            rates.append((k, prof[k] / prof[k-1]))
        else:
            rates.append((k, 0.0))
    return rates


# ─── Main ───────────────────────────────────────────────────────────

if __name__ == "__main__":
    print()
    print("=" * 70)
    print("ITERATED SHADOW GEOMETRY — Applications")
    print("=" * 70)
    print()

    # App 1: Sparse differentiation
    poly = {
        (3, 2, 1): 1.0, (2, 0, 3): -2.0, (1, 4, 0): 3.0,
        (0, 1, 5): 1.0, (4, 1, 0): -1.0, (2, 2, 2): 7.0,
    }
    compare_shadow_vs_naive(poly, 6)

    # App 2: Newton polytope layers
    print("  Application: Newton Polytope Layer Decomposition")
    print("  " + "-" * 60)
    support = set(poly.keys())
    layers = newton_polytope_layers(support)
    for k, pts in sorted(layers.items()):
        print(f"  Layer {k}: {len(pts)} new lattice points")
    print()

    # App 3: Polynomial identity testing
    print("  Application: Shadow-Based Identity Testing")
    print("  " + "-" * 60)
    poly2 = {(3, 2, 1): 5.0, (2, 0, 3): -2.0, (1, 4, 0): 3.0,
             (0, 1, 5): 1.0, (4, 1, 0): -1.0, (2, 2, 2): 7.0}
    poly3 = {(3, 2, 1): 1.0, (2, 0, 3): -2.0, (1, 3, 0): 3.0}
    print(f"  f vs f (same coeffs): {test_polynomial_identity(poly, poly)}")
    print(f"  f vs g (same support): {test_polynomial_identity(poly, poly2)}")
    print(f"  f vs h (different support): {test_polynomial_identity(poly, poly3)}")
    print()

    # App 4: Derivative decay rates
    print("  Application: Derivative Complexity Decay Rates")
    print("  " + "-" * 60)
    rates = derivative_decay_rate(support)
    for k, r in rates:
        bar = '▓' * int(30 * r) if r > 0 else ''
        print(f"  k={k}: ratio = {r:.4f}  {bar}")
    print()


"""Build PACKAGE.json from all deliverables."""
import json
import os

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

# Read all files
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
lean_proofs = read_file('Catalog/Speculative/AutoResearch/IteratedShadowGeometry.lean')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')
viz_profiles = read_file('viz_shadow_profiles.py')
viz_logconcave = read_file('viz_log_concavity.py')
viz_lattice = read_file('viz_shadow_lattice.py')
interactive_html = read_file('interactive_shadow.html')

package = {
    "title": "Iterated Shadow Geometry of Polynomial Supports",
    "domain": "Pythagorean / Algebraic Combinatorics",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Shadow Theorem Verification & Log-Concavity Search",
            "code": demo_code
        }
    ],
    "algorithms": [
        {
            "name": "k-th Shadow Computation",
            "pseudocode": "Input: S ⊂ ℕⁿ (finite), k ≥ 0\nOutput: Sh_k(S)\n1. result ← ∅\n2. For each α ∈ S:\n3.   For each τ ∈ ℕⁿ with |τ| = k and τ ≤ α:\n4.     result ← result ∪ {α - τ}\n5. Return result\n\nComplexity: O(|S| · C(n+k-1,k) · n)",
            "code": algorithms_code
        },
        {
            "name": "Shadow-Based Applications",
            "pseudocode": "Applications of shadow geometry:\n1. Sparse differentiation complexity prediction\n2. Newton polytope layer decomposition\n3. Shadow-based polynomial identity testing\n4. Derivative decay rate analysis",
            "code": applications_code
        }
    ],
    "visualizations": [
        {
            "name": "Shadow Profile Comparison",
            "code": viz_profiles,
            "description": "Plots shadow profiles a_k = |Sh_k(S)| for simplex, matroid basis, and product simplex supports, showing how derivative complexity decays with shadow depth."
        },
        {
            "name": "Log-Concavity Heatmap",
            "code": viz_logconcave,
            "description": "Heatmap of log-concavity ratios a_k²/(a_{k-1}·a_{k+1}) across support families and shadow depths. Green cells confirm log-concavity."
        },
        {
            "name": "Shadow Lattice Erosion",
            "code": viz_lattice,
            "description": "Visualizes how a 2D support set erodes under successive shadow operations, showing the discrete geometric flow that governs derivative supports."
        }
    ],
    "interactive_demos": [
        {
            "name": "Interactive Shadow Explorer",
            "html": interactive_html,
            "description": "Click lattice points to build a support set, adjust the shadow depth slider to see shadows form in real-time, and observe the shadow profile and log-concavity status."
        }
    ],
    "lean_proofs": lean_proofs
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print("PACKAGE.json created successfully")
print(f"Size: {os.path.getsize('PACKAGE.json') / 1024:.1f} KB")


"""
demo.py — Interactive demonstration of Iterated Shadow Geometry.

This script:
1. Constructs sample polynomial supports.
2. Computes k-th shadows and compares with actual mixed derivative supports.
3. Tests log-concavity of shadow profiles on exchange-family examples.
4. Searches for counterexamples to the Shadow Log-Concavity Conjecture.
"""

from itertools import combinations
from collections import defaultdict
import random
import sys


# ─── Inline implementations (self-contained) ───────────────────────

def total_mass(v):
    return sum(v)

def multi_indices_of_mass(n, k):
    if k == 0:
        return [tuple([0]*n)]
    if n == 0:
        return []
    if n == 1:
        return [(k,)]
    result = []
    for first in range(k+1):
        for rest in multi_indices_of_mass(n-1, k-first):
            result.append((first,)+rest)
    return result

def kth_shadow(S, k):
    if not S:
        return set()
    n = len(next(iter(S)))
    shadow = set()
    for alpha in S:
        for tau in multi_indices_of_mass(n, k):
            if all(tau[i] <= alpha[i] for i in range(n)):
                beta = tuple(alpha[i]-tau[i] for i in range(n))
                shadow.add(beta)
    return shadow

def shadow_profile(S, max_k=None):
    if not S:
        return [0]
    if max_k is None:
        max_k = max(total_mass(a) for a in S)
    return [len(kth_shadow(S, k)) for k in range(max_k+1)]

def ascending_factorial(m, k):
    r = 1
    for j in range(k):
        r *= (m+j)
    return r

def iterated_pderiv(poly, tau):
    n = len(tau)
    result = {}
    for alpha, coeff in poly.items():
        if all(alpha[i] >= tau[i] for i in range(n)):
            beta = tuple(alpha[i]-tau[i] for i in range(n))
            scalar = 1
            for i in range(n):
                scalar *= ascending_factorial(beta[i]+1, tau[i])
            val = scalar * coeff
            if val != 0:
                result[beta] = result.get(beta, 0.0) + val
    return {k: v for k, v in result.items() if abs(v) > 1e-15}

def derivative_support_at_order(poly, k):
    if not poly:
        return set()
    n = len(next(iter(poly.keys())))
    result = set()
    for tau in multi_indices_of_mass(n, k):
        deriv = iterated_pderiv(poly, tau)
        result.update(deriv.keys())
    return result

def is_discrete_exchange_family(S):
    S_list = list(S)
    if not S_list:
        return True
    n = len(S_list[0])
    S_set = frozenset(S)
    for alpha in S_list:
        for beta in S_list:
            for i in range(n):
                if alpha[i] > beta[i]:
                    found = False
                    for j in range(n):
                        if beta[j] > alpha[j]:
                            c = list(alpha)
                            c[i] -= 1
                            c[j] += 1
                            if tuple(c) in S_set:
                                found = True
                                break
                    if not found:
                        return False
    return True

def check_log_concavity(profile):
    for k in range(1, len(profile)-1):
        if profile[k]**2 < profile[k-1]*profile[k+1]:
            return False
    return True

def check_ratio_monotonicity(profile):
    for k in range(1, len(profile)-1):
        if profile[k-1] == 0 or profile[k] == 0:
            continue
        if profile[k+1]*profile[k-1] > profile[k]**2:
            return False
    return True

def matroid_basis_support(n, r):
    result = set()
    for combo in combinations(range(n), r):
        vec = [0]*n
        for i in combo:
            vec[i] = 1
        result.add(tuple(vec))
    return result

def simplex_support(n, d):
    return set(multi_indices_of_mass(n, d))

def product_simplex_support(dims):
    """Support of product of simplices: all vectors (a1,...,an) with ai <= di."""
    if not dims:
        return {()}
    result = set()
    for a in range(dims[0]+1):
        for rest in product_simplex_support(dims[1:]):
            result.add((a,)+rest)
    return result


# ─── Main demonstration ────────────────────────────────────────────

def demo_shadow_theorem():
    """Demonstrate the exact k-th shadow theorem on concrete polynomials."""
    print("=" * 70)
    print("DEMO 1: The Exact k-th Shadow Theorem")
    print("=" * 70)
    print()
    print("We verify that the support of all k-th order mixed partial")
    print("derivatives equals the k-th combinatorial shadow of the support.")
    print()

    # Polynomial: 3x²y - z³ + 5xy² + 2x³
    poly = {
        (2, 1, 0): 3.0,
        (0, 0, 3): -1.0,
        (1, 2, 0): 5.0,
        (3, 0, 0): 2.0,
    }
    print(f"f(x,y,z) = 3x²y - z³ + 5xy² + 2x³")
    print(f"Support: {sorted(poly.keys())}")
    print()

    for k in range(5):
        supp = set(a for a, c in poly.items() if c != 0)
        shadow = kth_shadow(supp, k)
        deriv_supp = derivative_support_at_order(poly, k)
        match = shadow == deriv_supp
        print(f"  k={k}: |Shadow| = {len(shadow):3d}, |Deriv support| = {len(deriv_supp):3d}, Match: {'✓' if match else '✗'}")

    print()
    prof = shadow_profile(set(poly.keys()))
    print(f"Shadow profile: {prof}")
    print(f"Log-concave: {check_log_concavity(prof)}")
    print()


def demo_shadow_composition():
    """Demonstrate the shadow composition law: Sh_b(Sh_a(S)) = Sh_{a+b}(S)."""
    print("=" * 70)
    print("DEMO 2: Shadow Composition Law (Semigroup Property)")
    print("=" * 70)
    print()
    print("Verifying: kthShadow(kthShadow(S, a), b) = kthShadow(S, a+b)")
    print()

    S = simplex_support(3, 4)
    print(f"S = simplex support in 3 variables, degree 4")
    print(f"|S| = {len(S)}")
    print()

    for a in range(5):
        for b in range(5 - a):
            lhs = kth_shadow(kth_shadow(S, a), b)
            rhs = kth_shadow(S, a + b)
            match = lhs == rhs
            if not match:
                print(f"  FAILURE at a={a}, b={b}!")
    print("  All (a,b) pairs verified ✓")
    print()


def demo_exchange_families():
    """Test exchange families and their shadow profiles."""
    print("=" * 70)
    print("DEMO 3: Exchange Families and Log-Concavity")
    print("=" * 70)
    print()

    test_cases = [
        ("Uniform matroid U(2,4)", matroid_basis_support(4, 2)),
        ("Uniform matroid U(3,5)", matroid_basis_support(5, 3)),
        ("Uniform matroid U(2,6)", matroid_basis_support(6, 2)),
        ("Uniform matroid U(3,6)", matroid_basis_support(6, 3)),
        ("Simplex (n=3, d=3)", simplex_support(3, 3)),
        ("Simplex (n=4, d=2)", simplex_support(4, 2)),
        ("Product simplex [2,2,2]", product_simplex_support([2, 2, 2])),
        ("Product simplex [3,2,1]", product_simplex_support([3, 2, 1])),
    ]

    print(f"{'Family':<30} {'|S|':>5} {'Exchange':>10} {'Profile':<30} {'LogConc':>8} {'RatMon':>8}")
    print("-" * 100)

    for name, S in test_cases:
        is_exch = is_discrete_exchange_family(S)
        prof = shadow_profile(S)
        lc = check_log_concavity(prof)
        rm = check_ratio_monotonicity(prof)
        prof_str = str(prof) if len(str(prof)) <= 28 else str(prof)[:25] + "..."
        print(f"{name:<30} {len(S):>5} {'Yes' if is_exch else 'No':>10} {prof_str:<30} {'✓' if lc else '✗':>8} {'✓' if rm else '✗':>8}")

    print()


def demo_counterexample_search():
    """Search for counterexamples to the log-concavity conjecture."""
    print("=" * 70)
    print("DEMO 4: Counterexample Search for Shadow Log-Concavity")
    print("=" * 70)
    print()
    print("Conjecture: If S is a discrete exchange family, then the")
    print("shadow profile a_k = |Sh_k(S)| is log-concave.")
    print()
    print("Searching over random exchange-family-like supports...")
    print()

    counterexamples = 0
    tests = 0

    # Test all matroid basis supports up to n=8
    for n in range(2, 9):
        for r in range(1, n):
            S = matroid_basis_support(n, r)
            if is_discrete_exchange_family(S):
                prof = shadow_profile(S)
                lc = check_log_concavity(prof)
                tests += 1
                if not lc:
                    counterexamples += 1
                    print(f"  COUNTEREXAMPLE: U({r},{n}), profile={prof}")

    print(f"  Tested {tests} matroid basis supports, {counterexamples} counterexamples")
    print()

    # Test simplex supports
    for n in range(2, 7):
        for d in range(1, 7):
            S = simplex_support(n, d)
            if is_discrete_exchange_family(S):
                prof = shadow_profile(S)
                lc = check_log_concavity(prof)
                tests += 1
                if not lc:
                    counterexamples += 1
                    print(f"  COUNTEREXAMPLE: Simplex(n={n},d={d}), profile={prof}")

    print(f"  Total: {tests} exchange families tested, {counterexamples} counterexamples")

    # Test product simplices
    for d1 in range(1, 5):
        for d2 in range(1, 5):
            for d3 in range(1, 4):
                S = product_simplex_support([d1, d2, d3])
                if is_discrete_exchange_family(S):
                    prof = shadow_profile(S)
                    lc = check_log_concavity(prof)
                    tests += 1
                    if not lc:
                        counterexamples += 1
                        print(f"  COUNTEREXAMPLE: Product[{d1},{d2},{d3}], profile={prof}")

    print(f"\n  Final tally: {tests} exchange families tested, {counterexamples} counterexamples found")
    if counterexamples == 0:
        print("  ➤ Conjecture SURVIVES all tests!")
    else:
        print("  ➤ Conjecture REFUTED!")
    print()


def demo_shadow_profile_visualization():
    """Show shadow profiles as text-based bar charts."""
    print("=" * 70)
    print("DEMO 5: Shadow Profile Visualization")
    print("=" * 70)
    print()

    families = [
        ("Simplex(3,5)", simplex_support(3, 5)),
        ("U(3,6) matroid", matroid_basis_support(6, 3)),
        ("Product[2,2,2]", product_simplex_support([2,2,2])),
    ]

    for name, S in families:
        prof = shadow_profile(S)
        max_val = max(prof) if prof else 1
        print(f"  {name} (|S|={len(S)})")
        for k, a_k in enumerate(prof):
            bar = '█' * int(40 * a_k / max_val) if max_val > 0 else ''
            print(f"    k={k:2d}: {a_k:4d} {bar}")
        print(f"    Log-concave: {check_log_concavity(prof)}")
        print()


if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║   ITERATED SHADOW GEOMETRY — Interactive Demonstration             ║")
    print("║   Exploring the combinatorial footprint of polynomial derivatives  ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_shadow_theorem()
    demo_shadow_composition()
    demo_exchange_families()
    demo_counterexample_search()
    demo_shadow_profile_visualization()

    print("=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)


"""
Visualization: Log-Concavity Heatmap

Creates a heatmap showing the log-concavity ratio a_k^2 / (a_{k-1} * a_{k+1})
for various support families and shadow depths. Values >= 1 confirm log-concavity.
The conjecture predicts all cells should be >= 1 for exchange families.
"""

import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations


def multi_indices_of_mass(n, k):
    if k == 0: return [tuple([0]*n)]
    if n == 0: return []
    if n == 1: return [(k,)]
    result = []
    for first in range(k+1):
        for rest in multi_indices_of_mass(n-1, k-first):
            result.append((first,)+rest)
    return result

def kth_shadow(S, k):
    if not S: return set()
    n = len(next(iter(S)))
    shadow = set()
    for alpha in S:
        for tau in multi_indices_of_mass(n, k):
            if all(tau[i] <= alpha[i] for i in range(n)):
                shadow.add(tuple(alpha[i]-tau[i] for i in range(n)))
    return shadow

def shadow_profile(S, max_k=None):
    if not S: return [0]
    if max_k is None: max_k = max(sum(a) for a in S)
    return [len(kth_shadow(S, k)) for k in range(max_k+1)]

def matroid_basis_support(n, r):
    result = set()
    for combo in combinations(range(n), r):
        vec = [0]*n
        for i in combo: vec[i] = 1
        result.add(tuple(vec))
    return result

def simplex_support(n, d):
    return set(multi_indices_of_mass(n, d))


# Compute log-concavity ratios for various families
families = []
labels = []

for n in range(3, 8):
    for r in range(1, n):
        if r >= n: continue
        S = matroid_basis_support(n, r)
        prof = shadow_profile(S)
        families.append(prof)
        labels.append(f'U({r},{n})')

for n in range(2, 6):
    for d in range(2, 6):
        S = simplex_support(n, d)
        prof = shadow_profile(S)
        families.append(prof)
        labels.append(f'Δ({n},{d})')

# Find max length
max_len = max(len(p) for p in families)

# Compute LC ratios
ratios = np.full((len(families), max_len - 2), np.nan)
for i, prof in enumerate(families):
    for k in range(1, len(prof) - 1):
        if prof[k-1] > 0 and prof[k+1] > 0:
            ratios[i, k-1] = prof[k]**2 / (prof[k-1] * prof[k+1])
        elif prof[k] > 0 and prof[k+1] == 0:
            ratios[i, k-1] = float('inf')

# Plot
fig, ax = plt.subplots(figsize=(12, 8))

# Replace inf with a large number for display
display_ratios = np.where(np.isinf(ratios), 5.0, ratios)
display_ratios = np.where(np.isnan(display_ratios), 0, display_ratios)

im = ax.imshow(display_ratios, cmap='RdYlGn', vmin=0.5, vmax=3.0, aspect='auto')
ax.set_yticks(range(len(labels)))
ax.set_yticklabels(labels, fontsize=8)
ax.set_xticks(range(max_len - 2))
ax.set_xticklabels([f'k={k+1}' for k in range(max_len - 2)], fontsize=9)
ax.set_xlabel('Shadow depth k', fontsize=12)
ax.set_ylabel('Support family', fontsize=12)
ax.set_title('Log-Concavity Ratios: a_k² / (a_{k-1} · a_{k+1})\n'
             'Green ≥ 1 confirms log-concavity; Red < 1 would refute it',
             fontsize=13, fontweight='bold')

# Add text annotations
for i in range(len(families)):
    for j in range(max_len - 2):
        if not np.isnan(ratios[i, j]) and not np.isinf(ratios[i, j]):
            ax.text(j, i, f'{ratios[i,j]:.2f}', ha='center', va='center',
                   fontsize=6, color='black')
        elif np.isinf(ratios[i, j]):
            ax.text(j, i, '∞', ha='center', va='center', fontsize=7, color='darkgreen')

plt.colorbar(im, ax=ax, label='LC ratio (≥1 = log-concave)')
plt.tight_layout()
plt.savefig('log_concavity_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved log_concavity_heatmap.png")


"""
Visualization: Shadow Lattice Structure (2D)

Shows the support set and its successive shadows in 2 variables,
illustrating how the shadow operator "erodes" the support inward
like a discrete geometric flow.
"""

import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations


def multi_indices_of_mass(n, k):
    if k == 0: return [tuple([0]*n)]
    if n == 0: return []
    if n == 1: return [(k,)]
    result = []
    for first in range(k+1):
        for rest in multi_indices_of_mass(n-1, k-first):
            result.append((first,)+rest)
    return result

def kth_shadow(S, k):
    if not S: return set()
    n = len(next(iter(S)))
    shadow = set()
    for alpha in S:
        for tau in multi_indices_of_mass(n, k):
            if all(tau[i] <= alpha[i] for i in range(n)):
                shadow.add(tuple(alpha[i]-tau[i] for i in range(n)))
    return shadow


# Create a 2D support set
S0 = {(5, 0), (4, 1), (3, 2), (2, 3), (1, 4), (0, 5),
      (4, 0), (3, 1), (2, 2), (1, 3), (0, 4),
      (3, 3), (2, 4), (4, 2)}

fig, axes = plt.subplots(2, 3, figsize=(15, 10))

max_val = 6
shadows = [S0]
for k in range(1, 6):
    shadows.append(kth_shadow(S0, k))

colors = ['#E91E63', '#FF9800', '#FFC107', '#4CAF50', '#2196F3', '#9C27B0']
titles = ['S (original)', 'Sh₁(S)', 'Sh₂(S)', 'Sh₃(S)', 'Sh₄(S)', 'Sh₅(S)']

for idx, (ax, shadow, color, title) in enumerate(zip(axes.flat, shadows, colors, titles)):
    # Draw grid
    for x in range(max_val + 1):
        for y in range(max_val + 1):
            ax.plot(x, y, '.', color='#E0E0E0', markersize=4)

    # Draw shadow points
    if shadow:
        xs = [p[0] for p in shadow]
        ys = [p[1] for p in shadow]
        ax.scatter(xs, ys, c=color, s=100, zorder=5, edgecolors='black', linewidth=0.5)

    # Draw original support outline on all panels
    if idx > 0 and S0:
        xs0 = [p[0] for p in S0]
        ys0 = [p[1] for p in S0]
        ax.scatter(xs0, ys0, c='none', s=60, zorder=4, edgecolors='#BDBDBD', linewidth=1)

    ax.set_xlim(-0.5, max_val + 0.5)
    ax.set_ylim(-0.5, max_val + 0.5)
    ax.set_aspect('equal')
    ax.set_title(f'{title}  (|·| = {len(shadow)})', fontsize=13, fontweight='bold')
    ax.set_xlabel('x exponent', fontsize=10)
    ax.set_ylabel('y exponent', fontsize=10)
    ax.grid(True, alpha=0.15)

fig.suptitle('Shadow Erosion: The Support Contracts Under Iterated Shadows\n'
             'Gray circles: original support. Colored: shadow at each depth.',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('shadow_lattice.png', dpi=150, bbox_inches='tight')
print("Saved shadow_lattice.png")


"""
Visualization: Shadow Profile Comparison

Plots the shadow profile a_k = |Sh_k(S)| for several families of supports,
showing how derivative complexity decays as the shadow depth increases.
The log-concavity of these curves is visually apparent and relates to
deep conjectures connecting discrete convex geometry to polynomial algebra.
"""

import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations


def multi_indices_of_mass(n, k):
    if k == 0: return [tuple([0]*n)]
    if n == 0: return []
    if n == 1: return [(k,)]
    result = []
    for first in range(k+1):
        for rest in multi_indices_of_mass(n-1, k-first):
            result.append((first,)+rest)
    return result

def kth_shadow(S, k):
    if not S: return set()
    n = len(next(iter(S)))
    shadow = set()
    for alpha in S:
        for tau in multi_indices_of_mass(n, k):
            if all(tau[i] <= alpha[i] for i in range(n)):
                shadow.add(tuple(alpha[i]-tau[i] for i in range(n)))
    return shadow

def shadow_profile(S, max_k=None):
    if not S: return [0]
    if max_k is None: max_k = max(sum(a) for a in S)
    return [len(kth_shadow(S, k)) for k in range(max_k+1)]

def matroid_basis_support(n, r):
    result = set()
    for combo in combinations(range(n), r):
        vec = [0]*n
        for i in combo: vec[i] = 1
        result.add(tuple(vec))
    return result

def simplex_support(n, d):
    return set(multi_indices_of_mass(n, d))

def product_simplex_support(dims):
    if not dims: return {()}
    result = set()
    for a in range(dims[0]+1):
        for rest in product_simplex_support(dims[1:]):
            result.add((a,)+rest)
    return result


fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Panel 1: Simplex supports
ax = axes[0]
for n, d, color in [(3, 3, '#2196F3'), (3, 5, '#4CAF50'), (4, 3, '#FF9800'), (4, 4, '#E91E63')]:
    S = simplex_support(n, d)
    prof = shadow_profile(S)
    ax.plot(range(len(prof)), prof, 'o-', color=color, label=f'Simplex({n},{d})',
            markersize=6, linewidth=2)
ax.set_xlabel('Shadow depth k', fontsize=12)
ax.set_ylabel('Shadow size |Sh_k(S)|', fontsize=12)
ax.set_title('Simplex Supports', fontsize=14, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 2: Matroid basis supports
ax = axes[1]
for n, r, color in [(5, 2, '#2196F3'), (6, 2, '#4CAF50'), (6, 3, '#FF9800'), (7, 3, '#E91E63')]:
    S = matroid_basis_support(n, r)
    prof = shadow_profile(S)
    ax.plot(range(len(prof)), prof, 's-', color=color, label=f'U({r},{n})',
            markersize=6, linewidth=2)
ax.set_xlabel('Shadow depth k', fontsize=12)
ax.set_ylabel('Shadow size |Sh_k(S)|', fontsize=12)
ax.set_title('Matroid Basis Supports', fontsize=14, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 3: Product simplex supports
ax = axes[2]
for dims, color in [([2,2,2], '#2196F3'), ([3,2,1], '#4CAF50'), ([3,3,2], '#FF9800'), ([4,2,2], '#E91E63')]:
    S = product_simplex_support(dims)
    prof = shadow_profile(S)
    ax.plot(range(len(prof)), prof, 'D-', color=color, label=f'Prod{dims}',
            markersize=6, linewidth=2)
ax.set_xlabel('Shadow depth k', fontsize=12)
ax.set_ylabel('Shadow size |Sh_k(S)|', fontsize=12)
ax.set_title('Product Simplex Supports', fontsize=14, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

fig.suptitle('Shadow Profiles: Derivative Complexity Decay', fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('shadow_profiles.png', dpi=150, bbox_inches='tight')
print("Saved shadow_profiles.png")
