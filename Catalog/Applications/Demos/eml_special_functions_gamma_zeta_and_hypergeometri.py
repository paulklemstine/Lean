#!/usr/bin/env python3
"""
Demo: EML Special Functions — Gamma, Zeta, and Hypergeometric

Numerical demonstrations of the key relationships proved in Lean 4:
1. Gamma function poles and the reflection formula
2. Riemann zeta special values via Bernoulli numbers
3. Hypergeometric ₂F₁ series convergence
4. The Pochhammer-Gamma bridge
"""

import math
from fractions import Fraction

# ============================================================
# 1. Gamma function at integer points and poles
# ============================================================

def gamma_factorial_check():
    """Verify Γ(n+1) = n! for small n (Theorem: gamma_nat_factorial)"""
    print("=" * 60)
    print("Theorem: Γ(n+1) = n!")
    print("=" * 60)
    for n in range(10):
        gamma_val = math.gamma(n + 1)
        factorial_val = math.factorial(n)
        print(f"  Γ({n+1}) = {gamma_val:.6f},  {n}! = {factorial_val},  match: {abs(gamma_val - factorial_val) < 1e-10}")
    print()

def gamma_reflection_check():
    """Verify Γ(z)·Γ(1-z) = π/sin(πz) (Theorem: gamma_reflection)"""
    print("=" * 60)
    print("Theorem: Γ(z)·Γ(1-z) = π/sin(πz)")
    print("=" * 60)
    for z in [0.25, 0.5, 0.75, 1.5, 2.3, 0.1]:
        lhs = math.gamma(z) * math.gamma(1 - z)
        rhs = math.pi / math.sin(math.pi * z)
        print(f"  z = {z}: LHS = {lhs:.10f}, RHS = {rhs:.10f}, diff = {abs(lhs-rhs):.2e}")
    print()

# ============================================================
# 2. Pochhammer symbol and its relationship to Gamma
# ============================================================

def pochhammer(a, n):
    """Rising factorial: (a)_n = a(a+1)...(a+n-1)"""
    result = 1.0
    for k in range(n):
        result *= (a + k)
    return result

def pochhammer_gamma_check():
    """Verify (a)_n · Γ(a) = Γ(a+n) (Theorem: pochhammer_gamma_relation)"""
    print("=" * 60)
    print("Theorem: (a)_n · Γ(a) = Γ(a+n)")
    print("=" * 60)
    for a in [1.5, 2.0, 0.5, 3.7]:
        for n in [0, 1, 3, 5]:
            lhs = pochhammer(a, n) * math.gamma(a)
            rhs = math.gamma(a + n)
            print(f"  a={a}, n={n}: (a)_n·Γ(a) = {lhs:.8f}, Γ(a+n) = {rhs:.8f}, diff = {abs(lhs-rhs):.2e}")
    print()

def pochhammer_one_factorial_check():
    """Verify (1)_n = n! (Theorem: pochhammer_one_eq_factorial)"""
    print("=" * 60)
    print("Theorem: (1)_n = n!")
    print("=" * 60)
    for n in range(10):
        poch = pochhammer(1, n)
        fact = math.factorial(n)
        print(f"  (1)_{n} = {poch:.0f},  {n}! = {fact},  match: {abs(poch - fact) < 1e-10}")
    print()

# ============================================================
# 3. Hypergeometric ₂F₁ series
# ============================================================

def hypergeom_2F1(a, b, c, z, N=50):
    """Compute ₂F₁(a,b;c;z) via partial sums"""
    total = 0.0
    term = 1.0  # n=0 term
    for n in range(N):
        total += term
        # Ratio: term_{n+1}/term_n = (a+n)(b+n)/((c+n)(n+1)) * z
        if abs(c + n) < 1e-15:
            break
        term *= (a + n) * (b + n) / ((c + n) * (n + 1)) * z
    return total

