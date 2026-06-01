import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np

np.random.seed(42)
n = 10
matrix = np.random.randint(0, 2, size=(n, n))
antidiag = np.array([1 - matrix[i, i] for i in range(n)])

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6), gridspec_kw={'width_ratios': [3, 1]})
cmap = plt.cm.RdYlGn
im = ax1.imshow(matrix, cmap=cmap, vmin=0, vmax=1, aspect='equal')
for i in range(n):
    rect = patches.Rectangle((i-0.5, i-0.5), 1, 1, linewidth=3, edgecolor='blue', facecolor='none', linestyle='--')
    ax1.add_patch(rect)
    ax1.text(i, i, str(matrix[i,i]), ha='center', va='center', fontsize=12, fontweight='bold', color='blue')
for i in range(n):
    for j in range(n):
        if i != j:
            ax1.text(j, i, str(matrix[i,j]), ha='center', va='center', fontsize=9, color='gray')
ax1.set_xlabel('Input n'); ax1.set_ylabel('Program e')
ax1.set_title('Boolean Matrix with Diagonal Highlighted')
ax1.set_xticks(range(n)); ax1.set_yticks(range(n))
antidiag_2d = antidiag.reshape(-1, 1)
ax2.imshow(antidiag_2d, cmap=cmap, vmin=0, vmax=1, aspect=0.3)
for i in range(n):
    ax2.text(0, i, str(antidiag[i]), ha='center', va='center', fontsize=12, fontweight='bold', color='white')
ax2.set_title('Anti-diagonal'); ax2.set_xticks([]); ax2.set_yticks(range(n))
plt.suptitle('The Diagonal Argument', fontsize=14, fontweight='bold')
plt.tight_layout(); plt.savefig('diagonal_argument.png', dpi=150, bbox_inches='tight'); plt.close()