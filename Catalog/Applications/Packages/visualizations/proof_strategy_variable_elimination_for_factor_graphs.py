"""
Applications of Tropical Polyphonic Optimization

Real-world applications demonstrating the theorems:
1. Certified chorale generation with optimality proof
2. Factor graph energy minimization (WCSP)
3. Shortest path as tropical tensor contraction
4. Sequence alignment via tropical DP
"""

import numpy as np
from itertools import product as cartesian_product

# ================================================================
# Application 1: Certified Chorale Generation
# ================================================================

def certified_chorale_generation():
    """
    Generate an optimal 4-voice chorale and produce a certificate
    proving its optimality via the rigidity theorem.
    """
    print("=" * 60)
    print("Application 1: Certified Chorale Generation")
    print("=" * 60)

    CONSONANCES = {0, 3, 4, 5, 7, 8, 9, 12}
    NOTE_NAMES = ['C', 'C#', 'D', 'D#', 'E', 'F',
                  'F#', 'G', 'G#', 'A', 'A#', 'B']

    def note_name(midi):
        return f"{NOTE_NAMES[midi % 12]}{midi // 12 - 1}"

    def pair_cost(pi, pj):
        interval = abs(pi - pj) % 12
        return 0.0 if interval in CONSONANCES else 2.0

    def spacing_cost(voice, pitch):
        ranges = [(60, 77), (55, 72), (48, 67), (41, 60)]
        lo, hi = ranges[voice]
        return max(0.0, max(lo - pitch, pitch - hi))

    # Search for zero-cost chorales
    pitches = list(range(48, 72))
    voice_pairs = [(i, j) for i in range(4) for j in range(i + 1, 4)]

    zero_cost_chorales = []
    for s, a, t, b in cartesian_product(
        range(60, 72), range(55, 67), range(48, 60), range(41, 55)
    ):
        chorale = [s, a, t, b]
        pair_total = sum(pair_cost(chorale[i], chorale[j])
                         for i, j in voice_pairs)
        space_total = sum(spacing_cost(v, chorale[v]) for v in range(4))
        if pair_total + space_total == 0:
            zero_cost_chorales.append(chorale)

    print(f"\n  Found {len(zero_cost_chorales)} zero-cost chorales")
    for c in zero_cost_chorales[:5]:
        names = [note_name(p) for p in c]
        print(f"    S={names[0]:4s} A={names[1]:4s} "
              f"T={names[2]:4s} B={names[3]:4s}  ({c})")

    if zero_cost_chorales:
        print(f"\n  Certificate for first chorale:")
        c = zero_cost_chorales[0]
        for i, j in voice_pairs:
            pc = pair_cost(c[i], c[j])
            vnames = ['S', 'A', 'T', 'B']
            print(f"    pairCost({vnames[i]},{vnames[j]}) = {pc} ✓")
        for v in range(4):
            sc = spacing_cost(v, c[v])
            print(f"    spacingPenalty({['S','A','T','B'][v]}) = {sc} ✓")
        print("    → By rigidity theorem: total cost = 0 ✓")
    print()


# ================================================================
# Application 2: Weighted CSP / Factor Graph
# ================================================================

def factor_graph_optimization():
    """
    Solve a weighted constraint satisfaction problem (WCSP)
    using the tropical tensor framework.

    Example: graph coloring with soft constraints.
    """
    print("=" * 60)
    print("Application 2: Factor Graph Optimization (Graph Coloring)")
    print("=" * 60)

    n_nodes = 4
    n_colors = 3
    edges = [(0, 1), (0, 2), (1, 2), (1, 3), (2, 3)]

    # Pairwise penalty: 1 for same color, 0 for different
    def edge_penalty(ci, cj):
        return 1.0 if ci == cj else 0.0

    # Unary preference: slight preference for certain colors per node
    preferences = np.random.RandomState(123).rand(n_nodes, n_colors) * 0.3

    def node_penalty(node, color):
        return preferences[node, color]

    # Brute force
    best_cost = float('inf')
    best_coloring = None

    for coloring in cartesian_product(range(n_colors), repeat=n_nodes):
        cost = sum(edge_penalty(coloring[i], coloring[j]) for i, j in edges)
        cost += sum(node_penalty(v, coloring[v]) for v in range(n_nodes))
        if cost < best_cost:
            best_cost = cost
            best_coloring = coloring

    print(f"\n  Graph: {n_nodes} nodes, {len(edges)} edges, {n_colors} colors")
    print(f"  Optimal coloring: {best_coloring}")
    print(f"  Optimal cost: {best_cost:.4f}")

    # Verify rigidity if cost is near zero
    edge_costs = [edge_penalty(best_coloring[i], best_coloring[j])
                  for i, j in edges]
    node_costs = [node_penalty(v, best_coloring[v]) for v in range(n_nodes)]
    print(f"  Edge penalties: {edge_costs}")
    print(f"  Node penalties: {[f'{c:.3f}' for c in node_costs]}")
    print(f"  All edge constraints satisfied: "
          f"{'✓' if all(c == 0 for c in edge_costs) else '✗'}")
    print()


