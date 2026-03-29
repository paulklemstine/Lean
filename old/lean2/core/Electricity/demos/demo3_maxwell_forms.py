#!/usr/bin/env python3
"""
Demo 3: Maxwell's Equations as Differential Forms
===================================================

Maxwell's four equations reduce to TWO algebraic identities:
  dF = 0      (Bianchi identity, automatic from F = dA)
  d★F = J     (dynamical equation)

This demo visualizes the electromagnetic field as a 2-form,
the Hodge star operation, and the algebraic structure of Maxwell's equations.

Part of: The Algebraic Theory of Electricity
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec
from mpl_toolkits.mplot3d import Axes3D
from matplotlib.colors import Normalize
from matplotlib import cm

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

fig = plt.figure(figsize=(22, 16))
fig.suptitle("MAXWELL'S EQUATIONS AS DIFFERENTIAL FORMS",
             fontsize=18, color=GOLD, fontweight='bold', y=0.98)
gs = GridSpec(2, 3, figure=fig, hspace=0.35, wspace=0.3)

# ─── Panel 1: Electric field of a point charge (1-form → vector field) ───
ax1 = fig.add_subplot(gs[0, 0])

x = np.linspace(-2, 2, 20)
y = np.linspace(-2, 2, 20)
X, Y = np.meshgrid(x, y)

# Point charge at origin
r = np.sqrt(X**2 + Y**2)
r = np.maximum(r, 0.3)  # avoid singularity
Ex = X / r**3
Ey = Y / r**3
E_mag = np.sqrt(Ex**2 + Ey**2)

ax1.streamplot(X, Y, Ex, Ey, color=E_mag, cmap='inferno', linewidth=1.5,
              density=1.5, arrowsize=1.5)
ax1.plot(0, 0, 'o', markersize=12, color=RED, markeredgecolor=WHITE,
        markeredgewidth=2, zorder=5)
ax1.set_title('Electric Field E\n(from potential 1-form A₀)',
             color=CYAN, fontsize=13)
ax1.set_xlabel('x')
ax1.set_ylabel('y')
ax1.set_aspect('equal')
ax1.text(0.05, 0.05, 'E = -dφ = -∇φ', transform=ax1.transAxes,
        fontsize=10, color=CYAN)

# ─── Panel 2: Magnetic field (2-form = area element) ───
ax2 = fig.add_subplot(gs[0, 1])

# Current-carrying wire along z-axis
Bx = -Y / r**2
By = X / r**2
B_mag = np.sqrt(Bx**2 + By**2)

ax2.streamplot(X, Y, Bx, By, color=B_mag, cmap='cool', linewidth=1.5,
              density=1.5, arrowsize=1.5)
ax2.plot(0, 0, 's', markersize=10, color=GOLD, markeredgecolor=WHITE,
        markeredgewidth=2, zorder=5)
ax2.set_title('Magnetic Field B\n(2-form F = dA)', color=MAGENTA, fontsize=13)
ax2.set_xlabel('x')
ax2.set_ylabel('y')
ax2.set_aspect('equal')
ax2.text(0.05, 0.05, 'B = ∇ × A  (curl of potential)', transform=ax2.transAxes,
        fontsize=10, color=MAGENTA)

# ─── Panel 3: The Faraday 2-form F ───
ax3 = fig.add_subplot(gs[0, 2])
ax3.axis('off')

form_text = """
╔═══════════════════════════════════════════╗
║    THE FARADAY 2-FORM F                   ║
╠═══════════════════════════════════════════╣
║                                           ║
║  In components (Minkowski spacetime):     ║
║                                           ║
║  F = E₁ dt∧dx + E₂ dt∧dy + E₃ dt∧dz     ║
║    + B₁ dy∧dz + B₂ dz∧dx + B₃ dx∧dy     ║
║                                           ║
║  As a matrix (antisymmetric):             ║
║                                           ║
║       ┌  0   E₁  E₂  E₃ ┐               ║
║  Fμν = │-E₁   0   B₃ -B₂│               ║
║       │-E₂ -B₃   0   B₁│               ║
║       └-E₃  B₂ -B₁   0 ┘               ║
║                                           ║
║  F ∈ Ω²(M) = ∧²T*M                      ║
║  (antisymmetric bilinear form on          ║
║   tangent vectors)                        ║
║                                           ║
║  F = dA  where A ∈ Ω¹(M) is the         ║
║  electromagnetic potential                ║
╚═══════════════════════════════════════════╝
"""
ax3.text(0.02, 0.98, form_text, transform=ax3.transAxes, fontsize=9,
        verticalalignment='top', fontfamily='monospace', color=GOLD,
        bbox=dict(boxstyle='round', facecolor='#111122', edgecolor=GOLD, alpha=0.8))

# ─── Panel 4: Maxwell's equations — traditional vs forms ───
ax4 = fig.add_subplot(gs[1, 0])
ax4.axis('off')

maxwell_text = """
╔═══════════════════════════════════════════╗
║   MAXWELL: FOUR → TWO EQUATIONS          ║
╠═══════════════════════════════════════════╣
║                                           ║
║  TRADITIONAL (vector calculus):           ║
║  ① ∇·E = ρ/ε₀      (Gauss)             ║
║  ② ∇·B = 0          (no monopoles)       ║
║  ③ ∇×E = -∂B/∂t     (Faraday)           ║
║  ④ ∇×B = μ₀J + μ₀ε₀∂E/∂t  (Ampère)     ║
║                                           ║
║  ALGEBRAIC (differential forms):          ║
║                                           ║
║    ┌───────────────────────────┐          ║
║    │  dF = 0        ②③        │          ║
║    │  d★F = J       ①④        │          ║
║    └───────────────────────────┘          ║
║                                           ║
║  dF = 0 is AUTOMATIC since F = dA        ║
║  and d² = 0 (algebraic identity!)        ║
║                                           ║
║  So really there is ONE equation:         ║
║                                           ║
║    ┌───────────────────────────┐          ║
║    │       d★dA = J            │          ║
║    └───────────────────────────┘          ║
╚═══════════════════════════════════════════╝
"""
ax4.text(0.02, 0.98, maxwell_text, transform=ax4.transAxes, fontsize=9,
        verticalalignment='top', fontfamily='monospace', color=LIME,
        bbox=dict(boxstyle='round', facecolor='#111122', edgecolor=LIME, alpha=0.8))

# ─── Panel 5: Electromagnetic wave — algebra in action ───
ax5 = fig.add_subplot(gs[1, 1])

z = np.linspace(0, 4 * np.pi, 500)
t = 0  # snapshot

E_wave = np.sin(z - t)
B_wave = np.sin(z - t)

ax5.plot(z, E_wave, color=CYAN, linewidth=2.5, label='E (electric)')
ax5.plot(z, B_wave, color=MAGENTA, linewidth=2.5, linestyle='--', label='B (magnetic)')
ax5.fill_between(z, E_wave, alpha=0.1, color=CYAN)
ax5.fill_between(z, B_wave, alpha=0.1, color=MAGENTA)

ax5.axhline(y=0, color='#444444', linewidth=0.5)
ax5.set_xlabel('z (propagation direction)')
ax5.set_ylabel('Field amplitude')
ax5.set_title('EM Wave: F = E dt∧dz + B dx∧dy\nSelf-dual solution: ★F = ±iF',
             color=GOLD, fontsize=12)
ax5.legend(loc='upper right', fontsize=10)
ax5.grid(True, alpha=0.2, color='#444444')

# Add algebraic annotation
ax5.text(0.02, 0.15, 'Wave equation from:\nd★dA = 0 (vacuum)\n⟹ □A = 0 (d\'Alembertian)',
        transform=ax5.transAxes, fontsize=9, color=ORANGE,
        bbox=dict(boxstyle='round', facecolor='#111122', edgecolor=ORANGE, alpha=0.8))

# ─── Panel 6: The de Rham complex and Hodge star ───
ax6 = fig.add_subplot(gs[1, 2])
ax6.axis('off')

derham_text = """
╔═══════════════════════════════════════════╗
║  THE de RHAM COMPLEX & HODGE STAR         ║
╠═══════════════════════════════════════════╣
║                                           ║
║  On 4D spacetime M:                       ║
║                                           ║
║   d     d      d      d                  ║
║  Ω⁰ → Ω¹ → Ω² → Ω³ → Ω⁴               ║
║   φ    A     F    ★F    ★J               ║
║  scalar pot.  field  dual  charge        ║
║                                           ║
║  HODGE STAR ★: Ωᵖ → Ω⁴⁻ᵖ               ║
║  Encodes the metric (constitutive rels)  ║
║                                           ║
║  ★★ = (-1)^{p(n-p)+s}                    ║
║  In Minkowski: ★★|_{Ω²} = -1             ║
║  ⟹ ★ has eigenvalues ±i on Ω²            ║
║  ⟹ Self-dual / anti-self-dual split      ║
║                                           ║
║  GAUGE SYMMETRY:                          ║
║  A ↦ A + dχ  (χ ∈ Ω⁰)                   ║
║  F = dA is invariant (d² = 0)            ║
║  Physics lives in H¹(M) = ker d / im d   ║
║                                           ║
║  TOPOLOGY:                                ║
║  ∫_S F = 2πn (n ∈ ℤ)                     ║
║  Charge quantization from π₁(U(1)) = ℤ   ║
╚═══════════════════════════════════════════╝
"""
ax6.text(0.02, 0.98, derham_text, transform=ax6.transAxes, fontsize=8.5,
        verticalalignment='top', fontfamily='monospace', color=CYAN,
        bbox=dict(boxstyle='round', facecolor='#111122', edgecolor=CYAN, alpha=0.8))

plt.savefig('/workspace/request-project/Electricity/demos/fig3_maxwell_forms.png',
           dpi=150, bbox_inches='tight', facecolor='#0a0a1a')
plt.close()

print("✅ Demo 3: Maxwell-Forms visualization saved.")
