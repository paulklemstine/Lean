#!/usr/bin/env python3
"""
EML Differential Equations: Numerical Demonstrations

Demonstrates the key results from the EML differential obstruction theory:
1. Airy equation solutions and their growth rates
2. EML tower functions and growth comparison
3. Wronskian conservation for Airy solutions
4. The "gap" between EML growth levels
"""

import numpy as np
from scipy.integrate import solve_ivp
from scipy.special import airy as scipy_airy


def airy_ode(x, y):
    """Airy equation y'' = x*y as a first-order system."""
    return [y[1], x * y[0]]


def compute_airy_solutions(x_range=(0, 15), n_points=1000):
    """Compute Airy function Ai(x) and Bi(x) numerically."""
    x_eval = np.linspace(x_range[0], x_range[1], n_points)
    
    # Airy Ai: Ai(0) ≈ 0.3550, Ai'(0) ≈ -0.2588
    sol_ai = solve_ivp(airy_ode, x_range, [0.3550280539, -0.2588194038],
                       t_eval=x_eval, rtol=1e-12, atol=1e-14)
    
    # Airy Bi: Bi(0) ≈ 0.6149, Bi'(0) ≈ 0.4483
    sol_bi = solve_ivp(airy_ode, x_range, [0.6149266274, 0.4482883574],
                       t_eval=x_eval, rtol=1e-12, atol=1e-14)
    
    return x_eval, sol_ai, sol_bi


def tower_exp(d, x):
    """Compute tower exponential: tower(0,x) = x, tower(d+1,x) = exp(tower(d,x))."""
    result = x
    for _ in range(d):
        result = np.exp(np.clip(result, -500, 500))  # clip to avoid overflow
    return result


def airy_growth_function(x):
    """The asymptotic growth rate of Bi(x): exp(2/3 * x^{3/2})."""
    return np.exp((2/3) * np.power(np.maximum(x, 0), 1.5))


def wronskian(y1, y1p, y2, y2p):
    """Compute the Wronskian W(y1, y2) = y1*y2' - y1'*y2."""
    return y1 * y2p - y1p * y2


