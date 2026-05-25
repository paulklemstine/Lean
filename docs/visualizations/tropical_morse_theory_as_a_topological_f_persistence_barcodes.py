#!/usr/bin/env python3
"""
Visualization 3: Persistence Barcodes from Tropical Morse Spectrum

Compares the persistence barcodes of C₆ vs 2×C₃, showing how different
Morse event sequences produce different H₀ and H₁ barcodes despite
the graphs being 1-WL equivalent.

This visualizes the cross-domain connection between tropical geometry
(weight filtration) and algebraic topology (persistent homology).
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


# ──── Self-contained implementations ────

class UnionFind:
    def __init__(self, n):
        self.parent = list(range(n))
        self.rank = [0] * n
        self.num_components = n
        self.birth = list(range(n))  # track representative birth

    def find(self, x):
        while self.parent[x] != x:
            self.parent[x] = self.parent[self.parent[x]]
            x = self.parent[x]
        return x

    def union(self, x, y):
        rx, ry = self.find(x), self.find(y)
        if rx == ry:
            return False, -1
        # Younger component dies
        if self.rank[rx] < self.rank[ry]:
            rx, ry = ry, rx
        self.parent[ry] = rx
        if self.rank[rx] == self.rank[ry]:
            self.rank[rx] += 1
        self.num_components -= 1
        return True, ry  # ry dies


def compute_barcode(n, edges):
    """Compute H₀ and H₁ barcodes."""
    h0_bars = []  # (birth, death) pairs
    h1_bars = []

    uf = UnionFind(n)
    sorted_edges = sorted(edges, key=lambda e: e[2])

    # Each vertex born at t=-∞ (we use 0 for display)
    for u, v, w in sorted_edges:
        merged, dying = uf.union(u, v)
        if merged:
            h0_bars.append((0, w))  # Component born at 0, dies at w
        else:
            h1_bars.append((w, None))  # Cycle born at w, lives forever

    return h0_bars, h1_bars


# ──── Graph definitions ────

c6_edges = [(i, (i+1)%6, float(i+1)) for i in range(6)]
tri_edges = [
    (0, 1, 1.0), (1, 2, 3.0), (0, 2, 5.0),
    (3, 4, 2.0), (4, 5, 4.0), (3, 5, 6.0)
]


# ──── Compute barcodes ────

h0_c6, h1_c6 = compute_barcode(6, c6_edges)
h0_2t, h1_2t = compute_barcode(6, tri_edges)


# ──── Plotting ────

fig, axes = plt.subplots(2, 2, figsize=(14, 8))
fig.suptitle("Persistence Barcodes: Tropical Morse Spectrum → Topological Invariants\n"
             "C₆ and 2×C₃ are 1-WL equivalent but have different barcodes",
             fontsize=13, fontweight='bold')

max_t = 8

def plot_barcode(ax, h0_bars, h1_bars, title, max_t=8):
    """Plot H₀ and H₁ bars."""
    y_pos = 0
    colors_h0 = plt.cm.Blues(np.linspace(0.4, 0.8, max(len(h0_bars), 1)))
    colors_h1 = plt.cm.Reds(np.linspace(0.4, 0.8, max(len(h1_bars), 1)))

    # H₀ bars
    for i, (b, d) in enumerate(h0_bars):
        ax.barh(y_pos, d - b, left=b, height=0.6,
                color=colors_h0[i % len(colors_h0)], edgecolor='navy',
                linewidth=0.5, label='H₀' if i == 0 else '')
        ax.text(d + 0.1, y_pos, f'†{d:.0f}', va='center', fontsize=8, color='navy')
        y_pos += 1

    # Separator
    y_pos += 0.5
    ax.axhline(y=y_pos - 0.25, color='gray', linestyle=':', alpha=0.5)

    # H₁ bars
    for i, (b, d) in enumerate(h1_bars):
        end = d if d is not None else max_t
        ax.barh(y_pos, end - b, left=b, height=0.6,
                color=colors_h1[i % len(colors_h1)], edgecolor='darkred',
                linewidth=0.5, label='H₁' if i == 0 else '')
        if d is None:
            ax.annotate('', xy=(max_t, y_pos), xytext=(max_t - 0.3, y_pos),
                       arrowprops=dict(arrowstyle='->', color='darkred', lw=1.5))
        ax.text(b - 0.3, y_pos, f'b={b:.0f}', va='center', fontsize=8, color='darkred')
        y_pos += 1

    ax.set_xlim(-0.5, max_t + 0.5)
    ax.set_xlabel('Weight threshold t', fontsize=11)
    ax.set_title(title, fontsize=11)
    ax.set_yticks([])
    ax.legend(fontsize=9, loc='upper right')
    ax.grid(True, axis='x', alpha=0.3)


# Plot barcodes
plot_barcode(axes[0, 0], h0_c6, h1_c6, "C₆: 5 merges (H₀ deaths) + 1 cycle (H₁ birth)")
plot_barcode(axes[0, 1], h0_2t, h1_2t, "2×C₃: 4 merges + 2 cycles")

# Panel 3: Comparison of Betti number evolution
ax3 = axes[1, 0]
thresholds = np.linspace(0, 7, 100)

def betti_at_threshold(n, edges, t):
    uf = UnionFind(n)
    cycles = 0
    for u, v, w in sorted(edges, key=lambda e: e[2]):
        if w <= t:
            merged, _ = uf.union(u, v)
            if not merged:
                cycles += 1
    return uf.num_components, cycles

beta0_c6 = [betti_at_threshold(6, c6_edges, t)[0] for t in thresholds]
beta1_c6 = [betti_at_threshold(6, c6_edges, t)[1] for t in thresholds]
beta0_2t = [betti_at_threshold(6, tri_edges, t)[0] for t in thresholds]
beta1_2t = [betti_at_threshold(6, tri_edges, t)[1] for t in thresholds]

ax3.step(thresholds, beta0_c6, 'b-', linewidth=2, label='C₆ β₀', where='post')
ax3.step(thresholds, beta0_2t, 'b--', linewidth=2, label='2×C₃ β₀', where='post')
ax3.step(thresholds, beta1_c6, 'r-', linewidth=2, label='C₆ β₁', where='post')
ax3.step(thresholds, beta1_2t, 'r--', linewidth=2, label='2×C₃ β₁', where='post')

ax3.set_xlabel('Weight threshold t', fontsize=11)
ax3.set_ylabel('Betti number', fontsize=11)
ax3.set_title('Betti Number Evolution\nβ₀ (components) and β₁ (cycles)', fontsize=11)
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3)

# Panel 4: Euler characteristic
ax4 = axes[1, 1]
chi_c6 = [b0 - b1 for b0, b1 in zip(beta0_c6, beta1_c6)]
chi_2t = [b0 - b1 for b0, b1 in zip(beta0_2t, beta1_2t)]

ax4.step(thresholds, chi_c6, 'g-', linewidth=2, label='C₆: χ = β₀ - β₁', where='post')
ax4.step(thresholds, chi_2t, 'g--', linewidth=2, label='2×C₃: χ = β₀ - β₁', where='post')

ax4.set_xlabel('Weight threshold t', fontsize=11)
ax4.set_ylabel('Euler characteristic χ', fontsize=11)
ax4.set_title('Euler Characteristic = V - E(t)\nCross-domain: Topology ↔ Tropical Geometry', fontsize=11)
ax4.legend(fontsize=9)
ax4.grid(True, alpha=0.3)

plt.tight_layout(rect=[0, 0, 1, 0.93])
plt.savefig('vis_barcode.png', dpi=150, bbox_inches='tight')
print("Saved vis_barcode.png")
