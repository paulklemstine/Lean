#!/usr/bin/env python3
"""
DEMO 1: The Vacuum Triple (0,1,1) — Genesis of the Berggren Tree

The standard Berggren tree starts at (3,4,5) and generates all primitive
Pythagorean triples. But what happens when we look BELOW the root?

The degenerate Pythagorean triple (0,1,1) satisfies 0² + 1² = 1².
It is the "vacuum state" — a right triangle with zero area, pure potentiality.

Applying the three Berggren matrices to (0,1,1) reveals:
  • Matrix A: (0,1,1) → (0,1,1)  — FIXED POINT! The vacuum is A-invariant.
  • Matrix B: (0,1,1) → (4,3,5)  — Creates the first real triple!
  • Matrix C: (0,1,1) → (4,3,5)  — Same triple! B and C are degenerate here.

This is creation from nothing: the vacuum spontaneously generates matter.
"""

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

# ═══════════════════════════════════════════════════════════════
# Berggren Matrices
# ═══════════════════════════════════════════════════════════════

A = np.array([[ 1, -2,  2],
              [ 2, -1,  2],
              [ 2, -2,  3]])

B = np.array([[ 1,  2,  2],
              [ 2,  1,  2],
              [ 2,  2,  3]])

C = np.array([[-1,  2,  2],
              [-2,  1,  2],
              [-2,  2,  3]])

# ═══════════════════════════════════════════════════════════════
# The Vacuum Triple
# ═══════════════════════════════════════════════════════════════

vacuum = np.array([0, 1, 1])

print("=" * 70)
print("THE VACUUM TRIPLE: GENESIS OF THE BERGGREN TREE")
print("=" * 70)
print()
print(f"Vacuum triple: {tuple(vacuum)}")
print(f"Check: 0² + 1² = {0**2 + 1**2} = 1² ✓")
print(f"Lorentz form Q = a² + b² - c² = {vacuum[0]**2 + vacuum[1]**2 - vacuum[2]**2}")
print()

# Apply matrices to vacuum
Av = A @ vacuum
Bv = B @ vacuum
Cv = C @ vacuum

print("Applying Berggren matrices to the vacuum:")
print(f"  A · (0,1,1) = {tuple(Av)}  ← FIXED POINT!")
print(f"  B · (0,1,1) = {tuple(Bv)}  ← Creates (4,3,5) ~ (3,4,5)")
print(f"  C · (0,1,1) = {tuple(Cv)}  ← Creates (4,3,5) ~ (3,4,5)")
print()

# Verify Pythagorean property
for name, v in [("A·vacuum", Av), ("B·vacuum", Bv), ("C·vacuum", Cv)]:
    check = v[0]**2 + v[1]**2 - v[2]**2
    print(f"  Q({name}) = {v[0]}² + {v[1]}² - {v[2]}² = {check}")
print()

# ═══════════════════════════════════════════════════════════════
# The OTHER degenerate triple: (1,0,1) — pure light
# ═══════════════════════════════════════════════════════════════

light = np.array([1, 0, 1])

print("THE LIGHT TRIPLE: (1,0,1)")
print(f"  Check: 1² + 0² = {1**2 + 0**2} = 1² ✓")
print(f"  Lorentz form Q = {light[0]**2 + light[1]**2 - light[2]**2}")
print()

Al = A @ light
Bl = B @ light
Cl = C @ light

print("Applying Berggren matrices to the light triple:")
print(f"  A · (1,0,1) = {tuple(Al)}")
print(f"  B · (1,0,1) = {tuple(Bl)}")
print(f"  C · (1,0,1) = {tuple(Cl)}")
print()

# ═══════════════════════════════════════════════════════════════
# Generate the extended tree from (0,1,1)
# ═══════════════════════════════════════════════════════════════

def generate_tree(root, depth, matrices=[A, B, C]):
    """Generate all triples from root to given depth."""
    triples = [root]
    current_level = [root]
    for d in range(depth):
        next_level = []
        for triple in current_level:
            for M in matrices:
                child = M @ triple
                # Normalize: make first nonzero component positive, sort (a,b)
                if child[0] < 0 or (child[0] == 0 and child[1] < 0):
                    child = -child  # shouldn't happen for positive triples
                next_level.append(child)
                triples.append(child)
        current_level = next_level
    return triples

print("=" * 70)
print("EXTENDED BERGGREN TREE FROM VACUUM (0,1,1)")
print("=" * 70)
print()

# Level 0: vacuum
print("Level 0: (0, 1, 1)  [the vacuum]")

# Level 1: apply A, B, C
level1 = [A @ vacuum, B @ vacuum, C @ vacuum]
print(f"Level 1: {[tuple(t) for t in level1]}")

# Level 2
level2 = []
for t in level1:
    for M in [A, B, C]:
        level2.append(M @ t)
print(f"Level 2: {[tuple(t) for t in level2]}")

# Level 3
level3 = []
for t in level2:
    for M in [A, B, C]:
        level3.append(M @ t)

