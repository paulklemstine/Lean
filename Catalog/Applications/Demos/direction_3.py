#!/usr/bin/env python3
"""
applications.py — Real-World Applications of Tropical Convexity

Demonstrates how the tropical Carathéodory theorem and tropical convexity
connect to practical domains:
1. Shortest path problems (network optimization)
2. Mean-payoff games (verification/game theory)
3. Discrete event systems (control/scheduling)
4. Abstract interpretation (static analysis)
"""

import numpy as np
from typing import List, Tuple


# ============================================================================
# APPLICATION 1: Shortest Path via Max-Plus Algebra
# ============================================================================

def shortest_path_maxplus(adj_matrix: np.ndarray, source: int) -> np.ndarray:
    """
    Compute shortest paths using max-plus (actually min-plus) algebra.

    In tropical (min-plus) semiring, matrix multiplication computes
    shortest paths: (A⊗B)_{ij} = min_k(A_{ik} + B_{kj}).

    The tropical Carathéodory theorem implies that optimal paths
    need at most n intermediate vertices — a tropical certificate
    compression result.

    Parameters:
        adj_matrix: (n, n) adjacency matrix with edge weights (np.inf for no edge)
        source: source vertex index

    Returns:
        (n,) array of shortest distances from source
    """
    n = adj_matrix.shape[0]
    dist = np.full(n, np.inf)
    dist[source] = 0.0

    # Bellman-Ford (which IS tropical matrix iteration)
    for _ in range(n - 1):
        for u in range(n):
            for v in range(n):
                if dist[u] + adj_matrix[u, v] < dist[v]:
                    dist[v] = dist[u] + adj_matrix[u, v]

    return dist


def demo_shortest_path():
    """Demonstrate shortest paths as tropical semiring computation."""
    print("=" * 70)
    print("APPLICATION 1: Shortest Paths via Tropical Algebra")
    print("=" * 70)

    # Create a weighted graph
    n = 5
    INF = np.inf
    adj = np.array([
        [0,   3,   INF, 7,   INF],
        [INF, 0,   2,   INF, INF],
        [INF, INF, 0,   1,   5  ],
        [INF, INF, INF, 0,   2  ],
        [INF, INF, INF, INF, 0  ],
    ], dtype=float)

    print(f"\n  Graph with {n} vertices:")
    print(f"  Edges: 0→1(3), 0→3(7), 1→2(2), 2→3(1), 2→4(5), 3→4(2)")

    dist = shortest_path_maxplus(adj, 0)
    print(f"\n  Shortest distances from vertex 0:")
    for v in range(n):
        print(f"    d(0, {v}) = {dist[v]}")

    print(f"\n  Connection to tropical Carathéodory:")
    print(f"  Each shortest path uses at most n-1 = {n-1} edges (generators)")
    print(f"  This is the tropical Carathéodory bound for path compression")


# ============================================================================
# APPLICATION 2: Mean-Payoff Games
# ============================================================================

def mean_payoff_value(weights: np.ndarray, max_iters: int = 100) -> np.ndarray:
    """
    Compute mean-payoff game values using max-plus iteration.

    A mean-payoff game has positions with transition weights.
    The value at position i is the long-run average payoff.

    The connection: max-plus linear operators define the game dynamics,
    and their tropical eigenvalue (= spectral radius) gives the mean payoff.
    The tropical Carathéodory theorem provides certificate compression:
    optimal strategies need at most n+1 support positions.

    Parameters:
        weights: (n, n) matrix where weights[i][j] is payoff for transition i→j
                 (use -np.inf for invalid transitions)

    Returns:
        Approximate mean-payoff values for each position
    """
    n = weights.shape[0]
    v = np.zeros(n)

    for k in range(1, max_iters + 1):
        v_new = np.max(weights + v[None, :], axis=1)  # max-plus matrix-vector
        # Mean payoff approximation: v_k / k
        v = v_new

    return v / max_iters


