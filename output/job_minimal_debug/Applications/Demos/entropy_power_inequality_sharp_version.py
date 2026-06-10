#!/usr/bin/env python3
"""
Demo: Entropy Power Inequality — Sharp Version

Demonstrates the key results from the formalization:
1. Shannon entropy properties
2. Entropy power inequality verification
3. Brunn-Minkowski connection
4. Rényi vs Shannon entropy ordering
5. Stability analysis
"""

import math
from algorithms import (
    shannon_entropy, renyi_entropy, entropy_power, gaussian_proximity,
    brunn_minkowski_defect, volume_entropy_power, discrete_convolution,
    verify_epi_discrete, epi_profile, stability_analysis
)


def demo_entropy_basics():
    """Demonstrate basic entropy properties."""
    print("=" * 60)
    print("1. SHANNON ENTROPY PROPERTIES")
    print("=" * 60)

    # Uniform distribution
    n = 8
    uniform = [1.0 / n] * n
    h_uniform = shannon_entropy(uniform)
    print(f"\nUniform on {n} elements:")
    print(f"  H(uniform) = {h_uniform:.6f}")
    print(f"  log({n})    = {math.log(n):.6f}")
    print(f"  Match: {abs(h_uniform - math.log(n)) < 1e-10}")

    # Dirac distribution
    dirac = [0.0] * n
    dirac[0] = 1.0
    h_dirac = shannon_entropy(dirac)
    print(f"\nDirac delta:")
    print(f"  H(dirac) = {h_dirac:.6f} (should be 0)")

    # Non-uniform distribution
    p = [0.5, 0.25, 0.125, 0.0625, 0.03125, 0.015625, 0.0078125, 0.0078125]
    h_p = shannon_entropy(p)
    print(f"\nGeometric-like distribution:")
    print(f"  H(p) = {h_p:.6f}")
    print(f"  H(p) ≤ log(8) = {math.log(8):.6f}: {h_p <= math.log(8) + 1e-10}")
    print(f"  Gaussian proximity = {gaussian_proximity(p):.6f}")


def demo_entropy_power():
    """Demonstrate entropy power properties."""
    print("\n" + "=" * 60)
    print("2. ENTROPY POWER")
    print("=" * 60)

    n = 4
    uniform = [1.0 / n] * n
    dirac = [0.0] * n
    dirac[0] = 1.0

    print(f"\nEntropy power N(p) = exp(2·H(p)/d) with d=1:")
    print(f"  N(uniform on {n}) = {entropy_power(uniform):.6f}")
    print(f"  N(dirac)          = {entropy_power(dirac):.6f} (should be 1)")
    print(f"  N ≥ 1 always: verified by theorem entropy_power_ge_one")


def demo_epi_verification():
    """Verify EPI for several distribution pairs."""
    print("\n" + "=" * 60)
    print("3. ENTROPY POWER INEQUALITY VERIFICATION")
    print("=" * 60)

    test_cases = [
        ("Uniform(4) * Uniform(4)", [0.25]*4, [0.25]*4),
        ("Uniform(2) * Uniform(3)", [0.5, 0.5], [1/3, 1/3, 1/3]),
        ("Skewed * Uniform(2)", [0.9, 0.1], [0.5, 0.5]),
        ("Geometric * Geometric", [0.5, 0.25, 0.25], [0.5, 0.25, 0.25]),
    ]

    for name, p, q in test_cases:
        result = verify_epi_discrete(p, q)
        print(f"\n  {name}:")
        print(f"    N(p)={result['N_p']:.4f}, N(q)={result['N_q']:.4f}")
        print(f"    N(p*q)={result['N_conv']:.4f} ≥ N(p)+N(q)={result['sum']:.4f}")
        print(f"    Deficit: {result['deficit']:.4f}")
        print(f"    AM-GM bound: 2√(N(p)N(q)) = {result['am_gm_bound']:.4f}")
        print(f"    EPI holds: {result['epi_holds']}")


