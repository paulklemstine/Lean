"""
Visualization: TMS Distinguishes WL1-Equivalent Graphs

Shows how the Tropical Morse Spectrum can distinguish graphs that
the Weisfeiler-Leman algorithm cannot. Compares C₆ (6-cycle) with
2×C₃ (two disjoint triangles) — both are 2-regular but have
different TMS fingerprints.

Uses matplotlib to produce a static plot saved as PNG.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


# ── Self-contained TMS implementation ─────────────────────────────────

class UnionFind:
    def __init__(self, n):
        self.parent = list(range(n))
        self.rank = [0] * n
        self.n = n
    def find(self, x):
        if self.parent[x] != x:
            self.parent[x] = self.find(self.parent[x])
        return self.parent[x]
    def same(self, u, v): return self.find(u) == self.find(v)
    def union(self, u, v):
        ru, rv = self.find(u), self.find(v)
        if ru == rv: return False
        if self.rank[ru] < self.rank[rv]: ru, rv = rv, ru
        self.parent[rv] = ru
        if self.rank[ru] == self.rank[rv]: self.rank[ru] += 1
        return True


def compute_tms(n, edges):
    uf = UnionFind(n)
    events = []
    for w, u, v in sorted(edges):
        if uf.same(u, v):
            events.append((w, (u, v), 'cycle'))
        else:
            uf.union(u, v)
            events.append((w, (u, v), 'merge'))
    return events


# ── Define the two graphs ─────────────────────────────────────────────

# C₆: 6-cycle with weights 1..6
c6_edges = [(i + 1, i, (i + 1) % 6) for i in range(6)]
c6_events = compute_tms(6, c6_edges)

# 2×C₃: two triangles with weights 1..6
t2_edges = [(1, 0, 1), (2, 1, 2), (3, 0, 2), (4, 3, 4), (5, 4, 5), (6, 3, 5)]
t2_events = compute_tms(6, t2_edges)

# ── Create visualization ─────────────────────────────────────────────

fig, axes = plt.subplots(2, 3, figsize=(16, 10))

# ── Row 1: C₆ ────────────────────────────────────────────────────────

# Graph drawing
ax = axes[0, 0]
theta = np.linspace(0, 2 * np.pi, 7)[:-1]
x = np.cos(theta)
y = np.sin(theta)

for i in range(6):
    j = (i + 1) % 6
    ax.plot([x[i], x[j]], [y[i], y[j]], 'b-', linewidth=2, alpha=0.7)
    mx, my = (x[i] + x[j]) / 2, (y[i] + y[j]) / 2
    ax.text(mx * 1.3, my * 1.3, str(i + 1), fontsize=9, ha='center',
            color='blue', fontweight='bold')

for i in range(6):
    ax.plot(x[i], y[i], 'ko', markersize=10, zorder=5)
    ax.text(x[i] * 0.7, y[i] * 0.7, str(i), fontsize=8, ha='center',
            va='center', color='white', fontweight='bold',
            bbox=dict(boxstyle='circle', facecolor='black', edgecolor='black'))

ax.set_xlim(-1.8, 1.8)
ax.set_ylim(-1.8, 1.8)
ax.set_aspect('equal')
ax.set_title('C₆ (6-cycle)', fontsize=14, fontweight='bold')
ax.axis('off')

# Event timeline
ax = axes[0, 1]
for i, (w, (u, v), etype) in enumerate(c6_events):
    color = '#2196F3' if etype == 'merge' else '#F44336'
    ax.barh(i, 1, color=color, alpha=0.8, height=0.8)
    ax.text(0.5, i, f't={w:.0f}: ({u},{v}) {etype}', ha='center', va='center',
            fontsize=9, fontweight='bold', color='white')

ax.set_yticks(range(len(c6_events)))
ax.set_yticklabels([f'Step {i+1}' for i in range(len(c6_events))])
ax.set_xlim(0, 1)
ax.set_xticks([])
ax.set_title('TMS Events (C₆)', fontsize=14, fontweight='bold')
ax.invert_yaxis()

# Betti evolution
ax = axes[0, 2]
beta0, beta1 = [6], [0]
for w, (u, v), etype in c6_events:
    if etype == 'merge':
        beta0.append(beta0[-1] - 1)
        beta1.append(beta1[-1])
    else:
        beta0.append(beta0[-1])
        beta1.append(beta1[-1] + 1)

steps = range(len(beta0))
ax.step(steps, beta0, where='post', color='#2196F3', linewidth=2.5, label='β₀')
ax.step(steps, beta1, where='post', color='#F44336', linewidth=2.5, label='β₁')
ax.set_xlabel('Step', fontsize=11)
ax.set_ylabel('Betti Number', fontsize=11)
ax.set_title('Betti Evolution (C₆)', fontsize=14, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.text(0.95, 0.95, f'Final: β₀=1, β₁=1',
        transform=ax.transAxes, fontsize=10, va='top', ha='right',
        bbox=dict(facecolor='wheat', alpha=0.5))

# ── Row 2: 2×C₃ ──────────────────────────────────────────────────────

# Graph drawing
ax = axes[1, 0]
# Triangle 1
t1x = [-0.8, 0, 0.8]
t1y = [-0.5, 0.87, -0.5]
# Triangle 2
t2x = [x + 0.0 for x in [-0.8, 0, 0.8]]
t2y = [y - 2.0 for y in [-0.5, 0.87, -0.5]]

positions = list(zip(t1x + t2x, t1y + t2y))
tri_edges_draw = [(0, 1, 1), (1, 2, 2), (0, 2, 3), (3, 4, 4), (4, 5, 5), (3, 5, 6)]

for u, v, w in tri_edges_draw:
    px, py = positions[u]
    qx, qy = positions[v]
    ax.plot([px, qx], [py, qy], 'b-', linewidth=2, alpha=0.7)
    mx, my = (px + qx) / 2, (py + qy) / 2
    ax.text(mx + 0.15, my, str(w), fontsize=9, ha='center', color='blue',
            fontweight='bold')

for i, (px, py) in enumerate(positions):
    ax.plot(px, py, 'ko', markersize=10, zorder=5)
    ax.text(px, py, str(i), fontsize=8, ha='center', va='center',
            color='white', fontweight='bold')

ax.set_xlim(-1.5, 1.5)
ax.set_ylim(-3.5, 1.5)
ax.set_aspect('equal')
ax.set_title('2×C₃ (Two Triangles)', fontsize=14, fontweight='bold')
ax.axis('off')

# Event timeline
ax = axes[1, 1]
for i, (w, (u, v), etype) in enumerate(t2_events):
    color = '#2196F3' if etype == 'merge' else '#F44336'
    ax.barh(i, 1, color=color, alpha=0.8, height=0.8)
    ax.text(0.5, i, f't={w:.0f}: ({u},{v}) {etype}', ha='center', va='center',
            fontsize=9, fontweight='bold', color='white')

ax.set_yticks(range(len(t2_events)))
ax.set_yticklabels([f'Step {i+1}' for i in range(len(t2_events))])
ax.set_xlim(0, 1)
ax.set_xticks([])
ax.set_title('TMS Events (2×C₃)', fontsize=14, fontweight='bold')
ax.invert_yaxis()

# Betti evolution
ax = axes[1, 2]
beta0, beta1 = [6], [0]
for w, (u, v), etype in t2_events:
    if etype == 'merge':
        beta0.append(beta0[-1] - 1)
        beta1.append(beta1[-1])
    else:
        beta0.append(beta0[-1])
        beta1.append(beta1[-1] + 1)

steps = range(len(beta0))
ax.step(steps, beta0, where='post', color='#2196F3', linewidth=2.5, label='β₀')
ax.step(steps, beta1, where='post', color='#F44336', linewidth=2.5, label='β₁')
ax.set_xlabel('Step', fontsize=11)
ax.set_ylabel('Betti Number', fontsize=11)
ax.set_title('Betti Evolution (2×C₃)', fontsize=14, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.text(0.95, 0.95, f'Final: β₀=2, β₁=2',
        transform=ax.transAxes, fontsize=10, va='top', ha='right',
        bbox=dict(facecolor='wheat', alpha=0.5))

# ── Annotations ───────────────────────────────────────────────────────

fig.suptitle('TMS Distinguishes WL1-Equivalent Graphs\n'
             'Both are 2-regular (same degree sequence) but have different TMS fingerprints',
             fontsize=16, fontweight='bold', y=1.02)

plt.tight_layout()
plt.savefig('viz_tms_comparison.png', dpi=150, bbox_inches='tight')
print("Saved: viz_tms_comparison.png")
