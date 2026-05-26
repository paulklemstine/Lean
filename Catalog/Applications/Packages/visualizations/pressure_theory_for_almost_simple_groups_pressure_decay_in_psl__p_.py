#!/usr/bin/env python3
"""
Visualization: Pressure Decay in PSL₂(p)

Plots the subgroup family pressure of PSL₂(p) as a function of p,
showing the O(1/p) polynomial decay predicted by the entropy-energy
theorem. The plot demonstrates that pressure drops rapidly, meaning
random pairs generate the group with probability approaching 1.
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


def psl2_pressure(p):
    """Compute model pressure for PSL₂(p)."""
    n = p * (p * p - 1) // 2
    pressure = 0.0
    # Borel
    pressure += (p + 1) / ((p + 1) ** 2)
    if p >= 5:
        # Dihedral classes
        d1_count = p * (p + 1) // 2
        d1_index = p * (p - 1) // 2
        pressure += d1_count / (d1_index ** 2)
        d2_count = p * (p - 1) // 2
        d2_index = p * (p + 1) // 2
        pressure += d2_count / (d2_index ** 2)
    return pressure


primes = [p for p in range(3, 200) if is_prime(p)]
pressures = [psl2_pressure(p) for p in primes]
gen_probs = [1 - pr for pr in pressures]

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Pressure Theory for Almost Simple Groups: PSL₂(p)', 
             fontsize=16, fontweight='bold')

# Plot 1: Pressure decay (log scale)
ax1 = axes[0, 0]
ax1.semilogy(primes, pressures, 'bo-', markersize=4, linewidth=1, label='Pressure P(G,M)')
# Fit line C/p
p_arr = np.array(primes[2:], dtype=float)
C_fit = np.median([p * psl2_pressure(p) for p in primes[2:]])
ax1.semilogy(p_arr, C_fit / p_arr, 'r--', linewidth=2, label=f'C/p fit (C={C_fit:.2f})')
ax1.set_xlabel('Prime p', fontsize=12)
ax1.set_ylabel('Family Pressure', fontsize=12)
ax1.set_title('Pressure Decay (Log Scale)', fontsize=13)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

# Plot 2: Generation probability
ax2 = axes[0, 1]
ax2.plot(primes, gen_probs, 'gs-', markersize=4, linewidth=1)
ax2.axhline(y=1.0, color='gray', linestyle=':', alpha=0.5)
ax2.axhline(y=0.9, color='orange', linestyle='--', alpha=0.5, label='90% threshold')
ax2.set_xlabel('Prime p', fontsize=12)
ax2.set_ylabel('P_gen lower bound', fontsize=12)
ax2.set_title('Generation Probability Lower Bound', fontsize=13)
ax2.set_ylim(0, 1.05)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

# Plot 3: Pressure decomposition by class
ax3 = axes[1, 0]
borel_pressures = [1.0 / (p + 1) for p in primes]
dihedral_pressures = []
for p in primes:
    if p >= 5:
        d1 = (p * (p + 1) // 2) / ((p * (p - 1) // 2) ** 2)
        d2 = (p * (p - 1) // 2) / ((p * (p + 1) // 2) ** 2)
        dihedral_pressures.append(d1 + d2)
    else:
        dihedral_pressures.append(0)

ax3.semilogy(primes, borel_pressures, 'b^-', markersize=4, label='Borel class')
ax3.semilogy(primes, dihedral_pressures, 'rv-', markersize=4, label='Dihedral classes')
ax3.semilogy(primes, pressures, 'ko-', markersize=3, alpha=0.5, label='Total')
ax3.set_xlabel('Prime p', fontsize=12)
ax3.set_ylabel('Class Pressure', fontsize=12)
ax3.set_title('Thermodynamic Decomposition by Class', fontsize=13)
ax3.legend(fontsize=10)
ax3.grid(True, alpha=0.3)

# Plot 4: p * pressure (should be bounded = O(1))
ax4 = axes[1, 1]
p_times_pressure = [p * pr for p, pr in zip(primes, pressures)]
ax4.plot(primes, p_times_pressure, 'mo-', markersize=4, linewidth=1)
ax4.axhline(y=C_fit, color='red', linestyle='--', alpha=0.7, 
            label=f'Median = {C_fit:.3f}')
ax4.set_xlabel('Prime p', fontsize=12)
ax4.set_ylabel('p · Pressure(PSL₂(p))', fontsize=12)
ax4.set_title('Scaled Pressure (Testing O(1/p) Conjecture)', fontsize=13)
ax4.legend(fontsize=10)
ax4.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('pressure_decay.png', dpi=150, bbox_inches='tight')
print("Saved pressure_decay.png")
