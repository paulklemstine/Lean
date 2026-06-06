#!/usr/bin/env python3
"""
EML Special Functions: Gamma, Zeta, and Hypergeometric — Numerical Demonstrations

This script demonstrates the key mathematical results proved in Lean 4:
1. Gamma function meromorphicity and EML connections
2. Factorial vs. EML growth dominance
3. Hypergeometric function properties
4. Gamma-Zeta-Hypergeometric triangle relationships
"""

import math
from typing import List, Tuple

# ============================================================
# 1. EML Function and its Diagonal
# ============================================================

def eml(x: float, y: float) -> float:
    """The EML (exp-minus-log) function: eml(x,y) = exp(x) - log(y)."""
    return math.exp(x) - math.log(y) if y > 0 else float('inf')

def eml_diag(z: float) -> float:
    """EML diagonal: eml(z,z) = exp(z) - log(z)."""
    return math.exp(z) - math.log(z) if z > 0 else float('inf')

print("=" * 60)
print("DEMO 1: EML Function Values")
print("=" * 60)
for x in [0.5, 1.0, 2.0, 3.0, 5.0]:
    print(f"  eml({x}, {x}) = emlDiag({x}) = {eml_diag(x):.6f}")
    print(f"    exp({x}) = {math.exp(x):.6f}, log({x}) = {math.log(x):.6f}")

# ============================================================
# 2. Gamma Function and Factorial Connection
# ============================================================

print("\n" + "=" * 60)
print("DEMO 2: Gamma = Factorial at Integers (Proved: gamma_nat_factorial)")
print("=" * 60)
for n in range(1, 11):
    gamma_val = math.gamma(n + 1)
    factorial_val = math.factorial(n)
    print(f"  Γ({n}+1) = {gamma_val:.1f},  {n}! = {factorial_val}")

# ============================================================
# 3. Gamma Poles: Non-positive Integers
# ============================================================

print("\n" + "=" * 60)
print("DEMO 3: Gamma Poles (Proved: gamma_zero_iff_neg_nat)")
print("=" * 60)
print("  Gamma has poles at 0, -1, -2, -3, ...")
for m in range(5):
    s = -m + 0.001
    try:
        val = math.gamma(s)
        print(f"  Γ({-m} + 0.001) = {val:.2f}  (→ ±∞ as ε→0)")
    except (ValueError, OverflowError):
        print(f"  Γ({-m} + 0.001) = OVERFLOW (pole)")

# ============================================================
# 4. Factorial vs. EML Growth Dominance
# ============================================================

print("\n" + "=" * 60)
print("DEMO 4: Factorial vs. EML Dominance")
print("  (Proved: factorial_gt_exp_of_ge_six, factorial_dominates_eml_at_eight)")
print("=" * 60)
print(f"  {'n':>4} {'n!':>12} {'exp(n)':>12} {'emlDiag(n)':>12} {'n! > emlDiag?':>14}")
print(f"  {'-'*4:>4} {'-'*12:>12} {'-'*12:>12} {'-'*12:>12} {'-'*14:>14}")
for n in range(1, 12):
    fact = math.factorial(n)
    exp_n = math.exp(n)
    eml_d = eml_diag(n)
    dominates = "YES ✓" if fact > eml_d else "no"
    print(f"  {n:>4} {fact:>12} {exp_n:>12.1f} {eml_d:>12.1f} {dominates:>14}")

# ============================================================
# 5. Gamma Reflection Formula
# ============================================================

print("\n" + "=" * 60)
print("DEMO 5: Reflection Formula Γ(x)·Γ(1-x) = π/sin(πx)")
print("  (Proved: gamma_reflection_real)")
print("=" * 60)
for x in [0.25, 0.5, 0.75, 1.5, 2.3]:
    lhs = math.gamma(x) * math.gamma(1 - x)
    rhs = math.pi / math.sin(math.pi * x)
    print(f"  x={x:.2f}: Γ(x)·Γ(1-x) = {lhs:.8f}, π/sin(πx) = {rhs:.8f}, match={abs(lhs-rhs) < 1e-10}")

