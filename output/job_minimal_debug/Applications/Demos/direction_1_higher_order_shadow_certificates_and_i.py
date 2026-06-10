#!/usr/bin/env python3
"""
Applications of Higher-Order Shadow Certificates

Demonstrates real-world applications of the theory that derivative supports
are determined by support shadows.

Applications:
1. Sparse Symbolic Differentiation Acceleration
2. Arithmetic Complexity Lower Bounds
3. Taylor Jet Support Prediction
4. Polynomial Identity Testing Support
"""

from fractions import Fraction
from typing import Dict, Tuple, List, Set, FrozenSet
import time
import random

MultiIndex = Tuple[int, ...]
SparsePolynomial = Dict[MultiIndex, Fraction]
Support = FrozenSet[MultiIndex]

# Import core algorithms
def add_mi(a, b): return tuple(x + y for x, y in zip(a, b))
def sub_mi(a, b): return tuple(x - y for x, y in zip(a, b))
def le_mi(a, b): return all(x <= y for x, y in zip(a, b))
def weight(g): return sum(g)

def desc_factorial(n, k):
    r = 1
    for i in range(k): r *= (n - i)
    return r

def falling_factorial_multi(beta, gamma):
    r = Fraction(1)
    for b, g in zip(beta, gamma): r *= Fraction(desc_factorial(b + g, g))
    return r

def shadow_along(S, gamma):
    return frozenset(sub_mi(a, gamma) for a in S if le_mi(gamma, a))

def enumerate_multi_indices(k, n):
    if n == 0: return [()] if k == 0 else []
    if n == 1: return [(k,)]
    result = []
    for i in range(k + 1):
        for rest in enumerate_multi_indices(k - i, n - 1):
            result.append((i,) + rest)
    return result

def total_shadow_order(k, S, n_vars):
    result = set()
    for gamma in enumerate_multi_indices(k, n_vars):
        result.update(shadow_along(S, gamma))
    return frozenset(result)

def iterated_pderiv(poly, gamma):
    result = {}
    for alpha, c in poly.items():
        if le_mi(gamma, alpha):
            beta = sub_mi(alpha, gamma)
            scalar = falling_factorial_multi(beta, gamma)
            result[beta] = c * scalar
    return {k: v for k, v in result.items() if v != 0}

def random_sparse_polynomial(n_vars, max_degree, n_terms, coeff_range=10):
    poly = {}
    attempts = 0
    while len(poly) < n_terms and attempts < n_terms * 10:
        exp = tuple(random.randint(0, max_degree) for _ in range(n_vars))
        if exp not in poly:
            c = random.randint(-coeff_range, coeff_range)
            if c != 0: poly[exp] = Fraction(c)
        attempts += 1
    return poly


# ────────────────────────────────────────────────────────────────────
# Application 1: Sparse Symbolic Differentiation Acceleration
# ────────────────────────────────────────────────────────────────────

def app_sparse_differentiation():
    """Demonstrates how shadow prediction accelerates sparse differentiation.

    Key insight: We can predict which monomials will appear in the derivative
    WITHOUT computing the actual coefficients. This enables:
    - Pre-allocation of exact output size
    - Skipping zero terms entirely
    - Parallelization by output monomial
    """
    print("=" * 72)
    print("APPLICATION 1: Sparse Symbolic Differentiation Acceleration")
    print("=" * 72)
    print()

    random.seed(123)

    for n_vars, max_deg, n_terms in [(5, 8, 50), (8, 6, 100), (10, 5, 200)]:
        poly = random_sparse_polynomial(n_vars, max_deg, n_terms)
        S = frozenset(poly.keys())

        # Compare: naive approach vs shadow-guided approach
        gamma = tuple(1 if i < min(3, n_vars) else 0 for i in range(n_vars))

        # Naive: iterate through all support elements, compute, filter zeros
        t0 = time.perf_counter()
        for _ in range(100):
            naive_result = {}
            for alpha, c in poly.items():
                if le_mi(gamma, alpha):
                    beta = sub_mi(alpha, gamma)
                    scalar = falling_factorial_multi(beta, gamma)
                    coeff = c * scalar
                    if coeff != 0:
                        naive_result[beta] = coeff
        t_naive = time.perf_counter() - t0

        # Shadow-guided: predict output support first, then fill coefficients
        t0 = time.perf_counter()
        for _ in range(100):
            predicted_support = shadow_along(S, gamma)
            guided_result = {}
            for beta in predicted_support:
                alpha = add_mi(beta, gamma)
                c = poly.get(alpha, Fraction(0))
                scalar = falling_factorial_multi(beta, gamma)
                guided_result[beta] = c * scalar
        t_guided = time.perf_counter() - t0

        print(f"  {n_vars} vars, deg≤{max_deg}, {len(poly)} terms, γ={gamma}")
        print(f"    Naive: {t_naive:.4f}s, Shadow-guided: {t_guided:.4f}s")
        print(f"    Output size: {len(naive_result)} terms "
              f"(predicted exactly by shadow: {len(predicted_support)})")
        print(f"    Results match: {naive_result == guided_result}")
        print()


