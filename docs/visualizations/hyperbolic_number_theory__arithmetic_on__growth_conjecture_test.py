"""
Visualization 3: Hyperbolic Growth Conjecture Test
====================================================
Tests the conjecture that N(r) · (1-r²) converges to a constant
as r → 1, where N(r) counts orbit points within Euclidean radius r.
This is the hyperbolic analogue of the Gauss circle problem.
"""

import numpy as np
import matplotlib.pyplot as plt
import math

# === Inline all functions ===

def sl2_mul(g, h):
    a1,b1,c1,d1 = g
    a2,b2,c2,d2 = h
    return (a1*a2+b1*c2, a1*b2+b1*d2, c1*a2+d1*c2, c1*b2+d1*d2)

def generate_orbit(max_depth):
    S = (0,-1,1,0)
    T = (1,1,0,1)
    Ti = (1,-1,0,1)
    gens = [S, T, Ti]
    orbit = {}
    identity = (1,0,0,1)
    key = lambda g: tuple(round(x, 6) for x in g)
    orbit[key(identity)] = identity
    frontier = [identity]
    for _ in range(max_depth):
        nf = []
        for g in frontier:
            for gen in gens:
                h = sl2_mul(g, gen)
                k = key(h)
                if k not in orbit:
                    orbit[k] = h
                    nf.append(h)
        frontier = nf
    return list(orbit.values())

def to_disk(g):
    a,b,c,d = g
    denom = c**2 + d**2
    if denom < 1e-15: return None
    re_z = (a*c + b*d) / denom
    im_z = (a*d - b*c) / denom
    num_re, num_im = re_z, im_z - 1
    den_re, den_im = re_z, im_z + 1
    den_sq = den_re**2 + den_im**2
    if den_sq < 1e-15: return None
    w_re = (num_re*den_re + num_im*den_im) / den_sq
    w_im = (num_im*den_re - num_re*den_im) / den_sq
    r_sq = w_re**2 + w_im**2
    return (w_re, w_im, r_sq) if r_sq < 1 - 1e-10 else None

# === Generate data ===
print("Generating orbit...")
matrices = generate_orbit(8)
points = []
for g in matrices:
    pt = to_disk(g)
    if pt:
        points.append(pt)

print(f"Total points: {len(points)}")

# Compute counting function
r_vals = np.linspace(0.05, 0.98, 200)
counts = []
for r in r_vals:
    r_sq = r**2
    count = sum(1 for _, _, rsq in points if rsq <= r_sq)
    counts.append(count)

counts = np.array(counts, dtype=float)
normalized = counts * (1 - r_vals**2)

# Also compute expected: N(r) ~ C/(1-r²)
# In hyperbolic radius R, the area of a disk is 4π sinh²(R/2)
# and r = tanh(R/2), so 1-r² = 1/cosh²(R/2)
# N(R) ~ cR for hyperbolic counting => N(r) ~ c/(1-r²)

# === Plot ===
fig, axes = plt.subplots(2, 2, figsize=(14, 10), facecolor='white')

# Top left: N(r) raw count
ax = axes[0, 0]
ax.plot(r_vals, counts, '-', color='#2c3e50', linewidth=1.5)
ax.set_xlabel('Euclidean radius r', fontsize=11)
ax.set_ylabel('N(r)', fontsize=11)
ax.set_title('Counting Function N(r)', fontsize=13)
ax.grid(True, alpha=0.3)

# Top right: N(r) on log scale
ax = axes[0, 1]
mask = counts > 0
ax.semilogy(r_vals[mask], counts[mask], '-', color='#e74c3c', linewidth=1.5)
# Fit: N(r) ~ C/(1-r²)
ax.semilogy(r_vals, 3 / (1 - r_vals**2), '--', color='#3498db', linewidth=1,
            alpha=0.7, label=r'$3/(1-r^2)$')
ax.set_xlabel('Euclidean radius r', fontsize=11)
ax.set_ylabel('N(r) (log scale)', fontsize=11)
ax.set_title('Growth Rate (log scale)', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Bottom left: Normalized N(r)·(1-r²)
ax = axes[1, 0]
mask2 = (r_vals > 0.3) & (counts > 0)
ax.plot(r_vals[mask2], normalized[mask2], '-', color='#2ecc71', linewidth=1.5)
ax.axhline(y=np.median(normalized[mask2 & (r_vals > 0.7)]), 
           color='#e74c3c', linestyle='--', linewidth=1, 
           label=f'Median = {np.median(normalized[mask2 & (r_vals > 0.7)]):.2f}')
ax.set_xlabel('Euclidean radius r', fontsize=11)
ax.set_ylabel(r'$N(r) \cdot (1-r^2)$', fontsize=11)
ax.set_title('Conjecture Test: Does N(r)·(1-r²) converge?', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Bottom right: p(p²-1)/6 for primes
ax = axes[1, 1]
primes = [p for p in range(2, 50) if all(p % i != 0 for i in range(2, int(p**0.5)+1))]
indices = [p * (p**2 - 1) // 6 for p in primes]
ax.bar(range(len(primes)), indices, color='#9b59b6', alpha=0.7)
ax.set_xticks(range(len(primes)))
ax.set_xticklabels(primes, fontsize=8)
ax.set_xlabel('Prime p', fontsize=11)
ax.set_ylabel(r'$p(p^2-1)/6$', fontsize=11)
ax.set_title('Congruence Subgroup Index (proved ∈ ℤ)', fontsize=13)
ax.grid(True, alpha=0.3, axis='y')

plt.suptitle('Hyperbolic Number Theory: Growth Conjecture Analysis',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('growth_conjecture.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved growth_conjecture.png")
