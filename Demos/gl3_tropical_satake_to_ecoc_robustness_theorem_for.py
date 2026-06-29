#!/usr/bin/env python3
"""
ECOC Robustness Demo: From Coordinatewise Lipschitz Margins to Certified Multiclass Stability

This script demonstrates the main theorems proved in Lean:
1. Nearest-codeword uniqueness from Hamming distance bounds
2. Coordinate bit stability from Lipschitz margin control
3. End-to-end ECOC robustness certification

We use concrete numerical examples motivated by the GL3 tropical Hecke setting.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from itertools import product

# ============================================================
# Section 1: Hamming Distance and Code Distance
# ============================================================

def hamming_dist(u, v):
    """Hamming distance between two binary vectors."""
    return np.sum(u != v)

def min_dist(code):
    """Minimum Hamming distance of a code (matrix: n_classes x m_coords)."""
    n = code.shape[0]
    d_min = float('inf')
    for i in range(n):
        for j in range(i+1, n):
            d = hamming_dist(code[i], code[j])
            d_min = min(d_min, d)
    return d_min

def nearest_codeword(code, y):
    """Find the nearest codeword to y. Returns (class_index, distance, is_unique)."""
    dists = [hamming_dist(y, code[i]) for i in range(code.shape[0])]
    min_d = min(dists)
    nearest = [i for i, d in enumerate(dists) if d == min_d]
    return nearest[0], min_d, len(nearest) == 1

# Example: 4-class code with 7 coordinates (like a [7,2] code)
print("=" * 70)
print("SECTION 1: Hamming Distance and Nearest-Codeword Uniqueness")
print("=" * 70)

code = np.array([
    [1, 1, 1, 0, 0, 0, 1],  # Class 0
    [0, 0, 1, 1, 1, 0, 0],  # Class 1
    [1, 0, 0, 0, 1, 1, 0],  # Class 2
    [0, 1, 0, 1, 0, 1, 1],  # Class 3
], dtype=bool)

n_classes, m_coords = code.shape
delta = min_dist(code)

print(f"\nCode matrix ({n_classes} classes × {m_coords} coordinates):")
for i in range(n_classes):
    print(f"  Class {i}: {code[i].astype(int)}")

print(f"\nMinimum distance δ = {delta}")
print(f"Correction radius ⌊(δ-1)/2⌋ = {(delta-1)//2}")
print(f"Uniqueness threshold: 2·d(y, code_c) < δ means d < {delta/2:.1f}")

# Demonstrate uniqueness theorem
print("\nDemonstrating nearest_codeword_unique_of_lt_half_minDist:")
for c in range(n_classes):
    y = code[c].copy()
    # Flip one bit
    y[0] = not y[0]
    d = hamming_dist(y, code[c])
    nc, nd, unique = nearest_codeword(code, y)
    print(f"  y = flip 1 bit of class {c}: d(y, code_{c}) = {d}, "
          f"2·d = {2*d} {'<' if 2*d < delta else '≥'} δ={delta}, "
          f"nearest = class {nc}, unique = {unique}")

# ============================================================
# Section 2: Coordinate Bit Stability from Lipschitz Margins
# ============================================================

print("\n" + "=" * 70)
print("SECTION 2: Coordinate Bit Stability from Lipschitz Margins")
print("=" * 70)

# Simulate score gaps and Lipschitz constants
np.random.seed(42)
m = 7

# Score gaps at clean point (positive means bit=1, negative means bit=0)
gap_clean = np.array([2.5, 1.8, -3.0, 0.5, -1.2, 0.3, 1.0])
L = np.array([1.0, 0.8, 1.2, 0.5, 0.9, 0.4, 0.7])  # Lipschitz constants

# Perturbation radius
r = 0.3

print(f"\nScore gaps at clean point x:")
for j in range(m):
    bit = int(gap_clean[j] >= 0)
    margin = abs(gap_clean[j])
    budget = L[j] * r
    stable = margin > budget
    print(f"  Coord {j}: gap = {gap_clean[j]:+.2f}, bit = {bit}, "
          f"margin = {margin:.2f}, L·r = {budget:.2f}, "
          f"{'STABLE ✓' if stable else 'VULNERABLE ✗'}")

# Count bad coordinates
bad_coords = []
for j in range(m):
    if gap_clean[j] >= 0:
        if gap_clean[j] <= L[j] * r:
            bad_coords.append(j)
    else:
        if -gap_clean[j] <= L[j] * r:
            bad_coords.append(j)

print(f"\nBad coordinates: {bad_coords}")
print(f"|bad| = {len(bad_coords)}, 2·|bad| = {2*len(bad_coords)}, δ = {delta}")
print(f"ECOC robust: 2·|bad| < δ? {2*len(bad_coords) < delta}")

# Simulate perturbation
print("\nSimulating 1000 random perturbations with ||ε|| ≤ r:")
n_trials = 1000
predictions_stable = 0
for trial in range(n_trials):
    # Random perturbation satisfying Lipschitz bound
    gap_perturbed = gap_clean.copy()
    for j in range(m):
        delta_gap = np.random.uniform(-L[j] * r, L[j] * r)
        gap_perturbed[j] += delta_gap

    bits_clean = (gap_clean >= 0).astype(int)
    bits_perturbed = (gap_perturbed >= 0).astype(int)

    if np.array_equal(bits_clean, bits_perturbed) or \
       hamming_dist(bits_perturbed, bits_clean) <= len(bad_coords):
        predictions_stable += 1

print(f"  Predictions within correction radius: {predictions_stable}/{n_trials} "
      f"({100*predictions_stable/n_trials:.1f}%)")

# ============================================================
# Section 3: Visualization
# ============================================================

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Plot 1: Code distance matrix
ax = axes[0]
dist_matrix = np.zeros((n_classes, n_classes))
for i in range(n_classes):
    for j in range(n_classes):
        dist_matrix[i, j] = hamming_dist(code[i], code[j])
im = ax.imshow(dist_matrix, cmap='YlOrRd', vmin=0)
ax.set_title('Pairwise Hamming Distances\nBetween Codewords', fontsize=12)
ax.set_xlabel('Class')
ax.set_ylabel('Class')
ax.set_xticks(range(n_classes))
ax.set_yticks(range(n_classes))
for i in range(n_classes):
    for j in range(n_classes):
        ax.text(j, i, f'{int(dist_matrix[i,j])}', ha='center', va='center',
                fontsize=14, fontweight='bold')
plt.colorbar(im, ax=ax, shrink=0.8)

# Plot 2: Margin analysis
ax = axes[1]
margins = np.abs(gap_clean)
budgets = L * r
colors = ['green' if m > b else 'red' for m, b in zip(margins, budgets)]
x_pos = np.arange(m)
bars1 = ax.bar(x_pos - 0.15, margins, 0.3, label='|margin|', color=colors, alpha=0.8)
bars2 = ax.bar(x_pos + 0.15, budgets, 0.3, label='L·r (budget)', color='orange', alpha=0.6)
ax.set_xlabel('Coordinate j')
ax.set_ylabel('Value')
ax.set_title(f'Margin vs Perturbation Budget (r={r})', fontsize=12)
ax.set_xticks(x_pos)
ax.legend()
ax.axhline(y=0, color='black', linewidth=0.5)
green_patch = mpatches.Patch(color='green', alpha=0.8, label='Certified stable')
red_patch = mpatches.Patch(color='red', alpha=0.8, label='Vulnerable')
ax.legend(handles=[green_patch, red_patch, bars2], loc='upper right')

# Plot 3: Robustness certification regions
ax = axes[2]
r_values = np.linspace(0, 1.5, 100)
bad_counts = []
for rv in r_values:
    count = 0
    for j in range(m):
        if gap_clean[j] >= 0:
            if gap_clean[j] <= L[j] * rv:
                count += 1
        else:
            if -gap_clean[j] <= L[j] * rv:
                count += 1
    bad_counts.append(count)

ax.plot(r_values, bad_counts, 'b-', linewidth=2, label='|bad coords|')
ax.axhline(y=delta/2, color='red', linestyle='--', linewidth=2,
           label=f'δ/2 = {delta/2:.1f} (threshold)')
ax.fill_between(r_values, 0, delta/2, alpha=0.1, color='green')
ax.fill_between(r_values, delta/2, m, alpha=0.1, color='red')
ax.set_xlabel('Perturbation radius r')
ax.set_ylabel('Number of bad coordinates')
ax.set_title('ECOC Robustness Certificate', fontsize=12)
ax.set_ylim(0, m)
ax.legend()
ax.text(0.3, 0.5, 'CERTIFIED\nROBUST', fontsize=14, color='green',
        ha='center', va='center', transform=ax.transAxes, alpha=0.5)

plt.tight_layout()
plt.savefig('/workspace/request-project/Bridges/ecoc_robustness_demo.png', dpi=150, bbox_inches='tight')
print("\nFigure saved to Bridges/ecoc_robustness_demo.png")

# ============================================================
# Section 4: Pairwise Majority Margins (Rival-wise Analysis)
# ============================================================

print("\n" + "=" * 70)
print("SECTION 4: Pairwise Majority Margin Analysis")
print("=" * 70)

# Use class 0 as the target
target_class = 0
print(f"\nTarget class: {target_class}")
print(f"Code: {code[target_class].astype(int)}")
print(f"Predicted bits: {(gap_clean >= 0).astype(int)}")

for rival in range(n_classes):
    if rival == target_class:
        continue

    # Disagreement set
    disagree = np.where(code[target_class] != code[rival])[0]
    D = len(disagree)

    # Robust disagree count
    robust_count = 0
    for j in disagree:
        if code[target_class][j]:
            if L[j] * r < gap_clean[j]:
                robust_count += 1
        else:
            if L[j] * r < -gap_clean[j]:
                robust_count += 1

    certified = 2 * robust_count > D
    print(f"\n  vs Class {rival}:")
    print(f"    Disagree set: {disagree.tolist()} (|D| = {D})")
    print(f"    Robust coords: {robust_count}")
    print(f"    2·robust = {2*robust_count} {'>' if certified else '≤'} |D| = {D}")
    print(f"    Certified: {'YES ✓' if certified else 'NO ✗'}")

# ============================================================
# Section 5: GL3 Tropical Hecke Specialization Example
# ============================================================

print("\n" + "=" * 70)
print("SECTION 5: GL₃ Tropical Hecke Score Specialization")
print("=" * 70)

print("""
In the GL₃ tropical Hecke setting:
  - Each coordinate j corresponds to a dominant coweight test family
  - gap(j, x) = tropical Satake score for bit=1 minus score for bit=0
  - L(j) = Lipschitz constant from the tropical/Hecke finite test machinery