# ────────────────────────────────────────────────────────────────────
# Application 2: Arithmetic Complexity Lower Bounds
# ────────────────────────────────────────────────────────────────────

def app_complexity_bounds():
    """Uses shadow sizes to bound derivative-space complexity.

    Key insight: |Shadow^(k)(S)| is a lower bound on the number of
    distinct nonzero coefficients across all order-k derivatives.
    Over char 0, this bound is tight.
    """
    print("=" * 72)
    print("APPLICATION 2: Arithmetic Complexity Lower Bounds")
    print("=" * 72)
    print()
    print("  The shadow profile predicts derivative-space complexity:")
    print("  |Shadow^(k)(S)| = # distinct nonzero coefficients in all order-k derivs")
    print()

    random.seed(456)

    for n_vars, max_deg, n_terms in [(3, 5, 10), (4, 4, 15), (3, 8, 20)]:
        poly = random_sparse_polynomial(n_vars, max_deg, n_terms)
        S = frozenset(poly.keys())

        print(f"  Polynomial: {n_vars} vars, deg≤{max_deg}, {len(poly)} terms")
        print(f"  {'k':<5} {'|Shadow^(k)|':<15} {'# gammas':<12} {'Avg per gamma':<15}")

        max_order = min(6, max_deg)
        for k in range(max_order + 1):
            ts = total_shadow_order(k, S, n_vars)
            n_gammas = len(enumerate_multi_indices(k, n_vars))
            avg = len(ts) / max(n_gammas, 1)
            print(f"  {k:<5} {len(ts):<15} {n_gammas:<12} {avg:<15.1f}")
        print()


# ────────────────────────────────────────────────────────────────────
# Application 3: Taylor Jet Support Prediction
# ────────────────────────────────────────────────────────────────────

def app_taylor_jet():
    """Predicts the support structure of the Taylor expansion.

    For a polynomial p of degree d, the Taylor jet at the origin consists of
    the homogeneous components of ∂^γ p for |γ| = 0, 1, ..., d.
    The shadow calculus predicts exactly which monomials appear at each level.
    """
    print("=" * 72)
    print("APPLICATION 3: Taylor Jet Support Prediction")
    print("=" * 72)
    print()

    # Create a specific polynomial for illustration
    p = {
        (3, 0, 0): Fraction(1),
        (2, 1, 0): Fraction(2),
        (1, 1, 1): Fraction(-3),
        (0, 2, 1): Fraction(4),
        (0, 0, 3): Fraction(1),
    }
    S = frozenset(p.keys())

    print(f"  p = " + " + ".join(f"{c}·x^{a}" for a, c in sorted(p.items())))
    print(f"  Support: {sorted(S)}")
    print()

    total_deg = max(weight(a) for a in S)
    print(f"  Total degree: {total_deg}")
    print(f"  Taylor jet decomposition by derivative order:")
    print()

    for k in range(total_deg + 1):
        gammas = enumerate_multi_indices(k, 3)
        print(f"  Order {k} ({len(gammas)} derivative directions):")
        for gamma in gammas:
            shadow = shadow_along(S, gamma)
            if shadow:
                deriv = iterated_pderiv(p, gamma)
                print(f"    ∂^{gamma}: support = {sorted(shadow)}, "
                      f"terms = {len(shadow)}")
        print()


# ────────────────────────────────────────────────────────────────────
# Application 4: Support-Based Identity Testing
# ────────────────────────────────────────────────────────────────────

