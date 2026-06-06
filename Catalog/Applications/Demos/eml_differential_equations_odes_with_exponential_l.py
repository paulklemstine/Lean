"""
EML Differential Equations: Numerical Demonstrations

Demonstrates key concepts from the formal verification:
1. Airy function computation and visualization
2. Wronskian verification of Abel's identity
3. Kovacic algorithm case classification
4. EML function growth rate hierarchy
"""

import numpy as np
from scipy.integrate import solve_ivp
from scipy.special import airy

def demo_airy_solutions():
    """Compute and display Airy function values, verifying y'' = xy."""
    print("=" * 60)
    print("Demo 1: Airy Functions Ai(x) and Bi(x)")
    print("=" * 60)
    
    x_vals = np.linspace(-10, 5, 100)
    
    for x in [-5, -2, 0, 1, 2, 3]:
        ai, aip, bi, bip = airy(x)
        # Verify y'' = xy by numerical differentiation
        h = 1e-6
        ai_plus, _, _, _ = airy(x + h)
        ai_minus, _, _, _ = airy(x - h)
        ai_second = (ai_plus - 2*ai + ai_minus) / h**2
        residual = abs(ai_second - x * ai)
        print(f"  x={x:5.1f}: Ai(x)={ai:12.8f}, Ai'(x)={aip:12.8f}, "
              f"|y''-xy|={residual:.2e}")
    print()


def demo_wronskian_abel():
    """Verify Abel's identity: W(x) = W(x0) * exp(-∫p(t)dt)."""
    print("=" * 60)
    print("Demo 2: Abel's Identity for the Wronskian")
    print("=" * 60)
    
    # For Airy's equation y'' = xy, written as y'' - xy = 0
    # This is y'' + p(x)y' + q(x)y = 0 with p(x) = 0, q(x) = -x
    # Abel's identity: W' = -p * W = 0, so W is constant!
    
    x_vals = np.linspace(-5, 5, 50)
    wronskians = []
    
    for x in x_vals:
        ai, aip, bi, bip = airy(x)
        W = ai * bip - aip * bi
        wronskians.append(W)
    
    print(f"  Wronskian W = Ai*Bi' - Ai'*Bi should be constant (= 1/π)")
    print(f"  Expected: {1/np.pi:.10f}")
    print(f"  Mean:     {np.mean(wronskians):.10f}")
    print(f"  Std dev:  {np.std(wronskians):.2e}")
    print(f"  Max dev:  {max(abs(w - 1/np.pi) for w in wronskians):.2e}")
    print()


def demo_kovacic_cases():
    """Demonstrate the four Kovacic cases with concrete examples."""
    print("=" * 60)
    print("Demo 3: Kovacic Algorithm Cases")
    print("=" * 60)
    
    cases = [
        ("y'' = y (r=1)", "Case 1", "exp(x), exp(-x)", 
         "Reducible: diagonal Galois group"),
        ("y'' = -y (r=-1)", "Case 1", "cos(x), sin(x)",
         "Reducible: unitary diagonal"),
        ("y'' = (1/4x²)y", "Case 3", "x^(1/2), x^(-1/2)",
         "Finite: algebraic solutions"),
        ("y'' = xy (Airy)", "Case 4", "Ai(x), Bi(x)",
         "Full SL(2): NO elementary solutions"),
    ]
    
    for eq, case, solutions, explanation in cases:
        print(f"  {eq}")
        print(f"    → {case}: solutions = {solutions}")
        print(f"    ({explanation})")
        print()


def demo_growth_hierarchy():
    """Demonstrate the growth rate hierarchy of EML functions."""
    print("=" * 60)
    print("Demo 4: Growth Rate Hierarchy")
    print("=" * 60)
    
    x = 10.0
    
    levels = [
        ("Polynomial x^3", x**3),
        ("Exponential exp(x)", np.exp(x)),
        ("Double exp exp(exp(x))", np.exp(np.exp(min(x, 5)))),  # capped
        ("Airy growth exp(2/3 x^{3/2})", np.exp(2/3 * x**1.5)),
    ]
    
    print(f"  Growth comparison at x = {x}:")
    for name, val in levels:
        if val < 1e100:
            print(f"    {name:35s} = {val:.6e}")
        else:
            print(f"    {name:35s} = (overflow)")
    
    print()
    print("  Key insight: Airy's growth exp(2/3 x^{3/2}) involves")
    print("  a fractional exponent 3/2, which cannot arise from")
    print("  integration of rational functions. This is the growth-rate")
    print("  manifestation of the Galois obstruction.")
    print()


