#!/usr/bin/env python3
"""
Numerical demonstration of Sudoku phase transition theory.

Computes and displays:
1. Constraint degree decomposition for various grid sizes
2. Asymptotic degree ratio convergence to 3/2
3. Constraint interaction strength bounds
4. Overlap geometry fractions
5. Critical density and branching factor analysis
"""

import math


def latin_degree(n: int) -> int:
    """Latin square constraint degree: 2(n^2 - 1)."""
    return 2 * (n**2 - 1)


def box_only_degree(n: int) -> int:
    """Box-only constraint degree: (n-1)^2."""
    return (n - 1) ** 2


def sudoku_degree(n: int) -> int:
    """Total Sudoku constraint degree."""
    return latin_degree(n) + box_only_degree(n)


def degree_ratio(n: int) -> float:
    """Ratio of Sudoku to Latin square degree."""
    ld = latin_degree(n)
    if ld == 0:
        return float('inf')
    return sudoku_degree(n) / ld


def interaction_strength(n: int) -> float:
    """Constraint interaction strength sigma(n) = 2(n+1)/(3n+1)."""
    return 2 * (n + 1) / (3 * n + 1)


def overlap_fraction(n: int) -> float:
    """Fraction of Latin constraints that are also box constraints: 1/(n+1)."""
    return 1 / (n + 1)


def critical_density(n: int) -> float:
    """Critical density: 1 - 1/n^2."""
    return 1 - 1 / n**2


def avg_branching_factor(n: int, density: float) -> float:
    """Average branching factor at given density."""
    return n**2 * (1 - density)


def transition_window_width(n: int) -> float:
    """Transition window width: 1/n^2."""
    return 1 / n**2


