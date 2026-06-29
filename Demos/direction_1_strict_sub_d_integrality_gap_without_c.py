"""
Applications of Bounded Pair Codegree Theory to Real-World Problems.

Demonstrates how the integrality gap results apply to:
1. Sensor placement (covering with bounded overlap)
2. SAT clause covering (bounded variable co-occurrence)
3. Course scheduling (bounded room conflicts)

Dependencies: numpy, scipy
"""

import numpy as np
from itertools import combinations
from typing import List, Set, Dict, Tuple
import random


# ── Inlined core algorithms ──────────────────────────────────────

def solve_lp(edges, vertices):
    from scipy.optimize import linprog
    v_list = sorted(vertices)
    v_idx = {v: i for i, v in enumerate(v_list)}
    n = len(v_list)
    c = np.ones(n)
    A_ub = np.zeros((len(edges), n))
    b_ub = -np.ones(len(edges))
    for i, e in enumerate(edges):
        for v in e:
            if v in v_idx:
                A_ub[i, v_idx[v]] = -1.0
    result = linprog(c, A_ub=A_ub, b_ub=b_ub, bounds=[(0, None)] * n, method='highs')
    if result.success:
        return result.fun, {v_list[i]: result.x[i] for i in range(n)}
    return None, None


def threshold_rounding(edges, x, d):
    theta = 1.0 / d
    S = {v for v, val in x.items() if val >= theta}
    uncov = [e for e in edges if not (e & S)]
    repair = set()
    for e in uncov:
        repair.add(max(e, key=lambda v: x.get(v, 0)))
    return S | repair


def pair_codeg(edges, u, v):
    return sum(1 for e in edges if u in e and v in e)


def max_pair_codeg(edges):
    verts = set().union(*edges) if edges else set()
    return max((pair_codeg(edges, u, v) for u, v in combinations(verts, 2)), default=0)


# ── Application 1: Sensor Placement ─────────────────────────────

def sensor_placement_demo():
    """Sensor placement problem with bounded coverage overlap.

    Scenario: A grid of locations needs sensor coverage. Each sensor
    covers a neighborhood of d locations. We want minimum sensors
    to cover all target regions. The pair codegree represents how
    many sensors can see any given pair of locations simultaneously.
    """
    print("=" * 60)
    print("Application 1: Sensor Placement with Bounded Overlap")
    print("=" * 60)

    random.seed(123)

    # Create a grid of 25 locations (5x5)
    n_locs = 20
    d = 3  # Each sensor covers 3 locations

    # Generate coverage sets with controlled overlap
    edges: List[Set[int]] = []
    pair_used: Dict[Tuple[int, int], int] = {}
    K = 2  # Max pair codegree

    for _ in range(500):
        if len(edges) >= 15:
            break
        edge = set(random.sample(range(n_locs), d))
        pairs = list(combinations(sorted(edge), 2))
        if all(pair_used.get(p, 0) < K for p in pairs):
            edges.append(edge)
            for p in pairs:
                pair_used[p] = pair_used.get(p, 0) + 1

    vertices = set().union(*edges)
    actual_K = max_pair_codeg(edges)

    print(f"\n  Locations: {len(vertices)}")
    print(f"  Coverage sets: {len(edges)}")
    print(f"  Coverage size d = {d}")
    print(f"  Max pair codegree K = {actual_K}")

    tau_star, x = solve_lp(edges, vertices)
    S_rounded = threshold_rounding(edges, x, d)

    print(f"\n  Fractional optimum τ* = {tau_star:.3f}")
    print(f"  Rounded solution |S| = {len(S_rounded)}")
    print(f"  Ratio |S|/τ* = {len(S_rounded)/tau_star:.3f}")
    print(f"  Classical bound: d = {d}")
    print(f"  Improved bound: d - 1/(2d(K+1)) = {d - 1/(2*d*(actual_K+1)):.4f}")
    print(f"  → Improvement factor: {1 - len(S_rounded)/(d*tau_star):.1%}")


# ── Application 2: SAT Clause Covering ──────────────────────────

