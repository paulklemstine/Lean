#!/usr/bin/env python3
"""
Applications of Tropical Transfer Operators

Demonstrates real-world applications of the transfer operator formalism:
1. Shortest path in layered networks (logistics/routing)
2. Viterbi decoding in hidden Markov models
3. Dynamic programming for sequence alignment
4. Circuit complexity analysis
"""

import numpy as np
from typing import List, Tuple
from algorithms import TropicalMatrix, MinPlusBP, compute_layer_states, \
    compute_transfer_product, min_cost_with_certificate, partition_function

INF = float('inf')


# =============================================================================
# Application 1: Shortest Path in Layered Networks
# =============================================================================

def app_logistics_routing():
    """Shortest path routing through a layered distribution network.

    Models a supply chain with 4 distribution centers and 3 stages:
    - Stage 0: Factory → Regional warehouse
    - Stage 1: Regional warehouse → Distribution center
    - Stage 2: Distribution center → Retail store

    Edge costs represent shipping costs in dollars.
    """
    print("=" * 70)
    print("APPLICATION 1: Supply Chain Shortest Path Routing")
    print("=" * 70)

    # 4 nodes per layer (4 facilities at each stage)
    w = 4
    d = 3  # 3 shipping stages

    # Shipping cost matrices (some routes don't exist = INF)
    factory_to_regional = TropicalMatrix(np.array([
        [10, 25, INF, 30],   # Factory A
        [20, 15, 35, INF],   # Factory B
        [INF, 30, 20, 25],   # Factory C
        [35, INF, 15, 20],   # Factory D
    ], dtype=float))

    regional_to_distrib = TropicalMatrix(np.array([
        [5, 15, INF, 20],
        [10, 8, 12, INF],
        [INF, 18, 6, 14],
        [22, INF, 10, 7],
    ], dtype=float))

    distrib_to_retail = TropicalMatrix(np.array([
        [3, INF, 12, 8],
        [INF, 5, 7, 15],
        [9, 11, 4, INF],
        [6, 8, INF, 3],
    ], dtype=float))

    bp = MinPlusBP(w, d,
                   [factory_to_regional, regional_to_distrib, distrib_to_retail],
                   start=0, accept=3)

    print(f"\nNetwork: {w} facilities × {d} stages")
    print(f"Route: Factory A (node 0) → Retail D (node 3)")

    # Compute optimal route
    cost, path = min_cost_with_certificate(bp)
    facility_names = ['A', 'B', 'C', 'D']
    stage_names = ['Factory', 'Regional', 'Distribution', 'Retail']

    print(f"\nOptimal route (cost ${cost:.0f}):")
    if path:
        for i, node in enumerate(path):
            print(f"  Stage {i} ({stage_names[i]}): Facility {facility_names[node]}")

    # Show all layer states (costs to reach each facility at each stage)
    print(f"\nMinimum shipping costs to each facility:")
    states = compute_layer_states(bp)
    for i, state in enumerate(states):
        costs = [f"${x:.0f}" if x < INF else "N/A" for x in state]
        print(f"  {stage_names[i]:>14s}: {', '.join(f'{facility_names[j]}={costs[j]}' for j in range(w))}")

    # Transfer product gives all-pairs shortest paths
    print(f"\nTransfer product (full shortest-path matrix):")
    prod = compute_transfer_product(bp)
    for i in range(w):
        row = [f"${x:.0f}" if x < INF else "  ∞" for x in prod.data[i]]
        print(f"  From {facility_names[i]}: [{', '.join(row)}]")


# =============================================================================
# Application 2: Viterbi Decoding (HMM)
# =============================================================================

