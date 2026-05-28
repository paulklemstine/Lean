"""
Visualization: Independent Prime Channels in Torsion Persistence

Shows how torsion information decomposes into independent prime channels,
with each channel having its own stability properties. Illustrates the
cross-domain theorem (prime decomposition of torsion births).

Creates a multi-panel figure showing torsion presence/absence across
filtration levels for different primes.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from dataclasses import dataclass, field


# ============================================================
# Inline implementations
# ============================================================

@dataclass
class FinAb:
    free_rank: int = 0
    torsion_orders: list = field(default_factory=list)

@dataclass
class PersMod:
    groups: list

def p_torsion_detected(G, p):
    return any(n % p == 0 for n in G.torsion_orders)

def p_primary_subgroup(G, p):
    orders = []
    for n in G.torsion_orders:
        pk, m = 1, n
        while m % p == 0:
            pk *= p
            m //= p
        if pk > 1:
            orders.append(pk)
    return FinAb(free_rank=0, torsion_orders=sorted(orders))

def torsion_strength(G, p):
    """Compute 'strength' of p-torsion in G."""
    total = 0
    for n in G.torsion_orders:
        pk, m = 1, n
        while m % p == 0:
            pk *= p
            m //= p
        if pk > 1:
            total += np.log2(pk)
    return total


# ============================================================
# Create example modules
# ============================================================

# Module F: rich multi-prime torsion with staggered births
F = PersMod(groups=[
    FinAb(free_rank=3),                          # 0: pure free
    FinAb(free_rank=2, torsion_orders=[4]),       # 1: 2-torsion appears
    FinAb(free_rank=1, torsion_orders=[4, 3]),    # 2: 3-torsion appears
    FinAb(torsion_orders=[8, 9]),                 # 3: deeper torsion
    FinAb(torsion_orders=[8, 9, 5]),              # 4: 5-torsion appears
    FinAb(torsion_orders=[16, 27, 25]),           # 5: all grow
    FinAb(torsion_orders=[32, 27, 25, 7]),        # 6: 7-torsion appears
    FinAb(torsion_orders=[32, 81, 125, 49]),      # 7: all present
    FinAb(torsion_orders=[64, 81, 125, 49]),      # 8: mature
    FinAb(torsion_orders=[128, 243, 625, 343]),   # 9: full development
])

# Module G: similar but shifted
G = PersMod(groups=[
    FinAb(free_rank=2),                          # 0: free
    FinAb(free_rank=1),                          # 1: still free
    FinAb(torsion_orders=[2]),                   # 2: 2-torsion late
    FinAb(torsion_orders=[4, 3]),                # 3: 3-torsion appears
    FinAb(torsion_orders=[8, 9]),                # 4: growing
    FinAb(torsion_orders=[16, 27, 5]),           # 5: 5-torsion appears
    FinAb(torsion_orders=[32, 27, 25]),          # 6: growing
    FinAb(torsion_orders=[32, 81, 25, 7]),       # 7: 7-torsion appears
    FinAb(torsion_orders=[64, 81, 125, 49]),     # 8: mature
    FinAb(torsion_orders=[128, 243, 625, 343]),  # 9: full
])

primes = [2, 3, 5, 7]
prime_colors = {2: '#e74c3c', 3: '#3498db', 5: '#2ecc71', 7: '#f39c12'}
n_levels = len(F.groups)

# ============================================================
# Figure
# ============================================================

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
axes = axes.flatten()

for idx, p in enumerate(primes):
    ax = axes[idx]
    color = prime_colors[p]

    # Compute torsion strength at each level for F and G
    strengths_F = [torsion_strength(F.groups[i], p) for i in range(n_levels)]
    strengths_G = [torsion_strength(G.groups[i], p) for i in range(n_levels)]

    levels = np.arange(n_levels)
    width = 0.35

    bars_F = ax.bar(levels - width/2, strengths_F, width, label='Module F',
                    color=color, alpha=0.8, edgecolor='white')
    bars_G = ax.bar(levels + width/2, strengths_G, width, label='Module G',
                    color=color, alpha=0.4, edgecolor=color, linewidth=1.5,
                    linestyle='--')

    # Mark birth indices
    birth_F = None
    for i in range(n_levels):
        if p_torsion_detected(F.groups[i], p):
            birth_F = i
            break
    birth_G = None
    for i in range(n_levels):
        if p_torsion_detected(G.groups[i], p):
            birth_G = i
            break

    if birth_F is not None:
        ax.annotate('Birth(F)', xy=(birth_F - width/2, strengths_F[birth_F]),
                   xytext=(birth_F - 1.5, max(strengths_F) * 0.9),
                   arrowprops=dict(arrowstyle='->', color=color, lw=2),
                   fontsize=10, fontweight='bold', color=color)
    if birth_G is not None:
        ax.annotate('Birth(G)', xy=(birth_G + width/2, strengths_G[birth_G]),
                   xytext=(birth_G + 1.5, max(strengths_G or [1]) * 0.85),
                   arrowprops=dict(arrowstyle='->', color=color, lw=2, linestyle='--'),
                   fontsize=10, fontweight='bold', color=color, alpha=0.7)

    # Distance annotation
    if birth_F is not None and birth_G is not None:
        dist = abs(birth_F - birth_G)
        mid = (birth_F + birth_G) / 2
        ax.text(mid, max(max(strengths_F), max(strengths_G or [0])) * 1.05,
               f'δ_{p} = {dist}', ha='center', fontsize=12,
               fontweight='bold', color=color,
               bbox=dict(boxstyle='round,pad=0.3', facecolor='white',
                        edgecolor=color, alpha=0.9))

    ax.set_xlabel('Filtration Level', fontsize=11)
    ax.set_ylabel(f'{p}-Primary Strength (log₂)', fontsize=11)
    ax.set_title(f'Prime Channel p = {p}', fontsize=13, fontweight='bold', color=color)
    ax.set_xticks(levels)
    ax.legend(fontsize=10, loc='upper left')
    ax.set_ylim(0, max(max(strengths_F), max(strengths_G or [0])) * 1.25)

plt.suptitle('Independent Prime Channels in Torsion Persistence\n'
            'Each prime provides a separate "frequency band" of torsion information',
            fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_prime_channels.png', dpi=150, bbox_inches='tight')
print("Saved viz_prime_channels.png")
