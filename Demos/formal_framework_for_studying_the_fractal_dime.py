#!/usr/bin/env python3
"""
Tropical Truth Geometry: Demonstration

Numerical examples demonstrating the key results:
1. Density-exponent duality verification
2. Strict dimension bounds
3. Tropical sum of spectra
4. Entropy-dimension bridge
5. Computable approximation convergence
6. Spectrum comparison principle
"""

from algorithms import (
    growth_exponent,
    truth_density,
    density_exponent_duality_check,
    tropical_density_functional,
    tropical_sum_spectrum,
    binary_entropy,
    computable_approximation,
    spectrum_comparison,
    generate_example_spectrum,
)
import math


def demo_density_exponent_duality():
    """Demonstrate the density-exponent duality identity."""
    print("=" * 60)
    print("DEMO 1: Density-Exponent Duality")
    print("log(d(n)) = n · (α(n) - 1) · log 2")
    print("=" * 60)

    # Example: truth set where N(n) = Fibonacci(n+1)
    fib = [1, 1]
    for i in range(2, 21):
        fib.append(fib[-1] + fib[-2])

    print(f"\n{'n':>3} {'N(n)':>10} {'d(n)':>12} {'α(n)':>8} {'LHS':>12} {'RHS':>12} {'Match':>6}")
    print("-" * 70)

    for n in range(1, 16):
        count = min(fib[n], 2**n)  # Ensure count ≤ 2^n
        if count <= 0:
            continue
        d = truth_density(count, n)
        alpha = growth_exponent(count, n)
        lhs, rhs, match = density_exponent_duality_check(count, n)
        print(f"{n:3d} {count:10d} {d:12.8f} {alpha:8.5f} {lhs:12.6f} {rhs:12.6f} {'✓' if match else '✗':>6}")

    print("\n→ The duality holds exactly (up to floating-point precision).")


def demo_strict_dimension_bounds():
    """Demonstrate strict dimension bounds 0 < α(n) < 1."""
    print("\n" + "=" * 60)
    print("DEMO 2: Strict Dimension Bounds")
    print("For subexponential spectra with N(n) > 1: 0 < α(n) < 1")
    print("=" * 60)

    # Generate spectra with different target dimensions
    for alpha_target in [0.1, 0.3, 0.5, 0.7, 0.9]:
        counts = generate_example_spectrum(alpha_target, max_n=15)
        print(f"\nTarget α = {alpha_target}:")
        print(f"  {'n':>3} {'N(n)':>8} {'2^n':>8} {'α(n)':>8} {'0<α<1':>6}")
        for n in range(1, 16):
            if counts[n] <= 0 or counts[n] >= 2**n:
                continue
            alpha = growth_exponent(counts[n], n)
            in_bounds = 0 < alpha < 1
            print(f"  {n:3d} {counts[n]:8d} {2**n:8d} {alpha:8.5f} {'✓' if in_bounds else '✗':>6}")


def demo_tropical_sum():
    """Demonstrate tropical sum of spectra."""
    print("\n" + "=" * 60)
    print("DEMO 3: Tropical Sum (Pointwise Max)")
    print("α(max(N₁,N₂)) = max(α₁, α₂)")
    print("=" * 60)

    s1 = generate_example_spectrum(0.3, max_n=12)
    s2 = generate_example_spectrum(0.7, max_n=12)
    s_sum = tropical_sum_spectrum(s1, s2)

    print(f"\n{'n':>3} {'N₁':>6} {'N₂':>6} {'max':>6} {'α₁':>8} {'α₂':>8} {'α_max':>8} {'max(α)':>8} {'Match':>6}")
    print("-" * 70)

    for n in range(1, 13):
        if s1[n] <= 0 or s2[n] <= 0 or s_sum[n] <= 0:
            continue
        a1 = growth_exponent(s1[n], n)
        a2 = growth_exponent(s2[n], n)
        a_sum = growth_exponent(s_sum[n], n)
        a_max = max(a1, a2)
        match = abs(a_sum - a_max) < 1e-10
        print(f"{n:3d} {s1[n]:6d} {s2[n]:6d} {s_sum[n]:6d} {a1:8.5f} {a2:8.5f} {a_sum:8.5f} {a_max:8.5f} {'✓' if match else '✗':>6}")

    print("\n→ The tropical sum theorem holds: growth exponent of max = max of exponents.")


