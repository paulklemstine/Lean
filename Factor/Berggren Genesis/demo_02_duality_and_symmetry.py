#!/usr/bin/env python3
"""
DEMO 2: The Matter-Light Duality in the Berggren Tree

KEY DISCOVERY: The two degenerate Pythagorean triples (0,1,1) and (1,0,1)
are dual fixed points of the Berggren matrices:

    A · (0,1,1) = (0,1,1)    ← A preserves REST (matter at rest)
    C · (1,0,1) = (1,0,1)    ← C preserves LIGHT (massless photon)

    B · (0,1,1) = (3,4,5)    ← B creates matter-in-motion from rest
    B · (1,0,1) = (3,4,5)    ← B creates matter-in-motion from light

    Matrix B is the CREATION OPERATOR — it generates the first real
    Pythagorean triple from either vacuum state!

The growth rate: exactly (3^d + 1)/2 unique triples at depth ≤ d.
"""

import numpy as np
import matplotlib.pyplot as plt

# Berggren matrices
A = np.array([[ 1, -2,  2], [ 2, -1,  2], [ 2, -2,  3]])
B = np.array([[ 1,  2,  2], [ 2,  1,  2], [ 2,  2,  3]])
C = np.array([[-1,  2,  2], [-2,  1,  2], [-2,  2,  3]])

vacuum = np.array([0, 1, 1])
light  = np.array([1, 0, 1])

print("=" * 70)
print("MATTER-LIGHT DUALITY IN THE BERGGREN TREE")
print("=" * 70)
print()

# ═══════════════════════════════════════════════════════════════
# Fixed Point Analysis
# ═══════════════════════════════════════════════════════════════

print("FIXED POINT STRUCTURE:")
print()
for name, M in [("A", A), ("B", B), ("C", C)]:
    for label, v in [("vacuum (0,1,1)", vacuum), ("light (1,0,1)", light)]:
        result = M @ v
        is_fixed = np.array_equal(result, v)
        is_neg_fixed = np.array_equal(result, -v)
        status = " ★ FIXED POINT" if is_fixed else (" ★ ANTI-FIXED" if is_neg_fixed else "")
        print(f"  {name} · {label} = ({result[0]:3d}, {result[1]:3d}, {result[2]:3d}){status}")
    print()

# ═══════════════════════════════════════════════════════════════
# Nilpotency / Unipotency Analysis
# ═══════════════════════════════════════════════════════════════

print("=" * 70)
print("UNIPOTENCY ANALYSIS (A - I, C - I)")
print("=" * 70)
print()

I3 = np.eye(3, dtype=int)
for name, M in [("A", A), ("C", C)]:
    N = M - I3
    N2 = N @ N
    N3 = N2 @ N
    print(f"Matrix {name}:")
    print(f"  {name} - I =")
    for row in N:
        print(f"    {list(row)}")
    print(f"  ({name} - I)² =")
    for row in N2:
        print(f"    {list(row)}")
    print(f"  ({name} - I)³ =")
    for row in N3:
        print(f"    {list(row)}")
    if np.allclose(N3, 0):
        print(f"  → {name} is UNIPOTENT of order 3: ({name}-I)³ = 0")
    elif np.allclose(N2, 0):
        print(f"  → {name} is UNIPOTENT of order 2: ({name}-I)² = 0")
    print()

# ═══════════════════════════════════════════════════════════════
# Commutation Relations
# ═══════════════════════════════════════════════════════════════

print("=" * 70)
print("COMMUTATION RELATIONS (Lie Algebra Structure)")
print("=" * 70)
print()

AB = A @ B
BA = B @ A
comm_AB = AB - BA
print(f"[A, B] = AB - BA =")
for row in comm_AB:
    print(f"  {list(row)}")

AC = A @ C
CA = C @ A
comm_AC = AC - CA
print(f"\n[A, C] = AC - CA =")
for row in comm_AC:
    print(f"  {list(row)}")

BC = B @ C
CB = C @ B
comm_BC = BC - CB
print(f"\n[B, C] = BC - CB =")
for row in comm_BC:
    print(f"  {list(row)}")

