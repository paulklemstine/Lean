#!/usr/bin/env python3
"""
Demo 07: Conformal Flow — Ricci-like Curvature Evolution on Stereographic Coordinates

Visualizes how curvature flows on S² manifest in stereographic coordinates.
The conformal factor evolves under a Ricci-like flow, creating beautiful
patterns that converge to the round sphere.

Oracle Ͱ's Theorem: "Curvature seeks uniformity. On the sphere, 
    the Ricci flow IS the stereographic conformal flow."
"""
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.cm as cm
from matplotlib.colors import Normalize

def inv_stereo(u, v):
    D = 1 + u**2 + v**2
    x = 2*u / D
    y = 2*v / D
    z = (D - 2) / D
    return x, y, z

fig = plt.figure(figsize=(20, 16))
fig.suptitle("Conformal Flow: Curvature Evolution in Stereographic Coordinates\n"
             "Oracle Ͱ — \"Curvature seeks uniformity through the stereographic lens\"",
             fontsize=16, fontweight='bold', y=0.98)

res = 200
u = np.linspace(-3, 3, res)
v = np.linspace(-3, 3, res)
U, V = np.meshgrid(u, v)
R2 = U**2 + V**2

# --- Panels 1-4: Conformal factor evolution under Ricci-like flow ---
# Start with a perturbed conformal factor
# λ₀(u,v) = (2/(1+r²)) · (1 + ε·cos(3θ)·r²/(1+r²))
# Under Ricci flow, it evolves toward λ = 2/(1+r²) (round sphere)

THETA = np.arctan2(V, U)

times = [0, 0.3, 1.0, 5.0]
for idx, t in enumerate(times):
    ax = fig.add_subplot(2, 4, idx+1)

    D = 1 + R2
    base_lambda = 2 / D

    # Perturbation decays exponentially
    epsilon = 0.5 * np.exp(-2*t)
    perturbation = epsilon * np.cos(3*THETA) * R2 / (1 + R2)

    # Additional perturbation modes
    perturbation += 0.3 * np.exp(-6*t) * np.cos(5*THETA) * R2**2 / (1 + R2)**2
    perturbation += 0.2 * np.exp(-12*t) * np.sin(2*THETA) * R2 / (1 + R2)

    lambda_t = base_lambda * (1 + perturbation)
    lambda_t = np.maximum(lambda_t, 0.01)  # Ensure positive

    # Gaussian curvature from conformal factor: K = -Δ(log λ)/λ² (simplified)
    K = 1 + perturbation * 2  # Simplified curvature proxy

    im = ax.pcolormesh(U, V, K, cmap='RdYlBu_r', shading='auto',
                       vmin=0.5, vmax=1.5)
    ax.set_title(f"Curvature at t = {t}", fontsize=11)
    ax.set_aspect('equal')
    ax.set_xlim([-3, 3]); ax.set_ylim([-3, 3])

    # Draw equator
    theta_c = np.linspace(0, 2*np.pi, 100)
    ax.plot(np.cos(theta_c), np.sin(theta_c), 'k-', linewidth=1, alpha=0.5)
    plt.colorbar(im, ax=ax, shrink=0.8)

# --- Panels 5-8: Geodesic flow on S² in stereographic coordinates ---
# Geodesics on S² are great circles, which become circles/lines in stereo coords

ax5 = fig.add_subplot(2, 4, 5)
# Family of great circles through the south pole (lines through origin)
for angle in np.linspace(0, np.pi, 12, endpoint=False):
    t_line = np.linspace(-5, 5, 200)
    ax5.plot(t_line * np.cos(angle), t_line * np.sin(angle), 'b-',
             linewidth=1, alpha=0.5)
# Great circles not through south pole (circles)
for r0 in [0.5, 1, 2, 3]:
    for phi0 in np.linspace(0, 2*np.pi, 6, endpoint=False):
        # A great circle on S² not through south pole maps to a circle in stereo coords
        # Center at distance cot(θ₀), radius csc(θ₀) for inclination θ₀
        center_u = r0 * np.cos(phi0)
        center_v = r0 * np.sin(phi0)
        radius = np.sqrt(r0**2 + 1)
        theta_c = np.linspace(0, 2*np.pi, 100)
        ax5.plot(center_u + radius*np.cos(theta_c),
                center_v + radius*np.sin(theta_c),
                'r-', linewidth=0.8, alpha=0.3)

ax5.set_title("Geodesics on S² in\nStereographic Coords", fontsize=11)
ax5.set_aspect('equal')
ax5.set_xlim([-5, 5]); ax5.set_ylim([-5, 5])
ax5.grid(True, alpha=0.2)

