"""
Dual Numbers and Automatic Differentiation — Interactive Demo
=============================================================

This script demonstrates the theorems formally proved in Algebra/DualAutoDiff.lean:

1. The dual number ring R[ε]/(ε²) automatically computes derivatives
2. Evaluating p(a + bε) = p(a) + p'(a)·b·ε
3. The chain rule emerges from ring multiplication
4. Invertibility depends only on the real part

We implement dual numbers from scratch and show they match symbolic derivatives
exactly — no approximation, no symbolic manipulation needed.
"""

import numpy as np
import matplotlib.pyplot as plt
from typing import Callable, Tuple
import os

# ══════════════════════════════════════════════════════════════════════════════
# Part 1: The Dual Number Class
# ══════════════════════════════════════════════════════════════════════════════

class Dual:
    """
    A dual number a + bε where ε² = 0.

    This is the ring R[ε]/(ε²). The multiplication rule:
        (a + bε)(c + dε) = ac + (ad + bc)ε

    encodes the Leibniz product rule: (fg)' = f'g + fg'.
    """

    def __init__(self, real: float, dual: float = 0.0):
        self.real = real  # The "value" part
        self.dual = dual  # The "derivative" part (coefficient of ε)

    def __repr__(self):
        if self.dual >= 0:
            return f"{self.real:.6f} + {self.dual:.6f}ε"
        return f"{self.real:.6f} - {abs(self.dual):.6f}ε"

    def __add__(self, other):
        if isinstance(other, (int, float)):
            other = Dual(other)
        return Dual(self.real + other.real, self.dual + other.dual)

    def __radd__(self, other):
        return self.__add__(other)

    def __sub__(self, other):
        if isinstance(other, (int, float)):
            other = Dual(other)
        return Dual(self.real - other.real, self.dual - other.dual)

    def __rsub__(self, other):
        if isinstance(other, (int, float)):
            other = Dual(other)
        return other.__sub__(self)

    def __mul__(self, other):
        if isinstance(other, (int, float)):
            other = Dual(other)
        # (a + bε)(c + dε) = ac + (ad + bc)ε   [since ε² = 0]
        return Dual(
            self.real * other.real,
            self.real * other.dual + self.dual * other.real
        )

    def __rmul__(self, other):
        return self.__mul__(other)

    def __truediv__(self, other):
        if isinstance(other, (int, float)):
            other = Dual(other)
        # (a + bε)/(c + dε) = (a/c) + (bc - ad)/c² · ε
        if other.real == 0:
            raise ZeroDivisionError("Cannot divide by dual number with zero real part")
        return Dual(
            self.real / other.real,
            (self.dual * other.real - self.real * other.dual) / other.real**2
        )

    def __pow__(self, n):
        if isinstance(n, int):
            # (a + bε)^n = a^n + n·a^(n-1)·b·ε
            if n == 0:
                return Dual(1.0, 0.0)
            return Dual(self.real**n, n * self.real**(n - 1) * self.dual)
        raise NotImplementedError("Non-integer powers not supported")

    def __neg__(self):
        return Dual(-self.real, -self.dual)


def dual_sin(x: Dual) -> Dual:
    """sin(a + bε) = sin(a) + cos(a)·b·ε"""
    return Dual(np.sin(x.real), np.cos(x.real) * x.dual)

def dual_cos(x: Dual) -> Dual:
    """cos(a + bε) = cos(a) - sin(a)·b·ε"""
    return Dual(np.cos(x.real), -np.sin(x.real) * x.dual)

def dual_exp(x: Dual) -> Dual:
    """exp(a + bε) = exp(a) + exp(a)·b·ε"""
    e = np.exp(x.real)
    return Dual(e, e * x.dual)

def dual_log(x: Dual) -> Dual:
    """log(a + bε) = log(a) + (1/a)·b·ε"""
    return Dual(np.log(x.real), x.dual / x.real)


# ══════════════════════════════════════════════════════════════════════════════
# Part 2: Verification — Dual Numbers Match Symbolic Derivatives
# ══════════════════════════════════════════════════════════════════════════════

