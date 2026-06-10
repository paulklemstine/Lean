#!/usr/bin/env python3
"""
demo.py — Numerical demonstrations of EML Special Functions results.

Demonstrates:
1. Hypergeometric coefficient computation and recurrence verification
2. The Gauss ODE coefficient identity
3. The EML-Hypergeometric Bridge: 2F1(1,1;2;-z) = log(1+z)/z
4. Pochhammer-Gamma connection
5. Operator factorization verification
"""

import math
from typing import Tuple

def pochhammer(a: float, n: int) -> float:
    """Rising factorial (a)_n = a(a+1)...(a+n-1)."""
    result = 1.0
    for k in range(n):
        result *= (a + k)
    return result

def hypergeom_coeff(a: float, b: float, c: float, n: int) -> float:
    """Coefficient of z^n in 2F1(a,b;c;z)."""
    return pochhammer(a, n) * pochhammer(b, n) / (pochhammer(c, n) * math.factorial(n))

def hypergeom_partial_sum(a: float, b: float, c: float, z: float, N: int) -> float:
    """Partial sum of the hypergeometric series."""
    total = 0.0
    coeff = 1.0
    z_power = 1.0
    for k in range(N):
        total += coeff * z_power
        if k < N - 1:
            coeff *= (a + k) * (b + k) / ((c + k) * (k + 1))
            z_power *= z
    return total

def gauss_lhs(c: float, f, n: int) -> float:
    """θ(θ+c-1) operator action on coefficient sequence f at index n."""
    return n * (n + c - 1) * f(n)

def gauss_rhs(a: float, b: float, f, n: int) -> float:
    """z·(θ+a)(θ+b) operator action on coefficient sequence f at index n."""
    if n == 0:
        return 0.0
    return (n - 1 + a) * (n - 1 + b) * f(n - 1)


def demo_1_coefficient_recurrence():
    """Verify the hypergeometric coefficient recurrence."""
    print("=" * 60)
    print("Demo 1: Hypergeometric Coefficient Recurrence")
    print("=" * 60)
    a, b, c = 2.0, 3.0, 5.0
    print(f"Parameters: a={a}, b={b}, c={c}")
    print(f"{'n':>3} {'coeff(n)':>15} {'ratio':>15} {'predicted':>15}")
    print("-" * 52)
    for n in range(8):
        cn = hypergeom_coeff(a, b, c, n)
        if n > 0:
            ratio = cn / hypergeom_coeff(a, b, c, n - 1)
            predicted = (a + n - 1) * (b + n - 1) / ((c + n - 1) * n)
            print(f"{n:3d} {cn:15.8f} {ratio:15.8f} {predicted:15.8f}")
        else:
            print(f"{n:3d} {cn:15.8f}")
    print()


def demo_2_gauss_ode_identity():
    """Verify the Gauss ODE coefficient identity."""
    print("=" * 60)
    print("Demo 2: Gauss ODE Coefficient Identity")
    print("  (n+1)(n+c) · a_{n+1} = (n+a)(n+b) · a_n")
    print("=" * 60)
    a, b, c = 1.5, 2.5, 4.0
    f = lambda n: hypergeom_coeff(a, b, c, n)
    print(f"Parameters: a={a}, b={b}, c={c}")
    print(f"{'n':>3} {'LHS':>18} {'RHS':>18} {'diff':>12}")
    print("-" * 55)
    for n in range(10):
        lhs = (n + 1) * (n + c) * f(n + 1)
        rhs = (n + a) * (n + b) * f(n)
        diff = abs(lhs - rhs)
        print(f"{n:3d} {lhs:18.12f} {rhs:18.12f} {diff:12.2e}")
    print()


