#!/usr/bin/env python3
"""
Causal Loops in Category Theory: Numerical Demonstrations

Demonstrates the cocycle-pentagon bridge, defect accumulation, and
non-strictifiability via concrete computations.
"""

import itertools
from typing import Callable

# --- Part 1: The ℤ/2ℤ Cocycle ---

def zmod2_cocycle(a: int, b: int, c: int) -> int:
    """The generator of H³(ℤ/2ℤ, ℤ/2ℤ): α(a,b,c) = a·b·c mod 2."""
    return (a * b * c) % 2

def check_cocycle_condition(alpha: Callable, n: int) -> bool:
    """Check the 3-cocycle condition over ℤ/nℤ."""
    for g1, g2, g3, g4 in itertools.product(range(n), repeat=4):
        val = (alpha(g2, g3, g4)
               - alpha((g1 + g2) % n, g3, g4)
               + alpha(g1, (g2 + g3) % n, g4)
               - alpha(g1, g2, (g3 + g4) % n)
               + alpha(g1, g2, g3)) % n
        if val != 0:
            return False
    return True

def check_pentagon(alpha: Callable, n: int) -> bool:
    """Check the pentagon identity over ℤ/nℤ."""
    for f, g, h, k in itertools.product(range(n), repeat=4):
        lhs = (alpha((f + g) % n, h, k) + alpha(f, g, (h + k) % n)) % n
        rhs = (alpha(g, h, k) + alpha(f, (g + h) % n, k) + alpha(f, g, h)) % n
        if lhs != rhs:
            return False
    return True

def check_coboundary(alpha: Callable, n: int) -> bool:
    """Check if alpha is a coboundary by exhaustive search over all 2-cochains."""
    # There are n^(n^2) possible 2-cochains β: (ℤ/nℤ)² → ℤ/nℤ
    for beta_vals in itertools.product(range(n), repeat=n*n):
        beta = lambda g1, g2, bv=beta_vals: bv[g1 * n + g2]
        is_match = True
        for g1, g2, g3 in itertools.product(range(n), repeat=3):
            coboundary_val = (beta(g2, g3)
                             - beta((g1 + g2) % n, g3)
                             + beta(g1, (g2 + g3) % n)
                             - beta(g1, g2)) % n
            if coboundary_val != alpha(g1, g2, g3):
                is_match = False
                break
        if is_match:
            return True
    return False

print("=" * 60)
print("CAUSAL LOOPS: Cocycle-Pentagon Bridge Demonstrations")
print("=" * 60)

print("\n--- Part 1: ℤ/2ℤ Cocycle Verification ---")
print(f"α(1,1,1) = {zmod2_cocycle(1,1,1)}")
print(f"α(1,1,0) = {zmod2_cocycle(1,1,0)}")
print(f"α(0,1,1) = {zmod2_cocycle(0,1,1)}")
print(f"Is 3-cocycle: {check_cocycle_condition(zmod2_cocycle, 2)}")
print(f"Satisfies pentagon: {check_pentagon(zmod2_cocycle, 2)}")
print(f"Is coboundary: {check_coboundary(zmod2_cocycle, 2)}")

# Zero cocycle
zero = lambda a, b, c: 0
print(f"\nZero cocycle is cocycle: {check_cocycle_condition(zero, 2)}")
print(f"Zero cocycle is coboundary: {check_coboundary(zero, 2)}")

# --- Part 2: Associator Defect ---

print("\n--- Part 2: Associator Defect for Subtraction ---")
def assoc_defect_sub(a: int, b: int, c: int) -> int:
    """Associator defect of subtraction: (a-b)-c vs a-(b-c)."""
    return (a - b) - c - (a - (b - c))

for a, b, c in [(10, 3, 5), (7, 2, 4), (0, 0, 1), (100, 50, 25)]:
    defect = assoc_defect_sub(a, b, c)
    print(f"  Defect({a},{b},{c}) = {defect} = -2·{c} = {-2*c}  ✓" if defect == -2*c else f"  ERROR")

