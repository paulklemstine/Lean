#!/usr/bin/env python3
"""
Applications of BP-to-Circuit Simulation

Demonstrates real-world applications of the simulation theorem:
1. Dynamic Programming as Circuit Evaluation
2. Streaming Algorithm Analysis
3. Shortest Path in Layered Graphs
4. Pattern Matching via Branching Programs
"""

from algorithms import (
    BranchingProgram, Literal, TropicalBP,
    transfer_matrix_product, tropical_matrix_multiply,
    min_depth_from_circuit_lower_bound, min_width_from_circuit_lower_bound,
    INF
)


# ============================================================
# Application 1: Dynamic Programming as Circuit Evaluation
# ============================================================

def app_knapsack_dp():
    """
    0/1 Knapsack via tropical branching program.

    Items have weights and values. We want to maximize total value
    subject to capacity constraint.

    The BP has width = capacity + 1 (one state per possible weight),
    depth = number of items.

    In tropical (max-plus) interpretation, the BP computes the
    maximum value achievable.
    """
    print("=" * 60)
    print("APPLICATION 1: 0/1 Knapsack as Tropical BP")
    print("=" * 60)

    # Items: (weight, value)
    items = [(2, 3), (3, 4), (4, 5), (5, 8)]
    capacity = 7
    n_items = len(items)

    # States = {0, 1, ..., capacity} = current weight used
    # We use max-plus: want to MAXIMIZE value
    # Edge weight: item value if taken, 0 if not
    w = capacity + 1  # width = capacity + 1
    d = n_items        # depth = number of items

    # Build tropical BP (using negative weights for min-plus = max-plus trick)
    weights = {}
    for i, (item_w, item_v) in enumerate(items):
        for s in range(w):
            # Don't take item i: stay at same weight, value += 0
            weights[(i, s, s)] = 0
            # Take item i: weight increases by item_w, value += item_v
            if s + item_w < w:
                weights[(i, s, s + item_w)] = -item_v  # negative for max-plus via min-plus

    tbp = TropicalBP(w=w, d=d, start=0, accept=0, weights=weights)

    # Find best value by checking all accept states
    costs = tbp.evaluate()
    best_value = INF
    best_state = -1
    for s in range(w):
        if costs[d][s] < best_value:
            best_value = costs[d][s]
            best_state = s

    print(f"Items: {items}")
    print(f"Capacity: {capacity}")
    print(f"BP width: {w}, depth: {d}")
    print(f"Circuit op count bound: {2 * w * w * d + w}")
    print(f"Best value: {-best_value} (weight used: {best_state})")
    print(f"DP table (negated costs = accumulated values):")
    for i in range(d + 1):
        vals = [f"{-c:5.0f}" if c < INF else "  ---" for c in costs[i]]
        print(f"  After item {i}: {vals}")
    print()


# ============================================================
# Application 2: Streaming Algorithm Analysis
# ============================================================

def app_streaming_analysis():
    """
    Analyze streaming algorithm memory requirements.

    A streaming algorithm with s bits of memory is a BP of width 2^s.
    The simulation theorem gives: circuit_size ≤ 2·(2^s)²·d + 2^s.

    If a function requires circuit size ≥ K, then:
    s ≥ ½ log₂((K - 2^s) / (2d))
    """
    import math

    print("=" * 60)
    print("APPLICATION 2: Streaming Algorithm Memory Bounds")
    print("=" * 60)

    print("\nIf a function requires circuit size ≥ K,")
    print("any streaming algorithm with s bits of memory and d passes satisfies:")
    print("  K ≤ 2 · 4^s · d + 2^s")
    print()

    K_values = [100, 1000, 10000, 100000]
    passes = [1, 2, 5, 10]

    print(f"{'K':>8} | {'passes':>6} | {'min memory bits':>15} | {'2·4^s·d + 2^s':>14}")
    print("-" * 55)
    for K in K_values:
        for d in passes:
            # Find minimum s such that 2·4^s·d + 2^s ≥ K
            for s in range(0, 30):
                bound = 2 * (4 ** s) * d + (2 ** s)
                if bound >= K:
                    print(f"{K:8d} | {d:6d} | {s:15d} | {bound:14d}")
                    break
    print()


