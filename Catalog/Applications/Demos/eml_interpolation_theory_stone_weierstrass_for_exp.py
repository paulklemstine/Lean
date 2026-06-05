#!/usr/bin/env python3
"""
EML Interpolation Theory: Demonstrations

This script demonstrates key results from the EML Stone-Weierstrass theory:
1. EML term evaluation and point separation
2. Polynomial approximation via EML terms
3. Depth hierarchy visualization
4. Quantitative separation bounds
"""

import math
from typing import Callable, List, Tuple


# ============================================================
# EML Term Algebra (mirrors the Lean formalization)
# ============================================================

class EMLTerm:
    """Base class for EML terms."""
    def eval(self, x: float) -> float:
        raise NotImplementedError
    
    def width(self) -> int:
        raise NotImplementedError
    
    def depth(self) -> int:
        raise NotImplementedError


class Var(EMLTerm):
    def eval(self, x: float) -> float:
        return x
    def width(self) -> int:
        return 1
    def depth(self) -> int:
        return 0
    def __repr__(self):
        return "x"


class Const(EMLTerm):
    def __init__(self, c: float):
        self.c = c
    def eval(self, x: float) -> float:
        return self.c
    def width(self) -> int:
        return 1
    def depth(self) -> int:
        return 0
    def __repr__(self):
        return f"{self.c}"


class Add(EMLTerm):
    def __init__(self, t1: EMLTerm, t2: EMLTerm):
        self.t1, self.t2 = t1, t2
    def eval(self, x: float) -> float:
        return self.t1.eval(x) + self.t2.eval(x)
    def width(self) -> int:
        return self.t1.width() + self.t2.width()
    def depth(self) -> int:
        return max(self.t1.depth(), self.t2.depth()) + 1
    def __repr__(self):
        return f"({self.t1} + {self.t2})"


class Mul(EMLTerm):
    def __init__(self, t1: EMLTerm, t2: EMLTerm):
        self.t1, self.t2 = t1, t2
    def eval(self, x: float) -> float:
        return self.t1.eval(x) * self.t2.eval(x)
    def width(self) -> int:
        return self.t1.width() + self.t2.width()
    def depth(self) -> int:
        return max(self.t1.depth(), self.t2.depth()) + 1
    def __repr__(self):
        return f"({self.t1} * {self.t2})"


class ExpOf(EMLTerm):
    def __init__(self, t: EMLTerm):
        self.t = t
    def eval(self, x: float) -> float:
        val = self.t.eval(x)
        if val > 700:  # overflow protection
            return float('inf')
        return math.exp(val)
    def width(self) -> int:
        return self.t.width()
    def depth(self) -> int:
        return self.t.depth() + 1
    def __repr__(self):
        return f"exp({self.t})"


class LogOf(EMLTerm):
    def __init__(self, t: EMLTerm):
        self.t = t
    def eval(self, x: float) -> float:
        val = self.t.eval(x)
        if val <= 0:
            return 0.0  # matches Lean's Real.log convention
        return math.log(val)
    def width(self) -> int:
        return self.t.width()
    def depth(self) -> int:
        return self.t.depth() + 1
    def __repr__(self):
        return f"log({self.t})"


# ============================================================
# Demo 1: Point Separation
# ============================================================

def demo_point_separation():
    """Demonstrate that EML functions separate points on [0,1]."""
    print("=" * 60)
    print("DEMO 1: Point Separation")
    print("=" * 60)
    
    # The identity function (var) separates all distinct points
    var = Var()
    x1, x2 = 0.3, 0.7
    print(f"\nPoints: x₁ = {x1}, x₂ = {x2}")
    print(f"var(x₁) = {var.eval(x1)}, var(x₂) = {var.eval(x2)}")
    print(f"Separated: {var.eval(x1) != var.eval(x2)}")
    
    # exp(ax) also separates for a ≠ 0
    for a in [1.0, 2.0, -1.0]:
        t = ExpOf(Mul(Const(a), Var()))
        print(f"\nexp({a}·x): f(x₁) = {t.eval(x1):.6f}, f(x₂) = {t.eval(x2):.6f}")
        print(f"  Separation = |f(x₁) - f(x₂)| = {abs(t.eval(x1) - t.eval(x2)):.6f}")
    print()


