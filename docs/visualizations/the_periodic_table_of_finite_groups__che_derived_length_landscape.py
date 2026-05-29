#!/usr/bin/env python3
"""
Visualization 2: Derived Length Landscape

Shows the derived length bounds across group orders, revealing the
"complexity landscape" of finite groups. Orders where groups can have
high derived length appear as peaks; prime orders are flat valleys.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import log2


def prime_factorization(n):
    if n <= 1: return {}
    factors = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1
    if n > 1:
        factors[n] = factors.get(n, 0) + 1
    return factors


def is_prime(n):
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0: return False
        i += 6
    return True


def derived_length_bound(n):
    if n <= 1: return 0
    if is_prime(n): return 1
    factors = prime_factorization(n)
    if len(factors) == 1:
        _, a = list(factors.items())[0]
        return a
    return int(3 * log2(n) / 2) + 1


def euler_totient(n):
    if n <= 0: return 0
    result = n
    temp = n
    d = 2
    while d * d <= temp:
        if temp % d == 0:
            while temp % d == 0: temp //= d
            result -= result // d
        d += 1
    if temp > 1:
        result -= result // temp
    return result


def classify(n):
    if n <= 1 or is_prime(n): return 0
    factors = prime_factorization(n)
    if len(factors) == 1:
        _, a = list(factors.items())[0]
        return 1 if a == 2 else 2
    if n % 60 == 0 and n >= 60: return 3
    return 2


# Generate data
N = 100
orders = list(range(1, N + 1))
dl_bounds = [derived_length_bound(n) for n in orders]
totients = [euler_totient(n) for n in orders]
classes = [classify(n) for n in orders]

colors_map = {0: '#2196F3', 1: '#4CAF50', 2: '#FF9800', 3: '#F44336'}
point_colors = [colors_map[c] for c in classes]

fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(14, 10), sharex=True)

# Top: Derived length landscape
ax1.bar(orders, dl_bounds, color=point_colors, alpha=0.8, width=0.8)
ax1.set_ylabel('Derived Length Upper Bound', fontsize=12)
ax1.set_title('Derived Length Landscape: Complexity of Finite Groups',
              fontsize=14, fontweight='bold')

# Highlight prime orders
primes = [n for n in orders if is_prime(n)]
for p in primes:
    ax1.plot(p, 1, 'v', color='#2196F3', markersize=4, alpha=0.5)

# Highlight powers of 2
powers_of_2 = [2**k for k in range(1, 8) if 2**k <= N]
for p2 in powers_of_2:
    ax1.annotate(f'2^{int(log2(p2))}', (p2, derived_length_bound(p2)),
                textcoords="offset points", xytext=(0, 10),
                fontsize=7, ha='center', color='#FF9800')

ax1.set_ylim(0, max(dl_bounds) + 2)

# Bottom: Euler totient (φ(n)/n ratio)
phi_ratio = [euler_totient(n) / n for n in orders]
ax2.scatter(orders, phi_ratio, c=point_colors, s=20, alpha=0.7)
ax2.plot(orders, phi_ratio, color='gray', alpha=0.3, linewidth=0.5)
ax2.set_ylabel('φ(n)/n (Unit Group Density)', fontsize=12)
ax2.set_xlabel('Group Order n', fontsize=12)
ax2.set_title('Euler Totient Density: The Unit Group Bridge',
              fontsize=14, fontweight='bold')

# Add annotations for notable values
ax2.annotate('primes\n(φ/n → 1)', xy=(97, euler_totient(97)/97),
            xytext=(85, 0.5), fontsize=9,
            arrowprops=dict(arrowstyle='->', color='#2196F3'),
            color='#2196F3')

ax2.annotate('2^k\n(φ/n = 1/2)', xy=(64, 0.5),
            xytext=(70, 0.3), fontsize=9,
            arrowprops=dict(arrowstyle='->', color='#FF9800'),
            color='#FF9800')

plt.tight_layout()
plt.savefig('derived_length_landscape.png', dpi=150, bbox_inches='tight')
print("Saved derived_length_landscape.png")
