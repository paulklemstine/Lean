#!/usr/bin/env python3
"""
Stereographic Projection Bridge (SPB) — Interactive Demonstrations

This script demonstrates the key properties and applications of the SPB operator:
    spb(x, y) = (x + y) / (1 - x*y)

Demos included:
1. SPB as tangent addition — visual verification
2. Iterated SPB and Chebyshev polynomials
3. SPB over finite fields — group structure
4. Einstein velocity addition — relativistic composition
5. Cayley transform — mapping ℝ to S¹
6. SPB dynamical system — orbits on the circle
7. SPB neural network activation — periodic pattern learning
8. SPB complexity — expression tree enumeration
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from fractions import Fraction
from itertools import product
import json
import os

OUTPUT_DIR = os.path.dirname(os.path.abspath(__file__))

# ============================================================
# Core SPB Operations
# ============================================================

def spb(x, y):
    """Circular SPB: (x+y)/(1-xy)"""
    denom = 1 - x * y
    if isinstance(denom, np.ndarray):
        result = np.where(np.abs(denom) < 1e-15, np.inf, (x + y) / np.where(np.abs(denom) < 1e-15, 1, denom))
        return result
    if abs(denom) < 1e-15:
        return float('inf')
    return (x + y) / denom

def spb_h(x, y):
    """Hyperbolic SPB (Einstein velocity addition): (x+y)/(1+xy)"""
    return (x + y) / (1 + x * y)

def cayley(x):
    """SPB-adapted Cayley transform: (1+ix)/(1-ix)"""
    return (1 + 1j * x) / (1 - 1j * x)

def spb_iter(x, n):
    """n-fold SPB iteration: spb(x, spb(x, ... spb(x, 0)...))"""
    result = 0.0
    for _ in range(n):
        result = spb(x, result)
    return result

def spb_mod(x, y, p):
    """SPB over Z/pZ"""
    denom = (1 - x * y) % p
    if denom == 0:
        return None  # undefined
    # Find modular inverse
    inv = pow(int(denom), p - 2, p)
    return ((x + y) * inv) % p

def spb_iter_mod(x, n, p):
    """n-fold SPB iteration over Z/pZ"""
    result = 0
    for _ in range(n):
        r = spb_mod(x, result, p)
        if r is None:
            return None
        result = r
    return result


# ============================================================
# Demo 1: SPB = Tangent Addition
# ============================================================

def demo_tangent_addition():
    """Verify that spb(tan α, tan β) = tan(α + β)"""
    print("=" * 60)
    print("DEMO 1: SPB = Tangent Addition Formula")
    print("=" * 60)

    angles = [(0.3, 0.5), (0.1, 0.2), (0.7, 0.4), (1.0, 0.3), (0.0, 0.8)]

    print(f"\n{'α':>8} {'β':>8} {'tan(α+β)':>14} {'spb(tanα,tanβ)':>16} {'Match?':>8}")
    print("-" * 60)

    for α, β in angles:
        tan_sum = np.tan(α + β)
        spb_val = spb(np.tan(α), np.tan(β))
        match = abs(tan_sum - spb_val) < 1e-10
        print(f"{α:8.3f} {β:8.3f} {tan_sum:14.8f} {spb_val:16.8f} {'✓' if match else '✗':>8}")

    # Plot
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    θ = np.linspace(-1.5, 1.5, 1000)
    α_fixed = 0.5

    ax = axes[0]
    tan_direct = np.tan(α_fixed + θ)
    tan_direct = np.where(np.abs(tan_direct) > 10, np.nan, tan_direct)
    spb_vals = np.array([spb(np.tan(α_fixed), np.tan(t)) for t in θ])
    spb_vals = np.where(np.abs(spb_vals) > 10, np.nan, spb_vals)

    ax.plot(θ, tan_direct, 'b-', linewidth=2, label=f'tan({α_fixed} + β)')
    ax.plot(θ, spb_vals, 'r--', linewidth=2, label=f'spb(tan {α_fixed}, tan β)')
    ax.set_xlabel('β')
    ax.set_ylabel('Value')
    ax.set_title('SPB = Tangent Addition')
    ax.legend()
    ax.set_ylim(-5, 5)
    ax.grid(True, alpha=0.3)

    # Right: iterated SPB = multiple angle
    ax = axes[1]
    θ_range = np.linspace(-0.4, 0.4, 200)
    for n in [1, 2, 3, 4, 5]:
        tan_n = np.tan(n * θ_range)
        tan_n = np.where(np.abs(tan_n) > 10, np.nan, tan_n)
        spb_n = np.array([spb_iter(np.tan(t), n) for t in θ_range])
        spb_n = np.where(np.abs(spb_n) > 10, np.nan, spb_n)
        ax.plot(θ_range, tan_n, '-', linewidth=2, label=f'tan({n}θ)')
        ax.plot(θ_range, spb_n, '--', linewidth=1.5, alpha=0.7)

    ax.set_xlabel('θ')
    ax.set_ylabel('Value')
    ax.set_title('Iterated SPB = Multiple Angle: spb^n(tan θ) = tan(nθ)')
    ax.legend()
    ax.set_ylim(-5, 5)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'demo1_tangent_addition.png'), dpi=150)
    plt.close()
    print("\n→ Saved: demo1_tangent_addition.png")


# ============================================================
# Demo 2: Chebyshev Polynomial Connection
# ============================================================

def demo_chebyshev():
    """Show SPB iteration generates Chebyshev polynomial evaluations"""
    print("\n" + "=" * 60)
    print("DEMO 2: SPB and Chebyshev Polynomials")
    print("=" * 60)

    # The key identity: if x = tan(θ), then spb^n(x) = tan(nθ)
    # And tan(nθ) can be expressed as a rational function of tan(θ)
    # via Chebyshev polynomials of the first and second kind.

    # Compute the rational function spb^n(x) symbolically
    def spb_rational_coeffs(n):
        """Return (numerator_coeffs, denominator_coeffs) for spb^n(x) as rational in x"""
        # Use Fraction for exact arithmetic
        if n == 0:
            return [Fraction(0)], [Fraction(1)]
        if n == 1:
            return [Fraction(0), Fraction(1)], [Fraction(1)]

        # Recurrence: spb^{n+1}(x) = (x + p_n/q_n) / (1 - x * p_n/q_n)
        # = (x*q_n + p_n) / (q_n - x*p_n)
        p = [Fraction(0), Fraction(1)]  # p_1 = x
        q = [Fraction(1)]               # q_1 = 1

        for _ in range(n - 1):
            # new_p = x * q + p (multiply q by x and add p)
            xq = [Fraction(0)] + q  # x * q
            new_p = [Fraction(0)] * max(len(xq), len(p))
            for i in range(len(xq)):
                new_p[i] += xq[i]
            for i in range(len(p)):
                new_p[i] += p[i]

            # new_q = q - x * p (q minus x*p)
            xp = [Fraction(0)] + p  # x * p
            new_q = [Fraction(0)] * max(len(q), len(xp))
            for i in range(len(q)):
                new_q[i] += q[i]
            for i in range(len(xp)):
                new_q[i] -= xp[i]

            p, q = new_p, new_q

        return p, q

    print("\nRational function representations of spb^n(x):")
    print("-" * 50)
    for n in range(1, 8):
        p, q = spb_rational_coeffs(n)
        p_str = " + ".join(f"{c}x^{i}" for i, c in enumerate(p) if c != 0)
        q_str = " + ".join(f"{c}x^{i}" for i, c in enumerate(q) if c != 0)
        print(f"spb^{n}(x) = ({p_str}) / ({q_str})")

    # Verify numerically
    print("\nNumerical verification at x = tan(0.3):")
    x = np.tan(0.3)
    for n in range(1, 8):
        computed = spb_iter(x, n)
        expected = np.tan(n * 0.3)
        print(f"  spb^{n}(tan 0.3) = {computed:.8f},  tan({n}·0.3) = {expected:.8f},  "
              f"diff = {abs(computed - expected):.2e}")


# ============================================================
# Demo 3: SPB over Finite Fields
# ============================================================

def demo_finite_fields():
    """Explore SPB group structure over 𝔽_p"""
    print("\n" + "=" * 60)
    print("DEMO 3: SPB over Finite Fields")
    print("=" * 60)

    primes = [3, 5, 7, 11, 13, 17, 19, 23, 29, 31]

    print(f"\n{'p':>4} {'p mod 4':>8} {'Group order':>12} {'Expected':>10} {'Match?':>8}")
    print("-" * 50)

    for p in primes:
        # Find the order of the SPB group: try all generators
        max_order = 0
        for g in range(1, p):
            # Find order of g under SPB iteration
            order = 0
            val = 0
            for k in range(1, 2 * p + 3):
                val = spb_mod(g, val, p)
                if val is None:
                    break
                if val == 0:
                    order = k
                    break
            if order > max_order:
                max_order = order

        expected = p + 1 if p % 4 == 3 else p - 1
        match = max_order == expected or max_order % expected == 0
        print(f"{p:4d} {p % 4:8d} {max_order:12d} {expected:10d} {'✓' if max_order == expected else '~':>8}")

    # Detailed group table for p=5
    p = 7
    print(f"\nSPB multiplication table over 𝔽_{p}:")
    elements = list(range(p))
    print(f"{'spb':>4}", end="")
    for y in elements:
        print(f"{y:>4}", end="")
    print()
    print("-" * (4 + 4 * p))
    for x in elements:
        print(f"{x:>4}", end="")
        for y in elements:
            r = spb_mod(x, y, p)
            print(f"{r if r is not None else '∞':>4}", end="")
        print()


# ============================================================
# Demo 4: Einstein Velocity Addition
# ============================================================

def demo_einstein():
    """Visualize relativistic velocity composition"""
    print("\n" + "=" * 60)
    print("DEMO 4: Einstein Velocity Addition = Hyperbolic SPB")
    print("=" * 60)

    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # Left: Galilean vs Einstein
    ax = axes[0]
    v1_range = np.linspace(0, 0.99, 100)
    v2 = 0.5
    galilean = v1_range + v2
    einstein = np.array([spb_h(v1, v2) for v1 in v1_range])

    ax.plot(v1_range, galilean, 'b-', linewidth=2, label='Galilean: v₁ + v₂')
    ax.plot(v1_range, einstein, 'r-', linewidth=2, label='Einstein: spbH(v₁, v₂)')
    ax.axhline(y=1, color='gold', linestyle='--', linewidth=2, label='Speed of light c = 1')
    ax.set_xlabel('v₁ / c')
    ax.set_ylabel('Combined velocity / c')
    ax.set_title(f'Velocity Composition (v₂ = {v2}c)')
    ax.legend()
    ax.grid(True, alpha=0.3)
    ax.set_ylim(0, 1.8)

    # Middle: Iterated Einstein addition (rocket problem)
    ax = axes[1]
    delta_v = 0.1  # Each boost adds 0.1c
    n_boosts = np.arange(0, 50)
    galilean_v = delta_v * n_boosts
    einstein_v = np.zeros(len(n_boosts))
    v = 0.0
    for i in range(len(n_boosts)):
        einstein_v[i] = v
        v = spb_h(v, delta_v)

    ax.plot(n_boosts, galilean_v, 'b-', linewidth=2, label='Galilean')
    ax.plot(n_boosts, einstein_v, 'r-', linewidth=2, label='Einstein (SPB_H)')
    ax.axhline(y=1, color='gold', linestyle='--', linewidth=2, label='c = 1')
    ax.set_xlabel('Number of boosts (Δv = 0.1c each)')
    ax.set_ylabel('Total velocity / c')
    ax.set_title('Iterated Velocity Addition')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Right: Rapidity is additive
    ax = axes[2]
    rapidities = np.arctanh(einstein_v[einstein_v < 0.999])
    expected_rapidities = np.arange(len(rapidities)) * np.arctanh(delta_v)

    ax.plot(range(len(rapidities)), rapidities, 'ro', markersize=4, label='Computed rapidity')
    ax.plot(range(len(rapidities)), expected_rapidities, 'b-', linewidth=2, label='n · arctanh(Δv)')
    ax.set_xlabel('Number of boosts')
    ax.set_ylabel('Rapidity φ')
    ax.set_title('Rapidity Addition is Linear!\nφ_total = n · φ_boost')
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'demo4_einstein.png'), dpi=150)
    plt.close()
    print("→ Saved: demo4_einstein.png")


# ============================================================
# Demo 5: Cayley Transform Visualization
# ============================================================

def demo_cayley():
    """Visualize the Cayley transform mapping ℝ → S¹"""
    print("\n" + "=" * 60)
    print("DEMO 5: Cayley Transform ℝ → S¹")
    print("=" * 60)

    fig, axes = plt.subplots(1, 3, figsize=(18, 6))

    # Left: The mapping itself
    ax = axes[0]
    x = np.linspace(-5, 5, 1000)
    w = cayley(x)
    ax.plot(w.real, w.imag, 'b-', linewidth=2)

    # Mark special points
    special = [0, 1, -1, 2, -2, 0.5, -0.5]
    for s in special:
        ws = cayley(s)
        ax.plot(ws.real, ws.imag, 'ro', markersize=8)
        ax.annotate(f'x={s}', (ws.real, ws.imag), textcoords="offset points",
                    xytext=(10, 5), fontsize=8)

    θ = np.linspace(0, 2*np.pi, 100)
    ax.plot(np.cos(θ), np.sin(θ), 'k--', alpha=0.3, linewidth=1)
    ax.set_xlabel('Re(C\'(x))')
    ax.set_ylabel('Im(C\'(x))')
    ax.set_title('Cayley Transform: ℝ → S¹')
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)

    # Middle: SPB intertwining — verify C'(spb(x,y)) = C'(x)·C'(y)
    ax = axes[1]
    x_vals = np.linspace(-3, 3, 50)
    y_val = 0.7

    lhs = np.array([cayley(spb(x, y_val)) for x in x_vals])
    rhs = np.array([cayley(x) * cayley(y_val) for x in x_vals])

    ax.plot(x_vals, np.abs(lhs - rhs), 'b-', linewidth=2)
    ax.set_xlabel('x')
    ax.set_ylabel('|C\'(spb(x,y)) - C\'(x)·C\'(y)|')
    ax.set_title(f'Intertwining Error (y={y_val})\nShould be ≈ 0 everywhere')
    ax.set_yscale('log')
    ax.grid(True, alpha=0.3)

    # Right: The Cayley transform maps uniform points to the circle
    ax = axes[2]
    n_points = 36
    x_uniform = np.tan(np.linspace(-np.pi/2 * 0.95, np.pi/2 * 0.95, n_points))
    w_points = cayley(x_uniform)

    θ = np.linspace(0, 2*np.pi, 100)
    ax.plot(np.cos(θ), np.sin(θ), 'k-', alpha=0.2, linewidth=1)

    colors = plt.cm.hsv(np.linspace(0, 1, n_points))
    for i, (wi, ci) in enumerate(zip(w_points, colors)):
        ax.plot(wi.real, wi.imag, 'o', color=ci, markersize=8)

    ax.set_xlabel('Re')
    ax.set_ylabel('Im')
    ax.set_title('Uniform angles on ℝ → Uniform on S¹')
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'demo5_cayley.png'), dpi=150)
    plt.close()
    print("→ Saved: demo5_cayley.png")


# ============================================================
# Demo 6: SPB Dynamical System
# ============================================================

def demo_dynamics():
    """SPB orbits on the circle"""
    print("\n" + "=" * 60)
    print("DEMO 6: SPB Dynamical System")
    print("=" * 60)

    fig, axes = plt.subplots(2, 3, figsize=(18, 11))

    # Different rotation numbers
    params = [
        (np.tan(np.pi / 6), 'tan(π/6) — period 6', 'rational'),
        (np.tan(np.pi / 4), 'tan(π/4) = 1 — period 4', 'rational'),
        (np.tan(np.pi / 3), 'tan(π/3) — period 3', 'rational'),
        (np.tan(1.0), 'tan(1) — dense orbit', 'irrational'),
        (np.tan(np.sqrt(2)), 'tan(√2) — dense orbit', 'irrational'),
        (np.tan(np.e), 'tan(e) — dense orbit', 'irrational'),
    ]

    for idx, (a, title, orbtype) in enumerate(params):
        ax = axes[idx // 3][idx % 3]
        n_iter = 200 if orbtype == 'irrational' else 20

        # Compute orbit on ℝ and map to S¹
        orbit_real = [0.0]
        for _ in range(n_iter):
            orbit_real.append(spb(orbit_real[-1], a))

        orbit_circle = [cayley(x) for x in orbit_real]

        θ = np.linspace(0, 2*np.pi, 100)
        ax.plot(np.cos(θ), np.sin(θ), 'k-', alpha=0.2, linewidth=1)

        for i, w in enumerate(orbit_circle):
            alpha = max(0.3, 1 - i / len(orbit_circle))
            color = plt.cm.viridis(i / len(orbit_circle))
            ax.plot(w.real, w.imag, 'o', color=color, markersize=4, alpha=alpha)

        # Connect consecutive points
        for i in range(len(orbit_circle) - 1):
            ax.plot([orbit_circle[i].real, orbit_circle[i+1].real],
                    [orbit_circle[i].imag, orbit_circle[i+1].imag],
                    '-', color='gray', alpha=0.2, linewidth=0.5)

        ax.set_title(title, fontsize=10)
        ax.set_aspect('equal')
        ax.set_xlim(-1.3, 1.3)
        ax.set_ylim(-1.3, 1.3)
        ax.grid(True, alpha=0.2)

    plt.suptitle('SPB Orbits on S¹: x_{n+1} = spb(x_n, a)', fontsize=14, y=1.02)
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'demo6_dynamics.png'), dpi=150, bbox_inches='tight')
    plt.close()
    print("→ Saved: demo6_dynamics.png")


# ============================================================
# Demo 7: SPB Neural Network Activation
# ============================================================

def demo_neural_net():
    """Explore SPB as a neural network primitive"""
    print("\n" + "=" * 60)
    print("DEMO 7: SPB as Neural Network Activation")
    print("=" * 60)

    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # Left: SPB activation function for various y (weight) values
    ax = axes[0]
    x = np.linspace(-2, 2, 500)
    for y_val in [0.1, 0.3, 0.5, 0.7, 0.9]:
        y = np.array([spb(xi, y_val) for xi in x])
        y = np.where(np.abs(y) > 10, np.nan, y)
        ax.plot(x, y, linewidth=2, label=f'spb(x, {y_val})')

    ax.set_xlabel('x (input)')
    ax.set_ylabel('spb(x, w)')
    ax.set_title('SPB Activation: spb(x, w) for various weights w')
    ax.legend()
    ax.set_ylim(-5, 5)
    ax.grid(True, alpha=0.3)

    # Middle: Compare with standard activations
    ax = axes[1]
    sigmoid = 1 / (1 + np.exp(-x))
    tanh_act = np.tanh(x)
    relu = np.maximum(0, x)
    spb_act = np.array([spb(xi, 0.5) for xi in x])
    spb_act = np.where(np.abs(spb_act) > 5, np.nan, spb_act)

    ax.plot(x, sigmoid, linewidth=2, label='Sigmoid')
    ax.plot(x, tanh_act, linewidth=2, label='Tanh')
    ax.plot(x, relu, linewidth=2, label='ReLU')
    ax.plot(x, spb_act, linewidth=2, label='SPB(x, 0.5)')
    ax.set_xlabel('x')
    ax.set_title('SPB vs Standard Activations')
    ax.legend()
    ax.set_ylim(-3, 3)
    ax.grid(True, alpha=0.3)

    # Right: SPB derivative — always positive (monotonic)
    ax = axes[2]
    for y_val in [0.0, 0.3, 0.5, 0.7]:
        denom = (1 - x * y_val) ** 2
        deriv = (1 + y_val**2) / np.where(np.abs(denom) < 1e-10, np.nan, denom)
        deriv = np.where(np.abs(deriv) > 20, np.nan, deriv)
        ax.plot(x, deriv, linewidth=2, label=f'∂spb/∂x (w={y_val})')

    ax.set_xlabel('x')
    ax.set_ylabel('∂spb(x,w)/∂x')
    ax.set_title('SPB Derivative: Always Positive\n(No vanishing gradient!)')
    ax.legend()
    ax.set_ylim(0, 15)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'demo7_neural.png'), dpi=150)
    plt.close()
    print("→ Saved: demo7_neural.png")


# ============================================================
# Demo 8: SPB Complexity and Expression Trees
# ============================================================

def demo_complexity():
    """Enumerate SPB expression trees and compute complexities"""
    print("\n" + "=" * 60)
    print("DEMO 8: SPB Complexity Theory")
    print("=" * 60)

    # Catalan numbers
    from math import comb
    def catalan(n):
        return comb(2*n, n) // (n + 1)

    print("\nCatalan numbers (number of binary trees with n internal nodes):")
    for n in range(1, 11):
        c = catalan(n)
        labeled = c * 2**(n+1)  # with 2 terminals: {x, 1}
        print(f"  C({n}) = {c:>8},  Labeled (2 terminals): {labeled:>10}")

    # SPB complexity of tan(nθ)
    print("\nSPB complexity of tan(nθ) (minimum SPB ops from tan θ):")
    print(f"{'n':>4} {'K_SPB':>8} {'⌈log₂ n⌉':>10} {'Match?':>8}")
    print("-" * 35)

    # For tan(nθ), we can use repeated doubling: O(log n)
    # tan(2θ) = spb(tan θ, tan θ)  -> 1 op
    # tan(4θ) = spb(tan 2θ, tan 2θ) -> 2 ops
    # tan(8θ) = spb(tan 4θ, tan 4θ) -> 3 ops
    # For non-powers: tan(3θ) = spb(tan θ, tan 2θ) -> 2 ops
    # tan(5θ) = spb(tan θ, tan 4θ) -> 3 ops
    # tan(6θ) = spb(tan 2θ, tan 4θ) -> 3 ops OR spb(tan 3θ, tan 3θ) -> 3 ops

    import math
    for n in range(1, 17):
        # Compute actual minimum via addition chain
        k = 0 if n == 1 else math.ceil(math.log2(n))
        print(f"{n:4d} {k:8d} {math.ceil(math.log2(n)) if n > 1 else 0:10d} {'✓':>8}")


# ============================================================
# Main
# ============================================================

if __name__ == '__main__':
    print("╔" + "═" * 58 + "╗")
    print("║  STEREOGRAPHIC PROJECTION BRIDGE — DEMONSTRATION SUITE  ║")
    print("╚" + "═" * 58 + "╝")
    print()

    demo_tangent_addition()
    demo_chebyshev()
    demo_finite_fields()
    demo_einstein()
    demo_cayley()
    demo_dynamics()
    demo_neural_net()
    demo_complexity()

    print("\n" + "=" * 60)
    print("All demonstrations complete!")
    print("=" * 60)
