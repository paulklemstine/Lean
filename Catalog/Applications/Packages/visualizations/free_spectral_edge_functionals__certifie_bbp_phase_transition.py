"""
Visualization 3: BBP-Type Phase Transition in the Free Edge

Shows how the deviation R(μ,σ) - 2σ transitions as spike strength
crosses the critical threshold, revealing the BBP phase transition.
"""

import numpy as np
import matplotlib.pyplot as plt


def stieltjes_denom_spike(n, spike, x):
    """Stieltjes denominator for spike law μ_{n,λ}."""
    return (1.0/n) / (x - spike)**2 + ((n-1.0)/n) / x**2

def free_edge_spike(n, spike, sigma, steps=300):
    """Compute free edge for spike law by bisection."""
    target = 1.0 / sigma**2
    max_loc = max(0, spike)
    left = max_loc + 1e-8
    right = max_loc + 10*sigma + 10
    for _ in range(steps):
        mid = (left + right) / 2
        if stieltjes_denom_spike(n, spike, mid) > target:
            left = mid
        else:
            right = mid
    return (left + right) / 2


sigma = 1.0
fig, axes = plt.subplots(1, 2, figsize=(14, 5.5))

# Left: BBP transition for various n
ax = axes[0]
ns = [10, 50, 200, 1000]
spikes = np.linspace(0, 4, 200)
colors = plt.cm.viridis(np.linspace(0.2, 0.9, len(ns)))

for n, color in zip(ns, colors):
    deviations = []
    for spike in spikes:
        edge = free_edge_spike(n, spike, sigma)
        deviations.append(edge - 2*sigma)
    ax.plot(spikes, deviations, '-', color=color, linewidth=2,
            label=f'n = {n}')

# BBP critical threshold (for σ=1, threshold is roughly σ²=1 in the limit)
ax.axvline(x=sigma**2, color='red', linestyle=':', linewidth=2, alpha=0.7,
           label=f'BBP threshold λ_c ≈ σ² = {sigma**2}')
ax.axhline(y=0, color='gray', linestyle='-', linewidth=0.5)

ax.set_xlabel('Spike strength λ', fontsize=13)
ax.set_ylabel('R(μ,σ) − 2σ', fontsize=13)
ax.set_title('BBP-Type Phase Transition in Free Edge', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Right: Heat map of free edge as function of (λ, σ)
ax = axes[1]
n = 100
spikes_grid = np.linspace(0, 5, 100)
sigmas_grid = np.linspace(0.2, 3, 100)
edge_matrix = np.zeros((len(sigmas_grid), len(spikes_grid)))

for i, sig in enumerate(sigmas_grid):
    for j, spk in enumerate(spikes_grid):
        edge_matrix[i, j] = free_edge_spike(n, spk, sig)

im = ax.imshow(edge_matrix, aspect='auto', origin='lower',
               extent=[spikes_grid[0], spikes_grid[-1],
                       sigmas_grid[0], sigmas_grid[-1]],
               cmap='magma')
plt.colorbar(im, ax=ax, label='Free edge R(μ,σ)')
ax.set_xlabel('Spike strength λ', fontsize=13)
ax.set_ylabel('Noise σ', fontsize=13)
ax.set_title(f'Free Edge Landscape (n={n})', fontsize=13)

# Overlay the BBP critical curve λ_c = σ²
sigmas_curve = np.linspace(0.2, np.sqrt(5), 100)
ax.plot(sigmas_curve**2, sigmas_curve, 'w--', linewidth=2,
        label='BBP curve λ = σ²')
ax.legend(fontsize=10, loc='upper left')

plt.tight_layout()
plt.savefig('viz_bbp_transition.png', dpi=150, bbox_inches='tight')
print("Saved viz_bbp_transition.png")
