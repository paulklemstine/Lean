#!/usr/bin/env python3
"""
Visualization 1: Möbius Addition on the Poincaré Disk

Shows how Möbius addition maps pairs of disk points to new disk points,
illustrating the fundamental disk-preservation theorem. The plot shows
the action of a ⊕ · for several fixed values of a, demonstrating how
the gyrogroup operation "compresses" space near the boundary.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches

def moebius_add(a, b):
    """Möbius addition: (a+b)/(1+ab)"""
    return (a + b) / (1 + a * b)

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Panel 1: Möbius addition curves
ax = axes[0]
b_vals = np.linspace(-0.99, 0.99, 500)
a_fixed = [0.0, 0.2, 0.4, 0.6, 0.8, -0.3, -0.6]
colors = plt.cm.coolwarm(np.linspace(0.1, 0.9, len(a_fixed)))

for a, color in zip(a_fixed, colors):
    result = moebius_add(a, b_vals)
    ax.plot(b_vals, result, color=color, label=f'a={a:.1f}', linewidth=1.5)

ax.axhline(y=1, color='red', linestyle='--', alpha=0.5, label='Boundary')
ax.axhline(y=-1, color='red', linestyle='--', alpha=0.5)
ax.axhline(y=0, color='gray', linestyle=':', alpha=0.3)
ax.axvline(x=0, color='gray', linestyle=':', alpha=0.3)
ax.set_xlim(-1, 1)
ax.set_ylim(-1.1, 1.1)
ax.set_xlabel('b', fontsize=12)
ax.set_ylabel('a ⊕ b', fontsize=12)
ax.set_title('Möbius Addition: a ⊕ b', fontsize=14)
ax.legend(fontsize=8, loc='upper left')

# Panel 2: Iteration sequence
ax = axes[1]
starting_points = [0.1, 0.2, 0.3, 0.5, 0.7, 0.9]
colors2 = plt.cm.viridis(np.linspace(0.1, 0.9, len(starting_points)))

for a, color in zip(starting_points, colors2):
    seq = [a]
    x = a
    for _ in range(30):
        x = moebius_add(a, x)
        seq.append(x)
    ax.plot(range(len(seq)), seq, 'o-', color=color, markersize=3, 
            label=f'a={a}', linewidth=1.2)

ax.axhline(y=1, color='red', linestyle='--', alpha=0.5, label='Boundary')
ax.set_xlabel('Iteration n', fontsize=12)
ax.set_ylabel('x_n', fontsize=12)
ax.set_title('Möbius Iteration: x_{n+1} = a ⊕ x_n', fontsize=14)
ax.legend(fontsize=8)
ax.set_ylim(0, 1.05)

# Panel 3: Pythagorean points on the disk
ax = axes[2]
circle = plt.Circle((0, 0), 1, fill=False, color='red', linewidth=2, linestyle='--')
ax.add_patch(circle)

# Generate Pythagorean triples and embed
triples = []
for m in range(2, 25):
    for n in range(1, m):
        if (m - n) % 2 == 0:
            continue
        import math
        if math.gcd(m, n) != 1:
            continue
        a = m*m - n*n
        b = 2*m*n
        c = m*m + n*n
        triples.append((min(a,b), max(a,b), c))

x_pts = [a/c for a, b, c in triples]
y_pts = [b/c for a, b, c in triples]

ax.scatter(x_pts, y_pts, c='blue', s=15, alpha=0.6, label='a/c, b/c')

# Show some Möbius sums
for i in range(min(10, len(triples)-1)):
    r1 = triples[i][0] / triples[i][2]
    r2 = triples[i+1][0] / triples[i+1][2]
    ms = moebius_add(r1, r2)
    ax.plot([r1, ms], [triples[i][1]/triples[i][2], 0.02], 'g-', alpha=0.3)
    ax.scatter([ms], [0.02], c='green', s=20, marker='x', zorder=5)

ax.set_xlim(-1.1, 1.1)
ax.set_ylim(-0.1, 1.1)
ax.set_aspect('equal')
ax.set_xlabel('a/c', fontsize=12)
ax.set_ylabel('b/c', fontsize=12)
ax.set_title('Pythagorean Points on the Disk', fontsize=14)
ax.legend(fontsize=9)

plt.tight_layout()
plt.savefig('viz_moebius_disk.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_moebius_disk.png")
