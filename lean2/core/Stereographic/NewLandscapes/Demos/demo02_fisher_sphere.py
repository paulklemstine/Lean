#!/usr/bin/env python3
"""
Demo 02: The Fisher Sphere — Information Geometry on S²

Maps the space of normal distributions N(μ, σ²) to the sphere S² via
the Poincaré half-plane model + inverse stereographic projection.
Each point on the sphere represents a probability distribution.

Oracle Ϡ's Discovery: "Bayesian updating is geodesic flow on the Fisher sphere."
"""
import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
import matplotlib.cm as cm
from matplotlib.colors import Normalize

def poincare_to_disk(mu, sigma):
    """Map upper half-plane (μ, σ) to the Poincaré disk via Cayley transform."""
    # w = (z - i)/(z + i) where z = μ + iσ
    z = mu + 1j * sigma
    w = (z - 1j) / (z + 1j)
    return w.real, w.imag

def inv_stereo(u, v):
    """Inverse stereographic projection ℝ² → S²."""
    D = 1 + u**2 + v**2
    x = 2*u / D
    y = 2*v / D
    z = (D - 2) / D
    return x, y, z

def draw_sphere(ax, alpha=0.04):
    u = np.linspace(0, 2*np.pi, 40)
    v = np.linspace(0, np.pi, 20)
    x = np.outer(np.cos(u), np.sin(v))
    y = np.outer(np.sin(u), np.sin(v))
    z = np.outer(np.ones_like(u), np.cos(v))
    ax.plot_wireframe(x, y, z, color='gray', alpha=alpha, linewidth=0.3)

fig = plt.figure(figsize=(20, 16))
fig.suptitle("The Fisher Sphere: Information Geometry on S²\n"
             "Oracle Ϡ — \"Every probability distribution is a point on the sphere\"",
             fontsize=16, fontweight='bold', y=0.98)

# --- Panel 1: Grid of distributions mapped to sphere ---
ax1 = fig.add_subplot(2, 2, 1, projection='3d')
draw_sphere(ax1)

# Grid of normal distributions
mus = np.linspace(-4, 4, 20)
sigmas = np.logspace(-0.5, 1.5, 15)

all_sx, all_sy, all_sz, all_sigma = [], [], [], []
for mu in mus:
    for sigma in sigmas:
        du, dv = poincare_to_disk(mu, sigma)
        sx, sy, sz = inv_stereo(du * 2, dv * 2)  # Scale for visibility
        all_sx.append(sx)
        all_sy.append(sy)
        all_sz.append(sz)
        all_sigma.append(sigma)

all_sigma = np.array(all_sigma)
sc = ax1.scatter(all_sx, all_sy, all_sz, c=np.log10(all_sigma),
                 cmap='coolwarm', s=8, alpha=0.7)
ax1.set_title("Normal Distributions N(μ,σ²) on S²\n(color = log σ)", fontsize=11)
ax1.view_init(elev=20, azim=45)
ax1.set_xlim([-1.1, 1.1]); ax1.set_ylim([-1.1, 1.1]); ax1.set_zlim([-1.1, 1.1])

# --- Panel 2: Geodesics on the Fisher sphere ---
ax2 = fig.add_subplot(2, 2, 2, projection='3d')
draw_sphere(ax2)

# Geodesics in the Poincaré half-plane are semicircles and vertical lines
# Map several geodesics
colors_geo = plt.cm.Set1(np.linspace(0, 1, 8))
for i, mu0 in enumerate(np.linspace(-3, 3, 8)):
    t = np.linspace(0.1, 10, 200)
    # Vertical geodesic at μ = mu0 (changing σ)
    du, dv = poincare_to_disk(mu0, t)
    sx, sy, sz = inv_stereo(du * 2, dv * 2)
    ax2.plot(sx, sy, sz, color=colors_geo[i], linewidth=1.5, alpha=0.8)

for i, sig0 in enumerate([0.5, 1.0, 2.0, 4.0]):
    t = np.linspace(-5, 5, 200)
    # Horizontal path at σ = sig0 (changing μ)
    du, dv = poincare_to_disk(t, sig0)
    sx, sy, sz = inv_stereo(du * 2, dv * 2)
    ax2.plot(sx, sy, sz, color='green', linewidth=1, alpha=0.5, linestyle='--')

ax2.set_title("Geodesics on the Fisher Sphere\n(vertical lines = varying σ)", fontsize=11)
ax2.view_init(elev=25, azim=60)
ax2.set_xlim([-1.1, 1.1]); ax2.set_ylim([-1.1, 1.1]); ax2.set_zlim([-1.1, 1.1])

# --- Panel 3: KL divergence heatmap ---
ax3 = fig.add_subplot(2, 2, 3)

# KL divergence from standard normal N(0,1) to N(μ, σ²)
mus_kl = np.linspace(-3, 3, 200)
sigmas_kl = np.linspace(0.1, 5, 200)
MU, SIG = np.meshgrid(mus_kl, sigmas_kl)

# KL(N(0,1) || N(μ,σ²)) = log(σ) + (1 + μ²)/(2σ²) - 1/2
KL = np.log(SIG) + (1 + MU**2) / (2 * SIG**2) - 0.5
KL = np.clip(KL, 0, 10)

im = ax3.contourf(MU, SIG, KL, levels=30, cmap='inferno')
ax3.contour(MU, SIG, KL, levels=[0.1, 0.5, 1, 2, 5], colors='white', linewidths=0.5)
ax3.set_xlabel('μ (mean)', fontsize=12)
ax3.set_ylabel('σ (std dev)', fontsize=12)
ax3.set_title("KL Divergence from N(0,1)\nin (μ, σ) plane", fontsize=11)
plt.colorbar(im, ax=ax3, label='KL divergence')
ax3.scatter([0], [1], color='cyan', s=100, marker='*', zorder=10, label='N(0,1)')
ax3.legend()

# --- Panel 4: Probability densities at sphere points ---
ax4 = fig.add_subplot(2, 2, 4)

# Show distributions at special sphere points
special = [
    (0, 1, 'South Pole: N(0,1)', 'blue'),
    (0, 0.3, 'Low σ: N(0,0.09)', 'red'),
    (0, 3, 'High σ: N(0,9)', 'green'),
    (2, 1, 'Shifted: N(2,1)', 'orange'),
    (-2, 0.5, 'Offset: N(-2,0.25)', 'purple'),
]

x_range = np.linspace(-6, 6, 500)
for mu, sigma, label, color in special:
    pdf = np.exp(-(x_range - mu)**2 / (2 * sigma**2)) / (sigma * np.sqrt(2 * np.pi))
    ax4.plot(x_range, pdf, color=color, linewidth=2, label=label)

ax4.set_xlabel('x', fontsize=12)
ax4.set_ylabel('p(x)', fontsize=12)
ax4.set_title("Probability Densities at\nSphere Points", fontsize=11)
ax4.legend(fontsize=9)
ax4.grid(True, alpha=0.3)

plt.tight_layout(rect=[0, 0, 1, 0.94])
plt.savefig('/workspace/request-project/Stereographic/NewLandscapes/Demos/demo02_fisher_sphere.png',
            dpi=150, bbox_inches='tight')
plt.close()
print("✅ Demo 02: Fisher Sphere — Information Geometry on S² saved.")
