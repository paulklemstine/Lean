"""
Visualization: Noise Accumulation in Fermionic Quantum Circuits

Shows how the correlation matrix perturbation grows with circuit depth,
comparing the actual perturbation with the certified bound (3dε/2)
and the Bernoulli approximation (dε/2). Demonstrates that our
certified bound correctly envelopes all empirical observations.
"""

import numpy as np
import matplotlib.pyplot as plt

# Parameters
n = 4
eps_values = [0.01, 0.05, 0.1]
depths = np.arange(0, 101)

# Test correlation matrices
K_identity = np.eye(n)
K_mixed = np.array([[0.7, 0.2, -0.1, 0.05],
                     [0.2, 0.6,  0.1, -0.05],
                     [-0.1, 0.1, 0.5, 0.08],
                     [0.05, -0.05, 0.08, 0.4]])
K_extreme = np.array([[ 1.0,  0.5, -0.3,  0.2],
                       [ 0.5,  0.8,  0.4, -0.1],
                       [-0.3,  0.4,  0.6,  0.3],
                       [ 0.2, -0.1,  0.3, -0.5]])

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

for ax, eps in zip(axes, eps_values):
    for K, label, color in [(K_identity, 'K = I', '#2196F3'),
                             (K_mixed, 'K mixed', '#4CAF50'),
                             (K_extreme, 'K extreme', '#FF5722')]:
        perturbations = []
        for d in depths:
            contraction = (1 - eps) ** d
            shift = (1 - contraction) / 2
            K_noisy = contraction * K + shift * np.eye(n)
            pert = np.max(np.abs(K - K_noisy))
            perturbations.append(pert)
        ax.plot(depths, perturbations, color=color, label=f'Actual ({label})',
                linewidth=1.5, alpha=0.8)

    # Certified bound
    ax.plot(depths, 3 * depths * eps / 2, 'k--', linewidth=2, label='Bound: 3dε/2',
            alpha=0.9)
    # Bernoulli approximation
    ax.plot(depths, depths * eps / 2, 'k:', linewidth=1.5, label='Approx: dε/2',
            alpha=0.7)

    ax.set_xlabel('Circuit Depth d', fontsize=12)
    ax.set_ylabel('‖K - K\'‖_max', fontsize=12)
    ax.set_title(f'ε = {eps}', fontsize=14)
    ax.legend(fontsize=8, loc='upper left')
    ax.grid(True, alpha=0.3)
    ax.set_xlim(0, 100)

plt.suptitle('Noise Accumulation in Fermionic Quantum Circuits\n'
             'Certified Bound vs. Actual Perturbation',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_noise_accumulation.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_noise_accumulation.png")
