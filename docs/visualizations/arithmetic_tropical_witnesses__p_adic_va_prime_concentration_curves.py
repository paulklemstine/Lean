#!/usr/bin/env python3
"""
Visualization: Prime Concentration Curves

Shows how the p-adic tropical witness weight distributes across primes
for DPP polynomials with varying kernel structures. Illustrates the
"sparse prime domination" phenomenon: for many natural polynomials,
a small number of primes capture most of the arithmetic complexity.
"""

import math
from fractions import Fraction
import numpy as np
import matplotlib.pyplot as plt


# ─── Inlined core functions ─────────────────────────────────────────────────

def padic_val(p, n):
    if n == 0 or p < 2:
        return 0
    n = abs(n)
    v = 0
    while n % p == 0:
        v += 1
        n //= p
    return v

def padic_val_rat(p, c):
    if c == 0:
        return 0
    return padic_val(p, c.numerator) - padic_val(p, c.denominator)

def padic_coeff_weight(p, c):
    return abs(padic_val_rat(p, c))


class Poly:
    def __init__(self, coeffs=None):
        self.coeffs = {}
        if coeffs:
            for exp, c in coeffs.items():
                c = Fraction(c)
                if c != 0:
                    self.coeffs[exp] = c

    def weight(self, p):
        return sum(padic_coeff_weight(p, c) for c in self.coeffs.values())


def make_dpp_diagonal(weights):
    n = len(weights)
    coeffs = {}
    for subset in range(1 << n):
        exp = tuple(1 if (subset >> i) & 1 else 0 for i in range(n))
        c = Fraction(1)
        for i in range(n):
            if (subset >> i) & 1:
                c *= weights[i]
        if c != 0:
            coeffs[exp] = c
    return Poly(coeffs)


# ─── Build DPP examples with different prime structures ─────────────────────

test_primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31]

examples = {
    "Harmonic: 1/k": [Fraction(1, k) for k in range(1, 6)],
    "Powers of 2: 1/2^k": [Fraction(1, 2**k) for k in range(1, 6)],
    "Mixed: k/(k+1)": [Fraction(k, k+1) for k in range(1, 6)],
    "Primorial: 1/p#": [Fraction(1, 2), Fraction(1, 6), Fraction(1, 30),
                          Fraction(1, 210)],
    "Fibonacci ratios": [Fraction(1, 1), Fraction(1, 2), Fraction(2, 3),
                          Fraction(3, 5), Fraction(5, 8)],
}

# ─── Create figure ──────────────────────────────────────────────────────────

fig, axes = plt.subplots(2, 3, figsize=(16, 10))
axes = axes.flatten()

colors = plt.cm.Set2(np.linspace(0, 1, len(examples)))

# Plot 1-5: Individual witness profiles
for idx, (name, weights) in enumerate(examples.items()):
    ax = axes[idx]
    poly = make_dpp_diagonal(weights)
    
    witness_vals = [poly.weight(p) for p in test_primes]
    
    bars = ax.bar(range(len(test_primes)), witness_vals,
                  color=colors[idx], edgecolor="black", linewidth=0.5)
    ax.set_xticks(range(len(test_primes)))
    ax.set_xticklabels([str(p) for p in test_primes], fontsize=8)
    ax.set_xlabel("Prime q", fontsize=9)
    ax.set_ylabel("$W^{(q)}$", fontsize=10)
    ax.set_title(f"{name}", fontsize=11, fontweight="bold")
    
    # Highlight the dominant prime
    if witness_vals:
        max_idx = np.argmax(witness_vals)
        bars[max_idx].set_edgecolor("red")
        bars[max_idx].set_linewidth(2)

# Plot 6: Cumulative concentration curves
ax = axes[5]
for idx, (name, weights) in enumerate(examples.items()):
    poly = make_dpp_diagonal(weights)
    witness_vals = sorted([poly.weight(p) for p in test_primes], reverse=True)
    total = sum(witness_vals)
    if total == 0:
        continue
    cumulative = np.cumsum(witness_vals) / total
    ax.plot(range(1, len(cumulative) + 1), cumulative,
            marker="o", markersize=4, label=name.split(":")[0],
            color=colors[idx], linewidth=2)

ax.set_xlabel("Number of primes (sorted by weight)", fontsize=10)
ax.set_ylabel("Cumulative fraction of total weight", fontsize=10)
ax.set_title("Prime Concentration\nCurves", fontsize=11, fontweight="bold")
ax.axhline(y=0.9, color="gray", linestyle="--", alpha=0.5, label="90% threshold")
ax.legend(fontsize=7, loc="lower right")
ax.set_ylim(0, 1.05)
ax.grid(True, alpha=0.3)

plt.suptitle("p-Adic Tropical Witness: Prime Concentration Analysis",
             fontsize=14, fontweight="bold", y=1.02)
plt.tight_layout()
plt.savefig("prime_concentration.png", dpi=150, bbox_inches="tight")
plt.close()
print("Saved: prime_concentration.png")
