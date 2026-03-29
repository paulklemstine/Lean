#!/usr/bin/env python3
"""
╔══════════════════════════════════════════════════════════════════════╗
║  DEMO 4: Spinors as Ideals & The Dirac Equation                    ║
║  The Algebraic Theory of Spacetime                                  ║
╚══════════════════════════════════════════════════════════════════════╝

Demonstrates that:
1. Dirac spinors are minimal left ideals of Cl(1,3)
2. The Dirac equation is a first-order algebraic equation in Cl(1,3)
3. The spinor transformation law under Lorentz boosts
4. Chirality (γ₅) and the Weyl decomposition
"""

import numpy as np
import matplotlib.pyplot as plt
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

gamma5 = 1j * gamma[0] @ gamma[1] @ gamma[2] @ gamma[3]

print("=" * 60)
print("  SPINORS AS ALGEBRAIC IDEALS")
print("=" * 60)

# ══════════════════════════════════════════════════════════════════
# Section 1: The Primitive Idempotent
# ══════════════════════════════════════════════════════════════════

# Construct primitive idempotent P = ½(1+γ₀)·½(1+iγ₁₂)
P = 0.25 * (I4 + gamma[0]) @ (I4 + 1j * gamma[1] @ gamma[2])

print(f"\n  Idempotent P = ½(1+γ₀)·½(1+iγ₁₂)")
print(f"  P² = P? {np.allclose(P @ P, P)}")
print(f"  Rank of P: {int(np.round(np.real(np.trace(P))))}")

# The left ideal Cl(1,3)·P
# Every column of P is a spinor direction
print(f"\n  The left ideal Cl(1,3)·P has dimension {int(np.round(np.real(np.trace(P))))} over ℂ")
print(f"  This IS the Dirac spinor space!")

# ══════════════════════════════════════════════════════════════════
# Section 2: Chirality and Weyl Decomposition
# ══════════════════════════════════════════════════════════════════

print("\n" + "=" * 60)
print("  CHIRALITY: THE PSEUDOSCALAR γ₅")
print("=" * 60)

# Chirality projectors
P_L = 0.5 * (I4 - gamma5)  # Left-handed
P_R = 0.5 * (I4 + gamma5)  # Right-handed

print(f"\n  γ₅ = iγ₀γ₁γ₂γ₃")
print(f"  γ₅² = I? {np.allclose(gamma5 @ gamma5, I4)}")
print(f"  {{γ₅, γμ}} = 0? ", end="")
anticomm_check = all(np.allclose(gamma5 @ gamma[mu] + gamma[mu] @ gamma5, 
                                  np.zeros((4,4))) for mu in range(4))
print(f"{'YES ✓' if anticomm_check else 'NO ✗'}")

print(f"\n  Chirality projectors:")
print(f"  P_L = ½(1-γ₅),  P_R = ½(1+γ₅)")
print(f"  P_L² = P_L? {np.allclose(P_L @ P_L, P_L)}")
print(f"  P_R² = P_R? {np.allclose(P_R @ P_R, P_R)}")
print(f"  P_L · P_R = 0? {np.allclose(P_L @ P_R, np.zeros((4,4)))}")
print(f"  P_L + P_R = I? {np.allclose(P_L + P_R, I4)}")

print(f"\n  A Dirac spinor ψ decomposes as:")
print(f"    ψ = ψ_L + ψ_R  (left-handed + right-handed)")
print(f"  This is the WEYL decomposition — chirality is algebraic!")

# ══════════════════════════════════════════════════════════════════
# Section 3: Spinor transformation under boosts
# ══════════════════════════════════════════════════════════════════

print("\n" + "=" * 60)
print("  SPINOR TRANSFORMATION LAW")
print("=" * 60)

from scipy.linalg import expm

# A boost in x-direction
def spinor_boost(phi):
    """Rotor for boost: R = exp(-φ/2 · γ₀₁)"""
    B = gamma[0] @ gamma[1]
    return expm(-phi/2 * B)

# A rotation about z-axis
def spinor_rotation(theta):
    """Rotor for rotation: R = exp(-θ/2 · γ₁₂)"""
    B = gamma[1] @ gamma[2]
    return expm(-theta/2 * B)

