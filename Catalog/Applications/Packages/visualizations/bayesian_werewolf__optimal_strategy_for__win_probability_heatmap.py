#!/usr/bin/env python3
"""
Visualization 1: Villager Win Probability Heatmap

Visualizes the exact villager win probability under random elimination
as a heatmap over the (wolves, villagers) state space. The absorbing
states (wolves = 0 or wolves ≥ villagers) form the boundary conditions.
This directly corresponds to the Lean-verified `villagerWinProb` function.
"""

import numpy as np
import matplotlib.pyplot as plt
from functools import lru_cache


@lru_cache(maxsize=None)
def villager_win_prob(w: int, v: int) -> float:
    """Exact villager win probability under random elimination."""
    if w == 0:
        return 1.0 if v > 0 else 0.0
    if w >= v:
        return 0.0
    if v <= 1:
        return 0.0
    tot = w + v
    return (w / tot) * villager_win_prob(w - 1, v - 1) + \
           (v / tot) * villager_win_prob(w, v - 2)


max_w = 10
max_v = 20

# Build heatmap data
data = np.full((max_w + 1, max_v + 1), np.nan)
for w in range(max_w + 1):
    for v in range(max_v + 1):
        data[w, v] = villager_win_prob(w, v)

fig, ax = plt.subplots(figsize=(12, 7))
im = ax.imshow(data, origin='lower', aspect='auto',
               cmap='RdYlGn', vmin=0, vmax=1,
               extent=[-0.5, max_v + 0.5, -0.5, max_w + 0.5])

# Add diagonal line for w = v (werewolf win boundary)
ax.plot([0, max_w], [0, max_w], 'k--', linewidth=2, label='w = v (wolf win boundary)')

# Annotate key states
for w in range(max_w + 1):
    for v in range(max_v + 1):
        if w + v <= 12 and not np.isnan(data[w, v]):
            val = data[w, v]
            color = 'white' if val < 0.3 or val > 0.7 else 'black'
            ax.text(v, w, f'{val:.2f}', ha='center', va='center',
                    fontsize=6, color=color, fontweight='bold')

ax.set_xlabel('Villagers (v)', fontsize=14)
ax.set_ylabel('Werewolves (w)', fontsize=14)
ax.set_title('Villager Win Probability Under Random Elimination\n'
             '(Markov Chain Absorption Probability)',
             fontsize=16, fontweight='bold')

cbar = plt.colorbar(im, ax=ax, shrink=0.8)
cbar.set_label('P(Villagers Win)', fontsize=12)

ax.legend(loc='upper right', fontsize=11)
plt.tight_layout()
plt.savefig('viz_win_probability.png', dpi=150, bbox_inches='tight')
print("Saved viz_win_probability.png")
