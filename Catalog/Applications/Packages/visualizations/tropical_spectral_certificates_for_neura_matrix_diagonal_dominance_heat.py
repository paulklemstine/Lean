"""
Visualization: Matrix Diagonal Dominance Heatmap

Shows the structure of diagonally dominant matrices and how the tropical
spectral gap relates to the visual pattern of diagonal vs off-diagonal entries.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def tropical_spectral_gap(Q):
    n = Q.shape[0]
    return min(Q[i, i] - sum(abs(Q[i, j]) for j in range(n) if j != i) for i in range(n))


def generate_diag_dominant_matrix(n, gap, seed=42):
    rng = np.random.RandomState(seed)
    Q = 0.5 * rng.randn(n, n)
    Q = (Q + Q.T) / 2
    for i in range(n):
        off_sum = sum(abs(Q[i, j]) for j in range(n) if j != i)
        Q[i, i] = off_sum + gap
    return Q


fig, axes = plt.subplots(2, 3, figsize=(14, 9))

gaps = [0.5, 2.0, 5.0, 0.0, -1.0, 10.0]
titles = ['γ = 0.5 (weak)', 'γ = 2.0 (moderate)', 'γ = 5.0 (strong)',
          'γ ≈ 0 (borderline)', 'γ < 0 (not dominant)', 'γ = 10 (very strong)']

for idx, (gap, title) in enumerate(zip(gaps, titles)):
    ax = axes[idx // 3, idx % 3]
    n = 8

    if gap >= 0:
        Q = generate_diag_dominant_matrix(n, gap, seed=42 + idx)
    else:
        rng = np.random.RandomState(42 + idx)
        Q = 2.0 * rng.randn(n, n)
        Q = (Q + Q.T) / 2
        # Don't enforce diagonal dominance

    actual_gap = tropical_spectral_gap(Q)
    eigvals = np.linalg.eigvalsh(Q)
    lam_min = eigvals.min()

    im = ax.imshow(Q, cmap='RdBu_r', aspect='equal',
                   vmin=-np.abs(Q).max(), vmax=np.abs(Q).max())
    ax.set_title(f'{title}\nγ={actual_gap:.2f}, λ_min={lam_min:.2f}', fontsize=10)
    ax.set_xticks([])
    ax.set_yticks([])

    # Highlight diagonal
    for i in range(n):
        ax.add_patch(plt.Rectangle((i-0.5, i-0.5), 1, 1,
                     fill=False, edgecolor='black', linewidth=2))

    plt.colorbar(im, ax=ax, shrink=0.8)

plt.suptitle('Matrix Structure: Tropical Spectral Gap Visualization\n'
             '(Black boxes = diagonal entries; gap = diagonal excess over off-diagonal sum)',
             fontsize=13, y=1.02)
plt.tight_layout()
plt.savefig('viz_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_heatmap.png")
