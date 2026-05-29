#!/usr/bin/env python3
"""
Visualization 3: Prime Decomposition Timeline

Visualizes the temporal evolution of torsion along different prime channels.
Each prime gets its own colored timeline, showing when p-torsion appears.
The global birth set is shown as the union of all prime timelines.

This directly illustrates the decomposition theorem:
  globalTorsionBirthSet = ⋃_p pTorsionBirthSet(p)
and shows how the union operation loses prime-channel information.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def p_torsion_birth_set(p, max_level, orders_at):
    return {i for i in range(max_level + 1) if any(m > 1 and m % p == 0 for m in orders_at.get(i, []))}

def global_torsion_birth_set(max_level, orders_at):
    return {i for i in range(max_level + 1) if any(m > 1 for m in orders_at.get(i, []))}


# Two profiles to compare
profiles = [
    ("Profile F: {2}@1, {6}@3", 3, {1: [2], 3: [6]}),
    ("Profile G: {3}@1, {6}@3", 3, {1: [3], 3: [6]}),
]

primes = [2, 3, 5]
prime_colors = {2: '#e74c3c', 3: '#3498db', 5: '#2ecc71'}
prime_labels = {2: 'p=2 (even)', 3: 'p=3', 5: 'p=5'}

fig, axes = plt.subplots(len(profiles), 1, figsize=(14, 6), sharex=True)

for ax_idx, (name, ml, orders) in enumerate(profiles):
    ax = axes[ax_idx]

    levels = list(range(ml + 1))
    gbs = global_torsion_birth_set(ml, orders)

    # Draw global birth set as background
    for lvl in levels:
        if lvl in gbs:
            ax.axvspan(lvl - 0.4, lvl + 0.4, alpha=0.1, color='gray')

    # Draw prime timelines
    for pi, p in enumerate(primes):
        pbs = p_torsion_birth_set(p, ml, orders)
        y_pos = len(primes) - pi - 1

        # Draw timeline
        ax.plot(levels, [y_pos] * len(levels), '-', color='lightgray',
                linewidth=1, zorder=1)

        # Mark birth events
        for lvl in pbs:
            ax.plot(lvl, y_pos, 'o', color=prime_colors[p], markersize=18,
                    zorder=3, markeredgecolor='black', markeredgewidth=1)
            ax.text(lvl, y_pos, f'{p}', ha='center', va='center',
                    fontsize=9, fontweight='bold', color='white', zorder=4)

        # Mark non-birth levels
        for lvl in levels:
            if lvl not in pbs:
                ax.plot(lvl, y_pos, 'o', color='white', markersize=12,
                        zorder=2, markeredgecolor='lightgray', markeredgewidth=1)

    # Show torsion orders at each level
    for lvl in levels:
        if lvl in orders:
            order_str = ', '.join(str(m) for m in orders[lvl])
            ax.text(lvl, len(primes) + 0.3, f'⟨{order_str}⟩',
                    ha='center', va='bottom', fontsize=9,
                    color='purple', fontweight='bold')

    ax.set_yticks(range(len(primes)))
    ax.set_yticklabels([prime_labels[p] for p in reversed(primes)], fontsize=10)
    ax.set_title(name, fontsize=11, fontweight='bold', pad=10)
    ax.set_ylim(-0.5, len(primes) + 0.8)
    ax.grid(axis='x', alpha=0.3)

axes[-1].set_xticks(range(profiles[0][1] + 1))
axes[-1].set_xticklabels([f'Level {i}' for i in range(profiles[0][1] + 1)], fontsize=10)
axes[-1].set_xlabel('Filtration Level', fontsize=12)

# Add annotation showing the key difference
fig.text(0.5, -0.02,
         "Both profiles have global birth set = {1, 3}, but their prime channel "
         "patterns differ:\n"
         "F has 2-torsion at level 1 (from order 2); G has 3-torsion at level 1 (from order 3).\n"
         "The primewise spectrum detects this difference; the global birth set cannot.",
         ha='center', va='top', fontsize=9, style='italic',
         bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

fig.suptitle("Prime Decomposition Timeline — Temporal Signatures by Prime Channel",
             fontsize=14, fontweight='bold', y=1.02)

plt.tight_layout()
plt.savefig("viz_decomposition.png", dpi=150, bbox_inches='tight')
print("Saved viz_decomposition.png")
