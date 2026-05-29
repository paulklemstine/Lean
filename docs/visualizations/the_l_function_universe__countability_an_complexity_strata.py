"""
Visualization: Complexity Strata of the L-Function Universe

This script visualizes the entropy filtration of finite-description L-data.
It shows how the number of L-data objects grows with description length,
demonstrating the finiteness theorem: each stratum {dL ≤ B} is finite,
and the growth rate reveals the combinatorial structure of the L-data cosmos.
"""

import matplotlib.pyplot as plt
import numpy as np
from dataclasses import dataclass
from itertools import product as cartesian_product
from collections import defaultdict
from typing import Iterator
import math


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
by_dl = defaultdict(int)
by_deg_dl = defaultdict(lambda: defaultdict(int))

for x in enumerate_ldata(max_B):
    dl = x.description_length
    by_dl[dl] += 1
    by_deg_dl[x.degree][dl] += 1

dls = sorted(by_dl.keys())
counts = [by_dl[dl] for dl in dls]
cumulative = np.cumsum(counts)
log_counts = [math.log2(c) if c > 0 else 0 for c in counts]
log_cum = [math.log2(c) if c > 0 else 0 for c in cumulative]

# ─── Create figure ─────────────────────────────────────────────────────────

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle("The L-Function Universe: Complexity Strata",
             fontsize=16, fontweight='bold', y=0.98)

# Panel 1: Stratum sizes (bar chart)
ax1 = axes[0, 0]
colors = plt.cm.viridis(np.linspace(0.2, 0.9, len(dls)))
ax1.bar(dls, counts, color=colors, edgecolor='black', linewidth=0.5)
ax1.set_xlabel("Description Length (B)", fontsize=12)
ax1.set_ylabel("Number of L-data", fontsize=12)
ax1.set_title("Stratum Sizes: |{x : dL(x) = B}|", fontsize=13)
ax1.set_yscale('log')
for i, (dl, cnt) in enumerate(zip(dls, counts)):
    ax1.text(dl, cnt * 1.2, str(cnt), ha='center', va='bottom', fontsize=8)

# Panel 2: Cumulative growth (log scale)
ax2 = axes[0, 1]
ax2.plot(dls, cumulative, 'o-', color='darkblue', linewidth=2, markersize=6)
ax2.fill_between(dls, 1, cumulative, alpha=0.15, color='blue')
ax2.set_xlabel("Description Length Bound (B)", fontsize=12)
ax2.set_ylabel("Cumulative Count", fontsize=12)
ax2.set_title("Cumulative: |{x : dL(x) ≤ B}|", fontsize=13)
ax2.set_yscale('log')
ax2.grid(True, alpha=0.3)

# Panel 3: log₂ of stratum size (information content)
ax3 = axes[1, 0]
ax3.plot(dls, log_counts, 's-', color='crimson', linewidth=2, markersize=7)
ax3.plot(dls, log_cum, 'D-', color='darkgreen', linewidth=2, markersize=6, alpha=0.7)
ax3.set_xlabel("Description Length (B)", fontsize=12)
ax3.set_ylabel("log₂(count)", fontsize=12)
ax3.set_title("Information Content per Stratum", fontsize=13)
ax3.legend(["log₂(stratum size)", "log₂(cumulative)"], fontsize=10)
ax3.grid(True, alpha=0.3)

# Panel 4: Stacked by degree
ax4 = axes[1, 1]
degrees = sorted(by_deg_dl.keys())
bottom = np.zeros(len(dls))
cmap = plt.cm.Set2
for i, deg in enumerate(degrees):
    vals = [by_deg_dl[deg].get(dl, 0) for dl in dls]
    ax4.bar(dls, vals, bottom=bottom, label=f"deg={deg}",
            color=cmap(i / max(len(degrees), 1)), edgecolor='black', linewidth=0.3)
    bottom += np.array(vals)
ax4.set_xlabel("Description Length (B)", fontsize=12)
ax4.set_ylabel("Count", fontsize=12)
ax4.set_title("Strata Decomposed by Degree", fontsize=13)
ax4.legend(fontsize=9, loc='upper left')

plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.savefig("viz_complexity_strata.png", dpi=150, bbox_inches='tight')
print("Saved viz_complexity_strata.png")
