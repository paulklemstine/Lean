#!/usr/bin/env python3
"""
Visualization: Overlap Spectrum as Integer Partition

Visualizes how the overlap spectrum changes as supports progressively
overlap, showing the transition from n singleton classes (disjoint case)
to 1 class (fully connected case).

Uses matplotlib for static visualization.
"""

import matplotlib.pyplot as plt
import numpy as np
from collections import defaultdict


def overlap_spectrum(family):
    """Compute overlap spectrum (self-contained)."""
    n = len(family)
    parent = list(range(n))
    
    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x
    
    def union(x, y):
        px, py = find(x), find(y)
        if px != py:
            parent[px] = py
    
    for i in range(n):
        for j in range(i + 1, n):
            if len(family[i] & family[j]) > 0:
                union(i, j)
    
    sizes = defaultdict(int)
    for i in range(n):
        sizes[find(i)] += 1
    return sorted(sizes.values(), reverse=True)


def overlap_degree(family):
    """Count overlapping pairs."""
    n = len(family)
    return sum(1 for i in range(n) for j in range(i+1, n) 
               if len(family[i] & family[j]) > 0)


def overlap_complexity(family):
    """Sum of intersection sizes."""
    n = len(family)
    return sum(len(family[i] & family[j]) 
               for i in range(n) for j in range(i+1, n))


# Create a sequence of families showing progressive overlap
n = 6
base_family = [{10*i+1, 10*i+2, 10*i+3} for i in range(n)]

# Progressive merging: add shared elements one by one
stages = []
labels = []

# Stage 0: Fully disjoint
stages.append([s.copy() for s in base_family])
labels.append("Disjoint")

# Stage 1: F0 and F1 share element
fam1 = [s.copy() for s in base_family]
fam1[1].add(3)  # share element 3
stages.append(fam1)
labels.append("F₀∩F₁ ≠ ∅")

# Stage 2: F2 and F3 also share
fam2 = [s.copy() for s in fam1]
fam2[3].add(23)  # share element 23
stages.append(fam2)
labels.append("+F₂∩F₃ ≠ ∅")

# Stage 3: Connect the two pairs
fam3 = [s.copy() for s in fam2]
fam3[2].add(13)  # F1 and F2 share
stages.append(fam3)
labels.append("+F₁∩F₂ ≠ ∅")

# Stage 4: F4 joins the big cluster
fam4 = [s.copy() for s in fam3]
fam4[4].add(33)  # F3 and F4 share
stages.append(fam4)
labels.append("+F₃∩F₄ ≠ ∅")

# Stage 5: Fully connected
fam5 = [s.copy() for s in fam4]
fam5[5].add(43)  # F4 and F5 share
stages.append(fam5)
labels.append("Fully connected")

# Create the visualization
fig, axes = plt.subplots(2, 3, figsize=(18, 12))

colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3', '#ff7f00', '#a65628']

for idx, (fam, label) in enumerate(zip(stages, labels)):
    row, col = idx // 3, idx % 3
    ax = axes[row][col]
    
    spec = overlap_spectrum(fam)
    deg = overlap_degree(fam)
    comp = overlap_complexity(fam)
    n_classes = len(spec)
    
    # Draw Young diagram
    max_part = max(spec) if spec else 0
    for r, part_size in enumerate(spec):
        for c in range(part_size):
            rect = plt.Rectangle((c * 1.1, (len(spec) - 1 - r) * 1.1), 
                               1.0, 1.0,
                               facecolor=colors[r % len(colors)],
                               alpha=0.7, edgecolor='black', linewidth=2)
            ax.add_patch(rect)
    
    ax.set_xlim(-0.5, max(max_part * 1.1 + 0.5, 2))
    ax.set_ylim(-2, len(spec) * 1.1 + 1)
    
    ax.set_title(f"Stage {idx}: {label}", fontsize=12, fontweight='bold')
    
    # Add info text
    info = (f"Spectrum: {spec}\n"
            f"Classes: {n_classes}, Edges: {deg}\n"
            f"Complexity: {comp}\n"
            f"Sum = {sum(spec)} = n ✓")
    ax.text(0.02, 0.02, info, transform=ax.transAxes, fontsize=9,
           verticalalignment='bottom', fontfamily='monospace',
           bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))
    
    ax.axis('off')

plt.suptitle("Overlap Spectrum Evolution: From Disjoint to Fully Connected\n"
             "Each box represents one index; color = overlap class; "
             "row width = class size",
             fontsize=14, fontweight='bold')
plt.tight_layout(rect=[0, 0, 1, 0.92])
plt.savefig("viz_spectrum_partition.png", dpi=150, bbox_inches='tight')
print("Saved viz_spectrum_partition.png")
