#!/usr/bin/env python3
"""
Berggren–Tropical Correspondence: Interactive Demo

Demonstrates the bridge between Pythagorean triples and tropical geometry.
Shows Maslov dequantization convergence, tropical light cone visualization,
and the approximate intertwining of classical and tropical Berggren actions.
"""

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
from matplotlib.patches import FancyArrowPatch


# ============================================================
# 1. Classical Berggren Matrices
# ============================================================
A = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]])
B = np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]])
C = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]])
berggren_mats = [A, B, C]
root = np.array([3, 4, 5])


def generate_berggren_tree(depth=5):
    """Generate Pythagorean triples from the Berggren tree."""
    triples = [root.copy()]
    current_level = [root.copy()]
    for _ in range(depth):
        next_level = []
        for v in current_level:
            for M in berggren_mats:
                w = M @ v
                if all(x > 0 for x in w):
                    next_level.append(w)
                    triples.append(w)
        current_level = next_level
    return triples


# ============================================================
# 2. Tropical (Max-Plus) Operations
# ============================================================
def tropical_add(x, y):
    """Tropical addition = max"""
    return np.maximum(x, y)


def tropical_mul(x, y):
    """Tropical multiplication = addition"""
    return x + y


def tropical_mat_vec_mul(M, v):
    """Max-plus matrix-vector multiplication"""
    n = M.shape[0]
    result = np.full(n, -np.inf)
    for i in range(n):
        for j in range(n):
            result[i] = max(result[i], M[i, j] + v[j])
    return result


# Tropical Berggren matrix (log of abs values)
trop_berggren = np.log(np.abs(B).astype(float))
print("=" * 60)
print("TROPICAL BERGGREN MATRIX (log|B|)")
print("=" * 60)
print(f"  [[{trop_berggren[0,0]:.4f}, {trop_berggren[0,1]:.4f}, {trop_berggren[0,2]:.4f}],")
print(f"   [{trop_berggren[1,0]:.4f}, {trop_berggren[1,1]:.4f}, {trop_berggren[1,2]:.4f}],")
print(f"   [{trop_berggren[2,0]:.4f}, {trop_berggren[2,1]:.4f}, {trop_berggren[2,2]:.4f}]]")
print(f"\nDiagonal entries: 0, 0, log(3)≈{np.log(3):.4f}")
print(f"Off-diagonal: log(2)≈{np.log(2):.4f}")


# ============================================================
# 3. Maslov Dequantization
# ============================================================
def maslov_deq(h, x, y):
    """Maslov dequantization: h·log(exp(x/h) + exp(y/h))"""
    # Numerically stable computation
    m = max(x, y)
    return m + h * np.log(np.exp((x - m) / h) + np.exp((y - m) / h))


print("\n" + "=" * 60)
print("MASLOV DEQUANTIZATION CONVERGENCE")
print("=" * 60)
x, y = 3.0, 5.0
print(f"\nx = {x}, y = {y}, max(x,y) = {max(x,y)}")
print(f"{'h':>10} {'MaslovDeq':>12} {'|error|':>10} {'h·log2':>10} {'within?':>10}")
print("-" * 56)
for h in [10.0, 5.0, 2.0, 1.0, 0.5, 0.1, 0.01, 0.001]:
    m = maslov_deq(h, x, y)
    err = abs(m - max(x, y))
    bound = h * np.log(2)
    ok = "✓" if err <= bound + 1e-12 else "✗"
    print(f"{h:10.3f} {m:12.6f} {err:10.6f} {bound:10.6f} {ok:>10}")

print(f"\nTheorem: |MaslovDeq(h,x,y) - max(x,y)| ≤ h·log(2) ✓")
print(f"This is the PROVED convergence rate from our Lean formalization.")


# ============================================================
# 4. Tropical Light Cone Visualization
# ============================================================
print("\n" + "=" * 60)
print("TROPICAL LIGHT CONE: {v : max(v₀, v₁) = v₂}")
print("=" * 60)

fig = plt.figure(figsize=(18, 6))

