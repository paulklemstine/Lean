#!/usr/bin/env python3
"""
Visualization: Primewise Witness Profile Heatmap

Visualizes the p-adic tropical witness profiles of several test polynomials
as a heatmap, showing how arithmetic complexity concentrates at different primes.
This is the core visual artifact of arithmetic tropical witness theory.
"""

import math
from fractions import Fraction
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors


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

    def height(self):
        return sum(math.log(max(abs(c.numerator), c.denominator))
                   for c in self.coeffs.values())


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


# ─── Build test polynomials ─────────────────────────────────────────────────

polys = {}

# 1. Harmonic DPP
polys["DPP\n(1/2,2/3,3/5)"] = make_dpp_diagonal(
    [Fraction(1, 2), Fraction(2, 3), Fraction(3, 5)]
)

# 2. Power-of-2 polynomial
coeffs = {}
for i in range(4):
    exp = tuple(1 if j == i else 0 for j in range(4))
    coeffs[exp] = Fraction(2 ** (5 * (i + 1)))
polys["Powers\nof 2"] = Poly(coeffs)

# 3. Mixed arithmetic
coeffs = {}
for i in range(4):
    for j in range(4):
        if i != j:
            exp = tuple(1 if k in (i, j) else 0 for k in range(4))
            coeffs[exp] = Fraction((2**i) * (3**j), (5**(i+j)) * 7)
polys["Mixed\n2,3,5,7"] = Poly(coeffs)

# 4. Unit poly ({2,3}-units)
polys["{2,3}\nunits"] = Poly({
    (1, 0, 0): Fraction(2, 3),
    (0, 1, 0): Fraction(4, 9),
    (0, 0, 1): Fraction(8, 27),
    (1, 1, 0): Fraction(3, 2),
})

# 5. Large denominators
coeffs = {}
primes_list = [2, 3, 5, 7, 11]
for i in range(5):
    exp = tuple(1 if j == i else 0 for j in range(5))
    coeffs[exp] = Fraction(1, primes_list[i] ** 6)
polys["Large\ndenominators"] = Poly(coeffs)

# 6. Catalan-like
def catalan(k):
    if k < 0: return 0
    c = 1
    for i in range(k):
        c = c * (2 * k - i) // (i + 1)
    return c // (k + 1)

polys["Catalan\ncoeffs"] = Poly({(k,): Fraction(catalan(k)) for k in range(8) if catalan(k) != 0})


# ─── Compute heatmap data ───────────────────────────────────────────────────

test_primes = [2, 3, 5, 7, 11, 13]
poly_names = list(polys.keys())
n_polys = len(poly_names)
n_primes = len(test_primes)

data = np.zeros((n_polys, n_primes))
for i, name in enumerate(poly_names):
    for j, p in enumerate(test_primes):
        data[i, j] = polys[name].weight(p)


# ─── Create figure ──────────────────────────────────────────────────────────

fig, axes = plt.subplots(1, 2, figsize=(14, 6), gridspec_kw={"width_ratios": [3, 1]})

# Heatmap
ax = axes[0]
cmap = plt.cm.YlOrRd
norm = mcolors.Normalize(vmin=0, vmax=max(data.max(), 1))
im = ax.imshow(data, cmap=cmap, norm=norm, aspect="auto")

ax.set_xticks(range(n_primes))
ax.set_xticklabels([f"q = {p}" for p in test_primes], fontsize=11)
ax.set_yticks(range(n_polys))
ax.set_yticklabels(poly_names, fontsize=10)
ax.set_xlabel("Prime q", fontsize=12)
ax.set_ylabel("Polynomial", fontsize=12)
ax.set_title("p-Adic Tropical Witness Profiles\n$W^{(q)}_{\\mathrm{coeff}}(p)$", fontsize=14)

# Annotate cells
for i in range(n_polys):
    for j in range(n_primes):
        val = int(data[i, j])
        color = "white" if val > data.max() * 0.6 else "black"
        ax.text(j, i, str(val), ha="center", va="center", fontsize=11,
                fontweight="bold", color=color)

plt.colorbar(im, ax=ax, label="Weight $|v_q(c_\\alpha)|$", shrink=0.8)

# Bar chart: heights vs max witness
ax2 = axes[1]
heights = [polys[name].height() for name in poly_names]
max_witnesses = [max(data[i]) for i in range(n_polys)]

y_pos = np.arange(n_polys)
width = 0.35

bars1 = ax2.barh(y_pos - width/2, heights, width, label="Coeff Height",
                  color="#2196F3", alpha=0.8)
bars2 = ax2.barh(y_pos + width/2, max_witnesses, width, label="Max Witness",
                  color="#FF5722", alpha=0.8)

ax2.set_yticks(y_pos)
ax2.set_yticklabels([""] * n_polys)
ax2.set_xlabel("Value", fontsize=11)
ax2.set_title("Height vs\nMax Witness", fontsize=12)
ax2.legend(fontsize=9, loc="lower right")

plt.tight_layout()
plt.savefig("witness_profiles_heatmap.png", dpi=150, bbox_inches="tight")
plt.close()
print("Saved: witness_profiles_heatmap.png")
