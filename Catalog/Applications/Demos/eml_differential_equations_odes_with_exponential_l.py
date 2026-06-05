#!/usr/bin/env python3
"""
Demo: EML Differential Equations — Wronskian Theory and Kovacic Classification

Demonstrates the key theorems from our formalization with numerical examples.
"""

import numpy as np
from scipy.integrate import odeint
from scipy.special import airy


def wronskian(y1, y1_prime, y2, y2_prime):
    """Compute the Wronskian W(y1, y2) = y1*y2' - y2*y1'."""
    return y1 * y2_prime - y2 * y1_prime


def verify_abel_identity():
    """
    Verify Abel's Identity: W' = -p * W for y'' + p*y' + q*y = 0.
    
    Example: Damped oscillator y'' + 2*y' + 5*y = 0 (p=2, q=5)
    Solutions: y1 = e^{-x} cos(2x), y2 = e^{-x} sin(2x)
    Predicted: W(x) = W(0) * e^{-2x} (since W' = -2W)
    """
    print("=" * 60)
    print("DEMO 1: Abel's Identity — W' = -p · W")
    print("=" * 60)
    print("\nODE: y'' + 2y' + 5y = 0 (damped oscillator)")
    print("Solutions: y1 = e^(-x)cos(2x), y2 = e^(-x)sin(2x)")
    print()

    p = 2.0
    xs = np.linspace(0, 3, 100)

    y1 = np.exp(-xs) * np.cos(2 * xs)
    y1_prime = np.exp(-xs) * (-np.cos(2 * xs) - 2 * np.sin(2 * xs))

    y2 = np.exp(-xs) * np.sin(2 * xs)
    y2_prime = np.exp(-xs) * (-np.sin(2 * xs) + 2 * np.cos(2 * xs))

    W = wronskian(y1, y1_prime, y2, y2_prime)
    W_predicted = W[0] * np.exp(-p * xs)

    print(f"  W(0) = {W[0]:.6f}")
    print(f"  W(1) = {W[50]:.6f}  (predicted: {W_predicted[50]:.6f})")
    print(f"  W(3) = {W[-1]:.6f}  (predicted: {W_predicted[-1]:.6f})")
    print(f"  Max |W - W_pred| = {np.max(np.abs(W - W_predicted)):.2e}")
    print(f"\n  ✓ Abel's identity verified: W' = -{p}·W")


def verify_wronskian_reduced():
    """
    Verify: when p = 0 (reduced form), the Wronskian is constant.
    
    Example: y'' + y = 0 (harmonic oscillator, p=0)
    Solutions: y1 = cos(x), y2 = sin(x)
    """
    print("\n" + "=" * 60)
    print("DEMO 2: Constant Wronskian for Reduced ODEs (p = 0)")
    print("=" * 60)
    print("\nODE: y'' + y = 0 (p=0, reduced form)")
    print("Solutions: y1 = cos(x), y2 = sin(x)")
    print()

    xs = np.linspace(0, 10, 200)
    y1 = np.cos(xs)
    y1p = -np.sin(xs)
    y2 = np.sin(xs)
    y2p = np.cos(xs)

    W = wronskian(y1, y1p, y2, y2p)

    print(f"  W(0)  = {W[0]:.10f}")
    print(f"  W(π)  = {W[62]:.10f}")
    print(f"  W(2π) = {W[125]:.10f}")
    print(f"  W(10) = {W[-1]:.10f}")
    print(f"  Variation: {np.max(W) - np.min(W):.2e}")
    print(f"\n  ✓ Wronskian is constant (within numerical precision)")


