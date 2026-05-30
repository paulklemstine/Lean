#!/usr/bin/env python3
"""
Visualization 2: Hyperbolic Zeta Function and Prime Counting

Shows the growth of the hyperbolic zeta sum ζ_H(s, N) for different values
of s, compared to classical growth rates. Also shows the hyperbolic prime
counting function compared to N/ln(N).
"""

import numpy as np
import matplotlib.pyplot as plt


def moebius_map(a, z):
    return (z - a) / (1 - np.conj(a) * z)


def compute_orbit(a, N):
    orbit = [0.0 + 0j]
    for _ in range(N):
        orbit.append(moebius_map(a, orbit[-1]))
    return orbit


def hyp_zeta_partial(a, s, N):
    orbit = compute_orbit(a, N)
    total = 0.0
    for i in range(1, N + 1):
        nsq = abs(orbit[i])**2
        if nsq > 1e-30:
            total += nsq**(-s)
    return total


def sieve_primes(N):
    if N < 2:
        return []
    is_prime = [True] * (N + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(N**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, N + 1, i):
                is_prime[j] = False
    return [i for i in range(N + 1) if is_prime[i]]


fig, axes = plt.subplots(1, 2, figsize=(14, 5.5))

golden = (3 - np.sqrt(5)) / 2

# Panel 1: Zeta function growth
ax1 = axes[0]
Ns = list(range(2, 201))
for s, color, label in [(0.5, '#E91E63', 's = 0.5'),
                          (1.0, '#2196F3', 's = 1.0'),
                          (2.0, '#4CAF50', 's = 2.0')]:
    zetas = [hyp_zeta_partial(golden, s, N) for N in Ns]
    ax1.plot(Ns, zetas, color=color, linewidth=2, label=label)

# Reference lines
ax1.plot(Ns, [np.log(N) for N in Ns], '--', color='gray', alpha=0.5, label='ln(N)')
ax1.plot(Ns, Ns, ':', color='gray', alpha=0.3, label='N')

ax1.set_xlabel('N (number of terms)', fontsize=12)
ax1.set_ylabel('ζ_H(s, N)', fontsize=12)
ax1.set_title('Hyperbolic Zeta Sum Growth', fontsize=13, fontweight='bold')
ax1.legend(fontsize=10)
ax1.set_yscale('log')
ax1.grid(True, alpha=0.3)

# Panel 2: Prime counting
ax2 = axes[1]
N_max = 500
primes = sieve_primes(N_max)

Ns_prime = list(range(2, N_max + 1))
pi_vals = []
count = 0
prime_idx = 0
for N in Ns_prime:
    while prime_idx < len(primes) and primes[prime_idx] <= N:
        count += 1
        prime_idx += 1
    pi_vals.append(count)

ax2.plot(Ns_prime, pi_vals, color='#2196F3', linewidth=2, label='π_H(N)')
ax2.plot(Ns_prime, [N / np.log(N) for N in Ns_prime], '--',
         color='#E91E63', linewidth=2, label='N / ln(N)')
ax2.plot(Ns_prime, [N / (np.log(N) - 1) for N in Ns_prime], ':',
         color='#4CAF50', linewidth=1.5, label='N / (ln(N) − 1)')

ax2.set_xlabel('N', fontsize=12)
ax2.set_ylabel('Count', fontsize=12)
ax2.set_title('Hyperbolic Prime Counting Function', fontsize=13, fontweight='bold')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

fig.suptitle('Hyperbolic Number Theory: Zeta Function & Primes',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_zeta.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_zeta.png")
