#!/usr/bin/env python3
"""
Visualization: Phase Diagram — Disorder vs Integrality Gap

Creates a 2D phase diagram showing regions of (collision_index, heterogeneity)
space colored by the typical integrality gap. This illustrates the conjectured
phase transition: the "uniform phase" (CI ≈ 1, het ≈ 0) has small gaps, while
the "disordered phase" (CI << 1, het >> 0) has large gaps.

Inspired by statistical mechanics phase diagrams where disorder parameters
control macroscopic behavior.
"""

import itertools
import random
import math
from collections import Counter
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import LinearSegmentedColormap


# ── Self-contained computations ──────────────────────────────────────

def edge_heterogeneity(edges):
    if not edges:
        return 0.0
    sizes = [len(e) for e in edges]
    mean = sum(sizes) / len(sizes)
    return sum((s - mean) ** 2 for s in sizes) / len(sizes)

def collision_index(edges):
    if not edges:
        return 1.0
    sizes = [len(e) for e in edges]
    n = len(sizes)
    counts = Counter(sizes)
    return sum((c / n) ** 2 for c in counts.values())

def transversal_number_exact(n_v, edges):
    for size in range(n_v + 1):
        for S in itertools.combinations(range(n_v), size):
            S_set = set(S)
            if all(S_set & e for e in edges):
                return size
    return n_v

def fractional_transversal_lp(n_v, edges):
    try:
        from scipy.optimize import linprog
        c = np.ones(n_v)
        A_ub = [[-1 if v in e else 0 for v in range(n_v)] for e in edges]
        b_ub = [-1] * len(edges)
        bounds = [(0, 1)] * n_v
        result = linprog(c, A_ub=A_ub, b_ub=b_ub, bounds=bounds, method='highs')
        if result.success:
            return result.fun
    except ImportError:
        pass
    return 0.0


# ── Generate data ────────────────────────────────────────────────────

random.seed(123)
n_v = 10
n_trials = 500

data_ci, data_het, data_gap, data_cgap = [], [], [], []

# Sample with various size distributions to cover the phase space
size_configs = [
    [2],       # uniform-2
    [3],       # uniform-3
    [4],       # uniform-4
    [2, 3],    # two-level
    [2, 4],    # two-level wide
    [2, 5],    # two-level wider
    [3, 5],    # two-level
    [2, 3, 4], # three-level
    [2, 3, 4, 5],  # four-level
    [2, 3, 5],     # three-level sparse
]

for config in size_configs:
    for _ in range(n_trials // len(size_configs)):
        n_e = random.randint(4, 12)
        edges = set()
        for _ in range(n_e * 3):
            k = random.choice(config)
            k = min(k, n_v)
            e = frozenset(random.sample(range(n_v), k))
            edges.add(e)
            if len(edges) >= n_e:
                break
        edges = list(edges)
        if not edges:
            continue

        ci = collision_index(edges)
        het = edge_heterogeneity(edges)
        tau = transversal_number_exact(n_v, edges)
        tau_star = fractional_transversal_lp(n_v, edges)
        gap = tau - tau_star
        cgap = tau - math.ceil(tau_star - 1e-9)

        data_ci.append(ci)
        data_het.append(het)
        data_gap.append(gap)
        data_cgap.append(cgap)


# ── Plot ─────────────────────────────────────────────────────────────

fig, ax = plt.subplots(1, 1, figsize=(10, 8))

# Custom colormap: blue (low gap) → yellow → red (high gap)
colors_custom = ['#2166ac', '#67a9cf', '#d1e5f0', '#fddbc7', '#ef8a62', '#b2182b']
cmap = LinearSegmentedColormap.from_list('gap_phase', colors_custom)

sc = ax.scatter(data_ci, data_het, c=data_gap, cmap=cmap,
                alpha=0.65, s=40, edgecolors='gray', linewidths=0.3,
                vmin=0, vmax=max(data_gap) if data_gap else 3)

# Add phase boundary annotation
ax.annotate('UNIFORM PHASE\n(Low disorder, small gap)',
            xy=(0.95, 0.05), fontsize=11, color='#2166ac',
            fontweight='bold', ha='center',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='white', alpha=0.8))

ax.annotate('DISORDERED PHASE\n(High disorder, large gap)',
            xy=(0.45, max(data_het)*0.7 if data_het else 1),
            fontsize=11, color='#b2182b', fontweight='bold', ha='center',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='white', alpha=0.8))

# Add conjectured phase boundary
ci_line = np.linspace(0.2, 1.0, 100)
het_boundary = 2 * (1 - ci_line) ** 2  # illustrative boundary
ax.plot(ci_line, het_boundary, 'k--', alpha=0.4, linewidth=2,
        label='Conjectured phase boundary')

ax.set_xlabel('Collision Index (CI)', fontsize=13)
ax.set_ylabel('Edge-size Heterogeneity (σ²)', fontsize=13)
ax.set_title('Phase Diagram: Disorder Parameters vs Integrality Gap',
             fontsize=14, fontweight='bold')

cbar = plt.colorbar(sc, ax=ax)
cbar.set_label('Integrality gap (τ − τ*)', fontsize=12)

ax.legend(fontsize=11, loc='upper left')
ax.grid(True, alpha=0.2)

# Inset: histogram of gaps by phase
ax_inset = fig.add_axes([0.15, 0.55, 0.25, 0.3])
uniform_gaps = [g for ci, g in zip(data_ci, data_gap) if ci > 0.8]
disordered_gaps = [g for ci, g in zip(data_ci, data_gap) if ci < 0.5]
if uniform_gaps:
    ax_inset.hist(uniform_gaps, bins=15, alpha=0.6, color='#2166ac',
                  label='CI > 0.8', density=True)
if disordered_gaps:
    ax_inset.hist(disordered_gaps, bins=15, alpha=0.6, color='#b2182b',
                  label='CI < 0.5', density=True)
ax_inset.set_xlabel('Gap', fontsize=9)
ax_inset.set_ylabel('Density', fontsize=9)
ax_inset.legend(fontsize=8)
ax_inset.set_title('Gap Distribution\nby Phase', fontsize=9)

plt.savefig('phase_diagram.png', dpi=150, bbox_inches='tight')
print("Saved: phase_diagram.png")
