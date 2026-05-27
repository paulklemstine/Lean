#!/usr/bin/env python3
"""
Visualization: Eigenvalue Perturbation Under Noise

Shows how eigenvalues of a gapped Hamiltonian shift under increasing
perturbation, demonstrating the 2σ mechanism: ground and excited states
move toward each other, closing the gap at rate 2p·σ. The certified
bound tracks the worst-case gap closure.
"""

import numpy as np
import matplotlib.pyplot as plt

def make_gapped_hamiltonian(n, gap, ground_dim=2):
    eigenvalues = np.zeros(n)
    eigenvalues[ground_dim:] = np.linspace(gap, gap + 1.5, n - ground_dim)
    rng = np.random.default_rng(42)
    Q, _ = np.linalg.qr(rng.standard_normal((n, n)))
    H = Q @ np.diag(eigenvalues) @ Q.T
    return (H + H.T) / 2

def make_noise(n, seed=123):
    rng = np.random.default_rng(seed)
    A = rng.standard_normal((n, n))
    N = (A + A.T) / 2
    return N / np.linalg.norm(N, ord=2)

n = 16
gap = 2.0
ground_dim = 3
H = make_gapped_hamiltonian(n, gap, ground_dim)
N = make_noise(n)
sigma = np.linalg.norm(N, ord=2)  # ≈ 1.0 after normalization
p_star = gap / (2 * sigma)

# Sweep p values
p_values = np.linspace(0, 2 * p_star, 60)
all_eigenvalues = []
for p in p_values:
    H_p = H + p * N
    eigs = np.sort(np.linalg.eigvalsh(H_p))
    all_eigenvalues.append(eigs)
all_eigenvalues = np.array(all_eigenvalues)

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: eigenvalue trajectories
ax1 = axes[0]
for i in range(n):
    color = '#2ecc71' if i < ground_dim else '#e74c3c'
    alpha = 0.8 if i < ground_dim or i == ground_dim else 0.3
    lw = 2 if i < ground_dim or i == ground_dim else 0.8
    ax1.plot(p_values / p_star, all_eigenvalues[:, i], color=color,
             alpha=alpha, linewidth=lw)

# Certified bounds
certified_upper = np.array([p * sigma for p in p_values])
certified_lower = np.array([gap - p * sigma for p in p_values])
ax1.plot(p_values / p_star, certified_upper, 'g--', linewidth=2,
         label='Ground bound: pσ', alpha=0.7)
ax1.plot(p_values / p_star, certified_lower, 'r--', linewidth=2,
         label='Excited bound: Δ − pσ', alpha=0.7)

ax1.axvline(x=1.0, color='orange', linewidth=2, linestyle=':',
            label=f'p = p* (threshold)', alpha=0.8)
ax1.axhspan(-1, gap/2, xmin=0, xmax=0.5, alpha=0.05, color='green')

ax1.set_xlabel('p / p*  (normalized perturbation)', fontsize=13)
ax1.set_ylabel('Energy', fontsize=13)
ax1.set_title('Eigenvalue Trajectories Under Perturbation', fontsize=14,
              fontweight='bold')
ax1.legend(fontsize=10, loc='upper left')
ax1.set_xlim(0, 2)
ax1.grid(True, alpha=0.3)

# Right: actual gap vs certified gap
ax2 = axes[1]
actual_gaps = all_eigenvalues[:, ground_dim] - all_eigenvalues[:, ground_dim - 1]
certified_gaps = [gap - 2 * p * sigma for p in p_values]

ax2.plot(p_values / p_star, actual_gaps, 'b-', linewidth=2.5,
         label='Actual spectral gap')
ax2.plot(p_values / p_star, certified_gaps, 'r--', linewidth=2,
         label='Certified lower bound: Δ − 2pσ')
ax2.axhline(y=0, color='black', linewidth=0.5)
ax2.axvline(x=1.0, color='orange', linewidth=2, linestyle=':',
            label='Threshold p*', alpha=0.8)

ax2.fill_between(p_values / p_star, 0, certified_gaps,
                 where=np.array(certified_gaps) > 0,
                 alpha=0.15, color='green', label='Certified region')
ax2.fill_between(p_values / p_star, certified_gaps, 0,
                 where=np.array(certified_gaps) < 0,
                 alpha=0.15, color='red')

ax2.set_xlabel('p / p*  (normalized perturbation)', fontsize=13)
ax2.set_ylabel('Spectral gap', fontsize=13)
ax2.set_title('Gap Stability: Actual vs Certified Bound', fontsize=14,
              fontweight='bold')
ax2.legend(fontsize=10, loc='upper right')
ax2.set_xlim(0, 2)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_eigenvalue_perturbation.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_eigenvalue_perturbation.png")