def sat_covering_demo():
    """SAT clause covering with bounded variable co-occurrence.

    Scenario: Given a set of 3-CNF clauses, find the minimum set of
    variables to set to True so that every clause is satisfied.
    This is equivalent to a transversal of the clause hypergraph.
    Variable co-occurrence = pair codegree.
    """
    print("\n" + "=" * 60)
    print("Application 2: SAT Clause Covering")
    print("=" * 60)

    random.seed(456)
    n_vars = 15
    d = 3  # 3-CNF

    # Generate clauses with bounded variable co-occurrence
    clauses: List[Set[int]] = []
    cooccur: Dict[Tuple[int, int], int] = {}
    K = 2

    for _ in range(1000):
        if len(clauses) >= 12:
            break
        clause = set(random.sample(range(n_vars), d))
        pairs = list(combinations(sorted(clause), 2))
        if all(cooccur.get(p, 0) < K for p in pairs):
            clauses.append(clause)
            for p in pairs:
                cooccur[p] = cooccur.get(p, 0) + 1

    variables = set().union(*clauses)
    actual_K = max_pair_codeg(clauses)

    print(f"\n  Variables: {len(variables)}")
    print(f"  Clauses: {len(clauses)}")
    print(f"  Clause size d = {d}")
    print(f"  Max variable co-occurrence K = {actual_K}")

    tau_star, x = solve_lp(clauses, variables)
    S_rounded = threshold_rounding(clauses, x, d)

    print(f"\n  Fractional minimum τ* = {tau_star:.3f}")
    print(f"  Rounded solution |S| = {len(S_rounded)}")
    print(f"  Ratio |S|/τ* = {len(S_rounded)/tau_star:.3f}")

    # Verify all clauses are hit
    all_hit = all(S_rounded & c for c in clauses)
    print(f"  All clauses satisfied: {'✓' if all_hit else '✗'}")

    print(f"\n  Connection to proof complexity:")
    print(f"  Resolution width lower bound ≈ (d - ε) · τ* = {(d - 1/(2*d*(actual_K+1))) * tau_star:.2f}")


# ── Application 3: Course Scheduling ────────────────────────────

def scheduling_demo():
    """Course scheduling with bounded room conflicts.

    Scenario: Each course needs a specific set of resources (rooms,
    equipment, TAs). Find the minimum set of time slots so that
    every course can be scheduled. Two courses conflict if they
    share 2+ resources. Pair codegree = max resource co-occurrence.
    """
    print("\n" + "=" * 60)
    print("Application 3: Course Scheduling")
    print("=" * 60)

    random.seed(789)
    n_resources = 20
    d = 4  # Each course uses 4 resources

    # Generate course-resource assignments
    courses: List[Set[int]] = []
    res_pair: Dict[Tuple[int, int], int] = {}
    K = 1  # Linear: each pair of resources used by at most 1 course

    for _ in range(2000):
        if len(courses) >= 15:
            break
        course = set(random.sample(range(n_resources), d))
        pairs = list(combinations(sorted(course), 2))
        if all(res_pair.get(p, 0) < K for p in pairs):
            courses.append(course)
            for p in pairs:
                res_pair[p] = res_pair.get(p, 0) + 1

    resources = set().union(*courses)
    actual_K = max_pair_codeg(courses)

    print(f"\n  Resources: {len(resources)}")
    print(f"  Courses: {len(courses)}")
    print(f"  Resources per course d = {d}")
    print(f"  Max pair co-usage K = {actual_K}")

    tau_star, x = solve_lp(courses, resources)
    S_rounded = threshold_rounding(courses, x, d)

    print(f"\n  Fractional optimum τ* = {tau_star:.3f}")
    print(f"  Time slots needed |S| = {len(S_rounded)}")
    print(f"  Ratio |S|/τ* = {len(S_rounded)/tau_star:.3f}")
    print(f"  Improvement over d = {d}: {(1 - len(S_rounded)/(d*tau_star))*100:.1f}%")

    from math import comb
    edge_bound = K * comb(len(resources), 2) // comb(d, 2)
    print(f"\n  Fisher bound on courses: ≤ {edge_bound}")
    print(f"  Actual courses: {len(courses)}")


# ── Main ─────────────────────────────────────────────────────────

def main():
    print("╔" + "═" * 58 + "╗")
    print("║  Applications of Bounded Pair Codegree Theory            ║")
    print("╚" + "═" * 58 + "╝")

    sensor_placement_demo()
    sat_covering_demo()
    scheduling_demo()

    print("\n" + "=" * 60)
    print("All applications demonstrated successfully!")
    print("=" * 60)