# Key property: under 2π rotation, spinor gets a MINUS SIGN
R_2pi = spinor_rotation(2 * np.pi)
print(f"\n  Under 2π rotation:")
print(f"  R(2π) = −I? {np.allclose(R_2pi, -I4)}")
print(f"  Spinors are DOUBLE-VALUED: they need 4π to return to original state!")
print(f"  This is the hallmark of spin-½ — it's built into the algebra.")

R_4pi = spinor_rotation(4 * np.pi)
print(f"\n  Under 4π rotation:")
print(f"  R(4π) = +I? {np.allclose(R_4pi, I4)}")

# ══════════════════════════════════════════════════════════════════
# Section 4: The Dirac Equation
# ══════════════════════════════════════════════════════════════════

print("\n" + "=" * 60)
print("  THE DIRAC EQUATION IN SPACETIME ALGEBRA")
print("=" * 60)
print()
print("  Standard form:  (iγμ∂μ − m)ψ = 0")
print("  STA form:       ∇ψIσ₃ = mψγ₀")
print()
print("  where σ₃ = γ₃γ₀ and I = γ₀₁₂₃")
print()
print("  The algebraic form reveals:")
print("  • ψ is an EVEN element of Cl(1,3), not a column vector")
print("  • The equation is FIRST-ORDER and REAL (no complex numbers needed!)")
print("  • Mass couples left and right chiralities through γ₀")

# ══════════════════════════════════════════════════════════════════
# Visualization
# ══════════════════════════════════════════════════════════════════

fig = plt.figure(figsize=(16, 12))
fig.suptitle("The Algebraic Theory of Spacetime\nSpinors, Chirality, and the Dirac Equation",
             fontsize=16, fontweight='bold', y=0.98)

gs = gridspec.GridSpec(2, 2, hspace=0.4, wspace=0.35)

# Panel 1: Spinor rotation — double cover
ax1 = fig.add_subplot(gs[0, 0], projection='polar')

# Show how a vector returns after π rotation but a spinor needs 2π
angles = np.linspace(0, 4*np.pi, 500)

# Vector phase (returns at 2π)
vector_phase = np.cos(angles)

# Spinor phase (returns at 4π — needs double the angle)
spinor_phase = np.cos(angles/2)

ax1.plot(angles, np.abs(vector_phase) + 0.1, 'b-', linewidth=2, label='Vector (period 2π)')
ax1.plot(angles, np.abs(spinor_phase) + 0.1, 'r-', linewidth=2, label='Spinor (period 4π)')

# Mark 2π and 4π
ax1.axvline(x=2*np.pi, color='green', linewidth=2, linestyle='--', alpha=0.7)
ax1.text(2*np.pi, 1.3, '2π', fontsize=12, fontweight='bold', color='green', ha='center')
ax1.text(0, 1.3, '4π = 0', fontsize=12, fontweight='bold', color='green', ha='center')

ax1.set_title('Double Cover: Spinors Need 4π\nR(2π)ψ = −ψ, R(4π)ψ = +ψ',
             fontsize=11, fontweight='bold', pad=20)
ax1.legend(loc='lower right', fontsize=9)

# Panel 2: Chirality eigenvalues under boost
ax2 = fig.add_subplot(gs[0, 1])

# Create a test spinor and track chirality under boosts
psi_up = np.array([1, 0, 0, 0], dtype=complex)  # spin-up, positive energy
psi_down = np.array([0, 1, 0, 0], dtype=complex)  # spin-down, positive energy

phis = np.linspace(0, 3, 100)
chirality_up = []
chirality_down = []
norm_up = []
norm_down = []

for phi in phis:
    R = spinor_boost(phi)
    psi_boosted_up = R @ psi_up
    psi_boosted_down = R @ psi_down
    
    # Chirality expectation: ψ†γ₅ψ / ψ†ψ
    chir_up = np.real(psi_boosted_up.conj() @ gamma5 @ psi_boosted_up) / \
              np.real(psi_boosted_up.conj() @ psi_boosted_up)
    chir_down = np.real(psi_boosted_down.conj() @ gamma5 @ psi_boosted_down) / \
                np.real(psi_boosted_down.conj() @ psi_boosted_down)
    
    chirality_up.append(chir_up)
    chirality_down.append(chir_down)
    norm_up.append(np.real(psi_boosted_up.conj() @ gamma[0] @ psi_boosted_up))
    norm_down.append(np.real(psi_boosted_down.conj() @ gamma[0] @ psi_boosted_down))

