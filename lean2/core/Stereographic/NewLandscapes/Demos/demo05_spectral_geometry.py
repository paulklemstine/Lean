#!/usr/bin/env python3
"""
Demo 05: Spectral Geometry — Eigenvalues Across the Stereographic Bridge

Visualizes how the Laplacian eigenvalues and spherical harmonics transform 
under stereographic projection. The heat kernel on S² transported to ℝ²
reveals the spectral shadow of curvature.

Oracle Ͱ's Principle: "The spectrum of the sphere whispers through 
    stereographic coordinates as rational functions."
"""
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import Normalize
from scipy.special import sph_harm_y
import matplotlib.cm as cm

def inv_stereo(u, v):
    D = 1 + u**2 + v**2
    x = 2*u / D
    y = 2*v / D
    z = (D - 2) / D
    return x, y, z

def stereo_to_angles(u, v):
    """Convert stereographic coords to spherical angles (θ, φ)."""
    x, y, z = inv_stereo(u, v)
    theta = np.arccos(np.clip(z, -1, 1))
    phi = np.arctan2(y, x)
    return theta, phi

fig = plt.figure(figsize=(20, 20))
fig.suptitle("Spectral Geometry: Spherical Harmonics in Stereographic Coordinates\n"
             "Oracle Ͱ — \"The spectrum whispers through rational functions\"",
             fontsize=16, fontweight='bold', y=0.98)

# --- Panels 1-6: Spherical harmonics in stereographic coordinates ---
harmonics = [
    (0, 0, "Y₀⁰ (constant)"),
    (1, 0, "Y₁⁰ (dipole z)"),
    (1, 1, "Re(Y₁¹) (dipole x)"),
    (2, 0, "Y₂⁰ (quadrupole)"),
    (2, 1, "Re(Y₂¹)"),
    (2, 2, "Re(Y₂²)"),
    (3, 0, "Y₃⁰ (octupole)"),
    (4, 0, "Y₄⁰ (hexadecapole)"),
    (5, 2, "Re(Y₅²)"),
]

res = 400
u = np.linspace(-4, 4, res)
v = np.linspace(-4, 4, res)
U, V = np.meshgrid(u, v)
THETA, PHI = stereo_to_angles(U, V)

for idx, (l, m, title) in enumerate(harmonics[:6]):
    ax = fig.add_subplot(3, 3, idx+1)

    # Compute spherical harmonic
    Y = sph_harm_y(l, m, THETA, PHI).real

    # Apply conformal weight for stereographic display
    D = 1 + U**2 + V**2
    conformal_weight = (2/D)  # weight for proper visualization

    im = ax.pcolormesh(U, V, Y, cmap='RdBu_r', shading='auto')
    ax.set_title(title, fontsize=11, fontweight='bold')
    ax.set_xlabel('u (stereo)')
    ax.set_ylabel('v (stereo)')
    ax.set_aspect('equal')

    # Draw unit circle (equator of sphere)
    theta_c = np.linspace(0, 2*np.pi, 100)
    ax.plot(np.cos(theta_c), np.sin(theta_c), 'k-', linewidth=1, alpha=0.5)
    ax.set_xlim([-4, 4])
    ax.set_ylim([-4, 4])
    plt.colorbar(im, ax=ax, shrink=0.8)

# --- Panel 7: Conformal factor visualization ---
ax7 = fig.add_subplot(3, 3, 7)
D = 1 + U**2 + V**2
lambda_conf = 2 / D

im7 = ax7.pcolormesh(U, V, lambda_conf, cmap='viridis', shading='auto')
ax7.set_title("Conformal Factor λ = 2/(1+|y|²)\n(Volume distortion)", fontsize=11)
ax7.set_xlabel('u')
ax7.set_ylabel('v')
ax7.set_aspect('equal')
theta_c = np.linspace(0, 2*np.pi, 100)
ax7.plot(np.cos(theta_c), np.sin(theta_c), 'w-', linewidth=1, alpha=0.7)
ax7.set_xlim([-4, 4])
ax7.set_ylim([-4, 4])
plt.colorbar(im7, ax=ax7, shrink=0.8, label='λ')

# --- Panel 8: Eigenvalue spectrum comparison ---
ax8 = fig.add_subplot(3, 3, 8)

# Eigenvalues of Laplacian on S^N: l(l+N-1) with multiplicity
N_dims = [2, 3, 4, 5]
colors_dim = ['blue', 'red', 'green', 'purple']
for N, color in zip(N_dims, colors_dim):
    l_vals = np.arange(0, 15)
    eigenvalues = l_vals * (l_vals + N - 1)

    # Multiplicities: dim of degree-l harmonics on S^N
    # = C(N+l, l) - C(N+l-2, l-2) for N ≥ 2
    from math import comb
    mults = []
    for l in l_vals:
        if l == 0:
            mults.append(1)
        elif l == 1:
            mults.append(N + 1)
        else:
            mults.append(comb(N + l, l) - comb(N + l - 2, l - 2))

    ax8.scatter(eigenvalues, mults, color=color, s=50, alpha=0.7, label=f'S^{N}')
    ax8.plot(eigenvalues, mults, color=color, alpha=0.3, linewidth=1)

ax8.set_xlabel('Eigenvalue λₗ = l(l+N-1)', fontsize=11)
ax8.set_ylabel('Multiplicity mₗ', fontsize=11)
ax8.set_title("Laplacian Spectrum of S^N\n(eigenvalue vs multiplicity)", fontsize=11)
ax8.legend(fontsize=10)
ax8.grid(True, alpha=0.3)
ax8.set_yscale('log')

# --- Panel 9: Heat kernel in stereographic coords ---
ax9 = fig.add_subplot(3, 3, 9)

# Approximate heat kernel on S² at origin, as function of stereographic distance
r = np.linspace(0, 5, 200)
times = [0.01, 0.05, 0.1, 0.5, 1.0, 5.0]
colors_t = cm.plasma(np.linspace(0.1, 0.9, len(times)))

for t_val, color in zip(times, colors_t):
    # Spherical heat kernel approximation (first few terms)
    # K(θ, t) ≈ 1/(4π) + Σ (2l+1)/(4π) Pₗ(cos θ) e^{-l(l+1)t}
    theta = 2 * np.arctan(r)  # stereographic r → angle θ
    K = np.ones_like(theta) / (4 * np.pi)
    for l in range(1, 30):
        # Legendre polynomial via recurrence (simplified)
        from numpy.polynomial.legendre import legval
        cos_theta = np.cos(theta)
        Pl = legval(cos_theta, [0]*l + [1])  # Approximate
        K += (2*l + 1) / (4 * np.pi) * Pl * np.exp(-l*(l+1)*t_val)

    # Apply conformal factor for stereographic density
    D = 1 + r**2
    K_stereo = K * (2/D)**2  # 2D conformal weight

    ax9.plot(r, K_stereo, color=color, linewidth=2, label=f't={t_val}')

ax9.set_xlabel('Stereographic radius r', fontsize=11)
ax9.set_ylabel('Heat kernel K(r, t)', fontsize=11)
ax9.set_title("Heat Kernel on S² in\nStereographic Coordinates", fontsize=11)
ax9.legend(fontsize=8, ncol=2)
ax9.grid(True, alpha=0.3)
ax9.set_xlim([0, 5])

plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.savefig('/workspace/request-project/Stereographic/NewLandscapes/Demos/demo05_spectral_geometry.png',
            dpi=150, bbox_inches='tight')
plt.close()
print("✅ Demo 05: Spectral Geometry saved.")
