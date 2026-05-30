"""
Visualization: Quadratic Residue Balance

Visualizes the theorem that exactly half of {1,...,p-1} are quadratic
residues mod p, for each odd prime p. Shows:
- A bar chart of QR count vs (p-1)/2 for primes up to 100
- A scatter plot of the actual quadratic residues for small primes

This is the key testable prediction of the Langlands correspondence:
the "colors" are perfectly balanced.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import isqrt


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


fig, axes = plt.subplots(1, 2, figsize=(16, 7))

# === Left panel: QR count vs (p-1)/2 ===
primes = [p for p in sieve_primes(100) if p > 2]
qr_counts = []
expected = []

for p in primes:
    qr = sum(1 for a in range(1, p) if jacobi_symbol(a, p) == 1)
    qr_counts.append(qr)
    expected.append((p - 1) // 2)

ax = axes[0]
x = np.arange(len(primes))
width = 0.35
bars1 = ax.bar(x - width/2, qr_counts, width, label='Actual QR count', color='#b2182b', alpha=0.8)
bars2 = ax.bar(x + width/2, expected, width, label='(p−1)/2', color='#2166ac', alpha=0.8)

ax.set_xlabel('Prime p', fontsize=12)
ax.set_ylabel('Count', fontsize=12)
ax.set_title('Quadratic Residue Balance Theorem\n#{QR mod p} = (p−1)/2', fontsize=13, fontweight='bold')
ax.set_xticks(x[::3])
ax.set_xticklabels([str(p) for p in primes[::3]], fontsize=8)
ax.legend()

# === Right panel: QR/NR pattern for small primes ===
ax2 = axes[1]
small_primes = [p for p in sieve_primes(40) if p > 2]

for idx, p in enumerate(small_primes):
    for a in range(1, p):
        chi = jacobi_symbol(a, p)
        color = '#b2182b' if chi == 1 else '#2166ac'
        marker = 's' if chi == 1 else 'o'
        ax2.scatter(a, idx, c=color, s=15, marker=marker, alpha=0.7)

ax2.set_yticks(range(len(small_primes)))
ax2.set_yticklabels([f'p={p}' for p in small_primes], fontsize=9)
ax2.set_xlabel('Residue a ∈ {1, ..., p−1}', fontsize=12)
ax2.set_title('Quadratic Residues (■) vs Non-Residues (●)\nPerfect balance: equal counts', fontsize=13, fontweight='bold')

# Add legend
from matplotlib.lines import Line2D
legend_elements = [
    Line2D([0], [0], marker='s', color='w', markerfacecolor='#b2182b',
           markersize=8, label='QR (+1)'),
    Line2D([0], [0], marker='o', color='w', markerfacecolor='#2166ac',
           markersize=8, label='NR (−1)')
]
ax2.legend(handles=legend_elements, loc='upper right')

plt.tight_layout()
plt.savefig('viz_residue_balance.png', dpi=150, bbox_inches='tight')
print("Saved viz_residue_balance.png")