if __name__ == "__main__":
    main()


"""
Demo: Integrality Gap for Hypergraphs with Bounded Pair Codegree.

Generates d-uniform hypergraphs with controlled pair codegree,
solves LP/ILP for τ* and τ, and demonstrates the layered threshold
rounding algorithm.

Dependencies: numpy, scipy, matplotlib
"""

import numpy as np
from itertools import combinations
from typing import List, Set, Tuple, Dict
import random


# ── Inline algorithm implementations ──────────────────────────────

def pair_codegree(edges: List[Set[int]], u: int, v: int) -> int:
    return sum(1 for e in edges if u in e and v in e)


def max_pair_codegree(edges: List[Set[int]]) -> int:
    vertices = set().union(*edges) if edges else set()
    return max(
        (pair_codegree(edges, u, v) for u, v in combinations(vertices, 2)),
        default=0
    )


def solve_lp(edges, vertices):
    from scipy.optimize import linprog
    v_list = sorted(vertices)
    v_idx = {v: i for i, v in enumerate(v_list)}
    n = len(v_list)
    c = np.ones(n)
    A_ub = np.zeros((len(edges), n))
    b_ub = -np.ones(len(edges))
    for i, e in enumerate(edges):
        for v in e:
            if v in v_idx:
                A_ub[i, v_idx[v]] = -1.0
    result = linprog(c, A_ub=A_ub, b_ub=b_ub, bounds=[(0, None)] * n, method='highs')
    if result.success:
        return result.fun, {v_list[i]: result.x[i] for i in range(n)}
    return None, None


def solve_ilp(edges, vertices):
    v_list = sorted(vertices)
    for k in range(len(v_list) + 1):
        for subset in combinations(v_list, k):
            S = set(subset)
            if all(S & e for e in edges):
                return k, S
    return len(v_list), set(v_list)


def generate_linear_hypergraph(n: int, d: int, max_edges: int = 30) -> List[Set[int]]:
    edges: List[Set[int]] = []
    pair_used: Set[Tuple[int, ...]] = set()
    for _ in range(2000):
        if len(edges) >= max_edges:
            break
        edge = set(random.sample(range(n), d))
        pairs = set(combinations(sorted(edge), 2))
        if not pairs & pair_used:
            edges.append(edge)
            pair_used |= pairs
    return edges


def generate_bounded_codegree_hypergraph(
    n: int, d: int, K: int, max_edges: int = 30
) -> List[Set[int]]:
    edges: List[Set[int]] = []
    pair_count: Dict[Tuple[int, int], int] = {}
    for _ in range(3000):
        if len(edges) >= max_edges:
            break
        edge = set(random.sample(range(n), d))
        pairs = list(combinations(sorted(edge), 2))
        if all(pair_count.get(p, 0) < K for p in pairs):
            edges.append(edge)
            for p in pairs:
                pair_count[p] = pair_count.get(p, 0) + 1
    return edges


# ── Main Demo ─────────────────────────────────────────────────────