def demo_airy_solutions():
    """Demo 1: Airy function solutions."""
    print("=" * 60)
    print("Demo 1: Airy Equation y'' = x*y Solutions")
    print("=" * 60)
    
    x_eval, sol_ai, sol_bi = compute_airy_solutions(x_range=(0, 10))
    
    print(f"\nAiry Ai(x) at selected points:")
    for i in range(0, len(x_eval), len(x_eval)//5):
        x = x_eval[i]
        print(f"  Ai({x:.1f}) = {sol_ai.y[0][i]:.6e}")
    
    print(f"\nAiry Bi(x) at selected points:")
    for i in range(0, len(x_eval), len(x_eval)//5):
        x = x_eval[i]
        print(f"  Bi({x:.1f}) = {sol_bi.y[0][i]:.6e}")
    
    print("\nNote: Bi(x) grows explosively while Ai(x) decays to 0.")
    print("The growth rate of Bi(x) ~ exp(2/3 * x^{3/2}) / (pi^{1/2} * x^{1/4})")


def demo_growth_comparison():
    """Demo 2: EML tower growth vs Airy growth."""
    print("\n" + "=" * 60)
    print("Demo 2: EML Tower Growth vs Airy Growth")
    print("=" * 60)
    
    x_vals = [1, 2, 3, 4, 5, 6, 7, 8]
    
    print(f"\n{'x':>4} | {'x^{3/2}':>12} | {'exp(x)':>12} | {'exp(2/3·x^{3/2})':>18} | {'exp(x²)':>12}")
    print("-" * 70)
    
    for x in x_vals:
        x32 = x ** 1.5
        exp_x = np.exp(x)
        airy_g = np.exp((2/3) * x32)
        exp_x2 = np.exp(min(x**2, 500))
        
        print(f"{x:4d} | {x32:12.2f} | {exp_x:12.2f} | {airy_g:18.2f} | {exp_x2:12.2e}")
    
    print("\nKey insight: exp(2/3·x^{3/2}) grows BETWEEN exp(x) and exp(x²)")
    print("This 'gap' is why Airy solutions cannot be EML functions.")
    print("EML depth-1 functions have growth exp(polynomial), requiring INTEGER degree.")
    print("The exponent 3/2 is not an integer → no EML expression can match this growth.")


def demo_wronskian_conservation():
    """Demo 3: Wronskian conservation for Airy equation."""
    print("\n" + "=" * 60)
    print("Demo 3: Wronskian Conservation (Abel's Theorem)")
    print("=" * 60)
    
    x_eval, sol_ai, sol_bi = compute_airy_solutions(x_range=(0, 8))
    
    W = wronskian(sol_ai.y[0], sol_ai.y[1], sol_bi.y[0], sol_bi.y[1])
    
    print(f"\nWronskian W(Ai, Bi) = Ai·Bi' - Ai'·Bi")
    print(f"Theory predicts: W = 1/π ≈ {1/np.pi:.10f} (constant)")
    print(f"\nSampled values:")
    
    for i in range(0, len(x_eval), len(x_eval)//8):
        x = x_eval[i]
        print(f"  W({x:.2f}) = {W[i]:.10f}  (error: {abs(W[i] - 1/np.pi):.2e})")
    
    print(f"\nMax deviation from 1/π: {np.max(np.abs(W - 1/np.pi)):.2e}")
    print("The Wronskian is constant because p = 0 in the Airy equation.")
    print("This is Abel's theorem: W' = -p·W, and p = 0 → W' = 0.")


def demo_eml_depth_hierarchy():
    """Demo 4: EML depth hierarchy and growth filtration."""
    print("\n" + "=" * 60)
    print("Demo 4: EML Depth Hierarchy")
    print("=" * 60)
    
    print("\nEML functions organized by depth:")
    print("  Depth 0: Polynomials (1, x, x², x³, ...)")
    print("  Depth 1: exp(p(x)), log(p(x)), p(x)·exp(q(x)), ...")
    print("  Depth 2: exp(exp(x)), log(log(x)), exp(x·log(x)), ...")
    print("  Depth d: d-fold nested exp/log compositions")
    
    print("\nGrowth rates at x = 5:")
    x = 5.0
    examples = [
        ("x²", x**2, 0),
        ("x¹⁰", x**10, 0),
        ("exp(x)", np.exp(x), 1),
        ("exp(2/3·x^{3/2})", np.exp(2/3 * x**1.5), "???"),
        ("exp(x²)", np.exp(x**2), 1),
        ("exp(exp(x))", np.exp(np.exp(min(x, 6))), 2),
    ]
    
    print(f"  {'Expression':>20} | {'Value':>15} | {'EML Depth':>10}")
    print("  " + "-" * 52)
    for name, val, depth in examples:
        print(f"  {name:>20} | {val:>15.2e} | {str(depth):>10}")
    
    print("\n  The '???' for exp(2/3·x^{3/2}) shows the problem:")
    print("  x^{3/2} is NOT a polynomial (non-integer exponent),")
    print("  so exp(2/3·x^{3/2}) doesn't fit any EML depth level.")


def demo_differential_invariant():
    """Demo 5: Differential invariant theory."""
    print("\n" + "=" * 60)
    print("Demo 5: Differential Invariant Theory")
    print("=" * 60)
    
    print("\nFor y'' + p·y' + q·y = 0, the differential invariant is:")
    print("  I(x) = q(x) - p(x)²/4 - p'(x)/2")
    print("\nThe invariant determines the equation up to gauge transformation.")
    print("\nExamples:")
    
    examples = [
        ("Airy: y'' - x·y = 0", "p=0, q=-x", "I = -x"),
        ("Hermite: y'' - 2x·y' + 2n·y = 0", "p=-2x, q=2n", "I = 2n - x² + 1"),
        ("Bessel (transformed): u'' + (1-ν²/x²)u = 0", "p=0, q=1-ν²/x²", "I = 1-ν²/x²"),
    ]
    
    for name, coeffs, invariant in examples:
        print(f"  {name}")
        print(f"    {coeffs} → {invariant}")
        print()


if __name__ == "__main__":
    demo_airy_solutions()
    demo_growth_comparison()
    demo_wronskian_conservation()
    demo_eml_depth_hierarchy()
    demo_differential_invariant()
    
    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: The EML Growth Gap

Shows how Airy solutions (exp(2/3 * x^{3/2})) fall in a "gap" between
EML depth levels, making them impossible to express as EML functions.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib


def plot_growth_gap():
    """Plot the growth rates of various functions showing the EML gap."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Panel 1: Log-scale growth comparison
    ax1 = axes[0]
    x = np.linspace(1, 8, 500)
    
    # Depth 0 functions
    ax1.plot(x, np.log(x**2), 'b--', alpha=0.5, label='x² (depth 0)')
    ax1.plot(x, np.log(x**5), 'b-', alpha=0.5, label='x⁵ (depth 0)')
    
    # Depth 1 functions
    ax1.plot(x, x, 'g--', label='exp(x) (depth 1, deg 1)')
    ax1.plot(x, x**2, 'g-', label='exp(x²) (depth 1, deg 2)')
    
    # Airy growth
    ax1.plot(x, (2/3) * x**1.5, 'r-', linewidth=3, label='exp(⅔x^{3/2}) [AIRY]')
    
    ax1.set_xlabel('x', fontsize=12)
    ax1.set_ylabel('log(f(x))', fontsize=12)
    ax1.set_title('Growth Rate Comparison (log scale)', fontsize=14)
    ax1.legend(fontsize=9)
    ax1.set_ylim(0, 40)
    ax1.grid(True, alpha=0.3)
    
    # Shade the gap region
    ax1.fill_between(x, x, (2/3)*x**1.5, alpha=0.15, color='red',
                     label='_nolegend_')
    ax1.fill_between(x, (2/3)*x**1.5, x**2, alpha=0.15, color='red',
                     label='_nolegend_')
    ax1.text(6, 18, 'EML\nGAP', fontsize=16, color='red', fontweight='bold',
             ha='center', va='center', alpha=0.7)
    
    # Panel 2: Exponent comparison
    ax2 = axes[1]
    x = np.linspace(0, 10, 500)
    
    degrees = [1, 1.5, 2, 3]
    colors = ['green', 'red', 'green', 'green']
    styles = ['--', '-', '-', '-.']
    widths = [1, 3, 1, 1]
    labels_list = ['x¹ (integer)', 'x^{3/2} (AIRY)', 'x² (integer)', 'x³ (integer)']
    
    for deg, color, style, width, label in zip(degrees, colors, styles, widths, labels_list):
        ax2.plot(x, x**deg, color=color, linestyle=style, linewidth=width, label=label)
    
    ax2.set_xlabel('x', fontsize=12)
    ax2.set_ylabel('Exponent function', fontsize=12)
    ax2.set_title('EML Requires Integer Polynomial Degrees', fontsize=14)
    ax2.legend(fontsize=10)
    ax2.set_ylim(0, 50)
    ax2.grid(True, alpha=0.3)
    
    # Annotate the gap
    ax2.annotate('x^{3/2} has non-integer\ndegree → not polynomial\n→ not EML',
                xy=(4, 4**1.5), xytext=(5, 35),
                arrowprops=dict(arrowstyle='->', color='red', lw=2),
                fontsize=10, color='red', fontweight='bold')
    
    plt.tight_layout()
    plt.savefig('/workspace/request-project/Applications/growth_gap.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved growth_gap.png")


def plot_wronskian_conservation():
    """Plot Wronskian conservation for the Airy equation."""
    from scipy.integrate import solve_ivp
    
    def airy_system(x, y):
        return [y[1], x * y[0]]
    
    x_span = (0, 12)
    x_eval = np.linspace(0, 12, 2000)
    
    sol_ai = solve_ivp(airy_system, x_span, [0.3550280539, -0.2588194038],
                       t_eval=x_eval, rtol=1e-12, atol=1e-14)
    sol_bi = solve_ivp(airy_system, x_span, [0.6149266274, 0.4482883574],
                       t_eval=x_eval, rtol=1e-12, atol=1e-14)
    
    W = sol_ai.y[0] * sol_bi.y[1] - sol_ai.y[1] * sol_bi.y[0]
    
    fig, axes = plt.subplots(2, 1, figsize=(12, 8))
    
    # Panel 1: Solutions
    ax1 = axes[0]
    ax1.plot(x_eval, sol_ai.y[0], 'b-', label='Ai(x)', linewidth=2)
    ax1.plot(x_eval, sol_bi.y[0], 'r-', label='Bi(x)', linewidth=2)
    ax1.set_ylabel('y(x)', fontsize=12)
    ax1.set_title('Airy Functions and Wronskian Conservation', fontsize=14)
    ax1.legend(fontsize=11)
    ax1.set_ylim(-2, 5)
    ax1.grid(True, alpha=0.3)
    
    # Panel 2: Wronskian
    ax2 = axes[1]
    ax2.plot(x_eval, W, 'k-', linewidth=2, label='W(Ai, Bi)')
    ax2.axhline(y=1/np.pi, color='r', linestyle='--', alpha=0.7, label=f'1/π ≈ {1/np.pi:.6f}')
    ax2.set_xlabel('x', fontsize=12)
    ax2.set_ylabel('Wronskian', fontsize=12)
    ax2.set_title("Abel's Theorem: W' = -p·W = 0 (since p=0)", fontsize=14)
    ax2.legend(fontsize=11)
    ax2.set_ylim(0.3, 0.35)
    ax2.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('/workspace/request-project/Applications/wronskian_conservation.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved wronskian_conservation.png")


def plot_tower_hierarchy():
    """Plot the EML tower function hierarchy."""
    fig, ax = plt.subplots(figsize=(10, 7))
    
    x = np.linspace(0.1, 4, 500)
    
    # Tower level 0: identity
    ax.plot(x, x, 'b-', linewidth=2, label='tower₀(x) = x')
    
    # Tower level 1: exp
    ax.plot(x, np.exp(x), 'g-', linewidth=2, label='tower₁(x) = eˣ')
    
    # Tower level 2: exp(exp)
    y2 = np.exp(np.exp(np.clip(x, -10, 3.5)))
    ax.plot(x[y2 < 1e6], y2[y2 < 1e6], 'r-', linewidth=2, label='tower₂(x) = e^(eˣ)')
    
    # Airy growth (the misfit)
    airy_y = np.exp((2/3) * x**1.5)
    ax.plot(x, airy_y, 'k--', linewidth=3, label='Airy: exp(⅔x^{3/2})')
    
    ax.set_yscale('log')
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('f(x) (log scale)', fontsize=12)
    ax.set_title('EML Tower Hierarchy vs Airy Growth', fontsize=14)
    ax.legend(fontsize=11)
    ax.set_ylim(1e-1, 1e6)
    ax.grid(True, alpha=0.3, which='both')
    
    # Annotate
    ax.annotate('Airy growth sits BETWEEN\ntower levels — no EML fit',
                xy=(3, np.exp((2/3)*3**1.5)), xytext=(1.5, 1e5),
                arrowprops=dict(arrowstyle='->', color='black', lw=2),
                fontsize=11, fontweight='bold',
                bbox=dict(boxstyle='round,pad=0.3', facecolor='yellow', alpha=0.8))
    
    plt.tight_layout()
    plt.savefig('/workspace/request-project/Applications/tower_hierarchy.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved tower_hierarchy.png")


if __name__ == "__main__":
    plot_growth_gap()
    plot_wronskian_conservation()
    plot_tower_hierarchy()
