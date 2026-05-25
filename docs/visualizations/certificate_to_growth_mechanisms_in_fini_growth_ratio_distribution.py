#!/usr/bin/env python3
"""
Visualization: Growth Ratio Distribution

Shows the distribution of growth ratios |A^{k+1}|/|A^k| across many
certified pairs in GL(2, F_5) and GL(2, F_7), confirming that the
ratio is always > 1 before saturation (strict growth theorem).

Visualizes:
- Histogram of growth ratios at each step
- All ratios are strictly > 1, confirming the theorem
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

def compute_sizes(g, h, p, max_k=5):
    A = sym_set(g, h, p)
    order = gl2_order(p)
    sizes = [len(A)]
    current = set(A)
    for k in range(2, max_k + 1):
        current = product_set_mul(current, A, p)
        sizes.append(len(current))
        if len(current) == order:
            break
    return sizes

# ──────────────────────────────────────────────────────────────────────
# Collect growth ratio data
# ──────────────────────────────────────────────────────────────────────

all_ratios = {5: {}, 7: {}}

for p in [5, 7]:
    elements = enumerate_gl2(p)
    order = gl2_order(p)
    random.seed(1234 + p)

    step_ratios = {1: [], 2: [], 3: [], 4: []}

    count = 0
    target = 80 if p == 5 else 40
    attempts = 0

    while count < target and attempts < 500:
        g = random.choice(elements)
        h = random.choice(elements)
        attempts += 1
        if g == (1,0,0,1) or h == (1,0,0,1) or g == h:
            continue
        if not generates(g, h, p):
            continue

        sizes = compute_sizes(g, h, p, max_k=5)
        count += 1

        for k in range(len(sizes) - 1):
            if sizes[k] < order and sizes[k] > 0:
                ratio = sizes[k+1] / sizes[k]
                if k + 1 in step_ratios:
                    step_ratios[k+1].append(ratio)

    all_ratios[p] = step_ratios
    print(f"GL(2, F_{p}): collected {count} certified pairs")

# ──────────────────────────────────────────────────────────────────────
# Plot
# ──────────────────────────────────────────────────────────────────────

fig, axes = plt.subplots(2, 2, figsize=(12, 10))

colors = {5: '#e74c3c', 7: '#3498db'}
titles = {
    1: 'Step 1→2: |A²|/|A|',
    2: 'Step 2→3: |A³|/|A²|',
    3: 'Step 3→4: |A⁴|/|A³|',
    4: 'Step 4→5: |A⁵|/|A⁴|',
}

for idx, step in enumerate([1, 2, 3, 4]):
    ax = axes[idx // 2][idx % 2]

    for p in [5, 7]:
        data = all_ratios[p].get(step, [])
        if data:
            ax.hist(data, bins=20, alpha=0.6, color=colors[p],
                    label=f'GL(2,F_{p}) (n={len(data)})',
                    edgecolor='white', linewidth=0.5)

    ax.axvline(x=1.0, color='black', linestyle='--', linewidth=1.5,
               alpha=0.7, label='Ratio = 1 (stall)')
    ax.set_xlabel('Growth ratio', fontsize=11)
    ax.set_ylabel('Count', fontsize=11)
    ax.set_title(titles[step], fontsize=12, fontweight='bold')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    # Annotate minimum ratio
    all_data = []
    for p in [5, 7]:
        all_data.extend(all_ratios[p].get(step, []))
    if all_data:
        min_r = min(all_data)
        ax.annotate(f'min = {min_r:.2f}',
                   xy=(min_r, 0), xytext=(min_r, ax.get_ylim()[1] * 0.8),
                   arrowprops=dict(arrowstyle='->', color='red'),
                   fontsize=9, color='red', fontweight='bold')

plt.suptitle('Growth Ratio Distribution for Certified Pairs\n'
             'All ratios > 1 confirms the Strict Growth Theorem',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('growth_ratios.png', dpi=150, bbox_inches='tight')
print("Saved growth_ratios.png")