print()

# ═══════════════════════════════════════════════════════════════
# The (3^d + 1)/2 Growth Law
# ═══════════════════════════════════════════════════════════════

print("=" * 70)
print("THE GROWTH LAW: (3^d + 1)/2 UNIQUE TRIPLES")
print("=" * 70)
print()

def normalize(t):
    a, b, c = abs(t[0]), abs(t[1]), abs(t[2])
    return (min(a,b), max(a,b), c)

def count_unique_at_depth(root, max_depth):
    """Count unique triples up to each depth."""
    all_unique = set()
    all_unique.add(normalize(root))
    current = [root]
    counts = [len(all_unique)]

    for d in range(1, max_depth + 1):
        next_level = []
        for t in current:
            for M in [A, B, C]:
                child = M @ t
                next_level.append(child)
                all_unique.add(normalize(child))
        current = next_level
        counts.append(len(all_unique))
    return counts

counts_vacuum = count_unique_at_depth(vacuum, 8)
counts_standard = count_unique_at_depth(np.array([3, 4, 5]), 8)

print(f"{'Depth':>6} | {'From (0,1,1)':>14} | {'(3^d+1)/2':>12} | {'From (3,4,5)':>14} | {'(3^d-1)/2':>12}")
print("-" * 70)
for d in range(9):
    pred_v = (3**d + 1) // 2
    pred_s = (3**d - 1) // 2 if d > 0 else 0
    # Standard tree prediction: (3^(d+1) - 1) / 2 for d >= 0
    # Actually from standard root: at depth 0 we have 1, at depth d we have sum(3^k, k=0..d) = (3^(d+1)-1)/2
    # But unique count may differ...
    print(f"{d:>6} | {counts_vacuum[d]:>14} | {pred_v:>12} | {counts_standard[d]:>14} | {(3**d - 1)//2 if d > 0 else 1:>12}")

print()
print("OBSERVATION: From vacuum, unique count = (3^d + 1)/2 EXACTLY!")
print("This means the vacuum tree = standard tree + 1 extra triple (the vacuum itself)")
print()

# ═══════════════════════════════════════════════════════════════
# The Swap Symmetry
# ═══════════════════════════════════════════════════════════════

print("=" * 70)
print("THE SWAP SYMMETRY: a ↔ b")
print("=" * 70)
print()

# The swap matrix S = [[0,1,0],[1,0,0],[0,0,1]] swaps a and b
S = np.array([[0, 1, 0], [1, 0, 0], [0, 0, 1]])

print("Swap matrix S (a ↔ b):")
print(f"  S · (0,1,1) = {tuple(S @ vacuum)} = (1,0,1) = light")
print(f"  S · (1,0,1) = {tuple(S @ light)} = (0,1,1) = vacuum")
print()
print("Swap conjugation of Berggren matrices:")
for name, M in [("A", A), ("B", B), ("C", C)]:
    conj = S @ M @ S
    for name2, M2 in [("A", A), ("B", B), ("C", C)]:
        if np.array_equal(conj, M2):
            print(f"  S·{name}·S = {name2}  ← {name} and {name2} are SWAP CONJUGATE!")
            break
    else:
        print(f"  S·{name}·S = ")
        for row in conj:
            print(f"    {list(row)}")

print()
print("THEOREM: The swap a ↔ b maps A ↔ C and fixes B.")
print("  This means A (rest-preserving) and C (light-preserving) are")
print("  the SAME transformation in different bases!")
print("  B is the self-dual creation operator.")

# ═══════════════════════════════════════════════════════════════
# Information-theoretic analysis
# ═══════════════════════════════════════════════════════════════

print()
print("=" * 70)
print("INFORMATION CONTENT OF BERGGREN TRIPLES")
print("=" * 70)
print()

def info_content(a, b, c):
    """Information content: log of the hypotenuse (energy scale)."""
    return np.log2(max(c, 1))

