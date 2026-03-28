#!/usr/bin/env python3
"""
Demo 6: N-Dimensional Pythagorean Tuples via Stereographic Projection
=====================================================================

Generates N-dimensional "Pythagorean tuples" — integer points on S^{N-1} —
using the N-dimensional inverse stereographic projection on rational inputs.

This generalizes the classical:
  2D: (3,4,5), (5,12,13), ...
  3D: (1,2,2,3), (2,3,6,7), ...
to arbitrary dimension.

Oracle Ψ's number-theoretic experiment.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import product
from collections import Counter

def inv_stereo_nd(y):
    """
    N-dimensional inverse stereographic projection.
    Input: y ∈ ℝ^N
    Output: point on S^N ⊂ ℝ^{N+1}

    Formula: x_i = 2y_i / D for i=1..N, x_{N+1} = (D-2)/D
    where D = 1 + ||y||²
    """
    y = np.array(y, dtype=float)
    norm_sq = np.sum(y**2)
    D = 1 + norm_sq
    x = np.zeros(len(y) + 1)
    x[:-1] = 2 * y / D
    x[-1] = (D - 2) / D
    return x

def generate_pythagorean_nd(N, max_param=10):
    """
    Generate N-dimensional Pythagorean (N+1)-tuples.

    For rational y = (a₁/d, ..., a_N/d), the inverse stereo gives a point on S^N.
    Scaling by d² + a₁² + ... + a_N² gives integer coordinates summing to
    (d² + a₁² + ... + a_N²)².

    Returns list of (tuple, denominator) pairs.
    """
    tuples = []
    for d in range(1, max_param + 1):
        for a_vals in product(range(-max_param, max_param + 1), repeat=N):
            a = np.array(a_vals, dtype=int)
            D = d**2 + np.sum(a**2)

            # The (N+1)-tuple
            coords = np.zeros(N + 1, dtype=int)
            for i in range(N):
                coords[i] = 2 * a[i] * d
            coords[N] = d**2 - np.sum(a**2)

            # Verify: sum of squares should equal D²
            if np.sum(coords**2) == D**2:
                # Normalize by GCD
                from math import gcd
                from functools import reduce
                g = reduce(gcd, [abs(c) for c in coords] + [D])
                normalized = tuple(c // g for c in coords)
                norm_D = D // g

                if all(c >= 0 for c in normalized) and normalized not in [t[0] for t in tuples]:
                    tuples.append((normalized, norm_D))

    # Sort by hypotenuse (D value)
    tuples.sort(key=lambda x: x[1])
    return tuples

# ─── Generate and visualize ───

fig, axes = plt.subplots(2, 3, figsize=(20, 14))

# === Dimension 2: Classical Pythagorean Triples ===
ax = axes[0, 0]
triples_2d = generate_pythagorean_nd(1, max_param=15)
# Filter unique primitives
seen = set()
primitive_triples = []
for t, D in triples_2d:
    if len(t) == 2 and t not in seen and all(c > 0 for c in t):
        seen.add(t)
        primitive_triples.append((t, D))

# Classic parametrization
classic = []
for m in range(1, 15):
    for n in range(1, m):
        a, b, c = 2*m*n, m*m - n*n, m*m + n*n
        if b > 0:
            a, b = min(a,b), max(a,b)
            classic.append((a, b, c))

classic = list(set(classic))
classic.sort(key=lambda x: x[2])

if classic:
    a_vals = [t[0] for t in classic[:30]]
    b_vals = [t[1] for t in classic[:30]]
    c_vals = [t[2] for t in classic[:30]]
    scatter = ax.scatter(a_vals, b_vals, c=c_vals, cmap='viridis',
                        s=80, edgecolors='black', linewidth=0.5)
    plt.colorbar(scatter, ax=ax, label='Hypotenuse c')
    ax.set_xlabel('a')
    ax.set_ylabel('b')

ax.set_title('2D: Pythagorean Triples (a,b,c)\na² + b² = c²', fontsize=13, fontweight='bold')
ax.grid(True, alpha=0.3)

# === Dimension 3: Pythagorean Quadruples ===
ax = axes[0, 1]
quads = []
for a in range(1, 30):
    for b in range(a, 30):
        for c in range(b, 30):
            d_sq = a*a + b*b + c*c
            d = int(np.sqrt(d_sq))
            if d*d == d_sq:
                quads.append((a, b, c, d))

if quads:
    a_vals = [q[0] for q in quads[:40]]
    b_vals = [q[1] for q in quads[:40]]
    c_vals = [q[2] for q in quads[:40]]
    d_vals = [q[3] for q in quads[:40]]
    scatter = ax.scatter(a_vals, b_vals, c=d_vals, cmap='plasma',
                        s=[c*5 for c in c_vals], edgecolors='black', linewidth=0.5,
                        alpha=0.7)
    plt.colorbar(scatter, ax=ax, label='Hypotenuse d')
    ax.set_xlabel('a')
    ax.set_ylabel('b')

ax.set_title('3D: Pythagorean Quadruples (a,b,c,d)\na² + b² + c² = d²',
            fontsize=13, fontweight='bold')
ax.grid(True, alpha=0.3)

# === Sum-of-squares representability by dimension ===
ax = axes[0, 2]
dims = range(2, 9)
representable_fraction = []

for N in dims:
    count = 0
    total = 100
    for n in range(1, total + 1):
        # Check if n is a sum of N squares (always true for N >= 4 by Lagrange)
        if N >= 4:
            count += 1
        elif N == 3:
            # Not a sum of 3 squares iff n = 4^a(8b+7)
            m = n
            while m % 4 == 0:
                m //= 4
            if m % 8 != 7:
                count += 1
        elif N == 2:
            # Sum of 2 squares: all prime factors ≡ 3 (mod 4) appear to even power
            m = n
            is_sum = True
            for p in range(2, int(np.sqrt(n)) + 1):
                if m % p == 0:
                    exp_count = 0
                    while m % p == 0:
                        exp_count += 1
                        m //= p
                    if p % 4 == 3 and exp_count % 2 == 1:
                        is_sum = False
                        break
            if m > 1 and m % 4 == 3:
                is_sum = False
            if is_sum:
                count += 1

    representable_fraction.append(count / total)

ax.bar(list(dims), representable_fraction, color=plt.cm.Set2(np.linspace(0, 1, len(list(dims)))),
      edgecolor='black')
ax.set_xlabel('Dimension N', fontsize=12)
ax.set_ylabel('Fraction representable as sum of N squares', fontsize=10)
ax.set_title('Sum-of-Squares Representability\n(of integers 1-100, by dimension)',
            fontsize=13, fontweight='bold')
ax.axhline(y=1.0, color='red', linestyle='--', alpha=0.5, label='100% (Lagrange, N≥4)')
ax.legend()

# === Stereo denominator distribution ===
ax = axes[1, 0]
# For 2D stereo with rational t = p/q, denominator is p² + q²
denoms = []
for p in range(1, 50):
    for q in range(1, 50):
        if np.gcd(p, q) == 1:
            denoms.append(p**2 + q**2)

ax.hist(denoms, bins=50, color='steelblue', edgecolor='black', alpha=0.7)
ax.set_xlabel('Denominator p² + q²', fontsize=12)
ax.set_ylabel('Count', fontsize=12)
ax.set_title('Distribution of Stereographic Denominators\n(= sums of two coprime squares)',
            fontsize=13, fontweight='bold')

# === Rational points on S¹ ===
ax = axes[1, 1]
theta_circle = np.linspace(0, 2*np.pi, 200)
ax.plot(np.cos(theta_circle), np.sin(theta_circle), 'b-', linewidth=2, alpha=0.3)

# Generate rational points via stereo
for p in range(-10, 11):
    for q in range(1, 11):
        if np.gcd(abs(p), q) == 1:
            t = p / q
            D = 1 + t**2
            x = 2*t / D
            y = (1 - t**2) / D
            size = max(5, 80 / q)
            ax.plot(x, y, 'ro', markersize=np.sqrt(size), alpha=0.6)

ax.set_xlim(-1.3, 1.3)
ax.set_ylim(-1.3, 1.3)
ax.set_aspect('equal')
ax.set_title('Rational Points on S¹\n(via stereographic projection of ℚ)',
            fontsize=13, fontweight='bold')
ax.grid(True, alpha=0.3)

# === N-dimensional sphere point count ===
ax = axes[1, 2]
# Count lattice points on spheres of radius √n for small dimensions
dims_count = [2, 3, 4]
colors_dim = plt.cm.Set1(np.linspace(0, 1, len(dims_count)))

for idx, N in enumerate(dims_count):
    counts = []
    radii = range(1, 20)
    for n in radii:
        count = 0
        from itertools import product as iprod
        bound = int(np.sqrt(n)) + 1
        for combo in iprod(range(-bound, bound + 1), repeat=N):
            if sum(x**2 for x in combo) == n:
                count += 1
        counts.append(count)

    ax.plot(list(radii), counts, 'o-', color=colors_dim[idx],
           label=f'N={N}', markersize=4, alpha=0.8)

ax.set_xlabel('n (radius² = n)', fontsize=12)
ax.set_ylabel('r_N(n) = #{representations}', fontsize=10)
ax.set_title('Lattice Points on S^{N-1}(√n)\nr_N(n) = representations as sum of N squares',
            fontsize=13, fontweight='bold')
ax.legend(fontsize=9)
ax.set_yscale('log')
ax.grid(True, alpha=0.3)

fig.suptitle('N-Dimensional Pythagorean Geometry via Stereographic Projection',
            fontsize=18, fontweight='bold', y=1.02)

plt.savefig('/workspace/request-project/Stereographic/NDimensional/Demos/demo6_nd_pythagorean.png',
           dpi=150, bbox_inches='tight')
plt.close()
print("✓ Demo 6 saved: demo6_nd_pythagorean.png")
