"""
Visualization 3: Hyperbolic Prime Counting — The PNT on Curved Space

Compares:
- Classical prime counting π(n) vs n/ln(n)
- Lyndon word counting L(k,n) vs k^n/n (hyperbolic PNT analog)
- Lattice point counting in balls vs π·R² (Gauss circle problem)
"""

import numpy as np
import matplotlib.pyplot as plt


def mobius_function(m):
    """Compute the Möbius function μ(m)."""
    if m == 1:
        return 1
    factors = set()
    temp = m
    for p in range(2, int(np.sqrt(m)) + 2):
        if temp % p == 0:
            factors.add(p)
            temp //= p
            if temp % p == 0:
                return 0
    if temp > 1:
        factors.add(temp)
    return (-1) ** len(factors)

def count_lyndon(k, n):
    """Count Lyndon words of length n on k symbols via Witt's formula."""
    total = 0
    for d in range(1, n + 1):
        if n % d == 0:
            total += mobius_function(n // d) * k**d
    return total // n

def sieve_primes(N):
    """Sieve of Eratosthenes."""
    is_prime = [True] * (N + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(np.sqrt(N)) + 1):
        if is_prime[i]:
            for j in range(i*i, N+1, i):
                is_prime[j] = False
    return [i for i in range(N+1) if is_prime[i]]

def lattice_count(R):
    """Count lattice points in disk of radius R."""
    count = 0
    for a in range(-R, R+1):
        for b in range(-R, R+1):
            if a*a + b*b <= R*R:
                count += 1
    return count


fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# --- Panel 1: Classical PNT ---
ax = axes[0]
primes = sieve_primes(200)
ns = np.arange(2, 201)
pi_n = np.array([sum(1 for p in primes if p <= n) for n in ns])
approx = ns / np.log(ns)

ax.plot(ns, pi_n, 'b-', linewidth=2, label=r'$\pi(n)$')
ax.plot(ns, approx, 'r--', linewidth=1.5, label=r'$n / \ln(n)$')
ax.fill_between(ns, pi_n, approx, alpha=0.1, color='purple')
ax.set_xlabel('n')
ax.set_ylabel('Count')
ax.set_title('Classical Prime Number Theorem', fontsize=12)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# --- Panel 2: Hyperbolic PNT (Lyndon words) ---
ax2 = axes[1]
k = 2  # Binary alphabet
n_vals = np.arange(1, 25)
lyndon_counts = np.array([count_lyndon(k, n) for n in n_vals])
asymptotic = k**n_vals / n_vals

ax2.semilogy(n_vals, lyndon_counts, 'go-', markersize=6, linewidth=2,
             label=f'Lyndon words $L({k}, n)$')
ax2.semilogy(n_vals, asymptotic, 'r--', linewidth=1.5,
             label=f'${k}^n / n$')
ax2.set_xlabel('Word length n')
ax2.set_ylabel('Count (log scale)')
ax2.set_title('Hyperbolic PNT: Primitive Words', fontsize=12)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

# Annotate the ratio
ratios = lyndon_counts / asymptotic
ax2_twin = ax2.twinx()
ax2_twin.plot(n_vals, ratios, 'b:', alpha=0.5, linewidth=1)
ax2_twin.set_ylabel('Ratio L(k,n) / (k^n/n)', color='blue', alpha=0.7)
ax2_twin.tick_params(axis='y', labelcolor='blue')
ax2_twin.set_ylim(0.5, 1.1)

# --- Panel 3: Gauss Circle Problem ---
ax3 = axes[2]
R_vals = np.arange(1, 51)
counts = np.array([lattice_count(R) for R in R_vals])
pi_R2 = np.pi * R_vals**2

ax3.plot(R_vals, counts, 'b-', linewidth=2, label=r'$|\{(a,b) : a^2+b^2 \leq R^2\}|$')
ax3.plot(R_vals, pi_R2, 'r--', linewidth=1.5, label=r'$\pi R^2$')
ax3.set_xlabel('Radius R')
ax3.set_ylabel('Count')
ax3.set_title('Lattice Points in Ball (Gauss Circle)', fontsize=12)
ax3.legend(fontsize=10)
ax3.grid(True, alpha=0.3)

# Inset: error term
ax3_inset = ax3.inset_axes([0.15, 0.55, 0.4, 0.35])
error = counts - pi_R2
ax3_inset.plot(R_vals, error, 'purple', linewidth=1.5)
ax3_inset.axhline(0, color='gray', linewidth=0.5)
ax3_inset.set_title('Error term', fontsize=8)
ax3_inset.set_xlabel('R', fontsize=7)
ax3_inset.tick_params(labelsize=7)

plt.tight_layout()
plt.savefig('viz_prime_counting.png', dpi=150, bbox_inches='tight')
plt.close()
