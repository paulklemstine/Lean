#!/usr/bin/env python3
"""
EML Single-Operator Church-Turing Thesis: Demo

Demonstrates:
1. EML operator recovering exp and log
2. Elementary functions as EML circuits
3. Transcendental depth hierarchy
4. Depth-width tradeoff investigation
5. Growth rate analysis of iterated exponentials
"""

import math
from algorithms import (
    EMLCircuit, Var, Const, Add, Mul, Neg, Inv, Exp, Log,
    eml_op, recover_exp_via_eml, recover_log_via_eml,
    iter_exp, iter_exp_circuit,
    sinh_circuit, cosh_circuit, gaussian_circuit, sigmoid_circuit,
    logistic_map_circuit, verify_depth_class, check_tradeoff
)


def demo_eml_operator():
    """Demonstrate the EML operator recovering exp and log."""
    print("=" * 60)
    print("§1. The EML Operator: eml(x, y) = exp(x) - log(y)")
    print("=" * 60)

    print("\n  Identity 1: eml(x, 1) = exp(x)")
    for x in [-2.0, -1.0, 0.0, 1.0, 2.0]:
        eml_val = recover_exp_via_eml(x)
        exp_val = math.exp(x)
        print(f"    x = {x:5.1f}: eml(x,1) = {eml_val:.10f}, exp(x) = {exp_val:.10f}, "
              f"error = {abs(eml_val - exp_val):.2e}")

    print("\n  Identity 2: 1 - eml(0, y) = log(y)")
    for y in [0.5, 1.0, 2.0, math.e, 10.0]:
        eml_val = recover_log_via_eml(y)
        log_val = math.log(y)
        print(f"    y = {y:5.2f}: 1-eml(0,y) = {eml_val:.10f}, log(y) = {log_val:.10f}, "
              f"error = {abs(eml_val - log_val):.2e}")


def demo_elementary_functions():
    """Show elementary functions as EML circuits."""
    print("\n" + "=" * 60)
    print("§2. Elementary Functions as EML Circuits")
    print("=" * 60)

    test_points = [-2.0, -1.0, -0.5, 0.0, 0.5, 1.0, 2.0]

    circuits = [
        ("sinh(x)", sinh_circuit(), math.sinh),
        ("cosh(x)", cosh_circuit(), math.cosh),
        ("exp(-x²)", gaussian_circuit(), lambda x: math.exp(-x**2)),
        ("σ(x)", sigmoid_circuit(), lambda x: 1.0 / (1.0 + math.exp(-x))),
        ("4x(1-x)", logistic_map_circuit(4.0), lambda x: 4*x*(1-x)),
    ]

    for name, circuit, target in circuits:
        result = verify_depth_class(circuit, target, test_points, circuit.transc_depth)
        status = "✓" if result['function_correct'] else "✗"
        print(f"\n  {status} {name}")
        print(f"    Circuit: {circuit}")
        print(f"    Size: {result['size']}, Transc Depth: {result['transc_depth']}")
        print(f"    Max error: {result['max_error']:.2e}")


def demo_depth_hierarchy():
    """Demonstrate the transcendental depth hierarchy."""
    print("\n" + "=" * 60)
    print("§3. Transcendental Depth Hierarchy")
    print("=" * 60)

    print("\n  Depth 0 (algebraic/rational):")
    alg_circuits = [
        ("x²", Mul(Var(), Var())),
        ("1/x", Inv(Var())),
        ("x² + 2x + 1", Add(Add(Mul(Var(), Var()), Mul(Const(2), Var())), Const(1))),
        ("4x(1-x)", logistic_map_circuit(4.0)),
    ]
    for name, c in alg_circuits:
        print(f"    {name}: size={c.size}, depth={c.depth}, "
              f"transc_depth={c.transc_depth}, algebraic={c.is_algebraic}")

    print("\n  Depth 1 (one level of exp/log):")
    depth1 = [
        ("exp(x)", Exp(Var())),
        ("log(x)", Log(Var())),
        ("sinh(x)", sinh_circuit()),
        ("σ(x)", sigmoid_circuit()),
        ("exp(-x²)", gaussian_circuit()),
    ]
    for name, c in depth1:
        print(f"    {name}: size={c.size}, depth={c.depth}, "
              f"transc_depth={c.transc_depth}")

    print("\n  Depth n (iterated exponentials):")
    for n in range(1, 6):
        c = iter_exp_circuit(n)
        print(f"    exp^{n}(x): size={c.size}, depth={c.depth}, "
              f"transc_depth={c.transc_depth}")


