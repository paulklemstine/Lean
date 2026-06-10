#!/usr/bin/env python3
"""
Social Deduction Game: Random Elimination Probability Demo

Demonstrates the Parity Paradox and Skip-Two Monotonicity
in social deduction games (Werewolf/Mafia).
"""

from fractions import Fraction
from functools import lru_cache


@lru_cache(maxsize=None)
def win_prob(v: int, w: int) -> Fraction:
    """Compute the exact win probability for villagers.
    
    Args:
        v: Number of villagers
        w: Number of werewolves
    
    Returns:
        Exact rational win probability
    """
    if w == 0:
        return Fraction(1)
    if v <= w:
        return Fraction(0)
    
    total = Fraction(v + w)
    
    # Day: werewolf eliminated
    if w == 1:
        day_werewolf = Fraction(1) / total
    else:
        day_werewolf = Fraction(w) / total * win_prob(v - 1, w - 1)
    
    # Day: villager eliminated
    if v <= w + 2:
        day_villager = Fraction(0)
    else:
        day_villager = Fraction(v) / total * win_prob(v - 2, w)
    
    return day_werewolf + day_villager


def parity_defect(v: int, w: int) -> Fraction:
    """Parity defect: ratio P(v,w) / P(v+1,w)."""
    denom = win_prob(v + 1, w)
    if denom == 0:
        return Fraction(0)
    return win_prob(v, w) / denom


def main():
    print("=" * 60)
    print("SOCIAL DEDUCTION GAME: RANDOM ELIMINATION PROBABILITIES")
    print("=" * 60)
    
    # Table of win probabilities
    print("\n§ Win Probability Table P(v, w)")
    print("-" * 50)
    header = 'v\\w'
    print(f"{header:>5}", end="")
    for w in range(5):
        print(f"{'w=' + str(w):>12}", end="")
    print()
    
    for v in range(1, 13):
        print(f"{v:>5}", end="")
        for w in range(5):
            p = win_prob(v, w)
            print(f"{str(p):>12}", end="")
        print()
    
    # Parity Paradox demonstration
    print("\n" + "=" * 60)
    print("§ THE PARITY PARADOX")
    print("=" * 60)
    print("\nFor w=1 (one werewolf):")
    for v in range(2, 11):
        p = win_prob(v, 1)
        marker = ""
        if v >= 3 and win_prob(v, 1) < win_prob(v - 1, 1):
            marker = " ← PARADOX (worse than v-1!)"
        print(f"  P({v}, 1) = {p} ≈ {float(p):.6f}{marker}")
    
    print("\nFor w=2 (two werewolves):")
    for v in range(3, 13):
        p = win_prob(v, 2)
        marker = ""
        if v >= 4 and win_prob(v, 2) < win_prob(v - 1, 2):
            marker = " ← PARADOX"
        print(f"  P({v}, 2) = {p} ≈ {float(p):.6f}{marker}")
    
    # Skip-Two Monotonicity
    print("\n" + "=" * 60)
    print("§ SKIP-TWO MONOTONICITY")
    print("=" * 60)
    print("\nP(v+2, w) > P(v, w) for all tested cases:")
    for w in range(1, 4):
        print(f"\n  w = {w}:")
        for v in range(w + 2, w + 12, 2):
            p1 = win_prob(v, w)
            p2 = win_prob(v + 2, w)
            check = "✓" if p2 > p1 else "✗"
            print(f"    P({v+2},{w}) - P({v},{w}) = {p2 - p1} ≈ {float(p2 - p1):.6f} {check}")
    
    # Diagonal Monotonicity
    print("\n" + "=" * 60)
    print("§ DIAGONAL MONOTONICITY")
    print("=" * 60)
    print("\nP(v+1, w-1) > P(v, w) for all tested cases:")
    for w in range(2, 5):
        print(f"\n  w = {w}:")
        for v in range(w + 2, w + 10):
            p1 = win_prob(v, w)
            p2 = win_prob(v + 1, w - 1)
            check = "✓" if p2 >= p1 else "✗"
            print(f"    P({v+1},{w-1}) - P({v},{w}) = {p2 - p1} ≈ {float(p2 - p1):.6f} {check}")
    
    # Parity Defect
    print("\n" + "=" * 60)
    print("§ PARITY DEFECT (measures paradox strength)")
    print("=" * 60)
    for w in range(1, 4):
        print(f"\n  w = {w}:")
        for v in range(w + 2, w + 12):
            d = parity_defect(v, w)
            marker = " (paradox!)" if d > 1 else ""
            print(f"    D({v},{w}) = {d} ≈ {float(d):.6f}{marker}")
    
    # Asymptotic behavior
    print("\n" + "=" * 60)
    print("§ ASYMPTOTIC CONVERGENCE TO 1")
    print("=" * 60)
    for w in range(1, 4):
        print(f"\n  w = {w}, large v:")
        for v in [10, 20, 50, 100, 200]:
            p = win_prob(v, w)
            print(f"    P({v:>3}, {w}) ≈ {float(p):.10f}")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Win Probability Heatmap for Social Deduction Games

Generates a heatmap showing win probability P(v, w) across the (v, w) plane,
with the parity structure clearly visible as alternating light/dark bands.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from fractions import Fraction
from functools import lru_cache


@lru_cache(maxsize=None)
def win_prob(v: int, w: int) -> Fraction:
    if w == 0:
        return Fraction(1)
    if v <= w:
        return Fraction(0)
    total = Fraction(v + w)
    day_w = Fraction(w) / total * (Fraction(1) if w == 1 else win_prob(v - 1, w - 1))
    day_v = Fraction(0) if v <= w + 2 else Fraction(v) / total * win_prob(v - 2, w)
    return day_w + day_v


