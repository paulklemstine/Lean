"""
Visualization: Kronecker Character Table Heatmap

Visualizes the Langlands shape-color correspondence as a heatmap where:
- Rows are discriminants d (shapes = quadratic extensions Q(√d))
- Columns are primes p (test points)
- Colors represent χ_d(p): red (+1, split), blue (-1, inert), white (0, ramified)

This makes visible the deep structure of the Langlands correspondence:
each row is a unique "color pattern" matching a unique "shape".
"""

import numpy as np
import matplotlib.pyplot as plt
from math import gcd, isqrt


def jacobi_symbol(a: int, n: int) -> int:
    if n <= 0 or n % 2 == 0:
        return 0
    a = a % n
    result = 1
    while a != 0:
        while a % 2 == 0:
            a //= 2
            if n % 8 in (3, 5):
                result = -result
        a, n = n, a
        if a % 4 == 3 and n % 4 == 3:
            result = -result
        a = a % n
    return result if n == 1 else 0


def kronecker_symbol(d: int, n: int) -> int:
    if n == 0:
        return 1 if abs(d) == 1 else 0
    if n == 1:
        return 1
    result = 1
    while n % 2 == 0:
        n //= 2
        if d % 2 == 0:
            return 0
        if d % 8 in (3, 5):
            result = -result
    if n > 1:
        result *= jacobi_symbol(d, n)
    return result


def is_squarefree(n: int) -> bool:
    n = abs(n)
    if n == 0:
        return False
    for p in range(2, isqrt(n) + 1):
        if n % (p * p) == 0:
            return False
    return True


def sieve_primes(n: int) -> list:
    if n < 2:
        return []
    sieve = [True] * (n + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, isqrt(n) + 1):
        if sieve[i]:
            for j in range(i*i, n + 1, i):
                sieve[j] = False
    return [i for i in range(2, n + 1) if sieve[i]]


# Generate data
primes = sieve_primes(60)
discriminants = sorted([d for d in range(-30, 31) if d not in (0, 1) and is_squarefree(d)])

# Build character table
data = np.zeros((len(discriminants), len(primes)))
for i, d in enumerate(discriminants):
    for j, p in enumerate(primes):
        data[i, j] = kronecker_symbol(d, p)

# Create figure
fig, ax = plt.subplots(figsize=(14, 10))

# Custom colormap: blue (-1, inert), white (0, ramified), red (+1, split)
from matplotlib.colors import LinearSegmentedColormap
colors = ['#2166ac', '#f7f7f7', '#b2182b']
cmap = LinearSegmentedColormap.from_list('langlands', colors, N=3)

im = ax.imshow(data, cmap=cmap, aspect='auto', vmin=-1, vmax=1,
               interpolation='nearest')

ax.set_xticks(range(len(primes)))
ax.set_xticklabels([str(p) for p in primes], fontsize=7, rotation=45)
ax.set_yticks(range(len(discriminants)))
ax.set_yticklabels([f'd={d}' for d in discriminants], fontsize=7)

ax.set_xlabel('Prime p', fontsize=12)
ax.set_ylabel('Discriminant d (Shape = Q(√d))', fontsize=12)
ax.set_title('Langlands Shape-Color Correspondence (n=1)\n'
             'Each row is a unique "color" matching a unique "shape"',
             fontsize=14, fontweight='bold')

# Add colorbar
cbar = plt.colorbar(im, ax=ax, ticks=[-1, 0, 1], shrink=0.8)
cbar.ax.set_yticklabels(['−1 (inert)', '0 (ramified)', '+1 (split)'])
cbar.set_label('χ_d(p) = Kronecker Symbol', fontsize=11)

plt.tight_layout()
plt.savefig('viz_character_table.png', dpi=150, bbox_inches='tight')
print("Saved viz_character_table.png")
