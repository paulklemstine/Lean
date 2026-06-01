#!/usr/bin/env python3
"""
Self-Avoiding Walk: Connective Constant Demo

Demonstrates key results from the SAW formalization:
1. SAW enumeration on Z²
2. Submultiplicativity verification
3. Connective constant estimation
4. Nienhuis value verification
5. Critical exponent estimation
"""

import math
from algorithms import (
    count_saws, nienhuis_mu, verify_minimal_polynomial,
    critical_fugacity, submultiplicativity_check,
    saw_end_to_end_distance
)


def main():
    print("=" * 70)
    print("SELF-AVOIDING WALK: CONNECTIVE CONSTANT")
    print("=" * 70)

    # 1. Enumerate SAW counts
    print("\n1. SAW COUNTS ON Z²")
    print("-" * 40)
    max_n = 16
    counts = []
    for n in range(max_n + 1):
        c = count_saws(n)
        counts.append(c)
        print(f"  c({n:2d}) = {c:>12d}")

    # Known values for verification
    known = {0: 1, 1: 4, 2: 12, 3: 36, 4: 100, 5: 284, 6: 780}
    print("\n  Verification against known values:")
    for n, expected in known.items():
        status = "✓" if counts[n] == expected else "✗"
        print(f"    c({n}) = {counts[n]} (expected {expected}) {status}")

    # 2. Submultiplicativity
    print("\n2. HAMMERSLEY'S INEQUALITY: c(m+n) ≤ c(m)·c(n)")
    print("-" * 40)
    violations = 0
    total = 0
    for m in range(len(counts)):
        for n in range(len(counts) - m):
            if m + n < len(counts):
                total += 1
                if counts[m + n] > counts[m] * counts[n]:
                    violations += 1
                    print(f"  VIOLATION: c({m}+{n}) = {counts[m+n]} > "
                          f"c({m})·c({n}) = {counts[m] * counts[n]}")

    print(f"  Checked {total} pairs, {violations} violations")
    if violations == 0:
        print("  ✓ Submultiplicativity verified for all computed values!")

    # 3. Connective constant estimation
    print("\n3. CONNECTIVE CONSTANT ESTIMATION")
    print("-" * 40)
    print("  n-th root estimates μ ≈ c(n)^(1/n):")
    for n in range(1, len(counts)):
        est = counts[n] ** (1.0 / n)
        print(f"    n={n:2d}: μ ≈ {est:.8f}")

    print("\n  Ratio estimates μ ≈ c(n+1)/c(n):")
    for n in range(1, len(counts) - 1):
        est = counts[n + 1] / counts[n]
        print(f"    n={n:2d}: μ ≈ {est:.8f}")

    print(f"\n  Literature value: μ(Z²) ≈ 2.63815853...")
    best_root = counts[-1] ** (1.0 / (len(counts) - 1))
    print(f"  Our best root estimate (n={len(counts)-1}): {best_root:.8f}")

    # 4. Nienhuis value for hexagonal lattice
    print("\n4. NIENHUIS VALUE: μ_hex = √(2+√2)")
    print("-" * 40)
    mu = nienhuis_mu()
    print(f"  μ_hex = √(2+√2) = {mu:.15f}")
    print(f"  μ_hex² = {mu**2:.15f}")
    print(f"  2 + √2 = {2 + math.sqrt(2):.15f}")
    print(f"  μ_hex² - (2+√2) = {mu**2 - (2 + math.sqrt(2)):.2e}")

    print(f"\n  Minimal polynomial x⁴ - 4x² + 2:")
    residual = verify_minimal_polynomial(mu)
    print(f"    μ⁴ - 4μ² + 2 = {residual:.2e}")

    print(f"\n  Algebraic identity (μ²-2)² = 2:")
    identity = (mu**2 - 2)**2
    print(f"    (μ²-2)² = {identity:.15f}")
    print(f"    Error: {abs(identity - 2):.2e}")

    print(f"\n  Fourth power: μ⁴ = 6 + 4√2:")
    fourth = mu**4
    expected_fourth = 6 + 4 * math.sqrt(2)
    print(f"    μ⁴ = {fourth:.15f}")
    print(f"    6 + 4√2 = {expected_fourth:.15f}")
    print(f"    Error: {abs(fourth - expected_fourth):.2e}")

    print(f"\n  Bounds: 1 < μ_hex < 2")
    print(f"    1 < {mu:.6f} < 2: {'✓' if 1 < mu < 2 else '✗'}")

    # 5. Critical fugacity
    print("\n5. CRITICAL FUGACITY")
    print("-" * 40)
    xc = critical_fugacity()
    print(f"  x_c = 1/μ_hex = {xc:.15f}")
    print(f"  x_c² · (2+√2) = {xc**2 * (2 + math.sqrt(2)):.15f}")
    print(f"  Error from 1: {abs(xc**2 * (2 + math.sqrt(2)) - 1):.2e}")

    # 6. Critical exponent estimation
    print("\n6. CRITICAL EXPONENT ν (END-TO-END DISTANCE)")
    print("-" * 40)
    print("  Conjectured: <R²> ~ n^(2ν) with ν = 3/4")
    r2_values = []
    for n in range(1, 13):
        r2 = saw_end_to_end_distance(n)
        r2_values.append((n, r2))
        nu_est = math.log(r2) / (2 * math.log(n)) if n > 1 else float('nan')
        print(f"    n={n:2d}: <R²> = {r2:10.4f}, "
              f"ν_est = {nu_est:.4f}" if n > 1 else
              f"    n={n:2d}: <R²> = {r2:10.4f}")

    # Estimate ν from last two points
    if len(r2_values) >= 2:
        n1, r1 = r2_values[-2]
        n2, r2 = r2_values[-1]
        nu_final = (math.log(r2) - math.log(r1)) / (2 * (math.log(n2) - math.log(n1)))
        print(f"\n  Best ν estimate (from n={n1},{n2}): {nu_final:.4f}")
        print(f"  Conjectured ν = 3/4 = 0.7500")

    # 7. Summary
    print("\n" + "=" * 70)
    print("SUMMARY OF FORMALIZED RESULTS")
    print("=" * 70)
    print("""
  PROVED (machine-verified in Lean 4):
  ✓ Submultiplicative.log_subadditive: log of submultiplicative is subadditive
  ✓ Submultiplicative.le_first_pow:    a(n) ≤ a(1)^n
  ✓ Submultiplicative.le_pow:          a(kn) ≤ a(n)^k
  ✓ nienhuis_mu_sq:                    μ² = 2 + √2
  ✓ nienhuis_mu_fourth:                μ⁴ = 6 + 4√2
  ✓ nienhuis_mu_minimal_poly:          μ⁴ - 4μ² + 2 = 0
  ✓ nienhuis_algebraic_identity:       (μ²-2)² = 2
  ✓ nienhuis_mu_bounds:                1 < μ < 2
  ✓ criticalFugacity_identity:         x_c² · (2+√2) = 1
  ✓ ConnectiveConstantData.mu_pos:     μ > 0

  OPEN PROBLEMS:
  ? Exact value of μ(Z²) ≈ 2.638...
  ? Critical exponent γ = 43/32
  ? Universality of critical exponents
    """)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Self-Avoiding Walk Connective Constant

