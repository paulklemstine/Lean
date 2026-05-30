"""
Visualization: Modular Sieve Efficiency Across Bases

This script visualizes how effective the modular sieve (Theorem 1) is
at eliminating non-vampire candidates across different number bases.
The theoretical elimination rate is (base-2)/(base-1), and this plot
compares theory vs. empirical measurement.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def digits(n, base):
    if n == 0:
        return [0]
    result = []
    while n > 0:
        result.append(n % base)
        n //= base
    return result


def digit_bag(n, base):
    from collections import Counter
    return Counter(digits(n, base))


def modular_sieve(x, y, base):
    m = base - 1
    return (x * y) % m == (x + y) % m


def is_vampire(v, x, y, base):
    if v != x * y:
        return False
    return digit_bag(v, base) == digit_bag(x, base) + digit_bag(y, base)


bases = list(range(3, 25))
theoretical_rates = [(b - 2) / (b - 1) for b in bases]
empirical_rates = []
vampire_counts = []

for base in bases:
    total = 0
    sieve_eliminated = 0
    n_vampires = 0
    max_val = min(base**4, 5000)

    for v in range(base * base, max_val + 1):
        sqrt_v = int(v**0.5)
        for x in range(base, sqrt_v + 1):
            if v % x != 0:
                continue
            y = v // x
            if y < x:
                continue
            total += 1
            if not modular_sieve(x, y, base):
                sieve_eliminated += 1
            elif is_vampire(v, x, y, base):
                n_vampires += 1

    rate = sieve_eliminated / total if total > 0 else 0
    empirical_rates.append(rate)
    vampire_counts.append(n_vampires)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5.5))

# Plot 1: Sieve efficiency
ax1.plot(bases, theoretical_rates, 'r-', linewidth=2.5, label='Theory: (b−2)/(b−1)',
         marker='o', markersize=4)
ax1.plot(bases, empirical_rates, 'b--', linewidth=2, label='Empirical',
         marker='s', markersize=4)
ax1.fill_between(bases, theoretical_rates, empirical_rates, alpha=0.15, color='blue')
ax1.set_xlabel('Base b', fontsize=12)
ax1.set_ylabel('Elimination Rate', fontsize=12)
ax1.set_title('Modular Sieve Efficiency by Base', fontsize=13, fontweight='bold')
ax1.legend(fontsize=11)
ax1.grid(True, alpha=0.3)
ax1.set_ylim(0, 1.05)

# Plot 2: Vampire count by base
colors = plt.cm.viridis(np.linspace(0.2, 0.8, len(bases)))
ax2.bar(bases, vampire_counts, color=colors, edgecolor='black', linewidth=0.5)
ax2.set_xlabel('Base b', fontsize=12)
ax2.set_ylabel('Vampire Count (v ≤ b⁴ or 5000)', fontsize=12)
ax2.set_title('Vampire Numbers Found per Base', fontsize=13, fontweight='bold')
ax2.grid(True, alpha=0.3, axis='y')

for i, (b, count) in enumerate(zip(bases, vampire_counts)):
    if count > 0:
        ax2.text(b, count + 0.3, str(count), ha='center', va='bottom', fontsize=8)

plt.suptitle('The Modular Sieve: A Universal Filter for Digit-Preserving Multiplications',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_sieve_efficiency.png', dpi=150, bbox_inches='tight')
print("Saved viz_sieve_efficiency.png")
