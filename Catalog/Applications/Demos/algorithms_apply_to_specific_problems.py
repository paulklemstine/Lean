#!/usr/bin/env python3
"""
Tropical Branching Program Complexity: Algorithms

Implements the core algorithms from the tropical complexity framework:
1. Tropical matrix arithmetic (min-plus semiring)
2. Layered branching program construction and analysis
3. Obstruction certificate computation
4. Direct-sum cost estimation
5. Width-depth tradeoff analysis
"""

import numpy as np
from typing import List, Tuple, Optional, Dict
from dataclasses import dataclass

INF = float('inf')


# ============================================================
# 1. Tropical Semiring Arithmetic
# ============================================================

class TropicalSemiring:
    """
    The min-plus (tropical) semiring over non-negative reals with infinity.
    
    Operations:
    - Addition: a ⊕ b = min(a, b)
    - Multiplication: a ⊗ b = a + b
    - Zero: ∞ (additive identity)
    - One: 0 (multiplicative identity)
    
    Time complexity: O(1) per operation
    """
    
    @staticmethod
    def add(a: float, b: float) -> float:
        """Tropical addition (min). O(1)"""
        return min(a, b)
    
    @staticmethod
    def mul(a: float, b: float) -> float:
        """Tropical multiplication (plus). O(1)"""
        if a == INF or b == INF:
            return INF
        return a + b
    
    @staticmethod
    def zero() -> float:
        """Additive identity (infinity). O(1)"""
        return INF
    
    @staticmethod
    def one() -> float:
        """Multiplicative identity (zero). O(1)"""
        return 0.0
    
    @staticmethod
    def matmul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
        """
        Tropical matrix multiplication.
        
        C[i,j] = min_k (A[i,k] + B[k,j])
        
        Time: O(n * m * p) for (n×m) @ (m×p)
        Space: O(n * p) for the result
        """
        n, m = A.shape
        m2, p = B.shape
        assert m == m2, f"Shape mismatch: {A.shape} vs {B.shape}"
        C = np.full((n, p), INF)
        for i in range(n):
            for j in range(p):
                for k in range(m):
                    val = TropicalSemiring.mul(A[i, k], B[k, j])
                    C[i, j] = TropicalSemiring.add(C[i, j], val)
        return C
    
    @staticmethod
    def matpow(A: np.ndarray, exp: int) -> np.ndarray:
        """
        Tropical matrix power via repeated squaring.
        
        Time: O(n^3 * log(exp))
        Space: O(n^2)
        """
        n = A.shape[0]
        assert A.shape == (n, n), "Matrix must be square"
        # Identity: diagonal 0, off-diagonal INF
        result = np.full((n, n), INF)
        np.fill_diagonal(result, 0)
        base = A.copy()
        while exp > 0:
            if exp % 2 == 1:
                result = TropicalSemiring.matmul(result, base)
            base = TropicalSemiring.matmul(base, base)
            exp //= 2
        return result


# ============================================================
# 2. Layered Tropical Branching Programs
# ============================================================

@dataclass
class LayerEdge:
    """An edge in the layered branching program."""
    source: int
    target: int
    cost: float


@dataclass
class BPPath:
    """A path through a branching program."""
    nodes: List[int]
    layer_costs: List[float]
    total_cost: float