def app_viterbi_decoding():
    """Viterbi decoding as tropical transfer operator computation.

    A Hidden Markov Model with 3 hidden states observed over 4 time steps.
    The Viterbi algorithm finds the most likely state sequence, which is
    exactly a shortest-path (min-cost) computation in the tropical semiring.

    Transition costs = -log(transition probabilities)
    Emission costs = -log(emission probabilities)
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Viterbi Decoding via Tropical Transfer Operators")
    print("=" * 70)

    # 3 hidden states: Sunny(0), Cloudy(1), Rainy(2)
    # 4 time steps with observations
    w = 3
    d = 4

    states = ['Sunny', 'Cloudy', 'Rainy']

    # Transition probabilities → costs (-log)
    trans_probs = np.array([
        [0.7, 0.2, 0.1],  # From Sunny
        [0.3, 0.4, 0.3],  # From Cloudy
        [0.2, 0.3, 0.5],  # From Rainy
    ])
    trans_costs = -np.log(trans_probs)

    # Observations at each time step and emission probabilities
    # Observations: Walk, Shop, Clean, Walk
    observations = ['Walk', 'Shop', 'Clean', 'Walk']
    emission_probs = {
        'Walk':  [0.6, 0.3, 0.1],
        'Shop':  [0.3, 0.4, 0.3],
        'Clean': [0.1, 0.3, 0.6],
    }

    # Build transfer matrices: M_t[i,j] = trans_cost[i,j] + emission_cost[j, obs_t+1]
    edge_costs = []
    for t in range(d):
        obs = observations[t] if t < len(observations) else observations[-1]
        M = np.zeros((w, w))
        for i in range(w):
            for j in range(w):
                emit_cost = -np.log(emission_probs[obs][j])
                M[i, j] = trans_costs[i, j] + emit_cost
        edge_costs.append(TropicalMatrix(M))

    # Initial state: Sunny with cost 0 (assume known starting state)
    bp = MinPlusBP(w, d, edge_costs, start=0, accept=0)

    print(f"\nHidden states: {states}")
    print(f"Observations: {observations}")
    print(f"Time steps: {d}")

    # Find most likely sequence ending at each state
    print(f"\nMost likely state sequences (Viterbi):")
    for final_state in range(w):
        bp_temp = MinPlusBP(w, d, edge_costs, start=0, accept=final_state)
        cost, path = min_cost_with_certificate(bp_temp)
        if path:
            state_seq = [states[node] for node in path]
            prob = np.exp(-cost)
            print(f"  Ending at {states[final_state]:>6s}: "
                  f"cost={cost:.3f}, prob={prob:.6f}, "
                  f"sequence={' → '.join(state_seq)}")

    # Temperature sweep: show transition from Viterbi to forward algorithm
    print(f"\n  Temperature sweep (Viterbi → Forward algorithm):")
    for T in [0.01, 0.1, 0.5, 1.0, 2.0, 5.0]:
        F = partition_function(bp, T)
        print(f"    T={T:5.2f}: free energy = {F:.4f}")


# =============================================================================
# Application 3: Sequence Alignment (Edit Distance)
# =============================================================================

def app_sequence_alignment():
    """Sequence alignment as tropical transfer operator computation.

    Computing edit distance between two strings can be cast as a
    min-plus branching program where each layer corresponds to
    processing one character of the target string.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Sequence Alignment via Tropical Operators")
    print("=" * 70)

    seq1 = "ACGT"
    seq2 = "AGT"

    # States represent positions in seq2 (plus boundary)
    w = len(seq2) + 1  # 0..len(seq2)
    d = len(seq1)      # Process each char of seq1

    # Costs: match=0, mismatch=1, insert=1, delete=1

    edge_costs = []
    for t in range(d):
        char1 = seq1[t]
        M = np.full((w, w), INF)
        for i in range(w):
            # Delete char1 (stay at same position in seq2)
            M[i, i] = 1.0

            # Match/mismatch with next char in seq2
            if i < len(seq2):
                char2 = seq2[i]
                cost = 0.0 if char1 == char2 else 1.0
                if i + 1 < w:
                    M[i, i + 1] = cost

        edge_costs.append(TropicalMatrix(M))

    bp = MinPlusBP(w, d, edge_costs, start=0, accept=len(seq2))

    print(f"\nSequences: '{seq1}' → '{seq2}'")
    print(f"States: positions 0..{len(seq2)} in target")

    # Compute alignment cost
    states = compute_layer_states(bp)
    print(f"\nLayer states (min cost to reach each position):")
    for i, state in enumerate(states):
        prefix = seq1[:i] if i > 0 else "(start)"
        s_str = [f"{x:.0f}" if x < INF else "∞" for x in state]
        print(f"  After '{prefix}': [{', '.join(s_str)}]")

    cost, path = min_cost_with_certificate(bp)
    print(f"\nEdit distance: {cost:.0f}")
    if path:
        print(f"Alignment path: {path}")

    # Transfer product
    prod = compute_transfer_product(bp)
    transfer_cost = prod.mul_vec(bp.start_vec())[bp.accept]
    print(f"Transfer product confirms: {transfer_cost:.0f}")