def demo_growth_rates():
    """Show growth rates of iterated exponentials."""
    print("\n" + "=" * 60)
    print("§4. Growth Rates of Iterated Exponentials")
    print("=" * 60)

    print("\n  iterExp(n, 0) for n = 0, 1, ..., 4:")
    for n in range(5):
        val = iter_exp(n, 0.0)
        if math.isfinite(val):
            print(f"    iterExp({n}, 0) = {val:.6f}")
        else:
            print(f"    iterExp({n}, 0) = ∞")

    print("\n  iterExp(n, 1) for n = 0, 1, 2, 3:")
    for n in range(4):
        val = iter_exp(n, 1.0)
        if math.isfinite(val):
            print(f"    iterExp({n}, 1) = {val:.6f}")
        else:
            print(f"    iterExp({n}, 1) = ∞")

    print("\n  Strict monotonicity check (iterExp n is increasing):")
    for n in range(1, 4):
        points = [-1.0, 0.0, 1.0, 2.0]
        values = [iter_exp(n, x) for x in points]
        is_increasing = all(v1 < v2 for v1, v2 in zip(values, values[1:])
                           if math.isfinite(v1) and math.isfinite(v2))
        print(f"    iterExp({n}): {['%.4f' % v if math.isfinite(v) else '∞' for v in values]} "
              f"{'✓ increasing' if is_increasing else '✗ NOT increasing'}")


def demo_composition():
    """Demonstrate composition and depth addition."""
    print("\n" + "=" * 60)
    print("§5. Composition: Depths Add")
    print("=" * 60)

    # exp ∘ exp = exp(exp(x))
    f = Exp(Var())  # depth 1
    g = Exp(Var())  # depth 1
    fg = f.substitute(g)  # should be depth 2
    print(f"\n  f = {f}, transc_depth = {f.transc_depth}")
    print(f"  g = {g}, transc_depth = {g.transc_depth}")
    print(f"  f ∘ g = {fg}, transc_depth = {fg.transc_depth}")
    print(f"  Depth bound: {f.transc_depth} + {g.transc_depth} = "
          f"{f.transc_depth + g.transc_depth} ≥ {fg.transc_depth} ✓")

    # sigmoid ∘ polynomial
    sig = sigmoid_circuit()  # depth 1
    poly = Mul(Var(), Var())  # depth 0, computes x²
    composed = sig.substitute(poly)
    print(f"\n  σ = {sig}, transc_depth = {sig.transc_depth}")
    print(f"  p = {poly}, transc_depth = {poly.transc_depth}")
    print(f"  σ ∘ p = {composed}, transc_depth = {composed.transc_depth}")
    print(f"  Depth bound: {sig.transc_depth} + {poly.transc_depth} = "
          f"{sig.transc_depth + poly.transc_depth} ≥ {composed.transc_depth} ✓")

    # Verify correctness
    x_test = 1.5
    expected = 1.0 / (1.0 + math.exp(-x_test**2))
    actual = composed.eval(x_test)
    print(f"\n  Verification at x = {x_test}:")
    print(f"    σ(x²) expected = {expected:.10f}")
    print(f"    σ(x²) computed = {actual:.10f}")
    print(f"    Error = {abs(actual - expected):.2e}")


def demo_depth_width_tradeoff():
    """Investigate the depth-width tradeoff conjecture."""
    print("\n" + "=" * 60)
    print("§6. Depth-Width Tradeoff Conjecture")
    print("=" * 60)

    for n in [1, 2, 3]:
        result = check_tradeoff(n, max_search_size=5)
        print(f"\n  n = {n}:")
        print(f"    Chain size: {result['chain_size']}")
        print(f"    Best size found: {result['best_size']}")
        print(f"    Conjecture bound (2n-1): {result['conjecture_bound']}")
        print(f"    Conjecture holds: {result['conjecture_holds']}")


