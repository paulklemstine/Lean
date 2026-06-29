#!/usr/bin/env python3
"""
Proof Search Dimension — Numerical Demonstrations

Demonstrates the key mathematical results:
1. Search dimension bounds and phase transitions
2. Product composition law
3. Heterogeneous search dimension convergence
4. Success probability decay rates
"""

import math
import random


def search_dimension(k: int, b: int) -> float:
    """Compute D = log(k)/log(b) for 1 <= k <= b, b >= 2."""
    assert 1 <= k <= b and b >= 2, f"Invalid params: k={k}, b={b}"
    if k == 1:
        return 0.0
    return math.log(k) / math.log(b)


def entropy_deficit(k: int, b: int) -> float:
    """Compute the entropy deficit 1 - D."""
    return 1.0 - search_dimension(k, b)


def success_probability(k: int, b: int, depth: int) -> float:
    """Compute (k/b)^depth."""
    return (k / b) ** depth


def product_dimension(k1: int, b1: int, k2: int, b2: int) -> float:
    """Compute the dimension of the product search."""
    return search_dimension(k1 * k2, b1 * b2)


def het_search_dimension(levels: list[tuple[int, int]]) -> float:
    """Heterogeneous search dimension: Σ log(k_i) / Σ log(b_i)."""
    num = sum(math.log(k) for k, b in levels)
    den = sum(math.log(b) for k, b in levels)
    return num / den if den > 0 else 0.0


def main():
    print("=" * 60)
    print("PROOF SEARCH DIMENSION — NUMERICAL DEMONSTRATIONS")
    print("=" * 60)

    # Demo 1: Phase transitions
    print("\n--- Demo 1: Phase Transitions ---")
    b = 10
    print(f"Branching factor b = {b}")
    print(f"{'k':>4} {'D':>8} {'Deficit':>8} {'Phase':>15}")
    print("-" * 40)
    for k in range(1, b + 1):
        D = search_dimension(k, b)
        delta = entropy_deficit(k, b)
        if k == 1:
            phase = "DETERMINISTIC"
        elif k == b:
            phase = "TRIVIAL"
        else:
            phase = f"D = {D:.4f}"
        print(f"{k:>4} {D:>8.4f} {delta:>8.4f} {phase:>15}")

    # Demo 2: Bounds verification
    print("\n--- Demo 2: Bounds 0 ≤ D ≤ 1 ---")
    violations = 0
    for b in range(2, 50):
        for k in range(1, b + 1):
            D = search_dimension(k, b)
            if D < -1e-10 or D > 1 + 1e-10:
                violations += 1
    print(f"Tested all (k,b) with 2 ≤ b < 50: {violations} bound violations (expected: 0)")

    # Demo 3: Monotonicity
    print("\n--- Demo 3: Monotonicity in k ---")
    b = 20
    print(f"b = {b}, dimensions for k = 1..{b}:")
    dims = [search_dimension(k, b) for k in range(1, b + 1)]
    is_monotone = all(dims[i] <= dims[i + 1] + 1e-10 for i in range(len(dims) - 1))
    print(f"  Monotone: {is_monotone}")
    print(f"  D values: {[f'{d:.3f}' for d in dims]}")

    # Demo 4: Product law
    print("\n--- Demo 4: Product Composition Law ---")
    params = [(3, 10), (5, 8), (2, 7), (4, 6)]
    for (k1, b1), (k2, b2) in zip(params, params[1:]):
        D_prod = product_dimension(k1, b1, k2, b2)
        D1 = search_dimension(k1, b1)
        D2 = search_dimension(k2, b2)
        # Verify: D_prod * log(b1*b2) = D1 * log(b1) + D2 * log(b2)
        lhs = D_prod * math.log(b1 * b2)
        rhs = D1 * math.log(b1) + D2 * math.log(b2)
        print(f"  ({k1},{b1}) × ({k2},{b2}): LHS = {lhs:.6f}, RHS = {rhs:.6f}, "
              f"match = {abs(lhs - rhs) < 1e-10}")

    # Demo 5: Success probability decay
    print("\n--- Demo 5: Success Probability Decay ---")
    b = 10
    for k in [1, 3, 5, 10]:
        D = search_dimension(k, b)
        print(f"\n  k={k}, b={b}, D={D:.3f}:")
        for d in [1, 5, 10, 20, 50]:
            P = success_probability(k, b, d)
            log_P = math.log(P) if P > 0 else float('-inf')
            predicted = d * (D - 1) * math.log(b)
            print(f"    depth {d:>3}: P = {P:.2e}, log(P) = {log_P:.4f}, "
                  f"predicted = {predicted:.4f}, match = {abs(log_P - predicted) < 1e-8}")

    # Demo 6: Heterogeneous convergence
    print("\n--- Demo 6: Heterogeneous Dimension Convergence ---")
    random.seed(42)
    b_range = range(2, 11)
    for trial in range(3):
        levels = []
        print(f"\n  Trial {trial + 1}:")
        for d in [10, 100, 1000, 10000]:
            while len(levels) < d:
                b = random.choice(b_range)
                k = random.randint(1, b)
                levels.append((k, b))
            D_het = het_search_dimension(levels[:d])
            print(f"    depth {d:>5}: D_het = {D_het:.6f}")
        print(f"    → Converges to ≈ {het_search_dimension(levels):.6f}")

    # Demo 7: Entropy deficit interpretation
    print("\n--- Demo 7: Entropy Deficit as Wasted Information ---")
    b = 8
    d = 10
    total_info = d * math.log(b)
    print(f"  b={b}, d={d}, total tree information = {total_info:.4f} nats")
    for k in [1, 2, 4, 8]:
        D = search_dimension(k, b)
        useful_info = d * D * math.log(b)
        wasted_info = d * entropy_deficit(k, b) * math.log(b)
        print(f"  k={k}: D={D:.3f}, useful={useful_info:.2f} nats, "
              f"wasted={wasted_info:.2f} nats ({entropy_deficit(k, b)*100:.1f}%)")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Search Dimension Landscape

