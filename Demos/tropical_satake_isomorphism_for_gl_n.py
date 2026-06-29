#!/usr/bin/env python3
"""
Tropical Satake Isomorphism for GL_n: Numerical Demonstrations

Demonstrates:
1. Tropical Schur polynomial computation
2. Weyl invariance verification
3. Super-additivity of tropical Schur
4. Tropical Hecke convolution collapse
5. Tropical Demazure operator
"""

from itertools import permutations
from typing import List, Tuple, Callable
import math


def tropical_schur(w: List[int], x: List[int]) -> int:
    """Compute tropSchur(w, x) = min_{σ ∈ Sₙ} Σᵢ w(σ(i)) * x(i)."""
    n = len(w)
    assert len(x) == n
    min_val = float('inf')
    for perm in permutations(range(n)):
        val = sum(w[perm[i]] * x[i] for i in range(n))
        min_val = min(min_val, val)
    return min_val


def tropical_monomial(w: List[int], x: List[int]) -> int:
    """Compute tropMonomial(w, x) = Σᵢ w(i) * x(i)."""
    return sum(w[i] * x[i] for i in range(len(w)))


def satake_transform(f: Callable, x: List[int]) -> int:
    """Compute S(f)(x) = min_{σ ∈ Sₙ} f(x ∘ σ)."""
    n = len(x)
    min_val = float('inf')
    for perm in permutations(range(n)):
        permuted_x = [x[perm[i]] for i in range(n)]
        min_val = min(min_val, f(permuted_x))
    return min_val


def trop_hecke_conv(f: Callable, g: Callable, x: List[int]) -> int:
    """Compute (f ⊛ g)(x) = min_{σ ∈ Sₙ} [f(x) + g(x ∘ σ)]."""
    n = len(x)
    min_val = float('inf')
    for perm in permutations(range(n)):
        permuted_x = [x[perm[i]] for i in range(n)]
        min_val = min(min_val, f(x) + g(permuted_x))
    return min_val


def trop_demazure(i: int, f: Callable, x: List[int]) -> int:
    """Compute Dᵢ(f)(x) = min(f(x), f(sᵢ·x) + xᵢ - x_{i+1})."""
    n = len(x)
    assert i + 1 < n
    si_x = list(x)
    si_x[i], si_x[i + 1] = si_x[i + 1], si_x[i]
    return min(f(x), f(si_x) + x[i] - x[i + 1])


def weyl_rho(n: int) -> List[int]:
    """The Weyl rho vector: ρ = (n-1, n-2, ..., 1, 0)."""
    return [n - 1 - i for i in range(n)]


# ============================================================
# DEMO 1: Tropical Schur Polynomial for GL₂
# ============================================================
print("=" * 60)
print("DEMO 1: Tropical Schur Polynomial for GL₂")
print("=" * 60)

w = [3, 1]
test_points = [[2, 5], [5, 2], [1, 1], [0, 10], [10, 0]]

for x in test_points:
    val = tropical_schur(w, x)
    perms = []
    for p in permutations(range(2)):
        v = sum(w[p[i]] * x[i] for i in range(2))
        perms.append(f"{'⟨' + ','.join(str(w[p[i]]) for i in range(2)) + '⟩·⟨' + ','.join(str(xi) for xi in x) + '⟩'}={v}")
    print(f"  tropSchur({w}, {x}) = min({', '.join(str(sum(w[p[i]]*x[i] for i in range(2))) for p in permutations(range(2)))}) = {val}")

print()

# ============================================================
# DEMO 2: Weyl Invariance Verification
# ============================================================
print("=" * 60)
print("DEMO 2: Weyl Invariance Verification for GL₃")
print("=" * 60)

w = [5, 3, 1]
x = [2, 7, 4]
base_val = tropical_schur(w, x)
print(f"  w = {w}, x = {x}")
print(f"  tropSchur(w, x) = {base_val}")

for perm in permutations(range(3)):
    permuted_x = [x[perm[i]] for i in range(3)]
    val = tropical_schur(w, permuted_x)
    status = "✓" if val == base_val else "✗"
    print(f"  tropSchur(w, {permuted_x}) = {val} {status}")

print()

# ============================================================
# DEMO 3: Super-Additivity
# ============================================================
print("=" * 60)
print("DEMO 3: Super-Additivity of Tropical Schur")
print("=" * 60)

w1 = [3, 1]
w2 = [2, 0]
w_sum = [w1[i] + w2[i] for i in range(2)]

test_x = [[1, 0], [0, 1], [2, 5], [3, -1], [1, 1]]

for x in test_x:
    ts1 = tropical_schur(w1, x)
    ts2 = tropical_schur(w2, x)
    ts_sum = tropical_schur(w_sum, x)
    gap = ts_sum - (ts1 + ts2)
    status = "✓" if ts1 + ts2 <= ts_sum else "✗"
    print(f"  x={x}: tropSchur(w₁+w₂)={ts_sum}, tropSchur(w₁)+tropSchur(w₂)={ts1}+{ts2}={ts1+ts2}, gap={gap} {status}")

print()

# ============================================================
# DEMO 4: Convolution Collapse
# ============================================================
print("=" * 60)
print("DEMO 4: Tropical Hecke Convolution Collapse")
print("=" * 60)

w_f = [3, 1]
w_g = [2, 0]

# f = tropSchur(w_f), g = tropSchur(w_g) are Weyl-invariant
f = lambda x: tropical_schur(w_f, x)
g = lambda x: tropical_schur(w_g, x)

