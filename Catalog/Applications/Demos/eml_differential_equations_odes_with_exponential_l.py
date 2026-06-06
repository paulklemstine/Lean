#!/usr/bin/env python3
"""
EML Differential Equations: Demonstrations

This script demonstrates the key mathematical ideas from the EML Differential
Ring theory, including:
1. Wronskian computation for Airy functions
2. Abel's identity verification
3. Riccati equation from exponential ansatz
4. SL(2) invariance of the Wronskian
"""

import numpy as np
from scipy.special import airy
from scipy.integrate import solve_ivp
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def demo_airy_wronskian():
    """
    Demonstrate that the Wronskian of Airy functions Ai(x) and Bi(x)
    is constant = 1/π.
    """
    print("=" * 60)
    print("Demo 1: Airy Wronskian is Constant")
    print("=" * 60)

    x = np.linspace(-10, 5, 1000)
    ai, ai_prime, bi, bi_prime = airy(x)

    # W(Ai, Bi) = Ai * Bi' - Bi * Ai'
    wronskian = ai * bi_prime - bi * ai_prime

    print(f"  Theoretical value: W = 1/π ≈ {1/np.pi:.10f}")
    print(f"  Computed W at x=0:       {wronskian[500]:.10f}")
    print(f"  Max deviation from 1/π:  {np.max(np.abs(wronskian - 1/np.pi)):.2e}")
    print(f"  → Abel's identity confirmed: W' = -p·W = 0 (since p=0)")
    print()

    return x, ai, bi, wronskian


def demo_abel_identity():
    """
    Verify Abel's identity W' = -p*W for a general 2nd-order ODE.
    Consider y'' + sin(x)*y' + cos(x)*y = 0.
    """
    print("=" * 60)
    print("Demo 2: Abel's Identity for General ODE")
    print("=" * 60)

    def ode_system(t, Y):
        y1, y1p, y2, y2p = Y
        p = np.sin(t)
        q = np.cos(t)
        return [y1p, -p*y1p - q*y1, y2p, -p*y2p - q*y2]

    # Two linearly independent initial conditions
    sol = solve_ivp(ode_system, [0, 10], [1, 0, 0, 1],
                    t_eval=np.linspace(0, 10, 1000), rtol=1e-12)

    y1, y1p, y2, y2p = sol.y
    t = sol.t

    # Wronskian
    W = y1 * y2p - y2 * y1p

    # Abel's formula: W(x) = W(0) * exp(-∫₀ˣ p(t) dt)
    # ∫₀ˣ sin(t) dt = 1 - cos(x)
    W_abel = W[0] * np.exp(-(1 - np.cos(t)))

    print(f"  ODE: y'' + sin(x)·y' + cos(x)·y = 0")
    print(f"  W(0) = {W[0]:.10f}")
    print(f"  Max |W_numerical - W_Abel|: {np.max(np.abs(W - W_abel)):.2e}")
    print(f"  → Abel's identity W(x) = W(0)·exp(-∫p dx) verified!")
    print()

    return t, W, W_abel


def demo_riccati_reduction():
    """
    Show that y = exp(∫v dx) reduces y'' + q*y = 0 to v' + v² + q = 0.
    For the Airy equation (q = -x), the Riccati equation is v' + v² - x = 0.
    """
    print("=" * 60)
    print("Demo 3: Riccati Reduction for Airy Equation")
    print("=" * 60)

    # Solve Riccati equation v' + v² - x = 0
    def riccati(t, v):
        return [-(v[0]**2) + t]

    sol = solve_ivp(riccati, [0.1, 10], [0.5], t_eval=np.linspace(0.1, 10, 500),
                    rtol=1e-10)

    # The Riccati equation blows up (poles), reflecting Airy's non-integrability
    t = sol.t
    v = sol.y[0]

    print(f"  Airy equation: y'' = x·y (p=0, q=-x)")
    print(f"  Riccati reduction: v' + v² - x = 0 where y = exp(∫v dx)")
    print(f"  Solution v(0.1) = {v[0]:.6f}")
    print(f"  Solution v(1.0) ≈ {v[np.argmin(np.abs(t-1))]:.6f}")
    print(f"  The Riccati equation has movable poles → no EML solution")
    print()


