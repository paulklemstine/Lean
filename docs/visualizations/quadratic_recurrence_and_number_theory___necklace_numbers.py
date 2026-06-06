#!/usr/bin/env python3
"""
Visualization: Necklace Numbers and Dynatomic Point Counts

Shows the deep parallel between Euler's totient function φ(n)
and the dynatomic point count Ψ(n) = ∑_{d|n} μ(n/d)·2^d.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def moebius(n):
    if n == 1:
        return 1
    temp, d, factors = n, 2, 0
    while d * d <= temp:
        if temp % d == 0:
            count = 0
            while temp % d == 0:
                temp //= d
                count += 1
            if count > 1:
                return 0
            factors += 1
        d += 1
    if temp > 1:
        factors += 1
    return (-1) ** factors


def divisors(n):
    result = []
    for d in range(1, n + 1):
        if n % d == 0:
            result.append(d)
    return result


def dynatomic_sum(n):
    return sum(moebius(n // d) * (2 ** d) for d in divisors(n))


def euler_totient(n):
    result = n
    temp = n
    d = 2
    while d * d <= temp:
        if temp % d == 0:
            while temp % d == 0:
                temp //= d
            result -= result // d
        d += 1
    if temp > 1:
        result -= result // temp
    return result


N = 30
ns = list(range(1, N + 1))
psi_vals = [dynatomic_sum(n) for n in ns]
necklace_vals = [psi_vals[i] // ns[i] for i in range(N)]
phi_vals = [euler_totient(n) for n in ns]
necklace_phi = [phi_vals[i] // 1 for i in range(N)]  # φ(n)/1

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Plot 1: Dynatomic sum Ψ(n) vs 2^n
ax = axes[0, 0]
ax.semilogy(ns, psi_vals, 'bo-', label='Ψ(n) = dynatomic sum', markersize=5)
ax.semilogy(ns, [2**n for n in ns], 'r--', alpha=0.5, label='2^n (total periodic pts)')
ax.set_xlabel('Period n')
ax.set_ylabel('Count (log scale)')
ax.set_title('Dynatomic Point Count Ψ(n)')
ax.legend()
ax.grid(True, alpha=0.3)

# Plot 2: Necklace numbers N(n) = Ψ(n)/n
ax = axes[0, 1]
ax.bar(ns, necklace_vals, color='steelblue', alpha=0.7)
ax.set_xlabel('Length n')
ax.set_ylabel('N(n) = Ψ(n)/n')
ax.set_title('Binary Necklace Numbers')
ax.grid(True, alpha=0.3, axis='y')

# Plot 3: Totient-Dynatomic analogy
ax = axes[1, 0]
ax.semilogy(ns, [psi_vals[i] / ns[i] for i in range(N)], 'bo-',
            label='Ψ(n)/n (necklaces)', markersize=5)
ax.semilogy(ns, [phi_vals[i] / ns[i] for i in range(N)], 'rs-',
            label='φ(n)/n (reduced residues)', markersize=5)
ax.set_xlabel('n')
ax.set_ylabel('Ratio (log scale)')
ax.set_title('Totient-Dynatomic Analogy: Ψ(n)/n vs φ(n)/n')
ax.legend()
ax.grid(True, alpha=0.3)

# Plot 4: Prime power verification
ax = axes[1, 1]
primes = [2, 3, 5, 7]
colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3']
for i, p in enumerate(primes):
    ks = list(range(1, 8))
    pks = [p**k for k in ks if p**k <= 200]
    ks = ks[:len(pks)]
    psi_pk = [dynatomic_sum(pk) for pk in pks]
    expected = [2**pk - 2**(p**(k-1)) for pk, k in zip(pks, ks)]
    ax.semilogy(ks, psi_pk, 'o-', color=colors[i], label=f'Ψ({p}^k)', markersize=6)
    ax.semilogy(ks, expected, 's--', color=colors[i], alpha=0.5, markersize=4)
ax.set_xlabel('k')
ax.set_ylabel('Ψ(p^k) (log scale)')
ax.set_title('Prime Power Formula: Ψ(p^k) = 2^{p^k} - 2^{p^{k-1}}')
ax.legend()
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('/workspace/request-project/Applications/necklace_numbers.png', dpi=150)
plt.close()
print("Saved necklace_numbers.png")