for x in [[1, 0], [2, 5], [3, -1], [1, 1]]:
    conv = trop_hecke_conv(f, g, x)
    pointwise = f(x) + g(x)
    status = "✓" if conv == pointwise else "✗"
    print(f"  x={x}: (f⊛g)(x)={conv}, f(x)+g(x)={pointwise} {status}")

print()

# ============================================================
# DEMO 5: Tropical Demazure Operator
# ============================================================
print("=" * 60)
print("DEMO 5: Tropical Demazure Operator")
print("=" * 60)

w_mono = [3, 1, 0]
mono = lambda x: tropical_monomial(w_mono, x)

print(f"  Monomial w = {w_mono}")
print(f"  D₀(mono)(x) = min(mono(x), mono(s₀·x) + x₀ - x₁)")
print()

for x in [[5, 3, 1], [1, 3, 5], [2, 2, 2], [4, 2, 0]]:
    mono_val = mono(x)
    dema_val = trop_demazure(0, mono, x)
    si_x = [x[1], x[0], x[2]]
    mono_si = mono(si_x)
    correction = x[0] - x[1]
    print(f"  x={x}: mono={mono_val}, mono(s₀·x)={mono_si}, correction={correction}")
    print(f"    D₀(mono)(x) = min({mono_val}, {mono_si}+{correction}={mono_si+correction}) = {dema_val}")

print()

# ============================================================
# DEMO 6: Weight Orbit Invariance (Boundary)
# ============================================================
print("=" * 60)
print("DEMO 6: Weight Orbit Invariance (Boundary)")
print("=" * 60)

w = [5, 3, 1]
x = [2, 7, 4]

print(f"  Base weight w = {w}")
for perm in permutations(range(3)):
    perm_w = [w[perm[i]] for i in range(3)]
    val = tropical_schur(perm_w, x)
    print(f"  tropSchur({perm_w}, {x}) = {val}")

print()

# ============================================================
# DEMO 7: Satake Transform Verification
# ============================================================
print("=" * 60)
print("DEMO 7: Satake Transform = Tropical Schur")
print("=" * 60)

w = [4, 2, 1]
mono_w = lambda x: tropical_monomial(w, x)

for x in [[1, 0, -1], [2, 3, 1], [5, 5, 5]]:
    satake_val = satake_transform(mono_w, x)
    schur_val = tropical_schur(w, x)
    status = "✓" if satake_val == schur_val else "✗"
    print(f"  x={x}: S(mono)(x)={satake_val}, tropSchur(w,x)={schur_val} {status}")

print()
print("All demonstrations complete.")


#!/usr/bin/env python3
"""
Visualization: Tropical Schur Polynomial Surface for GL₂

Plots the piecewise-linear surface tropSchur((a,b), (x₁, x₂)) as a function
of (x₁, x₂) for fixed weight (a, b).
"""
import numpy as np
import matplotlib.pyplot as plt
from itertools import permutations


def tropical_schur_2d(a: int, b: int, x1: float, x2: float) -> float:
    """tropSchur((a,b), (x1,x2)) = min(a*x1 + b*x2, b*x1 + a*x2)"""
    return min(a * x1 + b * x2, b * x1 + a * x2)


def tropical_schur_nd(w, x):
    """General tropSchur for any dimension."""
    n = len(w)
    return min(
        sum(w[p[i]] * x[i] for i in range(n))
        for p in permutations(range(n))
    )


# Create figure with two subplots
fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# ---- Plot 1: GL₂ Tropical Schur Surface ----
ax1 = axes[0]
x1_range = np.linspace(-3, 3, 200)
x2_range = np.linspace(-3, 3, 200)
X1, X2 = np.meshgrid(x1_range, x2_range)

a, b = 3, 1
Z = np.vectorize(lambda x1, x2: tropical_schur_2d(a, b, x1, x2))(X1, X2)

contour = ax1.contourf(X1, X2, Z, levels=20, cmap='viridis')
plt.colorbar(contour, ax=ax1, label='tropSchur((3,1), (x₁, x₂))')
ax1.plot([-3, 3], [-3, 3], 'r--', linewidth=2, label='Ridge: x₁ = x₂')
ax1.set_xlabel('x₁')
ax1.set_ylabel('x₂')
ax1.set_title('GL₂ Tropical Schur: tropSchur((3,1), x)')
ax1.legend()
ax1.set_aspect('equal')

# ---- Plot 2: Super-Additivity Gap ----
ax2 = axes[1]
w1 = [3, 1]
w2 = [2, 0]
w_sum = [5, 1]

gaps = []
x1_vals = np.linspace(-3, 3, 100)
x2_vals = np.linspace(-3, 3, 100)
X1g, X2g = np.meshgrid(x1_vals, x2_vals)

def gap_func(x1, x2):
    ts1 = tropical_schur_2d(w1[0], w1[1], x1, x2)
    ts2 = tropical_schur_2d(w2[0], w2[1], x1, x2)
    ts_sum = tropical_schur_2d(w_sum[0], w_sum[1], x1, x2)
    return ts_sum - (ts1 + ts2)

Zgap = np.vectorize(gap_func)(X1g, X2g)

contour2 = ax2.contourf(X1g, X2g, Zgap, levels=20, cmap='RdYlGn')
plt.colorbar(contour2, ax=ax2, label='Gap: tropSchur(w₁+w₂) - [tropSchur(w₁) + tropSchur(w₂)]')
ax2.contour(X1g, X2g, Zgap, levels=[0], colors='black', linewidths=2)
ax2.set_xlabel('x₁')
ax2.set_ylabel('x₂')
ax2.set_title('Super-Additivity Gap (w₁=(3,1), w₂=(2,0))')
ax2.set_aspect('equal')

plt.tight_layout()
plt.savefig('tropical_schur_visualization.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: tropical_schur_visualization.png")
