"""
Visualization: Coset Cover Composition

Demonstrates the transitivity theorem for coset covers:
if A ⊆ C cosets of H and H ⊆ D cosets of K, then A ⊆ C·D cosets of K.

Shows actual vs theoretical bound across different group sizes.
"""

import matplotlib.pyplot as plt
import numpy as np
import random

random.seed(42)

def left_coset(g, H, n):
    return {(g + h) % n for h in H}

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

# Collect data across group sizes
data_n = []
data_bound = []
data_actual = []
data_ratio = []

for n in range(6, 61, 2):
    # Find subgroups
    subgroup_sizes = [d for d in range(2, n) if n % d == 0]
    if len(subgroup_sizes) < 2:
        continue
    
    for _ in range(30):
        if len(subgroup_sizes) < 2:
            continue
        
        # Pick K and H as subgroups with K ⊂ H
        d_K = random.choice(subgroup_sizes)
        K_set = {(i * (n // d_K)) % n for i in range(d_K)}
        
        # Find subgroups containing K
        larger = [d for d in subgroup_sizes if d > d_K and d % d_K == 0 
                  and n % d == 0]
        if not larger:
            continue
        
        d_H = random.choice(larger)
        H_set = {(i * (n // d_H)) % n for i in range(d_H)}
        
        D = compute_cover(H_set, K_set, n)
        
        # Build A as union of a few cosets of H
        C = random.randint(1, min(4, n // d_H))
        reps = random.sample(range(n), min(C, n))
        A = set()
        for g in reps:
            A |= left_coset(g, H_set, n)
        
        if not A:
            continue
        
        actual = compute_cover(A, K_set, n)
        bound = C * D
        
        data_n.append(n)
        data_bound.append(bound)
        data_actual.append(actual)
        data_ratio.append(actual / bound if bound > 0 else 0)

# Plot
fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: actual vs bound
ax1 = axes[0]
ax1.scatter(data_bound, data_actual, alpha=0.4, s=20, c=data_n, cmap='plasma')
max_val = max(max(data_bound), max(data_actual)) + 1
ax1.plot([0, max_val], [0, max_val], 'r--', linewidth=2, label='actual = bound')
ax1.set_xlabel('Theoretical bound C·D', fontsize=12)
ax1.set_ylabel('Actual cover size', fontsize=12)
ax1.set_title('Coset Cover Composition: Actual vs Bound', fontsize=14)
ax1.legend()
ax1.grid(True, alpha=0.3)
cbar = plt.colorbar(ax1.collections[0], ax=ax1, label='Group size n')

# Right: ratio distribution
ax2 = axes[1]
ax2.hist(data_ratio, bins=30, alpha=0.7, color='steelblue', edgecolor='navy')
ax2.axvline(x=1.0, color='red', linestyle='--', linewidth=2, label='bound = actual')
avg_ratio = np.mean(data_ratio)
ax2.axvline(x=avg_ratio, color='green', linestyle='-', linewidth=2, 
            label=f'mean = {avg_ratio:.3f}')
ax2.set_xlabel('Ratio: actual / bound', fontsize=12)
ax2.set_ylabel('Frequency', fontsize=12)
ax2.set_title('Tightness of C·D Bound', fontsize=14)
ax2.legend()
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('cover_composition.png', dpi=150, bbox_inches='tight')
print("Saved: cover_composition.png")
