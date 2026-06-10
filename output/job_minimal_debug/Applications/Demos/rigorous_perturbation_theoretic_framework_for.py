#!/usr/bin/env python3
"""
Perturbation-Theoretic Framework: Interactive Demo

Demonstrates the key results with concrete numerical examples:
1. Overshoot Theorem with a concrete perturbation series
2. Phenomenon Selection across multiple models
3. Optimal truncation order for geometric corrections
4. Approximation landscape analysis
"""

import math
from algorithms import (
    PerturbationTheory,
    effectiveness_ratio,
    overshoot_check,
    geometric_tail_bound,
    optimal_truncation_order,
    analytical_optimal_order,
    ApproxLandscape,
)


def demo_overshoot():
    """Demonstrate the Overshoot Theorem with a concrete example."""
    print("=" * 60)
    print("DEMO 1: The Overshoot Theorem")
    print("=" * 60)

    # Consider estimating pi with a perturbation series
    truth = math.pi
    base = 3.0  # crude approximation

    # Corrections that sometimes overshoot
    corrections = [0.14, 0.002, -0.001, 0.0006, -0.00001, 0.03]
    # Note: correction[5] = 0.03 is a deliberate overshoot

    pt = PerturbationTheory(base, lambda k: corrections[k] if k < len(corrections) else 0)

    print(f"\nTruth: π = {truth:.10f}")
    print(f"Base:  {base}")
    print(f"\nCorrections: {corrections}")
    print(f"\n{'Order':>5} {'Approx':>14} {'Error':>12} {'Ratio':>8} {'Overshoot?':>12}")
    print("-" * 55)

    for N in range(len(corrections) + 1):
        approx = pt.approx(N)
        error = pt.trunc_error(truth, N)
        if N > 0 and N <= len(corrections):
            current_err = truth - pt.approx(N - 1)
            corr = corrections[N - 1]
            is_over, ratio = overshoot_check(current_err, corr)
            print(
                f"{N:5d} {approx:14.10f} {error:12.10f} {ratio:8.2f} {'YES ⚠' if is_over else 'no':>12}"
            )
        else:
            print(f"{N:5d} {approx:14.10f} {error:12.10f} {'':>8} {'':>12}")

    print("\n→ Notice: when the effectiveness ratio ≥ 2, adding the correction")
    print("  makes the error WORSE. The Overshoot Theorem guarantees this.")


def demo_phenomenon_selection():
    """Demonstrate the Phenomenon Selection Theorem."""
    print("\n" + "=" * 60)
    print("DEMO 2: Phenomenon Selection")
    print("=" * 60)

    # Three models, five phenomena
    errors = [
        [0.5, 0.1, 0.8, 0.3, 0.9],  # Simple model
        [0.3, 0.3, 0.3, 0.3, 0.3],  # Medium model (uniform)
        [0.1, 0.4, 0.2, 0.6, 0.2],  # Complex model
    ]
    model_names = ["Simple", "Medium", "Complex"]

    landscape = ApproxLandscape(errors, complexity=[1, 5, 20])

    print("\nError matrix (models × phenomena):")
    print(f"{'Model':>10} {'P1':>6} {'P2':>6} {'P3':>6} {'P4':>6} {'P5':>6} {'Avg':>8} {'Best':>8}")
    print("-" * 64)
    for m in range(3):
        avg = landscape.avg_error(m)
        best = landscape.best_error(m)
        row = "".join(f"{e:6.2f}" for e in errors[m])
        print(f"{model_names[m]:>10}{row} {avg:8.3f} {best:8.3f}")

    print(f"\nGlobal average error: {landscape.global_avg_error():.3f}")

    for m in range(3):
        favorable = landscape.phenomenon_selection(m)
        print(
            f"\n{model_names[m]} model favorable phenomena: "
            f"{['P' + str(p+1) for p in favorable]}"
        )
        print(f"  Best error ({landscape.best_error(m):.2f}) ≤ Avg error ({landscape.avg_error(m):.3f}) ✓")

    below_avg = landscape.cross_model_selection()
    print(f"\nModels with avg ≤ global avg: {[model_names[m] for m in below_avg]}")
    print("→ Guaranteed by Cross-Model Selection Theorem")


