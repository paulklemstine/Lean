#!/usr/bin/env python3
"""
Negative-Dimensional Topology: Numerical Demonstrations

Demonstrates the key theorems:
1. Spectrum gap: consecutive Euler chars sum to 2
2. Cesàro convergence: average Euler char → 1
3. Suspension-product non-commutativity
4. Poincaré duality for palindromic Betti sequences
5. Uniform cell theorem
"""

from dataclasses import dataclass
from typing import List, Tuple


@dataclass
class FormalDimObj:
    """Formal dimension object with dimension and Euler characteristic."""
    dim: int
    euler: int

    def suspend(self) -> 'FormalDimObj':
        return FormalDimObj(self.dim + 1, 2 - self.euler)

    def suspend_iter(self, n: int) -> 'FormalDimObj':
        result = self
        for _ in range(n):
            result = result.suspend()
        return result

    def product(self, other: 'FormalDimObj') -> 'FormalDimObj':
        return FormalDimObj(self.dim + other.dim, self.euler * other.euler)


def neg_dim_sphere(d: int) -> FormalDimObj:
    """Formal sphere S^d."""
    return FormalDimObj(d, 1 + (-1)**d)


# === Demonstration 1: Spectrum Gap ===
print("=" * 60)
print("THEOREM: Spectrum Gap")
print("χ(Σⁿ X) + χ(Σⁿ⁺¹ X) = 2 for all X, n")
print("=" * 60)

test_objects = [
    FormalDimObj(-3, 5),
    FormalDimObj(-1, 0),   # empty space
    FormalDimObj(0, 2),    # point
    FormalDimObj(-5, -7),
]

for X in test_objects:
    print(f"\nX = (dim={X.dim}, χ={X.euler})")
    for n in range(6):
        sn = X.suspend_iter(n)
        sn1 = X.suspend_iter(n + 1)
        gap = sn.euler + sn1.euler
        print(f"  n={n}: χ(Σ^{n}X)={sn.euler:4d}, χ(Σ^{n+1}X)={sn1.euler:4d}, sum={gap}")
        assert gap == 2, f"Spectrum gap failed!"


# === Demonstration 2: Cesàro Convergence ===
print("\n" + "=" * 60)
print("THEOREM: Cesàro Convergence")
print("Average of χ over 2(k+1) terms = 1 exactly")
print("=" * 60)

X = FormalDimObj(-2, 42)
print(f"\nX = (dim={X.dim}, χ={X.euler})")
for k in range(8):
    n_terms = 2 * (k + 1)
    total = sum(X.suspend_iter(i).euler for i in range(n_terms))
    avg = total / n_terms
    print(f"  {n_terms:3d} terms: sum={total:6d}, avg={avg:.6f}")
    assert total == n_terms, f"Even count sum failed!"

print(f"\nOdd count sums (2k+1 terms):")
for k in range(8):
    n_terms = 2 * k + 1
    total = sum(X.suspend_iter(i).euler for i in range(n_terms))
    expected = 2 * k + X.euler
    avg = total / n_terms if n_terms > 0 else 0
    print(f"  {n_terms:3d} terms: sum={total:6d}, expected={expected:6d}, avg={avg:.6f}")
    assert total == expected, f"Odd count sum failed!"


# === Demonstration 3: Suspension-Product Non-Commutativity ===
print("\n" + "=" * 60)
print("THEOREM: Suspension-Product Non-Commutativity")
print("Σ(X×Y) ≠ (ΣX)×Y when χ(Y) ≠ 1")
print("=" * 60)

for X in [FormalDimObj(0, 2), FormalDimObj(-1, 0), FormalDimObj(1, 3)]:
    for Y in [FormalDimObj(0, 2), FormalDimObj(-1, 0), FormalDimObj(1, 3)]:
        lhs = X.product(Y).suspend().euler  # Σ(X×Y)
        rhs = X.suspend().product(Y).euler  # (ΣX)×Y
        diff = lhs - rhs
        status = "EQUAL" if diff == 0 else "DIFFER"
        print(f"  X=(d={X.dim},χ={X.euler}), Y=(d={Y.dim},χ={Y.euler}): "
              f"Σ(X×Y).χ={lhs}, (ΣX×Y).χ={rhs}, diff={diff} [{status}]")
        if Y.euler != 1:
            assert diff != 0, "Non-commutativity failed!"


# === Demonstration 4: Poincaré Duality ===
print("\n" + "=" * 60)
print("THEOREM: Negative-Dimensional Poincaré Duality")
print("Palindromic Betti with even codim ⟹ χ ≡ β_k (mod 2)")
print("=" * 60)

def euler_from_betti(betti: List[int]) -> int:
    return sum((-1)**i * b for i, b in enumerate(betti))

# Test with palindromic sequences
palindromic_tests = [
    [1, 2, 1],          # codim=2, k=1
    [3, 5, 5, 3],       # codim=3 - not even, skip
    [1, 0, 1, 0, 1],    # codim=4, k=2
    [2, 3, 4, 3, 2],    # codim=4, k=2
    [1, 1, 1, 1, 1, 1, 1],  # codim=6, k=3
    [5, 2, 7, 3, 7, 2, 5],  # codim=6, k=3
]

for betti in palindromic_tests:
    codim = len(betti) - 1
    if codim % 2 != 0:
        continue
    k = codim // 2
    # Check palindromic
    is_palindrome = all(betti[i] == betti[codim - i] for i in range(codim + 1))
    if not is_palindrome:
        continue
    chi = euler_from_betti(betti)
    beta_k = betti[k]
    print(f"  β={betti}, codim={codim}, k={k}: χ={chi}, β_k={beta_k}, "
          f"χ mod 2 = {chi % 2}, β_k mod 2 = {beta_k % 2}")
    assert chi % 2 == beta_k % 2, "Poincaré duality failed!"


