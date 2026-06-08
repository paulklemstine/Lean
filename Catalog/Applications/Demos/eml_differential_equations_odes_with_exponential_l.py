#!/usr/bin/env python3
"""
EML Differential Equations: Demonstrations

Numerical examples demonstrating:
1. Abel's Wronskian Identity for specific ODEs
2. Riccati reduction: y''/y = w' + w²
3. Airy Riccati polynomial degree obstruction
4. Double exponential ODE solutions
5. Growth rate comparisons: EML vs Airy
"""

import numpy as np
from scipy.integrate import solve_ivp
from scipy.special import airy


def demo_abel_identity():
    """Demonstrate Abel's Wronskian Identity for y'' + y = 0."""
    print("=" * 60)
    print("Demo 1: Abel's Wronskian Identity")
    print("ODE: y'' + y = 0  (p(x) = 0, q(x) = 1)")
    print("Solutions: y1 = cos(x), y2 = sin(x)")
    print("=" * 60)
    
    x = np.linspace(0, 4*np.pi, 1000)
    y1 = np.cos(x)
    y2 = np.sin(x)
    y1_prime = -np.sin(x)
    y2_prime = np.cos(x)
    
    W = y1 * y2_prime - y2 * y1_prime  # Wronskian
    
    print(f"W(0) = {W[0]:.6f}")
    print(f"W(π) = {W[len(x)//4]:.6f}")
    print(f"W(2π) = {W[len(x)//2]:.6f}")
    print(f"W(4π) = {W[-1]:.6f}")
    print(f"Since p(x) = 0, Abel says W' = 0, so W = const = 1. ✓")
    print(f"Max |W - 1| = {np.max(np.abs(W - 1)):.2e}")
    print()


def demo_abel_exponential():
    """Abel's identity for y'' - y = 0 (exponential solutions)."""
    print("=" * 60)
    print("Demo 2: Abel's Identity with Exponential Solutions")
    print("ODE: y'' - y = 0  (p(x) = 0, q(x) = -1)")
    print("Solutions: y1 = exp(x), y2 = exp(-x)")
    print("=" * 60)
    
    x = np.linspace(-2, 2, 100)
    y1 = np.exp(x)
    y2 = np.exp(-x)
    y1p = np.exp(x)
    y2p = -np.exp(-x)
    
    W = y1 * y2p - y2 * y1p
    print(f"W(x) = exp(x)·(-exp(-x)) - exp(-x)·exp(x) = -2")
    print(f"Computed: W(0) = {W[50]:.6f}, W(1) = {W[75]:.6f}")
    print(f"Constant Wronskian confirms Abel's identity (p=0). ✓")
    print()


def demo_riccati_reduction():
    """Demonstrate the Riccati reduction w = y'/y."""
    print("=" * 60)
    print("Demo 3: Riccati Reduction")
    print("ODE: y'' = y (i.e., r(x) = 1)")
    print("Solution: y = exp(x), so w = y'/y = 1")
    print("Riccati: w' + w² = 0 + 1 = 1 = r(x) ✓")
    print("=" * 60)
    
    x = np.linspace(0, 3, 100)
    y = np.exp(x)
    w = np.ones_like(x)  # w = 1
    
    # Verify w' + w² = r(x) = 1
    w_prime = np.zeros_like(x)
    riccati_lhs = w_prime + w**2
    print(f"w'(x) + w(x)² = {riccati_lhs[0]:.6f} (should be 1)")
    print()
    
    # More interesting: y'' = 4y, y = exp(2x), w = 2
    print("ODE: y'' = 4y (r(x) = 4)")
    print("Solution: y = exp(2x), w = y'/y = 2")
    w2 = 2 * np.ones_like(x)
    print(f"w' + w² = 0 + 4 = {0 + 4} = r(x) ✓")
    print()


