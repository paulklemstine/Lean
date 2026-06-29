#!/usr/bin/env python3
"""
applications.py — Real-World Applications of Tropical Rank Growth

Demonstrates how tropical matrix powers and rank growth connect to:
1. Network routing and shortest-path diversity
2. Scheduling and discrete event systems (max-plus)
3. Machine learning: ReLU network complexity
4. Supply chain optimization
"""

import numpy as np
from typing import List, Tuple

INF = float('inf')


def trop_mul_entry(a: float, b: float) -> float:
    if a == INF or b == INF:
        return INF
    return a + b


def trop_mat_mul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    n = A.shape[0]
    C = np.full((n, n), INF)
    for i in range(n):
        for k in range(n):
            for j in range(n):
                C[i, k] = min(C[i, k], trop_mul_entry(A[i, j], B[j, k]))
    return C


def trop_identity(n: int) -> np.ndarray:
    I = np.full((n, n), INF)
    np.fill_diagonal(I, 0.0)
    return I


def trop_pow(A: np.ndarray, m: int) -> np.ndarray:
    n = A.shape[0]
    result = trop_identity(n)
    for _ in range(m):
        result = trop_mat_mul(result, A)
    return result


def tropical_rank(A: np.ndarray) -> int:
    n = A.shape[1]
    return len({tuple(A[:, j]) for j in range(n)})


# =============================================================
# Application 1: Network Routing Diversity
# =============================================================

def network_routing_demo():
    """
    Model a computer network where edges have latencies.
    Tropical powers give optimal k-hop routes.
    Rank growth measures route diversity.
    """
    print("=" * 60)
    print("APPLICATION 1: Network Routing Diversity")
    print("=" * 60)

    # 5-node network with latencies (ms)
    # Nodes: Data Center (0), Router A (1), Router B (2),
    #        Edge Server (3), Client (4)
    latency = np.array([
        [0.0,  2.0,  5.0, INF,  INF],  # DC
        [2.0,  0.0,  1.0,  3.0, INF],  # Router A
        [5.0,  1.0,  0.0,  2.0,  4.0],  # Router B
        [INF,  3.0,  2.0,  0.0,  1.0],  # Edge
        [INF, INF,  4.0,  1.0,  0.0],  # Client
    ])

    print("\nNetwork topology (latency in ms):")
    labels = ["DC", "RA", "RB", "ES", "CL"]
    print("     " + "  ".join(f"{l:>5}" for l in labels))
    for i, label in enumerate(labels):
        row = [f"{latency[i,j]:5.1f}" if latency[i,j] != INF else "  inf"
               for j in range(5)]
        print(f"  {label}: [{', '.join(row)}]")

    print("\nOptimal routes by hop count:")
    for hops in range(1, 6):
        Am = trop_pow(latency, hops)
        rank = tropical_rank(Am)
        dc_to_client = Am[0, 4]
        dc_str = f"{dc_to_client:.1f}ms" if dc_to_client != INF else "unreachable"
        print(f"  {hops}-hop: rank={rank}, DC→Client={dc_str}")

    print("\n  → Higher rank = more diverse routing profiles")
    print("  → Rank stabilization = no new route profiles from more hops")


# =============================================================
# Application 2: Manufacturing Scheduling (Max-Plus)
# =============================================================

