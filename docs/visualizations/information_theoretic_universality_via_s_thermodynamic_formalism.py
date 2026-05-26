"""
Visualization: Thermodynamic Analogy for Subgroup Entropy

Maps the subgroup weight distribution to a statistical mechanical
system, showing the partition function, free energy, and the
Gibbs identity H = <I> (entropy equals expected self-information).

This creates a visual bridge between algebraic combinatorics and
thermodynamic formalism.
"""

import math
import matplotlib.pyplot as plt
import numpy as np


def divisors(n):
    divs = []
    for i in range(1, int(n**0.5) + 1):
        if n % i == 0:
            divs.append(i)
            if i != n // i:
                divs.append(n // i)
    return sorted(divs)


def compute_thermodynamics(indices):
    weights = [1.0 / (i ** 2) for i in indices]
    Z = sum(weights)
    probs = [w / Z for w in weights]
    entropy = -sum(p * math.log(p) for p in probs if p > 0)
    free_energy = -math.log(Z)
    energies = [2 * math.log(i) for i in indices]
    avg_energy = sum(p * e for p, e in zip(probs, energies))
    self_infos = [-math.log(p) for p in probs]
    return {
        'Z': Z, 'F': free_energy, 'H': entropy,
        'avg_E': avg_energy, 'probs': probs,
        'energies': energies, 'self_infos': self_infos,
        'indices': indices
    }


fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle("Thermodynamic Formalism for Subgroup Ensembles",
             fontsize=14, fontweight='bold')

# Plot 1: Free energy vs group order
ax1 = axes[0, 0]
ns = list(range(2, 81))
free_energies = []
entropies = []
avg_energies = []

for n in ns:
    td = compute_thermodynamics(divisors(n))
    free_energies.append(td['F'])
    entropies.append(td['H'])
    avg_energies.append(td['avg_E'])

ax1.plot(ns, free_energies, 'b-', alpha=0.7, label='Free energy F = -ln Z')
ax1.plot(ns, entropies, 'r-', alpha=0.7, label='Entropy H')
ax1.plot(ns, avg_energies, 'g-', alpha=0.7, label='Avg energy ⟨E⟩')
ax1.set_xlabel('Group order n')
ax1.set_ylabel('Value')
ax1.set_title('Thermodynamic Quantities vs Group Order')
ax1.legend(fontsize=8)
ax1.grid(True, alpha=0.3)

# Plot 2: Helmholtz relation F = <E> - H
ax2 = axes[0, 1]
helmholtz_check = [avg_energies[i] - entropies[i] for i in range(len(ns))]
ax2.scatter(free_energies, helmholtz_check, c='purple', s=15, alpha=0.6)
diag = np.linspace(min(free_energies), max(free_energies), 100)
ax2.plot(diag, diag, 'r--', linewidth=1, label='F = ⟨E⟩ - H (exact)')
ax2.set_xlabel('Free energy F')
ax2.set_ylabel('⟨E⟩ - H')
ax2.set_title('Helmholtz Relation Verification')
ax2.legend()
ax2.grid(True, alpha=0.3)

# Plot 3: Energy spectrum for Z/60Z
ax3 = axes[1, 0]
td60 = compute_thermodynamics(divisors(60))
indices = td60['indices']
energies = td60['energies']
probs = td60['probs']

colors = plt.cm.coolwarm(np.array(probs) / max(probs))
bars = ax3.barh(range(len(indices)), energies, color=colors, alpha=0.8)
ax3.set_yticks(range(len(indices)))
ax3.set_yticklabels([f'[G:H]={i}' for i in indices], fontsize=7)
ax3.set_xlabel('Energy E(H) = 2 ln[G:H]')
ax3.set_title('Energy Spectrum of Z/60Z (color = probability)')
ax3.invert_yaxis()

# Plot 4: Gibbs identity H = <I>
ax4 = axes[1, 1]
gibbs_H = []
gibbs_EI = []
for n in ns:
    td = compute_thermodynamics(divisors(n))
    gibbs_H.append(td['H'])
    gibbs_EI.append(sum(p * si for p, si in zip(td['probs'], td['self_infos'])))

ax4.scatter(gibbs_H, gibbs_EI, c='teal', s=15, alpha=0.6)
diag2 = np.linspace(0, max(gibbs_H), 100)
ax4.plot(diag2, diag2, 'r--', linewidth=1, label='H = E[I] (Gibbs identity)')
ax4.set_xlabel('Shannon entropy H')
ax4.set_ylabel('Expected self-information E[I]')
ax4.set_title('Gibbs Identity Verification')
ax4.legend()
ax4.set_aspect('equal')
ax4.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('thermodynamics.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved thermodynamics.png")
