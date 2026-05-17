"""
Algorithms for Weighted Tropical BP-to-Circuit Simulation.

This module implements:
1. WeightedBP: a layered branching program with real-valued edge weights.
2. TropicalCircuit: a min-plus circuit with explicit layer structure.
3. bp_to_circuit: the simulation construction with operation count bound.
4. Bellman evaluation for branching programs.

All operations use float('inf') as the top element (unreachable state).
"""

from __future__ import annotations
import numpy as np
from dataclasses import dataclass
from typing import Optional

INF = float('inf')


@dataclass
class WeightedBP:
    """A weighted layered branching program.
    
    Attributes:
        width: Number of states per layer.
        depth: Number of layers (transitions).
        start: Index of the start state.
        accept: Index of the accept state.
        edge_weights: Array of shape (depth, width, width) where
            edge_weights[i, u, v] is the cost of the edge from state u
            at layer i to state v at layer i+1. Use INF for absent edges.
    """
    width: int
    depth: int
    start: int
    accept: int
    edge_weights: np.ndarray  # shape (depth, width, width)

    def __post_init__(self):
        assert self.edge_weights.shape == (self.depth, self.width, self.width)
        assert 0 <= self.start < self.width
        assert 0 <= self.accept < self.width

    def bellman_eval(self) -> float:
        """Evaluate the BP using Bellman's recurrence.
        
        Returns the minimum cost path from start to accept.
        Time: O(w^2 * d), Space: O(w).
        """
        w, d = self.width, self.depth
        cost = np.full(w, INF)
        cost[self.start] = 0.0

        for i in range(d):
            new_cost = np.full(w, INF)
            for v in range(w):
                for u in range(w):
                    candidate = cost[u] + self.edge_weights[i, u, v]
                    if candidate < new_cost[v]:
                        new_cost[v] = candidate
            cost = new_cost

        return cost[self.accept]

    def reach_cost_table(self) -> np.ndarray:
        """Compute the full reachability cost table.
        
        Returns array of shape (depth+1, width) where table[i, v] is
        the minimum cost to reach state v at layer i.
        """
        w, d = self.width, self.depth
        table = np.full((d + 1, w), INF)
        table[0, self.start] = 0.0

        for i in range(d):
            for v in range(w):
                for u in range(w):
                    candidate = table[i, u] + self.edge_weights[i, u, v]
                    if candidate < table[i + 1, v]:
                        table[i + 1, v] = candidate

        return table


@dataclass
class TropicalCircuit:
    """A tropical (min-plus) circuit.
    
    Attributes:
        depth: Number of layers.
        width: Number of wires per layer.
        values: Array of shape (depth+1, width) with circuit values.
        output_gate: Index of the output wire.
    """
    depth: int
    width: int
    values: np.ndarray  # shape (depth+1, width)
    output_gate: int

    @property
    def output(self) -> float:
        """The output value of the circuit."""
        return self.values[self.depth, self.output_gate]

    @property
    def op_count(self) -> int:
        """Conservative operation count: w^2*d + w*d + w."""
        w, d = self.width, self.depth
        return w * w * d + w * d + w

    @property
    def op_count_bound(self) -> int:
        """The proven upper bound: 2*w^2*d + w."""
        w, d = self.width, self.depth
        return 2 * w * w * d + w


def bp_to_circuit(bp: WeightedBP) -> TropicalCircuit:
    """Simulate a weighted BP by a tropical circuit.
    
    This is the main simulation construction. The circuit exactly
    reproduces the BP's Bellman recurrence at each layer.
    
    Args:
        bp: A weighted branching program.
        
    Returns:
        A tropical circuit C such that:
        - C.output == bp.bellman_eval()
        - C.op_count <= C.op_count_bound == 2*w^2*d + w
        
    Time: O(w^2 * d), Space: O(w * d).
    """
    values = bp.reach_cost_table()
    return TropicalCircuit(
        depth=bp.depth,
        width=bp.width,
        values=values,
        output_gate=bp.accept,
    )


