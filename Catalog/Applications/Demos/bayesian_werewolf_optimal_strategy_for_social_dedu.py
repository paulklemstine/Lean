#!/usr/bin/env python3
"""
Bayesian Werewolf: Numerical Demonstrations

Demonstrates the key results from the Elimination Game Theory formalization:
1. Random-play win probability computation
2. The Parity Paradox
3. Accuracy-parameterized win probability
4. Information advantage quantification
"""

from fractions import Fraction
from functools import lru_cache
from typing import Dict, List, Tuple


@lru_cache(maxsize=None)
def wolf_prob(v: int, w: int) -> Fraction:
    """Villager win probability with v villagers, w werewolves, random day voting."""
    if w == 0:
        return Fraction(1)
    if v <= w:
        return Fraction(0)
    
    total = Fraction(v + w)
    p_wolf = Fraction(w) / total
    p_vill = Fraction(v) / total
    
    # After day eliminates werewolf
    if w == 1:
        after_wolf = Fraction(1)
    else:
        after_wolf = wolf_prob(v - 1, w - 1)  # night kills villager
    
    # After day eliminates villager
    if w >= v - 1:
        after_vill = Fraction(0)
    elif w >= v - 2:
        after_vill = Fraction(0)
    else:
        after_vill = wolf_prob(v - 2, w)  # night kills villager
    
    return p_wolf * after_wolf + p_vill * after_vill


@lru_cache(maxsize=None)
def apeg_win_prob(v: int, w: int, p: Fraction) -> Fraction:
    """Win probability with constant accuracy p."""
    if w == 0:
        return Fraction(1)
    if v <= w:
        return Fraction(0)
    
    if w == 1:
        after_wolf = Fraction(1)
    elif v <= w - 1:
        after_wolf = Fraction(0)
    else:
        after_wolf = apeg_win_prob(v - 1, w - 1, p)
    
    if w >= v - 1:
        after_vill = Fraction(0)
    elif w >= v - 2:
        after_vill = Fraction(0)
    else:
        after_vill = apeg_win_prob(v - 2, w, p)
    
    return p * after_wolf + (1 - p) * after_vill


def demo_basic_probabilities():
    """Show win probabilities for standard game sizes."""
    print("=" * 60)
    print("RANDOM-PLAY WIN PROBABILITIES")
    print("=" * 60)
    print(f"{'Players':>8} {'Villagers':>10} {'Wolves':>7} {'P(win)':>15} {'Decimal':>10}")
    print("-" * 60)
    
    games = [
        (2, 1), (3, 1), (4, 1), (5, 1), (6, 1), (7, 1), (8, 1),
        (3, 2), (4, 2), (5, 2), (6, 2), (7, 2),
        (5, 3), (7, 3), (8, 3), (10, 3),
    ]
    
    for v, w in games:
        p = wolf_prob(v, w)
        print(f"{v+w:>8} {v:>10} {w:>7} {str(p):>15} {float(p):>10.4f}")


def demo_parity_paradox():
    """Demonstrate the Parity Paradox."""
    print("\n" + "=" * 60)
    print("THE PARITY PARADOX (w = 1)")
    print("=" * 60)
    print("Adding one villager to an even-count village DECREASES")
    print("the win probability!")
    print()
    print(f"{'Villagers':>10} {'P(win)':>15} {'Decimal':>10} {'Change':>10}")
    print("-" * 50)
    
    prev = None
    for v in range(2, 16):
        p = wolf_prob(v, 1)
        change = ""
        if prev is not None:
            diff = p - prev
            if diff > 0:
                change = f"+{float(diff):.4f} ↑"
            else:
                change = f"{float(diff):.4f} ↓"
        print(f"{v:>10} {str(p):>15} {float(p):>10.4f} {change:>10}")
        prev = p
    
    print("\nPattern: Even → Odd always drops! Odd → Even always rises!")