def main():
    random.seed(42)
    np.random.seed(42)

    print("=" * 70)
    print("DEMO: Sub-d Integrality Gap from Bounded Pair Codegree")
    print("=" * 70)

    # ── Demo 1: Basic example ──
    print("\n" + "─" * 70)
    print("Demo 1: Concrete example — 3-uniform linear hypergraph")
    print("─" * 70)

    edges = [{0, 1, 2}, {3, 4, 5}, {6, 7, 8}, {0, 3, 6}, {1, 4, 7}, {2, 5, 8}]
    vertices = set().union(*edges)
    d = 3
    K = max_pair_codegree(edges)

    print(f"Edges: {[sorted(e) for e in edges]}")
    print(f"Vertices: {sorted(vertices)}")
    print(f"d = {d}, max pair codegree K = {K}")

    tau_star, x = solve_lp(edges, vertices)
    tau, S = solve_ilp(edges, vertices)

    print(f"τ* (LP optimum) = {tau_star:.4f}")
    print(f"τ  (ILP optimum) = {tau}")
    print(f"Gap τ/τ* = {tau / tau_star:.4f}")
    print(f"Classical bound: d = {d}")
    print(f"Predicted bound: d - 1/(2dK) = {d - 1/(2*d*(K+1)):.4f}")

    # ── Demo 2: Varying n ──
    print("\n" + "─" * 70)
    print("Demo 2: Integrality gap vs. n (d=3, K=1, linear hypergraphs)")
    print("─" * 70)

    print(f"{'n':>4} {'|E|':>5} {'τ*':>8} {'τ':>4} {'τ/τ*':>8} {'bound':>8}")
    print("-" * 45)

    for n in [8, 10, 12, 14]:
        gaps = []
        for trial in range(10):
            edges = generate_linear_hypergraph(n, 3, max_edges=20)
            if len(edges) < 3:
                continue
            verts = set().union(*edges)
            ts, _ = solve_lp(edges, verts)
            if ts is None or ts < 0.01:
                continue
            ti, _ = solve_ilp(edges, verts)
            gaps.append((len(edges), ts, ti, ti / ts))

        if gaps:
            avg_E = np.mean([g[0] for g in gaps])
            avg_ts = np.mean([g[1] for g in gaps])
            avg_ti = np.mean([g[2] for g in gaps])
            max_gap = max(g[3] for g in gaps)
            bound = 3 - 1 / (2 * 3 * 2)
            print(f"{n:>4} {avg_E:>5.1f} {avg_ts:>8.3f} {avg_ti:>4.1f} {max_gap:>8.4f} {bound:>8.4f}")

    # ── Demo 3: Varying K ──
    print("\n" + "─" * 70)
    print("Demo 3: Integrality gap vs. K (d=3, n=12)")
    print("─" * 70)

    print(f"{'K':>4} {'|E|':>5} {'τ*':>8} {'τ':>4} {'max τ/τ*':>10} {'bound':>8}")
    print("-" * 50)

    for K in [1, 2, 3, 4]:
        gaps = []
        for trial in range(10):
            edges = generate_bounded_codegree_hypergraph(12, 3, K, max_edges=15)
            if len(edges) < 3:
                continue
            verts = set().union(*edges)
            ts, _ = solve_lp(edges, verts)
            if ts is None or ts < 0.01:
                continue
            ti, _ = solve_ilp(edges, verts)
            actual_K = max_pair_codegree(edges)
            gaps.append((len(edges), ts, ti, ti / ts, actual_K))

        if gaps:
            avg_E = np.mean([g[0] for g in gaps])
            avg_ts = np.mean([g[1] for g in gaps])
            avg_ti = np.mean([g[2] for g in gaps])
            max_gap = max(g[3] for g in gaps)
            bound = 3 - 1 / (2 * 3 * (K + 1))
            print(f"{K:>4} {avg_E:>5.1f} {avg_ts:>8.3f} {avg_ti:>4.1f} {max_gap:>10.4f} {bound:>8.4f}")

    # ── Demo 4: Edge count bound ──
    print("\n" + "─" * 70)
    print("Demo 4: Double-counting edge bound |E| · C(d,2) ≤ K · C(n,2)")
    print("─" * 70)

    from math import comb
    for n, d, K in [(10, 3, 1), (12, 3, 2), (15, 4, 1), (20, 3, 3)]:
        bound = K * comb(n, 2) // comb(d, 2)
        edges = generate_bounded_codegree_hypergraph(n, d, K, max_edges=100)
        actual = len(edges)
        print(f"  n={n}, d={d}, K={K}: |E| = {actual}, bound = {bound} ✓" if actual <= bound
              else f"  n={n}, d={d}, K={K}: |E| = {actual}, bound = {bound} ✗")

    # ── Demo 5: Conflict graph ──
    print("\n" + "─" * 70)
    print("Demo 5: Conflict graph structure")
    print("─" * 70)

    edges = [{0,1,2}, {1,2,3}, {2,3,4}, {5,6,7}, {0,3,5}]
    print(f"Edges: {[sorted(e) for e in edges]}")
    print(f"Max pair codegree: {max_pair_codegree(edges)}")

    n_edges = len(edges)
    print("\nConflict graph (edges sharing ≥ 2 vertices):")
    for i in range(n_edges):
        for j in range(i+1, n_edges):
            inter = edges[i] & edges[j]
            if len(inter) >= 2:
                print(f"  e{i} ~ e{j}: intersection = {sorted(inter)}")

    print(f"\nMax degree bound: K·C(d,2) = {max_pair_codegree(edges)}·{comb(3,2)} = {max_pair_codegree(edges) * comb(3,2)}")

    print("\n" + "=" * 70)
    print("All demos completed successfully!")
    print("=" * 70)