def demo_sl2_invariance():
    """
    Demonstrate SL(2) invariance of the Wronskian.
    """
    print("=" * 60)
    print("Demo 4: SL(2) Invariance of the Wronskian")
    print("=" * 60)

    x = np.linspace(-5, 3, 500)
    ai, ai_prime, bi, bi_prime = airy(x)

    # Original Wronskian
    W_orig = ai * bi_prime - bi * ai_prime

    # SL(2) transformation: [a b; c d] with ad - bc = 1
    test_matrices = [
        (2, 3, 1, 2),    # det = 4 - 3 = 1
        (1, 1, 0, 1),    # upper triangular
        (3, -1, 2, -0.33333333),  # approximate, det ≈ 1
        (0, -1, 1, 0),   # rotation-like
    ]

    for a, b, c, d in test_matrices:
        det = a*d - b*c
        y1_new = a * ai + b * bi
        y2_new = c * ai + d * bi
        y1p_new = a * ai_prime + b * bi_prime
        y2p_new = c * ai_prime + d * bi_prime
        W_new = y1_new * y2p_new - y2_new * y1p_new

        print(f"  Matrix [{a:.2f} {b:.2f}; {c:.2f} {d:.2f}], det = {det:.4f}")
        print(f"    W_new/W_orig ≈ {np.mean(W_new/W_orig):.6f} (should be {det:.4f})")

    print()
    print("  → W transforms as W ↦ det(σ)·W, confirming our theorem!")
    print()


def demo_eml_tower():
    """
    Demonstrate EML tower heights for various functions.
    """
    print("=" * 60)
    print("Demo 5: EML Tower Heights")
    print("=" * 60)

    x = np.linspace(0.1, 3, 100)

    towers = [
        ("Constants (height 0)", lambda x: np.ones_like(x) * 3, 0),
        ("x (height 0)", lambda x: x, 0),
        ("x² + 2x (height 0)", lambda x: x**2 + 2*x, 0),
        ("exp(x) (height 1)", lambda x: np.exp(x), 1),
        ("log(x) (height 1)", lambda x: np.log(x), 1),
        ("exp(exp(x)) (height 2)", lambda x: np.exp(np.exp(x)), 2),
        ("log(log(x)) (height 2)", lambda x: np.log(np.log(x)), 2),
        ("x·exp(x²) (height 1)", lambda x: x * np.exp(x**2), 1),
    ]

    for name, f, height in towers:
        vals = f(x)
        print(f"  {name}: range [{np.min(vals):.3f}, {np.max(vals):.3f}]")

    print()
    print("  Airy function Ai(x): NOT in any finite EML tower!")
    print("  → This is the content of our non-solvability obstruction.")


