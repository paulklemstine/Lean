#!/usr/bin/env python3
"""
Visualization: Pythagorean Triple Connection to Prime Fractal

Shows how Pythagorean triples (a, b, c) with a² + b² = c² are separated
in the prime fractal metric, connecting number theory to geometry.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def prime_fractal_embed(n):
    if n >= 2:
        return 1.0 / math.log(n)
    return 0.0


def prime_fractal_dist(p, q):
    return abs(prime_fractal_embed(p) - prime_fractal_embed(q))


def generate_pythagorean_triples(max_c):
    """Generate primitive Pythagorean triples with c ≤ max_c."""
    triples = []
    for m in range(2, int(max_c**0.5) + 1):
        for n in range(1, m):
            if (m - n) % 2 == 1 and math.gcd(m, n) == 1:
                a = m*m - n*n
                b = 2*m*n
                c = m*m + n*n
                if c <= max_c:
                    triples.append((min(a,b), max(a,b), c))
    return sorted(triples, key=lambda t: t[2])


fig, axes = plt.subplots(1, 3, figsize=(18, 5))

triples = generate_pythagorean_triples(500)

# ─── Panel 1: Pythagorean triples in fractal space ───
ax1 = axes[0]

for a, b, c in triples[:50]:
    ea = prime_fractal_embed(a)
    eb = prime_fractal_embed(b)
    ec = prime_fractal_embed(c)
    ax1.plot([ea, ec], [a, c], 'b-', alpha=0.15, linewidth=0.8)
    ax1.plot([eb, ec], [b, c], 'r-', alpha=0.15, linewidth=0.8)

as_vals = [t[0] for t in triples[:50]]
bs_vals = [t[1] for t in triples[:50]]
cs_vals = [t[2] for t in triples[:50]]
ea_vals = [prime_fractal_embed(a) for a in as_vals]
eb_vals = [prime_fractal_embed(b) for b in bs_vals]
ec_vals = [prime_fractal_embed(c) for c in cs_vals]

ax1.scatter(ea_vals, as_vals, s=15, c='#2563eb', alpha=0.7, label='Leg a', zorder=3)
ax1.scatter(eb_vals, bs_vals, s=15, c='#dc2626', alpha=0.7, label='Leg b', zorder=3)
ax1.scatter(ec_vals, cs_vals, s=20, c='#059669', alpha=0.7, label='Hypotenuse c', zorder=3, marker='D')

ax1.set_xlabel('φ(n) = 1/log(n)', fontsize=11)
ax1.set_ylabel('n', fontsize=11)
ax1.set_title('Pythagorean Triples in\nFractal Metric Space', fontsize=12, fontweight='bold')
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.3)

# ─── Panel 2: Fractal separation d(a,c) vs c ───
ax2 = axes[1]

cs = [t[2] for t in triples]
d_acs = [prime_fractal_dist(t[0], t[2]) for t in triples]
d_bcs = [prime_fractal_dist(t[1], t[2]) for t in triples]

ax2.scatter(cs, d_acs, s=12, c='#2563eb', alpha=0.6, label='d(a, c)')
ax2.scatter(cs, d_bcs, s=12, c='#dc2626', alpha=0.6, label='d(b, c)')

# Trend line
cs_arr = np.array(cs, dtype=float)
ax2.plot(sorted(cs), [1.0/math.log(c) for c in sorted(cs)], 'g--',
         alpha=0.5, linewidth=1.5, label='1/log(c) reference')

ax2.set_xlabel('Hypotenuse c', fontsize=11)
ax2.set_ylabel('Fractal distance', fontsize=11)
ax2.set_title('Leg-Hypotenuse Fractal Separation\n(always positive, proved)', fontsize=12, fontweight='bold')
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

# ─── Panel 3: Ratio d(a,c)/d(b,c) distribution ───
ax3 = axes[2]

ratios = []
for t in triples:
    d_ac = prime_fractal_dist(t[0], t[2])
    d_bc = prime_fractal_dist(t[1], t[2])
    if d_bc > 1e-15:
        ratios.append(d_ac / d_bc)

ax3.hist(ratios, bins=30, color='#7c3aed', alpha=0.7, edgecolor='white', linewidth=0.5)
ax3.axvline(x=1.0, color='red', linestyle='--', alpha=0.5, label='d(a,c) = d(b,c)')
ax3.set_xlabel('d(a,c) / d(b,c)', fontsize=11)
ax3.set_ylabel('Count', fontsize=11)
ax3.set_title('Fractal Asymmetry of\nPythagorean Triples', fontsize=12, fontweight='bold')
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3, axis='y')

plt.tight_layout()
plt.savefig('pythagorean_connection_visualization.png', dpi=150, bbox_inches='tight')
print("Saved: pythagorean_connection_visualization.png")