# === Demonstration 5: Uniform Cell Theorem ===
print("\n" + "=" * 60)
print("THEOREM: Uniform Cell — all βᵢ=1, codim=2k ⟹ χ=1")
print("=" * 60)

for k in range(10):
    codim = 2 * k
    betti = [1] * (codim + 1)
    chi = euler_from_betti(betti)
    print(f"  codim={codim:2d} (2k, k={k}): β={betti[:5]}{'...' if len(betti)>5 else ''}, χ={chi}")
    assert chi == 1, f"Uniform cell theorem failed for k={k}!"


# === Demonstration 6: Empty Space and Point Oscillation ===
print("\n" + "=" * 60)
print("THEOREM: Empty Space and Point Oscillation")
print("=" * 60)

empty = FormalDimObj(-1, 0)
point = FormalDimObj(0, 2)

print("\nEmpty space (dim=-1, χ=0) under suspension:")
for n in range(12):
    s = empty.suspend_iter(n)
    expected = 0 if n % 2 == 0 else 2
    marker = "✓" if s.euler == expected else "✗"
    print(f"  Σ^{n:2d}(∅) = (dim={s.dim:3d}, χ={s.euler}) {marker}")

print("\nPoint (dim=0, χ=2) under suspension:")
for n in range(12):
    s = point.suspend_iter(n)
    expected = 2 if n % 2 == 0 else 0
    marker = "✓" if s.euler == expected else "✗"
    print(f"  Σ^{n:2d}(pt) = (dim={s.dim:3d}, χ={s.euler}) {marker}")


print("\n" + "=" * 60)
print("ALL DEMONSTRATIONS PASSED ✓")
print("=" * 60)


#!/usr/bin/env python3
"""Visualization: Euler characteristic spectrum under iterated suspension."""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def suspend_euler(euler: int, n: int) -> int:
    """O(1) computation of χ(Σⁿ X)."""
    return euler if n % 2 == 0 else 2 - euler


def make_spectrum_plot():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    # Plot 1: Multiple base Euler chars
    ax = axes[0, 0]
    n_levels = 20
    bases = [("∅ (χ=0)", 0, -1), ("pt (χ=2)", 2, 0),
             ("S¹ (χ=0)", 0, 1), ("(χ=5)", 5, -3)]
    for label, euler, dim in bases:
        levels = range(n_levels)
        eulers = [suspend_euler(euler, n) for n in levels]
        dims = [dim + n for n in levels]
        ax.plot(dims, eulers, 'o-', label=label, markersize=4, alpha=0.8)
    ax.set_xlabel("Dimension")
    ax.set_ylabel("Euler Characteristic")
    ax.set_title("Euler Characteristic Spectrum")
    ax.legend()
    ax.grid(True, alpha=0.3)
    ax.axhline(y=1, color='gray', linestyle='--', alpha=0.5, label='Cesàro limit')

    # Plot 2: Cesàro averages
    ax = axes[0, 1]
    for label, euler, _ in bases:
        N_values = range(1, 40)
        averages = []
        for N in N_values:
            s = sum(suspend_euler(euler, n) for n in range(N))
            averages.append(s / N)
        ax.plot(list(N_values), averages, '-', label=label, alpha=0.8)
    ax.axhline(y=1, color='red', linestyle='--', linewidth=2, label='Limit = 1')
    ax.set_xlabel("Number of Terms")
    ax.set_ylabel("Cesàro Average")
    ax.set_title("Cesàro Convergence to 1")
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Plot 3: Spectrum gap visualization
    ax = axes[1, 0]
    euler_base = 7
    n_levels = 15
    levels = list(range(n_levels))
    eulers = [suspend_euler(euler_base, n) for n in levels]
    gaps = [eulers[n] + eulers[n+1] for n in range(n_levels - 1)]

    ax.bar(levels, eulers, alpha=0.6, color=['steelblue' if n%2==0 else 'coral' for n in levels])
    ax.axhline(y=1, color='gray', linestyle='--', alpha=0.5)
    for n in range(n_levels - 1):
        ax.annotate(f'Σ={gaps[n]}', xy=(n + 0.5, max(eulers[n], eulers[n+1]) + 0.3),
                   fontsize=7, ha='center', color='green')
    ax.set_xlabel("Suspension Level n")
    ax.set_ylabel("χ(Σⁿ X)")
    ax.set_title(f"Spectrum Gap (base χ={euler_base}): consecutive sum = 2")
    ax.grid(True, alpha=0.3)

    # Plot 4: Suspension-product defect
    ax = axes[1, 1]
    y_eulers = range(-5, 6)
    defects = [2 * (1 - ye) for ye in y_eulers]
    ax.bar(list(y_eulers), defects, alpha=0.7, color=['red' if d != 0 else 'green' for d in defects])
    ax.axhline(y=0, color='black', linewidth=0.5)
    ax.axvline(x=1, color='green', linestyle='--', linewidth=2, label='χ(Y)=1: commutes')
    ax.set_xlabel("χ(Y)")
    ax.set_ylabel("χ(Σ(X×Y)) - χ((ΣX)×Y)")
    ax.set_title("Suspension-Product Defect = 2(1 - χ(Y))")
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('neg_dim_spectrum.png', dpi=150, bbox_inches='tight')
    print("Saved neg_dim_spectrum.png")


if __name__ == "__main__":
    make_spectrum_plot()
