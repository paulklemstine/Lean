#!/usr/bin/env python3
"""
GL₃ Tropical Satake Surjectivity — Interactive Demo

This script demonstrates the tropical Satake correspondence for GL₃:
- Sorting triples into the dominant chamber
- The Satake extension/restriction bijection
- S₃-invariant functions and support data
- Tropical convolution on dominant coweights
- Visualization of the dominant Weyl chamber and Satake cone

Run: python3 gl3_tropical_satake_demo.py
"""

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
from itertools import permutations
from collections import defaultdict

# ──────────────────────────────────────────────────
# 1. Sorting and the Dominant Chamber
# ──────────────────────────────────────────────────

def sort3(a, b, c):
    """Sort (a,b,c) into weakly decreasing order (dominant coweight)."""
    s = sorted([a, b, c], reverse=True)
    return tuple(s)

def is_dominant(a, b, c):
    """Check if (a,b,c) is weakly decreasing."""
    return a >= b >= c

def satake_transform(a, b, c):
    """The tropical Satake transform: (e₁, e₂, e₃)."""
    e1 = max(a, b, c)
    e2 = max(a+b, a+c, b+c)
    e3 = a + b + c
    return (e1, e2, e3)

def satake_inverse(x, y, z):
    """Inverse of Satake transform on the Weyl chamber."""
    return (x, y - x, z - y)

print("=" * 60)
print("GL₃ TROPICAL SATAKE SURJECTIVITY — DEMONSTRATION")
print("=" * 60)

# Demo 1: Sorting examples
print("\n── 1. Sorting into the Dominant Chamber ──")
triples = [(3, 1, 2), (0, 5, -1), (2, 2, 2), (-1, 3, 0), (4, 4, 1)]
for t in triples:
    s = sort3(*t)
    print(f"  sort₃{t} = {s}  (dominant: {is_dominant(*s)})")

# Demo 2: Satake transform and inverse
print("\n── 2. Satake Transform Bijection ──")
dominants = [(5, 3, 1), (4, 2, 0), (3, 3, 3), (6, 4, 2), (10, 5, 0)]
print("  Forward: (a≥b≥c) → (e₁, e₂, e₃)")
for d in dominants:
    st = satake_transform(*d)
    inv = satake_inverse(*st)
    print(f"    {d} → {st} → {inv}  {'✓' if inv == d else '✗'}")

# Demo 3: S₃-invariance
print("\n── 3. S₃-Invariance of Satake Transform ──")
a, b, c = 5, 2, -1
perms = list(set(permutations([a, b, c])))
base = satake_transform(a, b, c)
print(f"  All permutations of ({a},{b},{c}):")
for p in sorted(perms, reverse=True):
    st = satake_transform(*p)
    print(f"    σ({a},{b},{c}) = {p} → e = {st}  {'✓ same' if st == base else '✗ DIFFERENT'}")

# Demo 4: Satake support extraction and extension
print("\n── 4. Satake Support: Restriction ↔ Extension ──")
print("  Define h on dominant chamber: h(a,b,c) = a - c (spread)")
def h_support(abc):
    a, b, c = abc
    return a - c

print("  h(5,3,1) =", h_support((5, 3, 1)))
print("  h(4,2,0) =", h_support((4, 2, 0)))

print("  Extend to S₃-invariant function f via sorting:")
def f_extended(a, b, c):
    return h_support(sort3(a, b, c))

for p in [(5, 3, 1), (3, 1, 5), (1, 5, 3), (3, 5, 1)]:
    print(f"    f{p} = h(sort₃{p}) = h{sort3(*p)} = {f_extended(*p)}")

print("  Verify: restrict f back to dominant = h")
test_doms = [(5, 3, 1), (4, 2, 0), (3, 3, 3)]
for d in test_doms:
    print(f"    f{d} = {f_extended(*d)}, h{d} = {h_support(d)}  "
          f"{'✓' if f_extended(*d) == h_support(d) else '✗'}")

# ──────────────────────────────────────────────────
# 5. Tropical Convolution on Support Data
# ──────────────────────────────────────────────────
print("\n── 5. Tropical Convolution on Dominant Coweights ──")