def app_identity_testing():
    """Uses shadow structure for polynomial identity testing.

    If two polynomials p, q have different supports, then for every γ,
    Shadow_γ(supp p) ≠ Shadow_γ(supp q) implies ∂^γ p ≠ ∂^γ q.

    This gives a support-level certificate of non-identity without
    evaluating the polynomial.
    """
    print("=" * 72)
    print("APPLICATION 4: Support-Based Identity Testing")
    print("=" * 72)
    print()

    p = {(2, 1): Fraction(3), (1, 2): Fraction(-5), (3, 0): Fraction(1)}
    q = {(2, 1): Fraction(3), (1, 2): Fraction(-5), (0, 3): Fraction(1)}

    Sp = frozenset(p.keys())
    Sq = frozenset(q.keys())

    print(f"  p support: {sorted(Sp)}")
    print(f"  q support: {sorted(Sq)}")
    print(f"  Supports equal? {Sp == Sq}")
    print()

    if Sp != Sq:
        print("  Searching for distinguishing derivative direction...")
        for k in range(1, 4):
            for gamma in enumerate_multi_indices(k, 2):
                sp = shadow_along(Sp, gamma)
                sq = shadow_along(Sq, gamma)
                if sp != sq:
                    print(f"  Found! γ={gamma} gives different shadows:")
                    print(f"    Shadow_γ(supp p) = {sorted(sp)}")
                    print(f"    Shadow_γ(supp q) = {sorted(sq)}")
                    print(f"    Therefore ∂^{gamma} p ≠ ∂^{gamma} q")
                    print(f"    (Detected at order {k})")
                    return
    print("  Supports are equal — need coefficient-level analysis")


def main():
    app_sparse_differentiation()
    print()
    app_complexity_bounds()
    print()
    app_taylor_jet()
    print()
    app_identity_testing()


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Higher-Order Shadow Certificates: Experimental Mathematics Lab

This script demonstrates the core theory that iterated differentiation of
multivariate polynomials is combinatorially controlled by iterated shadows
of support sets. Over characteristic-zero fields (like ℚ), the support of
every iterated partial derivative ∂^γ p equals the shadow of supp(p) along γ.

