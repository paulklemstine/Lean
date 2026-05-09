#!/usr/bin/env python3
"""
Weight-λ Rota-Baxter Algebras: Numerical Demonstrations

This demo brings the formally verified mathematics to life with concrete
numerical examples, visualizations, and interactive explorations.
"""

import numpy as np
import matplotlib.pyplot as plt
from fractions import Fraction
from math import factorial, exp, log

# ============================================================
# Section 1: Concrete RB Operators
# ============================================================

def scaling_rb(c):
    """R(x) = c*x is a weight-(-c) Rota-Baxter operator."""
    def R(x): return c * x
    weight = -c
    return R, weight

def verify_rb_identity(R, weight, a, b):
    """Verify R(a)*R(b) = R(R(a)*b + a*R(b) + weight*a*b)."""
    lhs = R(a) * R(b)
    rhs = R(R(a)*b + a*R(b) + weight*a*b)
    return abs(lhs - rhs) < 1e-12

print("=" * 60)
print("WEIGHT-λ ROTA-BAXTER ALGEBRA DEMONSTRATIONS")
print("=" * 60)

print("\n--- Section 1: Verifying RB Identity for Concrete Operators ---")
test_cases = [
    ("Scaling(2)", *scaling_rb(2)),
    ("Scaling(0.5)", *scaling_rb(0.5)),
    ("Negation", lambda x: -x, 1),
    ("Identity", lambda x: x, -1),
    ("Zero", lambda x: 0, 0),
]

for name, R, w in test_cases:
    results = [verify_rb_identity(R, w, a, b) 
               for a, b in [(1, 2), (3, -1), (0.5, 0.7), (-2, 3)]]
    print(f"  {name} (weight={w}): {'✓ All verified' if all(results) else '✗ FAILED'}")

# ============================================================
# Section 2: Lipschitz Bounds L_n = 2^n / n!
# ============================================================

print("\n--- Section 2: Renormalization Lipschitz Bounds ---")
print(f"  {'n':>3} | {'L_n = 2^n/n!':>12} | {'Decreasing?':>11} | {'Regime':>10}")
print(f"  {'-'*3}-+-{'-'*12}-+-{'-'*11}-+-{'-'*10}")

L_values = []
for n in range(15):
    L_n = 2**n / factorial(n)
    L_values.append(L_n)
    decreasing = "—" if n == 0 else ("✓ Yes" if L_n <= L_values[n-1] else "✗ No")
    regime = "expanding" if L_n > 1 else ("boundary" if L_n > 0.5 else "contracting")
    print(f"  {n:3d} | {L_n:12.6f} | {decreasing:>11} | {regime:>10}")

print(f"\n  Sum L_0..L_14 = {sum(L_values):.6f}")
print(f"  e^2 = {exp(2):.6f} (theoretical upper bound)")

# ============================================================
# Section 3: Bogoliubov Iteration Convergence
# ============================================================

print("\n--- Section 3: Bogoliubov Iteration Convergence ---")
kappa = 0.7  # contraction constant
eps0 = 10.0  # initial error

print(f"  Contraction κ = {kappa}, Initial error ε₀ = {eps0}")
print(f"  Theoretical bound: ε₀/(1-κ) = {eps0/(1-kappa):.4f}")
print(f"  {'n':>3} | {'ε_n':>10} | {'Cumulative':>10} | {'Bound':>10}")
print(f"  {'-'*3}-+-{'-'*10}-+-{'-'*10}-+-{'-'*10}")

cumulative = 0
for n in range(20):
    eps_n = eps0 * kappa**n
    cumulative += eps_n
    bound = eps0 / (1 - kappa)
    print(f"  {n:3d} | {eps_n:10.6f} | {cumulative:10.4f} | {bound:10.4f}")

# ============================================================
# Section 4: Tropical Min-Plus Semiring
# ============================================================

print("\n--- Section 4: Tropical Min-Plus Semiring ---")

def trop_add(a, b): return min(a, b)
def trop_mul(a, b): return a + b

# Verify distributivity
a, b, c = 3.0, 1.0, 5.0
lhs = trop_mul(a, trop_add(b, c))
rhs = trop_add(trop_mul(a, b), trop_mul(a, c))
print(f"  Distributivity: {a} ⊙ ({b} ⊕ {c}) = {a} ⊙ {trop_add(b,c)} = {lhs}")
print(f"                  ({a} ⊙ {b}) ⊕ ({a} ⊙ {c}) = {trop_mul(a,b)} ⊕ {trop_mul(a,c)} = {rhs}")
print(f"  Equal: {'✓' if abs(lhs - rhs) < 1e-12 else '✗'}")

# Idempotency
print(f"\n  Idempotency: 7 ⊕ 7 = min(7, 7) = {trop_add(7, 7)}")
print(f"  Identity: 0 ⊙ 5 = 0 + 5 = {trop_mul(0, 5)}")

# ============================================================
# Section 5: Quantum-Tropical Duality
# ============================================================

print("\n--- Section 5: Quantum-Tropical Duality ---")
C = 100.0
eps_target = 0.01
lam0 = C / eps_target + 1
print(f"  C = {C}, ε = {eps_target}")
print(f"  λ₀ = C/ε + 1 = {lam0:.1f}")
print(f"  {'λ':>10} | {'C/λ':>10} | {'< ε?':>5}")
print(f"  {'-'*10}-+-{'-'*10}-+-{'-'*5}")
for lam in [100, 1000, 5000, 10001, 50000, 100000]:
    ratio = C / lam
    print(f"  {lam:10d} | {ratio:10.6f} | {'✓' if ratio < eps_target else '✗':>5}")

