#!/usr/bin/env python3
"""
Visualization: Constructible Sheaf Profile for Tropical Persistence

Visualizes the main result — the tropical event profile as a step function
with jumps at critical values (entrance times). Shows:
- Top: Sheaf jump profile (bar chart at critical values)
- Bottom: Cumulative sheaf event profile = tropical event profile (step function)
- Vertical lines marking the singular support (critical values)

This visualizes the core theorem: tropEvtProfile_eq_cumSheafJump
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def path_graph_edges(n):
    return [(i, i+1) for i in range(n-1)]

def cycle_graph_edges(n):
    return [(i, (i+1) % n) for i in range(n)]

def degree(n, edges, v):
    return sum(1 for (a,b) in edges if a == v or b == v)

def sheaf_jump(n, edges, filt, c):
    entering = [v for v, fv in enumerate(filt) if fv == c]
    return sum(degree(n, edges, v) + 1 for v in entering)

def sheaf_event_profile(n, edges, filt, t):
    crit = sorted(set(filt))
    return sum(sheaf_jump(n, edges, filt, c) for c in crit if c <= t)


# Parameters
n = 8
fig, axes = plt.subplots(2, 2, figsize=(14, 10))

for col, (graph_name, edge_fn) in enumerate([("Path Graph P₈", path_graph_edges),
                                               ("Cycle Graph C₈", cycle_graph_edges)]):
    edges = edge_fn(n)
    filt = list(range(n))
    crit = sorted(set(filt))

    # Sheaf jumps
    jumps = [sheaf_jump(n, edges, filt, c) for c in crit]

    # Top: Bar chart of jumps
    ax_top = axes[0][col]
    colors = ['#e74c3c' if j >= 3 else '#3498db' for j in jumps]
    ax_top.bar(crit, jumps, width=0.6, color=colors, edgecolor='black', alpha=0.8)
    ax_top.set_ylabel('Sheaf Jump', fontsize=12)
    ax_top.set_title(f'{graph_name} — Sheaf Jumps at Critical Values', fontsize=13, fontweight='bold')
    ax_top.set_xlabel('Threshold t', fontsize=11)
    for i, (c, j) in enumerate(zip(crit, jumps)):
        ax_top.text(c, j + 0.1, str(j), ha='center', va='bottom', fontsize=10, fontweight='bold')

    # Vertical lines for singular support
    for c in crit:
        ax_top.axvline(x=c, color='gray', linestyle=':', alpha=0.3)

    # Bottom: Step function of cumulative profile
    ax_bot = axes[1][col]
    t_range = np.linspace(-0.5, n + 0.5, 500)
    profile = [sheaf_event_profile(n, edges, filt, t) for t in t_range]

    ax_bot.plot(t_range, profile, color='#2c3e50', linewidth=2.5)
    ax_bot.fill_between(t_range, profile, alpha=0.15, color='#3498db')

    # Mark critical values with dots
    crit_profile = [sheaf_event_profile(n, edges, filt, c) for c in crit]
    ax_bot.scatter(crit, crit_profile, color='#e74c3c', s=60, zorder=5, edgecolors='black')

    # Vertical lines
    for c in crit:
        ax_bot.axvline(x=c, color='gray', linestyle=':', alpha=0.3)

    ax_bot.set_ylabel('Cumulative Profile', fontsize=12)
    ax_bot.set_xlabel('Threshold t', fontsize=11)
    ax_bot.set_title(f'{graph_name} — Sheaf Event Profile (Step Function)', fontsize=13, fontweight='bold')

    # Annotate: "constructible = constant between jumps"
    if col == 0:
        ax_bot.annotate('Constructible:\nconstant between\ncritical values',
                       xy=(2.5, sheaf_event_profile(n, edges, filt, 2.5)),
                       xytext=(4, 5),
                       fontsize=9, fontweight='bold', color='#27ae60',
                       arrowprops=dict(arrowstyle='->', color='#27ae60'))

plt.suptitle('Constructible Sheaf Structure of Tropical Persistence',
            fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_sheaf_profile.png', dpi=150, bbox_inches='tight')
print("Saved viz_sheaf_profile.png")
