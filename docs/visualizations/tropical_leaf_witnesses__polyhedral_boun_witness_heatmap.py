"""
Visualization: Tropical vs Spectral Witness Heatmap
====================================================

Visualizes the gap between tropical leaf witnesses and spectral witnesses
across all subsets of a DPP kernel, organized by subset size.
The heatmap confirms the main theorem: W_trop ≥ W_spec everywhere.

Uses matplotlib to produce a static PNG.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations


# --- Self-contained polynomial engine ---
class MvPoly:
    def __init__(self, n, coeffs=None):
        self.n = n
        self.coeffs = {k: v for k, v in (coeffs or {}).items() if abs(v) > 1e-15}
    def pderiv(self, var):
        new = {}
        for exp, c in self.coeffs.items():
            if exp[var] > 0:
                ne = list(exp); nc = c * exp[var]; ne[var] -= 1; ne = tuple(ne)
                new[ne] = new.get(ne, 0.0) + nc
        return MvPoly(self.n, new)
    def eval_ones(self):
        return sum(self.coeffs.values())
    def coeff_abs_sum(self):
        return sum(abs(c) for c in self.coeffs.values())

def derivative_leaf(p, A):
    result = p
    for i in range(p.n):
        if i not in A:
            result = result.pderiv(i)
    return result

def tropical_leaf_witness(p, A):
    leaf = derivative_leaf(p, A)
    return sum(leaf.pderiv(a).pderiv(a).coeff_abs_sum() for a in A)

def leaf_witness_spectral(p, A):
    leaf = derivative_leaf(p, A)
    tr = sum(leaf.pderiv(a).pderiv(a).eval_ones() for a in A)
    return max(tr, 0.0)

def dpp_polynomial(K):
    n = K.shape[0]
    coeffs = {}
    for sz in range(n + 1):
        for S in combinations(range(n), sz):
            det_v = float(np.linalg.det(K[np.ix_(list(S), list(S))])) if S else 1.0
            if abs(det_v) > 1e-15:
                coeffs[tuple(1 if i in S else 0 for i in range(n))] = det_v
    return MvPoly(n, coeffs)
# --- End polynomial engine ---


def main():
    np.random.seed(42)
    n = 6
    M = np.random.randn(n, 4)
    K = M @ M.T
    K = K / np.trace(K)
    
    p = dpp_polynomial(K)
    
    # Collect data for all subsets of sizes 1..4
    data_by_size = {}
    for size in range(1, 5):
        subsets = list(combinations(range(n), size))
        specs = []
        trops = []
        labels = []
        for A_tuple in subsets:
            A = set(A_tuple)
            ws = leaf_witness_spectral(p, A)
            wt = tropical_leaf_witness(p, A)
            specs.append(ws)
            trops.append(wt)
            labels.append(str(A_tuple))
        data_by_size[size] = (labels, specs, trops)
    
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Tropical vs Spectral Leaf Witnesses\n(DPP Kernel, n=6)', 
                 fontsize=14, fontweight='bold')
    
    for idx, size in enumerate([1, 2, 3, 4]):
        ax = axes[idx // 2][idx % 2]
        labels, specs, trops = data_by_size[size]
        gaps = [t - s for s, t in zip(specs, trops)]
        
        x = np.arange(len(labels))
        width = 0.35
        
        bars1 = ax.bar(x - width/2, specs, width, label='Spectral W', 
                       color='#2196F3', alpha=0.8)
        bars2 = ax.bar(x + width/2, trops, width, label='Tropical W', 
                       color='#FF9800', alpha=0.8)
        
        ax.set_title(f'|A| = {size} ({len(labels)} subsets)', fontsize=11)
        ax.set_ylabel('Witness Value')
        ax.legend(fontsize=8)
        ax.set_xticks(x)
        
        if len(labels) <= 15:
            ax.set_xticklabels(labels, rotation=45, ha='right', fontsize=6)
        else:
            ax.set_xticklabels(['' for _ in labels])
            ax.set_xlabel(f'{len(labels)} subsets (labels omitted)')
        
        # Highlight: all gaps ≥ 0
        all_nonneg = all(g >= -1e-10 for g in gaps)
        color = '#4CAF50' if all_nonneg else '#F44336'
        ax.text(0.98, 0.95, f'Gap ≥ 0: {"✓" if all_nonneg else "✗"}',
                transform=ax.transAxes, ha='right', va='top',
                fontsize=10, color=color, fontweight='bold',
                bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))
    
    plt.tight_layout()
    plt.savefig('witness_heatmap.png', dpi=150, bbox_inches='tight')
    print("Saved witness_heatmap.png")


if __name__ == "__main__":
    main()