def demo_brunn_minkowski():
    """Demonstrate BM-EPI connection."""
    print("\n" + "=" * 60)
    print("4. BRUNN-MINKOWSKI CONNECTION")
    print("=" * 60)

    # 1D intervals: [0,a-1] + [0,b-1] = [0,a+b-2]
    cases = [(3, 4), (5, 5), (2, 8), (10, 10)]
    for a, b in cases:
        card_sum = a + b - 1
        defect = brunn_minkowski_defect(a, b, card_sum, d=1)
        vep_a = volume_entropy_power(a)
        vep_b = volume_entropy_power(b)
        vep_s = volume_entropy_power(card_sum)
        print(f"\n  |A|={a}, |B|={b}, |A+B|={card_sum}:")
        print(f"    BM defect (d=1): {defect:.4f} ≥ 0: {defect >= -1e-10}")
        print(f"    Vol EP: N(A)={vep_a:.2f}, N(B)={vep_b:.2f}, N(A+B)={vep_s:.2f}")
        print(f"    EPI analog: N(A+B)={vep_s:.2f} ≥ N(A)+N(B)={vep_a+vep_b:.2f}: {vep_s >= vep_a + vep_b - 1e-10}")


def demo_renyi_ordering():
    """Demonstrate Rényi ≤ Shannon ordering."""
    print("\n" + "=" * 60)
    print("5. RÉNYI ENTROPY ORDERING (H₂ ≤ H₁)")
    print("=" * 60)

    distributions = [
        ("Uniform(8)", [1/8]*8),
        ("Skewed", [0.5, 0.2, 0.1, 0.08, 0.05, 0.04, 0.02, 0.01]),
        ("Near-Dirac", [0.95, 0.01, 0.01, 0.01, 0.01, 0.01, 0.0, 0.0]),
        ("Bimodal", [0.4, 0.4, 0.05, 0.05, 0.05, 0.05, 0.0, 0.0]),
    ]

    for name, p in distributions:
        h1 = shannon_entropy(p)
        h2 = renyi_entropy(p, 2.0)
        print(f"\n  {name}:")
        print(f"    H₁ = {h1:.6f}")
        print(f"    H₂ = {h2:.6f}")
        print(f"    H₂ ≤ H₁: {h2 <= h1 + 1e-10} (gap = {h1 - h2:.6f})")


def demo_iterated_convolution():
    """Demonstrate linear growth of entropy power under iteration."""
    print("\n" + "=" * 60)
    print("6. ITERATED CONVOLUTION — ENTROPIC CLT")
    print("=" * 60)

    p = [0.6, 0.3, 0.1]
    print(f"\n  Base distribution p = {p}")
    print(f"  H(p) = {shannon_entropy(p):.6f}")
    print(f"  N(p) = {entropy_power(p):.6f}")

    current = p
    n_base = entropy_power(p)
    for k in range(1, 8):
        current = discrete_convolution(current, p)
        n_k = entropy_power(current)
        h_k = shannon_entropy(current)
        bound = (k + 1) * n_base
        support = len(current)
        print(f"\n  k={k}: p^{{{k+1}*}} on {support} points")
        print(f"    H = {h_k:.4f}, N = {n_k:.4f}")
        print(f"    (k+1)·N(p) = {bound:.4f}, N ≥ bound: {n_k >= bound - 1e-6}")
        print(f"    Normalized H/log(support) = {h_k/math.log(support):.4f} → 1 (CLT)")


def demo_stability():
    """Demonstrate stability analysis."""
    print("\n" + "=" * 60)
    print("7. STABILITY ANALYSIS")
    print("=" * 60)

    import random
    random.seed(42)

    results = stability_analysis(8, num_samples=500)

    # Statistics
    gp_values = [r["gaussian_proximity"] for r in results]
    gaps = [r["renyi_gap"] for r in results]

    print(f"\n  Tested 500 random distributions on Fin 8:")
    print(f"  Gaussian proximity: min={min(gp_values):.4f}, max={max(gp_values):.4f}, mean={sum(gp_values)/len(gp_values):.4f}")
    print(f"  H₁ - H₂ gap: min={min(gaps):.6f}, max={max(gaps):.4f}, mean={sum(gaps)/len(gaps):.4f}")
    print(f"  H₂ ≤ H₁ always: {all(g >= -1e-10 for g in gaps)}")

    # Test conjecture: gaussian_proximity ≤ C for all distributions
    print(f"\n  Conjecture check: gaussianProximity(p) ≤ log(n) = {math.log(8):.4f}")
    print(f"  Max observed: {max(gp_values):.4f}")
    print(f"  Conjecture holds: {max(gp_values) <= math.log(8) + 1e-10}")


