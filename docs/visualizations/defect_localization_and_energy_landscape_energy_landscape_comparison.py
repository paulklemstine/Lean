"""
Visualization: Energy Landscape of Tropical DiagExSlack Values

This script visualizes the "energy landscape" of a matrix — the sorted
collection of diagonal exchange slack values. It shows how a single
defect (the minimum) is isolated from the rest by a spectral gap,
illustrating the core phenomenon of defect localization.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

# ─── Inline functions (self-contained) ───────────────────────────────────────

def diag_ex_slack_matrix(W):
    diag = np.diag(W)
    return 2 * W - diag[:, np.newaxis] - diag[np.newaxis, :]

def mean_model(n, mu_diag, mu_off):
    M = np.full((n, n), mu_off)
    np.fill_diagonal(M, mu_diag)
    return M

def energy_landscape(W):
    n = W.shape[0]
    S = diag_ex_slack_matrix(W)
    pairs = [(i, j) for i in range(n) for j in range(n) if i != j]
    slacks = np.array([S[i, j] for i, j in pairs])
    sorted_slacks = np.sort(slacks)
    min_idx = np.argmin(slacks)
    return {
        'witness': pairs[min_idx],
        'sorted_values': sorted_slacks,
        'trop_margin': sorted_slacks[0],
        'spectral_gap': sorted_slacks[1] - sorted_slacks[0],
    }

# ─── Generate figure ────────────────────────────────────────────────────────

np.random.seed(2024)

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

for ax_idx, (n, c, title) in enumerate([
    (30, 0.5, 'Sub-critical (c=0.5)'),
    (30, 1.0, 'Critical (c=1.0)'),
    (30, 2.5, 'Super-critical (c=2.5)'),
]):
    ax = axes[ax_idx]
    mu_off = c * np.sqrt(np.log(n))
    W = mean_model(n, 0, mu_off) + np.random.randn(n, n)
    L = energy_landscape(W)
    vals = L['sorted_values']
    
    # Color: ground state red, first excited orange, rest blue
    colors = ['red'] + ['orange'] + ['steelblue'] * (len(vals) - 2)
    
    ax.bar(range(len(vals)), vals, color=colors, width=1.0, edgecolor='none', alpha=0.8)
    ax.axhline(y=vals[0], color='red', linestyle='--', alpha=0.5, linewidth=1)
    ax.axhline(y=vals[1], color='orange', linestyle='--', alpha=0.5, linewidth=1)
    
    # Annotate spectral gap
    gap = L['spectral_gap']
    mid_y = (vals[0] + vals[1]) / 2
    ax.annotate(f'Gap = {gap:.2f}', xy=(3, mid_y), fontsize=11,
                color='darkgreen', fontweight='bold',
                bbox=dict(boxstyle='round,pad=0.3', facecolor='lightgreen', alpha=0.7))
    
    ax.set_title(title, fontsize=13, fontweight='bold')
    ax.set_xlabel('Pair index (sorted)', fontsize=11)
    ax.set_ylabel('diagExSlack value', fontsize=11)
    ax.grid(True, alpha=0.2)

fig.suptitle('Energy Landscapes: Defect Localization in the Critical Window',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_energy_landscape.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: viz_energy_landscape.png")