def demo_mean_payoff():
    """Demonstrate mean-payoff game computation."""
    print("\n" + "=" * 70)
    print("APPLICATION 2: Mean-Payoff Games via Max-Plus Iteration")
    print("=" * 70)

    # Simple mean-payoff game
    INF = -np.inf
    W = np.array([
        [INF, 3,   1  ],
        [2,   INF, INF],
        [INF, 4,   INF],
    ], dtype=float)

    print(f"\n  Game with 3 positions:")
    print(f"  Transitions: 0→1(3), 0→2(1), 1→0(2), 2→1(4)")

    values = mean_payoff_value(W, max_iters=200)
    print(f"\n  Mean-payoff values (approximate):")
    for i in range(3):
        print(f"    v({i}) ≈ {values[i]:.4f}")

    print(f"\n  The optimal cycle: 0 →3→ 1 →2→ 0 has mean payoff (3+2)/2 = 2.5")
    print(f"  Tropical Carathéodory: optimal strategy needs ≤ n+1 = 4 support states")


# ============================================================================
# APPLICATION 3: Discrete Event Systems (Scheduling)
# ============================================================================

def discrete_event_simulation(processing_times: np.ndarray,
                               num_cycles: int = 10) -> List[np.ndarray]:
    """
    Simulate a discrete event system using max-plus algebra.

    In manufacturing/scheduling, the completion time of task i in cycle k+1 is:
    x_i(k+1) = max_j(A_{ij} + x_j(k))

    where A_{ij} is the time required between completing task j and starting task i.

    The tropical Carathéodory theorem implies: the long-run behavior depends
    on at most n+1 critical paths (generators), enabling schedule compression.

    Parameters:
        processing_times: (n, n) max-plus system matrix
        num_cycles: number of production cycles

    Returns:
        List of state vectors for each cycle
    """
    n = processing_times.shape[0]
    x = np.zeros(n)  # initial state
    trajectory = [x.copy()]

    for _ in range(num_cycles):
        x_new = np.zeros(n)
        for i in range(n):
            x_new[i] = np.max(processing_times[i, :] + x)
        x = x_new
        trajectory.append(x.copy())

    return trajectory


def demo_discrete_event():
    """Demonstrate discrete event system scheduling."""
    print("\n" + "=" * 70)
    print("APPLICATION 3: Discrete Event Systems (Manufacturing)")
    print("=" * 70)

    # Simple production line: 3 machines
    # A[i][j] = processing time from completion of j to start of i
    A = np.array([
        [5,   3,   -np.inf],  # Machine 0: self-loop 5, depends on machine 1 (3)
        [-np.inf, 4, 2     ],  # Machine 1: self-loop 4, depends on machine 2 (2)
        [1,   -np.inf, 3   ],  # Machine 2: depends on machine 0 (1), self-loop 3
    ], dtype=float)

    print(f"\n  Production system with 3 machines:")
    print(f"  Machine 0: processing time 5, input from Machine 1 (delay 3)")
    print(f"  Machine 1: processing time 4, input from Machine 2 (delay 2)")
    print(f"  Machine 2: input from Machine 0 (delay 1), processing time 3")

    trajectory = discrete_event_simulation(A, num_cycles=8)

    print(f"\n  Cycle completion times:")
    print(f"  {'Cycle':>6}  {'M0':>8}  {'M1':>8}  {'M2':>8}  {'Throughput':>10}")
    for k, x in enumerate(trajectory):
        if k > 0:
            throughput = (x - trajectory[k-1]).mean()
            print(f"  {k:>6}  {x[0]:>8.1f}  {x[1]:>8.1f}  {x[2]:>8.1f}  {throughput:>10.2f}")
        else:
            print(f"  {k:>6}  {x[0]:>8.1f}  {x[1]:>8.1f}  {x[2]:>8.1f}  {'—':>10}")

    # The asymptotic throughput is the max-plus eigenvalue
    growth_rates = []
    for k in range(3, len(trajectory)):
        rate = np.mean(trajectory[k] - trajectory[k-1])
        growth_rates.append(rate)

    print(f"\n  Asymptotic throughput (max-plus eigenvalue) ≈ {np.mean(growth_rates[-3:]):.2f}")
    print(f"  Tropical Carathéodory: critical path uses ≤ n+1 = 4 machine transitions")