# ============================================================
# Application 3: Layered Graph Shortest Path
# ============================================================

def app_layered_shortest_path():
    """
    Shortest path in a layered DAG.

    This is the canonical application of tropical BPs:
    each layer = one step in the graph, each state = a vertex.
    """
    print("=" * 60)
    print("APPLICATION 3: Shortest Path in Layered Graph")
    print("=" * 60)

    # Create a layered graph: 5 vertices, 6 layers
    w, d = 5, 6

    # Random-ish weights for a realistic example
    import random
    random.seed(42)

    weights = {}
    for layer in range(d):
        for u in range(w):
            # Each vertex connects to 2-3 random successors
            n_edges = random.randint(2, 3)
            targets = random.sample(range(w), n_edges)
            for v in targets:
                cost = random.randint(1, 10)
                weights[(layer, u, v)] = cost

    tbp = TropicalBP(w=w, d=d, start=0, accept=w-1, weights=weights)

    # Compute shortest path
    costs = tbp.evaluate()
    min_cost = costs[d][w - 1]

    print(f"Graph: {w} vertices, {d} layers")
    print(f"Source: vertex 0, Target: vertex {w-1}")
    print(f"Circuit op count bound: {2 * w * w * d + w}")
    print()
    print("Layer-by-layer shortest distances from source:")
    for i in range(d + 1):
        vals = [f"{c:4.0f}" if c < INF else " inf" for c in costs[i]]
        print(f"  Layer {i}: {vals}")
    print(f"\nShortest path cost: {min_cost}")

    # Verify via transfer matrix product
    product = transfer_matrix_product(tbp)
    assert product[0][w - 1] == min_cost, "Transfer matrix product mismatch!"
    print(f"Verified via transfer matrix product: {product[0][w-1]}")
    print()


# ============================================================
# Application 4: Pattern Matching
# ============================================================

def app_pattern_matching():
    """
    String pattern matching as a branching program.

    Match a fixed pattern in a text. The BP states track how much
    of the pattern has been matched so far.
    """
    print("=" * 60)
    print("APPLICATION 4: Pattern Matching via BP")
    print("=" * 60)

    # Pattern: "101" in a 6-bit input
    # States: 0 = nothing matched, 1 = "1" matched, 2 = "10" matched, 3 = "101" matched
    pattern = [True, False, True]  # "101"
    text_len = 6
    n_states = len(pattern) + 1  # 4 states

    bp = BranchingProgram(n=text_len, w=n_states, d=text_len, start=0, accept=3)

    for i in range(text_len):
        for s in range(n_states):
            if s < len(pattern):
                # If current bit matches next pattern bit: advance
                target_bit = pattern[s]
                bp.edges[(i, s, s + 1)] = Literal(i, neg=not target_bit)
                # If current bit doesn't match: reset to 0 (simplified)
                bp.edges[(i, s, 0)] = Literal(i, neg=target_bit)
            else:
                # Pattern fully matched: stay in accept state
                bp.edges[(i, s, s)] = Literal(i, neg=False)  # any bit
                bp.edges[(i, s, s)] = None  # unconditional

    circuit = bp.compile_to_circuit()

    print(f"Pattern: {''.join(str(int(b)) for b in pattern)}")
    print(f"Text length: {text_len}")
    print(f"BP width: {n_states}, depth: {text_len}")
    print(f"Circuit op count: {circuit.op_count} (bound: {circuit.op_count_bound})")
    print()

    # Test on some inputs
    test_inputs = [
        [True, False, True, False, True, False],   # "101010" - contains "101"
        [False, False, False, False, False, False], # "000000" - no match
        [True, True, False, True, False, True],     # "110101" - contains "101"
        [False, True, False, True, True, False],    # "010110" - contains "101"
    ]

    for x in test_inputs:
        bits_str = "".join(str(int(b)) for b in x)
        result = bp.accepts(x)
        print(f"  Input {bits_str}: {'MATCH' if result else 'no match'}")
    print()


# ============================================================
# Application 5: Width-Depth Tradeoff Analysis
# ============================================================

