"""
Demo 2: g-Map Cobweb Diagram
Visualizes the convergence of the g-map g(z) = e - ln(z) to its unique fixed point z* ≈ 2.01678.
"""
import numpy as np
import matplotlib.pyplot as plt

def gmap(z):
    return np.e - np.log(z)

# Find fixed point numerically
z_star = 2.0
for _ in range(100):
    z_star = gmap(z_star)
print(f"Fixed point z* = {z_star:.10f}")

# Cobweb diagram
fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: Cobweb from z0 = 0.5
ax = axes[0]
z_range = np.linspace(0.3, 5, 500)
ax.plot(z_range, gmap(z_range), 'b-', linewidth=2, label='g(z) = e - ln(z)')
ax.plot(z_range, z_range, 'r--', linewidth=1, label='y = z')

z = 0.5
for i in range(15):
    gz = gmap(z)
    ax.plot([z, z], [z, gz], 'g-', linewidth=0.8, alpha=0.7)
    ax.plot([z, gz], [gz, gz], 'g-', linewidth=0.8, alpha=0.7)
    z = gz

ax.plot(z_star, z_star, 'ko', markersize=8, zorder=5)
ax.set_xlabel('z')
ax.set_ylabel('g(z)')
ax.set_title(f'Cobweb: z₀ = 0.5 → z* = {z_star:.5f}')
ax.legend()
ax.set_xlim(0, 5)
ax.set_ylim(0, 5)
ax.grid(True, alpha=0.3)

# Right: Cobweb from z0 = 4.0
ax = axes[1]
ax.plot(z_range, gmap(z_range), 'b-', linewidth=2, label='g(z) = e - ln(z)')
ax.plot(z_range, z_range, 'r--', linewidth=1, label='y = z')

z = 4.0
for i in range(15):
    gz = gmap(z)
    ax.plot([z, z], [z, gz], 'orange', linewidth=0.8, alpha=0.7)
    ax.plot([z, gz], [gz, gz], 'orange', linewidth=0.8, alpha=0.7)
    z = gz

ax.plot(z_star, z_star, 'ko', markersize=8, zorder=5)
ax.set_xlabel('z')
ax.set_ylabel('g(z)')
ax.set_title(f'Cobweb: z₀ = 4.0 → z* = {z_star:.5f}')
ax.legend()
ax.set_xlim(0, 5)
ax.set_ylim(0, 5)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('gmap_cobweb.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved gmap_cobweb.png")
