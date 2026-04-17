"""
Demo 8: Lambert W Connection
z + ln(z) = e ⟺ z·exp(z) = exp(e), so z* = W(exp(e)).
"""
import numpy as np
import matplotlib.pyplot as plt
from scipy.special import lambertw

# Fixed point via Lambert W
z_star_lambert = float(np.real(lambertw(np.exp(np.e))))
print(f"z* = W(exp(e)) = {z_star_lambert:.10f}")
print(f"Verification: z* + ln(z*) = {z_star_lambert + np.log(z_star_lambert):.10f} (should be e = {np.e:.10f})")
print(f"Verification: z*·exp(z*) = {z_star_lambert * np.exp(z_star_lambert):.10f} (should be exp(e) = {np.exp(np.e):.10f})")

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: z + ln(z) = e
ax = axes[0]
z = np.linspace(0.1, 5, 500)
ax.plot(z, z + np.log(z), 'b-', linewidth=2, label='h(z) = z + ln(z)')
ax.axhline(y=np.e, color='r', linestyle='--', linewidth=1.5, label=f'y = e ≈ {np.e:.4f}')
ax.plot(z_star_lambert, np.e, 'ko', markersize=10, zorder=5, label=f'z* ≈ {z_star_lambert:.5f}')
ax.set_xlabel('z')
ax.set_ylabel('h(z)')
ax.set_title('Fixed Point: z + ln(z) = e')
ax.legend()
ax.grid(True, alpha=0.3)
ax.set_ylim(-2, 7)

# Right: z·exp(z) = exp(e)
ax = axes[1]
z = np.linspace(0.1, 4, 500)
ax.plot(z, z * np.exp(z), 'b-', linewidth=2, label='f(z) = z·exp(z)')
ax.axhline(y=np.exp(np.e), color='r', linestyle='--', linewidth=1.5, label=f'y = exp(e) ≈ {np.exp(np.e):.4f}')
ax.plot(z_star_lambert, np.exp(np.e), 'ko', markersize=10, zorder=5, label=f'z* ≈ {z_star_lambert:.5f}')
ax.set_xlabel('z')
ax.set_ylabel('f(z)')
ax.set_title('Lambert W Form: z·exp(z) = exp(e)')
ax.legend()
ax.grid(True, alpha=0.3)
ax.set_ylim(0, 100)

plt.tight_layout()
plt.savefig('lambert_w_connection.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved lambert_w_connection.png")
