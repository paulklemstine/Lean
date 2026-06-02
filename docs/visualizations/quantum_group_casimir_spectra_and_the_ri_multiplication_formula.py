#!/usr/bin/env python3
"""
Visualization: q-Integer Multiplication Formula Verification

Demonstrates the identity [nm]_q = [n]_q * [m]_{q^n} visually,
showing how this multiplicative structure mirrors the Euler product.
"""

import math


def q_integer(q, n):
    if n == 0:
        return 0.0
    if abs(q - 1.0) < 1e-15:
        return float(n)
    return (q**n - 1.0) / (q - 1.0)


def main():
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
        import numpy as np
    except ImportError:
        print("matplotlib/numpy not available")
        return

    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    # Panel 1: [nm]_q vs [n]_q * [m]_{q^n} for various n, m
    ax = axes[0]
    q = 1.5
    pairs = [(n, m) for n in range(1, 8) for m in range(1, 8)]
    lhs_vals = [q_integer(q, n * m) for n, m in pairs]
    rhs_vals = [q_integer(q, n) * q_integer(q**n, m) for n, m in pairs]
    ax.scatter(lhs_vals, rhs_vals, c='#E91E63', alpha=0.6, s=30)
    max_val = max(max(lhs_vals), max(rhs_vals))
    ax.plot([0, max_val], [0, max_val], 'k--', linewidth=1, alpha=0.5)
    ax.set_xlabel('[nm]_q')
    ax.set_ylabel('[n]_q · [m]_{q^n}')
    ax.set_title(f'Multiplication Formula (q={q})')
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)

    # Panel 2: Relative error as function of q
    ax = axes[1]
    q_range = [1.0 + 0.1 * i for i in range(1, 30)]
    n, m = 5, 7
    errors = []
    for q in q_range:
        lhs = q_integer(q, n * m)
        rhs = q_integer(q, n) * q_integer(q**n, m)
        err = abs(lhs - rhs) / max(abs(lhs), 1e-15)
        errors.append(err)
    ax.semilogy(q_range, [max(e, 1e-16) for e in errors], 'o-', color='#2196F3', markersize=3)
    ax.set_xlabel('q')
    ax.set_ylabel('Relative error')
    ax.set_title(f'[{n}·{m}]_q = [{n}]_q·[{m}]_{{q^{n}}} verification')
    ax.axhline(y=1e-12, color='gray', linestyle='--', alpha=0.5, label='machine epsilon')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Panel 3: q-integer as function of q for fixed n
    ax = axes[2]
    q_range = np.linspace(0.1, 3.0, 200)
    for n in [2, 3, 5, 7]:
        vals = [q_integer(q, n) for q in q_range]
        ax.plot(q_range, vals, linewidth=2, label=f'[{n}]_q')
    ax.axvline(x=1.0, color='gray', linestyle='--', alpha=0.5)
    ax.set_xlabel('q')
    ax.set_ylabel('[n]_q')
    ax.set_title('q-Integers as functions of q')
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.suptitle('q-Integer Multiplicative Structure', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('multiplication_formula.png', dpi=150, bbox_inches='tight')
    print("Saved multiplication_formula.png")


if __name__ == "__main__":
    main()
