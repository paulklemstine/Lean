"""
Chebyshev's Sum Inequality — Interactive Demonstration
=====================================================

This script demonstrates Chebyshev's sum inequality and the rearrangement
inequality with concrete numerical examples and visualizations.

Chebyshev's Sum Inequality states:
    For co-monotone sequences a₁ ≤ a₂ ≤ ... ≤ aₙ and b₁ ≤ b₂ ≤ ... ≤ bₙ:
    n * Σ aᵢbᵢ ≥ (Σ aᵢ)(Σ bᵢ)

Equivalently, the average of products ≥ the product of averages.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import permutations
import os

def chebyshev_demo():
    """Demonstrate Chebyshev's sum inequality with concrete examples."""
    print("=" * 70)
    print("CHEBYSHEV'S SUM INEQUALITY")
    print("For co-monotone sequences a and b of length n:")
    print("  n · Σ aᵢbᵢ ≥ (Σ aᵢ)(Σ bᵢ)")
    print("=" * 70)

    # Example 1: Simple increasing sequences
    a = np.array([1, 3, 5, 7])
    b = np.array([2, 4, 6, 8])
    n = len(a)

    lhs = sum(a) * sum(b)
    rhs = n * sum(a * b)

    print(f"\nExample 1: a = {a}, b = {b}")
    print(f"  n = {n}")
    print(f"  (Σ aᵢ)(Σ bᵢ) = {sum(a)} × {sum(b)} = {lhs}")
    print(f"  n · Σ aᵢbᵢ   = {n} × {sum(a*b)} = {rhs}")
    print(f"  Inequality holds: {lhs} ≤ {rhs} ✓" if lhs <= rhs else "  VIOLATION!")
    print(f"  Gap = {rhs - lhs}")

    # Example 2: Revenue optimization (price × quantity)
    print("\n" + "-" * 70)
    print("Example 2: Revenue Optimization")
    print("-" * 70)
    prices = np.array([10, 20, 50, 100])
    quantities = np.array([5, 15, 30, 50])

    n = len(prices)
    concordant_sum = n * sum(prices * quantities)
    product_of_sums = sum(prices) * sum(quantities)

    print(f"  Prices (sorted):     {prices}")
    print(f"  Quantities (sorted): {quantities}")
    print(f"  Concordant pairing revenue: n·Σpᵢqᵢ = {concordant_sum}")
    print(f"  Product of sums: (Σpᵢ)(Σqᵢ) = {product_of_sums}")
    print(f"  Chebyshev gap: {concordant_sum - product_of_sums}")

    # Example 3: Anti-monotone case
    print("\n" + "-" * 70)
    print("Example 3: Reverse Chebyshev (contra-monotone sequences)")
    print("-" * 70)
    a = np.array([1, 3, 5, 7])
    b_rev = np.array([8, 6, 4, 2])

    n = len(a)
    lhs_anti = n * sum(a * b_rev)
    rhs_anti = sum(a) * sum(b_rev)

    print(f"  a = {a} (monotone), b = {b_rev} (antitone)")
    print(f"  n · Σ aᵢbᵢ   = {n} × {sum(a*b_rev)} = {lhs_anti}")
    print(f"  (Σ aᵢ)(Σ bᵢ) = {sum(a)} × {sum(b_rev)} = {rhs_anti}")
    print(f"  Reverse inequality holds: {lhs_anti} ≤ {rhs_anti} ✓" if lhs_anti <= rhs_anti else "  VIOLATION!")


def rearrangement_demo():
    """Demonstrate the rearrangement inequality by exhaustive search."""
    print("\n" + "=" * 70)
    print("REARRANGEMENT INEQUALITY")
    print("Concordant pairing maximizes Σ aᵢbᵢ, discordant minimizes it.")
    print("=" * 70)

    a = np.array([1, 3, 5])
    b = np.array([2, 4, 6])

    print(f"\na = {a}, b = {b}")
    print(f"\nAll possible pairings Σ aᵢb_σ(i):")
    print(f"{'Permutation σ':<20} {'Pairing':<30} {'Sum':>8}")
    print("-" * 60)

    results = []
    for perm in permutations(range(len(b))):
        b_perm = b[list(perm)]
        pairing = " + ".join(f"{a[i]}·{b_perm[i]}" for i in range(len(a)))
        s = sum(a[i] * b_perm[i] for i in range(len(a)))
        results.append((perm, pairing, s))

    results.sort(key=lambda x: x[2])

    for perm, pairing, s in results:
        marker = ""
        if s == max(r[2] for r in results):
            marker = " ← CONCORDANT (maximum)"
        elif s == min(r[2] for r in results):
            marker = " ← DISCORDANT (minimum)"
        print(f"  {str(perm):<18} {pairing:<30} {s:>8}{marker}")


