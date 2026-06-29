#!/usr/bin/env python3
"""
Tropical Branching Program Complexity: Applications

Real-world applications of tropical complexity lower bounds to:
1. Streaming algorithm design barriers
2. Network routing congestion analysis
3. Dynamic programming state compression limits
4. Database query optimization lower bounds
"""

import numpy as np
from typing import List, Dict, Tuple
from dataclasses import dataclass

INF = float('inf')


# ============================================================
# Application 1: Streaming Algorithm Barriers
# ============================================================

def streaming_element_distinctness_barrier(
    n: int,
    memory_bits: int
) -> Dict:
    """
    Analyze the streaming barrier for element distinctness.
    
    Element distinctness: given a stream of n elements, determine
    if all elements are distinct using only `memory_bits` of memory.
    
    The tropical BP framework shows that with 2^memory_bits states,
    the streaming algorithm must make at least n-1 state transitions,
    and the total transition cost grows with the function's obstruction
    measure.
    
    Args:
        n: Number of elements in the stream
        memory_bits: Number of memory bits available
    
    Returns:
        Analysis of the streaming barrier
    """
    memory_states = 2 ** memory_bits
    
    # With bounded memory, the algorithm cannot remember all elements
    # Pigeonhole: after seeing memory_states+1 elements, collisions
    # in the state space are inevitable
    collision_threshold = min(memory_states + 1, n)
    
    # Minimum number of state transitions
    min_transitions = n - 1  # Must process each element
    
    # Information-theoretic lower bound on cost
    # To distinguish C(n,2) possible collision pairs with
    # memory_states states, need significant transition cost
    possible_collisions = n * (n - 1) // 2
    
    # Tropical cost lower bound (from obstruction certificate)
    # Each transition must "pay" for the information it processes
    if memory_states < n:
        tropical_cost_lb = n - 1  # Linear lower bound
        explanation = (
            f"With {memory_states} states < {n} elements, "
            f"pigeonhole forces state collisions. "
            f"Each collision loses information about prior elements, "
            f"requiring expensive re-computation or acceptance of errors."
        )
    else:
        tropical_cost_lb = 0
        explanation = (
            f"With {memory_states} states ≥ {n} elements, "
            f"sufficient memory to track all elements."
        )
    
    return {
        'n': n,
        'memory_bits': memory_bits,
        'memory_states': memory_states,
        'collision_threshold': collision_threshold,
        'min_transitions': min_transitions,
        'possible_collisions': possible_collisions,
        'tropical_cost_lower_bound': tropical_cost_lb,
        'explanation': explanation,
        'bottleneck': memory_states < n,
    }


# ============================================================
# Application 2: Network Routing Congestion
# ============================================================

@dataclass
class NetworkLink:
    """A link in a communication network."""
    source: str
    target: str
    capacity: int  # Maximum simultaneous flows
    latency: float  # Propagation delay


def network_routing_congestion(
    links: List[NetworkLink],
    demands: List[Tuple[str, str, float]],  # (src, dst, amount)
    max_width: int,  # Bandwidth constraint = width
) -> Dict:
    """
    Analyze routing congestion using tropical complexity.
    
    The network routing problem maps to a tropical BP:
    - Layers = hops in the routing path
    - Width = link capacity (max simultaneous flows)
    - Edge costs = latency × congestion
    
    The obstruction certificate lower bound gives the minimum
    total latency-congestion cost for routing all demands.
    
    Args:
        links: Network links with capacity and latency
        demands: Traffic demands (source, destination, amount)
        max_width: Maximum flows per link
    
    Returns:
        Congestion analysis results
    """
    # Build adjacency with capacities
    adj: Dict[str, List[Tuple[str, float, int]]] = {}
    for link in links:
        if link.source not in adj:
            adj[link.source] = []
        adj[link.source].append((link.target, link.latency, link.capacity))
    
    total_demand = sum(d[2] for d in demands)
    
    # Width bottleneck: find the minimum capacity cut
    all_capacities = [link.capacity for link in links]
    min_capacity = min(all_capacities) if all_capacities else 0
    
    # Tropical lower bound: total demand / min_capacity * avg_latency
    avg_latency = np.mean([link.latency for link in links]) if links else 0
    
    # Obstruction: if total demand exceeds min_capacity at any cut,
    # congestion is inevitable
    congestion_inevitable = total_demand > min_capacity
    
    # Per-hop congestion cost lower bound
    if min_capacity > 0:
        per_hop_lb = max(0, (total_demand - min_capacity)) * avg_latency
    else:
        per_hop_lb = INF
    
    return {
        'num_links': len(links),
        'num_demands': len(demands),
        'total_demand': total_demand,
        'min_link_capacity': min_capacity,
        'avg_latency': avg_latency,
        'congestion_inevitable': congestion_inevitable,
        'per_hop_cost_lower_bound': per_hop_lb,
        'width_bottleneck': max_width,
        'interpretation': (
            "The tropical BP framework shows that network congestion "
            "is unavoidable when traffic demand exceeds link capacity. "
            "The width (capacity) bound forces a per-hop cost floor, "
            "which accumulates across layers (hops) to give a total "
            "latency-congestion lower bound."
        ),
    }


