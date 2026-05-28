#!/usr/bin/env python3
"""
Visualization 3: Shadow Growth and Complexity Lower Bounds

Shows how the shadow lower bound grows as the support of a polynomial
increases. Compares sparse vs dense supports and illustrates why the
shadow-based complexity measure captures genuine arithmetic structure.
"""
import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations_with_replacement, product as cartesian_product
import random


def compute_shadow(support, n_vars):
    shadow = set()
    for alpha in support:
        for i in range(n_vars):
            if alpha[i] < 1:
                continue
            mid = list(alpha)
            mid[i] -= 1
            for j in range(n_vars):
                if mid[j] < 1:
                    continue
                beta = list(mid)
                beta[j] -= 1
                shadow.add(tuple(beta))
    return shadow


def is_shadow_closed(support, n_vars):
    return compute_shadow(support, n_vars).issubset(support)


# ─── Data Generation ─────────────────────────────────────

n_vars = 3
random.seed(42)

# Track data for plotting
dense_sizes = []
dense_shadows = []
dense_closed = []

sparse_sizes = []
sparse_shadows = []
sparse_closed = []

# Dense supports: all monomials up to degree d
for max_deg in range(1, 8):
    support = set()
    for degs in cartesian_product(range(max_deg + 1), repeat=n_vars):
        if sum(degs) <= max_deg:
            support.add(degs)
    shadow = compute_shadow(support, n_vars)
    dense_sizes.append(len(support))
    dense_shadows.append(len(shadow))
    dense_closed.append(is_shadow_closed(support, n_vars))

# Sparse random supports of increasing size
all_monomials = []
for degs in cartesian_product(range(8), repeat=n_vars):
    if sum(degs) <= 7:
        all_monomials.append(degs)

for n_terms in range(3, 50, 3):
    trials = []
    for _ in range(10):
        support = set(random.sample(all_monomials, min(n_terms, len(all_monomials))))
        shadow = compute_shadow(support, n_vars)
        trials.append((len(support), len(shadow), is_shadow_closed(support, n_vars)))
    avg_size = np.mean([t[0] for t in trials])
    avg_shadow = np.mean([t[1] for t in trials])
    frac_closed = np.mean([t[2] for t in trials])
    sparse_sizes.append(avg_size)
    sparse_shadows.append(avg_shadow)
    sparse_closed.append(frac_closed)


# ─── Plotting ────────────────────────────────────────────

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Panel 1: Shadow size vs support size
ax1.plot(dense_sizes, dense_shadows, 'o-', color='#2c3e50', linewidth=2,
         markersize=8, label='Dense (degree ≤ d)', zorder=5)
ax1.plot(sparse_sizes, sparse_shadows, 's--', color='#e74c3c', linewidth=1.5,
         markersize=6, label='Sparse (random, avg)', alpha=0.8)

# Reference line
max_x = max(max(dense_sizes), max(sparse_sizes))
ax1.plot([0, max_x], [0, max_x], ':', color='gray', alpha=0.5, label='|Sh₂| = |S|')

ax1.set_xlabel("Support Size |S|", fontsize=12)
ax1.set_ylabel("Shadow Size |Sh₂(S)|", fontsize=12)
ax1.set_title("Shadow Growth: Dense vs Sparse Supports\n(3 variables)",
              fontsize=13, fontweight='bold')
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

# Panel 2: Shadow closure fraction
# For dense supports, closure is always true
ax2.bar(range(len(dense_sizes)),
        [1.0 if c else 0.0 for c in dense_closed],
        alpha=0.7, color='#2c3e50', label='Dense supports')

# For sparse supports, show fraction
ax2_twin = ax2.twinx()
ax2_twin.plot(range(len(sparse_closed)), sparse_closed,
              's-', color='#e74c3c', linewidth=2, markersize=6,
              label='Sparse (fraction closed)')
ax2_twin.set_ylabel("Fraction shadow-closed (sparse)", fontsize=11, color='#e74c3c')
ax2_twin.set_ylim(-0.05, 1.05)
ax2_twin.tick_params(axis='y', labelcolor='#e74c3c')

ax2.set_xlabel("Configuration index", fontsize=12)
ax2.set_ylabel("Shadow-closed? (dense)", fontsize=11, color='#2c3e50')
ax2.set_title("Shadow Closure: Dense Supports Are Always Closed\n"
              "Sparse Supports Become Closed as They Densify",
              fontsize=13, fontweight='bold')
ax2.set_ylim(-0.05, 1.3)

# Combined legend
lines1, labels1 = ax2.get_legend_handles_labels()
lines2, labels2 = ax2_twin.get_legend_handles_labels()
ax2.legend(lines1 + lines2, labels1 + labels2, fontsize=10, loc='upper left')
ax2.grid(True, alpha=0.3)

plt.suptitle("Non-Cancellation Certificate: Shadow Growth and Closure Properties",
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig("viz_shadow_growth.png", dpi=150, bbox_inches='tight')
print("Saved viz_shadow_growth.png")