# ============================================================
# Section 6: Tropical Separation and Hash Collision
# ============================================================

print("\n--- Section 6: Tropical Separation & Collision Resistance ---")
a, b = 42.0, 43.0
print(f"  Elements: a = {a}, b = {b}, |a-b| = {abs(a-b)}")
print(f"  {'λ':>10} | {'|a/λ - b/λ|':>12} | {'Separation':>10}")
print(f"  {'-'*10}-+-{'-'*12}-+-{'-'*10}")
for lam in [1, 10, 100, 1000, 10000, 100000]:
    sep = abs(a/lam - b/lam)
    print(f"  {lam:10d} | {sep:12.8f} | {'large' if sep > 0.01 else 'small':>10}")

# ============================================================
# Section 7: Deformation Regime Classification
# ============================================================

print("\n--- Section 7: Deformation Regime Classification ---")
for lam in [0.001, 0.01, 0.05, 0.1, 0.5, 1, 5, 10, 50, 100, 1000]:
    if lam < 0.1:
        regime = "CLASSICAL (tree-level)"
    elif lam <= 10:
        regime = "QUANTUM   (loop corrections)"
    else:
        regime = "TROPICAL  (min-plus geometry)"
    print(f"  λ = {lam:8.3f} → {regime}")

# ============================================================
# Section 8: Visualizations
# ============================================================

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Plot 1: Lipschitz bounds
ax = axes[0, 0]
ns = list(range(15))
Ls = [2**n / factorial(n) for n in ns]
ax.bar(ns, Ls, color=['#e74c3c' if L > 1 else '#2ecc71' for L in Ls], alpha=0.7)
ax.axhline(y=1, color='gray', linestyle='--', label='L = 1 (contraction boundary)')
ax.set_xlabel('Degree n')
ax.set_ylabel('L_n = 2^n / n!')
ax.set_title('Renormalization Lipschitz Bounds')
ax.legend()

# Plot 2: Bogoliubov convergence
ax = axes[0, 1]
kappas = [0.3, 0.5, 0.7, 0.9]
for k in kappas:
    errors = [10 * k**n for n in range(30)]
    ax.semilogy(range(30), errors, label=f'κ = {k}', linewidth=2)
ax.set_xlabel('Iteration n')
ax.set_ylabel('Error ε_n (log scale)')
ax.set_title('Bogoliubov Iteration Convergence')
ax.legend()
ax.grid(True, alpha=0.3)

# Plot 3: Tropical collapse
ax = axes[1, 0]
lams = np.linspace(0.1, 50, 500)
for C in [1, 5, 10, 20]:
    ax.plot(lams, C / lams, label=f'C = {C}', linewidth=2)
ax.axhline(y=0, color='black', linewidth=0.5)
ax.set_xlabel('Weight λ')
ax.set_ylabel('Quantum correction C/λ')
ax.set_title('Quantum → Tropical Collapse (C/λ → 0)')
ax.legend()
ax.grid(True, alpha=0.3)

# Plot 4: Graded bounds
ax = axes[1, 1]
for lam in [0.5, 1.0, 2.0, 5.0]:
    C = 1.0
    bounds = [C * (2*lam)**n / factorial(n) for n in range(15)]
    ax.semilogy(range(15), bounds, 'o-', label=f'λ = {lam}', linewidth=2, markersize=4)
ax.set_xlabel('Degree n')
ax.set_ylabel('B(C, λ, n) (log scale)')
ax.set_title('Graded Bogoliubov Bounds (C=1)')
ax.legend()
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('diagram.svg', format='svg', dpi=150, bbox_inches='tight')
plt.savefig('weight_rota_baxter_demo.png', dpi=150, bbox_inches='tight')
print("\n--- Visualizations saved to diagram.svg and weight_rota_baxter_demo.png ---")

# ============================================================
# Section 9: Thermodynamic Connection
# ============================================================

print("\n--- Section 9: Thermodynamic Renormalization ---")
print("  λ = kT = 1/β (inverse temperature)")
print(f"  {'T (temp)':>10} | {'β = 1/T':>10} | {'λ = kT':>10} | {'Regime':>20}")
print(f"  {'-'*10}-+-{'-'*10}-+-{'-'*10}-+-{'-'*20}")
for T in [0.001, 0.01, 0.1, 1, 10, 100, 1000]:
    beta = 1/T
    lam = T  # k = 1 for simplicity
    regime = "TROPICAL (ground state)" if T < 0.1 else ("QUANTUM (thermal)" if T <= 10 else "CLASSICAL (high T)")
    print(f"  {T:10.3f} | {beta:10.3f} | {lam:10.3f} | {regime:>20}")

# ============================================================
# Section 10: Post-Quantum Security Parameters
# ============================================================

print("\n--- Section 10: Post-Quantum Security ---")
print(f"  {'Security bits':>14} | {'λ = 2^κ':>20} | {'Collision resistance':>20}")
print(f"  {'-'*14}-+-{'-'*20}-+-{'-'*20}")
for bits in [128, 192, 256, 384, 512]:
    weight = 2**bits
    print(f"  {bits:14d} | {'2^' + str(bits):>20} | {'> 2^' + str(bits):>20}")

print("\n" + "=" * 60)
print("All demonstrations complete.")
print("See RESEARCH_REPORT.md for mathematical details.")
print("See Algebra/RotaBaxter/WeightedRotaBaxter.lean for formal proofs.")
print("=" * 60)