# =============================================================================
# Application 4: Circuit Complexity Analysis
# =============================================================================

def app_circuit_complexity():
    """Analyze tropical circuit complexity via transfer operators.

    Demonstrates how the transfer operator formalism connects
    branching program width to computational complexity.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 4: Circuit Complexity via Transfer Operators")
    print("=" * 70)

    # Compare BPs of different widths computing "similar" functions
    d = 5  # Fixed depth

    print(f"\nDepth: {d}, varying width")
    print(f"\n{'Width':>6s}  {'Min Cost':>10s}  {'Product Entries':>15s}  {'Max Finite':>10s}")
    print(f"{'─'*6}  {'─'*10}  {'─'*15}  {'─'*10}")

    np.random.seed(99)
    for w in [2, 3, 4, 5, 8]:
        edge_costs = []
        for _ in range(d):
            M = np.random.randint(1, 10, (w, w)).astype(float)
            edge_costs.append(TropicalMatrix(M))

        bp = MinPlusBP(w, d, edge_costs, start=0, accept=w-1)
        cost, _ = min_cost_with_certificate(bp)
        prod = compute_transfer_product(bp)

        # Count finite entries in transfer product
        finite_entries = np.sum(prod.data < INF)
        max_finite = np.max(prod.data[prod.data < INF]) if finite_entries > 0 else INF

        print(f"{w:>6d}  {cost:>10.1f}  {finite_entries:>15d}  {max_finite:>10.1f}")

    # Periodic BP: demonstrate spectral behavior
    print(f"\n--- Periodic BP: Spectral Growth ---")
    w = 3
    M = TropicalMatrix(np.array([
        [1, 3, 5],
        [2, 1, 4],
        [3, 2, 1],
    ], dtype=float))

    print(f"\nRepeated matrix M:")
    print(f"{M.data}")
    print(f"\nDepth  Max Entry  Growth Rate")
    print(f"{'─'*5}  {'─'*9}  {'─'*11}")

    prev_max = None
    for depth in range(1, 11):
        edge_costs = [M] * depth
        bp = MinPlusBP(w, depth, edge_costs, start=0, accept=0)
        prod = compute_transfer_product(bp)
        max_entry = np.min(prod.data)  # Min in min-plus = "most optimal"

        if prev_max is not None and prev_max > 0:
            growth = max_entry / depth
        else:
            growth = max_entry
        prev_max = max_entry

        print(f"{depth:>5d}  {max_entry:>9.1f}  {growth:>11.3f}")


if __name__ == "__main__":
    app_logistics_routing()
    app_viterbi_decoding()
    app_sequence_alignment()
    app_circuit_complexity()
    print("\n" + "=" * 70)
    print("All applications completed successfully!")
    print("=" * 70)


#!/usr/bin/env python3
"""
Demo: Transfer Operators and Partition Functions for Tropical Branching Programs

