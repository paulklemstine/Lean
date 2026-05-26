#!/usr/bin/env python3
"""
Visualization: Thermodynamic Decomposition of Pressure

Shows how the total subgroup pressure decomposes into contributions
from different subgroup classes (Borel, dihedral, exceptional).
This is the visual counterpart of the formal subadditivity theorem
familyPressure_biUnion_le, demonstrating that each Aschbacher class
acts as an independent "species" in the thermodynamic partition.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def is_prime(n):
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0: return False
        i += 6
    return True


def psl2_class_pressures(p):
    """Return dict of class name → pressure for PSL₂(p)."""
    n = p * (p * p - 1) // 2
    result = {}
    result['Borel'] = (p + 1) / ((p + 1) ** 2)
    if p >= 5:
        d1_count = p * (p + 1) // 2
        d1_index = p * (p - 1) // 2
        result['Split Cartan'] = d1_count / (d1_index ** 2)
        d2_count = p * (p - 1) // 2
        d2_index = p * (p + 1) // 2
        result['Non-split Cartan'] = d2_count / (d2_index ** 2)
    exceptional = 0
    if p >= 5 and n % 24 == 0:
        exceptional += (n // 24) / ((n // 12) ** 2)
    if p >= 7 and p % 8 in (1, 7) and n % 48 == 0:
        exceptional += (n // 48) / ((n // 24) ** 2)
    if p >= 11 and p % 5 in (1, 4) and n % 120 == 0:
        exceptional += (n // 120) / ((n // 60) ** 2)
    if exceptional > 0:
        result['Exceptional'] = exceptional
    return result


primes = [p for p in range(3, 101) if is_prime(p)]

fig, axes = plt.subplots(1, 2, figsize=(14, 6))
fig.suptitle('Thermodynamic Decomposition of Subgroup Pressure',
             fontsize=15, fontweight='bold')

# Plot 1: Stacked area chart
ax1 = axes[0]
borel = []
split_cartan = []
nonsplit_cartan = []
exceptional = []

for p in primes:
    classes = psl2_class_pressures(p)
    borel.append(classes.get('Borel', 0))
    split_cartan.append(classes.get('Split Cartan', 0))
    nonsplit_cartan.append(classes.get('Non-split Cartan', 0))
    exceptional.append(classes.get('Exceptional', 0))

ax1.stackplot(primes, borel, split_cartan, nonsplit_cartan, exceptional,
              labels=['Borel', 'Split Cartan', 'Non-split Cartan', 'Exceptional'],
              colors=['#2196F3', '#FF5722', '#4CAF50', '#9C27B0'],
              alpha=0.8)
ax1.set_xlabel('Prime p', fontsize=12)
ax1.set_ylabel('Pressure Contribution', fontsize=12)
ax1.set_title('Pressure by Subgroup Class', fontsize=13)
ax1.legend(loc='upper right', fontsize=9)
ax1.grid(True, alpha=0.3)

# Plot 2: Relative contributions (percentage)
ax2 = axes[1]
totals = [b + s + n + e for b, s, n, e in 
          zip(borel, split_cartan, nonsplit_cartan, exceptional)]
borel_pct = [100 * b / t if t > 0 else 0 for b, t in zip(borel, totals)]
split_pct = [100 * s / t if t > 0 else 0 for s, t in zip(split_cartan, totals)]
nonsplit_pct = [100 * n / t if t > 0 else 0 for n, t in zip(nonsplit_cartan, totals)]
except_pct = [100 * e / t if t > 0 else 0 for e, t in zip(exceptional, totals)]

ax2.stackplot(primes, borel_pct, split_pct, nonsplit_pct, except_pct,
              labels=['Borel', 'Split Cartan', 'Non-split Cartan', 'Exceptional'],
              colors=['#2196F3', '#FF5722', '#4CAF50', '#9C27B0'],
              alpha=0.8)
ax2.set_xlabel('Prime p', fontsize=12)
ax2.set_ylabel('Percentage of Total Pressure', fontsize=12)
ax2.set_title('Relative Class Contributions', fontsize=13)
ax2.set_ylim(0, 100)
ax2.legend(loc='center right', fontsize=9)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('pressure_decomposition.png', dpi=150, bbox_inches='tight')
print("Saved pressure_decomposition.png")