def demo_3_operator_factorization():
    """Verify the operator factorization θ(θ+c-1) = z·(θ+a)(θ+b)."""
    print("=" * 60)
    print("Demo 3: Operator Factorization")
    print("  gaussLHS(c).act(coeff)(n) == gaussRHS(a,b).act(coeff)(n)")
    print("=" * 60)
    a, b, c = 0.7, 1.3, 2.1
    f = lambda n: hypergeom_coeff(a, b, c, n)
    print(f"Parameters: a={a}, b={b}, c={c}")
    print(f"{'n':>3} {'LHS θ(θ+c-1)':>18} {'RHS z(θ+a)(θ+b)':>18} {'diff':>12}")
    print("-" * 55)
    for n in range(1, 12):
        lhs = gauss_lhs(c, f, n)
        rhs = gauss_rhs(a, b, f, n)
        diff = abs(lhs - rhs)
        print(f"{n:3d} {lhs:18.12f} {rhs:18.12f} {diff:12.2e}")
    print()


def demo_4_eml_hypergeometric_bridge():
    """Verify 2F1(1,1;2;-z) = log(1+z)/z."""
    print("=" * 60)
    print("Demo 4: EML-Hypergeometric Bridge")
    print("  2F1(1,1;2;-z) ≈ log(1+z)/z")
    print("=" * 60)
    N = 50
    test_points = [0.1, 0.3, 0.5, 0.7, 0.9, 0.99]
    print(f"Using N={N} terms")
    print(f"{'z':>6} {'2F1(1,1;2;-z)':>18} {'log(1+z)/z':>18} {'diff':>12}")
    print("-" * 58)
    for z in test_points:
        hyper = hypergeom_partial_sum(1, 1, 2, -z, N)
        exact = math.log(1 + z) / z if z != 0 else 1.0
        diff = abs(hyper - exact)
        print(f"{z:6.2f} {hyper:18.12f} {exact:18.12f} {diff:12.2e}")
    print()


def demo_5_pochhammer_gamma():
    """Verify (a)_n = Gamma(a+n) / Gamma(a)."""
    print("=" * 60)
    print("Demo 5: Pochhammer-Gamma Connection")
    print("  (a)_n = Γ(a+n) / Γ(a)")
    print("=" * 60)
    test_cases = [(1.5, 5), (2.0, 4), (0.5, 6), (3.7, 3)]
    print(f"{'a':>6} {'n':>3} {'(a)_n':>18} {'Γ(a+n)/Γ(a)':>18} {'diff':>12}")
    print("-" * 61)
    for a, n in test_cases:
        poch = pochhammer(a, n)
        gamma_ratio = math.gamma(a + n) / math.gamma(a)
        diff = abs(poch - gamma_ratio)
        print(f"{a:6.1f} {n:3d} {poch:18.8f} {gamma_ratio:18.8f} {diff:12.2e}")
    print()


def demo_6_hypergeom_coeff_special_case():
    """Verify hypergeomCoeff(1,1,2,n) = 1/(n+1)."""
    print("=" * 60)
    print("Demo 6: Special Case 2F1(1,1;2;z) Coefficients")
    print("  coeff(n) = 1/(n+1)")
    print("=" * 60)
    print(f"{'n':>3} {'coeff(n)':>18} {'1/(n+1)':>18} {'diff':>12}")
    print("-" * 55)
    for n in range(12):
        cn = hypergeom_coeff(1, 1, 2, n)
        exact = 1.0 / (n + 1)
        diff = abs(cn - exact)
        print(f"{n:3d} {cn:18.12f} {exact:18.12f} {diff:12.2e}")
    print()


def demo_7_gamma_factorial():
    """Verify Γ(n) = (n-1)! for positive integers."""
    print("=" * 60)
    print("Demo 7: Gamma at Positive Integers")
    print("  Γ(n) = (n-1)!")
    print("=" * 60)
    print(f"{'n':>3} {'Γ(n)':>18} {'(n-1)!':>18} {'diff':>12}")
    print("-" * 55)
    for n in range(1, 12):
        gamma_n = math.gamma(n)
        factorial_n = math.factorial(n - 1)
        diff = abs(gamma_n - factorial_n)
        print(f"{n:3d} {gamma_n:18.8f} {factorial_n:18.8f} {diff:12.2e}")
    print()


