"""
Visualization: Active Shadow Density vs Inverse Temperature

Plots the normalized active shadow density ρ_β = |ActSh₂(Z,0)| / n²
as a function of inverse temperature β for the 2D Ising model on
L×L grids with L = 2, 3, 4.

The key prediction: the derivative of ρ_β shows a peak near the
critical inverse temperature β_c ≈ 0.4407, providing a finite-size
precursor of the phase transition detected purely through support
shadow combinatorics.
"""

import numpy as np
import matplotlib.pyplot as plt


# Self-contained functions
def ising_energy(spins, L):
    E = 0.0
    for x in range(L):
        for y in range(L):
            idx = x * L + y
            E -= spins[idx] * spins[(x * L + (y + 1) % L)]
            E -= spins[idx] * spins[((x + 1) % L) * L + y]
    return E

def build_ising(L, beta):
    N = L * L
    n_states = 2**N
    w = np.zeros(n_states)
    obs = np.zeros((n_states, N))
    for bits in range(n_states):
        spins = np.array([(bits >> i) & 1 for i in range(N)]) * 2 - 1
        w[bits] = np.exp(-beta * ising_energy(spins, L))
        obs[bits] = (spins + 1) // 2
    return w, obs

def shadow_density(w, obs, y, thr=1e-12):
    ll = obs @ y
    mx = np.max(ll)
    u = w * np.exp(ll - mx)
    mu = u / np.sum(u)
    m = mu @ obs
    cov = (obs.T * mu) @ obs - np.outer(m, m)
    n = cov.shape[0]
    return np.sum(np.abs(cov) > thr) / n**2 if n > 0 else 0.0


beta_c = np.log(1 + np.sqrt(2)) / 2

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
fig.suptitle('Active Shadow Density as Phase Transition Detector',
             fontsize=14, fontweight='bold')

colors = ['#2196F3', '#FF5722', '#4CAF50']
markers = ['o', 's', 'D']

for L, color, marker in zip([2, 3, 4], colors, markers):
    N = L * L
    n_betas = 30
    betas = np.linspace(0.05, 1.5, n_betas)
    densities = []

    for beta in betas:
        w, obs = build_ising(L, beta)
        y0 = np.zeros(N)
        d = shadow_density(w, obs, y0)
        densities.append(d)

    densities = np.array(densities)

    ax1.plot(betas, densities, f'-{marker}', color=color,
             label=f'L={L} ({2**N} states)', markersize=4, linewidth=1.5)

    # Discrete derivative
    diffs = np.diff(densities) / np.diff(betas)
    beta_mid = (betas[:-1] + betas[1:]) / 2
    ax2.plot(beta_mid, np.abs(diffs), f'-{marker}', color=color,
             label=f'L={L}', markersize=3, linewidth=1.5)

ax1.axvline(beta_c, color='red', linestyle='--', alpha=0.7,
            label=f'β_c = {beta_c:.4f}')
ax1.set_xlabel('Inverse temperature β', fontsize=12)
ax1.set_ylabel('Shadow density ρ_β', fontsize=12)
ax1.set_title('ρ_β = |ActSh₂(Z,0)| / n²')
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.3)

ax2.axvline(beta_c, color='red', linestyle='--', alpha=0.7,
            label=f'β_c = {beta_c:.4f}')
ax2.set_xlabel('Inverse temperature β', fontsize=12)
ax2.set_ylabel('|dρ/dβ|', fontsize=12)
ax2.set_title('Derivative of Shadow Density')
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('shadow_density_vs_beta.png', dpi=150, bbox_inches='tight')
print("Saved shadow_density_vs_beta.png")
