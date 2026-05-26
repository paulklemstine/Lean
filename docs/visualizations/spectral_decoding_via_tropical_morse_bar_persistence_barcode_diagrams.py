#!/usr/bin/env python3
"""
Visualization: Tropical Morse Barcode Persistence Diagram

Shows the persistence barcode from a tropical Morse filtration on a surface code
graph. Each horizontal bar represents a topological feature (connected component
or cycle) that is born at one weight threshold and dies at another. Longer bars
indicate more persistent features — these drive higher edge vulnerability and
define logical corridors.

This visualization makes the key mathematical object tangible: the barcode is the
topological memory of the weight filtration, and its geometry guides decoding.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def compute_barcode(L, seed=42):
    """Compute tropical Morse barcode for L×L grid with random weights."""
    np.random.seed(seed)
    nodes = list(range(L * L))
    edges = []
    weights = {}

    for r in range(L):
        for c in range(L):
            idx = r * L + c
            if c + 1 < L:
                e = (idx, idx + 1)
                edges.append(e)
                weights[e] = np.random.exponential(1.0)
            if r + 1 < L:
                e = (idx, idx + L)
                edges.append(e)
                weights[e] = np.random.exponential(1.0)

    sorted_edges = sorted(edges, key=lambda e: weights[e])
    parent = {n: n for n in nodes}
    rank_uf = {n: 0 for n in nodes}
    component_birth = {n: 0.0 for n in nodes}

    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x, y):
        rx, ry = find(x), find(y)
        if rx == ry:
            return False, rx
        if rank_uf[rx] < rank_uf[ry]:
            rx, ry = ry, rx
        parent[ry] = rx
        if rank_uf[rx] == rank_uf[ry]:
            rank_uf[rx] += 1
        return True, rx

    h0_bars = []  # Connected component bars (birth, death)
    h1_bars = []  # Cycle bars (birth, death)
    events = []

    for e in sorted_edges:
        u, v = e
        w = weights[e]
        ru, rv = find(u), find(v)

        if ru != rv:
            # Merge: younger component dies
            birth_u = component_birth.get(ru, 0.0)
            birth_v = component_birth.get(rv, 0.0)
            dying_birth = max(birth_u, birth_v)
            h0_bars.append((dying_birth, w))
            merged, new_root = union(u, v)
            component_birth[new_root] = min(birth_u, birth_v)
            events.append(('merge', w, e))
        else:
            # Cycle birth
            h1_bars.append((0.0, w))
            events.append(('cycle', w, e))

    return h0_bars, h1_bars, events, edges, weights


fig, axes = plt.subplots(2, 3, figsize=(15, 9))

for col, L in enumerate([3, 5, 7]):
    h0_bars, h1_bars, events, edges, weights = compute_barcode(L)

    # Top row: Barcode diagram
    ax = axes[0, col]
    y = 0
    # H0 bars
    for birth, death in sorted(h0_bars, key=lambda x: x[0]):
        ax.barh(y, death - birth, left=birth, height=0.7,
                color='steelblue', alpha=0.7, edgecolor='navy', linewidth=0.5)
        y += 1

    h0_count = y
    # H1 bars
    for birth, death in sorted(h1_bars, key=lambda x: -x[1]):
        ax.barh(y, death - birth, left=birth, height=0.7,
                color='crimson', alpha=0.7, edgecolor='darkred', linewidth=0.5)
        y += 1

    ax.axhline(h0_count - 0.5, color='gray', linestyle='--', linewidth=0.5)
    ax.set_xlabel('Weight Threshold', fontsize=10)
    ax.set_ylabel('Feature Index', fontsize=10)
    ax.set_title(f'{L}×{L} Grid — Persistence Barcode', fontsize=11, fontweight='bold')

    # Add labels
    if col == 0:
        mid_h0 = h0_count / 2
        mid_h1 = h0_count + len(h1_bars) / 2
        ax.text(-0.15, mid_h0, 'H₀', transform=ax.get_yaxis_transform(),
                fontsize=10, fontweight='bold', color='steelblue', va='center')
        ax.text(-0.15, mid_h1, 'H₁', transform=ax.get_yaxis_transform(),
                fontsize=10, fontweight='bold', color='crimson', va='center')

    # Bottom row: Persistence diagram (birth vs death)
    ax = axes[1, col]

    if h0_bars:
        births_h0, deaths_h0 = zip(*h0_bars)
        ax.scatter(births_h0, deaths_h0, c='steelblue', s=30, alpha=0.7,
                   label='H₀ (components)', zorder=3)

    if h1_bars:
        births_h1, deaths_h1 = zip(*h1_bars)
        ax.scatter(births_h1, deaths_h1, c='crimson', s=30, alpha=0.7,
                   marker='^', label='H₁ (cycles)', zorder=3)

    # Diagonal
    max_val = max(max(d for _, d in h0_bars + h1_bars), 0.1)
    ax.plot([0, max_val * 1.1], [0, max_val * 1.1], 'k--', linewidth=0.5, alpha=0.3)
    ax.set_xlabel('Birth', fontsize=10)
    ax.set_ylabel('Death', fontsize=10)
    ax.set_title(f'{L}×{L} Grid — Persistence Diagram', fontsize=11, fontweight='bold')
    ax.legend(fontsize=8, loc='lower right')
    ax.set_aspect('equal')

fig.suptitle('Tropical Morse Filtration: Persistence Barcodes and Diagrams',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_barcode_persistence.png', dpi=150, bbox_inches='tight')
print("Saved viz_barcode_persistence.png")
