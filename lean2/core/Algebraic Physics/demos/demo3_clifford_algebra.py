"""
Demo 3: Clifford Algebras and Spacetime

The Clifford algebra Cl(1,3) encodes all of special-relativistic spacetime physics.
The relation γμγν + γνγμ = 2gμν contains the Dirac equation, spinors, and Lorentz transformations.

This demonstrates Pillar III: Spacetime Algebra.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations

# ============================================================
# Clifford Algebra Cl(1,3) via Dirac Gamma Matrices
# ============================================================

# Pauli matrices
sigma = [
    np.array([[1, 0], [0, 1]], dtype=complex),   # sigma_0 = I
    np.array([[0, 1], [1, 0]], dtype=complex),    # sigma_1
    np.array([[0, -1j], [1j, 0]], dtype=complex), # sigma_2
    np.array([[1, 0], [0, -1]], dtype=complex),   # sigma_3
]

# Dirac gamma matrices (Dirac representation)
# γ⁰ = diag(I, -I), γⁱ = [[0, σⁱ], [-σⁱ, 0]]
gamma = [np.zeros((4, 4), dtype=complex) for _ in range(4)]

# γ⁰
gamma[0] = np.block([[sigma[0], np.zeros((2,2))],
                      [np.zeros((2,2)), -sigma[0]]])

# γ¹, γ², γ³
for i in range(1, 4):
    gamma[i] = np.block([[np.zeros((2,2)), sigma[i]],
                          [-sigma[i], np.zeros((2,2))]])

# γ⁵ = iγ⁰γ¹γ²γ³ (chirality operator)
gamma5 = 1j * gamma[0] @ gamma[1] @ gamma[2] @ gamma[3]

# Minkowski metric
eta = np.diag([1, -1, -1, -1])

def clifford_product(a, b):
    """Multiply two elements of the Clifford algebra (as 4x4 matrices)."""
    return a @ b

def anticommutator(a, b):
    """Compute {a, b} = ab + ba."""
    return a @ b + b @ a

def commutator(a, b):
    """Compute [a, b] = ab - ba."""
    return a @ b - b @ a

# ============================================================
# Figure: Clifford Algebra Structure
# ============================================================

fig = plt.figure(figsize=(18, 14))
fig.suptitle('Clifford Algebra Cl(1,3): The Algebra of Spacetime', 
             fontsize=18, fontweight='bold')

# --- Panel 1: Clifford algebra verification ---
ax1 = fig.add_subplot(231)

# Verify {γμ, γν} = 2ημν
verification_data = np.zeros((4, 4))
for mu in range(4):
    for nu in range(4):
        result = anticommutator(gamma[mu], gamma[nu])
        expected = 2 * eta[mu, nu] * np.eye(4)
        verification_data[mu, nu] = 1 if np.allclose(result, expected) else 0

im1 = ax1.imshow(verification_data, cmap='RdYlGn', vmin=0, vmax=1, aspect='equal')
ax1.set_xticks(range(4))
ax1.set_yticks(range(4))
labels = ['γ⁰', 'γ¹', 'γ²', 'γ³']
ax1.set_xticklabels(labels, fontsize=12)
ax1.set_yticklabels(labels, fontsize=12)
ax1.set_title('{γμ, γν} = 2ημν I₄\n(All verified ✓)', fontweight='bold', fontsize=12)

for mu in range(4):
    for nu in range(4):
        val = 2 * eta[mu, nu]
        color = 'white' if abs(val) > 0 else 'black'
        ax1.text(nu, mu, f'{int(val)}', ha='center', va='center', fontsize=14,
                fontweight='bold', color=color)

# --- Panel 2: Graded structure of Cl(1,3) ---
ax2 = fig.add_subplot(232)

grades = {
    0: {'label': 'Grade 0\n(Scalars)', 'elements': ['I'], 'count': 1, 'color': '#3498db'},
    1: {'label': 'Grade 1\n(Vectors)', 'elements': ['γ⁰','γ¹','γ²','γ³'], 'count': 4, 'color': '#e74c3c'},
    2: {'label': 'Grade 2\n(Bivectors)', 'elements': ['γ⁰¹','γ⁰²','γ⁰³','γ²³','γ³¹','γ¹²'], 'count': 6, 'color': '#2ecc71'},
    3: {'label': 'Grade 3\n(Trivectors)', 'elements': ['γ⁰¹²','γ⁰¹³','γ⁰²³','γ¹²³'], 'count': 4, 'color': '#9b59b6'},
    4: {'label': 'Grade 4\n(Pseudoscalar)', 'elements': ['γ⁵=γ⁰¹²³'], 'count': 1, 'color': '#f39c12'},
}

grade_nums = list(grades.keys())
counts = [grades[g]['count'] for g in grade_nums]
colors = [grades[g]['color'] for g in grade_nums]
grade_labels = [grades[g]['label'] for g in grade_nums]

bars = ax2.bar(grade_nums, counts, color=colors, edgecolor='black', linewidth=1.5, width=0.6)

for bar, count, g in zip(bars, counts, grade_nums):
    ax2.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.15,
            f'$\\binom{{4}}{{{g}}}$ = {count}', ha='center', fontsize=11, fontweight='bold')
    elts = ', '.join(grades[g]['elements'])
    ax2.text(bar.get_x() + bar.get_width()/2, bar.get_height()/2,
            elts, ha='center', va='center', fontsize=7, rotation=0,
            bbox=dict(boxstyle='round,pad=0.1', facecolor='white', alpha=0.7))

ax2.set_xlabel('Grade k', fontsize=12)
ax2.set_ylabel('Number of basis elements', fontsize=12)
ax2.set_title('Graded Structure of Cl(1,3)\ndim = 2⁴ = 16 = 1+4+6+4+1', fontweight='bold', fontsize=12)
ax2.set_xticks(grade_nums)
ax2.set_xticklabels(grade_labels, fontsize=9)

# --- Panel 3: Lorentz transformation as Clifford rotation ---
ax3 = fig.add_subplot(233)

# A boost in the x-direction: R = exp(φ/2 · γ⁰γ¹)
# = cosh(φ/2)I + sinh(φ/2)γ⁰γ¹
phis = np.linspace(0, 2, 50)  # rapidity

# Show how boost transforms (t, x) components
for phi in phis:
    # Boost matrix in 2D (t, x) subspace
    boost_t = np.cosh(phi)
    boost_x = np.sinh(phi)
    
ax3_t_vals = np.cosh(phis)
ax3_x_vals = np.sinh(phis)

# Plot worldlines under boost
ax3.plot(ax3_x_vals, ax3_t_vals, 'b-', linewidth=2.5, label='Boosted (1,0,0,0)')
ax3.plot(-ax3_x_vals, ax3_t_vals, 'r-', linewidth=2.5, label='Boosted (-1,0,0,0)')

# Light cone
phi_range = np.linspace(-3, 3, 100)
ax3.plot(phi_range, np.abs(phi_range), 'k--', alpha=0.3, linewidth=1, label='Light cone')

# Hyperbola t²-x²=1
x_hyp = np.linspace(-2.5, 2.5, 200)
t_hyp_pos = np.sqrt(1 + x_hyp**2)
ax3.plot(x_hyp, t_hyp_pos, 'g-', alpha=0.3, linewidth=1.5)

ax3.set_xlabel('x', fontsize=12)
ax3.set_ylabel('t', fontsize=12)
ax3.set_title('Lorentz Boost = Clifford Rotation\nR = exp(φ/2 · γ⁰γ¹)', fontweight='bold', fontsize=12)
ax3.legend(fontsize=9)
ax3.set_xlim([-3, 3])
ax3.set_ylim([0, 4])
ax3.set_aspect('equal')
ax3.grid(True, alpha=0.2)

# --- Panel 4: Bott periodicity ---
ax4 = fig.add_subplot(234)

# Clifford algebra classification (real case)
bott_data = {
    'n mod 8': list(range(8)),
    'Cl(n)': ['ℝ', 'ℂ', 'ℍ', 'ℍ⊕ℍ', 'M₂(ℍ)', 'M₄(ℂ)', 'M₈(ℝ)', 'M₈(ℝ)⊕M₈(ℝ)'],
    'K-theory': ['ℤ', 'ℤ₂', 'ℤ₂', '0', 'ℤ', '0', '0', '0'],
}

# Create table
table_data = list(zip(bott_data['n mod 8'], bott_data['Cl(n)'], bott_data['K-theory']))
col_labels = ['n mod 8', 'Cl(n,0)', 'KO⁻ⁿ(pt)']

table = ax4.table(cellText=table_data, colLabels=col_labels, loc='center',
                  cellLoc='center', colWidths=[0.2, 0.45, 0.2])
table.auto_set_font_size(False)
table.set_fontsize(11)
table.scale(1, 1.8)

# Color the header
for j in range(3):
    table[0, j].set_facecolor('#3498db')
    table[0, j].set_text_props(color='white', fontweight='bold')

# Color alternating rows
for i in range(1, 9):
    color = '#f0f0f0' if i % 2 == 0 else 'white'
    for j in range(3):
        table[i, j].set_facecolor(color)

ax4.axis('off')
ax4.set_title('Bott Periodicity: Cl(n+8) ≅ Cl(n) ⊗ M₁₆(ℝ)\n(Connected to topological insulators!)', 
             fontweight='bold', fontsize=12)

# --- Panel 5: Maxwell's equations as single Clifford equation ---
ax5 = fig.add_subplot(235)

maxwell_text = (
    "Maxwell's Equations in Cl(1,3)\n"
    "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n"
    "Define the electromagnetic bivector:\n"
    "  F = E₁γ₁₀ + E₂γ₂₀ + E₃γ₃₀\n"
    "    + B₁γ₂₃ + B₂γ₃₁ + B₃γ₁₂\n\n"
    "Define the spacetime derivative:\n"
    "  ∂ = γ⁰∂₀ + γ¹∂₁ + γ²∂₂ + γ³∂₃\n\n"
    "Then ALL FOUR Maxwell equations\n"
    "are the SINGLE equation:\n\n"
    "         ┌─────────────┐\n"
    "         │   ∂F = J    │\n"
    "         └─────────────┘\n\n"
    "Grade 1 part: ∇·E = ρ, ∇×B - ∂E/∂t = J\n"
    "Grade 3 part: ∇·B = 0, ∇×E + ∂B/∂t = 0\n\n"
    "One algebra. One equation. All of EM."
)
ax5.text(0.05, 0.95, maxwell_text, transform=ax5.transAxes, fontsize=10,
         verticalalignment='top', fontfamily='monospace',
         bbox=dict(boxstyle='round', facecolor='#fff3e0', alpha=0.9))
ax5.axis('off')
ax5.set_title('Electromagnetism from Algebra', fontweight='bold', fontsize=12)

# --- Panel 6: Dirac equation and spinor structure ---
ax6 = fig.add_subplot(236)

dirac_text = (
    "The Dirac Equation\n"
    "━━━━━━━━━━━━━━━━━━\n\n"
    "  (iγᵘ∂μ - m)ψ = 0\n\n"
    "Or in spacetime algebra:\n"
    "  (i∂ − m)ψ = 0\n"
    "  where ∂ = γᵘ∂μ (Dirac operator)\n\n"
    "Squaring the Dirac operator:\n"
    "  ∂² = γᵘγᵛ∂μ∂ν\n"
    "     = ½{γᵘ,γᵛ}∂μ∂ν  (by symmetry)\n"
    "     = ηᵘᵛ∂μ∂ν\n"
    "     = □  (d'Alembertian)\n\n"
    "So (i∂−m)(i∂+m)ψ = (□ + m²)ψ = 0\n"
    "⟹ Klein-Gordon from Dirac!\n\n"
    "γ⁵ψ_L = -ψ_L  (left-handed)\n"
    "γ⁵ψ_R = +ψ_R  (right-handed)\n\n"
    "Chirality is a GRADING of Cl(1,3)."
)
ax6.text(0.05, 0.97, dirac_text, transform=ax6.transAxes, fontsize=10,
         verticalalignment='top', fontfamily='monospace',
         bbox=dict(boxstyle='round', facecolor='#e8f8f5', alpha=0.9))
ax6.axis('off')
ax6.set_title('The Dirac Operator: Physics from D', fontweight='bold', fontsize=12)

plt.tight_layout()
plt.savefig('/workspace/request-project/figures/demo3_clifford_algebra.png', dpi=150, bbox_inches='tight')
plt.close()
print("✅ Figure saved: figures/demo3_clifford_algebra.png")

# ============================================================
# Computational Verification
# ============================================================
print("\n" + "="*60)
print("ALGEBRAIC VERIFICATION: Clifford Algebra Cl(1,3)")
print("="*60)

print("\n1. Clifford relation {γμ, γν} = 2ημν I₄:")
for mu in range(4):
    for nu in range(4):
        result = anticommutator(gamma[mu], gamma[nu])
        expected = 2 * eta[mu, nu] * np.eye(4)
        check = "✓" if np.allclose(result, expected) else "✗"
        if mu <= nu:
            print(f"   {check} {{γ{mu}, γ{nu}}} = {2*eta[mu,nu]:.0f} I₄")

print(f"\n2. (γ⁵)² = I₄: {np.allclose(gamma5 @ gamma5, np.eye(4))}")
print(f"   Tr(γ⁵) = {np.real(np.trace(gamma5)):.1f} (should be 0)")
print(f"   (γ⁵)† = γ⁵: {np.allclose(gamma5, gamma5.conj().T)}")

print(f"\n3. Chirality: {{γ⁵, γμ}} = 0 for all μ:")
for mu in range(4):
    ac = anticommutator(gamma5, gamma[mu])
    print(f"   {{γ⁵, γ{mu}}} = 0: {np.allclose(ac, 0)}")

# Verify Lorentz algebra
print(f"\n4. Lorentz generators σμν = (i/2)[γμ, γν]:")
sigma_01 = (1j/2) * commutator(gamma[0], gamma[1])
sigma_23 = (1j/2) * commutator(gamma[2], gamma[3])

# These should satisfy the Lorentz algebra
comm_result = commutator(sigma_01, sigma_23)
print(f"   [σ₀₁, σ₂₃] computed (should be 0 for independent planes)")
print(f"   Result is zero: {np.allclose(comm_result, 0)}")

print(f"\n5. Dimension count: 2⁴ = {2**4} basis elements for Cl(1,3)")
print(f"   Pascal row: C(4,0)+C(4,1)+C(4,2)+C(4,3)+C(4,4) = 1+4+6+4+1 = 16 ✓")
