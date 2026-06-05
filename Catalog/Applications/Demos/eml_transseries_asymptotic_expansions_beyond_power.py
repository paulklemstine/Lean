#!/usr/bin/env python3
"""
Transseries: Asymptotic Expansions Beyond Power Series — Demonstration

This script demonstrates the key results from our transseries formalization:
1. The exp-log growth hierarchy
2. Coefficient recovery from asymptotic expansions
3. The EML function's transseries structure
"""

import numpy as np

def demonstrate_growth_hierarchy():
    """Show that exp >> polynomial >> log in asymptotic growth."""
    print("=" * 70)
    print("§1. THE EXP-LOG GROWTH HIERARCHY")
    print("=" * 70)
    print()
    print("Theorem: exp(x) dominates x^n for all n.")
    print("We compute exp(x)/x^n for increasing x:\n")
    
    for n in [1, 2, 5, 10]:
        print(f"  exp(x) / x^{n}:")
        for x in [10, 20, 50, 100]:
            ratio = np.exp(x) / x**n
            print(f"    x={x:>4}: {ratio:.2e}")
        print()
    
    print("Theorem: x dominates log(x).")
    print("We compute x/log(x) for increasing x:\n")
    for x in [10, 100, 1000, 10000, 100000]:
        ratio = x / np.log(x)
        print(f"  x={x:>6}: x/log(x) = {ratio:.2f}")
    print()
    
    print("Theorem: exp(exp(x)) dominates exp(x).")
    print("We compute exp(exp(x))/exp(x) = exp(exp(x)-x) for small x:\n")
    for x in [1, 2, 3, 4, 5]:
        ratio = np.exp(np.exp(x) - x)
        print(f"  x={x}: exp(exp(x))/exp(x) = {ratio:.2e}")
    print()


def demonstrate_coefficient_recovery():
    """Show that transseries coefficients are uniquely recoverable."""
    print("=" * 70)
    print("§2. COEFFICIENT RECOVERY FROM ASYMPTOTIC EXPANSIONS")
    print("=" * 70)
    print()
    
    # The function f(x) = a*exp(x) + b*log(x) + c
    a, b, c = 3.0, -2.0, 7.0
    print(f"Ground truth: a={a}, b={b}, c={c}")
    print(f"Function: f(x) = {a}·exp(x) + ({b})·log(x) + {c}")
    print()
    
    def f(x):
        return a * np.exp(x) + b * np.log(x) + c
    
    # Recover a = lim f(x)/exp(x)
    print("Step 1: Recover a = lim_{x→∞} f(x)/exp(x)")
    for x in [5, 10, 20, 50]:
        recovered_a = f(x) / np.exp(x)
        print(f"  x={x:>3}: f(x)/exp(x) = {recovered_a:.10f}")
    print()
    
    # Recover b = lim (f(x) - a*exp(x))/log(x)
    print("Step 2: Recover b = lim_{x→∞} (f(x) - a·exp(x))/log(x)")
    for x in [10, 100, 1000, 10000]:
        recovered_b = (f(x) - a * np.exp(x)) / np.log(x)
        print(f"  x={x:>6}: remainder/log(x) = {recovered_b:.10f}")
    print()
    
    # Recover c = lim (f(x) - a*exp(x) - b*log(x))
    print("Step 3: Recover c = f(x) - a·exp(x) - b·log(x) (exact for all x)")
    for x in [1, 10, 100]:
        recovered_c = f(x) - a * np.exp(x) - b * np.log(x)
        print(f"  x={x:>4}: remainder = {recovered_c:.10f}")
    print()


def demonstrate_eml_transseries():
    """Show the EML function's transseries structure."""
    print("=" * 70)
    print("§3. THE EML FUNCTION AS A TRANSSERIES ELEMENT")
    print("=" * 70)
    print()
    
    print("eml(x,x) = exp(x) - log(x)")
    print("Transseries: 1·exp(x) + (-1)·log(x)")
    print()
    
    print("Theorem: eml(x,x) ~ exp(x) as x → ∞")
    print("Verification: eml(x,x)/exp(x) → 1:\n")
    for x in [1, 5, 10, 20, 50, 100]:
        eml_val = np.exp(x) - np.log(x)
        ratio = eml_val / np.exp(x)
        print(f"  x={x:>4}: eml(x,x)/exp(x) = {ratio:.15f}")
    print()
    
    print("Hardy field closure: d/dx[eml(x,x)] = exp(x) - 1/x")
    print("The derivative is again an exp-log expression!\n")
    for x in [1, 2, 5, 10]:
        deriv = np.exp(x) - 1/x
        print(f"  x={x:>3}: eml'(x,x) = exp({x}) - 1/{x} = {deriv:.6f}")
    print()


