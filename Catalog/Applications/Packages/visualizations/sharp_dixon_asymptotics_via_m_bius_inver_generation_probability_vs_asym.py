"""
Visualization: Generation Probability vs Asymptotic Approximations

This script plots the exact probability P_n that two random elements generate S_n,
compared against the asymptotic approximations 1 - 1/n and 1 - 1/n - 1/n².
It demonstrates how the Möbius inversion formula's dominant terms capture the behavior.
"""

import matplotlib.pyplot as plt
import numpy as np
from itertools import permutations
from math import factorial
from fractions import Fraction


def compose(p, q):
    return tuple(p[q[i]] for i in range(len(p)))

def inverse(p):
    n = len(p)
    inv = [0] * n
    for i in range(n):
        inv[p[i]] = i
    return tuple(inv)

def identity(n):
    return tuple(range(n))

def closure(generators, n):
    elements = {identity(n)}
    for g in generators:
        elements.add(g)
        elements.add(inverse(g))
    changed = True
    while changed:
        changed = False
        new = set()
        for a in elements:
            for b in elements:
                c = compose(a, b)
                if c not in elements and c not in new:
                    new.add(c)
                    changed = True
        elements |= new
    return frozenset(elements)

def compute_gen_prob(n):
    all_perms = list(permutations(range(n)))
    sn = frozenset(all_perms)
    total = len(all_perms) ** 2
    gen_count = sum(1 for s in all_perms for t in all_perms if closure([s, t], n) == sn)
    return Fraction(gen_count, total)

# Compute exact probabilities for small n
ns = [2, 3, 4, 5]
exact_probs = {}
for n in ns:
    exact_probs[n] = compute_gen_prob(n)
    print(f"S_{n}: P = {exact_probs[n]} = {float(exact_probs[n]):.6f}")

# Create figure with two subplots
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Plot 1: Probabilities and approximations
n_range = np.array(ns, dtype=float)
exact_vals = [float(exact_probs[n]) for n in ns]
approx1 = [1 - 1/n for n in ns]
approx2 = [1 - 1/n - 1/n**2 for n in ns]

# Extended range for asymptotic curves
n_ext = np.linspace(2, 10, 100)
approx1_ext = 1 - 1/n_ext
approx2_ext = 1 - 1/n_ext - 1/n_ext**2

ax1.plot(n_ext, approx1_ext, 'b--', alpha=0.5, label='$1 - 1/n$')
ax1.plot(n_ext, approx2_ext, 'r--', alpha=0.5, label='$1 - 1/n - 1/n^2$')
ax1.scatter(ns, exact_vals, c='black', s=100, zorder=5, label='Exact $P_n$')
ax1.scatter(ns, approx1, c='blue', s=50, marker='s', zorder=4, alpha=0.7)
ax1.scatter(ns, approx2, c='red', s=50, marker='^', zorder=4, alpha=0.7)

ax1.set_xlabel('$n$', fontsize=14)
ax1.set_ylabel('$P_n$', fontsize=14)
ax1.set_title('Generation Probability in $S_n$', fontsize=15)
ax1.legend(fontsize=12)
ax1.grid(True, alpha=0.3)
ax1.set_xlim(1.5, 6)
ax1.set_ylim(0.4, 1.05)

# Plot 2: Log-scale errors
errors1 = [abs(float(exact_probs[n]) - (1 - 1/n)) for n in ns]
errors2 = [abs(float(exact_probs[n]) - (1 - 1/n - 1/n**2)) for n in ns]

ax2.semilogy(ns, errors1, 'bs-', markersize=8, label='$|P_n - (1-1/n)|$')
ax2.semilogy(ns, errors2, 'r^-', markersize=8, label='$|P_n - (1-1/n-1/n^2)|$')

# Reference lines
n_ref = np.array(ns, dtype=float)
ax2.semilogy(n_ref, 1/n_ref**2, 'b:', alpha=0.4, label='$1/n^2$ reference')
ax2.semilogy(n_ref, 1/n_ref**3, 'r:', alpha=0.4, label='$1/n^3$ reference')

ax2.set_xlabel('$n$', fontsize=14)
ax2.set_ylabel('Approximation Error', fontsize=14)
ax2.set_title('Asymptotic Convergence (log scale)', fontsize=15)
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('generation_probability.png', dpi=150, bbox_inches='tight')
plt.close()
print("\nSaved: generation_probability.png")