def demo_polynomial_ad():
    """
    Demonstrate Theorem dual_aeval_snd:
    For p(x) = 3x⁴ - 2x³ + 5x - 7, evaluate at a = 2.0.
    The dual part should give p'(2) = 12·16 - 6·4 + 5 = 173.
    """
    print("=" * 70)
    print("THEOREM: dual_aeval_snd — Polynomial Automatic Differentiation")
    print("=" * 70)
    print()
    print("For p(x) = 3x⁴ - 2x³ + 5x - 7:")
    print("  p'(x) = 12x³ - 6x² + 5")
    print()

    # Evaluate p at 2 + ε (i.e., a=2, b=1)
    x = Dual(2.0, 1.0)  # x = 2 + ε
    p = 3 * x**4 - 2 * x**3 + 5 * x - 7

    # Symbolic values
    sym_value = 3 * 16 - 2 * 8 + 5 * 2 - 7  # = 48 - 16 + 10 - 7 = 35
    sym_deriv = 12 * 8 - 6 * 4 + 5  # = 96 - 24 + 5 = 77... wait

    # Let me compute properly
    a = 2.0
    sym_value = 3 * a**4 - 2 * a**3 + 5 * a - 7
    sym_deriv = 12 * a**3 - 6 * a**2 + 5

    print(f"  At a = {a}:")
    print(f"    Dual number result:    {p}")
    print(f"    p(a) = {p.real:.6f}  (symbolic: {sym_value:.6f})")
    print(f"    p'(a) = {p.dual:.6f}  (symbolic: {sym_deriv:.6f})")
    print(f"    Match: {np.isclose(p.real, sym_value) and np.isclose(p.dual, sym_deriv)}")
    print()

    # Multiple evaluation points
    print("  Verification across multiple points:")
    print(f"  {'a':>6} | {'p(a) dual':>14} {'p(a) sym':>14} | {'p′(a) dual':>14} {'p′(a) sym':>14}")
    print("  " + "-" * 68)
    for a in [-2.0, -1.0, 0.0, 0.5, 1.0, 2.0, 3.0]:
        x = Dual(a, 1.0)
        p_dual = 3 * x**4 - 2 * x**3 + 5 * x - 7
        p_sym = 3 * a**4 - 2 * a**3 + 5 * a - 7
        dp_sym = 12 * a**3 - 6 * a**2 + 5
        print(f"  {a:6.1f} | {p_dual.real:14.6f} {p_sym:14.6f} | {p_dual.dual:14.6f} {dp_sym:14.6f}")
    print()


def demo_chain_rule():
    """
    Demonstrate Theorem dual_aeval_chain_rule:
    (q ∘ p)'(a) = q'(p(a)) · p'(a)
    """
    print("=" * 70)
    print("THEOREM: dual_aeval_chain_rule — Chain Rule from Ring Structure")
    print("=" * 70)
    print()

    # p(x) = x² + 1, q(x) = x³
    # (q ∘ p)(x) = (x² + 1)³
    # (q ∘ p)'(x) = 3(x² + 1)² · 2x = 6x(x² + 1)²

    a = 2.0

    # Method 1: Direct composition with dual numbers
    x = Dual(a, 1.0)
    p = x**2 + 1           # p(x) = x² + 1
    q_of_p = p**3           # q(p(x)) = (x² + 1)³

    # Method 2: Chain rule q'(p(a)) · p'(a)
    p_val = a**2 + 1        # p(2) = 5
    p_deriv = 2 * a         # p'(2) = 4
    q_deriv_at_p = 3 * p_val**2  # q'(5) = 75
    chain_rule = q_deriv_at_p * p_deriv  # 75 * 4 = 300

    print("  p(x) = x² + 1,  q(x) = x³")
    print("  (q ∘ p)(x) = (x² + 1)³")
    print()
    print(f"  At a = {a}:")
    print(f"    Direct dual computation:  (q∘p)'({a}) = {q_of_p.dual:.6f}")
    print(f"    Chain rule:               q'(p({a}))·p'({a}) = {q_deriv_at_p}·{p_deriv} = {chain_rule:.6f}")
    print(f"    Match: {np.isclose(q_of_p.dual, chain_rule)}")
    print()

    # Extended functions (beyond polynomials)
    print("  Beyond polynomials — sin(exp(x)) at x = 1:")
    x = Dual(1.0, 1.0)
    result = dual_sin(dual_exp(x))
    sym_deriv = np.cos(np.exp(1.0)) * np.exp(1.0)
    print(f"    Dual:     f'(1) = {result.dual:.10f}")
    print(f"    Symbolic: f'(1) = {sym_deriv:.10f}")
    print(f"    Match: {np.isclose(result.dual, sym_deriv)}")
    print()


