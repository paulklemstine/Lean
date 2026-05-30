#!/usr/bin/env python3
"""
Visualization 3: Hyperbolic Prime Counting Function

Plots the hyperbolic prime counting function π_H(R) against the
conjectured asymptotic R²/(2 log R), testing the Hyperbolic Prime
Number Theorem conjecture.
"""

import numpy as np
import matplotlib.pyplot as plt


def mobius_map(a, z):
    return (z - a) / (1 - np.conj(a) * z)


def hyp_norm(z):
    r = abs(z)
    if r >= 1:
        return float('inf')
    if r < 1e-15:
        return 0.0
    return np.log((1 + r) / (1 - r)) / 2


def generate_lattice(generators, depth=6):
    points = {0j}
    frontier = {0j}
    for d in range(depth):
        new_frontier = set()
        for z in frontier:
            for g in generators:
                w = mobius_map(g, z)
                if abs(w) < 0.99999:
                    w_key = round(w.real, 9) + 1j * round(w.imag, 9)
                    if w_key not in points:
                        points.add(w_key)
                        new_frontier.add(w_key)
        frontier = new_frontier
        if not frontier:
            break
    return list(points)


def is_prime(z, generators):
    if abs(z) < 1e-10:
        return False
    for g1 in generators:
        for g2 in generators:
            if abs(mobius_map(g1, g2) - z) < 1e-7:
                return False
    return True


# Generate a large lattice
generators = [0.5, 0.3j, -0.4 + 0.2j, 0.2 - 0.3j, -0.35 - 0.15j]
print("Generating lattice...")
points = generate_lattice(generators, depth=7)
print(f"Generated {len(points)} points")

# Compute hyperbolic norms
norms = [(z, hyp_norm(z)) for z in points if abs(z) > 1e-10]
norms.sort(key=lambda x: x[1])

# Identify primes
prime_norms = [hn for z, hn in norms if is_prime(z, generators)]
prime_norms.sort()

# Compute counting functions
R_values = np.linspace(0.1, max(hn for _, hn in norms) * 0.95, 200)
pi_H = np.array([sum(1 for pn in prime_norms if pn <= R) for R in R_values])
N_total = np.array([sum(1 for _, hn in norms if hn <= R) for R in R_values])

# Conjectured asymptotic
with np.errstate(divide='ignore', invalid='ignore'):
    asymptotic = R_values**2 / (2 * np.log(R_values))
    asymptotic = np.where(np.isfinite(asymptotic) & (asymptotic > 0), asymptotic, 0)

fig, axes = plt.subplots(2, 2, figsize=(14, 11))

# Top left: π_H(R) vs R
ax1 = axes[0, 0]
ax1.plot(R_values, pi_H, 'crimson', linewidth=2, label='π_H(R) (actual)')
ax1.plot(R_values, asymptotic, 'blue', linewidth=1.5, linestyle='--',
         label='R²/(2 log R) (conjectured)')
ax1.set_xlabel('Hyperbolic radius R', fontsize=12)
ax1.set_ylabel('Count', fontsize=12)
ax1.set_title('Hyperbolic Prime Counting Function', fontsize=13, fontweight='bold')
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

# Top right: N(R) total counting function
ax2 = axes[0, 1]
ax2.plot(R_values, N_total, 'darkgreen', linewidth=2, label='N(R) total')
ax2.plot(R_values, pi_H, 'crimson', linewidth=1.5, label='π_H(R) primes')
ax2.set_xlabel('Hyperbolic radius R', fontsize=12)
ax2.set_ylabel('Count', fontsize=12)
ax2.set_title('Total vs Prime Counting Functions', fontsize=13, fontweight='bold')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

# Bottom left: ratio π_H(R) / (R²/(2 log R))
ax3 = axes[1, 0]
with np.errstate(divide='ignore', invalid='ignore'):
    ratio = np.where(asymptotic > 0, pi_H / asymptotic, 0)
    valid = (asymptotic > 0) & (R_values > 0.5)
ax3.plot(R_values[valid], ratio[valid], 'purple', linewidth=2)
ax3.axhline(y=1, color='black', linestyle='--', alpha=0.5, label='ratio = 1')
ax3.set_xlabel('Hyperbolic radius R', fontsize=12)
ax3.set_ylabel('π_H(R) / [R²/(2 log R)]', fontsize=12)
ax3.set_title('Ratio Test for Hyperbolic PNT Conjecture', fontsize=13, fontweight='bold')
ax3.legend(fontsize=10)
ax3.grid(True, alpha=0.3)
ax3.set_ylim(0, max(ratio[valid]) * 1.2 if np.any(valid) else 5)

# Bottom right: prime density π_H(R)/N(R)
ax4 = axes[1, 1]
with np.errstate(divide='ignore', invalid='ignore'):
    density = np.where(N_total > 0, pi_H / N_total, 0)
    valid_d = N_total > 0
ax4.plot(R_values[valid_d], density[valid_d], 'darkorange', linewidth=2)
ax4.set_xlabel('Hyperbolic radius R', fontsize=12)
ax4.set_ylabel('π_H(R) / N(R)', fontsize=12)
ax4.set_title('Hyperbolic Prime Density', fontsize=13, fontweight='bold')
ax4.grid(True, alpha=0.3)

# Summary stats
total_primes = len(prime_norms)
total_points = len(norms)
fig.suptitle(f'Hyperbolic Prime Number Theorem — {total_primes} primes among '
             f'{total_points} lattice points',
             fontsize=14, fontweight='bold', y=1.01)

plt.tight_layout()
plt.savefig('viz_prime_counting.png', dpi=150, bbox_inches='tight')
print(f"Saved prime counting visualization: {total_primes} primes / {total_points} points")
