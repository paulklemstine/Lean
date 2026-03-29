#!/usr/bin/env python3
"""
Demo 5: Clifford Algebra Unification of Electromagnetism
==========================================================

In the Clifford algebra Cl(1,3) of spacetime, the electric and magnetic
fields unify into a single multivector:

    F = E + IB

where I = e₀e₁e₂e₃ is the pseudoscalar.

Maxwell's equations become a single algebraic equation:
    ∇F = J/ε₀

This demo implements Clifford algebra computations and visualizes
the unified electromagnetic field.

Part of: The Algebraic Theory of Electricity
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec

plt.rcParams.update({
    'figure.facecolor': '#0a0a1a',
    'axes.facecolor': '#0a0a1a',
    'text.color': '#e0e0e0',
    'axes.labelcolor': '#e0e0e0',
    'xtick.color': '#888888',
    'ytick.color': '#888888',
    'axes.edgecolor': '#333333',
    'font.family': 'monospace',
    'font.size': 10,
})

GOLD = '#FFD700'
CYAN = '#00FFFF'
MAGENTA = '#FF00FF'
LIME = '#00FF88'
ORANGE = '#FF8800'
RED = '#FF4444'
BLUE = '#4488FF'
WHITE = '#FFFFFF'

# ─── Simplified Clifford Algebra Implementation ───

class Multivector:
    """A multivector in Cl(3,0) — the 3D Euclidean Clifford algebra.
    Basis: {1, e1, e2, e3, e12, e13, e23, e123}
    Represented as 8 components."""

    NAMES = ['1', 'e₁', 'e₂', 'e₃', 'e₁₂', 'e₁₃', 'e₂₃', 'e₁₂₃']

    def __init__(self, components=None):
        self.c = np.zeros(8) if components is None else np.array(components, dtype=float)

    @classmethod
    def scalar(cls, s):
        mv = cls()
        mv.c[0] = s
        return mv

    @classmethod
    def vector(cls, x, y, z):
        mv = cls()
        mv.c[1], mv.c[2], mv.c[3] = x, y, z
        return mv

    @classmethod
    def bivector(cls, xy, xz, yz):
        mv = cls()
        mv.c[4], mv.c[5], mv.c[6] = xy, xz, yz
        return mv

    def __add__(self, other):
        return Multivector(self.c + other.c)

    def __sub__(self, other):
        return Multivector(self.c - other.c)

    def __mul__(self, other):
        """Geometric product in Cl(3,0)."""
        if isinstance(other, (int, float)):
            return Multivector(self.c * other)
        # Full geometric product using multiplication table
        result = np.zeros(8)
        a, b = self.c, other.c

        # Scalar part
        result[0] = (a[0]*b[0] + a[1]*b[1] + a[2]*b[2] + a[3]*b[3]
                     - a[4]*b[4] - a[5]*b[5] - a[6]*b[6] - a[7]*b[7])
        # Vector parts
        result[1] = (a[0]*b[1] + a[1]*b[0] - a[4]*b[2] - a[5]*b[3]
                     + a[2]*b[4] + a[3]*b[5] - a[6]*b[7] - a[7]*b[6])
        result[2] = (a[0]*b[2] + a[2]*b[0] + a[4]*b[1] - a[6]*b[3]
                     - a[1]*b[4] + a[3]*b[6] + a[5]*b[7] + a[7]*b[5])
        result[3] = (a[0]*b[3] + a[3]*b[0] + a[5]*b[1] + a[6]*b[2]
                     - a[1]*b[5] - a[2]*b[6] - a[4]*b[7] - a[7]*b[4])
        # Bivector parts
        result[4] = (a[0]*b[4] + a[4]*b[0] + a[1]*b[2] - a[2]*b[1]
                     + a[5]*b[6] - a[6]*b[5] + a[7]*b[3] + a[3]*b[7])
        result[5] = (a[0]*b[5] + a[5]*b[0] + a[1]*b[3] - a[3]*b[1]
                     - a[4]*b[6] + a[6]*b[4] - a[7]*b[2] - a[2]*b[7])
        result[6] = (a[0]*b[6] + a[6]*b[0] + a[2]*b[3] - a[3]*b[2]
                     + a[4]*b[5] - a[5]*b[4] + a[7]*b[1] + a[1]*b[7])
        # Pseudoscalar part
        result[7] = (a[0]*b[7] + a[7]*b[0] + a[1]*b[6] - a[6]*b[1]
                     + a[2]*b[5] - a[5]*b[2] + a[3]*b[4] - a[4]*b[3])
        return Multivector(result)

    def reverse(self):
        """Reversion: (AB)† = B†A†, reverses order of basis vectors."""
        r = self.c.copy()
        r[4:7] *= -1  # bivectors
        r[7] *= -1    # pseudoscalar
        return Multivector(r)

    def grade(self, k):
        """Extract grade-k part."""
        mv = Multivector()
        if k == 0: mv.c[0] = self.c[0]
        elif k == 1: mv.c[1:4] = self.c[1:4]
        elif k == 2: mv.c[4:7] = self.c[4:7]
        elif k == 3: mv.c[7] = self.c[7]
        return mv

    def norm_sq(self):
        return (self * self.reverse()).c[0]

    def __repr__(self):
        terms = []
        for i, (c, name) in enumerate(zip(self.c, self.NAMES)):
            if abs(c) > 1e-10:
                terms.append(f'{c:+.3f}{name}')
        return ' '.join(terms) if terms else '0'

# ─── Demonstrate the Clifford algebra of EM ───

print("═══ CLIFFORD ALGEBRA OF ELECTROMAGNETISM ═══\n")

# Electric field as a vector
E = Multivector.vector(1.0, 0.0, 0.0)
print(f"E = {E}")

# Magnetic field as a bivector (dual to B vector via pseudoscalar)
I = Multivector()
I.c[7] = 1.0  # pseudoscalar e₁₂₃
B_vec = Multivector.vector(0.0, 0.0, 1.0)
B_bivec = I * B_vec  # IB is a bivector
print(f"B (vector) = {B_vec}")
print(f"IB (bivector) = {B_bivec}")

# The electromagnetic field
F = E + B_bivec
print(f"\nF = E + IB = {F}")

# Energy density: ½F†F
F_rev = F.reverse()
energy = (F * F_rev) * 0.5
print(f"\n½F†F = {energy}")
print(f"Energy density (scalar part): {energy.c[0]:.4f}")
print(f"  = ½(E² + B²) = ½({E.norm_sq():.1f} + {B_vec.norm_sq():.1f}) = {0.5*(E.norm_sq() + B_vec.norm_sq()):.4f}")

# Rotation of E by 90° around z-axis
theta = np.pi / 4
R = Multivector()
R.c[0] = np.cos(theta/2)  # scalar part
R.c[4] = -np.sin(theta/2)  # e₁₂ part (rotation in xy plane)
R_rev = R.reverse()

E_rotated = R * E * R_rev
print(f"\nRotation by {np.degrees(theta):.0f}° around z:")
print(f"  E' = RE R̃ = {E_rotated}")

# ─── Visualization ───

fig = plt.figure(figsize=(22, 14))
fig.suptitle("CLIFFORD ALGEBRA UNIFICATION OF ELECTROMAGNETISM",
             fontsize=18, color=GOLD, fontweight='bold', y=0.98)
gs = GridSpec(2, 3, figure=fig, hspace=0.35, wspace=0.3)

# Panel 1: Cl(3,0) multiplication table
ax1 = fig.add_subplot(gs[0, 0])
ax1.axis('off')

table_text = """
╔═══════════════════════════════════════╗
║  CLIFFORD ALGEBRA Cl(3,0)            ║
║  Geometric Product Table             ║
╠═══════════════════════════════════════╣
║                                       ║
║  e₁² = e₂² = e₃² = +1               ║
║  e₁e₂ = -e₂e₁ = e₁₂                 ║
║  e₁e₃ = -e₃e₁ = e₁₃                 ║
║  e₂e₃ = -e₃e₂ = e₂₃                 ║
║                                       ║
║  Grades:                              ║
║  0: scalar (1 dim)    — energy        ║
║  1: vector (3 dim)    — E field       ║
║  2: bivector (3 dim)  — B field       ║
║  3: pseudoscalar (1)  — duality       ║
║                                       ║
║  Total: 2³ = 8 dimensions             ║
║                                       ║
║  KEY: ab = a·b + a∧b                  ║
║  (dot product + wedge product)        ║
╚═══════════════════════════════════════╝
"""
ax1.text(0.02, 0.98, table_text, transform=ax1.transAxes, fontsize=9,
        verticalalignment='top', fontfamily='monospace', color=CYAN,
        bbox=dict(boxstyle='round', facecolor='#111122', edgecolor=CYAN, alpha=0.8))

# Panel 2: E and B as grades of F
ax2 = fig.add_subplot(gs[0, 1])

grades = ['Scalar\n(grade 0)', 'Vector\n(grade 1)\n= E field',
          'Bivector\n(grade 2)\n= IB field', 'Pseudoscalar\n(grade 3)']
dims = [1, 3, 3, 1]
colors = ['#444444', CYAN, MAGENTA, '#444444']
alphas = [0.3, 1.0, 1.0, 0.3]

bars = ax2.bar(range(4), dims, color=colors, edgecolor=WHITE, linewidth=1)
for bar, a in zip(bars, [0.3, 1.0, 1.0, 0.3]):
    bar.set_alpha(a)
ax2.set_xticks(range(4))
ax2.set_xticklabels(grades, fontsize=9)
ax2.set_ylabel('Dimension')
ax2.set_title('Grades of the EM Multivector F\nF = E + IB ∈ Cl(3,0)',
             color=GOLD, fontsize=13)
ax2.grid(True, alpha=0.2, color='#444444', axis='y')

for i, (d, c) in enumerate(zip(dims, colors)):
    ax2.text(i, d + 0.1, str(d), ha='center', va='bottom', color=c,
            fontsize=14, fontweight='bold')

# Panel 3: Rotor rotation of fields
ax3 = fig.add_subplot(gs[0, 2])

# Show how a rotor R = exp(-θ/2 e₁₂) rotates E in the xy plane
angles = np.linspace(0, 2*np.pi, 100)
E_original = np.array([1.0, 0.0])

for i, theta in enumerate(np.linspace(0, np.pi, 8)):
    cos_t = np.cos(theta)
    sin_t = np.sin(theta)
    E_rot = np.array([cos_t * E_original[0] - sin_t * E_original[1],
                       sin_t * E_original[0] + cos_t * E_original[1]])

    alpha = 0.3 + 0.7 * (i / 7)
    color = plt.cm.plasma(i / 7)
    ax3.annotate('', xy=E_rot, xytext=(0, 0),
                arrowprops=dict(arrowstyle='->', color=color, lw=2.5, alpha=alpha))
    if i in [0, 3, 7]:
        ax3.text(E_rot[0]*1.15, E_rot[1]*1.15, f'θ={np.degrees(theta):.0f}°',
                fontsize=8, color=color, ha='center')

# Draw unit circle
circle_theta = np.linspace(0, 2*np.pi, 100)
ax3.plot(np.cos(circle_theta), np.sin(circle_theta), '--', color='#333333',
        linewidth=0.5)

ax3.set_xlim(-1.5, 1.5)
ax3.set_ylim(-1.5, 1.5)
ax3.set_aspect('equal')
ax3.set_title('Rotor Rotation: E\' = RER̃\nR = exp(-θ/2 · e₁₂)',
             color=MAGENTA, fontsize=13)
ax3.grid(True, alpha=0.15, color='#444444')

# Panel 4: The algebraic hierarchy of physics
ax4 = fig.add_subplot(gs[1, 0])
ax4.axis('off')

hierarchy_text = """
╔═══════════════════════════════════════════╗
║  THE ALGEBRAIC HIERARCHY OF PHYSICS       ║
╠═══════════════════════════════════════════╣
║                                           ║
║  ℝ (reals)                                ║
║  └─ DC circuits: V = IR                   ║
║                                           ║
║  ℂ = Cl(0,1) (complex numbers)            ║
║  └─ AC circuits: V = IZ                   ║
║  └─ Phasors, impedance algebra            ║
║                                           ║
║  ℍ = Cl(0,2) (quaternions)                ║
║  └─ 3D rotations of fields                ║
║  └─ Spatial EM symmetries                 ║
║                                           ║
║  Cl(3,0) (Pauli algebra)                  ║
║  └─ F = E + IB (unified field)            ║
║  └─ ∇F = J (all of Maxwell)              ║
║                                           ║
║  Cl(1,3) (spacetime algebra)              ║
║  └─ Relativistic EM                       ║
║  └─ Lorentz force: F = qv·F              ║
║  └─ Stress-energy tensor                  ║
║                                           ║
║  Each level CONTAINS the previous one.    ║
║  Physics gains structure as algebra grows. ║
╚═══════════════════════════════════════════╝
"""
ax4.text(0.02, 0.98, hierarchy_text, transform=ax4.transAxes, fontsize=8.5,
        verticalalignment='top', fontfamily='monospace', color=ORANGE,
        bbox=dict(boxstyle='round', facecolor='#111122', edgecolor=ORANGE, alpha=0.8))

# Panel 5: Energy-momentum from algebra
ax5 = fig.add_subplot(gs[1, 1])

# Visualize energy density ½(E² + B²) over space
x = np.linspace(-3, 3, 200)
y = np.linspace(-3, 3, 200)
X, Y = np.meshgrid(x, y)

# Dipole field
r = np.sqrt(X**2 + Y**2)
r = np.maximum(r, 0.3)
theta_field = np.arctan2(Y, X)
Er = 2 * np.cos(theta_field) / r**3
Et = np.sin(theta_field) / r**3
Ex = Er * np.cos(theta_field) - Et * np.sin(theta_field)
Ey = Er * np.sin(theta_field) + Et * np.cos(theta_field)

energy_density = 0.5 * (Ex**2 + Ey**2)
energy_density = np.minimum(energy_density, 5)  # clip for visualization

im = ax5.pcolormesh(X, Y, energy_density, cmap='inferno', shading='auto')
ax5.streamplot(X, Y, Ex, Ey, color='white', linewidth=0.5, density=1.5,
              arrowsize=1)
ax5.set_title('Energy Density ½F†F\n(Scalar part of geometric product)',
             color=GOLD, fontsize=13)
ax5.set_xlabel('x')
ax5.set_ylabel('y')
ax5.set_aspect('equal')
plt.colorbar(im, ax=ax5, shrink=0.8, label='u = ½(E² + B²)')

# Panel 6: Maxwell in one equation
ax6 = fig.add_subplot(gs[1, 2])
ax6.axis('off')

maxwell_one = """
╔═══════════════════════════════════════════╗
║                                           ║
║   MAXWELL'S EQUATIONS IN ONE LINE         ║
║                                           ║
║   ┌─────────────────────────────┐         ║
║   │                             │         ║
║   │         ∇F = J/ε₀           │         ║
║   │                             │         ║
║   └─────────────────────────────┘         ║
║                                           ║
║   where:                                  ║
║   ∇ = eᵘ∂ᵘ  (vector derivative)          ║
║   F = E + IB  (electromagnetic field)     ║
║   J = ρ + j   (charge-current)            ║
║                                           ║
║   Expanding ∇F:                           ║
║   ∇F = ∇·E + ∇∧E + I(∇·B) + I(∇∧B)     ║
║                                           ║
║   Grade 0: ∇·E = ρ/ε₀     (Gauss)       ║
║   Grade 1: ∇∧E + I∂B/∂t = 0 (Faraday)   ║
║   Grade 2: I∇·B = 0    (no monopoles)    ║
║   Grade 3: I(∇∧B - ∂E/∂t) = J (Ampère)  ║
║                                           ║
║   ALL FOUR MAXWELL EQUATIONS              ║
║   FROM ONE ALGEBRAIC EQUATION!            ║
║                                           ║
║   "God said ∇F = J/ε₀,                   ║
║    and there was light."                  ║
╚═══════════════════════════════════════════╝
"""
ax6.text(0.02, 0.98, maxwell_one, transform=ax6.transAxes, fontsize=9,
        verticalalignment='top', fontfamily='monospace', color=GOLD,
        bbox=dict(boxstyle='round', facecolor='#111122', edgecolor=GOLD, alpha=0.8))

plt.savefig('/workspace/request-project/Electricity/demos/fig5_clifford_em.png',
           dpi=150, bbox_inches='tight', facecolor='#0a0a1a')
plt.close()

print("\n✅ Demo 5: Clifford Algebra EM visualization saved.")