def verify_solution_representation():
    """
    Verify the Solution Representation Theorem.
    
    y'' + y = 0, y1 = cos(x), y2 = sin(x)
    y3 = 3cos(x) - 2sin(x)
    Expected: c1 = 3, c2 = -2
    """
    print("\n" + "=" * 60)
    print("DEMO 3: Solution Representation Theorem")
    print("=" * 60)
    print("\nODE: y'' + y = 0")
    print("y1 = cos(x), y2 = sin(x), y3 = 3cos(x) - 2sin(x)")
    print()

    x = 1.0  # evaluate at x = 1
    y1 = np.cos(x)
    y1p = -np.sin(x)
    y2 = np.sin(x)
    y2p = np.cos(x)
    y3 = 3 * np.cos(x) - 2 * np.sin(x)
    y3p = -3 * np.sin(x) - 2 * np.cos(x)

    W12 = wronskian(y1, y1p, y2, y2p)
    W32 = wronskian(y3, y3p, y2, y2p)
    W13 = wronskian(y1, y1p, y3, y3p)

    c1 = W32 / W12
    c2 = W13 / W12

    print(f"  W(y1, y2) = {W12:.10f}")
    print(f"  c1 = W(y3, y2) / W(y1, y2) = {c1:.10f}  (expected: 3)")
    print(f"  c2 = W(y1, y3) / W(y1, y2) = {c2:.10f}  (expected: -2)")
    print(f"\n  ✓ Solution representation verified: y3 = {c1:.1f}·y1 + {c2:.1f}·y2")


def verify_riccati_reduction():
    """
    Verify the Riccati Reduction: if y solves the ODE, then r = y'/y solves
    the Riccati equation r' + r² + p·r + q = 0.
    
    Example: y'' - y = 0 (p=0, q=-1), solution y = e^x, r = 1
    Riccati: r' + r² - 1 = 0 + 1 - 1 = 0 ✓
    """
    print("\n" + "=" * 60)
    print("DEMO 4: Riccati Reduction")
    print("=" * 60)
    print("\nODE: y'' - y = 0 (p=0, q=-1)")
    print("Solution: y = e^x, so r = y'/y = 1")
    print()

    p, q = 0.0, -1.0
    r = 1.0
    r_prime = 0.0

    riccati = r_prime + r ** 2 + p * r + q
    print(f"  r' + r² + p·r + q = {r_prime} + {r**2} + {p*r} + {q} = {riccati}")
    print(f"\n  ✓ Riccati equation satisfied")

    # Also for y = e^{-x}, r = -1
    r = -1.0
    riccati = 0.0 + r ** 2 + p * r + q
    print(f"\n  For y = e^(-x): r = -1")
    print(f"  r' + r² + p·r + q = 0 + 1 + 0 + (-1) = {riccati}")
    print(f"  ✓ Also satisfied")


def airy_solutions():
    """
    Demonstrate Airy equation y'' = xy and its transcendence.
    """
    print("\n" + "=" * 60)
    print("DEMO 5: Airy Equation — y'' = xy (No EML Solutions)")
    print("=" * 60)
    print()

    xs = np.linspace(-15, 5, 1000)
    ai, aip, bi, bip = airy(xs)

    W = ai * bip - bi * aip

    print(f"  Airy functions computed at {len(xs)} points")
    print(f"  Wronskian W(Ai, Bi) = 1/π ≈ {1/np.pi:.10f}")
    print(f"  Computed W(0) = {W[len(xs)//4*3]:.10f}")
    print(f"  Wronskian variation: {np.max(W) - np.min(W):.2e}")
    print()
    print("  The Airy equation has Galois group SL(2,ℂ).")
    print("  Since SL(2) is not solvable, no Liouvillian solutions exist.")
    print("  This means Ai(x) and Bi(x) are genuinely new transcendental functions")
    print("  that cannot be expressed using exponentials and logarithms.")
    print()
    print("  Key obstruction (proved): If y solves y'' = xy and y ≠ 0,")
    print("  then r = y'/y cannot be constant (Theorem: airy_riccati_not_const).")


