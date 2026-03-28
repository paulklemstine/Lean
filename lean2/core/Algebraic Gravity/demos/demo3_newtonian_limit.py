#!/usr/bin/env python3
"""
Demo 3: The Newtonian Limit as an Algebraic Contraction
========================================================
Oracle III (Hephaestus) — Computational Experiments

This script demonstrates how the Newtonian limit of gravity emerges as
an Inönü-Wigner contraction of the Gravitational Algebra 𝔊, and
visualizes the transition from relativistic to Newtonian gravity.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec
from scipy.integrate import solve_ivp

print("=" * 70)
print("THE NEWTONIAN LIMIT — Algebraic Contraction of 𝔊")
print("=" * 70)

# ============================================================================
# Part 1: Inönü-Wigner Contraction
# ============================================================================

print("\n📐 Inönü-Wigner Contraction: 𝔊 → 𝔊_Newton")
print("-" * 50)

print("""
The contraction parameter is ε = v/c (ratio of typical velocity to speed of light).

As ε → 0:
  • The Lorentz algebra 𝔰𝔬(3,1) contracts to the Galilean algebra:
    - Rotations J_i remain unchanged
    - Boosts K_i → εK_i (become Galilean boosts)
    - [K_i, K_j] = -ε²·ε_ijk J_k → 0 (boosts commute in Newton)
    
  • The bracket [P_0, P_i] = λ·R_0i → Newtonian tidal force
  
  • The Einstein equation [R, T] = 0 in 𝔊₀ contracts to:
    ∇²Φ = 4πGρ  (Poisson equation)
    
  • The full 54-dimensional 𝔊 contracts to a 14-dimensional algebra:
    𝔊_Newton = {J_i, K_i, P_0, P_i, Φ, ρ, Ξ_ij}
    where Φ is the gravitational potential, ρ is mass density,
    and Ξ_ij are the Newtonian tidal tensor components.
