#!/usr/bin/env python3
"""
Demonstration of Riccati-Airy Obstruction Theory

Shows why Airy's equation y'' = xy has no polynomial Riccati solutions,
and visualizes the degree obstruction from the Kovacic algorithm.
"""

import numpy as np

def riccati_from_poly(coeffs):
    """
    Given polynomial p(x) = sum(coeffs[i] * x^i),
    compute p'(x) + p(x)^2 as a polynomial (list of coefficients).
    """
    n = len(coeffs)
    # Compute derivative
    deriv = [coeffs[i] * i for i in range(1, n)]
    if not deriv:
        deriv = [0.0]
    
    # Compute p^2 via convolution
    sq = [0.0] * (2 * n - 1)
    for i in range(n):
        for j in range(n):
            sq[i + j] += coeffs[i] * coeffs[j]
    
    # Add derivative + square
    max_len = max(len(deriv), len(sq))
    result = [0.0] * max_len
    for i in range(len(deriv)):
        result[i] += deriv[i]
    for i in range(len(sq)):
        result[i] += sq[i]
    
    return result


def check_riccati_airy(coeffs):
    """
    Check if polynomial with given coefficients satisfies ω' + ω² = x.
    Target: [0, 1, 0, 0, ...] (the polynomial X).
    """
    result = riccati_from_poly(coeffs)
    target = [0.0, 1.0]
    
    max_len = max(len(result), len(target))
    result.extend([0.0] * (max_len - len(result)))
    target.extend([0.0] * (max_len - len(target)))
    
    error = sum((r - t)**2 for r, t in zip(result, target))
    return result, error


def degree_obstruction_demo():
    """
    Demonstrate the degree obstruction: for any polynomial p of degree n ≥ 1,
    deg(p' + p²) = 2n, which can never equal 1 = deg(X).
    """
    print("=" * 60)
    print("DEGREE OBSTRUCTION FOR AIRY'S RICCATI EQUATION")
    print("=" * 60)
    print()
    print("Airy's equation: y'' = xy")
    print("Associated Riccati: ω' + ω² = x")
    print()
    print("For polynomial ω of degree n:")
    print("  deg(ω') = n - 1")
    print("  deg(ω²) = 2n")
    print("  deg(ω' + ω²) = max(n-1, 2n) = 2n  (when n ≥ 1)")
    print()
    print("But deg(x) = 1, so 2n = 1 → n = 1/2 (impossible!)")
    print()
    
    # Test specific cases
    test_cases = [
        ("Constant: ω = 1", [1.0]),
        ("Constant: ω = 2", [2.0]),
        ("Linear: ω = x", [0.0, 1.0]),
        ("Linear: ω = x + 1", [1.0, 1.0]),
        ("Quadratic: ω = x²", [0.0, 0.0, 1.0]),
        ("Quadratic: ω = x² + x", [0.0, 1.0, 1.0]),
        ("Cubic: ω = x³", [0.0, 0.0, 0.0, 1.0]),
    ]
    
    header2 = "ω' + ω²"
    print(f"{'Candidate ω':25} {header2:40} {'Error':>10}")
    print("-" * 80)
    
    for name, coeffs in test_cases:
        result, error = check_riccati_airy(coeffs)
        # Format result polynomial
        terms = []
        for i, c in enumerate(result):
            if abs(c) > 1e-10:
                if i == 0:
                    terms.append(f"{c:.0f}")
                elif i == 1:
                    terms.append(f"{c:.0f}x")
                else:
                    terms.append(f"{c:.0f}x^{i}")
        result_str = " + ".join(terms) if terms else "0"
        print(f"{name:25} {result_str:40} {error:>10.4f}")
    
    print()
    print("None match x = [0, 1] — the degree obstruction is absolute!")


