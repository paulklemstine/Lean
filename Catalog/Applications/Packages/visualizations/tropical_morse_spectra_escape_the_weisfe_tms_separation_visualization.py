#!/usr/bin/env python3
"""
Visualization: Tropical Morse Spectrum Separation

This script visualizes the key result: C_{2n} and 2×C_n have
different TMS despite being WL1-equivalent (both 2-regular).

The plot shows the filtration timeline for both graphs, highlighting
the divergence point where the cycle-death events differ.

SELF-CONTAINED: does not import any local modules.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


class UnionFind:
    def __init__(self, n):
        self.parent = list(range(n))
        self.rank = [0] * n
    def find(self, x):
        while self.parent[x] != x:
            self.parent[x] = self.parent[self.parent[x]]
            x = self.parent[x]
        return x
    def union(self, x, y):
        rx, ry = self.find(x), self.find(y)
        if rx == ry: return False
        if self.rank[rx] < self.rank[ry]: rx, ry = ry, rx
        self.parent[ry] = rx
        if self.rank[rx] == self.rank[ry]: self.rank[rx] += 1
        return True


def compute_filtration(nv, edges):
    """Compute filtration events."""
    sorted_edges = sorted(edges, key=lambda e: e[2])
    uf = UnionFind(nv)
    events = []
    components = nv
    betti1 = 0
    for u, v, w in sorted_edges:
        if uf.union(u, v):
            components -= 1
            events.append((w, 'merge', components, betti1))
        else:
            betti1 += 1
            events.append((w, 'cycle', components, betti1))
    return events


def make_cycle(m, wfn):
    return m, [(i, (i+1)%m, wfn(i)) for i in range(m)]

def make_two_cycles(n, wfn):
    edges = [(i, (i+1)%n, wfn(i)) for i in range(n)]
    edges += [(n+i, n+(i+1)%n, wfn(i)) for i in range(n)]
    return 2*n, edges


# Parameters
n = 5
wfn = lambda i: float(i + 1)

nv1, e1 = make_cycle(2*n, wfn)
nv2, e2 = make_two_cycles(n, wfn)

filt1 = compute_filtration(nv1, e1)
filt2 = compute_filtration(nv2, e2)

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Top left: Components over filtration
ax = axes[0, 0]
ws1 = [0] + [e[0] for e in filt1]
cs1 = [nv1] + [e[2] for e in filt1]
ws2 = [0] + [e[0] for e in filt2]
cs2 = [nv2] + [e[2] for e in filt2]
ax.step(ws1, cs1, where='post', label=f'C$_{{{2*n}}}$ (single cycle)', color='#2196F3', linewidth=2)
ax.step(ws2, cs2, where='post', label=f'2×C$_{{{n}}}$ (two cycles)', color='#F44336', linewidth=2)
ax.set_xlabel('Filtration weight', fontsize=12)
ax.set_ylabel('Connected components', fontsize=12)
ax.set_title('Component Count During Filtration', fontsize=13, fontweight='bold')
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

# Top right: β₁ over filtration
ax = axes[0, 1]
bs1 = [0] + [e[3] for e in filt1]
bs2 = [0] + [e[3] for e in filt2]
ax.step(ws1, bs1, where='post', label=f'C$_{{{2*n}}}$: β₁ = 1', color='#2196F3', linewidth=2)
ax.step(ws2, bs2, where='post', label=f'2×C$_{{{n}}}$: β₁ = 2', color='#F44336', linewidth=2)

# Highlight the divergence
for e in filt1:
    if e[1] == 'cycle':
        ax.axvline(x=e[0], color='#2196F3', linestyle='--', alpha=0.5)
        ax.annotate('cycle death', (e[0], e[3]), xytext=(e[0]+0.3, e[3]-0.2),
                   fontsize=9, color='#2196F3')
for e in filt2:
    if e[1] == 'cycle':
        ax.axvline(x=e[0], color='#F44336', linestyle='--', alpha=0.5)

ax.set_xlabel('Filtration weight', fontsize=12)
ax.set_ylabel('First Betti number β₁', fontsize=12)
ax.set_title('β₁ Evolution — The Separation Point', fontsize=13, fontweight='bold')
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

# Bottom left: Event timeline
ax = axes[1, 0]
y_offset = 0.3
for i, (w, typ, c, b) in enumerate(filt1):
    color = '#4CAF50' if typ == 'merge' else '#FF9800'
    marker = 'v' if typ == 'merge' else '^'
    ax.scatter(w, 1 + y_offset, c=color, marker=marker, s=100, zorder=5,
              edgecolors='black', linewidth=0.5)

for i, (w, typ, c, b) in enumerate(filt2):
    color = '#4CAF50' if typ == 'merge' else '#FF9800'
    marker = 'v' if typ == 'merge' else '^'
    ax.scatter(w, 0 - y_offset, c=color, marker=marker, s=100, zorder=5,
              edgecolors='black', linewidth=0.5)

ax.axhline(y=1+y_offset, color='#2196F3', alpha=0.3)
ax.axhline(y=0-y_offset, color='#F44336', alpha=0.3)
ax.set_yticks([1+y_offset, 0-y_offset])
ax.set_yticklabels([f'C$_{{{2*n}}}$', f'2×C$_{{{n}}}$'], fontsize=11)
ax.set_xlabel('Edge weight', fontsize=12)
ax.set_title('Event Timeline (▼=merge, ▲=cycle-death)', fontsize=13, fontweight='bold')
ax.grid(True, alpha=0.3, axis='x')

# Legend for event types
from matplotlib.lines import Line2D
legend_elements = [
    Line2D([0], [0], marker='v', color='w', markerfacecolor='#4CAF50',
           markersize=10, label='Merge event'),
    Line2D([0], [0], marker='^', color='w', markerfacecolor='#FF9800',
           markersize=10, label='Cycle-death event'),
]
ax.legend(handles=legend_elements, fontsize=10)

# Bottom right: Separation summary
ax = axes[1, 1]
ax.axis('off')

summary = (
    "TMS Separation Summary\n"
    "━━━━━━━━━━━━━━━━━━━━━━\n\n"
    f"Graph A: C$_{{{2*n}}}$ (single cycle)\n"
    f"  • {2*n} vertices, {2*n} edges\n"
    f"  • β₁ = 1 (one loop)\n"
    f"  • {2*n-1} merge events\n"
    f"  • 1 cycle-death event\n\n"
    f"Graph B: 2×C$_{{{n}}}$ (two cycles)\n"
    f"  • {2*n} vertices, {2*n} edges\n"
    f"  • β₁ = 2 (two loops)\n"
    f"  • {2*(n-1)} merge events\n"
    f"  • 2 cycle-death events\n\n"
    "Both are 2-regular → WL1 equivalent\n"
    "Cycle-death count differs → TMS separated\n\n"
    "Gap: Δ(merges) = 1, Δ(cycles) = 1"
)
ax.text(0.1, 0.95, summary, transform=ax.transAxes, fontsize=11,
        verticalalignment='top', fontfamily='monospace',
        bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

plt.suptitle('Tropical Morse Spectrum Escapes the WL Hierarchy',
             fontsize=15, fontweight='bold', y=0.98)
plt.tight_layout(rect=[0, 0, 1, 0.96])
plt.savefig('tms_separation.png', dpi=150, bbox_inches='tight')
print("Saved tms_separation.png")