if __name__ == "__main__":
    demo_entropy_basics()
    demo_entropy_power()
    demo_epi_verification()
    demo_brunn_minkowski()
    demo_renyi_ordering()
    demo_iterated_convolution()
    demo_stability()

    print("\n" + "=" * 60)
    print("ALL DEMOS COMPLETE")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Entropy landscape on the probability simplex.

Shows how Shannon entropy varies over the 3-simplex (distributions on 3 elements),
with contour lines highlighting the maximum at the uniform distribution.
"""
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.tri as tri


def shannon_entropy_3(p1, p2):
    """Compute Shannon entropy for (p1, p2, 1-p1-p2)."""
    p3 = 1.0 - p1 - p2
    h = 0.0
    for p in [p1, p2, p3]:
        if p > 1e-15:
            h -= p * np.log(p)
    return h


def barycentric_to_cartesian(l1, l2, l3):
    """Convert barycentric coordinates to Cartesian."""
    x = 0.5 * (2 * l2 + l3)
    y = (np.sqrt(3) / 2) * l3
    return x, y


def main():
    n = 200
    points = []
    values = []
    for i in range(n + 1):
        for j in range(n + 1 - i):
            k = n - i - j
            p1, p2, p3 = i / n, j / n, k / n
            if p1 + p2 + p3 > 0.999:
                x, y = barycentric_to_cartesian(p1, p2, p3)
                points.append((x, y))
                values.append(shannon_entropy_3(p1, p2))

    points = np.array(points)
    values = np.array(values)

    fig, ax = plt.subplots(1, 1, figsize=(10, 9))

    triang = tri.Triangulation(points[:, 0], points[:, 1])
    tcf = ax.tricontourf(triang, values, levels=30, cmap='viridis')
    ax.tricontour(triang, values, levels=10, colors='white', linewidths=0.5, alpha=0.5)

    plt.colorbar(tcf, ax=ax, label='Shannon Entropy H(p)', shrink=0.8)

    # Draw simplex boundary
    corners = np.array([[0, 0], [1, 0], [0.5, np.sqrt(3)/2], [0, 0]])
    ax.plot(corners[:, 0], corners[:, 1], 'k-', linewidth=2)

    # Mark vertices
    ax.annotate('(1,0,0)', (0, 0), fontsize=12, ha='right', va='top')
    ax.annotate('(0,1,0)', (1, 0), fontsize=12, ha='left', va='top')
    ax.annotate('(0,0,1)', (0.5, np.sqrt(3)/2), fontsize=12, ha='center', va='bottom')

    # Mark center (uniform)
    cx, cy = barycentric_to_cartesian(1/3, 1/3, 1/3)
    ax.plot(cx, cy, 'r*', markersize=15, zorder=5)
    ax.annotate(f'Uniform\nH = log(3) ≈ {np.log(3):.3f}', (cx, cy),
                fontsize=11, ha='center', va='bottom', color='red',
                xytext=(0, 15), textcoords='offset points')

    ax.set_title('Shannon Entropy on the Probability Simplex\n'
                 'Maximum at uniform distribution (our Theorem entropy_eq_log_iff_uniform)',
                 fontsize=14)
    ax.set_aspect('equal')
    ax.axis('off')
    plt.tight_layout()
    plt.savefig('viz_entropy_landscape.png', dpi=150, bbox_inches='tight')
    print("Saved viz_entropy_landscape.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Entropy power growth under iterated convolution.

Demonstrates the linear growth theorem (epi_iterated_growth):
N(X^{*k}) ≥ k · N(X), verified numerically for several distributions.
"""
import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def shannon_entropy(p):
    """Compute Shannon entropy."""
    return -sum(pi * math.log(pi) for pi in p if pi > 1e-15)


def entropy_power(p, d=1):
    """Compute entropy power."""
    return math.exp(2 * shannon_entropy(p) / d)


def discrete_convolution(p, q):
    """Convolve two distributions."""
    m, n = len(p), len(q)
    result = [0.0] * (m + n - 1)
    for i in range(m):
        for j in range(n):
            result[i + j] += p[i] * q[j]
    return result