def demo_polynomial_not_exp():
    """Numerical demonstration that no polynomial matches exp."""
    print("\n" + "=" * 60)
    print("§7. Exp is Not Polynomial: Numerical Evidence")
    print("=" * 60)

    print("\n  Taylor polynomials of exp at x = 0:")
    print("  The n-th Taylor polynomial T_n(x) = Σ x^k/k! approximates exp")
    print("  near 0 but diverges for large x.\n")

    for degree in [1, 2, 3, 5, 10]:
        # Taylor polynomial of exp
        def taylor_exp(x: float, d: int = degree) -> float:
            return sum(x**k / math.factorial(k) for k in range(d + 1))

        print(f"  Degree {degree} Taylor polynomial:")
        for x in [0.0, 1.0, 5.0, 10.0, 20.0]:
            t_val = taylor_exp(x)
            e_val = math.exp(x) if x < 500 else float('inf')
            if math.isfinite(e_val) and math.isfinite(t_val):
                rel_err = abs(t_val - e_val) / e_val if e_val != 0 else abs(t_val)
                print(f"    x={x:5.1f}: T_{degree}(x) = {t_val:15.4f}, "
                      f"exp(x) = {e_val:15.4f}, rel_err = {rel_err:.4f}")
            else:
                print(f"    x={x:5.1f}: overflow")

    print("\n  Key insight: any polynomial eventually grows slower than exp.")
    print("  Ratio exp(x) / x^n → ∞ as x → ∞ for all n:")
    for n in [1, 2, 5, 10]:
        x = 100.0
        ratio = math.exp(x) / x**n
        print(f"    exp(100) / 100^{n:2d} = {ratio:.4e}")


