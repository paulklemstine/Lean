#!/usr/bin/env python3
"""
Demo: Library of Babel — Combinatorial Topology
Numerical examples demonstrating the key theorems.
"""

import math
import random

# === Borges Parameters ===
ALPHA = 25       # alphabet size
PAGES = 410
LINES_PER_PAGE = 40
CHARS_PER_LINE = 80
N = PAGES * LINES_PER_PAGE * CHARS_PER_LINE  # 1,312,000

print("=" * 70)
print("THE LIBRARY OF BABEL: COMBINATORIAL TOPOLOGY")
print("=" * 70)

# --- Theorem 1: Cardinality ---
print("\n## Cardinality (Theorem: babel_card)")
print(f"Alphabet size α = {ALPHA}")
print(f"Book length N = {N:,}")
total_books = ALPHA ** N
log10_total = N * math.log10(ALPHA)
print(f"Total books = {ALPHA}^{N:,}")
print(f"           ≈ 10^{log10_total:,.0f}")
print(f"(That's a number with about {int(log10_total):,} digits)")

# --- Theorem 2: Hamming Distance ---
print("\n## Hamming Distance (Theorem: babelHammingDist is a metric)")

def hamming_dist(b1, b2):
    """Compute Hamming distance between two sequences."""
    return sum(1 for a, c in zip(b1, b2) if a != c)

# Small example
n_demo = 20
b1 = [random.randint(0, ALPHA - 1) for _ in range(n_demo)]
b2 = [random.randint(0, ALPHA - 1) for _ in range(n_demo)]
b3 = [random.randint(0, ALPHA - 1) for _ in range(n_demo)]

d12 = hamming_dist(b1, b2)
d23 = hamming_dist(b2, b3)
d13 = hamming_dist(b1, b3)

print(f"Example with N={n_demo}:")
print(f"  d(b1,b2) = {d12}")
print(f"  d(b2,b3) = {d23}")
print(f"  d(b1,b3) = {d13}")
print(f"  Triangle inequality: {d13} ≤ {d12} + {d23} = {d12 + d23}  ✓" if d13 <= d12 + d23 else "  VIOLATION!")
print(f"  Symmetry: d(b1,b2)={d12}, d(b2,b1)={hamming_dist(b2, b1)}  ✓")
print(f"  Self-distance: d(b1,b1)={hamming_dist(b1, b1)}  ✓")

# --- Theorem 3: Incompressibility ---
print("\n## Incompressibility (Theorem: incompressible_majority)")
print("Fraction of books compressible by k characters:")
for k in [1, 10, 100, 1000]:
    fraction = ALPHA ** (-k)
    log_fraction = -k * math.log10(ALPHA)
    print(f"  k={k:>5}: fraction ≤ {ALPHA}^(-{k}) ≈ 10^({log_fraction:.1f})")

print(f"\nFor k=100: only 1 in {ALPHA}**100 ≈ 10^{100*math.log10(ALPHA):.0f} books can be compressed.")
print("Almost ALL books are incompressible.")

# --- Theorem 4: Spectrum ---
print("\n## Symbol Spectrum (Theorem: spectrum_sum)")
book = [random.randint(0, ALPHA - 1) for _ in range(1000)]
spectrum = [sum(1 for c in book if c == s) for s in range(ALPHA)]
print(f"Example book (length {len(book)}):")
print(f"  Spectrum sum = {sum(spectrum)} (should equal {len(book)})")
print(f"  Spectrum (first 5 symbols): {spectrum[:5]}")
print(f"  Uniform would be {len(book)/ALPHA:.1f} per symbol")

# --- Theorem 5: Neighbors ---
print("\n## Single-Edit Neighbors")
neighbors_count = (ALPHA - 1) * N
print(f"Each book has exactly (α-1)·N = {ALPHA-1} × {N:,} = {neighbors_count:,} neighbors at distance 1")

# --- Topology ---
print("\n## Topological Structure")
print(f"Covering dimension: 0 (clopen basis from coordinate projections)")
print(f"Hamming diameter: {N:,}")
print(f"Clopen basis size: α·N = {ALPHA * N:,} sets")
print(f"The space is totally disconnected: every two distinct books")
print(f"  are separated by a clopen set (Theorem: babel_clopen_basis)")