Generates plots showing:
1. SAW count growth and connective constant convergence
2. Sample self-avoiding walks on Z²
3. Nienhuis value algebraic properties
"""

import math
import random
from algorithms import count_saws, enumerate_saws, nienhuis_mu

try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    import matplotlib.patches as mpatches
    import numpy as np
    HAS_MPL = True
except ImportError:
    HAS_MPL = False
    print("matplotlib not available, skipping plots")


def plot_saw_counts():
    """Plot SAW count growth and connective constant estimates."""
    if not HAS_MPL:
        return

    max_n = 16
    counts = [count_saws(n) for n in range(max_n + 1)]

    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # Plot 1: Log of SAW counts
    ax = axes[0]
    ns = list(range(max_n + 1))
    log_counts = [math.log(c) if c > 0 else 0 for c in counts]
    ax.plot(ns, log_counts, 'bo-', markersize=6, label='log c(n)')
    # Fit line for μ ≈ 2.638
    mu_est = 2.638
    ax.plot(ns, [n * math.log(mu_est) for n in ns], 'r--',
            label=f'n·log(μ), μ≈{mu_est}', alpha=0.7)
    ax.set_xlabel('Walk length n')
    ax.set_ylabel('log c(n)')
    ax.set_title('SAW Count Growth (log scale)')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Plot 2: Connective constant estimates
    ax = axes[1]
    root_est = [counts[n] ** (1.0 / n) for n in range(1, max_n + 1)]
    ratio_est = [counts[n+1] / counts[n] for n in range(1, max_n)]
    ax.plot(range(1, max_n + 1), root_est, 'bs-', markersize=5,
            label='c(n)^{1/n}')
    ax.plot(range(1, max_n), ratio_est, 'r^-', markersize=5,
            label='c(n+1)/c(n)')
    ax.axhline(y=2.638, color='green', linestyle='--', alpha=0.7,
               label='μ ≈ 2.638')
    ax.set_xlabel('Walk length n')
    ax.set_ylabel('Estimate of μ')
    ax.set_title('Connective Constant Convergence')
    ax.legend()
    ax.grid(True, alpha=0.3)
    ax.set_ylim(2.4, 4.2)

    # Plot 3: Submultiplicativity
    ax = axes[2]
    ratios = []
    labels = []
    for m in range(1, 8):
        for n in range(1, 8):
            if m + n <= max_n:
                ratio = counts[m + n] / (counts[m] * counts[n])
                ratios.append(ratio)
                labels.append(f'({m},{n})')
    ax.bar(range(len(ratios)), ratios, color='steelblue', alpha=0.7)
    ax.axhline(y=1.0, color='red', linestyle='--',
               label='c(m+n)/(c(m)·c(n)) ≤ 1')
    ax.set_xlabel('(m, n) pair index')
    ax.set_ylabel('c(m+n) / (c(m)·c(n))')
    ax.set_title('Submultiplicativity Ratios')
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('saw_connective_constant.png', dpi=150, bbox_inches='tight')
    print("Saved saw_connective_constant.png")
    plt.close()


def plot_sample_walks():
    """Plot sample self-avoiding walks."""
    if not HAS_MPL:
        return

    fig, axes = plt.subplots(2, 3, figsize=(15, 10))

    for idx, n in enumerate([4, 6, 8, 10, 12, 14]):
        ax = axes[idx // 3][idx % 3]
        walks = enumerate_saws(n) if n <= 10 else None

        if walks and len(walks) > 0:
            # Plot a few sample walks
            random.seed(42)
            samples = random.sample(walks, min(5, len(walks)))
            colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3', '#ff7f00']
            for i, walk in enumerate(samples):
                xs = [p[0] for p in walk]
                ys = [p[1] for p in walk]
                ax.plot(xs, ys, '-o', color=colors[i % len(colors)],
                        markersize=4, linewidth=1.5, alpha=0.7)

            ax.set_title(f'n={n}, c(n)={len(walks)}')
        else:
            c = count_saws(n)
            ax.text(0.5, 0.5, f'n={n}\nc(n)={c}',
                    transform=ax.transAxes, ha='center', va='center',
                    fontsize=14)
            ax.set_title(f'n={n}, c(n)={c}')

        ax.set_aspect('equal')
        ax.grid(True, alpha=0.3)
        ax.set_xlabel('x')
        ax.set_ylabel('y')

    plt.suptitle('Self-Avoiding Walks on ℤ²', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('saw_samples.png', dpi=150, bbox_inches='tight')
    print("Saved saw_samples.png")
    plt.close()


def plot_nienhuis_polynomial():
    """Plot the minimal polynomial of the Nienhuis value."""
    if not HAS_MPL:
        return

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Plot 1: The minimal polynomial x⁴ - 4x² + 2
    ax = axes[0]
    x = np.linspace(-2.5, 2.5, 1000)
    y = x**4 - 4*x**2 + 2
    ax.plot(x, y, 'b-', linewidth=2)
    ax.axhline(y=0, color='black', linewidth=0.5)
    ax.axvline(x=0, color='black', linewidth=0.5)

    # Mark the roots
    mu = nienhuis_mu()
    roots = [mu, -mu, math.sqrt(2 - math.sqrt(2)), -math.sqrt(2 - math.sqrt(2))]
    for r in roots:
        ax.plot(r, 0, 'ro', markersize=8)
    ax.annotate(f'μ_hex ≈ {mu:.4f}', xy=(mu, 0), xytext=(mu + 0.2, 2),
                arrowprops=dict(arrowstyle='->', color='red'),
                fontsize=10, color='red')

    ax.set_xlabel('x')
    ax.set_ylabel('x⁴ - 4x² + 2')
    ax.set_title('Minimal Polynomial of √(2+√2)')
    ax.grid(True, alpha=0.3)
    ax.set_ylim(-3, 10)

    # Plot 2: Critical fugacity and the identity x²(2+√2) = 1
    ax = axes[1]
    x = np.linspace(0.01, 1.5, 1000)
    y1 = x**2 * (2 + math.sqrt(2))
    ax.plot(x, y1, 'b-', linewidth=2, label='x²·(2+√2)')
    ax.axhline(y=1, color='red', linestyle='--', label='y = 1')

    xc = 1.0 / mu
    ax.plot(xc, 1, 'go', markersize=10, zorder=5)
    ax.annotate(f'x_c = 1/μ ≈ {xc:.4f}', xy=(xc, 1), xytext=(xc + 0.15, 1.5),
                arrowprops=dict(arrowstyle='->', color='green'),
                fontsize=10, color='green')

    ax.set_xlabel('x (fugacity)')
    ax.set_ylabel('x²·(2+√2)')
    ax.set_title('Critical Fugacity Identity')
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('nienhuis_polynomial.png', dpi=150, bbox_inches='tight')
    print("Saved nienhuis_polynomial.png")
    plt.close()


if __name__ == "__main__":
    plot_saw_counts()
    plot_sample_walks()
    plot_nienhuis_polynomial()
    print("All visualizations complete.")