def demo_eml_differentiation():
    """Demonstrate syntactic EML differentiation and EL-height preservation."""
    print("=" * 60)
    print("Demo 5: EML Expression Differentiation")
    print("=" * 60)
    
    # Represent EML expressions as nested tuples
    # ('const', c), ('var',), ('add', e1, e2), ('mul', e1, e2),
    # ('neg', e), ('inv', e), ('exp', e), ('log', e)
    
    def diff(e):
        """Syntactic differentiation of EML expressions."""
        if e[0] == 'const': return ('const', 0)
        if e[0] == 'var': return ('const', 1)
        if e[0] == 'add': return ('add', diff(e[1]), diff(e[2]))
        if e[0] == 'mul': return ('add', ('mul', diff(e[1]), e[2]), ('mul', e[1], diff(e[2])))
        if e[0] == 'neg': return ('neg', diff(e[1]))
        if e[0] == 'inv': return ('neg', ('mul', diff(e[1]), ('mul', ('inv', e[1]), ('inv', e[1]))))
        if e[0] == 'exp': return ('mul', diff(e[1]), ('exp', e[1]))
        if e[0] == 'log': return ('mul', diff(e[1]), ('inv', e[1]))
    
    def el_height(e):
        """EL-height: maximal nesting depth of exp/log."""
        if e[0] in ('const', 'var'): return 0
        if e[0] in ('add', 'mul'): return max(el_height(e[1]), el_height(e[2]))
        if e[0] in ('neg', 'inv'): return el_height(e[1])
        if e[0] in ('exp', 'log'): return el_height(e[1]) + 1
    
    def show(e, depth=0):
        """Pretty-print an EML expression."""
        if e[0] == 'const': return str(e[1])
        if e[0] == 'var': return 'x'
        if e[0] == 'add': return f"({show(e[1])} + {show(e[2])})"
        if e[0] == 'mul': return f"({show(e[1])} * {show(e[2])})"
        if e[0] == 'neg': return f"(-{show(e[1])})"
        if e[0] == 'inv': return f"(1/{show(e[1])})"
        if e[0] == 'exp': return f"exp({show(e[1])})"
        if e[0] == 'log': return f"log({show(e[1])})"
    
    examples = [
        ("exp(x²)", ('exp', ('mul', ('var',), ('var',)))),
        ("log(x)", ('log', ('var',))),
        ("exp(log(x))", ('exp', ('log', ('var',)))),
    ]
    
    for name, expr in examples:
        d = diff(expr)
        h_before = el_height(expr)
        h_after = el_height(d)
        print(f"  f(x) = {name}")
        print(f"    f'(x) = {show(d)}")
        print(f"    EL-height: {h_before} → {h_after} (≤ original: {h_after <= h_before})")
        print()


if __name__ == "__main__":
    demo_airy_solutions()
    demo_wronskian_abel()
    demo_kovacic_cases()
    demo_growth_hierarchy()
    demo_eml_differentiation()


"""
Visualization: Airy Functions and the Galois Obstruction

Produces a multi-panel figure showing:
1. Airy functions Ai(x) and Bi(x)
2. The constant Wronskian (Abel's identity)
3. Growth rate comparison: Airy vs EML functions
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from scipy.special import airy


def plot_airy_functions(ax):
    """Plot Ai(x) and Bi(x) on the given axes."""
    x = np.linspace(-15, 5, 1000)
    ai_vals, aip_vals, bi_vals, bip_vals = airy(x)
    
    ax.plot(x, ai_vals, 'b-', linewidth=2, label='Ai(x)')
    ax.plot(x, bi_vals, 'r-', linewidth=2, label='Bi(x)')
    ax.axhline(y=0, color='k', linewidth=0.5)
    ax.set_xlim(-15, 5)
    ax.set_ylim(-0.6, 1.2)
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('y', fontsize=12)
    ax.set_title('Airy Functions: Solutions of y\'\' = xy', fontsize=14)
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)


def plot_wronskian(ax):
    """Plot the Wronskian W = Ai·Bi' - Ai'·Bi (should be constant = 1/π)."""
    x = np.linspace(-15, 5, 500)
    ai_vals, aip_vals, bi_vals, bip_vals = airy(x)
    W = ai_vals * bip_vals - aip_vals * bi_vals
    
    ax.plot(x, W, 'g-', linewidth=2, label='W(x) = Ai·Bi\' - Ai\'·Bi')
    ax.axhline(y=1/np.pi, color='k', linewidth=1, linestyle='--', 
               label=f'1/π ≈ {1/np.pi:.6f}')
    ax.set_xlim(-15, 5)
    ax.set_ylim(0.3, 0.35)
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('W(x)', fontsize=12)
    ax.set_title('Abel\'s Identity: Wronskian is Constant', fontsize=14)
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)


def plot_growth_comparison(ax):
    """Compare growth rates: polynomial, exp, Airy, double exp."""
    x = np.linspace(0.1, 8, 200)
    
    poly = x**3
    exp_x = np.exp(x)
    airy_growth = np.exp(2/3 * x**1.5)
    
    ax.semilogy(x, poly, 'b-', linewidth=2, label='x³ (polynomial)')
    ax.semilogy(x, exp_x, 'r-', linewidth=2, label='exp(x)')
    ax.semilogy(x, airy_growth, 'g--', linewidth=2, 
                label='exp(⅔x^{3/2}) (Airy growth)')
    
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('|f(x)| (log scale)', fontsize=12)
    ax.set_title('Growth Rate Hierarchy', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(1e-1, 1e8)


def main():
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))
    
    plot_airy_functions(axes[0])
    plot_wronskian(axes[1])
    plot_growth_comparison(axes[2])
    
    plt.tight_layout()
    plt.savefig('airy_galois_obstruction.png', dpi=150, bbox_inches='tight')
    print("Saved: airy_galois_obstruction.png")


if __name__ == "__main__":
    main()
