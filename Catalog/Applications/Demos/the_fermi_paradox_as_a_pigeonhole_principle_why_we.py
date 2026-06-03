#!/usr/bin/env python3
"""
Demo: The Fermi Paradox as a Pigeonhole Principle

Numerical demonstrations of the Great Filter Theorem, temporal pigeonhole,
and Drake equation sensitivity analysis.
"""

import math
import random

def drake_equation(R_star: float, f_p: float, n_e: float,
                   f_l: float, f_i: float, f_c: float, L: float) -> float:
    """Compute the Drake equation N = R* × f_p × n_e × f_l × f_i × f_c × L."""
    return R_star * f_p * n_e * f_l * f_i * f_c * L

def great_filter_bound(product: float, n_filters: int) -> float:
    """Compute the Great Filter bound: at least one filter ≤ product^(1/n)."""
    if product <= 0:
        return 0.0
    return product ** (1.0 / n_filters)

def temporal_overlap_probability(N: int, L: float, T: float) -> float:
    """Probability that at least 2 of N civilizations overlap in time.
    Each lasts L years in a timeline of T years (birthday paradox analog)."""
    if N <= 1 or L <= 0 or T <= 0:
        return 0.0
    # Probability of NO overlap (birthday paradox):
    p_no_overlap = 1.0
    for k in range(1, N):
        p_no_overlap *= max(0, 1 - k * L / T)
    return 1 - p_no_overlap

def filter_chain_decay(base: float, p: float, n: int) -> float:
    """Expected civilizations with n filters each at probability p."""
    return base * (p ** n)

def main():
    print("=" * 70)
    print("THE FERMI PARADOX AS A PIGEONHOLE PRINCIPLE")
    print("Numerical Demonstrations")
    print("=" * 70)

    # === Demo 1: Drake Equation Scenarios ===
    print("\n" + "─" * 70)
    print("DEMO 1: Drake Equation Under Three Scenarios")
    print("─" * 70)

    scenarios = {
        "Optimistic": (3.0, 1.0, 0.4, 1.0, 0.5, 0.5, 1e9),
        "Moderate":   (1.5, 0.5, 0.1, 0.1, 0.1, 0.1, 1e4),
        "Pessimistic": (1.5, 0.5, 0.01, 0.01, 0.01, 0.01, 100),
    }

    for name, params in scenarios.items():
        N = drake_equation(*params)
        print(f"\n  {name} scenario:")
        print(f"    R* = {params[0]}, f_p = {params[1]}, n_e = {params[2]}")
        print(f"    f_l = {params[3]}, f_i = {params[4]}, f_c = {params[5]}, L = {params[6]:.0e}")
        print(f"    N (Milky Way) = {N:.3e}")
        if N < 1:
            print(f"    → Fewer than 1 civilization expected in our galaxy!")

    # === Demo 2: Great Filter Theorem ===
    print("\n" + "─" * 70)
    print("DEMO 2: Great Filter Theorem")
    print("─" * 70)

    for n in [7, 10, 15]:
        for log_product in [-7, -15, -22]:
            product = 10 ** log_product
            bound = great_filter_bound(product, n)
            print(f"  n = {n:2d} filters, product = 10^{log_product:3d}"
                  f"  →  Great Filter bound: {bound:.3e}")

    # === Demo 3: Temporal Pigeonhole ===
    print("\n" + "─" * 70)
    print("DEMO 3: Temporal Overlap Probability")
    print("─" * 70)

    T_galaxy = 1.3e10  # years
    print(f"  Galaxy age: {T_galaxy:.1e} years")
    for N_civ in [2, 5, 10, 100]:
        for L_civ in [1e3, 1e4, 1e5, 1e6]:
            p_overlap = temporal_overlap_probability(N_civ, L_civ, T_galaxy)
            coverage = N_civ * L_civ / T_galaxy * 100
            print(f"    N = {N_civ:3d}, L = {L_civ:.0e} yr"
                  f"  →  P(overlap) = {p_overlap:.6f}"
                  f"  coverage = {coverage:.4f}%")

    # === Demo 4: Filter Chain Exponential Decay ===
    print("\n" + "─" * 70)
    print("DEMO 4: Filter Chain Exponential Decay")
    print("─" * 70)

    base = 1e10  # habitable planets
    print(f"  Base count: {base:.0e} habitable planets")
    for p in [0.5, 0.1, 0.01]:
        print(f"\n  Filter probability p = {p}:")
        for n in range(1, 16):
            E = filter_chain_decay(base, p, n)
            status = "  ← ALONE" if E < 1 else ""
            print(f"    n = {n:2d} filters: E = {E:.3e}{status}")

    # === Demo 5: Monte Carlo Validation ===
    print("\n" + "─" * 70)
    print("DEMO 5: Monte Carlo — Great Filter Always Exists")
    print("─" * 70)

    n_trials = 100000
    n_filters = 7
    target_product = 1e-10

    min_filter_values = []
    random.seed(42)

    for _ in range(n_trials):
        # Generate random filters that multiply to approximately target_product
        log_target = math.log(target_product)
        # Random partition of log_target among n_filters
        cuts = sorted([random.uniform(0, 1) for _ in range(n_filters - 1)])
        cuts = [0] + cuts + [1]
        log_filters = [log_target * (cuts[i+1] - cuts[i]) for i in range(n_filters)]
        filters = [math.exp(lf) for lf in log_filters]
        min_filter_values.append(min(filters))

    theoretical_bound = target_product ** (1.0 / n_filters)
    empirical_fraction = sum(1 for m in min_filter_values if m <= theoretical_bound) / n_trials

    print(f"  Trials: {n_trials}")
    print(f"  Filters: {n_filters}")
    print(f"  Target product: {target_product:.0e}")
    print(f"  Theoretical bound (product^(1/n)): {theoretical_bound:.6f}")
    print(f"  Fraction with min ≤ bound: {empirical_fraction:.4f}")
    print(f"  (Should be 1.0000 by the Great Filter Theorem)")

    avg_min = sum(min_filter_values) / len(min_filter_values)
    print(f"  Average minimum filter value: {avg_min:.6f}")

    print("\n" + "=" * 70)
    print("CONCLUSION: The Fermi paradox is mathematics, not mystery.")
    print("=" * 70)