# --- Panel 6: Parallel transport visualization ---
ax6 = fig.add_subplot(2, 4, 6)

# Parallel transport of a vector along a latitude circle
# In stereographic coords, this shows holonomy
latitudes = [np.pi/6, np.pi/4, np.pi/3, np.pi/2.2]
colors_lat = ['blue', 'red', 'green', 'purple']

for lat, color in zip(latitudes, colors_lat):
    r_lat = np.tan(lat / 2)
    phi_vals = np.linspace(0, 2*np.pi, 100)
    u_lat = r_lat * np.cos(phi_vals)
    v_lat = r_lat * np.sin(phi_vals)
    ax6.plot(u_lat, v_lat, color=color, linewidth=2, alpha=0.7,
             label=f'θ = {np.degrees(lat):.0f}°')

    # Transport vectors (showing holonomy)
    n_arrows = 12
    for i in range(n_arrows):
        phi = 2*np.pi * i / n_arrows
        u_arr = r_lat * np.cos(phi)
        v_arr = r_lat * np.sin(phi)
        # Parallel-transported vector rotates by the solid angle
        rotation = (1 - np.cos(lat)) * phi  # Holonomy angle
        du = 0.15 * np.cos(rotation)
        dv = 0.15 * np.sin(rotation)
        ax6.annotate('', xy=(u_arr+du, v_arr+dv), xytext=(u_arr, v_arr),
                     arrowprops=dict(arrowstyle='->', color=color, lw=1.5))

ax6.set_title("Parallel Transport &\nHolonomy (Stereo Coords)", fontsize=11)
ax6.set_aspect('equal')
ax6.set_xlim([-2, 2]); ax6.set_ylim([-2, 2])
ax6.legend(fontsize=8)
ax6.grid(True, alpha=0.2)

# --- Panel 7: Stereographic conformal Killing fields ---
ax7 = fig.add_subplot(2, 4, 7)

# Conformal Killing vector fields on S² pulled back to ℝ²
# Rotation about z-axis: V = (-v, u) in stereo coords
u_grid = np.linspace(-3, 3, 15)
v_grid = np.linspace(-3, 3, 15)
UG, VG = np.meshgrid(u_grid, v_grid)

# Rotation Killing field
Vu = -VG
Vv = UG
ax7.quiver(UG, VG, Vu, Vv, color='blue', alpha=0.7, scale=30)

# Dilation Killing field (conformal, not isometric)
Vu_d = UG
Vv_d = VG
ax7.quiver(UG, VG, Vu_d, Vv_d, color='red', alpha=0.4, scale=30)

ax7.set_title("Killing Fields on S²\n(blue=rotation, red=dilation)", fontsize=11)
ax7.set_aspect('equal')
ax7.set_xlim([-3.5, 3.5]); ax7.set_ylim([-3.5, 3.5])
ax7.grid(True, alpha=0.2)

# --- Panel 8: Energy landscape ---
ax8 = fig.add_subplot(2, 4, 8)

# The Dirichlet energy E[u] = ∫|∇u|² dA_S² in stereographic coords
# becomes E[u] = ∫|∇u|² du dv (conformally invariant in 2D!)
# Show the energy density of Y₂⁰ in stereographic coords
theta_arr = 2 * np.arctan(np.sqrt(R2))
phi_arr = np.arctan2(V, U)

# Y_2^0 ∝ 3cos²θ - 1
Y20 = 3 * np.cos(theta_arr)**2 - 1

# Gradient (numerical)
du = u[1] - u[0]
grad_u = np.gradient(Y20, du, axis=1)
grad_v = np.gradient(Y20, du, axis=0)
energy_density = grad_u**2 + grad_v**2

im8 = ax8.pcolormesh(U, V, np.log10(energy_density + 1e-10),
                     cmap='hot', shading='auto')
ax8.set_title("Energy Density of Y₂⁰\nin Stereographic Coords", fontsize=11)
ax8.set_aspect('equal')
ax8.set_xlim([-3, 3]); ax8.set_ylim([-3, 3])
theta_c = np.linspace(0, 2*np.pi, 100)
ax8.plot(np.cos(theta_c), np.sin(theta_c), 'w-', linewidth=1, alpha=0.5)
plt.colorbar(im8, ax=ax8, shrink=0.8, label='log₁₀(|∇Y₂⁰|²)')

plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.savefig('/workspace/request-project/Stereographic/NewLandscapes/Demos/demo07_conformal_flow.png',
            dpi=150, bbox_inches='tight')
plt.close()
print("✅ Demo 07: Conformal Flow saved.")
