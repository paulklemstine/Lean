"""
Demo 15: Super-Exponential Diagonal Orbit
Iterating d(z) = exp(z) - ln(z) from z₀ shows super-exponential growth.
Also shows the orbit of the g-map for comparison.
"""
import numpy as np
import matplotlib.pyplot as plt
import warnings
warnings.filterwarnings('ignore')

def diag(z):
    if z <= 0:
        return float('inf')
    return np.exp(z) - np.log(z)

def gmap(z):
    return np.e - np.log(z)

fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# Left: Diagonal orbit (super-exponential growth)
ax = axes[0]
z0_vals = [0.5, 1.0, 2.0]
for z0 in z0_vals:
    orbit = [z0]
    z = z0
    for _ in range(6):
        try:
            z = diag(z)
            if z > 1e300:
                break
            orbit.append(z)
        except:
            break
    ax.semilogy(range(len(orbit)), orbit, 'o-', linewidth=2, markersize=6, label=f'z₀ = {z0}')

ax.set_xlabel('Iteration n')
ax.set_ylabel('d^n(z₀) (log scale)')
ax.set_title('Diagonal Orbit: Super-Exponential Growth')
ax.legend()
ax.grid(True, alpha=0.3)

# Middle: g-map orbit (convergent)
ax = axes[1]
z_star = 2.0
for _ in range(100):
    z_star = gmap(z_star)

z0_vals_g = [0.5, 1.0, 3.0, 5.0]
for z0 in z0_vals_g:
    orbit = [z0]
    z = z0
    for _ in range(20):
        z = gmap(z)
        orbit.append(z)
    ax.plot(range(len(orbit)), orbit, 'o-', linewidth=1.5, markersize=4, label=f'z₀ = {z0}')

ax.axhline(y=z_star, color='k', linestyle='--', label=f'z* = {z_star:.5f}')
ax.set_xlabel('Iteration n')
ax.set_ylabel('g^n(z₀)')
ax.set_title('g-Map Orbit: Convergent')
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)

# Right: Growth rate comparison
ax = axes[2]
n = np.arange(1, 8)
# Manual computation of first few diagonal iterates from z0=1
orbit_1 = [1.0]
z = 1.0
for _ in range(6):
    z = np.exp(z) - np.log(max(z, 1e-300))
    orbit_1.append(z)
    if z > 1e300:
        break

# Compare with tower function
tower = [1.0]
t = 1.0
for _ in range(6):
    try:
        t = np.exp(t)
        tower.append(t)
        if t > 1e300:
            break
    except:
        break

min_len = min(len(orbit_1), len(tower))
ax.semilogy(range(min_len), orbit_1[:min_len], 'ro-', linewidth=2, label='d^n(1)')
ax.semilogy(range(min_len), tower[:min_len], 'b--', linewidth=2, label='exp^n(1) (tower)')
ax.set_xlabel('n')
ax.set_ylabel('Value (log scale)')
ax.set_title('Diagonal vs Tower Function Growth')
ax.legend()
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('super_exponential_orbit.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved super_exponential_orbit.png")
