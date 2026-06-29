import matplotlib.pyplot as plt
from typing import List

Matrix = List[List[int]]

def E8() -> Matrix:
    return [
        [2,-1,0,0,0,0,0,0],[-1,2,-1,0,0,0,0,0],[0,-1,2,-1,0,0,0,0],
        [0,0,-1,2,-1,0,0,0],[0,0,0,-1,2,-1,0,-1],[0,0,0,0,-1,2,-1,0],
        [0,0,0,0,0,-1,2,0],[0,0,0,0,-1,0,0,2]]

def direct_sum(G: Matrix, H: Matrix) -> Matrix:
    n, m = len(G), len(H)
    out = [[0]*(n+m) for _ in range(n+m)]
    for i in range(n):
        for j in range(n): out[i][j] = G[i][j]
    for i in range(m):
        for j in range(m): out[n+i][n+j] = H[i][j]
    return out

def plot_matrix(M: Matrix, title: str, ax) -> None:
    ax.imshow(M, cmap='coolwarm', vmin=-2, vmax=2)
    ax.set_title(title)
    for i in range(len(M)):
        for j in range(len(M)):
            if M[i][j] != 0:
                ax.text(j, i, str(M[i][j]), ha='center', va='center', fontsize=7)

fig, (a, b) = plt.subplots(1, 2, figsize=(12, 6))
plot_matrix(E8(), 'E8 (rank 8, det 1, even)', a)
plot_matrix(direct_sum(E8(), E8()), 'E8 + E8 (rank 16, det 1, even)', b)
plt.tight_layout(); plt.savefig('e8_heatmaps.png', dpi=150)
print('saved e8_heatmaps.png')
