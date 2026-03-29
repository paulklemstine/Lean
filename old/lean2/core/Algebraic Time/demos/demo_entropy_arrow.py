#!/usr/bin/env python3
"""
Algebraic Theory of Time — Demo 2: The Arrow of Time Theorem
=============================================================

Visualizes the core theorem: strict entropy increase ⟹ time is a monoid (not a group).

We simulate:
  1. A reversible system (pendulum) — entropy is constant → GROUP
  2. An irreversible system (gas diffusion) — entropy increases → MONOID
  3. The contradiction: attempting to run the irreversible system backward

Run: python3 demo_entropy_arrow.py
Output: entropy_arrow.png
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec
import matplotlib.patches as mpatches

np.random.seed(42)

# ============================================================
# 1. Reversible system: Harmonic oscillator ensemble
# ============================================================

def harmonic_entropy(t, n_particles=100):
    """
    For a harmonic oscillator, the phase space distribution is
    a rotating ellipse. Shannon entropy of the distribution is CONSTANT.
    """
    return np.ones_like(t) * np.log(2 * np.pi)  # constant entropy

# ============================================================
# 2. Irreversible system: Diffusion / mixing
# ============================================================

def diffusion_entropy(t, D=0.5, S0=1.0, S_eq=5.0):
    """
    Entropy of a diffusing gas increases as:
    S(t) = S_eq - (S_eq - S0) * exp(-2Dt)
    Monotonically increasing, approaching equilibrium.
    """
    return S_eq - (S_eq - S0) * np.exp(-2 * D * t)

# ============================================================
# 3. Particle simulation for visualization
# ============================================================

def simulate_diffusion(n_particles=200, n_steps=100, dt=0.1, D=0.3):
    """Simulate 2D diffusion from a concentrated initial condition."""
    positions = np.random.randn(n_particles, 2) * 0.3  # concentrated
    history = [positions.copy()]
    for _ in range(n_steps):
        positions = positions + np.sqrt(2 * D * dt) * np.random.randn(n_particles, 2)
        history.append(positions.copy())
    return history

def compute_spatial_entropy(positions, n_bins=10, extent=3.0):
    """Compute discrete entropy from particle positions."""
    H, _, _ = np.histogram2d(positions[:, 0], positions[:, 1],
                              bins=n_bins,
                              range=[[-extent, extent], [-extent, extent]])
    H = H / H.sum()
    H = H[H > 0]
    return -np.sum(H * np.log(H))

# ============================================================
# 4. Run simulations
# ============================================================

times = np.linspace(0, 10, 200)
S_reversible = harmonic_entropy(times)
S_irreversible = diffusion_entropy(times)

# Particle simulation
diffusion_history = simulate_diffusion(n_particles=300, n_steps=200, dt=0.05)
particle_entropies = [compute_spatial_entropy(pos) for pos in diffusion_history]
particle_times = np.linspace(0, 10, len(particle_entropies))

# ============================================================
# 5. The contradiction visualization
# ============================================================

# If we try to run diffusion backward (assuming group structure):
times_backward = np.linspace(0, 10, 200)
S_forward = diffusion_entropy(times_backward)
# "Backward" would need entropy to ALSO increase (by monotonicity applied to -t)
# But Φ(-t)(Φ(t)(s)) = s, so entropy must return to original value → CONTRADICTION

# ============================================================
# 6. Create the figure
# ============================================================

fig = plt.figure(figsize=(16, 14))
gs = GridSpec(3, 3, figure=fig, hspace=0.35, wspace=0.3)
fig.suptitle('The Arrow of Time Theorem\n'
             '"Strictly increasing entropy ⟹ time is a MONOID, not a GROUP"',
             fontsize=16, fontweight='bold', y=0.98)

# --- Row 1: Particle snapshots ---
snapshot_indices = [0, 50, 150]
snapshot_labels = ['t = 0 (concentrated)', 't = 2.5 (spreading)', 't = 7.5 (diffused)']
for col, (idx, label) in enumerate(zip(snapshot_indices, snapshot_labels)):
    ax = fig.add_subplot(gs[0, col])
    pos = diffusion_history[idx]
    ax.scatter(pos[:, 0], pos[:, 1], s=3, alpha=0.5, c='#e34a33')
    ax.set_xlim(-3.5, 3.5)
    ax.set_ylim(-3.5, 3.5)
    ax.set_aspect('equal')
    ax.set_title(label, fontsize=11, fontweight='bold')
    ax.grid(True, alpha=0.2)
    ax.set_xlabel('x')
    ax.set_ylabel('y')
    # Compute and display entropy
    S = compute_spatial_entropy(pos)
    ax.text(0.05, 0.95, f'S = {S:.2f}', transform=ax.transAxes,
            fontsize=11, va='top',
            bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.9))

# --- Row 2: Entropy evolution comparison ---
ax_entropy = fig.add_subplot(gs[1, :2])
ax_entropy.plot(times, S_reversible, color='#2166ac', linewidth=3,
                label='Reversible (GROUP): S = const', linestyle='-')
ax_entropy.plot(times, S_irreversible, color='#b2182b', linewidth=3,
                label='Irreversible (MONOID): S ↑ monotonically')
ax_entropy.plot(particle_times, particle_entropies, color='#e34a33',
                linewidth=1.5, alpha=0.6, label='Simulation (particle diffusion)')

ax_entropy.set_xlabel('Time (t)', fontsize=13)
ax_entropy.set_ylabel('Entropy S(t)', fontsize=13)
ax_entropy.set_title('Entropy Evolution: Group vs Monoid', fontsize=13, fontweight='bold')
ax_entropy.legend(fontsize=10, loc='center right')
ax_entropy.grid(True, alpha=0.3)

# Shade the "arrow of time" region
ax_entropy.fill_between(times, S_reversible, S_irreversible,
                         alpha=0.15, color='red',
                         label='_Arrow of time gap')
ax_entropy.annotate('THE ARROW OF TIME\n= this gap',
                     xy=(6, 3.5), fontsize=11, fontweight='bold',
                     color='red', ha='center',
                     bbox=dict(boxstyle='round', facecolor='white',
                              edgecolor='red', alpha=0.9))

# --- Row 2 right: The proof by contradiction ---
ax_proof = fig.add_subplot(gs[1, 2])
ax_proof.axis('off')
ax_proof.set_title('Proof by Contradiction', fontsize=13, fontweight='bold',
                   color='#b2182b')

proof_text = (
    "ARROW OF TIME THEOREM\n"
    "━━━━━━━━━━━━━━━━━━━━━\n\n"
    "Assume: T is a GROUP\n"
    "        (∃ inverse: -t ∈ T)\n\n"
    "Given:  η(Φ(t)(s)) > η(s)\n"
    "        for t > 0  [entropy ↑]\n\n"
    "Then:   -t ∈ T (group inverse)\n\n"
    "Apply η to Φ(-t) on Φ(t)(s):\n"
    "  η(Φ(-t)(Φ(t)(s))) ≥ η(Φ(t)(s))\n"
    "  η(s) ≥ η(Φ(t)(s)) > η(s)\n\n"
    "  ⟹ η(s) > η(s)  ⚡\n\n"
    "CONTRADICTION! ∎\n\n"
    "∴ T is a MONOID, not a group."
)
ax_proof.text(0.05, 0.95, proof_text, transform=ax_proof.transAxes,
              fontsize=9.5, va='top', family='monospace',
              bbox=dict(boxstyle='round', facecolor='#fff5f0',
                       edgecolor='#b2182b', alpha=0.95))

# --- Row 3: The contradiction diagram ---
ax_contra = fig.add_subplot(gs[2, :])

# Forward evolution
t_fwd = np.linspace(0, 5, 100)
S_fwd = diffusion_entropy(t_fwd, S0=1.0, S_eq=5.0)
ax_contra.plot(t_fwd, S_fwd, color='#2166ac', linewidth=3, label='Forward: Φ(t), t > 0')

# "Backward" from endpoint (if group existed)
t_bwd = np.linspace(5, 10, 100)
S_bwd_correct = S_fwd[-1] * np.ones_like(t_bwd)  # should return to start
# What entropy WOULD do if we naively apply the monotonicity to backward time
S_bwd_wrong = diffusion_entropy(t_bwd - 5, S0=S_fwd[-1], S_eq=7.0)

ax_contra.plot(t_bwd, S_bwd_wrong, color='#b2182b', linewidth=3, linestyle='--',
               label='If Φ(-t) also increases entropy...')
ax_contra.axhline(y=S_fwd[0], color='green', linestyle=':', linewidth=2, alpha=0.7)
ax_contra.annotate('Should return here\n(Φ(-t)∘Φ(t) = id)',
                   xy=(10, S_fwd[0]), fontsize=10,
                   xytext=(8, S_fwd[0] - 0.8),
                   arrowprops=dict(arrowstyle='->', color='green', lw=2),
                   color='green', fontweight='bold')

ax_contra.annotate('But entropy says\nit goes HERE ⚡',
                   xy=(10, S_bwd_wrong[-1]), fontsize=10,
                   xytext=(8, S_bwd_wrong[-1] + 0.5),
                   arrowprops=dict(arrowstyle='->', color='#b2182b', lw=2),
                   color='#b2182b', fontweight='bold')

# The contradiction flash
ax_contra.plot([10], [S_bwd_wrong[-1]], '*', color='red', markersize=20, zorder=5)
ax_contra.plot([10], [S_fwd[0]], '*', color='green', markersize=20, zorder=5)

ax_contra.set_xlabel('Time', fontsize=13)
ax_contra.set_ylabel('Entropy S(t)', fontsize=13)
ax_contra.set_title('The Contradiction: Running Time Backward in a Dissipative System',
                    fontsize=13, fontweight='bold')
ax_contra.legend(fontsize=11)
ax_contra.grid(True, alpha=0.3)

# Add dramatic annotation
ax_contra.text(7.5, 3.5, 'CONTRADICTION!\nEntropy must simultaneously\n'
               'increase AND return to start.\n\n'
               '∴ Φ(-t) CANNOT EXIST\n∴ T is a MONOID',
               fontsize=11, fontweight='bold', color='red',
               ha='center', va='center',
               bbox=dict(boxstyle='round,pad=0.5', facecolor='white',
                        edgecolor='red', linewidth=2, alpha=0.95))

plt.savefig('/workspace/request-project/AlgebraicTime/demos/entropy_arrow.png',
            dpi=150, bbox_inches='tight')
plt.close()
print("✓ Saved: entropy_arrow.png")