def app_tradeoff_analysis():
    """
    Analyze the width-depth tradeoff for various circuit size targets.
    """
    import math

    print("=" * 60)
    print("APPLICATION 5: Width-Depth Tradeoff Curves")
    print("=" * 60)

    K = 10000  # circuit size lower bound
    print(f"\nCircuit size lower bound K = {K}")
    print(f"Constraint: K ≤ 2w²d + w")
    print(f"For fixed width w: d ≥ (K - w) / (2w²)")
    print(f"For fixed depth d: w ≥ √((K - w) / (2d)) ≈ √(K / (2d))")
    print()

    print("Fixed-width analysis:")
    print(f"{'width w':>10} | {'min depth d':>12} | {'w²d':>10} | {'2w²d+w':>10}")
    print("-" * 50)
    for w in [2, 3, 5, 8, 10, 15, 20, 50, 100]:
        d = min_depth_from_circuit_lower_bound(K, w)
        w2d = w * w * d
        bound = 2 * w * w * d + w
        print(f"{w:10d} | {d:12d} | {w2d:10d} | {bound:10d}")

    print()
    print("Fixed-depth analysis:")
    print(f"{'depth d':>10} | {'min width w':>12} | {'w²d':>10} | {'2w²d+w':>10}")
    print("-" * 50)
    for d in [1, 2, 5, 10, 20, 50, 100, 500]:
        w = min_width_from_circuit_lower_bound(K, d)
        w2d = w * w * d
        bound = 2 * w * w * d + w
        print(f"{d:10d} | {w:12d} | {w2d:10d} | {bound:10d}")
    print()


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    app_knapsack_dp()
    app_streaming_analysis()
    app_layered_shortest_path()
    app_pattern_matching()
    app_tradeoff_analysis()


#!/usr/bin/env python3
"""
Branching Program to Circuit Simulation — Demonstrations

Concrete numerical examples demonstrating the BP-to-circuit simulation theorem
and its tropical extension.
"""

from typing import Optional, Callable
import itertools


# ============================================================
# Core Data Structures
# ============================================================

class Literal:
    """A Boolean literal: variable index with optional negation."""
    def __init__(self, var: int, neg: bool = False):
        self.var = var
        self.neg = neg

    def eval(self, x: list[bool]) -> bool:
        return x[self.var] ^ self.neg

    def __repr__(self):
        return f"{'¬' if self.neg else ''}x{self.var}"


class BP:
    """
    Layered Branching Program.
    - n: number of input variables
    - w: width (states per layer)
    - d: depth (transition layers)
    - start, accept: start and accept state indices
    - edges: dict (layer, src, dst) -> Literal or None
      Missing keys = no edge. None value = unconditional edge (always active).
    """
    def __init__(self, n: int, w: int, d: int, start: int, accept: int,
                 edges: dict[tuple[int,int,int], Optional[Literal]]):
        self.n = n
        self.w = w
        self.d = d
        self.start = start
        self.accept = accept
        self.edges = edges

    def edge_active(self, x: list[bool], layer: int, u: int, v: int) -> bool:
        key = (layer, u, v)
        if key not in self.edges:
            return False
        lit = self.edges[key]
        if lit is None:
            return True  # unconditional edge
        return lit.eval(x)

    def reachable(self, x: list[bool]) -> list[set[int]]:
        """Compute reachable states at each layer."""
        layers = [set() for _ in range(self.d + 1)]
        layers[0].add(self.start)
        for i in range(self.d):
            for u in layers[i]:
                for v in range(self.w):
                    if self.edge_active(x, i, u, v):
                        layers[i+1].add(v)
        return layers

    def accepts(self, x: list[bool]) -> bool:
        return self.accept in self.reachable(x)[self.d]


class LayeredCircuit:
    """
    Layered Boolean Circuit simulating a BP.
    Gate (i, v) computes whether state v is reachable at layer i.
    """
    def __init__(self, bp: BP):
        self.depth = bp.d
        self.width = bp.w
        self.bp = bp
        self.output_gate = bp.accept

    def eval(self, x: list[bool], layer: int, v: int) -> bool:
        """Evaluate gate (layer, v) = reachable(layer, v)."""
        if layer == 0:
            return v == self.bp.start
        return any(
            self.eval(x, layer - 1, u) and self.bp.edge_active(x, layer - 1, u, v)
            for u in range(self.width)
        )

    def accepts(self, x: list[bool]) -> bool:
        return self.eval(x, self.depth, self.output_gate)

    @property
    def op_count(self) -> int:
        """w²d + wd + w"""
        w, d = self.width, self.depth
        return w * w * d + w * d + w

    @property
    def op_count_bound(self) -> int:
        """2w²d + w"""
        w, d = self.width, self.depth
        return 2 * w * w * d + w


