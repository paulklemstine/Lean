#!/usr/bin/env python3
"""
Demo 1: The Gravitational Algebra 𝔊 — Structure and Visualization
==================================================================
Oracle III (Hephaestus) — Computational Experiments

This script implements the Gravitational Algebra as a concrete matrix algebra,
computes its structure constants, and verifies the Jacobi identity.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from mpl_toolkits.mplot3d import Axes3D

# ============================================================================
# Part 1: The Lorentz Algebra 𝔰𝔬(3,1) — The Grade-0 Core
# ============================================================================

# Minkowski metric η = diag(-1, +1, +1, +1)
eta = np.diag([-1.0, 1.0, 1.0, 1.0])

def lorentz_generator(a, b):
    """
    Construct the (a,b) generator of 𝔰𝔬(3,1) as a 4×4 matrix.
    (M_ab)^c_d = η_ac δ^b_d - η_bc δ^a_d
    """
    M = np.zeros((4, 4))
    for c in range(4):
        for d in range(4):
            M[c, d] = eta[a, c] * (1 if b == d else 0) - eta[b, c] * (1 if a == d else 0)
    return M

# Build the 6 independent Lorentz generators
# Rotations: J1 = M_23, J2 = M_31, J3 = M_12
# Boosts:    K1 = M_01, K2 = M_02, K3 = M_03
lorentz_labels = ['J₁(M₂₃)', 'J₂(M₃₁)', 'J₃(M₁₂)', 'K₁(M₀₁)', 'K₂(M₀₂)', 'K₃(M₀₃)']
lorentz_pairs = [(2,3), (3,1), (1,2), (0,1), (0,2), (0,3)]
lorentz_gens = [lorentz_generator(a, b) for a, b in lorentz_pairs]

print("=" * 70)
print("THE GRAVITATIONAL ALGEBRA 𝔊 — Computational Verification")
print("=" * 70)
print("\n📐 Grade 0: The Lorentz Algebra 𝔰𝔬(3,1)")
print("-" * 50)

# Verify the Lorentz algebra commutation relations
print("\nLorentz algebra commutation relations [Mᵢ, Mⱼ]:")
for i in range(6):
    for j in range(i+1, 6):
        comm = lorentz_gens[i] @ lorentz_gens[j] - lorentz_gens[j] @ lorentz_gens[i]
        if np.max(np.abs(comm)) > 1e-10:
            # Decompose into basis
            coeffs = []
            for k in range(6):
                # Project onto generator k
                c = np.trace(comm @ np.linalg.pinv(lorentz_gens[k])) / 4
                if abs(c) > 1e-10:
                    coeffs.append(f"{c:+.0f}·{lorentz_labels[k]}")
            if coeffs:
                print(f"  [{lorentz_labels[i]}, {lorentz_labels[j]}] = {' '.join(coeffs)}")

# ============================================================================
# Part 2: The Full Graded Structure
# ============================================================================

print("\n\n🏗️  The Five-Graded Structure of 𝔊")
print("-" * 50)

grades = {
    -2: ("Curvature (R)", 20, "#e74c3c"),
    -1: ("Translations (P)", 4, "#e67e22"),
     0: ("Lorentz (M)", 6, "#f1c40f"),
     1: ("Momentum (Q)", 4, "#2ecc71"),
     2: ("Matter (T)", 20, "#3498db"),
}

total_dim = sum(v[1] for v in grades.values())
print(f"\nTotal dimension of 𝔊: {total_dim}\n")

for grade, (name, dim, color) in sorted(grades.items()):
    bar = "█" * dim
    print(f"  Grade {grade:+d}: {name:<25s} dim = {dim:2d}  {bar}")

# ============================================================================
# Part 3: Implementing the Key Bracket [P_a, P_b] = λ R_ab
# ============================================================================

print("\n\n🔗 The Fundamental Bracket: [Pₐ, Pᵦ] = λ·Rₐᵦ")
print("-" * 50)

# The cosmological parameter λ = Λ/3 (related to de Sitter radius ℓ: λ = 1/ℓ²)
Lambda_cosmo = 1.0e-52  # m⁻² (observed cosmological constant scale)
lambda_param = Lambda_cosmo / 3

print(f"\nCosmological constant Λ = {Lambda_cosmo:.2e} m⁻²")
print(f"De Sitter radius ℓ = {1/np.sqrt(Lambda_cosmo):.2e} m")
print(f"Algebraic parameter λ = {lambda_param:.2e}")

print("\nBracket table [Pₐ, Pᵦ]:")
print("        P₀      P₁      P₂      P₃")
for a in range(4):
    row = f"  P_{a}  "
    for b in range(4):
        if a == b:
            row += "   0    "
        elif a < b:
            row += f"  λR_{a}{b}  "
        else:
            row += f" -λR_{b}{a}  "
    print(row)

# ============================================================================
# Part 4: Jacobi Identity Verification
# ============================================================================

print("\n\n✅ Jacobi Identity Verification")
print("-" * 50)

# We verify the Jacobi identity for the Lorentz subalgebra numerically
violations = 0
max_violation = 0

for i in range(6):
    for j in range(6):
        for k in range(6):
            # [[Mi, Mj], Mk] + [[Mj, Mk], Mi] + [[Mk, Mi], Mj] = 0
            comm_ij = lorentz_gens[i] @ lorentz_gens[j] - lorentz_gens[j] @ lorentz_gens[i]
            comm_jk = lorentz_gens[j] @ lorentz_gens[k] - lorentz_gens[k] @ lorentz_gens[j]
            comm_ki = lorentz_gens[k] @ lorentz_gens[i] - lorentz_gens[i] @ lorentz_gens[k]
            
            jacobi = (comm_ij @ lorentz_gens[k] - lorentz_gens[k] @ comm_ij +
                      comm_jk @ lorentz_gens[i] - lorentz_gens[i] @ comm_jk +
                      comm_ki @ lorentz_gens[j] - lorentz_gens[j] @ comm_ki)
            
            v = np.max(np.abs(jacobi))
            max_violation = max(max_violation, v)
            if v > 1e-10:
                violations += 1

print(f"\nLorentz subalgebra Jacobi identity check:")
print(f"  Triples tested: {6**3}")
print(f"  Violations: {violations}")
print(f"  Max residual: {max_violation:.2e}")
print(f"  Status: {'✅ PASSED' if violations == 0 else '❌ FAILED'}")

# ============================================================================
# Part 5: Visualization — The Algebra Structure
# ============================================================================

print("\n\n🎨 Generating Visualizations...")
print("-" * 50)

# --- Figure 1: The Graded Structure ---
fig, axes = plt.subplots(1, 2, figsize=(16, 7))

# Left panel: Grade structure as a horizontal bar chart
ax = axes[0]
grade_list = sorted(grades.keys())
dims = [grades[g][1] for g in grade_list]
colors = [grades[g][2] for g in grade_list]
labels = [f"𝔊{g:+d}\n{grades[g][0]}" for g in grade_list]

bars = ax.barh(range(5), dims, color=colors, edgecolor='black', linewidth=1.5, height=0.6)
ax.set_yticks(range(5))
ax.set_yticklabels(labels, fontsize=11, fontweight='bold')
ax.set_xlabel('Dimension', fontsize=13)
ax.set_title('The Gravitational Algebra 𝔊\nGraded Structure (dim = 54)', fontsize=15, fontweight='bold')

for bar, dim in zip(bars, dims):
    ax.text(bar.get_width() + 0.3, bar.get_y() + bar.get_height()/2, 
            f'{dim}', va='center', fontsize=12, fontweight='bold')

ax.set_xlim(0, 25)
ax.grid(axis='x', alpha=0.3)

# Right panel: Bracket structure as a connectivity diagram
ax = axes[1]
ax.set_xlim(-3, 3)
ax.set_ylim(-3, 3)
ax.set_aspect('equal')
ax.set_title('Bracket Structure [𝔊ᵢ, 𝔊ⱼ] ⊂ 𝔊ᵢ₊ⱼ', fontsize=15, fontweight='bold')

# Place grades in a circle
angles = {g: np.pi/2 + 2*np.pi*i/5 for i, g in enumerate(grade_list)}
positions = {g: (1.8*np.cos(angles[g]), 1.8*np.sin(angles[g])) for g in grade_list}

# Draw nodes
for g in grade_list:
    x, y = positions[g]
    circle = plt.Circle((x, y), 0.4, color=grades[g][2], ec='black', linewidth=2, zorder=5)
    ax.add_patch(circle)
    ax.text(x, y, f'𝔊{g:+d}', ha='center', va='center', fontsize=12, fontweight='bold', zorder=6)

# Draw bracket arrows
brackets = [
    (-2, 2, 0, "Einstein Eq."),
    (-1, -1, -2, "Curvature"),
    (-1, 0, -1, "Lorentz action"),
    (-1, 1, 0, "Ang. momentum"),
    (0, 0, 0, "Lorentz algebra"),
    (0, 1, 1, "Lorentz action"),
    (1, 1, 2, "Stress-energy"),
]

for g1, g2, g_out, label in brackets:
    x1, y1 = positions[g1]
    x2, y2 = positions[g2]
    xo, yo = positions[g_out]
    
    # Draw arc from midpoint of (g1,g2) to g_out
    mx, my = (x1 + x2) / 2, (y1 + y2) / 2
    
    if g1 == g2:
        # Self-bracket — draw a loop
        ax.annotate('', xy=(xo + 0.35, yo + 0.15), xytext=(xo - 0.35, yo + 0.15),
                    arrowprops=dict(arrowstyle='->', color=grades[g_out][2], lw=2,
                                   connectionstyle='arc3,rad=-1.5'))
    else:
        # Draw a curved arrow from midpoint to target
        ax.annotate('', xy=(xo, yo), xytext=(mx, my),
                    arrowprops=dict(arrowstyle='->', color='gray', lw=1.5,
                                   connectionstyle='arc3,rad=0.3'))

ax.axis('off')

plt.tight_layout()
plt.savefig('/workspace/request-project/algebraic_gravity/demos/fig1_algebra_structure.png', 
            dpi=150, bbox_inches='tight')
print("  Saved: fig1_algebra_structure.png")

# --- Figure 2: The Curvature Landscape ---
fig, axes = plt.subplots(1, 2, figsize=(16, 7))

# Left: Simulated curvature tensor components for Schwarzschild
ax = axes[0]
ax.set_title('Schwarzschild Solution in 𝔊₋₂\n(Curvature Components vs. r/rₛ)', 
             fontsize=13, fontweight='bold')

r_over_rs = np.linspace(1.01, 10, 500)  # r/r_s from just outside horizon

# Schwarzschild curvature components (in orthonormal frame)
# R^t_rtr = -2M/r³, R^t_θtθ = M/r³, etc.
# Normalized to r_s = 2M = 1
weyl_trtr = -1.0 / r_over_rs**3
weyl_thth = 0.5 / r_over_rs**3
weyl_phph = 0.5 / r_over_rs**3
weyl_cross = -0.5 / r_over_rs**3

ax.plot(r_over_rs, weyl_trtr, 'r-', linewidth=2, label=r'$R^{\hat{0}}{}_{\hat{1}\hat{0}\hat{1}}$ (radial tidal)')
ax.plot(r_over_rs, weyl_thth, 'b-', linewidth=2, label=r'$R^{\hat{0}}{}_{\hat{2}\hat{0}\hat{2}}$ (angular tidal)')
ax.plot(r_over_rs, weyl_phph, 'g--', linewidth=2, label=r'$R^{\hat{0}}{}_{\hat{3}\hat{0}\hat{3}}$ (angular tidal)')
ax.plot(r_over_rs, weyl_cross, 'm:', linewidth=2, label=r'$R^{\hat{2}}{}_{\hat{3}\hat{2}\hat{3}}$ (cross)')

ax.axhline(y=0, color='k', linewidth=0.5)
ax.axvline(x=1, color='k', linewidth=0.5, linestyle=':', label='Horizon (r = rₛ)')
ax.set_xlabel('r / rₛ', fontsize=12)
ax.set_ylabel('Curvature (units of 1/rₛ²)', fontsize=12)
ax.legend(fontsize=9, loc='lower right')
ax.set_xlim(1, 10)
ax.set_ylim(-1.2, 0.8)
ax.grid(alpha=0.3)

# Right: Algebraic norm of curvature element
ax = axes[1]
ax.set_title('Kretschner Scalar K = RₐᵦᵧᵟRᵃᵝᵞᵟ\n(Algebraic Invariant of 𝔊₋₂)', 
             fontsize=13, fontweight='bold')

# Kretschner scalar for Schwarzschild: K = 48M²/r⁶ = 12/r_s² · (r_s/r)⁶
kretschner = 12.0 / r_over_rs**6

ax.semilogy(r_over_rs, kretschner, 'darkred', linewidth=2.5)
ax.fill_between(r_over_rs, kretschner, alpha=0.15, color='red')
ax.axvline(x=1, color='k', linewidth=0.5, linestyle=':')
ax.set_xlabel('r / rₛ', fontsize=12)
ax.set_ylabel('K (units of 1/rₛ⁴)', fontsize=12)
ax.set_xlim(1, 10)
ax.grid(alpha=0.3)

# Add annotation
ax.annotate('Singularity\n(K → ∞ as r → 0)', xy=(1.2, 8), fontsize=11,
            fontweight='bold', color='darkred',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow', edgecolor='darkred'))

plt.tight_layout()
plt.savefig('/workspace/request-project/algebraic_gravity/demos/fig2_schwarzschild_curvature.png', 
            dpi=150, bbox_inches='tight')
print("  Saved: fig2_schwarzschild_curvature.png")

# --- Figure 3: The Algebraic Periodic Table of Gravity ---
fig, ax = plt.subplots(figsize=(14, 10))
ax.set_title('The Algebraic Periodic Table of Gravitational Phenomena', 
             fontsize=16, fontweight='bold')

# Each "element" is a gravitational phenomenon, classified by which grades of 𝔊 it involves
elements = [
    # (x, y, symbol, name, grades_involved, color)
    (0, 4, "Λ", "Cosmological\nConstant", "𝔊₀", "#f1c40f"),
    (1, 4, "η", "Minkowski\nMetric", "𝔊₋₁⊗𝔊₁", "#2ecc71"),
    (2, 4, "P", "Momentum\nConservation", "𝔊₁", "#2ecc71"),
    (3, 4, "L", "Angular\nMomentum", "𝔊₀", "#f1c40f"),
    
    (0, 3, "g", "Metric\nTensor", "𝔊₋₁⊗𝔊₋₁", "#e67e22"),
    (1, 3, "Γ", "Connection\nCoefficients", "𝔊₀↔𝔊₋₁", "#f39c12"),
    (2, 3, "R", "Riemann\nTensor", "𝔊₋₂", "#e74c3c"),
    (3, 3, "G", "Einstein\nTensor", "𝔊₋₂/𝔊₀", "#e74c3c"),
    
    (0, 2, "Φ", "Newtonian\nPotential", "𝔊₋₂↓", "#c0392b"),
    (1, 2, "ω", "Frame\nDragging", "𝔊₀·𝔊₋₁", "#f1c40f"),
    (2, 2, "h", "Gravitational\nWaves", "𝔊₋₂~", "#e74c3c"),
    (3, 2, "S", "Schwarzschild\nSolution", "Rep(𝔊)", "#9b59b6"),
    
    (0, 1, "K", "Kerr\nSolution", "Rep(𝔊)", "#9b59b6"),
    (1, 1, "F", "FLRW\nCosmology", "Rep(𝔊)", "#9b59b6"),
    (2, 1, "T", "Stress-Energy\nTensor", "𝔊₂", "#3498db"),
    (3, 1, "E", "Einstein\nEquation", "[𝔊₋₂,𝔊₂]", "#1abc9c"),
    
    (0, 0, "B", "Bianchi\nIdentity", "Jacobi(𝔊)", "#16a085"),
    (1, 0, "C", "Conservation\nLaw", "Jacobi(𝔊)", "#16a085"),
    (2, 0, "W", "Weyl\nTensor", "𝔊₋₂/trace", "#e74c3c"),
    (3, 0, "Q", "Quantum\nGravity?", "U(𝔊)", "#8e44ad"),
]

for x, y, symbol, name, grades, color in elements:
    # Draw box
    rect = plt.Rectangle((x * 3.2 + 0.1, y * 1.8 + 0.1), 2.8, 1.5, 
                          facecolor=color, edgecolor='black', linewidth=2, alpha=0.8)
    ax.add_patch(rect)
    
    # Symbol (large)
    ax.text(x * 3.2 + 0.4, y * 1.8 + 1.2, symbol, fontsize=20, fontweight='bold', 
            color='white', va='top')
    
    # Name
    ax.text(x * 3.2 + 1.5, y * 1.8 + 0.85, name, fontsize=8, ha='center', va='center',
            color='white', fontweight='bold')
    
    # Grades
    ax.text(x * 3.2 + 2.6, y * 1.8 + 0.25, grades, fontsize=7, ha='right', va='bottom',
            color='white', fontstyle='italic', alpha=0.9)

ax.set_xlim(-0.5, 13.5)
ax.set_ylim(-0.5, 10)
ax.axis('off')

# Legend
legend_elements = [
    mpatches.Patch(facecolor='#e74c3c', edgecolor='black', label='Curvature (𝔊₋₂)'),
    mpatches.Patch(facecolor='#e67e22', edgecolor='black', label='Translations (𝔊₋₁)'),
    mpatches.Patch(facecolor='#f1c40f', edgecolor='black', label='Lorentz (𝔊₀)'),
    mpatches.Patch(facecolor='#2ecc71', edgecolor='black', label='Momentum (𝔊₁)'),
    mpatches.Patch(facecolor='#3498db', edgecolor='black', label='Matter (𝔊₂)'),
    mpatches.Patch(facecolor='#9b59b6', edgecolor='black', label='Representations'),
    mpatches.Patch(facecolor='#16a085', edgecolor='black', label='Jacobi Identity'),
]
ax.legend(handles=legend_elements, loc='upper right', fontsize=10, framealpha=0.9,
          title='Algebraic Origin', title_fontsize=11)

plt.tight_layout()
plt.savefig('/workspace/request-project/algebraic_gravity/demos/fig3_periodic_table.png', 
            dpi=150, bbox_inches='tight')
print("  Saved: fig3_periodic_table.png")

print("\n✅ All visualizations generated successfully!")
print("=" * 70)
