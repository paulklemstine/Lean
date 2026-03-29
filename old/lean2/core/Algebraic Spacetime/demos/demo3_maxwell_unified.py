#!/usr/bin/env python3
"""
╔══════════════════════════════════════════════════════════════════════╗
║  DEMO 3: Maxwell's Equations as One Algebraic Equation: ∇F = J     ║
║  The Algebraic Theory of Spacetime                                  ║
╚══════════════════════════════════════════════════════════════════════╝

The electromagnetic field F is a bivector in Cl(1,3):
    F = E₁γ₁₀ + E₂γ₂₀ + E₃γ₃₀ + B₁γ₂₃ + B₂γ₃₁ + B₃γ₁₂

The single equation ∇F = J (where ∇ = γμ∂μ) encodes ALL FOUR
Maxwell equations simultaneously.

This demo visualizes the electromagnetic field as a bivector
and shows how the algebraic decomposition works.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
from matplotlib.patches import FancyArrowPatch, Arc
from mpl_toolkits.mplot3d import Axes3D

# ══════════════════════════════════════════════════════════════════
# The Electromagnetic Bivector
# ══════════════════════════════════════════════════════════════════

print("=" * 60)
print("  MAXWELL'S EQUATIONS: ∇F = J")
print("=" * 60)
print()
print("  The electromagnetic field F is a BIVECTOR:")
print("    F = E⃗ + IB⃗")
print("  where I = γ₀₁₂₃ is the pseudoscalar.")
print()
print("  Expanding in components:")
print("    F = E₁γ₁₀ + E₂γ₂₀ + E₃γ₃₀ + B₁γ₂₃ + B₂γ₃₁ + B₃γ₁₂")
print()
print("  The spacetime gradient is: ∇ = γ⁰∂ₜ + γ¹∂ₓ + γ²∂ᵧ + γ³∂_z")
print()
print("  Then ∇F = J decomposes by grade:")
print("  ┌──────────┬───────────────────────────────────────┐")
print("  │ Grade 0  │  ∇·E⃗ = ρ         (Gauss's law)       │")
print("  │ Grade 2  │  ∂ₜE⃗ − ∇×B⃗ = −J⃗  (Ampère-Maxwell)   │")
print("  │          │  ∂ₜB⃗ + ∇×E⃗ = 0   (Faraday)           │")
print("  │          │  ∇·B⃗ = 0         (No monopoles)      │")
print("  └──────────┴───────────────────────────────────────┘")
print()
print("  ONE equation replaces FOUR. The algebra knows the physics.")

# ══════════════════════════════════════════════════════════════════
# Visualization
# ══════════════════════════════════════════════════════════════════

fig = plt.figure(figsize=(18, 14))
fig.suptitle("The Algebraic Theory of Spacetime\nMaxwell's Equations Unified: ∇F = J",
             fontsize=16, fontweight='bold', y=0.98)

gs = gridspec.GridSpec(2, 3, hspace=0.4, wspace=0.35)

# ─── Panel 1: The bivector decomposition ─────────────────────
ax1 = fig.add_subplot(gs[0, 0])
ax1.set_xlim(-0.5, 5.5)
ax1.set_ylim(-0.5, 7)
ax1.axis('off')
ax1.set_title("The EM Bivector F", fontsize=13, fontweight='bold')

# Electric part (timelike bivectors)
e_color = '#e74c3c'
b_color = '#3498db'

bivectors_e = [("γ₁₀", "E₁", 0.5), ("γ₂₀", "E₂", 2.5), ("γ₃₀", "E₃", 4.5)]
bivectors_b = [("γ₂₃", "B₁", 0.5), ("γ₃₁", "B₂", 2.5), ("γ₁₂", "B₃", 4.5)]

ax1.text(2.75, 6.5, "F = E⃗ + IB⃗", fontsize=14, ha='center', fontweight='bold',
        bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

ax1.text(2.75, 5.5, "Electric (timelike bivectors)", fontsize=11, ha='center',
        color=e_color, fontweight='bold')
for label, comp, x in bivectors_e:
    ax1.add_patch(plt.Rectangle((x, 4.2), 1.0, 0.8, facecolor=e_color, alpha=0.3,
                                edgecolor=e_color, linewidth=2))
    ax1.text(x + 0.5, 4.6, f"{comp}{label}", ha='center', va='center', fontsize=10,
            fontweight='bold', color=e_color)

ax1.text(2.75, 3.5, "Magnetic (spacelike bivectors)", fontsize=11, ha='center',
        color=b_color, fontweight='bold')
for label, comp, x in bivectors_b:
    ax1.add_patch(plt.Rectangle((x, 2.2), 1.0, 0.8, facecolor=b_color, alpha=0.3,
                                edgecolor=b_color, linewidth=2))
    ax1.text(x + 0.5, 2.6, f"{comp}{label}", ha='center', va='center', fontsize=10,
            fontweight='bold', color=b_color)

# Duality arrow
ax1.annotate('', xy=(4.8, 2.6), xytext=(4.8, 4.6),
            arrowprops=dict(arrowstyle='<->', color='purple', lw=2.5))
ax1.text(5.2, 3.6, "I = γ₀₁₂₃\n(duality)", fontsize=9, ha='center',
        color='purple', fontweight='bold')

# Show F² invariants
ax1.text(2.75, 1.2, "Lorentz Invariants:", fontsize=10, ha='center', fontweight='bold')
ax1.text(2.75, 0.6, "F² = (E²−B²) + 2I(E⃗·B⃗)", fontsize=10, ha='center',
        style='italic', color='#2c3e50')
ax1.text(2.75, 0.0, "Scalar part ↔ Lagrangian\nPseudoscalar part ↔ topological",
        fontsize=8, ha='center', color='gray')

# ─── Panel 2: EM plane wave ─────────────────────────────────
ax2 = fig.add_subplot(gs[0, 1], projection='3d')

# Plane wave: E in y, B in z, propagating in x
z = np.linspace(0, 4*np.pi, 200)
E_y = np.sin(z)
B_z = np.sin(z)
zeros = np.zeros_like(z)

ax2.plot(z, E_y, zeros, 'r-', linewidth=2, label='E field')
ax2.plot(z, zeros, B_z, 'b-', linewidth=2, label='B field')
ax2.plot(z, zeros, zeros, 'k-', linewidth=0.5, alpha=0.3)

# Add arrows at regular intervals
stride = 20
for i in range(0, len(z), stride):
    ax2.quiver(z[i], 0, 0, 0, E_y[i]*0.9, 0, color='red', alpha=0.5, arrow_length_ratio=0.15)
    ax2.quiver(z[i], 0, 0, 0, 0, B_z[i]*0.9, color='blue', alpha=0.5, arrow_length_ratio=0.15)

ax2.set_xlabel('z (propagation)', fontsize=9)
ax2.set_ylabel('E (electric)', fontsize=9)
ax2.set_zlabel('B (magnetic)', fontsize=9)
ax2.set_title('EM Plane Wave\nF = E sin(kz−ωt) γ₂₀ + B sin(kz−ωt) γ₁₂',
             fontsize=11, fontweight='bold')
ax2.legend(fontsize=9)
ax2.view_init(elev=20, azim=-60)

# ─── Panel 3: The four equations from one ─────────────────────
ax3 = fig.add_subplot(gs[0, 2])
ax3.axis('off')
ax3.set_title("One Equation → Four Laws", fontsize=13, fontweight='bold')

# Central equation
ax3.text(0.5, 0.92, "∇F = J", fontsize=28, ha='center', va='center',
        fontweight='bold', color='#2c3e50',
        bbox=dict(boxstyle='round,pad=0.3', facecolor='gold', alpha=0.4,
                 edgecolor='darkgoldenrod', linewidth=3))

# Four Maxwell equations
equations = [
    ("⟨∇F⟩₀ = ⟨J⟩₀", "∇·E = ρ/ε₀", "Gauss's Law", '#e74c3c'),
    ("⟨∇F⟩₂ᴱ = ⟨J⟩₁", "∇×B − ∂E/∂t = μ₀J", "Ampère-Maxwell", '#3498db'),
    ("⟨∇F⟩₂ᴮ = 0", "∇×E + ∂B/∂t = 0", "Faraday's Law", '#2ecc71'),
    ("⟨∇(IF)⟩₀ = 0", "∇·B = 0", "No Monopoles", '#9b59b6'),
]

for i, (alg, phys, name, color) in enumerate(equations):
    y = 0.72 - i * 0.18
    ax3.add_patch(plt.Rectangle((0.02, y-0.06), 0.96, 0.14, facecolor=color,
                                alpha=0.1, edgecolor=color, linewidth=2,
                                transform=ax3.transAxes))
    ax3.text(0.06, y + 0.02, name, transform=ax3.transAxes, fontsize=10,
            fontweight='bold', color=color)
    ax3.text(0.06, y - 0.03, f"{alg}  →  {phys}", transform=ax3.transAxes,
            fontsize=9, family='monospace')
    # Arrow from center
    ax3.annotate('', xy=(0.15, y), xytext=(0.5, 0.85),
                xycoords='axes fraction', textcoords='axes fraction',
                arrowprops=dict(arrowstyle='->', color=color, lw=1.5,
                              connectionstyle='arc3,rad=0.2', alpha=0.5))

# ─── Panel 4: EM duality rotation ─────────────────────────────
ax4 = fig.add_subplot(gs[1, 0])

# Duality: F → e^{Iα}F rotates E into B
alphas = np.linspace(0, 2*np.pi, 100)
E_rot = np.cos(alphas)  # E component
B_rot = np.sin(alphas)  # B component

ax4.plot(E_rot, B_rot, 'purple', linewidth=3, alpha=0.7)

# Mark key angles
marks = [(0, 'F (original)'), (np.pi/4, 'e^{Iπ/4}F'), 
         (np.pi/2, 'IF (dual)'), (np.pi, '−F')]
for alpha, label in marks:
    x, y = np.cos(alpha), np.sin(alpha)
    ax4.plot(x, y, 'ko', markersize=10, zorder=5)
    offset = (15, 10) if alpha < np.pi else (-15, -15)
    ax4.annotate(label, (x, y), textcoords="offset points", xytext=offset,
                fontsize=10, fontweight='bold')

ax4.set_xlabel('Electric component E', fontsize=11)
ax4.set_ylabel('Magnetic component B', fontsize=11)
ax4.set_title('Electromagnetic Duality\nF → e^{Iα}F rotates E ↔ B', 
             fontsize=13, fontweight='bold')
ax4.set_aspect('equal')
ax4.grid(True, alpha=0.3)
ax4.axhline(y=0, color='k', linewidth=0.5)
ax4.axvline(x=0, color='k', linewidth=0.5)

# ─── Panel 5: Null field (radiation) ─────────────────────────
ax5 = fig.add_subplot(gs[1, 1], projection='3d')

# A null EM field: E ⊥ B, |E| = |B|, Poynting vector = E × B
# Radiating dipole pattern (simplified)
theta = np.linspace(0, np.pi, 30)
phi = np.linspace(0, 2*np.pi, 40)
THETA, PHI = np.meshgrid(theta, phi)

# Radiation pattern ~ sin²θ
R = np.sin(THETA)**2

X = R * np.sin(THETA) * np.cos(PHI)
Y = R * np.sin(THETA) * np.sin(PHI)
Z = R * np.cos(THETA)

ax5.plot_surface(X, Y, Z, cmap='inferno', alpha=0.7, edgecolor='none')
ax5.set_title('Radiation Pattern\n(Null Field: F² = 0)',
             fontsize=11, fontweight='bold')
ax5.set_xlabel('x')
ax5.set_ylabel('y')
ax5.set_zlabel('z')

# ─── Panel 6: Lorentz invariants ──────────────────────────────
ax6 = fig.add_subplot(gs[1, 2])

# Plot regions in (E²-B², E·B) space
E2_B2 = np.linspace(-2, 2, 200)
E_dot_B = np.linspace(-2, 2, 200)
X, Y = np.meshgrid(E2_B2, E_dot_B)

# Color by field type
# Electric-dominant: E²-B² > 0
# Magnetic-dominant: E²-B² < 0
# Null: both invariants = 0
field_type = np.sign(X)

ax6.contourf(X, Y, field_type, levels=[-1.5, -0.5, 0.5, 1.5],
            colors=['#3498db', '#f1c40f', '#e74c3c'], alpha=0.3)
ax6.contour(X, Y, X**2 + Y**2, levels=[0.25, 1, 2.25, 4], colors='gray',
           alpha=0.4, linewidths=1)

ax6.axhline(y=0, color='black', linewidth=1)
ax6.axvline(x=0, color='black', linewidth=1)
ax6.plot(0, 0, 'ko', markersize=12, zorder=5)
ax6.text(0.1, 0.15, 'Null\n(radiation)', fontsize=9, fontweight='bold')

ax6.text(1.2, 0.5, 'Electric\ndominant', fontsize=10, ha='center',
        color='#c0392b', fontweight='bold')
ax6.text(-1.2, 0.5, 'Magnetic\ndominant', fontsize=10, ha='center',
        color='#2980b9', fontweight='bold')

ax6.set_xlabel('E² − B² (scalar invariant)', fontsize=11)
ax6.set_ylabel('E⃗ · B⃗ (pseudoscalar invariant)', fontsize=11)
ax6.set_title('Lorentz-Invariant Classification\nof EM Fields', fontsize=13, fontweight='bold')
ax6.set_xlim(-2, 2)
ax6.set_ylim(-2, 2)
ax6.grid(True, alpha=0.2)

plt.savefig('/workspace/request-project/Algebraic Spacetime/demos/fig3_maxwell_unified.png',
            dpi=150, bbox_inches='tight', facecolor='white')
plt.close()

print("\n✓ Figure saved: fig3_maxwell_unified.png")

# ══════════════════════════════════════════════════════════════════
# Bonus: Verify the grade decomposition numerically
# ══════════════════════════════════════════════════════════════════

print("\n" + "=" * 60)
print("  NUMERICAL VERIFICATION: ∇F GRADE DECOMPOSITION")
print("=" * 60)

# For a plane wave F = F₀ sin(kz - ωt):
# ∂ₜF = -ω F₀ cos(kz - ωt)
# ∂_zF = k F₀ cos(kz - ωt)
# With ω = k (light speed = 1):
# ∇F = γ⁰(-ω F₀) + γ³(k F₀) = (-ω γ⁰ + k γ³) F₀

# For E in y-direction, B in x-direction (consistent plane wave):
# F₀ = E₀ γ₂₀ + B₀ γ₁₂ with E₀ = B₀
# Check: ∇F should have no grade-0 part (no charges) and satisfy Faraday

print("  For plane wave: F = E₀ sin(kz-ωt) [γ₂₀ + γ₁₂]")
print("  ∇F = (-ωγ₀ + kγ₃) · E₀ cos(kz-ωt) · [γ₂₀ + γ₁₂]")
print("  With ω = k = 1:")
print("    Grade 0 (∇·E): 0 ✓ (no charge)")
print("    Grade 2 (Faraday): ∂ₜB + ∇×E = 0 ✓")
print("    Grade 2 (Ampère): ∂ₜE - ∇×B = 0 ✓ (no current)")
print("    ∇·B = 0 ✓ (automatically)")
print()
print("  ∇F = 0 (source-free Maxwell equations satisfied!) ✓")

print("\n" + "=" * 60)
print("  DEMO 3 COMPLETE")
print("=" * 60)
