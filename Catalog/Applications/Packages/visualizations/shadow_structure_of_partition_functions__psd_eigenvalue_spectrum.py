"""
Visualization: Eigenvalue Spectrum of the Covariance/Hessian Matrix

Demonstrates Theorem 5 (positive semidefiniteness) by plotting the
eigenvalue spectrum of the susceptibility matrix across temperatures.

Shows how the eigenvalue structure changes at criticality:
- High T: all eigenvalues small and similar
- Critical: one or few eigenvalues become large (diverging susceptibility)
- Low T: eigenvalues redistribute as order sets in

This connects the active shadow to the rank of thermodynamic response.
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

def cov_matrix(w, obs, y):
    ll = obs @ y
    mx = np.max(ll)
    u = w * np.exp(ll - mx)
    mu = u / np.sum(u)
    m = mu @ obs
    return (obs.T * mu) @ obs - np.outer(m, m)


L = 3
N = L * L
beta_c = np.log(1 + np.sqrt(2)) / 2
n_betas = 40
betas = np.linspace(0.05, 1.5, n_betas)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
fig.suptitle(f'Susceptibility Eigenvalue Spectrum: {L}×{L} Ising Model',
             fontsize=14, fontweight='bold')

# Collect eigenvalues
all_eigvals = []
max_eigvals = []
traces = []

y0 = np.zeros(N)
for beta in betas:
    w, obs = build_ising(L, beta)
    c = cov_matrix(w, obs, y0)
    eigvals = np.sort(np.linalg.eigvalsh(c))[::-1]
    all_eigvals.append(eigvals)
    max_eigvals.append(eigvals[0])
    traces.append(np.trace(c))

# Plot 1: Waterfall of eigenvalue spectra
all_eigvals = np.array(all_eigvals)
for k in range(min(5, N)):
    ax1.plot(betas, all_eigvals[:, k], '-', linewidth=1.5,
             label=f'λ_{k+1}')

ax1.axvline(beta_c, color='red', linestyle='--', alpha=0.7,
            label=f'β_c = {beta_c:.4f}')
ax1.set_xlabel('Inverse temperature β', fontsize=12)
ax1.set_ylabel('Eigenvalue', fontsize=12)
ax1.set_title('Top Eigenvalues of Cov(a)')
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.3)
ax1.set_yscale('log')
ax1.set_ylim(bottom=1e-4)

# Plot 2: Maximum eigenvalue (dominant susceptibility)
ax2.plot(betas, max_eigvals, 'b-o', markersize=3, linewidth=1.5,
         label='max eigenvalue')
ax2.plot(betas, traces, 'g-s', markersize=3, linewidth=1.5,
         label='trace (total variance)', alpha=0.7)
ax2.axvline(beta_c, color='red', linestyle='--', alpha=0.7,
            label=f'β_c = {beta_c:.4f}')
ax2.set_xlabel('Inverse temperature β', fontsize=12)
ax2.set_ylabel('Value', fontsize=12)
ax2.set_title('Maximum Susceptibility & Total Variance')
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

# Verify PSD (Theorem 5)
min_eigval = np.min([np.min(e) for e in all_eigvals])
print(f"Minimum eigenvalue across all β: {min_eigval:.2e}")
print(f"PSD theorem verified: {min_eigval >= -1e-14}")

plt.tight_layout()
plt.savefig('psd_eigenvalues.png', dpi=150, bbox_inches='tight')
print("Saved psd_eigenvalues.png")
