#!/usr/bin/env python3
"""
Tropical Satake Skeleton: Demonstrations and Visualizations

This script demonstrates the core mathematical constructions of the
Tropical Satake Skeleton theory through concrete numerical examples.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
from matplotlib.collections import LineCollection
import json
import base64
from io import BytesIO


# ─────────────────────────────────────────────────
# Section 1: Min-Plus Expression Evaluation
# ─────────────────────────────────────────────────

class MinPlusExpr:
    """A min-plus expression in n variables."""
    pass

class Const(MinPlusExpr):
    def __init__(self, c):
        self.c = c
    def eval(self, v):
        return self.c
    def __repr__(self):
        return f"{self.c}"

class Var(MinPlusExpr):
    def __init__(self, i):
        self.i = i
    def eval(self, v):
        return v[self.i]
    def __repr__(self):
        return f"x{self.i}"

class TropAdd(MinPlusExpr):
    """Tropical addition = min"""
    def __init__(self, e1, e2):
        self.e1, self.e2 = e1, e2
    def eval(self, v):
        return min(self.e1.eval(v), self.e2.eval(v))
    def __repr__(self):
        return f"min({self.e1}, {self.e2})"

class TropMul(MinPlusExpr):
    """Tropical multiplication = +"""
    def __init__(self, e1, e2):
        self.e1, self.e2 = e1, e2
    def eval(self, v):
        return self.e1.eval(v) + self.e2.eval(v)
    def __repr__(self):
        return f"({self.e1} + {self.e2})"


# ─────────────────────────────────────────────────
# Section 2: Tropical Relation Locus
# ─────────────────────────────────────────────────

def tropical_relation_locus(relations, n_vars, base=0, grid_range=(-3, 3), resolution=200):
    """
    Compute the normalized tropical relation locus for n=2 or n=3 variables.
    Returns points satisfying all relations with base coordinate = 0.
    """
    if n_vars == 2:
        x1_range = np.linspace(grid_range[0], grid_range[1], resolution)
        locus = []
        for x1 in x1_range:
            v = [0.0, x1]  # normalized: v[base] = 0
            if all(abs(lhs.eval(v) - rhs.eval(v)) < 1e-10 for lhs, rhs in relations):
                locus.append(v)
        return np.array(locus) if locus else np.empty((0, 2))

    elif n_vars == 3:
        x_range = np.linspace(grid_range[0], grid_range[1], resolution)
        locus = []
        for x1 in x_range:
            for x2 in x_range:
                v = [0.0, x1, x2]
                if all(abs(lhs.eval(v) - rhs.eval(v)) < 1e-10 for lhs, rhs in relations):
                    locus.append([x1, x2])
        return np.array(locus) if locus else np.empty((0, 2))


# ─────────────────────────────────────────────────
# Section 3: Concrete Examples
# ─────────────────────────────────────────────────

def demo_rank2_satake():
    """
    Rank-2 Satake Skeleton: min(x₀, x₁) = x₁
    This forces x₁ ≤ x₀, so with x₀ = 0 (normalization), we get x₁ ≤ 0.
    The skeleton is the ray (-∞, 0].
    """
    print("=" * 60)
    print("Demo 1: Rank-2 Satake Skeleton")
    print("=" * 60)
    print()
    print("Relation: min(x₀, x₁) = x₁")
    print("Normalization: x₀ = 0")
    print()

    relations = [(TropAdd(Var(0), Var(1)), Var(1))]

    # Test specific points
    test_points = [
        [0.0, -2.0],  # Should be in skeleton
        [0.0, -1.0],  # Should be in skeleton
        [0.0,  0.0],  # Should be in skeleton (boundary)
        [0.0,  1.0],  # Should NOT be in skeleton
        [0.0,  3.0],  # Should NOT be in skeleton
    ]

    for v in test_points:
        lhs = relations[0][0].eval(v)
        rhs = relations[0][1].eval(v)
        satisfied = abs(lhs - rhs) < 1e-10
        in_skeleton = satisfied and abs(v[0]) < 1e-10
        print(f"  v = {v} → min({v[0]}, {v[1]}) = {lhs:.1f}, x₁ = {rhs:.1f}, "
              f"satisfied = {satisfied}, in skeleton = {in_skeleton}")

    locus = tropical_relation_locus(relations, 2, resolution=500)
    print(f"\n  Skeleton has {len(locus)} sampled points")
    if len(locus) > 0:
        print(f"  Range of x₁ in skeleton: [{locus[:, 1].min():.2f}, {locus[:, 1].max():.2f}]")
    print()
    return locus


def demo_rank3_weyl():
    """
    Rank-3 Weyl Chamber: min(x₀ + x₂, x₁ + x₁) = x₁ + x₁
    With x₀ = 0, this gives: 2x₁ ≤ x₂.
    """
    print("=" * 60)
    print("Demo 2: Rank-3 Weyl Chamber Skeleton")
    print("=" * 60)
    print()
    print("Relation: min(x₀ + x₂, x₁ + x₁) = x₁ + x₁")
    print("Normalization: x₀ = 0")
    print("Equivalent to: 2x₁ ≤ x₂")
    print()

    lhs_expr = TropAdd(TropMul(Var(0), Var(2)), TropMul(Var(1), Var(1)))
    rhs_expr = TropMul(Var(1), Var(1))
    relations = [(lhs_expr, rhs_expr)]

    test_points = [
        [0.0, 1.0, 3.0],   # 2*1 = 2 ≤ 3 ✓
        [0.0, 1.0, 2.0],   # 2*1 = 2 ≤ 2 ✓
        [0.0, 1.0, 1.0],   # 2*1 = 2 > 1 ✗
        [0.0, -1.0, -1.0], # 2*(-1) = -2 ≤ -1 ✓
        [0.0, 0.0, 0.0],   # 2*0 = 0 ≤ 0 ✓
    ]

    for v in test_points:
        lhs = lhs_expr.eval(v)
        rhs = rhs_expr.eval(v)
        satisfied = abs(lhs - rhs) < 1e-10
        print(f"  v = {v} → min({v[0]+v[2]:.1f}, {v[1]+v[1]:.1f}) = {lhs:.1f}, "
              f"2x₁ = {rhs:.1f}, satisfied = {satisfied}")

    locus = tropical_relation_locus(relations, 3, resolution=100)
    print(f"\n  Weyl chamber has {len(locus)} sampled points")
    print()
    return locus


def demo_hecke_action():
    """
    Hecke min-action on rank-2: (x₀, x₁) ↦ (x₀, min(x₀, x₁))
    Fixed points: x₁ ≤ x₀
    """
    print("=" * 60)
    print("Demo 3: Hecke Min-Action and Fixed Points")
    print("=" * 60)
    print()
    print("Action: (x₀, x₁) ↦ (x₀, min(x₀, x₁))")
    print()

    def hecke_min_action(v):
        return [v[0], min(v[0], v[1])]

    test_points = [
        [0.0, -2.0],
        [0.0, -1.0],
        [0.0,  0.0],
        [0.0,  1.0],
        [0.0,  2.0],
    ]

    print("  Point          → Image           Fixed?")
    print("  " + "-" * 45)
    for v in test_points:
        img = hecke_min_action(v)
        is_fixed = abs(v[0] - img[0]) < 1e-10 and abs(v[1] - img[1]) < 1e-10
        print(f"  ({v[0]:5.1f}, {v[1]:5.1f}) → ({img[0]:5.1f}, {img[1]:5.1f})  {is_fixed}")

    print()
    print("  Fixed point condition: x₁ ≤ x₀ (equivalently x₁ ≤ 0 when normalized)")
    print()


def demo_concavity():
    """
    Demonstrate concavity of min-plus expressions.
    """
    print("=" * 60)
    print("Demo 4: Concavity of Min-Plus Expressions")
    print("=" * 60)
    print()

    # Expression: min(x₀, x₁ + 1)
    expr = TropAdd(Var(0), TropMul(Var(1), Const(1.0)))
    print(f"  Expression: {expr}")
    print()

    v = [0.0, 2.0]
    w = [4.0, 0.0]

    print(f"  v = {v}, w = {w}")
    print(f"  f(v) = {expr.eval(v):.2f}, f(w) = {expr.eval(w):.2f}")
    print()

    print("  t     f((1-t)v + tw)   (1-t)f(v) + tf(w)   Concave?")
    print("  " + "-" * 55)

    for t in [0.0, 0.25, 0.5, 0.75, 1.0]:
        vt = [(1 - t) * v[i] + t * w[i] for i in range(2)]
        f_vt = expr.eval(vt)
        convex_combo = (1 - t) * expr.eval(v) + t * expr.eval(w)
        print(f"  {t:.2f}    {f_vt:>8.3f}           {convex_combo:>8.3f}          "
              f"{'✓' if f_vt >= convex_combo - 1e-10 else '✗'}")
    print()


# ─────────────────────────────────────────────────
# Section 4: Visualizations
# ─────────────────────────────────────────────────

def fig_to_base64(fig):
    """Convert matplotlib figure to base64 PNG data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def visualize_rank2_skeleton():
    """Visualize the rank-2 Satake skeleton."""
    fig, ax = plt.subplots(1, 1, figsize=(8, 4))

    # The skeleton is the ray x₁ ≤ 0
    x1 = np.linspace(-3, 0, 100)
    ax.plot(x1, np.zeros_like(x1), 'b-', linewidth=3, label='Satake Skeleton')
    ax.plot(0, 0, 'ro', markersize=10, zorder=5, label='Origin (boundary)')

    # Show the forbidden region
    ax.fill_between([0, 3], -0.5, 0.5, alpha=0.15, color='red', label='Forbidden (x₁ > 0)')

    # Arrow showing direction
    ax.annotate('', xy=(-2.8, 0), xytext=(-0.3, 0),
                arrowprops=dict(arrowstyle='->', color='blue', lw=2))

    ax.set_xlabel('x₁ (normalized: x₀ = 0)', fontsize=12)
    ax.set_title('Rank-2 Satake Skeleton: {(0, x₁) | x₁ ≤ 0}', fontsize=14)
    ax.set_xlim(-3.5, 3.5)
    ax.set_ylim(-1, 1)
    ax.axhline(y=0, color='gray', linewidth=0.5)
    ax.axvline(x=0, color='gray', linewidth=0.5)
    ax.legend(fontsize=10)
    ax.set_yticks([])

    return fig_to_base64(fig)


