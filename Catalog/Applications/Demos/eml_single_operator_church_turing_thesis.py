#!/usr/bin/env python3
"""
EML Church-Turing Thesis: Numerical Demonstrations

Demonstrates the core EML reduction identities and approximation capabilities.
"""

import math
from typing import Callable

def product_via_exp_log(a: float, b: float) -> float:
    """Compute a * b via exp(log(a) + log(b))."""
    assert a > 0 and b > 0, "Requires positive inputs"
    return math.exp(math.log(a) + math.log(b))

def quotient_via_exp_log(a: float, b: float) -> float:
    """Compute a / b via exp(log(a) - log(b))."""
    assert a > 0 and b > 0, "Requires positive inputs"
    return math.exp(math.log(a) - math.log(b))

def power_via_exp_log(x: float, n: float) -> float:
    """Compute x^n via exp(n * log(x))."""
    assert x > 0, "Requires positive base"
    return math.exp(n * math.log(x))

def sqrt_via_exp_log(x: float) -> float:
    """Compute sqrt(x) via exp(log(x) / 2)."""
    assert x > 0, "Requires positive input"
    return math.exp(math.log(x) / 2)

def reciprocal_via_exp_log(x: float) -> float:
    """Compute 1/x via exp(-log(x))."""
    assert x > 0, "Requires positive input"
    return math.exp(-math.log(x))


def demo_reduction_identities():
    """Demonstrate that EML reductions match direct computation."""
    print("=" * 60)
    print("EML REDUCTION IDENTITIES")
    print("=" * 60)
    
    # Product
    a, b = 3.7, 2.1
    direct = a * b
    eml = product_via_exp_log(a, b)
    print(f"\nProduct: {a} × {b}")
    print(f"  Direct:  {direct}")
    print(f"  EML:     {eml}")
    print(f"  Error:   {abs(direct - eml):.2e}")
    
    # Quotient
    direct = a / b
    eml = quotient_via_exp_log(a, b)
    print(f"\nQuotient: {a} / {b}")
    print(f"  Direct:  {direct}")
    print(f"  EML:     {eml}")
    print(f"  Error:   {abs(direct - eml):.2e}")
    
    # Power
    x, n = 2.5, 7
    direct = x ** n
    eml = power_via_exp_log(x, n)
    print(f"\nPower: {x}^{n}")
    print(f"  Direct:  {direct}")
    print(f"  EML:     {eml}")
    print(f"  Error:   {abs(direct - eml):.2e}")
    
    # Square root
    x = 17.3
    direct = math.sqrt(x)
    eml = sqrt_via_exp_log(x)
    print(f"\nSquare root: √{x}")
    print(f"  Direct:  {direct}")
    print(f"  EML:     {eml}")
    print(f"  Error:   {abs(direct - eml):.2e}")
    
    # Reciprocal
    x = 4.2
    direct = 1.0 / x
    eml = reciprocal_via_exp_log(x)
    print(f"\nReciprocal: 1/{x}")
    print(f"  Direct:  {direct}")
    print(f"  EML:     {eml}")
    print(f"  Error:   {abs(direct - eml):.2e}")


def demo_polynomial_approximation():
    """Demonstrate polynomial approximation via EML."""
    print("\n" + "=" * 60)
    print("POLYNOMIAL APPROXIMATION OF sin(x)")
    print("=" * 60)
    
    def taylor_sin(x: float, terms: int = 10) -> float:
        """Taylor polynomial for sin(x) = Σ (-1)^k x^(2k+1) / (2k+1)!"""
        result = 0.0
        for k in range(terms):
            # Each term is a monomial, hence EML-representable
            coeff = (-1)**k / math.factorial(2*k + 1)
            result += coeff * x**(2*k + 1)
        return result
    
    print(f"\n{'x':>8} {'sin(x)':>12} {'Taylor(5)':>12} {'Taylor(10)':>12} {'Error(5)':>12} {'Error(10)':>12}")
    print("-" * 70)
    
    for x in [0.0, 0.5, 1.0, math.pi/4, math.pi/2, math.pi, 2*math.pi]:
        exact = math.sin(x)
        t5 = taylor_sin(x, 5)
        t10 = taylor_sin(x, 10)
        print(f"{x:8.4f} {exact:12.8f} {t5:12.8f} {t10:12.8f} {abs(exact-t5):12.2e} {abs(exact-t10):12.2e}")
    
    print("\nKey insight: Each Taylor term c·x^n is EML-representable")
    print("via c * exp(n * log(x)) on positive reals, or directly as monomial.")


