import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

fig, ax = plt.subplots(figsize=(10, 6))
for w in [2, 3, 5, 10]:
    L = np.arange(1, 11)
    deep = (w + 1.0) ** L
    shallow = L * w + 1
    ax.semilogy(L, deep, 'o-', label=f'Deep (w+1)^L, w={w}', ms=5)
    ax.semilogy(L, shallow, 's--', label=f'Shallow Lw+1, w={w}', ms=4, alpha=0.5)
ax.set_xlabel('Depth L', fontsize=13)
ax.set_ylabel('Max Linear Regions', fontsize=13)
ax.set_title('Depth-Width Asymmetry: Deep Networks Win Exponentially', fontsize=14)
ax.legend(fontsize=9, ncol=2)
ax.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig('depth_width_asymmetry.png', dpi=150)
plt.close()