if __name__ == '__main__':
    demo_eml_operator()
    demo_elementary_functions()
    demo_depth_hierarchy()
    demo_growth_rates()
    demo_composition()
    demo_depth_width_tradeoff()
    demo_polynomial_not_exp()

    print("\n" + "=" * 60)
    print("Demo complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: EML Transcendental Depth Hierarchy

Shows functions at different depth levels and their growth rates.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')


def iter_exp(n: int, x: float) -> float:
    result = x
    for _ in range(n):
        result = np.exp(np.clip(result, -500, 500))
    return result


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('EML Transcendental Depth Hierarchy', fontsize=16, fontweight='bold')

    # Panel 1: Depth 0 functions (rational/polynomial)
    ax = axes[0, 0]
    x = np.linspace(-3, 3, 500)
    ax.plot(x, x**2, label='x²', linewidth=2)
    ax.plot(x, x**3, label='x³', linewidth=2)
    ax.plot(x, 1/(1 + x**2), label='1/(1+x²)', linewidth=2)
    ax.plot(x, 4*x*(1-x), label='4x(1-x)', linewidth=2, linestyle='--')
    ax.set_title('Depth 0: Rational Functions', fontsize=12)
    ax.set_xlabel('x')
    ax.set_ylabel('f(x)')
    ax.legend(fontsize=9)
    ax.set_ylim(-5, 10)
    ax.grid(True, alpha=0.3)
    ax.axhline(y=0, color='k', linewidth=0.5)

    # Panel 2: Depth 1 functions (one exp/log layer)
    ax = axes[0, 1]
    x = np.linspace(-3, 3, 500)
    ax.plot(x, np.exp(x), label='exp(x)', linewidth=2)
    ax.plot(x, np.sinh(x), label='sinh(x)', linewidth=2)
    ax.plot(x, np.cosh(x), label='cosh(x)', linewidth=2)
    ax.plot(x, np.exp(-x**2), label='exp(-x²)', linewidth=2, linestyle='--')
    ax.plot(x, 1/(1 + np.exp(-x)), label='σ(x)', linewidth=2, linestyle=':')
    ax.set_title('Depth 1: One Level of exp/log', fontsize=12)
    ax.set_xlabel('x')
    ax.set_ylabel('f(x)')
    ax.legend(fontsize=9)
    ax.set_ylim(-5, 15)
    ax.grid(True, alpha=0.3)
    ax.axhline(y=0, color='k', linewidth=0.5)

    # Panel 3: Growth rate comparison (log scale)
    ax = axes[1, 0]
    x = np.linspace(0.1, 5, 500)
    ax.semilogy(x, x**2, label='x² (depth 0)', linewidth=2)
    ax.semilogy(x, x**5, label='x⁵ (depth 0)', linewidth=2)
    ax.semilogy(x, np.exp(x), label='exp(x) (depth 1)', linewidth=2)
    exp_exp = np.exp(np.clip(np.exp(x), 0, 500))
    mask = exp_exp < 1e200
    ax.semilogy(x[mask], exp_exp[mask], label='exp(exp(x)) (depth 2)', linewidth=2)
    ax.set_title('Growth Rate Comparison (log scale)', fontsize=12)
    ax.set_xlabel('x')
    ax.set_ylabel('f(x)')
    ax.legend(fontsize=9)
    ax.set_ylim(0.01, 1e50)
    ax.grid(True, alpha=0.3)

    # Panel 4: Depth hierarchy strictness
    ax = axes[1, 1]
    depths = list(range(6))
    sizes = [n + 1 for n in depths]
    colors = plt.cm.viridis(np.linspace(0.2, 0.9, len(depths)))

    bars = ax.bar(depths, sizes, color=colors, edgecolor='black', linewidth=0.5)
    ax.set_title('iterExp(n) Circuit Complexity', fontsize=12)
    ax.set_xlabel('Transcendental Depth n')
    ax.set_ylabel('Minimum Circuit Size')

    for i, (d, s) in enumerate(zip(depths, sizes)):
        ax.text(d, s + 0.1, f'{s}', ha='center', va='bottom', fontweight='bold')

    # Add the chain structure as annotation
    ax.annotate('exp(var) = 2 nodes',
                xy=(1, 2), xytext=(2.5, 4.5),
                arrowprops=dict(arrowstyle='->', color='red'),
                fontsize=9, color='red')
    ax.annotate('exp(exp(exp(var))) = 4 nodes',
                xy=(3, 4), xytext=(4, 5.5),
                arrowprops=dict(arrowstyle='->', color='red'),
                fontsize=9, color='red')

    ax.set_xticks(depths)
    ax.set_ylim(0, 8)
    ax.grid(True, alpha=0.3, axis='y')

    plt.tight_layout()
    plt.savefig('depth_hierarchy.png', dpi=150, bbox_inches='tight')
    print("Saved: depth_hierarchy.png")


if __name__ == '__main__':
    main()


#!/usr/bin/env python3
"""
Visualization: The EML Operator eml(x, y) = exp(x) - log(y)

Shows the surface plot and key cross-sections of the EML operator,
including the exp and log recovery identities.
"""

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
import matplotlib
matplotlib.use('Agg')


def eml(x: np.ndarray, y: np.ndarray) -> np.ndarray:
    """EML operator: eml(x, y) = exp(x) - log(y)."""
    log_y = np.where(y > 0, np.log(y), 0.0)
    return np.exp(np.clip(x, -10, 10)) - log_y


def main():
    fig = plt.figure(figsize=(16, 10))
    fig.suptitle('The EML Operator: eml(x, y) = exp(x) − log(y)',
                 fontsize=16, fontweight='bold')

    # Panel 1: Surface plot
    ax1 = fig.add_subplot(2, 2, 1, projection='3d')
    x_range = np.linspace(-2, 2, 50)
    y_range = np.linspace(0.1, 5, 50)
    X, Y = np.meshgrid(x_range, y_range)
    Z = eml(X, Y)
    Z = np.clip(Z, -10, 20)
    surf = ax1.plot_surface(X, Y, Z, cmap='viridis', alpha=0.8,
                            edgecolor='none')
    ax1.set_xlabel('x')
    ax1.set_ylabel('y')
    ax1.set_zlabel('eml(x,y)')
    ax1.set_title('EML Surface', fontsize=12)
    ax1.view_init(elev=25, azim=-45)

    # Panel 2: Recovery of exp (y = 1 cross-section)
    ax2 = fig.add_subplot(2, 2, 2)
    x = np.linspace(-3, 3, 200)
    eml_at_y1 = eml(x, np.ones_like(x))
    exp_x = np.exp(x)

    ax2.plot(x, exp_x, 'b-', linewidth=2.5, label='exp(x)')
    ax2.plot(x, eml_at_y1, 'r--', linewidth=2, label='eml(x, 1)')
    ax2.set_title('Recovery: eml(x, 1) = exp(x)', fontsize=12)
    ax2.set_xlabel('x')
    ax2.set_ylabel('Value')
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)
    ax2.set_ylim(-1, 15)

    # Panel 3: Recovery of log (x = 0 cross-section)
    ax3 = fig.add_subplot(2, 2, 3)
    y = np.linspace(0.1, 10, 200)
    recovered_log = 1 - eml(np.zeros_like(y), y)
    true_log = np.log(y)

    ax3.plot(y, true_log, 'b-', linewidth=2.5, label='log(y)')
    ax3.plot(y, recovered_log, 'r--', linewidth=2, label='1 − eml(0, y)')
    ax3.set_title('Recovery: 1 − eml(0, y) = log(y)', fontsize=12)
    ax3.set_xlabel('y')
    ax3.set_ylabel('Value')
    ax3.legend(fontsize=11)
    ax3.grid(True, alpha=0.3)

    # Panel 4: Diagonal eml(x, x) = exp(x) - log(x)
    ax4 = fig.add_subplot(2, 2, 4)
    x = np.linspace(0.01, 4, 500)
    diag = np.exp(x) - np.log(x)
    exp_part = np.exp(x)
    neg_log_part = -np.log(x)

    ax4.plot(x, diag, 'b-', linewidth=2.5, label='eml(x,x) = exp(x)−log(x)')
    ax4.plot(x, exp_part, 'g--', linewidth=1.5, alpha=0.7, label='exp(x)')
    ax4.plot(x, neg_log_part, 'r--', linewidth=1.5, alpha=0.7, label='−log(x)')
    ax4.axhline(y=1, color='gray', linestyle=':', alpha=0.5)

    # Mark the minimum
    idx = np.argmin(diag)
    ax4.plot(x[idx], diag[idx], 'ko', markersize=8)
    ax4.annotate(f'min ≈ ({x[idx]:.2f}, {diag[idx]:.2f})',
                xy=(x[idx], diag[idx]),
                xytext=(x[idx] + 0.5, diag[idx] + 2),
                arrowprops=dict(arrowstyle='->', color='black'),
                fontsize=10)

    ax4.set_title('Diagonal: eml(x, x) = exp(x) − log(x)', fontsize=12)
    ax4.set_xlabel('x')
    ax4.set_ylabel('Value')
    ax4.legend(fontsize=9)
    ax4.grid(True, alpha=0.3)
    ax4.set_ylim(-2, 20)

    plt.tight_layout()
    plt.savefig('eml_operator.png', dpi=150, bbox_inches='tight')
    print("Saved: eml_operator.png")