def visualize_rank3_weyl():
    """Visualize the rank-3 Weyl chamber skeleton."""
    fig, ax = plt.subplots(1, 1, figsize=(8, 7))

    # Weyl chamber: 2x₁ ≤ x₂ (with x₀ = 0)
    x1 = np.linspace(-3, 3, 300)
    x2 = np.linspace(-3, 6, 300)
    X1, X2 = np.meshgrid(x1, x2)

    # Chamber condition: 2*x₁ ≤ x₂
    mask = 2 * X1 <= X2 + 1e-10

    ax.contourf(X1, X2, mask.astype(float), levels=[0.5, 1.5],
                colors=['#4a90d9'], alpha=0.3)
    ax.contour(X1, X2, mask.astype(float), levels=[0.5],
               colors=['blue'], linewidths=2)

    # Draw the boundary line 2x₁ = x₂
    x1_line = np.linspace(-2, 3, 100)
    ax.plot(x1_line, 2 * x1_line, 'b-', linewidth=2, label='Boundary: x₂ = 2x₁')

    # Mark the origin
    ax.plot(0, 0, 'ro', markersize=10, zorder=5, label='Origin')

    # Arrows showing chamber interior
    ax.annotate('Weyl Chamber\n(skeleton)', xy=(-0.5, 2), fontsize=12,
                ha='center', color='blue', fontweight='bold')

    ax.set_xlabel('x₁', fontsize=12)
    ax.set_ylabel('x₂', fontsize=12)
    ax.set_title('Rank-3 Weyl Chamber: {(0, x₁, x₂) | 2x₁ ≤ x₂}', fontsize=14)
    ax.set_xlim(-3, 3)
    ax.set_ylim(-3, 6)
    ax.legend(fontsize=10, loc='lower right')
    ax.grid(True, alpha=0.3)

    return fig_to_base64(fig)


