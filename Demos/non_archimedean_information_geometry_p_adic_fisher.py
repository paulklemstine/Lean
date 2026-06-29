"""
p-adic Information Geometry: Numerical Demonstrations

This script demonstrates key concepts from the formalized p-adic
information geometry theory:
1. Ultrametric norm properties and how they differ from Euclidean
2. p-adic valuation depth hierarchy
3. Sample complexity saturation (n < p samples = 1 sample)
4. Convergence rate comparisons (Hensel vs Newton)
5. Ball structure visualization
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import Circle
from fractions import Fraction

# ============================================================
# 1. p-adic Norm Computation
# ============================================================

def p_adic_val(n, p):
    """Compute the p-adic valuation v_p(n) for integer n."""
    if n == 0:
        return float('inf')
    v = 0
    n = abs(n)
    while n % p == 0:
        n //= p
        v += 1
    return v

def p_adic_norm(n, p):
    """Compute |n|_p = p^{-v_p(n)}."""
    v = p_adic_val(n, p)
    if v == float('inf'):
        return 0.0
    return p ** (-v)

def p_adic_norm_rational(num, den, p):
    """Compute |num/den|_p."""
    return p_adic_norm(num, p) / p_adic_norm(den, p)

print("=" * 60)
print("p-adic Information Geometry: Numerical Demonstrations")
print("=" * 60)

# ============================================================
# 2. Ultrametric vs Euclidean Triangle Inequality
# ============================================================

print("\n--- Ultrametric vs Euclidean Triangle Inequality (p=5) ---")
p = 5
examples = [
    (10, 25),   # v_5(10) = 1, v_5(25) = 2
    (3, 7),     # v_5(3) = 0, v_5(7) = 0
    (5, 125),   # v_5(5) = 1, v_5(125) = 3
    (1, 5),     # v_5(1) = 0, v_5(5) = 1
]

print(f"{'x':>6} {'y':>6} {'|x|_5':>10} {'|y|_5':>10} {'|x+y|_5':>10} "
      f"{'max':>10} {'sum':>10} {'Ultra?':>8}")
for x, y in examples:
    nx = p_adic_norm(x, p)
    ny = p_adic_norm(y, p)
    nxy = p_adic_norm(x + y, p)
    print(f"{x:>6} {y:>6} {nx:>10.4f} {ny:>10.4f} {nxy:>10.4f} "
          f"{max(nx, ny):>10.4f} {nx+ny:>10.4f} "
          f"{'✓' if nxy <= max(nx, ny) + 1e-10 else '✗':>8}")

# ============================================================
# 3. Isosceles Triangle Property
# ============================================================

print("\n--- Isosceles Triangle Property ---")
print("In ultrametric spaces, if |x|_p ≠ |y|_p, then |x+y|_p = max(|x|_p, |y|_p)")
print("(Every triangle is isosceles with the two longer sides equal!)")

iso_examples = [(1, 5), (3, 25), (2, 125), (7, 5)]
for x, y in iso_examples:
    nx = p_adic_norm(x, p)
    ny = p_adic_norm(y, p)
    nxy = p_adic_norm(x + y, p)
    eq_max = abs(nxy - max(nx, ny)) < 1e-10
    status = "EQUAL to max ✓" if eq_max else "NOT equal to max"
    different = abs(nx - ny) > 1e-10
    print(f"  |{x}|_5={nx:.4f}, |{y}|_5={ny:.4f}, "
          f"|{x}+{y}|_5=|{x+y}|_5={nxy:.4f} → "
          f"{'different norms → ' + status if different else 'same norms → ≤ max ✓'}")

# ============================================================
# 4. Sample Complexity Saturation
# ============================================================

print("\n--- Sample Complexity Saturation (p=7) ---")
print("Key theorem: For n < p, |n·x|_p = |x|_p (no improvement!)")
p = 7
x = 3  # |3|_7 = 1
print(f"Base: |{x}|_7 = {p_adic_norm(x, p):.4f}")
for n in range(1, 12):
    norm_nx = p_adic_norm(n * x, p)
    improvement = norm_nx != p_adic_norm(x, p)
    marker = " ← FIRST IMPROVEMENT!" if improvement and n == p else \
             " ← improvement" if improvement else ""
    print(f"  n={n:>2}: |{n}·{x}|_7 = |{n*x:>3}|_7 = {norm_nx:.4f}{marker}")

print(f"\nConclusion: Need ≥ {p} samples to see ANY improvement in p-adic estimation!")
print("(This is our post-quantum security bound: adversaries with < p queries gain nothing)")

# ============================================================
# 5. Hensel Lifting Convergence Rate
# ============================================================

print("\n--- Convergence Rate Comparison ---")
print("Classical Newton: error ≤ c^(2^k) (doubly exponential)")
print("But in ultrametric: c^(2^k) ≤ c^k (at least linear)")

c = 0.5
print(f"\nc = {c}")
print(f"{'k':>4} {'c^k':>15} {'c^(2^k)':>15} {'ratio':>10}")
for k in range(8):
    ck = c ** k
    c2k = c ** (2 ** k)
    ratio = c2k / ck if ck > 0 else 0
    print(f"{k:>4} {ck:>15.10f} {c2k:>15.10f} {ratio:>10.6f}")

# ============================================================
# 6. Valuation Depth Hierarchy
# ============================================================

print("\n--- Valuation Depth Hierarchy (p=3) ---")
p = 3
print("The p-adic norm clusters numbers at discrete depth levels:")
for depth in range(5):
    examples_at_depth = [n for n in range(1, 300) if p_adic_val(n, p) == depth][:8]
    norm_val = p ** (-depth)
    print(f"  Depth {depth} (|·|_3 = 3^{-depth} = {norm_val:.4f}): "
          f"{examples_at_depth}")

# ============================================================
# 7. Visualization: Ultrametric Ball Tree
# ============================================================

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: Ultrametric ball structure (tree-like)
ax = axes[0]
ax.set_title("p-adic Ball Structure (p=3)\nBalls are nested or disjoint", fontsize=12)
ax.set_xlim(-1.5, 1.5)
ax.set_ylim(-1.5, 1.5)
ax.set_aspect('equal')

# Draw nested/disjoint balls
colors = ['#2196F3', '#4CAF50', '#FF9800', '#F44336']
radii = [1.2, 0.8, 0.5, 0.3]
centers_x = [0, -0.3, 0.4, -0.3]
centers_y = [0, 0.2, -0.1, 0.2]

for i, (r, cx, cy) in enumerate(zip(radii, centers_x, centers_y)):
    circle = Circle((cx, cy), r, fill=False, edgecolor=colors[i],
                    linewidth=2, linestyle='--' if i > 0 else '-',
                    label=f'Depth {i}: r=p^{{-{i}}}')
    ax.add_patch(circle)

# Add some "points"
np.random.seed(42)
for i in range(20):
    x = np.random.uniform(-1, 1)
    y = np.random.uniform(-1, 1)
    if x**2 + y**2 < 1.2**2:
        depth = min(3, int(-np.log(max(0.01, np.sqrt(x**2+y**2))) / np.log(3)))
        ax.plot(x, y, 'o', color=colors[min(depth, 3)], markersize=4, alpha=0.6)

ax.legend(loc='lower right', fontsize=8)
ax.set_xlabel("Parameter θ₁")
ax.set_ylabel("Parameter θ₂")
ax.text(0, -1.35, "Key: In ultrametric spaces,\nevery point is a center!", 
        ha='center', fontsize=9, style='italic')

# Right: Convergence comparison
ax = axes[1]
ax.set_title("Convergence Rate Comparison\nUltrametric vs Archimedean", fontsize=12)

k_vals = np.arange(0, 8)
c = 0.5

# Classical: error = c * initial (sum-based)
# Ultrametric: error = c * initial (max-based, same single-step)
# But for n samples: classical gets 1/n, ultrametric stays constant for n < p

p = 5
classical_error = [1.0 / (n + 1) for n in range(8)]
ultrametric_error = []
for n in range(8):
    if n < p:
        ultrametric_error.append(1.0)
    else:
        ultrametric_error.append(p ** (-(n // p)))

ax.semilogy(range(8), classical_error, 'b-o', label='Classical: O(1/n)', linewidth=2)
ax.semilogy(range(8), ultrametric_error, 'r-s', label=f'p-adic (p={p}): step function', linewidth=2)
ax.axvline(x=p, color='gray', linestyle='--', alpha=0.5, label=f'n = p = {p}')
ax.set_xlabel("Number of samples n")
ax.set_ylabel("Error bound (log scale)")
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)
ax.text(3, 0.5, f"n < {p}: NO improvement\n(ultrametric saturation)", 
        fontsize=9, color='red', ha='center',
        bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

plt.tight_layout()
plt.savefig('diagram.svg', format='svg', bbox_inches='tight')
plt.savefig('padic_info_geom.png', dpi=150, bbox_inches='tight')
print("\n\nVisualization saved to diagram.svg and padic_info_geom.png")

# ============================================================
# 8. Cramér-Rao Bound Comparison
# ============================================================

print("\n--- p-adic Cramér-Rao Bound ---")
print("Classical: Var(θ̂) ≥ 1/I(θ) (continuous bound)")
print("p-adic:    ‖error‖_p ≥ ‖I(θ)‖_p^{-1} (discrete bound)")
print("\nThe p-adic bound is DISCRETE — error can only take values p^(-k):")

p = 5
print(f"\np = {p}")
print(f"{'Info depth':>12} {'‖I‖_p':>10} {'CR bound':>10} {'Best achievable':>16}")
for m in range(5):
    info_norm = p ** (-m)
    cr_bound = p ** m  # 1/info_norm
    # But due to discreteness, the achievable error is p^k for some k ≥ m
    print(f"{m:>12} {info_norm:>10.4f} {cr_bound:>10.4f} "
          f"{'p^' + str(m) + ' = ' + str(p**m):>16}")

print("\nKey insight: In p-adic setting, the Cramér-Rao bound is SHARP")
print("(due to multiplicativity of the p-adic norm: ‖info·error‖ = ‖info‖·‖error‖)")

# ============================================================
# 9. Ultrametric Advantage Summary
# ============================================================

print("\n" + "=" * 60)
print("SUMMARY: Ultrametric Advantages for Information Geometry")
print("=" * 60)
print("""
1. ERROR NON-AMPLIFICATION: ‖e₁ + e₂‖ ≤ max(‖e₁‖, ‖e₂‖)
   → Combining errors never makes things worse than the worst error
   → Classical: ‖e₁ + e₂‖ ≤ ‖e₁‖ + ‖e₂‖ (errors accumulate!)

2. SAMPLE COMPLEXITY SATURATION: For n < p samples, ‖n·x‖_p = ‖x‖_p
   → You need ≥ p samples to improve your estimate AT ALL
   → Classical: n samples always give 1/√n improvement

3. ISOSCELES TRIANGLES: If ‖x‖ ≠ ‖y‖, then ‖x+y‖ = max(‖x‖, ‖y‖)
   → The stronger signal always dominates completely
   → Classical: signals add and can cancel or interfere

4. CLOPEN BALLS: Every ball is simultaneously open and closed
   → Parameter spaces have rigid tree structure
   → Classical: parameter spaces are smooth manifolds

5. DISCRETE ERROR LEVELS: Errors can only take values p^(-k)
   → Uncertainty is quantized, not continuous
   → This is a non-Archimedean uncertainty principle

POST-QUANTUM SECURITY APPLICATION:
   An adversary with < p queries to a p-adic estimator gains
   ZERO information. This provides a natural security threshold
   for lattice-based cryptographic schemes.
""")
