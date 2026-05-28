"""
Visualization: Witness Gap Landscape
======================================

Shows how the gap W_trop - W_spec varies across different DPP kernels
and subset sizes, confirming the universal bound.

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
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    fig.suptitle('Witness Gap Landscape Across Random DPP Kernels', 
                 fontsize=14, fontweight='bold')
    
    n = 5
    num_trials = 30
    
    for panel_idx, (rank, title) in enumerate([
        (2, 'Low-rank (rank ≈ 2)'),
        (3, 'Medium-rank (rank ≈ 3)'),
        (5, 'Full-rank (rank ≈ 5)'),
    ]):
        ax = axes[panel_idx]
        
        all_sizes = []
        all_gaps = []
        all_ratios = []
        
        for trial in range(num_trials):
            np.random.seed(trial * 100 + rank)
            M = np.random.randn(n, rank)
            K = M @ M.T
            K = K / np.trace(K)
            p = dpp_polynomial(K)
            
            for size in range(1, 4):
                for A_tuple in combinations(range(n), size):
                    A = set(A_tuple)
                    ws = leaf_witness_spectral(p, A)
                    wt = tropical_leaf_witness(p, A)
                    gap = wt - ws
                    all_sizes.append(size + np.random.uniform(-0.15, 0.15))
                    all_gaps.append(gap)
                    if ws > 1e-10:
                        all_ratios.append(wt / ws)
        
        scatter = ax.scatter(all_sizes, all_gaps, alpha=0.3, s=8, 
                           c=all_gaps, cmap='RdYlGn', vmin=-0.1, 
                           vmax=max(all_gaps) * 0.5)
        ax.axhline(y=0, color='red', linestyle='--', linewidth=1.5, 
                   label='Zero line')
        ax.set_title(title, fontsize=11)
        ax.set_xlabel('|A| (subset size)')
        ax.set_ylabel('Gap (W_trop - W_spec)')
        ax.set_xticks([1, 2, 3])
        ax.legend(fontsize=8)
        
        min_gap = min(all_gaps)
        ax.text(0.02, 0.95, f'Min gap: {min_gap:.2e}',
                transform=ax.transAxes, fontsize=9, va='top',
                color='green' if min_gap >= -1e-10 else 'red',
                fontweight='bold')
    
    plt.tight_layout()
    plt.savefig('gap_landscape.png', dpi=150, bbox_inches='tight')
    print("Saved gap_landscape.png")


if __name__ == "__main__":
    main()