def kovacic_classification_examples():
    """
    Demonstrate the four Kovacic cases with examples.
    """
    print("\n" + "=" * 60)
    print("DEMO 6: Kovacic Classification — Four Cases")
    print("=" * 60)

    cases = [
        ("Case 1 (Reducible)", "y'' - y = 0", "e^x, e^{-x}",
         "Galois group ⊆ triangular. Tower height: 1"),
        ("Case 2 (Imprimitive)", "y'' - x^{-2}·y = 0", "x^φ, x^{1-φ} (φ = golden ratio)",
         "Galois group ⊆ D_∞. Tower height: 2"),
        ("Case 3 (Finite)", "y'' + y = 0", "cos(x), sin(x)",
         "Galois group finite. Solutions are algebraic over exp"),
        ("Case 4 (Full SL(2))", "y'' = x·y (Airy)", "Ai(x), Bi(x)",
         "Galois group = SL(2). No Liouvillian solutions"),
    ]

    for name, ode, sols, desc in cases:
        print(f"\n  {name}")
        print(f"    ODE: {ode}")
        print(f"    Solutions: {sols}")
        print(f"    {desc}")


def main():
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  EML Differential Equations: Wronskian & Kovacic Theory ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    verify_abel_identity()
    verify_wronskian_reduced()
    verify_solution_representation()
    verify_riccati_reduction()
    airy_solutions()
    kovacic_classification_examples()

    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Airy Functions and Their Transcendence

Shows the Airy functions Ai(x) and Bi(x), their Wronskian (constant = 1/π),
and the Riccati variable r = Ai'/Ai (which cannot be constant — our theorem).
"""

import numpy as np
import matplotlib.pyplot as plt
from scipy.special import airy


def plot_airy_analysis():
    """Create a multi-panel analysis of the Airy equation."""
    xs = np.linspace(-12, 5, 2000)
    ai, aip, bi, bip = airy(xs)

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    # Panel 1: Airy functions
    ax = axes[0, 0]
    ax.plot(xs, ai, 'b-', linewidth=1.5, label='Ai(x)')
    ax.plot(xs, bi, 'r-', linewidth=1.5, label='Bi(x)')
    ax.set_title(r"Airy Functions: $y'' = xy$", fontsize=13)
    ax.set_xlabel('x')
    ax.set_ylabel('y')
    ax.legend(fontsize=11)
    ax.set_ylim(-1, 2)
    ax.grid(True, alpha=0.3)

    # Panel 2: Wronskian (should be constant = 1/π)
    ax = axes[0, 1]
    W = ai * bip - bi * aip
    ax.plot(xs, W, 'k-', linewidth=1.5, label=r'$W(\mathrm{Ai}, \mathrm{Bi})$')
    ax.axhline(y=1/np.pi, color='g', linestyle='--', linewidth=1.5,
               label=r'$1/\pi \approx %.6f$' % (1/np.pi))
    ax.set_title(r"Wronskian (constant since $p=0$)", fontsize=13)
    ax.set_xlabel('x')
    ax.set_ylabel('W')
    ax.legend(fontsize=11)
    ax.set_ylim(0.3, 0.35)
    ax.grid(True, alpha=0.3)

    # Panel 3: Riccati variable r = Ai'/Ai
    ax = axes[1, 0]
    # Avoid zeros of Ai(x) — they cause poles in r
    mask = np.abs(ai) > 1e-6
    r_vals = np.where(mask, aip / ai, np.nan)
    ax.plot(xs, r_vals, 'b-', linewidth=1, label=r"$r = \mathrm{Ai}'/\mathrm{Ai}$")
    ax.set_title(r"Riccati Variable (cannot be constant)", fontsize=13)
    ax.set_xlabel('x')
    ax.set_ylabel('r(x)')
    ax.set_ylim(-10, 10)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.axhline(y=0, color='gray', linewidth=0.5)

    # Panel 4: Kovacic classification
    ax = axes[1, 1]
    ax.axis('off')
    text = """
    Kovacic Classification of y'' = xy

    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    The Airy equation falls into
    Case 4: Full SL(2) Galois group

    ▸ No Liouvillian solutions exist
    ▸ Ai(x), Bi(x) are genuinely
      new transcendental functions
    ▸ Cannot be expressed using
      exp, log, or algebraic operations

    Proved obstructions:
    1. No constant solutions (y=c ⟹ y=0)
    2. Riccati variable r ≠ const
       (if r = c, then x = c²,
        but D(x)=1 ≠ 0=D(c²))
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    """
    ax.text(0.05, 0.95, text, transform=ax.transAxes,
            fontsize=11, verticalalignment='top', fontfamily='monospace',
            bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

    plt.suptitle("Airy Equation: A Case Study in Differential Transcendence",
                 fontsize=15, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('viz_airy.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: viz_airy.png")


if __name__ == "__main__":
    plot_airy_analysis()


#!/usr/bin/env python3
"""
Visualization: Kovacic Classification — The Four Cases

