#!/usr/bin/env python3
"""
Visualization: Submodularity of Log-Det for PSD Kernels

This script visualizes the submodularity structure of the log-det function
for positive semidefinite matrices. It shows:
1. A heatmap of log-det values across all subsets organized by cardinality
2. Diminishing marginal returns curves for different base sets
3. The submodularity deficit (how much slack the inequality has)

The visualization demonstrates that det K is log-submodular for PSD K
(the Hadamard-Fischer inequality), which is the algebraic engine behind
DPP negative dependence and tropical witness submodularity.
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


def all_subsets(n):
    result = []
    for r in range(n + 1):
        for S in combinations(range(n), r):
            result.append(S)
    return result


def compute_log_det(K, n):
    W = {}
    for S in all_subsets(n):
        det_val = principal_minor(K, S)
        W[S] = np.log(max(det_val, 1e-300))
    return W


def random_psd_kernel(n, seed=42):
    np.random.seed(seed)
    M = np.random.randn(n, n)
    K = M.T @ M + 0.01 * np.eye(n)
    return K


# Setup
n = 5
K = random_psd_kernel(n, seed=42)
W = compute_log_det(K, n)

fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# --- Panel 1: Log-det values by cardinality layer ---
ax1 = axes[0]
for r in range(n + 1):
    subsets_r = [S for S in all_subsets(n) if len(S) == r]
    values = [W[S] for S in subsets_r]
    jitter = np.random.uniform(-0.15, 0.15, len(values))
    ax1.scatter(r + jitter, values, alpha=0.7, s=40, c='steelblue', edgecolors='navy', linewidths=0.5)
    ax1.plot([r - 0.25, r + 0.25], [np.mean(values)] * 2, 'r-', linewidth=2)

ax1.set_xlabel('Subset Cardinality |S|', fontsize=12)
ax1.set_ylabel('W(S) = log det K[S]', fontsize=12)
ax1.set_title('Log-Det Values by Layer', fontsize=13, fontweight='bold')
ax1.set_xticks(range(n + 1))
ax1.grid(alpha=0.3)

# --- Panel 2: Diminishing marginal returns ---
ax2 = axes[1]
colors = plt.cm.viridis(np.linspace(0, 0.8, n))

for base_size in range(n):
    # For each base set size, compute average marginal gain
    subsets_base = [S for S in all_subsets(n) if len(S) == base_size]
    avg_gains = []
    
    for base in subsets_base:
        base_set = set(base)
        for e in range(n):
            if e not in base_set:
                new = tuple(sorted(base_set | {e}))
                gain = W[new] - W[base]
                avg_gains.append(gain)
    
    if avg_gains:
        ax2.scatter([base_size] * len(avg_gains), avg_gains, 
                   alpha=0.3, s=20, c=[colors[base_size]])
        ax2.plot(base_size, np.mean(avg_gains), 'o', color=colors[base_size],
                markersize=10, markeredgecolor='black', markeredgewidth=1)

ax2.set_xlabel('Base Set Size |A|', fontsize=12)
ax2.set_ylabel('Marginal Gain W(A∪{e}) - W(A)', fontsize=12)
ax2.set_title('Diminishing Marginal Returns', fontsize=13, fontweight='bold')
ax2.set_xticks(range(n))
ax2.grid(alpha=0.3)

# Add trend line through means
means_x, means_y = [], []
for base_size in range(n):
    subsets_base = [S for S in all_subsets(n) if len(S) == base_size]
    gains = []
    for base in subsets_base:
        base_set = set(base)
        for e in range(n):
            if e not in base_set:
                new = tuple(sorted(base_set | {e}))
                gains.append(W[new] - W[base])
    if gains:
        means_x.append(base_size)
        means_y.append(np.mean(gains))

ax2.plot(means_x, means_y, 'k--', linewidth=2, alpha=0.5, label='Mean trend')
ax2.legend(fontsize=10)

# --- Panel 3: Submodularity slack histogram ---
ax3 = axes[2]
slacks = []
subsets = all_subsets(n)
for A in subsets:
    for B in subsets:
        A_set, B_set = set(A), set(B)
        inter = tuple(sorted(A_set & B_set))
        union = tuple(sorted(A_set | B_set))
        slack = (W[A] + W[B]) - (W[inter] + W[union])
        slacks.append(slack)

slacks = np.array(slacks)
# Remove near-zero slacks (when A ⊆ B or B ⊆ A)
nonzero_slacks = slacks[np.abs(slacks) > 1e-10]

ax3.hist(nonzero_slacks, bins=50, color='forestgreen', alpha=0.7, 
         edgecolor='darkgreen', linewidth=0.5)
ax3.axvline(x=0, color='red', linestyle='--', linewidth=2, label='Submodularity boundary')
ax3.set_xlabel('Slack: W(A)+W(B) - W(A∩B) - W(A∪B)', fontsize=12)
ax3.set_ylabel('Count', fontsize=12)
ax3.set_title('Submodularity Slack Distribution', fontsize=13, fontweight='bold')
ax3.legend(fontsize=10)
ax3.grid(alpha=0.3)

min_slack = slacks.min()
ax3.annotate(f'Min slack: {min_slack:.2e}', xy=(min_slack, 0),
            xytext=(min_slack + 0.5, ax3.get_ylim()[1] * 0.3),
            arrowprops=dict(arrowstyle='->', color='red'),
            fontsize=10, color='red')

plt.suptitle(f'Submodularity of Log-Det for {n}×{n} PSD Kernel\n'
             f'(Hadamard–Fischer Inequality Verification)',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_submodularity.png', dpi=150, bbox_inches='tight')
print("Saved viz_submodularity.png")
