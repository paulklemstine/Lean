#!/usr/bin/env python3
"""
EML-KA Decomposition Demo

Demonstrates the key results from the EML-Kolmogorov-Arnold representation theory:
1. Monomial decomposition: x^a * y^b = exp(a*log(x) + b*log(y))
2. Polynomial decomposition
3. AM-GM inequality via EML
4. Fenchel-Young duality
5. Universality conjecture test (sin(xy) approximation)
"""

import math
from algorithms import (
    EMLKADecomp, EMLChain, EMLChainOp, OpType,
    monomial_emlka, polynomial_emlka, mul_emlka, div_emlka,
    verify_monomial_decomp, am_gm_check, fenchel_young_check,
    scaled_log_chain, exp_chain,
)


def demo_multiplication():
    """Demo: x*y = exp(log(x) + log(y))"""
    print("=" * 60)
    print("DEMO 1: Multiplication via EML-KA")
    print("=" * 60)
    print()
    print("Identity: x·y = exp(log(x) + log(y))")
    print("This is a 1-term, depth-2 EML-KA decomposition.")
    print()

    d = mul_emlka()
    print(f"Decomposition: Q={d.Q} term(s), max depth={d.max_depth()}")
    print()

    test_pairs = [(2, 3), (0.5, 4), (math.pi, math.e), (100, 0.01)]
    print(f"{'x':>10} {'y':>10} {'x*y':>15} {'EML-KA':>15} {'Error':>12}")
    print("-" * 62)
    for x, y in test_pairs:
        exact = x * y
        approx = d.eval(x, y)
        error = abs(approx - exact)
        print(f"{x:10.4f} {y:10.4f} {exact:15.8f} {approx:15.8f} {error:12.2e}")
    print()


def demo_monomials():
    """Demo: x^a * y^b decomposition"""
    print("=" * 60)
    print("DEMO 2: Monomial Decomposition (Depth Independence)")
    print("=" * 60)
    print()
    print("Every monomial x^a·y^b has a 1-term, depth-3 EML-KA decomposition.")
    print("The depth is INDEPENDENT of a and b!")
    print()

    monomials = [(1, 1), (2, 0), (0, 3), (3, 2), (10, 10), (100, 200)]
    x, y = 1.5, 2.0

    print(f"Test point: (x, y) = ({x}, {y})")
    print()
    print(f"{'Monomial':>15} {'Exact':>18} {'EML-KA':>18} {'Depth':>6} {'Error':>12}")
    print("-" * 72)

    for a, b in monomials:
        d = monomial_emlka(a, b)
        exact = x**a * y**b
        approx = d.eval(x, y)
        depth = d.max_depth()
        error = abs(approx - exact) / max(abs(exact), 1e-300)
        print(f"x^{a}·y^{b:>3}     {exact:18.6f} {approx:18.6f} {depth:6d} {error:12.2e}")
    print()


def demo_polynomial():
    """Demo: polynomial decomposition"""
    print("=" * 60)
    print("DEMO 3: Polynomial Decomposition")
    print("=" * 60)
    print()

    # p(x,y) = 3x²y + 2xy² - x³ + 5y
    coeffs = [3.0, 2.0, -1.0, 5.0]
    exps_a = [2, 1, 3, 0]
    exps_b = [1, 2, 0, 1]

    def target(x: float, y: float) -> float:
        return 3*x**2*y + 2*x*y**2 - x**3 + 5*y

    d = polynomial_emlka(coeffs, exps_a, exps_b)
    print(f"p(x,y) = 3x²y + 2xy² - x³ + 5y")
    print(f"EML-KA terms: {d.Q}, max depth: {d.max_depth()}")
    print()

    test_points = [(1, 1), (2, 3), (0.5, 1.5), (3, 0.5), (1.5, 2.5)]
    print(f"{'(x, y)':>12} {'Exact':>15} {'EML-KA':>15} {'Rel Error':>12}")
    print("-" * 55)
    for x, y in test_points:
        exact = target(x, y)
        approx = d.eval(x, y)
        rel_err = abs(approx - exact) / max(abs(exact), 1e-15)
        print(f"({x:4.1f}, {y:4.1f}) {exact:15.6f} {approx:15.6f} {rel_err:12.2e}")
    print()


