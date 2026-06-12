import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

enum = np.array([
    [1, 0, 1, 0, 1, 0, 1],
    [0, 1, 0, 1, 0, 1, 0],
    [1, 1, 0, 0, 1, 1, 0],
    [0, 0, 1, 1, 0, 0, 1],
    [1, 0, 0, 1, 0, 1, 0],
    [0, 1, 1, 0, 1, 0, 1],
    [1, 1, 0, 1, 0, 1, 1],
])
n = len(enum)
diag = np.array([enum[i, i] for i in range(n)])
anti = 1 - diag

fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(8, 6), height_ratios=[7, 1], gridspec_kw={'hspace': 0.3})

ax1.imshow(enum, cmap='RdYlGn', aspect='equal', vmin=0, vmax=1)
for i in range(n):
    for j in range(n):
        color = 'white' if i == j else 'black'
        weight = 'bold' if i == j else 'normal'
        ax1.text(j, i, str(enum[i, j]), ha='center', va='center', color=color, fontweight=weight, fontsize=12)
    ax1.add_patch(plt.Rectangle((i-0.5, i-0.5), 1, 1, fill=False, edgecolor='blue', linewidth=2))
ax1.set_title('Enumeration Matrix (diagonal highlighted in blue)', fontsize=14)
ax1.set_xlabel('Position')
ax1.set_ylabel('Predicate index')

ax2.imshow(anti.reshape(1, -1), cmap='RdYlGn', aspect='equal', vmin=0, vmax=1)
for j in range(n):
    ax2.text(j, 0, str(anti[j]), ha='center', va='center', color='black', fontweight='bold', fontsize=12)
ax2.set_title('Anti-diagonal (differs from every row at its index)', fontsize=12)
ax2.set_yticks([])
ax2.set_xlabel('Position')

plt.savefig('diagonal_heatmap.png', dpi=150, bbox_inches='tight')
print('Saved diagonal_heatmap.png')