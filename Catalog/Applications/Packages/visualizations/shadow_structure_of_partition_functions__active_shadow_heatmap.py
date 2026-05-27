"""
Visualization: Active Second Shadow Heatmap

Shows the covariance matrix structure of a 2D Ising model at different
temperatures, visualizing how the active second shadow changes from
high temperature (disordered, sparse correlations) through the critical
point to low temperature (ordered, dense correlations).

This makes tangible the core theorem: the active shadow is exactly the
support of the susceptibility/covariance matrix.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec


# Self-contained functions (no local imports)
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

def cov_matrix(w, obs, y):
    ll = obs @ y
    mx = np.max(ll)
    u = w * np.exp(ll - mx)
    mu = u / np.sum(u)
    m = mu @ obs
    return (obs.T * mu) @ obs - np.outer(m, m)


# Parameters
L = 3
N = L * L
beta_c = np.log(1 + np.sqrt(2)) / 2
betas = [0.1, beta_c * 0.5, beta_c, beta_c * 1.5, 2.0]
labels = ['β = 0.10\n(High T)', f'β = {beta_c*0.5:.2f}\n(Warm)',
          f'β = {beta_c:.2f}\n(Critical)', f'β = {beta_c*1.5:.2f}\n(Cool)',
          'β = 2.00\n(Low T)']

fig, axes = plt.subplots(1, 5, figsize=(18, 4))
fig.suptitle('Active Second Shadow: Covariance Matrix of 3×3 Ising Model',
             fontsize=14, fontweight='bold')

y0 = np.zeros(N)
vmax_global = 0
covs = []
for beta in betas:
    w, obs = build_ising(L, beta)
    c = cov_matrix(w, obs, y0)
    covs.append(c)
    vmax_global = max(vmax_global, np.max(np.abs(c)))

for idx, (beta, label, c) in enumerate(zip(betas, labels, covs)):
    ax = axes[idx]
    shadow_density = np.sum(np.abs(c) > 1e-12) / N**2
    im = ax.imshow(np.abs(c), cmap='inferno', vmin=0, vmax=vmax_global,
                   aspect='equal')
    ax.set_title(f'{label}\nρ = {shadow_density:.2f}', fontsize=10)
    ax.set_xlabel('Observable j')
    if idx == 0:
        ax.set_ylabel('Observable i')
    ax.set_xticks(range(N))
    ax.set_yticks(range(N))

fig.colorbar(im, ax=axes, label='|Cov(aᵢ, aⱼ)|', shrink=0.8)
plt.tight_layout()
plt.savefig('shadow_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved shadow_heatmap.png")