def demo_am_gm():
    """Demo: AM-GM inequality via EML"""
    print("=" * 60)
    print("DEMO 4: AM-GM Inequality via EML-KA")
    print("=" * 60)
    print()
    print("exp((log x + log y)/2) ≤ (x + y)/2")
    print("i.e., geometric mean ≤ arithmetic mean")
    print()

    test_pairs = [
        (1, 1), (1, 4), (4, 16), (0.01, 100),
        (math.e, math.pi), (0.001, 1000),
    ]

    print(f"{'(x, y)':>18} {'GM':>12} {'AM':>12} {'Gap':>12} {'Valid':>6}")
    print("-" * 62)
    for x, y in test_pairs:
        gm, am, ok = am_gm_check(x, y)
        gap = am - gm
        status = "✓" if ok else "✗"
        print(f"({x:8.4f},{y:8.4f}) {gm:12.6f} {am:12.6f} {gap:12.6f}   {status}")
    print()
    print("The gap = (√x - √y)² / 2, which is zero iff x = y.")
    print()


def demo_fenchel_young():
    """Demo: Fenchel-Young inequality"""
    print("=" * 60)
    print("DEMO 5: Fenchel-Young Inequality")
    print("=" * 60)
    print()
    print("x·s ≤ exp(x) + s·log(s) - s  for all x ∈ ℝ, s > 0")
    print("Equality at x = log(s).")
    print()

    test_cases = [
        (0, 1), (1, 1), (0, math.e), (math.log(2), 2),
        (-1, 0.5), (2, 3), (-3, 0.1),
    ]

    print(f"{'x':>8} {'s':>8} {'x·s':>12} {'RHS':>12} {'Gap':>12} {'Tight?':>8}")
    print("-" * 62)
    for x, s in test_cases:
        lhs, rhs, ok = fenchel_young_check(x, s)
        gap = rhs - lhs
        tight = "≈ yes" if gap < 1e-10 else "no"
        print(f"{x:8.4f} {s:8.4f} {lhs:12.6f} {rhs:12.6f} {gap:12.6f} {tight:>8}")
    print()


def demo_universality_test():
    """Demo: Test universality conjecture for sin(xy)"""
    print("=" * 60)
    print("DEMO 6: Universality Conjecture Test — sin(x·y)")
    print("=" * 60)
    print()
    print("Can sin(xy) be approximated by EML-KA on [1,2]²?")
    print("Using Taylor series: sin(t) ≈ t - t³/6 + t⁵/120 - t⁷/5040")
    print("where t = xy = exp(log(x) + log(y))")
    print()

    # Taylor approximation of sin(xy) using monomials
    # sin(t) ≈ t - t³/6 + t⁵/120 - t⁷/5040
    # where t = xy, so t^k = x^k * y^k
    coeffs = [1.0, -1/6, 1/120, -1/5040]
    exps_a = [1, 3, 5, 7]
    exps_b = [1, 3, 5, 7]

    d = polynomial_emlka(coeffs, exps_a, exps_b)

    n_grid = 20
    max_error = 0.0
    xs = [1.0 + i / (n_grid - 1) for i in range(n_grid)]
    ys = [1.0 + i / (n_grid - 1) for i in range(n_grid)]

    for x in xs:
        for y in ys:
            exact = math.sin(x * y)
            approx = d.eval(x, y)
            error = abs(approx - exact)
            max_error = max(max_error, error)

    print(f"EML-KA terms used: {d.Q}")
    print(f"Maximum error on [1,2]²: {max_error:.6f}")
    print(f"Target tolerance: 0.01")
    print(f"Result: {'PASS ✓' if max_error < 0.01 else 'FAIL ✗ (need more terms or higher order Taylor)'}")
    print()

    # Try with more Taylor terms
    N = 10
    coeffs2, exps_a2, exps_b2 = [], [], []
    for k in range(N):
        n = 2 * k + 1
        sign = (-1) ** k
        coeff = sign / math.factorial(n)
        coeffs2.append(coeff)
        exps_a2.append(n)
        exps_b2.append(n)

    d2 = polynomial_emlka(coeffs2, exps_a2, exps_b2)

    max_error2 = 0.0
    for x in xs:
        for y in ys:
            exact = math.sin(x * y)
            approx = d2.eval(x, y)
            error = abs(approx - exact)
            max_error2 = max(max_error2, error)

    print(f"With {N} Taylor terms ({d2.Q} EML-KA terms):")
    print(f"Maximum error on [1,2]²: {max_error2:.2e}")
    print(f"Result: {'PASS ✓' if max_error2 < 0.01 else 'FAIL ✗'}")
    print()


