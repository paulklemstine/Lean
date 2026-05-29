#!/usr/bin/env python3
"""
Visualization: Persistence Stability and Entropy Monotonicity

This script visualizes two formally verified theorems:
1. Bottleneck stability: d_bottle(B, B') ≤ ε for ε-interleaved barcodes
2. Entropy monotonicity: coarsening never increases Shannon entropy

These are the scientific backbone of the primewise persistence program,
ensuring that barcode signatures are robust and well-behaved.
"""
import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def shannon_entropy(probs):
    return -sum(p * math.log(p) for p in probs if p > 0)


# Create figure
fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Verified Theorems: Stability and Entropy Monotonicity',
             fontsize=16, fontweight='bold')

# ---- Plot 1: Entropy Monotonicity ----
ax1 = axes[0, 0]

# Generate random refinements and verify monotonicity
np.random.seed(42)
n_tests = 50
fine_entropies = []
coarse_entropies = []

for _ in range(n_tests):
    # Random fine distribution on 6 elements
    raw = np.random.exponential(1, 6)
    fine = raw / raw.sum()
    fine = list(fine)

    # Random coarsening: group into 3 pairs
    coarse = [fine[0] + fine[1], fine[2] + fine[3], fine[4] + fine[5]]

    h_fine = shannon_entropy(fine)
    h_coarse = shannon_entropy(coarse)
    fine_entropies.append(h_fine)
    coarse_entropies.append(h_coarse)

ax1.scatter(fine_entropies, coarse_entropies, c='#3498db', alpha=0.6, s=60, edgecolors='black')
max_val = max(max(fine_entropies), max(coarse_entropies)) * 1.1
ax1.plot([0, max_val], [0, max_val], 'r--', linewidth=2, label='H(coarse) = H(fine)')
ax1.set_xlabel('H(fine distribution)', fontsize=12)
ax1.set_ylabel('H(coarse distribution)', fontsize=12)
ax1.set_title('Entropy Monotonicity (Verified)', fontsize=13)
ax1.legend(fontsize=10)
ax1.set_xlim(0, max_val)
ax1.set_ylim(0, max_val)
ax1.text(0.05, 0.95, 'All points below diagonal\n(verified theorem)',
         transform=ax1.transAxes, fontsize=10, verticalalignment='top',
         bbox=dict(boxstyle='round', facecolor='#eaf2f8', alpha=0.8))
ax1.grid(True, alpha=0.3)

# ---- Plot 2: Entropy Gap vs Number of Groups ----
ax2 = axes[0, 1]

n_elements = 12
raw = np.random.exponential(1, n_elements)
fine = raw / raw.sum()
fine = list(fine)

group_sizes = range(1, n_elements + 1)
gaps = []
for k in group_sizes:
    # Group into k roughly equal groups
    if k > n_elements:
        break
    size = n_elements // k
    groups = []
    for i in range(k):
        start = i * size
        end = start + size if i < k - 1 else n_elements
        groups.append(list(range(start, end)))

    coarse = [sum(fine[i] for i in g) for g in groups]
    h_fine = shannon_entropy(fine)
    h_coarse = shannon_entropy(coarse)
    gaps.append(h_fine - h_coarse)

ax2.bar(range(1, len(gaps) + 1), gaps, color='#2ecc71', edgecolor='black', alpha=0.8)
ax2.set_xlabel('Number of coarse groups', fontsize=12)
ax2.set_ylabel('Entropy gap H(fine) - H(coarse)', fontsize=12)
ax2.set_title('Entropy Gap vs Coarsening Level', fontsize=13)
ax2.text(0.95, 0.95, 'Gap ≥ 0 always\n(verified theorem)',
         transform=ax2.transAxes, fontsize=10, verticalalignment='top',
         horizontalalignment='right',
         bbox=dict(boxstyle='round', facecolor='#eafaf1', alpha=0.8))
ax2.grid(True, alpha=0.3, axis='y')

# ---- Plot 3: Bottleneck Stability Illustration ----
ax3 = axes[1, 0]

# Draw two barcodes and their matching
bars_original = [(0.1, 0.5), (0.2, 0.7), (0.4, 0.9), (0.6, 0.85)]
epsilon = 0.08
bars_perturbed = [(b + epsilon*0.7, d + epsilon*0.3) for b, d in bars_original]

y_orig = np.arange(len(bars_original)) * 0.3 + 0.5
y_pert = y_orig + 0.15

for i, ((b1, d1), (b2, d2)) in enumerate(zip(bars_original, bars_perturbed)):
    # Original bars
    ax3.barh(y_orig[i], d1 - b1, left=b1, height=0.1, color='#3498db',
             edgecolor='black', alpha=0.8)
    # Perturbed bars
    ax3.barh(y_pert[i], d2 - b2, left=b2, height=0.1, color='#e74c3c',
             edgecolor='black', alpha=0.8)
    # Matching lines
    ax3.plot([b1, b2], [y_orig[i], y_pert[i]], 'k:', alpha=0.5)
    ax3.plot([d1, d2], [y_orig[i], y_pert[i]], 'k:', alpha=0.5)

ax3.set_xlabel('Filtration value', fontsize=12)
ax3.set_ylabel('Bar index', fontsize=12)
ax3.set_title(f'Bottleneck Stability (ε = {epsilon})', fontsize=13)
ax3.legend(['Original', 'Perturbed'], fontsize=10)

# Add annotation
ax3.text(0.95, 0.05, f'd_bottle ≤ ε = {epsilon}\n(verified theorem)',
         transform=ax3.transAxes, fontsize=10, verticalalignment='bottom',
         horizontalalignment='right',
         bbox=dict(boxstyle='round', facecolor='#fdebd0', alpha=0.8))
ax3.grid(True, alpha=0.3)

# ---- Plot 4: x * log(x) function ----
ax4 = axes[1, 1]

x = np.linspace(0.001, 1.5, 500)
y = x * np.log(x)

ax4.plot(x, y, 'b-', linewidth=2.5)
ax4.fill_between(x[x <= 1], y[x <= 1], 0, alpha=0.2, color='blue')
ax4.axhline(y=0, color='black', linewidth=0.5)
ax4.axvline(x=1, color='gray', linestyle='--', alpha=0.5)
ax4.scatter([1], [0], c='red', s=100, zorder=5, label='(1, 0)')
ax4.scatter([1/math.e], [-1/math.e], c='green', s=100, zorder=5,
            label=f'min at (1/e, -1/e)')

ax4.set_xlabel('x', fontsize=12)
ax4.set_ylabel('x · log(x)', fontsize=12)
ax4.set_title('x·log(x) ≤ 0 for x ∈ [0,1] (Verified)', fontsize=13)
ax4.legend(fontsize=10)
ax4.set_xlim(-0.05, 1.5)
ax4.set_ylim(-0.5, 0.8)

ax4.text(0.3, 0.4, 'x·log(x) ≤ 0\nfor x ∈ [0,1]',
         transform=ax4.transAxes, fontsize=11,
         bbox=dict(boxstyle='round', facecolor='#eaf2f8', alpha=0.8))
ax4.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_stability.png', dpi=150, bbox_inches='tight')
print("Saved viz_stability.png")