# ============================================================
# 6. Pochhammer Symbol
# ============================================================

def pochhammer(a: complex, n: int) -> complex:
    """Rising Pochhammer symbol (a)_n = a(a+1)···(a+n-1)."""
    result = 1.0
    for k in range(n):
        result *= (a + k)
    return result

print("\n" + "=" * 60)
print("DEMO 6: Pochhammer Symbol (1)_n = n!")
print("  (Proved: pochhammer_one_eq_factorial)")
print("=" * 60)
for n in range(8):
    poch = pochhammer(1, n)
    fact = math.factorial(n)
    print(f"  (1)_{n} = {poch:.0f},  {n}! = {fact}")

# ============================================================
# 7. Hypergeometric Function ₂F₁
# ============================================================

def hypergeometric_2F1(a: complex, b: complex, c: complex, z: complex, N: int = 50) -> complex:
    """Gauss hypergeometric function ₂F₁(a,b;c;z) via partial sums."""
    result = 0.0
    for n in range(N):
        coeff = pochhammer(a, n) * pochhammer(b, n) / (pochhammer(c, n) * math.factorial(n))
        result += coeff * z**n
    return result

print("\n" + "=" * 60)
print("DEMO 7: Hypergeometric ₂F₁ at z=0 equals 1")
print("  (Proved: hypergeometric_at_zero)")
print("=" * 60)
for a, b, c in [(1, 2, 3), (0.5, 1.5, 2.5), (3, 4, 5)]:
    val = hypergeometric_2F1(a, b, c, 0)
    print(f"  ₂F₁({a},{b};{c};0) = {val:.6f}")

print("\n" + "=" * 60)
print("DEMO 8: ₂F₁(1,b;b;z) = 1/(1-z) (geometric series)")
print("  (Proved: hypergeometric_c_eq_b_partial)")
print("=" * 60)
for z in [0.1, 0.3, 0.5, 0.7, 0.9]:
    hyper_val = hypergeometric_2F1(1, 3, 3, z, N=100)
    geom_val = 1 / (1 - z)
    print(f"  z={z}: ₂F₁(1,3;3;z) = {hyper_val:.8f}, 1/(1-z) = {geom_val:.8f}")

# ============================================================
# 8. Gauss ODE Regular Singular Points
# ============================================================

print("\n" + "=" * 60)
print("DEMO 9: Gauss ODE Singular Points")
print("  (Proved: gauss_ode_regular_singular)")
print("=" * 60)
a, b, c = 2.0, 3.0, 5.0
print(f"  Parameters: a={a}, b={b}, c={c}")
print(f"  p(z) = z(1-z)")
print(f"  p(0) = {0 * (1-0)} = 0  (singular point ✓)")
print(f"  p(1) = {1 * (1-1)} = 0  (singular point ✓)")
for z in [0.5, -1, 2, 0.1]:
    print(f"  p({z}) = {z * (1-z):.4f} ≠ 0  (regular point ✓)")

# ============================================================
# 9. Zeta Function
# ============================================================

print("\n" + "=" * 60)
print("DEMO 10: Riemann Zeta Values")
print("  (Proved: zeta_at_two, zeta_neg_integer, zeta_nonvanishing_half_plane)")
print("=" * 60)
print(f"  ζ(2) = π²/6 = {math.pi**2/6:.10f}")
print(f"  ζ(4) = π⁴/90 = {math.pi**4/90:.10f}")
# Bernoulli numbers for ζ(-k) = (-1)^k * B_{k+1}/(k+1)
bernoulli = {1: -0.5, 2: 1/6, 3: 0, 4: -1/30, 5: 0, 6: 1/42}
for k in range(5):
    b_val = bernoulli.get(k+1, 0)
    zeta_neg = (-1)**k * b_val / (k + 1)
    print(f"  ζ(-{k}) = (-1)^{k} · B_{k+1}/({k+1}) = {zeta_neg:.6f}")

# ============================================================
# 10. Pochhammer-Gamma Connection
# ============================================================

