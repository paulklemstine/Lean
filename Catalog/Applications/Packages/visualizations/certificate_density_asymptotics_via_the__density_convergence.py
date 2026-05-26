#!/usr/bin/env python3
"""
Visualization: Certificate Density Convergence to 1/n

Shows how δ_n(q) = I(q,n)/q^n converges to 1/n as q increases,
for various values of n. The convergence rate is O(q^{-n/2}),
reflecting the function-field Riemann hypothesis.
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


def density_over_qn(q, n):
    return necklace_count(q, n) / q**n


fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left panel: density vs q for various n
ax1 = axes[0]
q_values = list(range(2, 51))
colors = plt.cm.viridis(np.linspace(0.1, 0.9, 6))

for i, n in enumerate([2, 3, 4, 5, 6, 8]):
    densities = [density_over_qn(q, n) for q in q_values]
    ax1.plot(q_values, densities, '-o', color=colors[i], markersize=2,
             label=f'n={n}', linewidth=1.5)
    ax1.axhline(y=1/n, color=colors[i], linestyle='--', alpha=0.3, linewidth=0.8)

ax1.set_xlabel('Field size q', fontsize=12)
ax1.set_ylabel('I(q,n) / q^n', fontsize=12)
ax1.set_title('Certificate Density Convergence to 1/n', fontsize=13)
ax1.legend(loc='upper right', fontsize=10)
ax1.grid(True, alpha=0.3)
ax1.set_ylim(0, 0.55)

# Right panel: log error vs n for various q
ax2 = axes[1]
n_values = list(range(2, 16))

for q, color, marker in [(2, '#e74c3c', 'o'), (3, '#3498db', 's'),
                           (5, '#2ecc71', '^'), (7, '#9b59b6', 'D')]:
    errors = [abs(density_over_qn(q, n) - 1/n) for n in n_values]
    bounds = [1/q**(n//2) for n in n_values]
    ax2.semilogy(n_values, errors, f'-{marker}', color=color, markersize=4,
                 label=f'|error|, q={q}', linewidth=1.5)
    ax2.semilogy(n_values, bounds, '--', color=color, alpha=0.4,
                 linewidth=1, label=f'bound, q={q}')

ax2.set_xlabel('Degree n', fontsize=12)
ax2.set_ylabel('|I(q,n)/q^n - 1/n|', fontsize=12)
ax2.set_title('Error Bound: Function-Field PNT', fontsize=13)
ax2.legend(loc='upper right', fontsize=8, ncol=2)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('density_convergence.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved density_convergence.png")