def demo_geometric_bounds():
    """Demonstrate geometric tail bounds and optimal truncation."""
    print("\n" + "=" * 60)
    print("DEMO 3: Geometric Tail Bounds & Optimal Truncation")
    print("=" * 60)

    M = 1.0
    r = 0.5
    alpha = 0.1

    print(f"\nParameters: M={M}, r={r}, α={alpha}")
    print(f"\n{'N':>3} {'Tail Bound':>12} {'Cost αN':>10} {'Total Cost':>12}")
    print("-" * 40)
    for N in range(8):
        tail = geometric_tail_bound(M, r, N)
        complexity_cost = alpha * N
        total = tail + complexity_cost
        print(f"{N:3d} {tail:12.6f} {complexity_cost:10.4f} {total:12.6f}")

    N_star, C_star = optimal_truncation_order(M, r, alpha)
    N_analytical = analytical_optimal_order(M, r, alpha)

    print(f"\nOptimal truncation order N* = {N_star} (cost = {C_star:.6f})")
    print(f"Analytical formula gives N* ≈ {N_analytical:.2f}")
    print(f"→ Confirmed: cost eventually increases (Theorem 7.1)")


def demo_effectiveness_ratio():
    """Demonstrate the effectiveness ratio classification."""
    print("\n" + "=" * 60)
    print("DEMO 4: Effectiveness Ratio")
    print("=" * 60)

    test_cases = [
        (1.0, 0.5, "undershoots"),
        (1.0, 1.0, "exact"),
        (1.0, 1.5, "mild overshoot"),
        (1.0, 2.0, "boundary (tight)"),
        (1.0, 3.0, "severe overshoot"),
        (-2.0, -5.0, "severe (negative)"),
    ]

    print(f"\n{'Error a':>10} {'Corr c':>10} {'Ratio':>8} {'|a-c|':>8} {'|a|':>8} {'Better?':>10} {'Type':>20}")
    print("-" * 80)
    for a, c, desc in test_cases:
        ratio = effectiveness_ratio(a, c)
        err_before = abs(a)
        err_after = abs(a - c)
        better = "✓ improve" if err_after < err_before else "✗ worse" if err_after > err_before else "= equal"
        print(f"{a:10.2f} {c:10.2f} {ratio:8.2f} {err_after:8.2f} {err_before:8.2f} {better:>10} {desc:>20}")

    print("\n→ Ratio < 1: always improves (effectiveness_improvement theorem)")
    print("→ Ratio ≥ 2 + same sign: always worsens (overshoot_general theorem)")
    print("→ Ratio = 2 + same sign: exactly equal (overshoot_tight theorem)")


def demo_convergence():
    """Demonstrate convergence of geometrically bounded perturbation series."""
    print("\n" + "=" * 60)
    print("DEMO 5: Perturbation Series Convergence")
    print("=" * 60)

    # e = 1 + 1 + 1/2! + 1/3! + ... ≈ 2.71828...
    # Use geometric-like corrections: c_k = 1/2^k
    truth = 1 / (1 - 0.5)  # = 2
    pt = PerturbationTheory(0.0, lambda k: 0.5 ** k)

    print(f"\nSeries: Σ (1/2)^k = {truth}")
    print(f"Geometric bound: M=1, r=0.5\n")
    print(f"{'N':>3} {'Approx':>12} {'Actual Error':>14} {'Tail Bound':>14} {'Bound Tight?':>14}")
    print("-" * 60)
    for N in range(10):
        approx = pt.approx(N)
        actual_err = pt.trunc_error(truth, N)
        bound = geometric_tail_bound(1.0, 0.5, N)
        ratio = actual_err / bound if bound > 0 else 0
        print(f"{N:3d} {approx:12.6f} {actual_err:14.10f} {bound:14.10f} {ratio:14.4f}")

    print("\n→ The tail bound is always valid (actual ≤ bound)")
    print("→ For this geometric series, the bound is tight (ratio → 1)")