def demo_information_advantage():
    """Show how accuracy affects win probability."""
    print("\n" + "=" * 60)
    print("INFORMATION ADVANTAGE (v=5, w=2)")
    print("=" * 60)
    print("Standard game: 7 players (5 villagers, 2 werewolves)")
    print(f"Random play accuracy: 2/7 ≈ {2/7:.4f}")
    print(f"Random play win prob: {wolf_prob(5, 2)} ≈ {float(wolf_prob(5, 2)):.4f}")
    print()
    print(f"{'Accuracy p':>12} {'P(win)':>15} {'Decimal':>10} {'Improvement':>12}")
    print("-" * 55)
    
    base = wolf_prob(5, 2)
    for p_num in range(0, 11):
        p = Fraction(p_num, 10)
        wp = apeg_win_prob(5, 2, p)
        improvement = float(wp) / float(base) if float(base) > 0 else float('inf')
        print(f"{float(p):>12.2f} {str(wp):>15} {float(wp):>10.4f} {improvement:>11.2f}x")


def demo_threshold_accuracy():
    """Find the minimum accuracy needed for >50% win probability."""
    print("\n" + "=" * 60)
    print("THRESHOLD ACCURACY FOR 50% WIN PROBABILITY")
    print("=" * 60)
    
    games = [(3, 1), (5, 1), (5, 2), (7, 2), (7, 3), (10, 3)]
    
    for v, w in games:
        # Binary search for threshold
        lo, hi = Fraction(0), Fraction(1)
        for _ in range(100):
            mid = (lo + hi) / 2
            if apeg_win_prob(v, w, mid) < Fraction(1, 2):
                lo = mid
            else:
                hi = mid
        
        threshold = float((lo + hi) / 2)
        base_rate = float(Fraction(w, v + w))
        random_prob = float(wolf_prob(v, w))
        
        print(f"  ({v}v, {w}w): base rate = {base_rate:.3f}, "
              f"threshold = {threshold:.3f}, "
              f"random P(win) = {random_prob:.3f}, "
              f"needed accuracy = {threshold/base_rate:.1f}x base")


def demo_loss_product_formula():
    """Verify the loss probability product formula for w=1."""
    print("\n" + "=" * 60)
    print("LOSS PROBABILITY PRODUCT FORMULA (w = 1)")
    print("=" * 60)
    print("Q(v) = 1 - P(v, 1) satisfies Q(v+2) = (v+2)/(v+3) · Q(v)")
    print()
    
    for v in range(2, 14):
        q = 1 - wolf_prob(v, 1)
        if v >= 4:
            q_prev = 1 - wolf_prob(v - 2, 1)
            ratio = q / q_prev if q_prev != 0 else None
            expected = Fraction(v, v + 1)
            print(f"  Q({v:2d}) = {str(q):>15}  |  Q({v})/Q({v-2}) = {str(ratio):>10} = {v}/{v+1} ✓")
        else:
            print(f"  Q({v:2d}) = {str(q):>15}  |  (base case)")


def demo_scaling():
    """Show how win probability scales with game size."""
    print("\n" + "=" * 60)
    print("SCALING: WIN PROBABILITY vs GAME SIZE")
    print("=" * 60)
    print("Fixed ratio k/n = 2/7 (approximately)")
    print()
    
    for n in [7, 14, 21, 28, 35]:
        w = max(1, round(2 * n / 7))
        v = n - w
        if v <= w:
            continue
        p = wolf_prob(v, w)
        print(f"  n={n:2d}, w={w}, v={v:2d}: P(win) = {float(p):.6f}")


if __name__ == "__main__":
    demo_basic_probabilities()
    demo_parity_paradox()
    demo_loss_product_formula()
    demo_information_advantage()
    demo_threshold_accuracy()
    demo_scaling()


