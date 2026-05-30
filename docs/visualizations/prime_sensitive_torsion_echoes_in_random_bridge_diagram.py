"""
Visualization: Prime Torsion Echo Bridge Diagram

Shows the bridge theorem in action: numbers are classified by their
prime power status and sensitivity index. The diagram illustrates that
prime powers (single-prime-divisor numbers) are exactly those with
trivial torsion echo, while composite numbers with multiple prime
factors exhibit rich prime-sensitive structure.

Also plots the persistence conjecture: for each n, the fraction of
m ≤ C(n,2) that exhibit non-universal torsion across {2, 3}.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb


def padic_val(p: int, n: int) -> int:
    """Compute the p-adic valuation v_p(n)."""
    if n == 0 or p < 2:
        return 0
    k = 0
    while n % p == 0:
        n //= p
        k += 1
    return k


def is_prime_power(n: int) -> bool:
    """Check if n is a prime power."""
    if n < 2:
        return False
    for p in range(2, int(n**0.5) + 1):
        if n % p == 0:
            m = n
            while m % p == 0:
                m //= p
            return m == 1
    return True  # n is prime (prime^1)


def count_prime_factors(n: int) -> int:
    """Count distinct prime factors."""
    count = 0
    d = 2
    temp = n
    while d * d <= temp:
        if temp % d == 0:
            count += 1
            while temp % d == 0:
                temp //= d
        d += 1
    if temp > 1:
        count += 1
    return count


def sensitivity_index(n: int, primes: list) -> int:
    """Number of distinct p-adic valuations."""
    return len(set(padic_val(p, n) for p in primes))


# ============================================================
# Figure with 3 subplots
# ============================================================
fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# --- Subplot 1: Classification scatter ---
N = 150
primes_full = [2, 3, 5, 7, 11]
x_pp, y_pp = [], []
x_comp, y_comp = [], []

for n in range(2, N + 1):
    si = sensitivity_index(n, primes_full)
    npf = count_prime_factors(n)
    if is_prime_power(n):
        x_pp.append(n)
        y_pp.append(si)
    else:
        x_comp.append(n)
        y_comp.append(si)

axes[0].scatter(x_pp, y_pp, c='#3498db', s=15, alpha=0.7, label='Prime powers', zorder=5)
axes[0].scatter(x_comp, y_comp, c='#e74c3c', s=15, alpha=0.7, label='Composites (≥2 prime factors)', zorder=5)
axes[0].set_xlabel('n')
axes[0].set_ylabel('Sensitivity Index')
axes[0].set_title('Bridge Theorem:\nPrime Powers vs Composites', fontweight='bold')
axes[0].legend(fontsize=8)
axes[0].set_xlim(0, N)

# --- Subplot 2: Prime factor count vs sensitivity ---
for n in range(2, N + 1):
    si = sensitivity_index(n, primes_full)
    npf = count_prime_factors(n)
    color = '#3498db' if is_prime_power(n) else '#e74c3c'
    axes[1].scatter(npf, si, c=color, s=12, alpha=0.4)

axes[1].set_xlabel('Number of Distinct Prime Factors')
axes[1].set_ylabel('Sensitivity Index')
axes[1].set_title('Prime Factor Count\nvs Sensitivity', fontweight='bold')

# --- Subplot 3: Persistence conjecture ---
max_n = 30
n_values = list(range(3, max_n + 1))
fractions = []

for n in n_values:
    cn2 = comb(n, 2)
    if cn2 < 2:
        fractions.append(0)
        continue
    count_nonuniv = sum(1 for m in range(2, cn2 + 1)
                        if padic_val(2, m) != padic_val(3, m))
    fractions.append(count_nonuniv / (cn2 - 1))

axes[2].plot(n_values, fractions, 'o-', color='#2ecc71', markersize=4, linewidth=1.5)
axes[2].axhline(y=0.5, color='gray', linestyle='--', alpha=0.5, label='50% threshold')
axes[2].fill_between(n_values, fractions, alpha=0.2, color='#2ecc71')
axes[2].set_xlabel('Number of vertices n')
axes[2].set_ylabel('Fraction of m with v₂(m) ≠ v₃(m)')
axes[2].set_title('Persistence Conjecture:\nNon-Universal Fraction', fontweight='bold')
axes[2].legend(fontsize=8)
axes[2].set_ylim(0, 1)

plt.tight_layout()
plt.savefig('viz_bridge_diagram.png', dpi=150, bbox_inches='tight')
print("Saved viz_bridge_diagram.png")