def riccati_landscape():
    """
    Show the 'landscape' of ω' + ω² - x for various trial functions.
    """
    print()
    print("=" * 60)
    print("RICCATI RESIDUAL LANDSCAPE")
    print("=" * 60)
    print()
    
    x_vals = np.linspace(-3, 3, 7)
    
    # For ω = ax + b, compute ω' + ω² - x = a + (ax+b)² - x
    print("Trial: ω = ax + b → residual = a + a²x² + 2abx + b² - x")
    print()
    
    for a in [-1, 0, 1]:
        for b in [-1, 0, 1]:
            residuals = [a + (a*x + b)**2 - x for x in x_vals]
            max_res = max(abs(r) for r in residuals)
            print(f"  a={a:+d}, b={b:+d}: max|residual| = {max_res:.2f}")
    
    print()
    print("Even the best linear trial has large residual — no solution exists!")


def wronskian_demo():
    """
    Demonstrate the Wronskian and Abel's identity for a specific ODE.
    """
    print()
    print("=" * 60)
    print("WRONSKIAN AND ABEL'S IDENTITY")
    print("=" * 60)
    print()
    print("For y'' + p(x)y' + q(x)y = 0:")
    print("  W(y₁,y₂) = y₁y₂' - y₁'y₂")
    print("  Abel's identity: W' = -pW")
    print("  Solution: W(x) = W(x₀) · exp(-∫p)")
    print()
    
    # Example: y'' - y = 0 (p = 0, q = -1)
    # Solutions: y₁ = eˣ, y₂ = e⁻ˣ
    print("Example: y'' - y = 0 (p=0, q=-1)")
    print("  y₁ = eˣ, y₂ = e⁻ˣ")
    
    x_vals = np.linspace(-2, 2, 9)
    print(f"\n  {'x':>6} {'W(x)':>12} {'W₀·e^{-∫0}':>12} {'Match?':>8}")
    print("  " + "-" * 42)
    
    W0 = np.exp(0) * (-np.exp(0)) - np.exp(0) * np.exp(0)  # W(0) = -2
    for x in x_vals:
        W = np.exp(x) * (-np.exp(-x)) - np.exp(x) * np.exp(-x)  # = -2
        W_abel = W0 * np.exp(0)  # ∫0 = 0, so W = W₀
        match = "✓" if abs(W - W_abel) < 1e-10 else "✗"
        print(f"  {x:6.2f} {W:12.6f} {W_abel:12.6f} {match:>8}")
    
    print()
    print("  W(x) = -2 everywhere (p=0 → W is constant). ✓")


def kovacic_overview():
    """
    Overview of Kovacic's algorithm cases.
    """
    print()
    print("=" * 60)
    print("KOVACIC ALGORITHM: THREE CASES")
    print("=" * 60)
    print()
    print("For y'' = r(x)y, the Kovacic algorithm checks:")
    print()
    print("  Case 1: Does ω' + ω² = r have a RATIONAL solution?")
    print("    → Galois group ⊆ Borel (upper triangular)")
    print("    → For Airy (r=x): FAILS (degree obstruction)")
    print()
    print("  Case 2: Does ω' + ω² = r have a solution ω = a + b√r?")
    print("    → Galois group ⊆ D∞ (dihedral)")
    print("    → For Airy: FAILS (pole analysis)")
    print()
    print("  Case 3: Is ω algebraic of degree 4, 6, or 12 over C(x)?")
    print("    → Galois group is finite")
    print("    → For Airy: FAILS (monodromy analysis)")
    print()
    print("  All cases fail → Galois group = SL(2,C)")
    print("    → No Liouvillian (EML) solutions exist!")
    print()
    print("  Our formalization proves Case 1 failure rigorously.")


if __name__ == "__main__":
    degree_obstruction_demo()
    riccati_landscape()
    wronskian_demo()
    kovacic_overview()


#!/usr/bin/env python3
"""
Visualization: Riccati Residual Landscape for Airy's Equation

Shows why no polynomial can satisfy ω' + ω² = x by plotting the residual
|ω' + ω² - x| over a grid of polynomial coefficients.
"""

import numpy as np

try:
    import matplotlib.pyplot as plt
    import matplotlib.colors as mcolors
    HAS_MPL = True
except ImportError:
    HAS_MPL = False


def riccati_residual_linear(a: float, b: float, x_vals: np.ndarray) -> np.ndarray:
    """Compute |ω' + ω² - x| for ω(x) = ax + b."""
    omega = a * x_vals + b
    omega_prime = a
    return np.abs(omega_prime + omega**2 - x_vals)