#!/usr/bin/env python3
"""
Visualization 2: Information Advantage in Werewolf Games

Shows how voting accuracy affects win probability, demonstrating
the value of Bayesian inference in social deduction games.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from fractions import Fraction
from functools import lru_cache


@lru_cache(maxsize=None)
def apeg_win_prob(v: int, w: int, p_num: int, p_den: int) -> Fraction:
    p = Fraction(p_num, p_den)
    if w == 0:
        return Fraction(1)
    if v <= w:
        return Fraction(0)
    after_wolf = Fraction(1) if w == 1 else (Fraction(0) if v <= w - 1 else apeg_win_prob(v - 1, w - 1, p_num, p_den))
    if w >= v - 1 or w >= v - 2:
        after_vill = Fraction(0)
    else:
        after_vill = apeg_win_prob(v - 2, w, p_num, p_den)
    return p * after_wolf + (1 - p) * after_vill


@lru_cache(maxsize=None)
def wolf_prob(v: int, w: int) -> Fraction:
    if w == 0:
        return Fraction(1)
    if v <= w:
        return Fraction(0)
    total = v + w
    p_wolf = Fraction(w, total)
    p_vill = Fraction(v, total)
    after_wolf = Fraction(1) if w == 1 else wolf_prob(v - 1, w - 1)
    if w >= v - 1 or w >= v - 2:
        after_vill = Fraction(0)
    else:
        after_vill = wolf_prob(v - 2, w)
    return p_wolf * after_wolf + p_vill * after_vill


fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Plot 1: Win probability as function of accuracy for different game sizes
ax1 = axes[0]
accuracies = np.linspace(0, 1, 101)

games = [(5, 2, '#2196F3', '5v 2w (7 players)'),
         (7, 2, '#4CAF50', '7v 2w (9 players)'),
         (5, 1, '#FF9800', '5v 1w (6 players)'),
         (8, 3, '#9C27B0', '8v 3w (11 players)')]

for v, w, color, label in games:
    probs = []
    for p in accuracies:
        p_frac = Fraction(p).limit_denominator(1000)
        wp = float(apeg_win_prob(v, w, p_frac.numerator, max(1, p_frac.denominator)))
        probs.append(wp)
    ax1.plot(accuracies, probs, color=color, linewidth=2, label=label)
    
    # Mark the random play point
    base_rate = w / (v + w)
    random_prob = float(wolf_prob(v, w))
    ax1.plot(base_rate, random_prob, 'o', color=color, markersize=8, 
             markeredgecolor='black', markeredgewidth=1.5)

ax1.axhline(y=0.5, color='gray', linestyle='--', alpha=0.5, label='50% threshold')
ax1.set_xlabel('Day-Vote Accuracy p', fontsize=12)
ax1.set_ylabel('Win Probability', fontsize=12)
ax1.set_title('Information Advantage\n(dots = random play base rate)', fontsize=14, fontweight='bold')
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.3)

# Plot 2: Threshold accuracy needed for 50% win
ax2 = axes[1]
wolf_counts = [1, 2, 3]
colors = ['#2196F3', '#F44336', '#4CAF50']

for w, color in zip(wolf_counts, colors):
    vs = list(range(w + 2, 20))
    thresholds = []
    base_rates = []
    
    for v in vs:
        lo, hi = 0.0, 1.0
        for _ in range(60):
            mid = (lo + hi) / 2
            mid_frac = Fraction(mid).limit_denominator(500)
            wp = float(apeg_win_prob(v, w, mid_frac.numerator, max(1, mid_frac.denominator)))
            if wp < 0.5:
                lo = mid
            else:
                hi = mid
        thresholds.append((lo + hi) / 2)
        base_rates.append(w / (v + w))
    
    ax2.plot(vs, thresholds, 'o-', color=color, linewidth=2, markersize=5,
             label=f'Threshold (w={w})')
    ax2.plot(vs, base_rates, '--', color=color, alpha=0.4,
             label=f'Base rate (w={w})')

ax2.set_xlabel('Number of Villagers', fontsize=12)
ax2.set_ylabel('Accuracy', fontsize=12)
ax2.set_title('Threshold Accuracy for 50% Win\n(solid = needed, dashed = random)', 
              fontsize=14, fontweight='bold')
ax2.legend(fontsize=8, ncol=2)
ax2.grid(True, alpha=0.3)
ax2.set_ylim(0, 1)

plt.tight_layout()
plt.savefig('information_advantage.png', dpi=150, bbox_inches='tight')
print("Saved information_advantage.png")


#!/usr/bin/env python3
"""
Visualization 1: The Parity Paradox in Werewolf Games

