#!/usr/bin/env python3
"""
EML Transseries: Asymptotic Expansions Beyond Power Series — Demonstration

This script demonstrates the key results of the transseries hierarchy:
1. Exponential dominates all polynomials
2. Double exponential dominates single exponential
3. Logarithm is sub-polynomial
4. EML function is asymptotically equivalent to exp
5. Uniqueness of leading coefficients in asymptotic expansions
"""

import math
from typing import Callable, List, Tuple


def demonstrate_exp_dominates_poly():
    """Show that x^n / exp(x) → 0 for various n."""
    print("=" * 70)
    print("THEOREM 1: Exponential Dominates All Polynomials")
    print("  x^n = o(exp(x)) as x → +∞")
    print("=" * 70)
    
    for n in [1, 2, 5, 10, 20]:
        print(f"\n  n = {n}:")
        print(f"  {'x':>10} {'x^n':>20} {'exp(x)':>20} {'ratio':>15}")
        print(f"  {'-'*10} {'-'*20} {'-'*20} {'-'*15}")
        for x in [10, 50, 100, 200, 500]:
            poly = x ** n
            try:
                expo = math.exp(x)
                ratio = poly / expo
            except OverflowError:
                expo = float('inf')
                ratio = 0.0
            print(f"  {x:>10} {poly:>20.3e} {expo:>20.3e} {ratio:>15.3e}")
    print()


def demonstrate_double_exp_dominance():
    """Show that exp(x) / exp(exp(x)) → 0."""
    print("=" * 70)
    print("THEOREM 2: Double Exponential Dominates Single Exponential")
    print("  exp(x) = o(exp(exp(x))) as x → +∞")
    print("=" * 70)
    
    print(f"\n  {'x':>6} {'exp(x)':>15} {'exp(exp(x))':>20} {'ratio':>15}")
    print(f"  {'-'*6} {'-'*15} {'-'*20} {'-'*15}")
    for x in [1, 2, 3, 4, 5, 6, 7]:
        exp_x = math.exp(x)
        try:
            exp_exp_x = math.exp(exp_x)
            ratio = exp_x / exp_exp_x
        except OverflowError:
            exp_exp_x = float('inf')
            ratio = 0.0
        print(f"  {x:>6} {exp_x:>15.3e} {exp_exp_x:>20.3e} {ratio:>15.3e}")
    print()


def demonstrate_log_subpolynomial():
    """Show that log(x) / x^α → 0 for α > 0."""
    print("=" * 70)
    print("THEOREM 3: Logarithm is Sub-polynomial")
    print("  log(x) = o(x^α) for all α > 0")
    print("=" * 70)
    
    for alpha in [0.01, 0.1, 0.5, 1.0]:
        print(f"\n  α = {alpha}:")
        print(f"  {'x':>12} {'log(x)':>12} {'x^α':>15} {'ratio':>15}")
        print(f"  {'-'*12} {'-'*12} {'-'*15} {'-'*15}")
        for x in [10, 100, 1000, 10000, 100000, 1000000]:
            log_x = math.log(x)
            pow_x = x ** alpha
            ratio = log_x / pow_x
            print(f"  {x:>12} {log_x:>12.4f} {pow_x:>15.4f} {ratio:>15.6f}")
    print()


def demonstrate_eml_asymptotic():
    """Show that EML(x,x) = exp(x) - log(x) ~ exp(x)."""
    print("=" * 70)
    print("THEOREM 5: EML Asymptotic Equivalence")
    print("  exp(x) - log(x) ~ exp(x) as x → +∞")
    print("=" * 70)
    
    print(f"\n  {'x':>8} {'exp(x)':>15} {'log(x)':>12} {'EML(x,x)':>15} {'EML/exp':>12}")
    print(f"  {'-'*8} {'-'*15} {'-'*12} {'-'*15} {'-'*12}")
    for x in [1, 2, 5, 10, 20, 50, 100]:
        exp_x = math.exp(x)
        log_x = math.log(x)
        eml = exp_x - log_x
        ratio = eml / exp_x
        print(f"  {x:>8} {exp_x:>15.4f} {log_x:>12.4f} {eml:>15.4f} {ratio:>12.8f}")
    print("\n  → The ratio EML/exp → 1, confirming exp(x) is the leading term.\n")


