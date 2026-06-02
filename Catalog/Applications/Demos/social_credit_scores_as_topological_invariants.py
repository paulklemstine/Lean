#!/usr/bin/env python3
"""
Social Credit Score Dynamics: Numerical Demonstrations

Demonstrates the key mathematical results:
1. Fixed-point existence for continuous scoring functions
2. Contraction convergence to unique equilibrium
3. Logistic map bifurcation analysis
4. Cantor attractor measure convergence
"""

import math


def logistic_map(mu: float, x: float) -> float:
    """The logistic scoring function f_mu(x) = mu * x * (1 - x)."""
    return mu * x * (1 - x)


def logistic_deriv(mu: float, x: float) -> float:
    """Derivative of the logistic map: f'(x) = mu * (1 - 2x)."""
    return mu * (1 - 2 * x)


def iterate_map(f, x0: float, n: int) -> list[float]:
    """Iterate a map f starting from x0 for n steps."""
    trajectory = [x0]
    x = x0
    for _ in range(n):
        x = f(x)
        trajectory.append(x)
    return trajectory


def find_fixed_point_ivt(f, a: float, b: float, tol: float = 1e-12) -> float:
    """Find fixed point of f in [a,b] using bisection (IVT on g(x) = f(x) - x)."""
    def g(x):
        return f(x) - x

    ga, gb = g(a), g(b)
    if ga * gb > 0:
        raise ValueError("g does not change sign on [a,b]")

    for _ in range(100):
        mid = (a + b) / 2
        gm = g(mid)
        if abs(gm) < tol:
            return mid
        if ga * gm < 0:
            b = mid
        else:
            a = mid
            ga = gm
    return (a + b) / 2


def demo_fixed_point_existence():
    """Demonstrate that every continuous f: [0,1] -> [0,1] has a fixed point."""
    print("=" * 60)
    print("DEMO 1: Fixed Point Existence (1D Brouwer)")
    print("=" * 60)

    test_functions = [
        ("f(x) = x^2 + 0.1", lambda x: x ** 2 + 0.1),
        ("f(x) = sqrt(x)", lambda x: math.sqrt(max(0, x))),
        ("f(x) = 0.5", lambda x: 0.5),
        ("f(x) = sin(pi*x/2)", lambda x: math.sin(math.pi * x / 2)),
        ("f(x) = 1 - x", lambda x: 1 - x),
    ]

    for name, f in test_functions:
        try:
            fp = find_fixed_point_ivt(f, 0.001, 0.999)
            print(f"  {name}: fixed point at x = {fp:.8f}, f(x) = {f(fp):.8f}")
        except ValueError:
            # Try endpoints
            for x0 in [0.0, 1.0]:
                if abs(f(x0) - x0) < 1e-10:
                    print(f"  {name}: fixed point at x = {x0:.8f}, f(x) = {f(x0):.8f}")
                    break
    print()


def demo_contraction_convergence():
    """Demonstrate convergence to unique fixed point under contraction."""
    print("=" * 60)
    print("DEMO 2: Contraction Convergence")
    print("=" * 60)

    # f(x) = 0.5*x + 0.25 is a contraction with ratio 0.5
    f = lambda x: 0.5 * x + 0.25
    # Fixed point: x = 0.5*x + 0.25 => x = 0.5

    for x0 in [0.0, 0.3, 0.7, 1.0]:
        traj = iterate_map(f, x0, 20)
        print(f"  x0 = {x0:.1f}: converges to {traj[-1]:.10f} (exact: 0.5)")
    print()


def demo_logistic_bifurcation():
    """Demonstrate the transcritical bifurcation in the logistic map."""
    print("=" * 60)
    print("DEMO 3: Logistic Map Bifurcation Analysis")
    print("=" * 60)

    print("\n  Fixed point classification:")
    for mu in [0.5, 0.9, 1.0, 1.5, 2.5, 3.0, 3.5]:
        fp_nontrivial = 1 - 1 / mu if mu != 0 else float("nan")
        deriv_at_fp = logistic_deriv(mu, fp_nontrivial) if mu != 0 else float("nan")
        status = ""
        if mu < 1:
            status = "(not viable, < 0)"
        elif mu == 1:
            status = "(bifurcation point)"
        elif mu < 3:
            status = f"(STABLE, |f'| = {abs(deriv_at_fp):.3f} < 1)"
        elif mu == 3:
            status = f"(MARGINAL, |f'| = {abs(deriv_at_fp):.3f})"
        else:
            status = f"(UNSTABLE, |f'| = {abs(deriv_at_fp):.3f} > 1)"
        print(f"  μ = {mu:.1f}: x* = {fp_nontrivial:.4f} {status}")

    print("\n  Orbit behavior at different μ values:")
    for mu in [0.8, 2.0, 3.2, 3.8]:
        f = lambda x, m=mu: logistic_map(m, x)
        traj = iterate_map(f, 0.5, 100)
        last_values = sorted(set(round(x, 6) for x in traj[-20:]))
        print(f"  μ = {mu:.1f}: attractor has ~{len(last_values)} points: {last_values[:4]}...")
    print()