ax2.plot(phis, chirality_up, 'r-', linewidth=2.5, label='Spin ↑')
ax2.plot(phis, chirality_down, 'b-', linewidth=2.5, label='Spin ↓')
ax2.axhline(y=0, color='gray', linewidth=0.5)

ax2.set_xlabel('Boost rapidity φ', fontsize=11)
ax2.set_ylabel('Chirality ⟨γ₅⟩', fontsize=11)
ax2.set_title('Chirality vs. Boost\n(Helicity → Chirality as v → c)', fontsize=13, fontweight='bold')
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)

# Panel 3: The algebraic structure of the Dirac equation
ax3 = fig.add_subplot(gs[1, 0])
ax3.axis('off')
ax3.set_xlim(0, 10)
ax3.set_ylim(0, 10)
ax3.set_title('The Dirac Equation: Algebraic Structure', fontsize=13, fontweight='bold')

# Main equation
ax3.text(5, 9, '∇ψIσ₃ = mψγ₀', fontsize=22, ha='center', fontweight='bold',
        color='#2c3e50',
        bbox=dict(boxstyle='round,pad=0.4', facecolor='#f0e68c', alpha=0.5,
                 edgecolor='#b8860b', linewidth=2))

# Breakdown
components = [
    (5, 7.5, '∇ = γμ∂μ', 'Spacetime gradient\n(encodes all derivatives)', '#e74c3c'),
    (5, 6.0, 'ψ ∈ Cl⁺(1,3)', 'Even multivector\n(NOT a column vector!)', '#3498db'),
    (5, 4.5, 'Iσ₃ = γ₀₁₂₃γ₃₀ = γ₁₂', 'Spin plane selector\n(replaces i = √−1)', '#2ecc71'),
    (5, 3.0, 'm = rest mass', 'Couples ψ_L ↔ ψ_R\n(mass mixes chiralities)', '#9b59b6'),
    (5, 1.5, 'γ₀ = time direction', 'Selects rest frame\n(observer-dependent split)', '#f39c12'),
]

for x, y, formula, desc, color in components:
    ax3.add_patch(plt.Rectangle((1, y-0.5), 8, 1.0, facecolor=color, alpha=0.1,
                                edgecolor=color, linewidth=2, linestyle='--'))
    ax3.text(3, y, formula, fontsize=13, ha='center', va='center',
            fontweight='bold', color=color)
    ax3.text(7, y, desc, fontsize=9, ha='center', va='center',
            color='#2c3e50')

# Panel 4: Idempotent and ideal structure
ax4 = fig.add_subplot(gs[1, 1])

# Visualize the 4×4 idempotent P as a heatmap
fig_P = np.real(P)
fig_P_imag = np.imag(P)

# Show real and imaginary parts side by side
combined = np.zeros((4, 9))
combined[:, :4] = fig_P
combined[:, 5:9] = fig_P_imag

im = ax4.imshow(np.abs(P), cmap='YlOrRd', aspect='equal')
for i in range(4):
    for j in range(4):
        val = P[i, j]
        text = ""
        if np.abs(val) > 0.01:
            if np.abs(np.imag(val)) < 0.01:
                text = f"{np.real(val):.2f}"
            elif np.abs(np.real(val)) < 0.01:
                text = f"{np.imag(val):.2f}i"
            else:
                text = f"{np.real(val):.1f}+{np.imag(val):.1f}i"
        ax4.text(j, i, text, ha='center', va='center', fontsize=10,
                fontweight='bold', color='black' if np.abs(val) < 0.3 else 'white')

ax4.set_xticks(range(4))
ax4.set_yticks(range(4))
ax4.set_title('Primitive Idempotent P\nP = ½(1+γ₀)·½(1+iγ₁₂), P² = P',
             fontsize=13, fontweight='bold')
ax4.set_xlabel('Column index', fontsize=11)
ax4.set_ylabel('Row index', fontsize=11)
plt.colorbar(im, ax=ax4, shrink=0.8, label='|P_{ij}|')

plt.savefig('/workspace/request-project/Algebraic Spacetime/demos/fig4_spinors_dirac.png',
            dpi=150, bbox_inches='tight', facecolor='white')
plt.close()

print("\n✓ Figure saved: fig4_spinors_dirac.png")
print("\n" + "=" * 60)
print("  DEMO 4 COMPLETE")
print("=" * 60)
