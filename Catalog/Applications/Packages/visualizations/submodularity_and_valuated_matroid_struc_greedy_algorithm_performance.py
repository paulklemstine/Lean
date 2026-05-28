#!/usr/bin/env python3
"""
Visualization: Greedy Algorithm Performance with Submodular Log-Det

This script visualizes the greedy algorithm for maximizing log-det diversity,
showing how the diminishing returns property (equivalent to submodularity)
enables efficient optimization.

Shows:
1. Greedy vs optimal performance across different cardinality constraints
2. Marginal gain curves demonstrating diminishing returns
3. Kernel structure and selected subsets
"""

import numpy as np
from itertools import combinations
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def principal_minor(K, subset):
    if len(subset) == 0:
        return 1.0
    idx = list(subset)
    return np.linalg.det(K[np.ix_(idx, idx)])


def log_det(K, subset):
    det_val = principal_minor(K, subset)
    return np.log(max(det_val, 1e-300))


def greedy_selection(K, k):
    n = K.shape[0]
    selected = []
    values = [0.0]
    marginals = []
    
    for step in range(k):
        best_gain = -np.inf
        best_elem = None
        
        for e in range(n):
            if e in selected:
                continue
            new_set = tuple(sorted(selected + [e]))
            gain = log_det(K, new_set) - values[-1]
            if gain > best_gain:
                best_gain = gain
                best_elem = e
        
        selected.append(best_elem)
        values.append(values[-1] + best_gain)
        marginals.append(best_gain)
    
    return selected, values, marginals


def optimal_value(K, k):
    n = K.shape[0]
    best = -np.inf
    best_set = None
    for S in combinations(range(n), k):
        val = log_det(K, S)
        if val > best:
            best = val
            best_set = S
    return best, best_set


n = 6
np.random.seed(42)
M = np.random.randn(n, n)
K = M.T @ M + 0.05 * np.eye(n)

fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# --- Panel 1: Greedy vs Optimal ---
ax1 = axes[0]
greedy_vals = []
optimal_vals = []
ks = list(range(1, n + 1))

full_selected, full_values, full_marginals = greedy_selection(K, n)

for k in ks:
    greedy_vals.append(full_values[k])
    opt_val, _ = optimal_value(K, k)
    optimal_vals.append(opt_val)

ax1.plot(ks, optimal_vals, 'b-o', linewidth=2, markersize=8, label='Optimal', zorder=3)
ax1.plot(ks, greedy_vals, 'r--s', linewidth=2, markersize=8, label='Greedy', zorder=3)
ax1.fill_between(ks, greedy_vals, optimal_vals, alpha=0.1, color='blue')

# Add (1-1/e) bound
one_minus_inv_e = 1 - 1/np.e
for k in ks:
    bound = one_minus_inv_e * optimal_vals[k-1]
    ax1.plot(k, bound, 'g^', markersize=6, alpha=0.7)

ax1.plot([], [], 'g^', markersize=6, label=f'(1-1/e)·OPT ≈ {one_minus_inv_e:.3f}·OPT')

ax1.set_xlabel('Cardinality k', fontsize=12)
ax1.set_ylabel('log det K[S]', fontsize=12)
ax1.set_title('Greedy vs Optimal', fontsize=13, fontweight='bold')
ax1.legend(fontsize=10)
ax1.set_xticks(ks)
ax1.grid(alpha=0.3)

# Add ratio annotations
for k in ks:
    ratio = greedy_vals[k-1] / optimal_vals[k-1] if optimal_vals[k-1] > 0 else 1.0
    ax1.annotate(f'{ratio:.2f}', (k, greedy_vals[k-1]), 
                textcoords="offset points", xytext=(10, -10),
                fontsize=8, color='red')

# --- Panel 2: Marginal gains ---
ax2 = axes[1]
bar_colors = plt.cm.Reds(np.linspace(0.3, 0.9, n))
bars = ax2.bar(range(1, n + 1), full_marginals, color=bar_colors, 
               edgecolor='darkred', linewidth=0.5)

# Add element labels
for i, (bar, elem) in enumerate(zip(bars, full_selected)):
    ax2.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.05,
             f'elem {elem}', ha='center', va='bottom', fontsize=9)

ax2.set_xlabel('Step', fontsize=12)
ax2.set_ylabel('Marginal Gain', fontsize=12)
ax2.set_title('Diminishing Marginal Returns', fontsize=13, fontweight='bold')
ax2.set_xticks(range(1, n + 1))
ax2.grid(alpha=0.3, axis='y')

# Verify diminishing returns
is_diminishing = all(full_marginals[i] >= full_marginals[i+1] - 1e-10 
                     for i in range(len(full_marginals)-1))
ax2.text(0.95, 0.95, 
         f'Diminishing: {"✓" if is_diminishing else "✗"}',
         transform=ax2.transAxes, ha='right', va='top',
         fontsize=11, fontweight='bold',
         color='green' if is_diminishing else 'red',
         bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))

# --- Panel 3: Kernel heatmap with greedy selection order ---
ax3 = axes[2]

# Reorder by greedy selection
order = full_selected
K_reordered = K[np.ix_(order, order)]

im3 = ax3.imshow(K_reordered, cmap='coolwarm', aspect='auto')
ax3.set_xticks(range(n))
ax3.set_yticks(range(n))
ax3.set_xticklabels([f'{order[i]}' for i in range(n)])
ax3.set_yticklabels([f'{order[i]}' for i in range(n)])
ax3.set_title('Kernel (greedy order)', fontsize=13, fontweight='bold')
plt.colorbar(im3, ax=ax3)

# Highlight diagonal
for i in range(n):
    ax3.add_patch(plt.Rectangle((i-0.5, i-0.5), 1, 1, 
                                fill=False, edgecolor='gold', linewidth=2))

# Add selection step annotations
for i in range(n):
    ax3.text(i, -0.7, f'step {i+1}', ha='center', fontsize=8, color='navy')

plt.suptitle(f'Greedy Optimization of Submodular Log-Det (n={n})',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_greedy.png', dpi=150, bbox_inches='tight')
print("Saved viz_greedy.png")