Demonstrates the core theorems with concrete numerical examples:
1. Layer state evolution via Bellman propagation
2. Transfer matrix product equivalence
3. Circuit unrolling as dynamic programming
4. Path-cost verification
"""

import numpy as np
from typing import List, Tuple, Optional

INF = float('inf')


def tropical_mul_vec(M: np.ndarray, v: np.ndarray) -> np.ndarray:
    """Min-plus matrix-vector multiplication: (M ⬝ v)[j] = min_i (v[i] + M[i,j])."""
    w = len(v)
    result = np.full(w, INF)
    for j in range(w):
        for i in range(w):
            result[j] = min(result[j], v[i] + M[i, j])
    return result


def tropical_mat_mul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Min-plus matrix multiplication: (A*B)[i,j] = min_k (A[i,k] + B[k,j])."""
    w = A.shape[0]
    result = np.full((w, w), INF)
    for i in range(w):
        for j in range(w):
            for k in range(w):
                result[i, j] = min(result[i, j], A[i, k] + B[k, j])
    return result


def tropical_identity(w: int) -> np.ndarray:
    """Tropical identity matrix: 0 on diagonal, ∞ elsewhere."""
    M = np.full((w, w), INF)
    np.fill_diagonal(M, 0.0)
    return M


class MinPlusBP:
    """A layered min-plus branching program."""

    def __init__(self, w: int, d: int, edge_costs: List[np.ndarray],
                 start: int, accept: int):
        self.w = w
        self.d = d
        self.edge_costs = edge_costs  # List of d matrices, each w×w
        self.start = start
        self.accept = accept

    def start_vec(self) -> np.ndarray:
        """Initial state vector: 0 at start, ∞ elsewhere."""
        v = np.full(self.w, INF)
        v[self.start] = 0.0
        return v

    def transfer_matrix(self, i: int) -> np.ndarray:
        """Transfer matrix at layer i."""
        return self.edge_costs[i]

    def layer_state(self, i: int) -> np.ndarray:
        """Compute layer state at layer i by Bellman propagation."""
        state = self.start_vec()
        for k in range(i):
            state = tropical_mul_vec(self.transfer_matrix(k), state)
        return state

    def transfer_product_up_to(self, i: int) -> np.ndarray:
        """Compute the prefix product of the first i transfer matrices."""
        prod = tropical_identity(self.w)
        for k in range(i):
            prod = tropical_mat_mul(prod, self.transfer_matrix(k))
        return prod

    def min_cost(self) -> float:
        """Minimum cost of any accepting path."""
        return self.layer_state(self.d)[self.accept]

    def eval_unrolled_transfer(self) -> float:
        """Evaluate via transfer product (algebraic view)."""
        prod = self.transfer_product_up_to(self.d)
        result = tropical_mul_vec(prod, self.start_vec())
        return result[self.accept]


def enumerate_paths(bp: MinPlusBP) -> List[Tuple[List[int], float]]:
    """Enumerate all paths and their costs (for small instances)."""
    paths = []
    _enumerate_paths_helper(bp, 0, [bp.start], 0.0, paths)
    return paths


def _enumerate_paths_helper(bp, layer, current_path, current_cost, results):
    if layer == bp.d:
        results.append((list(current_path), current_cost))
        return
    for next_node in range(bp.w):
        edge_cost = bp.edge_costs[layer][current_path[-1], next_node]
        if edge_cost < INF:
            current_path.append(next_node)
            _enumerate_paths_helper(bp, layer + 1, current_path,
                                    current_cost + edge_cost, results)
            current_path.pop()