def demonstrate_leading_coeff_uniqueness():
    """Numerical illustration of leading coefficient uniqueness."""
    print("=" * 70)
    print("THEOREM 7: Uniqueness of Leading Coefficients")
    print("  If f(x) - c·g(x) = o(g(x)), then c is unique.")
    print("=" * 70)
    
    # f(x) = 3*exp(x) + x^2
    # The leading coefficient relative to exp(x) must be 3
    print("\n  Example: f(x) = 3·exp(x) + x², g(x) = exp(x)")
    print(f"\n  {'x':>8} {'f(x)':>20} {'3·g(x)':>20} {'f-3g':>15} {'(f-3g)/g':>12}")
    print(f"  {'-'*8} {'-'*20} {'-'*20} {'-'*15} {'-'*12}")
    for x in [1, 2, 5, 10, 20, 50]:
        f_x = 3 * math.exp(x) + x**2
        g_x = math.exp(x)
        three_g = 3 * g_x
        residual = f_x - three_g
        ratio = residual / g_x
        print(f"  {x:>8} {f_x:>20.4f} {three_g:>20.4f} {residual:>15.4f} {ratio:>12.8f}")
    print("\n  → The residual ratio → 0, confirming c = 3 is the unique leading coefficient.\n")


def demonstrate_transseries_hierarchy():
    """Show the full hierarchy: exp(exp(x)) >> exp(x) >> x^n >> log(x)."""
    print("=" * 70)
    print("THE COMPLETE TRANSSERIES HIERARCHY")
    print("  exp(exp(x)) ≻ exp(x) ≻ x^n ≻ x ≻ log(x)")
    print("=" * 70)
    
    print(f"\n  {'x':>6} {'log(x)':>10} {'x':>10} {'x²':>10} {'exp(x)':>12} {'exp(exp(x))':>15}")
    print(f"  {'-'*6} {'-'*10} {'-'*10} {'-'*10} {'-'*12} {'-'*15}")
    for x in [2, 3, 4, 5, 6]:
        log_x = math.log(x)
        x2 = x ** 2
        exp_x = math.exp(x)
        try:
            exp_exp_x = math.exp(exp_x)
        except OverflowError:
            exp_exp_x = float('inf')
        print(f"  {x:>6} {log_x:>10.4f} {x:>10} {x2:>10} {exp_x:>12.2f} {exp_exp_x:>15.2e}")
    
    print("\n  Each level grows incomparably faster than the one below it.")
    print("  This is the foundational structure of transseries theory.\n")


