"""
Algorithms for Cycle-Birth Concentration in Weighted Graph Filtrations.

This module implements certified algorithms for computing cycle-birth edges,
empirical cycle-birth CDFs, and related quantities. All algorithms correspond
to formally verified definitions in the Lean 4 formalization.

Application keywords: tropical Morse theory, persistent homology, minimum
spanning tree, graphic matroid, concentration of measure.
"""

from typing import List, Tuple, Set, Dict, Optional
import numpy as np
from collections import defaultdict


class UnionFind:
    """Disjoint-set (Union-Find) data structure for tracking connected components.
    
    Used in Kruskal-style filtration to determine whether edge endpoints
    are in the same component (cycle birth) or different components (merge).
    
    Time complexity: O(α(n)) per operation (nearly constant with path
    compression and union by rank).
    """
    
    def __init__(self, n: int):
        self.parent = list(range(n))
        self.rank = [0] * n
        self.num_components = n
    
    def find(self, x: int) -> int:
        """Find root with path compression."""
        if self.parent[x] != x:
            self.parent[x] = self.find(self.parent[x])
        return self.parent[x]
    
    def union(self, x: int, y: int) -> bool:
        """Union by rank. Returns True if merge occurred (different components)."""
        rx, ry = self.find(x), self.find(y)
        if rx == ry:
            return False
        if self.rank[rx] < self.rank[ry]:
            rx, ry = ry, rx
        self.parent[ry] = rx
        if self.rank[rx] == self.rank[ry]:
            self.rank[rx] += 1
        self.num_components -= 1
        return True
    
    def connected(self, x: int, y: int) -> bool:
        """Check if x and y are in the same component."""
        return self.find(x) == self.find(y)


def compute_filtration(n: int, edges: List[Tuple[int, int, float]]) -> dict:
    """Compute the graph filtration from weighted edges.
    
    Processes edges in weight order (Kruskal-style). Each edge is classified as:
    - 'merge': endpoints in different components → MST edge
    - 'cycle_birth': endpoints in same component → creates cycle
    
    This implements the deterministic characterization (Theorem 1):
    an edge is a cycle-birth iff its endpoints are connected among lighter edges.
    
    Args:
        n: Number of vertices
        edges: List of (u, v, weight) tuples
        
    Returns:
        Dictionary with filtration data including cycle-birth and merge edges.
        
    Time complexity: O(m log m + m α(n)) where m = |edges|
    Space complexity: O(n + m)
    """
    sorted_edges = sorted(edges, key=lambda e: e[2])
    uf = UnionFind(n)
    
    cycle_birth_edges = []
    merge_edges = []
    cycle_birth_weights = []
    merge_weights = []
    steps = []
    
    for u, v, w in sorted_edges:
        if uf.connected(u, v):
            # Cycle birth: endpoints already connected
            cycle_birth_edges.append((u, v, w))
            cycle_birth_weights.append(w)
            steps.append({'weight': w, 'same_component': True, 'edge': (u, v)})
        else:
            # Merge: connecting two components (MST edge)
            uf.union(u, v)
            merge_edges.append((u, v, w))
            merge_weights.append(w)
            steps.append({'weight': w, 'same_component': False, 'edge': (u, v)})
    
    return {
        'n': n,
        'num_edges': len(sorted_edges),
        'cycle_birth_edges': cycle_birth_edges,
        'merge_edges': merge_edges,
        'cycle_birth_weights': np.array(cycle_birth_weights),
        'merge_weights': np.array(merge_weights),
        'cycle_count': len(cycle_birth_edges),
        'merge_count': len(merge_edges),
        'num_components': uf.num_components,
        'steps': steps,
    }


def compute_mst_edges(n: int, edges: List[Tuple[int, int, float]]) -> Set[Tuple[int, int]]:
    """Compute MST edges using Kruskal's algorithm.
    
    Returns the set of (u,v) pairs that form the minimum spanning forest.
    By Theorem 5, these are exactly the merge edges in the filtration.
    
    Time complexity: O(m log m + m α(n))
    """
    sorted_edges = sorted(edges, key=lambda e: e[2])
    uf = UnionFind(n)
    mst = set()
    
    for u, v, w in sorted_edges:
        if uf.union(u, v):
            mst.add((min(u, v), max(u, v)))
    
    return mst