def demo_entropy_bridge():
    """Demonstrate the entropy-dimension bridge."""
    print("\n" + "=" * 60)
    print("DEMO 4: Entropy-Dimension Bridge")
    print("H(d(n)) ≤ -d·log(d) + log 2")
    print("=" * 60)

    counts = generate_example_spectrum(0.5, max_n=15)

    print(f"\n{'n':>3} {'d(n)':>10} {'H(d)':>10} {'bound':>10} {'H ≤ bound':>10}")
    print("-" * 50)

    for n in range(1, 16):
        if counts[n] <= 0 or counts[n] >= 2**n:
            continue
        d = truth_density(counts[n], n)
        if d <= 0 or d >= 1:
            continue
        H = binary_entropy(d)
        bound = -d * math.log(d) + math.log(2)
        satisfied = H <= bound + 1e-10
        print(f"{n:3d} {d:10.6f} {H:10.6f} {bound:10.6f} {'✓' if satisfied else '✗':>10}")

    print("\n→ The entropy-dimension bridge bound holds at every level.")


def demo_computable_approximation():
    """Demonstrate computable approximation convergence."""
    print("\n" + "=" * 60)
    print("DEMO 5: Computable Approximation from Below")
    print("α_A(k,n) ↑ α(n) as k → ∞")
    print("=" * 60)

    # True count: N(10) = 100
    true_count = 100
    n = 10
    true_alpha = growth_exponent(true_count, n)

    # Approximation oracle: A(k, 10) = min(k * 10, 100)
    def oracle(k: int, level: int) -> int:
        return min((k + 1) * 10, true_count)

    results = computable_approximation(oracle, n, max_steps=20)

    print(f"\nTrue count N({n}) = {true_count}, true α({n}) = {true_alpha:.6f}")
    print(f"\n{'Step k':>8} {'A(k,n)':>8} {'α_A':>10} {'≤ α':>6}")
    print("-" * 36)

    for step, alpha_k in results:
        approx_val = min((step + 1) * 10, true_count)
        ok = alpha_k <= true_alpha + 1e-10
        print(f"{step:8d} {approx_val:8d} {alpha_k:10.6f} {'✓' if ok else '✗':>6}")

    print(f"\n→ Approximation converges monotonically to true exponent {true_alpha:.6f}.")


def demo_spectrum_comparison():
    """Demonstrate the spectrum comparison principle."""
    print("\n" + "=" * 60)
    print("DEMO 6: Spectrum Comparison Principle")
    print("N₁ ≤ N₂ pointwise ⟹ α₁ ≤ α₂")
    print("=" * 60)

    s1 = generate_example_spectrum(0.3, max_n=12)
    s2 = generate_example_spectrum(0.6, max_n=12)

    # Ensure s1 ≤ s2 pointwise
    for i in range(len(s1)):
        s1[i] = min(s1[i], s2[i])

    results = spectrum_comparison(s1, s2)

    print(f"\n{'n':>3} {'N₁':>8} {'N₂':>8} {'α₁':>10} {'α₂':>10} {'α₁ ≤ α₂':>10}")
    print("-" * 55)

    for n, a1, a2, ok in results:
        print(f"{n:3d} {s1[n]:8d} {s2[n]:8d} {a1:10.6f} {a2:10.6f} {'✓' if ok else '✗':>10}")

    print("\n→ Containment of truth sets implies ordering of dimensions.")


if __name__ == "__main__":
    demo_density_exponent_duality()
    demo_strict_dimension_bounds()
    demo_tropical_sum()
    demo_entropy_bridge()
    demo_computable_approximation()
    demo_spectrum_comparison()

    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Entropy-Dimension Bridge

Shows the relationship between binary entropy and truth density,
with the entropy-dimension bridge bound overlaid.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def binary_entropy(p: float) -> float:
    if p <= 0 or p >= 1:
        return 0.0
    return -p * math.log(p) - (1 - p) * math.log(1 - p)


def entropy_bound(p: float) -> float:
    if p <= 0:
        return math.log(2)
    return -p * math.log(p) + math.log(2)


