import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

L_base = 50.0
margin = 1.0
k_values = np.arange(0, 31)
graphs = [('Path-like (c=0.95)', 0.95, '#e74c3c'), ('Sparse (c=0.80)', 0.80, '#e67e22'), ('Moderate (c=0.60)', 0.60, '#2ecc71'), ('Dense (c=0.30)', 0.30, '#3498db'), ('Very dense (c=0.10)', 0.10, '#9b59b6')]
fig, axes = plt.subplots(1, 2, figsize=(14, 6))
for label, c, color in graphs:
    lip = [c**k * L_base for k in k_values]
    rad = [margin/(c**k * L_base) if c**k * L_base > 0 else float('inf') for k in k_values]
    axes[0].semilogy(k_values, lip, '-o', color=color, label=label, markersize=3, linewidth=2)
    axes[1].semilogy(k_values, rad, '-s', color=color, label=label, markersize=3, linewidth=2)
axes[0].set_xlabel('Smoothing Iterations'); axes[0].set_ylabel('Effective Lipschitz'); axes[0].set_title('Lipschitz Decay'); axes[0].legend(); axes[0].grid(True, alpha=0.3)
axes[1].set_xlabel('Smoothing Iterations'); axes[1].set_ylabel('Certified Radius'); axes[1].set_title('Radius Growth'); axes[1].legend(); axes[1].grid(True, alpha=0.3)
plt.tight_layout(); plt.savefig('spectral_robustness_plot.png', dpi=150); plt.close(); print('Saved spectral_robustness_plot.png')