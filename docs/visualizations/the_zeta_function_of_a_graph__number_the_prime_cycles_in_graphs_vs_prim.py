"""
Visualization 3: Prime Cycles in Graphs vs Primes in Integers
================================================================
Compares the prime cycle counting function Π_G(ℓ) of Ramanujan graphs
with q^ℓ/ℓ (the predicted asymptotic), analogous to π(x) ~ x/ln(x).
Shows how graph prime cycles mirror the distribution of prime numbers.
"""

import numpy as np
import matplotlib.pyplot as plt
from numpy.linalg import eigvalsh


def adjacency_matrix_petersen():
    edges = [
        (0,1),(0,4),(0,5),(1,2),(1,6),(2,3),(2,7),
        (3,4),(3,8),(4,9),(5,7),(5,8),(6,8),(6,9),(7,9)
    ]
    A = np.zeros((10, 10))
    for i, j in edges:
        A[i, j] = A[j, i] = 1
    return A


def adjacency_matrix_complete(n):
    return np.ones((n, n)) - np.eye(n)


def paley_graph(q):
    qr = set()
    for x in range(1, q):
        qr.add((x * x) % q)
    A = np.zeros((q, q))
    for i in range(q):
        for j in range(q):
            if i != j and (i - j) % q in qr:
                A[i, j] = 1
    return A


def moebius(n):
    if n == 1:
        return 1
    factors = []
    d = 2
    temp = n
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


def prime_cycle_cumulative(A, max_len):
    """Return cumulative prime cycle counts."""
    cumulative = []
    total = 0.0
    for k in range(1, max_len + 1):
        inner = 0.0
        for d in range(1, k + 1):
            if k % d == 0:
                mu = moebius(d)
                if mu != 0:
                    inner += mu * np.trace(np.linalg.matrix_power(A, k // d))
        total += inner / k
        cumulative.append(total)
    return cumulative


fig, axes = plt.subplots(2, 2, figsize=(14, 10))

max_len = 14

# Panel 1: Petersen graph prime cycles
ax = axes[0, 0]
A = adjacency_matrix_petersen()
q = 2
cum = prime_cycle_cumulative(A, max_len)
x = list(range(1, max_len + 1))
predicted = [sum(q**k / k for k in range(1, ell+1)) for ell in x]

ax.semilogy(x, cum, 'bo-', label='Π_G(ℓ) (actual)', markersize=6)
ax.semilogy(x, predicted, 'r^--', label='Σ q^k/k (predicted)', markersize=6)
ax.set_xlabel('Cycle length ℓ')
ax.set_ylabel('Cumulative count (log scale)')
ax.set_title('Petersen Graph (3-regular, q=2)', fontsize=12, fontweight='bold')
ax.legend()
ax.grid(True, alpha=0.3)

# Panel 2: K_5 prime cycles
ax = axes[0, 1]
A = adjacency_matrix_complete(5)
q = 3
cum = prime_cycle_cumulative(A, max_len)
predicted = [sum(q**k / k for k in range(1, ell+1)) for ell in x]

ax.semilogy(x, [max(c, 0.1) for c in cum], 'go-', label='Π_G(ℓ) (actual)', markersize=6)
ax.semilogy(x, predicted, 'r^--', label='Σ q^k/k (predicted)', markersize=6)
ax.set_xlabel('Cycle length ℓ')
ax.set_ylabel('Cumulative count (log scale)')
ax.set_title('Complete Graph K₅ (4-regular, q=3)', fontsize=12, fontweight='bold')
ax.legend()
ax.grid(True, alpha=0.3)

# Panel 3: Ratio Π_G(ℓ) / (Σ q^k/k) for Petersen
ax = axes[1, 0]
A = adjacency_matrix_petersen()
q = 2
cum = prime_cycle_cumulative(A, max_len)
predicted = [sum(q**k / k for k in range(1, ell+1)) for ell in x]
ratios = [c / p if p > 0 else 0 for c, p in zip(cum, predicted)]

ax.plot(x, ratios, 'bs-', markersize=7, linewidth=2)
ax.axhline(y=1, color='r', linestyle='--', linewidth=1, label='Predicted ratio = 1')
ax.set_xlabel('Cycle length ℓ')
ax.set_ylabel('Ratio Π_G(ℓ) / Σ q^k/k')
ax.set_title('Prime Cycle Ratio (Petersen)', fontsize=12, fontweight='bold')
ax.legend()
ax.grid(True, alpha=0.3)
ax.set_ylim(0, 3)

# Panel 4: Comparison with classical prime counting
ax = axes[1, 1]

# Classical prime counting function
def prime_count(n):
    if n < 2:
        return 0
    sieve = [True] * (n + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(n**0.5) + 1):
        if sieve[i]:
            for j in range(i*i, n+1, i):
                sieve[j] = False
    return sum(sieve)

x_classical = list(range(2, 200))
pi_x = [prime_count(n) for n in x_classical]
li_x = [n / np.log(n) for n in x_classical]

ax.plot(x_classical, pi_x, 'b-', linewidth=2, label='π(x) (integer primes)')
ax.plot(x_classical, li_x, 'r--', linewidth=2, label='x/ln(x) (PNT)')

ax.set_xlabel('x')
ax.set_ylabel('Count')
ax.set_title('Classical Prime Number Theorem', fontsize=12, fontweight='bold')
ax.legend()
ax.grid(True, alpha=0.3)
ax.text(0.5, 0.15, 'Graph primes ↔ Integer primes\nΠ_G(ℓ) ~ q^ℓ/ℓ ↔ π(x) ~ x/ln(x)',
        transform=ax.transAxes, fontsize=10, ha='center',
        bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

plt.suptitle('Prime Cycles in Graphs: The Graph Prime Number Theorem',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_prime_cycles.png', dpi=150, bbox_inches='tight')
print("Saved viz_prime_cycles.png")
