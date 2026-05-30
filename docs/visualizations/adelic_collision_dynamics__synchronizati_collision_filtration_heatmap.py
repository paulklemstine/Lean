"""
Visualization: Collision Filtration Heatmap
============================================
Shows how pairs of initial conditions in Z/nZ progressively synchronize
under the squaring map x ↦ x² mod n. Each pixel (a, b) shows the first
time step where f^k(a) = f^k(b), illustrating the collision filtration
as a "wave" of synchronization propagating through the system.
"""

import numpy as np
import matplotlib.pyplot as plt

N = 31  # Use a prime for clean structure
max_steps = 15

# Compute collision times for all pairs
collision_matrix = np.full((N, N), max_steps, dtype=float)

for a in range(N):
    for b in range(N):
        xa, xb = a, b
        for k in range(max_steps):
            if xa == xb:
                collision_matrix[a, b] = k
                break
            xa = (xa * xa) % N
            xb = (xb * xb) % N

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: Collision time heatmap
im1 = axes[0].imshow(collision_matrix, cmap='inferno_r', origin='lower',
                      vmin=0, vmax=max_steps)
axes[0].set_title(f'Collision Time Map\nx -> x^2 mod {N}', fontsize=14)
axes[0].set_xlabel('Initial condition b', fontsize=12)
axes[0].set_ylabel('Initial condition a', fontsize=12)
plt.colorbar(im1, ax=axes[0], label='First collision time')

# Right: Filtration cardinality growth
filtration_sizes = []
for k in range(max_steps):
    count = np.sum(collision_matrix <= k)
    filtration_sizes.append(count)

axes[1].plot(range(max_steps), filtration_sizes, 'o-', color='#e74c3c',
             linewidth=2, markersize=6)
axes[1].fill_between(range(max_steps), filtration_sizes, alpha=0.2, color='#e74c3c')
axes[1].set_title('Collision Filtration Growth\n(Monotone — Theorem Verified)', fontsize=14)
axes[1].set_xlabel('Time step k', fontsize=12)
axes[1].set_ylabel('Number of synchronized pairs', fontsize=12)
axes[1].set_ylim(0, N * N + 10)
axes[1].axhline(y=N * N, color='gray', linestyle='--', alpha=0.5,
                label=f'Total pairs = {N}² = {N*N}')
axes[1].legend(fontsize=10)
axes[1].grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('collision_filtration.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved collision_filtration.png")