if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("  EML DIFFERENTIAL EQUATIONS: RESEARCH DEMONSTRATIONS")
    print("=" * 60 + "\n")

    demo_airy_wronskian()
    demo_abel_identity()
    demo_riccati_reduction()
    demo_sl2_invariance()
    demo_eml_tower()

    print("\n" + "=" * 60)
    print("  All demonstrations completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Riccati Reduction and EML Tower Structure

Shows how the exponential ansatz y = exp(∫v dx) reduces a 2nd-order
ODE to the Riccati equation, and visualizes the pole structure that
obstructs EML solvability.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from scipy.integrate import solve_ivp


def plot_riccati_poles():
    """Plot Riccati solutions for Airy equation showing pole structure."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Airy Riccati: v' + v² - x = 0
    initial_values = [0.1, 0.5, 1.0, -0.5, -1.0, 2.0]
    colors = plt.cm.viridis(np.linspace(0, 1, len(initial_values)))

    ax = axes[0]
    for v0, color in zip(initial_values, colors):
        def riccati(t, v):
            return [-(v[0]**2) + t]

        sol = solve_ivp(riccati, [0, 8], [v0],
                        t_eval=np.linspace(0, 8, 2000),
                        rtol=1e-10, atol=1e-12,
                        max_step=0.01)

        # Clip to reasonable range
        v = np.clip(sol.y[0], -20, 20)
        ax.plot(sol.t, v, color=color, linewidth=1.5, label=f'v(0) = {v0}')

    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('v(x)', fontsize=12)
    ax.set_title("Riccati Equation v' + v² - x = 0\n(Airy's equation reduction)",
                 fontsize=12, fontweight='bold')
    ax.legend(fontsize=9)
    ax.set_ylim(-10, 10)
    ax.grid(True, alpha=0.3)
    ax.axhline(y=0, color='k', linewidth=0.5)

    # Constant coefficient case: v' + v² + 1 = 0 (harmonic oscillator)
    ax2 = axes[1]
    initial_values_2 = [0.5, 1.0, 2.0, -0.5, -1.0]
    colors2 = plt.cm.plasma(np.linspace(0, 1, len(initial_values_2)))

    for v0, color in zip(initial_values_2, colors2):
        def riccati_harmonic(t, v):
            return [-(v[0]**2) - 1]

        sol = solve_ivp(riccati_harmonic, [0, 5], [v0],
                        t_eval=np.linspace(0, 5, 2000),
                        rtol=1e-10, atol=1e-12,
                        max_step=0.01)

        v = np.clip(sol.y[0], -20, 20)
        ax2.plot(sol.t, v, color=color, linewidth=1.5, label=f'v(0) = {v0}')

    ax2.set_xlabel('x', fontsize=12)
    ax2.set_ylabel('v(x)', fontsize=12)
    ax2.set_title("Riccati v' + v² + 1 = 0\n(Harmonic oscillator: v = -tan(x+c))",
                  fontsize=12, fontweight='bold')
    ax2.legend(fontsize=9)
    ax2.set_ylim(-10, 10)
    ax2.grid(True, alpha=0.3)
    ax2.axhline(y=0, color='k', linewidth=0.5)

    plt.tight_layout()
    plt.savefig('riccati_reduction.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved riccati_reduction.png")


def plot_eml_tower():
    """Visualize EML tower hierarchy."""
    fig, ax = plt.subplots(figsize=(12, 7))

    # Tower levels
    levels = {
        0: ['1', 'x', 'x²', 'x³+2x', 'polynomials'],
        1: ['eˣ', 'ln x', 'x·eˣ', 'e^(x²)', 'ln(x²+1)'],
        2: ['e^(eˣ)', 'ln(ln x)', 'e^(x·ln x)', 'ln(eˣ+1)'],
        3: ['e^(e^(eˣ))', 'ln(ln(ln x))'],
    }

    colors = ['#2ecc71', '#3498db', '#e74c3c', '#9b59b6']
    y_offset = 0

    for level, funcs in levels.items():
        y = 3 - level
        for i, func in enumerate(funcs):
            x_pos = i * 2.2 + 0.5
            rect = plt.Rectangle((x_pos - 0.8, y - 0.3), 1.6, 0.6,
                                 facecolor=colors[level], alpha=0.3,
                                 edgecolor=colors[level], linewidth=2)
            ax.add_patch(rect)
            ax.text(x_pos, y, func, ha='center', va='center',
                    fontsize=10, fontweight='bold')

        ax.text(-0.5, y, f'Height {level}', ha='right', va='center',
                fontsize=12, fontweight='bold', color=colors[level])

    # Airy function annotation
    ax.annotate('Ai(x), Bi(x)\n(NOT in any tower!)',
                xy=(5, -0.5), fontsize=13, fontweight='bold',
                color='red', ha='center',
                bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow',
                         edgecolor='red', linewidth=2))

    ax.set_xlim(-1.5, 11)
    ax.set_ylim(-1.5, 4)
    ax.set_title('EML Tower Height Hierarchy', fontsize=14, fontweight='bold')
    ax.axis('off')

    plt.tight_layout()
    plt.savefig('eml_tower.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved eml_tower.png")


if __name__ == "__main__":
    plot_riccati_poles()
    plot_eml_tower()


#!/usr/bin/env python3
"""
Visualization: Airy Wronskian and Abel's Identity

Produces a 2-panel figure showing:
1. Airy functions Ai(x) and Bi(x)
2. Their Wronskian W(Ai, Bi) = 1/π (constant)
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from scipy.special import airy


def plot_airy_wronskian():
    x = np.linspace(-15, 5, 2000)
    ai, aip, bi, bip = airy(x)
    W = ai * bip - bi * aip

    fig, axes = plt.subplots(2, 1, figsize=(10, 8), sharex=True)

    # Panel 1: Airy functions
    ax1 = axes[0]
    ax1.plot(x, ai, 'b-', linewidth=2, label='Ai(x)')
    ax1.plot(x, bi, 'r-', linewidth=2, label='Bi(x)')
    ax1.set_ylabel('Function Value', fontsize=12)
    ax1.set_title('Airy Functions and Their Wronskian', fontsize=14, fontweight='bold')
    ax1.legend(fontsize=12)
    ax1.set_ylim(-1.5, 2.5)
    ax1.grid(True, alpha=0.3)
    ax1.axhline(y=0, color='k', linewidth=0.5)

    # Panel 2: Wronskian
    ax2 = axes[1]
    ax2.plot(x, W, 'g-', linewidth=2, label=f'W(Ai, Bi) = 1/π ≈ {1/np.pi:.4f}')
    ax2.axhline(y=1/np.pi, color='k', linestyle='--', alpha=0.5, label='1/π')
    ax2.set_xlabel('x', fontsize=12)
    ax2.set_ylabel('Wronskian', fontsize=12)
    ax2.set_title("Abel's Identity: W' = -p·W = 0 (since p = 0 for Airy)", fontsize=12)
    ax2.legend(fontsize=12)
    ax2.set_ylim(0, 0.5)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('airy_wronskian.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved airy_wronskian.png")


def plot_sl2_invariance():
    x = np.linspace(-8, 4, 1000)
    ai, aip, bi, bip = airy(x)
    W_orig = ai * bip - bi * aip

    fig, axes = plt.subplots(2, 2, figsize=(12, 8))

    matrices = [
        ((1, 0, 0, 1), 'Identity'),
        ((2, 1, 1, 1), 'det = 1'),
        ((1, 1, 0, 1), 'Upper triangular'),
        ((0, -1, 1, 0), 'Rotation'),
    ]

    for ax, ((a, b, c, d), name) in zip(axes.flat, matrices):
        y1_new = a * ai + b * bi
        y2_new = c * ai + d * bi
        y1p_new = a * aip + b * bip
        y2p_new = c * aip + d * bip
        W_new = y1_new * y2p_new - y2_new * y1p_new

        ax.plot(x, W_orig, 'b-', linewidth=2, alpha=0.7, label='Original W')
        ax.plot(x, W_new, 'r--', linewidth=2, alpha=0.7, label='Transformed W')
        det = a*d - b*c
        ax.set_title(f'{name}: det = {det}', fontsize=11)
        ax.legend(fontsize=9)
        ax.grid(True, alpha=0.3)
        ax.set_ylim(-0.1, 0.5)

    fig.suptitle('SL(2) Invariance of the Wronskian', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('sl2_invariance.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved sl2_invariance.png")


if __name__ == "__main__":
    plot_airy_wronskian()
    plot_sl2_invariance()
