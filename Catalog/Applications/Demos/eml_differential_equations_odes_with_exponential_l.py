#!/usr/bin/env python3
"""
EML Differential Equations: Numerical Demonstrations

Demonstrates key results from the EML Differential Equations research:
1. Airy function computation and growth analysis
2. Wronskian conservation verification
3. Polynomial obstruction verification
4. Kovacic/Riccati obstruction demonstration
"""

import numpy as np
from scipy.integrate import solve_ivp
from scipy.special import airy

def demo_airy_no_polynomial():
    """Demonstrate that no polynomial satisfies y'' = xy."""
    print("=" * 60)
    print("DEMO 1: No Polynomial Solves y'' = xy")
    print("=" * 60)
    
    # Check for monomials c*x^n
    for n in range(8):
        # If y = x^n, then y'' = n(n-1)x^{n-2}, and xy = x^{n+1}
        # Degree of y'' is n-2, degree of xy is n+1
        # These can never be equal for n >= 0
        lhs_deg = max(n - 2, -1)  # -1 means zero polynomial
        rhs_deg = n + 1
        print(f"  n={n}: deg(y'') = {lhs_deg}, deg(xy) = {rhs_deg}, "
              f"match = {lhs_deg == rhs_deg}")
    
    print("\n  → Degree mismatch for ALL n ≥ 0. No polynomial solution exists.\n")

def demo_airy_growth():
    """Demonstrate super-polynomial growth of Airy solutions."""
    print("=" * 60)
    print("DEMO 2: Airy Solutions Grow Super-Polynomially")
    print("=" * 60)
    
    # Airy function Ai(x) decays for x > 0, but Bi(x) grows
    x_vals = np.linspace(0, 15, 1000)
    ai, aip, bi, bip = airy(x_vals)
    
    # Bi(x) grows super-polynomially
    for n in [2, 5, 10, 20]:
        ratio = bi[-1] / (x_vals[-1] ** n) if x_vals[-1] ** n > 0 else float('inf')
        print(f"  Bi(15) / 15^{n} = {ratio:.6e}")
    
    # Compare with exp(2/3 * x^{3/2})
    x_large = 15.0
    asymp = np.exp(2/3 * x_large**1.5) / (2 * np.sqrt(np.pi) * x_large**0.25)
    print(f"\n  Bi(15) = {bi[-1]:.6e}")
    print(f"  Asymptotic formula: {asymp:.6e}")
    print(f"  → Airy Bi grows like exp(2x^{3}/2/3), faster than any polynomial\n")

def demo_wronskian_conservation():
    """Demonstrate that the Wronskian is constant for y'' + q(x)y = 0."""
    print("=" * 60)
    print("DEMO 3: Wronskian Conservation (Abel's Identity)")
    print("=" * 60)
    
    # For Airy equation y'' = xy (i.e., y'' + (-x)y = 0)
    # W(Ai, Bi) should be constant = 1/π
    
    x_vals = np.linspace(-10, 5, 1000)
    ai, aip, bi, bip = airy(x_vals)
    
    # Wronskian W = Ai * Bi' - Bi * Ai'
    W = ai * bip - bi * aip
    
    print(f"  W(Ai, Bi) at x = -10: {W[0]:.10f}")
    print(f"  W(Ai, Bi) at x = 0:   {W[500]:.10f}")
    print(f"  W(Ai, Bi) at x = 5:   {W[-1]:.10f}")
    print(f"  1/π =                  {1/np.pi:.10f}")
    print(f"  Max |W - 1/π| =        {np.max(np.abs(W - 1/np.pi)):.2e}")
    print(f"  → Wronskian is constant to machine precision!\n")

def demo_riccati_obstruction():
    """Demonstrate the Riccati equation obstruction."""
    print("=" * 60)
    print("DEMO 4: Riccati Equation Obstruction")
    print("=" * 60)
    
    print("  The substitution y = e^{∫ω} transforms y'' = xy into")
    print("  the Riccati equation: ω' + ω² = x")
    print()
    
    # If ω is a polynomial of degree d:
    # deg(ω') = d - 1, deg(ω²) = 2d
    # For the equation ω' + ω² = x, we need max(d-1, 2d) = 1
    for d in range(5):
        lhs_deg = max(d - 1, 2 * d) if d > 0 else 0
        print(f"  deg(ω) = {d}: deg(ω' + ω²) = {lhs_deg}, need = 1, "
              f"possible = {lhs_deg == 1}")
    
    print("\n  → No polynomial degree works. The Riccati equation has")
    print("    no polynomial solution, blocking EML-solvability.\n")