# --- Part 3: Pentagon Defect ---

print("\n--- Part 3: Pentagon Defect for Subtraction ---")
def pentagon_defect_sub(a: int, b: int, c: int, d: int) -> int:
    """Pentagon defect for subtraction."""
    D = assoc_defect_sub
    lhs = D(a, b, c) + D(a, b - c, d) + D(b, c, d)
    rhs = D(a - b, c, d) + D(a, b, c - d)
    return lhs - rhs

for a, b, c, d in [(0, 0, 0, 1), (1, 2, 3, 4), (5, 3, 7, 2)]:
    defect = pentagon_defect_sub(a, b, c, d)
    expected = -4 * d
    print(f"  PentDefect({a},{b},{c},{d}) = {defect} = -4·{d} = {expected}  {'✓' if defect == expected else '✗'}")

# --- Part 4: H³ computation for small cyclic groups ---

print("\n--- Part 4: H³(ℤ/n, ℤ/n) for small n ---")
for n in [2]:
    # Count cocycles and coboundaries
    cocycle_count = 0
    coboundary_count = 0
    
    # Count cocycles (checking all n^(n^3) cochains is expensive, but n is small)
    if n <= 3:
        for alpha_vals in itertools.product(range(n), repeat=n**3):
            alpha = lambda g1, g2, g3, av=alpha_vals, nn=n: av[g1 * nn**2 + g2 * nn + g3]
            if check_cocycle_condition(alpha, n):
                cocycle_count += 1

        # Count coboundaries
        coboundary_set = set()
        for beta_vals in itertools.product(range(n), repeat=n**2):
            beta = lambda g1, g2, bv=beta_vals, nn=n: bv[g1 * nn + g2]
            cb_key = tuple(
                (beta(g2, g3) - beta((g1+g2) % n, g3) + beta(g1, (g2+g3) % n) - beta(g1, g2)) % n
                for g1, g2, g3 in itertools.product(range(n), repeat=3)
            )
            coboundary_set.add(cb_key)
        coboundary_count = len(coboundary_set)
        
        h3_order = cocycle_count // coboundary_count if coboundary_count > 0 else 0
        print(f"  n={n}: |Z³| = {cocycle_count}, |B³| = {coboundary_count}, |H³| = {h3_order}")
    else:
        # For n >= 4, just check the product cocycle
        prod_cocycle = lambda a, b, c, nn=n: (a * b * c) % nn
        is_coc = check_cocycle_condition(prod_cocycle, n)
        is_cob = check_coboundary(prod_cocycle, n) if n <= 5 else "skipped"
        print(f"  n={n}: product cocycle is cocycle={is_coc}, is coboundary={is_cob}")

# --- Part 5: Defect accumulation ---

print("\n--- Part 5: Defect Accumulation ---")
def foldl_sub(lst):
    """Left-associated subtraction."""
    if not lst: return 0
    result = lst[0]
    for x in lst[1:]:
        result -= x
    return result

def foldr_sub(lst):
    """Right-associated subtraction."""
    if not lst: return 0
    result = lst[-1]
    for x in reversed(lst[:-1]):
        result = x - result
    return result

for n in range(2, 10):
    lst = [5] * n
    left = foldl_sub(lst)
    right = foldr_sub(lst)
    diff = abs(left - right)
    print(f"  n={n}: foldl={left:6d}, foldr={right:6d}, |diff|={diff}")

print("\n" + "=" * 60)
print("All demonstrations complete.")


