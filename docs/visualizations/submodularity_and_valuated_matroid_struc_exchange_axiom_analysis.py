#!/usr/bin/env python3
"""
Visualization: Exchange Axiom Analysis for Log-Det

This script visualizes the failure of the valuated matroid exchange axiom
for the log-det function. This is a key scientific finding: while log-det
is submodular (Hadamard-Fischer), it does NOT satisfy the valuated exchange
axiom on equal-cardinality layers.

The visualization shows:
1. Exchange deficit heatmap on 2-element subsets
2. Comparison of submodularity vs exchange on different cardinality layers
3. The gap between submodularity and valuated matroid structure
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


n = 5
K = random_psd_kernel(n, seed=42)
W = compute_log_det(K, n)

fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# --- Panel 1: Exchange analysis on 2-element subsets ---
ax1 = axes[0]
subsets_2 = list(combinations(range(n), 2))
m = len(subsets_2)

# For each pair of 2-element subsets, compute exchange deficit
exchange_matrix = np.zeros((m, m))
for i, A in enumerate(subsets_2):
    for j, B in enumerate(subsets_2):
        A_set, B_set = set(A), set(B)
        if A_set == B_set:
            exchange_matrix[i, j] = 0
            continue
        
        A_minus_B = A_set - B_set
        B_minus_A = B_set - A_set
        
        if not A_minus_B or not B_minus_A:
            exchange_matrix[i, j] = 0
            continue
        
        # Check if exchange axiom holds: for each a ∈ A\B, ∃ b ∈ B\A
        min_deficit = np.inf
        for a in A_minus_B:
            best_exchange = -np.inf
            for b in B_minus_A:
                new_A = tuple(sorted((A_set - {a}) | {b}))
                new_B = tuple(sorted((B_set - {b}) | {a}))
                exchange_val = W[new_A] + W[new_B] - W[A] - W[B]
                best_exchange = max(best_exchange, exchange_val)
            min_deficit = min(min_deficit, best_exchange)
        
        exchange_matrix[i, j] = min_deficit

labels = [f'{{{s[0]},{s[1]}}}' for s in subsets_2]
im1 = ax1.imshow(exchange_matrix, cmap='RdYlGn', aspect='auto')
ax1.set_xticks(range(m))
ax1.set_yticks(range(m))
ax1.set_xticklabels(labels, rotation=45, ha='right', fontsize=8)
ax1.set_yticklabels(labels, fontsize=8)
ax1.set_title('Exchange Deficit (2-element sets)', fontsize=12, fontweight='bold')
plt.colorbar(im1, ax=ax1, label='Min exchange value')

# Mark violations (negative values)
for i in range(m):
    for j in range(m):
        if exchange_matrix[i, j] < -1e-10:
            ax1.plot(j, i, 'rx', markersize=6, markeredgewidth=1.5)

# --- Panel 2: Submodularity vs Exchange by layer ---
ax2 = axes[1]

results = {'layer': [], 'sub_slack_mean': [], 'sub_slack_min': [],
           'exchange_pass_rate': []}

for r in range(1, n):
    subsets_r = list(combinations(range(n), r))
    
    # Submodularity slack on this layer
    slacks = []
    for A in subsets_r:
        for B in subsets_r:
            A_set, B_set = set(A), set(B)
            inter = tuple(sorted(A_set & B_set))
            union = tuple(sorted(A_set | B_set))
            slack = (W[A] + W[B]) - (W[inter] + W[union])
            slacks.append(slack)
    
    # Exchange pass rate on this layer
    total_tests = 0
    passed_tests = 0
    for A in subsets_r:
        for B in subsets_r:
            A_set, B_set = set(A), set(B)
            A_minus_B = A_set - B_set
            B_minus_A = B_set - A_set
            if not A_minus_B or not B_minus_A:
                continue
            
            all_exchanges_ok = True
            for a in A_minus_B:
                found = False
                for b in B_minus_A:
                    new_A = tuple(sorted((A_set - {a}) | {b}))
                    new_B = tuple(sorted((B_set - {b}) | {a}))
                    if W[A] + W[B] <= W[new_A] + W[new_B] + 1e-10:
                        found = True
                        break
                if not found:
                    all_exchanges_ok = False
                    break
            
            total_tests += 1
            if all_exchanges_ok:
                passed_tests += 1
    
    results['layer'].append(r)
    results['sub_slack_mean'].append(np.mean(slacks))
    results['sub_slack_min'].append(np.min(slacks))
    results['exchange_pass_rate'].append(
        passed_tests / total_tests if total_tests > 0 else 1.0)

x = results['layer']
ax2_twin = ax2.twinx()

bars = ax2.bar(np.array(x) - 0.15, results['sub_slack_mean'], 
               width=0.3, color='steelblue', alpha=0.7, label='Mean sub. slack')
ax2.bar(np.array(x) + 0.15, [max(0, s) for s in results['sub_slack_min']], 
        width=0.3, color='lightblue', alpha=0.7, label='Min sub. slack')

line = ax2_twin.plot(x, [r * 100 for r in results['exchange_pass_rate']], 
                     'ro-', linewidth=2, markersize=8, label='Exchange pass %')

ax2.set_xlabel('Cardinality Layer r', fontsize=12)
ax2.set_ylabel('Submodularity Slack', fontsize=12, color='steelblue')
ax2_twin.set_ylabel('Exchange Pass Rate (%)', fontsize=12, color='red')
ax2.set_title('Submodularity vs Exchange by Layer', fontsize=12, fontweight='bold')
ax2.set_xticks(x)

# Combined legend
lines1, labels1 = ax2.get_legend_handles_labels()
lines2, labels2 = ax2_twin.get_legend_handles_labels()
ax2.legend(lines1 + lines2, labels1 + labels2, fontsize=9, loc='upper right')

# --- Panel 3: Scatter plot of all pair deficits ---
ax3 = axes[2]

sub_slacks_all = []
exchange_slacks_all = []
colors = []

for A in all_subsets(n):
    for B in all_subsets(n):
        if len(A) != len(B) or len(A) == 0 or len(A) == n:
            continue
        A_set, B_set = set(A), set(B)
        
        # Submodularity slack
        inter = tuple(sorted(A_set & B_set))
        union = tuple(sorted(A_set | B_set))
        sub_slack = (W[A] + W[B]) - (W[inter] + W[union])
        
        # Exchange slack (best exchange value for worst element)
        A_minus_B = A_set - B_set
        B_minus_A = B_set - A_set
        if not A_minus_B or not B_minus_A:
            continue
        
        min_exchange = np.inf
        for a in A_minus_B:
            best = -np.inf
            for b in B_minus_A:
                new_A = tuple(sorted((A_set - {a}) | {b}))
                new_B = tuple(sorted((B_set - {b}) | {a}))
                best = max(best, W[new_A] + W[new_B] - W[A] - W[B])
            min_exchange = min(min_exchange, best)
        
        sub_slacks_all.append(sub_slack)
        exchange_slacks_all.append(min_exchange)
        colors.append(len(A))

scatter = ax3.scatter(sub_slacks_all, exchange_slacks_all, 
                     c=colors, cmap='viridis', alpha=0.5, s=15, edgecolors='none')
ax3.axhline(y=0, color='red', linestyle='--', linewidth=1, alpha=0.7, label='Exchange boundary')
ax3.axvline(x=0, color='blue', linestyle='--', linewidth=1, alpha=0.7, label='Submodularity boundary')
ax3.set_xlabel('Submodularity Slack (≥0 for submodular)', fontsize=11)
ax3.set_ylabel('Exchange Slack (≥0 for exchange)', fontsize=11)
ax3.set_title('Submodularity vs Exchange\n(per pair)', fontsize=12, fontweight='bold')
ax3.legend(fontsize=9)
plt.colorbar(scatter, ax=ax3, label='Cardinality |A|=|B|')

plt.suptitle(f'Log-Det: Submodular but NOT a Valuated Matroid Weight (n={n})',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_exchange.png', dpi=150, bbox_inches='tight')
print("Saved viz_exchange.png")
