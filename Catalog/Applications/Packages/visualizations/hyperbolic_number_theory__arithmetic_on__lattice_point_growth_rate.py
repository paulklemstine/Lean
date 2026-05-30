#!/usr/bin/env python3
"""
Visualization 2: Lattice Point Growth Rate

Plots the counting function N(r) against the theoretical prediction C/(1-r²),
demonstrating the hyperbolic analogue of the prime number theorem.
The linear relationship on a log-log scale confirms exponential growth
in hyperbolic radius.
"""

import numpy as np
import matplotlib.pyplot as plt
from collections import deque


def cayley_to_disk(z):
    return (z - 1j) / (z + 1j)


def generate_psl2z_orbit(max_points=2000, max_depth=10):
    visited = {}
    queue = deque()
    basepoint = complex(0, 1)
    
    def canonical(z):
        return (round(z.real * 1e8), round(z.imag * 1e8))
    
    visited[canonical(basepoint)] = basepoint
    queue.append((basepoint, 0))
    
    while queue and len(visited) < max_points:
        z, depth = queue.popleft()
        if depth >= max_depth:
            continue
        transforms = []
        if abs(z) > 1e-10:
            transforms.append(-1/z)
        transforms.append(z + 1)
        transforms.append(z - 1)
        for w in transforms:
            if w.imag < 1e-10:
                continue
            key = canonical(w)
            if key not in visited:
                visited[key] = w
                queue.append((w, depth + 1))
    
    disk_points = []
    for z_uhp in visited.values():
        z_disk = cayley_to_disk(z_uhp)
        if abs(z_disk) < 1 - 1e-12:
            disk_points.append(z_disk)
    return sorted(disk_points, key=abs)


# Generate a large lattice
lattice = generate_psl2z_orbit(max_points=1500, max_depth=10)

# Compute counting function
radii = np.linspace(0.05, 0.98, 200)
counts = [sum(1 for z in lattice if abs(z) < r) for r in radii]

# Theoretical prediction
theory = [1 / (1 - r**2) for r in radii]

# Fit constant C
valid = [(c, t) for c, t in zip(counts, theory) if c > 5 and t > 2]
if valid:
    cs, ts = zip(*valid)
    C_fit = np.dot(cs, ts) / np.dot(ts, ts)
else:
    C_fit = 1.0

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: N(r) vs C/(1-r²)
ax1 = axes[0]
ax1.plot(radii, counts, 'b-', linewidth=2, label=f'N(r) (data, {len(lattice)} pts)')
ax1.plot(radii, [C_fit * t for t in theory], 'r--', linewidth=2,
         label=f'C/(1-r²), C={C_fit:.2f}')
ax1.set_xlabel('Euclidean radius r', fontsize=12)
ax1.set_ylabel('Count N(r)', fontsize=12)
ax1.set_title('Lattice Point Counting Function', fontsize=13, fontweight='bold')
ax1.legend(fontsize=11)
ax1.grid(True, alpha=0.3)
ax1.set_xlim(0, 1)

# Right: Log-log ratio
ax2 = axes[1]
hyp_radii = [2 * np.arctanh(r) for r in radii if r < 0.99]
hyp_counts = [sum(1 for z in lattice if abs(z) < r) for r in radii if r < 0.99]

# Plot N(R) vs e^R in hyperbolic radius
ax2.semilogy([2 * np.arctanh(r) for r in radii if 0.1 < r < 0.98],
             [max(c, 0.5) for r, c in zip(radii, counts) if 0.1 < r < 0.98],
             'b-', linewidth=2, label='N(R) (data)')
R_range = np.linspace(0.2, 5, 100)
ax2.semilogy(R_range, C_fit * np.exp(R_range), 'r--', linewidth=2,
             label=f'C·e^R, C={C_fit:.2f}')
ax2.set_xlabel('Hyperbolic radius R = 2 arctanh(r)', fontsize=12)
ax2.set_ylabel('Count N(R)', fontsize=12)
ax2.set_title('Exponential Growth in Hyperbolic Radius', fontsize=13, fontweight='bold')
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)

plt.suptitle('Hyperbolic Prime Number Theorem: Lattice Growth Rate',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('growth_rate.png', dpi=150, bbox_inches='tight')
print(f"Saved growth_rate.png (C_fit = {C_fit:.4f}, 6/π = {6/np.pi:.4f})")