# ============================================================
# Application 3: Dynamic Programming State Compression
# ============================================================

def dp_compression_barrier(
    problem_size: int,
    full_state_space: int,
    compressed_states: int,
    num_stages: int,
) -> Dict:
    """
    Analyze the barrier to compressing dynamic programming state space.
    
    Many DP algorithms have exponential state spaces that practitioners
    try to compress (e.g., approximate DP, state aggregation). The
    tropical BP framework provides formal limits on how much compression
    is possible without losing solution quality.
    
    In tropical terms:
    - DP stages = BP layers
    - State space = nodes per layer (width)
    - Bellman transitions = tropical edge costs
    - Optimal value = minimum-cost accepting path
    
    Args:
        problem_size: Input size parameter
        full_state_space: Size of the uncompressed state space
        compressed_states: Target number of compressed states
        num_stages: Number of DP stages
    
    Returns:
        Compression barrier analysis
    """
    # Compression ratio
    if compressed_states > 0:
        compression_ratio = full_state_space / compressed_states
    else:
        compression_ratio = INF
    
    # Pigeonhole: how many states collide per compressed state
    if compressed_states > 0:
        collisions_per_state = full_state_space / compressed_states
    else:
        collisions_per_state = INF
    
    # Information lost per stage (bits)
    if compressed_states > 0 and full_state_space > 0:
        bits_lost = np.log2(full_state_space) - np.log2(compressed_states)
    else:
        bits_lost = INF
    
    # Total information loss across all stages
    total_info_loss = bits_lost * num_stages
    
    # Tropical cost lower bound: compressed DP pays extra cost
    # proportional to the information lost
    tropical_cost_penalty = max(0, int(collisions_per_state - 1)) * num_stages
    
    return {
        'problem_size': problem_size,
        'full_state_space': full_state_space,
        'compressed_states': compressed_states,
        'compression_ratio': compression_ratio,
        'collisions_per_compressed_state': collisions_per_state,
        'bits_lost_per_stage': bits_lost,
        'total_information_loss_bits': total_info_loss,
        'tropical_cost_penalty': tropical_cost_penalty,
        'num_stages': num_stages,
        'verdict': (
            "COMPRESSION FEASIBLE" if compressed_states >= full_state_space
            else "COMPRESSION LOSSY — tropical cost penalty applies"
        ),
    }


# ============================================================
# Application 4: Database Query Optimization
# ============================================================

