#!/usr/bin/env python3
"""
Demo 2: The Integer Energy Landscape
=====================================

A 3D visualization of integer energy across multiple dimensions:
- Abundance (σ(n)/n)
- Factorization entropy
- Arithmetic derivative
- Robin ratio

Shows how highly composite numbers occupy a distinct "energy peak"
in the multidimensional energy landscape.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.colors import Normalize
from math import log, exp, sqrt, gcd
from collections import Counter
import os

output_dir = os.path.join(os.path.dirname(__file__), '..', 'visuals')
os.makedirs(output_dir, exist_ok=True)

EULER_GAMMA = 0.5772156649015329
E_GAMMA = exp(EULER_GAMMA)

# --- Core functions ---

def sigma(n):
    if n <= 0: return 0
    s = 0
    for d in range(1, int(n**0.5) + 1):
        if n % d == 0:
            s += d
            if d != n // d:
                s += n // d
    return s

def divisor_count(n):
    if n <= 0: return 0
    c = 0
    for d in range(1, int(n**0.5) + 1):
        if n % d == 0:
            c += 1
            if d != n // d:
                c += 1
    return c

def factorize(n):
    """Return prime factorization as dict {prime: exponent}."""
    if n <= 1: return {}
    factors = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1
    if n > 1:
        factors[n] = factors.get(n, 0) + 1
    return factors

def factorization_entropy(n):
    """Entropy of the exponent distribution in the prime factorization."""
    if n <= 1: return 0
    factors = factorize(n)
    exponents = list(factors.values())
    total = sum(exponents)
    if total == 0: return 0
    probs = [e / total for e in exponents]
    entropy = -sum(p * log(p) for p in probs if p > 0)
    # Normalize by log(number of distinct primes)
    if len(probs) > 1:
        entropy /= log(len(probs))
    else:
        entropy = 0  # single prime factor => zero entropy
    return entropy

def arithmetic_derivative(n):
    """The arithmetic derivative n'."""
    if n <= 1: return 0
    factors = factorize(n)
    return sum(n * e // p for p, e in factors.items())

def robin_ratio(n):
    if n < 3: return None
    lln = log(log(n))
    if lln <= 0: return None
    return sigma(n) / (E_GAMMA * n * lln)

# --- Compute energy landscape ---

N_MAX = 10000
print(f"Computing energy landscape for n = 2 to {N_MAX}...")

data = []
for n in range(2, N_MAX + 1):
    s = sigma(n)
    abundance = s / n
    entropy = factorization_entropy(n)
    ad = arithmetic_derivative(n)
    ad_norm = ad / n if n > 1 else 0
    dc = divisor_count(n)
    rr = robin_ratio(n)
    data.append({
        'n': n, 'sigma': s, 'abundance': abundance,
        'entropy': entropy, 'arith_deriv_norm': ad_norm,
        'divisor_count': dc, 'robin_ratio': rr
    })

# Identify special numbers
hcn_candidates = []
record_dc = 0
for d in data:
    if d['divisor_count'] > record_dc:
        record_dc = d['divisor_count']
        hcn_candidates.append(d['n'])

sa_candidates = []
record_ab = 0
for d in data:
    if d['abundance'] > record_ab:
        record_ab = d['abundance']
        sa_candidates.append(d['n'])

special_set = set(hcn_candidates) | set(sa_candidates)
print(f"Highly composite numbers found: {len(hcn_candidates)}")
print(f"Superabundant numbers found: {len(sa_candidates)}")

# --- Figure 1: 2D Energy Landscape (Abundance vs Entropy) ---

fig, axes = plt.subplots(2, 2, figsize=(16, 14))
fig.suptitle("The Integer Energy Landscape\n"
             "Highly Composite & Superabundant Numbers as Energy Peaks",
             fontsize=16, fontweight='bold')

# Extract arrays
ns = np.array([d['n'] for d in data])
abundances = np.array([d['abundance'] for d in data])
entropies = np.array([d['entropy'] for d in data])
ad_norms = np.array([d['arith_deriv_norm'] for d in data])
div_counts = np.array([d['divisor_count'] for d in data])
robin_rs = np.array([d['robin_ratio'] if d['robin_ratio'] is not None else 0 for d in data])

# Panel 1: Abundance vs n with entropy as color
ax1 = axes[0, 0]
sc1 = ax1.scatter(ns, abundances, c=entropies, s=1, alpha=0.5,
                   cmap='viridis', edgecolors='none')
# Highlight special numbers
for n in [6, 12, 24, 60, 120, 360, 720, 2520, 5040]:
    idx = n - 2
    if idx < len(data):
        d = data[idx]
        ax1.scatter([n], [d['abundance']], s=80, c='red', edgecolors='black',
                    zorder=5, linewidths=1)
        ax1.annotate(str(n), (n, d['abundance']), fontsize=7,
                     textcoords='offset points', xytext=(5, 5))
plt.colorbar(sc1, ax=ax1, label='Factorization Entropy')
ax1.set_xlabel('n', fontsize=11)
ax1.set_ylabel(r'$\sigma(n)/n$ (Abundance)', fontsize=11)
ax1.set_title('Abundance Colored by Factorization Entropy', fontsize=12)

# Panel 2: Abundance vs Entropy scatter
ax2 = axes[0, 1]
sc2 = ax2.scatter(entropies, abundances, c=np.log10(ns), s=1, alpha=0.3,
                   cmap='plasma', edgecolors='none')
for n in [6, 12, 24, 60, 120, 360, 720, 2520, 5040]:
    idx = n - 2
    if idx < len(data):
        d = data[idx]
        ax2.scatter([d['entropy']], [d['abundance']], s=80, c='red',
                    edgecolors='black', zorder=5, linewidths=1)
        ax2.annotate(str(n), (d['entropy'], d['abundance']), fontsize=7,
                     textcoords='offset points', xytext=(5, 5))
plt.colorbar(sc2, ax=ax2, label=r'$\log_{10}(n)$')
ax2.set_xlabel('Factorization Entropy (normalized)', fontsize=11)
ax2.set_ylabel(r'$\sigma(n)/n$ (Abundance)', fontsize=11)
ax2.set_title('Energy Landscape: Abundance vs Entropy', fontsize=12)

# Panel 3: Divisor count vs n (staircase)
ax3 = axes[1, 0]
ax3.scatter(ns, div_counts, s=0.5, alpha=0.3, c='steelblue', edgecolors='none')
for n in [6, 12, 24, 60, 120, 360, 720, 2520, 5040]:
    idx = n - 2
    if idx < len(data):
        d = data[idx]
        ax3.scatter([n], [d['divisor_count']], s=80, c='gold',
                    edgecolors='black', zorder=5, linewidths=1)
        ax3.annotate(f"{n}\n(d={d['divisor_count']})", (n, d['divisor_count']),
                     fontsize=7, textcoords='offset points', xytext=(5, 5))
ax3.set_xlabel('n', fontsize=11)
ax3.set_ylabel('d(n) (divisor count)', fontsize=11)
ax3.set_title('Divisor Count — HCN Staircase', fontsize=12)

# Panel 4: Arithmetic derivative (normalized) vs abundance
ax4 = axes[1, 1]
# Filter out extreme values for visibility
mask = ad_norms < 10
sc4 = ax4.scatter(abundances[mask], ad_norms[mask], c=np.log10(ns[mask]),
                   s=1, alpha=0.3, cmap='coolwarm', edgecolors='none')
for n in [6, 12, 24, 60, 120, 360, 720, 2520, 5040]:
    idx = n - 2
    if idx < len(data):
        d = data[idx]
        ax4.scatter([d['abundance']], [d['arith_deriv_norm']], s=80, c='lime',
                    edgecolors='black', zorder=5, linewidths=1)
        ax4.annotate(str(n), (d['abundance'], d['arith_deriv_norm']),
                     fontsize=7, textcoords='offset points', xytext=(5, 5))
plt.colorbar(sc4, ax=ax4, label=r'$\log_{10}(n)$')
ax4.set_xlabel(r'$\sigma(n)/n$ (Abundance)', fontsize=11)
ax4.set_ylabel(r"$n'/n$ (Normalized Arithmetic Derivative)", fontsize=11)
ax4.set_title('Abundance vs Arithmetic Derivative', fontsize=12)

plt.tight_layout()
plt.savefig(os.path.join(output_dir, 'energy_landscape.png'), dpi=150, bbox_inches='tight')
plt.close()
print(f"✅ Saved: energy_landscape.png")

# --- Figure 2: The Robin Ratio Heatmap ---

fig2, ax_heat = plt.subplots(figsize=(16, 6))
fig2.suptitle(r"Robin Ratio Heatmap: $R(n) = \sigma(n)/(e^\gamma \cdot n \cdot \ln\ln n)$",
              fontsize=14, fontweight='bold')

# Create a 2D "barcode" of Robin ratios
# Group by ranges
block_size = 100
n_blocks = N_MAX // block_size
heatmap_data = np.zeros((10, n_blocks))

for b in range(n_blocks):
    start = b * block_size + 1
    end = (b + 1) * block_size + 1
    block_ratios = []
    for n in range(max(3, start), end):
        rr = robin_ratio(n)
        if rr is not None:
            block_ratios.append(rr)
    if block_ratios:
        # Fill rows with quantile information
        br = np.array(block_ratios)
        for q in range(10):
            pct = (q + 1) * 10
            heatmap_data[q, b] = np.percentile(br, pct)

im = ax_heat.imshow(heatmap_data, aspect='auto', cmap='RdYlBu_r',
                     extent=[0, N_MAX, 0, 100],
                     vmin=0.3, vmax=1.1)
ax_heat.axvline(x=5040, color='lime', linewidth=2, linestyle='--', label='n = 5040')
ax_heat.set_xlabel('n', fontsize=12)
ax_heat.set_ylabel('Percentile of R(n) in block', fontsize=12)
ax_heat.set_title('Robin Ratio Distribution by Block', fontsize=13)
ax_heat.legend(fontsize=11)
plt.colorbar(im, ax=ax_heat, label='Robin Ratio R(n)')

plt.tight_layout()
plt.savefig(os.path.join(output_dir, 'robin_heatmap.png'), dpi=150, bbox_inches='tight')
plt.close()
print(f"✅ Saved: robin_heatmap.png")

# --- Figure 3: The Colossally Abundant Approach ---

print("\nComputing colossally abundant numbers (approximate)...")
# Approximate: find numbers that are both HCN and SA
ca_candidates = sorted(set(hcn_candidates) & set(sa_candidates))
print(f"Found {len(ca_candidates)} CA-like numbers: {ca_candidates[:20]}")

fig3, (ax_ca1, ax_ca2) = plt.subplots(1, 2, figsize=(14, 6))
fig3.suptitle("Colossally Abundant Numbers: Approaching the Robin Ceiling",
              fontsize=14, fontweight='bold')

ca_robins = [(n, robin_ratio(n)) for n in ca_candidates if robin_ratio(n) is not None and n >= 3]
ca_ns = [x[0] for x in ca_robins]
ca_rs = [x[1] for x in ca_robins]

ax_ca1.plot(ca_ns, ca_rs, 'o-', color='darkblue', markersize=8, linewidth=2)
ax_ca1.axhline(y=1.0, color='red', linewidth=2, linestyle='--', label='Robin bound')
ax_ca1.axvline(x=5040, color='green', linewidth=1.5, linestyle=':', alpha=0.7)

for n, r in ca_robins:
    if n in [6, 12, 60, 120, 360, 2520, 5040]:
        ax_ca1.annotate(str(n), (n, r), textcoords='offset points',
                        xytext=(8, 8), fontsize=9, fontweight='bold')

ax_ca1.set_xlabel('n (colossally abundant)', fontsize=11)
ax_ca1.set_ylabel('Robin Ratio R(n)', fontsize=11)
ax_ca1.set_title('Robin Ratio at CA Numbers', fontsize=12)
ax_ca1.legend(fontsize=10)

# Distance from Robin bound
distances = [1.0 - r for n, r in ca_robins if n > 5040]
ca_above = [n for n, r in ca_robins if n > 5040]
if distances and ca_above:
    ax_ca2.semilogy(ca_above, distances, 'o-', color='purple', markersize=8, linewidth=2)
    ax_ca2.set_xlabel('n (CA number, n > 5040)', fontsize=11)
    ax_ca2.set_ylabel('1 - R(n) (distance from ceiling)', fontsize=11)
    ax_ca2.set_title('How Close CA Numbers Get to the Ceiling', fontsize=12)
    ax_ca2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig(os.path.join(output_dir, 'colossally_abundant_approach.png'), dpi=150, bbox_inches='tight')
plt.close()
print(f"✅ Saved: colossally_abundant_approach.png")

print("\n✅ All energy landscape visualizations complete!")