# ============================================================
# Tropical Extension
# ============================================================

INF = float('inf')

class TropicalBP:
    """
    Tropical (min-plus) branching program.
    Edge weights are non-negative reals; INF = no edge.
    """
    def __init__(self, w: int, d: int, start: int, accept: int,
                 weights: dict[tuple[int,int,int], float]):
        self.w = w
        self.d = d
        self.start = start
        self.accept = accept
        self.weights = weights

    def edge_weight(self, layer: int, u: int, v: int) -> float:
        return self.weights.get((layer, u, v), INF)

    def trop_reachable(self) -> list[list[float]]:
        """Compute min-cost to reach each state at each layer."""
        costs = [[INF] * self.w for _ in range(self.d + 1)]
        costs[0][self.start] = 0
        for i in range(self.d):
            for v in range(self.w):
                for u in range(self.w):
                    w_uv = self.edge_weight(i, u, v)
                    if costs[i][u] < INF and w_uv < INF:
                        costs[i+1][v] = min(costs[i+1][v], costs[i][u] + w_uv)
        return costs

    def min_cost(self) -> float:
        return self.trop_reachable()[self.d][self.accept]


# ============================================================
# Demo 1: Parity Checker
# ============================================================

def demo_parity():
    """
    A width-2 BP that checks parity of 4 input bits.
    State 0 = even parity so far, State 1 = odd parity.
    """
    print("=" * 60)
    print("DEMO 1: Parity Checker (4 bits, width 2)")
    print("=" * 60)

    n, w, d = 4, 2, 4
    edges = {}
    for i in range(d):
        # If x_i = 0: stay in same state (literal x_i negated)
        edges[(i, 0, 0)] = Literal(i, neg=True)   # 0 -> 0 when ¬x_i
        edges[(i, 1, 1)] = Literal(i, neg=True)   # 1 -> 1 when ¬x_i
        # If x_i = 1: flip state
        edges[(i, 0, 1)] = Literal(i, neg=False)  # 0 -> 1 when x_i
        edges[(i, 1, 0)] = Literal(i, neg=False)  # 1 -> 0 when x_i

    bp = BP(n=n, w=w, d=d, start=0, accept=1, edges=edges)  # accept state 1 = odd parity
    circuit = LayeredCircuit(bp)

    print(f"BP: width={w}, depth={d}, vars={n}")
    print(f"Circuit op count: {circuit.op_count} (bound: {circuit.op_count_bound})")
    print()

    print("Input          | Parity | BP accepts | Circuit accepts | Match")
    print("-" * 70)
    for bits in itertools.product([False, True], repeat=n):
        x = list(bits)
        parity = sum(x) % 2 == 1
        bp_result = bp.accepts(x)
        ckt_result = circuit.accepts(x)
        match = "✓" if bp_result == ckt_result == parity else "✗"
        bits_str = "".join(str(int(b)) for b in x)
        print(f"  {bits_str}           | {'odd ' if parity else 'even'}"
              f"   | {str(bp_result):5s}      | {str(ckt_result):5s}           | {match}")

    # Verify all match
    all_match = all(
        bp.accepts(list(x)) == circuit.accepts(list(x))
        for x in itertools.product([False, True], repeat=n)
    )
    print(f"\nAll 2^{n} = {2**n} inputs match: {all_match}")
    print()


# ============================================================
# Demo 2: Majority Function
# ============================================================

