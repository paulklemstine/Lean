import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

n = np.arange(1, 20)
fig, ax = plt.subplots(figsize=(10, 6))
colors = ['#2196F3', '#4CAF50', '#FF9800', '#F44336', '#9C27B0']
labels = ['G_const(5)', 'G_n', 'G_{n^2}', 'G_{n^3}', 'G_{2^n}']
bounds = [np.full_like(n, 5.0), n.astype(float), (n**2).astype(float), (n**3).astype(float), (2.0**n)]
for bound, label, color in zip(bounds, labels, colors):
    ax.semilogy(n, bound, '-o', color=color, label=label, markersize=3, linewidth=2)
ax.set_xlabel('Index i')
ax.set_ylabel('Growth bound (log scale)')
ax.set_title('Growth Filtration Hierarchy')
ax.legend()
ax.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig('growth_hierarchy.png', dpi=150)
print('Saved growth_hierarchy.png')