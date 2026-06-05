#!/usr/bin/env python3
"""
Bayesian Werewolf: Optimal Strategy for Social Deduction Games
==============================================================

This demo computes exact survival probabilities for the Werewolf/Mafia game
under various strategies and player configurations.
"""

from fractions import Fraction
from typing import Dict, Tuple
import itertools


def survival_value(w: int, v: int, strategy: str = "random",
                   alpha: float = 0.0,
                   memo: Dict = None) -> Fraction:
    """
    Compute the exact survival probability for villagers.

    Parameters:
        w: number of remaining wolves
        v: number of remaining villagers
        strategy: "random", "perfect", or "skilled"
        alpha: skill parameter for "skilled" strategy (0=random, 1=perfect)
        memo: memoization dictionary

    Returns:
        Exact rational probability that villagers win
    """
    if memo is None:
        memo = {}

    key = (w, v, strategy, alpha)
    if key in memo:
        return memo[key]

    # Terminal conditions
    if w == 0:
        return Fraction(1)
    if v <= w:
        return Fraction(0)

    # Wolf elimination probability
    total = w + v
    if strategy == "random":
        p = Fraction(w, total)
    elif strategy == "perfect":
        p = Fraction(1) if w > 0 else Fraction(0)
    elif strategy == "skilled":
        alpha_frac = Fraction(alpha).limit_denominator(1000)
        p = alpha_frac + (1 - alpha_frac) * Fraction(w, total)
    else:
        raise ValueError(f"Unknown strategy: {strategy}")

    # After day vote eliminates a wolf: state (w-1, v)
    if w - 1 == 0:
        after_day_wolf = Fraction(1)
    else:
        # Night kill: (w-1, v-1)
        if v - 1 <= w - 1:
            after_day_wolf = Fraction(0)
        else:
            after_day_wolf = survival_value(w - 1, v - 1, strategy, alpha, memo)

    # After day vote eliminates a villager: state (w, v-1)
    if v - 1 <= w:
        after_day_vill = Fraction(0)
    else:
        # Night kill: (w, v-2)
        if v - 2 <= w:
            after_day_vill = Fraction(0)
        else:
            after_day_vill = survival_value(w, v - 2, strategy, alpha, memo)

    result = p * after_day_wolf + (1 - p) * after_day_vill
    memo[key] = result
    return result


def information_gap(w: int, v: int) -> Fraction:
    """Compute the gap between perfect and random play."""
    return survival_value(w, v, "perfect") - survival_value(w, v, "random")


def main():
    print("=" * 70)
    print("BAYESIAN WEREWOLF: Exact Survival Probabilities")
    print("=" * 70)

    # Single wolf cases
    print("\n--- Single Wolf (k=1) ---")
    for v in range(2, 11):
        val = survival_value(1, v)
        print(f"  V(1, {v:2d}) = {val} ≈ {float(val):.6f}")

    # Two wolf cases
    print("\n--- Two Wolves (k=2) ---")
    for v in range(3, 13):
        val = survival_value(2, v)
        print(f"  V(2, {v:2d}) = {val} ≈ {float(val):.6f}")

    # Three wolf cases
    print("\n--- Three Wolves (k=3) ---")
    for v in range(4, 15):
        val = survival_value(3, v)
        print(f"  V(3, {v:2d}) = {val} ≈ {float(val):.6f}")

    # Information gap
    print("\n--- Information Gap: V_perfect - V_random ---")
    for w in range(1, 5):
        for v in range(w + 1, w + 8):
            gap = information_gap(w, v)
            rand = survival_value(w, v, "random")
            perf = survival_value(w, v, "perfect")
            print(f"  Gap({w},{v:2d}) = {float(gap):.6f}  "
                  f"(random={float(rand):.4f}, perfect={float(perf):.4f})")
        print()

    # Skilled strategy comparison
    print("\n--- Skilled Strategy (α interpolation) for V(2, 5) ---")
    for alpha_pct in range(0, 101, 10):
        alpha = alpha_pct / 100.0
        val = survival_value(2, 5, "skilled", alpha)
        print(f"  α={alpha:.2f}: V = {val} ≈ {float(val):.6f}")

    # The classic n=7, k=2 game
    print("\n--- Classic Werewolf: n=7, k=2 ---")
    rand = survival_value(2, 5, "random")
    perf = survival_value(2, 5, "perfect")
    print(f"  Random play:  V = {rand} ≈ {float(rand):.6f}")
    print(f"  Perfect play: V = {perf} ≈ {float(perf):.6f}")
    print(f"  Info gap:     {float(perf - rand):.6f}")
    print(f"  Info multiplier: {float(perf / rand):.2f}x")

    # Test the conjectured formula C * (1 - k/(n-k))^2
    print("\n--- Testing Conjectured Formula ---")
    print("  Conjecture: V_random(k, n-k) ≈ C * (1 - k/(n-k))^2")
    for k in range(1, 4):
        print(f"\n  k={k}:")
        for n in range(2*k + 1, 3*k + 8):
            v = n - k
            actual = float(survival_value(k, v))
            ratio = k / (n - k) if n > k else 1
            predicted_shape = (1 - ratio) ** 2
            if predicted_shape > 0:
                C = actual / predicted_shape
            else:
                C = float('inf')
            print(f"    n={n:2d}: V={actual:.6f}, (1-k/(n-k))^2={predicted_shape:.6f}, "
                  f"implied C={C:.6f}")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Survival Probability Heatmaps and Information Gap
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from fractions import Fraction