def visualize_hecke_action():
    """Visualize the Hecke min-action dynamics."""
    fig, ax = plt.subplots(1, 1, figsize=(8, 7))

    # Plot several orbits of the min action
    x0 = 0.0
    x1_values = np.linspace(-3, 3, 15)

    for x1_init in x1_values:
        trajectory = [(x1_init, 0)]
        x1 = x1_init
        for _ in range(5):
            x1_new = min(x0, x1)
            if abs(x1_new - x1) < 1e-10:
                break
            trajectory.append((x1_new, trajectory[-1][1] + 1))
            x1 = x1_new

        xs = [t[0] for t in trajectory]
        ys = [t[1] for t in trajectory]
        color = 'green' if x1_init <= 0 else 'red'
        ax.plot(xs, ys, '-o', color=color, markersize=4, linewidth=1.5, alpha=0.6)

    # Mark the fixed point region
    ax.axvline(x=0, color='blue', linewidth=2, linestyle='--', alpha=0.5, label='x₀ = 0')
    ax.fill_betweenx([-0.5, 5.5], -3.5, 0, alpha=0.1, color='green', label='Fixed region (x₁ ≤ 0)')

    ax.set_xlabel('x₁ coordinate', fontsize=12)
    ax.set_ylabel('Iteration step', fontsize=12)
    ax.set_title('Hecke Min-Action: x₁ ↦ min(x₀, x₁)', fontsize=14)
    ax.legend(fontsize=10)
    ax.set_xlim(-3.5, 3.5)
    ax.set_ylim(-0.5, 3.5)
    ax.grid(True, alpha=0.3)

    return fig_to_base64(fig)


