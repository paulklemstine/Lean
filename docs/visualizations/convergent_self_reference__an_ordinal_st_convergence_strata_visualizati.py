import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

N = 8
colors = plt.cm.viridis(np.linspace(0.1, 0.9, N))

fig, ax = plt.subplots(figsize=(10, 6))
for i in range(N):
    conv_idx = i + 1
    bar = ax.barh(i, conv_idx, color=colors[i], edgecolor='white', height=0.7)
    ax.text(conv_idx + 0.1, i, f'Stratum {conv_idx}', va='center', fontsize=10)

ax.set_yticks(range(N))
ax.set_yticklabels([f'P{i}' for i in range(N)])
ax.set_xlabel('Convergence Index', fontsize=12)
ax.set_title('Convergence Stratification: Chain of Implications', fontsize=14)
ax.invert_yaxis()
plt.tight_layout()
plt.savefig('strata.png', dpi=150)
plt.show()