# Count unique triples (normalizing by sorting a,b)
def normalize(t):
    a, b, c = abs(t[0]), abs(t[1]), abs(t[2])
    return (min(a,b), max(a,b), c)

unique_l3 = set(normalize(t) for t in level3)
print(f"Level 3: {len(level3)} triples, {len(unique_l3)} unique (normalized)")
print(f"  Some: {sorted(list(unique_l3))[:10]}")

# ═══════════════════════════════════════════════════════════════
# THE FIBONACCI CONNECTION
# ═══════════════════════════════════════════════════════════════

print()
print("=" * 70)
print("THE FIBONACCI CONNECTION")
print("=" * 70)
print()
print("The vacuum triple (0, 1, 1) contains the Fibonacci seed!")
print()
print("Fibonacci sequence: 0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, ...")
print()

# Fibonacci Pythagorean triples: consecutive Fibonacci numbers form
# Pythagorean-adjacent structures
fib = [0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610]

print("Fibonacci Pythagorean connections:")
for i in range(len(fib) - 3):
    a = fib[i] * fib[i+3]
    b = 2 * fib[i+1] * fib[i+2]
    c_sq = a**2 + b**2
    c = int(c_sq**0.5)
    if c*c == c_sq:
        print(f"  F({i})·F({i+3}) = {a}, 2·F({i+1})·F({i+2}) = {b} → ({a}, {b}, {c})")

# ═══════════════════════════════════════════════════════════════
# The RELATIVITY interpretation
# ═══════════════════════════════════════════════════════════════

print()
print("=" * 70)
print("THE RELATIVITY INTERPRETATION")
print("=" * 70)
print()
print("In special relativity: E² = (pc)² + (mc²)²")
print()
print("(0, 1, 1) ↔ (p=0, mc²=1, E=1)")
print("  → A particle at REST. Pure mass, no momentum.")
print("  → The vacuum of motion.")
print()
print("(1, 0, 1) ↔ (p=1, mc²=0, E=1)")
print("  → A massless particle (PHOTON). Pure momentum.")
print("  → Pure light.")
print()
print("(3, 4, 5) ↔ A massive particle with both p and m nonzero.")
print("  → Matter in motion. The first 'real' state.")
print()
print("The Berggren tree starting from (0,1,1) = creating all possible")
print("mass-momentum states from the vacuum rest state via discrete")
print("Lorentz transformations!")
print()

# ═══════════════════════════════════════════════════════════════
# Visualization: The Light Cone with Berggren lattice points
# ═══════════════════════════════════════════════════════════════

fig = plt.figure(figsize=(16, 12))

# Plot 1: The light cone with Berggren triples
ax1 = fig.add_subplot(221, projection='3d')

# Generate triples from standard root
triples_standard = generate_tree(np.array([3, 4, 5]), 3)
triples_vacuum = generate_tree(vacuum, 4)

# Draw light cone
theta = np.linspace(0, 2*np.pi, 50)
z = np.linspace(0, 50, 30)
TH, Z = np.meshgrid(theta, z)
X = Z * np.cos(TH)
Y = Z * np.sin(TH)
ax1.plot_surface(X, Y, Z, alpha=0.1, color='gold')

# Plot Berggren triples on the cone
for t in triples_standard:
    ax1.scatter(t[0], t[1], t[2], c='blue', s=20, alpha=0.7)

ax1.scatter(0, 1, 1, c='red', s=200, marker='*', zorder=5)
ax1.scatter(3, 4, 5, c='green', s=100, marker='o', zorder=5)

ax1.set_xlabel('a')
ax1.set_ylabel('b')
ax1.set_zlabel('c')
ax1.set_title('Berggren Triples on the Light Cone\n★ = Vacuum (0,1,1)')

# Plot 2: Tree structure
ax2 = fig.add_subplot(222)

def draw_tree_level(ax, root, matrices, labels, depth=3):
    """Draw the tree structure."""
    positions = {}
    positions[tuple(root)] = (0.5, 1.0)
    ax.plot(*positions[tuple(root)], 'ro', markersize=15)
    ax.annotate(str(tuple(root)), positions[tuple(root)],
                textcoords="offset points", xytext=(0, 10),
                ha='center', fontsize=8, fontweight='bold')

    current = [(root, 0.5, 1.0)]
    for d in range(min(depth, 3)):
        next_nodes = []
        width = 0.4 / (2**d)
        for triple, x, y in current:
            for i, (M, label) in enumerate(zip(matrices, labels)):
                child = M @ triple
                cx = x + (i - 1) * width
                cy = y - 0.25
                ax.plot([x, cx], [y, cy], 'k-', alpha=0.5)
                color = 'red' if tuple(child) == tuple(root) else 'blue'
                ax.plot(cx, cy, 'o', color=color, markersize=8)
                text = f"{tuple(child)}"
                if len(text) < 20:
                    ax.annotate(text, (cx, cy),
                                textcoords="offset points", xytext=(0, -12),
                                ha='center', fontsize=5)
                next_nodes.append((child, cx, cy))
        current = next_nodes