def empirical_cycle_birth_cdf(weights: np.ndarray, t: float) -> float:
    """Compute the empirical cycle-birth CDF at threshold t.
    
    F(t) = (# cycle-birth weights ≤ t) / (total # cycle births)
    
    This is the tropical spectral measure of the filtration.
    Returns 0 if there are no cycle births.
    """
    if len(weights) == 0:
        return 0.0
    return np.mean(weights <= t)


def empirical_cycle_birth_cdf_curve(weights: np.ndarray, 
                                      t_values: np.ndarray) -> np.ndarray:
    """Compute the empirical CDF at multiple thresholds.
    
    Args:
        weights: Array of cycle-birth weights
        t_values: Array of threshold values
        
    Returns:
        Array of CDF values F(t) for each t in t_values
    """
    if len(weights) == 0:
        return np.zeros_like(t_values)
    sorted_w = np.sort(weights)
    return np.searchsorted(sorted_w, t_values, side='right') / len(sorted_w)


def ks_distance(sample1: np.ndarray, sample2: np.ndarray) -> float:
    """Compute the Kolmogorov-Smirnov distance between two samples.
    
    KS(F, G) = sup_t |F(t) - G(t)|
    
    Used to measure concentration: if cycle-birth CDFs from independent
    trials have small KS distance, the distribution is concentrating.
    
    Time complexity: O(n log n) where n = max(len(sample1), len(sample2))
    """
    if len(sample1) == 0 or len(sample2) == 0:
        return 1.0
    
    all_values = np.concatenate([sample1, sample2])
    all_values = np.sort(np.unique(all_values))
    
    cdf1 = np.searchsorted(np.sort(sample1), all_values, side='right') / len(sample1)
    cdf2 = np.searchsorted(np.sort(sample2), all_values, side='right') / len(sample2)
    
    return np.max(np.abs(cdf1 - cdf2))


def generate_erdos_renyi(n: int, p: float, 
                          weight_distribution: str = 'uniform',
                          rng: Optional[np.random.Generator] = None) -> List[Tuple[int, int, float]]:
    """Generate a weighted Erdős-Rényi random graph G(n,p).
    
    Each potential edge {i,j} is included independently with probability p.
    Included edges receive i.i.d. weights from the specified distribution.
    
    Args:
        n: Number of vertices
        p: Edge inclusion probability
        weight_distribution: 'uniform', 'exponential', or 'normal'
        rng: Random number generator (for reproducibility)
        
    Returns:
        List of (u, v, weight) tuples
        
    The choice of weight distribution does not affect cycle-birth edge
    IDENTITY (by monotone transport, Theorem 4), only the birth TIMES.
    """
    if rng is None:
        rng = np.random.default_rng()
    
    edges = []
    for i in range(n):
        for j in range(i+1, n):
            if rng.random() < p:
                if weight_distribution == 'uniform':
                    w = rng.random()
                elif weight_distribution == 'exponential':
                    w = rng.exponential(1.0)
                elif weight_distribution == 'normal':
                    w = rng.normal(0, 1)
                else:
                    raise ValueError(f"Unknown distribution: {weight_distribution}")
                edges.append((i, j, w))
    
    return edges


def verify_mst_complement(n: int, edges: List[Tuple[int, int, float]]) -> bool:
    """Verify Theorem 5: cycle-birth edges = complement of MST edges.
    
    Computes cycle-birth edges via filtration and MST edges via Kruskal,
    then checks they partition all graph edges.
    
    This is a computational validation of the formally proved theorem.
    """
    filtration = compute_filtration(n, edges)
    mst = compute_mst_edges(n, edges)
    
    all_edges = {(min(u, v), max(u, v)) for u, v, _ in edges}
    
    cycle_birth_set = {(min(u, v), max(u, v)) 
                       for u, v, _ in filtration['cycle_birth_edges']}
    merge_set = {(min(u, v), max(u, v)) 
                 for u, v, _ in filtration['merge_edges']}
    
    # Check merge edges = MST edges
    assert merge_set == mst, f"Merge edges ≠ MST edges"
    
    # Check partition
    assert cycle_birth_set | merge_set == all_edges, "Not a partition (missing edges)"
    assert cycle_birth_set & merge_set == set(), "Not a partition (overlap)"
    
    # Check complement
    assert cycle_birth_set == all_edges - mst, "Cycle births ≠ non-MST edges"
    
    return True


