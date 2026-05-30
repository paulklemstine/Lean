#!/usr/bin/env python3
"""
Visualization: Hyperbolic Lattice on the Poincaré Disk

Visualizes the orbit of the origin under PSL(2,Z) in the Poincaré disk model,
showing how "hyperbolic integers" tile the hyperbolic plane. Hyperbolic primes
are highlighted in red.

This illustrates the core concept of hyperbolic number theory: arithmetic
on a curved space where the density of lattice points grows exponentially
with distance from the origin.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from typing import List, Tuple, Set


def moebius_add(z: complex, w: complex) -> complex:
    denom = 1 + z.conjugate() * w
    if abs(denom) < 1e-15:
        return 0j
    return (z + w) / denom


def generate_psl2z_orbit(max_depth: int = 5) -> List[complex]:
    """Generate orbit of i under PSL(2,Z), mapped to Poincaré disk."""
    S = np.array([[0, -1], [1, 0]], dtype=float)
    T = np.array([[1, 1], [0, 1]], dtype=float)
    Si = np.array([[0, 1], [-1, 0]], dtype=float)
    Ti = np.array([[1, -1], [0, 1]], dtype=float)
    gens = [S, T, Si, Ti]
    
    base = 1j
    orbit = set()
    visited = set()
    
    def mat_key(M):
        return tuple(np.round(M.flatten(), 8))
    
    current = [np.eye(2)]
    visited.add(mat_key(np.eye(2)))
    
    def act(M, z):
        d = M[1, 0] * z + M[1, 1]
        if abs(d) < 1e-15:
            return None
        return (M[0, 0] * z + M[0, 1]) / d
    
    def cayley(z):
        return (z - 1j) / (z + 1j)
    
    for _ in range(max_depth):
        nxt = []
        for M in current:
            for g in gens:
                M2 = M @ g
                k = mat_key(M2)
                k_neg = mat_key(-M2)
                if k not in visited and k_neg not in visited:
                    visited.add(k)
                    z = act(M2, base)
                    if z is not None and z.imag > 1e-10:
                        w = cayley(z)
                        if abs(w) < 1 - 1e-10:
                            orbit.add((round(w.real, 10), round(w.imag, 10)))
                    nxt.append(M2)
        current = nxt
    
    return sorted([complex(r, i) for r, i in orbit], key=abs)


def is_hyp_prime(orbit, n, tol=1e-5):
    if n <= 0:
        return False
    target = orbit[n]
    for i in range(1, min(n, 30)):
        for j in range(1, min(n, 30)):
            w = moebius_add(orbit[i], orbit[j])
            if abs(w - target) < tol:
                return False
    return True


# Generate lattice
orbit = generate_psl2z_orbit(4)

# Classify primes
primes = []
composites = []
for n in range(len(orbit)):
    if n == 0:
        continue
    if n < 40 and is_hyp_prime(orbit, n):
        primes.append(orbit[n])
    else:
        composites.append(orbit[n])

# Plot
fig, ax = plt.subplots(1, 1, figsize=(10, 10))

# Draw unit circle
circle = plt.Circle((0, 0), 1, fill=False, color='black', linewidth=2)
ax.add_patch(circle)

# Draw some geodesics (arcs)
theta = np.linspace(0, 2*np.pi, 100)
for r in [0.3, 0.5, 0.7, 0.9]:
    ax.plot(r * np.cos(theta), r * np.sin(theta), 'k-', alpha=0.1, linewidth=0.5)

# Plot composites
if composites:
    cx = [z.real for z in composites]
    cy = [z.imag for z in composites]
    ax.scatter(cx, cy, c='steelblue', s=15, alpha=0.6, zorder=3, label='Composite')

# Plot primes
if primes:
    px = [z.real for z in primes]
    py = [z.imag for z in primes]
    ax.scatter(px, py, c='crimson', s=40, alpha=0.9, zorder=4, marker='*', label='Hyperbolic Prime')

# Plot origin
ax.scatter([0], [0], c='gold', s=100, zorder=5, marker='o', edgecolors='black',
           linewidth=2, label='Origin')

ax.set_xlim(-1.15, 1.15)
ax.set_ylim(-1.15, 1.15)
ax.set_aspect('equal')
ax.set_title('Hyperbolic Integers: PSL(2,ℤ) Orbit on the Poincaré Disk',
             fontsize=14, fontweight='bold')
ax.legend(loc='upper right', fontsize=11)
ax.set_xlabel('Re(z)', fontsize=12)
ax.set_ylabel('Im(z)', fontsize=12)

# Add annotation
ax.text(0.02, -1.08, f'{len(orbit)} lattice points | {len(primes)} primes detected',
        fontsize=10, style='italic', color='gray')

plt.tight_layout()
plt.savefig('viz_poincare_lattice.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_poincare_lattice.png")