Shows how the villager win probability oscillates with the number of villagers,
creating a surprising sawtooth pattern where more allies can hurt.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from fractions import Fraction
from functools import lru_cache


@lru_cache(maxsize=None)
def wolf_prob(v: int, w: int) -> Fraction:
    if w == 0:
        return Fraction(1)
    if v <= w:
        return Fraction(0)
    total = v + w
    p_wolf = Fraction(w, total)
    p_vill = Fraction(v, total)
    after_wolf = Fraction(1) if w == 1 else wolf_prob(v - 1, w - 1)
    if w >= v - 1 or w >= v - 2:
        after_vill = Fraction(0)
    else:
        after_vill = wolf_prob(v - 2, w)
    return p_wolf * after_wolf + p_vill * after_vill


fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Plot 1: The parity paradox for w=1
ax1 = axes[0]
vs = list(range(2, 20))
probs = [float(wolf_prob(v, 1)) for v in vs]
evens = [(v, p) for v, p in zip(vs, probs) if v % 2 == 0]
odds = [(v, p) for v, p in zip(vs, probs) if v % 2 == 1]

ax1.plot(vs, probs, 'k-', alpha=0.3, linewidth=1)
ax1.scatter([v for v, _ in evens], [p for _, p in evens], 
            color='#2196F3', s=80, zorder=5, label='Even villagers')
ax1.scatter([v for v, _ in odds], [p for _, p in odds], 
            color='#F44336', s=80, zorder=5, label='Odd villagers')

# Draw arrows showing drops
for i in range(len(vs) - 1):
    if vs[i] % 2 == 0:  # even to odd: drops
        ax1.annotate('', xy=(vs[i+1], probs[i+1]), xytext=(vs[i], probs[i]),
                    arrowprops=dict(arrowstyle='->', color='#F44336', lw=1.5, alpha=0.5))

ax1.set_xlabel('Number of Villagers', fontsize=12)
ax1.set_ylabel('Win Probability P(v, 1)', fontsize=12)
ax1.set_title('The Parity Paradox\n(Single Werewolf)', fontsize=14, fontweight='bold')
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)
ax1.set_ylim(0, 0.8)

# Plot 2: Win probability heatmap for multiple wolves
ax2 = axes[1]
max_v, max_w = 15, 6
data = np.zeros((max_w, max_v))
for w in range(1, max_w + 1):
    for v in range(1, max_v + 1):
        data[w-1][v-1] = float(wolf_prob(v, w))

im = ax2.imshow(data, cmap='RdYlGn', aspect='auto', origin='lower',
                vmin=0, vmax=1, extent=[0.5, max_v+0.5, 0.5, max_w+0.5])
ax2.set_xlabel('Number of Villagers', fontsize=12)
ax2.set_ylabel('Number of Werewolves', fontsize=12)
ax2.set_title('Win Probability Landscape\nP(v, w) under Random Play', fontsize=14, fontweight='bold')
plt.colorbar(im, ax=ax2, label='P(villagers win)')

# Add text annotations
for w in range(1, min(max_w + 1, 5)):
    for v in range(1, max_v + 1):
        val = data[w-1][v-1]
        if val > 0.01:
            ax2.text(v, w, f'{val:.2f}', ha='center', va='center', fontsize=6,
                    color='white' if val < 0.4 else 'black')

plt.tight_layout()
plt.savefig('parity_paradox.png', dpi=150, bbox_inches='tight')
print("Saved parity_paradox.png")
