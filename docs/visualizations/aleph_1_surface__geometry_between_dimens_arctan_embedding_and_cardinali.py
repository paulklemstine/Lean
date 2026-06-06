import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

def arctan_embedding(x):
    return np.arctan(x) / np.pi + 0.5

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

x = np.linspace(-20, 20, 1000)
axes[0].plot(x, arctan_embedding(x), 'b-', linewidth=2)
axes[0].axhline(y=0, color='gray', linewidth=0.5, linestyle='--')
axes[0].axhline(y=1, color='gray', linewidth=0.5, linestyle='--')
axes[0].set_xlabel('x in R')
axes[0].set_ylabel('arctan(x)/pi + 1/2')
axes[0].set_title('Arctan Embedding')
axes[0].set_ylim(-0.05, 1.05)
axes[0].grid(True, alpha=0.3)

test_pts = np.array([-50, -10, -5, -2, -1, 0, 1, 2, 5, 10, 50])
embedded = arctan_embedding(test_pts)
axes[1].scatter(test_pts, embedded, c='red', s=80, zorder=5)
axes[1].plot(x, arctan_embedding(x), 'b-', alpha=0.3)
axes[1].set_title('Injectivity')
axes[1].grid(True, alpha=0.3)

cats = ['R^n', '[0,1]^N', 'R^{a1}', '[0,1]^{a1}']
heights = [1, 1, 2.5, 2.5]
colors = ['#2196F3', '#2196F3', '#F44336', '#4CAF50']
axes[2].bar(cats, heights, color=colors, edgecolor='black')
axes[2].axhline(y=1, color='orange', linewidth=2, linestyle='--')
axes[2].set_title('Cardinality Gap (CH)')

plt.tight_layout()
plt.savefig('arctan_embedding.png', dpi=150)
plt.close()