def main():
    ps = np.linspace(0.001, 0.999, 500)

    fig, axes = plt.subplots(1, 2, figsize=(13, 5.5))

    # Plot 1: Entropy vs bound
    ax1 = axes[0]
    H_vals = [binary_entropy(p) for p in ps]
    bound_vals = [entropy_bound(p) for p in ps]

    ax1.plot(ps, H_vals, 'b-', linewidth=2.5, label='H(p) = binary entropy')
    ax1.plot(ps, bound_vals, 'r--', linewidth=2, label='Bound: -p·log(p) + log 2')
    ax1.fill_between(ps, H_vals, bound_vals, alpha=0.15, color='red')
    ax1.set_xlabel('Truth Density p = d(n)', fontsize=12)
    ax1.set_ylabel('Entropy / Bound', fontsize=12)
    ax1.set_title('Entropy-Dimension Bridge', fontsize=13, fontweight='bold')
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.2)

    # Plot 2: Gap between entropy and bound
    ax2 = axes[1]
    gaps = [entropy_bound(p) - binary_entropy(p) for p in ps]
    ax2.plot(ps, gaps, 'g-', linewidth=2.5)
    ax2.set_xlabel('Truth Density p', fontsize=12)
    ax2.set_ylabel('Gap = Bound - H(p)', fontsize=12)
    ax2.set_title('Entropy-Bound Gap', fontsize=13, fontweight='bold')
    ax2.grid(True, alpha=0.2)
    ax2.axhline(y=0, color='gray', linestyle='--', alpha=0.5)

    # Mark the minimum gap point
    min_gap_idx = np.argmin(gaps)
    min_gap_p = ps[min_gap_idx]
    min_gap_val = gaps[min_gap_idx]
    ax2.plot(min_gap_p, min_gap_val, 'ro', markersize=8)
    ax2.annotate(f'Min gap ≈ {min_gap_val:.4f}\nat p ≈ {min_gap_p:.3f}',
                 xy=(min_gap_p, min_gap_val),
                 xytext=(min_gap_p + 0.15, min_gap_val + 0.05),
                 fontsize=10, arrowprops=dict(arrowstyle='->', color='red'))

    plt.tight_layout()
    plt.savefig('entropy_bridge.png', dpi=150, bbox_inches='tight')
    print("Saved: entropy_bridge.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Growth Exponent Landscape

Plots the growth exponent α(n) for several example truth density spectra,
showing how different growth rates produce different fractal dimensions.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def generate_spectrum(alpha_target: float, max_n: int) -> list:
    counts = []
    for n in range(max_n + 1):
        raw = 2 ** (alpha_target * n)
        count = max(1, min(round(raw), 2**n))
        counts.append(count)
    return counts


def growth_exponent(count: int, n: int) -> float:
    if n == 0 or count <= 0:
        return 1.0
    return math.log2(count) / n


def main():
    max_n = 25
    targets = [0.2, 0.4, 0.6, 0.8, 0.95]
    colors = ['#e74c3c', '#e67e22', '#2ecc71', '#3498db', '#9b59b6']

    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    # Plot 1: Growth exponents
    ax1 = axes[0]
    for alpha_t, color in zip(targets, colors):
        counts = generate_spectrum(alpha_t, max_n)
        ns = list(range(1, max_n + 1))
        alphas = [growth_exponent(counts[n], n) for n in ns]
        ax1.plot(ns, alphas, 'o-', color=color, markersize=3,
                 label=f'α ≈ {alpha_t}', linewidth=1.5)

    ax1.set_xlabel('Level n', fontsize=12)
    ax1.set_ylabel('Growth Exponent α(n)', fontsize=12)
    ax1.set_title('Growth Exponent Landscape', fontsize=13, fontweight='bold')
    ax1.legend(fontsize=9)
    ax1.set_ylim(-0.05, 1.05)
    ax1.axhline(y=0, color='gray', linestyle='--', alpha=0.3)
    ax1.axhline(y=1, color='gray', linestyle='--', alpha=0.3)
    ax1.grid(True, alpha=0.2)

    # Plot 2: Truth density decay
    ax2 = axes[1]
    for alpha_t, color in zip(targets, colors):
        counts = generate_spectrum(alpha_t, max_n)
        ns = list(range(1, max_n + 1))
        densities = [counts[n] / (2**n) for n in ns]
        ax2.semilogy(ns, densities, 'o-', color=color, markersize=3,
                     label=f'α ≈ {alpha_t}', linewidth=1.5)

    ax2.set_xlabel('Level n', fontsize=12)
    ax2.set_ylabel('Truth Density d(n)', fontsize=12)
    ax2.set_title('Density Decay (log scale)', fontsize=13, fontweight='bold')
    ax2.legend(fontsize=9)
    ax2.grid(True, alpha=0.2)

    # Plot 3: Tropical density functional
    ax3 = axes[2]
    n_val = 10
    alphas_range = np.linspace(0, 1, 100)
    for n_val in [5, 10, 15, 20]:
        F_vals = [n_val * (a - 1) * math.log(2) for a in alphas_range]
        ax3.plot(alphas_range, F_vals, linewidth=2, label=f'n = {n_val}')

    ax3.set_xlabel('Growth Exponent α', fontsize=12)
    ax3.set_ylabel('F_n(α) = n(α-1)log 2', fontsize=12)
    ax3.set_title('Tropical Density Functional', fontsize=13, fontweight='bold')
    ax3.legend(fontsize=9)
    ax3.grid(True, alpha=0.2)
    ax3.axhline(y=0, color='gray', linestyle='--', alpha=0.3)

    plt.tight_layout()
    plt.savefig('growth_exponent_landscape.png', dpi=150, bbox_inches='tight')
    print("Saved: growth_exponent_landscape.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Tropical Sum of Truth Spectra

Demonstrates how the tropical sum (pointwise max) of two truth spectra
yields a spectrum whose growth exponent is the max of the components.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def generate_spectrum(alpha_target: float, max_n: int) -> list:
    counts = []
    for n in range(max_n + 1):
        raw = 2 ** (alpha_target * n)
        count = max(1, min(round(raw), 2**n))
        counts.append(count)
    return counts


def growth_exponent(count: int, n: int) -> float:
    if n == 0 or count <= 0:
        return 1.0
    return math.log2(count) / n


def main():
    max_n = 20
    s1 = generate_spectrum(0.35, max_n)
    s2 = generate_spectrum(0.65, max_n)
    s_sum = [max(s1[i], s2[i]) for i in range(max_n + 1)]

    ns = list(range(1, max_n + 1))
    a1 = [growth_exponent(s1[n], n) for n in ns]
    a2 = [growth_exponent(s2[n], n) for n in ns]
    a_sum = [growth_exponent(s_sum[n], n) for n in ns]
    a_max = [max(a1[i], a2[i]) for i in range(len(ns))]

    fig, axes = plt.subplots(1, 2, figsize=(13, 5.5))

    # Plot 1: Counts
    ax1 = axes[0]
    ax1.semilogy(ns, [s1[n] for n in ns], 'b^-', markersize=5, label='Spectrum S₁ (α≈0.35)', linewidth=1.5)
    ax1.semilogy(ns, [s2[n] for n in ns], 'rs-', markersize=5, label='Spectrum S₂ (α≈0.65)', linewidth=1.5)
    ax1.semilogy(ns, [s_sum[n] for n in ns], 'gD-', markersize=5, label='Tropical Sum max(S₁,S₂)', linewidth=2)
    ax1.semilogy(ns, [2**n for n in ns], 'k--', alpha=0.3, label='Total space 2ⁿ')
    ax1.set_xlabel('Level n', fontsize=12)
    ax1.set_ylabel('Count N(n)', fontsize=12)
    ax1.set_title('Truth Counts (log scale)', fontsize=13, fontweight='bold')
    ax1.legend(fontsize=9)
    ax1.grid(True, alpha=0.2)

    # Plot 2: Growth exponents
    ax2 = axes[1]
    ax2.plot(ns, a1, 'b^-', markersize=5, label='α₁(n)', linewidth=1.5)
    ax2.plot(ns, a2, 'rs-', markersize=5, label='α₂(n)', linewidth=1.5)
    ax2.plot(ns, a_sum, 'gD-', markersize=6, label='α_sum(n) = exponent of max', linewidth=2)
    ax2.plot(ns, a_max, 'k+', markersize=8, label='max(α₁, α₂)', markeredgewidth=2)
    ax2.set_xlabel('Level n', fontsize=12)
    ax2.set_ylabel('Growth Exponent', fontsize=12)
    ax2.set_title('Tropical Sum Theorem: α(max) = max(α)', fontsize=13, fontweight='bold')
    ax2.legend(fontsize=9)
    ax2.set_ylim(-0.05, 1.05)
    ax2.grid(True, alpha=0.2)

    plt.tight_layout()
    plt.savefig('tropical_sum.png', dpi=150, bbox_inches='tight')
    print("Saved: tropical_sum.png")


if __name__ == "__main__":
    main()
