#!/usr/bin/env python3
"""
Hyperbolic Number Theory: Interactive Demonstrations

This script demonstrates the key mathematical structures formalized
in the Lean 4 proofs:
1. Einstein addition and the rapidity isomorphism
2. Chebyshev polynomial composition (trace-distance duality)
3. Blaschke factor disk preservation
4. Orbit counting in the Poincaré disk
"""

import math
import cmath
from typing import List, Tuple


def einstein_add(a: float, b: float) -> float:
    """Einstein addition: (a + b) / (1 + ab)."""
    return (a + b) / (1 + a * b)


def rapidity(x: float) -> float:
    """Rapidity (artanh): (1/2) log((1+x)/(1-x))."""
    return 0.5 * math.log((1 + x) / (1 - x))


def chebyshev_T(n: int, x: float) -> float:
    """Chebyshev polynomial T_n(x) via recurrence."""
    if n == 0: return 1.0
    if n == 1: return x
    t0, t1 = 1.0, x
    for _ in range(2, n + 1):
        t0, t1 = t1, 2 * x * t1 - t0
    return t1


def hyperbolic_distance(z1: complex, z2: complex) -> float:
    """Poincaré disk hyperbolic distance."""
    ratio = abs(z1 - z2) / abs(1 - z1.conjugate() * z2)
    if ratio >= 1: return float('inf')
    return math.atanh(ratio)


def main():
    print("=" * 70)
    print("  HYPERBOLIC NUMBER THEORY: Arithmetic on the Poincaré Disk")
    print("=" * 70)

    # ─── Demo 1: Einstein Addition Group ───────────────────────────────
    print("\n── Demo 1: Einstein Addition is a Commutative Group on (-1,1) ──\n")
    
    test_values = [0.3, 0.5, 0.7, -0.4, 0.9]
    
    # Closure
    print("Closure: a,b ∈ (-1,1) ⟹ a⊕b ∈ (-1,1)")
    for a in [0.5, 0.9, -0.8]:
        for b in [0.3, 0.7, -0.6]:
            result = einstein_add(a, b)
            print(f"  {a:+.1f} ⊕ {b:+.1f} = {result:+.6f}  (|result| = {abs(result):.6f} < 1 ✓)")
    
    # Associativity
    print("\nAssociativity: (a⊕b)⊕c = a⊕(b⊕c)")
    a, b, c = 0.3, 0.5, 0.7
    left = einstein_add(einstein_add(a, b), c)
    right = einstein_add(a, einstein_add(b, c))
    print(f"  ({a}⊕{b})⊕{c} = {left:.10f}")
    print(f"  {a}⊕({b}⊕{c}) = {right:.10f}")
    print(f"  Difference: {abs(left - right):.2e} ✓")
    
    # Identity and inverse
    print(f"\nIdentity: {a}⊕0 = {einstein_add(a, 0)}")
    print(f"Inverse:  {a}⊕({-a}) = {einstein_add(a, -a):.2e} ≈ 0")

    # ─── Demo 2: The Rapidity Isomorphism ──────────────────────────────
    print("\n── Demo 2: Rapidity is a Homomorphism ──\n")
    print("  rapidity(a ⊕ b) = rapidity(a) + rapidity(b)")
    print()
    
    pairs = [(0.3, 0.5), (0.7, 0.2), (-0.4, 0.6), (0.9, -0.8)]
    for a, b in pairs:
        sum_val = einstein_add(a, b)
        rap_sum = rapidity(sum_val)
        rap_add = rapidity(a) + rapidity(b)
        print(f"  a={a:+.1f}, b={b:+.1f}: "
              f"rapidity(a⊕b) = {rap_sum:+.6f}, "
              f"rap(a)+rap(b) = {rap_add:+.6f}, "
              f"Δ = {abs(rap_sum - rap_add):.2e}")

    # ─── Demo 3: Chebyshev Cosine Duality ──────────────────────────────
    print("\n── Demo 3: Chebyshev-Cosine Duality T_n(cos θ) = cos(nθ) ──\n")
    
    theta = 0.7
    for n in range(0, 8):
        lhs = chebyshev_T(n, math.cos(theta))
        rhs = math.cos(n * theta)
        print(f"  T_{n}(cos {theta}) = {lhs:+.8f}, cos({n}·{theta}) = {rhs:+.8f}, "
              f"Δ = {abs(lhs - rhs):.2e}")

    # ─── Demo 4: Chebyshev Composition T_m∘T_n = T_{mn} ───────────────
    print("\n── Demo 4: Chebyshev Composition T_m(T_n(x)) = T_{mn}(x) ──\n")
    
    x = 2.5  # Note: works for ALL x, not just |x| ≤ 1
    print(f"  Testing at x = {x} (outside [-1,1]!):\n")
    for m, n in [(2, 3), (3, 4), (4, 5), (5, 7), (3, 11)]:
        lhs = chebyshev_T(m, chebyshev_T(n, x))
        rhs = chebyshev_T(m * n, x)
        print(f"  T_{m}(T_{n}({x})) = {lhs:.4f}")
        print(f"  T_{m*n}({x})      = {rhs:.4f}")
        print(f"  Match: {abs(lhs - rhs) < 1e-4} (Δ = {abs(lhs-rhs):.2e})\n")

    # ─── Demo 5: Blaschke Factor Identity ──────────────────────────────
    print("── Demo 5: Blaschke Factor Disk Preservation ──\n")
    
    a = complex(1.2, 0.3)
    b = complex(0.4, 0.1)
    det = abs(a)**2 - abs(b)**2
    print(f"  Coefficients: a = {a}, b = {b}")
    print(f"  |a|² - |b|² = {det:.6f}")
    print()
    
    test_points = [complex(0.3, 0.2), complex(-0.5, 0.1), complex(0, 0.7)]
    for z in test_points:
        denom = b.conjugate() * z + a.conjugate()
        phi_z = (a * z + b) / denom
        
        lhs = abs(denom)**2 * (1 - abs(phi_z)**2)
        rhs = det * (1 - abs(z)**2)
        
        print(f"  z = {z}:")
        print(f"    φ(z) = {phi_z.real:+.6f}{phi_z.imag:+.6f}i")
        print(f"    |z|  = {abs(z):.6f}, |φ(z)| = {abs(phi_z):.6f}")
        print(f"    LHS  = {lhs:.10f}")
        print(f"    RHS  = {rhs:.10f}")
        print(f"    Match: {abs(lhs - rhs) < 1e-10} ✓\n")

    # ─── Demo 6: Orbit Counting ────────────────────────────────────────
    print("── Demo 6: Hyperbolic Distance and Trace-Distance ──\n")
    
    print("  Trace-distance relation: cosh(d) = |tr(γ)|/2\n")
    for trace in [2, 3, 4, 5, 7, 10, 20]:
        t = abs(trace) / 2.0
        if t >= 1:
            d = math.acosh(t)
            print(f"  tr = {trace:3d}: d = {d:.6f}, cosh(d) = {math.cosh(d):.6f} = {t}")
    
    # Chebyshev recurrence for iterated trace
    print("\n  Iterated traces via Chebyshev: tr(γⁿ) = 2·T_n(tr(γ)/2)")
    trace = 3
    print(f"\n  Base trace = {trace}:")
    for n in range(1, 8):
        tr_n = 2 * chebyshev_T(n, trace / 2)
        print(f"    tr(γ^{n}) = {tr_n:.0f}")

    print("\n" + "=" * 70)
    print("  All demonstrations complete. See RESEARCH_PAPER.md for details.")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Poincaré Disk Tessellation and Einstein Addition

