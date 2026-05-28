"""
Visualization: Constructible Sheaf on the Threshold Line
=========================================================

Visualizes the core mathematical concept: the tropical event profile
as a constructible sheaf, with jumps at critical values and constant
stalks between them. Shows path graph and cycle graph side by side.

Uses matplotlib to produce a static PNG.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from collections import defaultdict
from typing import List, Tuple, Dict, Set


# ─── Self-contained graph/filtration infrastructure ──────────────────

def path_edges(n: int) -> List[Tuple[int, int]]:
    return [(i, i + 1) for i in range(n)]

def cycle_edges(n: int) -> List[Tuple[int, int]]:
    return [(i, (i + 1) % n) for i in range(n)]

def degree(edges: List[Tuple[int, int]], v: int) -> int:
    return sum(1 for (a, b) in edges if a == v or b == v)

def sheaf_jump(edges: List[Tuple[int, int]], filt: Dict[int, float], c: float) -> int:
    return sum(degree(edges, v) + 1 for v, ft in filt.items() if ft == c)

def cum_profile(edges: List[Tuple[int, int]], filt: Dict[int, float], t: float) -> int:
    crits = sorted(set(filt.values()))
    return sum(sheaf_jump(edges, filt, c) for c in crits if c <= t)


# ─── Main visualization ─────────────────────────────────────────────

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# --- Path Graph P_6 ---
n_path = 5
edges_p = path_edges(n_path)
filt_p = {i: float(i) for i in range(n_path + 1)}
crits_p = sorted(set(filt_p.values()))

# Panel 1: Sheaf profile (step function)
ax1 = axes[0, 0]
t_range = [c - 0.5 for c in crits_p] + crits_p + [c + 0.5 for c in crits_p]
t_range = sorted(set(t_range + [-1.0, n_path + 1.0]))
t_range = [t for t in t_range if -1.5 <= t <= n_path + 1.5]
profiles_p = [cum_profile(edges_p, filt_p, t) for t in t_range]

ax1.step(t_range, profiles_p, where='post', color='#2196F3', linewidth=2, label='Sheaf Event Profile')
for c in crits_p:
    j = sheaf_jump(edges_p, filt_p, c)
    y = cum_profile(edges_p, filt_p, c)
    ax1.plot(c, y, 'o', color='#F44336', markersize=8, zorder=5)
    ax1.annotate(f'+{j}', (c, y), textcoords="offset points",
                xytext=(5, 10), fontsize=9, color='#F44336', fontweight='bold')

ax1.set_xlabel('Threshold t', fontsize=11)
ax1.set_ylabel('Profile Value', fontsize=11)
ax1.set_title('Path Graph P₆: Constructible Sheaf Profile', fontsize=12, fontweight='bold')
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)
ax1.set_xlim(-1.5, n_path + 1.5)

# Panel 2: Sheaf jumps (bar chart)
ax2 = axes[0, 1]
jumps_p = [sheaf_jump(edges_p, filt_p, c) for c in crits_p]
colors_p = ['#4CAF50' if j <= 2 else '#FF9800' for j in jumps_p]
ax2.bar(crits_p, jumps_p, width=0.6, color=colors_p, edgecolor='black', linewidth=0.5)
ax2.axhline(y=3, color='red', linestyle='--', alpha=0.5, label='Bound (≤3)')
for i, (c, j) in enumerate(zip(crits_p, jumps_p)):
    ax2.text(c, j + 0.1, str(j), ha='center', fontsize=10, fontweight='bold')
ax2.set_xlabel('Critical Value', fontsize=11)
ax2.set_ylabel('Sheaf Jump', fontsize=11)
ax2.set_title('Path Graph P₆: Sheaf Jumps (Singular Support)', fontsize=12, fontweight='bold')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3, axis='y')

# --- Cycle Graph C_6 ---
n_cycle = 6
edges_c = cycle_edges(n_cycle)
filt_c = {i: float(i) for i in range(n_cycle)}
crits_c = sorted(set(filt_c.values()))

# Panel 3: Sheaf profile (step function)
ax3 = axes[1, 0]
t_range_c = sorted(set(
    [c - 0.5 for c in crits_c] + crits_c + [c + 0.5 for c in crits_c] + [-1.0, n_cycle + 0.5]
))
t_range_c = [t for t in t_range_c if -1.5 <= t <= n_cycle + 0.5]
profiles_c = [cum_profile(edges_c, filt_c, t) for t in t_range_c]

ax3.step(t_range_c, profiles_c, where='post', color='#9C27B0', linewidth=2, label='Sheaf Event Profile')
for c in crits_c:
    j = sheaf_jump(edges_c, filt_c, c)
    y = cum_profile(edges_c, filt_c, c)
    ax3.plot(c, y, 'o', color='#F44336', markersize=8, zorder=5)
    ax3.annotate(f'+{j}', (c, y), textcoords="offset points",
                xytext=(5, 10), fontsize=9, color='#F44336', fontweight='bold')

ax3.set_xlabel('Threshold t', fontsize=11)
ax3.set_ylabel('Profile Value', fontsize=11)
ax3.set_title('Cycle Graph C₆: Constructible Sheaf Profile', fontsize=12, fontweight='bold')
ax3.legend(fontsize=10)
ax3.grid(True, alpha=0.3)

# Panel 4: Stalk rank evolution
ax4 = axes[1, 1]
stalk_ranks_p = [len({v for v, ft in filt_p.items() if ft <= t}) for t in t_range]
stalk_ranks_c = [len({v for v, ft in filt_c.items() if ft <= t}) for t in t_range_c]

ax4.step(t_range, stalk_ranks_p, where='post', color='#2196F3', linewidth=2, label='Path P₆')
ax4.step(t_range_c, stalk_ranks_c, where='post', color='#9C27B0', linewidth=2, label='Cycle C₆')
ax4.set_xlabel('Threshold t', fontsize=11)
ax4.set_ylabel('Stalk Rank (|Active Vertices|)', fontsize=11)
ax4.set_title('Stalk Rank: Constructible Step Functions', fontsize=12, fontweight='bold')
ax4.legend(fontsize=10)
ax4.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('sheaf_visualization.png', dpi=150, bbox_inches='tight')
print("Saved: sheaf_visualization.png")
