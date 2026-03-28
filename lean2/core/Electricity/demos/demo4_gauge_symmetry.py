#!/usr/bin/env python3
"""
Demo 4: U(1) Gauge Symmetry and the Circle of Electricity
============================================================

The electromagnetic force is a U(1) gauge theory. This means:
- The "phase" of the wavefunction is unobservable
- Only phase *differences* (= electromagnetic potentials) matter
- The gauge group U(1) ≅ S¹ is the circle group
- Charge conservation follows from Noether's theorem

This demo visualizes gauge transformations, the fiber bundle structure,
and the deep connection between symmetry and conservation.

Part of: The Algebraic Theory of Electricity
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec
from matplotlib.patches import FancyArrowPatch, Circle, Arc
from mpl_toolkits.mplot3d import Axes3D
import matplotlib.colors as mcolors

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
fig.suptitle("U(1) GAUGE SYMMETRY — The Circle of Electricity",
             fontsize=18, color=GOLD, fontweight='bold', y=0.98)
gs = GridSpec(2, 3, figure=fig, hspace=0.35, wspace=0.3)

# ─── Panel 1: U(1) as the circle group ───
ax1 = fig.add_subplot(gs[0, 0])

theta = np.linspace(0, 2 * np.pi, 100)
ax1.plot(np.cos(theta), np.sin(theta), color=GOLD, linewidth=3)

# Mark specific elements
angles = [0, np.pi/3, 2*np.pi/3, np.pi, 4*np.pi/3, 5*np.pi/3]
for a in angles:
    ax1.plot(np.cos(a), np.sin(a), 'o', markersize=8, color=CYAN,
            markeredgecolor=WHITE, markeredgewidth=1.5)

# Show multiplication (group operation)
a1, a2 = np.pi/6, np.pi/4
a3 = a1 + a2
for a, c, label in [(a1, MAGENTA, f'e^{{iα}}'), (a2, CYAN, f'e^{{iβ}}'),
                     (a3, LIME, f'e^{{i(α+β)}}')]:
    ax1.annotate('', xy=(0.8*np.cos(a), 0.8*np.sin(a)), xytext=(0, 0),
                arrowprops=dict(arrowstyle='->', color=c, lw=2))
    ax1.text(1.15*np.cos(a), 1.15*np.sin(a), label, color=c,
            fontsize=10, ha='center', va='center')

ax1.set_xlim(-1.5, 1.5)
ax1.set_ylim(-1.5, 1.5)
ax1.set_aspect('equal')
ax1.set_title('U(1) = {e^{iθ} : θ ∈ [0,2π)}\nThe Circle Group', color=GOLD, fontsize=13)
ax1.text(0, -1.35, 'Group law: e^{iα} · e^{iβ} = e^{i(α+β)}',
        ha='center', fontsize=10, color=WHITE)

# ─── Panel 2: Gauge transformation ───
ax2 = fig.add_subplot(gs[0, 1])

x = np.linspace(-3, 3, 15)
y = np.linspace(-3, 3, 15)
X, Y = np.meshgrid(x, y)

# Original potential
Ax = -Y / (X**2 + Y**2 + 0.5)
Ay = X / (X**2 + Y**2 + 0.5)

# Gauge transformation: A → A + ∇χ, where χ = arctan(y/x)
chi_x = -Y / (X**2 + Y**2 + 0.5)
chi_y = X / (X**2 + Y**2 + 0.5)

# Gauge-transformed potential
Ax_prime = Ax + 0.3 * chi_x
Ay_prime = Ay + 0.3 * chi_y

# Both give the same B = ∇ × A
ax2.quiver(X, Y, Ax, Ay, color=CYAN, alpha=0.7, label='A (gauge 1)', scale=8)
ax2.quiver(X, Y, Ax_prime, Ay_prime, color=MAGENTA, alpha=0.5,
          label="A' = A + dχ (gauge 2)", scale=8)

ax2.set_title("Gauge Freedom\nA and A' = A + dχ give SAME F = dA",
             color=CYAN, fontsize=13)
ax2.legend(loc='lower right', fontsize=9)
ax2.set_aspect('equal')
ax2.set_xlim(-3.5, 3.5)
ax2.set_ylim(-3.5, 3.5)
ax2.text(0, -3.3, 'Physics is gauge-invariant: F = dA = dA\'',
        ha='center', fontsize=9, color=LIME)

# ─── Panel 3: Noether's theorem ───
ax3 = fig.add_subplot(gs[0, 2])
ax3.axis('off')

noether_text = """
╔═══════════════════════════════════════════╗
║  NOETHER'S THEOREM FOR U(1)              ║
╠═══════════════════════════════════════════╣
║                                           ║
║  SYMMETRY        →  CONSERVATION LAW      ║
║  ─────────────      ────────────────      ║
║                                           ║
║  U(1) gauge      →  Charge conservation   ║
║  ψ ↦ e^{iα}ψ       ∂μJμ = 0              ║
║                     ∂ρ/∂t + ∇·J = 0      ║
║                                           ║
║  Time transl.    →  Energy conservation   ║
║  t ↦ t + ε          ∂u/∂t + ∇·S = 0     ║
║                     (Poynting theorem)     ║
║                                           ║
║  Space transl.   →  Momentum conserv.     ║
║  x ↦ x + ε          ∂g/∂t + ∇·T = 0     ║
║                     (Maxwell stress)      ║
║                                           ║
║  Rotation        →  Angular momentum      ║
║  x ↦ Rx             conserved             ║
║                                           ║
║  ALGEBRAICALLY:                           ║
║  Symmetry group G acts on fields.         ║
║  Lie algebra 𝔤 gives conserved currents.  ║
║  For U(1): 𝔲(1) = iℝ → one current Jμ   ║
╚═══════════════════════════════════════════╝
"""
ax3.text(0.02, 0.98, noether_text, transform=ax3.transAxes, fontsize=9,
        verticalalignment='top', fontfamily='monospace', color=LIME,
        bbox=dict(boxstyle='round', facecolor='#111122', edgecolor=LIME, alpha=0.8))

# ─── Panel 4: Fiber bundle visualization ───
ax4 = fig.add_subplot(gs[1, 0], projection='3d')

# Base space: a line (1D spacetime)
t_vals = np.linspace(0, 4*np.pi, 200)

# Fiber: U(1) = circle at each point
for t in np.linspace(0, 4*np.pi, 15):
    phi = np.linspace(0, 2*np.pi, 50)
    ax4.plot(np.cos(phi) * 0.3, np.sin(phi) * 0.3 + t, np.zeros_like(phi),
            color=GOLD, alpha=0.3, linewidth=0.5)

# A section (choice of gauge) = a curve through the bundle
section_phase = 0.5 * np.sin(t_vals)
ax4.plot(0.3 * np.cos(section_phase), t_vals, 0.3 * np.sin(section_phase),
        color=CYAN, linewidth=3, label='Section (gauge choice)')

# Another section (different gauge)
section_phase2 = 0.5 * np.sin(t_vals) + np.pi/3
ax4.plot(0.3 * np.cos(section_phase2), t_vals, 0.3 * np.sin(section_phase2),
        color=MAGENTA, linewidth=3, alpha=0.7, label='Another gauge')

ax4.set_xlabel('Fiber (U(1))')
ax4.set_ylabel('Base (spacetime)')
ax4.set_zlabel('')
ax4.set_title('Principal U(1)-Bundle\nP → M', color=GOLD, fontsize=12)
ax4.legend(loc='upper left', fontsize=8)

# Style 3D
ax4.xaxis.pane.fill = False
ax4.yaxis.pane.fill = False
ax4.zaxis.pane.fill = False
ax4.xaxis.pane.set_edgecolor('#333333')
ax4.yaxis.pane.set_edgecolor('#333333')
ax4.zaxis.pane.set_edgecolor('#333333')

# ─── Panel 5: Phase winding and charge quantization ───
ax5 = fig.add_subplot(gs[1, 1])

theta_range = np.linspace(0, 2*np.pi, 300)

for n in range(-3, 4):
    winding = np.exp(1j * n * theta_range)
    color = plt.cm.coolwarm((n + 3) / 6)
    ax5.plot(theta_range / (2*np.pi), winding.real, color=color,
            linewidth=2 if n != 0 else 3,
            alpha=1.0 if abs(n) <= 2 else 0.5,
            label=f'n = {n:+d}' if abs(n) <= 2 else None)

ax5.set_xlabel('θ / 2π (around loop)')
ax5.set_ylabel('Re(e^{inθ})')
ax5.set_title('Charge Quantization\nfrom π₁(U(1)) = ℤ', color=CYAN, fontsize=13)
ax5.legend(loc='lower left', fontsize=9, ncol=2)
ax5.grid(True, alpha=0.2, color='#444444')
ax5.text(0.5, -0.18, 'Winding number n = charge in units of e\n'
        'Only integers allowed: topology forces quantization!',
        transform=ax5.transAxes, ha='center', fontsize=9, color=ORANGE)

# ─── Panel 6: Three-phase symmetry ───
ax6 = fig.add_subplot(gs[1, 2])

t = np.linspace(0, 2 * 2*np.pi, 500)
omega_power = 2 * np.pi  # normalized

phases = [0, 2*np.pi/3, 4*np.pi/3]
colors_3ph = [RED, LIME, BLUE]
labels = ['Phase A', 'Phase B', 'Phase C']

for phi, c, lab in zip(phases, colors_3ph, labels):
    V = np.sin(t + phi)
    ax6.plot(t / (2*np.pi), V, color=c, linewidth=2, label=lab)

# Show the ℤ/3ℤ symmetry
ax6.axhline(y=0, color='#444444', linewidth=0.5, linestyle='--')

# Sum of three phases = 0 (show this)
V_sum = sum(np.sin(t + phi) for phi in phases)
ax6.plot(t / (2*np.pi), V_sum, color=GOLD, linewidth=3, linestyle=':',
        label='Sum = 0 (ℤ/3ℤ symmetry)')

ax6.set_xlabel('Time (periods)')
ax6.set_ylabel('Voltage')
ax6.set_title('Three-Phase Power\nℤ/3ℤ Symmetry: ω = e^{2πi/3}',
             color=GOLD, fontsize=13)
ax6.legend(loc='upper right', fontsize=9)
ax6.grid(True, alpha=0.2, color='#444444')
ax6.text(0.5, -0.15, 'V_A + V_B + V_C = 0  (algebraic identity)\n'
        '1 + ω + ω² = 0 where ω = e^{2πi/3} (cube root of unity)',
        transform=ax6.transAxes, ha='center', fontsize=9, color=ORANGE)

plt.savefig('/workspace/request-project/Electricity/demos/fig4_gauge_symmetry.png',
           dpi=150, bbox_inches='tight', facecolor='#0a0a1a')
plt.close()

print("✅ Demo 4: Gauge Symmetry visualization saved.")