def covariance_identity_demo():
    """Demonstrate the algebraic identity underlying Chebyshev's inequality."""
    print("\n" + "=" * 70)
    print("CHEBYSHEV IDENTITY (Covariance Decomposition)")
    print("2(n·Σaᵢbᵢ - (Σaᵢ)(Σbᵢ)) = Σᵢ Σⱼ (aᵢ-aⱼ)(bᵢ-bⱼ)")
    print("=" * 70)

    a = np.array([1.0, 3.0, 5.0, 7.0])
    b = np.array([2.0, 4.0, 6.0, 8.0])
    n = len(a)

    lhs = 2 * (n * np.sum(a * b) - np.sum(a) * np.sum(b))
    rhs = sum((a[i] - a[j]) * (b[i] - b[j]) for i in range(n) for j in range(n))

    print(f"\na = {a}, b = {b}, n = {n}")
    print(f"\nLHS: 2(n·Σaᵢbᵢ - (Σaᵢ)(Σbᵢ)) = {lhs}")
    print(f"RHS: Σᵢ Σⱼ (aᵢ-aⱼ)(bᵢ-bⱼ) = {rhs}")
    print(f"Identity holds: {np.isclose(lhs, rhs)} ✓")

    print(f"\nAll pairwise products (aᵢ-aⱼ)(bᵢ-bⱼ) ≥ 0 for co-monotone sequences:")
    all_nonneg = True
    for i in range(n):
        for j in range(n):
            val = (a[i] - a[j]) * (b[i] - b[j])
            if val < 0:
                all_nonneg = False
            if i != j:
                print(f"  (a[{i}]-a[{j}])(b[{i}]-b[{j}]) = ({a[i]-a[j]:+.0f})({b[i]-b[j]:+.0f}) = {val:+.0f} ≥ 0 ✓")
    print(f"\nAll terms non-negative: {all_nonneg} ✓")


def abel_summation_demo():
    """Demonstrate Abel summation (summation by parts)."""
    print("\n" + "=" * 70)
    print("ABEL SUMMATION (Summation by Parts)")
    print("Σ aₖ(bₖ₊₁ - bₖ) = aₙbₙ - a₀b₀ - Σ (aₖ₊₁ - aₖ)bₖ₊₁")
    print("=" * 70)

    n = 5
    a = np.array([10, 8, 6, 4, 2, 1], dtype=float)
    b = np.array([0, 1, 3, 6, 10, 15], dtype=float)

    lhs = sum(a[k] * (b[k+1] - b[k]) for k in range(n))
    rhs = a[n] * b[n] - a[0] * b[0] - sum((a[k+1] - a[k]) * b[k+1] for k in range(n))

    print(f"\na = {a[:n+1]}")
    print(f"b = {b[:n+1]}")
    print(f"\nLHS: Σ aₖ(bₖ₊₁ - bₖ) = {lhs}")
    print(f"RHS: aₙbₙ - a₀b₀ - Σ(aₖ₊₁-aₖ)bₖ₊₁ = {rhs}")
    print(f"Identity holds: {np.isclose(lhs, rhs)} ✓")

    # Abel's inequality demo
    print("\n" + "-" * 70)
    print("ABEL'S INEQUALITY")
    print("|Σ aₖcₖ| ≤ a₀ · M  (a decreasing ≥ 0, |partial sums c| ≤ M)")
    print("-" * 70)

    n = 20
    a_dec = np.array([1.0 / (k + 1) for k in range(n)])
    c_osc = np.array([(-1)**k for k in range(n)], dtype=float)

    partial_sums = [sum(c_osc[:k]) for k in range(n + 1)]
    M = max(abs(s) for s in partial_sums)

    weighted_sum = abs(sum(a_dec * c_osc))
    bound = a_dec[0] * M

    print(f"\na[k] = 1/(k+1) (harmonic, decreasing)")
    print(f"c[k] = (-1)^k (alternating)")
    print(f"M = max|partial sums of c| = {M}")
    print(f"|Σ aₖcₖ| = {weighted_sum:.6f}")
    print(f"a₀ · M   = {bound:.6f}")
    print(f"Inequality holds: {weighted_sum <= bound + 1e-10} ✓")


def application_resource_allocation():
    """Application: optimal resource allocation using Chebyshev."""
    print("\n" + "=" * 70)
    print("APPLICATION: Optimal Task Assignment")
    print("=" * 70)
    print("""
Chebyshev's inequality gives a mathematical foundation for assignment:

  Given workers with skill levels s₁ ≤ s₂ ≤ ... ≤ sₙ
  and tasks with difficulty   d₁ ≤ d₂ ≤ ... ≤ dₙ,

  Total "synergy" Σ sᵢ · dσ(i) is MAXIMIZED when best workers
  are assigned to hardest tasks (concordant assignment).
    """)

    skills = np.array([2, 5, 7, 9])
    difficulties = np.array([1, 3, 6, 8])

    concordant = sum(skills * difficulties)
    discordant = sum(skills * difficulties[::-1])
    np.random.seed(42)
    random_sums = [sum(skills * np.random.permutation(difficulties)) for _ in range(1000)]

    print(f"Worker skills:      {skills}")
    print(f"Task difficulties:  {difficulties}")
    print(f"\nConcordant (optimal):  Σ sᵢdᵢ = {concordant}")
    print(f"Discordant (worst):    Σ sᵢd_{{n+1-i}} = {discordant}")
    print(f"Random (avg of 1000):  E[Σ sᵢd_σ(i)] ≈ {np.mean(random_sums):.1f}")
    print(f"  (theory predicts:    (Σsᵢ)(Σdᵢ)/n = {sum(skills)*sum(difficulties)/len(skills):.1f})")


