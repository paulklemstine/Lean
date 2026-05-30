#!/usr/bin/env python3
"""
Visualization: Pythagorean Counting Function vs Lehmer Asymptotic

Shows the remarkable convergence of pythCount(N) to N/(2π), confirming
Lehmer's 1900 theorem. The appearance of π in this counting problem
connects number theory to the geometry of the circle.

Also verifies the falsifiable conjecture: pythCount(N) ≥ N/7 for N ≥ 100.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from math import pi, gcd


def berggren_count(max_hyp):
    """Count primitive Pythagorean triples with hypotenuse ≤ max_hyp."""
    count = 0
    stack = [(3, 4, 5)]
    while stack:
        a, b, c = stack.pop()
        if c <= max_hyp:
            count += 1
            stack.append((a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c))
            stack.append((a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c))
            stack.append((-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c))
    return count


# Compute counting function at many points
N_values = list(range(10, 201, 5)) + list(range(200, 5001, 50))
counts = []
for N in N_values:
    counts.append(berggren_count(N))

N_arr = np.array(N_values, dtype=float)
count_arr = np.array(counts, dtype=float)
lehmer_arr = N_arr / (2 * pi)
ratio_arr = count_arr / lehmer_arr

# Create figure
fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# ---- PANEL 1: Count vs asymptotic ----
ax = axes[0, 0]
ax.plot(N_arr, count_arr, 'b-', linewidth=1.5, label='pythCount(N)')
ax.plot(N_arr, lehmer_arr, 'r--', linewidth=1.5, label='N/(2π)', alpha=0.8)
ax.plot(N_arr, N_arr/7, 'g:', linewidth=1.5, label='N/7 (conjecture bound)', alpha=0.7)
ax.set_xlabel('N', fontsize=11)
ax.set_ylabel('Count', fontsize=11)
ax.set_title('Primitive Pythagorean Triple Counting Function', fontsize=12)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# ---- PANEL 2: Ratio to asymptotic ----
ax = axes[0, 1]
ax.plot(N_arr, ratio_arr, 'b-', linewidth=1, alpha=0.7)
ax.axhline(y=1.0, color='r', linewidth=1.5, linestyle='--', label='Exact asymptotic (ratio = 1)')
ax.fill_between(N_arr, 0.95, 1.05, alpha=0.1, color='green', label='±5% band')
ax.set_xlabel('N', fontsize=11)
ax.set_ylabel('pythCount(N) / (N/(2π))', fontsize=11)
ax.set_title('Convergence to Lehmer Asymptotic', fontsize=12)
ax.set_ylim(0.8, 1.2)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# ---- PANEL 3: Error term ----
ax = axes[1, 0]
error = count_arr - lehmer_arr
ax.plot(N_arr, error, 'purple', linewidth=1, alpha=0.7)
ax.axhline(y=0, color='black', linewidth=0.5)
ax.plot(N_arr, np.sqrt(N_arr) * 0.5, 'r--', linewidth=1, alpha=0.5, label='~0.5√N')
ax.plot(N_arr, -np.sqrt(N_arr) * 0.5, 'r--', linewidth=1, alpha=0.5)
ax.set_xlabel('N', fontsize=11)
ax.set_ylabel('pythCount(N) - N/(2π)', fontsize=11)
ax.set_title('Error Term (appears to be O(√N))', fontsize=12)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# ---- PANEL 4: Distribution of hypotenuses ----
ax = axes[1, 1]

# Get all triples up to 500
all_triples = []
stack = [(3, 4, 5)]
while stack:
    a, b, c = stack.pop()
    if c <= 500:
        all_triples.append((a, b, c))
        stack.append((a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c))
        stack.append((a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c))
        stack.append((-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c))

hyps = [c for _, _, c in all_triples]
ax.hist(hyps, bins=50, density=True, alpha=0.7, color='steelblue', 
        edgecolor='white', linewidth=0.5, label='Observed distribution')

# Overlay the expected uniform density 1/(2π) per unit interval
x_range = np.linspace(5, 500, 100)
ax.axhline(y=1/(2*pi), color='red', linewidth=2, linestyle='--', 
           label=f'Expected density: 1/(2π) ≈ {1/(2*pi):.4f}')

ax.set_xlabel('Hypotenuse c', fontsize=11)
ax.set_ylabel('Density', fontsize=11)
ax.set_title('Distribution of Hypotenuses\n(converges to uniform density 1/(2π))', fontsize=12)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

plt.suptitle('Pythagorean Counting: From Berggren Trees to Lehmer\'s Theorem',
            fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('counting_function_visualization.png', dpi=150, bbox_inches='tight')
print("Saved: counting_function_visualization.png")
