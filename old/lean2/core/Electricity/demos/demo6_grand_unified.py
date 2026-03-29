#!/usr/bin/env python3
"""
Demo 6: The Grand Unified Algebraic Map of Electricity
========================================================

This demo creates a comprehensive visual map showing how all the algebraic
structures of electricity connect — from Ohm's law to QED.

Part of: The Algebraic Theory of Electricity
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch
import matplotlib.patheffects as pe

plt.rcParams.update({
    'figure.facecolor': '#050510',
    'axes.facecolor': '#050510',
    'text.color': '#e0e0e0',
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
VIOLET = '#8844FF'

fig, ax = plt.subplots(1, 1, figsize=(24, 18))
ax.set_xlim(0, 24)
ax.set_ylim(0, 18)
ax.axis('off')

# Title
ax.text(12, 17.5, 'THE ALGEBRAIC THEORY OF ELECTRICITY',
        fontsize=24, ha='center', va='center', color=GOLD, fontweight='bold',
        path_effects=[pe.withStroke(linewidth=3, foreground='#333300')])
ax.text(12, 16.8, 'A Complete Map of Algebraic Structures',
        fontsize=14, ha='center', va='center', color=WHITE, style='italic')

# ─── Level 1: Foundation (bottom) ───
def draw_box(ax, x, y, w, h, title, content, border_color, bg_alpha=0.15):
    box = FancyBboxPatch((x-w/2, y-h/2), w, h,
                         boxstyle="round,pad=0.1",
                         facecolor=border_color, alpha=bg_alpha,
                         edgecolor=border_color, linewidth=2)
    ax.add_patch(box)
    ax.text(x, y + h/2 - 0.25, title, fontsize=10, ha='center', va='top',
           color=border_color, fontweight='bold')
    ax.text(x, y - 0.1, content, fontsize=7.5, ha='center', va='center',
           color=WHITE, linespacing=1.4)

def draw_arrow(ax, x1, y1, x2, y2, color, label='', style='->', lw=1.5):
    ax.annotate('', xy=(x2, y2), xytext=(x1, y1),
               arrowprops=dict(arrowstyle=style, color=color, lw=lw,
                              connectionstyle='arc3,rad=0.1'))
    if label:
        mx, my = (x1+x2)/2, (y1+y2)/2
        ax.text(mx + 0.1, my + 0.1, label, fontsize=7, color=color,
               ha='center', style='italic')

# ─── Row 1: DC Circuits ───
draw_box(ax, 3, 2, 4.5, 2.5, '⚡ OHM\'S LAW',
         'V = IR\nAlgebra: ℝ (real numbers)\nGroup: (ℝ, +) additive\nField: (ℝ, +, ×)',
         GOLD)

draw_box(ax, 9, 2, 4.5, 2.5, '🔗 KIRCHHOFF\'S LAWS',
         'KCL: Σ Iₖ = 0 (cycles)\nKVL: Σ Vₖ = 0 (cocycles)\nAlgebra: Chain complex\nC₁ →∂₁ C₀',
         CYAN)

draw_box(ax, 15, 2, 4.5, 2.5, '📊 GRAPH LAPLACIAN',
         'L = ∂₁∂₁ᵀ = D - A\nSpectrum: eigenvalues λₖ\nβ₁ = m - n + 1\nTopology of circuit',
         LIME)

draw_box(ax, 21, 2, 4.5, 2.5, '🔄 THÉVENIN-NORTON',
         'V_th, Z_th ↔ I_N, Z_N\nDuality involution\nτ: series ↔ parallel\nτ² = id',
         ORANGE)

# ─── Row 2: AC Circuits ───
draw_box(ax, 3, 6, 4.5, 2.5, '🌀 PHASORS & IMPEDANCE',
         'Z = R + jX ∈ ℂ\nSeries: Z₁ + Z₂\nParallel: Z₁‖Z₂\nField: (ℂ, +, ×)',
         MAGENTA)

draw_box(ax, 9, 6, 4.5, 2.5, '🔺 THREE-PHASE POWER',
         'ℤ/3ℤ symmetry\nω = e^{2πi/3}\n1 + ω + ω² = 0\nBalanced: V_A+V_B+V_C=0',
         BLUE)

draw_box(ax, 15, 6, 4.5, 2.5, '📡 TRANSFER FUNCTIONS',
         'H(s) = P(s)/Q(s) ∈ ℂ(s)\nRational functions\nField of fractions\nPoles & zeros',
         VIOLET)

draw_box(ax, 21, 6, 4.5, 2.5, '⚙️ SIGNAL FLOW',
         'Mason\'s gain formula\nSemiring of paths\nTransfer matrix algebra\nSL(2,ℂ) for 2-ports',
         RED)

# ─── Row 3: Classical EM ───
draw_box(ax, 3, 10, 4.5, 2.5, '🌊 MAXWELL (FORMS)',
         'dF = 0 (Bianchi)\nd★F = J (dynamics)\nF ∈ Ω²(M)\nde Rham complex',
         CYAN)

draw_box(ax, 9, 10, 4.5, 2.5, '🔐 U(1) GAUGE THEORY',
         'A ↦ A + dχ\nF = dA (curvature)\nNoether: charge conserv.\nπ₁(U(1)) = ℤ → quantization',
         GOLD)

draw_box(ax, 15, 10, 4.5, 2.5, '🧮 CLIFFORD ALGEBRA',
         'F = E + IB ∈ Cl(1,3)\n∇F = J/ε₀ (Maxwell)\nRotors: F\' = RFR̃\n½F†F = energy',
         MAGENTA)

draw_box(ax, 21, 10, 4.5, 2.5, '★ HODGE THEORY',
         '★: Ωᵖ → Ω^{n-p}\nConstitutive relations\nHodge decomposition\nΔ = dδ + δd',
         LIME)

# ─── Row 4: Quantum EM ───
draw_box(ax, 6, 14, 4.5, 2.5, '⚛️ FOCK SPACE (QED)',
         'F(H) = ⊕ₙ Sⁿ(H)\na†, a operators\n[a, a†] = 1 (CCR)\nSymmetric algebra',
         GOLD)

draw_box(ax, 12, 14, 4.5, 2.5, '🌌 REPRESENTATION THEORY',
         'U(1) representations\nCharges = irreps\nα ≈ 1/137 (coupling)\nPerturbative expansion',
         CYAN)

draw_box(ax, 18, 14, 4.5, 2.5, '🔮 CATEGORY THEORY',
         'Circuits → Chain complexes\nFunctor: Graph → Vect\nNatural transformations\nTQFT connections',
         VIOLET)

# ─── Arrows (connections) ───
# Level 1 → Level 2
draw_arrow(ax, 3, 3.25, 3, 4.75, GOLD, 'ℝ ↪ ℂ')
draw_arrow(ax, 9, 3.25, 9, 4.75, CYAN, 'complex')
draw_arrow(ax, 15, 3.25, 15, 4.75, LIME, 'spectral')
draw_arrow(ax, 21, 3.25, 21, 4.75, ORANGE, 'n-port')

# Level 2 → Level 3
draw_arrow(ax, 3, 7.25, 3, 8.75, MAGENTA, 'ℂ ↪ Ω*')
draw_arrow(ax, 9, 7.25, 9, 8.75, BLUE, 'gauge')
draw_arrow(ax, 15, 7.25, 15, 8.75, VIOLET, 'Cl(1,3)')
draw_arrow(ax, 21, 7.25, 21, 8.75, RED, 'metric')

# Level 3 → Level 4
draw_arrow(ax, 5, 11.25, 6, 12.75, CYAN, 'quantize')
draw_arrow(ax, 10, 11.25, 10, 12.75, GOLD, 'rep theory')
draw_arrow(ax, 17, 11.25, 18, 12.75, MAGENTA, 'categorify')

# Cross-connections
draw_arrow(ax, 5.5, 2, 7, 2, '#555555', '', '->')
draw_arrow(ax, 11.5, 2, 13, 2, '#555555', '', '->')
draw_arrow(ax, 17.5, 2, 19, 2, '#555555', '', '->')

draw_arrow(ax, 5.5, 6, 7, 6, '#555555', '', '->')
draw_arrow(ax, 11.5, 6, 13, 6, '#555555', '', '->')
draw_arrow(ax, 17.5, 6, 19, 6, '#555555', '', '->')

draw_arrow(ax, 5.5, 10, 7, 10, '#555555', '', '->')
draw_arrow(ax, 11.5, 10, 13, 10, '#555555', '', '->')
draw_arrow(ax, 17.5, 10, 19, 10, '#555555', '', '->')

draw_arrow(ax, 8.5, 14, 10, 14, '#555555', '', '->')
draw_arrow(ax, 14.5, 14, 16, 14, '#555555', '', '->')

# ─── Layer labels ───
for y, label, color in [(2, 'DC CIRCUITS\n(ℝ-algebra)', GOLD),
                         (6, 'AC CIRCUITS\n(ℂ-algebra)', MAGENTA),
                         (10, 'CLASSICAL EM\n(Diff. Geometry)', CYAN),
                         (14, 'QUANTUM EM\n(Operator Algebra)', GOLD)]:
    ax.text(0.3, y, label, fontsize=8, ha='center', va='center',
           color=color, rotation=90, fontweight='bold', alpha=0.7)

# Footer
ax.text(12, 0.3, '"Electricity is algebra made manifest. Every wire is a morphism, '
       'every circuit a diagram, every field a representation."',
       fontsize=11, ha='center', va='center', color=WHITE, style='italic',
       alpha=0.7)

plt.savefig('/workspace/request-project/Electricity/demos/fig6_grand_unified_map.png',
           dpi=150, bbox_inches='tight', facecolor='#050510')
plt.close()

print("✅ Demo 6: Grand Unified Algebraic Map saved.")
