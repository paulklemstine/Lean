#!/usr/bin/env python3
"""
Monstrous Moonshine: Computational Demonstrations

This script demonstrates the key mathematical structures of monstrous moonshine:
1. The j-function coefficients and their Monster decompositions
2. The multiplicity recovery algorithm
3. The inner product identity verification
4. McKay-Thompson series for small conjugacy classes
"""

from fractions import Fraction
from typing import List, Dict, Tuple
import math


# === Monster Group Constants ===

MONSTER_ORDER = (
    2**46 * 3**20 * 5**9 * 7**6 * 11**2 * 13**3
    * 17 * 19 * 23 * 29 * 31 * 41 * 47 * 59 * 71
)

SUPERSINGULAR_PRIMES = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 41, 47, 59, 71]

MONSTER_NUM_CLASSES = 194

# First few j-function coefficients (j(q) = q^{-1} + 744 + sum c_n q^n)
J_COEFFICIENTS = {
    -1: 1,
    0: 744,
    1: 196884,
    2: 21493760,
    3: 864299970,
    4: 20245856256,
    5: 333202640600,
    6: 4252023300096,
    7: 44656994071935,
    8: 401490886656000,
    9: 3176440229784420,
    10: 22567393309593600,
}

# Smallest Monster irrep dimensions
MONSTER_IRREP_DIMS = [
    1,          # trivial
    196883,     # smallest faithful
    21296876,   # second smallest
    842609326,  # third
    18538750076,
]

# Known decompositions of j-function coefficients
MOONSHINE_DECOMPOSITIONS = {
    1: [(0, 1), (1, 1)],                      # 196884 = 1 + 196883
    2: [(0, 1), (1, 1), (2, 1)],              # 21493760 = 1 + 196883 + 21296876
    3: [(0, 2), (1, 2), (2, 1), (3, 1)],      # 864299970 = 2 + 2*196883 + 21296876 + 842609326
}


def verify_thompson_observations():
    """Verify Thompson's moonshine observations."""
    print("=" * 60)
    print("Thompson's Moonshine Observations")
    print("=" * 60)

    # First observation: 196884 = 196883 + 1
    assert 196884 == 196883 + 1
    print(f"196884 = 196883 + 1  ✓")
    print(f"  (j-coeff c₁ = dim(ρ₁) + dim(ρ₀))")

    # Second observation: 21493760 = 21296876 + 196883 + 1
    assert 21493760 == 21296876 + 196883 + 1
    print(f"21493760 = 21296876 + 196883 + 1  ✓")
    print(f"  (j-coeff c₂ = dim(ρ₂) + dim(ρ₁) + dim(ρ₀))")

    # Third coefficient
    c3 = 864299970
    decomp = 842609326 + 21296876 + 2 * 196883 + 2 * 1
    assert c3 == decomp
    print(f"864299970 = 842609326 + 21296876 + 2×196883 + 2×1  ✓")
    print(f"  (j-coeff c₃ = dim(ρ₃) + dim(ρ₂) + 2·dim(ρ₁) + 2·dim(ρ₀))")
    print()


def verify_monster_order():
    """Verify properties of the Monster group order."""
    print("=" * 60)
    print("Monster Group Order Properties")
    print("=" * 60)

    print(f"|M| = {MONSTER_ORDER}")
    print(f"|M| ≈ {MONSTER_ORDER:.3e}")
    print(f"Number of digits: {len(str(MONSTER_ORDER))}")
    print()

    # Verify divisibility by 24
    assert MONSTER_ORDER % 24 == 0
    print(f"24 | |M|  ✓  (|M|/24 has {len(str(MONSTER_ORDER // 24))} digits)")

    # Supersingular primes
    print(f"\nSupersingular primes (prime divisors of |M|):")
    for p in SUPERSINGULAR_PRIMES:
        # Find exact power
        k = 0
        temp = MONSTER_ORDER
        while temp % p == 0:
            k += 1
            temp //= p
        print(f"  {p}^{k}", end="")
    print()

    # Product of supersingular primes
    prod = 1
    for p in SUPERSINGULAR_PRIMES:
        prod *= p
    print(f"\nProduct of supersingular primes: {prod}")
    print(f"Number of supersingular primes: {len(SUPERSINGULAR_PRIMES)}")
    print()


