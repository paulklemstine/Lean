"""
Visualization 2: Phase Transition in Synchronization Landscape

Shows the mean cross-prime synchronization index as a function of the
parameter c in the quadratic family x -> x^2 + c. The plot reveals a
bimodal distribution: exceptional parameters (with special algebraic
relations among critical orbits) cluster at high synchronization,
while generic parameters remain at low synchronization.
"""

import numpy as np
import matplotlib.pyplot as plt
from collections import Counter
from math import sqrt


def sieve_primes(n):
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(sqrt(n)) + 1):
        if is_prime[i]:
            for j in range(i*i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]


def orbit_signature(f, domain):
    visited = set()
    cycle_lengths = []
    tree_size = 0
    for start in domain:
        if start in visited:
            continue
        path = []
        seen = {}
        x = start
        step = 0
        while x not in seen and x not in visited:
            seen[x] = step
            path.append(x)
            x = f(x)
            step += 1
        if x in visited:
            for pt in path:
                visited.add(pt)
                tree_size += 1
        else:
            cycle_start = seen[x]
            period = step - cycle_start
            cycle_lengths.append(period)
            for i, pt in enumerate(path):
                visited.add(pt)
                if i < cycle_start:
                    tree_size += 1
    return sorted(cycle_lengths), tree_size


def sync_index(sig1, sig2):
    c1, _ = sig1
    c2, _ = sig2
    if not c1 or not c2:
        return 0.0
    counter1 = Counter(c1)
    counter2 = Counter(c2)
    common = sum((counter1 & counter2).values())
    return common / max(len(c1), len(c2))


def mean_sync(c, primes):
    sigs = {}
    for p in primes:
        f = lambda x, p=p, c=c: (x * x + c) % p
        sigs[p] = orbit_signature(f, list(range(p)))
    
    total = 0
    count = 0
    for i in range(len(primes)):
        for j in range(i + 1, len(primes)):
            total += sync_index(sigs[primes[i]], sigs[primes[j]])
            count += 1
    return total / count if count else 0


# Setup
primes = [p for p in sieve_primes(40) if p > 2]
c_range = list(range(-15, 16))

# Compute synchronization for each parameter
syncs = []
for c in c_range:
    ms = mean_sync(c, primes)
    syncs.append(ms)

# Known exceptional parameters
exceptional = {0: 'Fixed: 0↦0',
               -1: 'Period 2: 0↦-1↦0',
               -2: '0↦-2↦2↦2'}

fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(14, 10), height_ratios=[2, 1])
fig.suptitle('Adelic Synchronization Phase Transition\nQuadratic Family x → x² + c',
             fontsize=16, fontweight='bold')

# Top plot: bar chart
colors = ['#e74c3c' if c in exceptional else '#3498db' for c in c_range]
bars = ax1.bar(c_range, syncs, color=colors, alpha=0.8, edgecolor='white', linewidth=0.5)

# Add threshold line
threshold = 0.5 * (max(syncs) + np.median(syncs))
ax1.axhline(y=threshold, color='#2c3e50', linestyle='--', linewidth=1.5,
            label=f'Threshold τ ≈ {threshold:.3f}')

# Annotate exceptional parameters
for c, label in exceptional.items():
    if c in c_range:
        idx = c_range.index(c)
        ax1.annotate(label, (c, syncs[idx]),
                    textcoords="offset points", xytext=(0, 15),
                    ha='center', fontsize=8, fontweight='bold',
                    arrowprops=dict(arrowstyle='->', color='#e74c3c'),
                    color='#e74c3c')

ax1.set_xlabel('Parameter c', fontsize=12)
ax1.set_ylabel('Mean Cross-Prime\nSynchronization', fontsize=12)
ax1.legend(fontsize=10, loc='upper right')
ax1.set_ylim(0, max(syncs) * 1.3)

# Add legend patches
from matplotlib.patches import Patch
legend_elements = [Patch(facecolor='#e74c3c', alpha=0.8, label='Exceptional'),
                   Patch(facecolor='#3498db', alpha=0.8, label='Generic')]
ax1.legend(handles=legend_elements, loc='upper left', fontsize=10)

# Bottom plot: histogram of sync values
ax2.hist(syncs, bins=20, color='#95a5a6', edgecolor='white', alpha=0.8)
ax2.axvline(x=threshold, color='#e74c3c', linestyle='--', linewidth=1.5,
            label=f'Threshold τ')
ax2.set_xlabel('Mean Synchronization Value', fontsize=12)
ax2.set_ylabel('Count', fontsize=12)
ax2.set_title('Distribution of Synchronization Values', fontsize=12)
ax2.legend(fontsize=10)

plt.tight_layout()
plt.savefig('phase_transition.png', dpi=150, bbox_inches='tight')
print("Saved phase_transition.png")
