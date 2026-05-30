"""
Visualization 1: Bifurcation Diagram of the Logistic Map

Visualizes the bifurcation diagram of f(x) = r*x*(1-x) as the parameter r
varies from 2.5 to 4.0. This is the "landscape of déjà vu" — each horizontal
slice shows the periodic attractor at that parameter value. Period-doubling
cascades, chaos windows, and the famous period-3 window at r ≈ 3.83 are all
visible. The period-3 window is highlighted because, by Sharkovsky's theorem,
it implies chaos and the existence of periodic orbits of every order.
"""

import numpy as np
import matplotlib.pyplot as plt

# Parameters
r_min, r_max = 2.5, 4.0
n_r = 2000
transient = 1000
n_plot = 300

# Compute bifurcation diagram
r_vals = np.linspace(r_min, r_max, n_r)
all_r = []
all_x = []

for r in r_vals:
    x = 0.5
    for _ in range(transient):
        x = r * x * (1.0 - x)
    for _ in range(n_plot):
        x = r * x * (1.0 - x)
        all_r.append(r)
        all_x.append(x)

# Plot
fig, ax = plt.subplots(figsize=(14, 8))
ax.scatter(all_r, all_x, s=0.01, c='#1a1a2e', alpha=0.5, edgecolors='none')

# Highlight period-3 window
ax.axvspan(3.828, 3.857, alpha=0.15, color='crimson', label='Period-3 window (r ≈ 3.83)')
ax.axvline(x=3.8284, color='crimson', linestyle='--', alpha=0.5, linewidth=0.8)

# Annotations
ax.annotate('Period-3 Window\n(Sharkovsky: chaos guaranteed)',
            xy=(3.83, 0.15), fontsize=10, color='crimson',
            ha='center', style='italic')

ax.annotate('Period-doubling\ncascade begins',
            xy=(3.0, 0.67), xytext=(2.7, 0.3),
            arrowprops=dict(arrowstyle='->', color='navy'),
            fontsize=9, color='navy')

ax.annotate('Onset of chaos\n(r ≈ 3.57)',
            xy=(3.57, 0.5), xytext=(3.35, 0.15),
            arrowprops=dict(arrowstyle='->', color='darkgreen'),
            fontsize=9, color='darkgreen')

ax.set_xlabel('Parameter r (cognitive dynamics intensity)', fontsize=12)
ax.set_ylabel('Attractor states (cognitive equilibria)', fontsize=12)
ax.set_title('The Landscape of Déjà Vu: Bifurcation Diagram of Cognitive Dynamics',
             fontsize=14, fontweight='bold')
ax.legend(loc='upper left', fontsize=10)
ax.set_xlim(r_min, r_max)
ax.set_ylim(0, 1)

plt.tight_layout()
plt.savefig('bifurcation_diagram.png', dpi=200, bbox_inches='tight')
print("Saved bifurcation_diagram.png")
