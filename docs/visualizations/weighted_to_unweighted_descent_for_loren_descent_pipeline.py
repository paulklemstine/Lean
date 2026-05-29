#!/usr/bin/env python3
"""
Visualization: The Descent Pipeline

Visualizes how the descent inequality transforms weighted log-concavity
into unweighted log-concavity. Shows the three sequences W_k, r_k, S_k
for several matroid examples, highlighting log-concavity/convexity properties.
"""
import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')
import numpy as np
from itertools import combinations


def descending_factorial(x, k):
    result = 1
    for i in range(k):
        result *= (x - i)
    return result


def compute_shadow_profile(bases, n, max_k):
    """Compute W_k and Sh_k for a matroid given by its bases."""
    def derivative_support(support, gamma):
        result = set()
        for monomial in support:
            remaining = list(monomial)
            valid = True
            for v in gamma:
                if v in remaining:
                    remaining.remove(v)
                else:
                    valid = False
                    break
            if valid:
                result.add(tuple(sorted(remaining)))
        return result
    
    support = set(bases)
    W, Sh = [], []
    for k in range(max_k + 1):
        w, s = 0, 0
        for gamma in combinations(range(n), k):
            ds = derivative_support(support, gamma)
            w += len(ds)
            if len(ds) > 0:
                s += 1
        W.append(w)
        Sh.append(s)
    return W, Sh


# Compute profiles for several matroids
matroids = {
    'U_{2,5}': (list(combinations(range(5), 2)), 5, 2),
    'U_{3,6}': (list(combinations(range(6), 3)), 6, 3),
    'U_{3,7}': (list(combinations(range(7), 3)), 7, 3),
}

fig, axes = plt.subplots(2, 3, figsize=(14, 8))
fig.suptitle('The Descent Pipeline: From Weighted to Unweighted Log-Concavity', 
             fontsize=14, fontweight='bold')

for idx, (name, (bases, n, rank)) in enumerate(matroids.items()):
    W, Sh = compute_shadow_profile(bases, n, rank)
    r = [W[k] / Sh[k] if Sh[k] > 0 else 0 for k in range(rank + 1)]
    ks = list(range(rank + 1))
    
    # Top row: sequences
    ax = axes[0][idx]
    ax.plot(ks, W, 'o-', color='#2196F3', linewidth=2, markersize=8, label='W_k (weighted)')
    ax.plot(ks, Sh, 's-', color='#4CAF50', linewidth=2, markersize=8, label='Sh_k (unweighted)')
    ax.set_title(f'{name}', fontsize=12, fontweight='bold')
    ax.set_xlabel('k')
    ax.set_ylabel('Count')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)
    
    # Bottom row: log-concavity ratios
    ax2 = axes[1][idx]
    
    # Log-concavity ratio for W: W_k^2 / (W_{k-1} * W_{k+1})
    w_ratios = []
    s_ratios = []
    r_ratios = []
    k_inner = []
    for k in range(1, rank):
        k_inner.append(k)
        w_ratios.append(W[k]**2 / (W[k-1] * W[k+1]) if W[k-1] * W[k+1] > 0 else float('inf'))
        s_ratios.append(Sh[k]**2 / (Sh[k-1] * Sh[k+1]) if Sh[k-1] * Sh[k+1] > 0 else float('inf'))
        r_ratios.append(r[k]**2 / (r[k-1] * r[k+1]) if r[k-1] * r[k+1] > 0 else 0)
    
    if k_inner:
        x_pos = np.arange(len(k_inner))
        width = 0.25
        ax2.bar(x_pos - width, w_ratios, width, color='#2196F3', alpha=0.8, label='W: a²/(a₋a₊)')
        ax2.bar(x_pos, s_ratios, width, color='#4CAF50', alpha=0.8, label='Sh: a²/(a₋a₊)')
        ax2.bar(x_pos + width, r_ratios, width, color='#FF9800', alpha=0.8, label='r: a²/(a₋a₊)')
        ax2.axhline(y=1, color='red', linestyle='--', linewidth=1.5, label='Threshold = 1')
        ax2.set_xticks(x_pos)
        ax2.set_xticklabels([f'k={k}' for k in k_inner])
        ax2.set_ylabel('Ratio a_k²/(a_{k-1}·a_{k+1})')
        ax2.legend(fontsize=7)
        ax2.grid(True, alpha=0.3)
        ax2.set_title('Log-concavity ratios (≥1 = log-concave)', fontsize=10)

plt.tight_layout()
plt.savefig('viz_descent_pipeline.png', dpi=150, bbox_inches='tight')
print("Saved viz_descent_pipeline.png")