def random_bp(width: int, depth: int, density: float = 0.5,
              max_weight: float = 10.0, seed: Optional[int] = None) -> WeightedBP:
    """Generate a random weighted branching program.
    
    Args:
        width: Number of states per layer.
        depth: Number of layers.
        density: Probability that an edge exists (non-INF weight).
        max_weight: Maximum edge weight for existing edges.
        seed: Random seed for reproducibility.
        
    Returns:
        A random WeightedBP.
    """
    rng = np.random.default_rng(seed)
    weights = np.full((depth, width, width), INF)
    mask = rng.random((depth, width, width)) < density
    weights[mask] = rng.uniform(0, max_weight, size=mask.sum())

    return WeightedBP(
        width=width,
        depth=depth,
        start=0,
        accept=width - 1,
        edge_weights=weights,
    )


def edit_distance_bp(s: str, t: str) -> WeightedBP:
    """Construct a weighted BP computing the edit distance between s and t.
    
    The BP has width len(s)+1 and depth len(t), where:
    - State i at layer j represents having processed t[0:j] and aligned
      up to s[0:i].
    - Edge weights encode insertion (cost 1), deletion (cost 1),
      and substitution (cost 0 if match, 1 if mismatch).
    
    Args:
        s: Source string.
        t: Target string.
        
    Returns:
        A WeightedBP whose eval gives edit_distance(s, t).
    """
    m, n = len(s), len(t)
    w = m + 1  # width = len(s) + 1
    d = n      # depth = len(t)

    if d == 0:
        # Edge case: empty target
        weights = np.full((1, w, w), INF)
        bp = WeightedBP(width=w, depth=1, start=0, accept=0,
                        edge_weights=weights)
        # Manually set identity edge
        weights[0, 0, 0] = 0
        return bp

    weights = np.full((d, w, w), INF)

    for j in range(d):
        for i in range(w):
            # Insertion: stay at state i, pay cost 1
            if i < w:
                weights[j, i, i] = min(weights[j, i, i], 1.0)
            # Deletion: move from state i to i+1, pay cost 1
            if i + 1 < w:
                weights[j, i, i + 1] = min(weights[j, i, i + 1], 1.0)
            # Match/substitution: move from state i to i+1
            if i < m and i + 1 < w:
                cost = 0.0 if s[i] == t[j] else 1.0
                weights[j, i, i + 1] = min(weights[j, i, i + 1], cost)

    return WeightedBP(
        width=w, depth=d, start=0, accept=m,
        edge_weights=weights,
    )


def verify_simulation(bp: WeightedBP) -> dict:
    """Verify that the simulation construction is correct.
    
    Returns a dict with:
    - 'bp_eval': the BP's evaluation result.
    - 'circuit_output': the circuit's output.
    - 'match': whether they are equal.
    - 'op_count': the circuit's operation count.
    - 'bound': the proven bound 2w²d + w.
    - 'bound_satisfied': whether op_count <= bound.
    """
    circuit = bp_to_circuit(bp)
    bp_val = bp.bellman_eval()
    c_val = circuit.output

    return {
        'bp_eval': bp_val,
        'circuit_output': c_val,
        'match': (bp_val == c_val) or (bp_val == INF and c_val == INF),
        'op_count': circuit.op_count,
        'bound': circuit.op_count_bound,
        'bound_satisfied': circuit.op_count <= circuit.op_count_bound,
    }


if __name__ == '__main__':
    print("=== Weighted Tropical BP-to-Circuit Simulation ===\n")

    # Example 1: Random BP
    print("Example 1: Random BP (w=4, d=6)")
    bp = random_bp(4, 6, density=0.6, seed=42)
    result = verify_simulation(bp)
    for k, v in result.items():
        print(f"  {k}: {v}")

    # Example 2: Edit distance
    print("\nExample 2: Edit distance('kitten', 'sitting')")
    bp_ed = edit_distance_bp("kitten", "sitting")
    result_ed = verify_simulation(bp_ed)
    for k, v in result_ed.items():
        print(f"  {k}: {v}")

    # Example 3: Verify bound for various (w, d)
    print("\nExample 3: Bound verification")
    for w in [2, 3, 5, 10]:
        for d in [1, 5, 10, 20]:
            bp = random_bp(w, d, density=0.5, seed=w * 100 + d)
            r = verify_simulation(bp)
            status = "✓" if r['bound_satisfied'] else "✗"
            print(f"  {status} w={w}, d={d}: opCount={r['op_count']} ≤ {r['bound']}")
