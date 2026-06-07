#!/usr/bin/env python3
"""
EML Approximation Filtration — Demonstration

This script demonstrates the key concepts from the EML Approximation Filtration:
1. Polynomial (Horner) approximation of continuous functions (depth 0)
2. EML expression evaluation with transcendental operations
3. Composition error propagation (the contraction principle)
4. Information-theoretic decay curves
5. Depth-size product analysis for iterated exponentials
"""

import math
import numpy as np

# ============================================================
# Section 1: EML Expression Evaluator
# ============================================================

class EMLNode:
    """An EML expression tree node."""
    pass

class Var(EMLNode):
    def eval(self, x): return x
    def depth(self): return 0
    def size(self): return 1
    def transc(self): return 0
    def __repr__(self): return "x"

class Lit(EMLNode):
    def __init__(self, c): self.c = c
    def eval(self, x): return np.full_like(np.atleast_1d(x), self.c, dtype=float)
    def depth(self): return 0
    def size(self): return 1
    def transc(self): return 0
    def __repr__(self): return f"{self.c:.4g}"

class Add(EMLNode):
    def __init__(self, a, b): self.a, self.b = a, b
    def eval(self, x): return self.a.eval(x) + self.b.eval(x)
    def depth(self): return max(self.a.depth(), self.b.depth())
    def size(self): return 1 + self.a.size() + self.b.size()
    def transc(self): return self.a.transc() + self.b.transc()
    def __repr__(self): return f"({self.a} + {self.b})"

class Mul(EMLNode):
    def __init__(self, a, b): self.a, self.b = a, b
    def eval(self, x): return self.a.eval(x) * self.b.eval(x)
    def depth(self): return max(self.a.depth(), self.b.depth())
    def size(self): return 1 + self.a.size() + self.b.size()
    def transc(self): return self.a.transc() + self.b.transc()
    def __repr__(self): return f"({self.a} * {self.b})"

class Neg(EMLNode):
    def __init__(self, a): self.a = a
    def eval(self, x): return -self.a.eval(x)
    def depth(self): return self.a.depth()
    def size(self): return 1 + self.a.size()
    def transc(self): return self.a.transc()
    def __repr__(self): return f"(-{self.a})"

class Exp(EMLNode):
    def __init__(self, a): self.a = a
    def eval(self, x): return np.exp(self.a.eval(x))
    def depth(self): return 1 + self.a.depth()
    def size(self): return 1 + self.a.size()
    def transc(self): return 1 + self.a.transc()
    def __repr__(self): return f"exp({self.a})"

class Log(EMLNode):
    def __init__(self, a): self.a = a
    def eval(self, x): return np.log(np.maximum(self.a.eval(x), 1e-300))
    def depth(self): return 1 + self.a.depth()
    def size(self): return 1 + self.a.size()
    def transc(self): return 1 + self.a.transc()
    def __repr__(self): return f"log({self.a})"


def horner_eml(coeffs):
    """Build an EML expression tree for a polynomial using Horner's method."""
    n = len(coeffs) - 1
    if n == 0:
        return Lit(coeffs[0])
    else:
        inner = horner_eml(coeffs[1:])
        return Add(Lit(coeffs[0]), Mul(Var(), inner))


def iterated_exp_node(n):
    """Build the canonical EML expression for exp^n(x)."""
    if n == 0:
        return Var()
    else:
        return Exp(iterated_exp_node(n - 1))


def iterated_exp(n, x):
    """Evaluate the n-fold iterated exponential at x."""
    result = x
    for _ in range(n):
        result = np.exp(result)
    return result


# ============================================================
# Section 2: Demonstrations
# ============================================================

