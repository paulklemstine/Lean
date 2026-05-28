"""
Visualization 3: Perturbation Phase Diagram

This script visualizes the phase transition from Lorentzian to non-Lorentzian
behavior as the perturbation magnitude increases. It shows:

1. How eigenvalues of the perturbed Hessian shift with perturbation strength
2. The critical threshold where the second eigenvalue crosses zero
3. The "phase boundary" separating Lorentzian from non-Lorentzian regimes

This is the computational microscope that reveals the spectral mechanism
of Lorentzian breakdown.
"""

import numpy as np
import matplotlib.pyplot as plt


def leaf_hessian(m):
    return np.ones((m, m)) - np.eye(m)


def verify_lorentzian(H, tol=1e-10):
    eigs = np.linalg.eigvalsh(H)
    return np.sum(eigs > tol) <= 1


# Parameters
m_values = [3, 5, 8, 12]
t_values = np.linspace(0, 2.5, 200)

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Phase Transition: Lorentzian → Non-Lorentzian\nunder Diagonal Perturbation E = t·I',
             fontsize=15, fontweight='bold')

for idx, m in enumerate(m_values):
    ax = axes[idx // 2, idx % 2]
    H = leaf_hessian(m)

    # Track eigenvalues under perturbation E = t*I
    all_eigs = []
    is_lor = []
    for t in t_values:
        E = t * np.eye(m)
        H_pert = H + E
        eigs = np.sort(np.linalg.eigvalsh(H_pert))
        all_eigs.append(eigs)
        is_lor.append(verify_lorentzian(H_pert))

    all_eigs = np.array(all_eigs)

    # Plot eigenvalue trajectories
    for j in range(m):
        color = 'blue' if j == m - 1 else 'red'
        alpha = 1.0 if j == m - 1 or j == 0 else 0.3
        label = None
        if j == m - 1:
            label = rf'$\lambda_+ = {m-1} + t$'
        elif j == 0:
            label = rf'$\lambda_- = -1 + t$ (mult {m-1})'
        ax.plot(t_values, all_eigs[:, j], color=color, alpha=alpha,
                linewidth=2 if j in [0, m-1] else 1, label=label)

    # Mark the critical point t = 1
    ax.axvline(x=1, color='green', linestyle='--', linewidth=2, alpha=0.7,
               label='Critical: t = 1')
    ax.axhline(y=0, color='gray', linestyle='-', alpha=0.3)

    # Shade Lorentzian and non-Lorentzian regions
    ax.axvspan(0, 1, alpha=0.05, color='blue', label='Lorentzian')
    ax.axvspan(1, t_values[-1], alpha=0.05, color='red', label='Non-Lorentzian')

    ax.set_xlabel('Perturbation magnitude t', fontsize=11)
    ax.set_ylabel('Eigenvalue', fontsize=11)
    ax.set_title(f'm = {m} (leaf of $U_{{r,n}}$ with n−r+2={m})', fontsize=12)
    ax.legend(fontsize=8, loc='upper left')
    ax.grid(True, alpha=0.3)
    ax.set_xlim(0, 2.5)

plt.tight_layout()
plt.savefig('perturbation_phase.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: perturbation_phase.png")