The theorems proved in Lean establish:
  1. Individual score gaps are Lipschitz-stable
  2. Sufficient margin ⇒ bit preservation under perturbation
  3. Code distance + margin certificates ⇒ multiclass robustness

This creates a certified pipeline:
  Tropical Hecke scores → Lipschitz margins → ECOC robustness certificates
""")

# Simulated GL3 tropical scores
print("Simulated GL₃ tropical Hecke scores (3 classes, 5 coordinates):")
gl3_code = np.array([
    [1, 1, 0, 0, 1],
    [0, 1, 1, 0, 0],
    [1, 0, 0, 1, 0],
], dtype=bool)

# Tropical Satake score gaps (from dominant coweight analysis)
gl3_gaps = np.array([1.5, 2.0, -1.8, -0.8, 1.2])
gl3_L = np.array([0.6, 0.7, 0.5, 0.4, 0.5])

gl3_delta = min_dist(gl3_code)
gl3_r = 0.5

print(f"\n  Code distance δ = {gl3_delta}")
print(f"  Perturbation radius r = {gl3_r}")

bad = sum(1 for j in range(5)
          if (gl3_code[0][j] and gl3_gaps[j] <= gl3_L[j] * gl3_r) or
             (not gl3_code[0][j] and -gl3_gaps[j] <= gl3_L[j] * gl3_r))
print(f"  Bad coordinates for class 0: {bad}")
print(f"  2·|bad| = {2*bad} vs δ = {gl3_delta}")
print(f"  ECOC robust: {2*bad < gl3_delta}")

plt.show()
print("\nDemo complete.")
