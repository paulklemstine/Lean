#!/usr/bin/env python3
"""
Demo 2: Representations of 𝔊 and Geodesic Motion
=================================================
Oracle III (Hephaestus) — Computational Experiments

This script demonstrates how solutions of Einstein's equations correspond
to representations of the Gravitational Algebra, and visualizes geodesic
motion as orbits under the algebra's action.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec
from scipy.integrate import solve_ivp

# ============================================================================
# Part 1: The Schwarzschild Representation
# ============================================================================

print("=" * 70)
print("REPRESENTATIONS OF 𝔊 — Solutions as Algebraic Objects")
print("=" * 70)

# Physical constants (geometrized units: G = c = 1)
M = 1.0  # Mass parameter (in units where r_s = 2M = 2)
rs = 2 * M  # Schwarzschild radius

def schwarzschild_metric(r, theta=np.pi/2):
    """
    The Schwarzschild metric components at radius r.
    In the algebraic framework, this is the 'state vector' in the
    representation space of 𝔊.
    
    ds² = -(1-rₛ/r)dt² + (1-rₛ/r)⁻¹dr² + r²(dθ² + sin²θ dφ²)
    """
    f = 1 - rs / r
    g = np.diag([-f, 1/f, r**2, r**2 * np.sin(theta)**2])
    return g

def effective_potential(r, L, particle_type='massive'):
    """
    Effective potential for geodesic motion.
    
    V_eff(r) = -M/r + L²/(2r²) - ML²/r³    (massive)
    V_eff(r) = L²/(2r²) - ML²/r³             (massless)
    
    In the algebraic framework, this is the Casimir eigenvalue of the
    representation: the orbit is determined by which irreducible
    representation of 𝔊 the particle lives in.
    """
    if particle_type == 'massive':
        return -M/r + L**2/(2*r**2) - M*L**2/r**3
    else:
        return L**2/(2*r**2) - M*L**2/r**3

def geodesic_equations(phi, y, L, E):
    """
    Geodesic equations in Schwarzschild spacetime, parameterized by φ.
    u = 1/r, du/dφ = u'
    
    u'' + u = 3Mu² + M/L²   (massive particles)
    
    In the algebraic framework, this is the equation of motion generated
    by the action of 𝔊 on the representation space.
    """
    u, du_dphi = y
    d2u_dphi2 = -u + 3*M*u**2 + M/L**2
    return [du_dphi, d2u_dphi2]

# ============================================================================
# Part 2: Geodesic Orbits — Visualization
# ============================================================================

print("\n🌀 Computing Geodesic Orbits...")

fig = plt.figure(figsize=(18, 14))
gs = GridSpec(2, 2, figure=fig, hspace=0.3, wspace=0.3)

# --- Panel 1: Effective Potential ---
ax1 = fig.add_subplot(gs[0, 0])
ax1.set_title('Effective Potential V_eff(r)\nCasimir Eigenvalue of 𝔊 Representation', 
              fontsize=12, fontweight='bold')

r_range = np.linspace(2.1, 30, 1000)
for L, color, label in [(3.0, '#e74c3c', 'L = 3M'), 
                          (3.464, '#2ecc71', 'L = 2√3 M (ISCO)'),
                          (4.0, '#3498db', 'L = 4M'),
                          (5.0, '#9b59b6', 'L = 5M')]:
    V = effective_potential(r_range, L)
    ax1.plot(r_range, V, color=color, linewidth=2, label=label)

ax1.axhline(y=0, color='gray', linewidth=0.5, linestyle='-')
ax1.axvline(x=rs, color='black', linewidth=1, linestyle=':', alpha=0.5, label='Horizon')
ax1.set_xlabel('r / M', fontsize=11)
ax1.set_ylabel('V_eff', fontsize=11)
ax1.set_xlim(2, 25)
ax1.set_ylim(-0.1, 0.05)
ax1.legend(fontsize=9)
ax1.grid(alpha=0.3)

# Annotate algebraic meaning
ax1.annotate('Each curve = different\nirreducible representation\nof the Poincaré subalgebra', 
             xy=(15, -0.02), fontsize=9, fontstyle='italic',
             bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

# --- Panel 2: Bound Orbits (Elliptical + Precessing) ---
ax2 = fig.add_subplot(gs[0, 1], projection='polar')
ax2.set_title('Precessing Orbit in 𝔊\n(Bound Representation)', fontsize=12, fontweight='bold',
              pad=20)

# Compute a precessing orbit
L = 4.2
E_squared = 0.95  # Slightly bound
u0 = 1/10.0  # Start at r = 10M
du0 = 0.0

phi_span = (0, 12 * np.pi)
phi_eval = np.linspace(*phi_span, 5000)

sol = solve_ivp(geodesic_equations, phi_span, [u0, du0], args=(L, np.sqrt(E_squared)),
                t_eval=phi_eval, rtol=1e-10, atol=1e-12, method='DOP853')

r_orbit = 1.0 / sol.y[0]
# Filter out unphysical values
mask = (r_orbit > rs) & (r_orbit < 100)
phi_plot = sol.t[mask]
r_plot = r_orbit[mask]

ax2.plot(phi_plot, r_plot, color='#3498db', linewidth=0.8, alpha=0.8)
ax2.plot(0, 0, 'ko', markersize=8)  # Central mass
circle_theta = np.linspace(0, 2*np.pi, 100)
ax2.fill(circle_theta, np.full_like(circle_theta, rs), color='black', alpha=0.8)
ax2.set_rmax(20)
ax2.set_rticks([5, 10, 15, 20])
ax2.grid(alpha=0.3)

# --- Panel 3: Light Deflection ---
ax3 = fig.add_subplot(gs[1, 0], projection='polar')
ax3.set_title('Photon Orbits in 𝔊\n(Null Representations)', fontsize=12, fontweight='bold',
              pad=20)

# Multiple photon trajectories at different impact parameters
for b, color, alpha in [(2.8, '#e74c3c', 0.9), (3.0, '#e67e22', 0.9),
                          (3.5, '#f1c40f', 0.9), (4.0, '#2ecc71', 0.9),
                          (5.0, '#3498db', 0.9), (7.0, '#9b59b6', 0.9),
                          (10.0, '#8e44ad', 0.7)]:
    
    # For photons: u'' + u = 3Mu²
    def photon_eq(phi, y):
        u, du = y
        return [du, -u + 3*M*u**2]
    
    u0_photon = 1e-4  # Start far away
    du0_photon = 1/b   # Impact parameter b
    
    sol_photon = solve_ivp(photon_eq, (0, 3*np.pi), [u0_photon, du0_photon],
                           t_eval=np.linspace(0, 3*np.pi, 3000),
                           rtol=1e-10, atol=1e-12, method='DOP853',
                           events=None)
    
    r_photon = 1.0 / sol_photon.y[0]
    mask_p = (r_photon > rs) & (r_photon < 50)
    
    if np.sum(mask_p) > 10:
        ax3.plot(sol_photon.t[mask_p], r_photon[mask_p], color=color, 
                linewidth=1.5, alpha=alpha, label=f'b={b:.1f}M')

ax3.fill(circle_theta, np.full_like(circle_theta, rs), color='black', alpha=0.8)
ax3.set_rmax(25)
ax3.grid(alpha=0.3)
ax3.legend(fontsize=7, loc='upper right', bbox_to_anchor=(1.3, 1.0))

# --- Panel 4: Algebraic Classification of Orbits ---
ax4 = fig.add_subplot(gs[1, 1])
ax4.set_title('Algebraic Classification of Orbits\nin 𝔊 Representation Space', 
              fontsize=12, fontweight='bold')

# Create a phase diagram: (L, E) space
L_range = np.linspace(2.5, 8, 200)
E_range = np.linspace(0.9, 1.1, 200)
L_grid, E_grid = np.meshgrid(L_range, E_range)

# Classify orbits based on effective potential
orbit_type = np.zeros_like(L_grid)
for i in range(len(E_range)):
    for j in range(len(L_range)):
        L_val = L_range[j]
        E_val = E_range[i]
        
        r_test = np.linspace(rs + 0.1, 50, 500)
        V = effective_potential(r_test, L_val)
        
        E_eff = E_val**2 / 2 - 0.5  # Effective energy for comparison
        
        # Check if bound or unbound
        V_max = np.max(V)
        V_min = np.min(V)
        
        if E_eff > V_max:
            orbit_type[i, j] = 3  # Plunge orbit (capture)
        elif E_eff < V_min:
            orbit_type[i, j] = 0  # Forbidden
        elif E_eff < V_max and np.any(V[V < E_eff]):
            orbit_type[i, j] = 1  # Bound orbit
        else:
            orbit_type[i, j] = 2  # Scatter orbit

cmap = plt.cm.get_cmap('RdYlBu_r', 4)
im = ax4.pcolormesh(L_grid, E_grid, orbit_type, cmap=cmap, alpha=0.7, shading='auto')

# ISCO line
L_isco = 2 * np.sqrt(3) * M
ax4.axvline(x=L_isco, color='white', linewidth=2, linestyle='--', label='ISCO')

ax4.set_xlabel('Angular Momentum L / M', fontsize=11)
ax4.set_ylabel('Energy E / mc²', fontsize=11)
ax4.grid(alpha=0.2)

# Color bar with labels
cbar = plt.colorbar(im, ax=ax4, ticks=[0.375, 1.125, 1.875, 2.625])
cbar.ax.set_yticklabels(['Forbidden', 'Bound\n(Elliptic)', 'Scatter\n(Hyperbolic)', 'Plunge\n(Capture)'])

ax4.annotate('Irreducible representations\nof 𝔊 classified by\nCasimir eigenvalues (E, L)', 
             xy=(5.5, 0.92), fontsize=9, fontstyle='italic',
             bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

plt.savefig('/workspace/request-project/algebraic_gravity/demos/fig4_geodesics_representations.png', 
            dpi=150, bbox_inches='tight')
print("  Saved: fig4_geodesics_representations.png")

# ============================================================================
# Part 3: Gravitational Waves as Oscillations in 𝔊₋₂
# ============================================================================

print("\n🌊 Computing Gravitational Wave Representation...")

fig, axes = plt.subplots(2, 2, figsize=(16, 12))

# Gravitational wave: h+ and h× polarizations
# These are oscillations in the 𝔊₋₂ (curvature) sector
t = np.linspace(0, 10, 1000)  # Time in units of period
omega = 2 * np.pi  # Angular frequency

# Plus polarization
h_plus = 0.5 * np.cos(omega * t) * np.exp(-0.1 * t)
# Cross polarization  
h_cross = 0.5 * np.sin(omega * t) * np.exp(-0.1 * t)

# Panel 1: Waveforms
ax = axes[0, 0]
ax.plot(t, h_plus, 'b-', linewidth=2, label='h₊ (plus)')
ax.plot(t, h_cross, 'r-', linewidth=2, label='h× (cross)')
ax.set_xlabel('Time (periods)', fontsize=11)
ax.set_ylabel('Strain h', fontsize=11)
ax.set_title('Gravitational Wave Polarizations\n(Oscillations in 𝔊₋₂)', fontsize=12, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(alpha=0.3)

# Panel 2: Phase space portrait in 𝔊₋₂
ax = axes[0, 1]
ax.plot(h_plus, h_cross, 'purple', linewidth=1.5, alpha=0.8)
ax.plot(h_plus[0], h_cross[0], 'go', markersize=10, label='Start')
ax.plot(h_plus[-1], h_cross[-1], 'rs', markersize=10, label='End')
ax.set_xlabel('h₊', fontsize=11)
ax.set_ylabel('h×', fontsize=11)
ax.set_title('Phase Portrait in 𝔊₋₂\n(Damped Spiral = Inspiral)', fontsize=12, fontweight='bold')
ax.set_aspect('equal')
ax.legend(fontsize=10)
ax.grid(alpha=0.3)

# Panel 3: Ring of test particles deformed by h+
ax = axes[1, 0]
ax.set_title('Plus Polarization h₊\n(Action of 𝔊₋₂ on Space)', fontsize=12, fontweight='bold')

n_particles = 24
theta_ring = np.linspace(0, 2*np.pi, n_particles, endpoint=False)
r0 = 1.0

for phase_idx, (phase, color, alpha) in enumerate(
    [(0, '#3498db', 0.3), (np.pi/4, '#2ecc71', 0.5), (np.pi/2, '#e74c3c', 1.0)]):
    
    h = 0.3 * np.cos(phase)
    x = r0 * (1 + h) * np.cos(theta_ring)
    y = r0 * (1 - h) * np.sin(theta_ring)
    
    # Close the ring
    x = np.append(x, x[0])
    y = np.append(y, y[0])
    
    ax.fill(x, y, alpha=0.1, color=color)
    ax.plot(x, y, 'o-', color=color, markersize=4, linewidth=1.5, alpha=alpha,
            label=f'ωt = {phase:.2f}')

ax.set_xlim(-1.8, 1.8)
ax.set_ylim(-1.8, 1.8)
ax.set_aspect('equal')
ax.legend(fontsize=9)
ax.grid(alpha=0.3)

# Panel 4: Ring of test particles deformed by h×
ax = axes[1, 1]
ax.set_title('Cross Polarization h×\n(Action of 𝔊₋₂ on Space)', fontsize=12, fontweight='bold')

for phase_idx, (phase, color, alpha) in enumerate(
    [(0, '#3498db', 0.3), (np.pi/4, '#2ecc71', 0.5), (np.pi/2, '#e74c3c', 1.0)]):
    
    h = 0.3 * np.cos(phase)
    
    # Cross polarization rotates by 45°
    x0 = r0 * np.cos(theta_ring)
    y0 = r0 * np.sin(theta_ring)
    
    # Apply cross deformation
    x = x0 + h * y0
    y = y0 + h * x0
    
    x = np.append(x, x[0])
    y = np.append(y, y[0])
    
    ax.fill(x, y, alpha=0.1, color=color)
    ax.plot(x, y, 'o-', color=color, markersize=4, linewidth=1.5, alpha=alpha,
            label=f'ωt = {phase:.2f}')

ax.set_xlim(-1.8, 1.8)
ax.set_ylim(-1.8, 1.8)
ax.set_aspect('equal')
ax.legend(fontsize=9)
ax.grid(alpha=0.3)

plt.tight_layout()
plt.savefig('/workspace/request-project/algebraic_gravity/demos/fig5_gravitational_waves.png', 
            dpi=150, bbox_inches='tight')
print("  Saved: fig5_gravitational_waves.png")

print("\n✅ All representation and geodesic visualizations complete!")
print("=" * 70)