def monotone_transport_test(n: int, edges: List[Tuple[int, int, float]],
                             phi) -> bool:
    """Verify Theorem 4: monotone transport preserves cycle-birth classification.
    
    Applies φ to all edge weights and checks that the same edges are
    classified as cycle births (though birth times change).
    
    Args:
        phi: A strictly monotone function ℝ → ℝ
    """
    filt1 = compute_filtration(n, edges)
    
    transformed_edges = [(u, v, phi(w)) for u, v, w in edges]
    filt2 = compute_filtration(n, transformed_edges)
    
    set1 = {(min(u, v), max(u, v)) for u, v, _ in filt1['cycle_birth_edges']}
    set2 = {(min(u, v), max(u, v)) for u, v, _ in filt2['cycle_birth_edges']}
    
    return set1 == set2


def edge_resampling_sensitivity(n: int, edges: List[Tuple[int, int, float]],
                                  t: float) -> int:
    """Compute the maximum change in cycle-birth count when resampling one edge.
    
    Tests the Lipschitz bound (Theorem 2) empirically: changing one edge
    weight should change cycleBirthCountLE(t) by at most 1.
    
    Returns the maximum observed change across all single-edge resamplings.
    """
    base_filt = compute_filtration(n, edges)
    base_count = sum(1 for w in base_filt['cycle_birth_weights'] if w <= t)
    
    max_change = 0
    rng = np.random.default_rng(42)
    
    for idx in range(len(edges)):
        modified = list(edges)
        u, v, _ = modified[idx]
        modified[idx] = (u, v, rng.random())
        
        mod_filt = compute_filtration(n, modified)
        mod_count = sum(1 for w in mod_filt['cycle_birth_weights'] if w <= t)
        
        change = abs(base_count - mod_count)
        max_change = max(max_change, change)
    
    return max_change


if __name__ == "__main__":
    # Quick validation
    print("=== Algorithm Validation ===\n")
    
    # Triangle example (matching Lean: 2 merges + 1 cycle)
    edges = [(0, 1, 1.0), (1, 2, 2.0), (0, 2, 3.0)]
    filt = compute_filtration(3, edges)
    print(f"Triangle: {filt['merge_count']} merges + {filt['cycle_count']} cycles = {filt['num_edges']} edges")
    assert filt['merge_count'] == 2 and filt['cycle_count'] == 1
    
    # K4 example (matching Lean: 3 merges + 3 cycles)
    edges_k4 = [(0,1,1), (0,2,2), (0,3,3), (1,2,4), (1,3,5), (2,3,6)]
    filt_k4 = compute_filtration(4, edges_k4)
    print(f"K4: {filt_k4['merge_count']} merges + {filt_k4['cycle_count']} cycles = {filt_k4['num_edges']} edges")
    assert filt_k4['merge_count'] == 3 and filt_k4['cycle_count'] == 3
    
    # MST complement test
    assert verify_mst_complement(4, edges_k4)
    print("MST complement: VERIFIED ✓")
    
    # Monotone transport test
    assert monotone_transport_test(4, edges_k4, lambda x: x**3)
    assert monotone_transport_test(4, edges_k4, np.exp)
    print("Monotone transport: VERIFIED ✓")
    
    # Lipschitz sensitivity test
    rng = np.random.default_rng(123)
    rand_edges = generate_erdos_renyi(20, 0.3, rng=rng)
    sensitivity = edge_resampling_sensitivity(20, rand_edges, 0.5)
    print(f"Edge resampling sensitivity: {sensitivity} (should be ≤ 1)")
    assert sensitivity <= 1
    
    print("\nAll validations passed! ✓")
