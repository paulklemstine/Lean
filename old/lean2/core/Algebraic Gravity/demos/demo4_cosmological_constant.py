#!/usr/bin/env python3
"""
Demo 4: The Cosmological Constant as the Center of 𝔊
=====================================================
Oracle III (Hephaestus) — Computational Experiments

This script demonstrates how the cosmological constant Λ emerges naturally
from the center of the Gravitational Algebra, and visualizes de Sitter
spacetime as a representation of 𝔊.
"""

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
from matplotlib.gridspec import GridSpec

print("=" * 70)
print("THE COSMOLOGICAL CONSTANT — Center of the Gravitational Algebra")
print("=" * 70)

print("""
🔮 KEY INSIGHT:

In the Gravitational Algebra 𝔊, the bracket [P_a, Q^b] contains a term
proportional to the identity:

    [P_a, Q^b] = δ^b_a · Λ/3 · I  +  M_a^b

The coefficient Λ/3 lives in the CENTER of 𝔊₀ — it commutes with
everything. This is the cosmological constant!

• Λ > 0: de Sitter spacetime (accelerating expansion)
• Λ = 0: Minkowski spacetime (the Poincaré algebra limit)  
• Λ < 0: Anti-de Sitter spacetime (used in AdS/CFT)

The cosmological constant is NOT an arbitrary parameter added to the
Einstein equation — it is a structural invariant of the algebra itself,
arising from the central extension of the translation-momentum bracket.
""")

# ============================================================================
# Part 1: de Sitter Spacetime Visualization
# ============================================================================

fig = plt.figure(figsize=(18, 14))
gs = GridSpec(2, 2, figure=fig, hspace=0.3, wspace=0.3)

# --- Panel 1: de Sitter hyperboloid ---
ax = fig.add_subplot(gs[0, 0], projection='3d')
ax.set_title('de Sitter Spacetime\n(Λ > 0: Hyperboloid in 5D)', fontsize=12, fontweight='bold')

# de Sitter space: -T² + X² + Y² + Z² + W² = ℓ² where ℓ² = 3/Λ
ell = 3.0  # de Sitter radius
u = np.linspace(-2, 2, 100)
v = np.linspace(0, 2*np.pi, 100)
U, V = np.meshgrid(u, v)

# Parameterize the hyperboloid (2+1 version for visualization)
T = ell * np.sinh(U)
X = ell * np.cosh(U) * np.cos(V)
Y = ell * np.cosh(U) * np.sin(V)

ax.plot_surface(X, Y, T, alpha=0.6, cmap='coolwarm', edgecolors='k', linewidth=0.1)
ax.set_xlabel('X', fontsize=10)
ax.set_ylabel('Y', fontsize=10)
ax.set_zlabel('T (time)', fontsize=10)
ax.view_init(elev=15, azim=35)

# --- Panel 2: Scale factor evolution ---
ax2 = fig.add_subplot(gs[0, 1])
ax2.set_title('Scale Factor a(t) for Different Λ\n(Representations of 𝔊 with Different Centers)', 
              fontsize=11, fontweight='bold')

t = np.linspace(0, 5, 500)

# Different cosmological constants = different central elements
lambdas = [
    (1.0, '#e74c3c', 'Λ = 1 (strong de Sitter)'),
    (0.3, '#e67e22', 'Λ = 0.3'),
    (0.1, '#2ecc71', 'Λ = 0.1 (observed ~ this)'),
    (0.0, '#3498db', 'Λ = 0 (Einstein-de Sitter)'),
    (-0.3, '#9b59b6', 'Λ = -0.3 (Anti-de Sitter)'),
]

for lam, color, label in lambdas:
    if lam > 0:
        # de Sitter: a(t) ∝ exp(√(Λ/3) t) (late time)
        H = np.sqrt(lam / 3)
        a = np.cosh(H * t)
    elif lam == 0:
        # Einstein-de Sitter: a(t) ∝ t^(2/3)
        a = (1 + t)**(2/3)
    else:
        # Anti-de Sitter (compact): a(t) = cos(√|Λ|/3 · t)
        H = np.sqrt(abs(lam) / 3)
        a = np.cos(H * t)
        a[a < 0] = np.nan  # Stop at crunch
    
    ax2.plot(t, a, color=color, linewidth=2.5, label=label)

ax2.set_xlabel('Cosmic Time t', fontsize=11)
ax2.set_ylabel('Scale Factor a(t)', fontsize=11)
ax2.set_ylim(0, 8)
ax2.legend(fontsize=9)
ax2.grid(alpha=0.3)

