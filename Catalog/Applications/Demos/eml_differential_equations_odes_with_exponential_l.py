"""
EML Differential Equations: Demonstrations

Demonstrates key concepts from the formalized theory:
1. Degree gap visualization for the Airy equation
2. Wronskian constancy verification using numerical Airy functions
3. EML expression differentiation and depth analysis
"""

import numpy as np
from scipy.special import airy
from scipy.integrate import solve_ivp

def demo_degree_gap():
    """Demonstrate the degree gap obstruction for polynomial solutions of Airy."""
    print("=" * 60)
    print("DEGREE GAP OBSTRUCTION FOR y'' = xy")
    print("=" * 60)
    print()
    print("If p(x) is a polynomial of degree n satisfying p'' = x·p,")
    print("then deg(p'') = n-2 and deg(x·p) = n+1.")
    print()
    print("  n | deg(p'') | deg(x·p) | Equal?")
    print("  --|----------|----------|-------")
    for n in range(0, 8):
        deg_lhs = max(n - 2, -1)  # -1 means zero polynomial
        deg_rhs = n + 1
        eq = "✓" if deg_lhs == deg_rhs else "✗ IMPOSSIBLE"
        lhs_str = str(deg_lhs) if deg_lhs >= 0 else "  (zero)"
        print(f"  {n} |    {lhs_str:>5} |    {deg_rhs:>5} | {eq}")
    print()
    print("No value of n makes the degrees match → no polynomial solution exists!")
    print()

def demo_wronskian_constancy():
    """Numerically verify that W(Ai, Bi) is constant."""
    print("=" * 60)
    print("WRONSKIAN CONSTANCY: W(Ai, Bi) = 1/π")
    print("=" * 60)
    print()

    xs = np.linspace(-10, 5, 1000)
    ai_vals, ai_prime, bi_vals, bi_prime = airy(xs)

    wronskian = ai_vals * bi_prime - bi_vals * ai_prime

    print(f"  x range: [{xs[0]:.1f}, {xs[-1]:.1f}]")
    print(f"  W(Ai,Bi) at x=-10: {wronskian[0]:.10f}")
    print(f"  W(Ai,Bi) at x=  0: {wronskian[len(xs)//2]:.10f}")
    print(f"  W(Ai,Bi) at x=  5: {wronskian[-1]:.10f}")
    print(f"  1/π             = {1/np.pi:.10f}")
    print(f"  Max deviation   = {np.max(np.abs(wronskian - 1/np.pi)):.2e}")
    print()
    print("The Wronskian is constant to machine precision! (Abel's identity)")
    print()

def demo_eml_differentiation():
    """Demonstrate EML expression differentiation with depth tracking."""
    print("=" * 60)
    print("EML EXPRESSION DIFFERENTIATION")
    print("=" * 60)
    print()

    expressions = [
        ("x", "1", 0, 0),
        ("x²", "2x", 0, 0),
        ("exp(x)", "exp(x)", 1, 1),
        ("exp(x²)", "2x·exp(x²)", 1, 1),
        ("log(x)", "1/x", 1, 1),
        ("exp(exp(x))", "exp(x)·exp(exp(x))", 2, 2),
        ("exp(log(x))", "exp(-log(x))·exp(log(x))", 2, 2),
        ("x·exp(x)", "exp(x) + x·exp(x)", 1, 1),
    ]

    print(f"  {'Expression':<20} {'Derivative':<30} {'Depth':<6} {'Deriv Depth':<11}")
    print(f"  {'─'*20} {'─'*30} {'─'*6} {'─'*11}")
    for expr, deriv, depth, d_depth in expressions:
        print(f"  {expr:<20} {deriv:<30} {depth:<6} {d_depth:<11}")
    print()
    print("Key insight: differentiation preserves EML class (closure theorem)")
    print("Depth bound: depth(f') ≤ 2·depth(f) + 1")
    print()

def demo_airy_numerical():
    """Solve the Airy equation numerically and show growth behavior."""
    print("=" * 60)
    print("AIRY EQUATION: NUMERICAL SOLUTIONS")
    print("=" * 60)
    print()

    xs = np.linspace(-15, 5, 2000)
    ai_vals, ai_prime, bi_vals, bi_prime = airy(xs)

    print("Ai(x) values at key points:")
    for x in [-10, -5, 0, 1, 2, 3, 4, 5]:
        ai_v, _, bi_v, _ = airy(x)
        print(f"  Ai({x:>3}) = {ai_v:>12.6e}    Bi({x:>3}) = {bi_v:>12.6e}")

    print()
    print("Growth behavior:")
    print("  For x → +∞: Ai(x) ~ exp(-2x^{3/2}/3) / (2√π·x^{1/4})  (decays)")
    print("  For x → +∞: Bi(x) ~ exp(+2x^{3/2}/3) / (√π·x^{1/4})    (grows)")
    print()
    print("  This intermediate growth rate exp(x^{3/2}) is BETWEEN")
    print("  polynomial growth and exp(x) growth — it's genuinely")
    print("  transcendental and cannot be captured by EML functions.")
    print()