if __name__ == "__main__":
    demo_overshoot()
    demo_phenomenon_selection()
    demo_geometric_bounds()
    demo_effectiveness_ratio()
    demo_convergence()
    print("\n" + "=" * 60)
    print("All demos completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Approximation Landscape

Heatmap of model errors across phenomena, with best phenomena highlighted.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def plot_landscape():
    """Create a heatmap of the approximation landscape."""
    np.random.seed(42)

    model_names = ['Linear', 'Quadratic', 'Cubic', 'Neural Net', 'Ensemble']
    phenom_names = [f'P{i+1}' for i in range(8)]

    # Generate error matrix with structure
    M, P = len(model_names), len(phenom_names)
    errors = np.random.exponential(0.3, (M, P))
    # Make simpler models better on some phenomena
    errors[0, :3] *= 0.3  # Linear good on P1-P3
    errors[1, 2:5] *= 0.3  # Quadratic good on P3-P5
    errors[3, 5:] *= 0.2  # Neural net good on P6-P8
    errors[4, :] *= 0.5  # Ensemble decent everywhere

    fig, axes = plt.subplots(1, 2, figsize=(16, 6), gridspec_kw={'width_ratios': [2, 1]})

    # Heatmap
    ax = axes[0]
    im = ax.imshow(errors, cmap='YlOrRd', aspect='auto')

    # Mark best phenomenon for each model
    for m in range(M):
        best_p = np.argmin(errors[m])
        ax.plot(best_p, m, 'g*', markersize=20, markeredgecolor='black', markeredgewidth=1)

    ax.set_xticks(range(P))
    ax.set_xticklabels(phenom_names, fontsize=11)
    ax.set_yticks(range(M))
    ax.set_yticklabels(model_names, fontsize=11)
    ax.set_xlabel('Phenomena', fontsize=13)
    ax.set_ylabel('Models', fontsize=13)
    ax.set_title('Approximation Landscape\n(★ = best phenomenon per model)', fontsize=14)

    # Add error values
    for m in range(M):
        for p in range(P):
            color = 'white' if errors[m, p] > 0.3 else 'black'
            ax.text(p, m, f'{errors[m,p]:.2f}', ha='center', va='center',
                   fontsize=9, color=color)

    plt.colorbar(im, ax=ax, label='Error', shrink=0.8)

    # Bar chart of average errors
    ax2 = axes[1]
    avg_errors = errors.mean(axis=1)
    best_errors = errors.min(axis=1)
    global_avg = avg_errors.mean()

    x = np.arange(M)
    width = 0.35
    bars1 = ax2.barh(x + width/2, avg_errors, width, label='Average error', color='steelblue', alpha=0.7)
    bars2 = ax2.barh(x - width/2, best_errors, width, label='Best error', color='forestgreen', alpha=0.7)
    ax2.axvline(x=global_avg, color='red', linestyle='--', linewidth=2, label=f'Global avg ({global_avg:.3f})')

    ax2.set_yticks(x)
    ax2.set_yticklabels(model_names, fontsize=11)
    ax2.set_xlabel('Error', fontsize=13)
    ax2.set_title('Best-Case Guarantee\n(best ≤ avg for all models)', fontsize=14)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3, axis='x')

    plt.tight_layout()
    plt.savefig('approx_landscape.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: approx_landscape.png")


def plot_optimal_truncation():
    """Plot the optimal truncation order as a function of parameters."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: cost function for fixed r, varying alpha
    ax = axes[0]
    M = 1.0
    r = 0.5
    N_range = np.arange(0, 15)

    for alpha in [0.01, 0.05, 0.1, 0.2, 0.5]:
        costs = [M * r**N / (1-r) + alpha * N for N in N_range]
        ax.plot(N_range, costs, 'o-', label=f'α = {alpha}', markersize=5)
        # Mark minimum
        min_idx = np.argmin(costs)
        ax.plot(min_idx, costs[min_idx], 's', markersize=12, color='black', zorder=5)

    ax.set_xlabel('Truncation Order N', fontsize=13)
    ax.set_ylabel('Total Cost C(N)', fontsize=13)
    ax.set_title(f'Cost Function (M={M}, r={r})\n■ = optimal order', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(0, 3)

    # Right: optimal order vs r for fixed alpha
    ax2 = axes[1]
    r_values = np.linspace(0.1, 0.95, 50)

    for alpha in [0.01, 0.1, 1.0]:
        N_stars = []
        for r in r_values:
            costs = [M * r**N / (1-r) + alpha * N for N in range(50)]
            N_stars.append(np.argmin(costs))
        ax2.plot(r_values, N_stars, '-', linewidth=2, label=f'α = {alpha}')

    ax2.set_xlabel('Decay Rate r', fontsize=13)
    ax2.set_ylabel('Optimal Order N*', fontsize=13)
    ax2.set_title('Optimal Truncation Order vs Decay Rate', fontsize=14)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('optimal_truncation.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: optimal_truncation.png")


if __name__ == "__main__":
    plot_landscape()
    plot_optimal_truncation()


#!/usr/bin/env python3
"""
Visualization: The Overshoot Theorem

Shows how corrections with different effectiveness ratios affect
approximation error, with the critical threshold at ratio = 2 highlighted.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def plot_overshoot_theorem():
    """Plot the overshoot criterion: |a - c| vs c for fixed a > 0."""
    a = 1.0
    c_values = np.linspace(0, 4, 500)

    error_after = np.abs(a - c_values)
    error_before = np.full_like(c_values, a)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Left panel: error before vs after as function of correction magnitude
    ax1.plot(c_values, error_after, 'b-', linewidth=2, label='|a - c| (error after correction)')
    ax1.axhline(y=a, color='r', linestyle='--', linewidth=2, label='|a| (error before correction)')
    ax1.axvline(x=2*a, color='orange', linestyle=':', linewidth=2, label=f'c = 2a (threshold)')

    # Shade regions
    ax1.fill_between(c_values, 0, error_after,
                      where=(error_after < error_before) & (c_values > 0),
                      alpha=0.15, color='green', label='Correction helps')
    ax1.fill_between(c_values, error_before, error_after,
                      where=(error_after > error_before) & (c_values > 0),
                      alpha=0.15, color='red', label='Overshoot (correction hurts)')

    ax1.set_xlabel('Correction magnitude c', fontsize=13)
    ax1.set_ylabel('Absolute error', fontsize=13)
    ax1.set_title('The Overshoot Theorem\n(a = 1, same-sign correction)', fontsize=14)
    ax1.legend(fontsize=10, loc='upper left')
    ax1.set_xlim(0, 4)
    ax1.set_ylim(0, 3.5)
    ax1.grid(True, alpha=0.3)

    # Mark the tightness point
    ax1.plot(2*a, a, 'ko', markersize=10, zorder=5)
    ax1.annotate('Tight bound\n|a| = |a-c|', xy=(2*a, a), xytext=(2.5, 1.5),
                fontsize=11, arrowprops=dict(arrowstyle='->', color='black'),
                ha='center')

    # Right panel: effectiveness ratio regions
    ratios = np.linspace(0, 4, 500)
    # For a > 0, c = ratio * a
    errors_after_ratio = np.abs(1 - ratios)  # |a - c|/|a| = |1 - ratio|

    ax2.plot(ratios, errors_after_ratio, 'b-', linewidth=2, label='Relative error after correction')
    ax2.axhline(y=1, color='r', linestyle='--', linewidth=2, label='Relative error before (= 1)')

    ax2.axvspan(0, 1, alpha=0.1, color='green')
    ax2.axvspan(1, 2, alpha=0.1, color='yellow')
    ax2.axvspan(2, 4, alpha=0.1, color='red')

    ax2.text(0.5, 2.8, 'Undershoots\n(always helps)', ha='center', fontsize=11, color='green')
    ax2.text(1.5, 2.8, 'Mild\novershoot', ha='center', fontsize=11, color='orange')
    ax2.text(3.0, 2.8, 'Severe overshoot\n(provably hurts)', ha='center', fontsize=11, color='red')

    ax2.set_xlabel('Effectiveness Ratio ρ = |c|/|a|', fontsize=13)
    ax2.set_ylabel('|a - c| / |a|', fontsize=13)
    ax2.set_title('Effectiveness Ratio Classification', fontsize=14)
    ax2.legend(fontsize=10)
    ax2.set_xlim(0, 4)
    ax2.set_ylim(0, 3.5)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('overshoot_theorem.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: overshoot_theorem.png")


def plot_perturbation_series():
    """Plot a perturbation series showing overshoot in action."""
    truth = 2.71828  # approximating e
    base = 2.0
    corrections = [0.5, 0.2, 0.05, -0.03, 0.01, -0.002, 0.15]  # last one overshoots

    fig, ax = plt.subplots(figsize=(10, 6))

    orders = list(range(len(corrections) + 1))
    approxs = [base + sum(corrections[:k]) for k in orders]
    errors = [abs(truth - a) for a in approxs]

    colors = []
    for k in range(len(orders)):
        if k == 0:
            colors.append('gray')
        else:
            curr_err = truth - approxs[k-1]
            corr = corrections[k-1]
            ratio = abs(corr) / abs(curr_err) if curr_err != 0 else 0
            same_sign = curr_err * corr > 0
            if same_sign and ratio >= 2:
                colors.append('red')
            elif errors[k] < errors[k-1]:
                colors.append('green')
            else:
                colors.append('orange')

    ax.bar(orders, errors, color=colors, alpha=0.7, edgecolor='black', linewidth=0.5)
    ax.axhline(y=0, color='black', linewidth=0.5)

    ax.set_xlabel('Truncation Order N', fontsize=13)
    ax.set_ylabel('Truncation Error |truth - approx(N)|', fontsize=13)
    ax.set_title('Perturbation Series: Error by Truncation Order\n(red = overshoot, green = improvement, orange = mild degradation)', fontsize=13)
    ax.set_xticks(orders)
    ax.grid(True, alpha=0.3, axis='y')

    plt.tight_layout()
    plt.savefig('perturbation_errors.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: perturbation_errors.png")


if __name__ == "__main__":
    plot_overshoot_theorem()
    plot_perturbation_series()
