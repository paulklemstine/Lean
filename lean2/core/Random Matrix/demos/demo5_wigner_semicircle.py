#!/usr/bin/env python3
"""
Demo 5: The Wigner Semicircle Law — Equilibrium of the Coulomb Gas
===================================================================
Shows how the balance between eigenvalue repulsion and confining potential
produces Wigner's famous semicircle distribution.

Run: python demo5_wigner_semicircle.py
Outputs: wigner_semicircle.png
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec

np.random.seed(42)

# ─── Semicircle density ───
def semicircle(x, R=2.0):
    """Wigner semicircle: ρ(x) = (2/πR²)√(R²−x²) for |x| ≤ R."""
    return np.where(np.abs(x) <= R, 2 * np.sqrt(R**2 - x**2) / (np.pi * R**2), 0)

# ─── Sample matrices ───
def sample_GUE(n):
    A = (np.random.randn(n, n) + 1j * np.random.randn(n, n)) / np.sqrt(2)
    H = (A + A.conj().T) / np.sqrt(2)
    return np.linalg.eigvalsh(H)

fig = plt.figure(figsize=(18, 12))
fig.suptitle("Wigner's Semicircle Law: The Equilibrium of the Eigenvalue Coulomb Gas\n"
             "Balance of repulsion (spreading) vs confinement (centering) → semicircle density",
             fontsize=15, fontweight='bold', y=0.98)

gs = GridSpec(2, 3, hspace=0.4, wspace=0.3)

# ═══ Panel 1-3: Convergence to semicircle ═══
x_plot = np.linspace(-3, 3, 500)

for idx, N in enumerate([5, 50, 500]):
    ax = fig.add_subplot(gs[0, idx])
    n_samples = max(5000 // N, 50)
    all_eigs = []
    for _ in range(n_samples):
        eigs = sample_GUE(N) / np.sqrt(N)  # Normalize to get standard semicircle
        all_eigs.extend(eigs)
    all_eigs = np.array(all_eigs)
    
    ax.hist(all_eigs, bins=80, density=True, alpha=0.6, color='#3498db',
            edgecolor='white', linewidth=0.5, label=f'GUE (N={N})')
    ax.plot(x_plot, semicircle(x_plot), 'k-', linewidth=2.5, label='Semicircle')
    ax.set_xlabel('Normalized eigenvalue λ/√N', fontsize=10)
    ax.set_ylabel('Density', fontsize=10)
    ax.set_title(f'N = {N} ({n_samples} samples)', fontsize=12, fontweight='bold')
    ax.legend(fontsize=10)
    ax.set_xlim(-3, 3)
    ax.set_ylim(0, 0.45)

# ═══ Panel 4: Energy minimization perspective ═══
ax4 = fig.add_subplot(gs[1, 0])
# The semicircle minimizes: E[ρ] = -∫∫ log|x-y| ρ(x)ρ(y)dxdy + ½∫x² ρ(x)dx
# Plot the effective potential that a single eigenvalue sees
x = np.linspace(-2.5, 2.5, 300)
for N in [5, 20, 100]:
    # Effective potential ≈ x²/2 - (N-1)∫ log|x-y| ρ(y) dy
    # For semicircle ρ: ∫ log|x-y| ρ(y) dy = x²/4 - ½ + log(2)/2 for |x| ≤ 2
    # Simplified: effective potential in the bulk
    V_confine = x**2 / 2
    # Log-potential from semicircle (approximate for visualization)
    V_repel = np.zeros_like(x)
    y_grid = np.linspace(-1.99, 1.99, 200)
    rho_y = semicircle(y_grid)
    for i, xi in enumerate(x):
        integrand = -np.log(np.maximum(np.abs(xi - y_grid), 1e-10)) * rho_y
        V_repel[i] = np.trapezoid(integrand, y_grid) * (N-1)/N
    V_total = V_confine + V_repel
    V_total -= V_total.min()
    ax4.plot(x, V_total, linewidth=2, label=f'N={N}', alpha=0.8)

ax4.set_xlabel('Position x', fontsize=10)
ax4.set_ylabel('Effective potential V_eff(x)', fontsize=10)
ax4.set_title('Effective Potential for One Eigenvalue\n'
              '(confinement + repulsion from others)',
              fontsize=11, fontweight='bold')
ax4.legend(fontsize=10)
ax4.set_xlim(-2.5, 2.5)

# ═══ Panel 5: Single eigenvalue trajectory ═══
ax5 = fig.add_subplot(gs[1, 1])
N_traj = 50
n_frames = 200
# Generate a "time-evolving" matrix and track eigenvalues
H = np.zeros((N_traj, N_traj), dtype=complex)
A = (np.random.randn(N_traj, N_traj) + 1j * np.random.randn(N_traj, N_traj)) / np.sqrt(2)
H = (A + A.conj().T) / np.sqrt(2)

trajectories = np.zeros((n_frames, N_traj))
for t in range(n_frames):
    dA = (np.random.randn(N_traj, N_traj) + 1j * np.random.randn(N_traj, N_traj)) * 0.1 / np.sqrt(2)
    dH = (dA + dA.conj().T) / np.sqrt(2)
    H = H + dH
    eigs = np.sort(np.linalg.eigvalsh(H)) / np.sqrt(N_traj * (t+1) * 0.01 + N_traj)
    if len(eigs) == N_traj:
        trajectories[t] = eigs

colors = plt.cm.viridis(np.linspace(0, 1, N_traj))
for k in range(N_traj):
    ax5.plot(range(n_frames), trajectories[:, k], linewidth=0.5, alpha=0.5, color=colors[k])
ax5.set_xlabel('Time step', fontsize=10)
ax5.set_ylabel('Normalized eigenvalue', fontsize=10)
ax5.set_title('Dyson Brownian Motion\nEigenvalue trajectories under matrix flow',
              fontsize=11, fontweight='bold')

# ═══ Panel 6: The free energy functional ═══
ax6 = fig.add_subplot(gs[1, 2])
ax6.axis('off')

text = (
    "THE VARIATIONAL PRINCIPLE\n"
    "━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n"
    "The semicircle law minimizes the\n"
    "free energy functional:\n\n"
    "  F[ρ] = −∫∫ log|x−y| ρ(x)ρ(y) dx dy\n"
    "         + ½ ∫ x² ρ(x) dx\n\n"
    "Subject to: ∫ ρ(x) dx = 1, ρ ≥ 0\n\n"
    "Solution (Euler-Lagrange):\n\n"
    "  ρ*(x) = (1/2π)√(4 − x²)\n\n"
    "This is Voiculescu's free probability\n"
    "result: the semicircle is the FREE\n"
    "CONVOLUTION analogue of the Gaussian.\n\n"
    "━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
    "Repulsion → spreads eigenvalues apart\n"
    "Confinement → pulls them toward zero\n"
    "Balance → the semicircle"
)
ax6.text(0.5, 0.5, text, transform=ax6.transAxes,
         fontsize=10, ha='center', va='center',
         fontfamily='monospace',
         bbox=dict(boxstyle='round,pad=0.8', facecolor='#f0f0ff',
                   edgecolor='#3498db', linewidth=2, alpha=0.95))

fig.text(0.5, 0.01,
         "As N→∞, the empirical eigenvalue distribution converges to the semicircle — "
         "Wigner (1955).\nThis is the equilibrium of the Coulomb gas: "
         "maximum entropy subject to repulsion + confinement.",
         ha='center', fontsize=11, style='italic',
         bbox=dict(boxstyle='round,pad=0.5', facecolor='lightyellow', alpha=0.9))

plt.savefig('wigner_semicircle.png', dpi=150, bbox_inches='tight')
print("Saved: wigner_semicircle.png")
plt.close()
