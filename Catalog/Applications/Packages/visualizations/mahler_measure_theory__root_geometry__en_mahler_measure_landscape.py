"""
Visualization: The Mahler Measure Landscape

Illustrates the distribution of Mahler measures across polynomial families,
revealing Lehmer's gap — the mysterious void between M = 1 (cyclotomic) and
M ≈ 1.176 (Lehmer's polynomial). This visualization makes visible the
conjectured universal lower bound on arithmetic-dynamical complexity.

The histogram shows that no non-cyclotomic monic integer polynomial has been
found with Mahler measure in the gap (1, 1.176...), despite exhaustive search.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import product as cart_product

def polynomial_roots(coeffs):
    return np.roots(list(reversed(coeffs)))

def mahler_measure(coeffs):
    if len(coeffs) <= 1:
        return abs(coeffs[0]) if coeffs else 0.0
    roots = polynomial_roots(coeffs)
    return float(abs(coeffs[-1]) * np.prod([max(1.0, abs(r)) for r in roots]))

def is_cyclotomic_like(coeffs, tol=1e-8):
    if len(coeffs) <= 1:
        return True
    roots = polynomial_roots(coeffs)
    return all(abs(abs(r) - 1.0) < tol for r in roots)

# Collect Mahler measures for degree 2-6 monic polynomials
print("Computing Mahler measures for polynomial families...")
all_measures = []
degrees_data = {}

for degree in [2, 3, 4, 5, 6]:
    measures = []
    coeff_bound = 3 if degree <= 3 else (2 if degree <= 5 else 1)
    
    for lower in cart_product(range(-coeff_bound, coeff_bound+1), repeat=degree):
        coeffs = list(lower) + [1]
        if all(c == 0 for c in coeffs[:-1]):
            continue
        M = mahler_measure(coeffs)
        if M > 1.0 + 1e-10 and not is_cyclotomic_like(coeffs):
            measures.append(M)
            all_measures.append(M)
    
    degrees_data[degree] = measures
    print(f"  Degree {degree}: {len(measures)} non-cyclotomic polynomials")

# Lehmer's Mahler measure
LEHMER_M = 1.17628081825991

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# --- Panel 1: Histogram of all Mahler measures ---
ax = axes[0, 0]
bins = np.linspace(1.0, 3.0, 200)
ax.hist(all_measures, bins=bins, color='steelblue', alpha=0.7, edgecolor='none')
ax.axvline(x=LEHMER_M, color='red', linewidth=2, linestyle='-', label=f"M(L) ≈ {LEHMER_M:.4f}")
ax.axvline(x=1.0, color='green', linewidth=2, linestyle='--', label='M = 1 (cyclotomic)')
ax.fill_betweenx([0, ax.get_ylim()[1] if ax.get_ylim()[1] > 0 else 100], 
                  1.0, LEHMER_M, alpha=0.15, color='red')
ax.set_xlabel('Mahler measure M(f)', fontsize=11)
ax.set_ylabel('Count', fontsize=11)
ax.set_title("Lehmer's Gap: The Forbidden Zone", fontsize=12, fontweight='bold')
ax.legend(fontsize=9)
ax.set_xlim(1.0, 3.0)
ax.annotate('LEHMER GAP\n(no polynomials here!)', xy=(1.08, 0), fontsize=9,
            color='red', fontweight='bold', ha='center',
            xytext=(1.08, ax.get_ylim()[1]*0.3 if ax.get_ylim()[1] > 0 else 30))

# --- Panel 2: Zoom into the gap region ---
ax = axes[0, 1]
near_lehmer = [m for m in all_measures if 1.0 < m < 1.5]
bins2 = np.linspace(1.0, 1.5, 100)
ax.hist(near_lehmer, bins=bins2, color='steelblue', alpha=0.7, edgecolor='none')
ax.axvline(x=LEHMER_M, color='red', linewidth=2, linestyle='-', label=f"M(L) ≈ {LEHMER_M:.4f}")
ax.axvline(x=1.0, color='green', linewidth=2, linestyle='--', label='M = 1')
ax.fill_betweenx([0, 200], 1.0, LEHMER_M, alpha=0.15, color='red')
ax.set_xlabel('Mahler measure M(f)', fontsize=11)
ax.set_ylabel('Count', fontsize=11)
ax.set_title('Zoomed: Near the Lehmer Barrier', fontsize=12, fontweight='bold')
ax.legend(fontsize=9)
ax.set_xlim(1.0, 1.5)

# --- Panel 3: By degree ---
ax = axes[1, 0]
for degree, measures in sorted(degrees_data.items()):
    if measures:
        bins3 = np.linspace(1.0, 2.5, 80)
        ax.hist(measures, bins=bins3, alpha=0.5, label=f'Degree {degree}')
ax.axvline(x=LEHMER_M, color='red', linewidth=2, linestyle='-', label=f'M(L)')
ax.set_xlabel('Mahler measure M(f)', fontsize=11)
ax.set_ylabel('Count', fontsize=11)
ax.set_title('Mahler Measure by Polynomial Degree', fontsize=12, fontweight='bold')
ax.legend(fontsize=8)
ax.set_xlim(1.0, 2.5)

# --- Panel 4: Minimum Mahler measure by degree ---
ax = axes[1, 1]
min_measures = {}
for degree, measures in degrees_data.items():
    if measures:
        min_measures[degree] = min(measures)

degs = sorted(min_measures.keys())
mins = [min_measures[d] for d in degs]
ax.bar(degs, mins, color='steelblue', alpha=0.8, edgecolor='black', linewidth=0.5)
ax.axhline(y=LEHMER_M, color='red', linewidth=2, linestyle='--', label=f'M(L) ≈ {LEHMER_M:.4f}')
ax.set_xlabel('Polynomial degree', fontsize=11)
ax.set_ylabel('Minimum M(f)', fontsize=11)
ax.set_title('Minimum Mahler Measure by Degree', fontsize=12, fontweight='bold')
ax.legend(fontsize=9)
ax.set_ylim(1.0, max(mins) * 1.1 if mins else 2.0)

for d, m in zip(degs, mins):
    ax.annotate(f'{m:.4f}', xy=(d, m), xytext=(d, m + 0.02),
                ha='center', fontsize=8, fontweight='bold')

plt.suptitle("The Mahler Measure Landscape — Searching for Lehmer's Gap",
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_mahler_landscape.png', dpi=150, bbox_inches='tight')
print("Saved viz_mahler_landscape.png")
