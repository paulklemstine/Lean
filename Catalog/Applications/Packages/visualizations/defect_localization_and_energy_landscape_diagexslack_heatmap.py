"""
Visualization: DiagExSlack Heatmap and Defect Localization

This script creates a heatmap of the diagExSlack matrix, showing
how the minimum (defect) is localized at a single entry. The witness
pair is highlighted with a marker.
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

# ─── Generate figure ────────────────────────────────────────────────────────

np.random.seed(123)

fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

for ax_idx, c in enumerate([0.5, 1.5, 3.0]):
    ax = axes[ax_idx]
    n = 20
    mu_off = c * np.sqrt(np.log(n))
    W = mean_model(n, 0, mu_off) + np.random.randn(n, n)
    S = diag_ex_slack_matrix(W)
    
    # Mask diagonal
    S_display = S.copy()
    np.fill_diagonal(S_display, np.nan)
    
    # Find witness
    S_offdiag = S.copy()
    np.fill_diagonal(S_offdiag, np.inf)
    witness = np.unravel_index(np.argmin(S_offdiag), S.shape)
    
    im = ax.imshow(S_display, cmap='RdYlBu_r', aspect='equal')
    plt.colorbar(im, ax=ax, shrink=0.8, label='diagExSlack')
    
    # Mark witness
    ax.plot(witness[1], witness[0], 'k*', markersize=20, markeredgewidth=2,
            markeredgecolor='white')
    ax.plot(witness[1], witness[0], 'r*', markersize=15)
    
    ax.set_title(f'c = {c} ({"sub" if c < 1 else "super"}-critical)',
                 fontsize=13, fontweight='bold')
    ax.set_xlabel('Column j', fontsize=11)
    ax.set_ylabel('Row i', fontsize=11)
    
    # Add text with gap info
    S_sorted = np.sort(S_offdiag.flatten())
    gap = S_sorted[1] - S_sorted[0]
    ax.text(0.02, 0.98, f'Gap={gap:.2f}\nWitness={witness}',
            transform=ax.transAxes, fontsize=9,
            verticalalignment='top',
            bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))

fig.suptitle('DiagExSlack Heatmaps: Defect Localization (★ = witness)',
             fontsize=15, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_heatmap.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: viz_heatmap.png")