class TropicalBP:
    """
    A layered tropical branching program.
    
    Structure:
    - nodes[layer] = list of node IDs at that layer
    - edges[(u, v)] = cost of edge from u to v
    - Only edges from layer i to layer i+1 are allowed
    
    Width: max number of nodes at any layer
    Depth: number of layers
    """
    
    def __init__(self, layers: int, width: int):
        """
        Initialize a branching program.
        
        Args:
            layers: Number of layers (depth)
            width: Maximum width per layer
        
        Time: O(layers)
        Space: O(layers * width)
        """
        self.layers = layers
        self.width = width
        self.nodes: Dict[int, List[int]] = {}
        self.edges: Dict[Tuple[int, int], float] = {}
        self.node_layer: Dict[int, int] = {}
        self._next_id = 0
    
    def add_node(self, layer: int) -> int:
        """
        Add a node to a specific layer.
        
        Time: O(1)
        """
        assert 0 <= layer <= self.layers
        if layer not in self.nodes:
            self.nodes[layer] = []
        assert len(self.nodes[layer]) < self.width, \
            f"Layer {layer} already has {self.width} nodes (max width)"
        node_id = self._next_id
        self._next_id += 1
        self.nodes[layer].append(node_id)
        self.node_layer[node_id] = layer
        return node_id
    
    def add_edge(self, u: int, v: int, cost: float):
        """
        Add a directed edge from u to v with given cost.
        
        Time: O(1)
        """
        assert self.node_layer[u] + 1 == self.node_layer[v], \
            f"Edge must go from layer {self.node_layer[u]} to {self.node_layer[u]+1}"
        self.edges[(u, v)] = cost
    
    def enumerate_paths(self, start: int, accept: int) -> List[BPPath]:
        """
        Enumerate all paths from start to accept.
        
        Time: O(width^layers) in the worst case
        Space: O(layers * width^layers)
        """
        if self.node_layer[start] == self.node_layer[accept]:
            if start == accept:
                return [BPPath([start], [], 0)]
            return []
        
        paths = []
        current_layer = self.node_layer[start]
        
        def dfs(node: int, path: List[int], costs: List[float]):
            if node == accept:
                paths.append(BPPath(path[:], costs[:], sum(costs)))
                return
            node_layer = self.node_layer[node]
            if node_layer >= self.layers:
                return
            next_layer = node_layer + 1
            for next_node in self.nodes.get(next_layer, []):
                if (node, next_node) in self.edges:
                    cost = self.edges[(node, next_node)]
                    path.append(next_node)
                    costs.append(cost)
                    dfs(next_node, path, costs)
                    path.pop()
                    costs.pop()
        
        dfs(start, [start], [])
        return paths
    
    def min_cost_path(self, start: int, accept: int) -> Optional[BPPath]:
        """
        Find the minimum-cost accepting path.
        
        Time: O(layers * width^2) via dynamic programming
        Space: O(layers * width)
        """
        paths = self.enumerate_paths(start, accept)
        if not paths:
            return None
        return min(paths, key=lambda p: p.total_cost)


# ============================================================
# 3. Obstruction Certificate Computation
# ============================================================

@dataclass
class ObstructionCertificate:
    """
    An obstruction certificate for a tropical BP.
    
    Provides per-layer minimum costs that any accepting path must pay.
    """
    layer_min_costs: List[float]
    total_cost: float
    
    @staticmethod
    def compute(bp: TropicalBP, start: int, accept: int) -> 'ObstructionCertificate':
        """
        Compute the obstruction certificate by finding the minimum cost
        that any accepting path must pay at each layer.
        
        Time: O(width^layers) in the worst case (enumerates all paths)
        Space: O(layers)
        
        Algorithm:
        1. Enumerate all accepting paths
        2. For each layer, find the minimum cost across all paths
        3. The certificate's total cost is the sum of per-layer minimums
        """
        paths = bp.enumerate_paths(start, accept)
        if not paths:
            return ObstructionCertificate([], 0)
        
        num_layers = bp.layers
        layer_mins = [INF] * num_layers
        
        for path in paths:
            for i, cost in enumerate(path.layer_costs):
                layer_mins[i] = min(layer_mins[i], cost)
        
        total = sum(c for c in layer_mins if c < INF)
        return ObstructionCertificate(layer_mins, total)
    
    def verify(self, paths: List[BPPath]) -> bool:
        """
        Verify the certificate: every path's total cost ≥ certificate total.
        
        Time: O(|paths| * layers)
        """
        for path in paths:
            if path.total_cost < self.total_cost:
                return False
        return True


# ============================================================
# 4. Direct-Sum Cost Estimation
# ============================================================

def direct_sum_lower_bound(single_instance_lb: float, k: int) -> float:
    """
    Compute the direct-sum lower bound for k independent copies.
    
    By the direct-sum theorem: total cost ≥ k * single_instance_lb
    
    Time: O(1)
    
    Args:
        single_instance_lb: Lower bound for a single instance
        k: Number of independent copies
    
    Returns:
        Lower bound for the k-fold direct sum
    """
    return k * single_instance_lb


def verify_direct_sum(sub_costs: List[float], per_instance_lb: float) -> Dict:
    """
    Verify the direct-sum lower bound for a list of sub-protocol costs.
    
    Time: O(k)
    
    Args:
        sub_costs: Cost of each sub-protocol
        per_instance_lb: Lower bound per instance
    
    Returns:
        Dictionary with verification results
    """
    k = len(sub_costs)
    total = sum(sub_costs)
    predicted_lb = k * per_instance_lb
    all_above = all(c >= per_instance_lb for c in sub_costs)
    
    return {
        'k': k,
        'total_cost': total,
        'predicted_lower_bound': predicted_lb,
        'bound_holds': total >= predicted_lb,
        'all_instances_above_lb': all_above,
        'sub_costs': sub_costs,
    }


# ============================================================
# 5. Width-Depth Tradeoff Analysis
# ============================================================