# ============================================================================
# APPLICATION 4: Abstract Interpretation (Static Analysis)
# ============================================================================

def tropical_abstract_domain(constraints: List[Tuple[np.ndarray, float]],
                              dimension: int) -> dict:
    """
    Compute a tropical abstract domain for static analysis.

    In abstract interpretation, tropical polyhedra serve as abstract domains
    for programs with max-affine operations (e.g., ReLU networks, timing analysis).

    A tropical polyhedron is an intersection of tropical halfspaces:
    {x | max_i(a_i + x_i) ≤ max_i(b_i + x_i)}

    The tropical Carathéodory theorem guarantees certificate compression:
    any infeasibility certificate needs at most n+1 constraints.

    Parameters:
        constraints: list of (coefficient_vector, threshold) pairs
        dimension: space dimension

    Returns:
        dict with domain information
    """
    # Sample the feasible region
    np.random.seed(42)
    num_samples = 10000
    points = np.random.randn(num_samples, dimension) * 5

    feasible = []
    for x in points:
        is_feasible = True
        for a, threshold in constraints:
            if np.max(a + x) > threshold:
                is_feasible = False
                break
        if is_feasible:
            feasible.append(x)

    feasible = np.array(feasible) if feasible else np.empty((0, dimension))

    return {
        "dimension": dimension,
        "num_constraints": len(constraints),
        "feasible_count": len(feasible),
        "volume_fraction": len(feasible) / num_samples,
        "feasible_center": feasible.mean(axis=0) if len(feasible) > 0 else None,
    }


def demo_abstract_interpretation():
    """Demonstrate tropical abstract domains."""
    print("\n" + "=" * 70)
    print("APPLICATION 4: Abstract Interpretation (Tropical Domains)")
    print("=" * 70)

    # 2D tropical constraints (modeling a simple timing analysis)
    constraints = [
        (np.array([1.0, 0.0]), 3.0),   # max(1+x₀, 0+x₁) ≤ 3
        (np.array([0.0, 1.0]), 2.5),   # max(0+x₀, 1+x₁) ≤ 2.5
        (np.array([0.5, 0.5]), 2.0),   # max(0.5+x₀, 0.5+x₁) ≤ 2.0
    ]

    result = tropical_abstract_domain(constraints, dimension=2)

    print(f"\n  Tropical abstract domain in ℝ²:")
    print(f"  Number of constraints: {result['num_constraints']}")
    print(f"  Feasible fraction: {result['volume_fraction']:.2%}")
    if result['feasible_center'] is not None:
        print(f"  Approximate center: ({result['feasible_center'][0]:.2f}, {result['feasible_center'][1]:.2f})")

    print(f"\n  Application to static analysis:")
    print(f"  - Tropical polyhedra model timing constraints in synchronous circuits")
    print(f"  - Max-plus operations arise naturally in ReLU neural networks")
    print(f"  - The Carathéodory theorem enables sparse safety certificates:")
    print(f"    any infeasibility needs at most n+1 = 3 active constraints")


if __name__ == "__main__":
    demo_shortest_path()
    demo_mean_payoff()
    demo_discrete_event()
    demo_abstract_interpretation()
    print("\n" + "=" * 70)
    print("All applications demonstrated successfully!")
    print("=" * 70)


#!/usr/bin/env python3
"""
demo.py — Tropical Carathéodory Theorem: Concrete Demonstrations

Demonstrates the tropical Carathéodory theorem with numerical examples.
In max-plus convexity, any tropical linear combination of m generators in ℝⁿ
can be represented using at most n+1 generators.
"""

import numpy as np
from itertools import combinations


