"""
Visualization: Conductor Landscape of the L-Function Universe

This script creates a heatmap showing the distribution of L-data objects
across the degree × conductor plane, revealing the geometric structure
of the arithmetic L-data cosmos. The density pattern reflects how
combinatorial complexity concentrates in different regions of parameter space.
"""

import matplotlib.pyplot as plt
import numpy as np
from dataclasses import dataclass
from itertools import product as cartesian_product
from collections import defaultdict


# ─── Self-contained L-data definitions ─────────────────────────────────────

@dataclass(frozen=True)
class DiscreteEulerFactor:
    coeffs: tuple

    @property
    def degree(self):
        return len(self.coeffs)


@dataclass(frozen=True)
class FiniteDescriptionLData:
    degree: int
    conductor: int
    root_number: int
    unramified_template: DiscreteEulerFactor
    bad_primes: tuple
    ramified_factors: tuple

    @property
    def num_bad_primes(self):
        return len(self.bad_primes)

    @property
    def max_bad_prime(self):
        return max(self.bad_primes) if self.bad_primes else 0

    @property
    def description_length(self):
        return self.degree + self.conductor + self.num_bad_primes + self.max_bad_prime + 1

    @property
    def arithmetic_complexity(self):
        return self.degree * (self.num_bad_primes + 1) + self.conductor


def enum_factors(degree, cr):
    if degree == 0:
        return [DiscreteEulerFactor(())]
    return [DiscreteEulerFactor(c) for c in cartesian_product(cr, repeat=degree)]


def enumerate_ldata(B, cr=range(-1, 2), rns=(-1, 1)):
    if B < 1:
        return
    for total in range(B):
        for d in range(total + 1):
            templates = enum_factors(d, cr)
            for c in range(total - d + 1):
                for nb in range(total - d - c + 1):
                    mbp = total - d - c - nb
                    for tmpl in templates:
                        for rn in rns:
                            if nb == 0:
                                yield FiniteDescriptionLData(d, c, rn, tmpl, (), ())
                            else:
                                rf_list = enum_factors(d, cr)
                                for bpl in cartesian_product(range(mbp + 1), repeat=nb):
                                    for rf in cartesian_product(rf_list, repeat=nb):
                                        yield FiniteDescriptionLData(
                                            d, c, rn, tmpl, tuple(bpl), tuple(rf))


# ─── Compute data ──────────────────────────────────────────────────────────

max_B = 6
grid = defaultdict(int)
ac_grid = defaultdict(int)

for x in enumerate_ldata(max_B):
    grid[(x.degree, x.conductor)] += 1
    ac_grid[(x.degree, x.num_bad_primes)] += 1

max_d = max(k[0] for k in grid) if grid else 0
max_c = max(k[1] for k in grid) if grid else 0
max_nb = max(k[1] for k in ac_grid) if ac_grid else 0

# Build matrices
mat1 = np.zeros((max_d + 1, max_c + 1))
for (d, c), cnt in grid.items():
    mat1[d, c] = cnt

mat2 = np.zeros((max_d + 1, max_nb + 1))
for (d, nb), cnt in ac_grid.items():
    mat2[d, nb] = cnt

# ─── Create figure ─────────────────────────────────────────────────────────

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(15, 6))
fig.suptitle("The Conductor Landscape of L-Data",
             fontsize=16, fontweight='bold', y=1.02)

# Heatmap 1: Degree × Conductor
log_mat1 = np.log10(mat1 + 1)
im1 = ax1.imshow(log_mat1, aspect='auto', cmap='YlOrRd',
                 origin='lower', interpolation='nearest')
ax1.set_xlabel("Conductor (N)", fontsize=12)
ax1.set_ylabel("Degree (d)", fontsize=12)
ax1.set_title("log₁₀(count + 1) by Degree × Conductor", fontsize=13)
cbar1 = plt.colorbar(im1, ax=ax1, shrink=0.8)
cbar1.set_label("log₁₀(count + 1)")

# Annotate cells
for d in range(max_d + 1):
    for c in range(max_c + 1):
        val = int(mat1[d, c])
        if val > 0:
            color = 'white' if log_mat1[d, c] > log_mat1.max() * 0.6 else 'black'
            ax1.text(c, d, str(val), ha='center', va='center',
                     fontsize=7, color=color, fontweight='bold')

# Heatmap 2: Degree × Number of Bad Primes
log_mat2 = np.log10(mat2 + 1)
im2 = ax2.imshow(log_mat2, aspect='auto', cmap='YlGnBu',
                 origin='lower', interpolation='nearest')
ax2.set_xlabel("Number of Bad Primes", fontsize=12)
ax2.set_ylabel("Degree (d)", fontsize=12)
ax2.set_title("log₁₀(count + 1) by Degree × #Bad Primes", fontsize=13)
cbar2 = plt.colorbar(im2, ax=ax2, shrink=0.8)
cbar2.set_label("log₁₀(count + 1)")

for d in range(max_d + 1):
    for nb in range(max_nb + 1):
        val = int(mat2[d, nb])
        if val > 0:
            color = 'white' if log_mat2[d, nb] > log_mat2.max() * 0.6 else 'black'
            ax2.text(nb, d, str(val), ha='center', va='center',
                     fontsize=7, color=color, fontweight='bold')

plt.tight_layout()
plt.savefig("viz_conductor_landscape.png", dpi=150, bbox_inches='tight')
print("Saved viz_conductor_landscape.png")
