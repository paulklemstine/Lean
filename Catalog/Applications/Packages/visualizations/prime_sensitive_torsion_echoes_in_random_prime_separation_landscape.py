#!/usr/bin/env python3
"""
Visualization 3: Prime Separation Landscape

Shows how the torsion echo difference |echo_p - echo_q| varies across
different Smith invariant configurations. Each point represents a randomly
generated set of Smith invariant factors, and the color/size encodes the
degree of prime separation. This visualizes the "arithmetic landscape"
where different primes see fundamentally different torsion signatures.
"""

import numpy as np
import matplotlib.pyplot as plt


def padic_valuation(p: int, n: int) -> int:
    if n == 0 or p < 2:
        return 0
    n = abs(n)
    v = 0
    while n % p == 0:
        n //= p
        v += 1
    return v


def torsion_echo(p, factors):
    return sum(padic_valuation(p, d) for d in factors)


# Generate random Smith invariant factor sets
rng = np.random.default_rng(2024)
n_configs = 500

echo_2 = []
echo_3 = []
echo_5 = []
total_order = []

for _ in range(n_configs):
    n_factors = rng.integers(1, 6)
    # Generate factors as products of small prime powers
    factors = []
    for _ in range(n_factors):
        f = 1
        for p in [2, 3, 5, 7]:
            exp = rng.integers(0, 4)
            f *= p ** exp
        if f > 1:
            factors.append(f)
    if not factors:
        factors = [1]

    echo_2.append(torsion_echo(2, factors))
    echo_3.append(torsion_echo(3, factors))
    echo_5.append(torsion_echo(5, factors))
    total_order.append(sum(np.log(f) for f in factors if f > 1))

echo_2 = np.array(echo_2)
echo_3 = np.array(echo_3)
echo_5 = np.array(echo_5)
total_order = np.array(total_order)

# Create figure with two panels
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Panel 1: echo_2 vs echo_3, colored by echo_5
scatter1 = ax1.scatter(echo_2 + rng.uniform(-0.15, 0.15, len(echo_2)),
                       echo_3 + rng.uniform(-0.15, 0.15, len(echo_3)),
                       c=echo_5, cmap='YlOrRd', s=30, alpha=0.6,
                       edgecolors='gray', linewidths=0.3)
ax1.set_xlabel('echo₂ (2-adic torsion)', fontsize=12)
ax1.set_ylabel('echo₃ (3-adic torsion)', fontsize=12)
ax1.set_title('Prime Separation: echo₂ vs echo₃\n(color = echo₅)', fontsize=13,
              fontweight='bold')
ax1.plot([0, max(echo_2)], [0, max(echo_2)], 'k--', alpha=0.3, label='echo₂ = echo₃')
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.2)
plt.colorbar(scatter1, ax=ax1, label='echo₅')

# Panel 2: Separation measure
separation = np.abs(echo_2 - echo_3) + np.abs(echo_2 - echo_5) + np.abs(echo_3 - echo_5)
scatter2 = ax2.scatter(total_order, separation + rng.uniform(-0.15, 0.15, len(separation)),
                       c=separation, cmap='viridis', s=30, alpha=0.6,
                       edgecolors='gray', linewidths=0.3)
ax2.set_xlabel('log(total order)', fontsize=12)
ax2.set_ylabel('Total prime separation\n|Δ₂₃| + |Δ₂₅| + |Δ₃₅|', fontsize=12)
ax2.set_title('Separation Grows with Arithmetic Complexity', fontsize=13,
              fontweight='bold')
ax2.grid(True, alpha=0.2)
plt.colorbar(scatter2, ax=ax2, label='Separation measure')

# Summary statistics
n_separated = sum(1 for s in separation if s > 0)
frac = n_separated / len(separation) * 100
fig.text(0.5, -0.02,
         f'{frac:.0f}% of random Smith configurations are prime-separated '
         f'(n = {n_configs})',
         ha='center', fontsize=12, style='italic')

plt.tight_layout()
plt.savefig('viz_prime_separation.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_prime_separation.png")
