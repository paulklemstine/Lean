"""
Visualization 1: Free Spectral Edge vs Classical 2σ Threshold

Shows how the structured free edge departs from the naive 2σ threshold
as the spike strength increases. Includes Monte Carlo validation.
"""

import numpy as np
import matplotlib.pyplot as plt


class SpectralAtom:
    def __init__(self, loc, weight):
        self.loc = loc
        self.weight = weight

class FiniteSpectrumLaw:
    def __init__(self, atoms):
        self.atoms = atoms
    def stieltjes_denom(self, x):
        return sum(a.weight / (x - a.loc)**2 for a in self.atoms)
    def max_loc(self):
        return max(a.loc for a in self.atoms)

def spike_law(n, spike):
    return FiniteSpectrumLaw([
        SpectralAtom(spike, 1.0/n),
        SpectralAtom(0.0, (n-1.0)/n),
    ])

def approximate_free_right_edge(mu, sigma, steps=200):
    target = 1.0 / sigma**2
    left = mu.max_loc() + 1e-6
    right = mu.max_loc() + 10*sigma + 10
    for _ in range(steps):
        mid = (left + right) / 2
        if mu.stieltjes_denom(mid) > target:
            left = mid
        else:
            right = mid
    return (left + right) / 2

def goe_matrix(n, sigma):
    A = np.random.randn(n, n) * sigma / np.sqrt(n)
    return (A + A.T) / 2


np.random.seed(42)
n = 100
sigma = 1.0
spikes = np.linspace(0, 6, 30)
trials = 500

free_edges = []
mc_means = []
mc_95 = []

for spike in spikes:
    mu = spike_law(n, spike)
    free_edges.append(approximate_free_right_edge(mu, sigma))

    D = np.zeros(n)
    D[0] = spike
    max_eigs = []
    for _ in range(trials):
        M = np.diag(D) + goe_matrix(n, sigma)
        max_eigs.append(np.linalg.eigvalsh(M)[-1])
    mc_means.append(np.mean(max_eigs))
    mc_95.append(np.percentile(max_eigs, 95))

fig, ax = plt.subplots(1, 1, figsize=(10, 6))
ax.plot(spikes, [2*sigma]*len(spikes), 'r--', linewidth=2, label='Classical 2σ')
ax.plot(spikes, free_edges, 'b-', linewidth=2.5, label='Free spectral edge R(μ,σ)')
ax.plot(spikes, mc_means, 'g^', markersize=5, alpha=0.7, label='Monte Carlo mean max eigenvalue')
ax.fill_between(spikes, mc_means, mc_95, alpha=0.15, color='green', label='MC mean → 95th percentile')
ax.plot(spikes, spikes, 'k:', linewidth=1, alpha=0.5, label='y = λ (spike location)')

ax.set_xlabel('Spike strength λ', fontsize=13)
ax.set_ylabel('Spectral edge / Max eigenvalue', fontsize=13)
ax.set_title('Free Spectral Edge vs Classical 2σ Threshold (n=100, σ=1)', fontsize=14)
ax.legend(fontsize=11, loc='upper left')
ax.grid(True, alpha=0.3)
ax.set_xlim(0, 6)
ax.set_ylim(1.5, 7)

plt.tight_layout()
plt.savefig('viz_edge_comparison.png', dpi=150, bbox_inches='tight')
print("Saved viz_edge_comparison.png")