def demo_depth_hierarchy():
    """Demonstrate the EML depth hierarchy."""
    print("\n" + "=" * 60)
    print("EML DEPTH HIERARCHY")
    print("=" * 60)
    
    x = 1.5
    
    # Depth 0: algebraic
    d0 = 3*x**2 + 2*x + 1
    print(f"\nDepth 0 (algebraic): 3x² + 2x + 1 at x={x}")
    print(f"  Value: {d0}")
    
    # Depth 1: single exp/log
    d1 = math.exp(x) + math.log(x)
    print(f"\nDepth 1: exp(x) + log(x) at x={x}")
    print(f"  Value: {d1}")
    
    # Depth 2: exp(log(...)) compositions
    d2 = math.exp(2 * math.log(x))  # = x^2
    print(f"\nDepth 2: exp(2·log(x)) = x² at x={x}")
    print(f"  Value: {d2}")
    print(f"  Equals x²: {abs(d2 - x**2) < 1e-15}")
    
    # Depth 3: exp(exp(x))
    d3 = math.exp(math.exp(x))
    print(f"\nDepth 2 (nested): exp(exp(x)) at x={x}")
    print(f"  Value: {d3}")
    
    # Depth 4: exp(exp(exp(x)))
    # d4 would be enormous, skip
    print(f"\nDepth 3 (nested): exp(exp(exp(x))) at x=0.5")
    d4 = math.exp(math.exp(math.exp(0.5)))
    print(f"  Value: {d4:.6f}")
    
    print("\nStrict hierarchy: depth d+1 expressions grow faster than depth d.")


def demo_diagonal_map():
    """Demonstrate the diagonal EML map d(x) = exp(x) - log(x)."""
    print("\n" + "=" * 60)
    print("DIAGONAL EML MAP: d(x) = exp(x) - log(x)")
    print("=" * 60)
    
    print(f"\n{'x':>8} {'d(x)':>12} {'d(x) > x':>10} {'d(x) ≥ 2':>10}")
    print("-" * 45)
    
    for x in [0.01, 0.1, 0.5, 1.0, 2.0, 5.0, 10.0]:
        d = math.exp(x) - math.log(x)
        print(f"{x:8.4f} {d:12.6f} {'✓' if d > x else '✗':>10} {'✓' if d >= 2 else '✗':>10}")
    
    print("\nTheorem (verified in Lean): d(x) > x and d(x) ≥ 2 for all x > 0.")
    print("Consequence: d has no fixed points on (0, ∞).")


def demo_eml_universality_test():
    """Test the EML universality conjecture numerically."""
    print("\n" + "=" * 60)
    print("EML UNIVERSALITY TEST")
    print("=" * 60)
    
    # Approximate various functions by polynomials (which are EML)
    def chebyshev_approx(f: Callable[[float], float], a: float, b: float, n: int) -> Callable[[float], float]:
        """Chebyshev polynomial approximation of f on [a, b]."""
        # Chebyshev nodes
        nodes = [(a + b)/2 + (b - a)/2 * math.cos((2*k + 1) * math.pi / (2*n)) for k in range(n)]
        values = [f(x) for x in nodes]
        
        # Barycentric interpolation weights
        def approx(x: float) -> float:
            # Direct Lagrange interpolation
            result = 0.0
            for i in range(n):
                basis = 1.0
                for j in range(n):
                    if i != j:
                        if abs(nodes[i] - nodes[j]) > 1e-15:
                            basis *= (x - nodes[j]) / (nodes[i] - nodes[j])
                result += values[i] * basis
            return result
        
        return approx
    
    test_functions = [
        ("sin(x)", math.sin, -math.pi, math.pi),
        ("cos(x)", math.cos, -math.pi, math.pi),
        ("|x|", abs, -1.0, 1.0),
        ("exp(-x²)", lambda x: math.exp(-x**2), -2.0, 2.0),
    ]
    
    for name, f, a, b in test_functions:
        print(f"\nApproximating {name} on [{a:.2f}, {b:.2f}]:")
        for n in [5, 10, 20]:
            approx = chebyshev_approx(f, a, b, n)
            # Compute max error over 100 test points
            test_pts = [a + (b - a) * i / 100 for i in range(101)]
            max_err = max(abs(f(x) - approx(x)) for x in test_pts)
            print(f"  n={n:2d} polynomial (EML depth 0): max error = {max_err:.2e}")
    
    print("\nConclusion: All continuous functions are approximable by EML expressions")
    print("(polynomials are in EMLClass by our Lean theorem polynomial_in_EMLClass).")


if __name__ == "__main__":
    demo_reduction_identities()
    demo_polynomial_approximation()
    demo_depth_hierarchy()
    demo_diagonal_map()
    demo_eml_universality_test()


#!/usr/bin/env python3
"""
EML Church-Turing Thesis: Visualization
Generates plots of EML reduction identities, depth hierarchy, and approximation.
"""

import math
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec


def plot_eml_reductions():
    """Plot EML reduction identities: multiplication, power, reciprocal via exp-log."""
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))
    fig.suptitle("EML Reduction Identities", fontsize=16, fontweight='bold')
    
    x = np.linspace(0.1, 5, 200)
    
    # Multiplication: a * b = exp(log(a) + log(b))
    ax = axes[0, 0]
    b_val = 2.0
    direct = x * b_val
    eml = np.exp(np.log(x) + np.log(b_val))
    ax.plot(x, direct, 'b-', linewidth=2, label=f'x × {b_val} (direct)')
    ax.plot(x, eml, 'r--', linewidth=2, label=f'exp(log(x) + log({b_val}))')
    ax.set_title('Product via exp-log')
    ax.set_xlabel('x')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    # Power: x^n = exp(n * log(x))
    ax = axes[0, 1]
    for n in [2, 3, 5]:
        direct = x**n
        eml = np.exp(n * np.log(x))
        ax.plot(x, direct, linewidth=2, label=f'x^{n}')
    ax.set_title('Powers via exp(n·log(x))')
    ax.set_xlabel('x')
    ax.set_ylim(0, 50)
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    # Reciprocal: 1/x = exp(-log(x))
    ax = axes[1, 0]
    direct = 1.0 / x
    eml = np.exp(-np.log(x))
    ax.plot(x, direct, 'b-', linewidth=2, label='1/x (direct)')
    ax.plot(x, eml, 'r--', linewidth=2, label='exp(-log(x))')
    ax.set_title('Reciprocal via exp-log')
    ax.set_xlabel('x')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    # Square root: √x = exp(log(x)/2)
    ax = axes[1, 1]
    direct = np.sqrt(x)
    eml = np.exp(np.log(x) / 2)
    ax.plot(x, direct, 'b-', linewidth=2, label='√x (direct)')
    ax.plot(x, eml, 'r--', linewidth=2, label='exp(log(x)/2)')
    ax.set_title('Square root via exp-log')
    ax.set_xlabel('x')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('eml_reductions.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: eml_reductions.png")


def plot_depth_hierarchy():
    """Plot functions at different EML depths."""
    fig, ax = plt.subplots(figsize=(10, 7))
    
    x = np.linspace(0.1, 3.0, 300)
    
    # Depth 0: polynomial
    y0 = 2*x**2 + x + 1
    ax.plot(x, y0, linewidth=2, label='Depth 0: 2x² + x + 1', color='#2196F3')
    
    # Depth 1: exp(x), log(x)
    y1a = np.exp(x)
    ax.plot(x, y1a, linewidth=2, label='Depth 1: exp(x)', color='#4CAF50')
    
    # Depth 1: diagonal EML
    y1b = np.exp(x) - np.log(x)
    ax.plot(x, y1b, linewidth=2, label='Depth 1: exp(x) - log(x)', color='#FF9800', linestyle='--')
    
    # Depth 2: exp(exp(x))
    y2 = np.exp(np.exp(np.minimum(x, 2.5)))  # Clip to avoid overflow
    ax.plot(x[x <= 2.5], y2[x <= 2.5], linewidth=2, label='Depth 2: exp(exp(x))', color='#F44336')
    
    ax.set_xlabel('x', fontsize=14)
    ax.set_ylabel('f(x)', fontsize=14)
    ax.set_title('EML Depth Hierarchy', fontsize=16, fontweight='bold')
    ax.set_ylim(0, 50)
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('eml_depth_hierarchy.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: eml_depth_hierarchy.png")


def plot_approximation_quality():
    """Plot polynomial (EML) approximation of sin and exp."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    fig.suptitle("EML Polynomial Approximation Quality", fontsize=16, fontweight='bold')
    
    # sin(x) approximation
    ax = axes[0]
    x = np.linspace(-np.pi, np.pi, 500)
    exact = np.sin(x)
    ax.plot(x, exact, 'k-', linewidth=2, label='sin(x) (exact)')
    
    for n, color in [(3, '#E91E63'), (5, '#FF9800'), (9, '#4CAF50')]:
        # Taylor polynomial
        approx = np.zeros_like(x)
        for k in range(n):
            approx += ((-1)**k / math.factorial(2*k + 1)) * x**(2*k + 1)
        ax.plot(x, approx, '--', linewidth=1.5, color=color, label=f'Taylor deg {2*n-1}')
    
    ax.set_title('sin(x) approximation')
    ax.set_xlabel('x')
    ax.set_ylim(-2, 2)
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    # Approximation error
    ax = axes[1]
    degrees = list(range(1, 20))
    errors = []
    
    for deg in degrees:
        # Taylor series for sin
        n_terms = (deg + 1) // 2
        def taylor_sin(t, nt=n_terms):
            s = 0.0
            for k in range(nt):
                s += ((-1)**k / math.factorial(2*k + 1)) * t**(2*k + 1)
            return s
        
        test_x = np.linspace(-np.pi, np.pi, 200)
        max_err = max(abs(math.sin(t) - taylor_sin(t)) for t in test_x)
        errors.append(max_err)
    
    ax.semilogy(degrees, errors, 'bo-', linewidth=2, markersize=6)
    ax.set_title('Approximation error vs polynomial degree')
    ax.set_xlabel('Polynomial degree (EML size)')
    ax.set_ylabel('Max error on [-π, π]')
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('eml_approximation.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: eml_approximation.png")


if __name__ == "__main__":
    plot_eml_reductions()
    plot_depth_hierarchy()
    plot_approximation_quality()
    print("\nAll visualizations generated.")