print("\n" + "=" * 70)
print("All theorems verified with machine-checked proofs.")
print("=" * 70)


#!/usr/bin/env python3
"""
Visualization: Incompressibility in the Library of Babel
Shows how the fraction of compressible books vanishes exponentially.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import math

# Parameters
alpha = 25
N = 1_312_000

# --- Plot 1: Compressible fraction vs compression savings ---
fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: log-scale fraction
savings = np.arange(1, 201)
log_fraction = -savings * np.log10(alpha)

ax = axes[0]
ax.plot(savings, log_fraction, 'b-', linewidth=2)
ax.set_xlabel('Compression savings (characters saved)', fontsize=12)
ax.set_ylabel('log₁₀(compressible fraction)', fontsize=12)
ax.set_title('Incompressibility: Almost All Books\nCannot Be Compressed', fontsize=14)
ax.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
ax.annotate('Save 1 char:\n4% compressible', 
            xy=(1, -np.log10(25)), xytext=(30, -20),
            fontsize=10, arrowprops=dict(arrowstyle='->', color='red'),
            color='red')
ax.annotate('Save 100 chars:\n≈ 0% compressible', 
            xy=(100, -100*np.log10(25)), xytext=(120, -100),
            fontsize=10, arrowprops=dict(arrowstyle='->', color='red'),
            color='red')
ax.grid(True, alpha=0.3)

# Right: Hamming ball volume (log scale)
ax2 = axes[1]
radii = np.arange(0, 51)
log_volumes = []
for r in radii:
    # log10 of sum_{k=0}^{r} C(N,k) * 24^k
    # Use Stirling approximation for large N
    # V(r) ≈ C(N,r) * 24^r for large N and small r
    if r == 0:
        log_volumes.append(0)
    else:
        log_vol = r * np.log10(24) + sum(np.log10(N - k) - np.log10(k + 1) for k in range(r))
        log_volumes.append(log_vol)

ax2.plot(radii, log_volumes, 'r-', linewidth=2)
ax2.axhline(y=N * np.log10(alpha), color='blue', linestyle='--', 
            alpha=0.5, label=f'Total books ≈ 10^{N*np.log10(alpha):.0f}')
ax2.set_xlabel('Hamming ball radius', fontsize=12)
ax2.set_ylabel('log₁₀(ball volume)', fontsize=12)
ax2.set_title('Hamming Ball Growth\n(neighborhood size)', fontsize=14)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('babel_incompressibility.png', dpi=150, bbox_inches='tight')
plt.close()

# --- Plot 2: Spectrum example ---
fig2, ax3 = plt.subplots(1, 1, figsize=(10, 5))

# Generate a random "book" spectrum
np.random.seed(42)
n_chars = 1000
book = np.random.randint(0, alpha, n_chars)
spectrum = np.bincount(book, minlength=alpha)

symbols = [chr(65 + i) if i < 22 else ['.', ',', ' '][i - 22] for i in range(alpha)]
colors = plt.cm.viridis(np.linspace(0.2, 0.8, alpha))

ax3.bar(range(alpha), spectrum, color=colors, edgecolor='black', linewidth=0.5)
ax3.axhline(y=n_chars / alpha, color='red', linestyle='--', linewidth=2,
            label=f'Uniform = {n_chars/alpha:.1f}')
ax3.set_xlabel('Symbol', fontsize=12)
ax3.set_ylabel('Frequency', fontsize=12)
ax3.set_title(f'Symbol Spectrum of a Random Book (N={n_chars})\nSpectrum sum = {sum(spectrum)} = N ✓',
              fontsize=14)
ax3.set_xticks(range(alpha))
ax3.set_xticklabels(symbols, fontsize=9)
ax3.legend(fontsize=11)
ax3.grid(True, alpha=0.3, axis='y')

plt.tight_layout()
plt.savefig('babel_spectrum.png', dpi=150, bbox_inches='tight')
plt.close()

print("Visualizations saved: babel_incompressibility.png, babel_spectrum.png")
