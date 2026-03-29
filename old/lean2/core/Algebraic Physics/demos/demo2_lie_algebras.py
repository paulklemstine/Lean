"""
Demo 2: Lie Algebras and Particle Physics

The symmetry algebras of physics — su(2), su(3), and the Poincaré algebra —
determine the classification of elementary particles.

This demonstrates Pillar II: Symmetry Algebras.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.patches import RegularPolygon
import matplotlib.colors as mcolors

# ============================================================
# SU(2) Representation Theory
# ============================================================

def su2_weights(j):
    """Return weights (eigenvalues of J₃) for spin-j representation."""
    return np.arange(-j, j + 1, 1)

def su2_dim(j):
    """Dimension of spin-j representation = 2j + 1."""
    return int(2 * j + 1)

# ============================================================
# SU(3) Weight Diagrams — The Eightfold Way
# ============================================================

def su3_weight_to_xy(I3, Y):
    """Convert SU(3) quantum numbers to plot coordinates.
    I3 = isospin third component, Y = hypercharge.
    Uses 60° axes natural for SU(3) weight diagrams.
    """
    x = I3
    y = Y * np.sqrt(3) / 2
    return x, y

# ============================================================
# Figure: Lie Algebras and Particle Classification
# ============================================================

fig = plt.figure(figsize=(18, 14))
fig.suptitle('Symmetry Algebras: Particles as Representations', 
             fontsize=18, fontweight='bold')

# --- Panel 1: SU(2) Spin Representations ---
ax1 = fig.add_subplot(231)

spins = [0, 0.5, 1, 1.5, 2]
colors_su2 = ['#2ecc71', '#3498db', '#e74c3c', '#9b59b6', '#f39c12']

for i, j in enumerate(spins):
    weights = su2_weights(j)
    y_pos = len(spins) - 1 - i
    ax1.scatter(weights, [y_pos]*len(weights), c=colors_su2[i], s=150, zorder=5, edgecolors='black')
    for w in weights:
        ax1.annotate(f'{w:+.1f}', (w, y_pos), textcoords="offset points", 
                    xytext=(0, 12), ha='center', fontsize=8)
    ax1.text(-2.7, y_pos, f'j = {j}\ndim = {su2_dim(j)}', fontsize=10, va='center',
            fontweight='bold', color=colors_su2[i])

ax1.set_xlabel('Weight m (eigenvalue of J₃)', fontsize=11)
ax1.set_title('SU(2) Representations\n[σᵢ, σⱼ] = 2iεᵢⱼₖσₖ', fontweight='bold', fontsize=12)
ax1.set_xlim([-3, 2.5])
ax1.set_yticks([])
ax1.grid(True, alpha=0.2, axis='x')
ax1.axvline(x=0, color='gray', linestyle='-', alpha=0.3)

# --- Panel 2: Meson Octet (SU(3) adjoint representation) ---
ax2 = fig.add_subplot(232)

# Meson octet: 8 representation of SU(3)_flavor
# (I3, Y, name, color)
mesons = [
    (1, 0, 'π⁺', '#e74c3c'),
    (-1, 0, 'π⁻', '#e74c3c'),
    (0, 0, 'π⁰', '#e74c3c'),
    (0.5, 1, 'K⁺', '#3498db'),
    (-0.5, 1, 'K⁰', '#3498db'),
    (0.5, -1, 'K̄⁰', '#2ecc71'),
    (-0.5, -1, 'K⁻', '#2ecc71'),
    (0, 0, 'η', '#9b59b6'),
]

for I3, Y, name, color in mesons:
    x, y = su3_weight_to_xy(I3, Y)
    if name == 'η':  # offset η from π⁰
        y -= 0.15
    ax2.scatter([x], [y], c=color, s=200, zorder=5, edgecolors='black', linewidth=1.5)
    offset = (10, 10) if name not in ['π⁰', 'η'] else (10, -15)
    ax2.annotate(name, (x, y), textcoords="offset points", xytext=offset,
                fontsize=12, fontweight='bold', color=color)

# Draw hexagonal outline
hex_points = [(1, 0), (0.5, np.sqrt(3)/2), (-0.5, np.sqrt(3)/2),
              (-1, 0), (-0.5, -np.sqrt(3)/2), (0.5, -np.sqrt(3)/2), (1, 0)]
hx, hy = zip(*hex_points)
ax2.plot(hx, hy, 'k-', alpha=0.3, linewidth=1)

ax2.set_xlabel('Isospin I₃', fontsize=11)
ax2.set_ylabel('Hypercharge Y (×√3/2)', fontsize=11)
ax2.set_title('Meson Octet: 8 of SU(3)\n3 ⊗ 3̄ = 8 ⊕ 1', fontweight='bold', fontsize=12)
ax2.set_aspect('equal')
ax2.grid(True, alpha=0.2)
ax2.set_xlim([-1.5, 1.5])
ax2.set_ylim([-1.2, 1.2])

# --- Panel 3: Baryon Decuplet ---
ax3 = fig.add_subplot(233)

# Baryon decuplet: 10 representation
# (I3, Y, name, charge)
baryons_10 = [
    # Row 1 (top): Δ particles, Y = 1
    (-1.5, 1, 'Δ⁻', '#e74c3c'),
    (-0.5, 1, 'Δ⁰', '#e74c3c'),
    (0.5, 1, 'Δ⁺', '#e74c3c'),
    (1.5, 1, 'Δ⁺⁺', '#e74c3c'),
    # Row 2: Σ* particles, Y = 0
    (-1, 0, 'Σ*⁻', '#3498db'),
    (0, 0, 'Σ*⁰', '#3498db'),
    (1, 0, 'Σ*⁺', '#3498db'),
    # Row 3: Ξ* particles, Y = -1
    (-0.5, -1, 'Ξ*⁻', '#2ecc71'),
    (0.5, -1, 'Ξ*⁰', '#2ecc71'),
    # Row 4: Ω⁻, Y = -2 (PREDICTED by algebra, then discovered!)
    (0, -2, 'Ω⁻', '#f39c12'),
]

for I3, Y, name, color in baryons_10:
    x, y = su3_weight_to_xy(I3, Y)
    ax3.scatter([x], [y], c=color, s=200, zorder=5, edgecolors='black', linewidth=1.5)
    ax3.annotate(name, (x, y), textcoords="offset points", xytext=(8, 8),
                fontsize=10, fontweight='bold', color=color)

# Triangular outline
tri_points = [(-1.5, np.sqrt(3)/2), (1.5, np.sqrt(3)/2), (0, -np.sqrt(3)), (-1.5, np.sqrt(3)/2)]
tx, ty = zip(*tri_points)
ax3.plot(tx, ty, 'k-', alpha=0.3, linewidth=1)

# Highlight the prediction
ax3.annotate('PREDICTED 1962\nDISCOVERED 1964', 
            xy=(0, -np.sqrt(3)), xytext=(0.8, -2),
            fontsize=9, fontweight='bold', color='#f39c12',
            arrowprops=dict(arrowstyle='->', color='#f39c12', lw=2),
            bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow', edgecolor='#f39c12'))

ax3.set_xlabel('Isospin I₃', fontsize=11)
ax3.set_ylabel('Hypercharge Y (×√3/2)', fontsize=11)
ax3.set_title('Baryon Decuplet: 10 of SU(3)\nAlgebra predicts particles!', fontweight='bold', fontsize=12)
ax3.set_aspect('equal')
ax3.grid(True, alpha=0.2)

# --- Panel 4: Representation dimensions ---
ax4 = fig.add_subplot(234)

# Young diagram / representation data for SU(3)
reps = ['1', '3', '3̄', '6', '8', '10', '10̄', '15', '27']
dims = [1, 3, 3, 6, 8, 10, 10, 15, 27]
physics = ['singlet', 'quarks', 'antiquarks', '—', 'octet', 'decuplet', 
           'anti-dec.', '—', '—']

bars = ax4.barh(range(len(reps)), dims, color=plt.cm.viridis(np.linspace(0.2, 0.8, len(reps))))
ax4.set_yticks(range(len(reps)))
ax4.set_yticklabels([f'{r} ({p})' for r, p in zip(reps, physics)], fontsize=10)
ax4.set_xlabel('Dimension', fontsize=11)
ax4.set_title('SU(3) Representations\nParticles = Irreps', fontweight='bold', fontsize=12)
ax4.grid(True, alpha=0.2, axis='x')

for bar, dim in zip(bars, dims):
    ax4.text(bar.get_width() + 0.3, bar.get_y() + bar.get_height()/2,
            str(dim), va='center', fontweight='bold', fontsize=10)

# --- Panel 5: Standard Model Gauge Group ---
ax5 = fig.add_subplot(235)

# Visualize the Standard Model gauge group structure
sm_text = (
    "Standard Model Gauge Group\n"
    "━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n"
    "G_SM = U(1)_Y × SU(2)_L × SU(3)_c\n\n"
    "┌─────────────────────────────────┐\n"
    "│ U(1)_Y   │ dim = 1  │ Hypercharge│\n"
    "│ SU(2)_L  │ dim = 3  │ Weak force │\n"
    "│ SU(3)_c  │ dim = 8  │ Strong force│\n"
    "│ Total    │ dim = 12 │ gauge bosons│\n"
    "└─────────────────────────────────┘\n\n"
    "Gauge Bosons = Generators:\n"
    "  • γ (photon)  — from U(1)_EM\n"
    "  • W⁺, W⁻, Z⁰ — from SU(2)_L × U(1)_Y\n"
    "  • g₁...g₈     — from SU(3)_c\n\n"
    "Forces ARE Lie algebra elements!"
)
ax5.text(0.05, 0.95, sm_text, transform=ax5.transAxes, fontsize=10.5,
         verticalalignment='top', fontfamily='monospace',
         bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))
ax5.axis('off')
ax5.set_title('The Algebraic Origin of Forces', fontweight='bold', fontsize=12)

# --- Panel 6: Noether's theorem diagram ---
ax6 = fig.add_subplot(236)

noether_text = (
    "Noether's Theorem (Algebraic Form)\n"
    "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n"
    "  Lie group G ──acts on──▶ C*-algebra A\n"
    "       │                        │\n"
    "       │ differentiate          │ derivations\n"
    "       ▼                        ▼\n"
    "  Lie algebra 𝔤 ──homomorphism──▶ Der(A)\n"
    "       │                        │\n"
    "       │                        │ if inner\n"
    "       ▼                        ▼\n"
    "  Generator ξ ◀──corresponds──▶ Q_ξ ∈ A\n"
    "  (symmetry)                (conserved charge)\n\n"
    "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
    "  Symmetry        │  Conserved Quantity\n"
    "  ─────────────── │ ──────────────────\n"
    "  Time translation│  Energy\n"
    "  Space translation│ Momentum\n"
    "  Rotation        │  Angular momentum\n"
    "  U(1) phase      │  Electric charge\n"
    "  SU(3) color     │  Color charge\n"
)
ax6.text(0.02, 0.97, noether_text, transform=ax6.transAxes, fontsize=9.5,
         verticalalignment='top', fontfamily='monospace',
         bbox=dict(boxstyle='round', facecolor='#e8f4fd', alpha=0.8))
ax6.axis('off')
ax6.set_title("Noether's Theorem: 𝔤 → Der(A)", fontweight='bold', fontsize=12)

plt.tight_layout()
plt.savefig('/workspace/request-project/figures/demo2_lie_algebras.png', dpi=150, bbox_inches='tight')
plt.close()
print("✅ Figure saved: figures/demo2_lie_algebras.png")

# ============================================================
# Computational Verification
# ============================================================
print("\n" + "="*60)
print("ALGEBRAIC VERIFICATION: Lie Algebras")
print("="*60)

# Pauli matrices for verification
sigma_x = np.array([[0, 1], [1, 0]], dtype=complex)
sigma_y = np.array([[0, -1j], [1j, 0]], dtype=complex)
sigma_z = np.array([[1, 0], [0, -1]], dtype=complex)

# Verify SU(2) structure constants
comm_xy = sigma_x @ sigma_y - sigma_y @ sigma_x
print(f"\n[σx, σy] = 2iσz: {np.allclose(comm_xy, 2j * sigma_z)}")

# Gell-Mann matrices (generators of su(3))
lambda1 = np.array([[0,1,0],[1,0,0],[0,0,0]], dtype=complex)
lambda2 = np.array([[0,-1j,0],[1j,0,0],[0,0,0]], dtype=complex)
lambda3 = np.array([[1,0,0],[0,-1,0],[0,0,0]], dtype=complex)
lambda4 = np.array([[0,0,1],[0,0,0],[1,0,0]], dtype=complex)
lambda5 = np.array([[0,0,-1j],[0,0,0],[1j,0,0]], dtype=complex)
lambda6 = np.array([[0,0,0],[0,0,1],[0,1,0]], dtype=complex)
lambda7 = np.array([[0,0,0],[0,0,-1j],[0,1j,0]], dtype=complex)
lambda8 = np.array([[1,0,0],[0,1,0],[0,0,-2]], dtype=complex) / np.sqrt(3)

gell_mann = [lambda1, lambda2, lambda3, lambda4, lambda5, lambda6, lambda7, lambda8]

print(f"\nSU(3) Gell-Mann matrices:")
print(f"  Number of generators: {len(gell_mann)} (= dim su(3) = 8)")
for i, lam in enumerate(gell_mann):
    print(f"  Tr(λ{i+1}) = {np.trace(lam):.4f} (should be 0)")
    print(f"  Tr(λ{i+1}²) = {np.real(np.trace(lam @ lam)):.4f} (should be 2)")

# Verify [λ1, λ2] = 2i λ3
comm_12 = lambda1 @ lambda2 - lambda2 @ lambda1
print(f"\n[λ₁, λ₂] = 2iλ₃: {np.allclose(comm_12, 2j * lambda3)}")

# Casimir operator
C2 = sum(lam @ lam for lam in gell_mann)
print(f"\nQuadratic Casimir C₂ = Σλᵢ²:")
print(f"  C₂ = {np.real(C2[0,0]):.4f} × I₃ (should be 16/3 × I₃ for adjoint)")
print(f"  Proportional to identity: {np.allclose(C2, C2[0,0]*np.eye(3))}")