def trop_lin_comb(V, c):
    """
    Compute the tropical linear combination: for each coordinate i,
    x_i = max_j (c_j + V_j(i))

    Parameters:
        V: (m, n) array of generators
        c: (m,) array of coefficients
    Returns:
        (n,) array — the tropical combination
    """
    m, n = V.shape
    # Broadcast: c[:, None] + V has shape (m, n), take max over axis 0
    return np.max(c[:, None] + V, axis=0)


def trop_lin_comb_active(V, c):
    """
    Compute the tropical linear combination and return active generators.

    Returns:
        x: the tropical combination
        active: set of generator indices that are active on at least one coordinate
    """
    m, n = V.shape
    shifted = c[:, None] + V  # (m, n)
    x = np.max(shifted, axis=0)
    active = set()
    for i in range(n):
        for j in range(m):
            if np.isclose(shifted[j, i], x[i]):
                active.add(j)
                break  # one active generator per coordinate suffices
    return x, active


def find_caratheodory_subset(V, c):
    """
    Find a subset I of at most n+1 generators that reproduces the tropical combination.

    This implements the constructive proof of the tropical Carathéodory theorem:
    for each coordinate, extract the argmax generator.

    Returns:
        I: list of generator indices (|I| ≤ n+1)
        x: the tropical combination
    """
    m, n = V.shape
    shifted = c[:, None] + V  # (m, n)
    x = np.max(shifted, axis=0)

    # For each coordinate, find the argmax generator
    active = set()
    for i in range(n):
        j_star = np.argmax(shifted[:, i])
        active.add(j_star)

    # The active set has at most n elements; add one for nonemptiness guarantee
    I = sorted(active)
    if len(I) == 0:
        I = [0]

    # Verify: restriction to I gives the same result
    V_sub = V[I, :]
    c_sub = c[I]
    x_check = trop_lin_comb(V_sub, c_sub)
    assert np.allclose(x, x_check), f"Carathéodory verification failed! diff = {np.max(np.abs(x - x_check))}"

    return I, x


def demo_basic():
    """Basic demonstration of tropical linear combinations."""
    print("=" * 70)
    print("DEMO 1: Basic Tropical Linear Combination")
    print("=" * 70)

    # 3 generators in ℝ²
    V = np.array([
        [1.0, 2.0],   # Generator 0
        [3.0, 0.0],   # Generator 1
        [2.0, 1.0],   # Generator 2
    ])
    c = np.array([0.0, -1.0, 0.5])

    print(f"\nGenerators V (3 vectors in ℝ²):")
    for j in range(3):
        print(f"  V_{j} = {V[j]}")
    print(f"\nCoefficients c = {c}")

    x = trop_lin_comb(V, c)
    print(f"\nTropical combination x_i = max_j(c_j + V_j(i)):")
    for i in range(2):
        terms = [f"({c[j]:.1f} + {V[j,i]:.1f})" for j in range(3)]
        values = [c[j] + V[j,i] for j in range(3)]
        print(f"  x_{i} = max({', '.join(terms)}) = max({', '.join(f'{v:.1f}' for v in values)}) = {x[i]:.1f}")

    I, x_check = find_caratheodory_subset(V, c)
    print(f"\nCarathéodory subset: I = {I} (|I| = {len(I)} ≤ n+1 = {V.shape[1]+1})")
    print(f"Restricted combination matches: {np.allclose(x, x_check)}")


def demo_high_dimensional():
    """Demonstrate Carathéodory compression in higher dimension."""
    print("\n" + "=" * 70)
    print("DEMO 2: Carathéodory Compression (High Dimensional)")
    print("=" * 70)

    n = 5   # dimension
    m = 20  # number of generators

    np.random.seed(42)
    V = np.random.randn(m, n) * 3
    c = np.random.randn(m) * 2

    x = trop_lin_comb(V, c)
    I, x_check = find_caratheodory_subset(V, c)

    print(f"\n  Dimension n = {n}")
    print(f"  Number of generators m = {m}")
    print(f"  Carathéodory bound: n+1 = {n+1}")
    print(f"  Active generators: |I| = {len(I)}")
    print(f"  Generators used: I = {I}")
    print(f"  Compression ratio: {len(I)}/{m} = {len(I)/m:.1%}")
    print(f"  Exact match: {np.allclose(x, x_check)}")
    print(f"  Max error: {np.max(np.abs(x - x_check)):.2e}")


