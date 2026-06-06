"""
EML Differential Equations: Numerical Demonstrations

This script demonstrates the key concepts from the EML ODE theory:
1. EML expression evaluation and symbolic differentiation
2. Depth filtration of EML expressions
3. Wronskian computation for Airy equation solutions
4. Growth comparison: EML vs Airy solutions
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import Callable, Tuple, List

# ============================================================
# §1. EML Expression Evaluation
# ============================================================

class EMLExpr:
    """Represents an EML expression (exp-log-algebraic)."""
    pass

class Const(EMLExpr):
    def __init__(self, c: float):
        self.c = c
    def eval(self, x: float) -> float:
        return self.c
    def depth(self) -> int:
        return 0
    def deriv(self) -> 'EMLExpr':
        return Const(0)
    def __repr__(self):
        return f"{self.c}"

class Var(EMLExpr):
    def eval(self, x: float) -> float:
        return x
    def depth(self) -> int:
        return 0
    def deriv(self) -> 'EMLExpr':
        return Const(1)
    def __repr__(self):
        return "x"

class Add(EMLExpr):
    def __init__(self, a: EMLExpr, b: EMLExpr):
        self.a, self.b = a, b
    def eval(self, x: float) -> float:
        return self.a.eval(x) + self.b.eval(x)
    def depth(self) -> int:
        return max(self.a.depth(), self.b.depth())
    def deriv(self) -> 'EMLExpr':
        return Add(self.a.deriv(), self.b.deriv())
    def __repr__(self):
        return f"({self.a} + {self.b})"

class Mul(EMLExpr):
    def __init__(self, a: EMLExpr, b: EMLExpr):
        self.a, self.b = a, b
    def eval(self, x: float) -> float:
        return self.a.eval(x) * self.b.eval(x)
    def depth(self) -> int:
        return max(self.a.depth(), self.b.depth())
    def deriv(self) -> 'EMLExpr':
        return Add(Mul(self.a.deriv(), self.b), Mul(self.a, self.b.deriv()))
    def __repr__(self):
        return f"({self.a} * {self.b})"

class Neg(EMLExpr):
    def __init__(self, e: EMLExpr):
        self.e = e
    def eval(self, x: float) -> float:
        return -self.e.eval(x)
    def depth(self) -> int:
        return self.e.depth()
    def deriv(self) -> 'EMLExpr':
        return Neg(self.e.deriv())
    def __repr__(self):
        return f"(-{self.e})"

class Inv(EMLExpr):
    def __init__(self, e: EMLExpr):
        self.e = e
    def eval(self, x: float) -> float:
        v = self.e.eval(x)
        return 1.0/v if v != 0 else float('inf')
    def depth(self) -> int:
        return self.e.depth()
    def deriv(self) -> 'EMLExpr':
        return Neg(Mul(self.e.deriv(), Inv(Mul(self.e, self.e))))
    def __repr__(self):
        return f"(1/{self.e})"

class Exp(EMLExpr):
    def __init__(self, e: EMLExpr):
        self.e = e
    def eval(self, x: float) -> float:
        return np.exp(np.clip(self.e.eval(x), -500, 500))
    def depth(self) -> int:
        return self.e.depth() + 1
    def deriv(self) -> 'EMLExpr':
        return Mul(Exp(self.e), self.e.deriv())
    def __repr__(self):
        return f"exp({self.e})"

class Log(EMLExpr):
    def __init__(self, e: EMLExpr):
        self.e = e
    def eval(self, x: float) -> float:
        v = self.e.eval(x)
        return np.log(max(v, 1e-300))
    def depth(self) -> int:
        return self.e.depth() + 1
    def deriv(self) -> 'EMLExpr':
        return Mul(self.e.deriv(), Inv(self.e))
    def __repr__(self):
        return f"log({self.e})"


# ============================================================
# §2. Demonstration: Depth Closure Under Differentiation
# ============================================================

def demonstrate_depth_closure():
    """Show that symbolic differentiation preserves EML depth."""
    print("=" * 60)
    print("§2. DEPTH CLOSURE UNDER DIFFERENTIATION")
    print("=" * 60)

    examples = [
        ("exp(x)", Exp(Var())),
        ("log(x)", Log(Var())),
        ("exp(exp(x))", Exp(Exp(Var()))),
        ("x * exp(x)", Mul(Var(), Exp(Var()))),
        ("log(exp(x) + 1)", Log(Add(Exp(Var()), Const(1)))),
    ]

    for name, expr in examples:
        d = expr.deriv()
        print(f"\n  f(x) = {name}")
        print(f"    depth(f)  = {expr.depth()}")
        print(f"    depth(f') = {d.depth()}")
        print(f"    f'(x) = {d}")
        assert d.depth() <= expr.depth(), f"FAILURE: depth increased for {name}!"
        print(f"    ✓ depth(f') ≤ depth(f)")

    print("\n  All depth closure checks passed! ✓")


# ============================================================
# §3. Wronskian Computation for Airy Equation
# ============================================================

def airy_wronskian_demo():
    """Compute the Wronskian for numerical Airy-like solutions."""
    print("\n" + "=" * 60)
    print("§3. WRONSKIAN FOR AIRY EQUATION y'' = xy")
    print("=" * 60)

    # Numerical integration of Airy equation using RK4
    def airy_rk4(x0: float, x1: float, y0: float, yp0: float, n: int = 1000):
        h = (x1 - x0) / n
        xs = [x0]
        ys = [y0]
        yps = [yp0]
        x, y, yp = x0, y0, yp0
        for _ in range(n):
            k1y = yp
            k1yp = x * y
            k2y = yp + 0.5*h*k1yp
            k2yp = (x + 0.5*h) * (y + 0.5*h*k1y)
            k3y = yp + 0.5*h*k2yp
            k3yp = (x + 0.5*h) * (y + 0.5*h*k2y)
            k4y = yp + h*k3yp
            k4yp = (x + h) * (y + h*k3y)
            y += h/6 * (k1y + 2*k2y + 2*k3y + k4y)
            yp += h/6 * (k1yp + 2*k2yp + 2*k3yp + k4yp)
            x += h
            xs.append(x)
            ys.append(y)
            yps.append(yp)
        return np.array(xs), np.array(ys), np.array(yps)

    # Two linearly independent solutions with different initial conditions
    x0, x1 = 0, 5
    xs1, y1, y1p = airy_rk4(x0, x1, 1, 0)  # Ai-like
    xs2, y2, y2p = airy_rk4(x0, x1, 0, 1)  # Bi-like

    # Wronskian W = y1*y2' - y2*y1'
    W = y1 * y2p - y2 * y1p

    print(f"\n  Initial conditions:")
    print(f"    y₁(0)=1, y₁'(0)=0  (Ai-like)")
    print(f"    y₂(0)=0, y₂'(0)=1  (Bi-like)")
    print(f"\n  Wronskian W(x) = y₁·y₂' - y₂·y₁'")
    print(f"    W(0) = {W[0]:.6f}")
    print(f"    W(1) = {W[len(W)//5]:.6f}")
    print(f"    W(3) = {W[3*len(W)//5]:.6f}")
    print(f"    W(5) = {W[-1]:.6f}")
    print(f"\n  Abel's identity: since p(x) = 0 for Airy,")
    print(f"  W' = -p·W = 0, so W is CONSTANT.")
    print(f"  Numerical verification: max|W - W(0)| = {np.max(np.abs(W - W[0])):.2e}")


# ============================================================
# §4. Growth Rate Comparison: EML vs Airy
# ============================================================

def growth_comparison():
    """Compare growth rates of EML functions vs Airy solutions."""
    print("\n" + "=" * 60)
    print("§4. GROWTH RATE OBSTRUCTION")
    print("=" * 60)

    # Airy Bi grows like exp(2/3 * x^(3/2)) / (sqrt(pi) * x^(1/4))
    x = np.linspace(1, 10, 100)

    # Airy-like growth
    airy_growth = np.exp(2/3 * x**(3/2)) / (np.sqrt(np.pi) * x**(1/4))

    # EML functions of various depths
    depth0 = x**3  # polynomial (depth 0)
    depth1 = np.exp(x)  # single exponential (depth 1)
    depth1b = np.exp(2*x)  # faster exponential (depth 1)

    print(f"\n  At x = 5:")
    print(f"    Polynomial x³:        {5**3:.2f}")
    print(f"    exp(x):                {np.exp(5):.2f}")
    print(f"    exp(2x):               {np.exp(10):.2f}")
    print(f"    Airy ~ exp(2x^1.5/3):  {np.exp(2/3 * 5**1.5):.2f}")
    print(f"\n  At x = 10:")
    print(f"    exp(x):                {np.exp(10):.2e}")
    print(f"    exp(2x):               {np.exp(20):.2e}")
    print(f"    Airy ~ exp(2x^1.5/3):  {np.exp(2/3 * 10**1.5):.2e}")
    print(f"\n  Key insight: Airy growth exp(2x^{{3/2}}/3) is BETWEEN")
    print(f"  polynomial and single-exponential growth for small x,")
    print(f"  but eventually dominates exp(cx) for any fixed c.")
    print(f"  The exponent x^{{3/2}} is NOT an EML function (fractional power).")
    print(f"  This is the growth-theoretic obstruction to Airy being EML.")


# ============================================================
# §5. EML Differential Operator Algebra
# ============================================================

def diff_operator_demo():
    """Demonstrate the EML differential operator algebra."""
    print("\n" + "=" * 60)
    print("§5. EML DIFFERENTIAL OPERATOR ALGEBRA")
    print("=" * 60)

    # The Airy operator: D² - x
    print("\n  Airy operator: L = D² - x·I")
    print(f"    Coefficient of D²: 1 (depth 0)")
    print(f"    Coefficient of D:  0 (depth 0)")
    print(f"    Coefficient of I:  -x (depth 0)")
    print(f"    Operator depth: max(0, 0, 0) = 0")

    # An EML operator: D² + exp(x)·D + log(x)·I
    print("\n  EML operator: M = D² + exp(x)·D + log(x)·I")
    print(f"    Coefficient of D²: 1 (depth 0)")
    print(f"    Coefficient of D:  exp(x) (depth 1)")
    print(f"    Coefficient of I:  log(x) (depth 1)")
    print(f"    Operator depth: max(0, 1, 1) = 1")

    # Addition preserves depth bound
    print("\n  Addition L + M:")
    print(f"    depth(L + M) ≤ max(depth(L), depth(M)) = max(0, 1) = 1")
    print(f"    This is our ADD_DEPTH_LE theorem.")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  EML DIFFERENTIAL EQUATIONS: NUMERICAL DEMONSTRATIONS   ║")
    print("╚══════════════════════════════════════════════════════════╝")

    demonstrate_depth_closure()
    airy_wronskian_demo()
    growth_comparison()
    diff_operator_demo()

    print("\n" + "=" * 60)
    print("All demonstrations completed successfully!")
    print("=" * 60)


"""
Visualization: Growth Rate Obstruction for Airy Solutions

