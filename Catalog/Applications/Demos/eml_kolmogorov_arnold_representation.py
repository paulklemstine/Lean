#!/usr/bin/env python3
"""
EML-KA Representation Demo: Kolmogorov-Arnold meets Exponential-Logarithmic

Demonstrates the key results from the EML-KA research:
1. Real-exponent monomial decomposition
2. Exponential product closure
3. n-variable monomial decomposition
4. Power sum decomposition
5. Arithmetic mean via EML-KA
6. AM-GM inequality via EML-KA
7. Rényi entropy bridge
8. Log-sum-exp bounds
9. Addition barrier
"""

import numpy as np
from typing import List, Tuple

def rpow_monomial_eml(x: float, y: float, a: float, b: float) -> float:
    """Compute x^a * y^b via EML-KA: exp(a*log(x) + b*log(y))"""
    return np.exp(a * np.log(x) + b * np.log(y))

def exp_product_closure(x: float, y: float, 
                        a1: float, b1: float, 
                        a2: float, b2: float) -> Tuple[float, float]:
    """
    Demonstrate product closure: 
    exp(a1*log(x) + b1*log(y)) * exp(a2*log(x) + b2*log(y))
    = exp((a1+a2)*log(x) + (b1+b2)*log(y))
    """
    lhs = (np.exp(a1*np.log(x) + b1*np.log(y)) * 
           np.exp(a2*np.log(x) + b2*np.log(y)))
    rhs = np.exp((a1+a2)*np.log(x) + (b1+b2)*np.log(y))
    return lhs, rhs

def nvar_monomial(xs: List[float], alphas: List[float]) -> Tuple[float, float]:
    """
    n-variable monomial: ∏ x_i^a_i = exp(∑ a_i * log(x_i))
    Returns (direct_product, eml_representation)
    """
    direct = np.prod([x**a for x, a in zip(xs, alphas)])
    eml = np.exp(sum(a * np.log(x) for x, a in zip(xs, alphas)))
    return direct, eml

def power_sum_ka(x: float, y: float, n: int) -> Tuple[float, float]:
    """
    x^n + y^n via 2-term EML-KA:
    exp(n*log(x)) + exp(n*log(y))
    """
    direct = x**n + y**n
    eml = np.exp(n * np.log(x)) + np.exp(n * np.log(y))
    return direct, eml

def arith_mean_ka(x: float, y: float) -> Tuple[float, float]:
    """
    (x+y)/2 via 2-term weighted EML-KA:
    (1/2)*exp(log(x)) + (1/2)*exp(log(y))
    """
    direct = (x + y) / 2
    eml = 0.5 * np.exp(np.log(x)) + 0.5 * np.exp(np.log(y))
    return direct, eml

def am_gm_eml(x: float, y: float) -> Tuple[float, float, float]:
    """
    AM-GM via EML-KA:
    geometric_mean = exp((log(x) + log(y))/2)
    arithmetic_mean = (x + y)/2
    Returns (geom_mean, arith_mean, gap)
    """
    gm = np.exp((np.log(x) + np.log(y)) / 2)
    am = (x + y) / 2
    return gm, am, am - gm

def renyi_power_sum(alpha: float, p: float) -> Tuple[float, float]:
    """
    Rényi power sum via EML-KA:
    p^α + (1-p)^α = exp(α*log(p)) + exp(α*log(1-p))
    """
    direct = p**alpha + (1-p)**alpha
    eml = np.exp(alpha * np.log(p)) + np.exp(alpha * np.log(1-p))
    return direct, eml

def log_sum_exp(a: float, b: float) -> Tuple[float, float, float]:
    """
    LogSumExp bounds: max(a,b) ≤ log(exp(a)+exp(b)) ≤ max(a,b) + log(2)
    Returns (lse, max_val, max_plus_log2)
    """
    lse = np.log(np.exp(a) + np.exp(b))
    mx = max(a, b)
    return lse, mx, mx + np.log(2)