def demo_unit_invertibility():
    """
    Demonstrate Theorem dual_unit_iff:
    (a + bε) is invertible ⟺ a is invertible (i.e., a ≠ 0 in a field)
    """
    print("=" * 70)
    print("THEOREM: dual_unit_iff — Invertibility of Dual Numbers")
    print("=" * 70)
    print()

    # Invertible case: a ≠ 0
    x = Dual(3.0, 5.0)
    x_inv = Dual(1.0, 0.0) / x
    product = x * x_inv
    print(f"  x = {x}")
    print(f"  x⁻¹ = {x_inv}")
    print(f"  x · x⁻¹ = {product}")
    print(f"  Is unit (real ≠ 0)? {x.real != 0} ✓")
    print()

    # The inverse formula: (a + bε)⁻¹ = a⁻¹ - a⁻²bε
    a, b = 3.0, 5.0
    inv_real = 1.0 / a
    inv_dual = -b / a**2
    print(f"  Inverse formula: (a + bε)⁻¹ = a⁻¹ - a⁻²bε")
    print(f"  = {inv_real:.6f} + {inv_dual:.6f}ε")
    print(f"  Matches computed: {np.isclose(x_inv.real, inv_real) and np.isclose(x_inv.dual, inv_dual)}")
    print()

    # Non-invertible case
    print("  Non-invertible: 0 + 5ε")
    print("  Real part = 0, so NOT a unit (division would fail)")
    try:
        z = Dual(0.0, 5.0)
        z_inv = Dual(1.0) / z
        print(f"  Result: {z_inv} (ERROR: should have failed!)")
    except ZeroDivisionError as e:
        print(f"  ✓ ZeroDivisionError: {e}")
    print()


def demo_eps_nilpotent():
    """
    Demonstrate Theorem dual_eps_sq: ε² = 0
    """
    print("=" * 70)
    print("THEOREM: dual_eps_sq — ε² = 0 (Nilpotency)")
    print("=" * 70)
    print()

    eps = Dual(0.0, 1.0)  # ε = 0 + 1·ε
    eps2 = eps * eps

    print(f"  ε = {eps}")
    print(f"  ε² = {eps2}")
    print(f"  ε² = 0? {eps2.real == 0 and eps2.dual == 0} ✓")
    print()
    print("  This is the DEFINING property of dual numbers.")
    print("  Everything else — automatic differentiation, the chain rule,")
    print("  the Leibniz rule — follows from this single equation.")
    print()


# ══════════════════════════════════════════════════════════════════════════════
# Part 3: Visualizations
# ══════════════════════════════════════════════════════════════════════════════

