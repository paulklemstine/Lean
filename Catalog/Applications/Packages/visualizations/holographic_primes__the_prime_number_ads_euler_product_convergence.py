#!/usr/bin/env python3
"""
Visualization 1: Euler Product Convergence — Holographic Factorization

Visualizes how the finite Euler product ∏_{p≤N} (1 - p^(-s))^(-1)
converges to ζ(s) as N grows, showing the holographic factorization
in action: the boundary (primes) progressively reconstructs the bulk (ζ).
"""

import math
import numpy as np
import matplotlib.pyplot as plt
import matplotlib


def sieve_of_eratosthenes(n):
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i * i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]


def finite_euler_product(primes_list, s):
    product = 1.0
    for p in primes_list:
        product *= 1.0 / (1.0 - p ** (-s))
    return product


# Generate primes
all_primes = sieve_of_eratosthenes(5000)

# Compute convergence for s = 2
zeta_2 = math.pi**2 / 6
N_values = list(range(2, 200))
products = []
for N in N_values:
    primes_up_to_N = [p for p in all_primes if p <= N]
    products.append(finite_euler_product(primes_up_to_N, 2))

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle("Holographic Factorization: Euler Product Convergence",
             fontsize=16, fontweight='bold')

# Plot 1: Convergence to ζ(2)
ax1 = axes[0, 0]
ax1.plot(N_values, products, 'b-', linewidth=1.5, label='∏_{p≤N} (1-p⁻²)⁻¹')
ax1.axhline(y=zeta_2, color='r', linestyle='--', linewidth=1, label=f'ζ(2) = π²/6 ≈ {zeta_2:.4f}')
ax1.set_xlabel('N (boundary cutoff)', fontsize=11)
ax1.set_ylabel('Finite Euler product', fontsize=11)
ax1.set_title('Boundary → Bulk reconstruction', fontsize=12)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

# Plot 2: Relative error
ax2 = axes[0, 1]
errors = [abs(p - zeta_2) / zeta_2 for p in products]
ax2.semilogy(N_values, errors, 'g-', linewidth=1.5)
# Mark where each new prime is added
prime_positions = [i for i, N in enumerate(N_values) if N in all_primes]
prime_errors = [errors[i] for i in prime_positions]
prime_Ns = [N_values[i] for i in prime_positions]
ax2.scatter(prime_Ns[:30], prime_errors[:30], c='red', s=20, zorder=5,
           label='New prime added')
ax2.set_xlabel('N', fontsize=11)
ax2.set_ylabel('Relative error', fontsize=11)
ax2.set_title('Error drops at each prime', fontsize=12)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

# Plot 3: Individual prime contributions (log scale)
ax3 = axes[1, 0]
contributions = [math.log(1.0 / (1.0 - p ** (-2))) for p in all_primes[:50]]
ax3.bar(range(len(contributions)), contributions, color='steelblue', alpha=0.7)
ax3.set_xlabel('Prime index', fontsize=11)
ax3.set_ylabel('log Z_p(2) = -log(1 - p⁻²)', fontsize=11)
ax3.set_title('Individual boundary contributions (bulk weights)', fontsize=12)
prime_labels = [str(p) for p in all_primes[:50]]
ax3.set_xticks(range(0, 50, 5))
ax3.set_xticklabels([prime_labels[i] for i in range(0, 50, 5)], fontsize=8)
ax3.grid(True, alpha=0.3, axis='y')

# Plot 4: Convergence for multiple s values
ax4 = axes[1, 1]
s_values = [1.5, 2.0, 3.0, 4.0]
colors = ['#e74c3c', '#3498db', '#2ecc71', '#9b59b6']
for s, color in zip(s_values, colors):
    prods = []
    Ns = list(range(2, 500, 5))
    for N in Ns:
        ps = [p for p in all_primes if p <= N]
        prods.append(finite_euler_product(ps, s) if ps else 1.0)
    ax4.plot(Ns, prods, color=color, linewidth=1.5, label=f's = {s}')

ax4.set_xlabel('N', fontsize=11)
ax4.set_ylabel('Finite Euler product', fontsize=11)
ax4.set_title('Convergence at different "depths" s', fontsize=12)
ax4.legend(fontsize=10)
ax4.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('euler_product_convergence.png', dpi=150, bbox_inches='tight')
print("Saved: euler_product_convergence.png")
