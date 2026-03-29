#!/usr/bin/env python3
"""
Birch and Swinnerton-Dyer Conjecture — Visual Demonstration

Visualizes:
1. Elliptic curves and their group structure
2. Point counting and L-functions
3. The BSD prediction: rank = order of vanishing of L(E,s) at s=1

Run: python demo_05_bsd.py
"""

import numpy as np
import matplotlib.pyplot as plt
from sympy import isprime, sqrt as sym_sqrt


def plot_elliptic_curves():
    """Visualize different elliptic curves and their rational points."""
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))

    # Panel 1: Several elliptic curves
    ax = axes[0]
    x = np.linspace(-3, 5, 1000)

    curves = [
        (-1, 0, 'y² = x³ - x', 'blue'),
        (0, -2, 'y² = x³ - 2', 'red'),
        (-1, 1, 'y² = x³ - x + 1', 'green'),
    ]

    for a, b, label, color in curves:
        for x_val in x:
            rhs = x_val**3 + a * x_val + b
            if rhs >= 0:
                y_val = np.sqrt(rhs)
                ax.plot(x_val, y_val, '.', color=color, markersize=0.5)
                ax.plot(x_val, -y_val, '.', color=color, markersize=0.5)
        ax.plot([], [], '-', color=color, linewidth=2, label=label)

    ax.set_xlim(-3, 5)
    ax.set_ylim(-6, 6)
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('y', fontsize=12)
    ax.set_title('Elliptic Curves over ℝ\ny² = x³ + ax + b',
                fontsize=12, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_aspect('equal')

    # Panel 2: The group law — geometric addition
    ax = axes[1]
    a, b = -1, 1  # y² = x³ - x + 1

    x_vals = np.linspace(-1.5, 3, 1000)
    for x_val in x_vals:
        rhs = x_val**3 + a * x_val + b
        if rhs >= 0:
            y_val = np.sqrt(rhs)
            ax.plot(x_val, y_val, 'b.', markersize=0.5)
            ax.plot(x_val, -y_val, 'b.', markersize=0.5)

    # Two points P and Q
    P = (0, 1)
    Q = (1, 1)

    # Line through P and Q
    slope = (Q[1] - P[1]) / (Q[0] - P[0])
    intercept = P[1] - slope * P[0]

    # Third intersection: solve x³ - x + 1 = (slope*x + intercept)²
    # x³ - slope²x² + (a - 2*slope*intercept)x + (b - intercept²) = 0
    # Roots: x_P, x_Q, x_R
    x_R = slope**2 - P[0] - Q[0]  # Vieta's formula
    y_R = slope * x_R + intercept
    R = (x_R, y_R)
    P_plus_Q = (x_R, -y_R)

    # Draw the line
    x_line = np.linspace(-1.5, 3, 100)
    y_line = slope * x_line + intercept
    ax.plot(x_line, y_line, 'r--', linewidth=1.5, alpha=0.7)

    # Draw the reflection
    ax.plot([R[0], P_plus_Q[0]], [R[1], P_plus_Q[1]], 'g--', linewidth=1.5, alpha=0.7)

    # Mark points
    ax.plot(*P, 'ro', markersize=12, zorder=5)
    ax.plot(*Q, 'go', markersize=12, zorder=5)
    ax.plot(*R, 'ko', markersize=8, zorder=5)
    ax.plot(*P_plus_Q, 'mo', markersize=12, zorder=5)

    ax.annotate('P', xy=P, xytext=(P[0]-0.4, P[1]+0.3), fontsize=14, fontweight='bold', color='red')
    ax.annotate('Q', xy=Q, xytext=(Q[0]+0.2, Q[1]+0.3), fontsize=14, fontweight='bold', color='green')
    ax.annotate('P+Q', xy=P_plus_Q, xytext=(P_plus_Q[0]+0.2, P_plus_Q[1]-0.5),
               fontsize=14, fontweight='bold', color='purple')

    ax.set_xlim(-1.5, 3)
    ax.set_ylim(-4, 4)
    ax.set_title('The Group Law on E\nP + Q via secant-and-reflect',
                fontsize=12, fontweight='bold')
    ax.set_xlabel('x')
    ax.set_ylabel('y')
    ax.grid(True, alpha=0.3)

    # Panel 3: Point counting mod p
    ax = axes[2]
    primes = [p for p in range(2, 100) if isprime(p)]
    a_p_list = []

    a_curve, b_curve = 0, -1  # y² = x³ - 1 (rank 0)

    for p in primes:
        if p == 2 or p == 3:
            a_p_list.append(0)
            continue
        count = 0
        for x_val in range(p):
            rhs = (x_val**3 + a_curve * x_val + b_curve) % p
            for y_val in range(p):
                if (y_val**2) % p == rhs:
                    count += 1
        # Add point at infinity
        N_p = count + 1
        a_p = p - N_p
        a_p_list.append(a_p)

    ax.bar(range(len(primes)), a_p_list, color='steelblue', alpha=0.7)
    ax.axhline(y=0, color='red', linewidth=1)

    # Hasse bound
    hasse = [2 * np.sqrt(p) for p in primes]
    ax.plot(range(len(primes)), hasse, 'r--', linewidth=1.5, label='Hasse bound: 2√p')
    ax.plot(range(len(primes)), [-h for h in hasse], 'r--', linewidth=1.5)

    ax.set_xlabel('Prime index', fontsize=12)
    ax.set_ylabel('aₚ = p - Nₚ', fontsize=12)
    ax.set_title('Point Counting: aₚ for y² = x³ - 1\n|aₚ| ≤ 2√p (Hasse bound)',
                fontsize=12, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('demo_05_bsd.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved demo_05_bsd.png")


def plot_l_function():
    """Approximate and visualize the L-function of an elliptic curve."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Compute L-function for y² = x³ - x (rank 0, conductor 32)
    # and y² + y = x³ - x (rank 1, conductor 37)

    def compute_a_p(a, b, p):
        """Count points on y² = x³ + ax + b mod p."""
        if p <= 3:
            return 0
        count = 0
        for x in range(p):
            rhs = (x**3 + a * x + b) % p
            for y in range(p):
                if (y**2) % p == rhs:
                    count += 1
        return p - (count + 1)

    primes = [p for p in range(2, 200) if isprime(p)]

    # Panel 1: Partial L-function products
    ax = axes[0]

    for a_coeff, b_coeff, label, color in [(-1, 0, 'y²=x³-x (rank 0)', 'blue'),
                                             (-1, 1, 'y²+y=x³-x (rank 1)', 'red')]:
        # Compute partial Euler product at s = 1
        s_values = np.linspace(0.5, 3, 100)
        L_approx = []

        a_p_vals = {}
        for p in primes:
            a_p_vals[p] = compute_a_p(a_coeff, b_coeff, p)

        for s in s_values:
            prod = 1.0
            for p in primes[:30]:  # use first 30 primes
                if p <= 3:
                    continue
                ap = a_p_vals[p]
                factor = 1 - ap * p**(-s) + p**(1 - 2*s)
                if abs(factor) > 1e-10:
                    prod /= factor
            L_approx.append(prod)

        ax.plot(s_values, L_approx, color=color, linewidth=2, label=label)

    ax.axvline(x=1, color='gray', linestyle='--', linewidth=1.5, label='s = 1')
    ax.axhline(y=0, color='gray', linewidth=0.5)
    ax.set_xlabel('s', fontsize=12)
    ax.set_ylabel('L(E, s) (partial product)', fontsize=12)
    ax.set_title('L-functions of Elliptic Curves\nBSD: rank = ord_{s=1} L(E,s)',
                fontsize=12, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(0.5, 3)
    ax.set_ylim(-1, 5)

    # Panel 2: BSD in pictures
    ax = axes[1]

    ranks = [0, 1, 2, 3]
    examples = [
        'y² = x³ - x\nL(E,1) ≈ 0.66\nFinitely many pts',
        'y² + y = x³ - x\nL(E,1) = 0, L\'(E,1) ≠ 0\nInfinitely many pts',
        'y² = x³ - 5x + 4\nL vanishes to order 2\n(conjectured)',
        'y² = x³ + ...\nL vanishes to order 3\n(conjectured)',
    ]
    colors = ['#2ecc71', '#3498db', '#e67e22', '#e74c3c']
    status = ['PROVED ✓', 'PROVED ✓', 'OPEN ✗', 'OPEN ✗']

    bars = ax.barh(ranks, [1, 1, 0.5, 0.3], color=colors, edgecolor='black', linewidth=1.5)

    for i, (rank, example, stat) in enumerate(zip(ranks, examples, status)):
        ax.text(1.1, rank, f'Rank {rank}: {stat}\n{example}',
               fontsize=9, va='center', fontfamily='monospace')

    ax.set_xlabel('Verification Status', fontsize=12)
    ax.set_ylabel('Rank', fontsize=12)
    ax.set_title('BSD Conjecture Status by Rank\nRanks 0,1: Proved (Gross-Zagier-Kolyvagin)',
                fontsize=12, fontweight='bold')
    ax.set_xlim(0, 4)
    ax.set_yticks(ranks)
    ax.grid(True, alpha=0.3, axis='x')

    plt.tight_layout()
    plt.savefig('demo_05b_bsd_l_function.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved demo_05b_bsd_l_function.png")


if __name__ == '__main__':
    print("=" * 60)
    print("Birch and Swinnerton-Dyer — Visual Demonstrations")
    print("=" * 60)
    print("\n1. Generating elliptic curve visualizations...")
    plot_elliptic_curves()
    print("\n2. Generating L-function analysis...")
    plot_l_function()
    print("\nDone! Check the generated PNG files.")
