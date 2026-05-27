"""
Visualization: Laplacian Structure for Separated vs Non-Separated Subsets

This script visualizes the restricted Laplacian matrix structure,
showing how separation forces diagonal form. It compares a separated
subset (diagonal L_S) with a non-separated subset (non-diagonal L_S)
side by side.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors

# Create a graph (cycle C_6 with extra edges)
n = 6
adj = np.zeros((n, n), dtype=int)
edges = [(0,1), (1,2), (2,3), (3,4), (4,5), (5,0), (0,3)]
for i, j in edges:
    adj[i,j] = adj[j,i] = 1

def graph_laplacian(adj):
    return np.diag(np.sum(adj, axis=1)) - adj

def restricted_laplacian(L, S):
    idx = np.array(S)
    return L[np.ix_(idx, idx)]

def is_separated(adj, S):
    for i in range(len(S)):
        for j in range(i + 1, len(S)):
            if adj[S[i], S[j]] != 0:
                return False
    return True

L = graph_laplacian(adj)

# Separated subset
S_sep = [1, 3, 5]  # No two are adjacent
# Non-separated subset
S_nonsep = [0, 1, 3]  # 0 and 1 are adjacent

L_sep = restricted_laplacian(L, S_sep)
L_nonsep = restricted_laplacian(L, S_nonsep)

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Full Laplacian
cmap = plt.cm.RdBu_r
norm = mcolors.TwoSlopeNorm(vmin=-3, vcenter=0, vmax=4)

im0 = axes[0].imshow(L, cmap=cmap, norm=norm)
axes[0].set_title('Full Laplacian L(G)', fontsize=14, fontweight='bold')
axes[0].set_xlabel('Column index')
axes[0].set_ylabel('Row index')
for i in range(n):
    for j in range(n):
        axes[0].text(j, i, str(L[i,j]), ha='center', va='center', fontsize=12,
                    color='white' if abs(L[i,j]) > 1.5 else 'black')
axes[0].set_xticks(range(n))
axes[0].set_yticks(range(n))

# Separated L_S (diagonal)
k = len(S_sep)
im1 = axes[1].imshow(L_sep, cmap=cmap, norm=norm)
axes[1].set_title(f'L_S (Separated)\nS = {{{", ".join(str(s) for s in S_sep)}}}',
                  fontsize=14, fontweight='bold')
axes[1].set_xlabel('Column index')
for i in range(k):
    for j in range(k):
        axes[1].text(j, i, str(L_sep[i,j]), ha='center', va='center', fontsize=14,
                    color='white' if abs(L_sep[i,j]) > 1.5 else 'black',
                    fontweight='bold')
axes[1].set_xticks(range(k))
axes[1].set_yticks(range(k))
axes[1].set_xticklabels([f'v{s}' for s in S_sep])
axes[1].set_yticklabels([f'v{s}' for s in S_sep])

# Add diagonal indicator
for i in range(k):
    rect = plt.Rectangle((i-0.5, i-0.5), 1, 1, linewidth=2, 
                         edgecolor='lime', facecolor='none')
    axes[1].add_patch(rect)
axes[1].annotate('DIAGONAL\n(all off-diag = 0)', xy=(0.5, -0.15),
                xycoords='axes fraction', ha='center', fontsize=11,
                color='green', fontweight='bold')

# Non-separated L_S (not diagonal)
k2 = len(S_nonsep)
im2 = axes[2].imshow(L_nonsep, cmap=cmap, norm=norm)
axes[2].set_title(f'L_S (Non-separated)\nS = {{{", ".join(str(s) for s in S_nonsep)}}}',
                  fontsize=14, fontweight='bold')
axes[2].set_xlabel('Column index')
for i in range(k2):
    for j in range(k2):
        axes[2].text(j, i, str(L_nonsep[i,j]), ha='center', va='center', fontsize=14,
                    color='white' if abs(L_nonsep[i,j]) > 1.5 else 'black',
                    fontweight='bold')
axes[2].set_xticks(range(k2))
axes[2].set_yticks(range(k2))
axes[2].set_xticklabels([f'v{s}' for s in S_nonsep])
axes[2].set_yticklabels([f'v{s}' for s in S_nonsep])

# Highlight non-zero off-diagonal
for i in range(k2):
    for j in range(k2):
        if i != j and L_nonsep[i,j] != 0:
            rect = plt.Rectangle((j-0.5, i-0.5), 1, 1, linewidth=2,
                                edgecolor='red', facecolor='none')
            axes[2].add_patch(rect)
axes[2].annotate('NON-DIAGONAL\n(off-diag ≠ 0)', xy=(0.5, -0.15),
                xycoords='axes fraction', ha='center', fontsize=11,
                color='red', fontweight='bold')

plt.colorbar(im0, ax=axes, shrink=0.8, label='Matrix entry value')
plt.suptitle('Separation Forces Diagonal Structure in Restricted Laplacian',
            fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_laplacian_heatmap.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_laplacian_heatmap.png")
