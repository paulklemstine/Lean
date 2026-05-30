#!/usr/bin/env python3
"""
Visualization 1: PSL(2,Z) Lattice on the Poincaré Disk

Shows the orbit of the point i under PSL(2,Z), mapped to the Poincaré disk.
Hyperbolic primes are highlighted in red, composite points in blue.
The unit circle boundary represents infinity in hyperbolic geometry.
"""

import numpy as np
import matplotlib.pyplot as plt
from collections import deque
from typing import List, Dict, Tuple


def cayley_to_disk(z: complex) -> complex:
    return (z - 1j) / (z + 1j)


def generate_psl2z_orbit(max_points=500, max_depth=8):
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


def mobius_add(z, w):
    denom = 1 + np.conj(z) * w
    if abs(denom) < 1e-15:
        return complex(float('inf'), 0)
    return (z + w) / denom


def is_hyp_prime(z, points, tol=1e-5):
    r = abs(z)
    if r < tol:
        return False
    smaller = [w for w in points if tol < abs(w) < r - tol]
    for a in smaller:
        for b in smaller:
            s = mobius_add(a, b)
            if abs(s) < 1e10 and abs(s - z) < tol:
                return False
    return True


# Generate lattice
lattice = generate_psl2z_orbit(max_points=300, max_depth=7)

# Classify primes (only check first ~40 for speed)
n_check = min(40, len(lattice))
primes = []
composites = []
for i, z in enumerate(lattice[:n_check]):
    if abs(z) < 1e-5:
        continue
    if is_hyp_prime(z, lattice[:n_check]):
        primes.append(z)
    else:
        composites.append(z)

remaining = lattice[n_check:]

# Plot
fig, ax = plt.subplots(1, 1, figsize=(10, 10))

# Unit circle
theta = np.linspace(0, 2*np.pi, 200)
ax.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=2, alpha=0.8)

# Hyperbolic geodesic circles (circles of constant hyperbolic distance)
for r_hyp in [1, 2, 3, 4]:
    r_euc = np.tanh(r_hyp / 2)
    circle = r_euc * np.exp(1j * theta)
    ax.plot(circle.real, circle.imag, 'k--', alpha=0.15, linewidth=0.5)

# Plot remaining lattice points
if remaining:
    ax.scatter([z.real for z in remaining], [z.imag for z in remaining],
               c='lightblue', s=15, alpha=0.5, zorder=2, label='Lattice points')

# Plot composites
if composites:
    ax.scatter([z.real for z in composites], [z.imag for z in composites],
               c='steelblue', s=30, alpha=0.7, zorder=3, label='Composite')

# Plot primes
if primes:
    ax.scatter([z.real for z in primes], [z.imag for z in primes],
               c='crimson', s=60, marker='*', zorder=4, label='Hyperbolic primes')

# Origin
ax.plot(0, 0, 'ko', markersize=8, zorder=5)
ax.annotate('0', (0.02, 0.02), fontsize=12, fontweight='bold')

ax.set_xlim(-1.15, 1.15)
ax.set_ylim(-1.15, 1.15)
ax.set_aspect('equal')
ax.legend(fontsize=12, loc='upper right')
ax.set_title('PSL(2,ℤ) Lattice on the Poincaré Disk\nHyperbolic Primes (★) vs Composites (●)',
             fontsize=14, fontweight='bold')
ax.set_xlabel('Re(z)', fontsize=12)
ax.set_ylabel('Im(z)', fontsize=12)
ax.grid(True, alpha=0.2)

plt.tight_layout()
plt.savefig('poincare_lattice.png', dpi=150, bbox_inches='tight')
print("Saved poincare_lattice.png")
