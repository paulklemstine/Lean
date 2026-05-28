"""
Visualization: Shadow Size Heatmap on the Integer Simplex

For n=3 and various degrees d, shows the shadow size of each singleton {α}
(which equals the support size) on the simplex lattice. Also shows the
optimal lex-initial segments highlighted.

CRITICAL: Fully self-contained. No local imports.
"""

import matplotlib.pyplot as plt
import numpy as np
from typing import List, Tuple, Set


def degree_slice(n: int, d: int) -> List[Tuple[int, ...]]:
    if n == 0:
        return [()] if d == 0 else []
    if n == 1:
        return [(d,)]
    result = []
    for k in range(d + 1):
        for rest in degree_slice(n - 1, d - k):
            result.append((k,) + rest)
    return result


def shadow(family: Set[Tuple[int, ...]]) -> Set[Tuple[int, ...]]:
    result = set()
    for alpha in family:
        for i in range(len(alpha)):
            if alpha[i] > 0:
                beta = list(alpha)
                beta[i] -= 1
                result.add(tuple(beta))
    return result


def bary_to_xy(alpha, d):
    x = alpha[1] + 0.5 * alpha[2]
    y = alpha[2] * np.sqrt(3) / 2
    return x / max(d, 1), y / max(d, 1)


fig, axes = plt.subplots(2, 3, figsize=(16, 10))

for idx, d in enumerate([2, 3, 4, 5, 6, 7]):
    ax = axes[idx // 3][idx % 3]
    slc = degree_slice(3, d)
    
    # Draw simplex outline
    corners = np.array([[0, 0], [1, 0], [0.5, np.sqrt(3)/2], [0, 0]])
    ax.plot(corners[:, 0], corners[:, 1], 'k-', linewidth=1)
    
    # Color by support size (= singleton shadow size)
    for alpha in slc:
        x, y = bary_to_xy(alpha, d)
        supp = sum(1 for a in alpha if a > 0)
        
        # Color map: 1=blue (concentrated), 2=yellow, 3=red (spread)
        if supp == 1:
            color = '#2196F3'
            size = 10
        elif supp == 2:
            color = '#FFC107'
            size = 8
        else:
            color = '#F44336'
            size = 6
        
        ax.plot(x, y, 'o', color=color, markersize=size, zorder=2)
    
    # Highlight lex-initial segment for m = (slice_size + 1) // 2
    m = max(1, len(slc) // 2)
    lex_seg = set(sorted(slc)[:m])
    for alpha in lex_seg:
        x, y = bary_to_xy(alpha, d)
        ax.plot(x, y, 's', color='none', markeredgecolor='black',
                markeredgewidth=1.5, markersize=12, zorder=3)
    
    sh_size = len(shadow(lex_seg))
    ax.set_title(f'd={d}: {len(slc)} pts, lex-{m} shadow={sh_size}', fontsize=10)
    ax.set_aspect('equal')
    ax.axis('off')

# Add legend
from matplotlib.lines import Line2D
legend_elements = [
    Line2D([0], [0], marker='o', color='w', markerfacecolor='#2196F3',
           markersize=10, label='Support 1 (concentrated)'),
    Line2D([0], [0], marker='o', color='w', markerfacecolor='#FFC107',
           markersize=8, label='Support 2 (mixed)'),
    Line2D([0], [0], marker='o', color='w', markerfacecolor='#F44336',
           markersize=6, label='Support 3 (spread)'),
    Line2D([0], [0], marker='s', color='w', markeredgecolor='black',
           markeredgewidth=1.5, markersize=10, label='Lex-initial segment'),
]
fig.legend(handles=legend_elements, loc='lower center', ncol=4, fontsize=10,
           bbox_to_anchor=(0.5, -0.02))

plt.suptitle('Multi-Index Support Structure on the Integer Simplex (n=3)',
             fontsize=14, y=1.02)
plt.tight_layout()
plt.savefig('viz_simplex_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_simplex_heatmap.png")