def plot_autodiff_visualization():
    """
    Create a visualization showing how dual number evaluation
    simultaneously computes a function and its derivative.
    """
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle("Dual Number Automatic Differentiation\n"
                 "Formally Verified: p(a + ε) = p(a) + p'(a)·ε",
                 fontsize=14, fontweight='bold')

    # Function: p(x) = x³ - 3x + 1
    def p(x):
        return x**3 - 3*x + 1

    def dp(x):
        return 3*x**2 - 3

    xs = np.linspace(-2.5, 2.5, 300)

    # Panel 1: Function and tangent lines via dual numbers
    ax = axes[0, 0]
    ax.plot(xs, [p(x) for x in xs], 'b-', linewidth=2, label='p(x) = x³ - 3x + 1')
    for a in [-1.5, 0.0, 1.0, 2.0]:
        x_dual = Dual(a, 1.0)
        result = x_dual**3 - 3*x_dual + 1
        # Tangent line: y = p(a) + p'(a)(x - a)
        tangent_x = np.linspace(a - 0.8, a + 0.8, 50)
        tangent_y = result.real + result.dual * (tangent_x - a)
        ax.plot(tangent_x, tangent_y, '--', linewidth=1.5, alpha=0.8)
        ax.plot(a, result.real, 'o', markersize=8)
    ax.set_title('Function + Tangent Lines (from dual numbers)')
    ax.set_xlabel('x')
    ax.set_ylabel('p(x)')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(-8, 8)

    # Panel 2: Derivative comparison
    ax = axes[0, 1]
    # Dual number derivatives
    dual_derivs = []
    eval_points = np.linspace(-2.5, 2.5, 50)
    for a in eval_points:
        x_dual = Dual(a, 1.0)
        result = x_dual**3 - 3*x_dual + 1
        dual_derivs.append(result.dual)

    ax.plot(xs, [dp(x) for x in xs], 'r-', linewidth=2, label="Symbolic p'(x)")
    ax.plot(eval_points, dual_derivs, 'ko', markersize=4, alpha=0.6,
            label='Dual number p\'(a)')
    ax.set_title('Derivative: Symbolic vs Dual Number')
    ax.set_xlabel('x')
    ax.set_ylabel("p'(x)")
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    # Panel 3: Error analysis (dual vs finite differences)
    ax = axes[1, 0]
    a = 1.0
    hs = np.logspace(-15, 0, 100)

    x_dual = Dual(a, 1.0)
    result = x_dual**3 - 3*x_dual + 1
    dual_deriv = result.dual
    exact_deriv = dp(a)

    fd_errors = []
    dual_error = abs(dual_deriv - exact_deriv)

    for h in hs:
        fd = (p(a + h) - p(a)) / h
        fd_errors.append(abs(fd - exact_deriv))

    ax.loglog(hs, fd_errors, 'b-', linewidth=2, label='Finite difference error')
    ax.axhline(y=max(dual_error, 1e-16), color='r', linestyle='--', linewidth=2,
               label=f'Dual number error = {dual_error:.1e}')
    ax.set_xlabel('Step size h')
    ax.set_ylabel('|Approximate - Exact|')
    ax.set_title('Error: Finite Differences vs Dual Numbers')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(1e-17, 1e2)

    # Panel 4: The algebra — multiplication table
    ax = axes[1, 1]
    ax.axis('off')
    table_text = (
        "The Dual Number Ring R[ε]/(ε²)\n"
        "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n"
        "Elements:  a + bε,   where ε² = 0\n\n"
        "Addition:\n"
        "  (a + bε) + (c + dε) = (a+c) + (b+d)ε\n\n"
        "Multiplication (Leibniz rule!):\n"
        "  (a + bε)(c + dε) = ac + (ad + bc)ε\n\n"
        "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
        "Key Theorem (formally verified):\n\n"
        "  p(a + bε) = p(a) + p'(a)·b·ε\n\n"
        "The derivative appears AUTOMATICALLY\n"
        "from the ring structure — no symbolic\n"
        "differentiation needed!"
    )
    ax.text(0.05, 0.95, table_text, transform=ax.transAxes,
            fontsize=11, verticalalignment='top', fontfamily='monospace',
            bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

    plt.tight_layout()
    plt.savefig(os.path.join(os.path.dirname(__file__), 'autodiff_visualization.png'),
                dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: demos/autodiff_visualization.png")


def plot_chain_rule_visualization():
    """Visualize the chain rule through dual numbers."""
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    fig.suptitle("Chain Rule via Dual Numbers: (q ∘ p)'(a) = q'(p(a)) · p'(a)",
                 fontsize=13, fontweight='bold')

    xs = np.linspace(-2, 2, 300)

    # p(x) = sin(x), q(x) = x²
    # (q ∘ p)(x) = sin²(x)
    # (q ∘ p)'(x) = 2sin(x)cos(x) = sin(2x)

    # Panel 1: Inner function p(x) = sin(x)
    ax = axes[0]
    ax.plot(xs, np.sin(xs), 'b-', linewidth=2)
    ax.set_title('Inner: p(x) = sin(x)', fontsize=11)
    ax.set_xlabel('x')
    ax.grid(True, alpha=0.3)

    # Panel 2: Outer function q(x) = x²
    ax = axes[1]
    qs = np.linspace(-1.2, 1.2, 200)
    ax.plot(qs, qs**2, 'r-', linewidth=2)
    ax.set_title('Outer: q(x) = x²', fontsize=11)
    ax.set_xlabel('x')
    ax.grid(True, alpha=0.3)

    # Panel 3: Composition and its derivative
    ax = axes[2]
    comp = np.sin(xs)**2
    comp_deriv_exact = np.sin(2 * xs)

    # Compute derivative via dual numbers
    dual_derivs = []
    for a in xs:
        x = Dual(a, 1.0)
        inner = dual_sin(x)
        outer = inner**2
        dual_derivs.append(outer.dual)

    ax.plot(xs, comp, 'g-', linewidth=2, label='sin²(x)')
    ax.plot(xs, comp_deriv_exact, 'k--', linewidth=2, alpha=0.5, label="sin(2x) (symbolic)")
    ax.plot(xs[::5], [dual_derivs[i] for i in range(0, len(xs), 5)],
            'ro', markersize=4, label="Dual number d/dx")
    ax.set_title('Composition (q ∘ p)(x) = sin²(x)', fontsize=11)
    ax.set_xlabel('x')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig(os.path.join(os.path.dirname(__file__), 'chain_rule_visualization.png'),
                dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: demos/chain_rule_visualization.png")


def plot_nilpotent_tower():
    """Visualize the nilpotent structure and higher-order jets."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 7))

    # Show the "tower" of approximation
    a = 1.0
    xs = np.linspace(-1, 3, 300)

    def f(x):
        return np.exp(x)

    # Order 0: just the value
    y0 = np.full_like(xs, np.exp(a))
    # Order 1: value + derivative (dual number gives this)
    y1 = np.exp(a) + np.exp(a) * (xs - a)
    # Order 2: Taylor (would need "triple numbers" with ε³ = 0)
    y2 = np.exp(a) + np.exp(a) * (xs - a) + 0.5 * np.exp(a) * (xs - a)**2
    # Exact
    ye = f(xs)

    ax.plot(xs, ye, 'k-', linewidth=3, label='exp(x) — exact', zorder=5)
    ax.plot(xs, y0, 'r--', linewidth=1.5, label='Order 0: f(a) (constant)', alpha=0.7)
    ax.plot(xs, y1, 'b--', linewidth=2, label='Order 1: f(a) + f\'(a)(x-a) [DUAL NUMBERS]', zorder=4)
    ax.plot(xs, y2, 'g--', linewidth=1.5, label='Order 2: + ½f\'\'(a)(x-a)² (hyper-dual)', alpha=0.7)

    ax.plot(a, np.exp(a), 'ko', markersize=10, zorder=6)
    ax.annotate(f'a = {a}\nf(a) = e ≈ {np.exp(a):.3f}',
                xy=(a, np.exp(a)), xytext=(a + 0.5, np.exp(a) + 3),
                arrowprops=dict(arrowstyle='->', color='black'),
                fontsize=11, bbox=dict(boxstyle='round', facecolor='lightyellow'))

    ax.set_title('Dual Numbers = First-Order Jet Space\n'
                 'ε² = 0 captures exactly the first derivative',
                 fontsize=13, fontweight='bold')
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('y', fontsize=12)
    ax.legend(fontsize=10, loc='upper left')
    ax.grid(True, alpha=0.3)
    ax.set_ylim(-2, 20)

    plt.tight_layout()
    plt.savefig(os.path.join(os.path.dirname(__file__), 'jet_space_visualization.png'),
                dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: demos/jet_space_visualization.png")


# ══════════════════════════════════════════════════════════════════════════════
# Part 4: Applications
# ══════════════════════════════════════════════════════════════════════════════

def demo_newton_raphson():
    """
    Application: Newton-Raphson root finding using dual numbers.
    No need to manually compute or code derivatives!
    """
    print("=" * 70)
    print("APPLICATION: Newton-Raphson with Automatic Differentiation")
    print("=" * 70)
    print()
    print("  Find root of f(x) = x³ - 2x - 5 near x = 2")
    print()

    def f(x):
        return x**3 - 2*x - 5

    x = 2.0
    print(f"  {'Iter':>4} | {'x':>18} | {'f(x)':>18} | {'f′(x)':>18}")
    print("  " + "-" * 65)

    for i in range(8):
        x_dual = Dual(x, 1.0)
        result = f(x_dual)
        fx = result.real
        fpx = result.dual

        print(f"  {i:4d} | {x:18.15f} | {fx:18.15f} | {fpx:18.6f}")

        if abs(fx) < 1e-15:
            break
        x = x - fx / fpx  # Newton step — derivative computed automatically!

    print()
    print(f"  Root found: x ≈ {x:.15f}")
    print(f"  Verification: f(x) = {f(Dual(x)).real:.2e}")
    print()


def demo_gradient_descent():
    """
    Application: Gradient descent optimization using dual numbers.
    Minimize f(x) = (x - 3)⁴ + (x - 3)² + 1
    """
    print("=" * 70)
    print("APPLICATION: Gradient Descent with Automatic Derivatives")
    print("=" * 70)
    print()

    def f(x):
        return (x - 3)**4 + (x - 3)**2 + 1

    x = 0.0
    lr = 0.01  # learning rate
    history = [(x, f(Dual(x)).real)]

    print(f"  Minimizing f(x) = (x-3)⁴ + (x-3)² + 1")
    print(f"  Starting at x = {x}, learning rate = {lr}")
    print()

    for i in range(200):
        x_dual = Dual(x, 1.0)
        result = f(x_dual)
        grad = result.dual
        x = x - lr * grad
        history.append((x, result.real))

        if i % 20 == 0 or i < 5:
            print(f"  Step {i:4d}: x = {x:10.6f}, f(x) = {result.real:10.6f}, f'(x) = {grad:10.6f}")

    print()
    print(f"  Converged to x ≈ {x:.6f} (exact minimum: 3.0)")
    print(f"  f(x) = {f(Dual(x)).real:.6f} (exact minimum value: 1.0)")
    print()


def demo_sensitivity_analysis():
    """
    Application: Sensitivity analysis in engineering.
    How does the resonant frequency of an LC circuit change with component values?
    """
    print("=" * 70)
    print("APPLICATION: Engineering Sensitivity Analysis")
    print("=" * 70)
    print()
    print("  LC Circuit: resonant frequency ω = 1/√(LC)")
    print("  How sensitive is ω to changes in L and C?")
    print()

    L = 1e-3   # 1 mH
    C = 1e-6   # 1 μF

    # Sensitivity to L (treat L as dual, C as constant)
    L_dual = Dual(L, 1.0)
    omega_L = (L_dual * C) ** (-1)  # 1/(LC), then we'd take sqrt...
    # Using 1/sqrt(LC): ω = (LC)^(-1/2)
    # dω/dL = -1/2 · (LC)^(-3/2) · C = -C/(2(LC)^(3/2))

    omega = 1.0 / np.sqrt(L * C)
    d_omega_dL = -0.5 * C / (L * C)**1.5
    d_omega_dC = -0.5 * L / (L * C)**1.5

    print(f"  L = {L*1000:.1f} mH, C = {C*1e6:.1f} μF")
    print(f"  ω₀ = {omega:.2f} rad/s = {omega/(2*np.pi):.2f} Hz")
    print()
    print(f"  Sensitivity to L: dω/dL = {d_omega_dL:.2f} rad/(s·H)")
    print(f"    → 1% increase in L changes ω by {d_omega_dL * L * 0.01:.2f} rad/s")
    print(f"    → Relative sensitivity: {d_omega_dL * L / omega * 100:.1f}%")
    print()
    print(f"  Sensitivity to C: dω/dC = {d_omega_dC:.2f} rad/(s·F)")
    print(f"    → 1% increase in C changes ω by {d_omega_dC * C * 0.01:.2f} rad/s")
    print(f"    → Relative sensitivity: {d_omega_dC * C / omega * 100:.1f}%")
    print()
    print("  Both sensitivities are -50% (elasticity = -0.5)")
    print("  This is exact: ω ∝ (LC)^(-1/2), so ∂log(ω)/∂log(L) = -1/2")
    print()


# ══════════════════════════════════════════════════════════════════════════════
# Main
# ══════════════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  DUAL NUMBERS & AUTOMATIC DIFFERENTIATION                          ║")
    print("║  Theorems formally verified in Lean 4 (Algebra/DualAutoDiff.lean)  ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    # Theorem demonstrations
    demo_eps_nilpotent()
    demo_polynomial_ad()
    demo_chain_rule()
    demo_unit_invertibility()

    # Applications
    demo_newton_raphson()
    demo_gradient_descent()
    demo_sensitivity_analysis()

    # Visualizations
    print("=" * 70)
    print("GENERATING VISUALIZATIONS")
    print("=" * 70)
    print()
    try:
        plot_autodiff_visualization()
        plot_chain_rule_visualization()
        plot_nilpotent_tower()
        print()
        print("  All visualizations saved to demos/")
    except Exception as e:
        print(f"  Could not generate plots: {e}")
        print("  (matplotlib may not be available)")

    print()
    print("=" * 70)
    print("All demonstrations complete!")
    print("=" * 70)
