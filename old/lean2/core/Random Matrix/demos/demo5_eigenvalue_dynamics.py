#!/usr/bin/env python3
"""
Demo 5: Dyson Brownian Motion

Visualizes eigenvalue trajectories as a function of a perturbation parameter t.
H(t) = (1-t)H₀ + tH₁, interpolating between two random matrices.
The eigenvalues execute Dyson Brownian motion, repelling each other as they evolve.

Generates: dyson_brownian_motion.png
"""

import numpy as np
import matplotlib.pyplot as plt
from scipy.linalg import eigvalsh

np.random.seed(42)

N = 20  # Matrix size
num_steps = 500

# Generate two random GUE matrices
A0 = np.random.randn(N, N) + 1j * np.random.randn(N, N)
H0 = (A0 + A0.conj().T) / (2 * np.sqrt(N))

A1 = np.random.randn(N, N) + 1j * np.random.randn(N, N)
H1 = (A1 + A1.conj().T) / (2 * np.sqrt(N))

# Interpolate and track eigenvalues
t_values = np.linspace(0, 1, num_steps)
eigenvalue_trajectories = np.zeros((num_steps, N))

for i, t in enumerate(t_values):
    H_t = (1 - t) * H0 + t * H1
    eigenvalue_trajectories[i] = np.sort(np.real(np.linalg.eigvalsh(H_t)))

# Plot
fig, axes = plt.subplots(1, 2, figsize=(16, 7))
fig.suptitle('Dyson Brownian Motion: Eigenvalue Trajectories Under Perturbation',
             fontsize=15, fontweight='bold', y=1.02)

# Left: Full trajectories
ax = axes[0]
colors = plt.cm.viridis(np.linspace(0, 1, N))
for j in range(N):
    ax.plot(t_values, eigenvalue_trajectories[:, j], color=colors[j],
            linewidth=1.2, alpha=0.8)
ax.set_xlabel('Interpolation Parameter $t$', fontsize=13)
ax.set_ylabel('Eigenvalue $\\lambda_i(t)$', fontsize=13)
ax.set_title('Eigenvalue Paths: $H(t) = (1-t)H_0 + tH_1$', fontsize=13)

# Annotate avoided crossings
# Find close approaches
for step in range(1, num_steps - 1):
    evals = eigenvalue_trajectories[step]
    gaps = np.diff(evals)
    min_gap_idx = np.argmin(gaps)
    if gaps[min_gap_idx] < 0.05:
        ax.annotate('avoided\ncrossing',
                    xy=(t_values[step], evals[min_gap_idx]),
                    xytext=(t_values[step] + 0.1, evals[min_gap_idx] + 0.3),
                    fontsize=9, color='red',
                    arrowprops=dict(arrowstyle='->', color='red'))
        break

# Right: Close-up of avoided crossing
ax = axes[1]

# Find the region with smallest gap
min_gaps = np.array([np.min(np.diff(eigenvalue_trajectories[i]))
                     for i in range(num_steps)])
min_gap_step = np.argmin(min_gaps)
t_focus = t_values[min_gap_step]
min_gap_idx = np.argmin(np.diff(eigenvalue_trajectories[min_gap_step]))

# Zoom into the two closest eigenvalues
idx1, idx2 = min_gap_idx, min_gap_idx + 1
t_range = max(0.15, 0.3)
t_mask = (t_values > t_focus - t_range) & (t_values < t_focus + t_range)

for j in [idx1 - 1, idx1, idx2, idx2 + 1]:
    if 0 <= j < N:
        lw = 3.0 if j in [idx1, idx2] else 1.0
        alpha = 1.0 if j in [idx1, idx2] else 0.4
        color = 'red' if j == idx1 else ('blue' if j == idx2 else 'gray')
        ax.plot(t_values[t_mask], eigenvalue_trajectories[t_mask, j],
                color=color, linewidth=lw, alpha=alpha)

# Mark the minimum gap
ax.annotate(f'Min gap = {min_gaps[min_gap_step]:.4f}',
            xy=(t_focus, eigenvalue_trajectories[min_gap_step, idx1]),
            xytext=(t_focus + 0.05, eigenvalue_trajectories[min_gap_step, idx1] - 0.15),
            fontsize=11, color='darkred', fontweight='bold',
            arrowprops=dict(arrowstyle='->', color='darkred', lw=2),
            bbox=dict(boxstyle='round,pad=0.3', facecolor='wheat', alpha=0.8))

ax.set_xlabel('Interpolation Parameter $t$', fontsize=13)
ax.set_ylabel('Eigenvalue', fontsize=13)
ax.set_title('Avoided Crossing (Close-up): Eigenvalues Repel!', fontsize=13)

plt.tight_layout()
plt.savefig('Random Matrix/demos/dyson_brownian_motion.png', dpi=150, bbox_inches='tight')
print("Saved: Random Matrix/demos/dyson_brownian_motion.png")
plt.close()


# ===== Figure 2: Multiple independent trajectories showing level repulsion =====
fig, ax = plt.subplots(figsize=(14, 7))
fig.suptitle('Dyson Brownian Motion: Multiple Realizations',
             fontsize=15, fontweight='bold', y=1.02)

N_small = 8
num_realizations = 4
colors_real = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3']

for r in range(num_realizations):
    # Each realization: Brownian motion on matrix entries
    H = np.zeros((N_small, N_small), dtype=complex)
    dt = 0.01
    times = np.arange(0, 3, dt)
    trajectories = np.zeros((len(times), N_small))

    for i, t in enumerate(times):
        dH = (np.random.randn(N_small, N_small) + 1j * np.random.randn(N_small, N_small)) * np.sqrt(dt)
        dH = (dH + dH.conj().T) / (2 * np.sqrt(N_small))
        H = H + dH
        trajectories[i] = np.sort(np.real(np.linalg.eigvalsh(H)))

    for j in range(N_small):
        ax.plot(times, trajectories[:, j], color=colors_real[r],
                linewidth=0.8, alpha=0.7)

ax.set_xlabel('Time $t$', fontsize=13)
ax.set_ylabel('Eigenvalue $\\lambda_i(t)$', fontsize=13)
ax.set_title('Eigenvalue Brownian Motion: Lines Never Cross (Level Repulsion)', fontsize=14)
ax.text(0.02, 0.98, 'Eigenvalue trajectories never cross\n— the Coulomb repulsion prevents it!',
        transform=ax.transAxes, fontsize=12, verticalalignment='top',
        bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))

plt.tight_layout()
plt.savefig('Random Matrix/demos/level_repulsion_trajectories.png', dpi=150, bbox_inches='tight')
print("Saved: Random Matrix/demos/level_repulsion_trajectories.png")
plt.close()
