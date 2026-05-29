"""
Visualization: Growth Conjecture Test for L-Data Census

Tests the falsifiable conjecture that the number of finite-description
L-data with description length ≤ B grows at most polynomially in B
for fixed coefficient alphabets. Plots the growth curve alongside
polynomial and exponential reference curves for comparison.
"""

import matplotlib.pyplot as plt
import numpy as np
from dataclasses import dataclass
from itertools import product as cartesian_product
from collections import defaultdict
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


# ─── Compute growth data for multiple coefficient ranges ───────────────────

configs = [
    ("α = {0}", range(0, 1), (1,)),
    ("α = {0, 1}", range(0, 2), (-1, 1)),
    ("α = {-1, 0, 1}", range(-1, 2), (-1, 1)),
]

max_B = 7
results = {}

for label, cr, rns in configs:
    by_dl = defaultdict(int)
    for x in enumerate_ldata(max_B, cr, rns):
        by_dl[x.description_length] += 1

    dls = sorted(by_dl.keys())
    cumulative = []
    running = 0
    for dl in range(1, max_B + 1):
        running += by_dl.get(dl, 0)
        cumulative.append(running)
    results[label] = cumulative

# ─── Create figure ─────────────────────────────────────────────────────────

fig, axes = plt.subplots(1, 3, figsize=(18, 6))
fig.suptitle("Growth Conjecture: Is |{x : dL(x) ≤ B}| Polynomial in B?",
             fontsize=16, fontweight='bold', y=1.02)

Bs = np.arange(1, max_B + 1)

# Panel 1: Raw growth curves
ax1 = axes[0]
markers = ['o-', 's-', 'D-']
colors = ['#2196F3', '#FF9800', '#E91E63']
for i, (label, cum) in enumerate(results.items()):
    ax1.plot(Bs, cum, markers[i], color=colors[i], linewidth=2,
             markersize=7, label=label)
ax1.set_xlabel("Description Length Bound (B)", fontsize=12)
ax1.set_ylabel("Cumulative Count", fontsize=12)
ax1.set_title("Growth Curves", fontsize=13)
ax1.legend(fontsize=10)
ax1.set_yscale('log')
ax1.grid(True, alpha=0.3)

# Panel 2: Log-log plot with polynomial fit
ax2 = axes[1]
main_label = "α = {-1, 0, 1}"
cum = results[main_label]
log_B = np.log(Bs.astype(float))
log_cum = np.array([math.log(max(c, 1)) for c in cum])

# Fit polynomial (in log-log)
coeffs = np.polyfit(log_B[1:], log_cum[1:], 1)
fit_line = np.polyval(coeffs, log_B)

ax2.plot(log_B, log_cum, 'D-', color='#E91E63', linewidth=2,
         markersize=7, label='Data')
ax2.plot(log_B, fit_line, '--', color='gray', linewidth=2,
         label=f'Fit: slope={coeffs[0]:.2f}')
ax2.set_xlabel("log(B)", fontsize=12)
ax2.set_ylabel("log(cumulative count)", fontsize=12)
ax2.set_title(f"Log-Log Plot ({main_label})", fontsize=13)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)
ax2.text(0.05, 0.95, f"Power law exponent ≈ {coeffs[0]:.2f}",
         transform=ax2.transAxes, fontsize=11, va='top',
         bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

# Panel 3: Successive ratios
ax3 = axes[2]
for i, (label, cum) in enumerate(results.items()):
    ratios = []
    for j in range(1, len(cum)):
        if cum[j-1] > 0:
            ratios.append(cum[j] / cum[j-1])
        else:
            ratios.append(0)
    ax3.plot(Bs[1:], ratios, markers[i], color=colors[i], linewidth=2,
             markersize=7, label=label)

ax3.axhline(y=1, color='gray', linestyle=':', alpha=0.5)
ax3.set_xlabel("Description Length Bound (B)", fontsize=12)
ax3.set_ylabel("Ratio: count(B) / count(B-1)", fontsize=12)
ax3.set_title("Successive Growth Ratios", fontsize=13)
ax3.legend(fontsize=10)
ax3.grid(True, alpha=0.3)
ax3.text(0.05, 0.95,
         "Stabilizing ratio → polynomial growth\n"
         "Increasing ratio → super-polynomial",
         transform=ax3.transAxes, fontsize=9, va='top',
         bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.5))

plt.tight_layout()
plt.savefig("viz_growth_conjecture.png", dpi=150, bbox_inches='tight')
print("Saved viz_growth_conjecture.png")
