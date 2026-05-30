#!/usr/bin/env python3
"""
Visualization: Summand Polynomial — The Cross-Domain Bridge

This script visualizes the summand polynomial for various quantum tensor
expressions. The key insight: evaluating this polynomial at x=1 recovers
the summand count (a combinatorial invariant), while the full polynomial
shape encodes the circuit's algebraic structure.

The polynomial is the formal bridge between commutative algebra and
quantum information theory, proved as Theorem summandPoly_eval_one.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib

matplotlib.rcParams['font.size'] = 12

# ============================================================
# Self-contained expression types and polynomial computation
# ============================================================

class Gate:
    def __init__(self, idx):
        self.idx = idx
    def __repr__(self): return f"G{self.idx}"

class Seq:
    def __init__(self, left, right):
        self.left, self.right = left, right
    def __repr__(self): return f"({self.left};{self.right})"

class Par:
    def __init__(self, left, right):
        self.left, self.right = left, right
    def __repr__(self): return f"({self.left}⊗{self.right})"

class Add:
    def __init__(self, left, right):
        self.left, self.right = left, right
    def __repr__(self): return f"({self.left}+{self.right})"


def summand_poly(e):
    """Compute summand polynomial as coefficient list [a0, a1, ..., an]."""
    if isinstance(e, Gate):
        return [0, 1]
    left = summand_poly(e.left)
    right = summand_poly(e.right)
    if isinstance(e, Add):
        n = max(len(left), len(right))
        left += [0] * (n - len(left))
        right += [0] * (n - len(right))
        return [a + b for a, b in zip(left, right)]
    else:
        n = len(left) + len(right) - 1
        result = [0] * n
        for i, a in enumerate(left):
            for j, b in enumerate(right):
                result[i + j] += a * b
        return result


def eval_poly_float(coeffs, x):
    """Evaluate polynomial at float x."""
    return sum(c * x**i for i, c in enumerate(coeffs))


def summand_count(e):
    if isinstance(e, Gate): return 1
    if isinstance(e, Add): return summand_count(e.left) + summand_count(e.right)
    return summand_count(e.left) * summand_count(e.right)


# ============================================================
# Build example expressions
# ============================================================

g0, g1, g2, g3 = Gate(0), Gate(1), Gate(2), Gate(3)

expressions = {
    "Single gate\nG0": g0,
    "Sequential\n(G0;G1)": Seq(g0, g1),
    "Superposition\n(G0+G1)": Add(g0, g1),
    "Mixed\n(G0;(G1+G2))": Seq(g0, Add(g1, g2)),
    "Tensor product\n(G0⊗G1)": Par(g0, g1),
    "Complex\n((G0+G1)⊗(G2+G3))": Par(Add(g0, g1), Add(g2, g3)),
}

# ============================================================
# Plot
# ============================================================

fig, axes = plt.subplots(2, 3, figsize=(15, 10))
axes = axes.flatten()

x_vals = np.linspace(-0.5, 2.5, 300)

for ax, (name, expr) in zip(axes, expressions.items()):
    poly = summand_poly(expr)
    y_vals = [eval_poly_float(poly, x) for x in x_vals]

    ax.plot(x_vals, y_vals, 'b-', linewidth=2.5, label='p(x)')

    # Mark x=0 (always 0) and x=1 (= summand count)
    sc = summand_count(expr)
    ax.plot(0, 0, 'ro', markersize=10, zorder=5)
    ax.plot(1, sc, 'g*', markersize=15, zorder=5)

    ax.axhline(y=0, color='gray', linewidth=0.5, linestyle='--')
    ax.axvline(x=0, color='gray', linewidth=0.5, linestyle='--')
    ax.axvline(x=1, color='green', linewidth=0.5, linestyle='--', alpha=0.5)

    # Format polynomial string
    poly_terms = []
    for i, c in enumerate(poly):
        if c == 0: continue
        if i == 0:
            poly_terms.append(str(c))
        elif i == 1:
            poly_terms.append(f"{c}x" if c != 1 else "x")
        else:
            poly_terms.append(f"{c}x^{i}" if c != 1 else f"x^{i}")
    poly_str = " + ".join(poly_terms) if poly_terms else "0"

    ax.set_title(name, fontsize=11)
    ax.annotate(f'p(x) = {poly_str}', xy=(0.05, 0.95),
                xycoords='axes fraction', fontsize=9,
                verticalalignment='top',
                bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))
    ax.annotate(f'p(1) = {sc}', xy=(1, sc),
                xytext=(1.5, sc + 0.5),
                arrowprops=dict(arrowstyle='->', color='green'),
                fontsize=10, color='green', fontweight='bold')
    ax.set_xlabel('x')
    ax.set_ylabel('p(x)')
    ax.set_ylim(min(y_vals) - 1, max(max(y_vals), sc) + 2)

fig.suptitle('Summand Polynomials of Quantum Tensor Expressions\n'
             'Red dot: p(0) = 0  |  Green star: p(1) = summand count',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('summand_polynomials.png', dpi=150, bbox_inches='tight')
print("Saved summand_polynomials.png")
