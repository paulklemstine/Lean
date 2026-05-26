#!/usr/bin/env python3
"""
Visualization: Certificate Density in GL(2, F_p)

Shows the empirical density of certified pairs (both generators and their
product having irreducible characteristic polynomials) as a function of
the field size q. The density converges to a positive limit as q grows,
consistent with the generation certificate conjecture.
"""

import matplotlib.pyplot as plt
import numpy as np
import random

random.seed(42)

def is_irred_charpoly_2x2(M, p):
    """Check if charpoly of 2x2 matrix is irreducible over F_p."""
    tr = int((M[0][0] + M[1][1]) % p)
    det = int((M[0][0]*M[1][1] - M[0][1]*M[1][0]) % p)
    if det == 0:
        return False
    disc = (tr*tr - 4*det) % p
    if disc == 0:
        return False
    if p == 2:
        return True
    return pow(disc, (p-1)//2, p) == p - 1

def estimate_certificate_density(p, n_samples=500):
    """Estimate the density of certified pairs in GL(2, F_p)."""
    certified = 0
    for _ in range(n_samples):
        g = [[random.randint(0,p-1) for _ in range(2)] for _ in range(2)]
        h = [[random.randint(0,p-1) for _ in range(2)] for _ in range(2)]
        
        det_g = (g[0][0]*g[1][1] - g[0][1]*g[1][0]) % p
        det_h = (h[0][0]*h[1][1] - h[0][1]*h[1][0]) % p
        if det_g == 0 or det_h == 0:
            continue
        
        gh = [[(g[0][0]*h[0][0] + g[0][1]*h[1][0]) % p,
               (g[0][0]*h[0][1] + g[0][1]*h[1][1]) % p],
              [(g[1][0]*h[0][0] + g[1][1]*h[1][0]) % p,
               (g[1][0]*h[0][1] + g[1][1]*h[1][1]) % p]]
        
        if (is_irred_charpoly_2x2(g, p) and
            is_irred_charpoly_2x2(h, p) and
            is_irred_charpoly_2x2(gh, p)):
            certified += 1
    
    return certified / n_samples

# Compute densities
primes = [3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53,
          59, 61, 67, 71, 73, 79, 83, 89, 97, 101, 127, 151, 197, 251,
          307, 397, 499, 599, 701, 809, 997]

densities = []
for p in primes:
    n_samp = 2000 if p < 100 else (1000 if p < 500 else 500)
    d = estimate_certificate_density(p, n_samp)
    densities.append(d)
    
# Single irreducible charpoly density (theoretical: ~(p-1)/(2p) for large p → 1/2)
single_densities = []
for p in primes:
    # Fraction of GL(2,F_p) with irreducible charpoly ≈ (p²-p)/(2(p²-1)) ≈ 1/2
    single_densities.append((p*p - p) / (2 * (p*p - 1)))

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Left: Certificate density
ax1.scatter(primes, densities, c='steelblue', s=40, alpha=0.8, zorder=3)
ax1.plot(primes, densities, '-', color='steelblue', alpha=0.4)

# Theoretical single-generator density for comparison
ax1.plot(primes, single_densities, '--', color='coral', linewidth=2,
         label='Single irreducible charpoly density')

# Rough theoretical triple density estimate: ~(1/2)^3 = 1/8 = 0.125
ax1.axhline(y=0.125, color='green', linestyle=':', linewidth=1.5, alpha=0.7,
            label='Naive estimate (1/2)³ = 1/8')

ax1.set_xlabel('Prime p (field size)', fontsize=13)
ax1.set_ylabel('Certificate density', fontsize=13)
ax1.set_title('Density of Certified Pairs in GL(2, 𝔽ₚ)', fontsize=14,
              fontweight='bold')
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)
ax1.set_xscale('log')

# Right: Convergence analysis
ax2.scatter(primes, densities, c='steelblue', s=40, alpha=0.8, zorder=3)

# Moving average
window = 5
if len(densities) >= window:
    smoothed = np.convolve(densities, np.ones(window)/window, mode='valid')
    ax2.plot(primes[window-1:], smoothed, '-', color='darkblue', linewidth=2,
             label=f'{window}-point moving average')

ax2.set_xlabel('Prime p (field size)', fontsize=13)
ax2.set_ylabel('Certificate density', fontsize=13)
ax2.set_title('Convergence of Certificate Density', fontsize=14,
              fontweight='bold')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)
ax2.set_xscale('log')

plt.tight_layout()
plt.savefig('certificate_density.png', dpi=150, bbox_inches='tight')
print("Saved certificate_density.png")