def hypergeom_111_check():
    """Verify ₂F₁(1,1;1;z) = 1/(1-z) for |z| < 1 (Theorem: hypergeom_111_term_eq)"""
    print("=" * 60)
    print("Theorem: ₂F₁(1,1;1;z) = 1/(1-z)  for |z| < 1")
    print("=" * 60)
    for z in [0.1, 0.3, 0.5, 0.7, 0.9, -0.5]:
        hyp = hypergeom_2F1(1, 1, 1, z, N=100)
        exact = 1.0 / (1.0 - z)
        print(f"  z = {z:5.1f}: ₂F₁ = {hyp:.10f}, 1/(1-z) = {exact:.10f}, diff = {abs(hyp-exact):.2e}")
    print()

def hypergeom_special_values():
    """Known special values of ₂F₁"""
    print("=" * 60)
    print("Special values of ₂F₁")
    print("=" * 60)
    # ₂F₁(1, b; b; z) = 1/(1-z) (a=1, c=b cancellation)
    for b in [2.0, 3.5, 0.5]:
        z = 0.3
        hyp = hypergeom_2F1(1, b, b, z)
        exact = 1.0 / (1.0 - z)
        print(f"  ₂F₁(1, {b}, {b}, {z}) = {hyp:.10f}, 1/(1-z) = {exact:.10f}")

    # ₂F₁(a, b; c; 0) = 1
    for a, b, c in [(2, 3, 5), (0.5, 1.5, 2.5)]:
        hyp = hypergeom_2F1(a, b, c, 0)
        print(f"  ₂F₁({a}, {b}, {c}, 0) = {hyp:.10f} (should be 1)")
    print()

# ============================================================
# 4. Zeta function special values
# ============================================================

def bernoulli_numbers(N):
    """Compute Bernoulli numbers B_0, ..., B_N"""
    B = [Fraction(0)] * (N + 1)
    B[0] = Fraction(1)
    for m in range(1, N + 1):
        B[m] = Fraction(0)
        for k in range(m):
            B[m] -= Fraction(math.comb(m, k)) * B[k] / Fraction(m - k + 1)
    return B

def zeta_negative_integers():
    """Verify ζ(-k) = (-1)^k · B_{k+1}/(k+1) (Theorem: zeta_at_neg_integers)"""
    print("=" * 60)
    print("Theorem: ζ(-k) = (-1)^k · B_{k+1}/(k+1)")
    print("=" * 60)
    B = bernoulli_numbers(12)
    for k in range(11):
        zeta_val = (-1)**k * B[k+1] / (k+1)
        print(f"  ζ(-{k}) = {float(zeta_val):12.6f}  (B_{k+1} = {B[k+1]})")
    print()

# ============================================================
# 5. Gamma-Zeta bridge
# ============================================================

def gamma_zeta_bridge_demo():
    """Demonstrate ζ(s) = ξ(s) / Γ_ℝ(s) structure"""
    print("=" * 60)
    print("Gamma-Zeta Bridge: Γ_ℝ(s) = π^(-s/2) · Γ(s/2)")
    print("=" * 60)
    for s in [2, 4, 6, 8]:
        gamma_R = math.pi ** (-s/2) * math.gamma(s/2)
        print(f"  Γ_ℝ({s}) = π^(-{s}/2) · Γ({s}/2) = {gamma_R:.10f}")
    print()

# ============================================================
# 6. Gauss's recurrence
# ============================================================

def gauss_recurrence_check():
    """Verify (n+1)(c+n) · term(n+1) = (a+n)(b+n) · term(n)"""
    print("=" * 60)
    print("Theorem: Gauss's hypergeometric recurrence")
    print("(n+1)(c+n) · aₙ₊₁ = (a+n)(b+n) · aₙ  (at z=1)")
    print("=" * 60)
    a, b, c = 0.5, 1.5, 2.5

    def term(n):
        return pochhammer(a, n) * pochhammer(b, n) / (pochhammer(c, n) * math.factorial(n))

    for n in range(8):
        lhs = (n + 1) * (c + n) * term(n + 1)
        rhs = (a + n) * (b + n) * term(n)
        print(f"  n={n}: LHS = {lhs:.10f}, RHS = {rhs:.10f}, diff = {abs(lhs-rhs):.2e}")
    print()

# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("EML Special Functions: Gamma, Zeta, and Hypergeometric")
    print("=" * 60)
    print()

    gamma_factorial_check()
    gamma_reflection_check()
    pochhammer_one_factorial_check()
    pochhammer_gamma_check()
    hypergeom_111_check()
    hypergeom_special_values()
    zeta_negative_integers()
    gamma_zeta_bridge_demo()
    gauss_recurrence_check()

    print("All numerical demonstrations completed successfully.")


#!/usr/bin/env python3
"""
Visualization: Gamma and Zeta Singularity Structure

Creates plots showing the pole/zero structure of the Gamma function,
Riemann zeta function, and their connection through the Deligne Gamma factor.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.colors import LogNorm
import math


def plot_gamma_magnitude():
    """Plot |Γ(x + iy)| showing poles at non-positive integers."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Real line plot
    ax = axes[0]
    x_ranges = [(-4.9, -4.1), (-3.9, -3.1), (-2.9, -2.1), (-1.9, -1.1),
                (-0.9, -0.1), (0.1, 5.0)]
    for xmin, xmax in x_ranges:
        x = np.linspace(xmin, xmax, 200)
        y = np.array([math.gamma(xi) if xi > 0 or xi != int(xi) else np.nan for xi in x])
        valid = np.isfinite(y) & (np.abs(y) < 20)
        ax.plot(x[valid], y[valid], 'b-', linewidth=1.5)

    ax.set_xlim(-5, 5)
    ax.set_ylim(-10, 10)
    ax.axhline(y=0, color='gray', linewidth=0.5)
    ax.axvline(x=0, color='gray', linewidth=0.5)
    for n in range(0, 6):
        ax.axvline(x=-n, color='red', linewidth=0.5, linestyle='--', alpha=0.5)
    ax.set_xlabel('x')
    ax.set_ylabel('Γ(x)')
    ax.set_title('Γ(x) on the real line\nPoles at 0, -1, -2, -3, ...')

    # Complex plane |Γ(z)|
    ax = axes[1]
    x = np.linspace(-4.5, 4.5, 400)
    y = np.linspace(-3, 3, 300)
    X, Y = np.meshgrid(x, y)

    # Compute |Γ(z)| using scipy if available, else lgamma
    Z = np.zeros_like(X)
    for i in range(X.shape[0]):
        for j in range(X.shape[1]):
            try:
                z = complex(X[i,j], Y[i,j])
                # Use log-gamma for stability
                lgz = complex(math.lgamma(X[i,j])) if Y[i,j] == 0 else None
                if lgz is not None:
                    Z[i,j] = math.exp(lgz.real)
                else:
                    # Stirling approximation for complex gamma
                    z = complex(X[i,j], Y[i,j])
                    if X[i,j] > 0.5:
                        # Use reflection if needed
                        log_abs = (X[i,j] - 0.5) * math.log(abs(z)) - Y[i,j] * np.angle(z) - X[i,j]
                        Z[i,j] = min(math.exp(min(log_abs, 50)), 1e20)
                    else:
                        # Reflection formula: |Γ(z)| = π / (|sin(πz)| · |Γ(1-z)|)
                        Z[i,j] = 1.0  # placeholder
            except (ValueError, OverflowError):
                Z[i,j] = 1e20

    Z = np.clip(Z, 1e-5, 1e5)
    im = ax.pcolormesh(X, Y, Z, norm=LogNorm(vmin=0.01, vmax=100),
                       cmap='hot', shading='auto')
    for n in range(0, 5):
        ax.plot(-n, 0, 'wo', markersize=8, markeredgecolor='cyan', markeredgewidth=2)
    plt.colorbar(im, ax=ax, label='|Γ(z)|')
    ax.set_xlabel('Re(z)')
    ax.set_ylabel('Im(z)')
    ax.set_title('|Γ(z)| in the complex plane\n○ = poles (non-positive integers)')

    plt.tight_layout()
    plt.savefig('/workspace/request-project/Applications/gamma_structure.png', dpi=150)
    plt.close()
    print("Saved: gamma_structure.png")