#!/usr/bin/env python3
"""
Visualization: The Pentagon Identity and Associahedron

Generates a visualization of:
1. The pentagon (K4 associahedron) showing the 5 parenthesizations
2. The cocycle defect heatmap for ℤ/nℤ
3. Defect accumulation growth
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import itertools

# --- Figure 1: The Associahedron (Pentagon) ---

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

ax = axes[0]
ax.set_title("The Associahedron K₄\n(Pentagon Identity)", fontsize=14, fontweight='bold')

# Pentagon vertices
angles = [np.pi/2 + 2*np.pi*i/5 for i in range(5)]
R = 1.0
vx = [R * np.cos(a) for a in angles]
vy = [R * np.sin(a) for a in angles]

labels = [
    "((ab)c)d",
    "(a(bc))d", 
    "a((bc)d)",
    "a(b(cd))",
    "(ab)(cd)"
]

# Draw edges
for i in range(5):
    j = (i + 1) % 5
    ax.plot([vx[i], vx[j]], [vy[i], vy[j]], 'b-', linewidth=2)

# Draw vertices and labels
for i in range(5):
    ax.plot(vx[i], vy[i], 'ko', markersize=10, zorder=5)
    offset = 0.25
    lx = vx[i] * (1 + offset/R)
    ly = vy[i] * (1 + offset/R)
    ax.text(lx, ly, labels[i], ha='center', va='center', fontsize=9,
            bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow', edgecolor='gray'))

# Arrows for the two paths
ax.annotate('', xy=(vx[3], vy[3]-0.05), xytext=(vx[0], vy[0]-0.05),
            arrowprops=dict(arrowstyle='->', color='red', lw=2, connectionstyle='arc3,rad=0.3'))
ax.annotate('', xy=(vx[3]+0.05, vy[3]), xytext=(vx[0]+0.05, vy[0]),
            arrowprops=dict(arrowstyle='->', color='green', lw=2, connectionstyle='arc3,rad=-0.3'))

ax.text(0, -1.7, "Red path = Green path\n(Pentagon Identity)", 
        ha='center', fontsize=10, style='italic', color='purple')

ax.set_xlim(-1.8, 1.8)
ax.set_ylim(-2.0, 1.8)
ax.set_aspect('equal')
ax.axis('off')

# --- Figure 2: Cocycle Values Heatmap ---

ax = axes[1]
ax.set_title("3-Cocycle α(a,b,c) = abc\non ℤ/2ℤ", fontsize=14, fontweight='bold')

n = 2
data = np.zeros((n**2, n))
for idx, (a, b) in enumerate(itertools.product(range(n), repeat=2)):
    for c in range(n):
        data[idx, c] = (a * b * c) % n

im = ax.imshow(data, cmap='YlOrRd', aspect='auto', interpolation='nearest')
ax.set_xlabel('c', fontsize=12)
ax.set_ylabel('(a, b)', fontsize=12)
ax.set_xticks(range(n))
ax.set_yticks(range(n**2))
ax.set_yticklabels([f"({a},{b})" for a, b in itertools.product(range(n), repeat=2)])
plt.colorbar(im, ax=ax, label='α(a,b,c)')

# Annotate cells
for idx in range(n**2):
    for c in range(n):
        val = int(data[idx, c])
        ax.text(c, idx, str(val), ha='center', va='center', fontsize=14, fontweight='bold')

# --- Figure 3: Defect Accumulation ---

ax = axes[2]
ax.set_title("Defect Accumulation\nLeft vs Right Association", fontsize=14, fontweight='bold')

ns = list(range(2, 20))
v = 5
left_vals = []
right_vals = []
diffs = []

for nn in ns:
    lst = [v] * nn
    # Left fold
    left = lst[0]
    for x in lst[1:]:
        left -= x
    # Right fold
    right = lst[-1]
    for x in reversed(lst[:-1]):
        right = x - right
    left_vals.append(left)
    right_vals.append(right)
    diffs.append(abs(left - right))

ax.plot(ns, left_vals, 'b-o', label='Left-assoc', markersize=5)
ax.plot(ns, right_vals, 'r-s', label='Right-assoc', markersize=5)
ax.plot(ns, diffs, 'g--^', label='|Difference|', markersize=5)
ax.axhline(y=0, color='gray', linestyle=':', alpha=0.5)
ax.set_xlabel('Number of elements', fontsize=12)
ax.set_ylabel('Value', fontsize=12)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('pentagon_visualization.png', dpi=150, bbox_inches='tight')
print("Saved pentagon_visualization.png")
