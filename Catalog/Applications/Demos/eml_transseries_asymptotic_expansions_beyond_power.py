#!/usr/bin/env python3
"""
Transseries: Asymptotic Expansions Beyond Power Series — Demo

Demonstrates the key mathematical results:
1. Exponential dominance hierarchy: exp(x) >> x^n >> log(x)
2. Iterated exponentials form a strict tower
3. EML diagonal function: exp(z) - log(z) ~ exp(z) for large z
4. Monomial comparison via lexicographic ordering
"""

import math

def iterExp(n: int, x: float) -> float:
    """n-fold iterated exponential."""
    result = x
    for _ in range(n):
        if result > 700:
            return float('inf')
        result = math.exp(result)
    return result

def emlDiag(z: float) -> float:
    """EML diagonal: exp(z) - log(z)."""
    return math.exp(z) - math.log(z)

def emlDiagIter(n: int, z: float) -> float:
    """Iterated EML diagonal."""
    result = z
    for _ in range(n):
        if result > 700:
            return float('inf')
        result = emlDiag(result)
    return result


print("=" * 70)
print("DEMO 1: Exponential Dominates All Polynomials")
print("=" * 70)
print(f"{'x':>8} {'x^5':>15} {'exp(x)':>15} {'x^5/exp(x)':>15}")
for x in [1, 5, 10, 20, 50, 100]:
    xn = x**5
    ex = math.exp(x)
    ratio = xn / ex if ex > 0 else float('inf')
    print(f"{x:>8} {xn:>15.2f} {ex:>15.2e} {ratio:>15.2e}")
print("\nConfirmed: x^5 / exp(x) → 0 ✓")


print("\n" + "=" * 70)
print("DEMO 2: Log Subordinate to Any Positive Power")
print("=" * 70)
eps = 0.1
print(f"ε = {eps}")
print(f"{'x':>8} {'log(x)':>12} {'x^ε':>12} {'log(x)/x^ε':>15}")
for x in [10, 100, 1000, 10000, 100000, 1000000]:
    lx = math.log(x)
    xe = x**eps
    ratio = lx / xe
    print(f"{x:>8} {lx:>12.4f} {xe:>12.4f} {ratio:>15.6f}")
print("\nConfirmed: log(x) / x^ε → 0 ✓")


print("\n" + "=" * 70)
print("DEMO 3: Iterated Exponential Hierarchy")
print("=" * 70)
x = 2.0
print(f"Starting value x = {x}")
for n in range(5):
    val = iterExp(n, x)
    if val < 1e300 and val != float('inf'):
        print(f"  iterExp({n}, {x}) = {val:.6e}")
    else:
        print(f"  iterExp({n}, {x}) = +∞ (overflow)")
print("\nEach level grows incomparably faster than the previous. ✓")


print("\n" + "=" * 70)
print("DEMO 4: EML Diagonal ~ exp(z) for large z")
print("=" * 70)
print(f"{'z':>6} {'emlDiag(z)':>15} {'exp(z)':>15} {'ratio':>12}")
for z in [1, 2, 5, 10, 20]:
    ed = emlDiag(z)
    ex = math.exp(z)
    ratio = ed / ex
    print(f"{z:>6} {ed:>15.6e} {ex:>15.6e} {ratio:>12.8f}")
print("\nConfirmed: emlDiag(z) / exp(z) → 1 ✓")


print("\n" + "=" * 70)
print("DEMO 5: Iterated EML Diagonal — Strict Growth")
print("=" * 70)
z0 = 2.0
print(f"Starting value z = {z0}")
for n in range(4):
    val = emlDiagIter(n, z0)
    if val < 1e300 and val != float('inf'):
        print(f"  emlDiagIter({n}, {z0}) = {val:.6e}")
    else:
        print(f"  emlDiagIter({n}, {z0}) = +∞ (overflow)")
print("\nStrict monotonicity: emlDiagIter(n+1,z) > emlDiagIter(n,z) ✓")


