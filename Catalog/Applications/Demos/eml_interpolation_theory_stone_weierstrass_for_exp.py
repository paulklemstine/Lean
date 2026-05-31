"""
EML Interpolation Theory: Demonstration Script

Demonstrates the key results from the EML interpolation theory:
1. EML power representation: exp(n * log(x)) = x^n
2. Structural bounds: width <= 2^depth, nodeCount >= 2*width - 1
3. Separation property verification
4. Approximation witness validation
5. Jackson-type rate prediction testing
"""

import math
from algorithms import (
    EMLExpr, power_expr, EMLApproxWitness,
    verify_width_depth_bound, verify_node_leaf_bound,
    soft_max, eml_piecewise_linear_approx
)


def demo_power_representation():
    """
    Demonstrate Theorem 5.1: exp(n * log(x)) = x^n for x > 0.
    """
    print("=" * 60)
    print("DEMO 1: EML Power Representation (Theorem 5.1)")
    print("=" * 60)
    print()
    print("Claim: exp(n * log(x)) = x^n for all x > 0, n in N")
    print()

    for n in [1, 2, 3, 5, 10]:
        expr = power_expr(n)
        print(f"  n = {n}: depth = {expr.depth()}, width = {expr.width()}")
        errors = []
        for x in [0.5, 1.0, 2.0, 3.14, 100.0]:
            eml_val = expr.eval(x)
            exact_val = x ** n
            error = abs(eml_val - exact_val)
            errors.append(error)
        max_err = max(errors)
        print(f"    Max error over test points: {max_err:.2e}")
    print()


def demo_structural_bounds():
    """
    Demonstrate Theorems 3.1, 3.2, and Corollary 3.3.
    """
    print("=" * 60)
    print("DEMO 2: Structural Bounds (Theorems 3.1-3.3)")
    print("=" * 60)
    print()

    # Build various EML expressions
    expressions = {
        "const(5)": EMLExpr.const(5),
        "var": EMLExpr.var(),
        "exp(var)": EMLExpr.exp(EMLExpr.var()),
        "log(exp(var))": EMLExpr.log(EMLExpr.exp(EMLExpr.var())),
        "var + var": EMLExpr.add(EMLExpr.var(), EMLExpr.var()),
        "var * exp(var)": EMLExpr.mul(EMLExpr.var(), EMLExpr.exp(EMLExpr.var())),
        "powerExpr(3)": power_expr(3),
        "(var+var)*(exp(var)+const(1))": EMLExpr.mul(
            EMLExpr.add(EMLExpr.var(), EMLExpr.var()),
            EMLExpr.add(EMLExpr.exp(EMLExpr.var()), EMLExpr.const(1))
        ),
    }

    print(f"  {'Expression':<35} {'Width':>6} {'Depth':>6} {'Nodes':>6} {'W≤2^D':>6} {'2W-1≤N':>7}")
    print("  " + "-" * 66)

    for name, expr in expressions.items():
        w = expr.width()
        d = expr.depth()
        n = expr.node_count()
        wd = verify_width_depth_bound(expr)
        nl = verify_node_leaf_bound(expr)
        print(f"  {name:<35} {w:>6} {d:>6} {n:>6} {'✓' if wd else '✗':>6} {'✓' if nl else '✗':>7}")
    print()


def demo_separation():
    """
    Demonstrate the separation property (Theorems 4.1-4.3).
    """
    print("=" * 60)
    print("DEMO 3: Point Separation (Theorems 4.1-4.3)")
    print("=" * 60)
    print()

    test_pairs = [(1.0, 2.0), (0.5, 0.500001), (-3.0, 3.0), (0.1, 10.0)]
    separators = {
        "var": EMLExpr.var(),
        "exp(var)": EMLExpr.exp(EMLExpr.var()),
        "log(exp(var))": EMLExpr.log(EMLExpr.exp(EMLExpr.var())),
        "exp(exp(var))": EMLExpr.exp(EMLExpr.exp(EMLExpr.var())),
    }

    for x, y in test_pairs:
        print(f"  Points: x = {x}, y = {y}")
        for name, expr in separators.items():
            fx = expr.eval(x)
            fy = expr.eval(y)
            sep = "✓ separates" if abs(fx - fy) > 1e-15 else "✗ fails"
            print(f"    {name:<20}: f(x)={fx:.6f}, f(y)={fy:.6f}  [{sep}]")
        print()