# ============================================================
# Demo 2: Polynomial Approximation
# ============================================================

def eml_power(n: int) -> EMLTerm:
    """Construct x^n as an EML term."""
    if n == 0:
        return Const(1.0)
    return Mul(eml_power(n - 1), Var())


def eml_polynomial(coeffs: List[float]) -> EMLTerm:
    """Construct a polynomial in Horner form."""
    if not coeffs:
        return Const(0.0)
    if len(coeffs) == 1:
        return Const(coeffs[0])
    # a₀ + x * (a₁ + x * (a₂ + ...))
    return Add(Const(coeffs[0]), Mul(Var(), eml_polynomial(coeffs[1:])))


def demo_polynomial_approximation():
    """Demonstrate polynomial representation via EML terms."""
    print("=" * 60)
    print("DEMO 2: Polynomial Approximation")
    print("=" * 60)
    
    # x^2 via repeated multiplication
    t_x2 = eml_power(2)
    print(f"\nx² term: {t_x2}")
    print(f"  Width = {t_x2.width()}, Depth = {t_x2.depth()}")
    for x in [0.0, 0.5, 1.0, 2.0]:
        print(f"  eval({x}) = {t_x2.eval(x):.4f} (expected {x**2:.4f})")
    
    # Polynomial 1 + 2x + 3x² in Horner form
    poly = eml_polynomial([1.0, 2.0, 3.0])
    print(f"\n1 + 2x + 3x² term: {poly}")
    print(f"  Width = {poly.width()}, Depth = {poly.depth()}")
    for x in [0.0, 0.5, 1.0]:
        expected = 1.0 + 2.0 * x + 3.0 * x * x
        print(f"  eval({x}) = {poly.eval(x):.4f} (expected {expected:.4f})")
    print()


# ============================================================
# Demo 3: Depth Hierarchy
# ============================================================

def iter_exp(k: int, x: float) -> float:
    """k-fold iterated exponential."""
    result = x
    for _ in range(k):
        if result > 700:
            return float('inf')
        result = math.exp(result)
    return result


def eml_iter_exp(k: int) -> EMLTerm:
    """EML term for k-fold iterated exponential."""
    if k == 0:
        return Var()
    return ExpOf(eml_iter_exp(k - 1))


def demo_depth_hierarchy():
    """Demonstrate the strict depth hierarchy for iterated exponentials."""
    print("=" * 60)
    print("DEMO 3: Depth Hierarchy")
    print("=" * 60)
    
    print("\nIterated exponentials at x = 1:")
    for k in range(5):
        t = eml_iter_exp(k)
        val = t.eval(1.0)
        print(f"  exp^{k}(1) = {val:.6f}  [width={t.width()}, depth={t.depth()}]")
    
    print("\nGrowth comparison at x = 2:")
    for k in range(4):
        val_k = iter_exp(k, 2.0)
        val_k1 = iter_exp(k + 1, 2.0)
        if val_k > 0 and not math.isinf(val_k1):
            ratio = val_k1 / val_k
            print(f"  exp^{k+1}(2) / exp^{k}(2) = {ratio:.2f}")
        else:
            print(f"  exp^{k+1}(2) / exp^{k}(2) = ∞ (overflow)")
    
    print("\nDepth-1, Width-1 Classification:")
    terms = [
        ("const(π)", Const(math.pi)),
        ("var", Var()),
        ("exp(var)", ExpOf(Var())),
        ("exp(const(1))", ExpOf(Const(1.0))),
    ]
    for name, t in terms:
        vals = [t.eval(x) for x in [0.0, 0.5, 1.0]]
        print(f"  {name}: width={t.width()}, depth={t.depth()}, "
              f"values at 0,0.5,1 = [{vals[0]:.4f}, {vals[1]:.4f}, {vals[2]:.4f}]")
    print()