def demo_basic():
    """Demo 1: Basic transfer operator semantics with a 3-node, 2-layer BP."""
    print("=" * 70)
    print("DEMO 1: Basic Transfer Operator Semantics")
    print("=" * 70)

    # 3 nodes, 2 layers
    w, d = 3, 2

    # Layer 0: edge costs
    M0 = np.array([
        [1.0, 3.0, INF],   # from node 0
        [INF, 2.0, 5.0],   # from node 1
        [4.0, INF, 1.0],   # from node 2
    ])

    # Layer 1: edge costs
    M1 = np.array([
        [2.0, INF, 3.0],
        [1.0, 4.0, INF],
        [INF, 2.0, 1.0],
    ])

    bp = MinPlusBP(w, d, [M0, M1], start=0, accept=2)

    print(f"\nBranching program: w={w}, d={d}, start=0, accept=2")
    print(f"\nTransfer matrix M₀ (layer 0):")
    print(M0)
    print(f"\nTransfer matrix M₁ (layer 1):")
    print(M1)

    # Demonstrate layer state evolution
    print(f"\n--- Layer State Evolution (Bellman Propagation) ---")
    for i in range(d + 1):
        state = bp.layer_state(i)
        print(f"  Layer {i}: {state}")

    # Demonstrate transfer product equivalence
    print(f"\n--- Transfer Product Equivalence ---")
    for i in range(d + 1):
        prod = bp.transfer_product_up_to(i)
        prod_vec = tropical_mul_vec(prod, bp.start_vec())
        layer = bp.layer_state(i)
        match = np.allclose(prod_vec, layer) or all(
            (a == b) or (a == INF and b == INF)
            for a, b in zip(prod_vec, layer)
        )
        print(f"  Layer {i}: layerState = {layer}")
        print(f"           prod·start = {prod_vec}")
        print(f"           Match: {match}")

    # Min cost
    print(f"\n--- Min-Cost Extraction ---")
    mc = bp.min_cost()
    mc_transfer = bp.eval_unrolled_transfer()
    print(f"  minCost (Bellman):  {mc}")
    print(f"  minCost (Transfer): {mc_transfer}")
    print(f"  Match: {mc == mc_transfer}")

    # Path enumeration
    print(f"\n--- All Paths to Accept Node ---")
    all_paths = enumerate_paths(bp)
    accepting = [(p, c) for p, c in all_paths if p[-1] == bp.accept]
    for path, cost in sorted(accepting, key=lambda x: x[1]):
        print(f"  Path {path}: cost = {cost}")
    if accepting:
        min_path_cost = min(c for _, c in accepting)
        print(f"  Minimum path cost: {min_path_cost}")
        print(f"  Matches minCost: {min_path_cost == mc}")


def demo_shortest_path():
    """Demo 2: Shortest path in a grid graph as tropical BP."""
    print("\n" + "=" * 70)
    print("DEMO 2: Shortest Path as Tropical Transfer Product")
    print("=" * 70)

    # 4-node graph, 3 layers (modeling a shortest path problem)
    w, d = 4, 3

    # Random edge costs
    np.random.seed(42)
    edge_costs = []
    for _ in range(d):
        M = np.random.randint(1, 10, (w, w)).astype(float)
        # Make some edges infinite (no connection)
        mask = np.random.random((w, w)) > 0.6
        M[mask] = INF
        edge_costs.append(M)

    bp = MinPlusBP(w, d, edge_costs, start=0, accept=3)

    print(f"\nBranching program: w={w}, d={d}, start=0, accept=3")

    # Show layer states
    print(f"\n--- Layer State Evolution ---")
    for i in range(d + 1):
        state = bp.layer_state(i)
        state_str = [f"{x:.0f}" if x < INF else "∞" for x in state]
        print(f"  Layer {i}: [{', '.join(state_str)}]")

    # Transfer product
    print(f"\n--- Transfer Product ---")
    prod = bp.transfer_product_up_to(d)
    print("  Transfer product M₀·M₁·M₂:")
    for i in range(w):
        row = [f"{x:.0f}" if x < INF else "∞" for x in prod[i]]
        print(f"    [{', '.join(row)}]")

    result_vec = tropical_mul_vec(prod, bp.start_vec())
    result_str = [f"{x:.0f}" if x < INF else "∞" for x in result_vec]
    print(f"\n  Product · startVec = [{', '.join(result_str)}]")
    print(f"  Min cost to accept: {bp.min_cost()}")
    print(f"  Transfer product value: {bp.eval_unrolled_transfer()}")
    print(f"  Match: {bp.min_cost() == bp.eval_unrolled_transfer()}")