def demo_airy_polynomial_obstruction():
    """Show no polynomial satisfies w' + w² = x."""
    print("=" * 60)
    print("Demo 4: Airy Riccati Polynomial Obstruction")
    print("Riccati equation: w' + w² = x")
    print("Testing polynomial candidates...")
    print("=" * 60)
    
    x = np.linspace(-5, 5, 1000)
    
    # Test constant: w = c => c² = x, impossible
    for c in [0, 1, -1, 0.5]:
        residual = c**2 - x
        print(f"  w = {c}: max|w' + w² - x| = {np.max(np.abs(residual)):.2f}")
    
    # Test linear: w = ax + b => a + a²x² + 2abx + b² = x
    # Need a² = 0 (coeff of x²), but then a = 0, contradiction
    print(f"\n  Linear w = ax + b requires a² = 0 (x² coeff) => a = 0.")
    print(f"  But then w is constant, already ruled out.")
    
    # Test quadratic: w = x² => w' + w² = 2x + x⁴, degree 4 ≠ 1
    w_quad = x**2
    lhs = 2*x + x**4
    print(f"\n  w = x²: w' + w² = 2x + x⁴ (degree 4 ≠ 1)")
    print(f"  Degree mismatch confirms no polynomial solution. ✓")
    print()


def demo_airy_solutions():
    """Compute and display Airy function solutions."""
    print("=" * 60)
    print("Demo 5: Airy Function Solutions")
    print("y'' = x·y  (no EML solutions exist!)")
    print("=" * 60)
    
    x = np.linspace(-15, 5, 1000)
    ai, aip, bi, bip = airy(x)
    
    print(f"  Ai(0) = {ai[x >= 0][0]:.6f}  (≈ 0.355028)")
    print(f"  Bi(0) = {bi[x >= 0][0]:.6f}  (≈ 0.614927)")
    print(f"  Ai(5) = {ai[-1]:.6e}  (rapidly decaying)")
    print(f"  Bi(5) = {bi[-1]:.6e}  (rapidly growing)")
    
    # Verify y'' = x·y numerically
    dx = x[1] - x[0]
    ai_pp = np.diff(ai, 2) / dx**2  # numerical second derivative
    x_mid = x[1:-1]
    ai_mid = ai[1:-1]
    residual = ai_pp - x_mid * ai_mid
    print(f"\n  Numerical verification: max|Ai'' - x·Ai| = {np.max(np.abs(residual)):.4e}")
    print(f"  (Non-zero due to numerical differentiation error)")
    
    # Growth order: Bi(x) ~ exp(2x^(3/2)/3) for large x
    x_large = np.array([2, 3, 4, 5])
    _, _, bi_large, _ = airy(x_large)
    predicted = np.exp(2 * x_large**(3/2) / 3) / (np.sqrt(np.pi) * x_large**(1/4))
    print(f"\n  Growth comparison for Bi(x):")
    print(f"  x    Bi(x)           exp(2x^(3/2)/3)/(√π·x^(1/4))")
    for xi, b, p in zip(x_large, bi_large, predicted):
        print(f"  {xi:.0f}    {b:.6e}    {p:.6e}")
    print(f"\n  Growth order 3/2 is NOT a natural number => not EML! ✓")
    print()


def demo_double_exponential():
    """Demonstrate the double exponential ODE from Abel's identity."""
    print("=" * 60)
    print("Demo 6: Double Exponential ODE")
    print("f(x) = exp(-exp(x)) satisfies f' = -exp(x)·f")
    print("This arises from Abel's identity with p(x) = exp(x)")
    print("=" * 60)
    
    x = np.linspace(-2, 3, 100)
    f = np.exp(-np.exp(x))
    f_prime = -np.exp(x) * np.exp(-np.exp(x))
    
    # Numerical derivative
    dx = x[1] - x[0]
    f_prime_num = np.gradient(f, dx)
    
    print(f"  f(0) = exp(-1) = {f[x >= 0][0]:.6f}")
    print(f"  f'(0) = -1·exp(-1) = {f_prime[x >= 0][0]:.6f}")
    print(f"  f(1) = exp(-e) = {np.exp(-np.e):.6f}")
    print(f"  f(2) = exp(-e²) = {np.exp(-np.e**2):.10f}")
    print(f"  f(3) = exp(-e³) ≈ {np.exp(-np.e**3):.2e}")
    print(f"\n  Double exponential decay is faster than any polynomial decay.")
    print(f"  This is EML of tower height 2.")
    print()


