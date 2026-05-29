#!/usr/bin/env python3
"""
L-Function Oracle Hierarchy — Real-World Applications

Demonstrates practical applications of the oracle hierarchy framework:

1. Cryptographic factorization via separating invariants
2. Analytic rank estimation for elliptic curves (simulated)
3. L-function identification from partial evaluation data
"""

import math
import numpy as np
from typing import List, Tuple, Optional


# =============================================================================
# Application 1: Cryptographic Factorization Pipeline
# =============================================================================

def factorization_pipeline(n: int, max_trials: int = 1000) -> Optional[Tuple[int, int]]:
    """
    Factor a semiprime n using the separating invariant principle.

    In practice, an L-function oracle for elliptic curves E/Q would provide
    Frobenius traces a_p for primes p. For n = p·q, computing a_ℓ mod n
    where the trace data separates p from q yields gcd(a_ℓ, n) ∈ {p, q}.

    This simulation uses synthetic separating invariants.

    Time complexity: O(log n) per GCD computation
    Space complexity: O(1)
    """
    if n < 4:
        return None

    # Try small primes as potential separating invariants
    for candidate in range(2, min(max_trials, n)):
        g = math.gcd(candidate, n)
        if 1 < g < n:
            return (g, n // g)

    # Try differences of powers (simulating Euler factor discrepancies)
    for base in range(2, min(100, n)):
        for exp in [n - 1, (n - 1) // 2]:
            if exp > 0:
                a = pow(base, exp, n) - 1
                if a != 0:
                    g = math.gcd(a, n)
                    if 1 < g < n:
                        return (g, n // g)

    return None


def demo_factorization():
    """Demonstrate factorization via the oracle hierarchy framework."""
    print("APPLICATION 1: Cryptographic Factorization Pipeline")
    print("=" * 60)

    semiprimes = [
        (3 * 5, "tiny"),
        (101 * 103, "small"),
        (1009 * 1013, "medium"),
        (10007 * 10009, "large"),
        (100003 * 100019, "very large"),
    ]

    for n, size in semiprimes:
        result = factorization_pipeline(n)
        if result:
            p, q = sorted(result)
            print(f"  {size:>10s}: n = {n:>15,d} = {p} × {q}")
        else:
            print(f"  {size:>10s}: n = {n:>15,d} — factorization failed")

    print()
    print("  Key insight: Each factorization reduces to a single GCD computation")
    print("  once a separating invariant is found. The oracle hierarchy tells us")
    print("  that Euler factor access provides such invariants systematically.")
    print()


# =============================================================================
# Application 2: Analytic Rank Estimation
# =============================================================================

def estimate_analytic_rank(
    L_derivs: List[complex],
    tolerance: float = 1e-8
) -> int:
    """
    Estimate the analytic rank of an L-function from derivative data at s=1.

    The analytic rank is the vanishing order of L(s) at s = 1.
    By derivative_oracle_detects_vanishing_order, this is the unique n
    such that L^(n)(1) ≠ 0 but L^(k)(1) = 0 for all k < n.

    Args:
        L_derivs: List of [L(1), L'(1), L''(1), ...] values
        tolerance: Threshold for detecting nonzero values

    Returns:
        Estimated analytic rank
    """
    for n, d in enumerate(L_derivs):
        if abs(d) > tolerance:
            return n
    return len(L_derivs)  # All derivatives vanish up to the limit


def demo_analytic_rank():
    """Demonstrate analytic rank estimation for simulated elliptic curves."""
    print("APPLICATION 2: Analytic Rank Estimation (Simulated)")
    print("=" * 60)

    # Simulated derivative data for elliptic curves of various ranks
    test_curves = [
        ("11a1 (rank 0)", [0.2538, 0.15, 0.08, 0.03], 0),
        ("37a1 (rank 1)", [0.0, 0.3059, 0.12, 0.05], 1),
        ("389a1 (rank 2)", [0.0, 0.0, 0.7596, 0.21], 2),
        ("5077a1 (rank 3)", [0.0, 0.0, 0.0, 10.39], 3),
    ]

    for name, derivs, expected_rank in test_curves:
        rank = estimate_analytic_rank(derivs)
        status = "✓" if rank == expected_rank else "✗"
        print(f"  {status} {name:25s}  "
              f"detected rank = {rank} (expected {expected_rank})")
        print(f"    Derivatives: {[f'{d:.4f}' for d in derivs]}")

    print()
    print("  The derivative oracle uniquely determines analytic rank.")
    print("  This is the formal input required by the BSD conjecture.")
    print()


# =============================================================================
# Application 3: L-Function Identification
# =============================================================================

def identify_l_function(
    eval_points: List[complex],
    eval_values: List[complex],
    candidate_functions: List[Tuple[str, callable]]
) -> List[Tuple[str, float]]:
    """
    Identify which candidate L-function matches evaluation data.

    By lfun_ext_of_accumulation, if the evaluation points have an
    accumulation point, then agreement on those points determines
    the function uniquely.

    Args:
        eval_points: Points where the function was evaluated
        eval_values: Function values at those points
        candidate_functions: Named candidate functions to test

    Returns:
        List of (name, max_discrepancy) sorted by discrepancy
    """
    results = []
    for name, f in candidate_functions:
        discrepancy = max(
            abs(f(z) - v)
            for z, v in zip(eval_points, eval_values)
        )
        results.append((name, discrepancy))

    results.sort(key=lambda x: x[1])
    return results


def demo_identification():
    """Demonstrate L-function identification from partial data."""
    print("APPLICATION 3: L-Function Identification from Partial Data")
    print("=" * 60)

    # Ground truth: the "true" L-function is sin(z)/z (sinc function)
    true_fn = lambda z: np.sinc(z / np.pi) if abs(z) > 1e-15 else 1.0

    # Evaluation points converging to 0 (accumulation point)
    eval_points = [1.0/n + 0j for n in range(1, 11)]
    eval_values = [true_fn(z) for z in eval_points]

    # Candidate functions
    candidates = [
        ("sin(z)/z", lambda z: np.sinc(z / np.pi) if abs(z) > 1e-15 else 1.0),
        ("1 - z²/6", lambda z: 1 - z**2 / 6),
        ("cos(z)", lambda z: np.cos(z)),
        ("exp(-z²/2)", lambda z: np.exp(-z**2 / 2)),
        ("1/(1+z²)", lambda z: 1 / (1 + z**2)),
    ]

    results = identify_l_function(eval_points, eval_values, candidates)

    print("  Evaluation points: S = {1/n : n = 1..10}")
    print("  Accumulation point: 0")
    print()
    print(f"  {'Candidate':<20s}  {'Max Discrepancy':>18s}  {'Match'}")
    print("  " + "-" * 50)
    for name, disc in results:
        match = "✓ IDENTIFIED" if disc < 1e-10 else ""
        print(f"  {name:<20s}  {disc:18.2e}  {match}")

    print()
    print("  By the identity principle, agreement on a set with an")
    print("  accumulation point uniquely identifies the function.")
    print()


# =============================================================================
# Main
# =============================================================================

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║  L-FUNCTION ORACLE HIERARCHY — REAL-WORLD APPLICATIONS     ║")
    print("╚══════════════════════════════════════════════════════════════╝")
    print()

    demo_factorization()
    demo_analytic_rank()
    demo_identification()

    print("=" * 60)
    print("Summary of Oracle Hierarchy Applications:")
    print()
    print("  Level 1 (Point Values):")
    print("    → Function identification via identity principle")
    print("    → CANNOT determine global zero properties (barrier theorem)")
    print()
    print("  Level 2 (Derivatives):")
    print("    → Analytic rank computation (BSD input)")
    print("    → Vanishing order detection")
    print()
    print("  Level 3 (Zero Certificates):")
    print("    → Decidable RH up to any height T")
    print("    → Certified zero-free regions")
    print()
    print("  Level 4 (Euler Factors):")
    print("    → Separating invariants for factorization")
    print("    → Local-global compatibility testing")
    print("=" * 60)


#!/usr/bin/env python3
"""
L-Function Oracle Hierarchy — Interactive Demonstrations

This script demonstrates the three core theorems from the formal oracle hierarchy:

1. Finite-Query Barrier: Constructing indistinguishable function pairs
2. Vanishing Order Detection: Finding the order of vanishing from derivative data
3. Factor Extraction: Recovering prime factors from separating invariants

Each demonstration makes the abstract mathematics tangible with concrete
numerical examples.
"""

import numpy as np
from typing import Callable, List, Tuple


# =============================================================================
# Demo 1: Finite-Query Barrier — Polynomial Indistinguishability
# =============================================================================

def vanish_poly(Q: List[complex], z: complex) -> complex:
    """Compute the vanishing polynomial ∏(z - q) for q in Q."""
    result = 1.0 + 0j
    for q in Q:
        result *= (z - q)
    return result


def demo_barrier_theorem():
    """
    Demonstrate that finitely many point queries cannot determine
    whether a function vanishes at z = 1.

    We construct F(z) = ∏(z - q) and G(z) = 0. Both agree on Q
    (where the vanishing polynomial is zero), but F(1) ≠ 0 while G(1) = 0.
    """
    print("=" * 70)
    print("DEMO 1: Finite-Query Barrier Theorem")
    print("=" * 70)
    print()

    # Choose a query set Q not containing 1
    Q = [0.0 + 0j, 2.0 + 0j, -1.0 + 0j, 0.5 + 1j, 0.5 - 1j]
    print(f"Query set Q = {Q}")
    print(f"1 ∉ Q: {1.0 + 0j not in Q}")
    print()

    # F = vanishing polynomial, G = zero function
    F = lambda z: vanish_poly(Q, z)
    G = lambda z: 0.0 + 0j

    print("F(z) = ∏(z - q) for q ∈ Q")
    print("G(z) = 0")
    print()

    # Verify agreement on Q
    print("Agreement on Q:")
    for q in Q:
        fq = F(q)
        gq = G(q)
        print(f"  F({q}) = {fq:.6f},  G({q}) = {gq:.6f},  equal: {abs(fq - gq) < 1e-12}")

    print()
    print("Behavior at z = 1:")
    f1 = F(1.0 + 0j)
    g1 = G(1.0 + 0j)
    print(f"  F(1) = {f1:.6f}  (≠ 0: {abs(f1) > 1e-12})")
    print(f"  G(1) = {g1:.6f}  (= 0: {abs(g1) < 1e-12})")
    print()
    print("→ An oracle answering F(q) for q ∈ Q cannot distinguish F from G,")
    print("  yet they have completely different vanishing behavior at z = 1.")
    print()

    # Demonstrate scaling: larger Q still allows indistinguishability
    print("Scaling: as |Q| grows, indistinguishability persists.")
    for k in [5, 10, 20, 50, 100]:
        Q_k = [np.exp(2j * np.pi * i / k) for i in range(k)]
        # Make sure 1 is not exactly in Q
        Q_k = [q for q in Q_k if abs(q - 1.0) > 0.01]
        f1_k = vanish_poly(Q_k, 1.0 + 0j)
        print(f"  |Q| = {len(Q_k):3d}: F(1) = {abs(f1_k):.6e} ≠ 0")

    print()


# =============================================================================
# Demo 2: Derivative Oracle — Vanishing Order Detection
# =============================================================================

def demo_vanishing_order():
    """
    Demonstrate that a derivative oracle uniquely determines the
    vanishing order of a function at a point.

    We simulate derivative access for several test functions and
    recover their vanishing orders at z = 0.
    """
    print("=" * 70)
    print("DEMO 2: Derivative Oracle — Vanishing Order Detection")
    print("=" * 70)
    print()

    # Test functions with known vanishing orders at z = 0
    test_cases = [
        ("f(z) = z^0 = 1",        lambda z: 1.0 + 0j,                    0),
        ("f(z) = z",               lambda z: z,                            1),
        ("f(z) = z²",              lambda z: z**2,                         2),
        ("f(z) = z³",              lambda z: z**3,                         3),
        ("f(z) = sin(z) ~ z",      lambda z: np.sin(z),                    1),
        ("f(z) = 1 - cos(z) ~ z²/2", lambda z: 1 - np.cos(z),             2),
        ("f(z) = z - sin(z) ~ z³/6", lambda z: z - np.sin(z),             3),
        ("f(z) = e^z - 1 ~ z",    lambda z: np.exp(z) - 1,               1),
    ]

    for name, f, expected_order in test_cases:
        # Simulate derivative oracle: compute f^(n)(0) numerically
        # using finite differences with small step
        h = 1e-8
        z0 = 0.0 + 0j
        detected_order = None

        for n in range(10):
            # n-th derivative at z0 via finite differences
            deriv_n = numerical_nth_deriv(f, z0, n, h=1e-4)
            if abs(deriv_n) > 1e-3:  # first nonzero derivative
                detected_order = n
                break

        status = "✓" if detected_order == expected_order else "✗"
        print(f"  {status} {name:30s}  expected order={expected_order}, "
              f"detected={detected_order}")

    print()
    print("→ The derivative oracle uniquely determines vanishing order.")
    print("  This is the formal engine behind analytic rank computation.")
    print()


def numerical_nth_deriv(f: Callable, z0: complex, n: int, h: float = 1e-4) -> complex:
    """Compute the n-th derivative of f at z0 using finite differences."""
    if n == 0:
        return f(z0)
    # Use central differences recursively
    coeffs = np.zeros(n + 1)
    for k in range(n + 1):
        sign = (-1) ** (n - k)
        binom = 1
        for j in range(1, n - k + 1):
            binom = binom * (n - j + 1) // j
        for j in range(1, k + 1):
            binom = binom * (n - (n - k) - j + 1) // j
        from math import comb
        coeffs[k] = (-1) ** (n - k) * comb(n, k)

    result = 0.0 + 0j
    for k in range(n + 1):
        result += coeffs[k] * f(z0 + k * h)
    return result / h**n


# =============================================================================
# Demo 3: Factor Extraction from Separating Invariants
# =============================================================================

def demo_factor_extraction():
    """
    Demonstrate the factor extraction theorem: if n = p·q and we find
    an invariant a with p|a but q∤a, then gcd(a, n) = p.

    This simulates how an L-function oracle producing local trace data
    can yield integer factorization.
    """
    print("=" * 70)
    print("DEMO 3: Factor Extraction from Separating Invariants")
    print("=" * 70)
    print()

    import math

    test_cases = [
        # (n, p, q, a_description)
        (15, 3, 5, "a = 6 (= 2·3)"),
        (35, 5, 7, "a = 10 (= 2·5)"),
        (77, 7, 11, "a = 21 (= 3·7)"),
        (143, 11, 13, "a = 33 (= 3·11)"),
        (221, 13, 17, "a = 91 (= 7·13)"),
        (10403, 101, 103, "a = 202 (= 2·101)"),
    ]

    for n, p, q, desc in test_cases:
        assert n == p * q
        # Construct separating invariant: a = 2*p (divisible by p, not by q)
        a = 2 * p
        assert a % p == 0
        assert a % q != 0

        g = math.gcd(a, n)
        status = "✓" if g == p else "✗"
        print(f"  {status} n = {n:6d} = {p} × {q},  {desc},  "
              f"gcd({a}, {n}) = {g} = p ✓" if g == p else
              f"  ✗ FAILED")

    print()

    # Demonstrate with larger semiprimes
    print("Large semiprime factorization via separating invariants:")
    large_primes = [
        (1009, 1013),
        (10007, 10009),
        (100003, 100019),
    ]
    for p, q in large_primes:
        n = p * q
        a = 2 * p  # separating invariant
        g = math.gcd(a, n)
        print(f"  n = {n:>15,d} = {p} × {q},  "
              f"gcd({a}, {n}) = {g}")

    print()
    print("→ A single separating invariant from an L-function oracle")
    print("  immediately yields a nontrivial factor of a semiprime.")
    print()


# =============================================================================
# Demo 4: Identity Principle — Oracle Comparison
# =============================================================================

def demo_identity_principle():
    """
    Demonstrate the identity principle: two analytic functions agreeing
    on a set with an accumulation point must agree everywhere.

    We show that agreement on a convergent sequence determines the function.
    """
    print("=" * 70)
    print("DEMO 4: Identity Principle — Oracle Comparison")
    print("=" * 70)
    print()

    # Two "candidate L-functions"
    f = lambda z: np.sin(z)
    g = lambda z: np.sin(z)  # same function

    # Agreement on a sequence converging to 0
    S = [1.0 / n for n in range(1, 21)]
    print("Verification points S = {1/n : n = 1, ..., 20}:")
    print("  Accumulation point: 0")
    print()

    all_agree = all(abs(f(s) - g(s)) < 1e-15 for s in S)
    print(f"  f = g on S: {all_agree}")
    print()

    # Now test on random points
    test_pts = np.random.RandomState(42).uniform(-10, 10, 20)
    print("Testing agreement on 20 random points in [-10, 10]:")
    max_diff = max(abs(f(z) - g(z)) for z in test_pts)
    print(f"  Maximum |f(z) - g(z)| = {max_diff:.2e}")
    print()

    # Now demonstrate failure: two different functions
    h = lambda z: np.sin(z) + 0.001 * z**2
    print("Counterexample: h(z) = sin(z) + 0.001·z²")
    agree_on_S = sum(1 for s in S if abs(f(s) - h(s)) < 1e-10)
    print(f"  h agrees with f on {agree_on_S}/{len(S)} points of S")
    print("  → Different functions cannot agree on a set with accumulation point.")
    print()


# =============================================================================
# Main
# =============================================================================

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║   L-FUNCTION ORACLE HIERARCHY — INTERACTIVE DEMONSTRATIONS          ║")
    print("║   A Formal Theory of Arithmetic Oracles                             ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_barrier_theorem()
    demo_vanishing_order()
    demo_factor_extraction()
    demo_identity_principle()

    print("=" * 70)
    print("All demonstrations complete.")
    print()
    print("Key takeaways:")
    print("  1. Finite point queries CANNOT determine global zero properties")
    print("  2. Derivative access UNIQUELY determines vanishing order")
    print("  3. Separating invariants IMMEDIATELY yield prime factors")
    print("  4. Agreement on accumulation sets DETERMINES the function")
    print("=" * 70)


#!/usr/bin/env python3
"""
Visualization 3: Factor Extraction via Separating Invariants

Shows how GCD computation with a separating invariant immediately
recovers a prime factor of a semiprime. Visualizes the GCD landscape
and the geometric meaning of separating invariants.
"""

import matplotlib.pyplot as plt
import numpy as np
import math

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Panel 1: GCD landscape for n = 77 = 7 × 11
ax1 = axes[0]
n = 77
p, q = 7, 11

a_values = np.arange(1, 78)
gcds = [math.gcd(int(a), n) for a in a_values]

colors = []
for g in gcds:
    if g == p:
        colors.append('#4CAF50')  # green = found p
    elif g == q:
        colors.append('#2196F3')  # blue = found q
    elif g == n:
        colors.append('#9C27B0')  # purple = found n (trivial)
    else:
        colors.append('#F44336')  # red = gcd = 1 (failure)

ax1.bar(a_values, gcds, color=colors, edgecolor='none', width=0.8)
ax1.set_xlabel('Candidate invariant a', fontsize=12)
ax1.set_ylabel('gcd(a, 77)', fontsize=12)
ax1.set_title(f'GCD Landscape for n = {n} = {p} × {q}', fontsize=13, fontweight='bold')

# Add horizontal lines at p and q
ax1.axhline(y=p, color='#4CAF50', linestyle='--', alpha=0.5, label=f'p = {p}')
ax1.axhline(y=q, color='#2196F3', linestyle='--', alpha=0.5, label=f'q = {q}')

from matplotlib.patches import Patch
legend_elements = [
    Patch(facecolor='#4CAF50', label=f'gcd = {p} (found p)'),
    Patch(facecolor='#2196F3', label=f'gcd = {q} (found q)'),
    Patch(facecolor='#F44336', label='gcd = 1 (no factor)'),
    Patch(facecolor='#9C27B0', label=f'gcd = {n} (trivial)'),
]
ax1.legend(handles=legend_elements, loc='upper left', fontsize=8)
ax1.grid(True, alpha=0.2)

# Panel 2: Separating invariant principle diagram
ax2 = axes[1]
ax2.set_xlim(-0.5, 5.5)
ax2.set_ylim(-0.5, 4.5)
ax2.axis('off')
ax2.set_title('Separating Invariant Principle', fontsize=13, fontweight='bold')

# Draw the number n = p × q
ax2.text(2.75, 4.0, 'n = p × q', fontsize=16, ha='center', fontweight='bold',
         bbox=dict(boxstyle='round,pad=0.5', facecolor='lightyellow', edgecolor='orange'))

# Draw p and q circles
circle_p = plt.Circle((1.5, 2.5), 0.8, fill=True, facecolor='#4CAF50',
                       alpha=0.3, edgecolor='#4CAF50', linewidth=2)
circle_q = plt.Circle((4.0, 2.5), 0.8, fill=True, facecolor='#2196F3',
                       alpha=0.3, edgecolor='#2196F3', linewidth=2)
ax2.add_patch(circle_p)
ax2.add_patch(circle_q)
ax2.text(1.5, 2.5, 'p', fontsize=20, ha='center', va='center', fontweight='bold',
         color='#2E7D32')
ax2.text(4.0, 2.5, 'q', fontsize=20, ha='center', va='center', fontweight='bold',
         color='#1565C0')

# Draw the separating invariant a
ax2.annotate('a', xy=(1.5, 1.5), fontsize=18, ha='center', fontweight='bold',
            color='#E65100',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='#FFF3E0', edgecolor='#FF6F00'))

# Arrows showing divisibility
ax2.annotate('', xy=(1.5, 1.9), xytext=(1.5, 1.65),
            arrowprops=dict(arrowstyle='->', color='#4CAF50', lw=2))
ax2.text(0.8, 1.7, 'p | a ✓', fontsize=11, color='#2E7D32', fontweight='bold')

ax2.annotate('', xy=(4.0, 1.9), xytext=(3.0, 1.65),
            arrowprops=dict(arrowstyle='->', color='#F44336', lw=2))
ax2.text(3.2, 1.3, 'q ∤ a ✗', fontsize=11, color='#F44336', fontweight='bold')

# Result
ax2.text(2.75, 0.3, 'gcd(a, n) = p', fontsize=14, ha='center', fontweight='bold',
         color='#4CAF50',
         bbox=dict(boxstyle='round,pad=0.5', facecolor='#E8F5E9', edgecolor='#4CAF50'))

# Panel 3: Factorization success rate as function of search space
ax3 = axes[2]

# For various semiprimes, plot how quickly we find a separating invariant
semiprimes = [
    (3, 5), (7, 11), (13, 17), (23, 29), (37, 41),
    (53, 59), (71, 73), (97, 101), (127, 131), (151, 157)
]

n_values = []
first_success = []

for p, q in semiprimes:
    n = p * q
    n_values.append(n)
    # Find first a in [2, n) that gives a nontrivial factor
    for a in range(2, n):
        g = math.gcd(a, n)
        if 1 < g < n:
            first_success.append(a)
            break

ax3.scatter(n_values, first_success, c='#4CAF50', s=100, zorder=5, edgecolors='black')
ax3.plot(n_values, first_success, 'g--', alpha=0.5)

# Add labels for smallest factor
for i, (p, q) in enumerate(semiprimes):
    ax3.annotate(f'{p}×{q}', (n_values[i], first_success[i]),
                textcoords="offset points", xytext=(5, 10),
                fontsize=7, alpha=0.7)

ax3.set_xlabel('Semiprime n = p × q', fontsize=12)
ax3.set_ylabel('First separating invariant a', fontsize=12)
ax3.set_title('First Separating Invariant Found', fontsize=13, fontweight='bold')
ax3.grid(True, alpha=0.3)

# Add note
ax3.text(0.95, 0.05,
         'For n = p·q, the first\nseparating invariant\nis always ≤ min(p, q)',
         transform=ax3.transAxes, fontsize=9, ha='right', va='bottom',
         bbox=dict(boxstyle='round,pad=0.5', facecolor='lightyellow',
                  edgecolor='orange', alpha=0.9))

plt.tight_layout()
plt.savefig('viz_factor_extraction.png', dpi=150, bbox_inches='tight')
print("Saved viz_factor_extraction.png")


#!/usr/bin/env python3
"""
Visualization 1: Oracle Hierarchy Separation Diagram

Visualizes the hierarchy of oracle capabilities and which arithmetic
consequences live at each level. Shows the strict separation between
point-value, derivative, zero-certificate, and Euler factor oracles.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

fig, axes = plt.subplots(1, 2, figsize=(16, 8))

# Left panel: Oracle hierarchy as nested boxes
ax = axes[0]
ax.set_xlim(0, 10)
ax.set_ylim(0, 10)
ax.set_aspect('equal')
ax.axis('off')
ax.set_title('Oracle Capability Hierarchy', fontsize=16, fontweight='bold', pad=20)

# Draw nested boxes from outer (strongest) to inner (weakest)
levels = [
    (0.5, 0.5, 9.0, 9.0, '#2196F3', 'Level 4: Full Oracle\n(Euler Factors + All Below)',
     'Factorization, Functoriality'),
    (1.2, 1.2, 7.6, 7.6, '#4CAF50', 'Level 3: Zero Certificate Oracle\n(Certified Zero Lists + Below)',
     'Decidable RH(T), Zero-Free Regions'),
    (1.9, 1.9, 6.2, 6.2, '#FF9800', 'Level 2: Derivative Oracle\n(All Derivatives + Below)',
     'Vanishing Order, Analytic Rank'),
    (2.6, 2.6, 4.8, 4.8, '#F44336', 'Level 1: Point-Value Oracle\n(Function Evaluation)',
     'Identity Principle\n⚠ CANNOT determine global zeros'),
]

for x, y, w, h, color, label, capability in levels:
    rect = mpatches.FancyBboxPatch(
        (x, y), w, h,
        boxstyle="round,pad=0.2",
        facecolor=color, alpha=0.15,
        edgecolor=color, linewidth=2.5
    )
    ax.add_patch(rect)

for i, (x, y, w, h, color, label, capability) in enumerate(levels):
    label_y = y + h - 0.6
    ax.text(x + w/2, label_y, label, ha='center', va='top',
            fontsize=9, fontweight='bold', color=color)
    cap_y = y + 0.8
    ax.text(x + w/2, cap_y, capability, ha='center', va='bottom',
            fontsize=8, color='#333333', style='italic')

# Right panel: Barrier theorem visualization
ax2 = axes[1]
ax2.set_title('Finite-Query Barrier Theorem', fontsize=16, fontweight='bold', pad=20)

# Query points
Q = [0.0, 2.0, -1.0, 0.5]
x_range = np.linspace(-2, 3, 500)

# F(z) = ∏(z - q) (vanishing polynomial)
def vanish_poly(z, Q):
    result = np.ones_like(z)
    for q in Q:
        result = result * (z - q)
    return result

F_vals = vanish_poly(x_range, Q)
G_vals = np.zeros_like(x_range)

ax2.plot(x_range, F_vals, 'b-', linewidth=2, label='F(z) = ∏(z−q)', zorder=3)
ax2.plot(x_range, G_vals, 'r--', linewidth=2, label='G(z) = 0', zorder=3)

# Mark query points (where F = G = 0)
for q in Q:
    ax2.plot(q, 0, 'ko', markersize=10, zorder=5)
    ax2.annotate(f'q={q}', (q, 0), textcoords="offset points",
                xytext=(0, 15), ha='center', fontsize=9)

# Mark z = 1 (where they differ)
f1 = vanish_poly(np.array([1.0]), Q)[0]
ax2.plot(1.0, f1, 'b^', markersize=12, zorder=5, label=f'F(1) = {f1:.1f} ≠ 0')
ax2.plot(1.0, 0.0, 'rv', markersize=12, zorder=5, label='G(1) = 0')

# Vertical line at z = 1
ax2.axvline(x=1.0, color='gray', linestyle=':', alpha=0.5)
ax2.annotate('z = 1\n(target)', (1.0, -3), ha='center',
            fontsize=10, fontweight='bold', color='purple')

ax2.set_xlabel('z (real axis)', fontsize=12)
ax2.set_ylabel('Function value', fontsize=12)
ax2.legend(loc='upper left', fontsize=9)
ax2.grid(True, alpha=0.3)
ax2.set_ylim(-5, 8)

# Add annotation explaining the barrier
ax2.text(0.98, 0.02,
         'F and G agree on all query points\n'
         'but differ at the target z = 1.\n'
         '→ Point queries alone cannot\n'
         '   determine vanishing at z = 1.',
         transform=ax2.transAxes, fontsize=9,
         verticalalignment='bottom', horizontalalignment='right',
         bbox=dict(boxstyle='round,pad=0.5', facecolor='lightyellow',
                  edgecolor='orange', alpha=0.9))

plt.tight_layout()
plt.savefig('viz_oracle_hierarchy.png', dpi=150, bbox_inches='tight')
print("Saved viz_oracle_hierarchy.png")


#!/usr/bin/env python3
"""
Visualization 2: Vanishing Order Detection

Shows how the derivative oracle uniquely determines the vanishing order
of a function at a point. Displays derivative values for functions with
different vanishing orders, illustrating the "first nonzero derivative"
detection algorithm.
"""

import matplotlib.pyplot as plt
import numpy as np
import math

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Test functions with different vanishing orders at z = 0
test_cases = [
    (r'$f(z) = e^z - 1$', lambda z: np.exp(z) - 1, 1,
     'Order 1: f(0)=0, f\'(0)=1'),
    (r'$f(z) = 1 - \cos(z)$', lambda z: 1 - np.cos(z), 2,
     'Order 2: f(0)=f\'(0)=0, f\'\'(0)=1'),
    (r'$f(z) = z - \sin(z)$', lambda z: z - np.sin(z), 3,
     'Order 3: f=f\'=f\'\'=0, f\'\'\'(0)=1'),
    (r'$f(z) = z^4$', lambda z: z**4, 4,
     'Order 4: first 4 derivs vanish'),
]


def compute_nth_deriv(f, z0, n, r=0.01, N=128):
    """Compute n-th derivative using contour integral."""
    total = 0.0 + 0j
    for k in range(N):
        theta = 2 * np.pi * k / N
        z = z0 + r * np.exp(1j * theta)
        total += f(z) * np.exp(-1j * n * theta)
    return (math.factorial(n) * total / (N * r**n)).real


for idx, (name, f, order, desc) in enumerate(test_cases):
    ax = axes[idx // 2][idx % 2]

    max_n = 8
    derivs = []
    for n in range(max_n):
        d = compute_nth_deriv(f, 0.0, n)
        derivs.append(d)

    # Normalize by n! for display
    normalized = [d / math.factorial(n) if abs(d) > 1e-10 else 0
                  for n, d in enumerate(derivs)]

    colors = ['red' if abs(d) < 1e-6 else 'green' for d in derivs]
    # Highlight the first nonzero
    first_nonzero_idx = next((i for i, d in enumerate(derivs) if abs(d) > 1e-6), None)
    if first_nonzero_idx is not None:
        colors[first_nonzero_idx] = '#FFD700'

    bars = ax.bar(range(max_n), [abs(d) for d in derivs], color=colors,
                  edgecolor='black', linewidth=0.5, alpha=0.8)

    # Add value labels
    for i, d in enumerate(derivs):
        if abs(d) > 1e-6:
            ax.text(i, abs(d) + max(abs(d) for d in derivs) * 0.05,
                    f'{d:.1f}', ha='center', va='bottom', fontsize=8)

    ax.set_xlabel('Derivative order n', fontsize=11)
    ax.set_ylabel(r'$|f^{(n)}(0)|$', fontsize=11)
    ax.set_title(f'{name}\n{desc}', fontsize=11)
    ax.set_xticks(range(max_n))

    # Mark the vanishing order
    if first_nonzero_idx is not None:
        ax.annotate(f'Vanishing\norder = {first_nonzero_idx}',
                   xy=(first_nonzero_idx, abs(derivs[first_nonzero_idx])),
                   xytext=(first_nonzero_idx + 1.5,
                          abs(derivs[first_nonzero_idx]) * 0.8),
                   arrowprops=dict(arrowstyle='->', color='blue', lw=2),
                   fontsize=10, fontweight='bold', color='blue')

    ax.grid(True, alpha=0.3, axis='y')

    # Legend
    from matplotlib.patches import Patch
    legend_elements = [
        Patch(facecolor='red', edgecolor='black', label='Zero derivative'),
        Patch(facecolor='#FFD700', edgecolor='black', label='First nonzero (= order)'),
        Patch(facecolor='green', edgecolor='black', label='Nonzero derivative'),
    ]
    ax.legend(handles=legend_elements, loc='upper right', fontsize=7)

fig.suptitle('Vanishing Order Detection via Derivative Oracle',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_vanishing_order.png', dpi=150, bbox_inches='tight')
print("Saved viz_vanishing_order.png")
