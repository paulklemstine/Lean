"""
Visualization: Eigenvalue Flow of the Principal Minor Matrix

Shows how the eigenvalues of H = d·dᵀ - K⊙K evolve as the transverse field
h varies, revealing the emergence and persistence of Lorentzian signature.
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


fig, axes = plt.subplots(1, 3, figsize=(18, 5))

for plot_idx, n in enumerate([4, 5, 6]):
    h_vals = np.linspace(0.05, 3.0, 100)
    all_eigs = np.zeros((len(h_vals), n))

    for i, h in enumerate(h_vals):
        K = tfim_correlation_matrix(n, J=1.0, h=h)
        d = np.diag(K)
        H = np.outer(d, d) - K * K
        eigs = np.sort(np.linalg.eigvalsh(H))[::-1]
        all_eigs[i] = eigs

    ax = axes[plot_idx]

    # Plot each eigenvalue branch
    colors = plt.cm.RdYlBu(np.linspace(0, 1, n))
    for j in range(n):
        label = f'λ_{j+1}' if j < 3 else None
        lw = 2.5 if j == 0 else 1.5
        ax.plot(h_vals, all_eigs[:, j], color=colors[j], linewidth=lw, label=label)

    ax.axhline(y=0, color='black', linewidth=0.5, linestyle='-')
    ax.axvline(x=1.0, color='gray', linewidth=1.5, linestyle='--', alpha=0.7, label='h = J')

    # Shade the gap region
    ax.fill_between(h_vals, all_eigs[:, 0], all_eigs[:, 1],
                     alpha=0.15, color='red', label='Lorentzian gap')

    ax.set_xlabel('Transverse field h', fontsize=12)
    ax.set_ylabel('Eigenvalues of H', fontsize=12)
    ax.set_title(f'n = {n} qubits (J = 1)', fontsize=13)
    ax.legend(fontsize=9, loc='best')
    ax.grid(True, alpha=0.3)
    ax.set_xlim(h_vals[0], h_vals[-1])

plt.suptitle('Eigenvalue Flow of the Principal Minor Matrix\n'
             'H = d·dᵀ - K⊙K   (one positive eigenvalue = Lorentzian signature)',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('eigenvalue_flow.png', dpi=150, bbox_inches='tight')
print("Saved: eigenvalue_flow.png")