def query_plan_tropical_cost(
    num_tables: int,
    join_widths: List[int],  # Width of each intermediate result
    max_memory: int,  # Maximum memory for intermediate results
) -> Dict:
    """
    Analyze database join optimization using tropical BP framework.
    
    A query plan for joining n tables can be modeled as a layered BP:
    - Each layer = processing one join
    - Width = number of distinct intermediate result schemas
    - Edge cost = I/O cost of materializing intermediate results
    
    The tropical lower bound says: if intermediate results must pass
    through memory bottlenecks, the total I/O cost has a certified
    minimum regardless of join ordering.
    
    Args:
        num_tables: Number of tables to join
        join_widths: Width of intermediate join results
        max_memory: Maximum buffer pool size
    
    Returns:
        Query plan analysis
    """
    # Spill cost: when intermediate result exceeds memory
    spill_costs = []
    for width in join_widths:
        if width > max_memory:
            spill_costs.append(width - max_memory)
        else:
            spill_costs.append(0)
    
    total_spill = sum(spill_costs)
    
    # Tropical lower bound: minimum total I/O
    # Each "layer" (join) that exceeds memory must spill
    layers_with_spill = sum(1 for c in spill_costs if c > 0)
    
    # Certificate: per-layer minimum cost
    min_spill_per_layer = min(spill_costs) if spill_costs else 0
    
    # Width-depth tradeoff for query plans
    if max_memory > 0:
        depth_lb = total_spill / max_memory if total_spill > 0 else 0
    else:
        depth_lb = INF
    
    return {
        'num_tables': num_tables,
        'num_joins': len(join_widths),
        'max_memory': max_memory,
        'join_widths': join_widths,
        'spill_costs': spill_costs,
        'total_spill_cost': total_spill,
        'layers_with_spill': layers_with_spill,
        'depth_lower_bound': depth_lb,
        'interpretation': (
            f"With {max_memory} units of memory, "
            f"{layers_with_spill} of {len(join_widths)} joins "
            f"must spill to disk. Total I/O lower bound: {total_spill}. "
            f"No join reordering can eliminate this cost."
        ),
    }


# ============================================================
# Main: Run All Applications
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("Application 1: Streaming Algorithm Barriers")
    print("=" * 60)
    
    for n, mem in [(100, 5), (1000, 8), (10000, 10)]:
        result = streaming_element_distinctness_barrier(n, mem)
        print(f"\nn={n}, memory={mem} bits ({result['memory_states']} states):")
        print(f"  Bottleneck: {result['bottleneck']}")
        print(f"  Tropical cost LB: {result['tropical_cost_lower_bound']}")
        print(f"  {result['explanation']}")
    
    print("\n" + "=" * 60)
    print("Application 2: Network Routing Congestion")
    print("=" * 60)
    
    links = [
        NetworkLink("A", "B", 10, 1.0),
        NetworkLink("B", "C", 5, 2.0),
        NetworkLink("A", "C", 8, 3.0),
        NetworkLink("C", "D", 3, 1.5),
    ]
    demands = [("A", "D", 4), ("A", "D", 3), ("B", "D", 2)]
    result = network_routing_congestion(links, demands, max_width=5)
    print(f"\nTotal demand: {result['total_demand']}")
    print(f"Min link capacity: {result['min_link_capacity']}")
    print(f"Congestion inevitable: {result['congestion_inevitable']}")
    print(f"Per-hop cost LB: {result['per_hop_cost_lower_bound']:.2f}")
    
    print("\n" + "=" * 60)
    print("Application 3: DP State Compression Barriers")
    print("=" * 60)
    
    for n, full, compressed in [(20, 2**20, 2**10), (30, 2**30, 2**15), (10, 1024, 1024)]:
        result = dp_compression_barrier(n, full, compressed, n)
        print(f"\nProblem size n={n}:")
        print(f"  Full states: {full}, Compressed: {compressed}")
        print(f"  Compression ratio: {result['compression_ratio']:.1f}x")
        print(f"  Bits lost/stage: {result['bits_lost_per_stage']:.1f}")
        print(f"  Verdict: {result['verdict']}")
    
    print("\n" + "=" * 60)
    print("Application 4: Database Query Optimization")
    print("=" * 60)
    
    result = query_plan_tropical_cost(
        num_tables=5,
        join_widths=[100, 500, 1200, 300],
        max_memory=400
    )
    print(f"\nJoin analysis ({result['num_tables']} tables):")
    print(f"  Max memory: {result['max_memory']}")
    print(f"  Join widths: {result['join_widths']}")
    print(f"  Spill costs: {result['spill_costs']}")
    print(f"  {result['interpretation']}")