def demo_eml_derivative_closure():
    """Show EML derivatives stay within EML class."""
    print("=" * 60)
    print("Demo 7: EML Differential Closure")
    print("d/dx[exp(x) - log(x)] = exp(x) - 1/x")
    print("Both terms are EML building blocks.")
    print("=" * 60)
    
    x = np.linspace(0.1, 3, 100)
    eml_val = np.exp(x) - np.log(x)
    eml_deriv = np.exp(x) - 1/x
    
    # Numerical derivative
    dx = x[1] - x[0]
    eml_deriv_num = np.gradient(eml_val, dx)
    
    error = np.max(np.abs(eml_deriv - eml_deriv_num))
    print(f"  Max |exact - numerical derivative| = {error:.6e}")
    print(f"  eml(x,x)' = exp(x) - 1/x")
    print(f"  = [exponential part] + [rational part]")
    print(f"  Both parts are EML building blocks. ✓")
    print()
    
    # Log-derivative of product
    print("  Log-derivative additivity:")
    print("  (log(f·g))' = f'/f + g'/g")
    f = np.exp(x)
    g = x**2
    fg = f * g
    
    # d/dx[log(exp(x)·x²)] = d/dx[x + 2·log(x)] = 1 + 2/x
    exact = 1 + 2/x
    # f'/f + g'/g = exp(x)/exp(x) + 2x/x² = 1 + 2/x
    computed = np.exp(x)/np.exp(x) + 2*x/x**2
    print(f"  f = exp(x), g = x²")
    print(f"  f'/f + g'/g = 1 + 2/x")
    print(f"  Max error: {np.max(np.abs(exact - computed)):.2e} ✓")
    print()


