import math
"""
Visualization: Robustness Landscape — Certified vs Rejected Perturbations

Shows the certification boundary in (noise_level, gap) space, illustrating
where perturbations are certified as robustly log-concave vs rejected.
This visualizes the core theorem: coeffDist < gap/2 → certified.
"""

import numpy as np
import matplotlib.pyplot as plt

# Compute coefficient distance for binomial distributions with noise
def binomial_coeffs(n, normalize=True):
    c = np.array([float(math.comb(n, k)) for k in range(n+1)])
    if normalize:
        c /= c.sum()
    return c

def estimate_gap(coeffs):
    n = len(coeffs)
    if n < 3:
        return 0.0
    min_g = float('inf')
    for k in range(1, n-1):
        if coeffs[k-1] > 1e-15 and coeffs[k+1] > 1e-15 and coeffs[k] > 1e-15:
            r = coeffs[k]**2 / (coeffs[k-1] * coeffs[k+1])
            min_g = min(min_g, r - 1.0)
    return max(min_g, 0.0)

rng = np.random.default_rng(2025)

# Grid of (dimension, noise_level) pairs
dims = [5, 8, 10, 12, 15]
noise_levels = np.linspace(0, 0.12, 50)
n_trials = 30

fig, axes = plt.subplots(1, len(dims), figsize=(16, 4), sharey=True)

for idx, n in enumerate(dims):
    ax = axes[idx]
    ref = binomial_coeffs(n)
    gap = estimate_gap(ref)
    
    cert_fracs = []
    mean_dists = []
    
    for sigma in noise_levels:
        n_cert = 0
        dists = []
        for _ in range(n_trials):
            noisy = ref + sigma * rng.standard_normal(len(ref))
            noisy = np.maximum(noisy, 0)
            s = noisy.sum()
            if s > 0:
                noisy /= s
            d = float(np.sum(np.abs(ref - noisy)))
            dists.append(d)
            if d < gap / 2:
                n_cert += 1
        cert_fracs.append(n_cert / n_trials)
        mean_dists.append(np.mean(dists))
    
    # Plot certification fraction
    ax.fill_between(noise_levels, cert_fracs, alpha=0.3, color='green')
    ax.plot(noise_levels, cert_fracs, '-', color='green', linewidth=2)
    
    # Mark the gap/2 threshold (approx noise level where dist = gap/2)
    ax.axhline(y=0.5, color='gray', linestyle=':', alpha=0.4)
    ax.set_title(f'n = {n}\ngap = {gap:.4f}', fontsize=11)
    ax.set_xlabel('Noise σ', fontsize=10)
    if idx == 0:
        ax.set_ylabel('Certification Rate', fontsize=11)
    ax.set_ylim(-0.05, 1.05)
    ax.grid(alpha=0.3)

fig.suptitle('Robustness Certification Rate vs Noise Level\n'
             'Green region: perturbation is certified as safely log-concave',
             fontsize=13, fontweight='bold', y=1.05)
plt.tight_layout()
plt.savefig('viz_robustness_landscape.png', dpi=150, bbox_inches='tight')
plt.close()