draw_tree_level(ax2, vacuum, [A, B, C], ['A', 'B', 'C'], depth=3)
ax2.set_title('Berggren Tree from Vacuum (0,1,1)\nRed = Fixed Points')
ax2.set_xlim(-0.1, 1.1)
ax2.set_ylim(-0.1, 1.1)
ax2.axis('off')

# Plot 3: The rapidity/angle distribution
ax3 = fig.add_subplot(223)

# For each triple (a,b,c), compute the "angle" θ = arctan(a/b)
angles_v = []
hyps_v = []
for t in triples_vacuum:
    if t[2] > 0:
        angle = np.arctan2(t[0], t[1])
        angles_v.append(angle)
        hyps_v.append(t[2])

ax3.scatter(angles_v, hyps_v, c=hyps_v, cmap='plasma', alpha=0.6, s=10)
ax3.axvline(0, color='red', linestyle='--', alpha=0.5, label='Vacuum angle (θ=0)')
ax3.set_xlabel('Angle θ = arctan(a/b)')
ax3.set_ylabel('Hypotenuse c (Energy)')
ax3.set_title('Angle Distribution from Vacuum Genesis')
ax3.legend()

# Plot 4: Velocity parameter β = a/c
ax4 = fig.add_subplot(224)

betas = []
energies = []
for t in triples_standard[:100]:
    if t[2] > 0:
        beta = abs(t[0]) / t[2]  # v/c
        betas.append(beta)
        energies.append(t[2])

# Add vacuum and light
ax4.scatter(0, 1, c='red', s=200, marker='*', zorder=5, label='Vacuum (0,1,1): β=0')
ax4.scatter(1, 1, c='gold', s=200, marker='D', zorder=5, label='Light (1,0,1): β=1')
ax4.scatter(betas, energies, c='blue', alpha=0.5, s=20, label='Berggren triples')

ax4.set_xlabel('β = a/c (velocity/c)')
ax4.set_ylabel('c (Energy)')
ax4.set_title('Velocity Parameter β for Berggren Triples\n0 ≤ β < 1: All speeds below light')
ax4.set_xlim(-0.05, 1.05)
ax4.legend(fontsize=8)

plt.tight_layout()
plt.savefig('/workspace/request-project/Berggren Genesis/figure_01_vacuum_genesis.png', dpi=150)
print("\n✓ Figure saved: figure_01_vacuum_genesis.png")
print()

# ═══════════════════════════════════════════════════════════════
# EIGENVALUE ANALYSIS
# ═══════════════════════════════════════════════════════════════

print("=" * 70)
print("EIGENVALUE ANALYSIS OF BERGGREN MATRICES")
print("=" * 70)
print()

for name, M in [("A", A), ("B", B), ("C", C)]:
    evals, evecs = np.linalg.eig(M)
    print(f"Matrix {name}:")
    print(f"  Eigenvalues: {np.round(evals, 6)}")
    print(f"  det = {int(round(np.linalg.det(M)))}")

    # Check if (0,1,1) is eigenvector
    Mv = M @ vacuum
    if np.allclose(Mv, vacuum):
        print(f"  (0,1,1) is a FIXED POINT (eigenvector with λ=1)")
    else:
        ratio = Mv / vacuum if all(vacuum != 0) else None
        print(f"  {name} · (0,1,1) = {tuple(Mv)}")
    print()

# ═══════════════════════════════════════════════════════════════
# COMPUTATION INTERPRETATION
# ═══════════════════════════════════════════════════════════════

print("=" * 70)
print("THE COMPUTATION INTERPRETATION")
print("=" * 70)
print()
print("The Berggren tree is a UNIVERSAL COMPUTER:")
print()
print("  (0,1,1) = Empty state / Blank tape / Zero register")
print("  Matrix A = NOP (no-operation, identity on vacuum)")
print("  Matrix B = First instruction (creates content)")
print("  Matrix C = Second instruction (creates same content!)")
print()
print("Key insight: At the vacuum, B and C are DEGENERATE —")
print("they produce the same output. This is like the symmetry")
print("breaking of the early universe: from perfect symmetry (vacuum),")
print("the first distinction creates identical copies.")
print()
print("The tree has TERNARY branching, suggesting a connection to")
print("balanced ternary arithmetic (Knuth's favorite number system).")
print()

# Count how many unique triples at each depth
for depth in range(7):
    triples_at_depth = generate_tree(vacuum, depth)
    unique = set()
    for t in triples_at_depth:
        unique.add(normalize(t))
    print(f"  Depth {depth}: {len(triples_at_depth)} nodes, {len(unique)} unique triples")

print()
print("The tree grows as 3^d but with significant collisions —")
print("multiple paths reach the same triple. This 'path multiplicity'")
print("is the DEGENERACY of each quantum state!")