def demo_coefficient_recurrence():
    """Demonstrate the Airy coefficient recurrence."""
    print("=" * 60)
    print("DEMO 5: Airy Power Series Coefficient Recurrence")
    print("=" * 60)
    
    # For y = Σ a_n x^n, the Airy equation gives:
    # (n+3)(n+2) a_{n+3} = a_n
    
    # Two linearly independent solutions:
    # y1 starting with a0 = 1, a1 = 0
    # y2 starting with a0 = 0, a1 = 1
    
    N = 20
    a1 = np.zeros(N)
    a2 = np.zeros(N)
    a1[0] = 1.0
    a2[1] = 1.0
    
    for n in range(N - 3):
        a1[n + 3] = a1[n] / ((n + 3) * (n + 2))
        a2[n + 3] = a2[n] / ((n + 3) * (n + 2))
    
    print("  Solution y₁ (a₀=1, a₁=0):")
    for n in range(min(12, N)):
        if abs(a1[n]) > 1e-20:
            print(f"    a_{n} = {a1[n]:.10e}")
    
    print(f"\n  Note: a_{{3k+2}} = 0 for all k (mod-3 pattern)")
    
    # Verify: coefficients of indices ≡ 2 (mod 3) are zero
    for k in range(N // 3):
        idx = 3 * k + 2
        if idx < N:
            assert abs(a1[idx]) < 1e-15 and abs(a2[idx]) < 1e-15
    print(f"  ✓ Verified: a_{{3k+2}} = 0 for k = 0,...,{N//3 - 1}\n")

def demo_galois_sl2():
    """Demonstrate SL₂ invariance of the Wronskian."""
    print("=" * 60)
    print("DEMO 6: SL₂ Galois Group Preserves Wronskian")
    print("=" * 60)
    
    x_vals = np.linspace(-5, 5, 1000)
    ai, aip, bi, bip = airy(x_vals)
    
    # Original Wronskian
    W_orig = ai * bip - bi * aip
    
    # Apply an SL₂ transformation: [a b; c d] with ad-bc=1
    a, b, c, d = 3.0, 1.0, 2.0, 1.0  # det = 3*1 - 1*2 = 1
    
    f1 = a * ai + b * bi
    f1p = a * aip + b * bip
    f2 = c * ai + d * bi
    f2p = c * aip + d * bip
    
    W_new = f1 * f2p - f2 * f1p
    
    print(f"  SL₂ matrix: [[{a}, {b}], [{c}, {d}]]")
    print(f"  det = {a*d - b*c}")
    print(f"  Original W(Ai,Bi) at x=0:     {W_orig[500]:.10f}")
    print(f"  Transformed W(f₁,f₂) at x=0:  {W_new[500]:.10f}")
    print(f"  Max |W_new - W_orig| =         {np.max(np.abs(W_new - W_orig)):.2e}")
    print(f"  → SL₂ transformation preserves the Wronskian!\n")

if __name__ == "__main__":
    print("\n" + "🔬 EML DIFFERENTIAL EQUATIONS: NUMERICAL DEMONSTRATIONS".center(60))
    print("=" * 60 + "\n")
    
    demo_airy_no_polynomial()
    demo_airy_growth()
    demo_wronskian_conservation()
    demo_riccati_obstruction()
    demo_coefficient_recurrence()
    demo_galois_sl2()
    
    print("=" * 60)
    print("All demonstrations completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Airy Function Solutions and Growth Analysis

Plots the Airy functions Ai(x) and Bi(x), their growth rates,
and the Wronskian conservation theorem.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from scipy.special import airy


def plot_airy_functions():
    """Plot Airy functions Ai(x) and Bi(x)."""
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    
    # Panel 1: Ai and Bi on moderate range
    x = np.linspace(-15, 5, 2000)
    ai_vals, aip_vals, bi_vals, bip_vals = airy(x)
    
    ax = axes[0, 0]
    ax.plot(x, ai_vals, 'b-', linewidth=2, label='Ai(x)')
    ax.plot(x, bi_vals, 'r-', linewidth=2, label='Bi(x)')
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('y', fontsize=12)
    ax.set_title('Airy Functions: Solutions of y′′ = xy', fontsize=13)
    ax.legend(fontsize=11)
    ax.set_ylim(-1.5, 3)
    ax.grid(True, alpha=0.3)
    ax.axhline(y=0, color='k', linewidth=0.5)
    
    # Panel 2: Wronskian
    W = ai_vals * bip_vals - bi_vals * aip_vals
    ax = axes[0, 1]
    ax.plot(x, W, 'g-', linewidth=2)
    ax.axhline(y=1/np.pi, color='k', linestyle='--', linewidth=1, label=f'1/π ≈ {1/np.pi:.6f}')
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('W(Ai, Bi)', fontsize=12)
    ax.set_title("Wronskian Conservation (Abel's Identity)", fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(0.3, 0.35)
    
    # Panel 3: Growth rate comparison
    x_pos = np.linspace(0.1, 12, 500)
    ai_pos, _, bi_pos, _ = airy(x_pos)
    
    ax = axes[1, 0]
    ax.semilogy(x_pos, np.abs(bi_pos), 'r-', linewidth=2, label='|Bi(x)|')
    asymp = np.exp(2/3 * x_pos**1.5) / (np.sqrt(np.pi) * x_pos**0.25)
    ax.semilogy(x_pos, asymp, 'k--', linewidth=1, label=r'$\frac{1}{\sqrt{\pi} x^{1/4}} e^{2x^{3/2}/3}$')
    for n in [2, 5, 10]:
        ax.semilogy(x_pos, x_pos**n, '--', linewidth=1, alpha=0.5, label=f'x^{n}')
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('|y|', fontsize=12)
    ax.set_title('Super-Polynomial Growth of Bi(x)', fontsize=13)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)
    
    # Panel 4: Phase portrait
    x_range = np.linspace(-8, 2, 500)
    ai_r, aip_r, bi_r, bip_r = airy(x_range)
    
    ax = axes[1, 1]
    ax.plot(ai_r, aip_r, 'b-', linewidth=1.5, label='(Ai, Ai′)')
    ax.plot(bi_r, bip_r, 'r-', linewidth=1.5, label='(Bi, Bi′)')
    ax.set_xlabel('y', fontsize=12)
    ax.set_ylabel("y′", fontsize=12)
    ax.set_title('Phase Portrait: Airy Equation', fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(-1.5, 2)
    ax.set_ylim(-2, 2)
    
    plt.tight_layout()
    plt.savefig('airy_solutions.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: airy_solutions.png")


def plot_polynomial_obstruction():
    """Visualize why polynomials can't solve y'' = xy."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    
    # Panel 1: Degree diagram
    ax = axes[0]
    n_vals = np.arange(0, 8)
    deg_lhs = np.maximum(n_vals - 2, -1)  # deg(y'')
    deg_rhs = n_vals + 1  # deg(xy)
    
    ax.bar(n_vals - 0.15, deg_lhs, width=0.3, color='blue', alpha=0.7, label='deg(y′′) = n-2')
    ax.bar(n_vals + 0.15, deg_rhs, width=0.3, color='red', alpha=0.7, label='deg(xy) = n+1')
    ax.set_xlabel('Polynomial degree n', fontsize=12)
    ax.set_ylabel('Degree', fontsize=12)
    ax.set_title('Degree Obstruction: deg(y′′) ≠ deg(xy)', fontsize=13)
    ax.legend(fontsize=11)
    ax.set_xticks(n_vals)
    ax.grid(True, alpha=0.3, axis='y')
    
    # Panel 2: Riccati obstruction
    ax = axes[1]
    d_vals = np.arange(0, 6)
    deg_riccati = np.array([0] + [2*d for d in range(1, 6)])  # deg(ω' + ω²)
    colors = ['red' if d != 1 else 'green' for d in deg_riccati]
    
    ax.bar(d_vals, deg_riccati, color=colors, alpha=0.7)
    ax.axhline(y=1, color='blue', linestyle='--', linewidth=2, label='Required: deg = 1')
    ax.set_xlabel('Degree of ω', fontsize=12)
    ax.set_ylabel('deg(ω′ + ω²)', fontsize=12)
    ax.set_title('Riccati Obstruction: 2d ≠ 1', fontsize=13)
    ax.legend(fontsize=11)
    ax.set_xticks(d_vals)
    ax.grid(True, alpha=0.3, axis='y')
    
    plt.tight_layout()
    plt.savefig('polynomial_obstruction.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: polynomial_obstruction.png")


def plot_sl2_invariance():
    """Visualize SL₂ Galois group action on solutions."""
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    
    x = np.linspace(-10, 4, 1000)
    ai, aip, bi, bip = airy(x)
    
    # Several SL₂ transformations
    transforms = [
        (1, 0, 0, 1, "Identity"),
        (2, 1, 1, 1, "[[2,1],[1,1]]"),
        (0, -1, 1, 0, "[[0,-1],[1,0]]"),
    ]
    
    for idx, (a, b, c, d, label) in enumerate(transforms):
        ax = axes[idx]
        f1 = a * ai + b * bi
        f2 = c * ai + d * bi
        f1p = a * aip + b * bip
        f2p = c * aip + d * bip
        W = f1 * f2p - f2 * f1p
        
        ax.plot(x, f1, 'b-', linewidth=1.5, label=f'f₁ = {a}Ai + {b}Bi')
        ax.plot(x, f2, 'r-', linewidth=1.5, label=f'f₂ = {c}Ai + {d}Bi')
        ax.set_xlabel('x', fontsize=12)
        ax.set_ylabel('y', fontsize=12)
        ax.set_title(f'SL₂ transform {label}\nW = {W[500]:.6f}', fontsize=11)
        ax.legend(fontsize=9)
        ax.set_ylim(-3, 3)
        ax.grid(True, alpha=0.3)
    
    plt.suptitle('SL₂(ℂ) Galois Group Action: Wronskian Preserved', fontsize=14, y=1.02)
    plt.tight_layout()
    plt.savefig('sl2_invariance.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: sl2_invariance.png")


if __name__ == "__main__":
    plot_airy_functions()
    plot_polynomial_obstruction()
    plot_sl2_invariance()
    print("\nAll visualizations generated!")