def demonstrate_multiplicity_recovery():
    """
    Demonstrate the multiplicity recovery theorem:
    mult(i, m) * |G| = sum_j |C_j| * chi_i(g_j) * a_m(g_j)

    We use a small example (S₃) to illustrate.
    """
    print("=" * 60)
    print("Multiplicity Recovery Theorem — S₃ Example")
    print("=" * 60)

    # S₃ has 3 conjugacy classes: {e}, {(12),(13),(23)}, {(123),(132)}
    # Class sizes: 1, 3, 2
    # Group order: 6
    # Character table:
    #         e   (12)  (123)
    # triv    1    1     1
    # sign    1   -1     1
    # std     2    0    -1

    n = 3
    class_sizes = [1, 3, 2]
    group_order = 6
    chi = [
        [Fraction(1), Fraction(1), Fraction(1)],     # trivial
        [Fraction(1), Fraction(-1), Fraction(1)],     # sign
        [Fraction(2), Fraction(0), Fraction(-1)],     # standard
    ]

    # Verify orthogonality
    print("\nVerifying row orthogonality for S₃:")
    for i in range(n):
        for j in range(n):
            inner = sum(
                Fraction(class_sizes[k]) * chi[i][k] * chi[j][k]
                for k in range(n)
            )
            expected = Fraction(group_order) if i == j else Fraction(0)
            assert inner == expected, f"Row orth failed: ({i},{j}): {inner} ≠ {expected}"
            if i <= j:
                print(f"  <χ_{i}, χ_{j}> = {inner} {'= |G| ✓' if i == j else '= 0 ✓'}")

    # Define a graded module: V₁ = triv ⊕ std (dimension 3)
    mult_grade1 = [1, 0, 1]  # 1 copy of triv, 0 sign, 1 standard

    # Compute McKay-Thompson coefficients
    print("\nMcKay-Thompson coefficients for V₁ = triv ⊕ std:")
    mckay = []
    for j in range(n):
        coeff = sum(
            Fraction(mult_grade1[i]) * chi[i][j]
            for i in range(n)
        )
        mckay.append(coeff)
        class_names = ["e", "(12)", "(123)"]
        print(f"  a₁({class_names[j]}) = {coeff}")

    # Apply multiplicity recovery
    print("\nMultiplicity recovery:")
    for i in range(n):
        recovered = sum(
            Fraction(class_sizes[j]) * chi[i][j] * mckay[j]
            for j in range(n)
        )
        recovered_mult = recovered / Fraction(group_order)
        rep_names = ["triv", "sign", "std"]
        print(f"  mult({rep_names[i]}, V₁) = {recovered}/{group_order} = {recovered_mult}"
              f" {'✓' if recovered_mult == Fraction(mult_grade1[i]) else '✗'}")

    # Verify inner product identity
    print("\nInner product identity verification:")
    lhs = sum(
        Fraction(class_sizes[j]) * mckay[j] * mckay[j]
        for j in range(n)
    )
    rhs = Fraction(group_order) * sum(
        Fraction(mult_grade1[i]) ** 2
        for i in range(n)
    )
    print(f"  LHS = Σ |C_j| · a₁(g_j)² = {lhs}")
    print(f"  RHS = |G| · Σ mult(i,1)² = {rhs}")
    print(f"  Equal: {lhs == rhs} ✓")
    print()


def burnside_dimension_identity():
    """Demonstrate sum of squared dimensions = group order."""
    print("=" * 60)
    print("Burnside's Dimension Identity")
    print("=" * 60)

    # S₃ example
    dims_S3 = [1, 1, 2]
    order_S3 = 6
    sum_sq = sum(d**2 for d in dims_S3)
    print(f"S₃: Σ dᵢ² = {' + '.join(f'{d}²' for d in dims_S3)} = {sum_sq} = |S₃| ✓")

    # S₄ example
    dims_S4 = [1, 1, 2, 3, 3]
    order_S4 = 24
    sum_sq = sum(d**2 for d in dims_S4)
    print(f"S₄: Σ dᵢ² = {' + '.join(f'{d}²' for d in dims_S4)} = {sum_sq} = |S₄| ✓")

    # A₅ example
    dims_A5 = [1, 3, 3, 4, 5]
    order_A5 = 60
    sum_sq = sum(d**2 for d in dims_A5)
    print(f"A₅: Σ dᵢ² = {' + '.join(f'{d}²' for d in dims_A5)} = {sum_sq} = |A₅| ✓")

    # Monster (partial)
    print(f"\nMonster (first 5 irreps of 194):")
    partial_sum = sum(d**2 for d in MONSTER_IRREP_DIMS)
    print(f"  Σ dᵢ² (first 5) = {partial_sum:.6e}")
    print(f"  |M| = {MONSTER_ORDER:.6e}")
    print(f"  These 5 account for {partial_sum/MONSTER_ORDER*100:.2f}% of |M|")
    print()