if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""Visualization: Exponential Decay of Expected Civilizations with Filter Count."""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

def main():
    base_count = 1e10  # habitable planets
    filter_probs = [0.5, 0.1, 0.01, 0.001]
    n_range = np.arange(1, 21)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Left: log-scale expected civilizations
    for p in filter_probs:
        E = base_count * p ** n_range
        ax1.semilogy(n_range, E, 'o-', label=f'p = {p}', markersize=4)

    ax1.axhline(y=1, color='red', linestyle='--', linewidth=2, label='E = 1 (alone)')
    ax1.set_xlabel('Number of Filters (n)', fontsize=12)
    ax1.set_ylabel('Expected Civilizations E', fontsize=12)
    ax1.set_title('Filter Chain Exponential Decay', fontsize=14)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)
    ax1.set_xlim(1, 20)

    # Right: Great Filter bound
    products = np.logspace(-30, -1, 100)
    for n in [3, 5, 7, 10, 15]:
        bounds = products ** (1.0 / n)
        ax2.loglog(products, bounds, '-', label=f'n = {n} filters', linewidth=2)

    ax2.set_xlabel('Product of Filters (∏ fᵢ)', fontsize=12)
    ax2.set_ylabel('Great Filter Bound (max of min filter)', fontsize=12)
    ax2.set_title('Great Filter Theorem: Minimum Filter Bound', fontsize=14)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_drake_decay.png', dpi=150, bbox_inches='tight')
    print("Saved viz_drake_decay.png")

if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""Visualization: Monte Carlo Drake Equation — Distribution of Expected Civilizations."""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

