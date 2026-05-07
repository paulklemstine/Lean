"""
Quantum Walk on the Berggren Tree: Computational Demonstrations

This script demonstrates the core mathematical structures formalized in
Computation/QuantumBerggrenWalk.lean, making the algebraic and combinatorial
results tangible through numerical computation and visualization.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
import json

# ============================================================
# 1. Berggren Matrices and Pythagorean Triple Generation
# ============================================================

# The three Berggren matrices in O(2,1;Z)
A = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]])
B = np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]])
C = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]])

# Minkowski metric
eta = np.diag([1, 1, -1])

print("=" * 60)
print("BERGGREN MATRICES AND LORENTZ GROUP STRUCTURE")
print("=" * 60)
print(f"\nMatrix A (det = {int(np.linalg.det(A))}):  tr = {int(np.trace(A))}")
print(A)
print(f"\nMatrix B (det = {int(np.linalg.det(B))}): tr = {int(np.trace(B))}")
print(B)
print(f"\nMatrix C (det = {int(np.linalg.det(C))}):  tr = {int(np.trace(C))}")
print(C)

# Verify Lorentz property: M^T eta M = eta
for name, M in [("A", A), ("B", B), ("C", C)]:
    result = M.T @ eta @ M
    assert np.allclose(result, eta), f"{name} fails Lorentz test"
    print(f"\n{name}^T η {name} = η: ✓ (Lorentz preservation verified)")

# ============================================================
# 2. Berggren Tree Generation
# ============================================================

print("\n" + "=" * 60)
print("BERGGREN TREE: FIRST 3 LEVELS")
print("=" * 60)

root = np.array([3, 4, 5])
print(f"\nRoot: {tuple(root)}  (3² + 4² = {3**2 + 4**2} = 5² = {5**2})")

def generate_tree(v, depth, max_depth, path=""):
    """Generate the Berggren tree to given depth."""
    a, b, c = int(v[0]), int(v[1]), int(v[2])
    verify = a**2 + b**2 == c**2
    result = [(a, b, c, len(path), path, verify)]

    if depth < max_depth:
        for name, M in [("A", A), ("B", B), ("C", C)]:
            child = M @ v
            result.extend(generate_tree(child, depth + 1, max_depth, path + name))

    return result

tree = generate_tree(root, 0, 3)
print(f"\nTotal vertices through depth 3: {len(tree)}")
print(f"Expected: (3^4 - 1)/2 = {(3**4 - 1)//2}")

for a, b, c, d, path, ok in sorted(tree, key=lambda x: (x[3], x[4])):
    indent = "  " * d
    check = "✓" if ok else "✗"
    p = path if path else "root"
    print(f"  {indent}({a},{b},{c}) depth={d} path={p} pythag={check}")

# ============================================================
# 3. Pell Sequence from B-Branch
# ============================================================

print("\n" + "=" * 60)
print("PELL HYPOTENUSE SEQUENCE (B-BRANCH)")
print("=" * 60)

def pell_hyp(n):
    """Compute the B-branch hypotenuse sequence."""
    if n == 0: return 5
    if n == 1: return 29
    a, b = 5, 29
    for _ in range(n - 1):
        a, b = b, 6 * b - a
    return b

print("\nSequence: c_n where c_{n+2} = 6c_{n+1} - c_n")
print("Characteristic roots: 3 ± 2√2 (Pell equation x² - 2y² = ±1)")
print()
for i in range(8):
    c = pell_hyp(i)
    ratio = pell_hyp(i+1) / c if c > 0 else 0
    sqrt_check = int(round(c**0.5))**2
    is_sq = "= " + str(int(round(c**0.5))) + "²" if sqrt_check == c else ""
    print(f"  c_{i} = {c:>10}  ratio c_{i+1}/c_{i} = {ratio:.6f}  {is_sq}")

print(f"\n  Limit ratio = 3 + 2√2 = {3 + 2*2**0.5:.6f}")

# ============================================================
# 4. Quantum vs Classical Search Advantage
# ============================================================

print("\n" + "=" * 60)
print("QUANTUM SEARCH ADVANTAGE ON BERGGREN TREE")
print("=" * 60)

print(f"\n{'Depth':>6} {'Vertices':>10} {'Classical':>10} {'Quantum':>10} {'Speedup':>10}")
print("-" * 50)
for d in range(1, 12):
    V = (3**(d+1) - 1) // 2
    classical = V  # O(V) for exhaustive search
    quantum = int(V**0.5)  # O(√V) for Grover search
    speedup = classical / quantum if quantum > 0 else float('inf')
    print(f"{d:>6} {V:>10} {classical:>10} {quantum:>10} {speedup:>10.1f}x")

# ============================================================
# 5. Spectral Divisibility Filter Demonstration
# ============================================================

print("\n" + "=" * 60)
print("SPECTRAL DIVISIBILITY FILTER")
print("=" * 60)

N = 65  # = 5 * 13, product of Pythagorean hypotenuses
print(f"\nTarget: N = {N} = 5 × 13")
print("Filtering tree vertices by hypotenuse divisibility:\n")

tree_d4 = generate_tree(root, 0, 4)
divisors = [(a, b, c, d, p) for a, b, c, d, p, _ in tree_d4 if c != 0 and N % c == 0]
coprime = [(a, b, c, d, p) for a, b, c, d, p, _ in tree_d4 if c != 0 and N % c != 0 and
           np.gcd(c, N) == 1]

print(f"  Vertices with c | {N}: {len(divisors)}")
for a, b, c, d, p in divisors:
    print(f"    ({a},{b},{c}) at depth {d} — c = {c} divides {N}")

print(f"\n  Vertices with gcd(c, {N}) = 1: {len(coprime)}")
print(f"  (showing first 5)")
for a, b, c, d, p in coprime[:5]:
    print(f"    ({a},{b},{c}) at depth {d} — gcd({c},{N}) = {np.gcd(c, N)}")

print(f"\n  Quantum filter advantage: divisor amplitude Ω(1/√d)")
print(f"  vs coprime amplitude O(1/d)")
print(f"  → √d enhancement for divisor detection")

# ============================================================
# 6. Trace Spectrum Analysis
# ============================================================

print("\n" + "=" * 60)
print("TRACE SPECTRUM OF BERGGREN PRODUCTS")
print("=" * 60)

print("\nSingle matrices:")
for name, M in [("A", A), ("B", B), ("C", C)]:
    print(f"  tr({name}) = {int(np.trace(M))}, det({name}) = {int(round(np.linalg.det(M)))}")

print("\nPairwise products:")
for n1, M1 in [("A", A), ("B", B), ("C", C)]:
    for n2, M2 in [("A", A), ("B", B), ("C", C)]:
        P = M1 @ M2
        print(f"  tr({n1}{n2}) = {int(np.trace(P)):>4}, det({n1}{n2}) = {int(round(np.linalg.det(P))):>3}")

print("\nTriple products:")
for n1, M1 in [("A", A), ("B", B)]:
    for n2, M2 in [("A", A), ("B", B), ("C", C)]:
        for n3, M3 in [("A", A), ("B", B), ("C", C)]:
            P = M1 @ M2 @ M3
            print(f"  tr({n1}{n2}{n3}) = {int(np.trace(P)):>5}")

# ============================================================
# 7. Visualization: Berggren Tree
# ============================================================

fig, axes = plt.subplots(1, 2, figsize=(16, 8))

# Left panel: Tree structure
ax = axes[0]
ax.set_title("Berggren Tree of Primitive Pythagorean Triples\n(First 3 Levels)", fontsize=12)

positions = {}
tree_d2 = generate_tree(root, 0, 2)

# Layout
level_counts = {}
for item in tree_d2:
    d = item[3]
    level_counts[d] = level_counts.get(d, 0) + 1

level_idx = {}
for a, b, c, d, path, ok in sorted(tree_d2, key=lambda x: (x[3], x[4])):
    idx = level_idx.get(d, 0)
    total = level_counts[d]
    x = (idx + 0.5) / total
    y = 1 - d * 0.35
    positions[path if path else "root"] = (x, y)
    level_idx[d] = idx + 1

    color = ['#2196F3', '#4CAF50', '#FF9800', '#E91E63'][d]
    ax.plot(x, y, 'o', color=color, markersize=12, zorder=5)
    ax.annotate(f"({a},{b},{c})", (x, y), textcoords="offset points",
                xytext=(0, -18), ha='center', fontsize=7, fontweight='bold')

# Draw edges
for a, b, c, d, path, ok in tree_d2:
    if d > 0:
        parent = path[:-1] if len(path) > 1 else "root"
        child = path
        if parent in positions and child in positions:
            px, py = positions[parent]
            cx, cy = positions[child]
            branch = path[-1]
            color = {'A': '#2196F3', 'B': '#4CAF50', 'C': '#FF9800'}[branch]
            ax.annotate("", xy=(cx, cy + 0.02), xytext=(px, py - 0.02),
                       arrowprops=dict(arrowstyle='->', color=color, lw=1.5))

ax.set_xlim(-0.05, 1.05)
ax.set_ylim(-0.2, 1.15)
ax.axis('off')

# Add legend
for i, (label, color) in enumerate([('Branch A', '#2196F3'), ('Branch B', '#4CAF50'),
                                      ('Branch C', '#FF9800')]):
    ax.plot([], [], 'o-', color=color, label=label, markersize=8)
ax.legend(loc='upper right', fontsize=9)

# Right panel: Quantum vs Classical search advantage
ax2 = axes[1]
depths = range(1, 15)
vertices = [(3**(d+1) - 1) // 2 for d in depths]
quantum_steps = [int(v**0.5) for v in vertices]

ax2.semilogy(list(depths), vertices, 'ro-', label='Classical: O(N) steps', markersize=6)
ax2.semilogy(list(depths), quantum_steps, 'bs-', label='Quantum: O(√N) steps', markersize=6)
ax2.fill_between(list(depths), quantum_steps, vertices, alpha=0.15, color='green')
ax2.set_xlabel('Tree Depth d', fontsize=12)
ax2.set_ylabel('Number of Steps', fontsize=12)
ax2.set_title('Quantum Search Advantage\non the Berggren Tree', fontsize=12)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)
ax2.annotate('Quantum\nAdvantage\nRegion', xy=(8, 500), fontsize=10,
            color='green', ha='center', fontweight='bold')

plt.tight_layout()
plt.savefig('berggren_quantum_walk.png', dpi=150, bbox_inches='tight')
print("\n✓ Saved visualization to berggren_quantum_walk.png")

# ============================================================
# 8. Gaussian Integer Connection
# ============================================================

print("\n" + "=" * 60)
print("GAUSSIAN INTEGER CONNECTION")
print("=" * 60)

print("\nPythagorean triple (a,b,c) ↔ Gaussian integer a + bi with |a+bi|² = c²")
print()
for a, b, c, d, path, ok in sorted(tree_d2, key=lambda x: x[2])[:10]:
    norm = a**2 + b**2
    print(f"  ({a:>3},{b:>3},{c:>3}) → {a}+{b}i,  |·|² = {a}²+{b}² = {norm} = {c}²")

print("\n" + "=" * 60)
print("DEMO COMPLETE")
print("=" * 60)