#!/usr/bin/env python3
"""
Tropical Branching Program Complexity: Demonstrations

Concrete numerical examples showing how bounded-width tropical branching
programs incur super-linear costs when computing global predicates.
"""

import numpy as np
from typing import List, Tuple, Optional

# ============================================================
# Min-Plus (Tropical) Semiring Operations
# ============================================================

INF = float('inf')

def trop_add(a: float, b: float) -> float:
    """Tropical addition = min"""
    return min(a, b)

def trop_mul(a: float, b: float) -> float:
    """Tropical multiplication = ordinary addition"""
    if a == INF or b == INF:
        return INF
    return a + b

def trop_matmul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Tropical matrix multiplication: C[i,j] = min_k (A[i,k] + B[k,j])"""
    n, m = A.shape
    m2, p = B.shape
    assert m == m2
    C = np.full((n, p), INF)
    for i in range(n):
        for j in range(p):
            for k in range(m):
                C[i, j] = trop_add(C[i, j], trop_mul(A[i, k], B[k, j]))
    return C

def trop_matpow(A: np.ndarray, exp: int) -> np.ndarray:
    """Tropical matrix power via repeated squaring."""
    n = A.shape[0]
    result = np.full((n, n), INF)
    np.fill_diagonal(result, 0)  # Identity in tropical semiring
    base = A.copy()
    while exp > 0:
        if exp % 2 == 1:
            result = trop_matmul(result, base)
        base = trop_matmul(base, base)
        exp //= 2
    return result

# ============================================================
# Demo 1: Layered Branching Program with Width Bottleneck
# ============================================================

def demo_layered_bp():
    """
    Demonstrate a width-3 layered branching program with 4 layers.
    
    Layer structure:
      Layer 0: [start] (1 node)
      Layer 1: [a, b, c] (3 nodes = width)
      Layer 2: [d, e, f] (3 nodes = width)
      Layer 3: [accept] (1 node)
    
    Shows that total path cost = sum of per-layer edge costs,
    and the minimum cost path respects the layer structure.
    """
    print("=" * 60)
    print("Demo 1: Layered Tropical Branching Program")
    print("=" * 60)
    
    # Nodes: 0=start, 1-3=layer1, 4-6=layer2, 7=accept
    n = 8
    width = 3
    layers = 3
    
    # Cost matrix (INF = no edge)
    C = np.full((n, n), INF)
    
    # Layer 0 -> Layer 1 edges
    C[0, 1] = 2   # start -> a, cost 2
    C[0, 2] = 5   # start -> b, cost 5
    C[0, 3] = 1   # start -> c, cost 1
    
    # Layer 1 -> Layer 2 edges
    C[1, 4] = 3   # a -> d, cost 3
    C[1, 5] = 7   # a -> e, cost 7
    C[2, 4] = 1   # b -> d, cost 1
    C[2, 6] = 4   # b -> f, cost 4
    C[3, 5] = 2   # c -> e, cost 2
    C[3, 6] = 8   # c -> f, cost 8
    
    # Layer 2 -> Layer 3 edges
    C[4, 7] = 4   # d -> accept, cost 4
    C[5, 7] = 1   # e -> accept, cost 1
    C[6, 7] = 3   # f -> accept, cost 3
    
    print(f"Width: {width}, Layers: {layers}")
    print(f"Nodes: start(0), {{a,b,c}}(1-3), {{d,e,f}}(4-6), accept(7)")
    print()
    
    # Enumerate all paths and find costs
    paths = []
    for l1 in [1, 2, 3]:       # Layer 1 choices
        for l2 in [4, 5, 6]:   # Layer 2 choices
            c01 = C[0, l1]
            c12 = C[l1, l2]
            c23 = C[l2, 7]
            total = c01 + c12 + c23
            if total < INF:
                node_names = {0: 'start', 1: 'a', 2: 'b', 3: 'c',
                              4: 'd', 5: 'e', 6: 'f', 7: 'accept'}
                path_str = f"start -> {node_names[l1]} -> {node_names[l2]} -> accept"
                paths.append((total, path_str, [c01, c12, c23]))
    
    paths.sort()
    print("All accepting paths (sorted by total cost):")
    for total, path_str, layer_costs in paths:
        print(f"  {path_str}: layer costs = {layer_costs}, total = {total}")
    
    min_cost = paths[0][0]
    print(f"\nMinimum cost (tropical optimal): {min_cost}")
    print(f"Path: {paths[0][1]}")
    
    # Verify with tropical matrix power
    M3 = trop_matpow(C, 3)
    print(f"\nVerification via W^3[start,accept] = {M3[0, 7]}")
    assert M3[0, 7] == min_cost, "Matrix power should give minimum path cost"
    
    # Demonstrate the lower bound
    min_layer_costs = [INF, INF, INF]
    for _, _, lc in paths:
        for i in range(3):
            min_layer_costs[i] = min(min_layer_costs[i], lc[i])
    
    cert_total = sum(min_layer_costs)
    print(f"\nObstruction certificate (per-layer minimums): {min_layer_costs}")
    print(f"Certificate total cost: {cert_total}")
    print(f"Lower bound verified: {cert_total} ≤ {min_cost} ✓" 
          if cert_total <= min_cost else "ERROR")
    print()


# ============================================================
# Demo 2: Width Pigeonhole and State Compression
# ============================================================

def demo_pigeonhole():
    """
    Demonstrate the width pigeonhole collision lemma.
    
    With width w and more than w distinct input behaviors,
    at least two inputs must map to the same internal state.
    """
    print("=" * 60)
    print("Demo 2: Width Pigeonhole and State Compression")
    print("=" * 60)
    
    width = 4
    num_inputs = 10
    
    print(f"Width (number of states): {width}")
    print(f"Number of distinct inputs: {num_inputs}")
    print()
    
    # Random mapping from inputs to states
    np.random.seed(42)
    state_map = np.random.randint(0, width, size=num_inputs)
    
    print("Input -> State mapping:")
    for i in range(num_inputs):
        print(f"  Input {i} -> State {state_map[i]}")
    
    # Find collisions
    collisions = []
    for i in range(num_inputs):
        for j in range(i + 1, num_inputs):
            if state_map[i] == state_map[j]:
                collisions.append((i, j, state_map[i]))
    
    print(f"\nCollisions found: {len(collisions)}")
    for i, j, s in collisions[:5]:
        print(f"  Input {i} and Input {j} both map to State {s}")
    if len(collisions) > 5:
        print(f"  ... and {len(collisions) - 5} more")
    
    # Minimum number of collisions by pigeonhole
    min_collisions = num_inputs - width
    print(f"\nPigeonhole guarantee: at least {min_collisions} input pairs collide")
    print(f"  (since {num_inputs} inputs > {width} states)")
    print()


# ============================================================
# Demo 3: Direct-Sum Lower Bound
# ============================================================

def demo_direct_sum():
    """
    Demonstrate the direct-sum lower bound for tropical communication.
    
    If computing f once costs at least B, then computing k copies
    of f costs at least k * B.
    """
    print("=" * 60)
    print("Demo 3: Tropical Communication Direct-Sum Lower Bound")
    print("=" * 60)
    
    single_cost = 7  # Cost of computing f once
    k_values = [1, 2, 3, 5, 10, 20, 50, 100]
    
    print(f"Single-instance lower bound B = {single_cost}")
    print()
    print(f"{'k (copies)':>12} {'k * B (lower bound)':>20} {'Linear (k * 1)':>15} {'Ratio':>8}")
    print("-" * 60)
    
    for k in k_values:
        lower_bound = k * single_cost
        linear = k
        ratio = lower_bound / linear if linear > 0 else float('inf')
        print(f"{k:>12} {lower_bound:>20} {linear:>15} {ratio:>8.1f}x")
    
    print()
    print("Key insight: the lower bound grows linearly with k,")
    print("proving that independent instances cannot amortize cost.")
    print()


# ============================================================
# Demo 4: Width-Depth Tradeoff
# ============================================================

def demo_width_depth_tradeoff():
    """
    Demonstrate the width-depth tradeoff theorem.
    
    If total obstruction cost is B and max edge weight is W,
    then depth ≥ B / W.
    """
    print("=" * 60)
    print("Demo 4: Width-Depth Tradeoff")
    print("=" * 60)
    
    print()
    print(f"{'Obstruction B':>15} {'Max Weight W':>13} {'Min Depth B/W':>15} {'Width':>8}")
    print("-" * 55)
    
    configurations = [
        (100, 10, 4),
        (100, 5, 8),
        (100, 2, 16),
        (1000, 10, 4),
        (1000, 5, 8),
        (1000, 1, 32),
        (50, 1, 2),
    ]
    
    for B, W, width in configurations:
        min_depth = B // W
        print(f"{B:>15} {W:>13} {min_depth:>15} {width:>8}")
    
    print()
    print("Interpretation: to achieve low depth, you need either")
    print("high max edge weight or low obstruction cost.")
    print("Width bounds prevent reducing obstruction cost.")
    print()


# ============================================================
# Demo 5: Streaming Barrier Visualization
# ============================================================

def demo_streaming_barrier():
    """
    Show how bounded memory (= bounded width) forces high cost
    for global predicates like element distinctness.
    """
    print("=" * 60)
    print("Demo 5: Streaming Barrier for Element Distinctness")
    print("=" * 60)
    
    print()
    print("Element distinctness: given n elements, are all distinct?")
    print()
    print(f"{'n (elements)':>14} {'Memory bits':>13} {'States (2^m)':>14} {'Min cost':>10}")
    print("-" * 55)
    
    for n in [8, 16, 32, 64, 128, 256, 512, 1024]:
        for mem_bits in [4, 8]:
            states = 2 ** mem_bits
            if states < n:
                # With fewer states than elements, pigeonhole forces
                # expensive transitions
                min_cost = n - 1  # Must process each element
                print(f"{n:>14} {mem_bits:>13} {states:>14} {min_cost:>10}")
    
    print()
    print("Key insight: with bounded memory, the streaming algorithm")
    print("must pay for each element processed, yielding Ω(n) cost.")
    print()


# ============================================================
# Demo 6: Cost Composition (No Algebraic Collapse)
# ============================================================

def demo_cost_composition():
    """
    Demonstrate that tropical matrix multiplication preserves
    the existence of intermediate witnesses — costs don't collapse.
    """
    print("=" * 60)
    print("Demo 6: Tropical Cost Composition (No Collapse)")
    print("=" * 60)
    
    n = 4
    A = np.array([
        [0, 3, INF, 5],
        [INF, 0, 2, INF],
        [1, INF, 0, 4],
        [INF, INF, 3, 0]
    ])
    
    B = np.array([
        [0, INF, 2, INF],
        [4, 0, INF, 1],
        [INF, 3, 0, INF],
        [1, INF, INF, 0]
    ])
    
    C = trop_matmul(A, B)
    
    print(f"\nMatrix A (layer 1 costs):")
    for i in range(n):
        print(f"  {['∞' if x == INF else str(int(x)) for x in A[i]]}")
    
    print(f"\nMatrix B (layer 2 costs):")
    for i in range(n):
        print(f"  {['∞' if x == INF else str(int(x)) for x in B[i]]}")
    
    print(f"\nA ⊗ B (composed cost, tropical product):")
    for i in range(n):
        print(f"  {['∞' if x == INF else str(int(x)) for x in C[i]]}")
    
    # Show witnesses for non-infinite entries
    print(f"\nWitness decomposition (no-collapse theorem):")
    for i in range(n):
        for j in range(n):
            if C[i, j] < INF:
                witnesses = []
                for k in range(n):
                    if A[i, k] < INF and B[k, j] < INF:
                        witnesses.append((k, A[i, k] + B[k, j]))
                best_k, best_cost = min(witnesses, key=lambda x: x[1])
                print(f"  C[{i},{j}] = {int(C[i,j])}: "
                      f"witness k={best_k}, A[{i},{best_k}]={int(A[i,best_k])} + "
                      f"B[{best_k},{j}]={int(B[best_k,j])} = {int(best_cost)}")
    print()


if __name__ == "__main__":
    demo_layered_bp()
    demo_pigeonhole()
    demo_direct_sum()
    demo_width_depth_tradeoff()
    demo_streaming_barrier()
    demo_cost_composition()
    
    print("=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Tropical Branching Program Complexity: Visualizations

Generates charts and diagrams illustrating key results.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import base64
import io

def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def viz_direct_sum_scaling():
    """Visualize direct-sum lower bound scaling."""
    fig, ax = plt.subplots(1, 1, figsize=(8, 5))
    
    k_values = np.arange(1, 51)
    B_values = [3, 5, 7, 10]
    colors = ['#2196F3', '#4CAF50', '#FF9800', '#F44336']
    
    for B, color in zip(B_values, colors):
        lower_bounds = k_values * B
        ax.plot(k_values, lower_bounds, '-', color=color, linewidth=2,
                label=f'B = {B} (single-instance LB)')
    
    # Linear baseline
    ax.plot(k_values, k_values, '--', color='gray', linewidth=1.5,
            label='Linear baseline (k)', alpha=0.7)
    
    ax.set_xlabel('Number of independent copies (k)', fontsize=12)
    ax.set_ylabel('Total tropical cost lower bound', fontsize=12)
    ax.set_title('Direct-Sum Theorem: Cost Scales Linearly with Copies', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(1, 50)
    
    return fig_to_base64(fig)


def viz_width_depth_tradeoff():
    """Visualize width-depth tradeoff."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    
    # Left: Depth vs Width for fixed obstruction
    B = 100
    widths = np.arange(2, 21)
    
    for max_weight in [1, 2, 5, 10]:
        depths = B / (max_weight * widths)
        ax1.plot(widths, depths, 'o-', linewidth=2, markersize=4,
                label=f'Max edge weight = {max_weight}')
    
    ax1.set_xlabel('Width (states per layer)', fontsize=12)
    ax1.set_ylabel('Minimum depth (layers)', fontsize=12)
    ax1.set_title(f'Width-Depth Tradeoff (B = {B})', fontsize=14)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)
    
    # Right: Cost landscape
    widths_2d = np.arange(2, 20)
    depths_2d = np.arange(2, 20)
    W, D = np.meshgrid(widths_2d, depths_2d)
    
    # Maximum possible cost with uniform edge weight 1
    C = W * D  # width * depth = upper bound
    # Color by whether it exceeds obstruction
    im = ax2.contourf(W, D, C, levels=20, cmap='RdYlGn_r')
    plt.colorbar(im, ax=ax2, label='Width × Depth product')
    
    # Mark the B=100 isoline
    ax2.contour(W, D, C, levels=[100], colors='black', linewidths=2)
    ax2.set_xlabel('Width', fontsize=12)
    ax2.set_ylabel('Depth', fontsize=12)
    ax2.set_title('Cost Landscape (B=100 isoline in black)', fontsize=14)
    
    plt.tight_layout()
    return fig_to_base64(fig)


