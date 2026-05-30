"""
Visualization: DPP Support Heatmap

Shows the principal minor values det(K_S) for all subsets S of a given size d,
arranged by subset index. The support (positive minors) is highlighted,
demonstrating that positive minors form a matroid-like structure.
"""
import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations


def random_psd_matrix(n, rank=None):
    if rank is None:
        rank = n
    B = np.random.randn(rank, n)
    return B.T @ B


def principal_minor(K, S):
    S_list = list(S)
    return np.linalg.det(K[np.ix_(S_list, S_list)])


np.random.seed(42)
n = 6
rank = 4
K = random_psd_matrix(n, rank)

fig, axes = plt.subplots(1, 4, figsize=(16, 4))
fig.suptitle('DPP Principal Minors by Subset Size\n(PSD kernel, n=6, rank=4)',
             fontsize=14, fontweight='bold')

for idx, d in enumerate([1, 2, 3, 4]):
    subsets = list(combinations(range(n), d))
    minors = [principal_minor(K, S) for S in subsets]

    colors = ['#2ecc71' if m > 1e-10 else '#e74c3c' for m in minors]

    ax = axes[idx]
    bars = ax.bar(range(len(subsets)), minors, color=colors, edgecolor='black',
                  linewidth=0.5, alpha=0.8)
    ax.set_title(f'd = {d}\n{sum(1 for m in minors if m > 1e-10)}/{len(subsets)} positive',
                 fontsize=11)
    ax.set_xlabel('Subset index')
    ax.set_ylabel('det(K_S)')
    ax.axhline(y=0, color='black', linewidth=0.5, linestyle='--')
    ax.set_xticks([])

plt.tight_layout()
plt.savefig('dpp_support_heatmap.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved dpp_support_heatmap.png")