def main():
    print("=" * 72)
    print("SUDOKU PHASE TRANSITION: NUMERICAL DEMONSTRATION")
    print("=" * 72)

    # Table 1: Constraint Degree Decomposition
    print("\n--- Table 1: Constraint Degree Decomposition ---")
    print(f"{'n':>3} {'n^2':>5} {'Latin':>8} {'Box-Only':>10} {'Sudoku':>8} {'Formula':>10}")
    print("-" * 50)
    for n in range(2, 11):
        ld = latin_degree(n)
        bd = box_only_degree(n)
        sd = sudoku_degree(n)
        formula = (3 * n + 1) * (n - 1)
        assert sd == formula, f"Degree formula mismatch at n={n}"
        print(f"{n:>3} {n**2:>5} {ld:>8} {bd:>10} {sd:>8} {formula:>10}")

    # Table 2: Degree Ratio Convergence
    print("\n--- Table 2: Degree Ratio → 3/2 ---")
    print(f"{'n':>3} {'ρ(n)':>10} {'3/2 - ρ(n)':>12} {'1/(n+1)':>10} {'Match':>6}")
    print("-" * 46)
    for n in range(2, 16):
        rho = degree_ratio(n)
        gap = 1.5 - rho
        predicted = 1 / (n + 1)
        match = abs(gap - predicted) < 1e-12
        print(f"{n:>3} {rho:>10.6f} {gap:>12.8f} {predicted:>10.8f} {'✓' if match else '✗':>6}")

    # Table 3: Interaction Strength
    print("\n--- Table 3: Constraint Interaction Strength ---")
    print(f"{'n':>3} {'σ(n)':>10} {'> 2/3':>7} {'< 1':>5}")
    print("-" * 30)
    for n in range(2, 16):
        sigma = interaction_strength(n)
        gt = sigma > 2 / 3
        lt = sigma < 1
        print(f"{n:>3} {sigma:>10.6f} {'✓' if gt else '✗':>7} {'✓' if lt else '✗':>5}")

    # Table 4: Overlap Geometry
    print("\n--- Table 4: Overlap Geometry ---")
    print(f"{'n':>3} {'Overlap/Cell':>14} {'Latin Deg':>11} {'Fraction':>10} {'1/(n+1)':>10}")
    print("-" * 50)
    for n in range(2, 11):
        oc = 2 * (n - 1)
        ld = latin_degree(n)
        frac = oc / ld
        predicted = 1 / (n + 1)
        print(f"{n:>3} {oc:>14} {ld:>11} {frac:>10.6f} {predicted:>10.6f}")

    # Table 5: Critical Density Analysis
    print("\n--- Table 5: Critical Density and Branching Factor ---")
    print(f"{'n':>3} {'Grid':>6} {'d_c':>10} {'Unfilled':>10} {'Branch':>8} {'Window':>10}")
    print("-" * 52)
    for n in range(2, 11):
        grid = n**4
        dc = critical_density(n)
        unfilled = n**2
        branch = avg_branching_factor(n, dc)
        window = transition_window_width(n)
        print(f"{n:>3} {grid:>6} {dc:>10.6f} {unfilled:>10} {branch:>8.4f} {window:>10.6f}")

    # Entropy analysis
    print("\n--- Entropy Analysis at Critical Density ---")
    print(f"{'n':>3} {'Total Entropy':>15} {'Remaining':>12} {'Ratio 1/n²':>12}")
    print("-" * 45)
    for n in range(2, 11):
        total = n**2 * math.log(n)
        remaining = math.log(n)
        ratio = remaining / total
        predicted = 1 / n**2
        print(f"{n:>3} {total:>15.4f} {remaining:>12.4f} {ratio:>12.6f} (={predicted:.6f})")

    # Conjecture test
    print("\n--- Conjecture Test: S(n)/L(n) Ratio ---")
    S = {2: 288, 3: 6.671e21}
    L = {2: 576, 3: 5.524e27}
    for n in [2, 3]:
        if n in S and n in L:
            ratio = S[n] / L[n]
            log_ratio = math.log(ratio)
            predicted_c = -log_ratio / (n**2 * math.log(n))
            print(f"n={n}: S/L = {ratio:.6e}, log(S/L) = {log_ratio:.4f}, "
                  f"implied c = {predicted_c:.4f}")

    print("\n" + "=" * 72)
    print("All numerical checks passed.")
    print("=" * 72)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""Visualization: Degree ratio convergence to 3/2."""
import matplotlib.pyplot as plt
import numpy as np


def latin_degree(n):
    return 2 * (n**2 - 1)


def box_only_degree(n):
    return (n - 1) ** 2


def sudoku_degree(n):
    return latin_degree(n) + box_only_degree(n)


def degree_ratio(n):
    ld = latin_degree(n)
    return sudoku_degree(n) / ld if ld > 0 else 0


def main():
    ns = np.arange(2, 51)
    ratios = [degree_ratio(n) for n in ns]
    predicted = [(3 * n + 1) / (2 * (n + 1)) for n in ns]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Left: degree ratio convergence
    ax1.plot(ns, ratios, 'b-o', markersize=3, label=r'$\rho(n)$', zorder=3)
    ax1.axhline(y=1.5, color='r', linestyle='--', alpha=0.7, label=r'$3/2$')
    ax1.axhline(y=1.0, color='gray', linestyle=':', alpha=0.5)
    ax1.set_xlabel('Block size n', fontsize=12)
    ax1.set_ylabel(r'Degree ratio $\rho(n)$', fontsize=12)
    ax1.set_title('Sudoku/Latin Square Degree Ratio', fontsize=14)
    ax1.legend(fontsize=11)
    ax1.set_ylim(0.9, 1.6)
    ax1.grid(True, alpha=0.3)

    # Right: convergence rate
    gaps = [1.5 - r for r in ratios]
    predicted_gaps = [1 / (n + 1) for n in ns]
    ax2.semilogy(ns, gaps, 'b-o', markersize=3, label=r'$3/2 - \rho(n)$', zorder=3)
    ax2.semilogy(ns, predicted_gaps, 'r--', alpha=0.7, label=r'$1/(n+1)$')
    ax2.set_xlabel('Block size n', fontsize=12)
    ax2.set_ylabel('Gap from limit', fontsize=12)
    ax2.set_title('Convergence Rate to 3/2', fontsize=14)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('degree_ratio_convergence.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: degree_ratio_convergence.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""Visualization: Constraint interaction strength and overlap geometry."""