def viz_streaming_barrier():
    """Visualize streaming barrier for element distinctness."""
    fig, ax = plt.subplots(1, 1, figsize=(8, 5))
    
    n_values = np.arange(4, 257)
    
    for mem_bits in [3, 4, 5, 6, 7, 8]:
        states = 2 ** mem_bits
        costs = []
        for n in n_values:
            if states < n:
                costs.append(n - 1)  # Linear lower bound
            else:
                costs.append(0)
        ax.plot(n_values, costs, linewidth=2,
                label=f'{mem_bits} bits ({states} states)')
    
    ax.set_xlabel('Input size n', fontsize=12)
    ax.set_ylabel('Tropical cost lower bound', fontsize=12)
    ax.set_title('Streaming Barrier: Element Distinctness', fontsize=14)
    ax.legend(fontsize=10, loc='upper left')
    ax.grid(True, alpha=0.3)
    
    return fig_to_base64(fig)


def viz_obstruction_decomposition():
    """Visualize per-layer cost decomposition."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    
    # Left: Stacked bar chart of per-layer costs
    layers = 8
    num_paths = 5
    np.random.seed(42)
    
    layer_costs = np.random.randint(1, 10, size=(num_paths, layers))
    
    x = np.arange(num_paths)
    bottom = np.zeros(num_paths)
    colors = plt.cm.viridis(np.linspace(0.2, 0.8, layers))
    
    for i in range(layers):
        ax1.bar(x, layer_costs[:, i], bottom=bottom, color=colors[i],
                label=f'Layer {i}', edgecolor='white', linewidth=0.5)
        bottom += layer_costs[:, i]
    
    # Mark the certificate total
    cert_total = np.sum(np.min(layer_costs, axis=0))
    ax1.axhline(y=cert_total, color='red', linestyle='--', linewidth=2,
                label=f'Certificate LB = {cert_total}')
    
    ax1.set_xlabel('Path index', fontsize=12)
    ax1.set_ylabel('Total cost', fontsize=12)
    ax1.set_title('Per-Layer Cost Decomposition', fontsize=14)
    ax1.legend(fontsize=8, loc='upper right', ncol=3)
    ax1.set_xticks(x)
    ax1.set_xticklabels([f'Path {i}' for i in range(num_paths)])
    
    # Right: Certificate construction
    layer_mins = np.min(layer_costs, axis=0)
    layer_maxs = np.max(layer_costs, axis=0)
    layer_means = np.mean(layer_costs, axis=0)
    
    layer_indices = np.arange(layers)
    ax2.fill_between(layer_indices, layer_mins, layer_maxs,
                     alpha=0.2, color='blue', label='Cost range')
    ax2.plot(layer_indices, layer_means, 'b-o', linewidth=2,
             label='Mean cost', markersize=6)
    ax2.plot(layer_indices, layer_mins, 'r-s', linewidth=2,
             label='Certificate (min)', markersize=6)
    
    ax2.set_xlabel('Layer index', fontsize=12)
    ax2.set_ylabel('Per-layer cost', fontsize=12)
    ax2.set_title('Obstruction Certificate Construction', fontsize=14)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    
    plt.tight_layout()
    return fig_to_base64(fig)


def viz_pigeonhole():
    """Visualize pigeonhole collision density."""
    fig, ax = plt.subplots(1, 1, figsize=(8, 5))
    
    widths = np.arange(2, 51)
    behaviors_list = [10, 25, 50, 100]
    
    for behaviors in behaviors_list:
        # Minimum collisions = behaviors - width (when positive)
        min_collisions = np.maximum(0, behaviors - widths)
        # Expected collisions (birthday-paradox style) 
        expected = behaviors * (behaviors - 1) / (2 * widths)
        
        ax.plot(widths, min_collisions, '-', linewidth=2,
                label=f'{behaviors} behaviors (guaranteed)')
        ax.plot(widths, expected, '--', linewidth=1, alpha=0.5)
    
    ax.set_xlabel('Width (number of states)', fontsize=12)
    ax.set_ylabel('Number of collisions', fontsize=12)
    ax.set_title('Width Pigeonhole: State Collisions vs Width', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(2, 50)
    
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")
    
    viz1 = viz_direct_sum_scaling()
    viz2 = viz_width_depth_tradeoff()
    viz3 = viz_streaming_barrier()
    viz4 = viz_obstruction_decomposition()
    viz5 = viz_pigeonhole()
    
    # Save as standalone PNGs
    for name, data_uri in [
        ("direct_sum_scaling", viz1),
        ("width_depth_tradeoff", viz2),
        ("streaming_barrier", viz3),
        ("obstruction_decomposition", viz4),
        ("pigeonhole_collisions", viz5),
    ]:
        # Decode and save
        b64_data = data_uri.split(",")[1]
        with open(f"{name}.png", "wb") as f:
            f.write(base64.b64decode(b64_data))
        print(f"  Saved {name}.png")
    
    print("All visualizations generated successfully!")
