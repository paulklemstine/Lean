"""
Demo 01: Diagonal Convexity and Minimum Analysis
=================================================
Visualizes d(z) = e^z - ln(z) on (0, ∞), showing:
- Strict convexity (verified in Lean: emlDiag_strictConvexOn)
- Global minimum at the Omega constant Ω ≈ 0.5671
- The bound d(z) ≥ 2 for all z > 0
- Tangent line at the minimum
"""

import numpy as np
import matplotlib.pyplot as plt
from scipy.optimize import minimize_scalar

# Domain
z = np.linspace(0.01, 4, 1000)
d = np.exp(z) - np.log(z)

# Find minimum numerically
res = minimize_scalar(lambda t: np.exp(t) - np.log(t), bounds=(0.01, 2), method='bounded')
z_min = res.x
d_min = res.fun

# Second derivative at minimum
d2_at_min = np.exp(z_min) + 1/z_min**2

fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# Plot 1: Diagonal with minimum
ax = axes[0]
ax.plot(z, d, 'b-', linewidth=2, label=r'$d(z) = e^z - \ln z$')
ax.axhline(y=2, color='r', linestyle='--', alpha=0.7, label=r'$d(z) \geq 2$ bound')
ax.plot(z_min, d_min, 'ro', markersize=10, label=f'Min at Ω ≈ {z_min:.4f}, d(Ω) ≈ {d_min:.4f}')

# Tangent line at minimum
slope = np.exp(z_min) - 1/z_min  # should be ≈ 0
tangent = d_min + slope * (z - z_min)
ax.plot(z, tangent, 'g--', alpha=0.5, label=f'Tangent (slope ≈ {slope:.2e})')

ax.set_xlim(0, 4)
ax.set_ylim(0, 15)
ax.set_xlabel('z', fontsize=12)
ax.set_ylabel('d(z)', fontsize=12)
ax.set_title('Diagonal d(z) — Strict Convexity', fontsize=14)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Plot 2: Second derivative (proves convexity)
ax = axes[1]
d2 = np.exp(z) + 1/z**2
ax.plot(z, d2, 'purple', linewidth=2, label=r"$d''(z) = e^z + 1/z^2$")
ax.axhline(y=0, color='k', linestyle='-', alpha=0.3)
ax.fill_between(z, 0, d2, alpha=0.15, color='purple')
ax.set_xlim(0, 3)
ax.set_ylim(0, 25)
ax.set_xlabel('z', fontsize=12)
ax.set_ylabel("d''(z)", fontsize=12)
ax.set_title("Second Derivative > 0 Everywhere", fontsize=14)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Plot 3: Convexity verification
ax = axes[2]
# Show midpoint inequality
z1_vals = np.random.uniform(0.1, 3, 500)
z2_vals = np.random.uniform(0.1, 3, 500)
d_mid = np.exp((z1_vals+z2_vals)/2) - np.log((z1_vals+z2_vals)/2)
d_avg = (np.exp(z1_vals) - np.log(z1_vals) + np.exp(z2_vals) - np.log(z2_vals)) / 2
violations = np.sum(d_mid > d_avg + 1e-10)

ax.scatter(d_avg, d_mid, s=5, alpha=0.5, c='blue')
lim = max(d_avg.max(), d_mid.max())
ax.plot([0, lim], [0, lim], 'r--', label='Equality line')
ax.set_xlabel('Average d(z₁), d(z₂)', fontsize=12)
ax.set_ylabel('d((z₁+z₂)/2)', fontsize=12)
ax.set_title(f'Midpoint Inequality ({violations} violations / 500)', fontsize=14)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('EML/EMLv18Research/demos/diagonal_convexity.png', dpi=150, bbox_inches='tight')
plt.close()
print("Demo 01 saved: diagonal_convexity.png")
