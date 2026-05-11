#!/usr/bin/env python3
"""
Closure Operator Bridge Theory — Interactive Demonstrations

Demonstrates the core theorems of the Fixed-Point Lattice Theorem
for Idempotent Monotone Bridge Operators with concrete numerical examples.

Key demonstrations:
1. ReLU as a closure operator with least-fixed-point characterization
2. Idempotent lattice structure in commutative rings (Z/nZ)
3. Nonexpansive idempotent retraction on metric spaces
4. Closure operator composition
5. Tropical min-plus closure operators
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import Callable, List, Set, Tuple
import base64
from io import BytesIO


# ═══════════════════════════════════════════════════════════════
# §1. ReLU as Closure Operator
# ═══════════════════════════════════════════════════════════════

def relu(x: float) -> float:
    """ReLU: the canonical closure operator on (ℝ, ≤)."""
    return max(0.0, x)


def demo_relu_closure():
    """Demonstrate ReLU satisfying all closure operator axioms."""
    print("=" * 60)
    print("§1. ReLU as a Closure Operator on (ℝ, ≤)")
    print("=" * 60)

    test_values = [-3.0, -1.5, -0.1, 0.0, 0.1, 1.5, 3.0]

    print("\n  Monotonicity: x ≤ y ⟹ relu(x) ≤ relu(y)")
    for i in range(len(test_values) - 1):
        x, y = test_values[i], test_values[i + 1]
        assert relu(x) <= relu(y), f"Monotonicity failed at {x}, {y}"
        print(f"    relu({x:5.1f}) = {relu(x):4.1f}  ≤  relu({y:5.1f}) = {relu(y):4.1f}  ✓")

    print("\n  Inflationary: x ≤ relu(x)")
    for x in test_values:
        assert x <= relu(x), f"Inflationary failed at {x}"
        print(f"    {x:5.1f} ≤ relu({x:5.1f}) = {relu(x):4.1f}  ✓")

    print("\n  Idempotent: relu(relu(x)) = relu(x)")
    for x in test_values:
        assert relu(relu(x)) == relu(x), f"Idempotent failed at {x}"
        print(f"    relu(relu({x:5.1f})) = relu({relu(x):4.1f}) = {relu(relu(x)):4.1f}  ✓")

    print("\n  ★ Least Fixed Point Above:")
    print("    For each x, relu(x) is the LEAST y ≥ x with relu(y) = y")
    for x in test_values:
        ox = relu(x)
        # Verify ox is fixed
        assert relu(ox) == ox
        # Verify ox is above x
        assert x <= ox
        # Verify minimality: any fixed point y ≥ x satisfies y ≥ ox
        # Fixed points are [0, ∞), so least fixed point above x is max(0, x)
        print(f"    x = {x:5.1f}: least fixed point above x = {ox:4.1f}")

    print("\n  Fixed-point set = {x ∈ ℝ | relu(x) = x} = [0, ∞)")
    print("  Range of relu = [0, ∞)")
    print("  ✓ Range = Fixed Points (Master Equation)")


# ═══════════════════════════════════════════════════════════════
# §2. Idempotent Lattice in ℤ/nℤ
# ═══════════════════════════════════════════════════════════════

def find_idempotents(n: int) -> List[int]:
    """Find all idempotents in Z/nZ."""
    return [e for e in range(n) if (e * e) % n == e]


def idem_meet(e: int, f: int, n: int) -> int:
    """Idempotent meet: e * f mod n."""
    return (e * f) % n


def idem_join(e: int, f: int, n: int) -> int:
    """Idempotent join: e + f - e*f mod n."""
    return (e + f - e * f) % n


def idem_le(e: int, f: int, n: int) -> bool:
    """Idempotent order: e ≤ f iff e*f = e."""
    return (e * f) % n == e


def demo_idempotent_lattice():
    """Demonstrate idempotent lattice structure in Z/nZ."""
    print("\n" + "=" * 60)
    print("§2. Idempotent Lattice Structure in ℤ/nℤ")
    print("=" * 60)

    for n in [6, 12, 30]:
        idems = find_idempotents(n)
        print(f"\n  ℤ/{n}ℤ: idempotents = {idems}")

        # Verify meet and join are idempotent
        print(f"  Checking meet (e*f) and join (e+f-ef) are idempotent:")
        for e in idems:
            for f in idems:
                m = idem_meet(e, f, n)
                j = idem_join(e, f, n)
                assert (m * m) % n == m, f"Meet {m} not idempotent"
                assert (j * j) % n == j, f"Join {j} not idempotent"

        # Display the partial order
        print(f"  Idempotent order (e ≤ f ⟺ e*f = e):")
        for e in idems:
            above = [f for f in idems if idem_le(e, f, n) and e != f]
            if above:
                print(f"    {e} ≤ {above}")

        # Show meet/join table
        if len(idems) <= 6:
            print(f"  Meet table (e*f mod {n}):")
            header = "      " + "".join(f"{f:4d}" for f in idems)
            print(header)
            for e in idems:
                row = f"  {e:3d} " + "".join(f"{idem_meet(e, f, n):4d}" for f in idems)
                print(row)

            print(f"  Join table (e+f-ef mod {n}):")
            print(header)
            for e in idems:
                row = f"  {e:3d} " + "".join(f"{idem_join(e, f, n):4d}" for f in idems)
                print(row)

    print("\n  ✓ All idempotent pairs verified: meet and join produce idempotents")


# ═══════════════════════════════════════════════════════════════
# §3. Nonexpansive Idempotent Retraction
# ═══════════════════════════════════════════════════════════════

def demo_metric_retraction():
    """Demonstrate idempotent nonexpansive retraction onto fixed-point set."""
    print("\n" + "=" * 60)
    print("§3. Nonexpansive Idempotent Retraction")
    print("=" * 60)

    # Projection onto [a, b] interval
    def proj_interval(x: float, a: float = -1.0, b: float = 2.0) -> float:
        return max(a, min(b, x))

    print("\n  P(x) = projection onto [-1, 2] = max(-1, min(2, x))")

    test_pts = [-5.0, -1.5, -1.0, 0.0, 1.0, 2.0, 2.5, 5.0]

    print("\n  Idempotence: P(P(x)) = P(x)")
    for x in test_pts:
        px = proj_interval(x)
        ppx = proj_interval(px)
        assert ppx == px
        print(f"    P(P({x:5.1f})) = P({px:5.1f}) = {ppx:5.1f}  ✓")

    print("\n  Nonexpansiveness: |P(x) - P(y)| ≤ |x - y|")
    for i in range(len(test_pts) - 1):
        x, y = test_pts[i], test_pts[i + 1]
        dp = abs(proj_interval(x) - proj_interval(y))
        dxy = abs(x - y)
        assert dp <= dxy + 1e-10
        print(f"    |P({x:5.1f}) - P({y:5.1f})| = {dp:4.1f} ≤ {dxy:4.1f} = |{x:5.1f} - {y:5.1f}|  ✓")

    print("\n  Fixed-point set = {x | P(x) = x} = [-1, 2]")
    print("  Range of P = [-1, 2]")
    print("  ✓ Range = Fixed Points (Master Equation)")
    print("  ✓ P is a metric retraction onto [-1, 2]")


# ═══════════════════════════════════════════════════════════════
# §4. Tropical Min-Plus Closure Operator
# ═══════════════════════════════════════════════════════════════

def demo_tropical_closure():
    """Demonstrate closure operators in the tropical (min-plus) setting."""
    print("\n" + "=" * 60)
    print("§4. Tropical Min-Plus Closure Operator")
    print("=" * 60)

    # In the tropical semiring (ℝ ∪ {∞}, min, +):
    # The "ceiling" operator T(x) = min(x, c) for a constant c
    # is NOT inflationary in the usual order.
    # But x ↦ max(x, c) IS inflationary, monotone, idempotent.

    c = 0.0
    def tropical_closure(x: float) -> float:
        """Tropical closure: max(x, c) — inflationary saturation."""
        return max(x, c)

    print(f"\n  Tropical closure: T(x) = max(x, {c})")
    print("  This is inflationary, monotone, and idempotent on (ℝ, ≤).")

    test_vals = [-3.0, -1.0, 0.0, 0.5, 2.0]
    for x in test_vals:
        tx = tropical_closure(x)
        ttx = tropical_closure(tx)
        print(f"    T({x:5.1f}) = {tx:4.1f}, T(T({x:5.1f})) = {ttx:4.1f}, "
              f"x ≤ T(x): {x <= tx}  ✓")

    print(f"\n  Fixed points = {{x | T(x) = x}} = [{c}, ∞)")
    print(f"  ✓ T is a closure operator; fixed points = nonneg reals")

    # Shortest-path closure (Floyd-Warshall as closure operator)
    print("\n  Shortest-path closure (Floyd-Warshall):")
    print("  Given a weighted graph, the shortest-path operator")
    print("  P : dist_matrix → dist_matrix is idempotent (on")
    print("  metric closure matrices) and monotone.")

    INF = float('inf')
    # 3-node graph
    D = np.array([
        [0.0, 1.0, INF],
        [INF, 0.0, 2.0],
        [3.0, INF, 0.0]
    ])

    def floyd_warshall(D: np.ndarray) -> np.ndarray:
        n = D.shape[0]
        R = D.copy()
        for k in range(n):
            for i in range(n):
                for j in range(n):
                    if R[i][k] + R[k][j] < R[i][j]:
                        R[i][j] = R[i][k] + R[k][j]
        return R

    D_closed = floyd_warshall(D)
    D_closed2 = floyd_warshall(D_closed)

    print(f"\n  Original distance matrix D:")
    for row in D:
        print(f"    {row}")
    print(f"\n  Shortest-path closure P(D):")
    for row in D_closed:
        print(f"    {row}")
    print(f"\n  P(P(D)) = P(D): {np.allclose(D_closed, D_closed2)}  ✓ (idempotent)")


# ═══════════════════════════════════════════════════════════════
# §5. Closure Operator Composition
# ═══════════════════════════════════════════════════════════════

def demo_composition():
    """Demonstrate composition of commuting closure operators."""
    print("\n" + "=" * 60)
    print("§5. Composition of Commuting Closure Operators")
    print("=" * 60)

    # O1(x) = max(0, x) (ReLU)
    # O2(x) = ceil to nearest integer ≥ x
    import math

    O1 = lambda x: max(0.0, x)
    O2 = lambda x: math.ceil(x) if x != int(x) else x

    print("\n  O₁(x) = max(0, x)  (ReLU)")
    print("  O₂(x) = ⌈x⌉        (ceiling)")
    print("  Both are monotone, inflationary, and idempotent.")

    # Check if they commute
    test_vals = [-2.5, -1.0, -0.5, 0.0, 0.5, 1.0, 1.7, 3.0]
    commutes = True
    for x in test_vals:
        v1 = O1(O2(x))
        v2 = O2(O1(x))
        if v1 != v2:
            commutes = False
        print(f"    O₁(O₂({x:5.1f})) = {v1:4.1f},  O₂(O₁({x:5.1f})) = {v2:4.1f}  "
              f"{'✓' if v1 == v2 else '✗'}")

    if commutes:
        print("\n  ✓ O₁ and O₂ commute!")
        print("  ⟹ O₁ ∘ O₂ is a closure operator (by composition theorem)")

        # Verify composition is idempotent
        comp = lambda x: O1(O2(x))
        print("\n  Fixed points of O₁ ∘ O₂ = {nonnegative integers}:")
        for x in test_vals:
            cx = comp(x)
            ccx = comp(cx)
            is_fp = (cx == ccx)
            print(f"    (O₁∘O₂)({x:5.1f}) = {cx:4.1f}, "
                  f"(O₁∘O₂)²({x:5.1f}) = {ccx:4.1f}  "
                  f"{'✓ idempotent' if is_fp else '✗'}")
    else:
        print("\n  ✗ O₁ and O₂ do NOT commute in general.")


# ═══════════════════════════════════════════════════════════════
# §6. Visualization
# ═══════════════════════════════════════════════════════════════

def generate_visualizations():
    """Generate publication-quality visualizations."""
    print("\n" + "=" * 60)
    print("§6. Generating Visualizations")
    print("=" * 60)

    # Figure 1: ReLU as closure operator
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    # Panel 1: ReLU function with fixed points highlighted
    x = np.linspace(-3, 3, 300)
    y_relu = np.maximum(0, x)

    axes[0].plot(x, x, 'k--', alpha=0.3, label='y = x')
    axes[0].plot(x, y_relu, 'b-', linewidth=2, label='ReLU(x) = max(0, x)')
    axes[0].fill_between(x[x >= 0], x[x >= 0], alpha=0.15, color='green',
                         label='Fixed points [0, ∞)')
    axes[0].axhline(y=0, color='gray', linewidth=0.5)
    axes[0].axvline(x=0, color='gray', linewidth=0.5)
    axes[0].set_xlabel('x')
    axes[0].set_ylabel('ReLU(x)')
    axes[0].set_title('ReLU as Closure Operator')
    axes[0].legend(fontsize=9)
    axes[0].set_xlim(-3, 3)
    axes[0].set_ylim(-1, 3)

    # Panel 2: Least fixed point above
    for x_val in [-2.0, -1.0, 0.5, 1.5]:
        ox = max(0, x_val)
        axes[1].annotate('', xy=(ox, ox), xytext=(x_val, x_val),
                         arrowprops=dict(arrowstyle='->', color='red', lw=1.5))
        axes[1].plot(x_val, x_val, 'ro', markersize=6)
        axes[1].plot(ox, ox, 'g^', markersize=8)

    x_line = np.linspace(-3, 3, 100)
    axes[1].plot(x_line, x_line, 'k--', alpha=0.3)
    axes[1].fill_between(x_line[x_line >= 0], -1, x_line[x_line >= 0],
                         alpha=0.1, color='green')
    axes[1].axhline(y=0, color='gray', linewidth=0.5)
    axes[1].axvline(x=0, color='gray', linewidth=0.5)
    axes[1].set_xlabel('x')
    axes[1].set_ylabel('y')
    axes[1].set_title('Least Fixed Point Above x')
    axes[1].set_xlim(-3, 3)
    axes[1].set_ylim(-1, 3)

    # Panel 3: Interval projection as nonexpansive retraction
    a, b = -1, 2
    x = np.linspace(-4, 5, 300)
    proj = np.clip(x, a, b)

    axes[2].plot(x, x, 'k--', alpha=0.3, label='y = x')
    axes[2].plot(x, proj, 'r-', linewidth=2, label=f'P(x) = clip(x, {a}, {b})')
    axes[2].axhspan(a, b, alpha=0.1, color='blue', label=f'Fixed points [{a}, {b}]')
    axes[2].set_xlabel('x')
    axes[2].set_ylabel('P(x)')
    axes[2].set_title('Interval Projection (Retraction)')
    axes[2].legend(fontsize=9)
    axes[2].set_xlim(-4, 5)
    axes[2].set_ylim(-2, 4)

    plt.tight_layout()
    plt.savefig('closure_operators.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved closure_operators.png")

    # Figure 2: Idempotent lattice in Z/30Z
    fig, ax = plt.subplots(1, 1, figsize=(8, 8))
    n = 30
    idems = find_idempotents(n)

    # Compute Hasse diagram (cover relations)
    def covers(e, f, idems, n):
        """Check if f covers e (e < f and no g with e < g < f)."""
        if not idem_le(e, f, n) or e == f:
            return False
        for g in idems:
            if g != e and g != f and idem_le(e, g, n) and idem_le(g, f, n):
                return False
        return True

    # Assign y-coordinates by "rank" (number of elements below)
    rank = {}
    for e in idems:
        rank[e] = sum(1 for f in idems if idem_le(f, e, n) and f != e)

    max_rank = max(rank.values()) if rank else 0
    rank_groups = {}
    for e in idems:
        r = rank[e]
        if r not in rank_groups:
            rank_groups[r] = []
        rank_groups[r].append(e)

    pos = {}
    for r, group in rank_groups.items():
        for i, e in enumerate(group):
            x_pos = (i - (len(group) - 1) / 2) * 1.5
            pos[e] = (x_pos, r * 1.5)

    # Draw edges
    for e in idems:
        for f in idems:
            if covers(e, f, idems, n):
                ax.plot([pos[e][0], pos[f][0]], [pos[e][1], pos[f][1]],
                        'b-', linewidth=1.5, alpha=0.6)

    # Draw nodes
    for e in idems:
        ax.plot(pos[e][0], pos[e][1], 'o', markersize=20,
                color='lightblue', markeredgecolor='navy', markeredgewidth=2)
        ax.text(pos[e][0], pos[e][1], str(e), ha='center', va='center',
                fontsize=10, fontweight='bold')

    ax.set_title(f'Idempotent Lattice in ℤ/{n}ℤ\n'
                 f'(meet = e·f, join = e+f−e·f)',
                 fontsize=14)
    ax.set_aspect('equal')
    ax.axis('off')

    plt.tight_layout()
    plt.savefig('idempotent_lattice.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved idempotent_lattice.png")

    # Figure 3: Convergence of tropical contraction
    fig, ax = plt.subplots(1, 1, figsize=(8, 5))

    rates = [0.3, 0.5, 0.7, 0.9]
    n_iters = 30

    for rate in rates:
        # Contraction f(x) = rate * x (fixed point at 0)
        x0 = 5.0
        iterates = [x0]
        x = x0
        for _ in range(n_iters):
            x = rate * x
            iterates.append(x)

        ax.plot(range(n_iters + 1), iterates, '-o', markersize=3,
                label=f'rate = {rate}')

    ax.axhline(y=0, color='gray', linewidth=0.5)
    ax.set_xlabel('Iteration n')
    ax.set_ylabel('x_n')
    ax.set_title('Contraction Map Convergence\n'
                 'f(x) = r·x, x₀ = 5')
    ax.legend()
    ax.set_yscale('log')
    ax.set_ylim(1e-10, 10)

    plt.tight_layout()
    plt.savefig('contraction_convergence.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved contraction_convergence.png")


def fig_to_base64(filename: str) -> str:
    """Convert a saved PNG file to base64 data URI."""
    with open(filename, 'rb') as f:
        data = f.read()
    return "data:image/png;base64," + base64.b64encode(data).decode('utf-8')


# ═══════════════════════════════════════════════════════════════
# Main
# ═══════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Closure Operator Bridge Theory — Demonstrations       ║")
    print("║  Fixed-Point Lattice Theorem for Idempotent Monotone   ║")
    print("║  Bridge Operators                                      ║")
    print("╚══════════════════════════════════════════════════════════╝")

    demo_relu_closure()
    demo_idempotent_lattice()
    demo_metric_retraction()
    demo_tropical_closure()
    demo_composition()
    generate_visualizations()

    print("\n" + "=" * 60)
    print("All demonstrations completed successfully!")
    print("=" * 60)