def support_conv(h1, supp1, h2, supp2, target):
    """Compute max-plus convolution: max over μ₁+μ₂=target of h₁(μ₁)+h₂(μ₂)."""
    best = None
    for m1 in supp1:
        m2 = (target[0] - m1[0], target[1] - m1[1], target[2] - m1[2])
        if is_dominant(*m2) and m2 in supp2:
            val = h1[m1] + h2[m2]
            if best is None or val > best:
                best = val
    return best

# Example: indicator functions
supp_A = {(2, 1, 0): 1, (1, 1, 0): 2, (0, 0, 0): 0}
supp_B = {(1, 0, 0): 1, (1, 1, 1): -1, (0, 0, 0): 0}

print("  h₁: ", {k: v for k, v in supp_A.items()})
print("  h₂: ", {k: v for k, v in supp_B.items()})

targets = [(3, 1, 0), (2, 1, 0), (3, 2, 1), (1, 1, 1)]
print("  Convolution (h₁ ⊛ h₂)(μ) = sup{h₁(μ₁) + h₂(μ₂) : μ₁ + μ₂ = μ}:")
for t in targets:
    v = support_conv(supp_A, supp_A, supp_B, supp_B, t)
    print(f"    (h₁ ⊛ h₂){t} = {v if v is not None else '−∞ (no decomposition)'}")

# ──────────────────────────────────────────────────
# 6. Visualization
# ──────────────────────────────────────────────────
print("\n── 6. Generating Visualizations ──")

# Figure 1: The dominant Weyl chamber in (a,b,c)-space
fig = plt.figure(figsize=(14, 5))

# Panel 1: Dominant coweights with a+b+c = const
ax1 = fig.add_subplot(131)
N = 8
pts = []
for a in range(N + 1):
    for b in range(a + 1):
        c = N - a - b
        if c <= b and c >= 0:
            pts.append((a, b, c))

xs = [p[0] for p in pts]
ys = [p[1] for p in pts]
ax1.scatter(xs, ys, c='steelblue', s=60, zorder=5)
for p in pts:
    ax1.annotate(f'({p[0]},{p[1]},{p[2]})', (p[0], p[1]),
                 fontsize=6, ha='center', va='bottom')
ax1.set_xlabel('a')
ax1.set_ylabel('b')
ax1.set_title(f'Dominant coweights\n(a≥b≥c≥0, a+b+c={N})')
ax1.grid(True, alpha=0.3)

# Panel 2: Satake transform image (Weyl chamber cone)
ax2 = fig.add_subplot(132)
wc_pts = []
for x in range(-2, 10):
    for y in range(-2, 15):
        if 2 * x >= y and 2 * y >= x + (10 - x):
            pass  # just for illustration
for a in range(-3, 8):
    for b in range(-3, 8):
        for c in range(-3, 8):
            e1, e2, e3 = satake_transform(a, b, c)
            if abs(e3) <= 6:
                wc_pts.append((e1, e2))

wc_xs = list(set([p[0] for p in wc_pts]))
wc_ys = list(set([p[1] for p in wc_pts]))
ax2.scatter([p[0] for p in wc_pts], [p[1] for p in wc_pts],
            c='coral', s=5, alpha=0.3)

# Overlay the cone boundary: 2x = y and 2y = x + z (for fixed z)
x_range = np.linspace(-3, 7, 100)
ax2.plot(x_range, 2 * x_range, 'k--', linewidth=1, label='2x = y')
ax2.set_xlabel('e₁ = max(a,b,c)')
ax2.set_ylabel('e₂ = max(a+b,a+c,b+c)')
ax2.set_title('Satake transform image\n(projected to e₁, e₂)')
ax2.legend(fontsize=8)
ax2.grid(True, alpha=0.3)

# Panel 3: Support datum example
ax3 = fig.add_subplot(133)
support_pts = []
support_vals = []
for a in range(6):
    for b in range(a + 1):
        for c in range(b + 1):
            support_pts.append((a, b))
            support_vals.append(a - c)  # spread function

scatter = ax3.scatter([p[0] for p in support_pts],
                      [p[1] for p in support_pts],
                      c=support_vals, cmap='viridis', s=80, zorder=5)