# Plot 1: Tropical Light Cone
ax1 = fig.add_subplot(131, projection='3d')
# Generate the cone surface
t = np.linspace(-2, 3, 100)
# Region 1: v₀ ≥ v₁, so v₂ = v₀
v0_1, v1_1 = np.meshgrid(t, t)
mask1 = v0_1 >= v1_1
v2_1 = v0_1.copy()
v0_1[~mask1] = np.nan
# Region 2: v₁ > v₀, so v₂ = v₁
v0_2, v1_2 = np.meshgrid(t, t)
mask2 = v1_2 > v0_2
v2_2 = v1_2.copy()
v0_2[~mask2] = np.nan

ax1.plot_surface(v0_1, v1_1, v2_1, alpha=0.3, color='blue', label='v₂=v₀')
ax1.plot_surface(v0_2, v1_2, v2_2, alpha=0.3, color='red', label='v₂=v₁')

# Add some cone points
ax1.set_xlabel('v₀')
ax1.set_ylabel('v₁')
ax1.set_zlabel('v₂ = max(v₀,v₁)')
ax1.set_title('Tropical Light Cone L_trop')

# Plot 2: Maslov convergence
ax2 = fig.add_subplot(132)
hs = np.logspace(-3, 1, 50)
errors = [abs(maslov_deq(h, 3.0, 5.0) - 5.0) for h in hs]
bounds = [h * np.log(2) for h in hs]
ax2.loglog(hs, errors, 'b-', linewidth=2, label='|MaslovDeq - max|')
ax2.loglog(hs, bounds, 'r--', linewidth=2, label='h·log(2) bound')
ax2.set_xlabel('h (dequantization parameter)')
ax2.set_ylabel('Error')
ax2.set_title('Maslov Dequantization Convergence\n(proved rate: O(h·log 2))')
ax2.legend()
ax2.grid(True, alpha=0.3)

# Plot 3: Berggren tree tropicalization
ax3 = fig.add_subplot(133)
triples = generate_berggren_tree(depth=4)
log_triples = [(np.log(v[0]), np.log(v[1]), np.log(v[2])) for v in triples]

# Plot the tropical approximation error
errors_berggren = []
for v in triples:
    log_v = np.log(v.astype(float))
    max_01 = max(log_v[0], log_v[1])
    gap = log_v[2] - max_01  # Should be 0 if on tropical cone
    errors_berggren.append(gap)

hypotenuses = [v[2] for v in triples]
ax3.scatter(hypotenuses, errors_berggren, s=5, alpha=0.7, c='blue')
ax3.axhline(y=0, color='green', linestyle='--', label='Tropical cone (gap=0)')
ax3.axhline(y=np.log(2), color='red', linestyle=':', alpha=0.5, label='log(2) ≈ 0.693')
ax3.set_xlabel('Hypotenuse c')
ax3.set_ylabel('log(c) − max(log(a), log(b))')
ax3.set_title('Gap from Tropical Light Cone\nfor Pythagorean Triples')
ax3.legend(fontsize=8)
ax3.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('diagram.svg', format='svg', bbox_inches='tight')
plt.savefig('tropical_berggren_demo.png', dpi=150, bbox_inches='tight')
print("Saved: diagram.svg, tropical_berggren_demo.png")


# ============================================================
# 5. Log-Sum Approximation Demo
# ============================================================
print("\n" + "=" * 60)
print("LOG-SUM APPROXIMATION (Proved in Lean)")
print("=" * 60)
print("\nFor positive x, y, z:")
print("  max(log x, log y, log z) ≤ log(x+y+z) ≤ max(log x, log y, log z) + log 3")
print(f"\nlog(3) ≈ {np.log(3):.6f}")
print()

test_cases = [
    (1, 1, 1),
    (1, 2, 3),
    (1, 100, 10000),
    (3, 4, 5),
    (5, 12, 13),
    (8, 15, 17),
]
print(f"{'(x,y,z)':>20} {'max(log)':>10} {'log(sum)':>10} {'gap':>8} {'≤log3?':>8}")
print("-" * 60)
for x, y, z in test_cases:
    max_log = max(np.log(x), np.log(y), np.log(z))
    log_sum = np.log(x + y + z)
    gap = log_sum - max_log
    ok = "✓" if gap <= np.log(3) + 1e-10 else "✗"
    print(f"{str((x,y,z)):>20} {max_log:10.4f} {log_sum:10.4f} {gap:8.4f} {ok:>8}")


