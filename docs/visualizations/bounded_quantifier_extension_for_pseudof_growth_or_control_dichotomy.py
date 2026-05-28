"""
Visualization: Growth-or-Control Dichotomy

Plots the relationship between doubling constant K = |A+A|/|A| and
minimum coset cover size for random subsets of Z/nZ. The growth-or-control
theorem predicts that sets with small K have small covers.

This visualizes the cross-domain bridge between model theory (definable
covers) and geometric group theory (growth of product sets).
"""

import matplotlib.pyplot as plt
import numpy as np
import random

random.seed(42)

def left_coset(g, H, n):
    return {(g + h) % n for h in H}

def product_set(A, B, n):
    return {(a + b) % n for a in A for b in B}

def compute_cover(A, H, n):
    remaining = set(A)
    count = 0
    while remaining:
        best = max(range(n), key=lambda g: len(remaining & left_coset(g, H, n)))
        covered = remaining & left_coset(best, H, n)
        if not covered:
            break
        remaining -= covered
        count += 1
    return count

# Generate data
n = 30
subgroups = []
for d in range(1, n + 1):
    if n % d == 0:
        subgroups.append({(i * (n // d)) % n for i in range(d)})

growths = []
covers = []
sizes = []

for _ in range(2000):
    k = random.randint(2, n // 2)
    A = set(random.sample(range(n), min(k, n)))
    A.add(0)
    
    AA = product_set(A, A, n)
    growth = len(AA) / len(A)
    
    min_cover = n
    for H in subgroups:
        if len(H) >= 2:
            cover = compute_cover(A, H, n)
            min_cover = min(min_cover, cover)
    
    growths.append(growth)
    covers.append(min_cover)
    sizes.append(len(A))

# Plot
fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: scatter plot
ax1 = axes[0]
scatter = ax1.scatter(growths, covers, c=sizes, cmap='viridis', 
                       alpha=0.5, s=30, edgecolors='none')
ax1.set_xlabel('Doubling constant K = |A+A|/|A|', fontsize=12)
ax1.set_ylabel('Minimum coset cover size', fontsize=12)
ax1.set_title('Growth vs Control in Z/30Z', fontsize=14)
cbar = plt.colorbar(scatter, ax=ax1, label='|A|')
ax1.axvline(x=2, color='red', linestyle='--', alpha=0.5, label='K=2 threshold')
ax1.legend()
ax1.grid(True, alpha=0.3)

# Right: histogram of covers for small vs large growth
ax2 = axes[1]
small_covers = [c for g, c in zip(growths, covers) if g <= 2.5]
large_covers = [c for g, c in zip(growths, covers) if g > 2.5]

bins = range(0, max(covers) + 2)
ax2.hist(small_covers, bins=bins, alpha=0.6, label=f'K ≤ 2.5 (n={len(small_covers)})',
         color='blue', edgecolor='navy')
ax2.hist(large_covers, bins=bins, alpha=0.6, label=f'K > 2.5 (n={len(large_covers)})',
         color='orange', edgecolor='brown')
ax2.set_xlabel('Minimum coset cover size', fontsize=12)
ax2.set_ylabel('Frequency', fontsize=12)
ax2.set_title('Cover Size Distribution: Small vs Large Growth', fontsize=14)
ax2.legend()
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('growth_control_dichotomy.png', dpi=150, bbox_inches='tight')
print("Saved: growth_control_dichotomy.png")