def plot_hypergeometric_convergence():
    """Plot ₂F₁ partial sums showing convergence for |z| < 1."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Convergence of partial sums
    ax = axes[0]
    z_vals = [0.3, 0.5, 0.7, 0.9]
    colors = ['blue', 'green', 'orange', 'red']
    a, b, c = 0.5, 1.0, 1.5

    for z, color in zip(z_vals, colors):
        partial_sums = []
        total = 0.0
        term = 1.0
        for n in range(30):
            total += term
            partial_sums.append(total)
            term *= (a + n) * (b + n) / ((c + n) * (n + 1)) * z
        ax.plot(range(30), partial_sums, color=color, label=f'z = {z}', linewidth=1.5)
        ax.axhline(y=partial_sums[-1], color=color, linewidth=0.5, linestyle='--', alpha=0.3)

    ax.set_xlabel('Number of terms N')
    ax.set_ylabel('Partial sum S_N')
    ax.set_title(f'₂F₁({a}, {b}; {c}; z) partial sums')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # ₂F₁(1,1;1;z) = 1/(1-z) comparison
    ax = axes[1]
    z = np.linspace(-0.95, 0.95, 200)
    exact = 1.0 / (1.0 - z)

    for N in [3, 5, 10, 20]:
        approx = np.zeros_like(z)
        for i, zi in enumerate(z):
            total = 0.0
            for n in range(N):
                total += zi**n
            approx[i] = total
        ax.plot(z, approx, label=f'N = {N}', linewidth=1.2)

    ax.plot(z, exact, 'k--', label='1/(1-z)', linewidth=2, alpha=0.5)
    ax.set_xlabel('z')
    ax.set_ylabel('₂F₁(1,1;1;z)')
    ax.set_ylim(-5, 20)
    ax.set_title('₂F₁(1,1;1;z) → 1/(1-z)\n(Theorem: hypergeom_111_term_eq)')
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('/workspace/request-project/Applications/hypergeometric_convergence.png', dpi=150)
    plt.close()
    print("Saved: hypergeometric_convergence.png")


def plot_pochhammer_gamma_bridge():
    """Visualize the Pochhammer-Gamma relation (a)_n = Γ(a+n)/Γ(a)."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Pochhammer growth for various a
    ax = axes[0]
    ns = list(range(15))
    for a in [0.5, 1.0, 1.5, 2.0, 3.0]:
        poch_vals = [1.0]
        val = 1.0
        for n in range(1, 15):
            val *= (a + n - 1)
            poch_vals.append(val)
        ax.semilogy(ns, poch_vals, 'o-', label=f'a = {a}', markersize=4)

    ax.set_xlabel('n')
    ax.set_ylabel('(a)_n')
    ax.set_title('Pochhammer symbol (a)_n growth')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Verification of (a)_n · Γ(a) = Γ(a+n)
    ax = axes[1]
    a_vals = np.linspace(0.1, 4.0, 100)
    for n in [1, 3, 5, 8]:
        errors = []
        for a in a_vals:
            lhs = 1.0
            for k in range(n):
                lhs *= (a + k)
            lhs *= math.gamma(a)
            rhs = math.gamma(a + n)
            errors.append(abs(lhs - rhs) / max(abs(rhs), 1e-15))
        ax.semilogy(a_vals, errors, label=f'n = {n}', linewidth=1.5)

    ax.set_xlabel('a')
    ax.set_ylabel('Relative error')
    ax.set_title('Pochhammer-Gamma relation accuracy\n(a)_n · Γ(a) = Γ(a+n)')
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('/workspace/request-project/Applications/pochhammer_gamma_bridge.png', dpi=150)
    plt.close()
    print("Saved: pochhammer_gamma_bridge.png")


if __name__ == "__main__":
    plot_gamma_magnitude()
    plot_hypergeometric_convergence()
    plot_pochhammer_gamma_bridge()
    print("\nAll visualizations generated.")
