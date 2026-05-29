#!/usr/bin/env python3
"""
Visualization 2: Darkness Dominance Ratios

Visualizes the ratio f_{k+1}(n) / f_k(n) for successive levels,
showing how the dominance gap widens. This illustrates the strict
hierarchy theorem: each darkness level is qualitatively harder
than the previous one.
"""
import numpy as np
import matplotlib.pyplot as plt


def fast_grow_closed(k, n):
    """Closed-form fast-growing hierarchy."""
    if k == 0:
        return n + 1
    elif k == 1:
        return n + 2
    elif k == 2:
        return 2 * n + 3
    elif k == 3:
        return 2 ** (n + 3) - 3
    return None


fig, axes = plt.subplots(1, 3, figsize=(15, 5))
colors = ['#2196F3', '#4CAF50', '#FF9800']
titles = [
    r'$f_1(n) / f_0(n)$: Level 0→1',
    r'$f_2(n) / f_1(n)$: Level 1→2',
    r'$f_3(n) / f_2(n)$: Level 2→3',
]

for idx, k in enumerate(range(3)):
    ax = axes[idx]
    n_max = 12 if k < 2 else 10
    n_vals = np.arange(0, n_max)

    ratios = []
    for n in n_vals:
        fk = fast_grow_closed(k, int(n))
        fk1 = fast_grow_closed(k + 1, int(n))
        ratios.append(fk1 / fk if fk > 0 else 0)

    bars = ax.bar(n_vals, ratios, color=colors[idx], alpha=0.7, edgecolor='white')

    # Color bars differently when ratio > 2 (density conjecture)
    for i, (bar, ratio) in enumerate(zip(bars, ratios)):
        if ratio > 2:
            bar.set_facecolor('#F44336')
            bar.set_alpha(0.8)

    ax.axhline(y=2, color='red', linestyle='--', alpha=0.5,
               label='Density threshold (ratio = 2)')
    ax.axhline(y=1, color='gray', linestyle='-', alpha=0.3)

    ax.set_xlabel('n', fontsize=11)
    ax.set_ylabel('Ratio', fontsize=11)
    ax.set_title(titles[idx], fontsize=12)
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.2, axis='y')

    if k == 2:
        ax.set_yscale('log')
        ax.set_ylabel('Ratio (log scale)', fontsize=11)

# Add explanatory text
fig.text(0.5, -0.05,
         'Red bars: ratio exceeds 2 (darkness density threshold).\n'
         'The exponential jump at Level 2→3 shows why level 3 darkness '
         'is qualitatively different.',
         ha='center', fontsize=10, style='italic',
         bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

plt.suptitle('Darkness Dominance: How Fast Does Each Level Outgrow the Previous?',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_dominance.png', dpi=150, bbox_inches='tight')
print("Saved viz_dominance.png")