if __name__ == "__main__":
    demo_1_coefficient_recurrence()
    demo_2_gauss_ode_identity()
    demo_3_operator_factorization()
    demo_4_eml_hypergeometric_bridge()
    demo_5_pochhammer_gamma()
    demo_6_hypergeom_coeff_special_case()
    demo_7_gamma_factorial()
    
    print("\n" + "=" * 60)
    print("All demonstrations completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""Visualization: Hypergeometric series convergence and the EML bridge."""

import math

def pochhammer(a, n):
    result = 1.0
    for k in range(n):
        result *= (a + k)
    return result

def hypergeom_coeff(a, b, c, n):
    return pochhammer(a, n) * pochhammer(b, n) / (pochhammer(c, n) * math.factorial(n))

def hypergeom_partial_sum(a, b, c, z, N):
    total = 0.0
    coeff = 1.0
    z_power = 1.0
    for k in range(N):
        total += coeff * z_power
        coeff *= (a + k) * (b + k) / ((c + k) * (k + 1))
        z_power *= z
    return total

try:
    import matplotlib.pyplot as plt
    import numpy as np

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    # Plot 1: Hypergeometric coefficient decay
    ax = axes[0, 0]
    params = [(1, 1, 2), (2, 3, 5), (0.5, 0.5, 1)]
    for a, b, c in params:
        ns = range(20)
        coeffs = [abs(hypergeom_coeff(a, b, c, n)) for n in ns]
        ax.semilogy(list(ns), coeffs, 'o-', label=f'({a},{b};{c})', markersize=4)
    ax.set_xlabel('n')
    ax.set_ylabel('|coefficient|')
    ax.set_title('Hypergeometric Coefficient Decay')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Plot 2: EML Bridge - 2F1(1,1;2;-z) vs log(1+z)/z
    ax = axes[0, 1]
    zs = np.linspace(0.01, 0.99, 100)
    for N in [3, 5, 10, 50]:
        vals = [hypergeom_partial_sum(1, 1, 2, -z, N) for z in zs]
        ax.plot(zs, vals, label=f'N={N}')
    exact = [math.log(1 + z) / z for z in zs]
    ax.plot(zs, exact, 'k--', linewidth=2, label='log(1+z)/z')
    ax.set_xlabel('z')
    ax.set_ylabel('value')
    ax.set_title('EML Bridge: ₂F₁(1,1;2;-z) → log(1+z)/z')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Plot 3: Operator factorization error
    ax = axes[1, 0]
    params_check = [(1.5, 2.5, 4), (0.7, 1.3, 2.1), (3, 2, 7)]
    for a, b, c in params_check:
        f = lambda n, a=a, b=b, c=c: hypergeom_coeff(a, b, c, n)
        ns = range(1, 15)
        errors = []
        for n in ns:
            lhs = n * (n + c - 1) * f(n)
            rhs = (n - 1 + a) * (n - 1 + b) * f(n - 1)
            errors.append(abs(lhs - rhs) + 1e-20)
        ax.semilogy(list(ns), errors, 'o-', label=f'({a},{b};{c})', markersize=4)
    ax.set_xlabel('n')
    ax.set_ylabel('|LHS - RHS|')
    ax.set_title('Operator Factorization Error (≈ machine epsilon)')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Plot 4: Pochhammer-Gamma connection
    ax = axes[1, 1]
    test_as = [0.5, 1.5, 2.5, 3.5]
    for a in test_as:
        ns = range(1, 10)
        poch_vals = [pochhammer(a, n) for n in ns]
        gamma_vals = [math.gamma(a + n) / math.gamma(a) for n in ns]
        ax.plot(list(ns), poch_vals, 'o', label=f'(a={a})_n', markersize=6)
        ax.plot(list(ns), gamma_vals, 'x', markersize=8)
    ax.set_xlabel('n')
    ax.set_ylabel('value')
    ax.set_title('Pochhammer vs Γ(a+n)/Γ(a)')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_hypergeometric.png', dpi=150)
    print("Saved viz_hypergeometric.png")

except ImportError:
    print("matplotlib not available; skipping visualization")
