#!/usr/bin/env python3
"""
Algebraic Theory of Time — Demo 1: Temporal Flows
==================================================

Visualizes the fundamental distinction between:
  - REVERSIBLE flows (temporal GROUP): Hamiltonian dynamics
  - IRREVERSIBLE flows (temporal MONOID): Dissipative dynamics

The key insight: when time is a group, phase space volume is preserved
(Liouville's theorem). When time is a monoid, phase space contracts
(the arrow of time).

Run: python3 demo_temporal_flows.py
Output: temporal_flows.png
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
import matplotlib.patches as mpatches

# ============================================================
# 1. Define temporal flows
# ============================================================

def hamiltonian_flow(state, t, omega=1.0):
    """
    Reversible flow: simple harmonic oscillator.
    Φ(t) = rotation matrix by angle ωt.
    This is a GROUP action: Φ(-t) = Φ(t)^{-1}.
    Phase space volume is PRESERVED (Liouville).
    """
    x, p = state
    cos_t = np.cos(omega * t)
    sin_t = np.sin(omega * t)
    return np.array([x * cos_t + p * sin_t,
                     -x * sin_t + p * cos_t])


def dissipative_flow(state, t, omega=1.0, gamma=0.3):
    """
    Irreversible flow: damped harmonic oscillator.
    Φ(t) = e^{-γt} × rotation matrix.
    This is a MONOID action: Φ(t) is not invertible for t > 0.
    Phase space volume CONTRACTS (arrow of time).
    """
    x, p = state
    decay = np.exp(-gamma * t)
    cos_t = np.cos(omega * t)
    sin_t = np.sin(omega * t)
    return decay * np.array([x * cos_t + p * sin_t,
                             -x * sin_t + p * cos_t])

# ============================================================
# 2. Generate phase space trajectories
# ============================================================

n_particles = 12
np.random.seed(42)
theta_init = np.linspace(0, 2 * np.pi, n_particles, endpoint=False)
r_init = 2.0
initial_states = np.array([[r_init * np.cos(th), r_init * np.sin(th)]
                           for th in theta_init])

times = np.linspace(0, 15, 500)

# Compute trajectories
ham_trajectories = []
dis_trajectories = []
for s0 in initial_states:
    ham_traj = np.array([hamiltonian_flow(s0, t) for t in times])
    dis_traj = np.array([dissipative_flow(s0, t) for t in times])
    ham_trajectories.append(ham_traj)
    dis_trajectories.append(dis_traj)

# ============================================================
# 3. Compute phase space volume (area of convex hull proxy)
# ============================================================

def phase_space_area(trajectories, t_idx):
    """Compute area of the region spanned by particles at time t_idx."""
    points = np.array([traj[t_idx] for traj in trajectories])
    # Use the determinant-based area of the polygon
    n = len(points)
    # Sort by angle
    angles = np.arctan2(points[:, 1], points[:, 0])
    order = np.argsort(angles)
    pts = points[order]
    # Shoelace formula
    area = 0.5 * abs(sum(pts[i][0] * pts[(i+1) % n][1] -
                         pts[(i+1) % n][0] * pts[i][1]
                         for i in range(n)))
    return area

ham_areas = [phase_space_area(ham_trajectories, i) for i in range(len(times))]
dis_areas = [phase_space_area(dis_trajectories, i) for i in range(len(times))]

# ============================================================
# 4. Visualize
# ============================================================

fig, axes = plt.subplots(2, 2, figsize=(14, 12))
fig.suptitle('The Algebraic Theory of Time: Temporal Flows',
             fontsize=18, fontweight='bold', y=0.98)

# Color map for particles
colors = plt.cm.viridis(np.linspace(0, 0.9, n_particles))

# --- Panel 1: Hamiltonian flow (reversible, GROUP) ---
ax1 = axes[0, 0]
for i, traj in enumerate(ham_trajectories):
    ax1.plot(traj[:, 0], traj[:, 1], color=colors[i], alpha=0.7, linewidth=0.8)
    ax1.plot(traj[0, 0], traj[0, 1], 'o', color=colors[i], markersize=6)
    ax1.plot(traj[-1, 0], traj[-1, 1], 's', color=colors[i], markersize=5)
ax1.set_xlim(-3, 3)
ax1.set_ylim(-3, 3)
ax1.set_aspect('equal')
ax1.set_xlabel('Position (q)', fontsize=12)
ax1.set_ylabel('Momentum (p)', fontsize=12)
ax1.set_title('Hamiltonian Flow (Temporal GROUP)\nReversible — T = (ℝ, +)',
              fontsize=13, fontweight='bold', color='#2166ac')
ax1.grid(True, alpha=0.3)

# Add algebraic annotation
ax1.text(0.05, 0.95, 'Φ(t) ∈ Aut(S)\nΦ(-t) = Φ(t)⁻¹\ndet(Φ(t)) = 1',
         transform=ax1.transAxes, fontsize=10, verticalalignment='top',
         bbox=dict(boxstyle='round', facecolor='#d1e5f0', alpha=0.8),
         family='monospace')

# --- Panel 2: Dissipative flow (irreversible, MONOID) ---
ax2 = axes[0, 1]
for i, traj in enumerate(dis_trajectories):
    ax2.plot(traj[:, 0], traj[:, 1], color=colors[i], alpha=0.7, linewidth=0.8)
    ax2.plot(traj[0, 0], traj[0, 1], 'o', color=colors[i], markersize=6)
    ax2.plot(traj[-1, 0], traj[-1, 1], 's', color=colors[i], markersize=5)
ax2.set_xlim(-3, 3)
ax2.set_ylim(-3, 3)
ax2.set_aspect('equal')
ax2.set_xlabel('Position (q)', fontsize=12)
ax2.set_ylabel('Momentum (p)', fontsize=12)
ax2.set_title('Dissipative Flow (Temporal MONOID)\nIrreversible — T = (ℝ≥0, +)',
              fontsize=13, fontweight='bold', color='#b2182b')
ax2.grid(True, alpha=0.3)

ax2.text(0.05, 0.95, 'Φ(t) ∈ End(S)\nΦ(-t) does not exist\ndet(Φ(t)) → 0',
         transform=ax2.transAxes, fontsize=10, verticalalignment='top',
         bbox=dict(boxstyle='round', facecolor='#fddbc7', alpha=0.8),
         family='monospace')

# --- Panel 3: Phase space volume ---
ax3 = axes[1, 0]
ax3.plot(times, ham_areas, color='#2166ac', linewidth=2.5,
         label='Hamiltonian (GROUP) — volume preserved')
ax3.plot(times, dis_areas, color='#b2182b', linewidth=2.5,
         label='Dissipative (MONOID) — volume contracts')
ax3.axhline(y=ham_areas[0], color='gray', linestyle='--', alpha=0.5)
ax3.set_xlabel('Time (t)', fontsize=12)
ax3.set_ylabel('Phase Space Volume', fontsize=12)
ax3.set_title('Liouville\'s Theorem: Group vs Monoid',
              fontsize=13, fontweight='bold')
ax3.legend(fontsize=10, loc='center right')
ax3.grid(True, alpha=0.3)
ax3.set_ylim(bottom=0)

ax3.annotate('GROUP:\nVolume = const\n(Liouville)',
             xy=(10, ham_areas[0]), fontsize=9,
             xytext=(10, ham_areas[0] + 2),
             arrowprops=dict(arrowstyle='->', color='#2166ac'),
             color='#2166ac', fontweight='bold')

ax3.annotate('MONOID:\nVolume → 0\n(Arrow of time)',
             xy=(12, dis_areas[min(400, len(dis_areas)-1)]),
             fontsize=9,
             xytext=(8, 4),
             arrowprops=dict(arrowstyle='->', color='#b2182b'),
             color='#b2182b', fontweight='bold')

# --- Panel 4: The algebraic hierarchy ---
ax4 = axes[1, 1]
ax4.set_xlim(0, 10)
ax4.set_ylim(0, 10)
ax4.axis('off')
ax4.set_title('The Algebraic Hierarchy of Time',
              fontsize=13, fontweight='bold')

# Draw hierarchy boxes
levels = [
    (5, 1.5, 'POSET\n(T, ≤)', '#fee8c8', 'Causality only\n(Causal set theory)'),
    (5, 3.5, 'MONOID\n(T, +, 0, ≤)', '#fdbb84', 'Irreversible dynamics\n(Thermodynamics)'),
    (5, 5.5, 'GROUP\n(T, +, 0, −, ≤)', '#e34a33', 'Reversible dynamics\n(Classical/Quantum)'),
    (5, 7.5, 'FIBER BUNDLE\n{T_o}_{o∈O}', '#b30000', 'Observer-dependent\n(Relativity)'),
]

for x, y, label, color, desc in levels:
    box = mpatches.FancyBboxPatch((x - 2.2, y - 0.7), 4.4, 1.4,
                                   boxstyle="round,pad=0.1",
                                   facecolor=color, edgecolor='black',
                                   linewidth=1.5, alpha=0.85)
    ax4.add_patch(box)
    ax4.text(x, y, label, ha='center', va='center',
             fontsize=10, fontweight='bold', family='monospace')
    ax4.text(x + 3.5, y, desc, ha='left', va='center',
             fontsize=9, style='italic', color='#333333')

# Arrows between levels
for i in range(3):
    y_start = levels[i][1] + 0.7
    y_end = levels[i+1][1] - 0.7
    ax4.annotate('', xy=(5, y_end), xytext=(5, y_start),
                 arrowprops=dict(arrowstyle='->', color='black',
                                lw=2, connectionstyle='arc3,rad=0'))

# Arrow of time annotation
ax4.annotate('', xy=(1.5, 3.5), xytext=(1.5, 5.5),
             arrowprops=dict(arrowstyle='<->', color='red', lw=3))
ax4.text(0.3, 4.5, 'ARROW\nOF\nTIME', ha='center', va='center',
         fontsize=11, fontweight='bold', color='red',
         bbox=dict(boxstyle='round', facecolor='white', edgecolor='red', alpha=0.9))

plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.savefig('/workspace/request-project/AlgebraicTime/demos/temporal_flows.png',
            dpi=150, bbox_inches='tight')
plt.close()
print("✓ Saved: temporal_flows.png")