# ================================================================
# Application 3: Shortest Path as Tropical Contraction
# ================================================================

def shortest_path_tropical():
    """
    Shortest path in a graph via tropical matrix multiplication.

    The adjacency matrix of a weighted graph is a tropical matrix.
    Tropical matrix powers give shortest paths of bounded length.
    """
    print("=" * 60)
    print("Application 3: Shortest Path via Tropical Matrix Power")
    print("=" * 60)

    # 5-node weighted graph
    INF = float('inf')
    W = np.array([
        [0, 3, INF, 7, INF],
        [3, 0, 1, INF, 2],
        [INF, 1, 0, 2, INF],
        [7, INF, 2, 0, 4],
        [INF, 2, INF, 4, 0]
    ])

    def tropical_matmul(A, B):
        """Tropical matrix multiplication: (A⊗B)_{ij} = min_k (A_{ik} + B_{kj})"""
        n = A.shape[0]
        C = np.full((n, n), INF)
        for i in range(n):
            for j in range(n):
                for k in range(n):
                    C[i, j] = min(C[i, j], A[i, k] + B[k, j])
        return C

    # Compute shortest paths by tropical power (Floyd-Warshall equivalent)
    D = W.copy()
    for _ in range(4):  # n-1 iterations
        D = tropical_matmul(D, W)

    print(f"\n  Weight matrix W:")
    for row in W:
        print(f"    {['∞' if x == INF else f'{x:.0f}' for x in row]}")

    print(f"\n  Shortest path matrix D = W^(⊗n):")
    for row in D:
        print(f"    {[f'{x:.0f}' for x in row]}")

    # Verify: shortest path from 0 to 4
    print(f"\n  Shortest path 0→4: {D[0, 4]:.0f} "
          f"(via 0→1→4: {W[0,1]+W[1,4]:.0f})")
    print()


# ================================================================
# Application 4: Sequence Alignment via Tropical DP
# ================================================================

def sequence_alignment_tropical():
    """
    Sequence alignment (edit distance) as tropical dynamic programming.

    This is a direct application of the product-space minimization theorem.
    """
    print("=" * 60)
    print("Application 4: Sequence Alignment (Edit Distance)")
    print("=" * 60)

    seq1 = "BACH"
    seq2 = "BEACH"

    n, m = len(seq1), len(seq2)

    # DP table (tropical minimum over alignment paths)
    dp = np.zeros((n + 1, m + 1))
    for i in range(n + 1):
        dp[i, 0] = i
    for j in range(m + 1):
        dp[0, j] = j

    for i in range(1, n + 1):
        for j in range(1, m + 1):
            match_cost = 0 if seq1[i-1] == seq2[j-1] else 1
            dp[i, j] = min(
                dp[i-1, j] + 1,      # deletion
                dp[i, j-1] + 1,      # insertion
                dp[i-1, j-1] + match_cost  # substitution/match
            )

    print(f"\n  Sequences: '{seq1}' → '{seq2}'")
    print(f"  Edit distance (tropical DP minimum): {int(dp[n, m])}")
    print(f"\n  DP table (tropical min-plus computation):")
    header = "    " + "   ".join([" "] + list(seq2))
    print(header)
    for i in range(n + 1):
        label = " " if i == 0 else seq1[i - 1]
        row = [f"{int(dp[i,j]):2d}" for j in range(m + 1)]
        print(f"  {label} " + "  ".join(row))
    print()


# ================================================================
# Run all applications
# ================================================================

if __name__ == "__main__":
    certified_chorale_generation()
    factor_graph_optimization()
    shortest_path_tropical()
    sequence_alignment_tropical()

    print("=" * 60)
    print("All applications completed successfully.")
    print("=" * 60)
