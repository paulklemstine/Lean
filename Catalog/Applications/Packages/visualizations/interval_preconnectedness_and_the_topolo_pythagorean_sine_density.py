"""
Visualization: Density of Pythagorean Sines in [0, 1]

Shows how the sine values a/c from primitive Pythagorean triples
(a² + b² = c²) fill in the interval [0, 1] as the hypotenuse bound grows.
The density conjecture states that these values are dense in [0, 1].
"""

import math
import matplotlib.pyplot as plt
import numpy as np
from collections import deque


def berggren_A(a, b, c):
    return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

def berggren_B(a, b, c):
    return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

def berggren_C(a, b, c):
    return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

def generate_triples(max_c):
    triples = []
    queue = deque([(3, 4, 5)])
    while queue:
        a, b, c = queue.popleft()
        a, b = min(abs(a), abs(b)), max(abs(a), abs(b))
        if c <= max_c and a > 0 and b > 0:
            triples.append((a, b, c))
            for T in [berggren_A, berggren_B, berggren_C]:
                na, nb, nc = T(a, b, c)
                if nc <= max_c:
                    queue.append((abs(na), abs(nb), nc))
    return triples


fig, axes = plt.subplots(3, 1, figsize=(12, 10))

bounds = [100, 1000, 10000]
for idx, max_c in enumerate(bounds):
    ax = axes[idx]
    triples = generate_triples(max_c)
    sines = sorted(set(a / c for a, b, c in triples))
    
    # Plot sine values as vertical lines
    ax.vlines(sines, 0, 1, alpha=0.3, linewidth=0.5, color='navy')
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1.2)
    ax.set_title(f'Pythagorean sines with c ≤ {max_c} ({len(sines)} values)', fontsize=12)
    ax.set_xlabel('Sine value a/c')
    ax.set_ylabel('Density')
    
    # Overlay histogram
    if len(sines) > 10:
        ax.hist(sines, bins=50, density=True, alpha=0.4, color='steelblue', label='Distribution')
    
    # Mark max gap
    if len(sines) > 1:
        gaps = [sines[i+1] - sines[i] for i in range(len(sines) - 1)]
        max_gap = max(gaps)
        max_gap_idx = gaps.index(max_gap)
        ax.axvspan(sines[max_gap_idx], sines[max_gap_idx + 1], 
                   alpha=0.3, color='red', label=f'Max gap: {max_gap:.4f}')
    
    ax.legend(loc='upper right')

plt.suptitle('Density of Pythagorean Sines: Evidence for the Density Conjecture', 
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_sine_density.png', dpi=150, bbox_inches='tight')
print("Saved viz_sine_density.png")
