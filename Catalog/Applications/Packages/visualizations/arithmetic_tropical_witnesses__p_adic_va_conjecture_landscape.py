#!/usr/bin/env python3
"""
Visualization: Arithmetic Tropical Witness Conjecture Landscape

Scatter plot of log(spectral proxy) vs max primewise witness for a large
collection of random rational polynomials. Tests whether the conjecture
log|W_spec| ≤ C · max_q W^(q) holds, and visualizes the boundary.
"""

import math
import random
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

    def spectral_proxy(self):
        return sum(float(abs(c)) for c in self.coeffs.values())

    def height(self):
        return sum(math.log(max(abs(c.numerator), c.denominator))
                   for c in self.coeffs.values())


# ─── Generate random polynomials ────────────────────────────────────────────

random.seed(42)
TEST_PRIMES = [2, 3, 5, 7, 11]

log_specs = []
max_witnesses = []
heights = []
categories = []  # for coloring

num_samples = 500

for trial in range(num_samples):
    n = random.randint(2, 5)
    num_terms = random.randint(2, 10)
    coeffs = {}
    
    # Different generation strategies
    cat = trial % 4
    for _ in range(num_terms):
        exp = tuple(random.randint(0, 3) for _ in range(n))
        
        if cat == 0:  # Small coefficients
            num = random.choice([-1, 1]) * random.randint(1, 10)
            den = random.randint(1, 10)
        elif cat == 1:  # Large numerators
            num = random.choice([-1, 1]) * random.randint(1, 1000)
            den = random.randint(1, 10)
        elif cat == 2:  # Large denominators
            num = random.choice([-1, 1]) * random.randint(1, 10)
            den = random.randint(1, 1000)
        else:  # Mixed
            num = random.choice([-1, 1]) * random.randint(1, 100)
            den = random.randint(1, 100)
        
        coeffs[exp] = Fraction(num, den)
    
    poly = Poly(coeffs)
    if not poly.coeffs:
        continue
    
    spec = poly.spectral_proxy()
    if spec <= 0:
        continue
    
    log_spec = math.log(spec)
    max_wit = max(poly.weight(p) for p in TEST_PRIMES)
    
    log_specs.append(log_spec)
    max_witnesses.append(max_wit)
    heights.append(poly.height())
    categories.append(["Small coeff", "Large num", "Large den", "Mixed"][cat])

log_specs = np.array(log_specs)
max_witnesses = np.array(max_witnesses)
heights = np.array(heights)


# ─── Create figure ──────────────────────────────────────────────────────────

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Plot 1: Conjecture test scatter
ax = axes[0]
cat_colors = {
    "Small coeff": "#2196F3",
    "Large num": "#FF5722",
    "Large den": "#4CAF50",
    "Mixed": "#9C27B0",
}

for cat_name in cat_colors:
    mask = np.array([c == cat_name for c in categories])
    if mask.any():
        ax.scatter(max_witnesses[mask], log_specs[mask],
                   c=cat_colors[cat_name], label=cat_name,
                   alpha=0.5, s=20, edgecolors="none")

# Draw the conjecture boundary lines
x_range = np.linspace(0, max(max_witnesses) * 1.1, 100)
for C, style, label in [(1.0, "--", "C=1"), (2.0, "-", "C=2"), (0.5, ":", "C=0.5")]:
    ax.plot(x_range, C * x_range, style, color="gray", alpha=0.7, label=f"y = {label}·x")

ax.set_xlabel("Max Primewise Witness $\\max_q W^{(q)}$", fontsize=11)
ax.set_ylabel("$\\log |W_{\\mathrm{spec}}|$", fontsize=11)
ax.set_title("Arithmetic Tropical Witness Conjecture\n"
             "$\\log|W_{\\mathrm{spec}}| \\leq C \\cdot \\max_q W^{(q)}$",
             fontsize=12)
ax.legend(fontsize=8, loc="upper left")
ax.grid(True, alpha=0.3)

# Count violations
violations = np.sum(log_specs > 2.0 * max_witnesses)
ax.text(0.95, 0.05, f"C=2 violations: {violations}/{len(log_specs)}",
        transform=ax.transAxes, ha="right", fontsize=10,
        bbox=dict(boxstyle="round", facecolor="wheat", alpha=0.8))

# Plot 2: Height vs max witness
ax2 = axes[1]
sc = ax2.scatter(max_witnesses, heights, c=log_specs, cmap="viridis",
                  alpha=0.6, s=20, edgecolors="none")
plt.colorbar(sc, ax=ax2, label="$\\log|W_{\\mathrm{spec}}|$", shrink=0.8)

# Regression line
valid = max_witnesses > 0
if valid.any():
    z = np.polyfit(max_witnesses[valid], heights[valid], 1)
    poly_fit = np.poly1d(z)
    x_fit = np.linspace(0, max(max_witnesses), 100)
    ax2.plot(x_fit, poly_fit(x_fit), "r--", alpha=0.7,
             label=f"Fit: H ≈ {z[0]:.2f}·W + {z[1]:.2f}")

ax2.set_xlabel("Max Primewise Witness $\\max_q W^{(q)}$", fontsize=11)
ax2.set_ylabel("Coefficient Height $H(p)$", fontsize=11)
ax2.set_title("Coefficient Height vs\nMax Arithmetic Witness", fontsize=12)
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig("conjecture_landscape.png", dpi=150, bbox_inches="tight")
plt.close()
print("Saved: conjecture_landscape.png")
