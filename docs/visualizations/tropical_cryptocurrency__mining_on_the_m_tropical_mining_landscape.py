"""
Visualization: Tropical Mining Landscape

Visualizes the 2D tropical hash landscape for k=2 (two message components).
Shows how TSHA(m, h) = min(m_1 + h_1, m_2 + h_2) creates a piecewise-linear
landscape, and how the mining target defines a feasibility region.

The key insight: the hash landscape is divided by a diagonal line where
m_1 + h_1 = m_2 + h_2, creating two linear regions. Mining solutions
(where hash ≤ target) form a wedge-shaped region — a tropical halfspace.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors


def tsha_2d(m1: np.ndarray, m2: np.ndarray, h1: float, h2: float) -> np.ndarray:
    """TSHA for k=2: min(m1+h1, m2+h2)"""
    return np.minimum(m1 + h1, m2 + h2)


fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Parameters
h1, h2 = 3.0, 7.0
target = 5.0

m1_range = np.linspace(-15, 15, 300)
m2_range = np.linspace(-15, 15, 300)
M1, M2 = np.meshgrid(m1_range, m2_range)

# Hash landscape
Z = tsha_2d(M1, M2, h1, h2)

# Panel 1: Hash landscape as heatmap
ax1 = axes[0]
im = ax1.contourf(M1, M2, Z, levels=30, cmap='viridis')
plt.colorbar(im, ax=ax1, label='TSHA(m, h)')
# Diagonal boundary where m1+h1 = m2+h2
ax1.plot(m1_range, m1_range + (h1 - h2), 'w--', linewidth=2, 
         label=f'm₁+{h1}=m₂+{h2}')
ax1.set_xlabel('m₁')
ax1.set_ylabel('m₂')
ax1.set_title('Tropical Hash Landscape')
ax1.legend(loc='upper left', fontsize=8)

# Panel 2: Mining feasibility region
ax2 = axes[1]
feasible = Z <= target
ax2.contourf(M1, M2, feasible.astype(float), levels=[0, 0.5, 1],
             colors=['#ffcccc', '#66cc66'], alpha=0.7)
ax2.contour(M1, M2, Z, levels=[target], colors='red', linewidths=2)
ax2.plot(m1_range, m1_range + (h1 - h2), 'k--', linewidth=1, alpha=0.5)
ax2.set_xlabel('m₁')
ax2.set_ylabel('m₂')
ax2.set_title(f'Mining Region (target ≤ {target})')
ax2.text(-12, 12, 'Valid\nnonces', fontsize=12, color='darkgreen', fontweight='bold')
ax2.text(8, -8, 'Invalid', fontsize=12, color='darkred', fontweight='bold')

# Panel 3: Multiple difficulty levels
ax3 = axes[2]
targets = [-5, 0, 5, 10]
colors = ['#d62728', '#ff7f0e', '#2ca02c', '#1f77b4']
for t, c in zip(targets, colors):
    ax3.contour(M1, M2, Z, levels=[t], colors=[c], linewidths=2)
    ax3.contourf(M1, M2, (Z <= t).astype(float), levels=[0.5, 1],
                 colors=[c], alpha=0.15)

ax3.set_xlabel('m₁')
ax3.set_ylabel('m₂')
ax3.set_title('Difficulty Levels')
# Custom legend
from matplotlib.lines import Line2D
legend_elements = [Line2D([0], [0], color=c, linewidth=2, label=f'target={t}')
                   for t, c in zip(targets, colors)]
ax3.legend(handles=legend_elements, loc='upper left', fontsize=8)

plt.suptitle('Tropical Cryptocurrency: Mining on the Min-Plus Semiring', 
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_mining_landscape.png', dpi=150, bbox_inches='tight')
print("Saved viz_mining_landscape.png")