if __name__ == "__main__":
    main()


"""
Visualization: Conflict Graph of Uncovered Edges

Creates a visual representation of the conflict graph structure:
- Shows a hypergraph with its edges
- Highlights uncovered edges after threshold rounding
- Draws the conflict graph (edges sharing ≥ 2 vertices)
- Shows the greedy coloring of the conflict graph

Uses matplotlib for static visualization.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from itertools import combinations
from math import cos, sin, pi


def draw_hypergraph_and_conflict():
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))

    # Define a hypergraph
    n_vertices = 9
    edges = [
        {0, 1, 2}, {1, 2, 3}, {3, 4, 5},
        {5, 6, 7}, {6, 7, 8}, {0, 4, 8}
    ]
    edge_colors_base = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12', '#9b59b6', '#1abc9c']

    # Vertex positions on a circle
    angles = [2 * pi * i / n_vertices - pi/2 for i in range(n_vertices)]
    pos = {i: (1.5 * cos(a), 1.5 * sin(a)) for i, a in enumerate(angles)}

    # ── Panel 1: The hypergraph ──
    ax = axes[0]
    ax.set_title('Hypergraph H\n(3-uniform, 6 edges)', fontsize=13, fontweight='bold')

    for idx, e in enumerate(edges):
        verts = [pos[v] for v in sorted(e)]
        cx = np.mean([v[0] for v in verts])
        cy = np.mean([v[1] for v in verts])
        # Draw triangle
        triangle = plt.Polygon(verts, alpha=0.15, color=edge_colors_base[idx],
                               edgecolor=edge_colors_base[idx], linewidth=2)
        ax.add_patch(triangle)
        ax.text(cx, cy, f'e{idx}', fontsize=8, ha='center', va='center',
                color=edge_colors_base[idx], fontweight='bold')

    for v, (x, y) in pos.items():
        ax.plot(x, y, 'ko', markersize=10, zorder=5)
        ax.text(x + 0.15, y + 0.15, str(v), fontsize=10, fontweight='bold', zorder=6)

    ax.set_xlim(-2.2, 2.2)
    ax.set_ylim(-2.2, 2.2)
    ax.set_aspect('equal')
    ax.axis('off')

    # ── Panel 2: Threshold rounding ──
    ax = axes[1]
    ax.set_title('After Threshold Rounding\n(θ = 1/3, S₁ shown in green)', fontsize=13, fontweight='bold')

    # Simulate fractional values
    x_frac = {0: 0.4, 1: 0.35, 2: 0.1, 3: 0.15, 4: 0.5,
              5: 0.3, 6: 0.1, 7: 0.1, 8: 0.4}
    theta = 1/3
    S1 = {v for v, val in x_frac.items() if val >= theta}

    # Find uncovered edges
    uncovered = [i for i, e in enumerate(edges) if not (e & S1)]
    covered = [i for i, e in enumerate(edges) if (e & S1)]

    for idx, e in enumerate(edges):
        verts = [pos[v] for v in sorted(e)]
        color = '#ff6b6b' if idx in uncovered else '#c8e6c9'
        alpha = 0.3 if idx in uncovered else 0.15
        lw = 2.5 if idx in uncovered else 1
        triangle = plt.Polygon(verts, alpha=alpha, color=color,
                               edgecolor='#ff6b6b' if idx in uncovered else '#4caf50',
                               linewidth=lw, linestyle='--' if idx in uncovered else '-')
        ax.add_patch(triangle)

    for v, (x, y) in pos.items():
        color = '#4caf50' if v in S1 else '#bbb'
        size = 12 if v in S1 else 8
        ax.plot(x, y, 'o', color=color, markersize=size, zorder=5,
                markeredgecolor='black', markeredgewidth=1)
        label = f'{v}\nx={x_frac[v]:.2f}'
        ax.text(x + 0.2, y + 0.2, label, fontsize=7, zorder=6)

    ax.text(-2, -1.9, f'S₁ = {sorted(S1)}', fontsize=10, color='#4caf50', fontweight='bold')
    ax.text(-2, -2.1, f'Uncovered: {[f"e{i}" for i in uncovered]}',
            fontsize=9, color='#ff6b6b')

    ax.set_xlim(-2.5, 2.5)
    ax.set_ylim(-2.5, 2.5)
    ax.set_aspect('equal')
    ax.axis('off')

    # ── Panel 3: Conflict graph with coloring ──
    ax = axes[2]
    ax.set_title('Conflict Graph on Uncovered Edges\n(colored by greedy algorithm)', fontsize=13, fontweight='bold')

    # Build conflict graph
    conflicts = []
    for i in range(len(edges)):
        for j in range(i+1, len(edges)):
            if len(edges[i] & edges[j]) >= 2:
                conflicts.append((i, j))

    # Position edges as nodes
    edge_pos = {}
    n_e = len(edges)
    for i in range(n_e):
        angle = 2 * pi * i / n_e - pi/2
        edge_pos[i] = (1.2 * cos(angle), 1.2 * sin(angle))

    # Greedy coloring
    adj = {i: set() for i in range(n_e)}
    for i, j in conflicts:
        adj[i].add(j)
        adj[j].add(i)

    coloring = {}
    color_palette = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12', '#9b59b6', '#1abc9c']
    for v in range(n_e):
        used = {coloring[u] for u in adj[v] if u in coloring}
        c = 0
        while c in used:
            c += 1
        coloring[v] = c

    # Draw conflict edges
    for i, j in conflicts:
        x_vals = [edge_pos[i][0], edge_pos[j][0]]
        y_vals = [edge_pos[i][1], edge_pos[j][1]]
        ax.plot(x_vals, y_vals, 'k-', linewidth=1.5, alpha=0.4, zorder=1)
        # Label intersection
        inter = edges[i] & edges[j]
        mx = (x_vals[0] + x_vals[1]) / 2
        my = (y_vals[0] + y_vals[1]) / 2
        ax.text(mx, my, f'∩={sorted(inter)}', fontsize=6, ha='center',
                alpha=0.7, style='italic')

    # Draw edge nodes
    for i in range(n_e):
        x, y = edge_pos[i]
        c = coloring[i]
        ax.plot(x, y, 'o', color=color_palette[c % len(color_palette)],
                markersize=25, zorder=3, markeredgecolor='black', markeredgewidth=1.5)
        ax.text(x, y, f'e{i}', fontsize=9, ha='center', va='center',
                fontweight='bold', zorder=4)

    n_colors = max(coloring.values()) + 1
    max_deg = max(len(adj[v]) for v in range(n_e))
    ax.text(-1.8, -1.7, f'χ = {n_colors} colors', fontsize=11, fontweight='bold')
    ax.text(-1.8, -2.0, f'Δ = {max_deg} (max degree)', fontsize=10)
    ax.text(-1.8, -2.3, f'Bound: Δ+1 = {max_deg+1}', fontsize=10, color='#666')

    ax.set_xlim(-2.3, 2.3)
    ax.set_ylim(-2.5, 2.5)
    ax.set_aspect('equal')
    ax.axis('off')

    plt.tight_layout()
    plt.savefig('viz_conflict_graph.png', dpi=150, bbox_inches='tight')
    print("Saved viz_conflict_graph.png")


draw_hypergraph_and_conflict()


"""
Visualization: Double-Counting Edge Bound

