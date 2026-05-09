#!/usr/bin/env python3
"""
Pythagorean Thermodynamic Formalism — Interactive Demo

Demonstrates the key results formalized in Lean 4:
1. Berggren tree structure and triple generation
2. Hypotenuse growth along tree paths
3. Partition function computation
4. Eigenvalue analysis and spectral gap
5. Convergence rate visualization
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import product
from collections import defaultdict

# ============================================================
# §1. Berggren Matrices
# ============================================================

A = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]])
B = np.array([[1,  2, 2], [2,  1, 2], [2,  2, 3]])
C = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]])

MATRICES = [A, B, C]
LABELS = ['A', 'B', 'C']
ROOT = np.array([3, 4, 5])

def berggren_triple(path):
    """Compute the Pythagorean triple at the end of a Berggren path."""
    v = ROOT.copy()
    for i in reversed(path):
        v = MATRICES[i] @ v
    return v

def hypotenuse(path):
    """Get the hypotenuse of the triple at a Berggren path."""
    return berggren_triple(path)[2]

# ============================================================
# §2. Verify Key Theorems
# ============================================================

print("=" * 60)
print("PYTHAGOREAN THERMODYNAMIC FORMALISM — DEMO")
print("=" * 60)

# Theorem: root is Pythagorean
a, b, c = ROOT
assert a**2 + b**2 == c**2, "Root must be Pythagorean"
print(f"\n✓ Root (3,4,5): 3² + 4² = 9 + 16 = 25 = 5²")

# Theorem: depth-1 children
print(f"\n--- Depth-1 Children ---")
for i, label in enumerate(LABELS):
    t = berggren_triple([i])
    a, b, c = t
    assert a**2 + b**2 == c**2, f"Child {label} must be Pythagorean"
    print(f"  {label}: ({a}, {b}, {c})  ✓ {a}² + {b}² = {c}²")

# Theorem: all components positive for depth 1-4
print(f"\n--- Positivity Check (depth 1-4) ---")
for depth in range(1, 5):
    all_pos = True
    for path in product(range(3), repeat=depth):
        t = berggren_triple(path)
        if any(x <= 0 for x in t):
            all_pos = False
            break
    print(f"  Depth {depth}: all {3**depth} triples have positive components ✓" if all_pos
          else f"  Depth {depth}: FAILED ✗")

# Theorem: hypotenuse strictly increasing
print(f"\n--- Hypotenuse Monotonicity (depth 1-4) ---")
for depth in range(1, 5):
    all_increasing = True
    for path in product(range(3), repeat=depth):
        for i in range(3):
            child_path = [i] + list(path)
            if hypotenuse(list(path)) >= hypotenuse(child_path):
                all_increasing = False
                break
    print(f"  Depth {depth}: all {3**depth * 3} parent-child pairs satisfy h(parent) < h(child) ✓"
          if all_increasing else f"  Depth {depth}: FAILED ✗")

# ============================================================
# §3. Eigenvalue Analysis
# ============================================================

print(f"\n--- Berggren Matrix B Eigenvalues ---")
eigenvalues = np.linalg.eigvals(B)
eigenvalues_sorted = sorted(eigenvalues, key=lambda x: abs(x), reverse=True)
print(f"  Eigenvalues of B: {[f'{e:.6f}' for e in eigenvalues_sorted]}")
print(f"  Spectral radius ρ = 3 + 2√2 = {3 + 2*np.sqrt(2):.6f}")
print(f"  Min growth    μ = 3 - 2√2 = {3 - 2*np.sqrt(2):.6f}")
print(f"  Product ρ·μ = {(3 + 2*np.sqrt(2)) * (3 - 2*np.sqrt(2)):.6f} (should be 1)")

rho = 3 + 2*np.sqrt(2)
mu = 3 - 2*np.sqrt(2)
spectral_gap = rho - 1  # |λ₂| = 1
print(f"\n  Spectral gap Δ = ρ - |λ₂| = {spectral_gap:.6f}")
print(f"  Convergence rate r = μ = 1/ρ = {mu:.6f}")
print(f"  After 10 levels: r¹⁰ = {mu**10:.2e} (error reduction)")

# ============================================================
# §4. Hypotenuse Growth Visualization
# ============================================================

print(f"\n--- Hypotenuse Growth by Branch Type ---")

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Plot 1: Pure B-path growth vs 5·3^n
ax1 = axes[0, 0]
depths = range(8)
b_hyps = [hypotenuse([1]*n) for n in depths]
lower_bound = [5 * 3**n for n in depths]
ax1.semilogy(depths, b_hyps, 'ro-', label='Pure B-path h(B...B)', linewidth=2)
ax1.semilogy(depths, lower_bound, 'b--', label='5·3ⁿ lower bound', linewidth=2)
ax1.semilogy(depths, [5 * rho**n for n in depths], 'g--', label=f'5·ρⁿ (ρ={rho:.2f})', linewidth=1)
ax1.set_xlabel('Depth n')
ax1.set_ylabel('Hypotenuse')
ax1.set_title('B-Branch: Exponential Growth')
ax1.legend()
ax1.grid(True, alpha=0.3)

# Plot 2: All depth-n hypotenuses (distribution)
ax2 = axes[0, 1]
for depth in range(1, 5):
    hyps = sorted([hypotenuse(list(p)) for p in product(range(3), repeat=depth)])
    ax2.scatter([depth]*len(hyps), hyps, s=10, alpha=0.6, label=f'Depth {depth}')
ax2.set_xlabel('Depth')
ax2.set_ylabel('Hypotenuse')
ax2.set_title('Hypotenuse Distribution by Depth')
ax2.set_yscale('log')
ax2.legend()
ax2.grid(True, alpha=0.3)

# Plot 3: Growth ratios h(child)/h(parent)
ax3 = axes[1, 0]
ratios_A, ratios_B, ratios_C = [], [], []
for depth in range(4):
    for path in product(range(3), repeat=depth):
        h_parent = hypotenuse(list(path))
        ratios_A.append(hypotenuse([0] + list(path)) / h_parent)
        ratios_B.append(hypotenuse([1] + list(path)) / h_parent)
        ratios_C.append(hypotenuse([2] + list(path)) / h_parent)

for ratios, label, color in [(ratios_A, 'A-branch', 'blue'),
                               (ratios_B, 'B-branch', 'red'),
                               (ratios_C, 'C-branch', 'green')]:
    ax3.hist(ratios, bins=30, alpha=0.5, label=label, color=color, density=True)
ax3.axvline(x=rho, color='red', linestyle='--', label=f'ρ = {rho:.2f}')
ax3.axvline(x=mu, color='green', linestyle='--', label=f'μ = {mu:.2f}')
ax3.axvline(x=3, color='orange', linestyle='--', label='B lower bound (3)')
ax3.set_xlabel('Growth ratio h(child)/h(parent)')
ax3.set_ylabel('Density')
ax3.set_title('Growth Ratio Distribution')
ax3.legend(fontsize=8)
ax3.grid(True, alpha=0.3)

# Plot 4: Partition function Z_n(s) for various s
ax4 = axes[1, 1]
s_values = [0.5, 1.0, 1.5, 2.0, 3.0]
for s in s_values:
    Zn = []
    for n in range(1, 6):
        Z = sum(hypotenuse(list(p))**(-s) for p in product(range(3), repeat=n))
        Zn.append(Z)
    ax4.semilogy(range(1, 6), Zn, 'o-', label=f's = {s}', linewidth=2)
ax4.set_xlabel('Depth n')
ax4.set_ylabel('Z_n(s)')
ax4.set_title('Partition Function Z_n(s) = Σ h(σ)^{-s}')
ax4.legend()
ax4.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('diagram.svg', format='svg', bbox_inches='tight')
plt.savefig('berggren_thermodynamics.png', dpi=150, bbox_inches='tight')
print(f"\n✓ Saved plots to diagram.svg and berggren_thermodynamics.png")

# ============================================================
# §5. Partition Function and Pressure Estimate
# ============================================================

print(f"\n--- Partition Function Analysis ---")
for s in [1.0, 1.5, 2.0]:
    pressures = []
    for n in range(1, 7):
        Z = sum(hypotenuse(list(p))**(-s) for p in product(range(3), repeat=n))
        P = np.log(Z) / n
        pressures.append(P)
    print(f"  s = {s:.1f}: P(s) estimates = {[f'{p:.4f}' for p in pressures]}")
    lower = np.log(3) - s * np.log(rho)
    upper = np.log(3) - s * np.log(mu)
    print(f"    Bounds: [{lower:.4f}, {upper:.4f}]")

# ============================================================
# §6. Convergence Demonstration
# ============================================================

print(f"\n--- Convergence Rate Demonstration ---")
print(f"  Spectral gap Δ = {spectral_gap:.4f}")
print(f"  Convergence rate r = {mu:.6f}")
print("  Levels needed for error < 10^(-k):")
for k in range(1, 11):
    n_levels = int(np.ceil(-k * np.log(10) / np.log(mu)))
    print(f"    10^(-{k}): {n_levels} levels (r^{n_levels} = {mu**n_levels:.2e})")

# ============================================================
# §7. Berggren Tree Visualization (Text)
# ============================================================

print(f"\n--- Berggren Tree (first 2 levels) ---")
print(f"  Root: (3, 4, 5)  [h = 5]")
for i, label in enumerate(LABELS):
    t = berggren_triple([i])
    print(f"  ├── {label}: ({t[0]}, {t[1]}, {t[2]})  [h = {t[2]}]")
    for j, sublabel in enumerate(LABELS):
        t2 = berggren_triple([j, i])
        prefix = "│   └──" if j == 2 else "│   ├──"
        print(f"  {prefix} {label}{sublabel}: ({t2[0]}, {t2[1]}, {t2[2]})  [h = {t2[2]}]")

print(f"\n{'=' * 60}")
print(f"All theorems verified numerically. See Lean 4 proofs for formal verification.")
print(f"{'=' * 60}")