if __name__ == "__main__":
    print("\n" + "█" * 70)
    print("  EML TRANSSERIES: ASYMPTOTIC EXPANSIONS BEYOND POWER SERIES")
    print("█" * 70 + "\n")
    
    demonstrate_exp_dominates_poly()
    demonstrate_double_exp_dominance()
    demonstrate_log_subpolynomial()
    demonstrate_eml_asymptotic()
    demonstrate_leading_coeff_uniqueness()
    demonstrate_transseries_hierarchy()
    
    print("=" * 70)
    print("All demonstrations complete.")
    print("These numerical results confirm the formally verified theorems")
    print("in the transseries hierarchy.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Visualization: The Transseries Asymptotic Hierarchy

Produces a plot showing the growth rates of the standard transseries scale:
  log(x) << x << x^2 << exp(x) << exp(exp(x))

on both linear and log scales, demonstrating the strict dominance chain.
"""

import math
import numpy as np

def create_hierarchy_plot():
    """Create and save the transseries hierarchy visualization."""
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
    except ImportError:
        print("matplotlib not available; skipping plot generation")
        return
    
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # --- Left panel: log scale ---
    x = np.linspace(1.01, 6, 500)
    
    log_x = np.log(x)
    x_vals = x
    x_sq = x ** 2
    exp_x = np.exp(x)
    # Cap exp(exp(x)) to avoid overflow
    exp_exp_x = np.array([math.exp(math.exp(xi)) if xi < 5.5 else float('nan') for xi in x])
    
    ax = axes[0]
    ax.semilogy(x, log_x, 'b-', linewidth=2, label=r'$\log(x)$')
    ax.semilogy(x, x_vals, 'g-', linewidth=2, label=r'$x$')
    ax.semilogy(x, x_sq, 'orange', linewidth=2, label=r'$x^2$')
    ax.semilogy(x, exp_x, 'r-', linewidth=2, label=r'$\exp(x)$')
    ax.semilogy(x, exp_exp_x, 'm-', linewidth=2, label=r'$\exp(\exp(x))$')
    
    # EML function
    eml = exp_x - log_x
    ax.semilogy(x, eml, 'r--', linewidth=1.5, alpha=0.7, label=r'$\exp(x) - \log(x)$')
    
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('f(x)  [log scale]', fontsize=12)
    ax.set_title('Transseries Hierarchy (Log Scale)', fontsize=14, fontweight='bold')
    ax.legend(fontsize=10, loc='upper left')
    ax.grid(True, alpha=0.3)
    ax.set_ylim(0.1, 1e100)
    
    # --- Right panel: ratios showing dominance ---
    x2 = np.linspace(1.01, 20, 500)
    
    ax2 = axes[1]
    
    # Ratio: x^n / exp(x) → 0  (for n = 1, 2, 3, 5)
    for n in [1, 2, 3, 5]:
        ratio = x2**n / np.exp(x2)
        ax2.plot(x2, ratio, linewidth=2, label=f'$x^{n}/\\exp(x)$')
    
    # Ratio: log(x) / x^0.5 → 0
    ratio_log = np.log(x2) / np.sqrt(x2)
    ax2.plot(x2, ratio_log, 'k--', linewidth=2, label=r'$\log(x)/\sqrt{x}$')
    
    ax2.axhline(y=0, color='gray', linestyle='-', alpha=0.5)
    ax2.set_xlabel('x', fontsize=12)
    ax2.set_ylabel('Ratio', fontsize=12)
    ax2.set_title('Dominance Ratios → 0', fontsize=14, fontweight='bold')
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    ax2.set_ylim(-0.1, 3.0)
    
    plt.tight_layout()
    plt.savefig('transseries_hierarchy.png', dpi=150, bbox_inches='tight')
    print("Saved: transseries_hierarchy.png")
    plt.close()


def create_eml_decomposition_plot():
    """Visualize the EML function as a transseries decomposition."""
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
    except ImportError:
        print("matplotlib not available; skipping plot generation")
        return
    
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    x = np.linspace(0.5, 8, 500)
    
    # Left: EML decomposition
    ax = axes[0]
    exp_x = np.exp(x)
    log_x = np.log(x)
    eml = exp_x - log_x
    
    ax.fill_between(x, 0, exp_x, alpha=0.2, color='red', label=r'$\exp(x)$ (leading term)')
    ax.fill_between(x, eml, exp_x, alpha=0.3, color='blue', label=r'$-\log(x)$ (correction)')
    ax.plot(x, eml, 'k-', linewidth=2, label=r'$\mathrm{EML}(x,x) = \exp(x) - \log(x)$')
    ax.plot(x, exp_x, 'r--', linewidth=1.5, alpha=0.7)
    
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('f(x)', fontsize=12)
    ax.set_title('EML Transseries Decomposition', fontsize=14, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(0, 300)
    
    # Right: relative error EML/exp - 1
    ax2 = axes[1]
    x2 = np.linspace(1, 30, 500)
    relative_error = -np.log(x2) / np.exp(x2)
    
    ax2.plot(x2, relative_error, 'b-', linewidth=2)
    ax2.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
    ax2.set_xlabel('x', fontsize=12)
    ax2.set_ylabel(r'$(\mathrm{EML} - \exp)/\exp$', fontsize=12)
    ax2.set_title('EML Relative Correction (→ 0)', fontsize=14, fontweight='bold')
    ax2.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('eml_transseries_decomposition.png', dpi=150, bbox_inches='tight')
    print("Saved: eml_transseries_decomposition.png")
    plt.close()


if __name__ == "__main__":
    create_hierarchy_plot()
    create_eml_decomposition_plot()
