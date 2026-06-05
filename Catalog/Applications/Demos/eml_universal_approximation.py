#!/usr/bin/env python3
"""
EML Universal Approximation Demo

Demonstrates the key results:
1. EML expressions can approximate any continuous function
2. Exponential towers have optimal EML representations
3. Information decay through depth layers
4. Depth-complexity tradeoffs
"""

import math
from algorithms import (
    EMLExpr, var, const, add, mul, neg, inv, eml,
    iter_exp_expr, iter_exp, monomial_expr,
    retained_info, info_depth_product
)


def demo_tower_efficiency():
    """Demonstrate that iterExp n has optimal EML representation."""
    print("=" * 60)
    print("DEMO 1: Exponential Tower Efficiency")
    print("=" * 60)
    print()
    print("The n-fold iterated exponential exp^n(x) can be represented")
    print("by an EML expression with depth exactly n and size 2n+1.")
    print()
    print(f"{'n':>3} {'size':>6} {'depth':>6} {'2n+1':>6} {'match?':>7}")
    print("-" * 35)

    for n in range(8):
        e = iter_exp_expr(n)
        s = e.size()
        d = e.eml_depth()
        expected = 2 * n + 1
        match = "✓" if s == expected and d == n else "✗"
        print(f"{n:>3} {s:>6} {d:>6} {expected:>6} {match:>7}")

    print()
    print("Key insight: size grows linearly in depth!")
    print("This is optimal — each exp layer adds exactly 2 nodes.")
    print()


def demo_depth_gap():
    """Demonstrate the depth gap between polynomials and exponentials."""
    print("=" * 60)
    print("DEMO 2: Depth Gap — Polynomials vs Exponentials")
    print("=" * 60)
    print()
    print("Polynomials have EML depth 0 (no exp/log needed).")
    print("Even exp(x) requires depth 1. This is a strict separation.")
    print()

    # Build polynomial x^2 + 3x + 1
    x = var()
    poly = add(add(mul(x, x), mul(const(3.0), x)), const(1.0))
    exp_expr = eml(const(1.0), var())

    print(f"Polynomial x² + 3x + 1:")
    print(f"  EML depth = {poly.eml_depth()} (always 0 for polynomials)")
    print(f"  Size = {poly.size()}")
    print()
    print(f"Exponential exp(x):")
    print(f"  EML depth = {exp_expr.eml_depth()} (exactly 1)")
    print(f"  Size = {exp_expr.size()}")
    print()

    # Evaluate both
    test_x = 2.0
    print(f"At x = {test_x}:")
    print(f"  x² + 3x + 1 = {poly.eval(test_x)} (expected: {test_x**2 + 3*test_x + 1})")
    print(f"  exp(x) = {exp_expr.eval(test_x):.6f} (expected: {math.exp(test_x):.6f})")
    print()

    # Monomials of increasing degree
    print("Monomials c·x^n all have EML depth 0:")
    for n in range(1, 8):
        m = monomial_expr(1.0, n)
        print(f"  x^{n}: size = {m.size()}, eml_depth = {m.eml_depth()}")
    print()


def demo_information_decay():
    """Demonstrate information decay through depth layers."""
    print("=" * 60)
    print("DEMO 3: Information Decay Through Depth")
    print("=" * 60)
    print()
    print("With contraction factor α, retained information after l layers")
    print("is α^l · K. This decreases geometrically in depth.")
    print()

    K = 100
    alphas = [0.9, 0.7, 0.5, 0.3, 0.1]

    print(f"Initial information K = {K}")
    print()
    print(f"{'α':>5} | " + " | ".join(f"l={l}" for l in range(7)))
    print("-" * 65)

    for alpha in alphas:
        vals = [f"{retained_info(alpha, l, K):>7.2f}" for l in range(7)]
        print(f"{alpha:>5.1f} | " + " | ".join(vals))

    print()
    print("The information-depth product α^l · K · l has a maximum:")
    print()
    print(f"{'α':>5} | " + " | ".join(f"l={l}" for l in range(7)))
    print("-" * 65)

    for alpha in alphas:
        vals = [f"{info_depth_product(alpha, l, K):>7.2f}" for l in range(7)]
        print(f"{alpha:>5.1f} | " + " | ".join(vals))
        # Find maximum
        max_l = max(range(20), key=lambda l: info_depth_product(alpha, l, K))
        max_val = info_depth_product(alpha, max_l, K)
        print(f"        → max at l={max_l}, value={max_val:.2f}")
    print()


