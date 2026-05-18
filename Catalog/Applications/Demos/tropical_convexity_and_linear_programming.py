#!/usr/bin/env python3
"""
applications.py — Real-World Applications of Tropical Convexity

Demonstrates applications in:
1. Train scheduling (discrete event systems)
2. Timed automata / static analysis
3. Project scheduling (critical path)
4. Network routing optimization
"""

import numpy as np
from algorithms import (
    floyd_warshall_closure,
    bellman_ford_solve,
    make_diff_constraint_generators,
    tropical_convex_combination,
    tropical_normalize,
)


# ═══════════════════════════════════════════════════════════════
# Application 1: Train Scheduling
# ═══════════════════════════════════════════════════════════════

def train_scheduling_demo():
    """
    Model a simple train network as a system of difference constraints.

    Stations: A, B, C (indices 0, 1, 2)
    Constraints (minimum travel/dwell times):
    - Train from A→B takes at least 30 min: t_B - t_A ≥ 30
    - Train from B→C takes at least 20 min: t_C - t_B ≥ 20
    - Turnaround A→C takes at most 90 min: t_C - t_A ≤ 90
    - Connection at B needs 5 min dwell: already in t_B - t_A ≥ 30

    As difference constraints x_i - x_j ≤ c[i,j]:
    - t_A - t_B ≤ -30   (i.e., t_B ≥ t_A + 30)
    - t_B - t_C ≤ -20   (i.e., t_C ≥ t_B + 20)
    - t_C - t_A ≤ 90
    """
    print("=" * 60)
    print("APPLICATION 1: Train Scheduling")
    print("=" * 60)

    stations = ["Station A", "Station B", "Station C"]
    n = 3

    # Constraint matrix: c[i,j] = upper bound on t_i - t_j
    INF = 1000.0
    c = np.array([
        [0.0,  -30.0, INF],    # t_A - t_B ≤ -30
        [INF,  0.0,   -20.0],  # t_B - t_C ≤ -20
        [90.0, INF,   0.0],    # t_C - t_A ≤ 90
    ])

    print("Constraints:")
    print("  t_B - t_A ≥ 30 min (travel A→B)")
    print("  t_C - t_B ≥ 20 min (travel B→C)")
    print("  t_C - t_A ≤ 90 min (total journey limit)")

    # Compute closure
    closure, feasible = floyd_warshall_closure(c)
    print(f"\nFeasible schedule exists: {feasible}")

    if feasible:
        print("\nTightest implied constraints (closure):")
        for i in range(n):
            for j in range(n):
                if i != j and closure[i, j] < INF / 2:
                    print(f"  t_{stations[i]} - t_{stations[j]} ≤ {closure[i,j]:.0f} min")

        # Find a feasible schedule using Bellman-Ford
        edges = []
        for i in range(n):
            for j in range(n):
                if i != j and c[i, j] < INF / 2:
                    edges.append((i, j, c[i, j]))

        feas, schedule, _ = bellman_ford_solve(n, edges)
        if schedule is not None:
            # Shift so t_A = 8:00 (480 min from midnight)
            schedule = schedule - schedule[0] + 480
            print("\nOptimal schedule:")
            for i, s in enumerate(stations):
                hours, mins = divmod(int(schedule[i]), 60)
                print(f"  {s}: {hours:02d}:{mins:02d}")

        # Show the set of all feasible schedules as a tropical polytope
        V = make_diff_constraint_generators(closure)
        print("\nCanonical generators (extremal schedules):")
        for j in range(n):
            gen = V[j]
            print(f"  Extremal schedule {j}: {gen}")

    print()


# ═══════════════════════════════════════════════════════════════
# Application 2: Static Analysis (Timing Constraints)
# ═══════════════════════════════════════════════════════════════