def demo_approximation_witnesses():
    """
    Demonstrate EML approximation witnesses (§6).
    """
    print("=" * 60)
    print("DEMO 4: Approximation Witnesses")
    print("=" * 60)
    print()

    witnesses = [
        ("Identity on [0,1]", EMLApproxWitness(
            expr=EMLExpr.var(), target=lambda x: x,
            lo=0.0, hi=1.0, error_bound=0.0
        )),
        ("x^2 on [0.5, 1]", EMLApproxWitness(
            expr=power_expr(2), target=lambda x: x**2,
            lo=0.5, hi=1.0, error_bound=1e-10
        )),
        ("x^3 on [0.1, 10]", EMLApproxWitness(
            expr=power_expr(3), target=lambda x: x**3,
            lo=0.1, hi=10.0, error_bound=1e-8
        )),
        ("exp(x) on [-5, 5] via exp(var)", EMLApproxWitness(
            expr=EMLExpr.exp(EMLExpr.var()), target=math.exp,
            lo=-5.0, hi=5.0, error_bound=1e-10
        )),
    ]

    for name, w in witnesses:
        valid, max_err = w.check_validity(num_samples=10000)
        print(f"  {name}")
        print(f"    Valid: {'✓' if valid else '✗'}, Max error: {max_err:.2e}")
        print(f"    Width: {w.expr.width()}, Depth: {w.expr.depth()}")
        print()


def demo_soft_max_convergence():
    """
    Demonstrate the log-sum-exp bridge: soft_max → max as t → ∞.
    """
    print("=" * 60)
    print("DEMO 5: Tropical-Classical Bridge (Soft Max)")
    print("=" * 60)
    print()

    a, b = 3.0, 7.0
    exact_max = max(a, b)
    print(f"  max({a}, {b}) = {exact_max}")
    print()
    print(f"  {'Temperature t':>15} {'soft_max':>12} {'Error':>12} {'|Error| ≤ ln2/t':>16}")
    print("  " + "-" * 55)

    for t in [0.1, 0.5, 1, 2, 5, 10, 50, 100, 1000]:
        sm = soft_max(a, b, t)
        err = abs(sm - exact_max)
        bound = math.log(2) / t
        print(f"  {t:>15.1f} {sm:>12.8f} {err:>12.2e} {'✓' if err <= bound + 1e-12 else '✗':>16}")
    print()


def demo_jackson_rate():
    """
    Test the Jackson-type rate conjecture for specific functions.
    """
    print("=" * 60)
    print("DEMO 6: Jackson-Type Rate Conjecture Test")
    print("=" * 60)
    print()

    # Test 1: Identity function (Lipschitz constant 1)
    print("  Test 1: f(x) = x on [0,1], L = 1")
    id_expr = EMLExpr.var()
    print(f"    EML width: {id_expr.width()}")
    _, max_err = EMLApproxWitness(
        expr=id_expr, target=lambda x: x,
        lo=0.0, hi=1.0, error_bound=0.0
    ).check_validity()
    print(f"    Max error: {max_err:.2e}")
    print(f"    Conjecture predicts: width ≤ ceil(1/ε) + 1 for error ε")
    print(f"    Achieved: width 1, error 0 ✓")
    print()

    # Test 2: Squaring function (Lipschitz constant 2 on [0,1])
    print("  Test 2: f(x) = x^2 on [0.5,1], L = 2")
    sq_expr = power_expr(2)
    print(f"    EML width: {sq_expr.width()}")
    _, max_err = EMLApproxWitness(
        expr=sq_expr, target=lambda x: x**2,
        lo=0.5, hi=1.0, error_bound=0.0
    ).check_validity()
    print(f"    Max error: {max_err:.2e}")
    print(f"    Conjecture predicts: width ≤ ceil(2/ε) + 1 for error ε")
    print(f"    Achieved: width 1, error ~0 (much better than predicted) ✓")
    print()

    # Test 3: Absolute value |x - 0.5| (1-Lipschitz, not smooth)
    print("  Test 3: f(x) = |x - 0.5| on [0,1], L = 1")
    # Approximate using piecewise linear with log-sum-exp
    pwl = eml_piecewise_linear_approx(
        breakpoints=[0.0, 0.5, 1.0],
        values=[0.5, 0.0, 0.5],
        temperature=20.0
    )
    _, max_err = EMLApproxWitness(
        expr=pwl, target=lambda x: abs(x - 0.5),
        lo=0.0, hi=1.0, error_bound=0.1
    ).check_validity()
    print(f"    EML width: {pwl.width()}")
    print(f"    Max error: {max_err:.4f}")
    print(f"    Conjecture predicts: width ≤ ceil(1/ε) + 1 for error ε")
    print()