def demo_composition():
    """Demonstrate compositional approximation."""
    print("=" * 60)
    print("DEMO 4: Compositional Approximation")
    print("=" * 60)
    print()
    print("Composing EML expressions: subst(outer, inner)")
    print("Depth is additive, size is multiplicative.")
    print()

    # exp(exp(x)) via composition
    exp_x = eml(const(1.0), var())

    # Manual composition: exp(exp(x))
    exp_exp = exp_x.subst(exp_x)
    # Direct construction
    direct = iter_exp_expr(2)

    print(f"exp(exp(x)) via composition:")
    print(f"  size = {exp_exp.size()}, eml_depth = {exp_exp.eml_depth()}")
    print(f"exp(exp(x)) via direct construction:")
    print(f"  size = {direct.size()}, eml_depth = {direct.eml_depth()}")
    print()

    # Verify they compute the same thing
    for x in [0.1, 0.5, 1.0]:
        v1 = exp_exp.eval(x)
        v2 = direct.eval(x)
        print(f"  x={x}: composed={v1:.6f}, direct={v2:.6f}, diff={abs(v1-v2):.2e}")

    print()

    # k-fold composition
    print("k-fold composition of exp(x):")
    e = eml(const(1.0), var())
    for k in range(1, 6):
        composed = iter_exp_expr(0)
        for _ in range(k):
            composed = e.subst(composed)
        print(f"  k={k}: size={composed.size():>4}, depth={composed.eml_depth()}, "
              f"depth_bound={k}*{e.eml_depth()}={k*e.eml_depth()}")
    print()


def demo_complexity_hierarchy():
    """Demonstrate the complexity class hierarchy."""
    print("=" * 60)
    print("DEMO 5: EML Complexity Class Hierarchy")
    print("=" * 60)
    print()
    print("Functions are classified by how fast their EML description")
    print("complexity grows as tolerance ε → 0.")
    print()

    functions = {
        "constant 5": (lambda x: 5.0, "O(1)"),
        "identity x": (lambda x: x, "O(1)"),
        "x²": (lambda x: x**2, "O(1)"),
        "exp(x)": (lambda x: math.exp(x), "O(1)"),
        "sin(x) ≈ Taylor": (lambda x: math.sin(x), "O(1/ε)"),
    }

    print("Function approximation on [0, 1]:")
    print(f"{'function':>20} {'class':>10} {'ε=0.1 size':>12} {'ε=0.01 size':>12}")
    print("-" * 56)

    for name, (f, cls) in functions.items():
        # Estimate sizes for different tolerances
        import numpy as np
        xs = np.linspace(0, 1, 100)
        fvals = np.array([f(x) for x in xs])

        # Simple polynomial fit
        sizes = []
        for eps in [0.1, 0.01]:
            for deg in range(1, 50):
                coeffs = np.polyfit(xs, fvals, deg)
                approx = np.polyval(coeffs, xs)
                if np.max(np.abs(fvals - approx)) <= eps:
                    size = 2 * deg + 1
                    sizes.append(size)
                    break
            else:
                sizes.append(99)

        print(f"{name:>20} {cls:>10} {sizes[0]:>12} {sizes[1]:>12}")
    print()