plt.colorbar(scatter, ax=ax3, label='h(a,b,c) = a − c')
ax3.set_xlabel('a')
ax3.set_ylabel('b')
ax3.set_title('Support datum h(a,b,c) = a − c\non dominant chamber')
ax3.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('demos/gl3_satake_visualization.png', dpi=150, bbox_inches='tight')
print("  Saved: demos/gl3_satake_visualization.png")

# Figure 2: The bijection illustrated
fig2, axes = plt.subplots(1, 2, figsize=(12, 5))

# Left: A support datum
ax = axes[0]
N_show = 5
dom_pts = [(a, b, c) for a in range(N_show + 1)
           for b in range(a + 1) for c in range(b + 1)]
h_vals = {p: p[0] * p[1] - p[2] ** 2 for p in dom_pts}

for i, p in enumerate(dom_pts):
    color = plt.cm.RdYlBu(0.5 + h_vals[p] / (2 * max(abs(v) for v in h_vals.values()) + 1))
    ax.scatter(p[0], p[1], c=[color], s=100, zorder=5, edgecolors='black', linewidth=0.5)
    ax.annotate(f'{h_vals[p]}', (p[0], p[1]), fontsize=5, ha='center', va='center')

ax.set_title('Support datum h on GL₃Dom\n(values at dominant coweights)')
ax.set_xlabel('a')
ax.set_ylabel('b')
ax.grid(True, alpha=0.3)

# Right: Extended S₃-invariant function
ax = axes[1]
ext_pts = []
for x in range(-2, N_show + 1):
    for y in range(-2, N_show + 1):
        z = 0  # fix z=0 slice
        s = sort3(x, y, z)
        if s in h_vals:
            ext_pts.append((x, y, h_vals[s]))

for x, y, v in ext_pts:
    color = plt.cm.RdYlBu(0.5 + v / (2 * max(abs(e[2]) for e in ext_pts) + 1))
    ax.scatter(x, y, c=[color], s=80, zorder=5, edgecolors='black', linewidth=0.5)
    ax.annotate(f'{v}', (x, y), fontsize=5, ha='center', va='center')

ax.set_title('Extended S₃-invariant function\nf(x,y,0) = h(sort₃(x,y,0))')
ax.set_xlabel('x')
ax.set_ylabel('y')
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('demos/gl3_satake_bijection.png', dpi=150, bbox_inches='tight')
print("  Saved: demos/gl3_satake_bijection.png")

# ──────────────────────────────────────────────────
# 7. Verification Statistics
# ──────────────────────────────────────────────────
print("\n── 7. Verification Statistics ──")

# Verify bijection on many examples
n_tested = 0
n_round_trip = 0
for a in range(-5, 6):
    for b in range(-5, 6):
        for c in range(-5, 6):
            n_tested += 1
            s = sort3(a, b, c)
            # Check sort is dominant
            assert is_dominant(*s), f"sort₃{(a,b,c)} = {s} not dominant!"
            # Check sort is idempotent
            assert sort3(*s) == s, f"sort₃ not idempotent at {s}!"
            # Check Satake round-trip
            if is_dominant(a, b, c):
                st = satake_transform(a, b, c)
                inv = satake_inverse(*st)
                if inv == (a, b, c):
                    n_round_trip += 1

print(f"  Tested {n_tested} triples in [-5,5]³")
print(f"  All sort₃ outputs are dominant: ✓")
print(f"  sort₃ is idempotent on all: ✓")

# Verify S₃-invariance of extension
n_inv_tested = 0
n_inv_ok = 0
for a in range(-3, 4):
    for b in range(-3, 4):
        for c in range(-3, 4):
            n_inv_tested += 1
            val = h_support(sort3(a, b, c))
            for perm in permutations([a, b, c]):
                assert h_support(sort3(*perm)) == val
            n_inv_ok += 1

print(f"  S₃-invariance of extension verified on {n_inv_tested} triples: ✓")

# Count dominant coweights with bounded entries
for N in [3, 5, 10]:
    count = sum(1 for a in range(N + 1) for b in range(a + 1) for c in range(b + 1))
    print(f"  |GL₃Dom ∩ [0,{N}]³| = {count}")

print("\n" + "=" * 60)
print("ALL DEMONSTRATIONS COMPLETED SUCCESSFULLY")
print("=" * 60)
