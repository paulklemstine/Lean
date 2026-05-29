#!/usr/bin/env python3
"""
Visualization: Matroid Shadow Sequences

Compares shadow sequences across different matroid types,
showing how weighted and unweighted counts relate through
the weight ratio. Demonstrates the universality of log-concavity
across diverse combinatorial structures.
"""
import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')
import numpy as np
from itertools import combinations


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


def fano_bases():
    lines = [{0,1,2}, {0,3,4}, {0,5,6}, {1,3,5}, {1,4,6}, {2,3,6}, {2,4,5}]
    return [t for t in combinations(range(7), 3) if set(t) not in lines]


matroids = {
    'U_{2,4}': (list(combinations(range(4), 2)), 4, 2),
    'U_{2,5}': (list(combinations(range(5), 2)), 5, 2),
    'U_{3,6}': (list(combinations(range(6), 3)), 6, 3),
    'Fano': (fano_bases(), 7, 3),
    'U_{3,7}': (list(combinations(range(7), 3)), 7, 3),
    'U_{2,6}': (list(combinations(range(6), 2)), 6, 2),
}

fig, axes = plt.subplots(2, 3, figsize=(15, 9))
fig.suptitle('Shadow Sequences Across Matroids: Universal Log-Concavity',
             fontsize=14, fontweight='bold')

for idx, (name, (bases, n, rank)) in enumerate(matroids.items()):
    row, col = divmod(idx, 3)
    ax = axes[row][col]
    
    W, Sh = compute_shadow_profile(bases, n, rank)
    r = [W[k] / Sh[k] if Sh[k] > 0 else 0 for k in range(rank + 1)]
    ks = list(range(rank + 1))
    
    # Normalize for visualization
    W_norm = [w / max(W) for w in W]
    Sh_norm = [s / max(Sh) for s in Sh]
    r_norm = [rv / max(r) if max(r) > 0 else 0 for rv in r]
    
    ax.fill_between(ks, 0, W_norm, alpha=0.2, color='#2196F3')
    ax.fill_between(ks, 0, Sh_norm, alpha=0.2, color='#4CAF50')
    
    ax.plot(ks, W_norm, 'o-', color='#2196F3', linewidth=2, markersize=6, label='W_k (norm)')
    ax.plot(ks, Sh_norm, 's-', color='#4CAF50', linewidth=2, markersize=6, label='Sh_k (norm)')
    ax.plot(ks, r_norm, '^-', color='#FF9800', linewidth=2, markersize=6, label='r_k (norm)')
    
    # Check log-concavity
    w_lc = all(W[k]**2 >= W[k-1]*W[k+1] for k in range(1, rank))
    s_lc = all(Sh[k]**2 >= Sh[k-1]*Sh[k+1] for k in range(1, rank))
    
    status = f"W:{'✓' if w_lc else '✗'} Sh:{'✓' if s_lc else '✗'}"
    ax.set_title(f'{name}  [{status}]', fontsize=11, fontweight='bold')
    ax.set_xlabel('k')
    ax.set_ylabel('Normalized value')
    ax.legend(fontsize=7, loc='upper right')
    ax.grid(True, alpha=0.3)
    
    # Add actual values as text
    for k in ks:
        ax.annotate(f'{W[k]}', (k, W_norm[k]), textcoords="offset points",
                   xytext=(0, 8), ha='center', fontsize=7, color='#1565C0')
        ax.annotate(f'{Sh[k]}', (k, Sh_norm[k]), textcoords="offset points",
                   xytext=(0, -12), ha='center', fontsize=7, color='#2E7D32')

plt.tight_layout()
plt.savefig('viz_matroid_shadows.png', dpi=150, bbox_inches='tight')
print("Saved viz_matroid_shadows.png")