def demo_horner_approximation():
    """Demonstrate polynomial approximation of sin(x) via Horner's method."""
    print("=" * 60)
    print("Demo 1: Polynomial Approximation (Depth 0)")
    print("=" * 60)

    x = np.linspace(0, np.pi, 1000)
    target = np.sin(x)

    # Taylor series coefficients for sin(x) around 0
    for degree in [3, 5, 7, 9, 11]:
        coeffs = []
        for k in range(degree + 1):
            if k % 2 == 0:
                coeffs.append(0.0)
            else:
                sign = (-1) ** ((k - 1) // 2)
                coeffs.append(sign / float(math.factorial(k)))

        expr = horner_eml(coeffs)
        approx = expr.eval(x)
        max_err = np.max(np.abs(target - approx))

        print(f"  Degree {degree:2d}: size={expr.size():3d}, "
              f"depth={expr.depth()}, max error={max_err:.2e}")

    print()


def demo_iterated_exponentials():
    """Show the depth hierarchy for iterated exponentials."""
    print("=" * 60)
    print("Demo 2: Iterated Exponentials & Depth Hierarchy")
    print("=" * 60)

    for n in range(5):
        expr = iterated_exp_node(n)
        val_at_1 = iterated_exp(n, 1.0)
        print(f"  iterExp({n}, 1.0) = {val_at_1:.6e}")
        print(f"    expLogDepth = {expr.depth()}, nodeCount = {expr.size()}, "
              f"transcCount = {expr.transc()}")
        print(f"    depth × nodeCount = {expr.depth() * expr.size()}, "
              f"depth × transcCount = {expr.depth() * expr.transc()}")

    print()


def demo_composition_contraction():
    """Demonstrate the composition error propagation principle."""
    print("=" * 60)
    print("Demo 3: Composition Contraction Principle")
    print("=" * 60)

    x = np.linspace(0, 1, 1000)

    # Inner: approximate sin(x) with degree-5 polynomial
    inner_coeffs = [0, 1, 0, -1/6, 0, 1/120]
    inner_expr = horner_eml(inner_coeffs)
    inner_true = np.sin(x)
    inner_approx = inner_expr.eval(x)
    eps2 = np.max(np.abs(inner_true - inner_approx))

    # Outer: approximate exp(y) with degree-4 polynomial on [0, 1]
    outer_coeffs = [1, 1, 0.5, 1/6, 1/24]
    outer_expr = horner_eml(outer_coeffs)
    outer_true = np.exp
    y_test = np.linspace(0, 1, 1000)
    eps1 = np.max(np.abs(outer_true(y_test) - outer_expr.eval(y_test)))

    # Lipschitz constant of exp on [0, 1] is e^1 ≈ 2.718
    L = np.exp(1.0)

    # Predicted bound: eps1 + L * eps2
    predicted_bound = eps1 + L * eps2

    # Actual composed error
    composed_true = np.exp(np.sin(x))
    composed_approx = outer_expr.eval(inner_expr.eval(x))
    actual_error = np.max(np.abs(composed_true - composed_approx))

    print(f"  Inner error (sin approx): ε₂ = {eps2:.6e}")
    print(f"  Outer error (exp approx): ε₁ = {eps1:.6e}")
    print(f"  Lipschitz constant L = e = {L:.4f}")
    print(f"  Predicted bound (ε₁ + L·ε₂) = {predicted_bound:.6e}")
    print(f"  Actual composed error     = {actual_error:.6e}")
    print(f"  Bound is {'tight' if actual_error > 0.5 * predicted_bound else 'loose'} "
          f"(ratio = {actual_error / predicted_bound:.4f})")
    print()


def demo_information_decay():
    """Demonstrate the information-theoretic decay model."""
    print("=" * 60)
    print("Demo 4: Information-Theoretic Decay")
    print("=" * 60)

    K0 = 100.0  # Initial information content
    for alpha in [0.9, 0.7, 0.5, 0.3]:
        print(f"  Contraction factor α = {alpha}:")
        for l in [1, 5, 10, 20, 50]:
            retained = alpha ** l * K0
            print(f"    After {l:2d} layers: retained = {retained:8.4f} "
                  f"({retained/K0*100:5.1f}% of initial)")
        print()


def demo_filtration_levels():
    """Show which functions are accessible at each filtration level."""
    print("=" * 60)
    print("Demo 5: Filtration Levels")
    print("=" * 60)

    x = np.linspace(0, 2, 1000)

    functions = [
        ("x²", lambda x: x**2, 0),
        ("x³ + 2x", lambda x: x**3 + 2*x, 0),
        ("exp(x)", lambda x: np.exp(x), 1),
        ("x·exp(x)", lambda x: x * np.exp(x), 1),
        ("exp(exp(x))", lambda x: np.exp(np.exp(x)), 2),
        ("log(1+x)", lambda x: np.log(1+x), 1),
    ]

    print(f"  {'Function':<16} {'Min Depth':>10} {'Range on [0,2]':>20}")
    print(f"  {'─' * 16} {'─' * 10} {'─' * 20}")
    for name, f, depth in functions:
        vals = f(x)
        print(f"  {name:<16} {depth:>10} {f'[{vals.min():.2f}, {vals.max():.2f}]':>20}")

    print()


if __name__ == "__main__":
    demo_horner_approximation()
    demo_iterated_exponentials()
    demo_composition_contraction()
    demo_information_decay()
    demo_filtration_levels()

    print("=" * 60)
    print("All demonstrations completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: EML Approximation Filtration Depth Hierarchy

Shows how different filtration levels (depths) capture increasingly complex functions,
and demonstrates the composition error propagation principle.
"""

import math
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec


def iterated_exp(n, x):
    """Compute exp^n(x)."""
    result = np.copy(x)
    for _ in range(n):
        result = np.exp(result)
    return result


def horner_eval(coeffs, x):
    """Evaluate polynomial via Horner's method."""
    result = np.full_like(x, coeffs[-1])
    for c in reversed(coeffs[:-1]):
        result = c + x * result
    return result


def main():
    fig = plt.figure(figsize=(16, 12))
    gs = GridSpec(2, 2, hspace=0.3, wspace=0.3)

    # ── Panel 1: Depth Hierarchy ──
    ax1 = fig.add_subplot(gs[0, 0])
    x = np.linspace(0, 1.5, 500)
    colors = ['#2196F3', '#4CAF50', '#FF9800', '#F44336', '#9C27B0']

    for n in range(5):
        y = iterated_exp(n, x)
        y_clipped = np.clip(y, 0, 50)
        ax1.plot(x, y_clipped, color=colors[n], linewidth=2,
                 label=f'exp$^{n}$(x), depth={n}')

    ax1.set_xlabel('x', fontsize=12)
    ax1.set_ylabel('f(x)', fontsize=12)
    ax1.set_title('EML Depth Hierarchy: Iterated Exponentials', fontsize=13)
    ax1.legend(fontsize=9)
    ax1.set_ylim(0, 50)
    ax1.grid(True, alpha=0.3)

    # ── Panel 2: Polynomial Approximation Error ──
    ax2 = fig.add_subplot(gs[0, 1])
    x = np.linspace(0, np.pi, 1000)
    target = np.sin(x)
    degrees = [3, 5, 7, 9, 11, 15]
    errors = []

    for deg in degrees:
        coeffs = []
        for k in range(deg + 1):
            if k % 2 == 0:
                coeffs.append(0.0)
            else:
                sign = (-1) ** ((k - 1) // 2)
                coeffs.append(sign / float(math.factorial(k)))
        approx = horner_eval(coeffs, x)
        max_err = np.max(np.abs(target - approx))
        errors.append(max_err)

    ax2.semilogy(degrees, errors, 'o-', color='#2196F3', linewidth=2, markersize=8)
    ax2.set_xlabel('Polynomial Degree (= expression size)', fontsize=12)
    ax2.set_ylabel('Max Approximation Error', fontsize=12)
    ax2.set_title('Depth-0 Approximation: sin(x) on [0, π]', fontsize=13)
    ax2.grid(True, alpha=0.3, which='both')

    # ── Panel 3: Composition Error Propagation ──
    ax3 = fig.add_subplot(gs[1, 0])
    eps_inner_vals = np.logspace(-4, 0, 50)
    eps_outer = 0.01
    lipschitz_constants = [1.0, np.e, np.e**2, np.e**3]

    for L in lipschitz_constants:
        total_error = eps_outer + L * eps_inner_vals
        ax3.loglog(eps_inner_vals, total_error, linewidth=2,
                   label=f'L = {L:.1f}')

    ax3.set_xlabel('Inner approximation error ε₂', fontsize=12)
    ax3.set_ylabel('Total composed error ε₁ + L·ε₂', fontsize=12)
    ax3.set_title('Composition Contraction Principle', fontsize=13)
    ax3.legend(fontsize=9)
    ax3.grid(True, alpha=0.3, which='both')

    # ── Panel 4: Information Decay ──
    ax4 = fig.add_subplot(gs[1, 1])
    depths = np.arange(0, 31)
    K0 = 100.0

    for alpha in [0.95, 0.9, 0.8, 0.7, 0.5]:
        retained = alpha ** depths * K0
        ax4.plot(depths, retained, linewidth=2, label=f'α = {alpha}')

    ax4.axhline(y=10, color='red', linestyle='--', alpha=0.5, label='Threshold')
    ax4.set_xlabel('Depth (number of layers)', fontsize=12)
    ax4.set_ylabel('Retained Information', fontsize=12)
    ax4.set_title('Information-Theoretic Decay', fontsize=13)
    ax4.legend(fontsize=9)
    ax4.grid(True, alpha=0.3)

    plt.suptitle('EML Approximation Filtration: Key Results',
                 fontsize=16, fontweight='bold', y=0.98)
    plt.savefig('eml_filtration_results.png', dpi=150, bbox_inches='tight')
    print("Saved: eml_filtration_results.png")


if __name__ == "__main__":
    main()
