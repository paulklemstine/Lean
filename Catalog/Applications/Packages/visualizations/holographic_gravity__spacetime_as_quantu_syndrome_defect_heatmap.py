import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations

def holographic_S(X, n=4):
    k = len(X)
    return float(min(k, n - k))

n = 4
all_subsets = []
for r in range(n + 1):
    for s in combinations(range(n), r):
        all_subsets.append(frozenset(s))

S = {fs: holographic_S(fs) for fs in all_subsets}
m = len(all_subsets)
defects = np.zeros((m, m))
for i, X in enumerate(all_subsets):
    for j, Y in enumerate(all_subsets):
        defects[i, j] = S[X] + S[Y] - S[X & Y] - S[X | Y]

fig, ax = plt.subplots(figsize=(10, 8))
im = ax.imshow(defects, cmap='YlOrRd', aspect='auto')
ax.set_title('Syndrome Defect Matrix (4-site holographic profile)', fontsize=14)
ax.set_xlabel('Region Y')
ax.set_ylabel('Region X')
plt.colorbar(im, label='δ(X, Y)')
plt.tight_layout()
plt.savefig('syndrome_defect_heatmap.png', dpi=150)
plt.show()