def main():
    max_v = 30
    max_w = 10
    
    # Compute probability matrix
    prob_matrix = np.zeros((max_w + 1, max_v + 1))
    for v in range(max_v + 1):
        for w in range(max_w + 1):
            prob_matrix[w, v] = float(win_prob(v, w))
    
    fig, axes = plt.subplots(1, 2, figsize=(16, 6))
    fig.suptitle('Win Probability Landscape in Social Deduction Games', fontsize=14, fontweight='bold')
    
    # Heatmap
    ax = axes[0]
    im = ax.imshow(prob_matrix, aspect='auto', origin='lower', cmap='RdYlGn',
                    vmin=0, vmax=1, extent=[0, max_v, 0, max_w])
    ax.set_xlabel('Number of Villagers (v)')
    ax.set_ylabel('Number of Werewolves (w)')
    ax.set_title('Win Probability P(v, w)')
    plt.colorbar(im, ax=ax, label='Probability')
    
    # Diagonal line v = w
    ax.plot([0, max_w], [0, max_w], 'k--', alpha=0.5, linewidth=2, label='v = w (werewolf majority)')
    ax.legend(loc='upper left')
    
    # Parity defect heatmap
    ax = axes[1]
    defect_matrix = np.ones((max_w + 1, max_v + 1))
    for v in range(max_v):
        for w in range(1, max_w + 1):
            denom = win_prob(v + 1, w)
            if denom > 0 and v >= w + 2:
                defect_matrix[w, v] = float(win_prob(v, w) / denom)
    
    im2 = ax.imshow(defect_matrix, aspect='auto', origin='lower', cmap='RdBu_r',
                     vmin=0.8, vmax=1.5, extent=[0, max_v, 0, max_w])
    ax.set_xlabel('Number of Villagers (v)')
    ax.set_ylabel('Number of Werewolves (w)')
    ax.set_title('Parity Defect D(v, w) = P(v,w)/P(v+1,w)')
    plt.colorbar(im2, ax=ax, label='Defect (>1 = paradox)')
    
    plt.tight_layout()
    plt.savefig('win_probability_heatmap.png', dpi=150, bbox_inches='tight')
    print("Saved win_probability_heatmap.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Parity Paradox in Social Deduction Games

Generates a plot showing how win probability oscillates with villager count,
revealing the parity paradox phenomenon.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from fractions import Fraction
from functools import lru_cache


@lru_cache(maxsize=None)
def win_prob(v: int, w: int) -> Fraction:
    if w == 0:
        return Fraction(1)
    if v <= w:
        return Fraction(0)
    total = Fraction(v + w)
    day_w = Fraction(w) / total * (Fraction(1) if w == 1 else win_prob(v - 1, w - 1))
    day_v = Fraction(0) if v <= w + 2 else Fraction(v) / total * win_prob(v - 2, w)
    return day_w + day_v


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Parity Paradox in Social Deduction Games', fontsize=16, fontweight='bold')
    
    # Plot 1: Win probability vs villagers for different w
    ax = axes[0, 0]
    for w in range(1, 5):
        vs = list(range(w + 2, 25))
        probs = [float(win_prob(v, w)) for v in vs]
        ax.plot(vs, probs, 'o-', label=f'w = {w}', markersize=4)
    ax.set_xlabel('Number of Villagers (v)')
    ax.set_ylabel('Win Probability P(v, w)')
    ax.set_title('Win Probability vs Villager Count')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    # Plot 2: Even vs Odd subsequences for w=1
    ax = axes[0, 1]
    even_vs = list(range(2, 22, 2))
    odd_vs = list(range(3, 22, 2))
    even_probs = [float(win_prob(v, 1)) for v in even_vs]
    odd_probs = [float(win_prob(v, 1)) for v in odd_vs]
    ax.plot(even_vs, even_probs, 's-', color='blue', label='Even v', markersize=6)
    ax.plot(odd_vs, odd_probs, 'D-', color='red', label='Odd v', markersize=6)
    ax.set_xlabel('Number of Villagers (v)')
    ax.set_ylabel('Win Probability P(v, 1)')
    ax.set_title('Parity Paradox: Even vs Odd (w=1)')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    # Plot 3: Parity defect
    ax = axes[1, 0]
    for w in range(1, 4):
        vs = list(range(w + 2, 20))
        defects = []
        for v in vs:
            denom = win_prob(v + 1, w)
            d = float(win_prob(v, w) / denom) if denom > 0 else 0
            defects.append(d)
        ax.plot(vs, defects, 'o-', label=f'w = {w}', markersize=4)
    ax.axhline(y=1.0, color='black', linestyle='--', alpha=0.5, label='No paradox (D=1)')
    ax.set_xlabel('Number of Villagers (v)')
    ax.set_ylabel('Parity Defect D(v, w)')
    ax.set_title('Parity Defect: Strength of the Paradox')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    # Plot 4: Skip-two improvement
    ax = axes[1, 1]
    for w in range(1, 4):
        vs = list(range(w + 2, 20))
        improvements = [float(win_prob(v + 2, w) - win_prob(v, w)) for v in vs]
        ax.plot(vs, improvements, 'o-', label=f'w = {w}', markersize=4)
    ax.axhline(y=0, color='black', linestyle='--', alpha=0.5)
    ax.set_xlabel('Number of Villagers (v)')
    ax.set_ylabel('P(v+2, w) - P(v, w)')
    ax.set_title('Skip-Two Improvement (always positive)')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('parity_paradox.png', dpi=150, bbox_inches='tight')
    print("Saved parity_paradox.png")


if __name__ == "__main__":
    main()