def create_visualizations():
    """Create matplotlib visualizations of the inequalities."""
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # Plot 1: Rearrangement inequality — all permutations
    ax1 = axes[0]
    a = np.array([1, 2, 3, 4, 5])
    b = np.array([1, 2, 3, 4, 5])

    sums = []
    for perm in permutations(range(len(b))):
        b_perm = b[list(perm)]
        sums.append(sum(a * b_perm))

    sums.sort()
    ax1.hist(sums, bins=20, color='steelblue', edgecolor='white', alpha=0.8)
    ax1.axvline(x=max(sums), color='green', linewidth=2, linestyle='--',
                label=f'Concordant: {max(sums)}')
    ax1.axvline(x=min(sums), color='red', linewidth=2, linestyle='--',
                label=f'Discordant: {min(sums)}')
    ax1.set_xlabel('Σ aᵢ b_σ(i)', fontsize=12)
    ax1.set_ylabel('Count', fontsize=12)
    ax1.set_title('Rearrangement Inequality\n(all permutations of [1..5])', fontsize=13)
    ax1.legend(fontsize=10)

    # Plot 2: Chebyshev gap as function of monotonicity
    ax2 = axes[1]
    n = 10
    a_fixed = np.arange(1, n + 1, dtype=float)

    alphas = np.linspace(-1, 1, 100)
    gaps = []
    for alpha in alphas:
        if alpha >= 0:
            b_seq = alpha * np.arange(1, n + 1) + (1 - alpha) * np.ones(n)
        else:
            b_seq = -alpha * np.arange(n, 0, -1) + (1 + alpha) * np.ones(n)
        gap = n * np.sum(a_fixed * b_seq) - np.sum(a_fixed) * np.sum(b_seq)
        gaps.append(gap)

    ax2.plot(alphas, gaps, color='steelblue', linewidth=2)
    ax2.axhline(y=0, color='gray', linewidth=0.5)
    ax2.axvline(x=0, color='gray', linewidth=0.5)
    ax2.fill_between(alphas, gaps, 0,
                      where=[g >= 0 for g in gaps], color='green', alpha=0.15, label='Co-monotone')
    ax2.fill_between(alphas, gaps, 0,
                      where=[g < 0 for g in gaps], color='red', alpha=0.15, label='Contra-monotone')
    ax2.set_xlabel('Monotonicity parameter α', fontsize=12)
    ax2.set_ylabel('n·Σaᵢbᵢ − (Σaᵢ)(Σbᵢ)', fontsize=12)
    ax2.set_title("Chebyshev's Gap", fontsize=13)
    ax2.legend(fontsize=10)

    # Plot 3: QM-AM inequality
    ax3 = axes[2]
    ns = range(2, 51)
    ratios = []
    np.random.seed(42)
    for nn in ns:
        a_rand = np.random.exponential(1, nn)
        ratio = np.sum(a_rand) ** 2 / (nn * np.sum(a_rand ** 2))
        ratios.append(ratio)

    ax3.scatter(list(ns), ratios, color='steelblue', s=15, alpha=0.8)
    ax3.axhline(y=1, color='red', linewidth=2, linestyle='--', label='Upper bound: 1')
    ax3.set_xlabel('n', fontsize=12)
    ax3.set_ylabel('(Σ aᵢ)² / (n · Σ aᵢ²)', fontsize=12)
    ax3.set_title('Sum-of-Squares Bound\n(Σ aᵢ)² ≤ n · Σ aᵢ²', fontsize=13)
    ax3.legend(fontsize=10)
    ax3.set_ylim(0, 1.1)

    plt.tight_layout()
    output_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'chebyshev_plots.png')
    plt.savefig(output_path, dpi=150, bbox_inches='tight')
    print(f"\nVisualization saved to: {output_path}")
    plt.close()


if __name__ == "__main__":
    chebyshev_demo()
    rearrangement_demo()
    covariance_identity_demo()
    abel_summation_demo()
    application_resource_allocation()
    try:
        create_visualizations()
    except Exception as e:
        print(f"\n[Visualization skipped: {e}]")
    print("\n" + "=" * 70)
    print("All demonstrations complete!")
    print("=" * 70)