""")

# ============================================================================
# Part 2: Orbit Comparison — Relativistic vs. Newtonian
# ============================================================================

print("🌀 Computing Orbit Comparison...")

M = 1.0  # Central mass
rs = 2 * M  # Schwarzschild radius

fig = plt.figure(figsize=(18, 16))
gs = GridSpec(3, 2, figure=fig, hspace=0.35, wspace=0.3)

# --- Panel 1: Relativistic vs Newtonian Orbits ---
ax = fig.add_subplot(gs[0, 0], projection='polar')
ax.set_title('Newtonian Orbit (no precession)\nContracted Algebra 𝔊_Newton', 
             fontsize=11, fontweight='bold', pad=15)

# Newtonian orbit: u = (M/L²)(1 + e·cos(φ))
L = 4.5
e = 0.5  # Eccentricity
phi = np.linspace(0, 6*np.pi, 2000)
r_newton = L**2 / (M * (1 + e * np.cos(phi)))
ax.plot(phi, r_newton, 'b-', linewidth=1.5, alpha=0.7, label='Newtonian')
theta_circ = np.linspace(0, 2*np.pi, 100)
ax.fill(theta_circ, np.full_like(theta_circ, rs), color='black', alpha=0.5)
ax.set_rmax(35)
ax.grid(alpha=0.3)

# Relativistic orbit with precession
ax2 = fig.add_subplot(gs[0, 1], projection='polar')
ax2.set_title('Relativistic Orbit (with precession)\nFull Algebra 𝔊', 
              fontsize=11, fontweight='bold', pad=15)

def geodesic_eq(phi, y):
    u, du = y
    return [du, -u + M/L**2 + 3*M*u**2]

u0 = M / (L**2) * (1 + e)
du0 = 0
sol = solve_ivp(geodesic_eq, (0, 6*np.pi), [u0, du0],
                t_eval=np.linspace(0, 6*np.pi, 3000),
                rtol=1e-12, atol=1e-14, method='DOP853')

r_rel = 1.0 / sol.y[0]
mask = (r_rel > rs) & (r_rel < 100)
ax2.plot(sol.t[mask], r_rel[mask], 'r-', linewidth=1.5, alpha=0.7, label='GR (𝔊)')
ax2.fill(theta_circ, np.full_like(theta_circ, rs), color='black', alpha=0.5)
ax2.set_rmax(35)
ax2.grid(alpha=0.3)

# --- Panel 2: Contraction Parameter Effect ---
ax3 = fig.add_subplot(gs[1, :])
ax3.set_title('Perihelion Precession vs. Contraction Parameter ε = rₛ/r\n'
              'Transition from Full 𝔊 to Contracted 𝔊_Newton', 
              fontsize=12, fontweight='bold')

# Precession angle per orbit: Δφ ≈ 6πM/a(1-e²) = 6πM²/(L²) in first order
L_values = np.linspace(3.5, 20, 100)
epsilon_values = M / (L_values**2 / M)  # ~ rs/r_peri
precession_gr = 6 * np.pi * M**2 / L_values**2  # Radians per orbit

# In degrees
precession_deg = np.degrees(precession_gr) * 3600  # Arcseconds

ax3.semilogy(1/L_values**2, precession_deg, 'r-', linewidth=2.5, label='GR Precession (full 𝔊)')
ax3.axhline(y=43, color='green', linewidth=2, linestyle='--', 
            label="Mercury's observed precession (43\"/century)")

ax3.set_xlabel('ε² = (M/L)² ∝ (v/c)²  [Contraction Parameter]', fontsize=11)
ax3.set_ylabel('Precession per orbit (arcseconds)', fontsize=11)
ax3.legend(fontsize=10)
ax3.grid(alpha=0.3)

ax3.annotate('As ε → 0:\n𝔊 contracts to 𝔊_Newton\nPrecession → 0\n(Closed ellipses)', 
             xy=(0.005, 10), fontsize=10, fontstyle='italic',
             bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

ax3.annotate('Strong field:\n𝔊 structure fully active\n(Large precession)', 
             xy=(0.07, 3000), fontsize=10, fontstyle='italic',
             bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

# --- Panel 3: Potential Comparison ---
ax4 = fig.add_subplot(gs[2, 0])
ax4.set_title('Gravitational Potential\n𝔊 vs. 𝔊_Newton', fontsize=12, fontweight='bold')

r = np.linspace(2.5, 30, 500)
L_pot = 4.0

V_newton = -M/r + L_pot**2/(2*r**2)
V_gr = -M/r + L_pot**2/(2*r**2) - M*L_pot**2/r**3

ax4.plot(r, V_newton, 'b-', linewidth=2.5, label='Newtonian (𝔊_Newton)')
ax4.plot(r, V_gr, 'r-', linewidth=2.5, label='General Relativity (𝔊)')
ax4.fill_between(r, V_newton, V_gr, alpha=0.2, color='purple', 
                 label='Algebraic correction term\n−ML²/r³')

ax4.axhline(y=0, color='gray', linewidth=0.5)
ax4.axvline(x=rs, color='black', linewidth=1, linestyle=':', alpha=0.5, label='Horizon (rₛ)')
ax4.set_xlabel('r / M', fontsize=11)
ax4.set_ylabel('V_eff', fontsize=11)
ax4.set_xlim(2, 25)
ax4.set_ylim(-0.15, 0.06)
ax4.legend(fontsize=9)
ax4.grid(alpha=0.3)

# --- Panel 4: Algebra Dimension as a Function of Contraction ---
ax5 = fig.add_subplot(gs[2, 1])
ax5.set_title('Algebra Dimension During Contraction\nProgressive Simplification', 
              fontsize=12, fontweight='bold')

# Schematic: as ε→0, effective degrees of freedom decrease
epsilon_contract = np.linspace(0, 1, 100)

# Full 𝔊 has dim 54, contracted 𝔊_Newton has fewer active components
# This is schematic — showing how components "decouple"
dim_active = 14 + 40 * (1 - np.exp(-5 * epsilon_contract**2))

ax5.fill_between(epsilon_contract, 0, dim_active, alpha=0.3, color='#3498db')
ax5.plot(epsilon_contract, dim_active, 'b-', linewidth=2.5)

# Add grade labels
ax5.axhline(y=54, color='red', linewidth=1, linestyle='--', label='Full 𝔊 (dim 54)')
ax5.axhline(y=14, color='blue', linewidth=1, linestyle='--', label='𝔊_Newton (dim 14)')
ax5.axhline(y=10, color='green', linewidth=1, linestyle='--', label='Poincaré (dim 10)')

ax5.set_xlabel('ε = v/c (Contraction Parameter)', fontsize=11)
ax5.set_ylabel('Effective Algebraic Dimension', fontsize=11)
ax5.set_xlim(0, 1)
ax5.set_ylim(0, 60)
ax5.legend(fontsize=9)
ax5.grid(alpha=0.3)

# Add regions
ax5.fill_betweenx([0, 60], 0, 0.1, alpha=0.1, color='blue')
ax5.fill_betweenx([0, 60], 0.1, 0.5, alpha=0.1, color='green')
ax5.fill_betweenx([0, 60], 0.5, 1.0, alpha=0.1, color='red')

ax5.text(0.03, 55, 'Newtonian\nRegime', fontsize=9, fontweight='bold', color='blue')
ax5.text(0.25, 55, 'Post-Newtonian', fontsize=9, fontweight='bold', color='green')
ax5.text(0.7, 55, 'Strong\nField', fontsize=9, fontweight='bold', color='red')

plt.savefig('/workspace/request-project/algebraic_gravity/demos/fig6_newtonian_limit.png', 
            dpi=150, bbox_inches='tight')
print("  Saved: fig6_newtonian_limit.png")

# ============================================================================
# Part 3: The Poisson Equation from Algebraic Contraction
# ============================================================================

print("\n📊 Visualizing the Poisson Equation...")

fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

# Solve Poisson equation for a point mass: ∇²Φ = 4πGρ
# Solution: Φ = -GM/r

# Panel 1: Potential
ax = axes[0]
x = np.linspace(-5, 5, 300)
y = np.linspace(-5, 5, 300)
X, Y = np.meshgrid(x, y)
R = np.sqrt(X**2 + Y**2)
R[R < 0.3] = 0.3  # Regularize

Phi = -M / R

im = ax.contourf(X, Y, Phi, levels=30, cmap='inferno')
plt.colorbar(im, ax=ax, label='Φ (potential)')
ax.set_title('Newtonian Potential Φ\n(from contracted 𝔊₋₂)', fontsize=12, fontweight='bold')
ax.set_xlabel('x / M')
ax.set_ylabel('y / M')
ax.set_aspect('equal')
ax.plot(0, 0, 'w*', markersize=15)

# Panel 2: Force field
ax = axes[1]
# Compute gradient
Fx = M * X / R**3
Fy = M * Y / R**3

# Subsample for quiver
skip = 15
ax.quiver(X[::skip, ::skip], Y[::skip, ::skip], 
          -Fx[::skip, ::skip], -Fy[::skip, ::skip],
          np.sqrt(Fx[::skip, ::skip]**2 + Fy[::skip, ::skip]**2),
          cmap='hot', alpha=0.8)
ax.set_title('Gravitational Force Field\n(Action of 𝔊_Newton)', fontsize=12, fontweight='bold')
ax.set_xlabel('x / M')
ax.set_ylabel('y / M')
ax.set_aspect('equal')
ax.set_xlim(-5, 5)
ax.set_ylim(-5, 5)
ax.plot(0, 0, 'r*', markersize=15)

# Panel 3: Tidal tensor (second derivatives)
ax = axes[2]
# Tidal tensor: ∂²Φ/∂x² = M(3x²-r²)/r⁵
Txx = M * (3*X**2 - R**2) / R**5
im = ax.contourf(X, Y, Txx, levels=30, cmap='RdBu_r', vmin=-2, vmax=2)
plt.colorbar(im, ax=ax, label='∂²Φ/∂x² (tidal force)')
ax.set_title('Newtonian Tidal Tensor\n(Contracted 𝔊₋₂ Element)', fontsize=12, fontweight='bold')
ax.set_xlabel('x / M')
ax.set_ylabel('y / M')
ax.set_aspect('equal')
ax.plot(0, 0, 'k*', markersize=15)

plt.tight_layout()
plt.savefig('/workspace/request-project/algebraic_gravity/demos/fig7_poisson_equation.png', 
            dpi=150, bbox_inches='tight')
print("  Saved: fig7_poisson_equation.png")

print("\n✅ Newtonian limit visualizations complete!")
print("=" * 70)