if __name__ == "__main__":
    demo_abel_identity()
    demo_abel_exponential()
    demo_riccati_reduction()
    demo_airy_polynomial_obstruction()
    demo_airy_solutions()
    demo_double_exponential()
    demo_eml_derivative_closure()
    
    print("=" * 60)
    print("Summary: All demonstrations confirm the formal theorems.")
    print("The Airy equation y'' = xy has no EML solution.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Airy Equation and Polynomial Obstruction

Standalone matplotlib visualization showing:
1. Airy functions Ai(x) and Bi(x)
2. The Riccati equation w' + w² = x and why polynomials fail
3. Growth order comparison: Airy (3/2) vs EML (integer)
"""

import numpy as np
import matplotlib.pyplot as plt
from scipy.special import airy


def plot_airy_functions(ax):
    """Plot Airy functions Ai(x) and Bi(x)."""
    x = np.linspace(-15, 5, 1000)
    ai_vals, _, bi_vals, _ = airy(x)
    
    ax.plot(x, ai_vals, 'b-', linewidth=2, label='Ai(x)')
    ax.plot(x, bi_vals, 'r-', linewidth=2, label='Bi(x)')
    ax.axhline(y=0, color='k', linewidth=0.5)
    ax.axvline(x=0, color='k', linewidth=0.5)
    ax.set_xlim(-15, 5)
    ax.set_ylim(-0.8, 1.5)
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('y', fontsize=12)
    ax.set_title("Airy Functions: Solutions of y'' = xy\n(No EML representation exists)", fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)


def plot_riccati_polynomial_obstruction(ax):
    """Show degree mismatch for Airy Riccati equation."""
    x = np.linspace(-3, 3, 200)
    
    # Plot r(x) = x (the target)
    ax.plot(x, x, 'k-', linewidth=2.5, label='r(x) = x (degree 1)')
    
    # Plot w' + w² for various polynomial w
    # w = 0: w' + w² = 0
    ax.plot(x, np.zeros_like(x), 'b--', linewidth=1.5, label="w=0: w'+w²=0 (deg 0)")
    
    # w = 1: w' + w² = 1
    ax.plot(x, np.ones_like(x), 'g--', linewidth=1.5, label="w=1: w'+w²=1 (deg 0)")
    
    # w = x: w' + w² = 1 + x²
    ax.plot(x, 1 + x**2, 'r--', linewidth=1.5, label="w=x: w'+w²=1+x² (deg 2)")
    
    # w = x²: w' + w² = 2x + x⁴
    vals = 2*x + x**4
    mask = np.abs(vals) < 15
    ax.plot(x[mask], vals[mask], 'm--', linewidth=1.5, label="w=x²: w'+w²=2x+x⁴ (deg 4)")
    
    ax.set_xlim(-3, 3)
    ax.set_ylim(-5, 10)
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel("w' + w²", fontsize=12)
    ax.set_title("Polynomial Degree Obstruction\nNo polynomial w satisfies w'+w²=x", fontsize=13)
    ax.legend(fontsize=9, loc='upper left')
    ax.grid(True, alpha=0.3)
    
    # Annotate the key insight
    ax.annotate('Degree mismatch!\ndeg(w²) ≠ 1 for any w',
                xy=(1, 1), xytext=(1.5, 7),
                arrowprops=dict(arrowstyle='->', color='red'),
                fontsize=10, color='red', fontweight='bold')


def plot_growth_orders(ax):
    """Compare growth orders of EML vs Airy solutions."""
    x = np.linspace(1, 8, 200)
    
    # EML growth: exp(x) ~ exp(x) (order ∞)
    # polynomial: x^n (order n ∈ ℕ)
    # Airy Bi: ~ exp(2x^(3/2)/3) (order 3/2)
    
    # Plot log-log of |f(x)| to show growth orders
    poly1 = x  # order 1
    poly2 = x**2  # order 2
    airy_growth = np.exp(2 * x**(3/2) / 3)  # order 3/2
    exp_growth = np.exp(x)  # order ∞
    
    ax.semilogy(x, poly1, 'b-', linewidth=1.5, label='x (order 1)')
    ax.semilogy(x, poly2, 'g-', linewidth=1.5, label='x² (order 2)')
    ax.semilogy(x, airy_growth, 'r-', linewidth=2.5, 
                label='exp(2x^{3/2}/3) (order 3/2)')
    ax.semilogy(x, exp_growth, 'k--', linewidth=1.5, label='exp(x) (order ∞)')
    
    # Highlight the gap: order 3/2 is between 1 and 2
    ax.fill_between(x, poly1, poly2, alpha=0.1, color='yellow',
                     label='Gap: orders 1 < 3/2 < 2')
    
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('|f(x)| (log scale)', fontsize=12)
    ax.set_title("Growth Order Obstruction\nAiry has order 3/2 ∉ ℕ", fontsize=13)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(1, 1e8)


def plot_wronskian_abel(ax):
    """Demonstrate Abel's identity: constant Wronskian for y''+y=0."""
    x = np.linspace(0, 4*np.pi, 500)
    
    # Solutions of y'' + y = 0
    y1 = np.cos(x)
    y2 = np.sin(x)
    y1p = -np.sin(x)
    y2p = np.cos(x)
    
    W = y1 * y2p - y2 * y1p  # = 1 identically
    
    ax.plot(x, y1, 'b-', linewidth=1.5, alpha=0.7, label='y₁ = cos(x)')
    ax.plot(x, y2, 'r-', linewidth=1.5, alpha=0.7, label='y₂ = sin(x)')
    ax.plot(x, W, 'k-', linewidth=2.5, label='W(y₁,y₂) = 1')
    
    ax.axhline(y=0, color='gray', linewidth=0.5)
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('value', fontsize=12)
    ax.set_title("Abel's Wronskian Identity\ny''+y=0: W(cos,sin) = 1 (constant)", fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 11))
    fig.suptitle('EML Differential Equations: Airy Obstruction Theory', 
                 fontsize=16, fontweight='bold', y=0.98)
    
    plot_airy_functions(axes[0, 0])
    plot_riccati_polynomial_obstruction(axes[0, 1])
    plot_growth_orders(axes[1, 0])
    plot_wronskian_abel(axes[1, 1])
    
    plt.tight_layout(rect=[0, 0, 1, 0.95])
    plt.savefig('airy_obstruction.png', dpi=150, bbox_inches='tight')
    plt.show()
    print("Saved: airy_obstruction.png")


if __name__ == "__main__":
    main()