def static_analysis_demo():
    """
    Model timing analysis for a digital circuit as difference constraints.

    Gates: A, B, C, D (indices 0-3)
    Propagation delays and setup/hold times create difference constraints.
    """
    print("=" * 60)
    print("APPLICATION 2: Digital Circuit Timing Analysis")
    print("=" * 60)

    gates = ["Input", "AND gate", "OR gate", "Output"]
    n = 4

    # Signal arrival times must satisfy propagation delays
    edges = [
        (1, 0, -2.0),  # AND gate ≥ Input + 2ns
        (2, 0, -3.0),  # OR gate ≥ Input + 3ns
        (2, 1, -1.5),  # OR gate ≥ AND + 1.5ns
        (3, 1, -2.0),  # Output ≥ AND + 2ns
        (3, 2, -1.0),  # Output ≥ OR + 1ns
        (3, 0, -10.0), # Output must be within 10ns of Input... wait
        (0, 3, -0.0),  # Actually: Output - Input ≤ 10ns
    ]

    # Use as: x_i ≤ w + x_j
    edges_clean = [
        (1, 0, -2.0),   # t_AND ≥ t_Input + 2
        (2, 0, -3.0),   # t_OR ≥ t_Input + 3
        (2, 1, -1.5),   # t_OR ≥ t_AND + 1.5
        (3, 1, -2.0),   # t_Output ≥ t_AND + 2
        (3, 2, -1.0),   # t_Output ≥ t_OR + 1
    ]

    print("Propagation constraints:")
    for (i, j, w) in edges_clean:
        print(f"  t_{gates[i]} ≥ t_{gates[j]} + {-w:.1f} ns")

    feas, timing, _ = bellman_ford_solve(n, edges_clean)
    print(f"\nFeasible: {feas}")
    if timing is not None:
        timing = timing - timing[0]  # Normalize input to 0
        print("Signal arrival times (ns from input):")
        for i, g in enumerate(gates):
            print(f"  {g}: {-timing[i]:.1f} ns")

        critical = -timing[3]
        print(f"\nCritical path delay: {critical:.1f} ns")

    print()


# ═══════════════════════════════════════════════════════════════
# Application 3: Project Scheduling (CPM)
# ═══════════════════════════════════════════════════════════════

def project_scheduling_demo():
    """
    Critical Path Method as tropical difference constraints.
    """
    print("=" * 60)
    print("APPLICATION 3: Project Scheduling (Critical Path)")
    print("=" * 60)

    tasks = ["Start", "Design", "Prototype", "Test", "Ship", "End"]
    n = 6

    # Task durations and dependencies
    # (successor, predecessor, min_duration)
    edges = [
        (1, 0, -0.0),   # Design after Start
        (2, 1, -5.0),   # Prototype after Design (5 weeks)
        (3, 2, -3.0),   # Test after Prototype (3 weeks)
        (4, 3, -2.0),   # Ship after Test (2 weeks)
        (5, 4, -1.0),   # End after Ship (1 week)
        (3, 1, -4.0),   # Test can also start 4 weeks after Design
        (5, 0, -15.0),  # Deadline: End within 15 weeks of Start
    ]

    print("Project constraints:")
    deps = [
        "Design starts at project start",
        "Prototype: 5 weeks after Design",
        "Testing: 3 weeks after Prototype",
        "Shipping: 2 weeks after Testing",
        "Completion: 1 week after Shipping",
        "Testing: at least 4 weeks after Design",
        "Deadline: 15 weeks from start",
    ]
    for d in deps:
        print(f"  • {d}")

    feas, schedule, neg_cycle = bellman_ford_solve(n, edges)
    print(f"\nFeasible within deadline: {feas}")

    if schedule is not None:
        schedule = schedule - schedule[0]
        print("\nEarliest schedule (weeks from start):")
        for i, t in enumerate(tasks):
            print(f"  {t}: week {-schedule[i]:.0f}")

        print(f"\nTotal project duration: {-schedule[5]:.0f} weeks")
        slack = 15 - (-schedule[5])
        print(f"Slack before deadline: {slack:.0f} weeks")
    else:
        print("Project cannot meet the deadline!")
        if neg_cycle:
            print(f"Conflict involves tasks: {[tasks[i] for i in neg_cycle]}")

    print()


# ═══════════════════════════════════════════════════════════════
# Application 4: Network Routing
# ═══════════════════════════════════════════════════════════════