The demo:
1. Generates random sparse polynomials in 3-5 variables
2. Computes order-3 and order-4 shadows
3. Compares predicted vs actual derivative supports
4. Displays ancestor collisions causing possible cancellation
5. Searches for counterexamples to the genericity conjecture
6. Prints a concise scientific summary
"""

import random
import itertools
from fractions import Fraction
from collections import defaultdict
from typing import Dict, Tuple, List, Set, FrozenSet

# Type aliases
MultiIndex = Tuple[int, ...]
Support = FrozenSet[MultiIndex]

def falling_factorial(n: int, k: int) -> int:
    """Compute n * (n-1) * ... * (n-k+1)."""
    result = 1
    for i in range(k):
        result *= (n - i)
    return result

def falling_factorial_multi(beta: MultiIndex, gamma: MultiIndex) -> Fraction:
    """Compute ∏ᵢ descFactorial((β+γ)(i), γ(i))."""
    result = Fraction(1)
    for b, g in zip(beta, gamma):
        result *= Fraction(falling_factorial(b + g, g))
    return result

def add_multi(a: MultiIndex, b: MultiIndex) -> MultiIndex:
    return tuple(x + y for x, y in zip(a, b))

def sub_multi(a: MultiIndex, b: MultiIndex) -> MultiIndex:
    return tuple(x - y for x, y in zip(a, b))

def le_multi(a: MultiIndex, b: MultiIndex) -> bool:
    return all(x <= y for x, y in zip(a, b))

def total_weight(gamma: MultiIndex) -> int:
    return sum(gamma)

def shadow_along(S: Support, gamma: MultiIndex) -> Support:
    """Compute Shadow_γ(S) = {α - γ | α ∈ S, γ ≤ α}."""
    result = set()
    for alpha in S:
        if le_multi(gamma, alpha):
            result.add(sub_multi(alpha, gamma))
    return frozenset(result)

def total_shadow_order(k: int, S: Support, n_vars: int) -> Support:
    """Compute Shadow^(k)(S) = ⋃_{|γ|=k} Shadow_γ(S)."""
    result = set()
    for gamma in multi_indices_of_weight(k, n_vars):
        result.update(shadow_along(S, gamma))
    return frozenset(result)

def multi_indices_of_weight(k: int, n: int) -> List[MultiIndex]:
    """Generate all multi-indices of total weight k in n variables."""
    if n == 0:
        return [()] if k == 0 else []
    if n == 1:
        return [(k,)]
    result = []
    for i in range(k + 1):
        for rest in multi_indices_of_weight(k - i, n - 1):
            result.append((i,) + rest)
    return result

def random_sparse_polynomial(n_vars: int, max_degree: int, n_terms: int,
                              coeff_range: int = 10) -> Dict[MultiIndex, Fraction]:
    """Generate a random sparse polynomial with rational coefficients."""
    poly = {}
    attempts = 0
    while len(poly) < n_terms and attempts < n_terms * 10:
        exponent = tuple(random.randint(0, max_degree) for _ in range(n_vars))
        if exponent not in poly:
            c = random.randint(-coeff_range, coeff_range)
            if c != 0:
                poly[exponent] = Fraction(c)
        attempts += 1
    return poly

def compute_iterated_pderiv(poly: Dict[MultiIndex, Fraction],
                             gamma: MultiIndex) -> Dict[MultiIndex, Fraction]:
    """Compute ∂^γ p using the coefficient formula:
    coeff_β(∂^γ p) = coeff_{β+γ}(p) · fallingFactorialMulti(β, γ)"""
    result = {}
    for alpha, c in poly.items():
        if le_multi(gamma, alpha):
            beta = sub_multi(alpha, gamma)
            scalar = falling_factorial_multi(beta, gamma)
            new_coeff = c * scalar
            if new_coeff != 0:
                result[beta] = result.get(beta, Fraction(0)) + new_coeff
    # Remove zeros
    return {k: v for k, v in result.items() if v != 0}

def find_ancestor_collisions(S: Support, gamma: MultiIndex) -> Dict[MultiIndex, List[MultiIndex]]:
    """Find all β in Shadow_γ(S) and their ancestors α ∈ S with α - γ = β."""
    collisions = defaultdict(list)
    for alpha in S:
        if le_multi(gamma, alpha):
            beta = sub_multi(alpha, gamma)
            collisions[beta].append(alpha)
    return {k: v for k, v in collisions.items() if len(v) > 0}

def audit_higher_order_shadow(k: int, poly: Dict[MultiIndex, Fraction],
                                n_vars: int) -> List[dict]:
    """Audit all order-k derivatives against shadow predictions."""
    S = frozenset(poly.keys())
    results = []
    for gamma in multi_indices_of_weight(k, n_vars):
        predicted = shadow_along(S, gamma)
        deriv = compute_iterated_pderiv(poly, gamma)
        actual = frozenset(deriv.keys())
        results.append({
            'gamma': gamma,
            'predicted': predicted,
            'actual': actual,
            'match': predicted == actual,
            'predicted_minus_actual': predicted - actual,
            'actual_minus_predicted': actual - predicted,
        })
    return results

def run_experiment(n_vars: int, max_degree: int, n_terms: int, order: int,
                    trial_num: int) -> dict:
    """Run a single experiment."""
    poly = random_sparse_polynomial(n_vars, max_degree, n_terms)
    S = frozenset(poly.keys())
    results = audit_higher_order_shadow(order, poly, n_vars)

    all_match = all(r['match'] for r in results)
    n_gammas = len(results)
    n_matches = sum(1 for r in results if r['match'])

    return {
        'trial': trial_num,
        'n_vars': n_vars,
        'max_degree': max_degree,
        'n_terms': len(poly),
        'order': order,
        'support_size': len(S),
        'n_gammas': n_gammas,
        'n_matches': n_matches,
        'all_match': all_match,
        'total_shadow_size': len(total_shadow_order(order, S, n_vars)),
    }

def main():
    random.seed(42)

    print("=" * 72)
    print("HIGHER-ORDER SHADOW CERTIFICATES: EXPERIMENTAL MATHEMATICS LAB")
    print("=" * 72)
    print()
    print("Testing the principle: supp(∂^γ p) = Shadow_γ(supp p) over ℚ")
    print("This should hold UNCONDITIONALLY for all polynomials over char 0.")
    print()

    # ─── Experiment 1: Systematic verification at orders 1-4 ───
    print("━" * 72)
    print("EXPERIMENT 1: Systematic verification across orders and dimensions")
    print("━" * 72)

    configs = [
        (3, 4, 8, 1),  # 3 vars, deg ≤ 4, 8 terms, order 1
        (3, 4, 8, 2),  # order 2
        (3, 4, 8, 3),  # order 3
        (3, 4, 8, 4),  # order 4
        (4, 3, 10, 2), # 4 vars, deg ≤ 3, 10 terms, order 2
        (4, 3, 10, 3), # order 3
        (5, 3, 12, 2), # 5 vars, deg ≤ 3, 12 terms, order 2
        (5, 3, 12, 3), # order 3
    ]

    total_tests = 0
    total_matches = 0
    counterexamples = []

    for n_vars, max_deg, n_terms, order in configs:
        n_trials = 20
        experiment_matches = 0
        for trial in range(n_trials):
            result = run_experiment(n_vars, max_deg, n_terms, order, trial)
            total_tests += result['n_gammas']
            total_matches += result['n_matches']
            if result['all_match']:
                experiment_matches += 1
            elif not result['all_match']:
                counterexamples.append(result)

        print(f"  {n_vars} vars, deg≤{max_deg}, {n_terms} terms, order {order}: "
              f"{experiment_matches}/{n_trials} trials fully match "
              f"({n_trials - experiment_matches} have discrepancies)")

    print()
    print(f"  Total derivative-shadow comparisons: {total_tests}")
    print(f"  Total matches: {total_matches}")
    print(f"  Match rate: {total_matches/total_tests*100:.2f}%")
    if counterexamples:
        print(f"  ⚠ Found {len(counterexamples)} trials with discrepancies!")
    else:
        print(f"  ✓ Perfect agreement in all {total_tests} comparisons!")

    # ─── Experiment 2: Ancestor collision analysis ───
    print()
    print("━" * 72)
    print("EXPERIMENT 2: Ancestor collision analysis")
    print("━" * 72)
    print("  For each shadow element β, how many ancestors α ∈ S satisfy α - γ = β?")
    print("  (Answer: always exactly 1, since β ↦ β + γ is injective)")
    print()

    poly = random_sparse_polynomial(3, 5, 10)
    S = frozenset(poly.keys())
    print(f"  Polynomial support ({len(S)} terms):")
    for alpha in sorted(S):
        print(f"    {alpha}: {poly[alpha]}")
    print()

    for order in [2, 3]:
        max_ancestors = 0
        total_shadow_elements = 0
        for gamma in multi_indices_of_weight(order, 3):
            collisions = find_ancestor_collisions(S, gamma)
            for beta, ancestors in collisions.items():
                max_ancestors = max(max_ancestors, len(ancestors))
                total_shadow_elements += 1

        print(f"  Order {order}: {total_shadow_elements} shadow elements, "
              f"max ancestors per element = {max_ancestors}")

    print()
    print("  Observation: Each shadow element has EXACTLY 1 ancestor.")
    print("  This is why cancellation is structurally impossible!")

    # ─── Experiment 3: Coefficient formula verification ───
    print()
    print("━" * 72)
    print("EXPERIMENT 3: Coefficient formula verification")
    print("━" * 72)
    print("  Verifying: coeff_β(∂^γ p) = coeff_{β+γ}(p) · ∏ᵢ (βᵢ+γᵢ)!/βᵢ!")
    print()

    poly = {(2, 1, 0): Fraction(3), (1, 2, 1): Fraction(-5),
            (3, 0, 2): Fraction(7), (0, 3, 1): Fraction(2)}
    gamma = (1, 1, 0)
    print(f"  p = {' + '.join(f'{c}·x^{a}' for a, c in sorted(poly.items()))}")
    print(f"  γ = {gamma}")
    print()

    deriv = compute_iterated_pderiv(poly, gamma)
    for beta in sorted(deriv.keys()):
        alpha = add_multi(beta, gamma)
        scalar = falling_factorial_multi(beta, gamma)
        ancestor_coeff = poly.get(alpha, Fraction(0))
        computed = ancestor_coeff * scalar
        print(f"  β={beta}: coeff(β+γ={alpha}, p)={ancestor_coeff}, "
              f"scalar={scalar}, product={computed}, actual={deriv[beta]}")
        assert computed == deriv[beta], "Coefficient formula failed!"

    print("  ✓ All coefficients match the formula!")

    # ─── Experiment 4: Shadow size growth ───
    print()
    print("━" * 72)
    print("EXPERIMENT 4: Shadow size decay with order (Taylor jet geometry)")
    print("━" * 72)

    poly = random_sparse_polynomial(3, 6, 15)
    S = frozenset(poly.keys())
    print(f"  Support size: {len(S)}")
    print(f"  {'Order k':<10} {'Total shadow size':<20} {'# derivative gammas':<20}")
    for k in range(7):
        ts = total_shadow_order(k, S, 3)
        n_gammas = len(multi_indices_of_weight(k, 3))
        print(f"  {k:<10} {len(ts):<20} {n_gammas:<20}")

    # ─── Experiment 5: Counterexample search ───
    print()
    print("━" * 72)
    print("EXPERIMENT 5: Intensive counterexample search (k=3,4, 3-5 vars)")
    print("━" * 72)

    n_counterexamples = 0
    n_intensive_tests = 0
    for trial in range(100):
        n_vars = random.choice([3, 4, 5])
        max_deg = random.choice([3, 4, 5])
        n_terms = random.randint(5, 20)
        order = random.choice([3, 4])
        poly = random_sparse_polynomial(n_vars, max_deg, n_terms)
        S = frozenset(poly.keys())

        for gamma in multi_indices_of_weight(order, n_vars):
            predicted = shadow_along(S, gamma)
            deriv = compute_iterated_pderiv(poly, gamma)
            actual = frozenset(deriv.keys())
            n_intensive_tests += 1
            if predicted != actual:
                n_counterexamples += 1
                print(f"  COUNTEREXAMPLE at trial {trial}: "
                      f"γ={gamma}, predicted≠actual")
                print(f"    predicted\\actual: {predicted - actual}")
                print(f"    actual\\predicted: {actual - predicted}")

    print(f"  Tested {n_intensive_tests} shadow-derivative pairs")
    if n_counterexamples == 0:
        print(f"  ✓ No counterexamples found!")
    else:
        print(f"  ⚠ Found {n_counterexamples} counterexamples!")

    # ─── Scientific Summary ───
    print()
    print("=" * 72)
    print("SCIENTIFIC SUMMARY")
    print("=" * 72)
    print()
    print("Principle verified: For polynomials over ℚ, the support of every")
    print("iterated partial derivative ∂^γ p is EXACTLY the shadow of supp(p)")
    print("along γ. This is because:")
    print()
    print("  1. Each coefficient coeff_β(∂^γ p) = coeff_{β+γ}(p) · F(β,γ)")
    print("     where F(β,γ) = ∏ᵢ descFactorial(βᵢ+γᵢ, γᵢ) > 0 always.")
    print()
    print("  2. Each shadow element β has exactly ONE ancestor α = β + γ in S.")
    print("     There is no possibility of cancellation between distinct ancestors.")
    print()
    print("  3. Therefore, coeff_β(∂^γ p) ≠ 0 ⟺ coeff_{β+γ}(p) ≠ 0")
    print("     ⟺ β + γ ∈ supp(p) ⟺ β ∈ Shadow_γ(supp p).")
    print()
    print("This is UNCONDITIONAL over characteristic zero — no genericity")
    print("assumption needed. The 'generic exactness conjecture' is actually")
    print("a theorem: the universal regime IS the generic regime.")
    print()
    print("Implications:")
    print("  • Higher differential structure of sparse polynomials is fully")
    print("    determined by support geometry (combinatorial Taylor theory)")
    print("  • Derivative-space complexity can be computed from support alone")
    print("  • Shadow calculus provides an exact prediction algorithm for")
    print("    sparse symbolic differentiation")
    print()

if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Falling Factorial Scalars

Visualizes the falling factorial multi-index product that governs
coefficient transformation under iterated differentiation.

Shows that this scalar is ALWAYS positive — the key fact that makes
cancellation impossible over characteristic zero.
"""

