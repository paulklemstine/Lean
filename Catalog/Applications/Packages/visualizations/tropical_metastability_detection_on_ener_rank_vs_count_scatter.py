#!/usr/bin/env python3
"""
Visualization 3: Metastability Rank vs Degeneracy Count

Scatter plot comparing metastability rank with degeneracy count across
many random energy landscapes, illustrating Theorem 3: under non-resonance,
rank = count (points on the diagonal), while resonant cases can have rank < count.

This script is fully self-contained — no local imports needed.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import combinations

# ── Inline core functions ──

def out_min_value(W, i):
    return float(np.min(W[i]))

def out_minimizer_set(W, i, tol=1e-12):
    m = out_min_value(W, i)
    return {j for j in range(W.shape[1]) if abs(W[i, j] - m) < tol}

def is_metastably_degenerate(W, i):
    return len(out_minimizer_set(W, i)) >= 2

def balance_witness_pair(W, i):
    mins = sorted(out_minimizer_set(W, i))
    return (mins[0], mins[1]) if len(mins) >= 2 else None

def is_witness_independent(W, family):
    supports = []
    for i in family:
        w = balance_witness_pair(W, i)
        if w is None:
            return False
        supports.append(set(w))
    for a, b in combinations(range(len(supports)), 2):
        if supports[a] & supports[b]:
            return False
    return True

def metastability_rank(W, S):
    degenerate = [i for i in S if is_metastably_degenerate(W, i)]
    best = 0
    for r in range(len(degenerate) + 1):
        for subset in combinations(degenerate, r):
            if is_witness_independent(W, list(subset)):
                best = max(best, len(subset))
    return best

def non_resonant_on(W, S):
    degenerate = [i for i in S if is_metastably_degenerate(W, i)]
    return is_witness_independent(W, degenerate)

def degeneracy_count(W, S):
    return sum(1 for i in S if is_metastably_degenerate(W, i))

# ── Generate data ──

np.random.seed(42)
n_trials = 300
n_vertices = 6

nr_ranks = []
nr_counts = []
res_ranks = []
res_counts = []

for _ in range(n_trials):
    W = np.random.uniform(1, 10, (n_vertices, n_vertices))
    np.fill_diagonal(W, 99.)
    
    # Impose random equalities
    for i in range(n_vertices):
        if np.random.random() < 0.4:
            others = [j for j in range(n_vertices) if j != i]
            j, k = np.random.choice(others, 2, replace=False)
            val = min(W[i, j], W[i, k])
            W[i, j] = val
            W[i, k] = val
    
    S = set(range(n_vertices))
    rank = metastability_rank(W, S)
    count = degeneracy_count(W, S)
    
    if non_resonant_on(W, S):
        nr_ranks.append(rank)
        nr_counts.append(count)
    else:
        res_ranks.append(rank)
        res_counts.append(count)

# ── Plot ──

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Panel 1: Scatter plot
ax1 = axes[0]
max_val = max(max(nr_counts + res_counts, default=0), 
              max(nr_ranks + res_ranks, default=0)) + 1

# Jitter for visibility
jitter = 0.12
nr_r_j = np.array(nr_ranks) + np.random.uniform(-jitter, jitter, len(nr_ranks))
nr_c_j = np.array(nr_counts) + np.random.uniform(-jitter, jitter, len(nr_counts))
res_r_j = np.array(res_ranks) + np.random.uniform(-jitter, jitter, len(res_ranks))
res_c_j = np.array(res_counts) + np.random.uniform(-jitter, jitter, len(res_counts))

ax1.scatter(nr_c_j, nr_r_j, c='#2ecc71', alpha=0.6, s=40, label='Non-resonant', 
           edgecolors='darkgreen', linewidth=0.5, zorder=3)
ax1.scatter(res_c_j, res_r_j, c='#e74c3c', alpha=0.6, s=40, label='Resonant',
           edgecolors='darkred', linewidth=0.5, zorder=3)

# Diagonal
ax1.plot([-0.5, max_val], [-0.5, max_val], 'k--', linewidth=1, alpha=0.5, 
         label='Rank = Count')

ax1.set_xlabel('Degeneracy Count', fontsize=12)
ax1.set_ylabel('Metastability Rank', fontsize=12)
ax1.set_title('Theorem 3: Rank vs Count', fontsize=14, fontweight='bold')
ax1.legend(fontsize=10, loc='upper left')
ax1.set_xlim(-0.5, max_val)
ax1.set_ylim(-0.5, max_val)
ax1.set_aspect('equal')
ax1.grid(True, alpha=0.3)

# Annotation
ax1.annotate('Non-resonant: always\non the diagonal (theorem!)',
            xy=(3, 3), xytext=(1, 4.5), fontsize=9,
            arrowprops=dict(arrowstyle='->', color='darkgreen'),
            color='darkgreen', fontweight='bold')
ax1.annotate('Resonant: rank < count\n(hypothesis needed!)',
            xy=(3.5, 1.5), xytext=(4, 0.5), fontsize=9,
            arrowprops=dict(arrowstyle='->', color='darkred'),
            color='darkred', fontweight='bold')

# Panel 2: Distribution
ax2 = axes[1]
gaps_nr = np.array(nr_counts) - np.array(nr_ranks)
gaps_res = np.array(res_counts) - np.array(res_ranks)

all_gaps = list(gaps_nr) + list(gaps_res)
max_gap = max(all_gaps, default=0)
bins = np.arange(-0.5, max_gap + 1.5, 1)

ax2.hist(gaps_nr, bins=bins, alpha=0.7, color='#2ecc71', label='Non-resonant',
         edgecolor='darkgreen', linewidth=1)
ax2.hist(gaps_res, bins=bins, alpha=0.7, color='#e74c3c', label='Resonant',
         edgecolor='darkred', linewidth=1)

ax2.set_xlabel('Count − Rank (gap)', fontsize=12)
ax2.set_ylabel('Frequency', fontsize=12)
ax2.set_title('Distribution of Rank-Count Gap', fontsize=14, fontweight='bold')
ax2.legend(fontsize=10)
ax2.axvline(x=0, color='black', linewidth=1, linestyle='--', alpha=0.5)

ax2.annotate('Gap = 0 always\nunder non-resonance', xy=(0, len(gaps_nr)*0.7),
            fontsize=9, ha='center', color='darkgreen', fontweight='bold')

plt.suptitle('Metastability Rank = Degeneracy Count Under Non-Resonance (n=6, 300 trials)',
             fontsize=13, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_rank_vs_count.png', dpi=150, bbox_inches='tight')
print("Saved viz_rank_vs_count.png")