def addition_barrier_test():
    """
    Test that x+y cannot be a monomial c*x^a*y^b.
    If it were, then at (1,1): c=2, at (2,1): 2*2^a=3, at (1,2): 2*2^b=3
    So 2^a = 2^b = 3/2, giving 2^(a+b) = 9/4.
    But at (2,2): 2*2^(a+b)=4, so 2^(a+b)=2. Contradiction: 9/4 ≠ 2.
    """
    # Fit c from (1,1)
    c = 2.0  # since 1+1 = c*1^a*1^b = c
    # From (2,1): c*2^a = 3, so 2^a = 3/2
    two_a = 3/2
    # From (1,2): c*2^b = 3, so 2^b = 3/2
    two_b = 3/2
    # Product: 2^(a+b) = 9/4
    two_ab = two_a * two_b
    # But from (2,2): c*2^(a+b) = 4, so 2^(a+b) = 2
    expected = 2.0
    return two_ab, expected, abs(two_ab - expected)

def polynomial_eml_demo():
    """
    Polynomial p(x,y) = 3x²y + 2xy³ + x in EML-KA form.
    """
    x, y = 2.0, 3.0
    # Direct computation
    direct = 3*x**2*y + 2*x*y**3 + x
    # EML-KA: ∑ c_i * exp(a_i*log(x) + b_i*log(y))
    coeffs = [3, 2, 1]
    exp_a = [2, 1, 1]
    exp_b = [1, 3, 0]
    eml = sum(c * np.exp(a*np.log(x) + b*np.log(y)) 
              for c, a, b in zip(coeffs, exp_a, exp_b))
    return direct, eml

if __name__ == "__main__":
    print("=" * 60)
    print("EML-KA Representation Demo")
    print("=" * 60)
    
    # Demo 1: Real-exponent monomial
    print("\n1. Real-Exponent Monomial Decomposition")
    x, y, a, b = 3.0, 2.0, 1.5, 2.7
    direct = x**a * y**b
    eml = rpow_monomial_eml(x, y, a, b)
    print(f"   x={x}, y={y}, a={a}, b={b}")
    print(f"   x^a * y^b = {direct:.10f}")
    print(f"   EML-KA    = {eml:.10f}")
    print(f"   Error     = {abs(direct-eml):.2e}")
    
    # Demo 2: Product closure
    print("\n2. Exponential Product Closure")
    x, y = 2.5, 1.8
    a1, b1, a2, b2 = 1.0, 2.0, 0.5, -1.0
    lhs, rhs = exp_product_closure(x, y, a1, b1, a2, b2)
    print(f"   Product of two EML terms = {lhs:.10f}")
    print(f"   Single EML term          = {rhs:.10f}")
    print(f"   Error = {abs(lhs-rhs):.2e}")
    
    # Demo 3: n-variable monomial
    print("\n3. n-Variable Monomial (n=5)")
    xs = [1.5, 2.0, 3.0, 0.8, 1.2]
    alphas = [2.0, 0.5, 1.0, -1.0, 3.0]
    direct, eml = nvar_monomial(xs, alphas)
    print(f"   Variables: {xs}")
    print(f"   Exponents: {alphas}")
    print(f"   Direct  = {direct:.10f}")
    print(f"   EML-KA  = {eml:.10f}")
    print(f"   Error   = {abs(direct-eml):.2e}")
    
    # Demo 4: Power sum
    print("\n4. Power Sum x^n + y^n (2-term EML-KA)")
    for n in [2, 3, 5]:
        direct, eml = power_sum_ka(3.0, 2.0, n)
        print(f"   n={n}: direct={direct:.4f}, EML-KA={eml:.4f}, err={abs(direct-eml):.2e}")
    
    # Demo 5: Arithmetic mean
    print("\n5. Arithmetic Mean (2-term weighted EML-KA)")
    x, y = 7.0, 3.0
    direct, eml = arith_mean_ka(x, y)
    print(f"   (x+y)/2: direct={direct}, EML-KA={eml:.10f}")
    
    # Demo 6: AM-GM
    print("\n6. AM-GM Inequality via EML-KA")
    for x, y in [(4.0, 4.0), (1.0, 9.0), (2.0, 8.0)]:
        gm, am, gap = am_gm_eml(x, y)
        print(f"   x={x}, y={y}: GM={gm:.4f} ≤ AM={am:.4f} (gap={gap:.4f})")
    
    # Demo 7: Rényi entropy
    print("\n7. Rényi Power Sum (Information Theory Bridge)")
    for alpha in [0.5, 2.0, 3.0]:
        direct, eml = renyi_power_sum(alpha, 0.3)
        print(f"   α={alpha}: direct={direct:.6f}, EML-KA={eml:.6f}")
    
    # Demo 8: LogSumExp bounds
    print("\n8. LogSumExp Bounds (Smooth Max)")
    for a, b in [(1.0, 2.0), (5.0, 5.0), (-1.0, 3.0)]:
        lse, mx, mx_log2 = log_sum_exp(a, b)
        print(f"   a={a}, b={b}: max={mx:.4f} ≤ LSE={lse:.4f} ≤ max+log2={mx_log2:.4f}")
    
    # Demo 9: Addition barrier
    print("\n9. Addition Barrier (x+y is not a monomial)")
    two_ab, expected, err = addition_barrier_test()
    print(f"   2^(a+b) should be: {expected}")
    print(f"   2^(a+b) from fit:  {two_ab}")
    print(f"   Contradiction gap: {err}")
    
    # Demo 10: Polynomial
    print("\n10. Polynomial EML-KA Completeness")
    direct, eml = polynomial_eml_demo()
    print(f"    p(2,3) = 3(4)(3) + 2(2)(27) + 2 = {direct}")
    print(f"    EML-KA = {eml:.10f}")
    
    print("\n" + "=" * 60)
    print("All demos completed successfully!")