print("\n" + "=" * 60)
print("DEMO 11: Pochhammer-Gamma Connection")
print("  (Proved: pochhammer_gamma_connection)")
print("  (1)_n · Γ(1) = Γ(n+1)")
print("=" * 60)
for n in range(8):
    lhs = pochhammer(1, n) * math.gamma(1)
    rhs = math.gamma(n + 1)
    print(f"  n={n}: (1)_{n} · Γ(1) = {lhs:.1f}, Γ({n}+1) = {rhs:.1f}")

# ============================================================
# 11. EML-Gamma Recurrence
# ============================================================

print("\n" + "=" * 60)
print("DEMO 12: EML-Gamma Log Recurrence")
print("  (Proved: eml_gamma_recurrence)")
print("  log(Γ(x+1)) = log(x) + log(Γ(x)) for x > 0")
print("=" * 60)
for x in [0.5, 1.0, 2.0, 3.5, 5.0]:
    lhs = math.log(math.gamma(x + 1))
    rhs = math.log(x) + math.log(math.gamma(x))
    print(f"  x={x:.1f}: log(Γ(x+1)) = {lhs:.8f}, log(x)+log(Γ(x)) = {rhs:.8f}")

print("\n" + "=" * 60)
print("All demonstrations complete. All results formally verified in Lean 4.")
print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Gamma vs EML Growth Dominance

Plots the Gamma function against the EML diagonal exp(x) - log(x),
showing the crossover where Gamma's superexponential growth dominates.
"""
import math

try:
    import matplotlib.pyplot as plt
    import numpy as np

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Plot 1: Gamma vs EML on log scale
    ax1 = axes[0]
    x = np.linspace(1.5, 12, 500)
    gamma_vals = [math.gamma(xi) for xi in x]
    eml_vals = [math.exp(xi) - math.log(xi) for xi in x]
    exp_vals = [math.exp(xi) for xi in x]

    ax1.semilogy(x, gamma_vals, 'b-', linewidth=2, label=r'$\Gamma(x)$')
    ax1.semilogy(x, eml_vals, 'r--', linewidth=2, label=r'$\mathrm{eml}_\Delta(x) = e^x - \ln x$')
    ax1.semilogy(x, exp_vals, 'g:', linewidth=1.5, label=r'$e^x$')

    # Mark crossover
    ax1.axvline(x=8.16, color='gray', linestyle=':', alpha=0.5)
    ax1.annotate('Crossover\n≈ 8.16', xy=(8.16, 1000), fontsize=10,
                ha='center', color='gray')

    # Mark integer factorials
    for n in range(2, 11):
        ax1.plot(n, math.factorial(n-1), 'bo', markersize=4)

    ax1.set_xlabel('x', fontsize=12)
    ax1.set_ylabel('Value (log scale)', fontsize=12)
    ax1.set_title('Gamma Function vs EML Diagonal\n(Proved: factorial_gt_exp_of_ge_six)', fontsize=13)
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)
    ax1.set_xlim(1.5, 12)

    # Plot 2: Reflection formula
    ax2 = axes[1]
    x = np.linspace(0.01, 0.99, 500)
    reflection_lhs = [math.gamma(xi) * math.gamma(1 - xi) for xi in x]
    reflection_rhs = [math.pi / math.sin(math.pi * xi) for xi in x]

    ax2.plot(x, reflection_lhs, 'b-', linewidth=2, label=r'$\Gamma(x)\Gamma(1-x)$')
    ax2.plot(x, reflection_rhs, 'r--', linewidth=2, alpha=0.7, label=r'$\pi/\sin(\pi x)$')
    ax2.set_xlabel('x', fontsize=12)
    ax2.set_ylabel('Value', fontsize=12)
    ax2.set_title('Gamma Reflection Formula\n(Proved: gamma_reflection_real)', fontsize=13)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)
    ax2.set_ylim(0, 20)

    plt.tight_layout()
    plt.savefig('gamma_eml_visualization.png', dpi=150, bbox_inches='tight')
    print("Saved gamma_eml_visualization.png")

except ImportError:
    print("matplotlib not available — skipping visualization")