def width_depth_tradeoff(
    obstruction_cost: float,
    max_edge_weight: float,
    width: int
) -> Dict:
    """
    Analyze the width-depth tradeoff.
    
    Given:
    - B = obstruction cost (total lower bound)
    - W = maximum edge weight per layer
    - w = width bound
    
    Then: depth ≥ B / W
    
    Time: O(1)
    
    Returns:
        Dictionary with tradeoff analysis
    """
    if max_edge_weight <= 0:
        min_depth = INF
    else:
        min_depth = obstruction_cost / max_edge_weight
    
    return {
        'obstruction_cost': obstruction_cost,
        'max_edge_weight': max_edge_weight,
        'width': width,
        'min_depth': min_depth,
        'states_per_layer': width,
        'total_states_lower_bound': width * min_depth if min_depth < INF else INF,
    }


# ============================================================
# 6. Pigeonhole Collision Detection
# ============================================================

def find_pigeonhole_collisions(
    num_behaviors: int,
    num_states: int,
    mapping: Optional[List[int]] = None
) -> Dict:
    """
    Find collisions forced by the pigeonhole principle.
    
    When num_behaviors > num_states, at least two behaviors
    must map to the same state.
    
    Time: O(num_behaviors^2) for collision detection
    Space: O(num_behaviors)
    
    Args:
        num_behaviors: Number of distinct input behaviors
        num_states: Number of available states (width)
        mapping: Optional explicit mapping; random if None
    
    Returns:
        Dictionary with collision information
    """
    if mapping is None:
        mapping = [i % num_states for i in range(num_behaviors)]
    
    # Find all collisions
    state_to_behaviors: Dict[int, List[int]] = {}
    for i, s in enumerate(mapping):
        if s not in state_to_behaviors:
            state_to_behaviors[s] = []
        state_to_behaviors[s].append(i)
    
    collisions = []
    for state, behaviors in state_to_behaviors.items():
        if len(behaviors) > 1:
            for i in range(len(behaviors)):
                for j in range(i + 1, len(behaviors)):
                    collisions.append((behaviors[i], behaviors[j], state))
    
    min_collisions_guaranteed = max(0, num_behaviors - num_states)
    
    return {
        'num_behaviors': num_behaviors,
        'num_states': num_states,
        'pigeonhole_applies': num_behaviors > num_states,
        'min_collisions_guaranteed': min_collisions_guaranteed,
        'actual_collisions': len(collisions),
        'collision_pairs': collisions[:10],  # First 10
        'max_bucket_size': max(len(b) for b in state_to_behaviors.values()) if state_to_behaviors else 0,
    }


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    print("Tropical Branching Program Algorithms")
    print("=" * 50)
    
    # Build a sample BP
    bp = TropicalBP(layers=3, width=3)
    
    # Layer 0
    start = bp.add_node(0)
    
    # Layer 1
    a = bp.add_node(1)
    b = bp.add_node(1)
    c = bp.add_node(1)
    
    # Layer 2
    d = bp.add_node(2)
    e = bp.add_node(2)
    f = bp.add_node(2)
    
    # Layer 3
    accept = bp.add_node(3)
    
    # Add edges
    bp.add_edge(start, a, 2)
    bp.add_edge(start, b, 5)
    bp.add_edge(start, c, 1)
    bp.add_edge(a, d, 3)
    bp.add_edge(a, e, 7)
    bp.add_edge(b, d, 1)
    bp.add_edge(b, f, 4)
    bp.add_edge(c, e, 2)
    bp.add_edge(c, f, 8)
    bp.add_edge(d, accept, 4)
    bp.add_edge(e, accept, 1)
    bp.add_edge(f, accept, 3)
    
    # Find optimal path
    opt = bp.min_cost_path(start, accept)
    if opt:
        print(f"\nOptimal path cost: {opt.total_cost}")
        print(f"Path: {opt.nodes}")
        print(f"Layer costs: {opt.layer_costs}")
    
    # Compute certificate
    cert = ObstructionCertificate.compute(bp, start, accept)
    print(f"\nObstruction certificate:")
    print(f"  Per-layer minimums: {cert.layer_min_costs}")
    print(f"  Certificate total: {cert.total_cost}")
    
    # Direct-sum analysis
    print(f"\nDirect-sum lower bounds:")
    for k in [1, 5, 10]:
        lb = direct_sum_lower_bound(cert.total_cost, k)
        print(f"  k={k}: lower bound = {lb}")
    
    # Width-depth tradeoff
    tradeoff = width_depth_tradeoff(100, 5, 3)
    print(f"\nWidth-depth tradeoff (B=100, W=5, w=3):")
    print(f"  Minimum depth: {tradeoff['min_depth']}")
    
    # Pigeonhole collisions
    collisions = find_pigeonhole_collisions(10, 4)
    print(f"\nPigeonhole (10 behaviors, 4 states):")
    print(f"  Collisions found: {collisions['actual_collisions']}")
    print(f"  Guaranteed minimum: {collisions['min_collisions_guaranteed']}")
