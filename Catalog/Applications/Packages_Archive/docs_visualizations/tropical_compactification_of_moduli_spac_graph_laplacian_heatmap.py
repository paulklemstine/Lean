import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

def graph_laplacian(n, edges):
    L = np.zeros((n,n), dtype=int)
    for u,v in edges:
        L[u][v] = -1; L[v][u] = -1
        L[u][u] += 1; L[v][v] += 1
    return L

# Cycle graph C_6
n = 6
edges = [(i,(i+1)%n) for i in range(n)]
L = graph_laplacian(n, edges)

fig, ax = plt.subplots(figsize=(6,5))
im = ax.imshow(L, cmap='RdBu_r', vmin=-2, vmax=2)
for i in range(n):
    for j in range(n):
        ax.text(j, i, str(L[i,j]), ha='center', va='center', fontsize=14)
ax.set_title('Graph Laplacian of C₆', fontsize=14)
ax.set_xlabel('Column'); ax.set_ylabel('Row')
plt.colorbar(im, ax=ax)
plt.tight_layout()
plt.savefig('laplacian_heatmap.png', dpi=150)
print('Saved laplacian_heatmap.png')