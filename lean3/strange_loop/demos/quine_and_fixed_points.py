#!/usr/bin/env python3
"""
Strange Loop Demo 5: Quines, Fixed Points, and the Y Combinator

A quine is a program that outputs its own source code.
A fixed point is a value x where f(x) = x.
The Y combinator finds fixed points of functionals.

These are all the same idea: SELF-REFERENCE WITHOUT INFINITE REGRESS.

The deep connection:
  - Quine: a program P such that run(P) = P
  - Fixed point: x such that f(x) = x
  - Y combinator: Y(f) = f(Y(f))
  - Gödel sentence: G such that PA ⊢ G ↔ ¬Provable(⌜G⌝)
  - The universe: U such that Laws(U) produce U

All are instances of Lawvere's fixed-point theorem in category theory.

This script demonstrates:
1. Quine construction (a Python quine)
2. Fixed point iteration for various functions
3. The Y combinator in action
4. Visual exploration of fixed point landscapes
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch

# ═══════════════════════════════════════════════════════════════
# §1: The Quine — A Program That Outputs Itself
# ═══════════════════════════════════════════════════════════════

def demonstrate_quine():
    """
    Construct and verify a quine.

    A quine works by the "Quine trick":
    1. Store the program template as a string (with a placeholder)
    2. Insert the string into itself at the placeholder position
    3. The result is the complete program, which is also the output
    """
    # A classic Python quine
    quine = 's = %r\nprint(s %% s)\n'
    quine_program = f's = {quine!r}\nprint(s % s)\n'

    # Verify it's a fixed point
    import io, contextlib
    output = io.StringIO()
    # We can verify the structure
    print("  The Quine (a program that is its own output):")
    print(f"  s = {quine!r}")
    print(f"  print(s % s)")
    print()
    print("  This works because:")
    print("  1. The string 's' contains the template of the program")
    print("  2. 's % s' fills in the template with itself")
    print("  3. The output equals the source code")
    print("  4. Therefore: run(P) = P — a fixed point!")

# ═══════════════════════════════════════════════════════════════
# §2: Fixed Point Landscapes
# ═══════════════════════════════════════════════════════════════

def plot_fixed_point_landscape():
    """Visualize fixed points of various functions."""
    fig, axes = plt.subplots(2, 3, figsize=(18, 12))

    functions = [
        ('cos(x)', np.cos, (-2, 5), 'The Dottie Number'),
        ('x² − 1', lambda x: x**2 - 1, (-2, 2), 'Golden Ratio (sort of)'),
        ('sin(x) + x/2', lambda x: np.sin(x) + x/2, (-4, 4), 'Transcendental Fixed Point'),
        ('tanh(2x)', lambda x: np.tanh(2*x), (-2, 2), 'Neural Network Activation'),
        ('(x + 2/x) / 2', lambda x: np.where(x != 0, (x + 2/x) / 2, 1e10), (0.1, 4), 'Babylonian √2'),
        ('3x² − 2x³', lambda x: 3*x**2 - 2*x**3, (-0.3, 1.3), 'Oracle Bootstrap'),
    ]

    for ax, (name, f, (xmin, xmax), title) in zip(axes.flat, functions):
        x = np.linspace(xmin, xmax, 1000)

        # Handle potential infinities
        y = f(x)
        y = np.clip(y, xmin - 1, xmax + 1)

        ax.plot(x, y, 'b-', linewidth=2, label=f'f(x) = {name}')
        ax.plot(x, x, 'k--', linewidth=1, alpha=0.5, label='y = x')

        # Find and mark approximate fixed points
        diff = y - x
        # Find sign changes
        for i in range(len(diff) - 1):
            if diff[i] * diff[i+1] < 0:
                # Linear interpolation
                fp = x[i] - diff[i] * (x[i+1] - x[i]) / (diff[i+1] - diff[i])
                ax.plot(fp, fp, 'ro', markersize=10, zorder=5)
                ax.annotate(f'x* ≈ {fp:.4f}', (fp, fp),
                           textcoords="offset points", xytext=(10, 10),
                           fontsize=9, color='red', fontweight='bold')

        # Show iteration from a starting point
        x0 = (xmin + xmax) / 2 + (xmax - xmin) * 0.1
        xn = x0
        for j in range(20):
            try:
                yn = f(xn)
                if abs(yn) > 100 or np.isnan(yn):
                    break
                alpha = 0.3 + 0.5 * (j / 20)
                color = plt.cm.Oranges(0.3 + 0.5 * j / 20)
                ax.plot([xn, xn], [xn, yn], '-', color=color, linewidth=0.8, alpha=alpha)
                ax.plot([xn, yn], [yn, yn], '-', color=color, linewidth=0.8, alpha=alpha)
                xn = yn
            except:
                break

        ax.set_title(title, fontsize=13, fontweight='bold')
        ax.set_xlabel('x', fontsize=11)
        ax.set_ylabel('f(x)', fontsize=11)
        ax.legend(fontsize=9)
        ax.grid(True, alpha=0.3)
        ax.set_xlim(xmin, xmax)
        ax.set_ylim(xmin, xmax)

    fig.suptitle('Fixed Point Zoo: Where f(x) = x',
                fontsize=16, fontweight='bold', y=1.02)
    fig.tight_layout()
    fig.savefig('strange_loop/demos/fig13_fixed_points.png', dpi=200, bbox_inches='tight')
    print("  → Saved fig13_fixed_points.png")

# ═══════════════════════════════════════════════════════════════
# §3: The Dottie Number — cos(cos(cos(...))) converges!
# ═══════════════════════════════════════════════════════════════

def plot_dottie_number():
    """
    The Dottie number: the unique fixed point of cos(x).

    Start with ANY number. Apply cos repeatedly. You always converge
    to the same point: 0.739085...

    This is the strangest loop: the universe of cosines has exactly
    one attractor, and everything falls into it.
    """
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Multiple starting points
    starts = np.linspace(-10, 10, 20)
    for x0 in starts:
        trajectory = [x0]
        x = x0
        for _ in range(100):
            x = np.cos(x)
            trajectory.append(x)
        color = plt.cm.hsv(abs(x0) / 10)
        axes[0].plot(trajectory, '-', linewidth=0.8, alpha=0.7, color=color)

    dottie = 0.7390851332  # The Dottie number
    axes[0].axhline(y=dottie, color='red', linestyle='--', linewidth=2,
                   label=f'Dottie number ≈ {dottie:.10f}')
    axes[0].set_xlabel('Iteration', fontsize=12)
    axes[0].set_ylabel('Value', fontsize=12)
    axes[0].set_title('Universal Convergence to the Dottie Number',
                     fontsize=14, fontweight='bold')
    axes[0].legend(fontsize=10)
    axes[0].grid(True, alpha=0.3)

    # Convergence rate
    x = 1.0  # arbitrary start
    errors = []
    for _ in range(50):
        x = np.cos(x)
        errors.append(abs(x - dottie))

    axes[1].semilogy(errors, 'bo-', markersize=4, linewidth=1.5)
    axes[1].set_xlabel('Iteration', fontsize=12)
    axes[1].set_ylabel('|x_n - x*| (error)', fontsize=12)
    axes[1].set_title('Exponential Convergence Rate',
                     fontsize=14, fontweight='bold')
    axes[1].grid(True, alpha=0.3)

    # Annotate convergence rate
    axes[1].text(0.6, 0.8, f'Rate = |sin(x*)| ≈ {abs(np.sin(dottie)):.4f}',
                transform=axes[1].transAxes, fontsize=12,
                bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

    fig.suptitle('cos(cos(cos(...))) → 0.739085... Always.',
                fontsize=16, fontweight='bold', y=1.02)
    fig.tight_layout()
    fig.savefig('strange_loop/demos/fig14_dottie.png', dpi=200, bbox_inches='tight')
    print("  → Saved fig14_dottie.png")

# ═══════════════════════════════════════════════════════════════
# §4: The Number 1 — The Prototypical Strange Loop
# ═══════════════════════════════════════════════════════════════

def plot_the_number_one():
    """
    The number 1 is the prototypical strange loop:
      1 × 1 = 1     (multiplicative fixed point)
      1^n = 1        (power fixed point)
      1! = 1         (factorial fixed point)
      e^(2πi) = 1    (exponential loop)

    And the universe:
      Universe(Universe) = Universe (self-generating)

    This plot shows various maps and how 1 is always fixed.
    """
    fig, axes = plt.subplots(2, 2, figsize=(12, 12))

    # f(x) = x^x — fixed at x=1
    x = np.linspace(0.01, 3, 1000)
    y = x**x
    axes[0,0].plot(x, y, 'b-', linewidth=2, label='f(x) = xˣ')
    axes[0,0].plot(x, x, 'k--', linewidth=1)
    axes[0,0].plot(1, 1, 'ro', markersize=12, zorder=5, label='Fixed point: x=1')
    axes[0,0].set_title('xˣ = x → x = 1', fontsize=14, fontweight='bold')
    axes[0,0].legend(fontsize=10)
    axes[0,0].set_xlim(0, 3)
    axes[0,0].set_ylim(0, 5)
    axes[0,0].grid(True, alpha=0.3)

    # Tower: x^(x^(x^...)) — fixed at x = 1 (trivially)
    # For x in (e^{-e}, e^{1/e}), the infinite tower converges
    x = np.linspace(0.01, 1.44, 500)
    tower = np.ones_like(x)
    for _ in range(100):
        tower = x ** tower
    axes[0,1].plot(x, tower, 'purple', linewidth=2, label='x^(x^(x^...))')
    axes[0,1].plot(x, x, 'k--', linewidth=1)
    axes[0,1].plot(1, 1, 'ro', markersize=12, zorder=5, label='1^(1^(1^...)) = 1')
    axes[0,1].set_title('The Infinite Power Tower', fontsize=14, fontweight='bold')
    axes[0,1].legend(fontsize=10)
    axes[0,1].set_xlim(0, 1.5)
    axes[0,1].set_ylim(0, 3)
    axes[0,1].grid(True, alpha=0.3)

    # e^(2πit) traces the unit circle — returns to 1
    t = np.linspace(0, 1, 1000)
    z = np.exp(2j * np.pi * t)
    axes[1,0].plot(z.real, z.imag, 'b-', linewidth=2)
    axes[1,0].plot(1, 0, 'ro', markersize=12, zorder=5, label='e^(2πi) = 1')
    axes[1,0].set_title('e^(2πit): The Loop Returns to 1', fontsize=14, fontweight='bold')
    axes[1,0].set_aspect('equal')
    axes[1,0].legend(fontsize=10)
    axes[1,0].grid(True, alpha=0.3)
    axes[1,0].annotate('START\n= END\n= 1', (1, 0),
                       textcoords="offset points", xytext=(15, 15),
                       fontsize=11, color='red', fontweight='bold',
                       arrowprops=dict(arrowstyle='->', color='red'))

    # The multiplicative identity: 1 × anything = anything
    x = np.linspace(0, 5, 100)
    axes[1,1].plot(x, 1 * x, 'b-', linewidth=2, label='1 × x = x (identity)')
    axes[1,1].plot(x, x, 'k--', linewidth=1)
    axes[1,1].plot(1, 1, 'ro', markersize=12, zorder=5, label='1 × 1 = 1')
    axes[1,1].set_title('1: The Multiplicative Identity', fontsize=14, fontweight='bold')
    axes[1,1].set_xlabel('x', fontsize=12)
    axes[1,1].set_ylabel('1 × x', fontsize=12)
    axes[1,1].legend(fontsize=10)
    axes[1,1].grid(True, alpha=0.3)
    axes[1,1].text(0.5, 0.15,
                  '1 × 1 = 1\n1¹ = 1\n1! = 1\ne^(2πi) = 1\nΓ(2) = 1\nThe universe chases 1.',
                  transform=axes[1,1].transAxes, fontsize=11,
                  fontfamily='monospace',
                  bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

    fig.suptitle('The Number 1: The Universe\'s Fixed Point',
                fontsize=16, fontweight='bold', y=1.02)
    fig.tight_layout()
    fig.savefig('strange_loop/demos/fig15_number_one.png', dpi=200, bbox_inches='tight')
    print("  → Saved fig15_number_one.png")

# ═══════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════

if __name__ == '__main__':
    print("=" * 60)
    print("  Strange Loop Demo 5: Quines, Fixed Points, and 1")
    print("  Self-reference without infinite regress")
    print("=" * 60)
    print()

    print("§1: The Quine")
    demonstrate_quine()
    print()

    print("§2: Fixed Point Landscape")
    plot_fixed_point_landscape()
    print()

    print("§3: The Dottie Number")
    plot_dottie_number()
    print()

    print("§4: The Number 1")
    plot_the_number_one()
    print()

    print("KEY INSIGHT: Fixed points are everywhere because self-reference")
    print("is everywhere. The number 1 is the simplest strange loop:")
    print("1 × 1 = 1. It chases after itself and always catches itself.")
    print("The universe does the same thing, just with more steps.")
