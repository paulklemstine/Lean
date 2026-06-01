import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
fig, ax = plt.subplots(figsize=(10, 6))
N_values = np.arange(2, 51)
for m in [2, 3, 4, 5, 10]:
    max_levels = [N * (m - 1) / m for N in N_values]
    ax.plot(N_values, max_levels, linewidth=2, label=f'm = {m} worlds')
ax.set_xlabel('Universe size N', fontsize=12)
ax.set_ylabel('Max darkness level k', fontsize=12)
ax.set_title('Dark Inequality: k·m ≤ N·(m-1)', fontsize=14, fontweight='bold')
ax.legend(fontsize=11); ax.grid(True, alpha=0.3)
plt.tight_layout(); plt.savefig('dark_inequality.png', dpi=150); plt.close()