def demo_matrix_associativity():
    """Demo 3: Verify tropical matrix multiplication associativity."""
    print("\n" + "=" * 70)
    print("DEMO 3: Tropical Matrix Multiplication Associativity")
    print("=" * 70)

    w = 3
    np.random.seed(123)

    A = np.random.randint(0, 5, (w, w)).astype(float)
    B = np.random.randint(0, 5, (w, w)).astype(float)
    C = np.random.randint(0, 5, (w, w)).astype(float)

    AB = tropical_mat_mul(A, B)
    BC = tropical_mat_mul(B, C)
    AB_C = tropical_mat_mul(AB, C)
    A_BC = tropical_mat_mul(A, BC)

    print(f"\nA = \n{A}")
    print(f"\nB = \n{B}")
    print(f"\nC = \n{C}")
    print(f"\n(A⊗B)⊗C = \n{AB_C}")
    print(f"\nA⊗(B⊗C) = \n{A_BC}")
    print(f"\nAssociativity holds: {np.allclose(AB_C, A_BC)}")


def demo_circuit_unrolling():
    """Demo 4: Circuit unrolling = transfer product iteration."""
    print("\n" + "=" * 70)
    print("DEMO 4: Circuit Unrolling as Transfer Operator Iteration")
    print("=" * 70)

    w, d = 3, 4
    np.random.seed(777)

    edge_costs = []
    for _ in range(d):
        M = np.random.randint(1, 8, (w, w)).astype(float)
        edge_costs.append(M)

    bp = MinPlusBP(w, d, edge_costs, start=0, accept=2)

    print(f"\nBranching program: w={w}, d={d}")
    print(f"Start: node {bp.start}, Accept: node {bp.accept}")

    # Circuit unrolling (step by step)
    print(f"\n--- Step-by-step circuit unrolling ---")
    state = bp.start_vec()
    print(f"  Initial state: {state}")

    for k in range(d):
        state = tropical_mul_vec(bp.transfer_matrix(k), state)
        state_str = [f"{x:.0f}" if x < INF else "∞" for x in state]
        print(f"  After layer {k}: [{', '.join(state_str)}]")

    print(f"\n  Circuit output (accept node): {state[bp.accept]}")

    # Transfer product (single matrix computation)
    prod = bp.transfer_product_up_to(d)
    transfer_result = tropical_mul_vec(prod, bp.start_vec())
    print(f"  Transfer product output:      {transfer_result[bp.accept]}")
    print(f"  Match: {state[bp.accept] == transfer_result[bp.accept]}")

    # Direct min-cost
    print(f"  Direct minCost:               {bp.min_cost()}")


def demo_statistical_mechanics():
    """Demo 5: Statistical mechanics interpretation."""
    print("\n" + "=" * 70)
    print("DEMO 5: Zero-Temperature Partition Function")
    print("=" * 70)

    # Temperature sweep: show how log-sum-exp approaches min as T→0
    w, d = 3, 2
    M0 = np.array([[1, 3, 5], [2, 1, 4], [3, 2, 1]], dtype=float)
    M1 = np.array([[2, 1, 3], [4, 2, 1], [1, 3, 2]], dtype=float)

    bp = MinPlusBP(w, d, [M0, M1], start=0, accept=2)

    # Enumerate all paths
    all_paths = enumerate_paths(bp)
    accepting = [(p, c) for p, c in all_paths if p[-1] == bp.accept]
    path_costs = [c for _, c in accepting]

    print(f"\nAccepting paths and costs:")
    for path, cost in sorted(accepting, key=lambda x: x[1]):
        print(f"  {path}: cost = {cost}")

    print(f"\n--- Temperature Sweep (Boltzmann → Tropical) ---")
    print(f"  {'T':>8s}  {'Free Energy':>12s}  {'Min Cost':>10s}")
    print(f"  {'-'*8}  {'-'*12}  {'-'*10}")

    tropical_min = min(path_costs)
    for T in [10.0, 5.0, 2.0, 1.0, 0.5, 0.1, 0.01, 0.001]:
        # Partition function Z = sum_p exp(-cost(p)/T)
        boltzmann_weights = [np.exp(-c / T) for c in path_costs]
        Z = sum(boltzmann_weights)
        free_energy = -T * np.log(Z)
        print(f"  {T:8.3f}  {free_energy:12.6f}  {tropical_min:10.1f}")

    print(f"\n  As T → 0, free energy → min cost = {tropical_min}")
    print(f"  Transfer product confirms: {bp.eval_unrolled_transfer()}")