def j_function_coefficients_table():
    """Display the j-function coefficients and their moonshine decompositions."""
    print("=" * 60)
    print("j-Function Coefficients and Monster Decompositions")
    print("=" * 60)

    print(f"{'n':>4} {'c_n':>16}  Decomposition")
    print("-" * 60)
    for n in sorted(J_COEFFICIENTS.keys()):
        cn = J_COEFFICIENTS[n]
        if n in MOONSHINE_DECOMPOSITIONS:
            terms = []
            for (idx, mult) in MOONSHINE_DECOMPOSITIONS[n]:
                dim = MONSTER_IRREP_DIMS[idx]
                if mult == 1:
                    terms.append(f"d_{idx}")
                else:
                    terms.append(f"{mult}·d_{idx}")
            decomp_str = " + ".join(terms)
            # Verify
            total = sum(mult * MONSTER_IRREP_DIMS[idx]
                       for (idx, mult) in MOONSHINE_DECOMPOSITIONS[n])
            check = "✓" if total == cn else "✗"
            print(f"{n:>4} {cn:>16}  {decomp_str} {check}")
        else:
            print(f"{n:>4} {cn:>16}")

    print(f"\nLegend: d₀=1, d₁=196883, d₂=21296876, d₃=842609326")
    print()


def trace_dominance_check():
    """
    Demonstrate trace dominance: |tr(g|V)| ≤ dim(V) for finite group representations.
    """
    print("=" * 60)
    print("Trace Dominance Check")
    print("=" * 60)

    # S₃ character table
    chi = [
        [1, 1, 1],
        [1, -1, 1],
        [2, 0, -1],
    ]

    # For any representation V = ⊕ mult_i * ρ_i,
    # tr(g_j | V) = Σ mult_i * χ_i(g_j)
    # dim(V) = tr(e | V) = Σ mult_i * χ_i(e)

    print("S₃: checking |tr(g|V)| ≤ dim(V) for various representations\n")

    test_mults = [
        [1, 0, 0],  # trivial
        [0, 0, 1],  # standard
        [1, 1, 1],  # regular
        [2, 0, 3],  # 2·triv ⊕ 3·std
        [0, 1, 2],  # sign ⊕ 2·std
    ]

    class_names = ["e", "(12)", "(123)"]

    for mults in test_mults:
        rep_name = " ⊕ ".join(
            f"{m}·ρ_{i}" for i, m in enumerate(mults) if m > 0
        )
        traces = []
        for j in range(3):
            tr = sum(mults[i] * chi[i][j] for i in range(3))
            traces.append(tr)
        dim = traces[0]  # trace at identity = dimension

        violations = False
        trace_strs = []
        for j in range(3):
            ok = abs(traces[j]) <= dim
            trace_strs.append(f"|tr({class_names[j]})| = {abs(traces[j])} ≤ {dim} {'✓' if ok else '✗'}")
            if not ok:
                violations = True

        print(f"V = {rep_name} (dim={dim})")
        for s in trace_strs:
            print(f"  {s}")
        print()


if __name__ == "__main__":
    verify_thompson_observations()
    verify_monster_order()
    burnside_dimension_identity()
    j_function_coefficients_table()
    demonstrate_multiplicity_recovery()
    trace_dominance_check()