def riccati_residual_quadratic(a: float, b: float, c: float,
                                x_vals: np.ndarray) -> np.ndarray:
    """Compute |ω' + ω² - x| for ω(x) = ax² + bx + c."""
    omega = a * x_vals**2 + b * x_vals + c
    omega_prime = 2 * a * x_vals + b
    return np.abs(omega_prime + omega**2 - x_vals)


def plot_residual_landscape():
    """Plot the Riccati residual for linear trial functions ω = ax + b."""
    if not HAS_MPL:
        print("matplotlib not available; printing numerical results instead.")
        a_vals = np.linspace(-3, 3, 7)
        b_vals = np.linspace(-3, 3, 7)
        x_eval = np.linspace(-2, 2, 50)
        print(f"{'a':>6} {'b':>6} {'max_residual':>15}")
        for a in a_vals:
            for b in b_vals:
                res = riccati_residual_linear(a, b, x_eval)
                print(f"{a:6.2f} {b:6.2f} {np.max(res):15.4f}")
        return

    fig, axes = plt.subplots(1, 3, figsize=(18, 5))
    
    # Plot 1: Max residual over [-2,2] as function of (a,b) for ω = ax + b
    a_vals = np.linspace(-3, 3, 100)
    b_vals = np.linspace(-3, 3, 100)
    x_eval = np.linspace(-2, 2, 200)
    
    A, B = np.meshgrid(a_vals, b_vals)
    max_res = np.zeros_like(A)
    
    for i in range(len(b_vals)):
        for j in range(len(a_vals)):
            res = riccati_residual_linear(A[i,j], B[i,j], x_eval)
            max_res[i, j] = np.max(res)
    
    ax = axes[0]
    im = ax.pcolormesh(A, B, np.log10(max_res + 1e-10),
                        cmap='hot_r', shading='auto')
    ax.set_xlabel('a (slope)')
    ax.set_ylabel('b (intercept)')
    ax.set_title('log₁₀ max|ω\' + ω² - x| for ω = ax + b')
    plt.colorbar(im, ax=ax)
    ax.set_aspect('equal')
    
    # Plot 2: Residual curves for specific trial functions
    ax = axes[1]
    x_plot = np.linspace(-3, 3, 300)
    
    trials = [
        (0, 0, 'ω = 0'),
        (1, 0, 'ω = x'),
        (0, 1, 'ω = 1'),
        (1, 1, 'ω = x+1'),
        (-1, 0, 'ω = -x'),
    ]
    
    for a, b, label in trials:
        res = riccati_residual_linear(a, b, x_plot)
        ax.plot(x_plot, res, label=label, linewidth=1.5)
    
    ax.set_xlabel('x')
    ax.set_ylabel('|ω\' + ω² - x|')
    ax.set_title('Riccati Residual: No Linear ω Works')
    ax.legend()
    ax.set_ylim(0, 15)
    ax.grid(True, alpha=0.3)
    
    # Plot 3: Degree obstruction diagram
    ax = axes[2]
    degrees = range(0, 8)
    lhs_degrees = [max(0, 2*n) for n in degrees]
    rhs_degree = 1  # deg(x)
    
    colors = ['green' if ld == rhs_degree else 'red' for ld in lhs_degrees]
    ax.bar(degrees, lhs_degrees, color=colors, alpha=0.7, edgecolor='black')
    ax.axhline(y=rhs_degree, color='blue', linestyle='--', linewidth=2,
               label='deg(x) = 1')
    ax.set_xlabel('deg(ω)')
    ax.set_ylabel('deg(ω\' + ω²)')
    ax.set_title('Degree Obstruction: 2n ≠ 1')
    ax.legend()
    ax.set_xticks(list(degrees))
    ax.grid(True, alpha=0.3, axis='y')
    
    plt.tight_layout()
    plt.savefig('riccati_landscape.png', dpi=150, bbox_inches='tight')
    print("Saved riccati_landscape.png")
    plt.close()


if __name__ == "__main__":
    plot_residual_landscape()
