#!/usr/bin/env python3
"""
Demo 07: Stereographic Information Geometry
=============================================
The Fisher information metric on statistical manifolds, viewed through the
lens of inverse stereographic projection. The space of probability distributions
is compactified onto a sphere.

Oracle Ξ's Discovery: The Gaussian manifold (μ, σ) with Fisher metric
is the hyperbolic half-plane. Stereographic projection maps this to a 
compact piece of the sphere, with maximum-entropy distributions at infinity
mapping to the north pole.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib import cm
from mpl_toolkits.mplot3d import Axes3D

def inverse_stereo_2d(y1, y2):
    D = 1.0 + y1**2 + y2**2
    return 2*y1/D, 2*y2/D, (D-2)/D

def fisher_metric_gaussian(mu, sigma):
    """
    Fisher information metric for N(μ, σ²):
    ds² = (1/σ²)dμ² + (2/σ²)dσ²
    
    This is the Poincaré half-plane metric (up to constant).
    Returns the metric tensor components g_11, g_12, g_22
    """
    return 1.0/sigma**2, 0.0, 2.0/sigma**2

def kl_divergence_gaussian(mu1, s1, mu2, s2):
    """KL divergence between two Gaussians"""
    return np.log(s2/s1) + (s1**2 + (mu1-mu2)**2)/(2*s2**2) - 0.5

def conformal_kl(mu1, s1, mu2, s2):
    """Conformally weighted KL divergence in stereographic coordinates"""
    kl = kl_divergence_gaussian(mu1, s1, mu2, s2)
    D1 = 1 + mu1**2 + s1**2
    D2 = 1 + mu2**2 + s2**2
    lambda1 = 2.0/D1
    lambda2 = 2.0/D2
    return kl + np.log(lambda1/lambda2)

fig = plt.figure(figsize=(20, 16))
fig.suptitle("Stereographic Information Geometry:\nProbability Distributions on the Sphere",
             fontsize=16, fontweight='bold', y=0.98)

# --- Panel 1: Gaussian manifold in (μ, σ) half-plane ---
ax1 = fig.add_subplot(2, 3, 1)
mu_range = np.linspace(-3, 3, 30)
sigma_range = np.linspace(0.1, 4, 30)
MU, SIGMA = np.meshgrid(mu_range, sigma_range)

# Color by Fisher "distance" from standard normal N(0,1)
KL_from_standard = kl_divergence_gaussian(MU, SIGMA, 0, 1)
im = ax1.pcolormesh(MU, SIGMA, np.log1p(KL_from_standard), cmap='inferno', shading='auto')
plt.colorbar(im, ax=ax1, label='log(1 + KL(N(μ,σ²) ‖ N(0,1)))')

# Geodesics in the Poincaré half-plane (semicircles centered on μ-axis)
for center in [-2, -1, 0, 1, 2]:
    for radius in [0.5, 1, 2, 3]:
        theta = np.linspace(0.01, np.pi-0.01, 100)
        geo_mu = center + radius * np.cos(theta)
        geo_sigma = radius * np.sin(theta)
        mask = geo_sigma > 0.1
        ax1.plot(geo_mu[mask], geo_sigma[mask], 'w-', linewidth=0.5, alpha=0.4)

ax1.set_xlabel('μ (mean)', fontsize=12)
ax1.set_ylabel('σ (std dev)', fontsize=12)
ax1.set_title('Gaussian Manifold (μ, σ)\nPoincaré Half-Plane', fontsize=13)

# --- Panel 2: Gaussian manifold on the sphere ---
ax2 = fig.add_subplot(2, 3, 2, projection='3d')

mu_pts = np.linspace(-3, 3, 50)
sigma_pts = np.linspace(0.2, 4, 50)
MU_f, SIG_f = np.meshgrid(mu_pts, sigma_pts)
mu_flat = MU_f.flatten()
sig_flat = SIG_f.flatten()

# Map to sphere
x1, x2, x3 = inverse_stereo_2d(mu_flat, sig_flat)
kl_flat = kl_divergence_gaussian(mu_flat, sig_flat, 0, 1)

sc = ax2.scatter(x1, x2, x3, c=np.log1p(kl_flat), cmap='inferno', s=2, alpha=0.6)

# Sphere wireframe
u_s = np.linspace(0, 2*np.pi, 30)
v_s = np.linspace(0, np.pi, 15)
xs_w = np.outer(np.cos(u_s), np.sin(v_s))
ys_w = np.outer(np.sin(u_s), np.sin(v_s))
zs_w = np.outer(np.ones_like(u_s), np.cos(v_s))
ax2.plot_wireframe(xs_w, ys_w, zs_w, color='lightblue', alpha=0.05, linewidth=0.2)

# Mark standard normal
x0, y0, z0 = inverse_stereo_2d(np.array([0.0]), np.array([1.0]))
ax2.scatter(x0, y0, z0, color='lime', s=100, zorder=5, marker='*')
ax2.text(x0[0], y0[0], z0[0]+0.15, 'N(0,1)', fontsize=10, color='lime')

ax2.set_title('Gaussian Manifold on S²\n(Stereographic Embedding)', fontsize=13)
ax2.set_box_aspect([1, 1, 1])
ax2.view_init(elev=25, azim=-50)

# --- Panel 3: KL divergence level sets ---
ax3 = fig.add_subplot(2, 3, 3)
KL_levels = [0.1, 0.5, 1, 2, 5, 10]
colors_kl = cm.cool(np.linspace(0.2, 0.9, len(KL_levels)))

theta = np.linspace(0, 2*np.pi, 500)
for kl_val, col in zip(KL_levels, colors_kl):
    # Approximate KL level set as ellipse in (μ, log σ) coordinates
    # KL = log(1/σ) + (σ² + μ²)/2 - 1/2
    # For level set, parametrize:
    mus = np.sqrt(2*kl_val) * np.cos(theta)
    # This is approximate
    sigmas = np.exp(np.sqrt(kl_val) * np.sin(theta))
    mask = sigmas > 0.05
    ax3.plot(mus[mask], sigmas[mask], color=col, linewidth=1.5,
             label=f'KL = {kl_val}')

ax3.set_xlabel('μ', fontsize=12)
ax3.set_ylabel('σ', fontsize=12)
ax3.set_title('KL Divergence Level Sets\nfrom N(0,1)', fontsize=13)
ax3.legend(fontsize=9)
ax3.set_xlim(-5, 5)
ax3.set_ylim(0, 5)
ax3.grid(True, alpha=0.3)

# --- Panel 4: Conformal vs standard KL divergence ---
ax4 = fig.add_subplot(2, 3, 4)
np.random.seed(42)

mus = np.random.randn(200) * 2
sigmas = np.abs(np.random.randn(200)) + 0.3
kl_standard = kl_divergence_gaussian(mus, sigmas, 0, 1)
kl_conformal = conformal_kl(mus, sigmas, 0, 1)

ax4.scatter(kl_standard, kl_conformal, c=sigmas, cmap='viridis', s=20, alpha=0.7)
ax4.plot([0, 20], [0, 20], 'r--', linewidth=1, label='y=x (no correction)')
ax4.set_xlabel('Standard KL(p ‖ N(0,1))', fontsize=12)
ax4.set_ylabel('Conformal KL (stereographic)', fontsize=12)
ax4.set_title('Standard vs Conformal\nKL Divergence', fontsize=13)
ax4.legend()
ax4.grid(True, alpha=0.3)
ax4.set_xlim(0, 15)
ax4.set_ylim(-5, 20)
cbar = plt.colorbar(ax4.collections[0], ax=ax4, label='σ')

# --- Panel 5: Geodesics on the sphere ---
ax5 = fig.add_subplot(2, 3, 5, projection='3d')
ax5.plot_wireframe(xs_w, ys_w, zs_w, color='lightblue', alpha=0.05, linewidth=0.2)

# Geodesics in Poincaré half-plane → great circle arcs on sphere
for center in [-3, -1.5, 0, 1.5, 3]:
    for radius in [0.5, 1.5, 3.0]:
        theta = np.linspace(0.02, np.pi-0.02, 200)
        geo_mu = center + radius * np.cos(theta)
        geo_sigma = radius * np.sin(theta)
        mask = geo_sigma > 0.05
        gx1, gx2, gx3 = inverse_stereo_2d(geo_mu[mask], geo_sigma[mask])
        ax5.plot(gx1, gx2, gx3, linewidth=1.0, alpha=0.7,
                 color=cm.Set2(abs(center)/4))

ax5.scatter(x0, y0, z0, color='lime', s=100, zorder=5, marker='*')
ax5.set_title('Fisher Geodesics on S²\n(Information geometry paths)', fontsize=13)
ax5.set_box_aspect([1, 1, 1])
ax5.view_init(elev=30, azim=-40)

# --- Panel 6: Entropy landscape ---
ax6 = fig.add_subplot(2, 3, 6)
# Entropy of N(μ, σ²) = ½ log(2πeσ²)
MU_e, SIG_e = np.meshgrid(np.linspace(-3, 3, 200), np.linspace(0.1, 4, 200))
entropy = 0.5 * np.log(2 * np.pi * np.e * SIG_e**2)
conformal = 2.0 / (1 + MU_e**2 + SIG_e**2)
# "Stereographic entropy" = entropy weighted by conformal factor
stereo_entropy = entropy * conformal

im = ax6.pcolormesh(MU_e, SIG_e, stereo_entropy, cmap='RdYlBu_r', shading='auto')
plt.colorbar(im, ax=ax6, label='Conformally weighted entropy')
ax6.set_xlabel('μ', fontsize=12)
ax6.set_ylabel('σ', fontsize=12)
ax6.set_title('Stereographic Entropy\nH(p) · λ(μ,σ)', fontsize=13)
ax6.contour(MU_e, SIG_e, stereo_entropy, levels=10, colors='black', linewidths=0.5, alpha=0.5)

plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.savefig('/workspace/request-project/demos/demo07_information_geometry.png',
            dpi=150, bbox_inches='tight')
plt.close()
print("✅ Demo 07 saved: demos/demo07_information_geometry.png")
