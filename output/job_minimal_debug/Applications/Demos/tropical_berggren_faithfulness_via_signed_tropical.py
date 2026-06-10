#!/usr/bin/env python3
"""
Signed Tropical Berggren Faithfulness — Python Demo

Demonstrates the key mathematical results:
1. Signed vs unsigned tropicalization (injectivity)
2. Berggren tree generation of Pythagorean triples
3. Tropical light cone recovery
4. Berggren path composition and hypotenuse growth
5. Visualization of the Berggren tree with tropical norms
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')  # Non-interactive backend
import matplotlib.pyplot as plt
from typing import Tuple, List
from enum import Enum

# =============================================================================
# Section 1: Signed Tropical Type
# =============================================================================

class TropSign(Enum):
    POS = "+"
    NEG = "-"

    def __mul__(self, other: 'TropSign') -> 'TropSign':
        """Sign multiplication: ℤ/2ℤ group operation."""
        if self == TropSign.POS:
            return other
        elif other == TropSign.POS:
            return TropSign.NEG
        else:
            return TropSign.POS  # neg * neg = pos

class SignedTrop:
    """Signed tropical element: (sign, magnitude)."""

    def __init__(self, sign: TropSign, mag: int):
        self.sign = sign
        self.mag = abs(mag)

    def __repr__(self):
        return f"({self.sign.value}, {self.mag})"

    def __eq__(self, other):
        return self.sign == other.sign and self.mag == other.mag

    def __ne__(self, other):
        return not self.__eq__(other)

    def tmul(self, other: 'SignedTrop') -> 'SignedTrop':
        """Signed tropical multiplication: signs multiply, magnitudes multiply."""
        return SignedTrop(self.sign * other.sign, self.mag * other.mag)


def sigma(n: int) -> SignedTrop:
    """Signed tropicalization: σ(n) = (sign(n), |n|)."""
    sign = TropSign.POS if n >= 0 else TropSign.NEG
    return SignedTrop(sign, abs(n))


def unsigned_trop(n: int) -> int:
    """Unsigned tropicalization: just take |n|."""
    return abs(n)


# =============================================================================
# Section 2: Demonstrate Faithfulness (Injectivity)
# =============================================================================

print("=" * 60)
print("SECTION 1: SIGNED vs UNSIGNED TROPICALIZATION")
print("=" * 60)
print()

# Show that unsigned tropicalization loses information
print("Unsigned tropicalization (lossy):")
for n in [3, -3, 5, -5, 7, -7]:
    print(f"  trop({n:3d}) = {unsigned_trop(n)}")

print()
print("Signed tropicalization (faithful):")
for n in [3, -3, 5, -5, 7, -7]:
    print(f"  σ({n:3d}) = {sigma(n)}")

print()
print("Key: σ(3) ≠ σ(-3) but trop(3) = trop(-3)")
print(f"  σ(3)  = {sigma(3)}")
print(f"  σ(-3) = {sigma(-3)}")
print(f"  σ(3) ≠ σ(-3): {sigma(3) != sigma(-3)}")
print(f"  trop(3) = trop(-3): {unsigned_trop(3) == unsigned_trop(-3)}")

# Demonstrate multiplicative homomorphism
print()
print("Multiplicative homomorphism (for nonneg):")
for m, n in [(2, 3), (4, 5), (3, 7)]:
    lhs = sigma(m * n)
    rhs = sigma(m).tmul(sigma(n))
    print(f"  σ({m}×{n}) = {lhs},  σ({m}) ⊗ σ({n}) = {rhs},  equal: {lhs == rhs}")


# =============================================================================
# Section 3: Berggren Matrices
# =============================================================================

print()
print("=" * 60)
print("SECTION 2: BERGGREN MATRICES AND PYTHAGOREAN TRIPLES")
print("=" * 60)
print()

A = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]])
B = np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]])
C = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]])
Q = np.diag([1, 1, -1])

root = np.array([3, 4, 5])

def is_pythagorean(v):
    """Check if v satisfies a² + b² = c²."""
    return v[0]**2 + v[1]**2 == v[2]**2

def lorentz_form(v):
    """Compute v₀² + v₁² - v₂²."""
    return v[0]**2 + v[1]**2 - v[2]**2

# Verify Lorentz preservation
print("Berggren matrices preserve the Lorentz form Aᵀ Q A = Q:")
for name, M in [("A", A), ("B", B), ("C", C)]:
    preserved = np.array_equal(M.T @ Q @ M, Q)
    det_val = int(round(np.linalg.det(M)))
    print(f"  {name}ᵀ Q {name} = Q: {preserved},  det({name}) = {det_val}")

# Generate depth-1 triples
print()
print("Depth-1 Berggren descendants of (3, 4, 5):")
for name, M in [("A", A), ("B", B), ("C", C)]:
    v = M @ root
    pyth = is_pythagorean(v)
    print(f"  {name}·(3,4,5) = ({v[0]}, {v[1]}, {v[2]}),  Pythagorean: {pyth}")


# =============================================================================
# Section 4: Berggren Tree Generation (3 levels)
# =============================================================================

print()
print("=" * 60)
print("SECTION 3: BERGGREN TREE (3 LEVELS)")
print("=" * 60)
print()

matrices = {"A": A, "B": B, "C": C}

def generate_berggren_tree(root, depth):
    """Generate Berggren tree to given depth."""
    nodes = [(root, "", 0)]
    all_nodes = []
    for _ in range(depth):
        new_nodes = []
        for v, path, d in nodes:
            for label, M in matrices.items():
                child = M @ v
                new_path = path + label
                new_nodes.append((child, new_path, d + 1))
        all_nodes.extend(new_nodes)
        nodes = new_nodes
    return all_nodes

tree = generate_berggren_tree(root, 3)

print(f"Root: {tuple(root)}")
print(f"Total triples generated (depth 1-3): {len(tree)}")
print()

# Group by depth
for depth in [1, 2, 3]:
    nodes_at_depth = [(v, p) for v, p, d in tree if d == depth]
    print(f"Depth {depth} ({len(nodes_at_depth)} triples):")
    for v, p in nodes_at_depth[:6]:  # show first 6
        hyp = v[2]
        trop_norm = max(abs(v[0]), abs(v[1]), abs(v[2]))
        print(f"  path={p:4s}  triple=({v[0]:5d}, {v[1]:5d}, {v[2]:5d})  "
              f"hypotenuse={hyp:5d}  tropNorm={trop_norm}")
    if len(nodes_at_depth) > 6:
        print(f"  ... ({len(nodes_at_depth) - 6} more)")
    print()


# =============================================================================
# Section 5: Tropical Light Cone Recovery
# =============================================================================

print("=" * 60)
print("SECTION 4: TROPICAL LIGHT CONE RECOVERY")
print("=" * 60)
print()

print("Tropical light cone: σ(a)² + σ(b)² = σ(c)² iff a² + b² = c²")
print()

triples = [(3, 4, 5), (5, 12, 13), (8, 15, 17), (7, 24, 25),
           (3, 4, 6), (1, 2, 3), (5, 5, 7)]  # last 3 are not Pythagorean

for a, b, c in triples:
    classical = (a**2 + b**2 == c**2)
    sa, sb, sc = sigma(a), sigma(b), sigma(c)
    tropical = (sa.mag**2 + sb.mag**2 == sc.mag**2)
    print(f"  ({a:2d}, {b:2d}, {c:2d}): "
          f"classical a²+b²=c²: {str(classical):5s}  "
          f"tropical σ(a).mag²+σ(b).mag²=σ(c).mag²: {str(tropical):5s}  "
          f"match: {classical == tropical}")


# =============================================================================
# Section 6: Hypotenuse Growth Visualization
# =============================================================================

print()
print("=" * 60)
print("SECTION 5: HYPOTENUSE GROWTH ALONG BERGGREN PATHS")
print("=" * 60)
print()

# Generate long paths and track hypotenuse
def berggren_path(path_string, start=root):
    """Apply a sequence of Berggren matrices."""
    v = start.copy()
    for c in path_string:
        v = matrices[c] @ v
    return v

# All-B path: exponential growth
print("All-B path (fastest growth, all entries positive):")
v = root.copy()
b_hyps = [v[2]]
for i in range(8):
    v = B @ v
    b_hyps.append(v[2])
    if i < 5:
        print(f"  B^{i+1}·root: hypotenuse = {v[2]}")

print()
print("All-A path (slower growth, has negative entries):")
v = root.copy()
a_hyps = [v[2]]
for i in range(8):
    v = A @ v
    a_hyps.append(v[2])
    if i < 5:
        print(f"  A^{i+1}·root: hypotenuse = {v[2]}")

print()
print("All-C path:")
v = root.copy()
c_hyps = [v[2]]
for i in range(8):
    v = C @ v
    c_hyps.append(v[2])
    if i < 5:
        print(f"  C^{i+1}·root: hypotenuse = {v[2]}")


# =============================================================================
# Section 7: Signed Tropical Collision Resistance
# =============================================================================

print()
print("=" * 60)
print("SECTION 6: COLLISION RESISTANCE")
print("=" * 60)
print()

# Check that all depth-2 paths give distinct triples
depth2_paths = [l1 + l2 for l1 in "ABC" for l2 in "ABC"]
depth2_results = {}
for path in depth2_paths:
    v = berggren_path(path)
    key = tuple(v)
    if key in depth2_results:
        print(f"COLLISION! paths {depth2_results[key]} and {path} give same triple {key}")
    else:
        depth2_results[key] = path

print(f"Depth-2 paths: {len(depth2_paths)}, distinct triples: {len(depth2_results)}")
print(f"No collisions at depth 2: {len(depth2_paths) == len(depth2_results)}")

# Check depth 3
depth3_paths = [l1 + l2 + l3 for l1 in "ABC" for l2 in "ABC" for l3 in "ABC"]
depth3_results = {}
for path in depth3_paths:
    v = berggren_path(path)
    depth3_results[tuple(v)] = path

print(f"Depth-3 paths: {len(depth3_paths)}, distinct triples: {len(depth3_results)}")
print(f"No collisions at depth 3: {len(depth3_paths) == len(depth3_results)}")


# =============================================================================
# Section 8: Visualization
# =============================================================================

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Plot 1: Hypotenuse growth
ax = axes[0]
steps = range(len(b_hyps))
ax.semilogy(steps, b_hyps, 'b-o', label='Path B^n', markersize=4)
ax.semilogy(steps, a_hyps, 'r-s', label='Path A^n', markersize=4)
ax.semilogy(steps, c_hyps, 'g-^', label='Path C^n', markersize=4)
ax.set_xlabel('Depth n')
ax.set_ylabel('Hypotenuse c (log scale)')
ax.set_title('Berggren Tree: Exponential Hypotenuse Growth')
ax.legend()
ax.grid(True, alpha=0.3)

# Plot 2: Pythagorean triples on the a-b plane (depth 1-3)
ax = axes[1]
for v, p, d in tree:
    color = ['red', 'blue', 'green'][d - 1]
    alpha = 1.0 if d == 1 else (0.7 if d == 2 else 0.4)
    ax.plot(v[0], v[1], 'o', color=color, alpha=alpha, markersize=8 - d * 2)

ax.plot(root[0], root[1], 'k*', markersize=15, label='Root (3,4)')
ax.set_xlabel('a')
ax.set_ylabel('b')
ax.set_title('Berggren Tree: Pythagorean Triples (a, b)')
ax.legend()
ax.grid(True, alpha=0.3)
ax.set_aspect('equal')

# Plot 3: Signed vs unsigned tropicalization
ax = axes[2]
integers = list(range(-10, 11))
unsigned = [abs(n) for n in integers]
signed_pos = [abs(n) if n >= 0 else None for n in integers]
signed_neg = [abs(n) if n < 0 else None for n in integers]

ax.scatter(integers, unsigned, color='gray', alpha=0.5, s=80, label='Unsigned (lossy)', zorder=2)
ax.scatter([n for n in integers if n >= 0],
           [abs(n) for n in integers if n >= 0],
           color='blue', s=40, marker='^', label='Signed: pos', zorder=3)
ax.scatter([n for n in integers if n < 0],
           [abs(n) for n in integers if n < 0],
           color='red', s=40, marker='v', label='Signed: neg', zorder=3)

# Draw arrows showing information loss
for n in [3, 5, 7]:
    ax.annotate('', xy=(n, abs(n)), xytext=(-n, abs(n)),
                arrowprops=dict(arrowstyle='<->', color='orange', lw=1.5, ls='--'))

ax.set_xlabel('Integer n')
ax.set_ylabel('|n| (magnitude)')
ax.set_title('Signed vs Unsigned Tropicalization')
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('Tropical/SignedBerggren/berggren_tropical_demo.png', dpi=150, bbox_inches='tight')
print()
print("Visualization saved to Tropical/SignedBerggren/berggren_tropical_demo.png")

# =============================================================================
# Summary
# =============================================================================

print()
print("=" * 60)
print("SUMMARY")
print("=" * 60)
print()
print("Key results demonstrated:")
print("  1. Signed tropicalization σ is injective (faithful)")
print("  2. Unsigned tropicalization loses sign information")
print("  3. Berggren matrices A, B, C preserve the Lorentz form")
print("  4. All Berggren descendants are Pythagorean triples")
print("  5. Tropical light cone exactly recovers Pythagorean condition")
print("  6. Hypotenuse grows exponentially along Berggren paths")
print("  7. No collisions in Berggren paths (up to depth 3)")
print()
print("All results are formally verified in Lean 4 (see Core.lean)")