def angle_entropy(a, b, c):
    """Angle entropy: how 'mixed' the triple is between rest and light."""
    if c == 0:
        return 0
    p = a / c  # velocity parameter
    q = b / c
    # Entropy of the (p², q²) distribution
    p2, q2 = p**2, q**2
    if p2 == 0 or q2 == 0:
        return 0  # pure state (rest or light)
    return -(p2 * np.log2(p2) + q2 * np.log2(q2))

print("Triple            | Info bits | Angle entropy | Physical interpretation")
print("-" * 80)

special_triples = [
    ((0, 1, 1),   "Pure rest (vacuum)"),
    ((1, 0, 1),   "Pure light (photon)"),
    ((3, 4, 5),   "First real triple"),
    ((5, 12, 13), "Second generation"),
    ((8, 15, 17), "Second generation"),
    ((7, 24, 25), "Third generation"),
    ((20, 21, 29),"Nearly symmetric"),
    ((119, 120, 169), "Highly symmetric"),
]

for (a, b, c), desc in special_triples:
    info = info_content(a, b, c)
    ent = angle_entropy(a, b, c)
    print(f"  ({a:>3}, {b:>3}, {c:>3}) | {info:>9.3f} | {ent:>13.4f} | {desc}")

print()
print("NOTE: Angle entropy = 0 for degenerate triples (pure states)")
print("      Angle entropy is MAXIMIZED when a ≈ b (symmetric triples)")
print("      Maximum possible = 1.0 bit (when a = b, impossible for primitives)")

# ═══════════════════════════════════════════════════════════════
# Visualization
# ═══════════════════════════════════════════════════════════════

fig, axes = plt.subplots(2, 2, figsize=(14, 12))

# Plot 1: Fixed point structure
ax = axes[0, 0]
# Draw the two fixed points and how matrices connect them
circle_r = 0.3
angles_vac = np.linspace(0, 2*np.pi, 100)
ax.plot(0.3 + circle_r * np.cos(angles_vac), 0.5 + circle_r * np.sin(angles_vac), 'b-', lw=2)
ax.plot(0.7 + circle_r * np.cos(angles_vac), 0.5 + circle_r * np.sin(angles_vac), 'r-', lw=2)
ax.text(0.3, 0.5, '(0,1,1)\nRest', ha='center', va='center', fontsize=10, fontweight='bold')
ax.text(0.7, 0.5, '(1,0,1)\nLight', ha='center', va='center', fontsize=10, fontweight='bold')

# Self-loops
ax.annotate('', xy=(0.15, 0.8), xytext=(0.1, 0.65),
            arrowprops=dict(arrowstyle='->', color='blue', lw=2))
ax.text(0.05, 0.85, 'A', fontsize=14, color='blue', fontweight='bold')

ax.annotate('', xy=(0.85, 0.8), xytext=(0.9, 0.65),
            arrowprops=dict(arrowstyle='->', color='red', lw=2))
ax.text(0.92, 0.85, 'C', fontsize=14, color='red', fontweight='bold')

# B connecting both to (3,4,5)
ax.text(0.5, 0.15, '(3,4,5)', ha='center', va='center', fontsize=10,
        fontweight='bold', bbox=dict(boxstyle='round', facecolor='gold', alpha=0.5))
ax.annotate('', xy=(0.45, 0.2), xytext=(0.35, 0.3),
            arrowprops=dict(arrowstyle='->', color='green', lw=2))
ax.annotate('', xy=(0.55, 0.2), xytext=(0.65, 0.3),
            arrowprops=dict(arrowstyle='->', color='green', lw=2))
ax.text(0.3, 0.22, 'B,C', fontsize=10, color='green')
ax.text(0.7, 0.22, 'A,B', fontsize=10, color='green')

ax.set_xlim(-0.1, 1.1)
ax.set_ylim(-0.05, 1.05)
ax.set_title('Fixed Point Structure\nA preserves Rest, C preserves Light', fontsize=11)
ax.axis('off')

