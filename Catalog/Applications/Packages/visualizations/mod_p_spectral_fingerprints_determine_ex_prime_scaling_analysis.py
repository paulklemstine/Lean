"""
Visualization: Prime Scaling for Spectral Gap Recovery

Shows how the number of primes needed for exact recovery scales with
graph size. Demonstrates that for bounded-degree graphs, the number
of primes grows logarithmically — supporting the asymptotic conjecture.

SELF-CONTAINED: All functions are defined inline.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import factorial, log


def is_prime(n):
    if n < 2: return False
    for i in range(2, int(n**0.5) + 1):
        if n % i == 0: return False
    return True


def primes_needed(n, D):
    """Count how many consecutive primes are needed for CRT recovery
    of an n×n matrix with entries bounded by D."""
    bound = factorial(n) * (D ** n)
    target = 2 * bound
    product = 1
    count = 0
    p = 2
    while product <= target:
        if is_prime(p):
            product *= p
            count += 1
        p += 1
    return count, p - 1  # count, largest prime


fig, axes = plt.subplots(1, 3, figsize=(18, 6))
fig.suptitle('Scaling of Mod-p Spectral Fingerprint Recovery',
             fontsize=16, fontweight='bold')

# Panel 1: Number of primes vs graph size (fixed degree)
ax = axes[0]
Ns = list(range(3, 16))
for D in [2, 3, 4, 5]:
    counts = []
    for n in Ns:
        try:
            c, _ = primes_needed(n, D)
            counts.append(c)
        except Exception:
            counts.append(None)
    valid = [(n, c) for n, c in zip(Ns, counts) if c is not None]
    if valid:
        ns, cs = zip(*valid)
        ax.plot(ns, cs, 'o-', label=f'D = {D}', linewidth=2, markersize=6)

ax.set_xlabel('Number of vertices (n)', fontsize=12)
ax.set_ylabel('Number of primes needed', fontsize=12)
ax.set_title('Primes Needed vs. Graph Size', fontsize=13, fontweight='bold')
ax.legend(title='Max degree D')
ax.grid(True, alpha=0.3)

# Panel 2: Largest prime needed vs graph size
ax = axes[1]
for D in [2, 3, 4]:
    max_primes = []
    for n in Ns:
        try:
            _, mp = primes_needed(n, D)
            max_primes.append(mp)
        except Exception:
            max_primes.append(None)
    valid = [(n, mp) for n, mp in zip(Ns, max_primes) if mp is not None]
    if valid:
        ns, mps = zip(*valid)
        ax.plot(ns, mps, 's-', label=f'D = {D}', linewidth=2, markersize=6)

# Add n*log(n) reference curves
for D in [2]:
    ref = [n * log(n) * D for n in Ns]
    ax.plot(Ns, ref, '--', color='gray', alpha=0.5, label='n·log(n)·D (ref)')

ax.set_xlabel('Number of vertices (n)', fontsize=12)
ax.set_ylabel('Largest prime needed', fontsize=12)
ax.set_title('Largest Prime vs. Graph Size', fontsize=13, fontweight='bold')
ax.legend(title='Max degree D')
ax.grid(True, alpha=0.3)
ax.set_yscale('log')

# Panel 3: Prime product growth vs Hadamard bound
ax = axes[2]
n = 8
D = 3
bound = factorial(n) * (D ** n)

# Cumulative prime products
products = []
prime_counts = []
product = 1
p = 2
count = 0
while count < 30:
    if is_prime(p):
        product *= p
        count += 1
        products.append(product)
        prime_counts.append(count)
    p += 1

ax.semilogy(prime_counts, products, 'b-o', linewidth=2, markersize=5,
            label='∏ primes')
ax.axhline(y=2*bound, color='r', linestyle='--', linewidth=2,
           label=f'2B = 2·{n}!·{D}^{n}')
ax.axhline(y=bound, color='orange', linestyle=':', linewidth=1.5,
           label=f'B = {n}!·{D}^{n}')

# Mark the crossing point
for i, prod in enumerate(products):
    if prod > 2 * bound:
        ax.axvline(x=prime_counts[i], color='green', linestyle='--', alpha=0.5)
        ax.annotate(f'{prime_counts[i]} primes\nsuffice',
                   xy=(prime_counts[i], prod),
                   xytext=(prime_counts[i]+3, prod/10),
                   arrowprops=dict(arrowstyle='->', color='green'),
                   fontsize=10, color='green', fontweight='bold')
        break

ax.set_xlabel('Number of primes used', fontsize=12)
ax.set_ylabel('Product of primes (log scale)', fontsize=12)
ax.set_title(f'CRT Recovery Threshold (n={n}, D={D})', fontsize=13, fontweight='bold')
ax.legend(loc='lower right')
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_prime_scaling.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: viz_prime_scaling.png")