#!/usr/bin/env python3
"""
Visualization: EML-KA Representation Landscape

Shows the key relationships between EML-KA decompositions:
1. Monomial decomposition accuracy across exponents
2. AM-GM gap as a function of x/y ratio
3. LogSumExp approximation quality
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib import cm

def plot_monomial_accuracy():
    """Plot EML-KA monomial representation accuracy across exponent space."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 4.5))
    
    # Panel 1: x^a * y^b via EML-KA for various (a,b)
    ax = axes[0]
    x_vals = np.linspace(0.1, 5, 200)
    exponents = [(1, 1), (2, 0.5), (0.5, 3), (1.5, 1.5)]
    y_fixed = 2.0
    for a, b in exponents:
        direct = x_vals**a * y_fixed**b
        eml = np.exp(a * np.log(x_vals) + b * np.log(y_fixed))
        ax.plot(x_vals, direct, '-', linewidth=2, label=f'$x^{{{a}}}y^{{{b}}}$')
        ax.plot(x_vals, eml, 'k--', linewidth=0.5, alpha=0.5)
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('$f(x, 2)$', fontsize=12)
    ax.set_title('Monomials via EML-KA (y=2)', fontsize=13)
    ax.legend(fontsize=9)
    ax.set_yscale('log')
    
    # Panel 2: Power sum x^n + y^n
    ax = axes[1]
    x_vals = np.linspace(0.1, 3, 200)
    for n in [1, 2, 3, 5]:
        ps = x_vals**n + y_fixed**n
        ax.plot(x_vals, ps, linewidth=2, label=f'$x^{n}+y^{n}$ (2 terms)')
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel(f'$x^n + 2^n$', fontsize=12)
    ax.set_title('Power Sums: 2-Term EML-KA', fontsize=13)
    ax.legend(fontsize=9)
    
    # Panel 3: Polynomial via EML-KA
    ax = axes[2]
    x_vals = np.linspace(0.5, 3, 200)
    # p(x,y) = 3x^2*y + 2xy^3 + x at y=2
    direct = 3*x_vals**2*2 + 2*x_vals*2**3 + x_vals
    eml = (3 * np.exp(2*np.log(x_vals) + np.log(2)) + 
           2 * np.exp(np.log(x_vals) + 3*np.log(2)) + 
           np.exp(np.log(x_vals)))
    ax.plot(x_vals, direct, 'b-', linewidth=2, label='Direct')
    ax.plot(x_vals, eml, 'r--', linewidth=2, label='EML-KA (3 terms)')
    ax.fill_between(x_vals, direct, eml, alpha=0.1, color='green')
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('p(x, 2)', fontsize=12)
    ax.set_title('Polynomial Completeness', fontsize=13)
    ax.legend(fontsize=9)
    
    plt.tight_layout()
    plt.savefig('eml_ka_monomial_landscape.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: eml_ka_monomial_landscape.png")


def plot_amgm_and_lse():
    """Plot AM-GM gap and LogSumExp bounds."""
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))
    
    # Panel 1: AM-GM gap
    ax = axes[0]
    ratios = np.linspace(0.01, 10, 500)
    y_fixed = 1.0
    x_vals = ratios * y_fixed
    
    gm = np.exp((np.log(x_vals) + np.log(y_fixed)) / 2)
    am = (x_vals + y_fixed) / 2
    gap = am - gm
    
    ax.fill_between(ratios, 0, gap, alpha=0.3, color='blue', label='AM - GM gap')
    ax.plot(ratios, am, 'r-', linewidth=2, label='AM = (x+1)/2')
    ax.plot(ratios, gm, 'g-', linewidth=2, label='GM = √x')
    ax.axvline(x=1, color='k', linestyle=':', alpha=0.5, label='x=y (equality)')
    ax.set_xlabel('x/y ratio', fontsize=12)
    ax.set_ylabel('Value', fontsize=12)
    ax.set_title('AM-GM via EML-KA (y=1)', fontsize=13)
    ax.legend(fontsize=9)
    ax.set_xlim(0, 5)
    ax.set_ylim(0, 3.5)
    
    # Panel 2: LogSumExp bounds
    ax = axes[1]
    b_fixed = 0
    a_vals = np.linspace(-5, 5, 500)
    lse = np.log(np.exp(a_vals) + np.exp(b_fixed))
    mx = np.maximum(a_vals, b_fixed)
    mx_log2 = mx + np.log(2)
    
    ax.fill_between(a_vals, mx, lse, alpha=0.3, color='orange', label='LSE − max')
    ax.fill_between(a_vals, lse, mx_log2, alpha=0.2, color='purple', label='max+log2 − LSE')
    ax.plot(a_vals, lse, 'b-', linewidth=2, label='LogSumExp(a, 0)')
    ax.plot(a_vals, mx, 'r--', linewidth=1.5, label='max(a, 0)')
    ax.plot(a_vals, mx_log2, 'g--', linewidth=1.5, label='max(a, 0) + log2')
    ax.set_xlabel('a', fontsize=12)
    ax.set_ylabel('Value', fontsize=12)
    ax.set_title('LogSumExp: Smooth Max Bounds', fontsize=13)
    ax.legend(fontsize=9, loc='upper left')
    
    plt.tight_layout()
    plt.savefig('eml_ka_amgm_lse.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: eml_ka_amgm_lse.png")


def plot_log_coordinate_transform():
    """Show the logarithmic isomorphism: monomials become linear in log-space."""
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))
    
    # Panel 1: Original coordinates - curved level sets
    ax = axes[0]
    x = np.linspace(0.1, 5, 300)
    y = np.linspace(0.1, 5, 300)
    X, Y = np.meshgrid(x, y)
    
    # Monomial x^2 * y
    Z = X**2 * Y
    levels = [0.5, 1, 2, 5, 10, 20, 50]
    cs = ax.contour(X, Y, Z, levels=levels, cmap='viridis')
    ax.clabel(cs, fontsize=8)
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('y', fontsize=12)
    ax.set_title('$x^2 y$ in original coordinates\n(curved level sets)', fontsize=12)
    
    # Panel 2: Log coordinates - linear level sets!
    ax = axes[1]
    t1 = np.linspace(-2, 2, 300)
    t2 = np.linspace(-2, 2, 300)
    T1, T2 = np.meshgrid(t1, t2)
    
    # In log-coords: log(x^2*y) = 2*log(x) + log(y) = 2*t1 + t2 (LINEAR!)
    Z_log = 2*T1 + T2
    levels_log = np.log(levels)
    cs = ax.contour(T1, T2, Z_log, levels=levels_log, cmap='viridis')
    ax.clabel(cs, fontsize=8, fmt='%.1f')
    ax.set_xlabel('$t_1 = \\log(x)$', fontsize=12)
    ax.set_ylabel('$t_2 = \\log(y)$', fontsize=12)
    ax.set_title('$2t_1 + t_2$ in log-coordinates\n(straight level sets!)', fontsize=12)
    
    plt.suptitle('The Logarithmic Isomorphism: Monomials → Linear Functions', 
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('eml_ka_log_isomorphism.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: eml_ka_log_isomorphism.png")


if __name__ == "__main__":
    plot_monomial_accuracy()
    plot_amgm_and_lse()
    plot_log_coordinate_transform()
    print("\nAll visualizations generated!")