def demo_kovacic_cases():
    """Illustrate the four cases of the Kovacic algorithm."""
    print("=" * 60)
    print("KOVACIC ALGORITHM: FOUR CASES")
    print("=" * 60)
    print()

    cases = [
        ("y'' = 0", "q=0", "Trivial ({1})", "y = ax + b", "Polynomial"),
        ("y'' = y", "q=1", "Borel subgroup", "y = e^x", "Exponential"),
        ("y'' = -y", "q=-1", "Finite (SO₂)", "y = sin(x)", "Trigonometric"),
        ("y'' = xy", "q=x", "SL₂(ℂ) (full)", "y = Ai(x)", "Transcendental"),
        ("y'' = x²y", "q=x²", "SL₂(ℂ) (full)", "Parabolic cyl.", "Transcendental"),
    ]

    print(f"  {'Equation':<14} {'q(x)':<6} {'Galois Group':<18} {'Solution':<16} {'Type':<14}")
    print(f"  {'─'*14} {'─'*6} {'─'*18} {'─'*16} {'─'*14}")
    for eq, q, galois, sol, typ in cases:
        print(f"  {eq:<14} {q:<6} {galois:<18} {sol:<16} {typ:<14}")
    print()
    print("The polynomial degree gap eliminates polynomial solutions for ALL")
    print("cases with deg(q) ≥ 1. The full Kovacic algorithm handles the rest.")
    print()

if __name__ == "__main__":
    demo_degree_gap()
    demo_wronskian_constancy()
    demo_eml_differentiation()
    demo_airy_numerical()
    demo_kovacic_cases()