def demo_depth_complexity():
    """Demo: Depth-complexity tradeoff visualization"""
    print("=" * 60)
    print("DEMO 7: Depth-Complexity Tradeoff")
    print("=" * 60)
    print()
    print("Classical KA requires 2n+1 = 5 terms for n=2.")
    print("EML-KA achieves 1 term per monomial at constant depth 3.")
    print()
    print(f"{'Function':>20} {'EML-KA Terms':>14} {'Depth':>8} {'Classical KA':>14}")
    print("-" * 58)

    functions = [
        ("x·y", 1, 3, 5),
        ("x/y", 1, 3, 5),
        ("x²·y³", 1, 3, 5),
        ("x¹⁰⁰·y²⁰⁰", 1, 3, 5),
        ("3x²y + 2xy²", 2, 3, 5),
        ("x² + xy + y²", 3, 3, 5),
        ("Degree-5 poly (21 terms)", 21, 3, 5),
    ]

    for name, terms, depth, classical in functions:
        print(f"{name:>20} {terms:>14} {depth:>8} {classical:>14}")
    print()


if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  EML-KA: Exponential-Log Kolmogorov-Arnold Decomposition║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    demo_multiplication()
    demo_monomials()
    demo_polynomial()
    demo_am_gm()
    demo_fenchel_young()
    demo_universality_test()
    demo_depth_complexity()

    print("All demos complete.")


#!/usr/bin/env python3
"""
Visualization: EML Chain Depth Analysis

Shows how EML chain evaluation transforms inputs through successive
operations, and demonstrates the depth-independence property.
"""