def visualize_concavity():
    """Visualize concavity of a min-plus expression."""
    fig, ax = plt.subplots(1, 1, figsize=(8, 5))

    # 1D slice: f(t) = min(t, 2-t) for t in [-1, 3]
    t_vals = np.linspace(-1, 3, 500)
    f_vals = np.minimum(t_vals, 2 - t_vals)

    ax.plot(t_vals, f_vals, 'b-', linewidth=2.5, label='f(x) = min(x, 2-x)')
    ax.plot(t_vals, t_vals, 'g--', linewidth=1, alpha=0.5, label='x')
    ax.plot(t_vals, 2 - t_vals, 'r--', linewidth=1, alpha=0.5, label='2-x')

    # Show concavity: chord lies below
    x_a, x_b = 0.0, 2.0
    f_a, f_b = min(x_a, 2 - x_a), min(x_b, 2 - x_b)
    chord_t = np.linspace(0, 1, 100)
    chord_x = (1 - chord_t) * x_a + chord_t * x_b
    chord_y = (1 - chord_t) * f_a + chord_t * f_b
    ax.plot(chord_x, chord_y, 'k--', linewidth=1.5, alpha=0.7, label='Chord (below graph)')
    ax.fill_between(chord_x,
                     np.minimum(chord_x, 2 - chord_x),
                     chord_y,
                     alpha=0.15, color='blue')

    ax.plot([x_a, x_b], [f_a, f_b], 'ko', markersize=8)

    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('f(x)', fontsize=12)
    ax.set_title('Concavity of Min-Plus Expressions', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    return fig_to_base64(fig)


# ─────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────

if __name__ == '__main__':
    print("\n" + "=" * 60)
    print("TROPICAL SATAKE SKELETON — DEMONSTRATIONS")
    print("=" * 60 + "\n")

    locus2 = demo_rank2_satake()
    locus3 = demo_rank3_weyl()
    demo_hecke_action()
    demo_concavity()

    print("=" * 60)
    print("Generating visualizations...")
    print("=" * 60)

    viz1 = visualize_rank2_skeleton()
    viz2 = visualize_rank3_weyl()
    viz3 = visualize_hecke_action()
    viz4 = visualize_concavity()

    print("  Generated 4 visualizations as base64 PNG data URIs.")
    print(f"  Visualization 1 size: {len(viz1)} chars")
    print(f"  Visualization 2 size: {len(viz2)} chars")
    print(f"  Visualization 3 size: {len(viz3)} chars")
    print(f"  Visualization 4 size: {len(viz4)} chars")

    # Save visualizations
    with open('viz_rank2_skeleton.txt', 'w') as f:
        f.write(viz1)
    with open('viz_rank3_weyl.txt', 'w') as f:
        f.write(viz2)
    with open('viz_hecke_action.txt', 'w') as f:
        f.write(viz3)
    with open('viz_concavity.txt', 'w') as f:
        f.write(viz4)

    print("\n  Done! Visualizations saved to viz_*.txt files.")