Illustrates the Fisher-type inequality |E| · C(d,2) ≤ K · C(n,2)
by showing how the maximum number of edges grows with n and K
for different values of d. Also shows the empirical edge counts
from random hypergraphs to demonstrate tightness.

Uses matplotlib.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb
from itertools import combinations
import random


def generate_bounded_codegree_hypergraph(n, d, K, max_edges=200):
    """Generate a random d-uniform hypergraph with pair codegree ≤ K."""
    edges = []
    pair_count = {}
    verts = list(range(n))
    random.shuffle(verts)
    attempts = 0
    while attempts < 5000 and len(edges) < max_edges:
        edge = set(random.sample(range(n), d))
        pairs = list(combinations(sorted(edge), 2))
        if all(pair_count.get(p, 0) < K for p in pairs):
            edges.append(edge)
            for p in pairs:
                pair_count[p] = pair_count.get(p, 0) + 1
        attempts += 1
    return edges


fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# ── Left: Theoretical bounds ──
ax = axes[0]
n_vals = np.arange(5, 51)

for d, K, ls in [(3, 1, '-'), (3, 2, '--'), (4, 1, '-'), (4, 2, '--'), (5, 1, ':')]:
    bounds = [K * comb(n, 2) / comb(d, 2) for n in n_vals]
    ax.plot(n_vals, bounds, ls, linewidth=2, label=f'd={d}, K={K}')

