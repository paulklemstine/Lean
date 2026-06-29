import numpy as np
import matplotlib.pyplot as plt
from scipy.cluster.hierarchy import linkage, dendrogram
from scipy.spatial.distance import squareform

def padic_val_int(p, n):
    if n == 0: return 30
    n, k = abs(n), 0
    while n % p == 0: n //= p; k += 1
    return k

def hdist(p, x, y):
    return 0.0 if x == y else p ** (-padic_val_int(p, x - y))

p, N = 2, 16
D = np.array([[hdist(p, x, y) for y in range(N)] for x in range(N)])
Z = linkage(squareform(D, checks=False), method='complete')
plt.figure(figsize=(8, 4))
dendrogram(Z, labels=[str(i) for i in range(N)])
plt.title(f'{p}-adic ultrametric tree on 0..{N-1}')
plt.ylabel('distance'); plt.tight_layout()
plt.savefig('padic_tree.png', dpi=150)
print('wrote padic_tree.png')
