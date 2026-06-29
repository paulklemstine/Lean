#!/usr/bin/env python3
"""
algorithms.py — Algorithms for Statistical Physics of Covering Polytopes

Implements:
1. Exact partition function computation
2. Greedy transversal finder
3. Metropolis-Hastings Gibbs sampler
4. Free energy and observable estimation
5. Bounded-codegree hypergraph generation
"""

import numpy as np
import itertools
from collections import defaultdict
from typing import List, Set, FrozenSet, Tuple, Optional


# ─── Core Data Structures ───────────────────────────────────────────────────

class Hypergraph:
    """
    A finite hypergraph H = (V, E) with V = {0, ..., n-1}.
    
    Attributes:
        n: number of vertices
        edges: list of frozensets representing hyperedges
        uniformity: if all edges have the same size, that size; else None
    """
    
    def __init__(self, n: int, edges: List[FrozenSet[int]]):
        self.n = n
        self.edges = edges
        sizes = {len(e) for e in edges}
        self.uniformity = sizes.pop() if len(sizes) == 1 else None
    
    def is_transversal(self, S: Set[int]) -> bool:
        """Check if vertex set S hits every edge."""
        return all(len(S & e) > 0 for e in self.edges)
    
    def pair_codegree(self, u: int, v: int) -> int:
        """Number of edges containing both u and v."""
        return sum(1 for e in self.edges if u in e and v in e)
    
    def max_pair_codegree(self) -> int:
        """Maximum pair-codegree Δ₂(H)."""
        max_K = 0
        for u in range(self.n):
            for v in range(u + 1, self.n):
                max_K = max(max_K, self.pair_codegree(u, v))
        return max_K
    
    def __repr__(self):
        return f"Hypergraph(n={self.n}, |E|={len(self.edges)}, d={self.uniformity})"


# ─── Hypergraph Generation ──────────────────────────────────────────────────

def generate_bounded_codegree_hypergraph(
    n: int, d: int = 3, target_edges: Optional[int] = None, 
    K: int = 2, seed: int = 42
) -> Hypergraph:
    """
    Generate a random d-uniform hypergraph on n vertices with pair-codegree ≤ K.
    
    Algorithm:
        1. Enumerate all d-subsets of {0,...,n-1} as candidate edges
        2. Randomly permute candidates  
        3. Greedily add edges that don't violate the codegree bound
    
    Complexity: O(C(n,d) · d²) time, O(n² + |E|·d) space
    
    Args:
        n: number of vertices
        d: uniformity parameter (edge size)
        target_edges: max number of edges to add (default: 2n)
        K: pair-codegree upper bound
        seed: random seed
    
    Returns:
        Hypergraph with pair-codegree ≤ K
    """
    rng = np.random.default_rng(seed)
    if target_edges is None:
        target_edges = 2 * n
    
    edges = []
    pair_count = defaultdict(int)
    
    candidates = list(itertools.combinations(range(n), d))
    rng.shuffle(candidates)
    
    for edge_tuple in candidates:
        if len(edges) >= target_edges:
            break
        edge = frozenset(edge_tuple)
        pairs = list(itertools.combinations(sorted(edge), 2))
        if all(pair_count[p] < K for p in pairs):
            edges.append(edge)
            for p in pairs:
                pair_count[p] += 1
    
    return Hypergraph(n, edges)


# ─── Transversal Algorithms ─────────────────────────────────────────────────

def find_greedy_transversal(H: Hypergraph) -> Set[int]:
    """
    Find a transversal using the greedy algorithm.
    
    Algorithm: Repeatedly pick the vertex covering the most uncovered edges.
    
    Complexity: O(|V| · |E|) time
    Approximation ratio: O(log(max edge size)) for the minimum transversal.
    """
    uncovered = list(range(len(H.edges)))
    S = set()
    edge_sets = [set(e) for e in H.edges]
    
    while uncovered:
        vertex_count = defaultdict(int)
        for i in uncovered:
            for v in edge_sets[i]:
                vertex_count[v] += 1
        best_v = max(vertex_count, key=vertex_count.get)
        S.add(best_v)
        uncovered = [i for i in uncovered if best_v not in edge_sets[i]]
    
    return S


def find_minimum_transversal_exact(H: Hypergraph) -> Tuple[Set[int], int]:
    """
    Find the minimum transversal by exact enumeration.
    
    Complexity: O(2^n · |E| · d) — only feasible for n ≤ 20.
    
    Returns:
        (best_transversal, transversal_number)
    """
    best = None
    tau = H.n + 1
    
    for mask in range(1 << H.n):
        S = {i for i in range(H.n) if mask & (1 << i)}
        if H.is_transversal(S) and len(S) < tau:
            tau = len(S)
            best = S
    
    return best, tau


# ─── Partition Function ─────────────────────────────────────────────────────

def exact_partition_function(H: Hypergraph, beta: float) -> float:
    """
    Compute Z_H(β) = Σ_{S transversal} exp(-β|S|) by exact enumeration.
    
    Complexity: O(2^n · |E| · d)
    Only feasible for n ≤ 20.
    """
    Z = 0.0
    for mask in range(1 << H.n):
        S = {i for i in range(H.n) if mask & (1 << i)}
        if H.is_transversal(S):
            Z += np.exp(-beta * len(S))
    return Z