# ============================================================
# Demo 4: Quantitative Separation Bound
# ============================================================

def demo_exp_separation():
    """Demonstrate the exponential separation lower bound."""
    print("=" * 60)
    print("DEMO 4: Exponential Separation Bound")
    print("=" * 60)
    
    print("\n|exp(x) - exp(y)| ≥ |x - y| * exp(min(x,y))")
    print()
    
    test_pairs = [
        (0.0, 1.0),
        (1.0, 2.0),
        (0.0, 0.1),
        (-1.0, 1.0),
        (2.0, 3.0),
    ]
    
    for x, y in test_pairs:
        lhs = abs(math.exp(x) - math.exp(y))
        rhs = abs(x - y) * math.exp(min(x, y))
        holds = lhs >= rhs - 1e-10  # numerical tolerance
        print(f"  x={x:5.1f}, y={y:5.1f}: |exp(x)-exp(y)| = {lhs:10.6f} >= "
              f"|x-y|*exp(min) = {rhs:10.6f}  [{'+' if holds else 'FAIL'}]")
    print()


# ============================================================
# Demo 5: EML Complexity Analysis
# ============================================================

def demo_complexity():
    """Analyze complexity of various EML terms."""
    print("=" * 60)
    print("DEMO 5: EML Complexity Analysis")
    print("=" * 60)
    
    terms = [
        ("x", Var()),
        ("x²", eml_power(2)),
        ("x⁵", eml_power(5)),
        ("exp(x)", ExpOf(Var())),
        ("exp(exp(x))", ExpOf(ExpOf(Var()))),
        ("exp(exp(exp(x)))", ExpOf(ExpOf(ExpOf(Var())))),
        ("1 + x + x²", eml_polynomial([1.0, 1.0, 1.0])),
        ("x·exp(x)", Mul(Var(), ExpOf(Var()))),
    ]
    
    print(f"\n{'Term':<25} {'Width':>6} {'Depth':>6} {'Total Cost':>12}")
    print("-" * 55)
    for name, t in terms:
        w, d = t.width(), t.depth()
        cost = w * (2 ** d)
        print(f"  {name:<23} {w:>6} {d:>6} {cost:>12}")
    print()


if __name__ == "__main__":
    demo_point_separation()
    demo_polynomial_approximation()
    demo_depth_hierarchy()
    demo_exp_separation()
    demo_complexity()
    print("All demos completed successfully!")


#!/usr/bin/env python3
"""Visualization: EML Depth Hierarchy — Growth rates of iterated exponentials."""

import math

def iterated_exponential(k, x):
    result = x
    for _ in range(k):
        if result > 700:
            return float('inf')
        result = math.exp(result)
    return result