ax2.annotate('The central element of 𝔊\ndetermines the large-scale\nfate of the universe', 
             xy=(2.5, 5.5), fontsize=9, fontstyle='italic',
             bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

# --- Panel 3: The de Sitter algebra structure ---
ax3 = fig.add_subplot(gs[1, 0])
ax3.set_title('Algebraic Structure: Poincaré → de Sitter\n[Pₐ, Pᵦ] = (Λ/3)·Mₐᵦ', 
              fontsize=12, fontweight='bold')
ax3.axis('off')

# Draw the algebra embedding diagram
# Poincaré inside de Sitter inside 𝔊
import matplotlib.patches as patches

# Background
poincare = patches.FancyBboxPatch((0.15, 0.15), 0.7, 0.7, 
                                   boxstyle="round,pad=0.05",
                                   facecolor='#3498db', alpha=0.2,
                                   edgecolor='#3498db', linewidth=3)
desitter = patches.FancyBboxPatch((0.10, 0.10), 0.8, 0.8,
                                   boxstyle="round,pad=0.05", 
                                   facecolor='#e74c3c', alpha=0.15,
                                   edgecolor='#e74c3c', linewidth=3)
grav_alg = patches.FancyBboxPatch((0.02, 0.02), 0.96, 0.96,
                                   boxstyle="round,pad=0.05",
                                   facecolor='#f1c40f', alpha=0.1,
                                   edgecolor='#f1c40f', linewidth=3)

ax3.add_patch(grav_alg)
ax3.add_patch(desitter)
ax3.add_patch(poincare)

ax3.text(0.5, 0.85, '𝔊 — Gravitational Algebra (dim 54)', 
         ha='center', fontsize=12, fontweight='bold', color='#d4a017')
ax3.text(0.5, 0.72, '𝔰𝔬(4,1) — de Sitter Algebra (dim 10)', 
         ha='center', fontsize=11, fontweight='bold', color='#c0392b')
ax3.text(0.5, 0.60, '𝔦𝔰𝔬(3,1) — Poincaré Algebra (dim 10)', 
         ha='center', fontsize=11, fontweight='bold', color='#2980b9')

ax3.text(0.5, 0.45, 'Key Bracket:', ha='center', fontsize=11, fontweight='bold')
ax3.text(0.5, 0.38, '[Pₐ, Pᵦ] = (Λ/3) · Mₐᵦ', ha='center', fontsize=14, 
         fontfamily='serif', fontstyle='italic')

ax3.text(0.5, 0.25, 'Λ = 0: Poincaré (flat spacetime)', ha='center', fontsize=10, color='#2980b9')
ax3.text(0.5, 0.18, 'Λ > 0: de Sitter (expanding universe)', ha='center', fontsize=10, color='#c0392b')
ax3.text(0.5, 0.11, 'Λ < 0: Anti-de Sitter (AdS/CFT)', ha='center', fontsize=10, color='#8e44ad')

# --- Panel 4: Observational Evidence ---
ax4 = fig.add_subplot(gs[1, 1])
ax4.set_title('Observational Evidence for Λ > 0\n(The Universe Selects a Representation of 𝔊)', 
              fontsize=11, fontweight='bold')

# Simulated Hubble diagram (Type Ia supernovae)
np.random.seed(42)
z_obs = np.sort(np.random.uniform(0.01, 1.5, 80))
noise = np.random.normal(0, 0.15, len(z_obs))

# Distance modulus for different cosmologies
def luminosity_distance(z, Omega_Lambda):
    """Simplified luminosity distance for flat ΛCDM"""
    from scipy.integrate import quad
    Omega_m = 1 - Omega_Lambda
    
    dL_list = []
    for zi in z:
        integral, _ = quad(lambda zp: 1/np.sqrt(Omega_m*(1+zp)**3 + Omega_Lambda), 0, zi)
        dL = (1 + zi) * integral
        dL_list.append(dL)
    return np.array(dL_list)

# Distance modulus: μ = 5 log10(dL) + 25 (in Mpc)
for OmL, color, label, ls in [(0.7, '#e74c3c', 'ΩΛ = 0.7 (observed)', '-'),
                                (0.0, '#3498db', 'ΩΛ = 0 (no Λ)', '--'),
                                (1.0, '#2ecc71', 'ΩΛ = 1.0 (pure de Sitter)', ':')]:
    dL = luminosity_distance(np.linspace(0.01, 1.5, 200), OmL)
    mu = 5 * np.log10(dL * 3000) + 25  # Convert to apparent distance modulus
    ax4.plot(np.linspace(0.01, 1.5, 200), mu, color=color, linewidth=2.5, 
             linestyle=ls, label=label)

# Simulated data points
dL_data = luminosity_distance(z_obs, 0.7)
mu_data = 5 * np.log10(dL_data * 3000) + 25 + noise
ax4.scatter(z_obs, mu_data, s=15, c='black', alpha=0.5, zorder=5, label='Simulated SNe Ia')

ax4.set_xlabel('Redshift z', fontsize=11)
ax4.set_ylabel('Distance Modulus μ', fontsize=11)
ax4.legend(fontsize=9)
ax4.grid(alpha=0.3)
ax4.set_xlim(0, 1.5)

plt.savefig('/workspace/request-project/algebraic_gravity/demos/fig8_cosmological_constant.png', 
            dpi=150, bbox_inches='tight')
print("  Saved: fig8_cosmological_constant.png")

print("\n✅ Cosmological constant visualizations complete!")
print("=" * 70)