This script creates a visualization comparing the growth rates of EML functions
at various depths with the growth of Airy function solutions. The key insight
is that Airy solutions grow like exp(2x^{3/2}/3), which is "between" the growth
classes available to EML functions of any fixed depth.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def create_growth_comparison():
    """Create the growth comparison plot."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Left panel: log-scale growth comparison
    x = np.linspace(0.5, 8, 200)

    # Depth 0: polynomial growth
    poly_growth = x**3

    # Depth 1: exponential growth
    exp_growth = np.exp(x)
    exp2_growth = np.exp(2*x)

    # Airy growth: exp(2/3 * x^{3/2})
    airy_growth = np.exp(2/3 * x**(1.5))

    ax1.semilogy(x, poly_growth, 'b-', linewidth=2, label='$x^3$ (depth 0)')
    ax1.semilogy(x, exp_growth, 'g-', linewidth=2, label='$e^x$ (depth 1)')
    ax1.semilogy(x, airy_growth, 'r-', linewidth=3, label='$e^{2x^{3/2}/3}$ (Airy)')
    ax1.semilogy(x, exp2_growth, 'g--', linewidth=2, label='$e^{2x}$ (depth 1)')

    ax1.set_xlabel('x', fontsize=14)
    ax1.set_ylabel('Function value (log scale)', fontsize=14)
    ax1.set_title('Growth Rate Obstruction', fontsize=16)
    ax1.legend(fontsize=11, loc='upper left')
    ax1.grid(True, alpha=0.3)
    ax1.set_ylim([1e-1, 1e15])

    # Right panel: the exponent comparison
    x2 = np.linspace(1, 20, 200)

    # Exponents of different growth classes
    linear_exp = x2  # exp(x)
    quadratic_exp = x2**2  # exp(x^2) - depth 1 can do this via exp(x^2)
    airy_exp = 2/3 * x2**1.5  # Airy exponent

    ax2.plot(x2, linear_exp, 'g-', linewidth=2, label='$x$ (in $e^x$)')
    ax2.plot(x2, airy_exp, 'r-', linewidth=3, label='$\\frac{2}{3}x^{3/2}$ (Airy exponent)')
    ax2.plot(x2, quadratic_exp, 'm--', linewidth=2, label='$x^2$ (in $e^{x^2}$)')
    ax2.fill_between(x2, linear_exp, airy_exp, alpha=0.15, color='red',
                      label='Gap: $x < \\frac{2}{3}x^{3/2}$ but $< x^2$')

    ax2.set_xlabel('x', fontsize=14)
    ax2.set_ylabel('Exponent value', fontsize=14)
    ax2.set_title('Airy Exponent is Non-EML', fontsize=16)
    ax2.legend(fontsize=10, loc='upper left')
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('Applications/EMLDiffEq/growth_obstruction.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved growth_obstruction.png")


def create_wronskian_plot():
    """Create plot showing Abel's identity for Airy equation."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Numerical Airy solutions via RK4
    def solve_airy(y0, yp0, x_range, n=2000):
        x0, x1 = x_range
        h = (x1 - x0) / n
        xs, ys, yps = [x0], [y0], [yp0]
        x, y, yp = x0, y0, yp0
        for _ in range(n):
            k1y, k1yp = yp, x * y
            k2y, k2yp = yp + 0.5*h*k1yp, (x + 0.5*h) * (y + 0.5*h*k1y)
            k3y, k3yp = yp + 0.5*h*k2yp, (x + 0.5*h) * (y + 0.5*h*k2y)
            k4y, k4yp = yp + h*k3yp, (x + h) * (y + h*k3y)
            y += h/6 * (k1y + 2*k2y + 2*k3y + k4y)
            yp += h/6 * (k1yp + 2*k2yp + 2*k3yp + k4yp)
            x += h
            xs.append(x); ys.append(y); yps.append(yp)
        return np.array(xs), np.array(ys), np.array(yps)

    xs, y1, y1p = solve_airy(1, 0, (-10, 5))
    _, y2, y2p = solve_airy(0, 1, (-10, 5))

    # Plot solutions
    ax1.plot(xs, y1, 'b-', linewidth=2, label='$y_1$ (Ai-like)')
    ax1.plot(xs, y2, 'r-', linewidth=2, label='$y_2$ (Bi-like)')
    ax1.set_xlabel('x', fontsize=14)
    ax1.set_ylabel('y', fontsize=14)
    ax1.set_title('Airy Equation Solutions', fontsize=16)
    ax1.legend(fontsize=12)
    ax1.grid(True, alpha=0.3)
    ax1.set_ylim([-2, 3])

    # Wronskian
    W = y1 * y2p - y2 * y1p
    ax2.plot(xs, W, 'k-', linewidth=2, label='$W(x) = y_1 y_2\' - y_2 y_1\'$')
    ax2.axhline(y=W[0], color='r', linestyle='--', alpha=0.7, label=f'$W(0) = {W[0]:.4f}$')
    ax2.set_xlabel('x', fontsize=14)
    ax2.set_ylabel('Wronskian', fontsize=14)
    ax2.set_title("Abel's Identity: W = const (p=0)", fontsize=16)
    ax2.legend(fontsize=12)
    ax2.grid(True, alpha=0.3)
    ax2.set_ylim([W[0]-0.1, W[0]+0.1])

    plt.tight_layout()
    plt.savefig('Applications/EMLDiffEq/wronskian_airy.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved wronskian_airy.png")


def create_depth_filtration_diagram():
    """Visualize the depth filtration of the EML algebra."""
    fig, ax = plt.subplots(figsize=(10, 8))

    # Draw boxes for each depth level
    levels = [
        (0, 'Rational Functions\n$\\frac{P(x)}{Q(x)}$', '#E3F2FD',
         ['$x$', '$x^2+1$', '$\\frac{1}{x}$', '$\\frac{x^2-1}{x+3}$']),
        (1, 'Depth-1 EML\n$\\exp, \\log$ of rationals', '#E8F5E9',
         ['$e^x$', '$\\ln x$', '$e^x - \\ln x$', '$\\frac{e^x}{x}$']),
        (2, 'Depth-2 EML\n$\\exp(\\exp), \\log(\\log)$, etc.', '#FFF3E0',
         ['$e^{e^x}$', '$\\ln(\\ln x)$', '$e^{x \\ln x}$']),
        (3, 'Depth-3+ EML\nHigher nesting', '#FCE4EC',
         ['$e^{e^{e^x}}$', '$\\ln(e^{\\ln x} + 1)$']),
    ]

    for depth, label, color, examples in levels:
        y = 6 - 1.8 * depth
        rect = plt.Rectangle((0.5, y - 0.7), 9, 1.4, facecolor=color,
                              edgecolor='black', linewidth=2)
        ax.add_patch(rect)
        ax.text(1.2, y + 0.3, f'Depth {depth}: {label}', fontsize=12, fontweight='bold',
                va='center')
        ex_str = ',  '.join(examples)
        ax.text(1.2, y - 0.3, f'Examples: {ex_str}', fontsize=10, va='center',
                style='italic')

    # Arrow showing differentiation preserves depth
    ax.annotate('', xy=(8.5, 1.5), xytext=(8.5, 5.8),
                arrowprops=dict(arrowstyle='<->', color='red', lw=2))
    ax.text(8.7, 3.7, '$\\frac{d}{dx}$\npreserves\ndepth', fontsize=13,
            color='red', fontweight='bold', ha='left')

    # Airy solution annotation
    ax.annotate('Airy: $e^{\\frac{2}{3}x^{3/2}}$\n(NOT EML — fractional power)',
                xy=(5, 0.3), fontsize=13, color='purple', fontweight='bold',
                ha='center',
                bbox=dict(boxstyle='round,pad=0.3', facecolor='#F3E5F5',
                          edgecolor='purple', linewidth=2))

    ax.set_xlim(0, 10)
    ax.set_ylim(-0.5, 7)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('EML Depth Filtration: A Tower of Function Classes', fontsize=18,
                 fontweight='bold', pad=20)

    plt.tight_layout()
    plt.savefig('Applications/EMLDiffEq/depth_filtration.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved depth_filtration.png")


if __name__ == '__main__':
    create_growth_comparison()
    create_wronskian_plot()
    create_depth_filtration_diagram()
    print("\nAll visualizations created!")