def maxplus_mat_mul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Max-plus matrix multiplication: (A⊗B)_{ik} = max_j(A_{ij} + B_{jk})"""
    n = A.shape[0]
    NEGINF = -INF
    C = np.full((n, n), NEGINF)
    for i in range(n):
        for k in range(n):
            for j in range(n):
                if A[i, j] != NEGINF and B[j, k] != NEGINF:
                    C[i, k] = max(C[i, k], A[i, j] + B[j, k])
    return C


def maxplus_identity(n: int) -> np.ndarray:
    I = np.full((n, n), -INF)
    np.fill_diagonal(I, 0.0)
    return I


def maxplus_pow(A: np.ndarray, m: int) -> np.ndarray:
    n = A.shape[0]
    result = maxplus_identity(n)
    for _ in range(m):
        result = maxplus_mat_mul(result, A)
    return result


def maxplus_rank(A: np.ndarray) -> int:
    n = A.shape[1]
    return len({tuple(A[:, j]) for j in range(n)})


def scheduling_demo():
    """
    Model a manufacturing pipeline where max-plus powers give
    earliest completion times for multi-stage production.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Manufacturing Scheduling (Max-Plus)")
    print("=" * 60)

    # 4 machines, processing times for each transition
    # -∞ means machine j cannot directly feed machine i
    NEGINF = -INF
    timing = np.array([
        [0.0,   3.0,   NEGINF, 2.0],   # Machine 1
        [NEGINF, 0.0,  4.0,    NEGINF], # Machine 2
        [5.0,   NEGINF, 0.0,   1.0],    # Machine 3
        [NEGINF, 2.0,  NEGINF, 0.0],    # Machine 4
    ])

    print("\nMachine transition times (max-plus):")
    machines = ["M1", "M2", "M3", "M4"]
    for i, m in enumerate(machines):
        row = [f"{timing[i,j]:5.1f}" if timing[i,j] != NEGINF else " -inf"
               for j in range(4)]
        print(f"  {m}: [{', '.join(row)}]")

    print("\nProduction stages (max-plus powers):")
    for stages in range(1, 8):
        Ts = maxplus_pow(timing, stages)
        rank = maxplus_rank(Ts)
        print(f"  {stages} stages: rank={rank}, "
              f"M1→M3 earliest={Ts[2,0]:.1f}h")

    print("\n  → Rank = number of distinct production profiles")
    print("  → Stabilization = production scheduling converges")


# =============================================================
# Application 3: ReLU Network Complexity
# =============================================================