import matplotlib.pyplot as plt
import numpy as np

def desc_factorial(n, k):
    r = 1
    for i in range(k): r *= (n - i)
    return r

def falling_factorial_multi_2d(beta, gamma):
    """For 2D multi-indices."""
    result = 1
    for b, g in zip(beta, gamma):
        result *= desc_factorial(b + g, g)
    return result

fig, axes = plt.subplots(2, 3, figsize=(16, 10))

# Show scalar values for different gamma directions
gammas = [(1, 0), (0, 1), (1, 1), (2, 0), (0, 2), (2, 1)]
titles = ['∂/∂x₁', '∂/∂x₂', '∂²/∂x₁∂x₂', '∂²/∂x₁²', '∂²/∂x₂²', '∂³/∂x₁²∂x₂']

for idx, (gamma, title) in enumerate(zip(gammas, titles)):
    ax = axes[idx // 3][idx % 3]

    max_b = 6
    data = np.zeros((max_b, max_b))
    for b1 in range(max_b):
        for b2 in range(max_b):
            beta = (b1, b2)
            data[b2, b1] = falling_factorial_multi_2d(beta, gamma)

    im = ax.imshow(data, cmap='YlGnBu', origin='lower',
                    interpolation='nearest', vmin=0)
    ax.set_xlabel('β₁', fontsize=11)
    ax.set_ylabel('β₂', fontsize=11)
    ax.set_title(f'{title}\nγ = {gamma}', fontsize=12)

    # Annotate cells with values
    for b1 in range(max_b):
        for b2 in range(max_b):
            val = int(data[b2, b1])
            if val > 0:
                color = 'white' if val > data.max() * 0.6 else 'black'
                ax.text(b1, b2, str(val), ha='center', va='center',
                       fontsize=7, color=color)

    plt.colorbar(im, ax=ax, shrink=0.8)

plt.suptitle('Falling Factorial Scalars: F(β, γ) = ∏ᵢ (βᵢ+γᵢ)!/βᵢ!\n'
             'Always positive → no cancellation possible over ℚ',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_falling_factorial.png', dpi=150, bbox_inches='tight')
print("Saved viz_falling_factorial.png")


#!/usr/bin/env python3
"""
Visualization: Shadow Profile Heatmap

Visualizes how the support shadow evolves across derivative orders.
For a random polynomial in 3 variables, shows |Shadow_γ(S)| for each
derivative direction γ at each order k, as a heatmap.

This illustrates the central principle: derivative supports are
combinatorially determined by support shadows.
"""

import matplotlib.pyplot as plt
import numpy as np
import random
from fractions import Fraction

# Inline all needed functions
def le_mi(a, b): return all(x <= y for x, y in zip(a, b))
def sub_mi(a, b): return tuple(x - y for x, y in zip(a, b))

def shadow_along(S, gamma):
    return frozenset(sub_mi(a, gamma) for a in S if le_mi(gamma, a))

def enumerate_multi_indices(k, n):
    if n == 0: return [()] if k == 0 else []
    if n == 1: return [(k,)]
    result = []
    for i in range(k + 1):
        for rest in enumerate_multi_indices(k - i, n - 1):
            result.append((i,) + rest)
    return result

def total_shadow_order(k, S, n_vars):
    result = set()
    for gamma in enumerate_multi_indices(k, n_vars):
        result.update(shadow_along(S, gamma))
    return frozenset(result)

def random_sparse_poly(n_vars, max_deg, n_terms, seed=42):
    random.seed(seed)
    poly = {}
    attempts = 0
    while len(poly) < n_terms and attempts < n_terms * 10:
        exp = tuple(random.randint(0, max_deg) for _ in range(n_vars))
        if exp not in poly:
            c = random.randint(-10, 10)
            if c != 0: poly[exp] = c
        attempts += 1
    return frozenset(poly.keys())

# Generate data
n_vars = 3
max_deg = 6
n_terms = 15
S = random_sparse_poly(n_vars, max_deg, n_terms)

max_order = 7
shadow_sizes = []
gamma_labels_per_order = []

for k in range(max_order + 1):
    gammas = enumerate_multi_indices(k, n_vars)
    sizes = [len(shadow_along(S, g)) for g in gammas]
    shadow_sizes.append(sizes)
    gamma_labels_per_order.append([str(g) for g in gammas])

# Create figure with two subplots
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 7))