def network_routing_demo():
    """
    Model network latency constraints as a tropical optimization problem.
    """
    print("=" * 60)
    print("APPLICATION 4: Network Latency Optimization")
    print("=" * 60)

    nodes = ["Client", "Edge Server", "CDN", "Origin", "Database"]
    n = 5

    # Latency constraints (ms): signal_i - signal_j ≤ c[i,j]
    c = np.array([
        [0,    10,   50,  200, 300],   # From Client
        [-5,   0,    20,  100, 200],   # From Edge
        [-20,  -10,  0,   30,  100],   # From CDN
        [-50,  -30,  -15, 0,   20],    # From Origin
        [-100, -80,  -50, -10, 0],     # From Database
    ], dtype=float)

    print("Network topology (latency bounds in ms):")
    for i in range(n):
        for j in range(n):
            if i != j and c[i, j] < 200:
                print(f"  {nodes[i]} → {nodes[j]}: ≤{c[i,j]:.0f} ms")

    closure, feasible = floyd_warshall_closure(c)
    print(f"\nConsistent latency model: {feasible}")

    if feasible:
        V = make_diff_constraint_generators(closure)
        print("\nExtremal latency profiles:")
        for j in range(n):
            v = tropical_normalize(V[j])
            print(f"  Profile {nodes[j]}-optimal: {v}")

        # Find a balanced latency assignment
        lam = np.full(n, -1.0)
        lam[0] = 0.0  # Favor client-optimal
        lam = tropical_normalize(lam)
        balanced = tropical_convex_combination(lam, V)
        balanced = tropical_normalize(balanced)
        print(f"\nBalanced latency profile: {balanced}")

    print()


# ═══════════════════════════════════════════════════════════════
# Main
# ═══════════════════════════════════════════════════════════════

if __name__ == "__main__":
    train_scheduling_demo()
    static_analysis_demo()
    project_scheduling_demo()
    network_routing_demo()

    print("=" * 60)
    print("All applications completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""Build PACKAGE.json from all deliverables."""
import json
import os

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

# Read all source files
article = read_file('/workspace/request-project/ARTICLE.md')
research_paper = read_file('/workspace/request-project/RESEARCH_PAPER.md')
future_directions = read_file('/workspace/request-project/FUTURE_DIRECTIONS.md')

# Read Lean files
lean_basic = read_file('/workspace/request-project/Tropical/Convexity/Basic.lean')
lean_diff = read_file('/workspace/request-project/Tropical/Convexity/DiffConstraints.lean')
lean_bf = read_file('/workspace/request-project/Tropical/Optimization/BellmanFord.lean')
lean_proofs = f"-- Tropical/Convexity/Basic.lean\n{lean_basic}\n\n-- Tropical/Convexity/DiffConstraints.lean\n{lean_diff}\n\n-- Tropical/Optimization/BellmanFord.lean\n{lean_bf}"

# Read Python files
demo_code = read_file('/workspace/request-project/demo.py')
algorithms_code = read_file('/workspace/request-project/algorithms.py')
applications_code = read_file('/workspace/request-project/applications.py')

# Read visualization data
viz_data = json.loads(read_file('/workspace/request-project/viz_data.json'))

# Build package
package = {
    "title": "Tropical Convexity, Minkowski-Weyl, and Algorithmic Tropical Optimization",
    "domain": "Tropical Mathematics / Combinatorial Optimization",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Tropical Algebra and Convex Hull Demo",
            "code": demo_code
        },
        {
            "name": "Applications: Scheduling, Circuits, and Networks",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Floyd-Warshall Closure",
            "pseudocode": "function FloydWarshallClosure(c):\n    d <- copy(c)\n    for k = 0 to n-1:\n        for i = 0 to n-1:\n            for j = 0 to n-1:\n                d[i,j] <- min(d[i,j], d[i,k] + d[k,j])\n    feasible <- all(d[i,i] >= 0)\n    return (d, feasible)\n\nComplexity: O(n^3) time, O(n^2) space",
            "code": algorithms_code
        },
        {
            "name": "Bellman-Ford Feasibility Solver",
            "pseudocode": "function BellmanFord(n, E):\n    dist <- array of n zeros\n    for iteration = 1 to n-1:\n        for (i, j, w) in E:\n            if dist[j] + w < dist[i]:\n                dist[i] <- dist[j] + w\n    for (i, j, w) in E:\n        if dist[j] + w < dist[i]:\n            return (infeasible, negative cycle)\n    return (feasible, dist)\n\nComplexity: O(n * |E|) time, O(n) space",
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {
            "name": "Tropical Convex Hull in 2D",
            "data": viz_data["tropical_hull_2d"]
        },
        {
            "name": "Difference-Constraint Polyhedron",
            "data": viz_data["diff_constraint"]
        },
        {
            "name": "Bellman-Ford Convergence",
            "data": viz_data["bellman_ford"]
        },
        {
            "name": "Tropical vs Classical Convexity",
            "data": viz_data["tropical_vs_classical"]
        }
    ],
    "lean_proofs": lean_proofs
}

