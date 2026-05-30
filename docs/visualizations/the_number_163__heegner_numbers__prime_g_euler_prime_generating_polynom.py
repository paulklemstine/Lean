"""
Visualization 1: Euler's Prime-Generating Polynomial

Shows the values of n²+n+41 for n = 0,...,45, highlighting which values
are prime (green) and which are composite (red). The transition at n=40
is the dramatic boundary predicted by Heegner number theory.
"""

import matplotlib.pyplot as plt
import numpy as np


def is_prime(n):
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
    return True


def euler_poly(n):
    return n * n + n + 41


fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(12, 8), gridspec_kw={'height_ratios': [3, 1]})

ns = list(range(46))
vals = [euler_poly(n) for n in ns]
primes = [is_prime(v) for v in vals]

# Top plot: polynomial values with prime/composite coloring
colors = ['#2ecc71' if p else '#e74c3c' for p in primes]
ax1.bar(ns, vals, color=colors, alpha=0.8, edgecolor='white', linewidth=0.5)
ax1.axvline(x=39.5, color='#f39c12', linewidth=2, linestyle='--',
            label='Boundary: n = 40')
ax1.set_xlabel('n', fontsize=14)
ax1.set_ylabel('f(n) = n² + n + 41', fontsize=14)
ax1.set_title("Euler's Prime-Generating Polynomial: 40 Consecutive Primes",
              fontsize=16, fontweight='bold')
ax1.legend(fontsize=12)

# Add text annotations
ax1.annotate('f(0) = 41', xy=(0, 41), xytext=(5, 200),
            fontsize=10, arrowprops=dict(arrowstyle='->', color='gray'))
ax1.annotate('f(39) = 1601', xy=(39, 1601), xytext=(30, 1400),
            fontsize=10, arrowprops=dict(arrowstyle='->', color='gray'))
ax1.annotate('f(40) = 1681 = 41²\n(COMPOSITE!)',
            xy=(40, 1681), xytext=(35, 1850),
            fontsize=10, color='#e74c3c', fontweight='bold',
            arrowprops=dict(arrowstyle='->', color='#e74c3c'))

# Legend
from matplotlib.patches import Patch
legend_elements = [Patch(facecolor='#2ecc71', label='Prime'),
                   Patch(facecolor='#e74c3c', label='Composite')]
ax1.legend(handles=legend_elements, fontsize=12, loc='upper left')

# Bottom plot: prime/composite indicator
ax2.bar(ns, [1 if p else -1 for p in primes], color=colors, alpha=0.8)
ax2.axvline(x=39.5, color='#f39c12', linewidth=2, linestyle='--')
ax2.set_xlabel('n', fontsize=14)
ax2.set_ylabel('Prime?', fontsize=14)
ax2.set_yticks([1, -1])
ax2.set_yticklabels(['Yes', 'No'])
ax2.set_title('Primality Pattern: Perfect Run of 40, Then Failure', fontsize=13)

plt.tight_layout()
plt.savefig('viz_euler_primes.png', dpi=150, bbox_inches='tight')
print("Saved viz_euler_primes.png")
