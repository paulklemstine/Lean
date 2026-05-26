#!/usr/bin/env python3
"""
Visualization: Error Term Structure

Shows the normalized error c₁(n,q) = n · q^(n/2) · (I(q,n)/q^n - 1/n)
as a function of n for various q, revealing the dependence on the
divisor structure of n. The testable prediction |c₁| ≤ 1 is falsified
for n with large proper divisors (e.g., n=6).
"""

import matplotlib.pyplot as plt
import numpy as np


def moebius(n):
    if n <= 0:
        return 0
    if n == 1:
        return 1
    factors = []
    temp = n
    d = 2
    while d * d <= temp:
        if temp % d == 0:
            factors.append(d)
            temp //= d
            if temp % d == 0:
                return 0
        d += 1
    if temp > 1:
        factors.append(temp)
    return (-1) ** len(factors)


def divisors(n):
    divs = []
    d = 1
    while d * d <= n:
        if n % d == 0:
            divs.append(d)
            if d != n // d:
                divs.append(n // d)
        d += 1
    return sorted(divs)


def necklace_count(q, n):
    return sum(moebius(n // d) * q**d for d in divisors(n)) / n


def normalized_error(q, n):
    """c₁(n,q) = n · q^(n//2) · (I(q,n)/q^n - 1/n)"""
    density = necklace_count(q, n) / q**n
    return n * q**(n // 2) * (density - 1.0/n)


fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: c₁ vs n for various q
ax1 = axes[0]
n_values = list(range(2, 25))

for q, color, ls in [(2, '#e74c3c', '-'), (3, '#3498db', '-'),
                      (5, '#2ecc71', '-'), (7, '#9b59b6', '-')]:
    c1_values = [normalized_error(q, n) for n in n_values]
    ax1.plot(n_values, c1_values, f'{ls}o', color=color, markersize=3,
             label=f'q={q}', linewidth=1.2)

ax1.axhline(y=1, color='gray', linestyle='--', alpha=0.5, label='|c₁| = 1')
ax1.axhline(y=-1, color='gray', linestyle='--', alpha=0.5)
ax1.axhline(y=0, color='black', linewidth=0.5)

# Mark primes, prime powers, and composite n
for n in n_values:
    is_prime = all(n % d != 0 for d in range(2, n))
    if is_prime and n >= 2:
        ax1.axvline(x=n, color='green', alpha=0.1, linewidth=8)

ax1.set_xlabel('Degree n', fontsize=12)
ax1.set_ylabel('c₁(n,q) = n·q^(n/2)·(I/q^n - 1/n)', fontsize=11)
ax1.set_title('Normalized Error: Divisor Structure Effect', fontsize=13)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)
ax1.set_ylim(-2, 0.5)
ax1.annotate('Green bands = prime n\n(error small)',
             xy=(0.02, 0.02), xycoords='axes fraction', fontsize=8,
             color='green', alpha=0.7)

# Right: |c₁| vs number of divisors of n
ax2 = axes[1]
for q, color in [(2, '#e74c3c'), (3, '#3498db'), (5, '#2ecc71'), (7, '#9b59b6')]:
    nd_values = [(len(divisors(n)), abs(normalized_error(q, n)))
                 for n in range(2, 31)]
    nd_x = [x[0] for x in nd_values]
    nd_y = [x[1] for x in nd_values]
    ax2.scatter(nd_x, nd_y, color=color, alpha=0.5, s=15, label=f'q={q}')

# Reference lines
d_range = np.linspace(1, 10, 100)
ax2.plot(d_range, d_range - 1, 'k--', alpha=0.3, label='d(n) - 1')
ax2.plot(d_range, np.ones_like(d_range), 'gray', linestyle=':', alpha=0.5)

ax2.set_xlabel('Number of divisors d(n)', fontsize=12)
ax2.set_ylabel('|c₁(n,q)|', fontsize=12)
ax2.set_title('Error vs Divisor Count', fontsize=13)
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)
ax2.set_xlim(1, 10)
ax2.set_ylim(0, 3)

plt.tight_layout()
plt.savefig('error_structure.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved error_structure.png")
