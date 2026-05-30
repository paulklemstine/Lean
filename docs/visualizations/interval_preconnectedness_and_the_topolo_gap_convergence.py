"""
Visualization: Convergence of Maximum Gap in Pythagorean Sines

Tests the density conjecture by showing how the maximum gap between
consecutive Pythagorean sine values shrinks as the hypotenuse bound grows.
If the conjecture is true, this gap → 0 as the bound → ∞.
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
    seen = set()
    while queue:
        a, b, c = queue.popleft()
        a, b = min(abs(a), abs(b)), max(abs(a), abs(b))
        key = (a, b, c)
        if key in seen or c > max_c or a <= 0 or b <= 0:
            continue
        seen.add(key)
        triples.append((a, b, c))
        for T in [berggren_A, berggren_B, berggren_C]:
            na, nb, nc = T(a, b, c)
            if nc <= max_c and nc > 0:
                queue.append((abs(na), abs(nb), nc))
    return triples


# Compute convergence data
bounds = [50, 100, 200, 500, 1000, 2000, 5000, 10000, 20000]
max_gaps = []
mean_gaps = []
num_sines = []

for max_c in bounds:
    triples = generate_triples(max_c)
    sines = sorted(set(a / c for a, b, c in triples))
    num_sines.append(len(sines))
    if len(sines) > 1:
        gaps = [sines[i+1] - sines[i] for i in range(len(sines) - 1)]
        max_gaps.append(max(gaps))
        mean_gaps.append(sum(gaps) / len(gaps))
    else:
        max_gaps.append(1.0)
        mean_gaps.append(1.0)

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Plot 1: Max gap vs bound (log-log)
ax = axes[0, 0]
ax.loglog(bounds, max_gaps, 'ro-', linewidth=2, markersize=8, label='Max gap')
ax.loglog(bounds, mean_gaps, 'bs-', linewidth=2, markersize=6, label='Mean gap')
# Fit power law
log_b = np.log(bounds[-4:])
log_g = np.log(max_gaps[-4:])
slope = np.polyfit(log_b, log_g, 1)[0]
ax.set_xlabel('Hypotenuse bound (c_max)', fontsize=12)
ax.set_ylabel('Gap size', fontsize=12)
ax.set_title(f'Gap Convergence (power law slope ≈ {slope:.2f})', fontsize=13)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

# Plot 2: Number of distinct sines
ax = axes[0, 1]
ax.loglog(bounds, num_sines, 'go-', linewidth=2, markersize=8)
ax.set_xlabel('Hypotenuse bound (c_max)', fontsize=12)
ax.set_ylabel('Number of distinct sines', fontsize=12)
ax.set_title('Growth of Pythagorean Sine Count', fontsize=13)
ax.grid(True, alpha=0.3)

# Plot 3: Gap distribution for large bound
ax = axes[1, 0]
triples = generate_triples(5000)
sines = sorted(set(a / c for a, b, c in triples))
gaps = [sines[i+1] - sines[i] for i in range(len(sines) - 1)]
ax.hist(gaps, bins=50, color='steelblue', edgecolor='black', alpha=0.7)
ax.axvline(x=np.mean(gaps), color='red', linestyle='--', label=f'Mean: {np.mean(gaps):.4f}')
ax.set_xlabel('Gap size', fontsize=12)
ax.set_ylabel('Frequency', fontsize=12)
ax.set_title(f'Gap Distribution (c ≤ 5000, n={len(sines)})', fontsize=13)
ax.legend(fontsize=11)

# Plot 4: Sine values colored by gap to next
ax = axes[1, 1]
gap_colors = gaps + [0]  # Last point has no gap
scatter = ax.scatter(sines, [1]*len(sines), c=gap_colors, 
                      cmap='hot_r', s=1, alpha=0.5)
plt.colorbar(scatter, ax=ax, label='Gap to next sine')
ax.set_xlim(0, 1)
ax.set_yticks([])
ax.set_xlabel('Sine value a/c', fontsize=12)
ax.set_title('Sine Values Colored by Gap Size', fontsize=13)

plt.suptitle('Evidence for the Pythagorean Sine Density Conjecture', 
             fontsize=15, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_convergence.png', dpi=150, bbox_inches='tight')
print("Saved viz_convergence.png")