def demo_exhaustive_verification():
    """Exhaustively verify the theorem for many random instances."""
    print("\n" + "=" * 70)
    print("DEMO 3: Exhaustive Verification")
    print("=" * 70)

    np.random.seed(123)
    num_tests = 1000
    max_active = 0
    dims_tested = []

    for trial in range(num_tests):
        n = np.random.randint(1, 10)
        m = np.random.randint(1, 50)
        V = np.random.randn(m, n) * 5
        c = np.random.randn(m) * 3

        I, x = find_caratheodory_subset(V, c)
        assert len(I) <= n + 1, f"Carathéodory bound violated: |I|={len(I)} > n+1={n+1}"
        dims_tested.append((n, m, len(I)))
        max_active = max(max_active, len(I))

    print(f"\n  Tested {num_tests} random instances")
    print(f"  Dimensions n ∈ [1, 9], generators m ∈ [1, 49]")
    print(f"  All instances satisfied |I| ≤ n+1: ✓")
    print(f"  Maximum |I| observed: {max_active}")

    # Statistics by dimension
    from collections import defaultdict
    by_dim = defaultdict(list)
    for n, m, k in dims_tested:
        by_dim[n].append(k)

    print(f"\n  Average |I| by dimension:")
    for n in sorted(by_dim.keys()):
        vals = by_dim[n]
        print(f"    n={n}: avg |I| = {np.mean(vals):.2f}, max |I| = {max(vals)}, bound = {n+1}")


def demo_shift_invariance():
    """Demonstrate shift invariance of tropical combinations."""
    print("\n" + "=" * 70)
    print("DEMO 4: Shift Invariance")
    print("=" * 70)

    V = np.array([[1.0, 3.0], [2.0, 1.0], [0.0, 4.0]])
    c = np.array([1.0, 0.0, -1.0])
    d = 5.0

    x1 = trop_lin_comb(V, c)
    x2 = trop_lin_comb(V, c + d)

    print(f"\n  c = {c}")
    print(f"  d = {d}")
    print(f"  tropLinComb(V, c) = {x1}")
    print(f"  tropLinComb(V, c + d) = {x2}")
    print(f"  tropLinComb(V, c) + d = {x1 + d}")
    print(f"  Match: {np.allclose(x2, x1 + d)}")


def demo_idempotency():
    """Demonstrate tropical idempotency (mirror theorem)."""
    print("\n" + "=" * 70)
    print("DEMO 5: Tropical Idempotency (Mirror Theorem)")
    print("=" * 70)

    print("\n  The tropical mirror theorem: max(a, a) = a")
    for a in [-3.14, 0, 2.718, 42.0]:
        print(f"    max({a}, {a}) = {max(a, a)} ✓")

    # Duplicate generator doesn't change the combination
    V = np.array([[1.0, 2.0], [3.0, 0.0]])
    c = np.array([1.0, -1.0])
    x1 = trop_lin_comb(V, c)

    # Add a duplicate of generator 0 with a smaller coefficient
    V_dup = np.vstack([V, V[0:1, :]])
    c_dup = np.array([1.0, -1.0, 0.5])  # duplicate has smaller coeff
    x2 = trop_lin_comb(V_dup, c_dup)

    print(f"\n  Original: tropLinComb(V, c) = {x1}")
    print(f"  With duplicate (smaller coeff): tropLinComb(V', c') = {x2}")
    print(f"  Equal: {np.allclose(x1, x2)}")


