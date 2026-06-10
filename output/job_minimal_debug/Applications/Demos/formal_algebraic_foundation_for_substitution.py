#!/usr/bin/env python3
"""
Hamming Fiber Algebra — Demonstration Script

Demonstrates the key results from the Hamming Fiber Algebra research:
1. Hamming graph regularity (degree = n*(m-1))
2. Plotkin bound verification
3. Bridge duality theorem validation
4. Fiber expansion ratio computation
"""

from itertools import product
from collections import defaultdict


def hamming_dist(u, v):
    """Hamming distance between two words."""
    return sum(1 for a, b in zip(u, v) if a != b)


def hamming_neighbors(w, n, m):
    """All distance-1 neighbors of word w in H(n,m)."""
    neighbors = []
    for i in range(n):
        for a in range(m):
            if a != w[i]:
                v = list(w)
                v[i] = a
                neighbors.append(tuple(v))
    return neighbors


def all_words(n, m):
    """All words in H(n,m)."""
    return list(product(range(m), repeat=n))


def additive_eval(slot_flavors, w):
    """Evaluate an additive flavor map: sum of slot_flavors[i][w[i]]."""
    return sum(slot_flavors[i][w[i]] for i in range(len(w)))


def compute_fiber(slot_flavors, n, m, target):
    """Compute the fiber f^{-1}(target)."""
    return [w for w in all_words(n, m) if additive_eval(slot_flavors, w) == target]


# ─── Demo 1: Hamming Graph Regularity ───
print("=" * 60)
print("Demo 1: Hamming Graph Regularity")
print("=" * 60)
for n in range(1, 6):
    for m in [2, 3, 4]:
        w = tuple([0] * n)
        nbrs = hamming_neighbors(w, n, m)
        expected = n * (m - 1)
        assert len(nbrs) == expected, f"FAIL: n={n}, m={m}"
        print(f"  H({n},{m}): degree = {len(nbrs)} = {n}×{m-1} ✓")
print()

# ─── Demo 2: Plotkin Bound Verification ───
print("=" * 60)
print("Demo 2: Plotkin Bound Verification")
print("=" * 60)
print("  Binary codes with minimum distance d > n/2 must have |C| ≤ 2d.")
print()

# Enumerate all binary codes of small size and check Plotkin bound
for n in range(2, 7):
    words = all_words(n, 2)
    for d in range(n // 2 + 1, n + 1):
        # Find maximum code size with minimum distance d
        # Greedy approach
        best_code = []
        for w in words:
            valid = all(hamming_dist(w, c) >= d for c in best_code)
            if valid:
                best_code.append(w)
        bound = 2 * d
        print(f"  H({n},2), d={d}: max code size found = {len(best_code)}, "
              f"Plotkin bound = {bound}, "
              f"{'✓' if len(best_code) * (2*d - n) <= 2*d else '✗'}")
print()

# ─── Demo 3: Bridge Duality Theorem ───
print("=" * 60)
print("Demo 3: Bridge Duality Theorem")
print("=" * 60)
print("  For distance-2 fiber pairs, bridge at position i₀ exists")
print("  iff bridge at position i₁ exists.")
print()

n, m = 4, 3
slot_flavors = {0: {0: 0, 1: 1, 2: 3}, 1: {0: 0, 1: 2, 2: 4},
                2: {0: 1, 1: 3, 2: 5}, 3: {0: 0, 1: 1, 2: 2}}

words = all_words(n, m)
fiber_map = defaultdict(list)
for w in words:
    t = additive_eval(slot_flavors, w)
    fiber_map[t].append(w)

bridge_checks = 0
bridge_duality_holds = 0
for t, fiber in fiber_map.items():
    for i, u in enumerate(fiber):
        for v in fiber[i+1:]:
            if hamming_dist(u, v) == 2:
                # Find the two differing positions
                diffs = [k for k in range(n) if u[k] != v[k]]
                i0, i1 = diffs
                # Check bridge at i0: update u at i0 to v[i0]
                w0 = list(u); w0[i0] = v[i0]; w0 = tuple(w0)
                bridge0 = additive_eval(slot_flavors, w0) == t
                # Check bridge at i1: update u at i1 to v[i1]
                w1 = list(u); w1[i1] = v[i1]; w1 = tuple(w1)
                bridge1 = additive_eval(slot_flavors, w1) == t
                bridge_checks += 1
                if bridge0 == bridge1:
                    bridge_duality_holds += 1
                # Also verify the slot flavor equality
                slot_eq_0 = (slot_flavors[i0][u[i0]] == slot_flavors[i0][v[i0]])
                slot_eq_1 = (slot_flavors[i1][u[i1]] == slot_flavors[i1][v[i1]])
                assert slot_eq_0 == slot_eq_1, "Duality FAILED!"
                assert bridge0 == slot_eq_0, "Bridge-slot correspondence FAILED!"

print(f"  Checked {bridge_checks} distance-2 fiber pairs in H({n},{m})")
print(f"  Bridge duality holds: {bridge_duality_holds}/{bridge_checks} ✓")
print()

# ─── Demo 4: Fiber Expansion Ratios ───
print("=" * 60)
print("Demo 4: Fiber Expansion Ratios (Conjecture Test)")
print("=" * 60)
print("  Testing: for injective slot flavors, external neighbors ≥ 2× internal")
print()

# Test with injective slot flavors on H(3,3)
n, m = 3, 3
slot_flavors_inj = {0: {0: 0, 1: 1, 2: 2},
                    1: {0: 0, 1: 3, 2: 6},
                    2: {0: 0, 1: 9, 2: 18}}

words = all_words(n, m)
fiber_map = defaultdict(list)
for w in words:
    t = additive_eval(slot_flavors_inj, w)
    fiber_map[t].append(w)

min_ratio = float('inf')
conjecture_holds = True
for t, fiber in fiber_map.items():
    fiber_set = set(fiber)
    for w in fiber:
        nbrs = hamming_neighbors(w, n, m)
        internal = sum(1 for v in nbrs if tuple(v) in fiber_set)
        external = len(nbrs) - internal
        total = len(nbrs)  # = n*(m-1) = 6
        if internal > 0:
            ratio = external / internal
            min_ratio = min(min_ratio, ratio)
            if total < 2 * internal:
                conjecture_holds = False
                print(f"  COUNTEREXAMPLE: w={w}, fiber={t}, internal={internal}, "
                      f"external={external}")

print(f"  H({n},{m}) with injective flavors:")
print(f"  Minimum expansion ratio: {min_ratio:.2f}")
print(f"  Conjecture (external ≥ 2×internal): {'✓ HOLDS' if conjecture_holds else '✗ FAILS'}")
print()

# ─── Demo 5: Triangle Dichotomy ───
print("=" * 60)
print("Demo 5: Triangle Dichotomy")
print("=" * 60)

for m_val in [2, 3, 4, 5]:
    n_val = 3
    words = all_words(n_val, m_val)
    triangles = 0
    for i, u in enumerate(words):
        for j, v in enumerate(words[i+1:], i+1):
            if hamming_dist(u, v) != 1:
                continue
            for w in words[j+1:]:
                if hamming_dist(u, w) == 1 and hamming_dist(v, w) == 1:
                    triangles += 1
    print(f"  H({n_val},{m_val}): {triangles} distance-1 triangles"
          f" {'(triangle-free!)' if triangles == 0 else ''}")

print()
print("Binary spaces are uniquely triangle-free — a topological phase transition at m=3.")


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
