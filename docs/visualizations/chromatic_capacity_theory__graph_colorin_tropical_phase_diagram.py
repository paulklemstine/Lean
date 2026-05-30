"""
Visualization: Tropical Chromatic Phase Diagram

Visualizes the tropical chromatic value T(n,k) = k - n + 1, showing the
phase transition between colorable and non-colorable regimes. The tropical
semiring reveals the sharp threshold structure of graph coloring.
"""

import numpy as np
import matplotlib.pyplot as plt


fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: Tropical phase diagram
ax1 = axes[0]
n_vals = np.arange(1, 16)
k_vals = np.arange(0, 21)
N, K = np.meshgrid(n_vals, k_vals)
T = K - N + 1

# Color by sign: positive (colorable), zero (threshold), negative (not colorable)
cmap = plt.cm.RdBu
im = ax1.contourf(N, K, T, levels=np.arange(-14, 16, 1), cmap=cmap, alpha=0.8)
ax1.contour(N, K, T, levels=[0], colors='black', linewidths=3)

plt.colorbar(im, ax=ax1, label='Tropical value $T(n,k) = k - n + 1$')
ax1.set_xlabel('Graph size $n$', fontsize=13)
ax1.set_ylabel('Number of colors $k$', fontsize=13)
ax1.set_title('Tropical Phase Diagram', fontsize=14, fontweight='bold')

# Add phase labels
ax1.text(3, 15, 'COLORABLE\n$T > 0$', fontsize=14, fontweight='bold',
         ha='center', va='center', color='darkblue',
         bbox=dict(boxstyle='round', facecolor='lightblue', alpha=0.7))
ax1.text(12, 5, 'NOT\nCOLORABLE\n$T < 0$', fontsize=14, fontweight='bold',
         ha='center', va='center', color='darkred',
         bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.7))

# Draw threshold line k = n - 1
ax1.plot(n_vals, n_vals - 1, 'k-', linewidth=3, label='Threshold: $k = n-1$')
ax1.legend(fontsize=11, loc='upper left')

# Right: Capacity scaling
ax2 = axes[1]
k_max = 100
k_range = np.arange(1, k_max + 1)

for n in [1, 2, 3, 5, 10, 20]:
    capacities = []
    for k in k_range:
        # Compute k^{(n)}
        df = 1
        for i in range(n):
            df *= max(0, k - i)
        if df > 0 and n > 0:
            capacities.append(np.log(df) / n)
        else:
            capacities.append(np.nan)
    
    ax2.plot(k_range, capacities, linewidth=2, label=f'$n = {n}$')

# Theoretical maximum
ax2.plot(k_range, np.log(k_range), 'k--', linewidth=1.5, alpha=0.5, label='$\\ln(k)$')

ax2.set_xlabel('Number of colors $k$', fontsize=13)
ax2.set_ylabel('Capacity $C(K_n, k)$ (nats)', fontsize=13)
ax2.set_title('Chromatic Capacity Convergence', fontsize=14, fontweight='bold')
ax2.legend(fontsize=10, ncol=2)
ax2.grid(True, alpha=0.3)
ax2.set_xlim(0, k_max)
ax2.set_ylim(0, 5)

plt.tight_layout()
plt.savefig('tropical_phase_diagram.png', dpi=150, bbox_inches='tight')
print("Saved: tropical_phase_diagram.png")