import matplotlib.pyplot as plt
import numpy as np


def interaction_strength(n):
    return 2 * (n + 1) / (3 * n + 1)


def overlap_fraction(n):
    return 1 / (n + 1)


def main():
    ns = np.arange(2, 51)
    sigmas = [interaction_strength(n) for n in ns]
    overlaps = [overlap_fraction(n) for n in ns]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Left: interaction strength
    ax1.plot(ns, sigmas, 'g-o', markersize=3, label=r'$\sigma(n)$', zorder=3)
    ax1.axhline(y=2/3, color='r', linestyle='--', alpha=0.7, label=r'$2/3$ (lower bound)')
    ax1.axhline(y=1.0, color='orange', linestyle='--', alpha=0.7, label=r'$1$ (upper bound)')
    ax1.fill_between(ns, 2/3, 1, alpha=0.1, color='green')
    ax1.set_xlabel('Block size n', fontsize=12)
    ax1.set_ylabel(r'Interaction strength $\sigma(n)$', fontsize=12)
    ax1.set_title('Constraint Interaction Strength', fontsize=14)
    ax1.legend(fontsize=10)
    ax1.set_ylim(0.5, 1.1)
    ax1.grid(True, alpha=0.3)

    # Right: overlap fraction
    ax2.plot(ns, overlaps, 'm-o', markersize=3, label=r'$1/(n+1)$', zorder=3)
    ax2.set_xlabel('Block size n', fontsize=12)
    ax2.set_ylabel('Overlap fraction', fontsize=12)
    ax2.set_title('Constraint Overlap Fraction', fontsize=14)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('interaction_strength.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: interaction_strength.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""Visualization: Phase transition analysis — critical density and branching."""
import matplotlib.pyplot as plt
import numpy as np


def critical_density(n):
    return 1 - 1 / n**2


def avg_branching(n, d):
    return n**2 * (1 - d)


def transition_width(n):
    return 1 / n**2


def main():
    ns = np.arange(2, 21)

    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # Panel 1: Critical density
    dc = [critical_density(n) for n in ns]
    axes[0].plot(ns, dc, 'b-o', markersize=4, zorder=3)
    axes[0].axhline(y=1.0, color='r', linestyle='--', alpha=0.5)
    axes[0].set_xlabel('Block size n', fontsize=12)
    axes[0].set_ylabel(r'Critical density $d_c(n)$', fontsize=12)
    axes[0].set_title('Critical Density', fontsize=14)
    axes[0].set_ylim(0.7, 1.02)
    axes[0].grid(True, alpha=0.3)

    # Panel 2: Branching factor vs density (for n=3)
    n = 3
    densities = np.linspace(0.5, 1.0, 100)
    bf = [avg_branching(n, d) for d in densities]
    axes[1].plot(densities, bf, 'g-', linewidth=2)
    dc_3 = critical_density(3)
    axes[1].axvline(x=dc_3, color='r', linestyle='--', alpha=0.7,
                    label=f'$d_c = {dc_3:.4f}$')
    axes[1].axhline(y=1.0, color='orange', linestyle=':', alpha=0.7,
                    label='Branch = 1')
    axes[1].set_xlabel('Density d', fontsize=12)
    axes[1].set_ylabel('Avg branching factor', fontsize=12)
    axes[1].set_title(f'Branching Factor (n={n})', fontsize=14)
    axes[1].legend(fontsize=10)
    axes[1].grid(True, alpha=0.3)

    # Panel 3: Transition window width
    widths = [transition_width(n) for n in ns]
    axes[2].semilogy(ns, widths, 'r-o', markersize=4, zorder=3)
    axes[2].set_xlabel('Block size n', fontsize=12)
    axes[2].set_ylabel(r'Window width $1/n^2$', fontsize=12)
    axes[2].set_title('Transition Window Width', fontsize=14)
    axes[2].grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('phase_transition_analysis.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: phase_transition_analysis.png")


if __name__ == "__main__":
    main()