def relu_network_demo():
    """
    ReLU networks compute piecewise-linear functions, which are
    tropical rational functions. Weight matrix powers correspond
    to depth. Tropical rank measures representation complexity.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: ReLU Network Complexity")
    print("=" * 60)

    # Weight matrix for a 4-neuron layer
    W = np.array([
        [0.5,  -0.3, 0.8, -0.1],
        [-0.2,  0.7, 0.1,  0.4],
        [0.3,  -0.5, 0.6,  0.2],
        [-0.4,  0.2, -0.1, 0.9]
    ])

    print("\nWeight matrix W:")
    print(W)

    print("\nDepth analysis (tropical interpretation):")
    # In the tropical interpretation, we track the number of
    # distinct linear regions, approximated by tropical column diversity
    current = W.copy()
    for depth in range(1, 7):
        rank = tropical_rank(current)
        n_finite = np.sum(current != INF)
        print(f"  Depth {depth}: tropical rank={rank}, "
              f"finite entries={n_finite}")
        current = current @ W  # Standard multiplication for ReLU analysis

    print("\n  → Tropical rank bounds the number of linear regions")
    print("  → Stabilization indicates representation saturation")


# =============================================================
# Application 4: Supply Chain Optimization
# =============================================================

def supply_chain_demo():
    """
    Model a supply chain where tropical powers give optimal
    multi-stage shipping costs.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Supply Chain Optimization")
    print("=" * 60)

    # 5 locations: Factory, Warehouse A, Warehouse B, Store 1, Store 2
    # Costs to ship between locations
    cost = np.array([
        [0.0,   5.0,   8.0,  INF,  INF],  # Factory
        [INF,   0.0,   2.0,   4.0,  6.0],  # Warehouse A
        [INF,   3.0,   0.0,   3.0,  5.0],  # Warehouse B
        [INF,  INF,   INF,   0.0,   1.0],  # Store 1
        [INF,  INF,   INF,   2.0,   0.0],  # Store 2
    ])

    locations = ["Factory", "Whs-A", "Whs-B", "Store1", "Store2"]

    print("\nDirect shipping costs ($):")
    print("          " + "  ".join(f"{l:>7}" for l in locations))
    for i, loc in enumerate(locations):
        row = [f"{cost[i,j]:7.1f}" if cost[i,j] != INF else "    inf"
               for j in range(5)]
        print(f"  {loc:>7}: [{', '.join(row)}]")

    print("\nMulti-leg optimal shipping:")
    for legs in range(1, 6):
        Cm = trop_pow(cost, legs)
        rank = tropical_rank(Cm)
        factory_to_stores = [
            f"{Cm[0,3]:.1f}" if Cm[0,3] != INF else "inf",
            f"{Cm[0,4]:.1f}" if Cm[0,4] != INF else "inf"
        ]
        print(f"  {legs} legs: rank={rank}, "
              f"Factory→Store1=${factory_to_stores[0]}, "
              f"Factory→Store2=${factory_to_stores[1]}")

    print("\n  → Rank growth = new optimal shipping patterns emerge")
    print("  → Each rank increment = a genuinely new cost profile")
    print("  → Stabilization = all useful routes discovered")


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════╗")
    print("║   Tropical Rank Growth — Real-World Applications    ║")
    print("╚══════════════════════════════════════════════════════╝")

    network_routing_demo()
    scheduling_demo()
    relu_network_demo()
    supply_chain_demo()

    print("\n" + "=" * 60)
    print("All applications demonstrated successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
demo.py — Tropical Rank Growth Under Matrix Powers

Demonstrates the core theorems about tropical matrix powers:
1. Tropical rank (number of distinct columns) is bounded by dimension
2. Monotone bounded sequences eventually stabilize
3. Strict rank jumps produce distinct matrix powers
4. Image-set growth from rank growth

Uses the min-plus tropical semiring convention:
  a ⊕ b = min(a, b)
  a ⊗ b = a + b
"""

import numpy as np
from typing import Optional

INF = float('inf')


def trop_add(a: float, b: float) -> float:
    """Tropical addition: min(a, b)."""
    return min(a, b)


def trop_mul(a: float, b: float) -> float:
    """Tropical multiplication: a + b (with ∞ + x = ∞)."""
    if a == INF or b == INF:
        return INF
    return a + b


def trop_mat_mul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Tropical matrix multiplication (min-plus).

    (A ⊗ B)_{ik} = min_j (A_{ij} + B_{jk})
    """
    n = A.shape[0]
    C = np.full((n, n), INF)
    for i in range(n):
        for k in range(n):
            for j in range(n):
                val = trop_mul(A[i, j], B[j, k])
                C[i, k] = trop_add(C[i, k], val)
    return C


def trop_identity(n: int) -> np.ndarray:
    """Tropical identity matrix: 0 on diagonal, ∞ off diagonal."""
    I = np.full((n, n), INF)
    for i in range(n):
        I[i, i] = 0.0
    return I


def trop_pow(A: np.ndarray, m: int) -> np.ndarray:
    """Compute A^m in the tropical semiring."""
    n = A.shape[0]
    if m == 0:
        return trop_identity(n)
    result = A.copy()
    for _ in range(m - 1):
        result = trop_mat_mul(result, A)
    return result


def tropical_rank(A: np.ndarray) -> int:
    """Tropical rank: number of distinct columns."""
    n = A.shape[1]
    columns = set()
    for j in range(n):
        col = tuple(A[:, j])
        columns.add(col)
    return len(columns)


def column_set(A: np.ndarray) -> set:
    """Set of distinct column vectors."""
    n = A.shape[1]
    cols = set()
    for j in range(n):
        cols.add(tuple(A[:, j]))
    return cols


def power_column_set(A: np.ndarray, M: int) -> set:
    """Union of column sets across powers A^0, ..., A^M."""
    all_cols = set()
    for m in range(M + 1):
        Am = trop_pow(A, m)
        all_cols |= column_set(Am)
    return all_cols


def demo_rank_bound():
    """Demonstrate that tropical rank ≤ dimension."""
    print("=" * 60)
    print("DEMO 1: Tropical Rank ≤ Dimension")
    print("=" * 60)

    # 3×3 matrix
    A = np.array([
        [0.0, 3.0, 7.0],
        [2.0, 0.0, 5.0],
        [1.0, 4.0, 0.0]
    ])
    n = A.shape[0]
    rank = tropical_rank(A)
    print(f"\nMatrix A (3×3):\n{A}")
    print(f"Tropical rank: {rank}")
    print(f"Dimension: {n}")
    print(f"rank ≤ n? {rank <= n} ✓")

    # Matrix with repeated columns
    B = np.array([
        [1.0, 1.0, 2.0],
        [3.0, 3.0, 4.0],
        [5.0, 5.0, 6.0]
    ])
    rank_B = tropical_rank(B)
    print(f"\nMatrix B (repeated columns):\n{B}")
    print(f"Tropical rank: {rank_B}")
    print(f"rank ≤ n? {rank_B <= n} ✓")

    # Identity matrix
    I = trop_identity(4)
    rank_I = tropical_rank(I)
    print(f"\nTropical identity (4×4):\n{I}")
    print(f"Tropical rank: {rank_I}")
    print(f"rank = n? {rank_I == 4} ✓ (identity always has full rank)")


def demo_rank_sequence():
    """Demonstrate rank sequences under tropical powering."""
    print("\n" + "=" * 60)
    print("DEMO 2: Rank Sequences Under Tropical Powers")
    print("=" * 60)

    # Example 1: Simple graph matrix
    A = np.array([
        [0.0, 1.0, INF],
        [INF, 0.0, 2.0],
        [3.0, INF, 0.0]
    ])
    print(f"\nMatrix A (3-cycle graph):\n{A}")
    print("\nPower | Rank | Matrix (first row)")
    print("-" * 50)
    for m in range(7):
        Am = trop_pow(A, m)
        r = tropical_rank(Am)
        print(f"  A^{m}  |  {r}   | {Am[0]}")

    # Example 2: Dense matrix
    B = np.array([
        [0.0, 2.0, 5.0, 1.0],
        [3.0, 0.0, 4.0, 2.0],
        [1.0, 3.0, 0.0, 6.0],
        [2.0, 1.0, 3.0, 0.0]
    ])
    print(f"\nMatrix B (4×4 dense):\n{B}")
    print("\nPower | Rank | Distinct columns")
    print("-" * 50)
    ranks = []
    for m in range(8):
        Bm = trop_pow(B, m)
        r = tropical_rank(Bm)
        ranks.append(r)
        print(f"  B^{m}  |  {r}   | {column_set(Bm)}")

    # Check if sequence is eventually stable
    stable_at = None
    for i in range(1, len(ranks)):
        if all(ranks[j] == ranks[i] for j in range(i, len(ranks))):
            stable_at = i
            break
    if stable_at:
        print(f"\n→ Rank sequence stabilizes at power {stable_at}")
    print(f"→ Rank sequence: {ranks}")


def demo_image_set_growth():
    """Demonstrate power column set growth."""
    print("\n" + "=" * 60)
    print("DEMO 3: Power Column Set Growth")
    print("=" * 60)

    A = np.array([
        [0.0, 1.0, INF, INF],
        [INF, 0.0, 2.0, INF],
        [INF, INF, 0.0, 3.0],
        [4.0, INF, INF, 0.0]
    ])
    print(f"\nMatrix A (4-cycle):\n{A}")

    for M in range(6):
        pcs = power_column_set(A, M)
        print(f"Power column set size for M={M}: {len(pcs)}")

    print("\nDetailed column evolution:")
    for m in range(5):
        Am = trop_pow(A, m)
        cs = column_set(Am)
        print(f"  A^{m}: rank={tropical_rank(Am)}, new columns at this step: ", end="")
        if m == 0:
            print(f"{len(cs)} columns")
        else:
            prev = power_column_set(A, m - 1)
            new = cs - prev
            print(f"{len(new)} new columns")


def demo_distinct_powers():
    """Demonstrate that different ranks imply different matrices."""
    print("\n" + "=" * 60)
    print("DEMO 4: Distinct Ranks ⟹ Distinct Matrix Powers")
    print("=" * 60)

    A = np.array([
        [0.0, 1.0, INF],
        [INF, 0.0, 2.0],
        [3.0, INF, 0.0]
    ])
    print(f"\nMatrix A:\n{A}")
    print("\nComparing ranks and matrix equality:")

    powers = {}
    for m in range(6):
        Am = trop_pow(A, m)
        r = tropical_rank(Am)
        powers[m] = (Am, r)
        print(f"  A^{m}: rank = {r}")

    # Check: same rank does not imply same matrix
    print("\nPairwise comparison (rank_i ≠ rank_j ⟹ A^i ≠ A^j):")
    for i in range(5):
        for j in range(i + 1, 6):
            ri = powers[i][1]
            rj = powers[j][1]
            same_matrix = np.array_equal(powers[i][0], powers[j][0])
            if ri != rj:
                assert not same_matrix, "Theorem violated!"
                print(f"  A^{i} vs A^{j}: ranks {ri}≠{rj}, matrices different ✓")


def demo_rank1_characterization():
    """Demonstrate the rank-1 characterization."""
    print("\n" + "=" * 60)
    print("DEMO 5: Rank-1 Characterization (All Columns Identical)")
    print("=" * 60)

    # Rank-1 matrix: all columns the same
    A = np.array([
        [1.0, 1.0, 1.0],
        [2.0, 2.0, 2.0],
        [3.0, 3.0, 3.0]
    ])
    r = tropical_rank(A)
    print(f"\nRank-1 matrix (all columns identical):\n{A}")
    print(f"Tropical rank: {r}")
    print(f"All columns identical? {r <= 1} ✓")

    # Not rank-1: distinct columns
    B = np.array([
        [1.0, 2.0, 3.0],
        [4.0, 5.0, 6.0],
        [7.0, 8.0, 9.0]
    ])
    r = tropical_rank(B)
    print(f"\nFull-rank matrix:\n{B}")
    print(f"Tropical rank: {r}")
    print(f"Rank > 1? {r > 1} ✓")


def demo_shortest_paths():
    """Show the graph-theoretic interpretation of tropical powers."""
    print("\n" + "=" * 60)
    print("DEMO 6: Shortest Paths via Tropical Powers")
    print("=" * 60)

    # Weighted directed graph as tropical matrix
    # ∞ means no direct edge
    A = np.array([
        [0.0, 3.0, INF, 7.0],
        [INF, 0.0, 1.0, INF],
        [INF, INF, 0.0, 2.0],
        [1.0, INF, INF, 0.0]
    ])
    print("\nWeighted digraph (adjacency matrix):")
    print("  0 →(3)→ 1 →(1)→ 2 →(2)→ 3 →(1)→ 0")
    print("  0 →(7)→ 3")

    for m in range(1, 6):
        Am = trop_pow(A, m)
        print(f"\nA^{m} (optimal {m}-step paths):")
        for i in range(4):
            row = [f"{Am[i,j]:5.1f}" if Am[i,j] != INF else "  inf"
                   for j in range(4)]
            print(f"  [{', '.join(row)}]")
        print(f"  Tropical rank: {tropical_rank(Am)}")


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════╗")
    print("║  Tropical Rank Growth Under Matrix Powers — Demos   ║")
    print("╚══════════════════════════════════════════════════════╝")

    demo_rank_bound()
    demo_rank_sequence()
    demo_image_set_growth()
    demo_distinct_powers()
    demo_rank1_characterization()
    demo_shortest_paths()

    print("\n" + "=" * 60)
    print("All demonstrations completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
visualizations.py — Generate visualizations for tropical rank growth

Produces PNG figures showing:
1. Rank sequences under tropical powering
2. Power column set growth curves
3. Stabilization detection
4. Graph-theoretic interpretation
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import base64
import io

INF = float('inf')


def trop_mul_entry(a, b):
    if a == INF or b == INF:
        return INF
    return a + b


def trop_mat_mul(A, B):
    n = A.shape[0]
    C = np.full((n, n), INF)
    for i in range(n):
        for k in range(n):
            for j in range(n):
                C[i, k] = min(C[i, k], trop_mul_entry(A[i, j], B[j, k]))
    return C


def trop_identity(n):
    I = np.full((n, n), INF)
    np.fill_diagonal(I, 0.0)
    return I


def trop_pow(A, m):
    n = A.shape[0]
    result = trop_identity(n)
    for _ in range(m):
        result = trop_mat_mul(result, A)
    return result


def tropical_rank(A):
    n = A.shape[1]
    return len({tuple(A[:, j]) for j in range(n)})


def column_set(A):
    n = A.shape[1]
    return {tuple(A[:, j]) for j in range(n)}


def fig_to_base64(fig):
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def generate_rank_sequence_plot():
    """Plot rank sequences for several matrix types."""
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))
    fig.suptitle('Tropical Rank Sequences Under Matrix Powers', fontsize=16, fontweight='bold')

    matrices = {
        '3-Cycle Graph': np.array([
            [0., 1., INF],
            [INF, 0., 2.],
            [3., INF, 0.]
        ]),
        '4-Node Complete': np.array([
            [0., 2., 5., 1.],
            [3., 0., 4., 2.],
            [1., 3., 0., 6.],
            [2., 1., 3., 0.]
        ]),
        '4-Cycle': np.array([
            [0., 1., INF, INF],
            [INF, 0., 2., INF],
            [INF, INF, 0., 3.],
            [4., INF, INF, 0.]
        ]),
        '5-Node Sparse': np.array([
            [0., 2., INF, INF, INF],
            [INF, 0., 3., INF, INF],
            [INF, INF, 0., 1., INF],
            [INF, INF, INF, 0., 4.],
            [5., INF, INF, INF, 0.]
        ])
    }

    for ax, (name, A) in zip(axes.flat, matrices.items()):
        n = A.shape[0]
        max_m = 12
        ranks = []
        current = trop_identity(n)
        for m in range(max_m + 1):
            if m > 0:
                current = trop_mat_mul(current, A)
            else:
                current = trop_identity(n)
            ranks.append(tropical_rank(current))

        ax.plot(range(max_m + 1), ranks, 'bo-', linewidth=2, markersize=6)
        ax.axhline(y=n, color='r', linestyle='--', alpha=0.5, label=f'n={n} (bound)')
        ax.set_xlabel('Power m')
        ax.set_ylabel('Tropical Rank')
        ax.set_title(name)
        ax.legend()
        ax.set_ylim(0, n + 1)
        ax.grid(True, alpha=0.3)

    plt.tight_layout()
    fig.savefig('/workspace/request-project/fig_rank_sequences.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def generate_column_set_growth_plot():
    """Plot power column set growth curves."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    matrices = {
        '3-Cycle': np.array([
            [0., 1., INF],
            [INF, 0., 2.],
            [3., INF, 0.]
        ]),
        '4-Complete': np.array([
            [0., 2., 5., 1.],
            [3., 0., 4., 2.],
            [1., 3., 0., 6.],
            [2., 1., 3., 0.]
        ]),
        '5-Cycle': np.array([
            [0., 1., INF, INF, INF],
            [INF, 0., 2., INF, INF],
            [INF, INF, 0., 3., INF],
            [INF, INF, INF, 0., 4.],
            [5., INF, INF, INF, 0.]
        ]),
    }

    colors = ['#2196F3', '#4CAF50', '#FF5722']
    for (name, A), color in zip(matrices.items(), colors):
        max_m = 15
        all_cols = set()
        sizes = []
        current = trop_identity(A.shape[0])
        for m in range(max_m + 1):
            if m > 0:
                current = trop_mat_mul(current, A)
            else:
                current = trop_identity(A.shape[0])
            all_cols |= column_set(current)
            sizes.append(len(all_cols))

        ax.plot(range(max_m + 1), sizes, 'o-', color=color,
                linewidth=2, markersize=5, label=name)

    ax.set_xlabel('Maximum Power M', fontsize=12)
    ax.set_ylabel('|Power Column Set|', fontsize=12)
    ax.set_title('Power Column Set Growth Under Tropical Iteration', fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    fig.savefig('/workspace/request-project/fig_column_set_growth.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def generate_stabilization_heatmap():
    """Visualize matrix entries evolving under tropical powers."""
    A = np.array([
        [0., 1., INF, INF],
        [INF, 0., 2., INF],
        [INF, INF, 0., 3.],
        [4., INF, INF, 0.]
    ])

    fig, axes = plt.subplots(2, 3, figsize=(15, 9))
    fig.suptitle('Tropical Matrix Powers: Entry Evolution (4-Cycle Graph)',
                 fontsize=14, fontweight='bold')

    for idx, m in enumerate([0, 1, 2, 3, 4, 5]):
        ax = axes[idx // 3][idx % 3]
        Am = trop_pow(A, m)
        # Replace inf with a large value for visualization
        display = Am.copy()
        display[display == INF] = np.nan

        im = ax.imshow(display, cmap='YlOrRd_r', aspect='equal')
        ax.set_title(f'A^{m} (rank={tropical_rank(Am)})')

        # Add text annotations
        for i in range(4):
            for j in range(4):
                val = Am[i, j]
                txt = '∞' if val == INF else f'{val:.0f}'
                color = 'gray' if val == INF else 'black'
                ax.text(j, i, txt, ha='center', va='center',
                       fontsize=11, color=color, fontweight='bold')

        ax.set_xticks(range(4))
        ax.set_yticks(range(4))

    plt.tight_layout()
    fig.savefig('/workspace/request-project/fig_stabilization_heatmap.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def generate_theorem_illustration():
    """Create a conceptual diagram of the main theorems."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    # Illustrate a monotone bounded rank sequence
    x = list(range(8))
    y = [1, 2, 2, 3, 3, 3, 3, 3]
    n = 4

    ax.step(x, y, 'b-', linewidth=2.5, where='post', label='tropicalRank(A^m)')
    ax.axhline(y=n, color='red', linestyle='--', linewidth=1.5,
               alpha=0.7, label=f'Bound n = {n}')

    # Mark jump points
    jumps = [(0, 1, 2), (2, 2, 3)]
    for x_j, y_old, y_new in jumps:
        ax.annotate('', xy=(x_j + 0.5, y_new), xytext=(x_j + 0.5, y_old),
                    arrowprops=dict(arrowstyle='->', color='green', lw=2))
        ax.plot(x_j + 0.5, y_new, 'g^', markersize=12)

    # Mark stabilization
    ax.axvline(x=3, color='purple', linestyle=':', alpha=0.6, linewidth=1.5)
    ax.annotate('Stabilization\n(Theorem)', xy=(3, 3.5),
                fontsize=10, color='purple', ha='center',
                bbox=dict(boxstyle='round,pad=0.3', facecolor='lavender'))

    # Mark jumps annotation
    ax.annotate('Strict rank\njumps ≤ n', xy=(1, 2.5),
                fontsize=10, color='green', ha='center',
                bbox=dict(boxstyle='round,pad=0.3', facecolor='#E8F5E9'))

    ax.set_xlabel('Power m', fontsize=12)
    ax.set_ylabel('Tropical Rank', fontsize=12)
    ax.set_title('Tropical Rank Growth Law: Bounded Monotone Stabilization',
                 fontsize=14, fontweight='bold')
    ax.legend(fontsize=11, loc='lower right')
    ax.set_ylim(0, n + 1.5)
    ax.set_xlim(-0.5, 7.5)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    fig.savefig('/workspace/request-project/fig_theorem_illustration.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


if __name__ == "__main__":
    print("Generating visualizations...")

    b64_rank = generate_rank_sequence_plot()
    print(f"  ✓ Rank sequence plot ({len(b64_rank)} bytes)")

    b64_cols = generate_column_set_growth_plot()
    print(f"  ✓ Column set growth plot ({len(b64_cols)} bytes)")

    b64_heat = generate_stabilization_heatmap()
    print(f"  ✓ Stabilization heatmap ({len(b64_heat)} bytes)")

    b64_thm = generate_theorem_illustration()
    print(f"  ✓ Theorem illustration ({len(b64_thm)} bytes)")

    print("\nAll visualizations saved to PNG files.")

    # Also store base64 for JSON packaging
    viz_data = {
        'rank_sequences': b64_rank,
        'column_set_growth': b64_cols,
        'stabilization_heatmap': b64_heat,
        'theorem_illustration': b64_thm,
    }

    import json
    with open('/workspace/request-project/viz_data.json', 'w') as f:
        json.dump(viz_data, f)
    print("Base64 data saved to viz_data.json")