with open('/workspace/request-project/PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2)

print(f"PACKAGE.json written ({os.path.getsize('/workspace/request-project/PACKAGE.json')} bytes)")


#!/usr/bin/env python3
"""
demo.py — Tropical Convexity Demonstrations

Concrete numerical examples illustrating tropical convex hulls,
difference-constraint polyhedra, and the Bellman-Ford feasibility test.
"""

import numpy as np
from itertools import product

# ─────────────────────────────────────────────────────────────
# 1. Basic tropical operations
# ─────────────────────────────────────────────────────────────

def tscale(a: float, x: np.ndarray) -> np.ndarray:
    """Tropical scalar multiplication: a ⊙ x = a + x (coordinate-wise)."""
    return a + x

def tadd(x: np.ndarray, y: np.ndarray) -> np.ndarray:
    """Tropical addition: x ⊕ y = max(x, y) (coordinate-wise)."""
    return np.maximum(x, y)

def trop_combination(lam: np.ndarray, V: np.ndarray) -> np.ndarray:
    """
    Tropical convex combination: x_i = max_j (lam_j + V[j,i]).
    V has shape (m, n), lam has shape (m,).
    """
    return np.max(lam[:, None] + V, axis=0)

print("=" * 60)
print("DEMO 1: Basic Tropical Algebra")
print("=" * 60)

x = np.array([3.0, 1.0, -2.0])
y = np.array([1.0, 4.0, 0.0])

print(f"x = {x}")
print(f"y = {y}")
print(f"x ⊕ y (trop add) = max(x,y) = {tadd(x, y)}")
print(f"2 ⊙ x (trop scale) = 2 + x = {tscale(2.0, x)}")
print(f"x ⊕ x = x (idempotent) = {tadd(x, x)}")
print(f"  Verified: {np.allclose(tadd(x, x), x)}")

a, b = -1.0, 0.0  # max(a,b) = 0, normalized
z = tadd(tscale(a, x), tscale(b, y))
print(f"\nTropical combination with λ=({a},{b}), max(λ)={max(a,b)}:")
print(f"  max({a}+x, {b}+y) = {z}")

# ─────────────────────────────────────────────────────────────
# 2. Tropical convex hull
# ─────────────────────────────────────────────────────────────

print("\n" + "=" * 60)
print("DEMO 2: Tropical Convex Hull of 3 Points in R^2")
print("=" * 60)

V = np.array([
    [0.0, -1.0],   # generator 0
    [-1.0, 0.0],   # generator 1
    [-0.5, -0.5],  # generator 2
])

print("Generators V:")
for j, v in enumerate(V):
    print(f"  v_{j} = {v}")

# Sample the hull by varying lambda
print("\nSampled points in TropConvHull(V):")
for lam_raw in [(1, 0, 0), (0, 1, 0), (0, 0, 1), (0.5, 0.5, 0), (0.5, 0, 0.5)]:
    lam = np.array(lam_raw, dtype=float)
    lam = lam - np.max(lam)  # normalize so max = 0
    pt = trop_combination(lam, V)
    print(f"  λ = {lam} → x = {pt}")

# ─────────────────────────────────────────────────────────────
# 3. Difference-constraint polyhedron
# ─────────────────────────────────────────────────────────────

print("\n" + "=" * 60)
print("DEMO 3: Difference-Constraint Polyhedron")
print("=" * 60)

n = 3
# Create a closed constraint matrix (Floyd-Warshall closure)
c = np.array([
    [0.0, 2.0, 3.0],
    [1.0, 0.0, 1.0],
    [2.0, 3.0, 0.0],
])

print("Constraint matrix c (x_i - x_j ≤ c[i,j]):")
print(c)

# Verify closure properties
print(f"\nDiagonal zeros: {all(c[i,i] == 0 for i in range(n))}")
triangle_ok = all(
    c[i,k] <= c[i,j] + c[j,k] + 1e-10
    for i, j, k in product(range(n), repeat=3)
)
print(f"Triangle inequality: {triangle_ok}")

# Canonical generators: V[j,i] = -c[j,i]
V_gen = -c  # V_gen[j,i] = -c[j,i]
print("\nCanonical generators (columns of -c^T):")
for j in range(n):
    gen = V_gen[j]
    print(f"  v_{j} = {gen}")

# Verify generators satisfy constraints
print("\nVerifying generators satisfy constraints:")
for j in range(n):
    gen = V_gen[j]
    ok = all(gen[i] - gen[k] <= c[i,k] + 1e-10 for i, k in product(range(n), repeat=2))
    print(f"  v_{j} feasible: {ok}")

# Test a feasible point
x_test = np.array([-0.5, -1.0, -1.5])
feasible = all(x_test[i] - x_test[k] <= c[i,k] + 1e-10 for i, k in product(range(n), repeat=2))
print(f"\nx_test = {x_test}, feasible: {feasible}")

# Show it's a tropical combination (normalize first)
x_norm = x_test - np.max(x_test)
print(f"Normalized: {x_norm} (max = {np.max(x_norm)})")

# The lambda coefficients are just x_norm
lam_test = x_norm.copy()
recon = trop_combination(lam_test, V_gen)
print(f"λ = x_norm = {lam_test}")
print(f"Reconstruction max_j(λ_j + V[j,i]) = {recon}")
print(f"Matches normalized x: {np.allclose(recon, x_norm)}")

# ─────────────────────────────────────────────────────────────
# 4. Bellman-Ford feasibility
# ─────────────────────────────────────────────────────────────

print("\n" + "=" * 60)
print("DEMO 4: Bellman-Ford Feasibility Check")
print("=" * 60)

def bellman_ford_feasibility(n: int, edges: list) -> tuple:
    """
    Check feasibility of x_i ≤ w + x_j for edges (i, j, w).
    Returns (feasible: bool, witness: array or None).
    """
    dist = np.zeros(n)

    # Relax n-1 times
    for _ in range(n - 1):
        for (i, j, w) in edges:
            if dist[i] > w + dist[j]:
                dist[i] = w + dist[j]

    # Check for negative cycles
    for (i, j, w) in edges:
        if dist[i] > w + dist[j] + 1e-12:
            return False, None

    return True, dist

# System 1: Feasible
edges1 = [
    (0, 1, 3.0),   # x0 ≤ 3 + x1
    (1, 2, -1.0),  # x1 ≤ -1 + x2
    (2, 0, 1.0),   # x2 ≤ 1 + x0
]
print("System 1 (feasible):")
for (i, j, w) in edges1:
    print(f"  x_{i} ≤ {w} + x_{j}")

feas, witness = bellman_ford_feasibility(3, edges1)
print(f"Feasible: {feas}")
if witness is not None:
    print(f"Witness: x = {witness}")
    for (i, j, w) in edges1:
        print(f"  x_{i}={witness[i]:.2f} ≤ {w}+x_{j}={w+witness[j]:.2f}: {witness[i] <= w + witness[j] + 1e-10}")

# System 2: Infeasible (negative cycle)
edges2 = [
    (0, 1, 1.0),   # x0 ≤ 1 + x1
    (1, 2, -2.0),  # x1 ≤ -2 + x2
    (2, 0, 0.0),   # x2 ≤ 0 + x0
]
print("\nSystem 2 (infeasible — negative cycle of weight -1):")
for (i, j, w) in edges2:
    print(f"  x_{i} ≤ {w} + x_{j}")
cycle_weight = sum(w for (_, _, w) in edges2)
print(f"Cycle weight: {cycle_weight}")

feas2, _ = bellman_ford_feasibility(3, edges2)
print(f"Feasible: {feas2}")

print("\n" + "=" * 60)
print("All demos completed successfully!")
print("=" * 60)


#!/usr/bin/env python3
"""
visualizations.py — Tropical Convexity Visualizations

Generates publication-quality figures illustrating tropical convex hulls,
difference-constraint polyhedra, and the Bellman-Ford algorithm.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
import base64
from io import BytesIO


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 PNG data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


# ═══════════════════════════════════════════════════════════════
# Figure 1: Tropical Convex Hull in 2D
# ═══════════════════════════════════════════════════════════════

def plot_tropical_hull_2d():
    """Plot a tropical convex hull of 3 points in R^2 (normalized)."""
    fig, ax = plt.subplots(1, 1, figsize=(8, 7))

    V = np.array([
        [0.0, -2.0],
        [-1.0, 0.0],
        [-1.5, -0.5],
    ])

    # Sample hull by varying lambda
    hull_points = []
    N = 200
    for i in range(N):
        for j in range(N - i):
            k = N - 1 - i - j
            lam = np.array([i, j, k], dtype=float) / (N - 1)
            lam = np.log(lam + 1e-8)  # Map to log scale
            lam = lam - np.max(lam)  # Normalize
            pt = np.max(lam[:, None] + V, axis=0)
            hull_points.append(pt)

    hull_points = np.array(hull_points)

    # Also sample with uniform lambda grid
    hull_uniform = []
    for a in np.linspace(-3, 0, 50):
        for b in np.linspace(-3, 0, 50):
            lam = np.array([0, a, b])
            lam = lam - np.max(lam)
            pt = np.max(lam[:, None] + V, axis=0)
            hull_uniform.append(pt)
    hull_uniform = np.array(hull_uniform)

    ax.scatter(hull_uniform[:, 0], hull_uniform[:, 1], c='lightblue', s=2, alpha=0.5, label='Hull interior')
    ax.scatter(hull_points[:, 0], hull_points[:, 1], c='steelblue', s=1, alpha=0.3)

    # Plot generators
    for i, v in enumerate(V):
        ax.plot(v[0], v[1], 'ro', markersize=12, zorder=5)
        ax.annotate(f'$v_{i}$', v, fontsize=14, fontweight='bold',
                   xytext=(10, 10), textcoords='offset points')

    # Plot tropical segments between generators
    for i in range(len(V)):
        for j in range(i + 1, len(V)):
            seg_pts = []
            for t in np.linspace(-5, 0, 200):
                lam = np.array([0.0, t]) if i == 0 else np.array([t, 0.0])
                lam_full = np.full(len(V), -10.0)
                lam_full[i] = lam[0]
                lam_full[j] = lam[1]
                lam_full = lam_full - np.max(lam_full)
                pt = np.max(lam_full[:, None] + V, axis=0)
                seg_pts.append(pt)
            seg_pts = np.array(seg_pts)
            ax.plot(seg_pts[:, 0], seg_pts[:, 1], 'r-', linewidth=1.5, alpha=0.7)

    ax.set_xlabel('$x_1$', fontsize=14)
    ax.set_ylabel('$x_2$', fontsize=14)
    ax.set_title('Tropical Convex Hull of Three Points in $\\mathbb{R}^2$', fontsize=16)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)
    ax.legend(fontsize=12)

    fig.savefig('/workspace/request-project/tropical_hull_2d.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


# ═══════════════════════════════════════════════════════════════
# Figure 2: Difference-Constraint Polyhedron
# ═══════════════════════════════════════════════════════════════

def plot_diff_constraint_polyhedron():
    """Plot a difference-constraint polyhedron in 2D (projected)."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: The constraint graph
    ax = axes[0]
    n = 3
    c = np.array([
        [0.0, 2.0, 3.0],
        [1.0, 0.0, 1.0],
        [2.0, 3.0, 0.0],
    ])

    positions = np.array([[0, 1], [1, -0.5], [-1, -0.5]], dtype=float)
    labels = ['$x_0$', '$x_1$', '$x_2$']

    for i in range(n):
        circle = plt.Circle(positions[i], 0.15, color='steelblue', zorder=5)
        ax.add_patch(circle)
        ax.text(positions[i][0], positions[i][1], labels[i],
               ha='center', va='center', fontsize=12, color='white',
               fontweight='bold', zorder=6)

    for i in range(n):
        for j in range(n):
            if i != j:
                dx = positions[j] - positions[i]
                dist = np.linalg.norm(dx)
                dx_norm = dx / dist
                start = positions[i] + 0.18 * dx_norm
                end = positions[j] - 0.18 * dx_norm

                offset = np.array([-dx_norm[1], dx_norm[0]]) * 0.08
                mid = (start + end) / 2 + offset

                ax.annotate('', xy=end + offset, xytext=start + offset,
                          arrowprops=dict(arrowstyle='->', color='gray',
                                        connectionstyle='arc3,rad=0.15',
                                        lw=1.5))
                ax.text(mid[0] + offset[0]*2, mid[1] + offset[1]*2,
                       f'{c[i,j]:.0f}', fontsize=10, ha='center', va='center',
                       color='darkred', fontweight='bold')

    ax.set_xlim(-1.8, 1.8)
    ax.set_ylim(-1.2, 1.6)
    ax.set_aspect('equal')
    ax.set_title('Constraint Graph\n$x_i - x_j \\leq c_{ij}$', fontsize=14)
    ax.axis('off')

    # Right: Feasible set (projected to x1-x2 plane, x0=0)
    ax = axes[1]

    x1_range = np.linspace(-3, 3, 300)
    x2_range = np.linspace(-3, 3, 300)
    X1, X2 = np.meshgrid(x1_range, x2_range)

    feasible = np.ones_like(X1, dtype=bool)
    x = np.zeros(3)
    for ii in range(len(x1_range)):
        for jj in range(len(x2_range)):
            x[0], x[1], x[2] = 0, X1[jj, ii], X2[jj, ii]
            ok = True
            for i in range(n):
                for j in range(n):
                    if x[i] - x[j] > c[i, j] + 1e-10:
                        ok = False
                        break
                if not ok:
                    break
            feasible[jj, ii] = ok

    ax.contourf(X1, X2, feasible.astype(float), levels=[0.5, 1.5],
               colors=['lightblue'], alpha=0.7)
    ax.contour(X1, X2, feasible.astype(float), levels=[0.5],
              colors=['steelblue'], linewidths=2)

    # Plot generators (normalized with x0=0)
    V = -c
    for j in range(n):
        gen = V[j] - V[j, 0]  # Normalize so x0 = 0
        ax.plot(gen[1], gen[2], 'ro', markersize=10, zorder=5)
        ax.annotate(f'$v_{j}$', (gen[1], gen[2]), fontsize=12,
                   xytext=(8, 8), textcoords='offset points', fontweight='bold')

    ax.set_xlabel('$x_1$ (with $x_0 = 0$)', fontsize=12)
    ax.set_ylabel('$x_2$ (with $x_0 = 0$)', fontsize=12)
    ax.set_title('Feasible Region\n(Difference-Constraint Polyhedron)', fontsize=14)
    ax.grid(True, alpha=0.3)
    ax.set_aspect('equal')

    plt.tight_layout()
    fig.savefig('/workspace/request-project/diff_constraint.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


# ═══════════════════════════════════════════════════════════════
# Figure 3: Bellman-Ford Convergence
# ═══════════════════════════════════════════════════════════════

def plot_bellman_ford_convergence():
    """Visualize Bellman-Ford relaxation convergence."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    n = 4
    edges = [
        (1, 0, 3),
        (2, 1, -1),
        (3, 2, 2),
        (2, 0, 5),
        (3, 1, 4),
        (0, 3, -2),
    ]

    # Track distances over iterations
    dist_history = [np.zeros(n).copy()]
    dist = np.zeros(n)

    for iteration in range(n):
        for (i, j, w) in edges:
            if dist[j] + w < dist[i]:
                dist[i] = dist[j] + w
        dist_history.append(dist.copy())

    dist_history = np.array(dist_history)

    # Left plot: convergence curves
    ax = axes[0]
    colors = ['#e74c3c', '#3498db', '#2ecc71', '#9b59b6']
    for v in range(n):
        ax.plot(range(len(dist_history)), dist_history[:, v],
               'o-', color=colors[v], linewidth=2, markersize=6,
               label=f'$x_{v}$')

    ax.set_xlabel('Iteration', fontsize=12)
    ax.set_ylabel('Distance', fontsize=12)
    ax.set_title('Bellman-Ford Relaxation Convergence', fontsize=14)
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)
    ax.set_xticks(range(len(dist_history)))

    # Right plot: constraint graph
    ax = axes[1]
    positions = np.array([[0, 1], [1.5, 1], [1.5, -0.5], [0, -0.5]], dtype=float)
    node_labels = ['$x_0$', '$x_1$', '$x_2$', '$x_3$']

    for i in range(n):
        circle = plt.Circle(positions[i], 0.2, color=colors[i], zorder=5)
        ax.add_patch(circle)
        ax.text(positions[i][0], positions[i][1], node_labels[i],
               ha='center', va='center', fontsize=12, color='white',
               fontweight='bold', zorder=6)
        # Show final distance
        ax.text(positions[i][0], positions[i][1] - 0.4,
               f'{dist_history[-1, i]:.0f}', ha='center', fontsize=10,
               color=colors[i], fontweight='bold')

    for (i, j, w) in edges:
        dx = positions[i] - positions[j]
        dist_val = np.linalg.norm(dx)
        dx_norm = dx / dist_val
        start = positions[j] + 0.22 * dx_norm
        end = positions[i] - 0.22 * dx_norm

        offset = np.array([-dx_norm[1], dx_norm[0]]) * 0.05
        mid = (start + end) / 2

        ax.annotate('', xy=end + offset, xytext=start + offset,
                   arrowprops=dict(arrowstyle='->', color='gray',
                                 connectionstyle='arc3,rad=0.2', lw=1.5))
        ax.text(mid[0] + offset[0]*4, mid[1] + offset[1]*4,
               f'{w}', fontsize=10, ha='center', va='center',
               color='darkred', fontweight='bold',
               bbox=dict(boxstyle='round,pad=0.2', facecolor='lightyellow',
                        edgecolor='none', alpha=0.8))

    ax.set_xlim(-0.8, 2.3)
    ax.set_ylim(-1.2, 1.6)
    ax.set_aspect('equal')
    ax.set_title('Constraint Graph\n$x_i \\leq w + x_j$', fontsize=14)
    ax.axis('off')

    plt.tight_layout()
    fig.savefig('/workspace/request-project/bellman_ford.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


# ═══════════════════════════════════════════════════════════════
# Figure 4: Tropical vs Classical Convexity
# ═══════════════════════════════════════════════════════════════

def plot_tropical_vs_classical():
    """Compare tropical and classical convex hulls."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    points = np.array([[0, -2], [-2, 0], [-1, -1]])

    # Left: Classical convex hull
    ax = axes[0]
    from matplotlib.patches import Polygon

    # Classical hull is a triangle
    hull_verts = points[np.array([0, 1, 2, 0])]
    poly = Polygon(hull_verts[:3], alpha=0.3, color='orange', label='Classical hull')
    ax.add_patch(poly)
    ax.plot(hull_verts[:, 0], hull_verts[:, 1], 'o-', color='darkorange',
           linewidth=2, markersize=10)

    for i, p in enumerate(points):
        ax.annotate(f'$p_{i}$', p, fontsize=14, fontweight='bold',
                   xytext=(10, 10), textcoords='offset points')

    ax.set_xlabel('$x_1$', fontsize=14)
    ax.set_ylabel('$x_2$', fontsize=14)
    ax.set_title('Classical Convex Hull', fontsize=16)
    ax.set_xlim(-3, 1)
    ax.set_ylim(-3, 1)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)
    ax.legend(fontsize=12)

    # Right: Tropical convex hull
    ax = axes[1]

    # Sample tropical hull densely
    V = points.astype(float)
    hull_pts = []
    for a in np.linspace(-5, 0, 100):
        for b in np.linspace(-5, 0, 100):
            for c_val in np.linspace(-5, 0, 30):
                lam = np.array([a, b, c_val])
                lam = lam - np.max(lam)
                pt = np.max(lam[:, None] + V, axis=0)
                hull_pts.append(pt)

    hull_pts = np.array(hull_pts)

    ax.scatter(hull_pts[:, 0], hull_pts[:, 1], c='lightblue', s=1, alpha=0.2)

    # Tropical segments (piecewise linear)
    for i in range(len(V)):
        for j in range(i + 1, len(V)):
            seg = []
            for t in np.linspace(-10, 0, 500):
                lam = np.full(len(V), -100.0)
                lam[i] = 0
                lam[j] = t
                lam = lam - np.max(lam)
                pt = np.max(lam[:, None] + V, axis=0)
                seg.append(pt)
            seg = np.array(seg)
            ax.plot(seg[:, 0], seg[:, 1], 'b-', linewidth=1.5, alpha=0.7)

    for i, p in enumerate(points):
        ax.plot(p[0], p[1], 'ro', markersize=10, zorder=5)
        ax.annotate(f'$p_{i}$', p, fontsize=14, fontweight='bold',
                   xytext=(10, 10), textcoords='offset points')

    ax.set_xlabel('$x_1$', fontsize=14)
    ax.set_ylabel('$x_2$', fontsize=14)
    ax.set_title('Tropical Convex Hull', fontsize=16)
    ax.set_xlim(-3, 1)
    ax.set_ylim(-3, 1)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    fig.savefig('/workspace/request-project/tropical_vs_classical.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


# ═══════════════════════════════════════════════════════════════
# Main
# ═══════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("Generating visualizations...")

    b64_hull = plot_tropical_hull_2d()
    print(f"  tropical_hull_2d.png ({len(b64_hull)} chars)")

    b64_diff = plot_diff_constraint_polyhedron()
    print(f"  diff_constraint.png ({len(b64_diff)} chars)")

    b64_bf = plot_bellman_ford_convergence()
    print(f"  bellman_ford.png ({len(b64_diff)} chars)")

    b64_comp = plot_tropical_vs_classical()
    print(f"  tropical_vs_classical.png ({len(b64_comp)} chars)")

    print("\nAll visualizations generated successfully!")

    # Save base64 data for JSON package
    import json
    viz_data = {
        "tropical_hull_2d": b64_hull,
        "diff_constraint": b64_diff,
        "bellman_ford": b64_bf,
        "tropical_vs_classical": b64_comp,
    }
    with open('/workspace/request-project/viz_data.json', 'w') as f:
        json.dump(viz_data, f)
    print("Saved visualization data to viz_data.json")
