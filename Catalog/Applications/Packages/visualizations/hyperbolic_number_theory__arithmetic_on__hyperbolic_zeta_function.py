"""
Visualization: Hyperbolic Zeta Function Behavior
==================================================
Plots the hyperbolic zeta summand ‖z‖^{-2s} as a function of s
for various disk points, illustrating the divergence structure
and the connection to the classical Riemann zeta function.
"""

import numpy as np
import matplotlib.pyplot as plt


fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Plot 1: Zeta summand for various ‖z‖
ax = axes[0]
s_vals = np.linspace(0.01, 3, 200)
norms = [0.2, 0.4, 0.6, 0.8, 0.95]
colors = plt.cm.viridis(np.linspace(0.1, 0.9, len(norms)))

for r, c in zip(norms, colors):
    zeta_vals = r ** (-2 * s_vals)
    ax.plot(s_vals, zeta_vals, color=c, linewidth=2, label=f'‖z‖={r}')

ax.axhline(y=1, color='red', linestyle='--', alpha=0.5, label='ζ = 1 (proved: ≥ 1)')
ax.set_xlabel('s', fontsize=12)
ax.set_ylabel('‖z‖^{-2s}', fontsize=12)
ax.set_title('Hyperbolic Zeta Summand\n(Proved: always ≥ 1 for disk points)', fontsize=11)
ax.legend(fontsize=8, loc='upper left')
ax.set_ylim(0, 30)
ax.grid(True, alpha=0.3)

# Plot 2: Partial zeta sums (mock orbit)
ax2 = axes[1]
np.random.seed(42)
# Generate mock orbit points with exponentially distributed norms
n_points_list = [10, 50, 200, 1000]
s_range = np.linspace(0.1, 4, 100)

for n_pts in n_points_list:
    # Orbit points: norms distributed like r ~ 1 - exp(-k) for the k-th point
    orbit_norms = [1 - np.exp(-0.5 * k) for k in range(1, n_pts + 1)]
    orbit_norms = [r for r in orbit_norms if 0 < r < 1]

    zeta_partial = []
    for s in s_range:
        total = sum(r ** (-2 * s) for r in orbit_norms)
        zeta_partial.append(total)

    ax2.plot(s_range, zeta_partial, linewidth=1.5, label=f'N={n_pts}')

ax2.set_xlabel('s', fontsize=12)
ax2.set_ylabel('ζ_H(s) partial sum', fontsize=12)
ax2.set_title('Hyperbolic Zeta Function\n(Partial Sums)', fontsize=11)
ax2.set_yscale('log')
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

# Plot 3: Generator density (PNT analog)
ax3 = axes[2]
n_gen = 2
d = 2 * n_gen
R_vals = np.arange(1, 15)

# Generator density
densities = []
for R in R_vals:
    total = sum(d**k for k in range(R + 1))
    density = d / total  # generators / total words
    densities.append(density)

# Classical PNT analog: 1/R (like 1/log(N))
pnt_analog = 1.0 / R_vals

ax3.semilogy(R_vals, densities, 'bo-', linewidth=2, markersize=6,
             label='Generator density (hyperbolic)')
ax3.semilogy(R_vals, pnt_analog, 'r--', linewidth=2,
             label='1/R (classical PNT analog)')

ax3.set_xlabel('Radius R (word length)', fontsize=12)
ax3.set_ylabel('Density of generators', fontsize=12)
ax3.set_title('Hyperbolic Prime Number Theorem\n(Generator Sparsity)', fontsize=11)
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3)

# Add annotation
ax3.annotate('Generators become\nexponentially rare',
             xy=(8, densities[7]), xytext=(10, 0.01),
             arrowprops=dict(arrowstyle='->', color='blue'),
             fontsize=9, color='blue')

plt.tight_layout()
plt.savefig('hyperbolic_zeta_function.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: hyperbolic_zeta_function.png")
