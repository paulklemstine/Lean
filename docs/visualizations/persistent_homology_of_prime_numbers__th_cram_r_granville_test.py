"""
Visualization 3: Cramér-Granville Conjecture Test

Compares the prime gap distribution to the Cramér model prediction
(exponential distribution with mean log(N)) across multiple scales.

This is the key falsifiable prediction: if prime gaps DON'T follow
an exponential distribution, the Cramér random model fails.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def sieve_primes(n):
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]


fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Test at multiple scales
test_params = [
    (10000, 'N = 10⁴'),
    (100000, 'N = 10⁵'),
    (500000, 'N = 5×10⁵'),
    (1000000, 'N = 10⁶'),
]

for idx, (N, label) in enumerate(test_params):
    ax = axes[idx // 2][idx % 2]
    primes = sieve_primes(N)
    gaps = [primes[i+1] - primes[i] for i in range(len(primes) - 1)]
    log_N = math.log(N)

    # Normalized gaps
    normalized = [g / log_N for g in gaps]

    # Histogram of normalized gaps
    bins = np.linspace(0, 6, 50)
    ax.hist(normalized, bins=bins, density=True, alpha=0.6, color='#3498db',
            edgecolor='white', label='Observed (normalized)')

    # Exponential(1) overlay
    x = np.linspace(0, 6, 200)
    ax.plot(x, np.exp(-x), 'r-', linewidth=2.5, label='Exp(1) prediction')

    # Compute KS-like statistic
    from collections import Counter
    sorted_norm = sorted(normalized)
    n_gaps = len(sorted_norm)
    ks_stat = 0
    for i, val in enumerate(sorted_norm):
        empirical_cdf = (i + 1) / n_gaps
        theoretical_cdf = 1 - math.exp(-val)
        ks_stat = max(ks_stat, abs(empirical_cdf - theoretical_cdf))

    ax.set_title(f'{label} (KS = {ks_stat:.4f})', fontsize=13, fontweight='bold')
    ax.set_xlabel('Normalized gap (g / log N)', fontsize=11)
    ax.set_ylabel('Density', fontsize=11)
    ax.legend(fontsize=10)
    ax.set_xlim(0, 6)

    # Add text with mean
    mean_norm = sum(normalized) / len(normalized)
    ax.text(0.95, 0.85, f'Mean = {mean_norm:.3f}\n(predicted: 1.0)',
            transform=ax.transAxes, ha='right', fontsize=10,
            bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))

plt.suptitle('Cramér-Granville Conjecture: Prime Gaps vs Exponential Distribution',
             fontsize=15, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_cramer.png', dpi=150, bbox_inches='tight')
print("Saved viz_cramer.png")