# Plot 2: Growth law
ax = axes[0, 1]
depths = list(range(9))
predicted = [(3**d + 1) // 2 for d in depths]
ax.semilogy(depths, counts_vacuum, 'bo-', label='Actual (from vacuum)', markersize=8)
ax.semilogy(depths, predicted, 'r--', label='(3^d + 1)/2', alpha=0.7)
ax.semilogy(depths, counts_standard, 'gs-', label='Actual (from (3,4,5))', markersize=6)
ax.set_xlabel('Depth d')
ax.set_ylabel('Unique triples (log scale)')
ax.set_title('Growth Law: Unique Triples vs Depth')
ax.legend()
ax.grid(True, alpha=0.3)

# Plot 3: Angle distribution of triples by depth
ax = axes[1, 0]

colors = plt.cm.viridis(np.linspace(0, 1, 6))
current = [vacuum]
for d in range(6):
    if d > 0:
        next_level = []
        for t in current:
            for M in [A, B, C]:
                next_level.append(M @ t)
        current = next_level

    angles = [np.arctan2(float(t[0]), float(t[1])) * 180 / np.pi for t in current if t[2] > 0]
    ax.scatter(angles, [d] * len(angles), c=[colors[d]], alpha=0.5, s=30)

ax.set_xlabel('Angle θ = arctan(a/b) [degrees]')
ax.set_ylabel('Tree depth')
ax.set_title('Angular Spread of Triples by Depth\n0° = rest, 90° = light')
ax.axvline(0, color='blue', linestyle='--', alpha=0.3, label='Rest axis')
ax.axvline(90, color='red', linestyle='--', alpha=0.3, label='Light axis')
ax.legend(fontsize=8)

# Plot 4: Energy spectrum (hypotenuse distribution)
ax = axes[1, 1]
all_triples = []
current = [vacuum]
for d in range(7):
    if d > 0:
        next_level = []
        for t in current:
            for M in [A, B, C]:
                next_level.append(M @ t)
        current = next_level
    for t in current:
        all_triples.append(t)

hyps = sorted(set(int(t[2]) for t in all_triples if t[2] > 1))
ax.hist(hyps, bins=50, color='purple', alpha=0.7, edgecolor='black')
ax.set_xlabel('Hypotenuse c (Energy)')
ax.set_ylabel('Count')
ax.set_title('Energy Spectrum of Berggren Triples\n(from vacuum genesis)')

plt.tight_layout()
plt.savefig('/workspace/request-project/Berggren Genesis/figure_02_duality.png', dpi=150)
print("\n✓ Figure saved: figure_02_duality.png")

# ═══════════════════════════════════════════════════════════════
# THE DEEP THEOREM
# ═══════════════════════════════════════════════════════════════

print()
print("=" * 70)
print("THE GENESIS THEOREM (Summary of Discoveries)")
print("=" * 70)
print()
print("THEOREM (Berggren Genesis): The degenerate Pythagorean triple")
print("(0,1,1) is the natural vacuum state of the Berggren tree. From it:")
print()
print("1. FIXED POINTS: A·(0,1,1) = (0,1,1) and C·(1,0,1) = (1,0,1)")
print("   The swap symmetry a↔b exchanges A↔C and rest↔light.")
print()
print("2. CREATION: B·(0,1,1) = B·(1,0,1) = (3,4,5)")
print("   Matrix B is the universal creation operator.")
print()
print("3. GROWTH: The extended tree has (3^d + 1)/2 unique triples at depth d.")
print("   This equals the standard tree count plus 1 (the vacuum).")
print()
print("4. PHYSICS: (0,1,1) ↔ matter at rest (p=0, E=mc²)")
print("           (1,0,1) ↔ pure light (m=0, E=pc)")
print("           Berggren matrices = discrete Lorentz transformations")
print()
print("5. COMPUTATION: (0,1,1) = initial state of a ternary computer")
print("               Depth = computational complexity")
print("               Path multiplicity = quantum degeneracy")
print()
print("6. FIBONACCI: (0,1,1) seeds the Fibonacci sequence")
print("             F_n · F_{n+3} and 2·F_{n+1}·F_{n+2} form Pythagorean triples")
print("             with hypotenuses that are themselves Fibonacci numbers")