"""
Visualization: Degree Gap Obstruction for Polynomial ODE Solutions

Shows why no polynomial can satisfy y'' = q(x)y when deg(q) >= 1.
The degree of the LHS (p'') and RHS (q*p) are irreconcilable.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches


def plot_degree_gap():
    """Create a visualization of the degree gap obstruction."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    # Panel 1: Degree comparison for Airy (q = x, deg = 1)
    ax = axes[0]
    ns = np.arange(0, 8)
    deg_lhs = np.maximum(ns - 2, -1)  # deg(p'') = n-2, or -inf if n <= 1
    deg_rhs = ns + 1  # deg(x*p) = n+1

    ax.plot(ns, deg_rhs, 'ro-', label="deg(x·p) = n+1", markersize=8, linewidth=2)
    ax.plot(ns[ns >= 2], ns[ns >= 2] - 2, 'bs-', label="deg(p'') = n−2", markersize=8, linewidth=2)
    ax.scatter([0, 1], [-0.5, -0.5], color='blue', marker='x', s=100, zorder=5, label="p'' = 0 (n ≤ 1)")

    for n in ns:
        if n >= 2:
            ax.annotate('', xy=(n, n+1), xytext=(n, n-2),
                       arrowprops=dict(arrowstyle='<->', color='green', lw=1.5))
            ax.text(n + 0.2, (n + 1 + n - 2) / 2, f'gap={3}',
                   fontsize=7, color='green')

    ax.set_xlabel('n = deg(p)', fontsize=12)
    ax.set_ylabel('Degree', fontsize=12)
    ax.set_title("Airy: y'' = xy\n(gap = 3, always)", fontsize=13, fontweight='bold')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    # Panel 2: General case (varying deg(q))
    ax = axes[1]
    n = 5  # fixed degree of p
    degs_q = np.arange(0, 6)
    deg_pp = max(n - 2, 0)
    deg_qp = degs_q + n

    ax.barh(degs_q - 0.15, deg_qp, height=0.3, color='red', alpha=0.7, label='deg(q·p)')
    ax.barh(degs_q + 0.15, [deg_pp] * len(degs_q), height=0.3, color='blue', alpha=0.7, label='deg(p\'\')')

    ax.set_ylabel('deg(q)', fontsize=12)
    ax.set_xlabel('Resulting degree', fontsize=12)
    ax.set_title(f"Fixed n = {n}: LHS vs RHS degree\n(never match for deg(q) ≥ 1)", fontsize=13, fontweight='bold')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    # Panel 3: The impossibility region
    ax = axes[2]
    ns_grid = np.arange(0, 10)
    dqs_grid = np.arange(0, 8)

    # For each (n, dq), compute whether LHS degree = RHS degree
    # LHS: n-2 (if n >= 2, else p'' = 0)
    # RHS: dq + n (if dq >= 1)
    for n in ns_grid:
        for dq in dqs_grid:
            if dq >= 1:
                color = 'red'  # impossible
                marker = 'x'
            elif dq == 0 and n >= 2:
                color = 'red'  # n-2 ≠ n
                marker = 'x'
            elif dq == 0 and n <= 1:
                color = 'red'  # p''=0, cp≠0
                marker = 'x'
            else:
                color = 'green'
                marker = 'o'
            ax.scatter(n, dq, color=color, marker=marker, s=60, zorder=5)

    # Only q=0 allows solutions (linear functions)
    ax.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
    ax.text(8.5, 0.3, 'Only q=0\nallows\nsolutions', fontsize=8, ha='right', color='green')

    # Shade impossible region
    rect = patches.Rectangle((0, 0.5), 9, 7, linewidth=0, facecolor='red', alpha=0.08)
    ax.add_patch(rect)

    ax.set_xlabel('n = deg(p)', fontsize=12)
    ax.set_ylabel('deg(q)', fontsize=12)
    ax.set_title("Impossibility Map\n(✗ = no poly solution)", fontsize=13, fontweight='bold')
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('degree_gap_obstruction.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: degree_gap_obstruction.png")


if __name__ == "__main__":
    plot_degree_gap()


"""
Visualization: Wronskian Constancy and Airy Functions

Shows the Airy functions Ai(x), Bi(x) and their constant Wronskian.
"""

import numpy as np
import matplotlib.pyplot as plt
from scipy.special import airy


def plot_wronskian():
    """Create a visualization of Airy functions and their Wronskian."""
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    xs = np.linspace(-15, 5, 2000)
    ai_vals, ai_prime, bi_vals, bi_prime = airy(xs)
    wronskian = ai_vals * bi_prime - bi_vals * ai_prime

    # Panel 1: Airy functions
    ax = axes[0, 0]
    ax.plot(xs, ai_vals, 'b-', linewidth=2, label='Ai(x)')
    ax.plot(xs, bi_vals, 'r-', linewidth=2, label='Bi(x)')
    ax.set_xlim(-15, 5)
    ax.set_ylim(-1.5, 1.5)
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('y', fontsize=12)
    ax.set_title('Airy Functions: Solutions of y\'\' = xy', fontsize=13, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.axhline(y=0, color='gray', linewidth=0.5)

    # Panel 2: Wronskian constancy
    ax = axes[0, 1]
    ax.plot(xs, wronskian, 'g-', linewidth=2, label='W(Ai, Bi)')
    ax.axhline(y=1/np.pi, color='orange', linestyle='--', linewidth=1.5, label=f'1/π ≈ {1/np.pi:.6f}')
    ax.set_xlim(-15, 5)
    ax.set_ylim(1/np.pi - 0.001, 1/np.pi + 0.001)
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('W(Ai, Bi)(x)', fontsize=12)
    ax.set_title('Wronskian: Constant = 1/π (Abel\'s Identity)', fontsize=13, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    # Panel 3: Verify y'' = xy
    ax = axes[1, 0]
    # Numerical second derivative
    dx = xs[1] - xs[0]
    ai_pp = np.gradient(np.gradient(ai_vals, dx), dx)
    x_times_ai = xs * ai_vals
    ax.plot(xs[10:-10], ai_pp[10:-10], 'b-', linewidth=1.5, alpha=0.7, label="Ai''(x) (numerical)")
    ax.plot(xs[10:-10], x_times_ai[10:-10], 'r--', linewidth=1.5, alpha=0.7, label="x · Ai(x)")
    ax.set_xlim(-15, 5)
    ax.set_ylim(-1.5, 1.5)
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('y', fontsize=12)
    ax.set_title("Verification: Ai''(x) = x · Ai(x)", fontsize=13, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    # Panel 4: Growth comparison
    ax = axes[1, 1]
    xs_pos = np.linspace(0.5, 8, 200)
    ai_pos, _, bi_pos, _ = airy(xs_pos)

    # Asymptotic approximation
    ai_asymp = np.exp(-2/3 * xs_pos**(3/2)) / (2 * np.sqrt(np.pi) * xs_pos**(1/4))

    ax.semilogy(xs_pos, np.abs(bi_pos), 'r-', linewidth=2, label='|Bi(x)| ~ exp(2x^{3/2}/3)')
    ax.semilogy(xs_pos, np.abs(ai_pos), 'b-', linewidth=2, label='|Ai(x)| ~ exp(-2x^{3/2}/3)')
    ax.semilogy(xs_pos, ai_asymp, 'b--', linewidth=1, alpha=0.5, label='Asymptotic approx.')

    # Compare with polynomial and exponential growth
    ax.semilogy(xs_pos, xs_pos**3, 'gray', linewidth=1, linestyle=':', label='x³ (polynomial)')
    ax.semilogy(xs_pos, np.exp(xs_pos), 'gray', linewidth=1, linestyle='-.', label='exp(x)')

    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('|y| (log scale)', fontsize=12)
    ax.set_title('Growth Rates: Beyond Polynomial, Beyond exp(x)', fontsize=13, fontweight='bold')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('wronskian_airy.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: wronskian_airy.png")


if __name__ == "__main__":
    plot_wronskian()
