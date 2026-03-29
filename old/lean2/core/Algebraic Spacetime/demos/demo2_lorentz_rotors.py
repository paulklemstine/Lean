#!/usr/bin/env python3
"""
╔══════════════════════════════════════════════════════════════════════╗
║  DEMO 2: Lorentz Transformations as Rotors                         ║
║  The Algebraic Theory of Spacetime                                  ║
╚══════════════════════════════════════════════════════════════════════╝

Shows how Lorentz boosts and spatial rotations are unified as
rotor transformations v ↦ RvR̃ in the Clifford algebra.

Includes visualization of:
- Boost hyperbolas and rotation circles
- Thomas precession (Wigner rotation)
- The rotor group structure
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
from mpl_toolkits.mplot3d import Axes3D
import matplotlib.gridspec as gridspec

# ══════════════════════════════════════════════════════════════════
# Gamma matrices (Dirac representation)
# ══════════════════════════════════════════════════════════════════
sigma_1 = np.array([[0, 1], [1, 0]], dtype=complex)
sigma_2 = np.array([[0, -1j], [1j, 0]], dtype=complex)
sigma_3 = np.array([[1, 0], [0, -1]], dtype=complex)
I2 = np.eye(2, dtype=complex)
I4 = np.eye(4, dtype=complex)

gamma = np.zeros((4, 4, 4), dtype=complex)
gamma[0] = np.block([[I2, np.zeros((2,2))], [np.zeros((2,2)), -I2]])
gamma[1] = np.block([[np.zeros((2,2)), sigma_1], [-sigma_1, np.zeros((2,2))]])
gamma[2] = np.block([[np.zeros((2,2)), sigma_2], [-sigma_2, np.zeros((2,2))]])
gamma[3] = np.block([[np.zeros((2,2)), sigma_3], [-sigma_3, np.zeros((2,2))]])

def gamma_reverse(M):
    """Reversion: reverse the order of gamma products."""
    return gamma[0] @ M.conj().T @ gamma[0]

def extract_vector(M):
    """Extract the 4-vector components from a matrix."""
    v = np.zeros(4)
    for mu in range(4):
        # v^μ = ¼ Tr(γ^μ M) with metric correction
        sign = 1 if mu == 0 else -1
        v[mu] = np.real(np.trace(gamma[mu] @ M)) / 4 * sign
    return v

# ══════════════════════════════════════════════════════════════════
# Rotor construction
# ══════════════════════════════════════════════════════════════════

def make_vector(v):
    """Convert a 4-vector to a Clifford algebra element."""
    return v[0]*gamma[0] + v[1]*gamma[1] + v[2]*gamma[2] + v[3]*gamma[3]

def boost_rotor(phi, direction):
    """Create a boost rotor: R = exp(-φ/2 · γ₀γᵢ) for boost in direction i.
    
    φ = rapidity (artanh(v/c))
    direction = spatial unit vector [nx, ny, nz]
    """
    d = np.array(direction, dtype=float)
    d = d / np.linalg.norm(d)
    # Bivector B = d₁γ₀₁ + d₂γ₀₂ + d₃γ₀₃
    B = d[0] * gamma[0] @ gamma[1] + d[1] * gamma[0] @ gamma[2] + d[2] * gamma[0] @ gamma[3]
    # R = cosh(φ/2) - sinh(φ/2) B
    from scipy.linalg import expm
    R = expm(-phi/2 * B)
    return R

def rotation_rotor(theta, axis):
    """Create a rotation rotor: R = exp(-θ/2 · Bᵢⱼ) for rotation about axis.
    
    θ = angle
    axis = [nx, ny, nz] (rotation axis)
    """
    a = np.array(axis, dtype=float)
    a = a / np.linalg.norm(a)
    # Bivector for rotation: σᵢ = γᵢγ₀ ... actually in spacelike plane
    # Rotation in ij plane: B = a₁γ₂₃ + a₂γ₃₁ + a₃γ₁₂
    B = a[0] * gamma[2] @ gamma[3] + a[1] * gamma[3] @ gamma[1] + a[2] * gamma[1] @ gamma[2]
    from scipy.linalg import expm
    R = expm(-theta/2 * B)
    return R

def apply_rotor(R, v):
    """Apply rotor transformation: v ↦ RvR̃"""
    V = make_vector(v)
    R_rev = gamma_reverse(R)
    V_prime = R @ V @ R_rev
    return extract_vector(V_prime)

# ══════════════════════════════════════════════════════════════════
# Demonstrations
# ══════════════════════════════════════════════════════════════════

print("=" * 60)
print("  LORENTZ BOOSTS AS ROTORS")
print("=" * 60)

# Test: boost a particle at rest
v_rest = np.array([1.0, 0.0, 0.0, 0.0])  # 4-momentum of particle at rest (m=1)

print(f"\n  Particle at rest: p = {v_rest}")
for beta in [0.3, 0.6, 0.9, 0.99]:
    phi = np.arctanh(beta)
    R = boost_rotor(phi, [1, 0, 0])
    p_boosted = apply_rotor(R, v_rest)
    gamma_factor = 1 / np.sqrt(1 - beta**2)
    print(f"  β={beta:.2f} (φ={phi:.3f}): p' = [{p_boosted[0]:.4f}, {p_boosted[1]:.4f}, 0, 0]"
          f"  (γ={gamma_factor:.4f})")

# Verify RR̃ = 1
print(f"\n  Verifying RR̃ = I:")
for phi_test in [0.5, 1.0, 2.0]:
    R = boost_rotor(phi_test, [1, 0, 0])
    R_rev = gamma_reverse(R)
    product = R @ R_rev
    is_identity = np.allclose(product, I4)
    print(f"  φ={phi_test:.1f}: RR̃ = I? {'YES ✓' if is_identity else 'NO ✗'}")

# ══════════════════════════════════════════════════════════════════
# Thomas Precession
# ══════════════════════════════════════════════════════════════════

print("\n" + "=" * 60)
print("  THOMAS PRECESSION (WIGNER ROTATION)")
print("=" * 60)

# Two successive boosts in perpendicular directions
beta1, beta2 = 0.6, 0.8
phi1 = np.arctanh(beta1)
phi2 = np.arctanh(beta2)

R1 = boost_rotor(phi1, [1, 0, 0])  # boost in x
R2 = boost_rotor(phi2, [0, 1, 0])  # boost in y

# Combined transformation
R_combined = R2 @ R1

# Extract the rotation angle from the combined rotor
# A pure boost has R = R̃⁻¹ (self-reverse); a rotation does not
R_rev = gamma_reverse(R_combined)
R_inv = np.linalg.inv(R_combined)
# The "rotation part" is R_combined · R_boost⁻¹
# For simplicity, measure how much the combined rotor differs from a pure boost

# Apply to test vectors to detect rotation
vx = apply_rotor(R_combined, np.array([0, 1, 0, 0]))
vy = apply_rotor(R_combined, np.array([0, 0, 1, 0]))

# Thomas precession angle (exact formula)
gamma1 = 1 / np.sqrt(1 - beta1**2)
gamma2 = 1 / np.sqrt(1 - beta2**2)
cos_omega = (gamma1 + gamma2) / (1 + gamma1 * gamma2)
omega_thomas = np.arccos(np.clip(cos_omega, -1, 1))

print(f"\n  Boost 1: β₁ = {beta1} in x-direction (φ₁ = {phi1:.4f})")
print(f"  Boost 2: β₂ = {beta2} in y-direction (φ₂ = {phi2:.4f})")
print(f"  Thomas precession angle: Ω = {omega_thomas:.4f} rad = {np.degrees(omega_thomas):.2f}°")
print(f"  This rotation is UNAVOIDABLE — it's built into the geometry of spacetime!")

# ══════════════════════════════════════════════════════════════════
# Visualization
# ══════════════════════════════════════════════════════════════════

fig = plt.figure(figsize=(16, 12))
fig.suptitle("The Algebraic Theory of Spacetime\nLorentz Transformations as Rotors: v ↦ RvR̃",
             fontsize=16, fontweight='bold', y=0.98)

gs = gridspec.GridSpec(2, 2, hspace=0.35, wspace=0.3)

# Panel 1: Boost hyperbolas in t-x plane
ax1 = fig.add_subplot(gs[0, 0])

# Light cone
t_lc = np.linspace(-3, 3, 100)
ax1.plot(t_lc, t_lc, 'y-', linewidth=2, alpha=0.5, label='Light cone')
ax1.plot(t_lc, -t_lc, 'y-', linewidth=2, alpha=0.5)
ax1.fill_between(t_lc, -t_lc, t_lc, alpha=0.05, color='yellow')

# Boost a unit timelike vector through various rapidities
colors = plt.cm.plasma(np.linspace(0.1, 0.9, 8))
for i, phi in enumerate(np.linspace(0, 2.5, 8)):
    R = boost_rotor(phi, [1, 0, 0])
    p = apply_rotor(R, v_rest)
    ax1.plot(p[1], p[0], 'o', color=colors[i], markersize=10, zorder=5)
    ax1.annotate(f'φ={phi:.1f}', (p[1], p[0]), textcoords="offset points",
                xytext=(8, 3), fontsize=7, color=colors[i])

# Hyperbola t² - x² = 1
x_hyp = np.linspace(-2.5, 2.5, 200)
t_hyp = np.sqrt(1 + x_hyp**2)
ax1.plot(x_hyp, t_hyp, 'b--', linewidth=1.5, alpha=0.5, label='t² − x² = 1')

ax1.set_xlabel('x (spatial)', fontsize=11)
ax1.set_ylabel('t (temporal)', fontsize=11)
ax1.set_title('Boost Orbits: Hyperbolas in Spacetime', fontsize=13, fontweight='bold')
ax1.set_xlim(-3, 3)
ax1.set_ylim(-0.5, 4)
ax1.legend(fontsize=9)
ax1.set_aspect('equal')
ax1.grid(True, alpha=0.3)

# Panel 2: Rotation in spatial plane
ax2 = fig.add_subplot(gs[0, 1])

# Rotate a spatial vector through various angles
v_spatial = np.array([0, 1, 0, 0])  # unit vector in x
thetas = np.linspace(0, 2*np.pi, 37)
x_rot = []
y_rot = []
for theta in thetas:
    R = rotation_rotor(theta, [0, 0, 1])  # rotate about z
    v_rotated = apply_rotor(R, v_spatial)
    x_rot.append(v_rotated[1])
    y_rot.append(v_rotated[2])

ax2.plot(x_rot, y_rot, 'b-', linewidth=2, alpha=0.7)

# Mark specific angles
for theta_mark in [0, np.pi/4, np.pi/2, np.pi, 3*np.pi/2]:
    R = rotation_rotor(theta_mark, [0, 0, 1])
    v_r = apply_rotor(R, v_spatial)
    ax2.plot(v_r[1], v_r[2], 'ro', markersize=10, zorder=5)
    ax2.annotate(f'θ={np.degrees(theta_mark):.0f}°', (v_r[1], v_r[2]),
                textcoords="offset points", xytext=(8, 5), fontsize=9)

# Arrow showing rotation direction
ax2.annotate('', xy=(0.5, 0.87), xytext=(0.87, 0.5),
            arrowprops=dict(arrowstyle='->', color='blue', lw=2,
                          connectionstyle='arc3,rad=0.3'))

ax2.set_xlabel('x', fontsize=11)
ax2.set_ylabel('y', fontsize=11)
ax2.set_title('Spatial Rotation: R = e^{−θ/2 · γ₁₂}', fontsize=13, fontweight='bold')
ax2.set_aspect('equal')
ax2.set_xlim(-1.5, 1.5)
ax2.set_ylim(-1.5, 1.5)
ax2.grid(True, alpha=0.3)

# Panel 3: Thomas precession visualization
ax3 = fig.add_subplot(gs[1, 0])

# Show how two non-collinear boosts produce a rotation
# Trace out the effect on a unit circle of spatial directions
angles = np.linspace(0, 2*np.pi, 100)
original_x = np.cos(angles)
original_y = np.sin(angles)

# After Thomas precession
rotated_x = np.cos(angles + omega_thomas)
rotated_y = np.sin(angles + omega_thomas)

ax3.plot(original_x, original_y, 'b-', linewidth=2, label='Before boosts', alpha=0.7)
ax3.plot(rotated_x, rotated_y, 'r--', linewidth=2, label='After two boosts', alpha=0.7)

# Show the precession for a specific direction
ax3.annotate('', xy=(np.cos(omega_thomas), np.sin(omega_thomas)),
            xytext=(1.0, 0.0),
            arrowprops=dict(arrowstyle='->', color='green', lw=3,
                          connectionstyle='arc3,rad=0.2'))
ax3.text(0.7, 0.3, f'Ω = {np.degrees(omega_thomas):.1f}°',
        fontsize=14, fontweight='bold', color='green')

ax3.set_xlabel('x direction', fontsize=11)
ax3.set_ylabel('y direction', fontsize=11)
ax3.set_title(f'Thomas Precession\nβ₁={beta1} (x) then β₂={beta2} (y)',
             fontsize=13, fontweight='bold')
ax3.set_aspect('equal')
ax3.legend(fontsize=10)
ax3.grid(True, alpha=0.3)

# Panel 4: Rotor magnitude and composition
ax4 = fig.add_subplot(gs[1, 1])

# Show how rapidity composes linearly for collinear boosts
phi_values = np.linspace(0, 3, 50)
beta_values = np.tanh(phi_values)
gamma_values = np.cosh(phi_values)

ax4_twin = ax4.twinx()
ax4.plot(phi_values, beta_values, 'b-', linewidth=2.5, label='β = tanh(φ)')
ax4_twin.plot(phi_values, gamma_values, 'r-', linewidth=2.5, label='γ = cosh(φ)')

ax4.set_xlabel('Rapidity φ', fontsize=11)
ax4.set_ylabel('Velocity β = v/c', fontsize=11, color='blue')
ax4_twin.set_ylabel('Lorentz factor γ', fontsize=11, color='red')
ax4.set_title('Rapidity: The Natural Boost Parameter\nR = exp(−φ/2 · γ₀ᵢ)',
             fontsize=13, fontweight='bold')

# Highlight key point: rapidities add
ax4.axhline(y=1.0, color='gray', linestyle=':', alpha=0.5)
ax4.text(2.0, 0.85, 'β → 1 (speed of light)\nbut φ → ∞ (no limit!)',
        fontsize=9, style='italic', ha='center',
        bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

lines1, labels1 = ax4.get_legend_handles_labels()
lines2, labels2 = ax4_twin.get_legend_handles_labels()
ax4.legend(lines1 + lines2, labels1 + labels2, loc='center left', fontsize=10)

ax4.grid(True, alpha=0.3)

plt.savefig('/workspace/request-project/Algebraic Spacetime/demos/fig2_lorentz_rotors.png',
            dpi=150, bbox_inches='tight', facecolor='white')
plt.close()

print("\n✓ Figure saved: fig2_lorentz_rotors.png")
print("\n" + "=" * 60)
print("  DEMO 2 COMPLETE")
print("=" * 60)