import math
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 12))
    fig.suptitle('EML Chain Structure and Depth Analysis', fontsize=16, fontweight='bold')

    # 1. Chain evaluation trace for multiplication
    ax = axes[0, 0]
    x_vals = np.linspace(0.1, 5, 100)
    y_val = 2.0

    # Trace: x → log(x) → log(x) + log(y) → exp(log(x) + log(y)) = x*y
    step0 = x_vals  # input x
    step1 = np.log(x_vals)  # after log
    step2 = step1 + np.log(y_val)  # after addition
    step3 = np.exp(step2)  # after exp = x*y

    ax.plot(x_vals, step0, 'b-', label='Input x', linewidth=1.5)
    ax.plot(x_vals, step1, 'g-', label='After log: log(x)', linewidth=1.5)
    ax.plot(x_vals, step2, 'orange', label=f'After +log({y_val}): log(x)+log({y_val})', linewidth=1.5)
    ax.plot(x_vals, step3, 'r-', label=f'After exp: x·{y_val}', linewidth=1.5)
    ax.set_xlabel('x')
    ax.set_ylabel('Value')
    ax.set_title(f'EML Chain Trace: x·y (y={y_val})')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    # 2. Monomial evaluation for different degrees
    ax = axes[0, 1]
    x_vals = np.linspace(0.5, 2.5, 100)

    for a in [1, 2, 3, 5, 10]:
        # EML-KA: exp(a * log(x))
        result = np.exp(a * np.log(x_vals))
        ax.plot(x_vals, result, label=f'x^{a} (depth 3)', linewidth=1.5)

    ax.set_xlabel('x')
    ax.set_ylabel('x^a')
    ax.set_title('Power Functions via EML Chains (all depth 3)')
    ax.legend()
    ax.grid(True, alpha=0.3)
    ax.set_ylim(0, 30)

    # 3. Polynomial decomposition: 3x²y + 2xy² - x³ + 5y at y=1.5
    ax = axes[1, 0]
    x_vals = np.linspace(0.1, 3.0, 200)
    y_val = 1.5

    # Individual terms
    term1 = 3 * x_vals**2 * y_val
    term2 = 2 * x_vals * y_val**2
    term3 = -x_vals**3
    term4 = 5 * y_val * np.ones_like(x_vals)
    total = term1 + term2 + term3 + term4

    ax.fill_between(x_vals, 0, term1, alpha=0.3, label='3x²y')
    ax.fill_between(x_vals, 0, term2, alpha=0.3, label='2xy²')
    ax.fill_between(x_vals, 0, term3, alpha=0.3, label='-x³')
    ax.plot(x_vals, total, 'k-', linewidth=2.5, label='Total polynomial')
    ax.axhline(y=0, color='gray', linewidth=0.5)
    ax.set_xlabel('x')
    ax.set_ylabel('p(x, y)')
    ax.set_title(f'Polynomial Terms (y={y_val}): each is 1 EML-KA term')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    # 4. Universality test: sin(xy) Taylor approximation
    ax = axes[1, 1]
    x_vals = np.linspace(1, 2, 100)
    y_val = 1.5

    exact = np.sin(x_vals * y_val)
    errors = {}
    for N in [1, 2, 3, 5, 7, 10]:
        approx = np.zeros_like(x_vals)
        for k in range(N):
            n = 2 * k + 1
            coeff = (-1)**k / math.factorial(n)
            # Each term is coeff * (xy)^n = coeff * exp(n*log(x) + n*log(y))
            approx += coeff * np.exp(n * np.log(x_vals) + n * np.log(y_val))
        max_err = np.max(np.abs(approx - exact))
        errors[N] = max_err

    terms = list(errors.keys())
    errs = list(errors.values())
    ax.semilogy(terms, errs, 'bo-', linewidth=2, markersize=8)
    ax.axhline(y=0.01, color='r', linestyle='--', label='ε = 0.01 target')
    ax.set_xlabel('Number of EML-KA terms')
    ax.set_ylabel('Max error on [1,2]×{1.5}')
    ax.set_title('sin(xy) Approximation by EML-KA')
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('eml_chain_depth.png', dpi=150, bbox_inches='tight')
    print("Saved: eml_chain_depth.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: EML-KA Decomposition Error Surfaces

Creates a visualization showing the error between exact functions
and their EML-KA decompositions across the positive quadrant.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib import cm


def eval_monomial_emlka(x, y, a, b):
    """Evaluate the EML-KA decomposition of x^a * y^b."""
    return np.exp(a * np.log(x) + b * np.log(y))


def eval_mul_emlka(x, y):
    """Evaluate the multiplication EML-KA decomposition."""
    return np.exp(np.log(x) + np.log(y))


def eval_div_emlka(x, y):
    """Evaluate the division EML-KA decomposition."""
    return np.exp(np.log(x) - np.log(y))


def am_gm_gap(x, y):
    """Compute the AM-GM gap: AM - GM."""
    gm = np.exp((np.log(x) + np.log(y)) / 2)
    am = (x + y) / 2
    return am - gm


def fenchel_young_gap(x, s):
    """Compute the Fenchel-Young gap: RHS - LHS."""
    return np.exp(x) + s * np.log(s) - s - x * s


def main():
    fig, axes = plt.subplots(2, 3, figsize=(18, 12))
    fig.suptitle('EML-KA Decomposition: Key Results', fontsize=16, fontweight='bold')

    x = np.linspace(0.1, 3.0, 100)
    y = np.linspace(0.1, 3.0, 100)
    X, Y = np.meshgrid(x, y)

    # 1. Multiplication decomposition error
    ax = axes[0, 0]
    exact = X * Y
    approx = eval_mul_emlka(X, Y)
    error = np.abs(approx - exact)
    c = ax.pcolormesh(X, Y, np.log10(error + 1e-16), cmap='RdYlGn_r', vmin=-16, vmax=-12)
    ax.set_xlabel('x')
    ax.set_ylabel('y')
    ax.set_title('log₁₀|error| for x·y = exp(log x + log y)')
    plt.colorbar(c, ax=ax, label='log₁₀(error)')

    # 2. Monomial x²y³ decomposition
    ax = axes[0, 1]
    a, b = 2, 3
    exact = X**a * Y**b
    approx = eval_monomial_emlka(X, Y, a, b)
    rel_error = np.abs(approx - exact) / (np.abs(exact) + 1e-300)
    c = ax.pcolormesh(X, Y, np.log10(rel_error + 1e-16), cmap='RdYlGn_r', vmin=-16, vmax=-12)
    ax.set_xlabel('x')
    ax.set_ylabel('y')
    ax.set_title(f'log₁₀|rel error| for x^{a}·y^{b}')
    plt.colorbar(c, ax=ax, label='log₁₀(rel error)')

    # 3. AM-GM gap surface
    ax = axes[0, 2]
    gap = am_gm_gap(X, Y)
    c = ax.pcolormesh(X, Y, gap, cmap='viridis')
    ax.set_xlabel('x')
    ax.set_ylabel('y')
    ax.set_title('AM-GM Gap: (x+y)/2 - √(xy) ≥ 0')
    plt.colorbar(c, ax=ax, label='Gap')
    # Mark the diagonal where gap = 0
    ax.plot([0.1, 3.0], [0.1, 3.0], 'r--', linewidth=2, label='x=y (gap=0)')
    ax.legend(loc='upper left')

    # 4. Fenchel-Young gap
    ax = axes[1, 0]
    x_fy = np.linspace(-2, 3, 100)
    s_fy = np.linspace(0.1, 5, 100)
    X_fy, S_fy = np.meshgrid(x_fy, s_fy)
    gap_fy = fenchel_young_gap(X_fy, S_fy)
    c = ax.pcolormesh(X_fy, S_fy, gap_fy, cmap='viridis')
    ax.set_xlabel('x')
    ax.set_ylabel('s')
    ax.set_title('Fenchel-Young Gap: exp(x) + s·log(s) - s - x·s ≥ 0')
    plt.colorbar(c, ax=ax, label='Gap')
    # Mark the tightness curve x = log(s)
    s_curve = np.linspace(0.1, 5, 100)
    x_curve = np.log(s_curve)
    ax.plot(x_curve, s_curve, 'r-', linewidth=2, label='x = log(s) (tight)')
    ax.legend(loc='upper left')

    # 5. Depth independence illustration
    ax = axes[1, 1]
    degrees = list(range(1, 21))
    depths = [3] * len(degrees)  # All have depth 3
    classical = [5] * len(degrees)  # Classical KA always needs 5

    ax.bar([d - 0.2 for d in degrees], depths, 0.4, label='EML-KA depth', color='steelblue')
    ax.bar([d + 0.2 for d in degrees], classical, 0.4, label='Classical KA terms', color='coral')
    ax.set_xlabel('Monomial degree (a+b)')
    ax.set_ylabel('Complexity')
    ax.set_title('Depth Independence: EML-KA vs Classical KA')
    ax.legend()
    ax.set_ylim(0, 7)

    # 6. EML encoding: log transforms multiplication to addition
    ax = axes[1, 2]
    x_enc = np.linspace(0.1, 5, 50)
    y_enc = np.linspace(0.1, 5, 50)
    X_enc, Y_enc = np.meshgrid(x_enc, y_enc)

    # In the original space: level curves of x*y = c
    levels_orig = [0.5, 1, 2, 4, 8]
    for c_val in levels_orig:
        y_curve = c_val / x_enc
        mask = (y_curve >= 0.1) & (y_curve <= 5)
        ax.plot(np.log(x_enc[mask]), np.log(y_curve[mask]), '-',
                label=f'xy={c_val}' if c_val in [0.5, 2, 8] else None)

    ax.set_xlabel('log(x)')
    ax.set_ylabel('log(y)')
    ax.set_title('EML Encoding: xy = c → log(x) + log(y) = log(c)')
    ax.legend()
    ax.grid(True, alpha=0.3)
    ax.set_aspect('equal')

    plt.tight_layout()
    plt.savefig('eml_ka_visualization.png', dpi=150, bbox_inches='tight')
    print("Saved: eml_ka_visualization.png")


if __name__ == "__main__":
    main()