ax.set_xlabel('Number of vertices n', fontsize=13)
ax.set_ylabel('Maximum number of edges', fontsize=13)
ax.set_title('Edge Count Bound: $|E| \\leq \\frac{K \\cdot \\binom{n}{2}}{\\binom{d}{2}}$',
             fontsize=14)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)
ax.set_ylim(0, 500)

# ── Right: Empirical vs theoretical ──
ax = axes[1]
random.seed(42)

d = 3
for K in [1, 2, 3]:
    n_range = list(range(6, 26, 2))
    theoretical = [K * comb(n, 2) / comb(d, 2) for n in n_range]
    empirical = []

    for n in n_range:
        counts = []
        for _ in range(20):
            edges = generate_bounded_codegree_hypergraph(n, d, K, max_edges=500)
            counts.append(len(edges))
        empirical.append(np.mean(counts))

    ax.plot(n_range, theoretical, '--', linewidth=2, alpha=0.6,
            color=f'C{K-1}', label=f'K={K} (bound)')
    ax.plot(n_range, empirical, 'o-', linewidth=1.5, markersize=5,
            color=f'C{K-1}', label=f'K={K} (empirical)')

ax.set_xlabel('Number of vertices n', fontsize=13)
ax.set_ylabel('Number of edges', fontsize=13)
ax.set_title('Empirical vs Theoretical Edge Count (d=3)\nDashes = bound, circles = random max',
             fontsize=14)
ax.legend(fontsize=10, ncol=2)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_edge_bound.png', dpi=150, bbox_inches='tight')
print("Saved viz_edge_bound.png")


"""
Visualization: Integrality Gap Landscape

Plots the theoretical upper bound on the integrality gap τ/τ* as a function
of the pair codegree K and uniformity d. Shows how the gap decreases from d
as K decreases, illustrating the sub-d barrier-breaking phenomenon.

Uses matplotlib to create a heatmap and contour plot.
"""

import numpy as np
import matplotlib.pyplot as plt

# Parameters
d_values = np.arange(3, 11)  # d from 3 to 10
K_values = np.arange(1, 21)  # K from 1 to 20

# Compute gap bounds: d - 1/(2d(K+1))
D, K = np.meshgrid(d_values, K_values)
gap_bound = D - 1.0 / (2.0 * D * (K + 1))

# Normalize: show gap/d (fraction of classical bound)
gap_ratio = gap_bound / D

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: Heatmap of gap bound
ax1 = axes[0]
im = ax1.imshow(gap_bound, aspect='auto', origin='lower',
                extent=[d_values[0]-0.5, d_values[-1]+0.5,
                        K_values[0]-0.5, K_values[-1]+0.5],
                cmap='RdYlGn_r')
ax1.set_xlabel('Uniformity d', fontsize=13)
ax1.set_ylabel('Pair Codegree Bound K', fontsize=13)
ax1.set_title('Integrality Gap Upper Bound\n$d - \\frac{1}{2d(K+1)}$', fontsize=14)
plt.colorbar(im, ax=ax1, label='Gap bound')

# Add contour lines
CS = ax1.contour(D, K, gap_bound, levels=[3, 4, 5, 6, 7, 8, 9],
                 colors='black', linewidths=0.8)
ax1.clabel(CS, inline=True, fontsize=9)

# Right: Gap improvement as percentage
ax2 = axes[1]
for d in [3, 4, 5, 7, 10]:
    improvement = 100 * (1 - (d - 1.0 / (2.0 * d * (K_values + 1))) / d)
    ax2.plot(K_values, improvement, 'o-', markersize=4, label=f'd = {d}')

ax2.set_xlabel('Pair Codegree Bound K', fontsize=13)
ax2.set_ylabel('Gap Improvement (%)', fontsize=13)
ax2.set_title('Improvement Over Classical d Bound\n$(1 - \\frac{\\text{gap bound}}{d}) \\times 100\\%$', fontsize=14)
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)
ax2.set_xlim(0.5, 20.5)

plt.tight_layout()
plt.savefig('viz_gap_landscape.png', dpi=150, bbox_inches='tight')
print("Saved viz_gap_landscape.png")
