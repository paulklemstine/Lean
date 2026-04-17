"""
Demo 5: Diagonal Map Analysis
d(z) = exp(z) - ln(z): minimum location, convexity, iterated dynamics.
"""
import numpy as np
import matplotlib.pyplot as plt
from scipy.optimize import brentq

def diag(z):
    return np.exp(z) - np.log(z)

def diag_prime(z):
    return np.exp(z) - 1/z

# Find minimum: d'(z) = 0 ⟹ exp(z) = 1/z
z_min = brentq(diag_prime, 0.1, 1.0)
d_min = diag(z_min)
print(f"Diagonal minimum at z = {z_min:.10f}, d(z) = {d_min:.10f}")

fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# Left: Diagonal function
ax = axes[0]
z = np.linspace(0.05, 4, 500)
ax.plot(z, diag(z), 'b-', linewidth=2, label='d(z) = exp(z) - ln(z)')
ax.axhline(y=2, color='r', linestyle='--', alpha=0.7, label='d = 2 (minimum bound)')
ax.plot(z_min, d_min, 'ro', markersize=10, zorder=5, label=f'min at z={z_min:.4f}, d={d_min:.4f}')
ax.plot(1, np.e, 'gs', markersize=8, label=f'd(1) = e ≈ {np.e:.4f}')
ax.set_xlabel('z')
ax.set_ylabel('d(z)')
ax.set_title('Diagonal Map d(z) = exp(z) - ln(z)')
ax.legend(fontsize=8)
ax.set_ylim(0, 15)
ax.grid(True, alpha=0.3)

# Middle: Second derivative (showing strict convexity)
ax = axes[1]
d2 = np.exp(z) + 1/z**2
ax.plot(z, d2, 'r-', linewidth=2, label="d''(z) = exp(z) + 1/z²")
ax.axhline(y=0, color='k', linewidth=0.5)
ax.set_xlabel('z')
ax.set_ylabel("d''(z)")
ax.set_title("d''(z) > 0 everywhere (strict convexity)")
ax.legend()
ax.set_ylim(0, 20)
ax.grid(True, alpha=0.3)

# Right: Iterated diagonal d(d(z)) vs d(z)
ax = axes[2]
z_pts = np.linspace(0.1, 3, 200)
d_vals = diag(z_pts)
dd_vals = diag(d_vals)
ax.plot(z_pts, d_vals, 'b-', linewidth=2, label='d(z)')
ax.plot(z_pts, dd_vals, 'r-', linewidth=2, label='d(d(z))')
ax.fill_between(z_pts, d_vals, dd_vals, alpha=0.2, color='green', label='d(d(z)) ≥ d(z)')
ax.set_xlabel('z')
ax.set_ylabel('value')
ax.set_title('Iterated Diagonal: d(d(z)) ≥ d(z)')
ax.legend()
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('diagonal_analysis.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved diagonal_analysis.png")
