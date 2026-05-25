#!/usr/bin/env python3
"""
Visualization: Product Growth Curves for GL(2, F_q)

Plots product-set growth |A^k| vs k for multiple certified pairs
in GL(2, F_q), showing the strict growth phenomenon predicted by
the certificate-to-growth theorem.

Visualizes:
- Left panel: Absolute growth |A^k| vs k (log scale)
- Right panel: Growth ratios |A^{k+1}|/|A^k| showing strict > 1
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

def cayley_balls(A, p, max_r=15):
    B = {(1,0,0,1)}
    sizes = [1]
    order = gl2_order(p)
    for _ in range(1, max_r+1):
        B_new = B | product_set_mul(B, A, p)
        sizes.append(len(B_new))
        if len(B_new) == len(B) or len(B_new) == order:
            break
        B = B_new
    return sizes

def generates(g, h, p):
    A = sym_set(g, h, p)
    visited = set(A)
    frontier = list(A)
    order = gl2_order(p)
    while frontier:
        nf = []
        for s in frontier:
            for a in A:
                prod = gl2_mul(s, a, p)
                if prod not in visited:
                    visited.add(prod)
                    nf.append(prod)
                    if len(visited) == order:
                        return True
        frontier = nf
    return len(visited) == order

# ──────────────────────────────────────────────────────────────────────
# Data collection
# ──────────────────────────────────────────────────────────────────────

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

colors = {'5': '#e74c3c', '7': '#3498db', '11': '#2ecc71'}
markers = {'5': 'o', '7': 's', '11': '^'}

for p in [5, 7]:
    elements = enumerate_gl2(p)
    order = gl2_order(p)
    random.seed(2025 + p)

    pairs_data = []
    attempts = 0
    while len(pairs_data) < 8 and attempts < 300:
        g = random.choice(elements)
        h = random.choice(elements)
        attempts += 1
        if g == (1,0,0,1) or h == (1,0,0,1) or g == h:
            continue
        if generates(g, h, p):
            A = sym_set(g, h, p)
            sizes = cayley_balls(A, p, max_r=12)
            pairs_data.append(sizes)

    c = colors[str(p)]
    m = markers[str(p)]

    # Left panel: absolute growth
    ax1 = axes[0]
    for i, sizes in enumerate(pairs_data):
        ks = list(range(len(sizes)))
        label = f'GL(2,F_{p})' if i == 0 else None
        alpha = 0.8 if i == 0 else 0.3
        lw = 2.0 if i == 0 else 1.0
        ax1.semilogy(ks, sizes, color=c, marker=m, markersize=4,
                     alpha=alpha, linewidth=lw, label=label)

    # Horizontal line for group order
    ax1.axhline(y=order, color=c, linestyle='--', alpha=0.4,
                label=f'|GL(2,F_{p})| = {order}')

    # Right panel: growth ratios
    ax2 = axes[1]
    for i, sizes in enumerate(pairs_data):
        ratios = [sizes[j+1]/sizes[j] for j in range(len(sizes)-1)
                  if sizes[j] > 0 and sizes[j] < order]
        ks = list(range(1, len(ratios)+1))
        label = f'GL(2,F_{p})' if i == 0 else None
        alpha = 0.8 if i == 0 else 0.3
        if ks and ratios:
            ax2.plot(ks, ratios, color=c, marker=m, markersize=5,
                     alpha=alpha, linewidth=1.5, label=label)

# Format left panel
ax1.set_xlabel('Step k (Cayley ball radius)', fontsize=12)
ax1.set_ylabel('|B_k| (log scale)', fontsize=12)
ax1.set_title('Product Growth: Cayley Ball Size vs Radius', fontsize=13)
ax1.legend(fontsize=9, loc='lower right')
ax1.grid(True, alpha=0.3)

# Format right panel
ax2.axhline(y=1.0, color='black', linestyle=':', alpha=0.5, linewidth=1)
ax2.set_xlabel('Step k', fontsize=12)
ax2.set_ylabel('Growth ratio |B_{k+1}|/|B_k|', fontsize=12)
ax2.set_title('Strict Growth: Ratio > 1 Before Saturation', fontsize=13)
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)
ax2.set_ylim(bottom=0.8)

# Add annotation
ax2.annotate('Theorem: ratio > 1\nbefore saturation',
             xy=(0.5, 0.95), xycoords='axes fraction',
             fontsize=10, ha='center', va='top',
             bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow',
                       edgecolor='orange', alpha=0.8))

plt.suptitle('Certificate-to-Growth: Product Set Expansion in GL(2, F_q)',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('growth_curves.png', dpi=150, bbox_inches='tight')
print("Saved growth_curves.png")
