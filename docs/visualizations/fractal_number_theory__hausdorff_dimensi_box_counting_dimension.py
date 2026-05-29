"""
Visualization 2: Box-Counting Dimension Estimation
====================================================
Shows the log-log plot of box count vs 1/ε for the prime fractal,
along with the dimension estimate and comparison to dimension = 1 line.
This is the key diagnostic plot for estimating Hausdorff dimension.
"""

import math
import matplotlib.pyplot as plt
import numpy as np


def sieve_primes(N):
    if N < 2:
        return []
    sieve = [True] * (N + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(N**0.5) + 1):
        if sieve[i]:
            for j in range(i * i, N + 1, i):
                sieve[j] = False
    return [i for i in range(2, N + 1) if sieve[i]]


def log_embed(p):
    return 1.0 / math.log(p)


def box_count(primes, epsilon):
    boxes = set()
    for p in primes:
        boxes.add(int(math.floor(log_embed(p) / epsilon)))
    return len(boxes)


# Parameters
N_values = [10**4, 10**5, 10**6]
colors = ['#e74c3c', '#3498db', '#2ecc71']
markers = ['o', 's', '^']

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 7))

for idx, N in enumerate(N_values):
    primes = sieve_primes(N)
    epsilons = [10**(-k/3) for k in range(1, 16)]

    log_inv_eps = []
    log_counts = []
    dims = []

    for eps in epsilons:
        bc = box_count(primes, eps)
        if bc > 0 and eps < 1:
            lie = math.log(1.0 / eps)
            lbc = math.log(bc)
            log_inv_eps.append(lie)
            log_counts.append(lbc)
            dims.append(lbc / lie)

    # Log-log plot
    ax1.scatter(log_inv_eps, log_counts, c=colors[idx], s=60,
                marker=markers[idx], alpha=0.8, label=f'N = 10^{int(math.log10(N))}',
                edgecolors='white', linewidth=0.5)

    # Linear fit
    if len(log_inv_eps) >= 2:
        n = len(log_inv_eps)
        sx = sum(log_inv_eps)
        sy = sum(log_counts)
        sxx = sum(x * x for x in log_inv_eps)
        sxy = sum(x * y for x, y in zip(log_inv_eps, log_counts))
        slope = (n * sxy - sx * sy) / (n * sxx - sx * sx)
        intercept = (sy - slope * sx) / n
        x_fit = np.linspace(min(log_inv_eps), max(log_inv_eps), 100)
        ax1.plot(x_fit, slope * x_fit + intercept, color=colors[idx],
                linestyle='--', alpha=0.6, linewidth=2,
                label=f'  slope = {slope:.3f}')

    # Dimension vs scale
    ax2.plot([math.log10(e) for e in epsilons[:len(dims)]], dims,
             color=colors[idx], marker=markers[idx], markersize=8,
             linewidth=2, alpha=0.8, label=f'N = 10^{int(math.log10(N))}')

# Reference line: dimension = 1
x_ref = np.linspace(0, 12, 100)
ax1.plot(x_ref, x_ref, 'k:', alpha=0.3, linewidth=2, label='slope = 1 (dimension 1)')

ax1.set_xlabel('log(1/ε)', fontsize=13)
ax1.set_ylabel('log(box count)', fontsize=13)
ax1.set_title('Box-Counting: log(N(ε)) vs log(1/ε)', fontsize=14, fontweight='bold')
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

ax2.axhline(y=1.0, color='black', linestyle=':', alpha=0.3, linewidth=2, label='dimension = 1')
ax2.set_xlabel('log₁₀(ε)', fontsize=13)
ax2.set_ylabel('Box-counting dimension estimate', fontsize=13)
ax2.set_title('Dimension Estimate vs Scale', fontsize=14, fontweight='bold')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)
ax2.set_ylim(0, 1.5)

plt.tight_layout()
plt.savefig('viz_box_counting.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_box_counting.png")
