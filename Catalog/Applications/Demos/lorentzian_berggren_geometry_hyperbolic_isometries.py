#!/usr/bin/env python3
"""
Lorentzian Berggren Geometry: Interactive Demo

Demonstrates the Lorentzian structure of the Berggren tree of Pythagorean triples.
The three Berggren matrices M₁, M₂, M₃ generate all primitive Pythagorean triples
from the root (3,4,5). Each matrix preserves the Minkowski quadratic form
Q(a,b,c) = a² + b² - c², placing them in the integer Lorentz group O(2,1;ℤ).

Key insight: M₂ is hyperbolic (exponential growth), while M₁ and M₃ are parabolic
(polynomial growth). The hypotenuse along the M₂ branch grows as (3+2√2)^k ≈ 5.83^k.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from math import gcd, log, acosh, sqrt

# === Berggren Matrices ===
M1 = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]], dtype=np.int64)
M2 = np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]], dtype=np.int64)
M3 = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]], dtype=np.int64)

GENERATORS = {'M1': M1, 'M2': M2, 'M3': M3}
ROOT = np.array([3, 4, 5], dtype=np.int64)

J = np.diag([1, 1, -1])  # Minkowski metric

def minkowski_form(v):
    """Q(a,b,c) = a² + b² - c²"""
    return v[0]**2 + v[1]**2 - v[2]**2

def lorentzian_displacement(M):
    """Displacement = arccosh((|tr(M)|-1)/2) if ≥1, else 0."""
    t = abs(np.trace(M))
    val = (t - 1) / 2
    return acosh(val) if val >= 1 else 0.0

# === Verification Section ===
print("=" * 60)
print("LORENTZIAN BERGGREN GEOMETRY — NUMERICAL VERIFICATION")
print("=" * 60)

print("\n1. MINKOWSKI FORM PRESERVATION (Q(Mv) = Q(v))")
print("-" * 40)
for name, M in GENERATORS.items():
    # Verify M^T J M = J
    result = M.T @ J @ M
    preserves = np.array_equal(result, J)
    print(f"  {name}^T · J · {name} = J: {preserves}")

print(f"\n  Q(root) = Q({ROOT}) = {minkowski_form(ROOT)}")
for name, M in GENERATORS.items():
    v = M @ ROOT
    print(f"  Q({name}·root) = Q({v}) = {minkowski_form(v)}")

print("\n2. DETERMINANTS")
print("-" * 40)
for name, M in GENERATORS.items():
    d = int(round(np.linalg.det(M)))
    print(f"  det({name}) = {d}")

print("\n3. TRACES AND DISPLACEMENT")
print("-" * 40)
for name, M in GENERATORS.items():
    tr = np.trace(M)
    disp = lorentzian_displacement(M)
    kind = "hyperbolic" if disp > 0 else "parabolic"
    print(f"  tr({name}) = {tr}, displacement = {disp:.4f} ({kind})")

print("\n4. EIGENVALUES")
print("-" * 40)
for name, M in GENERATORS.items():
    evals = sorted(np.linalg.eigvals(M).real, reverse=True)
    print(f"  {name}: λ = [{', '.join(f'{e:.4f}' for e in evals)}]")

spectral_radius = 3 + 2*sqrt(2)
print(f"\n  3+2√2 = {spectral_radius:.6f} (spectral radius of M₂)")
print(f"  3-2√2 = {1/spectral_radius:.6f} (reciprocal eigenvalue)")

print("\n5. UNIPOTENT STRUCTURE OF M₁, M₃")
print("-" * 40)
I3 = np.eye(3, dtype=np.int64)
for name, M in [('M1', M1), ('M3', M3)]:
    N = M - I3
    print(f"  ({name}-I)² = {'nonzero' if np.any(N @ N) else 'zero'}")
    print(f"  ({name}-I)³ = {'nonzero' if np.any(N @ N @ N) else 'zero'}")

print("\n6. BERGGREN TREE — FIRST 3 LEVELS")
print("-" * 40)

def generate_tree(root, depth, prefix=""):
    """Generate Berggren tree up to given depth."""
    triples = [(prefix or "root", root)]
    if depth > 0:
        for name, M in [("M1", M1), ("M2", M2), ("M3", M3)]:
            child = M @ root
            label = f"{prefix}{name}" if prefix else name
            triples.append((label, child))
            if depth > 1:
                for name2, M2_ in [("M1", M1), ("M2", M2), ("M3", M3)]:
                    grandchild = M2_ @ child
                    triples.append((f"{label}·{name2}", grandchild))
    return triples

tree = generate_tree(ROOT, 2)
for label, v in tree:
    a, b, c = v
    check = "✓" if a*a + b*b == c*c else "✗"
    prim = gcd(gcd(abs(int(a)), abs(int(b))), abs(int(c)))
    print(f"  {label:12s} → ({a:5d}, {b:5d}, {c:5d})  {check}  gcd={prim}")

print("\n7. M₂ BRANCH: EXPONENTIAL GROWTH")
print("-" * 40)
v = ROOT.copy()
hypotenuses = []
for k in range(8):
    c = int(v[2])
    hypotenuses.append(c)
    disp = lorentzian_displacement(np.linalg.matrix_power(M2, k)) if k > 0 else 0
    ratio = hypotenuses[-1] / hypotenuses[-2] if k > 0 else 0
    print(f"  k={k}: c = {c:>12d}  ratio = {ratio:>8.4f}  "
          f"log(c) = {log(c):>8.4f}  Δ = {disp:>8.4f}")
    v = M2 @ v

print(f"\n  Limiting ratio: 3+2√2 = {spectral_radius:.6f}")
print(f"  log(3+2√2) = {log(spectral_radius):.6f}")

print("\n8. M₁ BRANCH: POLYNOMIAL (QUADRATIC) GROWTH")
print("-" * 40)
v = ROOT.copy()
for k in range(8):
    a, b, c = int(v[0]), int(v[1]), int(v[2])
    predicted_c = 2*(k+1)*(k+2) + 1  # The pattern 5,13,25,41,...
    print(f"  k={k}: ({a:>5d}, {b:>5d}, {c:>5d})  "
          f"  2(k+1)(k+2)+1 = {predicted_c}")
    v = M1 @ v

print("\n9. DISPLACEMENT–HYPOTENUSE DUALITY")
print("-" * 40)
print("  For word w with matrix A = evalBerggrenWord(w):")
print("  log(c) ≈ Δ(A) where Δ = lorentzian displacement")
print()

# Test on various words
import itertools
words_depth3 = list(itertools.product(['M1', 'M2', 'M3'], repeat=3))
for word in words_depth3[:9]:
    A = np.eye(3, dtype=np.int64)
    for g in word:
        A = GENERATORS[g] @ A
    v = A @ ROOT
    c = int(v[2])
    disp = lorentzian_displacement(A)
    gap = abs(log(c) - disp)
    print(f"  {'·'.join(word):12s}: c={c:>6d}  log(c)={log(c):>7.3f}  "
          f"Δ={disp:>7.3f}  |gap|={gap:.3f}")

# === Visualizations ===
print("\n10. GENERATING VISUALIZATIONS...")
print("-" * 40)

# Figure 1: Berggren tree growth comparison
fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# M₂ branch (exponential)
v = ROOT.copy()
m2_hyps = []
for k in range(10):
    m2_hyps.append(int(v[2]))
    v = M2 @ v

axes[0].semilogy(range(10), m2_hyps, 'ro-', linewidth=2, markersize=8, label='M₂ branch')
axes[0].semilogy(range(10), [5 * spectral_radius**k for k in range(10)],
                 'b--', linewidth=1, alpha=0.7, label=f'5·(3+2√2)^k')
axes[0].set_xlabel('Depth k', fontsize=12)
axes[0].set_ylabel('Hypotenuse c (log scale)', fontsize=12)
axes[0].set_title('M₂ Branch: Exponential Growth\n(Hyperbolic Isometry)', fontsize=14)
axes[0].legend(fontsize=11)
axes[0].grid(True, alpha=0.3)

# M₁ branch (polynomial)
v = ROOT.copy()
m1_hyps = []
for k in range(10):
    m1_hyps.append(int(v[2]))
    v = M1 @ v

axes[1].plot(range(10), m1_hyps, 'go-', linewidth=2, markersize=8, label='M₁ branch')
axes[1].plot(range(10), [2*(k+1)*(k+2)+1 for k in range(10)],
             'b--', linewidth=1, alpha=0.7, label='2(k+1)(k+2)+1')
axes[1].set_xlabel('Depth k', fontsize=12)
axes[1].set_ylabel('Hypotenuse c', fontsize=12)
axes[1].set_title('M₁ Branch: Quadratic Growth\n(Parabolic Isometry)', fontsize=14)
axes[1].legend(fontsize=11)
axes[1].grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('berggren_growth.png', dpi=150, bbox_inches='tight')
print("  Saved: berggren_growth.png")

# Figure 2: Berggren tree on the projective light cone
fig, ax = plt.subplots(1, 1, figsize=(12, 10))

def plot_tree_recursive(v, depth, max_depth, color_map, ax, parent_pos=None):
    """Plot the Berggren tree on the projective light cone (a/c, b/c)."""
    a, b, c = float(v[0]), float(v[1]), float(v[2])
    pos = (a/c, b/c)
    
    if parent_pos is not None:
        ax.plot([parent_pos[0], pos[0]], [parent_pos[1], pos[1]],
                'k-', alpha=0.2, linewidth=0.5)
    
    color = color_map.get(depth, 'gray')
    size = max(3, 50 - depth * 8)
    ax.plot(pos[0], pos[1], 'o', color=color, markersize=size,
            markeredgecolor='black', markeredgewidth=0.5)
    
    if depth < max_depth:
        for M in [M1, M2, M3]:
            child = M @ v
            plot_tree_recursive(child, depth+1, max_depth, color_map, ax, pos)

color_map = {0: 'red', 1: 'blue', 2: 'green', 3: 'purple', 4: 'orange', 5: 'cyan'}
plot_tree_recursive(ROOT, 0, 5, color_map, ax)

# Plot the unit circle (boundary of {a²+b²=c²} ↔ (a/c)²+(b/c)²=1)
theta = np.linspace(0, np.pi/2, 100)
ax.plot(np.cos(theta), np.sin(theta), 'k-', alpha=0.3, linewidth=2, label='Unit circle')

ax.set_xlabel('a/c (normalized first leg)', fontsize=12)
ax.set_ylabel('b/c (normalized second leg)', fontsize=12)
ax.set_title('Berggren Tree on the Projective Light Cone\n'
             'Depth 0=red, 1=blue, 2=green, 3=purple, 4=orange, 5=cyan', fontsize=14)
ax.set_aspect('equal')
ax.set_xlim(-0.05, 1.05)
ax.set_ylim(-0.05, 1.05)
ax.grid(True, alpha=0.2)
ax.legend(fontsize=11)

plt.tight_layout()
plt.savefig('berggren_lightcone.png', dpi=150, bbox_inches='tight')
print("  Saved: berggren_lightcone.png")

# Figure 3: Displacement vs log(hypotenuse) scatter
fig, ax = plt.subplots(1, 1, figsize=(10, 8))

displacements = []
log_hypotenuses = []
depths = []
n_m2 = []

for depth in range(1, 5):
    for word in itertools.product(range(3), repeat=depth):
        matrices = [M1, M2, M3]
        A = np.eye(3, dtype=np.int64)
        m2_count = 0
        for g in word:
            A = matrices[g] @ A
            if g == 1:  # M₂
                m2_count += 1
        v = A @ ROOT
        c = int(v[2])
        if c > 0:
            disp = lorentzian_displacement(A)
            displacements.append(disp)
            log_hypotenuses.append(log(c))
            depths.append(depth)
            n_m2.append(m2_count)

scatter = ax.scatter(displacements, log_hypotenuses,
                     c=n_m2, cmap='viridis', s=50, alpha=0.7,
                     edgecolors='black', linewidth=0.5)
plt.colorbar(scatter, ax=ax, label='Number of M₂ generators')

# Perfect duality line: log(c) = Δ + log(5)
d_range = np.linspace(0, max(displacements), 100)
ax.plot(d_range, d_range + log(5), 'r--', linewidth=2, alpha=0.7,
        label='log(c) = Δ + log(5)')
ax.plot(d_range, d_range, 'k--', linewidth=1, alpha=0.3, label='log(c) = Δ')

ax.set_xlabel('Lorentzian Displacement Δ', fontsize=12)
ax.set_ylabel('log(hypotenuse)', fontsize=12)
ax.set_title('Displacement–Hypotenuse Duality\n'
             '"Gravitational Redshift" of Pythagorean Triples', fontsize=14)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('displacement_duality.png', dpi=150, bbox_inches='tight')
print("  Saved: displacement_duality.png")

print("\n" + "=" * 60)
print("DEMO COMPLETE")
print("=" * 60)
