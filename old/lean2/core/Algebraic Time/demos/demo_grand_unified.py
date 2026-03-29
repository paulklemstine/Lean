#!/usr/bin/env python3
"""
Algebraic Theory of Time — Demo 6: The Grand Unified View
===========================================================

A comprehensive visualization combining all aspects of the theory:
  1. The algebraic hierarchy of time
  2. The group↔monoid phase diagram
  3. Noether's theorem: group ↔ conservation
  4. The "landscape" of temporal algebras across physics

Run: python3 demo_grand_unified.py
Output: grand_unified.png
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec
import matplotlib.patches as mpatches
from matplotlib.colors import LinearSegmentedColormap

# ============================================================
# 1. Create the figure
# ============================================================

fig = plt.figure(figsize=(18, 20))
gs = GridSpec(4, 3, figure=fig, hspace=0.35, wspace=0.3,
             height_ratios=[1, 1, 1, 0.8])
fig.suptitle('THE ALGEBRAIC THEORY OF TIME\nA Grand Unified View',
             fontsize=20, fontweight='bold', y=0.98,
             color='#1a1a2e')

# ============================================================
# 2. Panel 1: The Algebraic Hierarchy (large)
# ============================================================

ax1 = fig.add_subplot(gs[0, :2])
ax1.set_xlim(0, 12)
ax1.set_ylim(0, 10)
ax1.axis('off')
ax1.set_title('The Algebraic Hierarchy of Time',
              fontsize=14, fontweight='bold', pad=20)

# Hierarchy levels
levels = [
    (6, 1.2, 'CAUSAL POSET\n(T, ≤)', '#fff3e0',
     'Discrete events with\ncausal ordering only'),
    (6, 3.2, 'TEMPORAL MONOID\n(T, +, 0, ≤)', '#ffe0b2',
     'Duration composition,\nforward-only (irreversible)'),
    (6, 5.2, 'TEMPORAL GROUP\n(T, +, 0, −, ≤)', '#ffb74d',
     'Full time-reversal\nsymmetry (reversible)'),
    (6, 7.2, 'TEMPORAL FIBER BUNDLE\n{𝒯_o}_{o∈O}', '#ff9800',
     'Observer-dependent\ntemporal algebras'),
    (6, 9.0, 'TEMPORAL ALGEBRA\n𝒯 = (T, S, Φ, η)', '#e65100',
     'Full structure with\nstate space & entropy'),
]

for x, y, label, color, desc in levels:
    box = mpatches.FancyBboxPatch((x - 2.5, y - 0.55), 5.0, 1.1,
                                   boxstyle="round,pad=0.15",
                                   facecolor=color, edgecolor='#333',
                                   linewidth=2, alpha=0.9)
    ax1.add_patch(box)
    ax1.text(x, y, label, ha='center', va='center',
             fontsize=10, fontweight='bold', family='monospace')
    ax1.text(x + 3.8, y, desc, ha='left', va='center',
             fontsize=9, style='italic', color='#555')

# Arrows
for i in range(4):
    y_start = levels[i][1] + 0.55
    y_end = levels[i+1][1] - 0.55
    ax1.annotate('', xy=(6, y_end), xytext=(6, y_start),
                 arrowprops=dict(arrowstyle='->', color='#333',
                                lw=2.5))

# Physical theories annotations (left side)
theories = [
    (1.0, 1.2, 'Causal Set\nTheory', '#795548'),
    (1.0, 3.2, 'Thermodynamics\nMarkov Processes', '#d32f2f'),
    (1.0, 5.2, 'Classical/Quantum\nMechanics', '#1976d2'),
    (1.0, 7.2, 'Special/General\nRelativity', '#7b1fa2'),
    (1.0, 9.0, 'Complete\nPhysical Theory', '#333'),
]
for x, y, label, color in theories:
    ax1.text(x, y, label, ha='center', va='center',
             fontsize=9, color=color, fontweight='bold',
             bbox=dict(boxstyle='round', facecolor='white',
                      edgecolor=color, alpha=0.8))
    ax1.annotate('', xy=(3.5, y), xytext=(2.2, y),
                 arrowprops=dict(arrowstyle='->', color=color, lw=1.5))

# ============================================================
# 3. Panel 2: Physical theories landscape
# ============================================================

ax2 = fig.add_subplot(gs[0, 2])
ax2.axis('off')
ax2.set_title('Physical Theories Map',
              fontsize=13, fontweight='bold')

theories_map = [
    ('Classical Mech', 'Group', '✗', '#1976d2'),
    ('Electrodynamics', 'Group', '✗', '#1976d2'),
    ('Quantum Mech', 'Group', '✗', '#1976d2'),
    ('QFT', 'Group', '✗', '#1976d2'),
    ('', '', '', 'white'),
    ('Thermodynamics', 'Monoid', '✓', '#d32f2f'),
    ('Statistical Mech', 'Monoid', '✓', '#d32f2f'),
    ('Open Quantum', 'Monoid', '✓', '#d32f2f'),
    ('', '', '', 'white'),
    ('Special Rel.', 'Fiber', '✗', '#7b1fa2'),
    ('General Rel.', 'Fiber', 'Local', '#7b1fa2'),
    ('', '', '', 'white'),
    ('Causal Sets', 'Poset', '✓', '#795548'),
]

y_pos = 0.95
for name, struct, arrow, color in theories_map:
    if name == '':
        y_pos -= 0.02
        continue
    ax2.text(0.05, y_pos, f'• {name}', transform=ax2.transAxes,
             fontsize=9, color=color, fontweight='bold')
    ax2.text(0.55, y_pos, struct, transform=ax2.transAxes,
             fontsize=9, color=color, family='monospace')
    arrow_color = '#d32f2f' if arrow == '✓' else '#1976d2'
    ax2.text(0.85, y_pos, arrow, transform=ax2.transAxes,
             fontsize=10, color=arrow_color, fontweight='bold')
    y_pos -= 0.065

# Header
ax2.text(0.05, 1.0, 'Theory', transform=ax2.transAxes,
         fontsize=10, fontweight='bold', color='gray')
ax2.text(0.55, 1.0, 'Time', transform=ax2.transAxes,
         fontsize=10, fontweight='bold', color='gray')
ax2.text(0.82, 1.0, 'Arrow?', transform=ax2.transAxes,
         fontsize=10, fontweight='bold', color='gray')

# ============================================================
# 4. Panel 3: Noether's theorem visualization
# ============================================================

ax3 = fig.add_subplot(gs[1, 0])

# Energy conservation in a Hamiltonian system
times = np.linspace(0, 20, 500)
omega = 1.0

# Hamiltonian (group → energy conserved)
KE = 0.5 * np.sin(omega * times)**2
PE = 0.5 * np.cos(omega * times)**2
E_total = KE + PE

ax3.fill_between(times, 0, KE, alpha=0.4, color='#42a5f5', label='Kinetic Energy')
ax3.fill_between(times, KE, KE + PE, alpha=0.4, color='#ef5350', label='Potential Energy')
ax3.plot(times, E_total, 'k-', linewidth=2.5, label='Total Energy (conserved)')
ax3.set_xlabel('Time', fontsize=11)
ax3.set_ylabel('Energy', fontsize=11)
ax3.set_title("Noether's Theorem\nGroup symmetry → Conservation",
              fontsize=12, fontweight='bold')
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.2)
ax3.set_ylim(0, 0.7)

ax3.text(0.5, 0.88, 'T = (ℝ, +) is a GROUP\n⟹ Energy is CONSERVED',
         transform=ax3.transAxes, fontsize=9, ha='center',
         family='monospace',
         bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.9))

# ============================================================
# 5. Panel 4: Energy dissipation in monoid system
# ============================================================

ax4 = fig.add_subplot(gs[1, 1])

gamma_diss = 0.15
KE_diss = 0.5 * np.exp(-2*gamma_diss*times) * np.sin(omega * times)**2
PE_diss = 0.5 * np.exp(-2*gamma_diss*times) * np.cos(omega * times)**2
E_diss = 0.5 * np.exp(-2*gamma_diss*times)
heat = 0.5 * (1 - np.exp(-2*gamma_diss*times))

ax4.fill_between(times, 0, KE_diss, alpha=0.4, color='#42a5f5', label='Kinetic Energy')
ax4.fill_between(times, KE_diss, KE_diss + PE_diss, alpha=0.4, color='#ef5350', label='Potential Energy')
ax4.fill_between(times, KE_diss + PE_diss, KE_diss + PE_diss + heat,
                 alpha=0.3, color='#ff9800', label='Heat (dissipated)')
ax4.plot(times, E_diss, 'k--', linewidth=2, label='Mechanical Energy (decreasing)')
ax4.plot(times, E_diss + heat, 'k-', linewidth=2.5, label='Total (1st law)')

ax4.set_xlabel('Time', fontsize=11)
ax4.set_ylabel('Energy', fontsize=11)
ax4.set_title('No Noether: Monoid → Dissipation',
              fontsize=12, fontweight='bold')
ax4.legend(fontsize=8, loc='center right')
ax4.grid(True, alpha=0.2)
ax4.set_ylim(0, 0.7)

ax4.text(0.5, 0.88, 'T = (ℝ≥0, +) is a MONOID\n⟹ Energy is NOT conserved',
         transform=ax4.transAxes, fontsize=9, ha='center',
         family='monospace',
         bbox=dict(boxstyle='round', facecolor='#fff3e0', alpha=0.9))

# ============================================================
# 6. Panel 5: The group-monoid phase diagram
# ============================================================

ax5 = fig.add_subplot(gs[1, 2])

# Create a "phase diagram" with dissipation rate on x-axis
# and coupling strength on y-axis
gamma_range = np.linspace(0, 2, 100)
coupling_range = np.linspace(0, 2, 100)
G, C = np.meshgrid(gamma_range, coupling_range)

# "Phase": group when γ=0, monoid when γ>0
# The transition happens at γ=0
Z = np.tanh(5 * G)  # 0 = group region, 1 = monoid region

cmap = LinearSegmentedColormap.from_list('gm', ['#1976d2', '#ffffff', '#d32f2f'])
im = ax5.pcolormesh(G, C, Z, cmap=cmap, shading='auto')
ax5.axvline(x=0, color='black', linewidth=3)

ax5.text(0.05, 1.5, 'GROUP\nRegion\n(reversible)', fontsize=11,
         fontweight='bold', color='#1976d2')
ax5.text(1.2, 1.5, 'MONOID\nRegion\n(irreversible)', fontsize=11,
         fontweight='bold', color='#d32f2f')

ax5.set_xlabel('Dissipation rate γ', fontsize=11)
ax5.set_ylabel('Coupling strength', fontsize=11)
ax5.set_title('Group↔Monoid Phase Diagram\n(γ = 0 is the critical point)',
              fontsize=12, fontweight='bold')

# Mark physical theories
theories_pts = [
    (0, 0.5, 'Newton', '#1976d2'),
    (0, 1.0, 'QM', '#1976d2'),
    (0, 1.5, 'EM', '#1976d2'),
    (0.5, 0.8, 'Friction', '#d32f2f'),
    (1.0, 1.2, 'Heat\nflow', '#d32f2f'),
    (1.5, 0.5, 'Viscous\nfluid', '#d32f2f'),
]
for x, y, name, color in theories_pts:
    ax5.plot(x, y, 'o', color=color, markersize=8, markeredgecolor='black')
    ax5.annotate(name, xy=(x, y), xytext=(x + 0.08, y + 0.08),
                 fontsize=8, color=color, fontweight='bold')

# ============================================================
# 7. Panel 6: Temporal algebra composition diagram
# ============================================================

ax6 = fig.add_subplot(gs[2, 0])
ax6.axis('off')
ax6.set_title('Temporal Algebra Components',
              fontsize=13, fontweight='bold')

# Draw the components of a temporal algebra
components = [
    (0.5, 0.85, 'T', 'Temporal\nMonoid', '#ff9800', 'Time durations\n(T, +, 0, ≤)'),
    (0.15, 0.5, 'S', 'State\nSpace', '#4caf50', 'Physical states\n(phase space, Hilbert space)'),
    (0.5, 0.5, 'Φ', 'Temporal\nFlow', '#9c27b0', 'Dynamics\nΦ: T → End(S)'),
    (0.85, 0.5, 'η', 'Entropy\nFunctional', '#f44336', 'Irreversibility\nη: S → ℝ'),
    (0.5, 0.15, '𝒯', 'Temporal\nAlgebra', '#1a1a2e', 'Full structure\n(T, S, Φ, η)'),
]

for x, y, symbol, name, color, desc in components:
    circle = plt.Circle((x, y), 0.1, transform=ax6.transAxes,
                        facecolor=color, edgecolor='black',
                        linewidth=2, alpha=0.8, clip_on=False)
    ax6.add_patch(circle)
    ax6.text(x, y, symbol, transform=ax6.transAxes,
             fontsize=16, fontweight='bold', color='white',
             ha='center', va='center')
    ax6.text(x, y - 0.14, name, transform=ax6.transAxes,
             fontsize=7, ha='center', va='top', color=color,
             fontweight='bold')

# Arrows
for (x1, y1), (x2, y2) in [
    ((0.5, 0.75), (0.5, 0.6)),
    ((0.25, 0.5), (0.4, 0.5)),
    ((0.6, 0.5), (0.75, 0.5)),
    ((0.5, 0.4), (0.5, 0.25)),
    ((0.25, 0.45), (0.45, 0.2)),
    ((0.75, 0.45), (0.55, 0.2)),
]:
    ax6.annotate('', xy=(x2, y2), xytext=(x1, y1),
                 xycoords='axes fraction', textcoords='axes fraction',
                 arrowprops=dict(arrowstyle='->', color='gray', lw=1.5))

# ============================================================
# 8. Panel 7: The fundamental equation
# ============================================================

ax7 = fig.add_subplot(gs[2, 1])
ax7.axis('off')
ax7.set_title('The Core Theorems',
              fontsize=13, fontweight='bold')

theorems = (
    "═══════════════════════════════════\n"
    "    ARROW OF TIME THEOREM\n"
    "═══════════════════════════════════\n\n"
    "  η(Φ(t)(s)) > η(s) for t > 0\n"
    "  ⟹ T is a MONOID (not a group)\n\n"
    "  \"Entropy increase ⟹ no going back\"\n\n"
    "═══════════════════════════════════\n"
    "    NOETHER'S THEOREM (algebraic)\n"
    "═══════════════════════════════════\n\n"
    "  T is a GROUP + symplectic\n"
    "  ⟹ ∃ conserved quantity (energy)\n\n"
    "  \"Time-reversal ⟹ conservation\"\n\n"
    "═══════════════════════════════════\n"
    "    FLOW DECOMPOSITION\n"
    "═══════════════════════════════════\n\n"
    "  V = V_rev ⊕ V_irr\n"
    "  Every flow = GROUP part + MONOID part"
)
ax7.text(0.5, 0.5, theorems, transform=ax7.transAxes,
         fontsize=8.5, ha='center', va='center', family='monospace',
         bbox=dict(boxstyle='round', facecolor='#f5f5f5',
                  edgecolor='#333', alpha=0.95))

# ============================================================
# 9. Panel 8: The one-line summary
# ============================================================

ax8 = fig.add_subplot(gs[2, 2])
ax8.axis('off')
ax8.set_title('The One-Line Summary',
              fontsize=13, fontweight='bold')

ax8.text(0.5, 0.65,
         'THE ARROW\nOF TIME',
         transform=ax8.transAxes, fontsize=24,
         ha='center', va='center', fontweight='bold',
         color='#d32f2f')

ax8.text(0.5, 0.40,
         '=',
         transform=ax8.transAxes, fontsize=30,
         ha='center', va='center', fontweight='bold')

ax8.text(0.5, 0.20,
         'MONOID ≠ GROUP',
         transform=ax8.transAxes, fontsize=20,
         ha='center', va='center', fontweight='bold',
         color='#1976d2', family='monospace')

ax8.text(0.5, 0.05,
         '(the gap between\nirreversibility and reversibility)',
         transform=ax8.transAxes, fontsize=10,
         ha='center', va='center', color='gray', style='italic')

# ============================================================
# 10. Bottom banner
# ============================================================

ax_banner = fig.add_subplot(gs[3, :])
ax_banner.axis('off')

banner_text = (
    "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
    "\n"
    "  Time is not a river.  Time is not a dimension.  Time is not a parameter.\n"
    "\n"
    "  ╔═══════════════════════════════════════════════════╗\n"
    "  ║                                                   ║\n"
    "  ║           T I M E   I S   A N   A L G E B R A     ║\n"
    "  ║                                                   ║\n"
    "  ╚═══════════════════════════════════════════════════╝\n"
    "\n"
    "  And its algebraic structure — monoid, group, or fiber bundle — determines the physics.\n"
    "\n"
    "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
)

ax_banner.text(0.5, 0.5, banner_text, transform=ax_banner.transAxes,
               fontsize=11, ha='center', va='center', family='monospace',
               color='#1a1a2e',
               bbox=dict(boxstyle='round', facecolor='#fff8e1',
                        edgecolor='#ff9800', linewidth=3, alpha=0.95))

plt.savefig('/workspace/request-project/AlgebraicTime/demos/grand_unified.png',
            dpi=150, bbox_inches='tight')
plt.close()
print("✓ Saved: grand_unified.png")
