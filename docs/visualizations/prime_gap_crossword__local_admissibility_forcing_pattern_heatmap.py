#!/usr/bin/env python3
"""
Visualization: Forcing Pattern Heatmap

Visualizes which gap word prefixes are "forcing" (uniquely determine the next gap)
under different sieve sets. Each cell shows whether a length-2 gap word [g1, g2]
is forcing, ambiguous, or inadmissible under the sieve S = {2, 3, 5}.

The heatmap reveals the structure of the "prime crossword grammar" — which
local patterns leave no choice for the next move.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import prod
from typing import List, Set

# ── Self-contained core algorithms ──────────────────────────────────────

def gap_word_positions(gaps: List[int]) -> List[int]:
    pos = [0]
    s = 0
    for g in gaps:
        s += g
        pos.append(s)
    return pos

def interior_positions(gaps: List[int]) -> Set[int]:
    positions = gap_word_positions(gaps)
    interior: Set[int] = set()
    for i in range(len(positions) - 1):
        for x in range(positions[i] + 1, positions[i + 1]):
            interior.add(x)
    return interior

def is_admissible_at(S: Set[int], gaps: List[int], a: int) -> bool:
    positions = gap_word_positions(gaps)
    inter = interior_positions(gaps)
    for t in positions:
        if any((a + t) % q == 0 for q in S):
            return False
    for u in inter:
        if not any((a + u) % q == 0 for q in S):
            return False
    return True

def admissible_over(S: Set[int], gaps: List[int]) -> bool:
    M = prod(S) if S else 1
    return any(is_admissible_at(S, gaps, a) for a in range(M))

def next_gaps(S: Set[int], word: List[int], max_gap: int = 20) -> Set[int]:
    return {g for g in range(1, max_gap + 1) if admissible_over(S, word + [g])}

# ── Build heatmap data ──────────────────────────────────────────────────

fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

sieve_configs = [
    ({2, 3}, "S = {2, 3}, M = 6"),
    ({2, 3, 5}, "S = {2, 3, 5}, M = 30"),
    ({2, 3, 5, 7}, "S = {2, 3, 5, 7}, M = 210"),
]

even_gaps = list(range(2, 16, 2))  # [2, 4, 6, 8, 10, 12, 14]
n = len(even_gaps)

for ax_idx, (S, title) in enumerate(sieve_configs):
    data = np.full((n, n), np.nan)

    for i, g1 in enumerate(even_gaps):
        for j, g2 in enumerate(even_gaps):
            word = [g1, g2]
            if not admissible_over(S, word):
                data[i, j] = -1  # inadmissible
            else:
                ng = next_gaps(S, word, 20)
                if len(ng) == 1:
                    data[i, j] = 1  # forcing
                elif len(ng) > 1:
                    data[i, j] = 0  # ambiguous

    # Custom colormap: gray=inadmissible, yellow=ambiguous, green=forcing
    from matplotlib.colors import ListedColormap, BoundaryNorm
    cmap = ListedColormap(['#cccccc', '#ffdd57', '#48c774'])
    bounds = [-1.5, -0.5, 0.5, 1.5]
    norm = BoundaryNorm(bounds, cmap.N)

    im = axes[ax_idx].imshow(data, cmap=cmap, norm=norm,
                              origin='lower', aspect='equal')
    axes[ax_idx].set_xticks(range(n))
    axes[ax_idx].set_xticklabels(even_gaps)
    axes[ax_idx].set_yticks(range(n))
    axes[ax_idx].set_yticklabels(even_gaps)
    axes[ax_idx].set_xlabel('Second gap (g₂)')
    axes[ax_idx].set_ylabel('First gap (g₁)')
    axes[ax_idx].set_title(title, fontsize=11)

    # Annotate forcing cells
    for i in range(n):
        for j in range(n):
            if data[i, j] == 1:
                word = [even_gaps[i], even_gaps[j]]
                ng = next_gaps(S, word, 20)
                forced = ng.pop()
                axes[ax_idx].text(j, i, f'→{forced}', ha='center', va='center',
                                   fontsize=7, fontweight='bold', color='#1a1a1a')
            elif data[i, j] == 0:
                word = [even_gaps[i], even_gaps[j]]
                ng = sorted(next_gaps(S, word, 20))
                label = ','.join(str(g) for g in ng[:3])
                if len(ng) > 3:
                    label += '…'
                axes[ax_idx].text(j, i, label, ha='center', va='center',
                                   fontsize=5, color='#555')

# Add legend
from matplotlib.patches import Patch
legend_elements = [
    Patch(facecolor='#48c774', label='Forcing (unique next gap)'),
    Patch(facecolor='#ffdd57', label='Ambiguous (multiple next gaps)'),
    Patch(facecolor='#cccccc', label='Inadmissible'),
]
fig.legend(handles=legend_elements, loc='lower center', ncol=3,
           fontsize=10, frameon=False, bbox_to_anchor=(0.5, -0.02))

fig.suptitle('Prime Gap Crossword: Forcing Patterns for Length-2 Words',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('forcing_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved forcing_heatmap.png")
