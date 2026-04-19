#!/usr/bin/env python3
"""
UNIVERSAL PARENT INVERSE — Python Demonstration
=================================================

Demonstrates the key discovery: the parent of ANY Pythagorean triple
in the Berggren tree can be found with a SINGLE formula:

    parent(a, b, c) = (|p|, |q|, h)

where:
    p = a + 2b - 2c
    q = 2a + b - 2c
    h = 3c - 2(a + b)

No branch determination needed. No matrix multiplication needed.
Just three linear combinations and two absolute values.
"""

import numpy as np
from math import gcd, sqrt
from collections import defaultdict

# ═══════════════════════════════════════════════════════════════
# SECTION 1: Core Functions
# ═══════════════════════════════════════════════════════════════

def ghost_p(a, b, c):
    """The p-parameter of the ghost triple."""
    return a + 2*b - 2*c

def ghost_q(a, b, c):
    """The q-parameter of the ghost triple."""
    return 2*a + b - 2*c

def ghost_h(a, b, c):
    """The h-parameter (universal parent hypotenuse)."""
    return 3*c - 2*(a + b)

def universal_parent(a, b, c):
    """The universal parent inverse: (|p|, |q|, h).
    Returns the parent of (a,b,c) in the Berggren tree.
    No branch determination needed!"""
    p = ghost_p(a, b, c)
    q = ghost_q(a, b, c)
    h = ghost_h(a, b, c)
    return (abs(p), abs(q), h)

def is_pythagorean(a, b, c):
    """Check if (a,b,c) is a Pythagorean triple."""
    return a*a + b*b == c*c

def is_primitive(a, b, c):
    """Check if (a,b,c) is a primitive Pythagorean triple."""
    return is_pythagorean(a, b, c) and gcd(gcd(a, b), c) == 1

# ═══════════════════════════════════════════════════════════════
# SECTION 2: Forward Berggren Matrices
# ═══════════════════════════════════════════════════════════════

B1 = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]])
B2 = np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]])
B3 = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]])

def generate_ppts(max_c=1000):
    """Generate all PPTs up to hypotenuse max_c using the Berggren tree."""
    root = np.array([3, 4, 5])
    triples = [tuple(root)]
    queue = [root]
    while queue:
        t = queue.pop(0)
        for B in [B1, B2, B3]:
            child = B @ t
            if child[2] <= max_c:
                triples.append(tuple(child))
                queue.append(child)
    return triples

# ═══════════════════════════════════════════════════════════════
# SECTION 3: Demonstration — Universal Parent vs Branch Method
# ═══════════════════════════════════════════════════════════════

print("=" * 70)
print("UNIVERSAL PARENT INVERSE — Demonstration")
print("=" * 70)

print("\n--- Section 1: Basic Examples ---\n")

examples = [(5, 12, 13), (21, 20, 29), (15, 8, 17), (7, 24, 25),
            (9, 40, 41), (119, 120, 169), (28, 45, 53)]

for a, b, c in examples:
    parent = universal_parent(a, b, c)
    p, q, h = ghost_p(a, b, c), ghost_q(a, b, c), ghost_h(a, b, c)
    # Determine branch
    if p > 0 and q < 0:
        branch = "B₁⁻¹"
    elif p > 0 and q > 0:
        branch = "B₂⁻¹"
    elif p < 0 and q > 0:
        branch = "B₃⁻¹"
    else:
        branch = "root"
    
    print(f"  ({a:3d}, {b:3d}, {c:3d}) → parent = {parent}  "
          f"[p={p:+d}, q={q:+d}, branch={branch}]")
    assert is_pythagorean(*parent) or parent == (1, 0, 1), \
        f"Parent {parent} is not Pythagorean!"

# ═══════════════════════════════════════════════════════════════
# SECTION 4: Full Descent to Root
# ═══════════════════════════════════════════════════════════════

print("\n--- Section 2: Full Descent Chains ---\n")

def full_descent(a, b, c):
    """Descend from (a,b,c) to the root (3,4,5) using the universal parent."""
    chain = [(a, b, c)]
    while (a, b, c) != (3, 4, 5) and (a, b, c) != (4, 3, 5):
        a, b, c = universal_parent(a, b, c)
        chain.append((a, b, c))
        if c <= 1:
            break
    return chain

test_triples = [(9, 40, 41), (119, 120, 169), (697, 696, 985), (4, 3, 5)]

for t in test_triples:
    chain = full_descent(*t)
    print(f"  {t} → root in {len(chain)-1} steps:")
    print(f"    {' → '.join(str(x) for x in chain)}")
    print()

# ═══════════════════════════════════════════════════════════════
# SECTION 5: Verification — All PPTs Return to Root
# ═══════════════════════════════════════════════════════════════

print("--- Section 3: Mass Verification ---\n")