def demo_majority():
    """
    A width-4 BP that computes majority of 3 input bits.
    States encode the count of 1-bits seen so far (0, 1, 2, 3).
    """
    print("=" * 60)
    print("DEMO 2: Majority of 3 bits (width 4)")
    print("=" * 60)

    n, w, d = 3, 4, 3
    edges = {}
    for i in range(d):
        for count in range(min(i + 1, 4)):  # possible counts at layer i
            if count < 3:
                # x_i = 0: stay at same count
                edges[(i, count, count)] = Literal(i, neg=True)
                # x_i = 1: increment count
                edges[(i, count, count + 1)] = Literal(i, neg=False)

    bp = BP(n=n, w=w, d=d, start=0, accept=2, edges=edges)  # accept ≥ 2
    circuit = LayeredCircuit(bp)

    print(f"BP: width={w}, depth={d}, vars={n}")
    print(f"Circuit op count: {circuit.op_count} (bound: {circuit.op_count_bound})")
    print()

    # Also check accept=3 and combine
    bp3 = BP(n=n, w=w, d=d, start=0, accept=3, edges=edges)

    print("Input | Majority | BP(≥2) | BP(=3) | Maj=BP(≥2)∨BP(=3)")
    print("-" * 60)
    for bits in itertools.product([False, True], repeat=n):
        x = list(bits)
        majority = sum(x) >= 2
        r2 = bp.accepts(x)
        r3 = bp3.accepts(x)
        combined = r2 or r3
        bits_str = "".join(str(int(b)) for b in x)
        print(f"  {bits_str}  | {str(majority):5s}    | {str(r2):5s}  | {str(r3):5s}  | {str(combined):5s}")

    print()


# ============================================================
# Demo 3: Tropical Shortest Path
# ============================================================

def demo_tropical():
    """
    A tropical BP computing shortest paths in a layered graph.
    """
    print("=" * 60)
    print("DEMO 3: Tropical (Min-Plus) Shortest Path")
    print("=" * 60)

    # 3 states, 4 layers
    w, d = 3, 4
    weights = {
        # Layer 0
        (0, 0, 0): 2, (0, 0, 1): 5, (0, 0, 2): INF,
        (0, 1, 0): INF, (0, 1, 1): 1, (0, 1, 2): 3,
        (0, 2, 0): INF, (0, 2, 1): INF, (0, 2, 2): 4,
        # Layer 1
        (1, 0, 0): 1, (1, 0, 1): INF, (1, 0, 2): 6,
        (1, 1, 0): 3, (1, 1, 1): 2, (1, 1, 2): INF,
        (1, 2, 0): INF, (1, 2, 1): 1, (1, 2, 2): 2,
        # Layer 2
        (2, 0, 0): 4, (2, 0, 1): 1, (2, 0, 2): INF,
        (2, 1, 0): INF, (2, 1, 1): 3, (2, 1, 2): 2,
        (2, 2, 0): 5, (2, 2, 1): INF, (2, 2, 2): 1,
        # Layer 3
        (3, 0, 0): 2, (3, 0, 1): INF, (3, 0, 2): 3,
        (3, 1, 0): 1, (3, 1, 1): 4, (3, 1, 2): INF,
        (3, 2, 0): INF, (3, 2, 1): 2, (3, 2, 2): 5,
    }

    tbp = TropicalBP(w=w, d=d, start=0, accept=2, weights=weights)
    costs = tbp.trop_reachable()

    print(f"Tropical BP: width={w}, depth={d}")
    print(f"Start state: 0, Accept state: 2")
    print(f"Circuit op count bound: {2 * w * w * d + w}")
    print()
    print("Layer-by-layer min costs:")
    for i in range(d + 1):
        costs_str = [f"{c:5.1f}" if c < INF else "  inf" for c in costs[i]]
        print(f"  Layer {i}: {costs_str}")
    print(f"\nMinimum cost to accept: {tbp.min_cost()}")
    print()


# ============================================================
# Demo 4: Size Bound Verification
# ============================================================

def demo_size_bounds():
    """
    Verify the size bound 2w²d + w for various parameters.
    """
    print("=" * 60)
    print("DEMO 4: Size Bound Verification")
    print("=" * 60)
    print()
    print(f"{'w':>4} {'d':>4} | {'w²d+wd+w':>10} {'2w²d+w':>10} | {'bound holds':>12}")
    print("-" * 50)

    for w in range(0, 8):
        for d in [0, 1, 5, 10, 50]:
            actual = w * w * d + w * d + w
            bound = 2 * w * w * d + w
            holds = actual <= bound
            print(f"{w:4d} {d:4d} | {actual:10d} {bound:10d} | {'✓' if holds else '✗':>12}")
    print()


# ============================================================
# Demo 5: Lower Bound Transfer
# ============================================================