def exact_free_energy(H: Hypergraph, beta: float) -> float:
    """
    Compute f_H(β) = -(1/|V|) log Z_H(β).
    
    Returns np.inf if Z_H(β) = 0.
    """
    Z = exact_partition_function(H, beta)
    if Z <= 0:
        return np.inf
    return -np.log(Z) / H.n


def exact_gibbs_observable(H: Hypergraph, beta: float, 
                           observable: callable) -> float:
    """
    Compute E_μ[f(S)] exactly.
    
    Args:
        observable: function S -> float
    """
    Z = 0.0
    expectation = 0.0
    for mask in range(1 << H.n):
        S = {i for i in range(H.n) if mask & (1 << i)}
        if H.is_transversal(S):
            w = np.exp(-beta * len(S))
            Z += w
            expectation += observable(S) * w
    return expectation / Z if Z > 0 else 0.0


# ─── Metropolis-Hastings Sampler ─────────────────────────────────────────────

def metropolis_sampler(
    H: Hypergraph, beta: float, 
    num_samples: int = 5000, burn_in: int = 1000, 
    seed: int = 123
) -> np.ndarray:
    """
    Metropolis-Hastings sampler for the hard-cover Gibbs measure μ_{H,β}.
    
    Algorithm:
        1. Initialize with a greedy transversal
        2. At each step, propose flipping a random vertex
        3. Accept if the new state is a transversal and passes the
           Metropolis criterion exp(-β·ΔE)
    
    Complexity per step: O(|E| · d) for transversal check
    Mixing time: empirically O(n log n) for sparse hypergraphs
    
    Args:
        H: hypergraph
        beta: inverse temperature
        num_samples: number of samples after burn-in
        burn_in: number of burn-in steps
        seed: random seed
    
    Returns:
        Array of transversal sizes (one per sample)
    """
    rng = np.random.default_rng(seed)
    
    S = find_greedy_transversal(H)
    current_size = len(S)
    state = [v in S for v in range(H.n)]
    
    samples = []
    
    for step in range(burn_in + num_samples):
        v = rng.integers(0, H.n)
        new_state = state.copy()
        new_state[v] = not new_state[v]
        
        new_S = {i for i in range(H.n) if new_state[i]}
        
        if H.is_transversal(new_S):
            new_size = len(new_S)
            delta_E = new_size - current_size
            
            if delta_E <= 0 or rng.random() < np.exp(-beta * delta_E):
                state = new_state
                current_size = new_size
        
        if step >= burn_in:
            samples.append(current_size)
    
    return np.array(samples)


# ─── Free Energy Bounds ─────────────────────────────────────────────────────

def free_energy_sandwich(H: Hypergraph, beta: float, tau: int) -> Tuple[float, float]:
    """
    Compute the free energy sandwich bounds:
        (β·τ - |V|·log2) / |V| ≤ f_H(β) ≤ β·τ / |V|
    
    Args:
        H: hypergraph
        beta: inverse temperature (must be > 0)
        tau: transversal number τ(H)
    
    Returns:
        (lower_bound, upper_bound) on f_H(β)
    """
    lower = (beta * tau - H.n * np.log(2)) / H.n
    upper = beta * tau / H.n
    return lower, upper


def gibbs_tail_bound(H: Hypergraph, beta: float, r: float, c: float, t: float) -> float:
    """
    Compute the Gibbs tail bound from coercivity:
        Σ_{S: trans, defect≥t} exp(-β|S|) ≤ 2^|V| · exp(-β(r + ct))
    
    Args:
        H: hypergraph  
        beta: inverse temperature (β ≥ 0)
        r: reference value for defect
        c: coercivity constant
        t: defect threshold
    
    Returns:
        Upper bound on the restricted sum
    """
    return 2**H.n * np.exp(-beta * (r + c * t))


# ─── Example Usage ──────────────────────────────────────────────────────────

if __name__ == "__main__":
    # Generate a small hypergraph
    H = generate_bounded_codegree_hypergraph(12, d=3, target_edges=10, K=2)
    print(f"Generated: {H}")
    print(f"Max pair-codegree: {H.max_pair_codegree()}")
    
    # Find minimum transversal
    best_S, tau = find_minimum_transversal_exact(H)
    print(f"Transversal number τ(H) = {tau}")
    print(f"Optimal transversal: {sorted(best_S)}")
    
    # Compute partition function at several β values
    for beta in [0, 0.5, 1.0, 2.0, 5.0]:
        Z = exact_partition_function(H, beta)
        f = exact_free_energy(H, beta)
        mean_size = exact_gibbs_observable(H, beta, len)
        lower, upper = free_energy_sandwich(H, beta if beta > 0 else 0.01, tau)
        print(f"  β={beta:.1f}: Z={Z:.4f}, f={f:.4f}, E[|S|]={mean_size:.2f}, "
              f"bounds=[{lower:.4f}, {upper:.4f}]")