def main():
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
        import numpy as np
    except ImportError:
        print("matplotlib/numpy not available; skipping visualization.")
        return

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Plot 1: Iterated exponentials on [0, 2]
    ax1 = axes[0]
    xs = np.linspace(0, 2, 500)
    colors = ['#2196F3', '#4CAF50', '#FF9800', '#F44336', '#9C27B0']
    labels = ['$x$', '$e^x$', '$e^{e^x}$', '$e^{e^{e^x}}$']

    for k in range(4):
        ys = []
        for x in xs:
            val = iterated_exponential(k, float(x))
            ys.append(min(val, 50))  # cap for visualization
        ax1.plot(xs, ys, color=colors[k], linewidth=2, label=labels[k])

    ax1.set_xlabel('x', fontsize=14)
    ax1.set_ylabel('$\\exp^{(k)}(x)$', fontsize=14)
    ax1.set_title('EML Depth Hierarchy: Iterated Exponentials', fontsize=14)
    ax1.legend(fontsize=12)
    ax1.set_ylim(0, 50)
    ax1.grid(True, alpha=0.3)

    # Plot 2: Width-Depth complexity landscape
    ax2 = axes[1]
    widths = range(1, 11)
    depths = range(0, 6)

    # Create heatmap of total cost
    cost_matrix = np.zeros((len(list(depths)), len(list(widths))))
    for i, d in enumerate(depths):
        for j, w in enumerate(widths):
            cost_matrix[i, j] = math.log2(w * 2**d + 1)

    im = ax2.imshow(cost_matrix, aspect='auto', cmap='YlOrRd',
                     extent=[0.5, 10.5, 5.5, -0.5])
    ax2.set_xlabel('Width', fontsize=14)
    ax2.set_ylabel('Depth', fontsize=14)
    ax2.set_title('EML Total Cost: $\\log_2(w \\cdot 2^d)$', fontsize=14)
    plt.colorbar(im, ax=ax2, label='$\\log_2$(total cost)')

    # Mark specific terms
    terms = [
        (1, 0, 'var'),
        (1, 1, 'exp(x)'),
        (1, 2, 'exp²(x)'),
        (3, 2, 'x²'),
        (5, 4, 'poly'),
    ]
    for w, d, name in terms:
        ax2.plot(w, d, 'ko', markersize=8)
        ax2.annotate(name, (w, d), textcoords="offset points",
                    xytext=(10, -5), fontsize=10, fontweight='bold')

    plt.tight_layout()
    plt.savefig('eml_depth_hierarchy.png', dpi=150, bbox_inches='tight')
    print("Saved eml_depth_hierarchy.png")

if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""Visualization: Exponential Separation Bound."""

import math

def main():
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
        import numpy as np
    except ImportError:
        print("matplotlib/numpy not available; skipping visualization.")
        return

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Plot 1: |exp(x) - exp(y)| vs |x-y| * exp(min(x,y)) for fixed y=0
    ax1 = axes[0]
    y_fixed = 0.0
    xs = np.linspace(0.01, 3, 200)

    actual = np.abs(np.exp(xs) - np.exp(y_fixed))
    bound = np.abs(xs - y_fixed) * np.exp(np.minimum(xs, y_fixed))

    ax1.fill_between(xs, bound, actual, alpha=0.3, color='#4CAF50', label='Gap (theorem margin)')
    ax1.plot(xs, actual, 'b-', linewidth=2, label='$|e^x - e^0|$')
    ax1.plot(xs, bound, 'r--', linewidth=2, label='$|x| \\cdot e^{\\min(x,0)}$')
    ax1.set_xlabel('x', fontsize=14)
    ax1.set_ylabel('Separation', fontsize=14)
    ax1.set_title('Exp Separation Bound (y = 0)', fontsize=14)
    ax1.legend(fontsize=12)
    ax1.grid(True, alpha=0.3)

    # Plot 2: Tightness ratio as function of separation distance
    ax2 = axes[1]
    deltas = np.linspace(0.01, 5, 200)
    y_vals = [0, 1, 2, -1]
    colors = ['#2196F3', '#4CAF50', '#FF9800', '#F44336']

    for y_base, color in zip(y_vals, colors):
        ratios = []
        for delta in deltas:
            x_val = y_base + delta
            actual_sep = abs(math.exp(x_val) - math.exp(y_base))
            bound_sep = delta * math.exp(min(x_val, y_base))
            ratios.append(actual_sep / bound_sep if bound_sep > 0 else 1)
        ax2.plot(deltas, ratios, color=color, linewidth=2, label=f'y = {y_base}')

    ax2.axhline(y=1, color='gray', linestyle=':', alpha=0.5, label='Tight bound')
    ax2.set_xlabel('$|x - y|$', fontsize=14)
    ax2.set_ylabel('Actual / Bound ratio', fontsize=14)
    ax2.set_title('Tightness of Separation Bound', fontsize=14)
    ax2.legend(fontsize=12)
    ax2.grid(True, alpha=0.3)
    ax2.set_ylim(0.8, 5)

    plt.tight_layout()
    plt.savefig('eml_separation_bound.png', dpi=150, bbox_inches='tight')
    print("Saved eml_separation_bound.png")

if __name__ == "__main__":
    main()
