"""
Visualization: Lorentzian Gap Phase Diagram

This script creates a phase diagram showing how the Lorentzian gap varies
across the (J, h) parameter space of the transverse-field Ising model,
revealing the quantum phase transition.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def tfim_correlation_matrix(n, J, h):
    K = np.zeros((n, n))
    for k in range(n):
        theta = 2 * np.pi * k / n
        eps_k = 2 * np.sqrt(max(J**2 + h**2 - 2*J*h*np.cos(theta), 0))
        if eps_k < 1e-14:
            n_k = 0.5
        else:
            cos_angle = (h - J * np.cos(theta)) / (eps_k / 2)
            cos_angle = np.clip(cos_angle, -1, 1)
            n_k = (1 - cos_angle) / 2
        for i in range(n):
            for j in range(n):
                K[i, j] += n_k * np.cos(theta * (i - j)) / n
    K = (K + K.T) / 2
    eigvals, eigvecs = np.linalg.eigh(K)
    eigvals = np.clip(eigvals, 0, 1)
    return eigvecs @ np.diag(eigvals) @ eigvecs.T


def eigenvalue_gap(H):
    eigs = np.sort(np.linalg.eigvalsh(H))[::-1]
    return eigs[0] - (eigs[1] if len(eigs) > 1 else 0.0)


n = 5
J_vals = np.linspace(0.1, 2.5, 40)
h_vals = np.linspace(0.1, 2.5, 40)

gap_map = np.zeros((len(h_vals), len(J_vals)))
delta_map = np.zeros((len(h_vals), len(J_vals)))
diversity_map = np.zeros((len(h_vals), len(J_vals)))

for i, h in enumerate(h_vals):
    for j, J in enumerate(J_vals):
        K = tfim_correlation_matrix(n, J, h)
        d = np.diag(K)
        H = np.outer(d, d) - K * K
        gap_map[i, j] = eigenvalue_gap(H)

        eigs_K = np.linalg.eigvalsh(K)
        delta_map[i, j] = np.min(np.minimum(eigs_K, 1 - eigs_K))
        diversity_map[i, j] = np.trace(K)**2 - np.sum(K*K)

fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

# Panel 1: Lorentzian gap
im0 = axes[0].imshow(gap_map, origin='lower', aspect='auto',
                       extent=[J_vals[0], J_vals[-1], h_vals[0], h_vals[-1]],
                       cmap='inferno')
axes[0].plot([0.1, 2.5], [0.1, 2.5], 'w--', linewidth=2, label='h = J (critical line)')
axes[0].set_xlabel('Coupling J', fontsize=12)
axes[0].set_ylabel('Field h', fontsize=12)
axes[0].set_title('Lorentzian Gap (λ₁ - λ₂)', fontsize=13)
axes[0].legend(fontsize=10, loc='upper left')
plt.colorbar(im0, ax=axes[0], shrink=0.9)

# Panel 2: Spectral gap
im1 = axes[1].imshow(delta_map, origin='lower', aspect='auto',
                       extent=[J_vals[0], J_vals[-1], h_vals[0], h_vals[-1]],
                       cmap='viridis')
axes[1].plot([0.1, 2.5], [0.1, 2.5], 'w--', linewidth=2, label='h = J (critical line)')
axes[1].set_xlabel('Coupling J', fontsize=12)
axes[1].set_ylabel('Field h', fontsize=12)
axes[1].set_title('Spectral Gap Δ', fontsize=13)
axes[1].legend(fontsize=10, loc='upper left')
plt.colorbar(im1, ax=axes[1], shrink=0.9)

# Panel 3: DPP diversity
im2 = axes[2].imshow(diversity_map, origin='lower', aspect='auto',
                       extent=[J_vals[0], J_vals[-1], h_vals[0], h_vals[-1]],
                       cmap='plasma')
axes[2].plot([0.1, 2.5], [0.1, 2.5], 'w--', linewidth=2, label='h = J (critical line)')
axes[2].set_xlabel('Coupling J', fontsize=12)
axes[2].set_ylabel('Field h', fontsize=12)
axes[2].set_title('DPP Diversity (tr²K - ‖K‖²_F)', fontsize=13)
axes[2].legend(fontsize=10, loc='upper left')
plt.colorbar(im2, ax=axes[2], shrink=0.9)

plt.suptitle(f'Phase Diagram: TFIM on {n} qubits\n'
             'Lorentzian gap vanishes at the quantum critical point h = J',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('phase_diagram.png', dpi=150, bbox_inches='tight')
print("Saved: phase_diagram.png")