def demo_lower_bound_transfer():
    """
    Demonstrate the lower bound transfer:
    If circuit size ≥ K, then w²d ≥ (K-w)/2.
    """
    print("=" * 60)
    print("DEMO 5: Lower Bound Transfer")
    print("=" * 60)
    print()
    print("If a function requires circuit size ≥ K,")
    print("then any BP with width w, depth d satisfies K ≤ 2w²d + w.")
    print("Equivalently: d ≥ (K - w) / (2w²) for w ≥ 1.")
    print()

    K = 1000
    print(f"Example: K = {K}")
    print(f"{'w':>4} | {'min depth d':>12} | {'2w²d + w':>10}")
    print("-" * 35)
    for w in [1, 2, 3, 4, 5, 10, 20, 50]:
        # K ≤ 2w²d + w  =>  d ≥ (K - w) / (2w²)
        min_d = max(0, -(-( K - w) // (2 * w * w)))  # ceiling division
        actual_bound = 2 * w * w * min_d + w
        print(f"{w:4d} | {min_d:12d} | {actual_bound:10d}")
    print()


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    demo_parity()
    demo_majority()
    demo_tropical()
    demo_size_bounds()
    demo_lower_bound_transfer()


#!/usr/bin/env python3
"""
Visualizations for BP-to-Circuit Simulation

Generates publication-quality figures:
1. BP structure diagram
2. Size bound comparison
3. Width-depth tradeoff curves
4. Tropical reachability heatmap
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import base64
import io


def fig_to_base64(fig, fmt='png', dpi=150):
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format=fmt, dpi=dpi, bbox_inches='tight')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/{fmt};base64,{b64}"


def viz_size_bound():
    """
    Plot the operation count w²d + wd + w vs the bound 2w²d + w.
    """
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Fixed d, varying w
    ax = axes[0]
    d = 10
    ws = np.arange(1, 21)
    actual = ws**2 * d + ws * d + ws
    bound = 2 * ws**2 * d + ws
    ax.plot(ws, actual, 'b-o', label='Actual: w²d + wd + w', markersize=4)
    ax.plot(ws, bound, 'r--s', label='Bound: 2w²d + w', markersize=4)
    ax.fill_between(ws, actual, bound, alpha=0.15, color='green', label='Slack')
    ax.set_xlabel('Width w', fontsize=12)
    ax.set_ylabel('Operation Count', fontsize=12)
    ax.set_title(f'Size Bound (depth d = {d})', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Fixed w, varying d
    ax = axes[1]
    w = 5
    ds = np.arange(1, 31)
    actual = w**2 * ds + w * ds + w
    bound = 2 * w**2 * ds + w
    ax.plot(ds, actual, 'b-o', label='Actual: w²d + wd + w', markersize=4)
    ax.plot(ds, bound, 'r--s', label='Bound: 2w²d + w', markersize=4)
    ax.fill_between(ds, actual, bound, alpha=0.15, color='green', label='Slack')
    ax.set_xlabel('Depth d', fontsize=12)
    ax.set_ylabel('Operation Count', fontsize=12)
    ax.set_title(f'Size Bound (width w = {w})', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    fig.suptitle('BP-to-Circuit Simulation: Size Bound Analysis', fontsize=14, y=1.02)
    fig.tight_layout()
    return fig


def viz_tradeoff_curves():
    """
    Plot width-depth tradeoff curves for different circuit size targets.
    """
    fig, ax = plt.subplots(figsize=(10, 7))

    K_values = [100, 500, 1000, 5000, 10000]
    colors = plt.cm.viridis(np.linspace(0.1, 0.9, len(K_values)))

    for K, color in zip(K_values, colors):
        ws = np.arange(1, int(np.sqrt(K)) + 1)
        ds = np.maximum(0, np.ceil((K - ws) / (2 * ws**2))).astype(int)
        ax.plot(ws, ds, '-', color=color, linewidth=2, label=f'K = {K}')

    ax.set_xlabel('Width w', fontsize=13)
    ax.set_ylabel('Minimum Depth d', fontsize=13)
    ax.set_title('Width-Depth Tradeoff: K ≤ 2w²d + w', fontsize=14)
    ax.legend(fontsize=11, title='Circuit Size\nLower Bound K')
    ax.set_yscale('log')
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    return fig


def viz_tropical_heatmap():
    """
    Heatmap of tropical reachability costs in a layered graph.
    """
    import random
    random.seed(42)

    w, d = 8, 12
    INF = float('inf')

    # Generate random tropical BP
    weights = {}
    for layer in range(d):
        for u in range(w):
            n_edges = random.randint(2, 4)
            targets = random.sample(range(w), min(n_edges, w))
            for v in targets:
                weights[(layer, u, v)] = random.randint(1, 8)

    # Compute costs
    costs = [[INF] * w for _ in range(d + 1)]
    costs[0][0] = 0
    for i in range(d):
        for v in range(w):
            for u in range(w):
                wt = weights.get((i, u, v), INF)
                if costs[i][u] < INF and wt < INF:
                    costs[i + 1][v] = min(costs[i + 1][v], costs[i][u] + wt)

    # Replace INF with NaN for visualization
    data = np.array([[c if c < INF else np.nan for c in row] for row in costs])

    fig, ax = plt.subplots(figsize=(12, 6))
    im = ax.imshow(data.T, aspect='auto', cmap='YlOrRd', origin='lower')
    ax.set_xlabel('Layer', fontsize=13)
    ax.set_ylabel('State', fontsize=13)
    ax.set_title('Tropical Reachability: Min-Cost to Each State', fontsize=14)
    ax.set_xticks(range(d + 1))
    ax.set_yticks(range(w))

    # Add text annotations
    for i in range(d + 1):
        for v in range(w):
            if not np.isnan(data[i][v]):
                ax.text(i, v, f'{int(data[i][v])}', ha='center', va='center',
                       fontsize=8, color='black' if data[i][v] < np.nanmax(data) * 0.6 else 'white')
            else:
                ax.text(i, v, '∞', ha='center', va='center', fontsize=8, color='gray')

    plt.colorbar(im, ax=ax, label='Min Cost')
    fig.tight_layout()
    return fig


def viz_bp_circuit_diagram():
    """
    Schematic diagram showing BP → Circuit transformation.
    """
    fig, axes = plt.subplots(1, 2, figsize=(16, 6))

    # Left: Branching Program
    ax = axes[0]
    ax.set_title('Branching Program (w=3, d=4)', fontsize=13)
    ax.set_xlim(-0.5, 4.5)
    ax.set_ylim(-0.5, 2.5)

    # Draw nodes
    for layer in range(5):
        for state in range(3):
            color = '#4CAF50' if (layer == 0 and state == 0) else \
                    '#F44336' if (layer == 4 and state == 2) else '#2196F3'
            circle = plt.Circle((layer, state), 0.2, color=color, ec='black', lw=1.5)
            ax.add_patch(circle)
            ax.text(layer, state, f'{state}', ha='center', va='center',
                   fontsize=9, fontweight='bold', color='white')

    # Draw some edges
    import random
    random.seed(123)
    edge_pairs = []
    for layer in range(4):
        for u in range(3):
            targets = random.sample(range(3), random.randint(1, 2))
            for v in targets:
                edge_pairs.append((layer, u, v))
                ax.annotate('', xy=(layer + 1 - 0.22, v), xytext=(layer + 0.22, u),
                          arrowprops=dict(arrowstyle='->', color='#666', lw=1.2))

    ax.set_xlabel('Layer', fontsize=12)
    ax.set_ylabel('State', fontsize=12)
    ax.set_xticks(range(5))
    ax.set_yticks(range(3))
    ax.set_aspect('equal')

    # Add legend
    legend_elements = [
        mpatches.Patch(color='#4CAF50', label='Start'),
        mpatches.Patch(color='#F44336', label='Accept'),
        mpatches.Patch(color='#2196F3', label='Intermediate'),
    ]
    ax.legend(handles=legend_elements, loc='upper left', fontsize=9)

    # Right: Circuit
    ax = axes[1]
    ax.set_title('Simulation Circuit (w²=9 ops/layer)', fontsize=13)
    ax.set_xlim(-0.5, 4.5)
    ax.set_ylim(-0.5, 2.5)

    # Draw gates
    for layer in range(5):
        for gate in range(3):
            shape = 's' if layer > 0 else 'o'  # squares for computed gates
            color = '#FF9800' if layer > 0 else '#4CAF50'
            if layer == 4 and gate == 2:
                color = '#F44336'
            ax.plot(layer, gate, shape, color=color, markersize=15,
                   markeredgecolor='black', markeredgewidth=1.5)
            ax.text(layer, gate, f'G{gate}', ha='center', va='center',
                   fontsize=8, fontweight='bold')

    # Draw connections (all-to-all between layers)
    for layer in range(4):
        for u in range(3):
            for v in range(3):
                ax.plot([layer + 0.15, layer + 0.85], [u, v],
                       color='#CCC', lw=0.5, alpha=0.5)

    ax.set_xlabel('Layer', fontsize=12)
    ax.set_ylabel('Gate', fontsize=12)
    ax.set_xticks(range(5))
    ax.set_yticks(range(3))
    ax.set_aspect('equal')

    legend_elements = [
        mpatches.Patch(color='#4CAF50', label='Base gates'),
        mpatches.Patch(color='#FF9800', label='OR(AND) gates'),
        mpatches.Patch(color='#F44336', label='Output gate'),
    ]
    ax.legend(handles=legend_elements, loc='upper left', fontsize=9)

    fig.suptitle('BP → Circuit Simulation', fontsize=15, y=1.02)
    fig.tight_layout()
    return fig


def viz_quadratic_factor():
    """
    Visualization of why the w² factor appears:
    all predecessor-successor pairs in a transition layer.
    """
    fig, ax = plt.subplots(figsize=(8, 8))

    w = 4
    # Draw two columns of states
    for v in range(w):
        # Layer i states (left)
        circle = plt.Circle((1, v), 0.25, color='#2196F3', ec='black', lw=2)
        ax.add_patch(circle)
        ax.text(1, v, f'u={v}', ha='center', va='center', fontsize=10, color='white', fontweight='bold')

        # Layer i+1 states (right)
        circle = plt.Circle((4, v), 0.25, color='#FF9800', ec='black', lw=2)
        ax.add_patch(circle)
        ax.text(4, v, f'v={v}', ha='center', va='center', fontsize=10, color='white', fontweight='bold')

    # Draw all w² connections
    for u in range(w):
        for v in range(w):
            ax.annotate('', xy=(4 - 0.28, v), xytext=(1 + 0.28, u),
                      arrowprops=dict(arrowstyle='->', color='#999', lw=0.8, alpha=0.6))
            # Label with AND gate
            mid_x = 2.5
            mid_y = (u + v) / 2
            ax.plot(mid_x, mid_y, 'D', color='#E91E63', markersize=3, alpha=0.5)

    ax.set_xlim(0, 5)
    ax.set_ylim(-0.5, w - 0.5)
    ax.set_title(f'w² = {w}² = {w*w} interactions per layer\n'
                 f'(Each arrow = one AND gate)', fontsize=13)
    ax.text(1, -0.4, 'Layer i', ha='center', fontsize=12, fontweight='bold')
    ax.text(4, -0.4, 'Layer i+1', ha='center', fontsize=12, fontweight='bold')
    ax.set_aspect('equal')
    ax.axis('off')
    fig.tight_layout()
    return fig


def generate_all():
    """Generate all visualizations and save them."""
    figs = {
        'size_bound': viz_size_bound(),
        'tradeoff_curves': viz_tradeoff_curves(),
        'tropical_heatmap': viz_tropical_heatmap(),
        'bp_circuit_diagram': viz_bp_circuit_diagram(),
        'quadratic_factor': viz_quadratic_factor(),
    }

    for name, fig in figs.items():
        fig.savefig(f'{name}.png', dpi=150, bbox_inches='tight')
        print(f"Saved {name}.png")

    return figs


def get_all_base64():
    """Get all visualizations as base64 data URIs."""
    return {
        'size_bound': fig_to_base64(viz_size_bound()),
        'tradeoff_curves': fig_to_base64(viz_tradeoff_curves()),
        'tropical_heatmap': fig_to_base64(viz_tropical_heatmap()),
        'bp_circuit_diagram': fig_to_base64(viz_bp_circuit_diagram()),
        'quadratic_factor': fig_to_base64(viz_quadratic_factor()),
    }


if __name__ == "__main__":
    generate_all()
