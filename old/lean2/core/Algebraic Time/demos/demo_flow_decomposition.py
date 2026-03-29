#!/usr/bin/env python3
"""
Algebraic Theory of Time — Demo 3: Flow Decomposition Theorem
==============================================================

Every linear temporal flow decomposes into:
  - REVERSIBLE component (oscillatory, eigenvalues on imaginary axis)
  - IRREVERSIBLE component (decaying/growing, eigenvalues off imaginary axis)

This is the algebraic decomposition of dynamics into GROUP and MONOID parts.

Run: python3 demo_flow_decomposition.py
Output: flow_decomposition.png
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec
from scipy.linalg import expm

# ============================================================
# 1. Define a 4D system with mixed reversible/irreversible dynamics
# ============================================================

# System matrix A has eigenvalues:
#   ±iω (purely imaginary → reversible, oscillatory)
#   -γ ± iω' (negative real part → irreversible, decaying)

omega_rev = 1.0    # frequency of reversible component
omega_irr = 0.7    # frequency of irreversible component
gamma = 0.4        # decay rate of irreversible component

# Build A in block form
A_rev = np.array([[0, omega_rev],
                  [-omega_rev, 0]])  # eigenvalues ±iω

A_irr = np.array([[-gamma, omega_irr],
                  [-omega_irr, -gamma]])  # eigenvalues -γ ± iω'

A_full = np.block([[A_rev, np.zeros((2, 2))],
                   [np.zeros((2, 2)), A_irr]])

# ============================================================
# 2. Simulate the full system and its components
# ============================================================

# Initial condition
x0 = np.array([2.0, 0.0, 1.5, 0.5])

times = np.linspace(0, 20, 1000)
dt = times[1] - times[0]

# Full trajectory
full_traj = np.array([expm(A_full * t) @ x0 for t in times])

# Reversible component (project onto first 2 dims)
rev_traj = full_traj[:, :2]

# Irreversible component (project onto last 2 dims)
irr_traj = full_traj[:, 2:]

# ============================================================
# 3. Compute eigenvalues and properties
# ============================================================

eigenvalues = np.linalg.eigvals(A_full)

# Determinant of flow matrix over time
dets_full = [np.linalg.det(expm(A_full * t)) for t in times]
dets_rev = [np.linalg.det(expm(A_rev * t)) for t in times]
dets_irr = [np.linalg.det(expm(A_irr * t)) for t in times]

# Energy-like quantities
energy_rev = rev_traj[:, 0]**2 + rev_traj[:, 1]**2
energy_irr = irr_traj[:, 0]**2 + irr_traj[:, 1]**2
energy_full = energy_rev + energy_irr

# ============================================================
# 4. Visualize
# ============================================================

fig = plt.figure(figsize=(16, 14))
gs = GridSpec(3, 3, figure=fig, hspace=0.35, wspace=0.35)
fig.suptitle('Flow Decomposition Theorem\n'
             'Every linear temporal flow = REVERSIBLE ⊕ IRREVERSIBLE',
             fontsize=16, fontweight='bold', y=0.98)

# --- Panel 1: Reversible component (phase portrait) ---
ax1 = fig.add_subplot(gs[0, 0])
ax1.plot(rev_traj[:, 0], rev_traj[:, 1], color='#2166ac', linewidth=1.5, alpha=0.8)
ax1.plot(rev_traj[0, 0], rev_traj[0, 1], 'o', color='#2166ac', markersize=8, label='start')
ax1.set_aspect('equal')
ax1.set_xlabel('x₁', fontsize=12)
ax1.set_ylabel('x₂', fontsize=12)
ax1.set_title('Reversible Component V_rev\n(Oscillatory, GROUP)',
              fontsize=12, fontweight='bold', color='#2166ac')
ax1.grid(True, alpha=0.3)
ax1.legend()
ax1.text(0.05, 0.05, f'λ = ±{omega_rev:.1f}i\n(imaginary axis)',
         transform=ax1.transAxes, fontsize=9, family='monospace',
         bbox=dict(boxstyle='round', facecolor='#d1e5f0', alpha=0.8))

# --- Panel 2: Irreversible component (phase portrait) ---
ax2 = fig.add_subplot(gs[0, 1])
ax2.plot(irr_traj[:, 0], irr_traj[:, 1], color='#b2182b', linewidth=1.5, alpha=0.8)
ax2.plot(irr_traj[0, 0], irr_traj[0, 1], 'o', color='#b2182b', markersize=8, label='start')
ax2.plot(0, 0, '*', color='black', markersize=12, label='attractor')
ax2.set_aspect('equal')
ax2.set_xlabel('x₃', fontsize=12)
ax2.set_ylabel('x₄', fontsize=12)
ax2.set_title('Irreversible Component V_irr\n(Decaying spiral, MONOID)',
              fontsize=12, fontweight='bold', color='#b2182b')
ax2.grid(True, alpha=0.3)
ax2.legend()
ax2.text(0.05, 0.05, f'λ = -{gamma:.1f} ± {omega_irr:.1f}i\n(left half-plane)',
         transform=ax2.transAxes, fontsize=9, family='monospace',
         bbox=dict(boxstyle='round', facecolor='#fddbc7', alpha=0.8))

# --- Panel 3: Eigenvalue plot ---
ax3 = fig.add_subplot(gs[0, 2])
for ev in eigenvalues:
    color = '#2166ac' if abs(ev.real) < 1e-10 else '#b2182b'
    marker = 'o' if abs(ev.real) < 1e-10 else 's'
    label = 'reversible' if abs(ev.real) < 1e-10 else 'irreversible'
    ax3.plot(ev.real, ev.imag, marker, color=color, markersize=12, label=label)

# Remove duplicate labels
handles, labels = ax3.get_legend_handles_labels()
by_label = dict(zip(labels, handles))
ax3.legend(by_label.values(), by_label.keys(), fontsize=10)

ax3.axvline(x=0, color='gray', linewidth=1, linestyle='-')
ax3.axhline(y=0, color='gray', linewidth=1, linestyle='-')
ax3.set_xlabel('Re(λ)', fontsize=12)
ax3.set_ylabel('Im(λ)', fontsize=12)
ax3.set_title('Eigenvalue Spectrum\nof Generator A',
              fontsize=12, fontweight='bold')
ax3.grid(True, alpha=0.3)
ax3.set_aspect('equal')

# Shade left half-plane
ax3.axvspan(-1, 0, alpha=0.1, color='red')
ax3.text(-0.5, 0, 'IRREVERSIBLE\nRe(λ) < 0', fontsize=8, ha='center',
         color='red', alpha=0.7)
ax3.axvspan(0, 0.5, alpha=0.05, color='gray')

# --- Panel 4: Time series ---
ax4 = fig.add_subplot(gs[1, :2])
ax4.plot(times, full_traj[:, 0], color='purple', linewidth=1.5, alpha=0.7, label='x₁ (full)')
ax4.plot(times, full_traj[:, 2], color='#b2182b', linewidth=1.5, alpha=0.7, label='x₃ (full)')
ax4.plot(times, rev_traj[:, 0], '--', color='#2166ac', linewidth=2, label='x₁ (rev component)')
ax4.plot(times, irr_traj[:, 0], '--', color='#e34a33', linewidth=2, label='x₃ (irr component)')
ax4.axhline(y=0, color='gray', linewidth=0.5)
ax4.set_xlabel('Time (t)', fontsize=12)
ax4.set_ylabel('Amplitude', fontsize=12)
ax4.set_title('Time Series: Oscillation (forever) vs Decay (→ 0)',
              fontsize=12, fontweight='bold')
ax4.legend(fontsize=9, ncol=2)
ax4.grid(True, alpha=0.3)

# --- Panel 5: Energy ---
ax5 = fig.add_subplot(gs[1, 2])
ax5.plot(times, energy_rev, color='#2166ac', linewidth=2, label='E_rev (constant)')
ax5.plot(times, energy_irr, color='#b2182b', linewidth=2, label='E_irr (decaying)')
ax5.plot(times, energy_full, color='purple', linewidth=2, linestyle='--', label='E_total')
ax5.set_xlabel('Time (t)', fontsize=12)
ax5.set_ylabel('Energy ||x||²', fontsize=12)
ax5.set_title('Energy: Conserved vs Dissipated',
              fontsize=12, fontweight='bold')
ax5.legend(fontsize=9)
ax5.grid(True, alpha=0.3)

# --- Panel 6: Determinant (volume preservation) ---
ax6 = fig.add_subplot(gs[2, :2])
ax6.plot(times, dets_rev, color='#2166ac', linewidth=2.5, label='det(Φ_rev(t)) = 1 (volume preserved)')
ax6.plot(times, dets_irr, color='#b2182b', linewidth=2.5, label='det(Φ_irr(t)) → 0 (volume contracts)')
ax6.plot(times, dets_full, color='purple', linewidth=2.5, linestyle='--', label='det(Φ(t)) (full system)')
ax6.set_xlabel('Time (t)', fontsize=12)
ax6.set_ylabel('Determinant det(Φ(t))', fontsize=12)
ax6.set_title('Volume Factor: The Algebraic Signature of Irreversibility',
              fontsize=12, fontweight='bold')
ax6.legend(fontsize=10)
ax6.grid(True, alpha=0.3)
ax6.set_ylim(-0.1, 1.5)

# --- Panel 7: Summary ---
ax7 = fig.add_subplot(gs[2, 2])
ax7.axis('off')
summary = (
    "FLOW DECOMPOSITION\n"
    "━━━━━━━━━━━━━━━━━━\n\n"
    "Theorem: For Φ(t) = e^{At},\n"
    "ℝⁿ = V_rev ⊕ V_irr where:\n\n"
    "V_rev: eigenvalues on\n"
    "  imaginary axis (Re λ = 0)\n"
    "  → oscillatory, reversible\n"
    "  → det(Φ) = 1 (GROUP)\n"
    "  → energy conserved\n\n"
    "V_irr: eigenvalues off\n"
    "  imaginary axis (Re λ ≠ 0)\n"
    "  → decaying/growing\n"
    "  → det(Φ) → 0 (MONOID)\n"
    "  → energy dissipated\n\n"
    "dim(V_irr) = \"amount of\n"
    "  irreversibility\" in system"
)
ax7.text(0.05, 0.95, summary, transform=ax7.transAxes,
         fontsize=9.5, va='top', family='monospace',
         bbox=dict(boxstyle='round', facecolor='#f0f0f0',
                  edgecolor='gray', alpha=0.95))

plt.savefig('/workspace/request-project/AlgebraicTime/demos/flow_decomposition.png',
            dpi=150, bbox_inches='tight')
plt.close()
print("✓ Saved: flow_decomposition.png")
