"""
Visualization: Critical Stratification and Singular Support
=============================================================

Visualizes the critical stratification of the threshold line,
showing how the sheaf is constructible: constant on open strata
with jumps only at critical values (the singular support).

Uses matplotlib to produce a static PNG.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from typing import List, Tuple, Dict


# ─── Self-contained infrastructure ──────────────────────────────────

def path_edges(n: int) -> List[Tuple[int, int]]:
    return [(i, i + 1) for i in range(n)]

def cycle_edges(n: int) -> List[Tuple[int, int]]:
    return [(i, (i + 1) % n) for i in range(n)]

def degree(edges: List[Tuple[int, int]], v: int) -> int:
    return sum(1 for (a, b) in edges if a == v or b == v)

def sheaf_jump(edges: List[Tuple[int, int]], filt: Dict[int, float], c: float) -> int:
    return sum(degree(edges, v) + 1 for v, ft in filt.items() if ft == c)

def active_verts(filt: Dict[int, float], t: float) -> set:
    return {v for v, ft in filt.items() if ft <= t}

def euler_char(edges: List[Tuple[int, int]], filt: Dict[int, float], t: float) -> int:
    active = active_verts(filt, t)
    ae = sum(1 for u, v in edges if u in active and v in active)
    return len(active) - ae


# ─── Setup ───────────────────────────────────────────────────────────

n = 6
edges = path_edges(n)
filt = {i: float(i) for i in range(n + 1)}
crits = sorted(set(filt.values()))

fig, axes = plt.subplots(3, 1, figsize=(12, 10))

# ─── Panel 1: Critical Stratification ───────────────────────────────

ax1 = axes[0]

# Draw the threshold line
ax1.axhline(y=0, color='black', linewidth=1)

# Draw open strata (green bars)
for i in range(len(crits) - 1):
    ax1.fill_between([crits[i], crits[i+1]], -0.15, 0.15,
                     color='#4CAF50', alpha=0.3)
    ax1.plot([(crits[i] + crits[i+1])/2], [0], 's',
            color='#4CAF50', markersize=10, zorder=5)

# Draw critical strata (red dots)
for c in crits:
    j = sheaf_jump(edges, filt, c)
    ax1.plot(c, 0, 'o', color='#F44336', markersize=12, zorder=6)
    ax1.annotate(f'c={int(c)}\njump={j}',
                (c, 0), textcoords="offset points",
                xytext=(0, 20), fontsize=9, ha='center',
                color='#F44336', fontweight='bold')

# Arrow indicating singular support
ax1.annotate('', xy=(-0.5, -0.3), xytext=(n + 0.5, -0.3),
            arrowprops=dict(arrowstyle='<->', color='purple', lw=1.5))
ax1.text(n/2, -0.45, 'Singular Support = Critical Values',
        ha='center', fontsize=10, color='purple', style='italic')

ax1.set_xlim(-1, n + 1)
ax1.set_ylim(-0.6, 0.6)
ax1.set_xlabel('Threshold t', fontsize=11)
ax1.set_title('Critical Stratification of the Threshold Line',
             fontsize=13, fontweight='bold')
ax1.set_yticks([])

legend_elements = [
    mpatches.Patch(color='#F44336', alpha=0.8, label='Critical strata (jumps)'),
    mpatches.Patch(color='#4CAF50', alpha=0.3, label='Open strata (sheaf constant)')
]
ax1.legend(handles=legend_elements, fontsize=10, loc='upper left')

# ─── Panel 2: Stalk Data at Each Stratum ────────────────────────────

ax2 = axes[1]

t_range = []
stalk_data = []
for i, c in enumerate(crits):
    if i > 0:
        t_mid = (crits[i-1] + c) / 2
        t_range.append(t_mid)
        stalk_data.append(len(active_verts(filt, t_mid)))
    t_range.append(c)
    stalk_data.append(len(active_verts(filt, c)))

# Add endpoints
t_range_ext = [-0.5] + t_range + [n + 0.5]
stalk_ext = [0] + stalk_data + [stalk_data[-1]]

ax2.step(t_range_ext, stalk_ext, where='post', color='#2196F3', linewidth=2.5)

for c in crits:
    sr = len(active_verts(filt, c))
    ax2.plot(c, sr, 'o', color='#F44336', markersize=8, zorder=5)

ax2.set_xlabel('Threshold t', fontsize=11)
ax2.set_ylabel('Stalk Rank', fontsize=11)
ax2.set_title('Stalk Rank = |Active Vertices| (Constructible Step Function)',
             fontsize=13, fontweight='bold')
ax2.grid(True, alpha=0.3)
ax2.set_xlim(-1, n + 1)

# ─── Panel 3: Euler Characteristic ──────────────────────────────────

ax3 = axes[2]

t_fine = [i * 0.05 for i in range(-20, (n + 1) * 20 + 10)]
euler_vals = [euler_char(edges, filt, t) for t in t_fine]

ax3.step(t_fine, euler_vals, where='post', color='#FF9800', linewidth=2.5)

for c in crits:
    ec = euler_char(edges, filt, c)
    ax3.plot(c, ec, 'o', color='#F44336', markersize=8, zorder=5)

ax3.set_xlabel('Threshold t', fontsize=11)
ax3.set_ylabel('Euler Characteristic', fontsize=11)
ax3.set_title('Euler Characteristic χ(t) = |V_active| - |E_active| (Also Constructible)',
             fontsize=13, fontweight='bold')
ax3.grid(True, alpha=0.3)
ax3.set_xlim(-1, n + 1)
ax3.axhline(y=1, color='gray', linestyle=':', alpha=0.5)

plt.tight_layout()
plt.savefig('stratification_visualization.png', dpi=150, bbox_inches='tight')
print("Saved: stratification_visualization.png")