def demo_cantor_attractor():
    """Demonstrate Cantor set measure convergence to zero."""
    print("=" * 60)
    print("DEMO 4: Cantor Attractor Measure → 0")
    print("=" * 60)

    print(f"  {'n':>4} {'Intervals':>12} {'Length':>15} {'Total Measure':>15}")
    print(f"  {'—' * 4} {'—' * 12} {'—' * 15} {'—' * 15}")
    for n in range(20):
        count = 2 ** n
        length = (1 / 3) ** n
        measure = (2 / 3) ** n
        print(f"  {n:4d} {count:12d} {length:15.10f} {measure:15.10f}")
    print(f"\n  Measure at n=100: {(2/3)**100:.2e}")
    print(f"  Limit as n → ∞: 0 (proved in Lean)")
    print()


def demo_feigenbaum():
    """Demonstrate Feigenbaum constant approximation."""
    print("=" * 60)
    print("DEMO 5: Feigenbaum Period-Doubling")
    print("=" * 60)

    mu1 = 3.0
    mu2 = 1 + math.sqrt(6)
    print(f"  μ₁ (period-2 onset) = {mu1:.6f}")
    print(f"  μ₂ (period-4 onset) = {mu2:.6f} = 1 + √6")
    print(f"  μ₂ ∈ (3.4, 3.5): {3.4 < mu2 < 3.5}")
    print(f"  Gap ratio (μ₂-μ₁)/(est. μ₃-μ₂):")

    # Known value for mu3 (approximate)
    mu3 = 3.5441  # period-8 onset
    ratio = (mu2 - mu1) / (mu3 - mu2)
    print(f"  ({mu2:.4f} - {mu1:.4f}) / ({mu3:.4f} - {mu2:.4f}) = {ratio:.4f}")
    print(f"  Feigenbaum constant δ ≈ 4.6692...")
    print()


if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("  SOCIAL CREDIT SCORE DYNAMICS")
    print("  Numerical Demonstrations")
    print("=" * 60 + "\n")

    demo_fixed_point_existence()
    demo_contraction_convergence()
    demo_logistic_bifurcation()
    demo_cantor_attractor()
    demo_feigenbaum()

    print("All demonstrations complete.")


#!/usr/bin/env python3
"""Bifurcation diagram of the logistic scoring map."""

import matplotlib.pyplot as plt
import numpy as np


def logistic_map(mu: float, x: float) -> float:
    return mu * x * (1.0 - x)


