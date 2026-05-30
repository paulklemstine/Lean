"""
Visualization: Sperner Coloring of a 2-Simplex for a Game
==========================================================

This script visualizes how a 2-player game's best-response structure
induces a Sperner coloring on the strategy simplex. Each lattice point
is colored according to which player would most benefit from deviating,
creating a coloring pattern that (by Sperner's lemma) must contain
a fully-colored simplex - the approximate Nash equilibrium.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.tri as mtri
from matplotlib.patches import Polygon
from matplotlib.collections import PatchCollection

def compute_regrets_matching_pennies(p1: float, p2: float):
    """Compute regrets for both players in Matching Pennies.
    Player 1 payoff matrix: [[1, -1], [-1, 1]]
    Player 2 payoff matrix: [[-1, 1], [1, -1]]
    """
    # Player 1's expected payoff: p1*p2*1 + p1*(1-p2)*(-1) + (1-p1)*p2*(-1) + (1-p1)*(1-p2)*1
    ep1 = p1 * p2 - p1 * (1 - p2) - (1 - p1) * p2 + (1 - p1) * (1 - p2)
    # = 4*p1*p2 - 2*p1 - 2*p2 + 1
    
    # Deviation payoff for player 1, action 0 (Heads)
    dev1_0 = p2 * 1 + (1 - p2) * (-1)  # = 2*p2 - 1
    # Deviation payoff for player 1, action 1 (Tails)
    dev1_1 = p2 * (-1) + (1 - p2) * 1  # = 1 - 2*p2
    
    regret1 = max(dev1_0 - ep1, dev1_1 - ep1)
    
    # Player 2's expected payoff
    ep2 = -ep1  # Zero-sum
    dev2_0 = p1 * (-1) + (1 - p1) * 1
    dev2_1 = p1 * 1 + (1 - p1) * (-1)
    
    regret2 = max(dev2_0 - ep2, dev2_1 - ep2)
    
    return regret1, regret2


def sperner_color(p1: float, p2: float) -> int:
    """Assign Sperner color based on best response structure.
    Color 0 (red): Player 1 has higher regret
    Color 1 (blue): Player 2 has higher regret
    Color 2 (green): Both players approximately best-responding (Nash-like)
    """
    r1, r2 = compute_regrets_matching_pennies(p1, p2)
    total = r1 + r2
    if total < 0.1:
        return 2  # Near Nash
    elif r1 > r2:
        return 0  # Player 1 wants to deviate more
    else:
        return 1  # Player 2 wants to deviate more


fig, axes = plt.subplots(1, 3, figsize=(18, 6))

for ax_idx, k in enumerate([4, 8, 16]):
    ax = axes[ax_idx]
    
    colors_map = {0: '#e74c3c', 1: '#3498db', 2: '#2ecc71'}
    color_names = {0: 'Player 1 regret', 1: 'Player 2 regret', 2: 'Near Nash'}
    
    # Generate lattice points
    xs, ys, cs = [], [], []
    for i in range(k + 1):
        for j in range(k + 1):
            p1 = i / k
            p2 = j / k
            color = sperner_color(p1, p2)
            xs.append(p1)
            ys.append(p2)
            cs.append(colors_map[color])
    
    # Draw grid lines
    for i in range(k + 1):
        ax.axhline(y=i/k, color='lightgray', linewidth=0.5, alpha=0.5)
        ax.axvline(x=i/k, color='lightgray', linewidth=0.5, alpha=0.5)
    
    # Plot lattice points
    ax.scatter(xs, ys, c=cs, s=80 / (1 + k/8), zorder=5, edgecolors='black', linewidths=0.5)
    
    # Mark Nash equilibrium
    ax.plot(0.5, 0.5, '*', color='gold', markersize=15, zorder=10, 
            markeredgecolor='black', markeredgewidth=1.5)
    
    ax.set_xlabel('Player 1: Pr(Heads)', fontsize=11)
    ax.set_ylabel('Player 2: Pr(Heads)', fontsize=11)
    ax.set_title(f'Mesh size k = {k}', fontsize=13)
    ax.set_xlim(-0.05, 1.05)
    ax.set_ylim(-0.05, 1.05)
    ax.set_aspect('equal')

# Add legend
from matplotlib.lines import Line2D
legend_elements = [
    Line2D([0], [0], marker='o', color='w', markerfacecolor='#e74c3c', 
           markersize=10, label='Player 1 wants to deviate'),
    Line2D([0], [0], marker='o', color='w', markerfacecolor='#3498db', 
           markersize=10, label='Player 2 wants to deviate'),
    Line2D([0], [0], marker='o', color='w', markerfacecolor='#2ecc71', 
           markersize=10, label='Near Nash equilibrium'),
    Line2D([0], [0], marker='*', color='w', markerfacecolor='gold', 
           markersize=15, markeredgecolor='black', label='Exact Nash (0.5, 0.5)')
]
fig.legend(handles=legend_elements, loc='lower center', ncol=4, fontsize=11,
           bbox_to_anchor=(0.5, -0.02))

fig.suptitle('Sperner Coloring of Strategy Space (Matching Pennies)',
             fontsize=15, fontweight='bold', y=1.02)

plt.tight_layout()
plt.savefig('viz_sperner_coloring.png', dpi=150, bbox_inches='tight')
plt.close()

print("Saved viz_sperner_coloring.png")
