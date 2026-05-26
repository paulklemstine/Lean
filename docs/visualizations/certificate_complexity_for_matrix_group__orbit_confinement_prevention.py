#!/usr/bin/env python3
"""
Visualization: Orbit Confinement Prevention

Demonstrates the cross-domain theorem: when generators have irreducible
characteristic polynomials, orbits cannot be confined to proper subspaces.
Contrasts certified (irreducible charpoly) vs uncertified (reducible charpoly)
generators to show the dramatic difference in orbit behavior.
"""

import matplotlib.pyplot as plt
import numpy as np
import random

random.seed(42)

def mat_mult_mod(A, B, p):
    return (A @ B) % p

def mat_vec_mod(A, v, p):
    return (A @ v) % p

def is_irred_charpoly_2x2_np(M, p):
    tr = int((M[0,0] + M[1,1]) % p)
    det = int((M[0,0]*M[1,1] - M[0,1]*M[1,0]) % p)
    if det == 0:
        return False
    disc = (tr*tr - 4*det) % p
    if disc == 0:
        return False
    if p == 2:
        return True
    return pow(disc, (p-1)//2, p) == p - 1

def find_certified_pair(p):
    """Find a pair where both g and h have irreducible charpolys."""
    for _ in range(10000):
        g = np.array([[random.randint(0,p-1) for _ in range(2)] for _ in range(2)])
        h = np.array([[random.randint(0,p-1) for _ in range(2)] for _ in range(2)])
        if (is_irred_charpoly_2x2_np(g, p) and is_irred_charpoly_2x2_np(h, p)):
            gh = mat_mult_mod(g, h, p)
            if is_irred_charpoly_2x2_np(gh, p):
                return g, h
    return None, None

def find_reducible_pair(p):
    """Find a pair where g has a reducible charpoly (has an eigenvector over F_p)."""
    for _ in range(10000):
        # Upper triangular matrix has reducible charpoly
        a, d = random.randint(1, p-1), random.randint(1, p-1)
        b = random.randint(0, p-1)
        g = np.array([[a, b], [0, d]])
        
        a2, d2 = random.randint(1, p-1), random.randint(1, p-1)
        b2 = random.randint(0, p-1)
        h = np.array([[a2, b2], [0, d2]])
        return g, h
    return None, None

def compute_word_orbit(g, h, v, p, n_steps=200):
    """Compute orbit under random words in g, h."""
    g_inv = np.array([[g[1,1], (-g[0,1]) % p], [(-g[1,0]) % p, g[0,0]]], dtype=int)
    det_g = int((g[0,0]*g[1,1] - g[0,1]*g[1,0]) % p)
    det_inv = pow(det_g, p-2, p)
    g_inv = (g_inv * det_inv) % p
    
    h_inv = np.array([[h[1,1], (-h[0,1]) % p], [(-h[1,0]) % p, h[0,0]]], dtype=int)
    det_h = int((h[0,0]*h[1,1] - h[0,1]*h[1,0]) % p)
    det_inv_h = pow(det_h, p-2, p)
    h_inv = (h_inv * det_inv_h) % p
    
    gens = [g, h, g_inv, h_inv]
    orbit = [v.copy()]
    current = v.copy()
    
    for _ in range(n_steps):
        gen = random.choice(gens)
        current = mat_vec_mod(gen, current, p)
        orbit.append(current.copy())
    
    return orbit

p = 23  # Use a prime large enough to see structure

# Find certified and uncertified pairs
g_cert, h_cert = find_certified_pair(p)
g_red, h_red = find_reducible_pair(p)

v0 = np.array([1, 0], dtype=int)

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: Certified pair (irreducible charpolys) - orbit fills the plane
ax1 = axes[0]
if g_cert is not None:
    orbit_cert = compute_word_orbit(g_cert, h_cert, v0, p, n_steps=500)
    xs = [int(o[0]) for o in orbit_cert]
    ys = [int(o[1]) for o in orbit_cert]
    
    # Color by step number to show trajectory
    colors = np.linspace(0, 1, len(xs))
    scatter1 = ax1.scatter(xs, ys, c=colors, cmap='viridis', s=15, alpha=0.6)
    ax1.scatter([xs[0]], [ys[0]], c='red', s=100, marker='*', zorder=5,
                label='Start')
    
    unique_points = len(set(zip(xs, ys)))
    total_points = p * p
    
    ax1.set_title(f'Certified Pair (Irreducible Charpolys)\n'
                  f'{unique_points} distinct points visited '
                  f'({unique_points}/{total_points} = {unique_points/total_points:.0%})',
                  fontsize=12, fontweight='bold')
else:
    ax1.text(0.5, 0.5, 'No certified pair found', transform=ax1.transAxes,
             ha='center')

ax1.set_xlabel('x coordinate (mod p)', fontsize=12)
ax1.set_ylabel('y coordinate (mod p)', fontsize=12)
ax1.set_xlim(-0.5, p - 0.5)
ax1.set_ylim(-0.5, p - 0.5)
ax1.set_aspect('equal')
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.2)

# Right: Uncertified pair (reducible charpolys) - orbit confined to subspace
ax2 = axes[1]
if g_red is not None:
    orbit_red = compute_word_orbit(g_red, h_red, v0, p, n_steps=500)
    xs = [int(o[0]) for o in orbit_red]
    ys = [int(o[1]) for o in orbit_red]
    
    colors = np.linspace(0, 1, len(xs))
    scatter2 = ax2.scatter(xs, ys, c=colors, cmap='magma', s=15, alpha=0.6)
    ax2.scatter([xs[0]], [ys[0]], c='red', s=100, marker='*', zorder=5,
                label='Start')
    
    unique_points = len(set(zip(xs, ys)))
    
    # Show the invariant line y=0
    ax2.axhline(y=0, color='red', linestyle='--', linewidth=2, alpha=0.5,
                label='Invariant subspace y=0')
    
    ax2.set_title(f'Uncertified Pair (Reducible — Upper Triangular)\n'
                  f'{unique_points} distinct points visited '
                  f'(confined near invariant line)',
                  fontsize=12, fontweight='bold')
else:
    ax2.text(0.5, 0.5, 'No reducible pair found', transform=ax2.transAxes,
             ha='center')

ax2.set_xlabel('x coordinate (mod p)', fontsize=12)
ax2.set_ylabel('y coordinate (mod p)', fontsize=12)
ax2.set_xlim(-0.5, p - 0.5)
ax2.set_ylim(-0.5, p - 0.5)
ax2.set_aspect('equal')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.2)

plt.suptitle(f'Orbit Confinement Prevention in GL(2, 𝔽₂₃)',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('orbit_confinement.png', dpi=150, bbox_inches='tight')
print("Saved orbit_confinement.png")
