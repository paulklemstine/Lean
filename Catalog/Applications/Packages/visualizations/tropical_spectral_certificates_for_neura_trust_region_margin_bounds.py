"""
Visualization: Trust-Region Margin from Tropical Spectral Gap

Shows how the tropical spectral gap controls trust-region model improvement
bounds, connecting adversarial robustness to optimization convergence.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


fig, axes = plt.subplots(1, 2, figsize=(12, 5))

# Plot 1: Trust-region model curves for different gaps
s_range = np.linspace(0, 4, 300)
G = 2.0
alphas = [0.5, 1.0, 2.0, 5.0, 10.0]
cmap = plt.cm.viridis(np.linspace(0.2, 0.9, len(alphas)))

for alpha, color in zip(alphas, cmap):
    model = -G * s_range + 0.5 * alpha * s_range**2
    margin = -G**2 / (2 * alpha)
    s_star = G / alpha
    axes[0].plot(s_range, model, linewidth=2, color=color, label=f'γ={alpha}')
    axes[0].plot(s_star, margin, 'o', color=color, markersize=6)

axes[0].axhline(y=0, color='k', linewidth=0.5)
axes[0].set_xlabel('Step size s', fontsize=12)
axes[0].set_ylabel('Model improvement', fontsize=12)
axes[0].set_title(f'Trust-Region Model (G={G})', fontsize=13)
axes[0].legend(fontsize=10, title='Tropical gap γ')
axes[0].grid(True, alpha=0.3)
axes[0].set_ylim(-5, 15)

# Plot 2: Worst-case margin vs tropical gap
gaps = np.linspace(0.1, 10, 200)
G_values = [0.5, 1.0, 2.0, 5.0]
colors2 = ['#2196F3', '#4CAF50', '#FF9800', '#E91E63']

for G_val, color in zip(G_values, colors2):
    margins = -G_val**2 / (2 * gaps)
    axes[1].plot(gaps, margins, linewidth=2, color=color, label=f'G={G_val}')

axes[1].axhline(y=0, color='k', linewidth=0.5)
axes[1].set_xlabel('Tropical Spectral Gap γ', fontsize=12)
axes[1].set_ylabel('Worst-case margin -G²/(2γ)', fontsize=12)
axes[1].set_title('Trust-Region Margin Bound', fontsize=13)
axes[1].legend(fontsize=10)
axes[1].grid(True, alpha=0.3)
axes[1].set_ylim(-15, 1)

plt.tight_layout()
plt.savefig('viz_trust_region.png', dpi=150, bbox_inches='tight')
print("Saved viz_trust_region.png")