Plots the search dimension D = log(k)/log(b) as a function of k
for various branching factors b, showing the phase transitions at D=0 and D=1.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def search_dimension(k: float, b: float) -> float:
    if k <= 0 or b <= 1:
        return 0.0
    if k == 1:
        return 0.0
    return math.log(k) / math.log(b)


def main():
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # Plot 1: D vs k for different b
    ax = axes[0]
    for b in [2, 5, 10, 20, 50]:
        ks = np.linspace(1, b, 200)
        dims = [search_dimension(k, b) for k in ks]
        ax.plot(ks / b, dims, label=f'b = {b}', linewidth=2)
    ax.set_xlabel('k/b (survival fraction)', fontsize=12)
    ax.set_ylabel('Search Dimension D', fontsize=12)
    ax.set_title('Search Dimension vs Survival Fraction', fontsize=14)
    ax.legend(fontsize=10)
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.axhline(y=0, color='gray', linestyle='--', alpha=0.3)
    ax.axhline(y=1, color='gray', linestyle='--', alpha=0.3)
    ax.grid(True, alpha=0.3)

    # Plot 2: Success probability decay
    ax = axes[1]
    b = 10
    depths = np.arange(1, 21)
    for k in [1, 2, 4, 7, 10]:
        D = search_dimension(k, b)
        probs = [(k / b) ** d for d in depths]
        ax.semilogy(depths, probs, 'o-', label=f'k={k}, D={D:.2f}',
                    linewidth=2, markersize=4)
    ax.set_xlabel('Depth d', fontsize=12)
    ax.set_ylabel('Success Probability P(d)', fontsize=12)
    ax.set_title(f'Success Probability Decay (b={b})', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Plot 3: Entropy deficit heatmap
    ax = axes[2]
    bs = np.arange(2, 31)
    max_k = 30
    deficit_matrix = np.full((max_k, len(bs)), np.nan)
    for j, b in enumerate(bs):
        for i in range(min(b, max_k)):
            k = i + 1
            D = search_dimension(k, b)
            deficit_matrix[i, j] = 1 - D

    im = ax.imshow(deficit_matrix, aspect='auto', origin='lower',
                   cmap='RdYlGn_r', vmin=0, vmax=1,
                   extent=[2, 30, 1, max_k])
    ax.set_xlabel('Branching Factor b', fontsize=12)
    ax.set_ylabel('Surviving Count k', fontsize=12)
    ax.set_title('Entropy Deficit (1 - D)', fontsize=14)
    plt.colorbar(im, ax=ax, label='Deficit')

    plt.tight_layout()
    plt.savefig('search_dimension_landscape.png', dpi=150, bbox_inches='tight')
    print("Saved: search_dimension_landscape.png")


if __name__ == "__main__":
    main()