# Left: Total shadow profile
orders = list(range(max_order + 1))
total_sizes = [len(total_shadow_order(k, S, n_vars)) for k in orders]
n_gammas = [len(enumerate_multi_indices(k, n_vars)) for k in orders]

ax1.bar(orders, total_sizes, color='steelblue', alpha=0.8, label='Total shadow size')
ax1.plot(orders, [len(S)] * len(orders), 'r--', label=f'Original support ({len(S)})')
ax1.set_xlabel('Derivative Order k', fontsize=12)
ax1.set_ylabel('|Shadow^(k)(S)|', fontsize=12)
ax1.set_title('Total Shadow Size by Derivative Order', fontsize=14)
ax1.legend(fontsize=11)
ax1.set_xticks(orders)

# Right: Heatmap of per-gamma shadow sizes for orders 1-4
max_gammas = max(len(shadow_sizes[k]) for k in range(1, min(5, max_order + 1)))
heatmap_data = np.zeros((4, max_gammas))
y_labels = []
x_labels_full = []

for idx, k in enumerate(range(1, 5)):
    sizes = shadow_sizes[k]
    labels = gamma_labels_per_order[k]
    for j, s in enumerate(sizes):
        heatmap_data[idx, j] = s
    y_labels.append(f'Order {k}')
    if len(labels) > len(x_labels_full):
        x_labels_full = labels + [''] * (max_gammas - len(labels))

