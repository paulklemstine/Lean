#!/usr/bin/env python3
"""
Visualization 3: Burnside's p^a·q^b Conjecture — Visual Test

Displays a scatter plot of all orders ≤ 200, highlighting those of the form
p^a·q^b (solvable by Burnside's theorem) vs. those with 3+ prime factors
(potentially non-solvable). The plot reveals the "safe zone" of Burnside's theorem.
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


N = 200
orders = list(range(2, N + 1))

# Classify by number of distinct prime factors
one_prime = []  # p^a (p-groups)
two_primes = []  # p^a·q^b (Burnside)
three_plus = []  # 3+ prime factors

for n in orders:
    factors = prime_factorization(n)
    num_distinct = len(factors)
    if num_distinct == 1:
        one_prime.append(n)
    elif num_distinct == 2:
        two_primes.append(n)
    else:
        three_plus.append(n)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 7))

# Left: Scatter plot of orders colored by Burnside classification
omega = lambda n: len(prime_factorization(n))  # number of distinct primes
Omega = lambda n: sum(prime_factorization(n).values())  # total prime factors

x_data = orders
y_omega = [omega(n) for n in orders]
y_Omega = [Omega(n) for n in orders]

colors = []
for n in orders:
    nf = len(prime_factorization(n))
    if nf == 1:
        colors.append('#2196F3')  # Blue: p-groups
    elif nf == 2:
        colors.append('#4CAF50')  # Green: Burnside zone
    else:
        colors.append('#F44336')  # Red: outside Burnside

ax1.scatter(x_data, y_omega, c=colors, s=30, alpha=0.7, edgecolors='white', linewidth=0.3)
ax1.set_xlabel('Group Order n', fontsize=12)
ax1.set_ylabel('ω(n) = # distinct prime factors', fontsize=12)
ax1.set_title("Burnside's Theorem: The Solvability Safe Zone",
              fontsize=13, fontweight='bold')

# Highlight A₅ territory
for n in [60, 120, 180]:
    if n <= N:
        ax1.annotate(f'n={n}', (n, omega(n)),
                    textcoords="offset points", xytext=(5, 8),
                    fontsize=8, color='#F44336',
                    arrowprops=dict(arrowstyle='->', color='#F44336', lw=0.8))

# Burnside boundary line
ax1.axhline(y=2.5, color='gray', linestyle='--', alpha=0.5, linewidth=1)
ax1.text(N * 0.7, 2.7, 'Burnside boundary', fontsize=9, color='gray', style='italic')

from matplotlib.patches import Patch
legend_elements = [
    Patch(facecolor='#2196F3', label='p-groups (always solvable)'),
    Patch(facecolor='#4CAF50', label='p^a·q^b (Burnside: solvable)'),
    Patch(facecolor='#F44336', label='3+ primes (may be non-solvable)'),
]
ax1.legend(handles=legend_elements, loc='upper left', fontsize=9)

# Right: Proportion of Burnside-safe orders
cumulative_burnside = []
cumulative_total = []
proportions = []

for n in range(2, N + 1):
    nf = len(prime_factorization(n))
    cumulative_total.append(n - 1)
    if nf <= 2:
        cumulative_burnside.append(cumulative_burnside[-1] + 1 if cumulative_burnside else 1)
    else:
        cumulative_burnside.append(cumulative_burnside[-1] if cumulative_burnside else 0)
    proportions.append(cumulative_burnside[-1] / cumulative_total[-1])

ax2.fill_between(range(2, N + 1), proportions, alpha=0.3, color='#4CAF50')
ax2.plot(range(2, N + 1), proportions, color='#4CAF50', linewidth=2)
ax2.set_xlabel('Max Order n', fontsize=12)
ax2.set_ylabel('Proportion of Burnside-safe orders', fontsize=12)
ax2.set_title('Coverage of Burnside\'s Theorem',
              fontsize=13, fontweight='bold')
ax2.set_ylim(0, 1.05)
ax2.axhline(y=proportions[-1], color='gray', linestyle=':', alpha=0.5)
ax2.text(N * 0.5, proportions[-1] + 0.03,
         f'{proportions[-1]:.1%} of orders ≤ {N}',
         fontsize=10, color='gray', ha='center')

plt.tight_layout()
plt.savefig('burnside_test.png', dpi=150, bbox_inches='tight')
print("Saved burnside_test.png")
