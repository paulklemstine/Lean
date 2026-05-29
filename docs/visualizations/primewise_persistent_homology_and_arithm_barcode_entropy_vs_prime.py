#!/usr/bin/env python3
"""
Visualization: Barcode Entropy vs Prime

This script visualizes the relationship between prime number p and the
barcode entropy of the Pythagorean filtered complex mod p. The plot
reveals how arithmetic complexity (measured by Shannon entropy of
normalized bar lengths) grows with prime size.

Key insight: entropy growth rate reveals the scaling law of arithmetic
incidence complexity.
"""
import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


# Inline all needed functions
class BarcodeBar:
    def __init__(self, birth, death):
        self.birth = birth
        self.death = death
    @property
    def length(self):
        return self.death - self.birth

class PersistenceBarcode:
    def __init__(self, bars):
        self.bars = bars
    @property
    def total_mass(self):
        return sum(b.length for b in self.bars)

def shannon_entropy(probs):
    return -sum(p * math.log(p) for p in probs if p > 0)

def barcode_entropy(barcode):
    mass = barcode.total_mass
    if mass == 0:
        return 0.0
    return shannon_entropy([b.length / mass for b in barcode.bars])

def build_complex_and_barcode(p):
    edges, filt = [], []
    for a in range(p):
        for b in range(a + 1, p):
            min_c = None
            for c in range(p):
                if (a * a + b * b - c * c) % p == 0:
                    if min_c is None or c < min_c:
                        min_c = c
            if min_c is not None:
                edges.append((a, b))
                filt.append(float(min_c) / p)

    paired = sorted(zip(edges, filt), key=lambda x: x[1])
    parent = list(range(p))
    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    bars = []
    for (a, b), f in paired:
        ra, rb = find(a), find(b)
        if ra != rb:
            bars.append(BarcodeBar(0.0, f))
            parent[ra] = rb
    return PersistenceBarcode(bars)


def pythagorean_count(p):
    count = 0
    for a in range(p):
        for b in range(p):
            for c in range(p):
                if (a * a + b * b - c * c) % p == 0:
                    count += 1
    return count


# Compute data
primes = [3, 5, 7, 11, 13, 17, 19, 23, 29, 31]
entropies = []
masses = []
pyth_counts = []

for p in primes:
    barcode = build_complex_and_barcode(p)
    entropies.append(barcode_entropy(barcode))
    masses.append(barcode.total_mass)
    pyth_counts.append(pythagorean_count(p))

# Create figure
fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Primewise Persistent Homology of Pythagorean Triples',
             fontsize=16, fontweight='bold')

# Plot 1: Entropy vs prime
ax1 = axes[0, 0]
colors_1mod4 = ['#e74c3c' if p % 4 == 1 else '#3498db' for p in primes]
ax1.scatter(primes, entropies, c=colors_1mod4, s=100, zorder=5, edgecolors='black')
ax1.plot(primes, entropies, 'k--', alpha=0.3)
ax1.set_xlabel('Prime p', fontsize=12)
ax1.set_ylabel('Barcode Entropy H(B)', fontsize=12)
ax1.set_title('Barcode Entropy vs Prime', fontsize=13)
ax1.legend(['Trend', 'p ≡ 1 mod 4', 'p ≡ 3 mod 4'], loc='upper left', fontsize=9)
ax1.grid(True, alpha=0.3)

# Plot 2: Pythagorean count (verified: = p²)
ax2 = axes[0, 1]
ax2.scatter(primes, pyth_counts, c='#2ecc71', s=100, zorder=5, edgecolors='black', label='Computed')
p_arr = np.array(primes)
ax2.plot(p_arr, p_arr**2, 'r-', linewidth=2, label='p² (verified)')
ax2.set_xlabel('Prime p', fontsize=12)
ax2.set_ylabel('|Pyth(𝔽ₚ)|', fontsize=12)
ax2.set_title('Pythagorean Triple Count = p²', fontsize=13)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

# Plot 3: Total barcode mass
ax3 = axes[1, 0]
ax3.bar(range(len(primes)), masses, color='#9b59b6', edgecolor='black', alpha=0.8)
ax3.set_xticks(range(len(primes)))
ax3.set_xticklabels([str(p) for p in primes])
ax3.set_xlabel('Prime p', fontsize=12)
ax3.set_ylabel('Total Barcode Mass', fontsize=12)
ax3.set_title('Barcode Mass (Sum of Bar Lengths)', fontsize=13)
ax3.grid(True, alpha=0.3, axis='y')

# Plot 4: Entropy normalized by ln(p)
ax4 = axes[1, 1]
normalized = [e / math.log(p) if p > 1 else 0 for e, p in zip(entropies, primes)]
ax4.scatter(primes, normalized, c='#e67e22', s=100, zorder=5, edgecolors='black')
ax4.axhline(y=np.mean(normalized), color='red', linestyle='--',
            label=f'Mean = {np.mean(normalized):.3f}')
ax4.set_xlabel('Prime p', fontsize=12)
ax4.set_ylabel('H(B) / ln(p)', fontsize=12)
ax4.set_title('Normalized Entropy (Complexity Ratio)', fontsize=13)
ax4.legend(fontsize=10)
ax4.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_barcode_entropy.png', dpi=150, bbox_inches='tight')
print("Saved viz_barcode_entropy.png")