Shows representative ODEs from each Kovacic case and their solutions.
"""

import numpy as np
import matplotlib.pyplot as plt
from scipy.integrate import solve_ivp
from scipy.special import airy


def solve_ode(p_func, q_func, y0, yp0, x_span, n_points=500):
    """Solve y'' + p(x)y' + q(x)y = 0 numerically."""
    def rhs(x, state):
        y, yp = state
        return [yp, -p_func(x) * yp - q_func(x) * y]

    sol = solve_ivp(rhs, x_span, [y0, yp0],
                    t_eval=np.linspace(*x_span, n_points),
                    method='RK45', max_step=0.01)
    return sol.t, sol.y[0]


def plot_four_cases():
    """Create a 2x2 grid showing the four Kovacic cases."""
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    colors = ['#2196F3', '#F44336', '#4CAF50', '#FF9800']

    # Case 1: Reducible — y'' - y = 0 (exp solutions)
    ax = axes[0, 0]
    xs = np.linspace(-2, 2, 300)
    y1 = np.exp(xs)
    y2 = np.exp(-xs)
    ax.plot(xs, y1, color=colors[0], linewidth=2, label=r'$e^x$')
    ax.plot(xs, y2, color=colors[1], linewidth=2, label=r'$e^{-x}$')
    ax.set_title("Case 1: Reducible (Exponential)", fontsize=13, fontweight='bold')
    ax.set_xlabel('x')
    ax.set_ylabel('y')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(-0.5, 7)
    ax.text(0.02, 0.98, r"$y'' - y = 0$" + "\n" + r"$G^0 \cong \mathbb{G}_m$",
            transform=ax.transAxes, fontsize=11, va='top',
            bbox=dict(boxstyle='round', facecolor='lightblue', alpha=0.8))

    # Case 2: Imprimitive — y'' + (1/(4x²))y = 0 (power solutions)
    ax = axes[0, 1]
    xs = np.linspace(0.1, 5, 300)
    y1 = np.sqrt(xs)
    y2 = 1.0 / np.sqrt(xs)
    ax.plot(xs, y1, color=colors[0], linewidth=2, label=r'$\sqrt{x}$')
    ax.plot(xs, y2, color=colors[1], linewidth=2, label=r'$1/\sqrt{x}$')
    ax.set_title("Case 2: Imprimitive (Algebraic)", fontsize=13, fontweight='bold')
    ax.set_xlabel('x')
    ax.set_ylabel('y')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(0, 3)
    ax.text(0.02, 0.98, r"$y'' + \frac{1}{4x^2}y = 0$" + "\n" + r"$G^0 \subseteq D_\infty$",
            transform=ax.transAxes, fontsize=11, va='top',
            bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

    # Case 3: Finite — y'' + y = 0 (trigonometric/algebraic)
    ax = axes[1, 0]
    xs = np.linspace(-4 * np.pi, 4 * np.pi, 500)
    y1 = np.cos(xs)
    y2 = np.sin(xs)
    ax.plot(xs, y1, color=colors[0], linewidth=2, label=r'$\cos(x)$')
    ax.plot(xs, y2, color=colors[1], linewidth=2, label=r'$\sin(x)$')
    ax.set_title("Case 3: Finite Galois Group", fontsize=13, fontweight='bold')
    ax.set_xlabel('x')
    ax.set_ylabel('y')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.text(0.02, 0.98, r"$y'' + y = 0$" + "\n" + r"$|G| < \infty$",
            transform=ax.transAxes, fontsize=11, va='top',
            bbox=dict(boxstyle='round', facecolor='lightgreen', alpha=0.8))

    # Case 4: Full SL(2) — Airy equation y'' = xy
    ax = axes[1, 1]
    xs = np.linspace(-15, 5, 1000)
    ai, aip, bi, bip = airy(xs)
    ax.plot(xs, ai, color=colors[0], linewidth=2, label='Ai(x)')
    ax.plot(xs, bi, color=colors[1], linewidth=2, label='Bi(x)')
    ax.set_title("Case 4: Full SL(2) — No EML Solutions", fontsize=13, fontweight='bold')
    ax.set_xlabel('x')
    ax.set_ylabel('y')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(-1.5, 2)
    ax.text(0.02, 0.98, r"$y'' = xy$ (Airy)" + "\n" + r"$G = \mathrm{SL}(2)$",
            transform=ax.transAxes, fontsize=11, va='top',
            bbox=dict(boxstyle='round', facecolor='#FFCCCC', alpha=0.8))

    plt.suptitle("The Kovacic Classification: Four Types of Second-Order Linear ODEs",
                 fontsize=15, fontweight='bold')
    plt.tight_layout()
    plt.savefig('viz_kovacic.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: viz_kovacic.png")


if __name__ == "__main__":
    plot_four_cases()


#!/usr/bin/env python3
"""
Visualization: Wronskian Evolution Under Abel's Identity

Shows how the Wronskian W(y1, y2) decays exponentially according to W' = -p*W
for the damped oscillator y'' + 2y' + 5y = 0.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib


def compute_wronskian_evolution():
    """Compute Wronskian for damped oscillator solutions."""
    p = 2.0  # damping coefficient

    xs = np.linspace(0, 4, 500)

    # Solutions: y1 = e^{-x}cos(2x), y2 = e^{-x}sin(2x)
    y1 = np.exp(-xs) * np.cos(2 * xs)
    y1p = np.exp(-xs) * (-np.cos(2 * xs) - 2 * np.sin(2 * xs))
    y2 = np.exp(-xs) * np.sin(2 * xs)
    y2p = np.exp(-xs) * (-np.sin(2 * xs) + 2 * np.cos(2 * xs))

    W_exact = y1 * y2p - y2 * y1p
    W_abel = W_exact[0] * np.exp(-p * xs)

    return xs, y1, y2, W_exact, W_abel, p


def plot_wronskian_evolution():
    """Create the Wronskian evolution plot."""
    xs, y1, y2, W_exact, W_abel, p = compute_wronskian_evolution()

    fig, axes = plt.subplots(2, 1, figsize=(10, 8), gridspec_kw={'height_ratios': [1, 1]})

    # Top: Solutions
    ax1 = axes[0]
    ax1.plot(xs, y1, 'b-', linewidth=1.5, label=r'$y_1 = e^{-x}\cos(2x)$')
    ax1.plot(xs, y2, 'r-', linewidth=1.5, label=r'$y_2 = e^{-x}\sin(2x)$')
    ax1.fill_between(xs, y1, y2, alpha=0.1, color='purple')
    ax1.set_ylabel('Solution value', fontsize=12)
    ax1.set_title(r"Damped Oscillator: $y'' + 2y' + 5y = 0$", fontsize=14)
    ax1.legend(fontsize=11, loc='upper right')
    ax1.grid(True, alpha=0.3)
    ax1.set_xlim(0, 4)

    # Bottom: Wronskian
    ax2 = axes[1]
    ax2.plot(xs, W_exact, 'k-', linewidth=2, label=r'$W(y_1, y_2)$ (exact)')
    ax2.plot(xs, W_abel, 'g--', linewidth=2, label=r"Abel's prediction: $W_0 e^{-2x}$")
    ax2.set_xlabel('x', fontsize=12)
    ax2.set_ylabel('Wronskian', fontsize=12)
    ax2.set_title(r"Abel's Identity: $W' = -pW$, so $W(x) = W_0 e^{-2x}$", fontsize=14)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)
    ax2.set_xlim(0, 4)

    plt.tight_layout()
    plt.savefig('viz_wronskian.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: viz_wronskian.png")


if __name__ == "__main__":
    plot_wronskian_evolution()