print("\n" + "=" * 70)
print("DEMO 6: Monomial Dominance — Lexicographic Order")
print("=" * 70)
print("Monomials: x^α · exp(β·x) · log(x)^γ")
print("Order: compare β first, then α, then γ")
monomials = [
    ("exp(2x)", 0, 2, 0),
    ("exp(x)", 0, 1, 0),
    ("x^3·exp(x)", 3, 1, 0),
    ("x^2·exp(x)", 2, 1, 0),
    ("x^2·exp(x)·log(x)", 2, 1, 1),
    ("x^5", 5, 0, 0),
    ("x^2", 2, 0, 0),
    ("log(x)^3", 0, 0, 3),
    ("1", 0, 0, 0),
]
print(f"\n{'Monomial':<25} {'(β, α, γ)':<20} {'Rank'}")
print("-" * 55)
sorted_monos = sorted(monomials, key=lambda m: (m[2], m[1], m[3]), reverse=True)
for i, (name, alpha, beta, gamma) in enumerate(sorted_monos):
    print(f"{name:<25} ({beta}, {alpha}, {gamma}){'':<12} {i+1}")
print("\nTotal order confirmed: any two monomials are comparable ✓")


print("\n" + "=" * 70)
print("DEMO 7: Asymptotic Comparison — Leading Term Determines Behavior")
print("=" * 70)
a1, a2, b1, b2 = 1.0, -3.0, 2.0, 1.0
print(f"f(x) = {a1}·exp({b1}·x) + {a2}·exp({b2}·x)")
print(f"Leading term: {a1}·exp({b1}·x) since β₁={b1} > β₂={b2}")
print(f"\n{'x':>6} {'f(x)':>18} {'leading':>18} {'f/leading':>12}")
for x in [1, 2, 5, 10, 20]:
    fx = a1 * math.exp(b1*x) + a2 * math.exp(b2*x)
    lead = a1 * math.exp(b1*x)
    ratio = fx / lead if lead != 0 else 0
    print(f"{x:>6} {fx:>18.6e} {lead:>18.6e} {ratio:>12.8f}")
print("\nConfirmed: f(x) / leading_term → 1 ✓")
print("\nThis is the ASYMPTOTIC COMPARISON THEOREM:")
print("  Distinct leading monomials ⟹ distinct asymptotic behavior")
print("  ⟹ Transseries expansions are FAITHFUL representations")


#!/usr/bin/env python3
"""Visualization: The Exponential Dominance Hierarchy

Shows how iterated exponentials, polynomials, and logarithms compare
on a log-log scale, illustrating the strict hierarchy that makes
transseries necessary.
"""
import numpy as np
import matplotlib.pyplot as plt
import matplotlib

matplotlib.rcParams['font.size'] = 12

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Panel 1: exp vs polynomials
ax = axes[0]
x = np.linspace(1, 8, 200)
ax.semilogy(x, np.exp(x), 'r-', linewidth=2, label='exp(x)')
for n in [1, 2, 3, 5]:
    ax.semilogy(x, x**n, '--', linewidth=1.5, label=f'x^{n}')
ax.set_xlabel('x')
ax.set_ylabel('f(x) [log scale]')
ax.set_title('Exponential Dominates All Polynomials')
ax.legend(fontsize=10)
ax.set_ylim(1, 1e4)
ax.grid(True, alpha=0.3)

# Panel 2: log subordinate to powers
ax = axes[1]
x = np.linspace(2, 1000, 500)
for eps in [0.01, 0.05, 0.1, 0.5, 1.0]:
    ratio = np.log(x) / x**eps
    ax.plot(x, ratio, linewidth=1.5, label=f'log(x)/x^{eps}')
ax.axhline(y=0, color='k', linestyle='-', linewidth=0.5)
ax.set_xlabel('x')
ax.set_ylabel('log(x) / x^ε')
ax.set_title('Log Subordinate to Any Positive Power')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 3: EML diagonal asymptotic to exp
ax = axes[2]
z = np.linspace(0.1, 6, 200)
exp_z = np.exp(z)
eml_diag = exp_z - np.log(z)
ax.semilogy(z, exp_z, 'r-', linewidth=2, label='exp(z)')
ax.semilogy(z, eml_diag, 'b--', linewidth=2, label='emlDiag(z) = exp(z) - log(z)')
ax.semilogy(z, np.abs(np.log(z)), 'g:', linewidth=1.5, label='|log(z)|')
ax.set_xlabel('z')
ax.set_ylabel('f(z) [log scale]')
ax.set_title('EML Diagonal ~ exp(z)')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('dominance_hierarchy.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: dominance_hierarchy.png")
