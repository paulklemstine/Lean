#!/usr/bin/env python3
"""
╔══════════════════════════════════════════════════════════════════════╗
║  DEMO 5: The Complete Algebraic Structure of Spacetime              ║
║  The Algebraic Theory of Spacetime                                  ║
╚══════════════════════════════════════════════════════════════════════╝

Grand unified visualization showing:
1. The causal structure (light cone) as algebraic sign of v²
2. The Lorentz group structure from rotors
3. The graded algebra as a hierarchy of physical objects
4. The master diagram: Algebra → Geometry → Physics
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch, Circle, Wedge
from mpl_toolkits.mplot3d import Axes3D

# ══════════════════════════════════════════════════════════════════
# Visualization: The Grand Unified Picture
# ══════════════════════════════════════════════════════════════════

fig = plt.figure(figsize=(20, 16))
fig.suptitle("THE ALGEBRAIC THEORY OF SPACETIME\nA Complete Framework from Clifford Algebra Cl(1,3)",
             fontsize=20, fontweight='bold', y=0.99, color='#1a1a2e')

gs = gridspec.GridSpec(3, 3, hspace=0.45, wspace=0.35,
                       top=0.93, bottom=0.05, left=0.05, right=0.95)

# ─── Panel 1: Light Cone (Causal Structure) ──────────────────
ax1 = fig.add_subplot(gs[0, 0], projection='3d')

# Light cone: t² = x² + y²
u = np.linspace(0, 2*np.pi, 50)
v_param = np.linspace(-2, 2, 50)
U, V = np.meshgrid(u, v_param)

X = V * np.cos(U)
Y = V * np.sin(U)
Z = np.abs(V)  # t = |r| for light cone

# Future cone
ax1.plot_surface(X, Y, Z, alpha=0.3, color='gold', edgecolor='orange', linewidth=0.1)
# Past cone
ax1.plot_surface(X, Y, -Z, alpha=0.2, color='gold', edgecolor='orange', linewidth=0.1)

# Timelike worldline
t_wl = np.linspace(-2, 2, 100)
ax1.plot([0]*100, [0]*100, t_wl, 'r-', linewidth=3, label='Timelike (v² < 0)')

# Spacelike vector
ax1.quiver(0, 0, 0, 1.5, 1.5, 0, color='blue', linewidth=2, arrow_length_ratio=0.1)
ax1.text(1.5, 1.5, 0.3, 'Spacelike\nv² > 0', fontsize=8, color='blue')

# Null vector
ax1.quiver(0, 0, 0, 1.5, 0, 1.5, color='orange', linewidth=2, arrow_length_ratio=0.1)
ax1.text(1.5, 0, 1.8, 'Null\nv² = 0', fontsize=8, color='orange')

ax1.set_xlabel('x')
ax1.set_ylabel('y')
ax1.set_zlabel('t')
ax1.set_title('Causal Structure from v²\nv² = v·v (Clifford scalar)', fontsize=11, fontweight='bold')
ax1.view_init(elev=20, azim=-60)

# ─── Panel 2: The Graded Algebra Diamond ─────────────────────
ax2 = fig.add_subplot(gs[0, 1])
ax2.axis('off')
ax2.set_xlim(-3, 3)
ax2.set_ylim(-1, 6.5)
ax2.set_title('The Multivector Diamond\nCl(1,3) = ⊕ₖ ∧ᵏV', fontsize=13, fontweight='bold')

# Diamond shape with grade levels
diamond_data = [
    (0, 1, "Scalar", "1", "Mass, charge", '#2ecc71', 0.5),
    (1, 4, "Vector", "4", "Position, momentum", '#3498db', 0.7),
    (2, 6, "Bivector", "6", "EM field, rotation", '#e74c3c', 0.9),
    (3, 4, "Trivector", "4", "Dual current", '#9b59b6', 0.7),
    (4, 1, "Pseudoscalar", "1", "Chirality", '#f39c12', 0.5),
]

y_pos = [5.5, 4.2, 3.0, 1.8, 0.5]
for i, (grade, dim, name, dim_str, phys, color, width) in enumerate(diamond_data):
    y = y_pos[i]
    rect = FancyBboxPatch((-width*1.8, y-0.35), width*3.6, 0.7,
                          boxstyle="round,pad=0.1", facecolor=color, alpha=0.25,
                          edgecolor=color, linewidth=2)
    ax2.add_patch(rect)
    ax2.text(-1.5, y, f"∧{grade}V", fontsize=11, ha='center', va='center',
            fontweight='bold', color=color)
    ax2.text(0, y, f"dim {dim_str}", fontsize=10, ha='center', va='center',
            fontweight='bold')
    ax2.text(1.5, y, phys, fontsize=9, ha='center', va='center',
            color='#2c3e50', style='italic')

# Hodge star arrows
for i in range(2):
    ax2.annotate('', xy=(2.2, y_pos[4-i]), xytext=(2.2, y_pos[i]),
                arrowprops=dict(arrowstyle='<->', color='purple', lw=1.5,
                              connectionstyle='arc3,rad=0.5'))
ax2.text(2.8, 3.0, '★\nHodge\ndual', fontsize=9, ha='center', color='purple',
        fontweight='bold')

# ─── Panel 3: Lorentz Group Structure ────────────────────────
ax3 = fig.add_subplot(gs[0, 2])
ax3.axis('off')
ax3.set_xlim(-2, 2)
ax3.set_ylim(-1, 5)
ax3.set_title('Lorentz Group from Rotors\nSpin(1,3) ≅ SL(2,ℂ)', fontsize=13, fontweight='bold')

# Hierarchy of groups
groups = [
    (0, 4.2, "Spin(1,3)", "Rotor group: RR̃=1, even", '#c0392b'),
    (0, 3.2, "SL(2,ℂ)", "2×2 complex, det=1", '#e74c3c'),
    (0, 2.2, "SO⁺(1,3)", "Proper orthochronous Lorentz", '#3498db'),
    (-1.0, 1.0, "SO(3)", "Spatial rotations", '#2ecc71'),
    (1.0, 1.0, "Boosts", "Hyperbolic rotations", '#f39c12'),
]

for x, y, name, desc, color in groups:
    bbox = FancyBboxPatch((x-0.9, y-0.35), 1.8, 0.7,
                          boxstyle="round,pad=0.1", facecolor=color, alpha=0.2,
                          edgecolor=color, linewidth=2)
    ax3.add_patch(bbox)
    ax3.text(x, y+0.1, name, fontsize=11, ha='center', va='center',
            fontweight='bold', color=color)
    ax3.text(x, y-0.15, desc, fontsize=7, ha='center', va='center',
            color='#2c3e50')

# Arrows
ax3.annotate('', xy=(0, 3.55), xytext=(0, 3.85),
            arrowprops=dict(arrowstyle='->', color='gray', lw=1.5))
ax3.text(0.5, 3.7, '2:1\ncover', fontsize=8, ha='center', color='gray')

ax3.annotate('', xy=(0, 2.55), xytext=(0, 2.85),
            arrowprops=dict(arrowstyle='->', color='gray', lw=1.5))
ax3.text(0.5, 2.7, '≅', fontsize=12, ha='center', color='gray')

ax3.annotate('', xy=(-1.0, 1.35), xytext=(-0.3, 1.85),
            arrowprops=dict(arrowstyle='->', color='gray', lw=1.5))
ax3.annotate('', xy=(1.0, 1.35), xytext=(0.3, 1.85),
            arrowprops=dict(arrowstyle='->', color='gray', lw=1.5))

# ─── Panel 4: The Master Equation ∇F = J ─────────────────────
ax4 = fig.add_subplot(gs[1, 0])
ax4.axis('off')
ax4.set_xlim(0, 10)
ax4.set_ylim(0, 10)
ax4.set_title("The Master Equations of Physics\nin Spacetime Algebra", fontsize=13, fontweight='bold')

equations = [
    ("∇F = J", "Maxwell's equations (all 4)", '#e74c3c', 9),
    ("∇ψIσ₃ = mψγ₀", "Dirac equation", '#3498db', 7.5),
    ("v² = ±1", "Causal classification", '#2ecc71', 6),
    ("v' = RvR̃", "Lorentz transformation", '#9b59b6', 4.5),
    ("I² = −1", "Spacetime orientation", '#f39c12', 3),
    ("F = dA", "EM potential (exterior derivative)", '#1abc9c', 1.5),
]

for eq, desc, color, y in equations:
    ax4.add_patch(FancyBboxPatch((0.5, y-0.5), 4, 1.0,
                                 boxstyle="round,pad=0.1", facecolor=color,
                                 alpha=0.15, edgecolor=color, linewidth=2))
    ax4.text(2.5, y, eq, fontsize=14, ha='center', va='center',
            fontweight='bold', color=color, family='serif')
    ax4.text(7, y, desc, fontsize=10, ha='center', va='center',
            color='#2c3e50')
    ax4.annotate('', xy=(5, y), xytext=(5.5, y),
                arrowprops=dict(arrowstyle='->', color=color, lw=2))

# ─── Panel 5: Periodicity / Bott Clock ───────────────────────
ax5 = fig.add_subplot(gs[1, 1], projection='polar')

# The Clifford algebra periodicity (Bott periodicity)
# Cl(n+8) ≅ Cl(n) ⊗ M₁₆(ℝ)
angles_bott = np.linspace(0, 2*np.pi, 9)[:-1]
labels_bott = [
    "Cl(0)=ℝ", "Cl(1)=ℝ⊕ℝ", "Cl(2)=M₂(ℝ)",
    "Cl(3)=M₂(ℂ)", "Cl(4)=M₂(ℍ)", "Cl(5)=M₄(ℂ)",
    "Cl(6)=M₈(ℝ)", "Cl(7)=M₈(ℝ)⊕M₈(ℝ)"
]
colors_bott = plt.cm.Set2(np.linspace(0, 1, 8))

bars = ax5.bar(angles_bott, [1]*8, width=0.7, alpha=0.6,
               color=colors_bott, edgecolor='black', linewidth=1)

for angle, label in zip(angles_bott, labels_bott):
    ax5.text(angle, 1.25, label, ha='center', va='center',
            fontsize=7, fontweight='bold', rotation=np.degrees(angle)-90
            if np.pi/2 < angle < 3*np.pi/2 else np.degrees(angle)+90)

ax5.set_ylim(0, 1.6)
ax5.set_yticks([])
ax5.set_xticks([])
ax5.set_title('Bott Periodicity Clock\nCl(n+8) ≅ Cl(n) ⊗ M₁₆(ℝ)',
             fontsize=11, fontweight='bold', pad=25)

# Highlight Cl(1,3)
ax5.text(0, 0, 'Cl(1,3)\n≅\nM₂(ℍ)', fontsize=12, ha='center', va='center',
        fontweight='bold', color='#c0392b',
        bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.9))

# ─── Panel 6: EM field as bivector planes ─────────────────────
ax6 = fig.add_subplot(gs[1, 2], projection='3d')

# Visualize bivector planes in 3D (spatial part)
# γ₁₂ plane (xy)
x_plane = np.linspace(-1, 1, 10)
y_plane = np.linspace(-1, 1, 10)
X_p, Y_p = np.meshgrid(x_plane, y_plane)
Z_p = np.zeros_like(X_p)

ax6.plot_surface(X_p, Y_p, Z_p, alpha=0.2, color='blue', edgecolor='blue', linewidth=0.3)
ax6.text(0, 0, -0.2, 'γ₁₂ (B₃)', fontsize=10, color='blue', ha='center', fontweight='bold')

# γ₂₃ plane (yz)
Y_p2, Z_p2 = np.meshgrid(y_plane, x_plane)
X_p2 = np.zeros_like(Y_p2)
ax6.plot_surface(X_p2, Y_p2, Z_p2, alpha=0.2, color='red', edgecolor='red', linewidth=0.3)
ax6.text(-0.2, 0, 0, 'γ₂₃ (B₁)', fontsize=10, color='red', ha='center', fontweight='bold')

# γ₃₁ plane (zx)
X_p3, Z_p3 = np.meshgrid(x_plane, y_plane)
Y_p3 = np.zeros_like(X_p3)
ax6.plot_surface(X_p3, Y_p3, Z_p3, alpha=0.2, color='green', edgecolor='green', linewidth=0.3)
ax6.text(0, -0.2, 0, 'γ₃₁ (B₂)', fontsize=10, color='green', ha='center', fontweight='bold')

ax6.set_xlabel('x (γ₁)')
ax6.set_ylabel('y (γ₂)')
ax6.set_zlabel('z (γ₃)')
ax6.set_title('Spatial Bivectors = Planes\nMagnetic field B lives here', fontsize=11, fontweight='bold')
ax6.view_init(elev=25, azim=-45)

# ─── Panel 7: The Grand Unified Diagram ──────────────────────
ax7 = fig.add_subplot(gs[2, :])
ax7.axis('off')
ax7.set_xlim(0, 20)
ax7.set_ylim(0, 4)
ax7.set_title('THE ALGEBRAIC THEORY OF SPACETIME — Grand Unified Picture',
             fontsize=16, fontweight='bold', color='#1a1a2e')

# Flow: Algebra → Geometry → Physics
boxes = [
    (2, 2, "ALGEBRA\nCl(1,3)", '#e74c3c', 2.5, 2.0),
    (7, 2, "GEOMETRY\nMinkowski\nSpace", '#3498db', 2.5, 2.0),
    (12, 2, "PHYSICS\nSpecial\nRelativity", '#2ecc71', 2.5, 2.0),
    (17, 2, "MATTER\nDirac\nEquation", '#9b59b6', 2.5, 2.0),
]

for x, y, text, color, w, h in boxes:
    bbox = FancyBboxPatch((x - w/2, y - h/2), w, h,
                          boxstyle="round,pad=0.2", facecolor=color, alpha=0.2,
                          edgecolor=color, linewidth=3)
    ax7.add_patch(bbox)
    ax7.text(x, y, text, fontsize=12, ha='center', va='center',
            fontweight='bold', color=color)

# Arrows between boxes
arrow_labels = [
    (4.25, 5.75, "γμγν + γνγμ = 2ημν\n→ metric emerges"),
    (9.25, 10.75, "v↦RvR̃\n→ Lorentz symmetry"),
    (14.25, 15.75, "∇ψIσ₃ = mψγ₀\n→ quantum fields"),
]

for x1, x2, label in arrow_labels:
    ax7.annotate('', xy=(x2, 2), xytext=(x1, 2),
                arrowprops=dict(arrowstyle='->', color='#2c3e50', lw=3,
                              connectionstyle='arc3,rad=0'))
    ax7.text((x1+x2)/2, 0.5, label, fontsize=9, ha='center', va='center',
            style='italic', color='#2c3e50')

# Bottom tagline
ax7.text(10, -0.2, '"The geometric product is the Rosetta Stone of physics — it translates between algebra, geometry, and physics."',
        fontsize=11, ha='center', va='center', style='italic', color='#7f8c8d')

plt.savefig('/workspace/request-project/Algebraic Spacetime/demos/fig5_grand_unified.png',
            dpi=150, bbox_inches='tight', facecolor='white')
plt.close()

print("=" * 60)
print("  DEMO 5: THE GRAND UNIFIED PICTURE")
print("=" * 60)
print("\n✓ Figure saved: fig5_grand_unified.png")
print("\n  The Algebraic Theory of Spacetime shows that:")
print("  1. Spacetime IS a Clifford algebra")
print("  2. The metric EMERGES from the algebraic relations")
print("  3. Lorentz transformations ARE rotor conjugations")
print("  4. EM field IS a bivector, Maxwell IS ∇F = J")
print("  5. Spinors ARE ideals, Dirac IS ∇ψIσ₃ = mψγ₀")
print("  6. Discrete symmetries ARE algebraic involutions")
print()
print("  Everything is algebra. The rest is commentary.")
print("\n" + "=" * 60)
print("  DEMO 5 COMPLETE — ALL DEMOS FINISHED")
print("=" * 60)