Generates plots showing:
1. The Poincaré disk with PSL₂(ℤ) orbit points
2. Einstein addition vs ordinary addition
3. Chebyshev polynomial composition
"""

import math
import cmath
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np


def einstein_add(a: float, b: float) -> float:
    return (a + b) / (1 + a * b)


def rapidity(x: float) -> float:
    return 0.5 * math.log((1 + x) / (1 - x))


def chebyshev_T(n: int, x: float) -> float:
    if n == 0: return 1.0
    if n == 1: return x
    t0, t1 = 1.0, x
    for _ in range(2, n + 1):
        t0, t1 = t1, 2 * x * t1 - t0
    return t1


def cayley_to_disk(z: complex) -> complex:
    return (z - 1j) / (z + 1j)


def sl2z_action(a, b, c, d, z):
    return (a * z + b) / (c * z + d)


def get_orbit_points(max_depth=6):
    """Generate PSL₂(ℤ) orbit of i, mapped to disk."""
    origin = 1j
    visited = set()
    points = []
    queue = [(origin, 0)]
    
    while queue:
        z, depth = queue.pop(0)
        w = cayley_to_disk(z)
        key = (round(w.real, 6), round(w.imag, 6))
        
        if key in visited or abs(w) >= 0.999:
            continue
        visited.add(key)
        points.append((w, depth))
        
        if depth < max_depth:
            # S: z -> -1/z
            if abs(z) > 1e-10:
                queue.append((-1/z, depth + 1))
            # T: z -> z + 1
            queue.append((z + 1, depth + 1))
            # T^{-1}: z -> z - 1
            queue.append((z - 1, depth + 1))
    
    return points


# ─── Figure 1: Poincaré Disk with Orbit Points ───────────────
fig, axes = plt.subplots(1, 3, figsize=(18, 6))

ax = axes[0]
circle = plt.Circle((0, 0), 1, fill=False, color='black', linewidth=2)
ax.add_patch(circle)

orbit = get_orbit_points(max_depth=7)
colors = plt.cm.viridis(np.linspace(0, 1, 8))

for w, depth in orbit:
    c = colors[min(depth, 7)]
    size = max(20 - depth * 2, 3)
    ax.plot(w.real, w.imag, 'o', color=c, markersize=size, alpha=0.7)

ax.set_xlim(-1.15, 1.15)
ax.set_ylim(-1.15, 1.15)
ax.set_aspect('equal')
ax.set_title('PSL₂(ℤ) Orbit on Poincaré Disk', fontsize=14)
ax.set_xlabel('Re(z)')
ax.set_ylabel('Im(z)')
ax.grid(True, alpha=0.3)

# ─── Figure 2: Einstein Addition vs Ordinary Addition ─────────
ax = axes[1]

b_vals = np.linspace(-0.95, 0.95, 200)
a = 0.5
einstein_results = [einstein_add(a, b) for b in b_vals]
ordinary_results = [a + b for b in b_vals]

ax.plot(b_vals, einstein_results, 'b-', linewidth=2, label=f'Einstein: {a} ⊕ b')
ax.plot(b_vals, ordinary_results, 'r--', linewidth=2, label=f'Ordinary: {a} + b')
ax.axhline(y=1, color='gray', linestyle=':', alpha=0.5, label='Speed of light')
ax.axhline(y=-1, color='gray', linestyle=':', alpha=0.5)
ax.fill_between(b_vals, -1, 1, alpha=0.05, color='blue')

ax.set_xlim(-1, 1)
ax.set_ylim(-2, 2)
ax.set_xlabel('b', fontsize=12)
ax.set_ylabel('Result', fontsize=12)
ax.set_title('Einstein vs Ordinary Addition', fontsize=14)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# ─── Figure 3: Chebyshev Polynomials ──────────────────────────
ax = axes[2]

x_vals = np.linspace(-1, 1, 500)
for n in range(1, 7):
    y_vals = [chebyshev_T(n, x) for x in x_vals]
    ax.plot(x_vals, y_vals, linewidth=1.5, label=f'T_{n}(x)')

ax.set_xlim(-1, 1)
ax.set_ylim(-1.2, 1.2)
ax.set_xlabel('x', fontsize=12)
ax.set_ylabel('T_n(x)', fontsize=12)
ax.set_title('Chebyshev Polynomials T_n(x)', fontsize=14)
ax.legend(fontsize=9, loc='lower left')
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('hyperbolic_arithmetic.png', dpi=150, bbox_inches='tight')
plt.close()

print("Saved: hyperbolic_arithmetic.png")

# ─── Figure 4: Chebyshev Composition Verification ─────────────
fig, axes = plt.subplots(1, 2, figsize=(14, 6))

ax = axes[0]
x_vals = np.linspace(-1.5, 1.5, 500)
m, n = 3, 4
lhs = [chebyshev_T(m, chebyshev_T(n, x)) for x in x_vals]
rhs = [chebyshev_T(m * n, x) for x in x_vals]

ax.plot(x_vals, lhs, 'b-', linewidth=2, label=f'T_{m}(T_{n}(x))')
ax.plot(x_vals, rhs, 'r--', linewidth=2, label=f'T_{m*n}(x)')
ax.set_xlabel('x', fontsize=12)
ax.set_ylabel('Value', fontsize=12)
ax.set_title(f'Chebyshev Composition: T_{m}∘T_{n} = T_{m*n}', fontsize=14)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

ax = axes[1]
a_vals = np.linspace(-0.99, 0.99, 200)
rap_vals = [rapidity(a) for a in a_vals]
ax.plot(a_vals, rap_vals, 'b-', linewidth=2)
ax.plot(a_vals, a_vals, 'r--', linewidth=1, alpha=0.5, label='y = x (linear)')
ax.set_xlabel('x ∈ (-1, 1)', fontsize=12)
ax.set_ylabel('rapidity(x)', fontsize=12)
ax.set_title('Rapidity: The Bridge to Flat Arithmetic', fontsize=14)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('chebyshev_rapidity.png', dpi=150, bbox_inches='tight')
plt.close()

print("Saved: chebyshev_rapidity.png")