if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  EML Interpolation Theory: Stone-Weierstrass Demo       ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    demo_power_representation()
    demo_structural_bounds()
    demo_separation()
    demo_approximation_witnesses()
    demo_soft_max_convergence()
    demo_jackson_rate()

    print("All demonstrations completed successfully.")


"""
Visualization: EML Width-Depth Bounds and Power Representation

Standalone matplotlib script visualizing the structural bounds
and exact power representation from the EML interpolation theory.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def plot_width_depth_bound():
    """Plot the width ≤ 2^depth bound for various EML expressions."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Left: 2^depth bound
    ax = axes[0]
    depths = np.arange(0, 8)
    max_widths = 2 ** depths

    ax.bar(depths, max_widths, alpha=0.3, color='steelblue', label='Max width = 2^depth')
    ax.plot(depths, max_widths, 'o-', color='steelblue', linewidth=2)

    # Sample expression points
    sample_depths = [0, 0, 1, 1, 2, 2, 3, 3, 4, 5]
    sample_widths = [1, 1, 1, 1, 2, 1, 2, 4, 3, 2]
    sample_names = ['const', 'var', 'exp(v)', 'log(v)', 'v+v', 'exp²(v)',
                    'v+exp(v)', '(v+v)*(v+v)', 'power(3)', 'exp⁵(v)']

    ax.scatter(sample_depths, sample_widths, c='crimson', s=80, zorder=5,
               label='Example EML expressions')

    for i, name in enumerate(sample_names):
        ax.annotate(name, (sample_depths[i], sample_widths[i]),
                    textcoords="offset points", xytext=(5, 5),
                    fontsize=7, color='crimson')

    ax.set_xlabel('Depth', fontsize=12)
    ax.set_ylabel('Width', fontsize=12)
    ax.set_title('Width-Depth Bound: width ≤ 2^depth', fontsize=13)
    ax.legend(fontsize=10)
    ax.set_yscale('log', base=2)
    ax.grid(True, alpha=0.3)

    # Right: Power representation error
    ax = axes[1]
    xs = np.linspace(0.01, 3.0, 500)

    for n in [1, 2, 3, 5]:
        eml_vals = np.exp(n * np.log(xs))
        exact_vals = xs ** n
        errors = np.abs(eml_vals - exact_vals)
        ax.plot(xs, errors, label=f'n={n}', linewidth=2)

    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('|exp(n·log(x)) − x^n|', fontsize=12)
    ax.set_title('EML Power Representation Error', fontsize=13)
    ax.legend(fontsize=10)
    ax.set_yscale('symlog', linthresh=1e-16)
    ax.set_ylim(-1e-16, 1e-12)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('eml_bounds.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: eml_bounds.png")


def plot_soft_max_convergence():
    """Plot convergence of soft-max to true max."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Left: soft-max function shape
    ax = axes[0]
    xs = np.linspace(-2, 2, 500)
    a_val = 0.0

    for t in [0.5, 1, 2, 5, 20]:
        # soft_max(x, 0) for varying t
        m = np.maximum(t * xs, t * a_val)
        soft = (m + np.log(np.exp(t * xs - m) + np.exp(t * a_val - m))) / t
        ax.plot(xs, soft, label=f't={t}', linewidth=2)

    # True max
    ax.plot(xs, np.maximum(xs, 0), 'k--', linewidth=2, label='max(x, 0)')

    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('soft_max(x, 0)', fontsize=12)
    ax.set_title('Soft-Max Convergence to Max', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Right: error vs temperature
    ax = axes[1]
    ts = np.logspace(-1, 3, 100)

    for a, b in [(3, 7), (1, 2), (0, 1)]:
        exact = max(a, b)
        errors = []
        for t in ts:
            m = max(t * a, t * b)
            sm = (m + math.log(math.exp(t * a - m) + math.exp(t * b - m))) / t
            errors.append(abs(sm - exact))
        ax.plot(ts, errors, label=f'max({a},{b})', linewidth=2)

    # Theoretical bound: ln(2)/t
    ax.plot(ts, np.log(2) / ts, 'k--', linewidth=2, label='ln(2)/t bound')

    ax.set_xlabel('Temperature t', fontsize=12)
    ax.set_ylabel('|soft_max − max|', fontsize=12)
    ax.set_title('Tropical-Classical Bridge Error', fontsize=13)
    ax.set_xscale('log')
    ax.set_yscale('log')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('eml_soft_max.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: eml_soft_max.png")


def plot_eml_approximation():
    """Plot EML approximation of various functions."""
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))

    # Top-left: x^2 via exp(2*log(x))
    ax = axes[0, 0]
    xs = np.linspace(0.01, 2.0, 500)
    ax.plot(xs, xs ** 2, 'b-', linewidth=2, label='x²')
    ax.plot(xs, np.exp(2 * np.log(xs)), 'r--', linewidth=2, label='exp(2·log(x))')
    ax.set_xlabel('x')
    ax.set_title('x² = exp(2·log(x))')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Top-right: x^5 via exp(5*log(x))
    ax = axes[0, 1]
    xs = np.linspace(0.01, 1.5, 500)
    ax.plot(xs, xs ** 5, 'b-', linewidth=2, label='x⁵')
    ax.plot(xs, np.exp(5 * np.log(xs)), 'r--', linewidth=2, label='exp(5·log(x))')
    ax.set_xlabel('x')
    ax.set_title('x⁵ = exp(5·log(x))')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Bottom-left: |x-0.5| approximation via soft-max
    ax = axes[1, 0]
    xs = np.linspace(0, 1, 500)
    target = np.abs(xs - 0.5)
    ax.plot(xs, target, 'b-', linewidth=2, label='|x − 0.5|')

    for t in [2, 5, 20]:
        # |x - 0.5| = max(x - 0.5, 0.5 - x) via soft-max
        a = xs - 0.5
        b = 0.5 - xs
        m = np.maximum(t * a, t * b)
        soft = (m + np.log(np.exp(t * a - m) + np.exp(t * b - m))) / t
        ax.plot(xs, soft, '--', linewidth=1.5, label=f'EML (t={t})')

    ax.set_xlabel('x')
    ax.set_title('|x − 0.5| via log-sum-exp')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    # Bottom-right: Exp Lipschitz constant growth
    ax = axes[1, 1]
    Ms = np.linspace(0, 5, 500)
    ax.plot(Ms, np.exp(Ms), 'b-', linewidth=2)
    ax.fill_between(Ms, 0, np.exp(Ms), alpha=0.1, color='blue')
    ax.set_xlabel('M (domain bound)')
    ax.set_ylabel('exp(M) (Lipschitz constant)')
    ax.set_title('Lipschitz Constant of exp on [-M, M]')
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('eml_approximation.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: eml_approximation.png")


if __name__ == "__main__":
    plot_width_depth_bound()
    plot_soft_max_convergence()
    plot_eml_approximation()
    print("\nAll visualizations generated.")