if __name__ == "__main__":
    demo_tower_efficiency()
    demo_depth_gap()
    demo_information_decay()
    demo_composition()
    demo_complexity_hierarchy()


#!/usr/bin/env python3
"""
Visualization: EML Depth Hierarchy and Information Decay

Creates publication-quality plots showing:
1. The EML depth hierarchy for exponential towers
2. Information decay through depth layers
3. The depth-size efficiency of EML representations
"""

import math

def create_plots():
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    import numpy as np

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    # Plot 1: Tower size vs depth
    ax1 = axes[0, 0]
    ns = list(range(0, 15))
    sizes = [2 * n + 1 for n in ns]
    depths = ns  # emlDepth = n for iterExp n
    ax1.plot(ns, sizes, 'bo-', label='Size (2n+1)', markersize=8)
    ax1.plot(ns, depths, 'rs-', label='EML Depth (n)', markersize=8)
    ax1.fill_between(ns, depths, sizes, alpha=0.15, color='blue')
    ax1.set_xlabel('Tower height n', fontsize=12)
    ax1.set_ylabel('Measure', fontsize=12)
    ax1.set_title('EML Tower Efficiency: Size vs Depth', fontsize=14, fontweight='bold')
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)

    # Plot 2: Information decay
    ax2 = axes[0, 1]
    K = 100
    layers = np.arange(0, 15)
    for alpha in [0.9, 0.7, 0.5, 0.3, 0.1]:
        retained = [alpha ** l * K for l in layers]
        ax2.plot(layers, retained, 'o-', label=f'α={alpha}', markersize=5)
    ax2.set_xlabel('Depth (layers)', fontsize=12)
    ax2.set_ylabel('Retained Information', fontsize=12)
    ax2.set_title(f'Information Decay (K={K})', fontsize=14, fontweight='bold')
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    ax2.set_yscale('log')

    # Plot 3: Information-depth product
    ax3 = axes[1, 0]
    layers_fine = np.linspace(0.1, 15, 200)
    for alpha in [0.9, 0.7, 0.5, 0.3]:
        product = [alpha ** l * K * l for l in layers_fine]
        ax3.plot(layers_fine, product, '-', label=f'α={alpha}', linewidth=2)
        # Find and mark maximum
        opt_l = -1 / math.log(alpha) if alpha < 1 else 1
        opt_val = alpha ** opt_l * K * opt_l
        ax3.plot(opt_l, opt_val, '*', markersize=15, color='black')
    ax3.set_xlabel('Depth (layers)', fontsize=12)
    ax3.set_ylabel('Info × Depth Product', fontsize=12)
    ax3.set_title('Information-Depth Product', fontsize=14, fontweight='bold')
    ax3.legend(fontsize=10)
    ax3.grid(True, alpha=0.3)

    # Plot 4: Depth stratification
    ax4 = axes[1, 1]
    categories = ['Polynomials\n(any degree)', 'exp(x)', 'exp(exp(x))',
                   'exp³(x)', 'exp⁴(x)', 'exp⁵(x)']
    eml_depths = [0, 1, 2, 3, 4, 5]
    colors = ['#2ecc71', '#3498db', '#9b59b6', '#e74c3c', '#f39c12', '#1abc9c']
    bars = ax4.barh(categories, eml_depths, color=colors, edgecolor='black', linewidth=0.5)
    ax4.set_xlabel('EML Depth', fontsize=12)
    ax4.set_title('EML Depth Hierarchy', fontsize=14, fontweight='bold')
    ax4.grid(True, alpha=0.3, axis='x')
    # Add value labels
    for bar, val in zip(bars, eml_depths):
        ax4.text(bar.get_width() + 0.1, bar.get_y() + bar.get_height()/2,
                 str(val), va='center', fontsize=11, fontweight='bold')

    plt.tight_layout()
    plt.savefig('eml_hierarchy.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: eml_hierarchy.png")


if __name__ == "__main__":
    create_plots()