def survival_value(w, v, strategy="random", alpha=0.0, memo=None):
    if memo is None:
        memo = {}
    key = (w, v, strategy, alpha)
    if key in memo:
        return memo[key]
    if w == 0:
        return Fraction(1)
    if v <= w:
        return Fraction(0)
    total = w + v
    if strategy == "random":
        p = Fraction(w, total)
    elif strategy == "perfect":
        p = Fraction(1)
    elif strategy == "skilled":
        af = Fraction(alpha).limit_denominator(1000)
        p = af + (1 - af) * Fraction(w, total)
    else:
        raise ValueError(strategy)
    day_wolf = (w - 1, v)
    if day_wolf[0] == 0:
        after_wolf = Fraction(1)
    else:
        ns = (day_wolf[0], day_wolf[1] - 1)
        if ns[1] <= ns[0]:
            after_wolf = Fraction(0)
        else:
            after_wolf = survival_value(ns[0], ns[1], strategy, alpha, memo)
    day_vill = (w, v - 1)
    if day_vill[1] <= day_vill[0]:
        after_vill = Fraction(0)
    else:
        ns = (day_vill[0], day_vill[1] - 1)
        if ns[1] <= ns[0]:
            after_vill = Fraction(0)
        else:
            after_vill = survival_value(ns[0], ns[1], strategy, alpha, memo)
    result = p * after_wolf + (1 - p) * after_vill
    memo[key] = result
    return result


def main():
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # Heatmap of random survival values
    max_w, max_v = 6, 15
    data = np.zeros((max_w, max_v))
    for w in range(1, max_w + 1):
        for v in range(1, max_v + 1):
            data[w - 1, v - 1] = float(survival_value(w, v))

    im1 = axes[0].imshow(data, cmap='RdYlGn', aspect='auto', vmin=0, vmax=1,
                          origin='lower')
    axes[0].set_xlabel('Villagers (v)')
    axes[0].set_ylabel('Wolves (w)')
    axes[0].set_title('Random Play: V(w, v)')
    axes[0].set_xticks(range(max_v))
    axes[0].set_xticklabels(range(1, max_v + 1))
    axes[0].set_yticks(range(max_w))
    axes[0].set_yticklabels(range(1, max_w + 1))
    plt.colorbar(im1, ax=axes[0], label='P(villagers win)')

    # Information gap heatmap
    gap_data = np.zeros((max_w, max_v))
    for w in range(1, max_w + 1):
        for v in range(1, max_v + 1):
            r = float(survival_value(w, v, "random"))
            p = float(survival_value(w, v, "perfect"))
            gap_data[w - 1, v - 1] = p - r

    im2 = axes[1].imshow(gap_data, cmap='YlOrRd', aspect='auto', vmin=0, vmax=1,
                          origin='lower')
    axes[1].set_xlabel('Villagers (v)')
    axes[1].set_ylabel('Wolves (w)')
    axes[1].set_title('Information Gap: V_perfect - V_random')
    axes[1].set_xticks(range(max_v))
    axes[1].set_xticklabels(range(1, max_v + 1))
    axes[1].set_yticks(range(max_w))
    axes[1].set_yticklabels(range(1, max_w + 1))
    plt.colorbar(im2, ax=axes[1], label='Gap')

    # Skill interpolation for different games
    alphas = np.linspace(0, 1, 21)
    for w, v, label in [(1, 4, 'n=5, k=1'), (2, 5, 'n=7, k=2'),
                         (3, 7, 'n=10, k=3'), (2, 8, 'n=10, k=2')]:
        vals = [float(survival_value(w, v, "skilled", a)) for a in alphas]
        axes[2].plot(alphas, vals, 'o-', label=label, markersize=3)

    axes[2].set_xlabel('Skill parameter α')
    axes[2].set_ylabel('P(villagers win)')
    axes[2].set_title('Survival vs. Skill Level')
    axes[2].legend()
    axes[2].grid(True, alpha=0.3)
    axes[2].set_xlim(0, 1)
    axes[2].set_ylim(0, 1.05)

    plt.tight_layout()
    plt.savefig('werewolf_analysis.png', dpi=150, bbox_inches='tight')
    print("Saved werewolf_analysis.png")


if __name__ == "__main__":
    main()