#!/usr/bin/env python3
"""
Visualization: Monstrous Moonshine Coefficient Growth

Plots the growth of j-function coefficients and their relationship
to Monster representation dimensions.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import math


def sigma3(n: int) -> int:
    """Sum of cubes of divisors of n."""
    return sum(d**3 for d in range(1, n + 1) if n % d == 0)


def compute_j_coefficients(num_terms: int) -> list:
    """Compute j-function coefficients via E_4^3 / Delta."""
    N = num_terms + 10

    e4 = [0] * N
    e4[0] = 1
    for n in range(1, N):
        e4[n] = 240 * sigma3(n)

    e4_sq = [0] * N
    for n in range(N):
        for k in range(n + 1):
            e4_sq[n] += e4[k] * e4[n - k]

    e4_cube = [0] * N
    for n in range(N):
        for k in range(n + 1):
            e4_cube[n] += e4_sq[k] * e4[n - k]

    p = [0] * N
    p[0] = 1
    for k in range(1, N):
        for _ in range(24):
            for n in range(N - 1, k - 1, -1):
                p[n] -= p[n - k]

    delta = [0] * N
    for n in range(1, N):
        delta[n] = p[n - 1]

    j_coeffs = [0] * num_terms
    for k in range(num_terms):
        rhs = e4_cube[k]
        for i in range(k):
            idx = k - i + 1
            if idx < N:
                rhs -= j_coeffs[i] * delta[idx]
        j_coeffs[k] = rhs // delta[1]

    return j_coeffs


def plot_coefficient_growth():
    """Plot the growth of j-function coefficients."""
    num_terms = 25
    coeffs = compute_j_coefficients(num_terms)

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left panel: log of coefficients
    ns = list(range(-1, num_terms - 1))
    log_coeffs = [math.log10(abs(c)) if c != 0 else 0 for c in coeffs]

    axes[0].bar(ns, log_coeffs, color='steelblue', alpha=0.8, edgecolor='navy')
    axes[0].set_xlabel('n', fontsize=12)
    axes[0].set_ylabel('log₁₀|cₙ|', fontsize=12)
    axes[0].set_title('j-Function Coefficients (log scale)', fontsize=14)
    axes[0].grid(axis='y', alpha=0.3)

    # Rademacher asymptotic: c_n ~ exp(4π√n) / (√2 · n^{3/4})
    rademacher_ns = np.arange(1, num_terms - 1)
    rademacher = [
        (4 * math.pi * math.sqrt(n)) / math.log(10) - 0.75 * math.log10(n)
        for n in rademacher_ns
    ]
    axes[0].plot(rademacher_ns, rademacher, 'r--', linewidth=2,
                 label='Rademacher asymptotic')
    axes[0].legend(fontsize=10)

    # Right panel: moonshine decomposition
    monster_dims = [1, 196883, 21296876, 842609326]
    decompositions = {
        1: {0: 1, 1: 1},
        2: {0: 1, 1: 1, 2: 1},
        3: {0: 2, 1: 2, 2: 1, 3: 1},
    }

    grades = [1, 2, 3]
    bottom = np.zeros(len(grades))
    colors = ['#2ecc71', '#3498db', '#9b59b6', '#e74c3c']
    labels = [f'ρ₀ (dim=1)', f'ρ₁ (dim=196883)', f'ρ₂ (dim=21296876)', f'ρ₃ (dim=842609326)']

    for rep_idx in range(4):
        heights = []
        for g in grades:
            if g in decompositions and rep_idx in decompositions[g]:
                mult = decompositions[g][rep_idx]
                heights.append(mult * monster_dims[rep_idx])
            else:
                heights.append(0)
        axes[1].bar(grades, heights, bottom=bottom, color=colors[rep_idx],
                    label=labels[rep_idx], alpha=0.8, edgecolor='black', linewidth=0.5)
        bottom += np.array(heights)

    axes[1].set_xlabel('Grade n', fontsize=12)
    axes[1].set_ylabel('Contribution to cₙ', fontsize=12)
    axes[1].set_title('Monster Decomposition of j-Coefficients', fontsize=14)
    axes[1].legend(fontsize=8, loc='upper left')
    axes[1].ticklabel_format(axis='y', style='scientific', scilimits=(0, 0))

    plt.tight_layout()
    plt.savefig('moonshine_coefficients.png', dpi=150, bbox_inches='tight')
    print("Saved: moonshine_coefficients.png")


def plot_supersingular_primes():
    """Visualize the supersingular primes and Monster order factorization."""
    fig, ax = plt.subplots(figsize=(12, 5))

    primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 41, 47, 59, 71]
    exponents = [46, 20, 9, 6, 2, 3, 1, 1, 1, 1, 1, 1, 1, 1, 1]

    colors = plt.cm.viridis(np.linspace(0.2, 0.9, len(primes)))

    bars = ax.bar(range(len(primes)), exponents, color=colors,
                  edgecolor='black', linewidth=0.5, alpha=0.85)

    ax.set_xticks(range(len(primes)))
    ax.set_xticklabels([str(p) for p in primes], fontsize=11)
    ax.set_xlabel('Supersingular Prime p', fontsize=13)
    ax.set_ylabel('Exponent in |M|', fontsize=13)
    ax.set_title('Monster Group Order: Prime Factorization\n'
                 '|M| = 2⁴⁶ · 3²⁰ · 5⁹ · 7⁶ · 11² · 13³ · 17 · 19 · 23 · 29 · 31 · 41 · 47 · 59 · 71',
                 fontsize=13)

    for bar, exp in zip(bars, exponents):
        ax.text(bar.get_x() + bar.get_width() / 2, bar.get_height() + 0.5,
                str(exp), ha='center', fontsize=10, fontweight='bold')

    ax.set_ylim(0, max(exponents) + 3)
    ax.grid(axis='y', alpha=0.3)

    plt.tight_layout()
    plt.savefig('supersingular_primes.png', dpi=150, bbox_inches='tight')
    print("Saved: supersingular_primes.png")


if __name__ == "__main__":
    plot_coefficient_growth()
    plot_supersingular_primes()
