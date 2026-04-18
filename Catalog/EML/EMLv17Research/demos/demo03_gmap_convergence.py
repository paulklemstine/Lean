"""Demo 3: g-Map Fixed Point Convergence and Contraction

Visualizes the g-map g(z) = e - ln(z), its unique fixed point z* ≈ 2.0168,
contraction on [2, ∞), and cobweb convergence from multiple starting points.
"""
import numpy as np
import matplotlib.pyplot as plt
from scipy.optimize import brentq

def gmap(z):
    return np.e - np.log(z)

# Find exact fixed point
z_star = brentq(lambda z: gmap(z) - z, 2, np.e)

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Plot 1: g(z) and y=z
z = np.linspace(0.1, 5, 1000)
axes[0,0].plot(z, gmap(z), 'b-', linewidth=2, label='g(z) = e - ln(z)')
axes[0,0].plot(z, z, 'k--', linewidth=1, label='y = z')
axes[0,0].plot(z_star, z_star, 'r*', markersize=15, label=f'z* ≈ {z_star:.5f}')
axes[0,0].axhline(y=2, color='gray', linestyle=':', alpha=0.5)
axes[0,0].set_xlabel('z'); axes[0,0].set_ylabel('g(z)')
axes[0,0].set_title('g-Map and Fixed Point')
axes[0,0].legend(); axes[0,0].grid(True, alpha=0.3)

# Plot 2: Cobweb diagram
def cobweb(z0, n_iter, ax, color, label):
    z = z0
    xs, ys = [z], [0]
    for _ in range(n_iter):
        gz = gmap(z)
        xs.extend([z, gz])
        ys.extend([gz, gz])
        z = gz
    ax.plot(xs, ys, color=color, linewidth=1, alpha=0.7, label=label)

z_plot = np.linspace(0.1, 5, 500)
axes[0,1].plot(z_plot, gmap(z_plot), 'b-', linewidth=2)
axes[0,1].plot(z_plot, z_plot, 'k--', linewidth=1)
cobweb(0.5, 20, axes[0,1], 'red', 'z₀ = 0.5')
cobweb(4.0, 20, axes[0,1], 'green', 'z₀ = 4.0')
axes[0,1].plot(z_star, z_star, 'r*', markersize=12)
axes[0,1].set_xlabel('z'); axes[0,1].set_ylabel('g(z)')
axes[0,1].set_title('Cobweb Diagram')
axes[0,1].legend(); axes[0,1].grid(True, alpha=0.3)
axes[0,1].set_xlim(0, 5); axes[0,1].set_ylim(0, 5)

# Plot 3: Convergence rate
starts = [0.5, 1.0, 2.5, 4.0]
for z0 in starts:
    errors = []
    z = z0
    for _ in range(30):
        errors.append(abs(z - z_star))
        z = gmap(z)
    axes[1,0].semilogy(errors, 'o-', markersize=3, label=f'z₀ = {z0}')

axes[1,0].set_xlabel('Iteration'); axes[1,0].set_ylabel('|zₙ - z*|')
axes[1,0].set_title('Convergence Rate (log scale)')
axes[1,0].legend(); axes[1,0].grid(True, alpha=0.3)

# Plot 4: |g'(z)| = 1/z (contraction constant)
z_range = np.linspace(0.5, 5, 500)
deriv = 1.0 / z_range
axes[1,1].plot(z_range, deriv, 'b-', linewidth=2, label="|g'(z)| = 1/z")
axes[1,1].axhline(y=0.5, color='r', linestyle='--', label='L = 1/2 (contraction)')
axes[1,1].axhline(y=1.0, color='gray', linestyle=':', label='L = 1 (boundary)')
axes[1,1].axvline(x=2, color='green', linestyle=':', alpha=0.5, label='z = 2')
axes[1,1].fill_between(z_range[z_range >= 2], 0, deriv[z_range >= 2],
                        alpha=0.1, color='green')
axes[1,1].set_xlabel('z'); axes[1,1].set_ylabel("|g'(z)|")
axes[1,1].set_title('Contraction: |g\'(z)| ≤ 1/2 for z ≥ 2')
axes[1,1].legend(); axes[1,1].grid(True, alpha=0.3)
axes[1,1].set_ylim(0, 2)

plt.tight_layout()
plt.savefig('/workspace/request-project/EML/EMLv17Research/demos/gmap_convergence.png', dpi=150)
plt.close()
print(f"Demo 3 complete. Fixed point z* = {z_star:.10f}")
