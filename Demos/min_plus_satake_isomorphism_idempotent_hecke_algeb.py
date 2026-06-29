"""
Min-Plus Satake Isomorphism: Numerical Demonstrations

This script demonstrates the key theorems from the tropical Satake theory:
1. Min-plus semiring operations
2. Tropical Cartan decomposition (= sorting)
3. Tropical Schur polynomials and their simplification
4. Lipschitz bounds for tropical matrix invariants
5. The Satake correspondence
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')

# ============================================================
# Section 1: Min-Plus Semiring Operations
# ============================================================

def trop_add(a, b):
    """Tropical addition: min(a, b)"""
    return min(a, b)

def trop_mul(a, b):
    """Tropical multiplication: a + b"""
    return a + b

print("=" * 60)
print("SECTION 1: Min-Plus Semiring")
print("=" * 60)

# Idempotence
for x in [3.14, -2.7, 0, 100]:
    assert trop_add(x, x) == x, f"Idempotence failed for {x}"
    print(f"  min({x}, {x}) = {x}  ✓ (idempotent)")

# Commutativity
for a, b in [(3, 5), (-1, 2), (0, 0), (7, -3)]:
    assert trop_add(a, b) == trop_add(b, a)
    print(f"  min({a}, {b}) = min({b}, {a}) = {trop_add(a,b)}  ✓ (commutative)")

# Distributivity: a + min(b,c) = min(a+b, a+c)
for a, b, c in [(1, 2, 3), (-1, 5, -2), (0, 0, 0)]:
    lhs = trop_mul(a, trop_add(b, c))
    rhs = trop_add(trop_mul(a, b), trop_mul(a, c))
    assert lhs == rhs, f"Distributivity failed for {a},{b},{c}"
    print(f"  {a} + min({b},{c}) = min({a}+{b}, {a}+{c}) = {lhs}  ✓ (distributive)")

# ============================================================
# Section 2: Tropical Matrix Operations
# ============================================================

print("\n" + "=" * 60)
print("SECTION 2: Tropical 2×2 Matrix Invariants")
print("=" * 60)

def tropical_det(M):
    """Tropical determinant: min(M00+M11, M01+M10)"""
    return min(M[0,0] + M[1,1], M[0,1] + M[1,0])

def tropical_trace(M):
    """Tropical trace: min(M00, M11)"""
    return min(M[0,0], M[1,1])

def tropical_spectral_gap(a, b):
    """Spectral gap: |a - b|"""
    return abs(a - b)

# Example matrices
M1 = np.array([[1.0, 3.0], [5.0, 2.0]])
M2 = np.array([[4.0, 1.0], [2.0, 7.0]])

for M, name in [(M1, "M1"), (M2, "M2")]:
    print(f"\n  {name} = {M.tolist()}")
    print(f"    trop_det({name})   = min({M[0,0]}+{M[1,1]}, {M[0,1]}+{M[1,0]}) = {tropical_det(M)}")
    print(f"    trop_trace({name}) = min({M[0,0]}, {M[1,1]}) = {tropical_trace(M)}")

# ============================================================
# Section 3: Tropical Cartan Decomposition
# ============================================================

print("\n" + "=" * 60)
print("SECTION 3: Tropical Cartan Decomposition (= Sorting)")
print("=" * 60)

def cartan_decompose(a, b):
    """Cartan decomposition: returns dominant weight (max, min)"""
    return max(a, b), min(a, b)

pairs = [(3, 7), (-2, 5), (4, 4), (10, -3), (0, 0)]
for a, b in pairs:
    w1, w2 = cartan_decompose(a, b)
    print(f"  ({a}, {b}) → dominant weight ({w1}, {w2})")
    print(f"    w₁ ≥ w₂: {w1} ≥ {w2} ✓")
    print(f"    det preserved: {w1}+{w2} = {w1+w2} = {a}+{b} = {a+b} ✓")
    assert w1 >= w2
    assert w1 + w2 == a + b

# ============================================================
# Section 4: Tropical Schur Polynomials
# ============================================================

print("\n" + "=" * 60)
print("SECTION 4: Tropical Schur Polynomials for GL₂")
print("=" * 60)

def tropical_schur(w1, w2, x1, x2):
    """Tropical Schur polynomial: min over S₂ permutations"""
    term1 = w1 + x1 + w2 + x2
    term2 = w2 + x1 + w1 + x2
    return min(term1, term2)

# Demonstrate simplification: both terms are always equal
print("\n  Simplification: s_{(w₁,w₂)}(x₁,x₂) = w₁+w₂+x₁+x₂")
for w1, w2, x1, x2 in [(1,2,3,4), (5,-1,0,3), (-2,-3,7,1)]:
    s = tropical_schur(w1, w2, x1, x2)
    expected = w1 + w2 + x1 + x2
    print(f"  s_{{({w1},{w2})}}({x1},{x2}) = {s} = {w1}+{w2}+{x1}+{x2} = {expected} ✓")
    assert s == expected

# Symmetry in x
print("\n  Symmetry in x: s_w(x₁,x₂) = s_w(x₂,x₁)")
for w1, w2, x1, x2 in [(1,2,3,4), (5,-1,7,2)]:
    assert tropical_schur(w1,w2,x1,x2) == tropical_schur(w1,w2,x2,x1)
    print(f"  s_{{({w1},{w2})}}({x1},{x2}) = s_{{({w1},{w2})}}({x2},{x1}) = {tropical_schur(w1,w2,x1,x2)} ✓")

# Symmetry in w
print("\n  Symmetry in w: s_{(w₁,w₂)} = s_{(w₂,w₁)}")
for w1, w2, x1, x2 in [(1,2,3,4), (5,-1,7,2)]:
    assert tropical_schur(w1,w2,x1,x2) == tropical_schur(w2,w1,x1,x2)
    print(f"  s_{{({w1},{w2})}} = s_{{({w2},{w1})}} at ({x1},{x2}): {tropical_schur(w1,w2,x1,x2)} ✓")

# ============================================================
# Section 5: Lipschitz Bounds
# ============================================================

print("\n" + "=" * 60)
print("SECTION 5: Lipschitz Bounds for Tropical Invariants")
print("=" * 60)

np.random.seed(42)
eps_values = [0.01, 0.1, 0.5, 1.0]

print("\n  Tropical det Lipschitz bound (L=2):")
for eps in eps_values:
    M = np.random.randn(2, 2)
    perturbation = np.random.uniform(-eps, eps, (2, 2))
    M_perturbed = M + perturbation
    det_diff = abs(tropical_det(M_perturbed) - tropical_det(M))
    bound = 2 * eps
    print(f"    ε={eps:.2f}: |Δdet| = {det_diff:.6f} ≤ {bound:.2f} ✓" +
          (" (tight!)" if det_diff > 0.8 * bound else ""))
    assert det_diff <= bound + 1e-10

print("\n  Tropical trace Lipschitz bound (L=1):")
for eps in eps_values:
    M = np.random.randn(2, 2)
    perturbation = np.random.uniform(-eps, eps, (2, 2))
    M_perturbed = M + perturbation
    trace_diff = abs(tropical_trace(M_perturbed) - tropical_trace(M))
    bound = eps
    print(f"    ε={eps:.2f}: |Δtr| = {trace_diff:.6f} ≤ {bound:.2f} ✓")
    assert trace_diff <= bound + 1e-10

print("\n  Spectral gap Lipschitz bound (L=2):")
for eps in eps_values:
    a, b = np.random.randn(2)
    da, db = np.random.uniform(-eps, eps, 2)
    gap_diff = abs(tropical_spectral_gap(a+da, b+db) - tropical_spectral_gap(a, b))
    bound = 2 * eps
    print(f"    ε={eps:.2f}: |Δgap| = {gap_diff:.6f} ≤ {bound:.2f} ✓")
    assert gap_diff <= bound + 1e-10

# ============================================================
# Section 6: Satake Correspondence
# ============================================================

print("\n" + "=" * 60)
print("SECTION 6: Satake Correspondence")
print("=" * 60)

print("\n  Injectivity test: same Schur poly ⟹ same weight sum")
test_cases = [
    ((3, 2), (4, 1)),   # same sum = 5
    ((5, 5), (7, 3)),   # same sum = 10
    ((0, 0), (-1, 1)),  # same sum = 0
]
for (w1, w2), (v1, v2) in test_cases:
    sum_w = w1 + w2
    sum_v = v1 + v2
    # Check Schur equality at multiple points
    all_equal = all(
        tropical_schur(w1, w2, x1, x2) == tropical_schur(v1, v2, x1, x2)
        for x1 in range(-5, 6) for x2 in range(-5, 6)
    )
    print(f"  w=({w1},{w2}), v=({v1},{v2}): |w|={sum_w}, |v|={sum_v}, " +
          f"Schur equal: {all_equal}, sums equal: {sum_w==sum_v} ✓")
    assert (sum_w == sum_v) == all_equal

print("\n  Grading preservation: s_w(x) - (x₁+x₂) = w₁+w₂")
for w1, w2 in [(3, 2), (0, -5), (10, 10)]:
    for x1, x2 in [(0, 0), (1, 2), (-3, 7)]:
        grade = tropical_schur(w1, w2, x1, x2) - (x1 + x2)
        expected = w1 + w2
        print(f"  s_{{({w1},{w2})}}({x1},{x2}) - ({x1}+{x2}) = {grade} = {expected} ✓")
        assert grade == expected

# ============================================================
# Section 7: Visualizations
# ============================================================

print("\n" + "=" * 60)
print("SECTION 7: Generating Visualizations")
print("=" * 60)

# Plot 1: Tropical characteristic polynomial
fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Characteristic polynomial for different matrices
x_range = np.linspace(-5, 5, 500)
matrices = [
    (np.array([[1, 3], [5, 2]]), "M = [[1,3],[5,2]]"),
    (np.array([[0, 0], [0, 0]]), "M = [[0,0],[0,0]]"),
    (np.array([[-1, 4], [2, 3]]), "M = [[-1,4],[2,3]]"),
]

for ax, (M, title) in zip(axes, matrices):
    tr = tropical_trace(M)
    det = tropical_det(M)
    y = np.minimum(2 * x_range, np.minimum(tr + x_range, det * np.ones_like(x_range)))
    ax.plot(x_range, y, 'b-', linewidth=2)
    ax.plot(x_range, 2 * x_range, 'r--', alpha=0.5, label='2x')
    ax.plot(x_range, tr + x_range, 'g--', alpha=0.5, label=f'tr+x={tr}+x')
    ax.axhline(y=det, color='orange', linestyle='--', alpha=0.5, label=f'det={det}')
    ax.set_title(title, fontsize=11)
    ax.set_xlabel('x')
    ax.set_ylabel('χ_M(x)')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(-10, 10)

plt.suptitle('Tropical Characteristic Polynomial: min(2x, tr+x, det)', fontsize=14)
plt.tight_layout()
plt.savefig('tropical_char_poly.png', dpi=150, bbox_inches='tight')
print("  Saved: tropical_char_poly.png")

# Plot 2: Cartan decomposition / dominant chamber
fig, ax = plt.subplots(1, 1, figsize=(8, 8))

# Sample random points and their sorted versions
np.random.seed(123)
n_points = 50
points = np.random.randn(n_points, 2) * 3

for a, b in points:
    w1, w2 = max(a, b), min(a, b)
    ax.plot(a, b, 'ro', markersize=4, alpha=0.6)
    ax.plot(w1, w2, 'b^', markersize=6, alpha=0.8)
    ax.plot([a, w1], [b, w2], 'k-', alpha=0.15)

# Dominant chamber
x_line = np.linspace(-8, 8, 100)
ax.fill_between(x_line, -8, x_line, alpha=0.1, color='blue', label='Dominant chamber (w₁ ≥ w₂)')
ax.plot(x_line, x_line, 'k--', alpha=0.5, label='w₁ = w₂ (Weyl wall)')

ax.set_xlabel('w₁', fontsize=12)
ax.set_ylabel('w₂', fontsize=12)
ax.set_title('Tropical Cartan Decomposition: (a,b) → (max(a,b), min(a,b))', fontsize=13)
ax.legend(fontsize=10)
ax.set_xlim(-8, 8)
ax.set_ylim(-8, 8)
ax.set_aspect('equal')
ax.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig('cartan_decomposition.png', dpi=150, bbox_inches='tight')
print("  Saved: cartan_decomposition.png")

# Plot 3: Lipschitz bound verification
fig, axes = plt.subplots(1, 3, figsize=(15, 5))

np.random.seed(42)
n_trials = 1000

for ax, (name, func, L) in zip(axes, [
    ("Tropical Det", lambda M: tropical_det(M), 2),
    ("Tropical Trace", lambda M: tropical_trace(M), 1),
    ("Spectral Gap", lambda M: abs(M[0,0] - M[1,1]), 2),
]):
    eps_range = np.linspace(0.01, 2, 50)
    max_diffs = []

    for eps in eps_range:
        diffs = []
        for _ in range(100):
            M = np.random.randn(2, 2)
            pert = np.random.uniform(-eps, eps, (2, 2))
            diffs.append(abs(func(M + pert) - func(M)))
        max_diffs.append(max(diffs))

    ax.plot(eps_range, max_diffs, 'b.', markersize=3, label='Max observed |Δf|')
    ax.plot(eps_range, L * eps_range, 'r-', linewidth=2, label=f'Bound: L={L} × ε')
    ax.set_xlabel('ε', fontsize=12)
    ax.set_ylabel('|Δf|', fontsize=12)
    ax.set_title(f'{name} (L={L})', fontsize=12)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

plt.suptitle('Lipschitz Bounds for Tropical Invariants', fontsize=14)
plt.tight_layout()
plt.savefig('lipschitz_bounds.png', dpi=150, bbox_inches='tight')
print("  Saved: lipschitz_bounds.png")

# Plot 4: Satake correspondence visualization
fig, ax = plt.subplots(1, 1, figsize=(8, 6))

# Show iso-sum lines in the dominant chamber
for s in range(-6, 7):
    w1_vals = np.linspace(s/2, 8, 100)
    w2_vals = s - w1_vals
    mask = w1_vals >= w2_vals
    if mask.any():
        ax.plot(w1_vals[mask], w2_vals[mask], '-',
                color=plt.cm.coolwarm((s + 6) / 12),
                alpha=0.7, linewidth=2)
        # Label
        idx = len(w1_vals[mask]) // 3
        if idx < len(w1_vals[mask]):
            ax.annotate(f's={s}', (w1_vals[mask][idx], w2_vals[mask][idx]),
                       fontsize=7, alpha=0.8)

ax.set_xlabel('w₁', fontsize=12)
ax.set_ylabel('w₂', fontsize=12)
ax.set_title('Satake Fibers: Dominant weights with same Schur polynomial\n'
             '(colored by weight sum s = w₁ + w₂)', fontsize=12)
ax.set_xlim(-2, 8)
ax.set_ylim(-8, 5)
ax.grid(True, alpha=0.3)

# Add dominant chamber boundary
x_line = np.linspace(-8, 8, 100)
ax.plot(x_line, x_line, 'k--', alpha=0.5, linewidth=1.5, label='Weyl wall (w₁=w₂)')
ax.fill_between(x_line, -8, x_line, alpha=0.05, color='blue')
ax.legend(fontsize=10)
plt.tight_layout()
plt.savefig('satake_fibers.png', dpi=150, bbox_inches='tight')
print("  Saved: satake_fibers.png")

print("\n" + "=" * 60)
print("All demonstrations completed successfully!")
print("=" * 60)
