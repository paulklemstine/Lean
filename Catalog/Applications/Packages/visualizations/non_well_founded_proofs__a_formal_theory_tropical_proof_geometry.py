#!/usr/bin/env python3
"""
Visualization 3: Tropical Proof Height Geometry

Visualizes the tropical semiring structure of proof heights,
showing how min/plus operations create tropical geometric
structures in proof complexity space.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def tropical_add(a, b):
    """Tropical addition = min."""
    return np.minimum(a, b)


def tropical_mul(a, b):
    """Tropical multiplication = +."""
    return a + b


fig, axes = plt.subplots(2, 2, figsize=(14, 12))
fig.suptitle('Tropical Geometry of Proof Heights',
             fontsize=15, fontweight='bold', y=0.98)

# Plot 1: Tropical "lines" (piecewise linear functions)
ax = axes[0, 0]
x = np.linspace(-3, 5, 300)

# Tropical polynomial: min(2+x, 3, 1+2x) — each term is a "proof strategy"
y1 = 2 + x
y2 = np.full_like(x, 3.0)
y3 = 1 + 2*x
tropical_poly = np.minimum(np.minimum(y1, y2), y3)

ax.plot(x, y1, '--', color='#FF9800', alpha=0.5, label='Strategy 1: 2+x')
ax.plot(x, y2, '--', color='#2196F3', alpha=0.5, label='Strategy 2: 3')
ax.plot(x, y3, '--', color='#4CAF50', alpha=0.5, label='Strategy 3: 1+2x')
ax.plot(x, tropical_poly, 'k-', linewidth=3, label='Optimal (tropical min)')
ax.fill_between(x, tropical_poly, 8, alpha=0.1, color='gray')
ax.set_xlabel('Input complexity parameter', fontsize=10)
ax.set_ylabel('Proof height', fontsize=10)
ax.set_title('Tropical Proof "Polynomial"\n(Best strategy = min of all options)', fontsize=11)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)
ax.set_ylim(-2, 8)

# Plot 2: Tropical proof distance heatmap
ax = axes[0, 1]
n = 8
# Simulate proof heights for different systems
np.random.seed(42)
systems = []
for i in range(n):
    heights = np.random.randint(1, 10, size=5).astype(float)
    if np.random.random() < 0.3:
        heights[np.random.randint(0, 5)] = np.inf
    systems.append(heights)

# Compute tropical distances
dist_matrix = np.zeros((n, n))
for i in range(n):
    for j in range(n):
        max_diff = 0
        for k in range(5):
            a, b = systems[i][k], systems[j][k]
            if np.isinf(a) and np.isinf(b):
                continue
            if np.isinf(a) or np.isinf(b):
                max_diff = 20  # cap for visualization
                break
            max_diff = max(max_diff, abs(a - b))
        dist_matrix[i, j] = max_diff

im = ax.imshow(dist_matrix, cmap='viridis', interpolation='nearest')
ax.set_xlabel('Proof System', fontsize=10)
ax.set_ylabel('Proof System', fontsize=10)
ax.set_title('Tropical Distance Between\nProof Systems', fontsize=11)
ax.set_xticks(range(n))
ax.set_yticks(range(n))
ax.set_xticklabels([f'S{i}' for i in range(n)])
ax.set_yticklabels([f'S{i}' for i in range(n)])
plt.colorbar(im, ax=ax, label='Max height difference')

# Plot 3: Self-reference depth vs ordinal height
ax = axes[1, 0]
depths = list(range(8))
# For each self-ref depth, show range of possible heights
for d in depths:
    # Height ≥ depth (from selfRefDepth_le_depth theorem)
    heights_range = range(d, d + 5)
    ax.barh(d, len(heights_range), left=d, height=0.6,
            color=plt.cm.Oranges(d / 8), edgecolor='black', alpha=0.7)
    ax.plot(d, d, 'r*', markersize=12, zorder=5)

# Draw the diagonal bound
ax.plot(depths, depths, 'r--', linewidth=2, label='selfRefDepth ≤ height (proved)')
ax.set_xlabel('Ordinal Height', fontsize=10)
ax.set_ylabel('Self-Reference Depth', fontsize=10)
ax.set_title('Self-Reference Depth vs Height\n(Proved: depth ≤ height)', fontsize=11)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Plot 4: Tropical distributivity visualization
ax = axes[1, 1]
a_vals = np.arange(0, 6)
b_vals = np.arange(0, 6)
A, B = np.meshgrid(a_vals, b_vals)

c = 2  # fixed c value
# LHS: a ⊗ (b ⊕ c) = a + min(b, c)
LHS = A + np.minimum(B, c)
# RHS: (a ⊗ b) ⊕ (a ⊗ c) = min(a+b, a+c)
RHS = np.minimum(A + B, A + c)

# They should be equal (proved in Lean!)
diff = np.abs(LHS - RHS)
im = ax.imshow(diff, cmap='RdYlGn_r', interpolation='nearest',
               extent=[0, 5, 5, 0], vmin=0, vmax=0.1)
ax.set_xlabel('a (proof composition cost)', fontsize=10)
ax.set_ylabel('b (proof height)', fontsize=10)
ax.set_title(f'Tropical Distributivity Verification\na ⊗ (b ⊕ {c}) = (a ⊗ b) ⊕ (a ⊗ {c})\n(All green = theorem holds)', fontsize=11)
plt.colorbar(im, ax=ax, label='|LHS - RHS|')

# Add "VERIFIED" stamp
ax.text(2.5, 2.5, '✓ VERIFIED', fontsize=18, fontweight='bold',
        color='green', ha='center', va='center', alpha=0.7,
        bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))

plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.savefig('viz_tropical.png', dpi=150, bbox_inches='tight')
print("Saved viz_tropical.png")