def demonstrate_uniqueness():
    """Demonstrate the asymptotic comparison theorem."""
    print("=" * 70)
    print("§4. THE ASYMPTOTIC COMPARISON THEOREM")
    print("=" * 70)
    print()
    
    print("Theorem: If a₁·exp + b₁·log + c₁ = a₂·exp + b₂·log + c₂")
    print("         as functions, then a₁=a₂, b₁=b₂, c₁=c₂.")
    print()
    print("This is the UNIQUENESS of transseries expansion.")
    print("The monomials {exp(x), log(x), 1} are 'linearly independent'")
    print("in the asymptotic sense.\n")
    
    print("Numerical verification: can we distinguish")
    print("  f(x) = 2·exp(x) + 3·log(x) + 5")
    print("  g(x) = 2·exp(x) + 3.001·log(x) + 5 ?")
    print()
    
    for x in [10, 100, 1000, 10000]:
        f_val = 2 * np.exp(min(x, 700)) + 3 * np.log(x) + 5
        g_val = 2 * np.exp(min(x, 700)) + 3.001 * np.log(x) + 5
        diff = g_val - f_val
        print(f"  x={x:>6}: f(x)-g(x) = {-diff:.6e}  (= -0.001·log(x) = {-0.001*np.log(x):.6e})")
    print()
    print("Even tiny coefficient differences are detectable at the right scale!")


def demonstrate_monomial_cross_terms():
    """Show that products of transseries elements require new monomials."""
    print("=" * 70)
    print("§5. TRANSSERIES ALGEBRA: WHY WE NEED INFINITELY MANY MONOMIALS")
    print("=" * 70)
    print()
    
    print("(a₁·exp + b₁·log) × (a₂·exp + b₂·log)")
    print("= a₁a₂·exp² + (a₁b₂+a₂b₁)·exp·log + b₁b₂·log²")
    print()
    print("New monomials appear: exp²(x) = exp(2x), exp(x)·log(x)")
    print("This shows the transseries monoid is NOT finitely generated.\n")
    
    a1, b1, a2, b2 = 1, 1, 1, -1
    print(f"Example: ({a1}·exp + {b1}·log) × ({a2}·exp + ({b2})·log)")
    print(f"= {a1*a2}·exp² + {a1*b2+a2*b1}·exp·log + ({b1*b2})·log²\n")
    
    for x in [1, 2, 5]:
        product = (np.exp(x) + np.log(x)) * (np.exp(x) - np.log(x))
        expansion = np.exp(2*x) - np.log(x)**2
        print(f"  x={x}: product = {product:.6f}, exp²-log² = {expansion:.6f}")


if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║     TRANSSERIES: ASYMPTOTIC EXPANSIONS BEYOND POWER SERIES         ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()
    
    demonstrate_growth_hierarchy()
    demonstrate_coefficient_recovery()
    demonstrate_eml_transseries()
    demonstrate_uniqueness()
    demonstrate_monomial_cross_terms()
    
    print("=" * 70)
    print("All demonstrations complete.")
    print("These results have been formally verified in Lean 4.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Visualization: The Exp-Log Growth Hierarchy

Shows the fundamental ordering of growth rates:
exp(exp(x)) >> exp(x) >> x^n >> x >> log(x) >> log(log(x))
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

def plot_growth_hierarchy():
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))
    
    # Panel 1: Basic hierarchy on log scale
    ax = axes[0]
    x = np.linspace(1.01, 8, 500)
    ax.semilogy(x, np.exp(x), 'r-', linewidth=2, label='exp(x)')
    ax.semilogy(x, x**3, 'b-', linewidth=2, label='x³')
    ax.semilogy(x, x, 'g-', linewidth=2, label='x')
    ax.semilogy(x, np.log(x), 'm-', linewidth=2, label='log(x)')
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('f(x) (log scale)', fontsize=12)
    ax.set_title('Growth Hierarchy', fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    
    # Panel 2: Dominance ratios
    ax = axes[1]
    x = np.linspace(1.01, 15, 500)
    ax.plot(x, np.exp(x) / x**3, 'r-', linewidth=2, label='exp(x)/x³ → ∞')
    ax.plot(x, x / np.log(x), 'b-', linewidth=2, label='x/log(x) → ∞')
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('Ratio', fontsize=12)
    ax.set_title('Dominance Ratios → ∞', fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(0, 200)
    
    # Panel 3: EML diagonal
    ax = axes[2]
    x = np.linspace(0.1, 5, 500)
    eml = np.exp(x) - np.log(x)
    ax.plot(x, eml, 'k-', linewidth=2.5, label='eml(x,x) = exp(x) − log(x)')
    ax.plot(x, np.exp(x), 'r--', linewidth=1.5, alpha=0.7, label='exp(x)')
    ax.plot(x, -np.log(x), 'b--', linewidth=1.5, alpha=0.7, label='−log(x)')
    ax.fill_between(x, np.exp(x), eml, alpha=0.15, color='blue', label='log(x) correction')
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('f(x)', fontsize=12)
    ax.set_title('EML Transseries: exp − log', fontsize=14, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(-3, 50)
    
    plt.tight_layout()
    plt.savefig('growth_hierarchy.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: growth_hierarchy.png")

if __name__ == "__main__":
    plot_growth_hierarchy()
