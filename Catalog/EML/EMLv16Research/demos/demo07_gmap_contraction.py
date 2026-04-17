"""
Demo 7: g-Map Contraction and Convergence Rate
Demonstrates |g'(z)| = 1/z ≤ 1/2 for z ≥ 2 and convergence analysis.
"""
import numpy as np
import matplotlib.pyplot as plt

def gmap(z):
    return np.e - np.log(z)

# Fixed point
z_star = 2.0
for _ in range(100):
    z_star = gmap(z_star)

fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# Left: Derivative magnitude
ax = axes[0]
z = np.linspace(0.5, 6, 500)
deriv = 1/z
ax.plot(z, deriv, 'b-', linewidth=2, label="|g'(z)| = 1/z")
ax.axhline(y=0.5, color='r', linestyle='--', label='Contraction bound 1/2')
ax.axvline(x=2, color='g', linestyle=':', alpha=0.7, label='z = 2')
ax.fill_between(z[z >= 2], 0, deriv[z >= 2], alpha=0.2, color='green')
ax.set_xlabel('z')
ax.set_ylabel("|g'(z)|")
ax.set_title("g-Map Derivative: |g'(z)| = 1/z ≤ 1/2 for z ≥ 2")
ax.legend()
ax.set_ylim(0, 2)
ax.grid(True, alpha=0.3)

# Middle: Convergence from multiple starting points
ax = axes[1]
starts = [0.1, 0.5, 1.0, 2.0, 3.0, 5.0, 10.0]
colors = plt.cm.viridis(np.linspace(0, 1, len(starts)))
for z0, col in zip(starts, colors):
    orbit = [z0]
    z = z0
    for _ in range(20):
        z = gmap(z)
        orbit.append(z)
    ax.plot(orbit, 'o-', color=col, markersize=3, linewidth=1, label=f'z₀ = {z0}')

ax.axhline(y=z_star, color='k', linestyle='--', label=f'z* = {z_star:.5f}')
ax.set_xlabel('Iteration n')
ax.set_ylabel('g^n(z₀)')
ax.set_title('g-Map Convergence from Various z₀')
ax.legend(fontsize=7, loc='upper right')
ax.grid(True, alpha=0.3)

# Right: Error decay (log scale)
ax = axes[2]
for z0, col in zip([0.5, 2.0, 5.0], ['blue', 'green', 'red']):
    errors = []
    z = z0
    for _ in range(25):
        errors.append(abs(z - z_star))
        z = gmap(z)
    ax.semilogy(errors, 'o-', color=col, markersize=3, label=f'z₀ = {z0}')

n_range = np.arange(5, 25)
ax.semilogy(n_range, 5 * 0.5**n_range, 'k--', alpha=0.5, label='O(0.5^n) reference')
ax.set_xlabel('Iteration n')
ax.set_ylabel('|g^n(z₀) - z*|')
ax.set_title('Error Decay (log scale)')
ax.legend()
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('gmap_contraction.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved gmap_contraction.png")
