import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

def minplus_matmul(A, B):
    n = A.shape[0]
    C = np.full((n,n), np.inf)
    for i in range(n):
        for j in range(n):
            for k in range(n):
                C[i,j] = min(C[i,j], A[i,k]+B[k,j])
    return C

INF = np.inf
A = np.array([[0,2,5],[INF,0,1],[3,INF,0]])

fig, axes = plt.subplots(1, 3, figsize=(14,4))
matrices = [A]
for _ in range(2):
    matrices.append(minplus_matmul(matrices[-1], A))

for idx, (ax, M, title) in enumerate(zip(axes, matrices, ['A (1-step)','A² (2-step)','A³ (3-step)'])):
    display = np.where(np.isinf(M), -1, M)
    im = ax.imshow(display, cmap='YlOrRd', vmin=0, vmax=8)
    for i in range(3):
        for j in range(3):
            val = '∞' if np.isinf(M[i,j]) else str(int(M[i,j]))
            ax.text(j, i, val, ha='center', va='center', fontsize=16, fontweight='bold')
    ax.set_title(title, fontsize=13)
    ax.set_xticks(range(3)); ax.set_yticks(range(3))

plt.suptitle('Tropical Matrix Powers: Min-Plus Shortest Paths', fontsize=14)
plt.tight_layout()
plt.savefig('tropical_shortest_paths.png', dpi=150)
print('Saved tropical_shortest_paths.png')