# ============================================================
# 6. Tropical Berggren Action Demo
# ============================================================
print("\n" + "=" * 60)
print("TROPICAL vs CLASSICAL BERGGREN ACTION")
print("=" * 60)

v = np.array([3, 4, 5])
print(f"\nRoot triple: {v}")
print(f"Tropical root: (log 3, log 4, log 5) = ({np.log(3):.4f}, {np.log(4):.4f}, {np.log(5):.4f})")

for name, M in [("A", A), ("B", B), ("C", C)]:
    w = M @ v
    w_abs = np.abs(w)
    log_w = np.log(w_abs.astype(float))
    trop_v = np.log(np.abs(v).astype(float))
    trop_w = tropical_mat_vec_mul(trop_berggren, trop_v)
    error = np.max(np.abs(log_w - trop_w))
    print(f"\n  {name} · {v} = {w}")
    print(f"  log|result|  = ({log_w[0]:.4f}, {log_w[1]:.4f}, {log_w[2]:.4f})")
    print(f"  M_trop ⊗ log = ({trop_w[0]:.4f}, {trop_w[1]:.4f}, {trop_w[2]:.4f})")
    print(f"  Max error: {error:.4f} (bound: log 3 = {np.log(3):.4f}) {'✓' if error <= np.log(3)+0.01 else '✗'}")


# ============================================================
# 7. Max-Plus Convexity Demo
# ============================================================
print("\n" + "=" * 60)
print("MAX-PLUS CONVEXITY OF TROPICAL LIGHT CONE")
print("=" * 60)

# Two points on the light cone
v1 = np.array([1.0, 3.0, 3.0])  # max(1,3) = 3 ✓
v2 = np.array([4.0, 2.0, 4.0])  # max(4,2) = 4 ✓
print(f"\nv = {v1}, max(v₀,v₁) = {max(v1[0],v1[1])}, v₂ = {v1[2]}: {'ON CONE' if max(v1[0],v1[1]) == v1[2] else 'OFF CONE'}")
print(f"w = {v2}, max(w₀,w₁) = {max(v2[0],v2[1])}, w₂ = {v2[2]}: {'ON CONE' if max(v2[0],v2[1]) == v2[2] else 'OFF CONE'}")

for a, b in [(0, 0), (1, 2), (-1, 3), (0.5, 0.5)]:
    conv = np.maximum(a + v1, b + v2)
    on_cone = max(conv[0], conv[1]) == conv[2]
    print(f"  a={a:4.1f}, b={b:4.1f}: a⊗v ⊕ b⊗w = {conv} → max={max(conv[0],conv[1]):.1f}, v₂={conv[2]:.1f}: {'✓ ON CONE' if on_cone else '✗ OFF CONE'}")

print(f"\nTheorem (PROVED): For all v,w ∈ L_trop and a,b ∈ ℝ: a⊗v ⊕ b⊗w ∈ L_trop")


# ============================================================
# 8. Tree Depth Security Analysis
# ============================================================
print("\n" + "=" * 60)
print("POST-QUANTUM TREE DEPTH ANALYSIS")
print("=" * 60)
print(f"\n{'depth':>6} {'paths (3^d)':>15} {'birthday (√)':>15} {'2^d':>15}")
print("-" * 55)
for d in range(1, 13):
    paths = 3**d
    birthday = int(np.sqrt(paths))
    two_d = 2**d
    print(f"{d:>6} {paths:>15,} {birthday:>15,} {two_d:>15,}")

print(f"\nTheorem (PROVED): 3^d ≥ 2^d for all d ∈ ℕ")
print(f"Theorem (PROVED): 3^n ≥ n + 1 for all n ∈ ℕ")

print("\n" + "=" * 60)
print("DEMO COMPLETE")
print("=" * 60)