if __name__ == "__main__":
    demo_basic()
    demo_shortest_path()
    demo_matrix_associativity()
    demo_circuit_unrolling()
    demo_statistical_mechanics()
    print("\n" + "=" * 70)
    print("All demos completed successfully!")
    print("=" * 70)


#!/usr/bin/env python3
"""
Visualizations for Transfer Operators and Partition Functions
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.colors import LinearSegmentedColormap
import base64
from io import BytesIO
from algorithms import TropicalMatrix, MinPlusBP, compute_layer_states, \
    compute_transfer_product, partition_function

INF = float('inf')


def fig_to_base64(fig) -> str:
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    return "data:image/png;base64," + base64.b64encode(buf.read()).decode()


def viz_layer_states():
    """Visualize layer state evolution through a branching program."""
    w, d = 5, 6
    np.random.seed(42)
    edge_costs = []
    for _ in range(d):
        M = np.random.randint(1, 8, (w, w)).astype(float)
        mask = np.random.random((w, w)) > 0.6
        M[mask] = INF
        edge_costs.append(TropicalMatrix(M))

    bp = MinPlusBP(w, d, edge_costs, start=0, accept=4)
    states = compute_layer_states(bp)

    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    colors = plt.cm.viridis(np.linspace(0.2, 0.9, w))
    for node in range(w):
        costs = []
        for i in range(d + 1):
            c = states[i][node]
            costs.append(c if c < INF else np.nan)
        ax.plot(range(d + 1), costs, 'o-', color=colors[node],
                label=f'Node {node}', linewidth=2, markersize=8)

    ax.set_xlabel('Layer', fontsize=14)
    ax.set_ylabel('Minimum Cost to Reach', fontsize=14)
    ax.set_title('Layer State Evolution: Bellman Propagation\nthrough Transfer Operators',
                 fontsize=16, fontweight='bold')
    ax.legend(fontsize=11, loc='upper left')
    ax.grid(True, alpha=0.3)
    ax.set_xticks(range(d + 1))

    plt.tight_layout()
    result = fig_to_base64(fig)
    fig.savefig('/workspace/request-project/viz_layer_states.png', dpi=150, bbox_inches='tight')
    plt.close(fig)
    return result


def viz_temperature_sweep():
    """Visualize the zero-temperature limit of partition functions."""
    w, d = 3, 3
    M0 = TropicalMatrix(np.array([[1, 3, 5], [2, 1, 4], [3, 2, 1]], dtype=float))
    M1 = TropicalMatrix(np.array([[2, 1, 3], [4, 2, 1], [1, 3, 2]], dtype=float))
    M2 = TropicalMatrix(np.array([[1, 2, 4], [3, 1, 2], [2, 4, 1]], dtype=float))

    bp = MinPlusBP(w, d, [M0, M1, M2], start=0, accept=2)

    # Compute min cost
    states = compute_layer_states(bp)
    min_cost = states[d][bp.accept]

    temperatures = np.logspace(-2, 1.5, 80)
    free_energies = []
    for T in temperatures:
        F = partition_function(bp, T)
        free_energies.append(F)

    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    ax.semilogx(temperatures, free_energies, 'b-', linewidth=2.5,
                label='Free Energy F(T)')
    ax.axhline(y=min_cost, color='r', linestyle='--', linewidth=2,
               label=f'Min Cost = {min_cost:.0f} (T→0 limit)')
    ax.fill_between(temperatures, min_cost - 0.5, min_cost + 0.5,
                    alpha=0.1, color='red')

    ax.set_xlabel('Temperature T', fontsize=14)
    ax.set_ylabel('Free Energy', fontsize=14)
    ax.set_title('Zero-Temperature Limit: Partition Function → Tropical Optimization',
                 fontsize=16, fontweight='bold')
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(temperatures[0], temperatures[-1])

    plt.tight_layout()
    result = fig_to_base64(fig)
    fig.savefig('/workspace/request-project/viz_temperature.png', dpi=150, bbox_inches='tight')
    plt.close(fig)
    return result


def viz_transfer_matrix_heatmap():
    """Visualize transfer matrices and their product."""
    w = 4
    np.random.seed(55)

    M0 = np.random.randint(1, 10, (w, w)).astype(float)
    M0[0, 2] = INF
    M0[3, 1] = INF
    M1 = np.random.randint(1, 10, (w, w)).astype(float)
    M1[1, 0] = INF
    M1[2, 3] = INF

    T0 = TropicalMatrix(M0)
    T1 = TropicalMatrix(M1)
    prod = T0 @ T1

    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    matrices = [M0, M1, prod.data]
    titles = ['Transfer Matrix M₀', 'Transfer Matrix M₁', 'Product M₀ ⊗ M₁']

    for ax, M, title in zip(axes, matrices, titles):
        display = M.copy()
        max_val = np.max(display[display < INF]) if np.any(display < INF) else 1
        display[display == INF] = max_val * 1.5

        cmap = LinearSegmentedColormap.from_list('tropical',
            ['#1a9850', '#91cf60', '#d9ef8b', '#fee08b', '#fc8d59', '#d73027'])

        im = ax.imshow(display, cmap=cmap, aspect='equal')

        for i in range(w):
            for j in range(w):
                val = M[i, j]
                text = '∞' if val == INF else f'{val:.0f}'
                color = 'white' if val == INF or val > max_val * 0.7 else 'black'
                ax.text(j, i, text, ha='center', va='center',
                        fontsize=14, fontweight='bold', color=color)

        ax.set_title(title, fontsize=14, fontweight='bold')
        ax.set_xticks(range(w))
        ax.set_yticks(range(w))
        ax.set_xlabel('To node')
        ax.set_ylabel('From node')

    plt.suptitle('Tropical Matrix Product: Min-Plus Composition',
                 fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()
    result = fig_to_base64(fig)
    fig.savefig('/workspace/request-project/viz_matrices.png', dpi=150, bbox_inches='tight')
    plt.close(fig)
    return result


def viz_spectral_growth():
    """Visualize spectral growth rate of periodic branching programs."""
    w = 3

    matrices = [
        ("Low spectral radius", np.array([[1, 5, 5], [5, 1, 5], [5, 5, 1]], dtype=float)),
        ("Medium spectral radius", np.array([[1, 2, 3], [3, 1, 2], [2, 3, 1]], dtype=float)),
        ("High spectral radius", np.array([[0, 1, 1], [1, 0, 1], [1, 1, 0]], dtype=float)),
    ]

    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    colors = ['#e41a1c', '#377eb8', '#4daf4a']

    for (name, M), color in zip(matrices, colors):
        depths = list(range(1, 16))
        min_costs = []
        for depth in depths:
            T = TropicalMatrix(M)
            edge_costs = [T] * depth
            bp = MinPlusBP(w, depth, edge_costs, start=0, accept=0)
            states = compute_layer_states(bp)
            min_costs.append(states[depth][0])

        ax.plot(depths, min_costs, 'o-', color=color, label=name,
                linewidth=2, markersize=6)

    ax.set_xlabel('Depth d', fontsize=14)
    ax.set_ylabel('Minimum Closed-Walk Cost', fontsize=14)
    ax.set_title('Spectral Growth Rate of Periodic Transfer Operators',
                 fontsize=16, fontweight='bold')
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    result = fig_to_base64(fig)
    fig.savefig('/workspace/request-project/viz_spectral.png', dpi=150, bbox_inches='tight')
    plt.close(fig)
    return result


if __name__ == "__main__":
    print("Generating visualizations...")
    viz_layer_states()
    print("  ✓ Layer states")
    viz_temperature_sweep()
    print("  ✓ Temperature sweep")
    viz_transfer_matrix_heatmap()
    print("  ✓ Transfer matrix heatmap")
    viz_spectral_growth()
    print("  ✓ Spectral growth")
    print("All visualizations saved!")
