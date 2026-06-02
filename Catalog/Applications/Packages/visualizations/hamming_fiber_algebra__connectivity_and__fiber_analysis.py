#!/usr/bin/env python3
"""
Visualization: Fiber graphs in Hamming spaces.
Shows fiber connectivity and bridge duality for additive flavor maps.
"""
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from itertools import product
from collections import defaultdict


def hamming_dist(u, v):
    return sum(1 for a, b in zip(u, v) if a != b)


def additive_eval(slot_flavors, w):
    return sum(slot_flavors[i][w[i]] for i in range(len(w)))


def all_words(n, m):
    return list(product(range(m), repeat=n))


def compute_fibers(slot_flavors, n, m):
    fibers = defaultdict(list)
    for w in all_words(n, m):
        t = additive_eval(slot_flavors, w)
        fibers[t].append(w)
    return dict(fibers)


# Parameters
n, m = 3, 3
slot_flavors = {0: {0: 0, 1: 1, 2: 2}, 1: {0: 0, 1: 1, 2: 2}, 2: {0: 0, 1: 1, 2: 2}}

fibers = compute_fibers(slot_flavors, n, m)
words = all_words(n, m)

# Create figure with two subplots
fig, axes = plt.subplots(1, 2, figsize=(16, 7))

# Plot 1: Fiber sizes
ax1 = axes[0]
targets = sorted(fibers.keys())
sizes = [len(fibers[t]) for t in targets]
colors = plt.cm.viridis(np.linspace(0.2, 0.8, len(targets)))
bars = ax1.bar(targets, sizes, color=colors, edgecolor='black', linewidth=0.5)
ax1.set_xlabel('Target Score t', fontsize=12)
ax1.set_ylabel('Fiber Size |f⁻¹(t)|', fontsize=12)
ax1.set_title(f'Fiber Sizes for Uniform Additive Map on H({n},{m})', fontsize=14)
ax1.set_xticks(targets)
total = sum(sizes)
ax1.text(0.95, 0.95, f'Total: {total} = {m}^{n}',
         transform=ax1.transAxes, ha='right', va='top', fontsize=11,
         bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

# Plot 2: Bridge analysis for a specific fiber
ax2 = axes[1]

# Analyze bridges for each fiber
bridge_data = []
for t in targets:
    fiber = fibers[t]
    if len(fiber) < 2:
        bridge_data.append((t, 0, 0))
        continue
    
    pairs_d2 = 0
    bridged = 0
    for i_idx, u in enumerate(fiber):
        for v in fiber[i_idx+1:]:
            if hamming_dist(u, v) == 2:
                pairs_d2 += 1
                diffs = [k for k in range(n) if u[k] != v[k]]
                i0 = diffs[0]
                if slot_flavors[i0][u[i0]] == slot_flavors[i0][v[i0]]:
                    bridged += 1
    bridge_data.append((t, pairs_d2, bridged))

targets_d2 = [d[0] for d in bridge_data]
pairs_vals = [d[1] for d in bridge_data]
bridged_vals = [d[2] for d in bridge_data]
unbridged_vals = [p - b for p, b in zip(pairs_vals, bridged_vals)]

x = np.arange(len(targets_d2))
width = 0.35
rects1 = ax2.bar(x - width/2, bridged_vals, width, label='Bridged pairs',
                  color='#2ecc71', edgecolor='black', linewidth=0.5)
rects2 = ax2.bar(x + width/2, unbridged_vals, width, label='Unbridged pairs',
                  color='#e74c3c', edgecolor='black', linewidth=0.5)
ax2.set_xlabel('Target Score t', fontsize=12)
ax2.set_ylabel('Number of Distance-2 Pairs', fontsize=12)
ax2.set_title('Bridge Duality: Distance-2 Fiber Pairs', fontsize=14)
ax2.set_xticks(x)
ax2.set_xticklabels(targets_d2)
ax2.legend()

plt.tight_layout()
plt.savefig('fiber_analysis.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved fiber_analysis.png")

# Plot 3: Expansion ratios
fig2, ax3 = plt.subplots(figsize=(10, 6))

# Test expansion for different slot flavors
configs = [
    ("Uniform φᵢ(j) = j", {i: {j: j for j in range(m)} for i in range(n)}),
    ("Injective φᵢ(j) = i·m + j", {i: {j: i*m + j for j in range(m)} for i in range(n)}),
    ("Mixed φ₀=id, φ₁=const", {0: {j: j for j in range(m)}, 1: {j: 0 for j in range(m)}, 2: {j: j for j in range(m)}}),
]

for cfg_idx, (label, sf) in enumerate(configs):
    fibers_cfg = compute_fibers(sf, n, m)
    all_ratios = []
    fiber_targets = []
    for t, fiber in sorted(fibers_cfg.items()):
        fiber_set = set(fiber)
        for w in fiber:
            nbrs = []
            for i in range(n):
                for a in range(m):
                    if a != w[i]:
                        v = list(w); v[i] = a
                        nbrs.append(tuple(v))
            internal = sum(1 for v in nbrs if v in fiber_set)
            if internal > 0:
                ratio = (len(nbrs) - internal) / internal
                all_ratios.append(ratio)
                fiber_targets.append(t)
    
    if all_ratios:
        ax3.scatter(fiber_targets, all_ratios, label=label, alpha=0.7, s=40)

ax3.axhline(y=m-2, color='red', linestyle='--', alpha=0.5, label=f'Conjectured min = m-2 = {m-2}')
ax3.set_xlabel('Target Score', fontsize=12)
ax3.set_ylabel('Expansion Ratio (external/internal)', fontsize=12)
ax3.set_title(f'Fiber Expansion Ratios in H({n},{m})', fontsize=14)
ax3.legend()
ax3.set_ylim(bottom=0)

plt.tight_layout()
plt.savefig('expansion_ratios.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved expansion_ratios.png")
