"""
Visualization: Drake Equation Expected Civilizations Heatmap

Shows how the expected number of civilizations E[N] = n × p varies
across different combinations of number of habitable planets (n)
and per-planet probability (p). The critical threshold E[N] = 1
divides the "alone" region from the "not alone" region.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as colors

# Parameter ranges (log scale)
log_n = np.linspace(8, 12, 200)  # 10^8 to 10^12 planets
log_p = np.linspace(-14, -6, 200)  # 10^-14 to 10^-6 probability

N, P = np.meshgrid(log_n, log_p)
log_E = N + P  # log10(E) = log10(n) + log10(p)

fig, ax = plt.subplots(1, 1, figsize=(10, 8))

# Heatmap
im = ax.pcolormesh(
    log_n, log_p, log_E,
    cmap='RdYlBu_r',
    shading='auto',
    vmin=-6, vmax=6
)

# Critical line: E[N] = 1 (log E = 0)
ax.contour(N, P, log_E, levels=[0], colors='white', linewidths=3, linestyles='--')
ax.contour(N, P, log_E, levels=[0], colors='black', linewidths=1.5, linestyles='--')

# Annotate regions
ax.text(9, -8, 'E[N] > 1\n"Not Alone"', fontsize=16, fontweight='bold',
        color='white', ha='center', va='center',
        bbox=dict(boxstyle='round,pad=0.3', facecolor='red', alpha=0.7))
ax.text(11, -13, 'E[N] < 1\n"Alone"', fontsize=16, fontweight='bold',
        color='black', ha='center', va='center',
        bbox=dict(boxstyle='round,pad=0.3', facecolor='lightblue', alpha=0.7))

# Mark conservative estimate
ax.plot(10, -11, 'w*', markersize=20, markeredgecolor='black', markeredgewidth=1.5)
ax.annotate('Conservative\nEstimate', xy=(10, -11), xytext=(10.5, -10),
            fontsize=11, fontweight='bold',
            arrowprops=dict(arrowstyle='->', color='black', lw=2),
            bbox=dict(boxstyle='round', facecolor='yellow', alpha=0.8))

# Labels
ax.set_xlabel('log₁₀(Number of Habitable Planets)', fontsize=14)
ax.set_ylabel('log₁₀(Per-Planet Probability)', fontsize=14)
ax.set_title('The Great Filter Dichotomy\nExpected Civilizations = n × p', fontsize=16, fontweight='bold')

cbar = fig.colorbar(im, ax=ax, label='log₁₀(Expected Civilizations)')
cbar.ax.axhline(y=0, color='black', linewidth=2, linestyle='--')
cbar.ax.text(0.5, 0, 'E=1', transform=cbar.ax.transAxes, fontsize=10,
             ha='center', va='bottom', fontweight='bold')

plt.tight_layout()
plt.savefig('viz_drake_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_drake_heatmap.png")