def main():
    np.random.seed(42)
    n_samples = 200000
    base_count = 1e10
    n_filters = 7

    # Sample filters uniformly from (0.001, 1.0)
    filters = np.random.uniform(0.001, 1.0, size=(n_samples, n_filters))
    log_products = np.sum(np.log10(filters), axis=1)
    log_E = np.log10(base_count) + log_products

    min_filters = np.min(filters, axis=1)
    theoretical_bounds = 10 ** (log_products / n_filters)

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    # Top-left: Distribution of log10(E)
    ax = axes[0, 0]
    ax.hist(log_E, bins=100, density=True, alpha=0.7, color='steelblue')
    ax.axvline(x=0, color='red', linestyle='--', linewidth=2, label='E = 1 (alone)')
    prob_alone = np.mean(log_E < 0)
    ax.set_xlabel('log₁₀(Expected Civilizations)', fontsize=11)
    ax.set_ylabel('Density', fontsize=11)
    ax.set_title(f'Drake Equation Distribution  —  P(alone) = {prob_alone:.1%}', fontsize=12)
    ax.legend(fontsize=10)

    # Top-right: Min filter vs theoretical bound
    ax = axes[0, 1]
    mask = np.random.choice(n_samples, 2000, replace=False)
    ax.scatter(theoretical_bounds[mask], min_filters[mask], alpha=0.3, s=5, color='steelblue')
    lim = [1e-4, 1.1]
    ax.plot(lim, lim, 'r--', linewidth=2, label='min = bound')
    ax.set_xscale('log')
    ax.set_yscale('log')
    ax.set_xlabel('Theoretical Bound (∏fᵢ)^(1/n)', fontsize=11)
    ax.set_ylabel('Actual Minimum Filter', fontsize=11)
    ax.set_title('Great Filter Theorem: min ≤ bound always holds', fontsize=12)
    ax.legend(fontsize=10)

    # Bottom-left: Expected civilizations vs number of filters
    ax = axes[1, 0]
    for p_label, p_lo, p_hi in [("Wide: U(0.001,1)", 0.001, 1.0),
                                  ("Medium: U(0.01,0.5)", 0.01, 0.5),
                                  ("Narrow: U(0.05,0.2)", 0.05, 0.2)]:
        medians = []
        ns = range(3, 16)
        for n in ns:
            f = np.random.uniform(p_lo, p_hi, size=(10000, n))
            lp = np.sum(np.log10(f), axis=1)
            le = np.log10(base_count) + lp
            medians.append(np.median(le))
        ax.plot(list(ns), medians, 'o-', label=p_label, markersize=5)

    ax.axhline(y=0, color='red', linestyle='--', linewidth=2)
    ax.set_xlabel('Number of Filters', fontsize=11)
    ax.set_ylabel('Median log₁₀(E)', fontsize=11)
    ax.set_title('Exponential Decay: More Filters → Fewer Civilizations', fontsize=12)
    ax.legend(fontsize=10)

    # Bottom-right: Which filter is the Great Filter?
    ax = axes[1, 1]
    great_filter_indices = np.argmin(filters, axis=1)
    counts = np.bincount(great_filter_indices, minlength=n_filters)
    ax.bar(range(n_filters), counts / n_samples * 100, color='steelblue', alpha=0.8)
    ax.set_xlabel('Filter Index', fontsize=11)
    ax.set_ylabel('Frequency as Great Filter (%)', fontsize=11)
    ax.set_title('Which Filter Is the Great Filter? (Uniform priors)', fontsize=12)
    ax.axhline(y=100/n_filters, color='red', linestyle='--', label=f'Expected: {100/n_filters:.1f}%')
    ax.legend(fontsize=10)

    plt.tight_layout()
    plt.savefig('viz_monte_carlo.png', dpi=150, bbox_inches='tight')
    print("Saved viz_monte_carlo.png")

if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""Visualization: Temporal Pigeonhole — Civilization Coverage Over Cosmic Time."""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

def main():
    np.random.seed(42)

    T = 13000  # million-year epochs
    scenarios = [
        ("5 civilizations, L=10 Myr", 5, 10),
        ("20 civilizations, L=10 Myr", 20, 10),
        ("100 civilizations, L=10 Myr", 100, 10),
        ("100 civilizations, L=100 Myr", 100, 100),
    ]

    fig, axes = plt.subplots(len(scenarios), 1, figsize=(14, 10), sharex=True)

    for ax, (title, N, L) in zip(axes, scenarios):
        starts = np.random.randint(0, T - L, size=N)
        coverage = np.zeros(T)
        for s in starts:
            coverage[s:s+L] = 1

        frac = np.sum(coverage) / T * 100

        time = np.arange(T) / 1000  # in billions of years
        ax.fill_between(time, 0, coverage, alpha=0.6, color='steelblue')
        ax.set_ylabel('Occupied', fontsize=10)
        ax.set_title(f'{title}  —  Coverage: {frac:.2f}%', fontsize=11)
        ax.set_ylim(-0.1, 1.3)
        ax.set_yticks([0, 1])
        ax.set_yticklabels(['Empty', 'Civilization'])

        # Mark "now"
        now = 13.0
        ax.axvline(x=now, color='red', linestyle='--', alpha=0.7)
        ax.text(now + 0.05, 1.1, 'Now', color='red', fontsize=9)

    axes[-1].set_xlabel('Cosmic Time (billions of years)', fontsize=12)

    fig.suptitle('Temporal Pigeonhole: Most of Cosmic History Is Empty',
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('viz_temporal_pigeonhole.png', dpi=150, bbox_inches='tight')
    print("Saved viz_temporal_pigeonhole.png")

if __name__ == "__main__":
    main()
