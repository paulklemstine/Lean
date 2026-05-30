"""
Visualization 3: The Tropical Bridge - Connecting Tilings to Tropical Geometry

Visualizes the cross-domain bridge between:
- Perron-Frobenius eigenvalues (substitution matrix theory)
- Topological entropy (dynamical systems)
- Tropical eigenvalues (max-plus algebra)

The key theorem: log(λ_PF) = λ_trop(log M) = topological entropy
This identity connects three mathematical domains through a single number.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib
import matplotlib.patches as mpatches

matplotlib.rcParams.update({
    'font.size': 12,
    'axes.labelsize': 14,
    'axes.titlesize': 15,
})

fig = plt.figure(figsize=(14, 7))

# ---- Left panel: The bridge diagram ----
ax1 = fig.add_subplot(121)

# Three domains as circles
circle_radius = 0.25
domains = {
    'Tiling Theory': (0.5, 0.85),
    'Tropical\nGeometry': (0.15, 0.25),
    'Dynamical\nSystems': (0.85, 0.25),
}
colors = {'Tiling Theory': '#3498db', 'Tropical\nGeometry': '#2ecc71',
          'Dynamical\nSystems': '#e74c3c'}
values = {
    'Tiling Theory': 'Perron root\nσ = 2 + √3',
    'Tropical\nGeometry': 'Tropical eigenvalue\nλ_trop = log σ',
    'Dynamical\nSystems': 'Entropy\nh = log σ',
}

for name, (cx, cy) in domains.items():
    circle = plt.Circle((cx, cy), circle_radius, color=colors[name],
                        alpha=0.3, transform=ax1.transAxes)
    ax1.add_patch(circle)
    ax1.text(cx, cy + 0.02, name, transform=ax1.transAxes,
             ha='center', va='center', fontsize=11, fontweight='bold')
    ax1.text(cx, cy - 0.12, values[name], transform=ax1.transAxes,
             ha='center', va='center', fontsize=9, style='italic')

# Draw connecting arrows
arrow_style = dict(arrowstyle='<->', color='gray', lw=2)
ax1.annotate('', xy=(0.35, 0.7), xytext=(0.22, 0.45),
             xycoords='axes fraction', textcoords='axes fraction',
             arrowprops=arrow_style)
ax1.annotate('', xy=(0.65, 0.7), xytext=(0.78, 0.45),
             xycoords='axes fraction', textcoords='axes fraction',
             arrowprops=arrow_style)
ax1.annotate('', xy=(0.35, 0.25), xytext=(0.65, 0.25),
             xycoords='axes fraction', textcoords='axes fraction',
             arrowprops=arrow_style)

# Bridge labels
ax1.text(0.22, 0.60, 'log', transform=ax1.transAxes,
         ha='center', va='center', fontsize=12, fontweight='bold',
         color='#2c3e50', rotation=55)
ax1.text(0.78, 0.60, 'log', transform=ax1.transAxes,
         ha='center', va='center', fontsize=12, fontweight='bold',
         color='#2c3e50', rotation=-55)
ax1.text(0.5, 0.3, 'identity', transform=ax1.transAxes,
         ha='center', va='center', fontsize=11, fontweight='bold',
         color='#2c3e50')

ax1.set_xlim(-0.1, 1.1)
ax1.set_ylim(-0.05, 1.15)
ax1.set_aspect('equal')
ax1.set_title('The Tropical Bridge\nThree Domains, One Number', fontsize=14)
ax1.axis('off')

# Central equation
ax1.text(0.5, -0.02, 'log(σ) = λ_trop(log M) = h = 1.317...',
         transform=ax1.transAxes, ha='center', va='center',
         fontsize=13, fontweight='bold', color='#2c3e50',
         bbox=dict(boxstyle='round,pad=0.5', facecolor='lightyellow',
                   edgecolor='orange', alpha=0.9))

# ---- Right panel: Entropy across the hat spectrum ----
ax2 = fig.add_subplot(122)

t_vals = np.linspace(0, 1, 500)
c_vals = 4 - 2 * t_vals * (1 - t_vals)
delta_vals = c_vals**2 - 4
sigma_vals = (c_vals + np.sqrt(delta_vals)) / 2
entropy_vals = np.log(sigma_vals)

# Plot entropy
ax2.fill_between(t_vals, 0, entropy_vals, alpha=0.2, color='green')
ax2.plot(t_vals, entropy_vals, 'g-', linewidth=3, label='h(t) = log σ(t)')

# Annotations
ax2.axhline(y=np.log(2 + np.sqrt(3)), color='red', linestyle='--', alpha=0.5,
            label=f'Hat/Turtle entropy = {np.log(2+np.sqrt(3)):.4f}')

mid_entropy = entropy_vals[250]
ax2.scatter([0.5], [mid_entropy], color='purple', s=120, zorder=5, marker='D')
ax2.annotate(f'Minimum: h(½) = {mid_entropy:.4f}\n(closest to periodic)',
             xy=(0.5, mid_entropy), xytext=(0.55, mid_entropy - 0.06),
             fontsize=10, arrowprops=dict(arrowstyle='->', color='purple'),
             color='purple')

ax2.scatter([0, 1], [entropy_vals[0], entropy_vals[-1]], color='red',
            s=100, zorder=5, marker='*')

ax2.set_xlabel('Hat Spectrum Parameter t')
ax2.set_ylabel('Topological Entropy h(t)')
ax2.set_title('Entropy = Tropical Eigenvalue\nAcross the Hat Spectrum')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)
ax2.set_ylim(1.0, 1.4)

plt.suptitle('Cross-Domain Bridge: Aperiodic Tilings ↔ Tropical Geometry',
             fontsize=16, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_tropical.png', dpi=150, bbox_inches='tight')
print("Saved viz_tropical.png")
