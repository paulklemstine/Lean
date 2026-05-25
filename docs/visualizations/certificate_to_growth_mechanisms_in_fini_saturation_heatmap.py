#!/usr/bin/env python3
"""
Visualization: Saturation Heatmap for GL(2, F_5)

Shows a heatmap of saturation steps for pairs of generators in GL(2, F_5).
Each cell (i, j) represents a pair of elements (g_i, g_j) and is colored
by the number of steps for the Cayley ball to fill the group.

Visualizes the certificate-to-growth theorem: every generating pair
eventually saturates, and the saturation step is bounded by |G|-1.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import random

# ──────────────────────────────────────────────────────────────────────
# Inline GL(2, F_p) implementation (self-contained)
# ──────────────────────────────────────────────────────────────────────

def gl2_mul(A, B, p):
    a, b, c, d = A
    e, f, g, h = B
    return ((a*e+b*g)%p, (a*f+b*h)%p, (c*e+d*g)%p, (c*f+d*h)%p)

def gl2_inv(A, p):
    a, b, c, d = A
    det = (a*d - b*c) % p
    di = pow(det, p-2, p)
    return (d*di%p, (-b*di)%p, (-c*di)%p, a*di%p)

def gl2_order(p):
    return (p*p - 1) * (p*p - p)

def enumerate_gl2(p):
    return [(a,b,c,d) for a in range(p) for b in range(p)
            for c in range(p) for d in range(p) if (a*d-b*c)%p != 0]

def sym_set(g, h, p):
    return {(1,0,0,1), g, gl2_inv(g,p), h, gl2_inv(h,p)}

def product_set_mul(S, A, p):
    return {gl2_mul(s, a, p) for s in S for a in A}

def cayley_diameter(g, h, p):
    """Return saturation step for pair (g, h), or 0 if they don't generate."""
    A = sym_set(g, h, p)
    order = gl2_order(p)
    visited = set(A)
    frontier = list(A)
    step = 1
    while frontier:
        if len(visited) == order:
            return step
        nf = []
        for s in frontier:
            for a in A:
                prod = gl2_mul(s, a, p)
                if prod not in visited:
                    visited.add(prod)
                    nf.append(prod)
        frontier = nf
        step += 1
    if len(visited) == order:
        return step
    return 0  # doesn't generate

# ──────────────────────────────────────────────────────────────────────
# Compute heatmap data
# ──────────────────────────────────────────────────────────────────────

p = 5
elements = enumerate_gl2(p)
order = gl2_order(p)

# Sample a manageable subset of elements for the heatmap
random.seed(42)
n_sample = 40
sample = random.sample(elements, min(n_sample, len(elements)))

print(f"Computing saturation steps for {len(sample)}×{len(sample)} pairs "
      f"in GL(2, F_{p})...")

heatmap = np.zeros((len(sample), len(sample)))

for i, g in enumerate(sample):
    for j, h in enumerate(sample):
        if i == j or g == (1,0,0,1) or h == (1,0,0,1):
            heatmap[i, j] = 0
        else:
            heatmap[i, j] = cayley_diameter(g, h, p)
    if (i + 1) % 10 == 0:
        print(f"  Row {i+1}/{len(sample)} done")

# ──────────────────────────────────────────────────────────────────────
# Plot
# ──────────────────────────────────────────────────────────────────────

fig, ax = plt.subplots(figsize=(10, 8))

# Mask non-generating pairs
masked = np.ma.masked_where(heatmap == 0, heatmap)

cmap = plt.cm.YlOrRd.copy()
cmap.set_bad(color='#f0f0f0')

im = ax.imshow(masked, cmap=cmap, aspect='equal', interpolation='nearest')

cbar = plt.colorbar(im, ax=ax, shrink=0.8, label='Saturation step')

ax.set_xlabel('Generator h index', fontsize=12)
ax.set_ylabel('Generator g index', fontsize=12)
ax.set_title(f'Cayley Graph Diameter: GL(2, F_{p})\n'
             f'(Gray = non-generating pair, Color = steps to fill group)',
             fontsize=13)

# Statistics annotation
gen_count = np.count_nonzero(heatmap)
total = heatmap.size
gen_frac = gen_count / total
gen_steps = heatmap[heatmap > 0]
if len(gen_steps) > 0:
    avg_diam = np.mean(gen_steps)
    max_diam = np.max(gen_steps)
    stats_text = (f'Generating pairs: {gen_count}/{total} ({gen_frac:.1%})\n'
                  f'Avg diameter: {avg_diam:.1f}\n'
                  f'Max diameter: {int(max_diam)}\n'
                  f'|G| = {order}')
else:
    stats_text = 'No generating pairs found'

ax.text(0.02, 0.98, stats_text, transform=ax.transAxes,
        fontsize=10, verticalalignment='top',
        bbox=dict(boxstyle='round', facecolor='white', alpha=0.9))

plt.tight_layout()
plt.savefig('saturation_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved saturation_heatmap.png")