def main():
    mu_values = np.linspace(0.5, 4.0, 2000)
    n_warmup = 500
    n_plot = 200

    fig, ax = plt.subplots(figsize=(12, 7))

    all_mu = []
    all_x = []
    for mu in mu_values:
        x = 0.5
        for _ in range(n_warmup):
            x = logistic_map(mu, x)
        for _ in range(n_plot):
            x = logistic_map(mu, x)
            all_mu.append(mu)
            all_x.append(x)

    ax.scatter(all_mu, all_x, s=0.02, c='black', alpha=0.5)

    # Mark key bifurcation points
    ax.axvline(x=1.0, color='blue', linestyle='--', alpha=0.5, label='μ=1 (transcritical)')
    ax.axvline(x=3.0, color='red', linestyle='--', alpha=0.5, label='μ=3 (period-2)')
    ax.axvline(x=1 + np.sqrt(6), color='green', linestyle='--', alpha=0.5, label='μ=1+√6 (period-4)')

    # Plot the non-trivial fixed point branch
    mu_fp = np.linspace(1.01, 4.0, 500)
    fp = 1 - 1 / mu_fp
    ax.plot(mu_fp, fp, 'r-', linewidth=1.5, alpha=0.7, label='x* = 1 - 1/μ')

    ax.set_xlabel('Feedback parameter μ', fontsize=13)
    ax.set_ylabel('Score attractor x', fontsize=13)
    ax.set_title('Bifurcation Diagram: Phase Transitions in Social Credit Scoring', fontsize=14)
    ax.legend(fontsize=10, loc='upper left')
    ax.set_xlim(0.5, 4.0)
    ax.set_ylim(-0.05, 1.05)
    plt.tight_layout()
    plt.savefig('bifurcation_diagram.png', dpi=150)
    print("Saved bifurcation_diagram.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""Visualization of Cantor set construction and measure convergence."""

import matplotlib.pyplot as plt
import numpy as np


def cantor_intervals(n: int) -> list[tuple[float, float]]:
    """Return the list of intervals at stage n of Cantor construction."""
    intervals = [(0.0, 1.0)]
    for _ in range(n):
        new_intervals = []
        for a, b in intervals:
            third = (b - a) / 3
            new_intervals.append((a, a + third))
            new_intervals.append((b - third, b))
        intervals = new_intervals
    return intervals


def main():
    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(12, 8))

    # Top: Cantor set construction stages
    n_stages = 7
    for n in range(n_stages):
        intervals = cantor_intervals(n)
        y = n_stages - n
        for a, b in intervals:
            ax1.plot([a, b], [y, y], 'b-', linewidth=max(1, 8 - n))

    ax1.set_xlabel('Score value x', fontsize=12)
    ax1.set_ylabel('Stage n', fontsize=12)
    ax1.set_title('Cantor Set Construction: Social Score Stratification', fontsize=14)
    ax1.set_yticks(range(1, n_stages + 1))
    ax1.set_yticklabels([f'n={n}' for n in range(n_stages - 1, -1, -1)])
    ax1.set_xlim(-0.05, 1.05)

    # Bottom: Measure convergence
    ns = np.arange(0, 30)
    measures = (2.0 / 3.0) ** ns
    ax2.semilogy(ns, measures, 'ro-', markersize=4, label='(2/3)ⁿ')
    ax2.axhline(y=0, color='black', linestyle='-', alpha=0.3)
    ax2.set_xlabel('Stage n', fontsize=12)
    ax2.set_ylabel('Total measure (log scale)', fontsize=12)
    ax2.set_title('Cantor Attractor Measure → 0', fontsize=14)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('cantor_construction.png', dpi=150)
    print("Saved cantor_construction.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""Visualization of stability regions for the logistic scoring model."""

import matplotlib.pyplot as plt
import numpy as np


def main():
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Left: Derivative at non-trivial fixed point as function of mu
    mu = np.linspace(0.1, 4.0, 1000)
    deriv = 2 - mu  # f'(x*) = 2 - mu

    ax1.plot(mu, deriv, 'b-', linewidth=2, label="|f'(x*)| = |2 - μ|")
    ax1.axhline(y=1, color='red', linestyle='--', alpha=0.7, label='Stability boundary')
    ax1.axhline(y=-1, color='red', linestyle='--', alpha=0.7)
    ax1.axhline(y=0, color='black', linestyle='-', alpha=0.3)
    ax1.axvline(x=1, color='blue', linestyle=':', alpha=0.5, label='μ=1 (bifurcation)')
    ax1.axvline(x=3, color='green', linestyle=':', alpha=0.5, label='μ=3 (instability)')

    # Shade stability region
    mu_stable = np.linspace(1, 3, 100)
    ax1.fill_between(mu_stable, -1, 1, alpha=0.1, color='green', label='Stable region')

    ax1.set_xlabel('Parameter μ', fontsize=12)
    ax1.set_ylabel("f'(x*) = 2 - μ", fontsize=12)
    ax1.set_title('Derivative at Non-trivial Fixed Point', fontsize=13)
    ax1.legend(fontsize=9, loc='lower left')
    ax1.set_xlim(0, 4)
    ax1.set_ylim(-2.5, 2.5)
    ax1.grid(True, alpha=0.3)

    # Right: Phase diagram
    regions = [
        (0, 1, 'lightblue', 'Score decay\n(x* < 0)'),
        (1, 3, 'lightgreen', 'Stable equilibrium\n(|f\'| < 1)'),
        (3, 3.57, 'lightyellow', 'Period doubling\ncascade'),
        (3.57, 4, 'lightsalmon', 'Chaos\n(dense orbits)'),
    ]

    for start, end, color, label in regions:
        ax2.axvspan(start, end, alpha=0.5, color=color, label=label)
        ax2.text((start + end) / 2, 0.5, label, ha='center', va='center',
                fontsize=9, fontweight='bold')

    ax2.axvline(x=1, color='blue', linewidth=2, label='Transcritical bifurcation')
    ax2.axvline(x=3, color='red', linewidth=2, label='Period-2 onset')
    ax2.axvline(x=3.57, color='darkred', linewidth=2, label='Chaos onset')

    ax2.set_xlabel('Feedback parameter μ', fontsize=12)
    ax2.set_title('Phase Diagram of Logistic Scoring', fontsize=13)
    ax2.set_xlim(0, 4)
    ax2.set_ylim(0, 1)
    ax2.set_yticks([])

    plt.tight_layout()
    plt.savefig('stability_regions.png', dpi=150)
    print("Saved stability_regions.png")


if __name__ == "__main__":
    main()