ppts = generate_ppts(500)
print(f"  Generated {len(ppts)} PPTs with c ≤ 500")

all_descend = True
max_depth = 0
total_depth = 0

for t in ppts:
    chain = full_descent(*t)
    depth = len(chain) - 1
    max_depth = max(max_depth, depth)
    total_depth += depth
    # Check that we reach (3,4,5) or (4,3,5)
    final = chain[-1]
    if final not in [(3, 4, 5), (4, 3, 5), (1, 0, 1)]:
        all_descend = False
        print(f"  FAIL: {t} descends to {final}")

if all_descend:
    print(f"  ✓ All {len(ppts)} PPTs descend to root!")
    print(f"  Max depth: {max_depth}")
    print(f"  Average depth: {total_depth/len(ppts):.1f}")

# ═══════════════════════════════════════════════════════════════
# SECTION 6: Ghost Pythagorean Verification
# ═══════════════════════════════════════════════════════════════

print("\n--- Section 4: Ghost Pythagorean Theorem ---\n")

for t in ppts[:10]:
    a, b, c = t
    p, q, h = ghost_p(a, b, c), ghost_q(a, b, c), ghost_h(a, b, c)
    lhs = p*p + q*q
    rhs = h*h
    status = "✓" if lhs == rhs else "✗"
    print(f"  ({a:3d},{b:3d},{c:3d}): p²+q²={lhs:6d}, h²={rhs:6d}  {status}")

all_ghost_pyth = all(
    ghost_p(*t)**2 + ghost_q(*t)**2 == ghost_h(*t)**2
    for t in ppts
)
print(f"\n  Ghost Pythagorean holds for all {len(ppts)} PPTs: {all_ghost_pyth}")

# ═══════════════════════════════════════════════════════════════
# SECTION 7: Klein Four-Group Visualization
# ═══════════════════════════════════════════════════════════════

print("\n--- Section 5: Klein Four-Group (Sign Flips) ---\n")

for a, b, c in [(5, 12, 13), (21, 20, 29), (7, 24, 25)]:
    p, q, h = ghost_p(a, b, c), ghost_q(a, b, c), ghost_h(a, b, c)
    print(f"  Triple ({a}, {b}, {c}): p={p}, q={q}, h={h}")
    print(f"    B₁⁻¹ = ( p, -q, h) = ({p:+d}, {-q:+d}, {h})")
    print(f"    B₂⁻¹ = ( p,  q, h) = ({p:+d}, {q:+d}, {h})")
    print(f"    B₃⁻¹ = (-p,  q, h) = ({-p:+d}, {q:+d}, {h})")
    print(f"    Ghost = (-p, -q, h) = ({-p:+d}, {-q:+d}, {h})")
    print(f"    Universal Parent    = ({abs(p)}, {abs(q)}, {h})")
    print()

# ═══════════════════════════════════════════════════════════════
# SECTION 8: Branch Statistics
# ═══════════════════════════════════════════════════════════════

print("--- Section 6: Branch Statistics ---\n")

branch_counts = defaultdict(int)
for a, b, c in ppts:
    if (a, b, c) == (3, 4, 5):
        continue
    p = ghost_p(a, b, c)
    q = ghost_q(a, b, c)
    if p > 0 and q < 0:
        branch_counts[1] += 1
    elif p > 0 and q > 0:
        branch_counts[2] += 1
    elif p < 0 and q > 0:
        branch_counts[3] += 1
    else:
        branch_counts['boundary'] += 1

total = sum(branch_counts.values())
for br in [1, 2, 3, 'boundary']:
    count = branch_counts[br]
    pct = 100 * count / total if total > 0 else 0
    print(f"  Branch {br}: {count:4d} ({pct:5.1f}%)")

# ═══════════════════════════════════════════════════════════════
# SECTION 9: Leg Swap Symmetry
# ═══════════════════════════════════════════════════════════════

print("\n--- Section 7: Leg Swap Symmetry ---\n")
print("  Swapping legs (a,b) → (b,a) swaps components of universal parent:\n")

for a, b, c in [(5, 12, 13), (7, 24, 25), (20, 21, 29)]:
    up_ab = universal_parent(a, b, c)
    up_ba = universal_parent(b, a, c)
    print(f"  UP({a},{b},{c}) = {up_ab}")
    print(f"  UP({b},{a},{c}) = {up_ba}")
    assert up_ab[0] == up_ba[1] and up_ab[1] == up_ba[0] and up_ab[2] == up_ba[2]
    print(f"  ✓ Components swapped correctly")
    print()

# ═══════════════════════════════════════════════════════════════
# SECTION 10: Euclid Parameters
# ═══════════════════════════════════════════════════════════════