def demo_tropical_hull():
    """Visualize a tropical convex hull in 2D (projective)."""
    print("\n" + "=" * 70)
    print("DEMO 6: Tropical Hull Sampling")
    print("=" * 70)

    V = np.array([
        [0.0, 0.0],
        [3.0, 1.0],
        [1.0, 4.0],
    ])

    print(f"\n  Generators:")
    for j in range(3):
        print(f"    V_{j} = {V[j]}")

    # Sample many points from the tropical hull
    np.random.seed(7)
    num_samples = 500
    points = []
    for _ in range(num_samples):
        c = np.random.randn(3) * 2
        x = trop_lin_comb(V, c)
        # Normalize: subtract max to project
        x = x - np.max(x)
        points.append(x)

    points = np.array(points)
    print(f"\n  Sampled {num_samples} points from tropical hull")
    print(f"  After projective normalization (subtract max):")
    print(f"    x range: [{points[:, 0].min():.2f}, {points[:, 0].max():.2f}]")
    print(f"    y range: [{points[:, 1].min():.2f}, {points[:, 1].max():.2f}]")


if __name__ == "__main__":
    demo_basic()
    demo_high_dimensional()
    demo_exhaustive_verification()
    demo_shift_invariance()
    demo_idempotency()
    demo_tropical_hull()
    print("\n" + "=" * 70)
    print("All demonstrations completed successfully!")
    print("=" * 70)


#!/usr/bin/env python3
"""Generate PACKAGE.json with all embedded content."""

import json
import base64
import os

# Read markdown files
def read_file(path):
    with open(path, 'r') as f:
        return f.read()

# Read and encode image
def encode_image(path):
    with open(path, 'rb') as f:
        data = base64.b64encode(f.read()).decode('utf-8')
    return f"data:image/png;base64,{data}"

article = read_file('/workspace/request-project/ARTICLE.md')
research_paper = read_file('/workspace/request-project/RESEARCH_PAPER.md')
future_directions = read_file('/workspace/request-project/FUTURE_DIRECTIONS.md')
lean_code = read_file('/workspace/request-project/Tropical/Caratheodory.lean')
demo_code = read_file('/workspace/request-project/demo.py')
algorithms_code = read_file('/workspace/request-project/algorithms.py')
applications_code = read_file('/workspace/request-project/applications.py')
viz_code = read_file('/workspace/request-project/visualizations.py')

# Encode images
img_hull = encode_image('/workspace/request-project/tropical_hull.png')
img_stats = encode_image('/workspace/request-project/caratheodory_stats.png')
img_des = encode_image('/workspace/request-project/discrete_event.png')

package = {
    "title": "Tropical Carathéodory Theorem: Formally Verified Max-Plus Convex Geometry",
    "domain": "Tropical Geometry / Max-Plus Convex Analysis",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Tropical Carathéodory Demonstration",
            "code": demo_code
        },
        {
            "name": "Real-World Applications",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Carathéodory Support Extraction",
            "pseudocode": """Algorithm: CaratheodoryExtract(V, c)
Input: Generators V ∈ ℝ^{m×n}, coefficients c ∈ ℝ^m
Output: Sparse index set I with |I| ≤ n

1. For each coordinate i = 1, ..., n:
     j*(i) ← argmax_j (c_j + V_j(i))
2. I ← {j*(1), ..., j*(n)}
3. Return I, tropLinComb(V[I], c[I])

Time: O(mn), Space: O(n)""",
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {
            "name": "Tropical Convex Hull and Carathéodory Compression",
            "data": img_hull
        },
        {
            "name": "Carathéodory Compression Statistics",
            "data": img_stats
        },
        {
            "name": "Discrete Event System Trajectory",
            "data": img_des
        }
    ],
    "lean_proofs": lean_code
}