def main():
    distributions = {
        'Uniform(3)': [1/3, 1/3, 1/3],
        'Skewed [0.7, 0.2, 0.1]': [0.7, 0.2, 0.1],
        'Near-Dirac [0.9, 0.05, 0.05]': [0.9, 0.05, 0.05],
        'Bernoulli(1/2)': [0.5, 0.5],
    }

    fig, axes = plt.subplots(1, 2, figsize=(16, 7))

    # Plot 1: Entropy power growth
    ax1 = axes[0]
    max_k = 10
    for name, p in distributions.items():
        n_base = entropy_power(p)
        ks = list(range(max_k + 1))
        n_values = []
        current = p
        for k in range(max_k + 1):
            if k == 0:
                n_values.append(n_base)
            else:
                current = discrete_convolution(current, p)
                n_values.append(entropy_power(current))

        ax1.plot(ks, n_values, 'o-', label=f'{name}', markersize=4)
        # Plot linear bound
        ax1.plot(ks, [(k + 1) * n_base for k in ks], '--', alpha=0.4)

    ax1.set_xlabel('Convolution count k', fontsize=12)
    ax1.set_ylabel('Entropy power N(X^{*k})', fontsize=12)
    ax1.set_title('Entropy Power Growth Under Iterated Convolution\n'
                   'Solid: actual, Dashed: linear bound (k+1)·N(X)', fontsize=13)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Plot 2: Normalized entropy approaching maximum
    ax2 = axes[1]
    for name, p in distributions.items():
        current = p
        ratios = [shannon_entropy(p) / math.log(len(p))]
        for k in range(1, max_k + 1):
            current = discrete_convolution(current, p)
            h = shannon_entropy(current)
            h_max = math.log(len(current))
            ratios.append(h / h_max)

        ax2.plot(range(max_k + 1), ratios, 'o-', label=f'{name}', markersize=4)

    ax2.axhline(y=1.0, color='red', linestyle=':', alpha=0.5, label='Gaussian limit')
    ax2.set_xlabel('Convolution count k', fontsize=12)
    ax2.set_ylabel('H(X^{*k}) / log(support)', fontsize=12)
    ax2.set_title('Entropy Normalization → 1 (Entropic CLT)\n'
                   'Distributions approach maximum entropy', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.set_ylim(0.5, 1.05)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_epi_growth.png', dpi=150, bbox_inches='tight')
    print("Saved viz_epi_growth.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Rényi entropy ordering H₂ ≤ H₁.

Demonstrates the proved theorem renyi2_le_shannon by plotting the
Shannon vs Rényi-2 entropy for random distributions, showing
that all points lie below the diagonal.
"""
import math
import random
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def shannon_entropy(p):
    """Compute Shannon entropy."""
    return -sum(pi * math.log(pi) for pi in p if pi > 1e-15)


def renyi_entropy_2(p):
    """Compute Rényi entropy of order 2 (collision entropy)."""
    s = sum(pi ** 2 for pi in p if pi > 1e-15)
    if s <= 0:
        return 0
    return -math.log(s)


def main():
    random.seed(42)
    n_values = [3, 5, 8, 16]
    fig, axes = plt.subplots(2, 2, figsize=(14, 12))

    for idx, n in enumerate(n_values):
        ax = axes[idx // 2][idx % 2]
        h1_list = []
        h2_list = []

        for _ in range(2000):
            raw = [random.expovariate(1.0) for _ in range(n)]
            total = sum(raw)
            p = [x / total for x in raw]
            h1_list.append(shannon_entropy(p))
            h2_list.append(renyi_entropy_2(p))

        ax.scatter(h1_list, h2_list, alpha=0.3, s=8, c='steelblue')
        max_h = math.log(n) * 1.05
        ax.plot([0, max_h], [0, max_h], 'r-', linewidth=2, label='H₂ = H₁')
        ax.plot(math.log(n), math.log(n), 'r*', markersize=15,
                label=f'Uniform: H = log({n})')

        ax.set_xlabel('Shannon Entropy H₁', fontsize=11)
        ax.set_ylabel('Rényi Entropy H₂', fontsize=11)
        ax.set_title(f'n = {n}: H₂ ≤ H₁ (renyi2_le_shannon)', fontsize=12)
        ax.legend(fontsize=9)
        ax.grid(True, alpha=0.3)
        ax.set_aspect('equal')
        ax.set_xlim(0, max_h)
        ax.set_ylim(0, max_h)

    plt.suptitle('Rényi-Shannon Entropy Ordering: H₂(p) ≤ H₁(p)\n'
                 'All 8000 points lie on or below the diagonal (formally proved)',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('viz_renyi_ordering.png', dpi=150, bbox_inches='tight')
    print("Saved viz_renyi_ordering.png")


if __name__ == "__main__":
    main()