im = ax1_right = ax2.imshow(heatmap_data, cmap='YlOrRd', aspect='auto',
                              interpolation='nearest')
ax2.set_xlabel('Derivative Direction γ', fontsize=12)
ax2.set_ylabel('Order', fontsize=12)
ax2.set_title('Shadow Size per Derivative Direction', fontsize=14)
ax2.set_yticks(range(4))
ax2.set_yticklabels(y_labels)

# Only label up to 15 x-ticks to avoid crowding
n_xticks = min(15, max_gammas)
ax2.set_xticks(range(n_xticks))
ax2.set_xticklabels(x_labels_full[:n_xticks], rotation=45, ha='right', fontsize=8)

plt.colorbar(im, ax=ax2, label='|Shadow_γ(S)|')

plt.suptitle(f'Higher-Order Shadow Structure (3 vars, {len(S)} terms, deg≤{max_deg})',
             fontsize=15, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_shadow_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_shadow_heatmap.png")


#!/usr/bin/env python3
"""
Visualization: Support and Shadow in 2D

Visualizes the support of a bivariate polynomial and its shadows along
various derivative directions. Shows how the shadow operation shifts and
filters the support set.

This makes the key idea tangible: differentiation is a shadow operation
on exponent lattice points.
"""

import matplotlib.pyplot as plt
import numpy as np

# Inline functions
def le_mi(a, b): return all(x <= y for x, y in zip(a, b))
def sub_mi(a, b): return tuple(x - y for x, y in zip(a, b))
def add_mi(a, b): return tuple(x + y for x, y in zip(a, b))

def shadow_along(S, gamma):
    return frozenset(sub_mi(a, gamma) for a in S if le_mi(gamma, a))

# Create a bivariate polynomial support
S = frozenset([
    (4, 0), (3, 1), (2, 2), (1, 3), (0, 4),  # degree 4
    (3, 0), (2, 1), (0, 3),                    # degree 3
    (2, 0), (1, 1),                              # degree 2
    (1, 0),                                       # degree 1
])

# Define derivative directions to show
directions = [
    ((1, 0), "∂/∂x₁", "tab:blue"),
    ((0, 1), "∂/∂x₂", "tab:red"),
    ((1, 1), "∂²/∂x₁∂x₂", "tab:green"),
    ((2, 0), "∂²/∂x₁²", "tab:purple"),
    ((2, 1), "∂³/∂x₁²∂x₂", "tab:orange"),
    ((3, 0), "∂³/∂x₁³", "tab:brown"),
]

fig, axes = plt.subplots(2, 3, figsize=(16, 10))
axes = axes.flatten()

for idx, (gamma, label, color) in enumerate(directions):
    ax = axes[idx]

    # Draw lattice grid
    for i in range(6):
        for j in range(6):
            ax.plot(i, j, '.', color='lightgray', markersize=3)

    # Draw original support
    xs = [p[0] for p in S]
    ys = [p[1] for p in S]
    ax.scatter(xs, ys, s=80, c='black', marker='s', label='Support S',
               zorder=5, alpha=0.3)

    # Draw shadow
    shadow = shadow_along(S, gamma)
    if shadow:
        sx = [p[0] for p in shadow]
        sy = [p[1] for p in shadow]
        ax.scatter(sx, sy, s=120, c=color, marker='o', label=f'Shadow',
                   zorder=6, edgecolors='black', linewidth=0.5)

    # Draw arrows from shadow to ancestor
    for beta in shadow:
        alpha = add_mi(beta, gamma)
        if alpha in S:
            ax.annotate('', xy=alpha, xytext=beta,
                       arrowprops=dict(arrowstyle='->', color=color, alpha=0.4, lw=1))

    ax.set_xlim(-0.5, 5.5)
    ax.set_ylim(-0.5, 5.5)
    ax.set_aspect('equal')
    ax.set_xlabel('x₁ exponent')
    ax.set_ylabel('x₂ exponent')
    ax.set_title(f'{label}, γ={gamma}\n|Shadow| = {len(shadow)}', fontsize=11)
    ax.legend(loc='upper right', fontsize=8)
    ax.grid(True, alpha=0.2)

plt.suptitle('Support Shadows: How Differentiation Maps Exponent Sets\n'
             '(■ = original support, ● = shadow = derivative support)',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_support_shadow.png', dpi=150, bbox_inches='tight')
print("Saved viz_support_shadow.png")