with open('/workspace/request-project/PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json generated ({os.path.getsize('/workspace/request-project/PACKAGE.json') / 1024:.0f} KB)")


#!/usr/bin/env python3
"""
visualizations.py — Visualizations for Tropical Convexity

Generates publication-quality visualizations of tropical convex hulls,
Carathéodory compression, and tropical geometry.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
import base64
from io import BytesIO


def fig_to_base64(fig):
    """Convert matplotlib figure to base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def trop_lin_comb(V, c):
    return np.max(c[:, None] + V, axis=0)


def viz_tropical_hull_2d():
    """Visualize a tropical convex hull in 2D (projective coordinates)."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Generators
    V = np.array([
        [0.0, 0.0],
        [4.0, 1.0],
        [1.0, 5.0],
    ])

    # Sample the tropical hull
    np.random.seed(42)
    num_samples = 3000
    points = []
    for _ in range(num_samples):
        c = np.random.randn(3) * 3
        x = trop_lin_comb(V, c)
        x_proj = x - np.max(x)  # projective normalization
        points.append(x_proj)

    points = np.array(points)

    # Left: Raw tropical hull
    ax = axes[0]
    ax.scatter(points[:, 0], points[:, 1], s=1, alpha=0.3, c='steelblue')

    # Plot normalized generators
    for j in range(3):
        g = V[j] - np.max(V[j])
        ax.plot(g[0], g[1], 'r*', markersize=15, markeredgecolor='darkred', zorder=5)
        ax.annotate(f'$V_{j}$', (g[0]+0.1, g[1]+0.2), fontsize=14, color='darkred')

    ax.set_xlabel('$x_1 - \\max(x)$', fontsize=12)
    ax.set_ylabel('$x_2 - \\max(x)$', fontsize=12)
    ax.set_title('Tropical Convex Hull\n(Projective Coordinates)', fontsize=14)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)

    # Right: Carathéodory compression visualization
    ax = axes[1]
    m = 8
    V_big = np.random.randn(m, 2) * 3
    c_orig = np.random.randn(m) * 2

    shifted = c_orig[:, None] + V_big
    x = np.max(shifted, axis=0)

    # Find active set
    active = set()
    for i in range(2):
        j_star = np.argmax(shifted[:, i])
        active.add(j_star)

    colors = ['#e74c3c' if j in active else '#95a5a6' for j in range(m)]
    sizes = [200 if j in active else 80 for j in range(m)]

    for j in range(m):
        ax.scatter(V_big[j, 0], V_big[j, 1], c=colors[j], s=sizes[j],
                   edgecolors='black', linewidth=1, zorder=4)
        label = f'$V_{j}$'
        if j in active:
            label += ' ★'
        ax.annotate(label, (V_big[j, 0]+0.15, V_big[j, 1]+0.15),
                    fontsize=10, color=colors[j], fontweight='bold' if j in active else 'normal')

    ax.plot(x[0], x[1], 'k^', markersize=15, markeredgecolor='black', zorder=5)
    ax.annotate('$x$ (result)', (x[0]+0.15, x[1]+0.15), fontsize=12, fontweight='bold')

    # Draw lines from active generators to x
    for j in active:
        ax.plot([V_big[j, 0], x[0]], [V_big[j, 1], x[1]],
                'r-', linewidth=2, alpha=0.5, zorder=3)

    ax.set_xlabel('Coordinate 1', fontsize=12)
    ax.set_ylabel('Coordinate 2', fontsize=12)
    ax.set_title(f'Carathéodory Compression\n{m} generators → {len(active)} active (bound: n+1={3})',
                 fontsize=14)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    fig.savefig('/workspace/request-project/tropical_hull.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def viz_caratheodory_statistics():
    """Visualize Carathéodory compression statistics."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    np.random.seed(42)
    dims = range(1, 16)
    avg_active = []
    max_active = []
    bounds = []

    for n in dims:
        active_counts = []
        for _ in range(200):
            m = max(n + 5, 20)
            V = np.random.randn(m, n) * 3
            c = np.random.randn(m) * 2
            shifted = c[:, None] + V
            active = set()
            for i in range(n):
                j_star = np.argmax(shifted[:, i])
                active.add(j_star)
            active_counts.append(len(active))
        avg_active.append(np.mean(active_counts))
        max_active.append(np.max(active_counts))
        bounds.append(n + 1)

    # Left: Average vs bound
    ax = axes[0]
    ax.plot(list(dims), avg_active, 'o-', color='steelblue', linewidth=2,
            markersize=6, label='Average |I|')
    ax.plot(list(dims), max_active, 's--', color='coral', linewidth=2,
            markersize=6, label='Maximum |I|')
    ax.plot(list(dims), bounds, 'k:', linewidth=2, label='Bound (n+1)')
    ax.fill_between(list(dims), avg_active, bounds, alpha=0.1, color='green')
    ax.set_xlabel('Dimension n', fontsize=12)
    ax.set_ylabel('Number of Active Generators', fontsize=12)
    ax.set_title('Carathéodory Compression vs Dimension', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    # Right: Compression ratio
    ax = axes[1]
    ms = [5, 10, 20, 50, 100]
    for m_val in ms:
        ratios = []
        for n in range(1, min(m_val, 20)):
            active_counts = []
            for _ in range(100):
                V = np.random.randn(m_val, n) * 3
                c = np.random.randn(m_val) * 2
                shifted = c[:, None] + V
                active = set()
                for i in range(n):
                    j_star = np.argmax(shifted[:, i])
                    active.add(j_star)
                active_counts.append(len(active))
            ratios.append(np.mean(active_counts) / m_val)
        ax.plot(range(1, len(ratios)+1), ratios, 'o-', linewidth=2,
                markersize=5, label=f'm={m_val}')

    ax.set_xlabel('Dimension n', fontsize=12)
    ax.set_ylabel('Compression Ratio |I|/m', fontsize=12)
    ax.set_title('Tropical Compression Efficiency', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(0, 1.05)

    plt.tight_layout()
    fig.savefig('/workspace/request-project/caratheodory_stats.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def viz_discrete_event_trajectory():
    """Visualize discrete event system trajectory."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    # Production system
    A = np.array([
        [5,   3,   -np.inf],
        [-np.inf, 4, 2     ],
        [1,   -np.inf, 3   ],
    ], dtype=float)

    num_cycles = 15
    n = 3
    x = np.zeros(n)
    trajectories = [[] for _ in range(n)]

    for k in range(num_cycles + 1):
        for i in range(n):
            trajectories[i].append(x[i])
        if k < num_cycles:
            x_new = np.zeros(n)
            for i in range(n):
                x_new[i] = np.max(A[i, :] + x)
            x = x_new

    colors = ['#e74c3c', '#3498db', '#2ecc71']
    names = ['Machine 0', 'Machine 1', 'Machine 2']
    cycles = range(num_cycles + 1)

    for i in range(n):
        ax.plot(list(cycles), trajectories[i], 'o-', color=colors[i],
                linewidth=2, markersize=5, label=names[i])

    # Mark the asymptotic growth
    for i in range(n):
        if num_cycles > 5:
            rate = (trajectories[i][-1] - trajectories[i][-2])
            ax.annotate(f'rate ≈ {rate:.1f}',
                       (num_cycles, trajectories[i][-1]),
                       textcoords="offset points", xytext=(10, 0),
                       fontsize=10, color=colors[i])

    ax.set_xlabel('Production Cycle', fontsize=12)
    ax.set_ylabel('Completion Time', fontsize=12)
    ax.set_title('Discrete Event System: Max-Plus Dynamics\n'
                 '(Tropical Eigenvalue = Asymptotic Throughput)', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    fig.savefig('/workspace/request-project/discrete_event.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


if __name__ == "__main__":
    print("Generating visualizations...")
    b64_hull = viz_tropical_hull_2d()
    print(f"  tropical_hull.png generated ({len(b64_hull)} chars)")
    b64_stats = viz_caratheodory_statistics()
    print(f"  caratheodory_stats.png generated ({len(b64_stats)} chars)")
    b64_des = viz_discrete_event_trajectory()
    print(f"  discrete_event.png generated ({len(b64_des)} chars)")
    print("All visualizations saved!")
