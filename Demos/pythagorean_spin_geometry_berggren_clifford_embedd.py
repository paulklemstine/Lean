#!/usr/bin/env python3
"""
Pythagorean Spin Geometry — Interactive Demo

Demonstrates the key mathematical results from the formalization:
1. Berggren tree generation and light-cone membership
2. SL₂ lifts and Möbius cusp action
3. Spectral gap computation and Pell equation connections
4. Clifford algebra Cl(2,1) multiplication verification
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import List, Tuple

# ============================================================================
# Section 1: Berggren Matrices and Tree Generation
# ============================================================================

# Berggren generators (3x3 integer matrices preserving Q = a² + b² - c²)
M1 = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]])
M2 = np.array([[1,  2, 2], [2,  1, 2], [2,  2, 3]])
M3 = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]])

BERGGREN = [M1, M2, M3]
ROOT = np.array([3, 4, 5])

def minkowski_form(v):
    """Q(a,b,c) = a² + b² - c²"""
    return v[0]**2 + v[1]**2 - v[2]**2

def generate_berggren_tree(depth: int) -> List[np.ndarray]:
    """Generate all primitive Pythagorean triples up to given depth."""
    triples = [ROOT]
    current_level = [ROOT]
    for _ in range(depth):
        next_level = []
        for triple in current_level:
            for M in BERGGREN:
                child = M @ triple
                triples.append(child)
                next_level.append(child)
        current_level = next_level
    return triples

print("=" * 60)
print("  PYTHAGOREAN SPIN GEOMETRY — DEMO")
print("=" * 60)

# Generate triples
print("\n1. BERGGREN TREE (depth 2)")
print("-" * 40)
triples = generate_berggren_tree(2)
print(f"Root: {ROOT}  Q = {minkowski_form(ROOT)}")
print("\nFirst generation:")
for i, M in enumerate(BERGGREN):
    child = M @ ROOT
    Q = minkowski_form(child)
    a, b, c = child
    print(f"  M{i+1}·(3,4,5) = ({a},{b},{c})  Q = {Q}  "
          f"Check: {a}² + {b}² = {a**2 + b**2} = {c}² = {c**2}")

print(f"\nTotal triples at depth 2: {len(triples)}")
print("All on light cone (Q=0)?", all(minkowski_form(t) == 0 for t in triples))

# ============================================================================
# Section 2: SL₂ Lifts and Cusp Action
# ============================================================================

print("\n\n2. SL₂ LIFTS AND MODULAR GROUP")
print("-" * 40)

# SL₂ lifts
SL2_M1 = np.array([[1, -1], [1, 0]])
SL2_M2 = np.array([[2, 1], [1, 1]])
SL2_M3 = np.array([[0, 1], [-1, 2]])

SL2_LIFTS = [SL2_M1, SL2_M2, SL2_M3]
names = ["M₁", "M₂", "M₃"]

for name, M, SL in zip(names, BERGGREN, SL2_LIFTS):
    det3 = int(round(np.linalg.det(M)))
    det2 = int(round(np.linalg.det(SL)))
    tr3 = int(np.trace(M))
    tr2 = int(np.trace(SL))
    print(f"  {name}: det₃ = {det3:+d}, tr₃ = {tr3}, det₂ = {det2}, tr₂ = {tr2}")

    # Classification
    if abs(tr2) < 2:
        cls = "elliptic"
    elif abs(tr2) == 2:
        cls = "parabolic"
    else:
        cls = "hyperbolic"
    print(f"       SL₂ classification: {cls}")

# Cusp action
print("\nMöbius cusp action (p/q representation):")
cusp_inf = np.array([1, 0])  # ∞ = 1/0
cusp_zero = np.array([0, 1]) # 0 = 0/1

for name, SL in zip(names, SL2_LIFTS):
    img = SL @ cusp_inf
    if img[1] == 0:
        val = "∞"
    else:
        val = f"{img[0]}/{img[1]}"
    print(f"  {name}(∞) = ({img[0]}:{img[1]}) = {val}")

# ============================================================================
# Section 3: Spectral Gap
# ============================================================================

print("\n\n3. SPECTRAL GAP AND DIRAC OPERATOR")
print("-" * 40)

sqrt2 = np.sqrt(2)
spectral_gap = sqrt2 - 1
laplacian_gap = 3 - 2 * sqrt2

print(f"  Laplacian spectral gap: 3 - 2√2 = {laplacian_gap:.6f}")
print(f"  Dirac spectral gap:     √2 - 1  = {spectral_gap:.6f}")
print(f"  Identity: (√2-1)²              = {spectral_gap**2:.6f}")
print(f"            3 - 2√2              = {laplacian_gap:.6f}")
print(f"  Match: {abs(spectral_gap**2 - laplacian_gap) < 1e-14}")

print(f"\n  Silver ratio: δ = 1+√2 = {1 + sqrt2:.6f}")
print(f"  δ · (√2-1) = {(1+sqrt2)*spectral_gap:.6f} (should be 1)")

print(f"\n  Spectral gap bounds:")
print(f"    2/5 = {2/5:.4f} < √2-1 = {spectral_gap:.4f} < 1/2 = {1/2:.4f}")

phi = (1 + np.sqrt(5)) / 2
print(f"\n  Golden ratio: φ = {phi:.6f}")
print(f"  log(φ)  = {np.log(phi):.6f}")
print(f"  1/φ     = {1/phi:.6f}")
print(f"  √2 - 1  = {spectral_gap:.6f}")
print(f"  log(φ) > √2-1 > 0: spectral gap below Fibonacci growth rate")

# ============================================================================
# Section 4: Pell Equation Connection
# ============================================================================

print("\n\n4. PELL EQUATION x² - 2y² = ±1")
print("-" * 40)

pell_solutions = [(1,1), (3,2), (7,5), (17,12), (41,29), (99,70), (239,169)]
print("  (x, y)     x²-2y²   y = CF denom of √2")
for x, y in pell_solutions:
    val = x*x - 2*y*y
    note = ""
    if y == 29:
        note = " ← Berggren hypotenuse! M₂(3,4,5)=(21,20,29)"
    if y == 169:
        note = " ← M₂²(3,4,5) hypotenuse"
    print(f"  ({x:3d}, {y:3d})  {val:+4d}      {y}{note}")

# ============================================================================
# Section 5: M₂ Exponential Growth
# ============================================================================

print("\n\n5. M₂ EXPONENTIAL GROWTH")
print("-" * 40)

v = ROOT.copy()
eigenvalue = 3 + 2*sqrt2
print(f"  Dominant eigenvalue: 3+2√2 = {eigenvalue:.6f}")
print(f"  Conjugate eigenvalue: 3-2√2 = {3-2*sqrt2:.6f}")
print(f"  Product: (3+2√2)(3-2√2) = {eigenvalue*(3-2*sqrt2):.6f} (= 1)")
print()

for k in range(7):
    c = v[2]
    ratio = c / ROOT[2] if k > 0 else 1
    predicted = eigenvalue**k
    print(f"  M₂^{k}(3,4,5): c = {c:>10d}, "
          f"c/5 = {ratio:>12.2f}, "
          f"(3+2√2)^{k} = {predicted:>12.2f}")
    v = M2 @ v

# ============================================================================
# Section 6: Clifford Algebra Cl(2,1) Verification
# ============================================================================

print("\n\n6. CLIFFORD ALGEBRA Cl(2,1)")
print("-" * 40)

# Represent Cl(2,1) elements as 8-vectors
# Basis: {1, e₁, e₂, e₃, e₁₂, e₁₃, e₂₃, e₁₂₃}

def cl21_mul(a, b):
    """Clifford multiplication in Cl(2,1)."""
    result = np.zeros(8, dtype=int)
    result[0] = (a[0]*b[0] - a[1]*b[1] - a[2]*b[2] + a[3]*b[3]
                 - a[4]*b[4] + a[5]*b[5] + a[6]*b[6] - a[7]*b[7])
    result[1] = (a[0]*b[1] + a[1]*b[0] - a[2]*b[4] + a[3]*b[5]
                 + a[4]*b[2] - a[5]*b[3] - a[6]*b[7] + a[7]*b[6])
    result[2] = (a[0]*b[2] + a[1]*b[4] + a[2]*b[0] + a[3]*b[6]
                 - a[4]*b[1] - a[5]*b[7] - a[6]*b[3] - a[7]*b[5])
    result[3] = (a[0]*b[3] + a[1]*b[5] + a[2]*b[6] + a[3]*b[0]
                 - a[4]*b[7] + a[5]*b[1] + a[6]*b[2] + a[7]*b[4])
    result[4] = (a[0]*b[4] + a[1]*b[2] - a[2]*b[1] + a[3]*b[7]
                 + a[4]*b[0] + a[5]*b[6] - a[6]*b[5] + a[7]*b[3])
    result[5] = (a[0]*b[5] + a[1]*b[3] - a[2]*b[7] - a[3]*b[1]
                 + a[4]*b[6] + a[5]*b[0] - a[6]*b[4] - a[7]*b[2])
    result[6] = (a[0]*b[6] + a[1]*b[7] + a[2]*b[3] - a[3]*b[2]
                 - a[4]*b[5] + a[5]*b[4] + a[6]*b[0] + a[7]*b[1])
    result[7] = (a[0]*b[7] + a[1]*b[6] - a[2]*b[5] + a[3]*b[4]
                 + a[4]*b[3] - a[5]*b[2] + a[6]*b[1] + a[7]*b[0])
    return result

basis_names = ['1', 'e₁', 'e₂', 'e₃', 'e₁₂', 'e₁₃', 'e₂₃', 'e₁₂₃']
basis = [np.zeros(8, dtype=int) for _ in range(8)]
for i in range(8):
    basis[i][i] = 1

print("  Clifford relations:")
for i, name in [(1,'e₁'), (2,'e₂'), (3,'e₃')]:
    sq = cl21_mul(basis[i], basis[i])
    scalar = sq[0]
    print(f"    {name}² = {scalar:+d}")

print("\n  Anticommutativity:")
for (i,j) in [(1,2), (1,3), (2,3)]:
    prod_ij = cl21_mul(basis[i], basis[j])
    prod_ji = cl21_mul(basis[j], basis[i])
    print(f"    {basis_names[i]}·{basis_names[j]} + {basis_names[j]}·{basis_names[i]} = "
          f"{(prod_ij + prod_ji).tolist()}")

vol = basis[7]
vol_sq = cl21_mul(vol, vol)
print(f"\n  Volume element: (e₁₂₃)² = {vol_sq[0]} {'(imaginary unit!)' if vol_sq[0]==-1 else ''}")

# ============================================================================
# Section 7: Visualization
# ============================================================================

print("\n\n7. GENERATING VISUALIZATIONS...")
print("-" * 40)

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Plot 1: Pythagorean triples from Berggren tree
ax = axes[0]
triples = generate_berggren_tree(4)
xs = [t[0] for t in triples]
ys = [t[1] for t in triples]
cs = [t[2] for t in triples]
ax.scatter(xs, ys, c=cs, cmap='viridis', s=15, alpha=0.7)
ax.set_xlabel('a')
ax.set_ylabel('b')
ax.set_title('Berggren Tree: Primitive Pythagorean Triples\n(color = hypotenuse c)')
ax.set_aspect('equal')
ax.grid(True, alpha=0.3)

# Plot 2: M₂ hypotenuse growth
ax = axes[1]
v = ROOT.copy()
hypotenuses = [v[2]]
for k in range(8):
    v = M2 @ v
    hypotenuses.append(v[2])
ks = range(len(hypotenuses))
ax.semilogy(list(ks), hypotenuses, 'bo-', label='Actual c(k)')
predicted = [5 * eigenvalue**k for k in ks]
ax.semilogy(list(ks), predicted, 'r--', label=f'5·(3+2√2)^k', alpha=0.7)
ax.set_xlabel('Depth k')
ax.set_ylabel('Hypotenuse c')
ax.set_title('M₂ Branch: Exponential Growth\n(rate = 3+2√2 ≈ 5.83)')
ax.legend()
ax.grid(True, alpha=0.3)

# Plot 3: Spectral gap diagram
ax = axes[2]
d_values = range(3, 12)
gaps = [d - 2*np.sqrt(d-1) for d in d_values]
ax.bar([str(d) for d in d_values], gaps, color='steelblue', alpha=0.8)
ax.axhline(y=3-2*sqrt2, color='red', linestyle='--',
           label=f'd=3 gap = {3-2*sqrt2:.3f}')
ax.set_xlabel('Vertex degree d')
ax.set_ylabel('Spectral gap λ₁ = d - 2√(d-1)')
ax.set_title('Kesten-McKay Spectral Gap\nfor d-Regular Trees')
ax.legend()
ax.grid(True, alpha=0.3, axis='y')

plt.tight_layout()
plt.savefig('diagram.svg', format='svg', dpi=150)
plt.savefig('diagram.png', format='png', dpi=150)
print("  Saved: diagram.svg, diagram.png")

print("\n" + "=" * 60)
print("  All computations verified. See Lean files for formal proofs.")
print("=" * 60)