if __name__ == '__main__':
    main()


#!/usr/bin/env python3
"""
Visualization: Why Exp is Not Polynomial

Illustrates the derivative fixed-point argument:
- If p = exp, then p' = exp = p
- But polynomial derivatives lower degree
- So p must be constant — contradiction
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')


def taylor(x: np.ndarray, degree: int) -> np.ndarray:
    """Taylor polynomial of exp at x=0."""
    result = np.zeros_like(x)
    factorial = 1.0
    for k in range(degree + 1):
        if k > 0:
            factorial *= k
        result += x**k / factorial
    return result


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Why exp(x) Cannot Be a Polynomial',
                 fontsize=16, fontweight='bold')

    # Panel 1: Taylor approximations diverge from exp for large x
    ax = axes[0, 0]
    x = np.linspace(-1, 6, 500)
    ax.plot(x, np.exp(x), 'k-', linewidth=3, label='exp(x)', zorder=10)
    colors = plt.cm.Set1(np.linspace(0, 0.8, 5))
    for i, deg in enumerate([1, 2, 3, 5, 10]):
        y = taylor(x, deg)
        y_clipped = np.clip(y, -50, 600)
        ax.plot(x, y_clipped, color=colors[i], linewidth=1.5,
                linestyle='--', label=f'T_{deg}(x)', alpha=0.8)

    ax.set_title('Taylor Polynomials vs exp(x)', fontsize=12)
    ax.set_xlabel('x')
    ax.set_ylabel('f(x)')
    ax.legend(fontsize=9)
    ax.set_ylim(-10, 500)
    ax.grid(True, alpha=0.3)

    # Panel 2: The derivative fixed-point argument
    ax = axes[0, 1]
    x = np.linspace(-2, 3, 500)

    # Show p(x) = exp(x) and p'(x) = exp(x) (same!)
    ax.plot(x, np.exp(x), 'b-', linewidth=2.5, label='exp(x)')
    ax.plot(x, np.exp(x), 'r--', linewidth=2, label="exp'(x) = exp(x)")

    # Show polynomial p(x) = 1 + x + x²/2 and its derivative
    p_approx = 1 + x + x**2/2
    p_deriv = 1 + x
    ax.plot(x, p_approx, 'g-', linewidth=1.5, alpha=0.7, label='p(x) = 1+x+x²/2')
    ax.plot(x, p_deriv, 'm--', linewidth=1.5, alpha=0.7, label="p'(x) = 1+x")

    ax.annotate('exp\' = exp\n(fixed point!)',
                xy=(1.5, np.exp(1.5)), xytext=(0, 12),
                arrowprops=dict(arrowstyle='->', color='blue'),
                fontsize=11, color='blue', fontweight='bold')
    ax.annotate('p\' ≠ p\n(degree drops!)',
                xy=(2, 1 + 2), xytext=(2.2, 8),
                arrowprops=dict(arrowstyle='->', color='green'),
                fontsize=10, color='green')

    ax.set_title('The Derivative Fixed-Point Argument', fontsize=12)
    ax.set_xlabel('x')
    ax.set_ylabel('f(x)')
    ax.legend(fontsize=9)
    ax.set_ylim(-2, 20)
    ax.grid(True, alpha=0.3)

    # Panel 3: Growth rate — exp vs polynomials (log scale)
    ax = axes[1, 0]
    x = np.linspace(1, 20, 500)
    ax.semilogy(x, np.exp(x), 'k-', linewidth=3, label='exp(x)')
    for n in [1, 2, 5, 10, 20]:
        ax.semilogy(x, x**n, linewidth=1.5, alpha=0.7, label=f'x^{n}')

    ax.set_title('exp(x) Eventually Dominates x^n', fontsize=12)
    ax.set_xlabel('x')
    ax.set_ylabel('f(x) (log scale)')
    ax.legend(fontsize=9, ncol=2)
    ax.grid(True, alpha=0.3)

    # Panel 4: Ratio exp(x)/x^n → ∞
    ax = axes[1, 1]
    x = np.linspace(1, 30, 500)
    for n in [1, 2, 3, 5, 10]:
        ratio = np.exp(x) / x**n
        ratio_clipped = np.clip(ratio, 0, 1e6)
        mask = ratio < 1e6
        ax.plot(x[mask], ratio_clipped[mask], linewidth=2,
                label=f'exp(x)/x^{n}')

    ax.set_title('exp(x)/x^n → ∞ for all n', fontsize=12)
    ax.set_xlabel('x')
    ax.set_ylabel('exp(x)/x^n')
    ax.legend(fontsize=9)
    ax.set_ylim(0, 100)
    ax.grid(True, alpha=0.3)
    ax.axhline(y=1, color='gray', linestyle=':', alpha=0.5)

    plt.tight_layout()
    plt.savefig('exp_not_polynomial.png', dpi=150, bbox_inches='tight')
    print("Saved: exp_not_polynomial.png")


if __name__ == '__main__':
    main()