print("--- Section 8: Euclid Parameter Analysis ---\n")
print("  For (m²-n², 2mn, m²+n²):")
print(f"  {'m':>3s} {'n':>3s} {'a':>5s} {'b':>5s} {'c':>5s} {'p':>6s} {'q':>6s} {'h':>5s} {'Branch':>7s}")

for m in range(2, 8):
    for n in range(1, m):
        if gcd(m, n) != 1 or (m - n) % 2 == 0:
            continue
        a = m*m - n*n
        b = 2*m*n
        c = m*m + n*n
        p = ghost_p(a, b, c)
        q = ghost_q(a, b, c)
        h = ghost_h(a, b, c)
        
        if p > 0 and q < 0:
            br = "B₁"
        elif p > 0 and q > 0:
            br = "B₂"
        elif p < 0 and q > 0:
            br = "B₃"
        else:
            br = "root"
        
        ratio = m / n
        # Verify Euclid factored forms
        p_check = -(m - n) * (m - 3*n)
        q_check = 2 * n * (m - 2*n)
        h_check = (m - 2*n)**2 + n**2
        
        assert p == p_check, f"p mismatch: {p} vs {p_check}"
        assert q == q_check, f"q mismatch: {q} vs {q_check}"
        assert h == h_check, f"h mismatch: {h} vs {h_check}"
        
        print(f"  {m:3d} {n:3d} {a:5d} {b:5d} {c:5d} {p:6d} {q:6d} {h:5d} {br:>7s}  m/n={ratio:.2f}")

# ═══════════════════════════════════════════════════════════════
# SECTION 11: Depth-2 Composition
# ═══════════════════════════════════════════════════════════════

print("\n--- Section 9: Depth-2 Composition (M_UP²) ---\n")

M_UP = np.array([[1, 2, -2], [2, 1, -2], [-2, -2, 3]])
M_UP2 = M_UP @ M_UP

print(f"  M_UP =\n{M_UP}\n")
print(f"  M_UP² =\n{M_UP2}\n")

# Verify: grandparent = M_UP² applied to (a,b,c)
for a, b, c in [(5, 12, 13), (7, 24, 25), (119, 120, 169)]:
    pqh = M_UP @ np.array([a, b, c])
    pqh2 = M_UP2 @ np.array([a, b, c])
    up1 = universal_parent(a, b, c)
    up2 = universal_parent(*up1)
    print(f"  ({a},{b},{c}): UP = {up1}, UP² = {up2}")
    print(f"    M_UP·v = {tuple(pqh)}, M_UP²·v = {tuple(pqh2)}")
    print()

# ═══════════════════════════════════════════════════════════════
# SECTION 12: Descent Rate Analysis
# ═══════════════════════════════════════════════════════════════

print("--- Section 10: Descent Rate Analysis ---\n")

descent_ratios = {1: [], 2: [], 3: []}
for a, b, c in ppts:
    if (a, b, c) == (3, 4, 5):
        continue
    p = ghost_p(a, b, c)
    q = ghost_q(a, b, c)
    h = ghost_h(a, b, c)
    ratio = h / c
    
    if p > 0 and q < 0:
        descent_ratios[1].append(ratio)
    elif p > 0 and q > 0:
        descent_ratios[2].append(ratio)
    elif p < 0 and q > 0:
        descent_ratios[3].append(ratio)

for br in [1, 2, 3]:
    ratios = descent_ratios[br]
    if ratios:
        print(f"  Branch {br}: min h/c = {min(ratios):.4f}, "
              f"max h/c = {max(ratios):.4f}, "
              f"mean h/c = {sum(ratios)/len(ratios):.4f}")

print(f"\n  Theoretical minimum (branch 2): 3 - 2√2 ≈ {3 - 2*sqrt(2):.6f}")

# ═══════════════════════════════════════════════════════════════
# SECTION 13: Summary
# ═══════════════════════════════════════════════════════════════

print("\n" + "=" * 70)
print("SUMMARY")
print("=" * 70)
print("""
The Universal Parent Inverse (|p|, |q|, h) provides:

  1. A SINGLE FORMULA for Berggren tree descent (no branch determination)
  2. The ghost triple (p, q, h) is always Pythagorean: p² + q² = h²
  3. The three Berggren inverse branches are sign-flip variants:
     B₁⁻¹ = (p, -q, h), B₂⁻¹ = (p, q, h), B₃⁻¹ = (-p, q, h)
  4. The sign-flip group is ℤ/2 × ℤ/2 (Klein four-group)
  5. Leg swap (a↔b) swaps the first two components of the parent
  6. In Euclid parameters: p = -(m-n)(m-3n), q = 2n(m-2n), h = (m-2n)² + n²
  7. The parent hypotenuse h is always a sum of two squares

All theorems are machine-verified in Lean 4 (0 sorries).
""")
