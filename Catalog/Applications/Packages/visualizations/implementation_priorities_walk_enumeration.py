#!/usr/bin/env python3
"""
Algorithms for Proof Architecture Complexity Analysis.

Implements efficient algorithms for computing complexity invariants
of finite directed graphs (proof architectures).
"""

from typing import Dict, List, Optional, Set, Tuple
import numpy as np
from collections import defaultdict


class ProofArchitecture:
    """A finite directed graph modeling a proof search space.
    
    Vertices represent proof states/goals, edges represent admissible
    proof transformations.
    
    Attributes:
        vertices: Set of vertex labels
        edges: Set of directed edges (u, v)
        adj: Adjacency list representation
    """
    
    def __init__(self, vertices: List[int], edges: List[Tuple[int, int]]):
        """Initialize a proof architecture.
        
        Args:
            vertices: List of vertex labels
            edges: List of directed edges (source, target)
        """
        self.vertices = sorted(set(vertices))
        self.edges = set(edges)
        self.n = len(self.vertices)
        self.adj: Dict[int, List[int]] = defaultdict(list)
        for u, v in self.edges:
            self.adj[u].append(v)
        self._vertex_index = {v: i for i, v in enumerate(self.vertices)}
    
    def branching_degree(self, v: int) -> int:
        """Compute the branching degree (out-degree) of vertex v.
        
        Time complexity: O(1) with adjacency list.
        
        Args:
            v: Vertex label
            
        Returns:
            Number of successors of v
        """
        return len(self.adj[v])
    
    def max_branching_degree(self) -> int:
        """Compute the maximum branching degree across all vertices.
        
        Time complexity: O(|V|).
        
        Returns:
            Maximum out-degree in the graph
        """
        return max(self.branching_degree(v) for v in self.vertices)
    
    def has_branching_obstruction(self) -> Optional[Tuple[int, int, int]]:
        """Detect a branching obstruction.
        
        Time complexity: O(|V| + |E|).
        
        Returns:
            (v, w1, w2) if obstruction exists, None otherwise
        """
        for v in self.vertices:
            succs = self.adj[v]
            if len(succs) >= 2:
                return (v, succs[0], succs[1])
        return None
    
    def adjacency_matrix(self) -> np.ndarray:
        """Compute the adjacency matrix.
        
        Time complexity: O(|V|² + |E|).
        
        Returns:
            |V| x |V| numpy array
        """
        A = np.zeros((self.n, self.n), dtype=float)
        for u, v in self.edges:
            A[self._vertex_index[u]][self._vertex_index[v]] = 1.0
        return A
    
    def walk_count(self, length: int) -> int:
        """Count all walks of given length using matrix exponentiation.
        
        The number of walks of length k equals sum of all entries of A^k,
        where A is the adjacency matrix.
        
        Time complexity: O(|V|³ · log(length)).
        
        Args:
            length: Walk length (number of edges)
            
        Returns:
            Total number of walks
        """
        A = self.adjacency_matrix()
        if length == 0:
            return self.n
        Ak = np.linalg.matrix_power(A, length)
        # Total walks = sum of all entries of A^k, then multiply by
        # the number of starting vertices... actually the total walk count
        # for walks of length k (k edges, k+1 vertices) is 1^T A^k 1
        ones = np.ones(self.n)
        return int(round(ones @ Ak @ ones))
    
    def walk_count_from(self, v: int, length: int) -> int:
        """Count walks of given length starting from vertex v.
        
        Time complexity: O(|V|³ · log(length)).
        
        Args:
            v: Starting vertex
            length: Walk length
            
        Returns:
            Number of walks starting at v
        """
        A = self.adjacency_matrix()
        if length == 0:
            return 1
        Ak = np.linalg.matrix_power(A, length)
        vi = self._vertex_index[v]
        return int(round(sum(Ak[vi])))
    
    def walk_count_between(self, u: int, v: int, length: int) -> int:
        """Count walks of given length from u to v.
        
        Time complexity: O(|V|³ · log(length)).
        
        Args:
            u: Starting vertex
            v: Ending vertex
            length: Walk length
            
        Returns:
            Number of walks from u to v
        """
        A = self.adjacency_matrix()
        if length == 0:
            return 1 if u == v else 0
        Ak = np.linalg.matrix_power(A, length)
        return int(round(Ak[self._vertex_index[u]][self._vertex_index[v]]))
    
    def spectral_radius(self) -> float:
        """Compute the spectral radius of the adjacency matrix.
        
        This controls the asymptotic growth rate of walk counts:
        walk_count(k) ~ ρ^k · |V| for large k.
        
        Time complexity: O(|V|³).
        
        Returns:
            Largest absolute eigenvalue
        """
        A = self.adjacency_matrix()
        eigenvalues = np.linalg.eigvals(A)
        return float(max(abs(eigenvalues)))
    
    def topological_entropy(self, max_length: int = 20) -> float:
        """Estimate the topological entropy via truncated walk counts.
        
        Entropy h = lim_{k→∞} (1/k) · log(walk_count(k)).
        For finite graphs, this equals log(spectral_radius).
        
        Args:
            max_length: Maximum walk length for estimation
            
        Returns:
            Estimated topological entropy
        """
        rho = self.spectral_radius()
        if rho > 0:
            return float(np.log(rho))
        return 0.0
    
    def upper_bound(self, length: int) -> int:
        """Compute the universal upper bound |V|^(length+1).
        
        Args:
            length: Walk length
            
        Returns:
            Upper bound on walk count
        """
        return self.n ** (length + 1)
    
    @staticmethod
    def product(g1: 'ProofArchitecture', g2: 'ProofArchitecture') -> 'ProofArchitecture':
        """Construct the product architecture.
        
        Time complexity: O(|V₁|²·|V₂|²).
        
        Args:
            g1: First architecture
            g2: Second architecture
            
        Returns:
            Product architecture
        """
        # Encode product vertices as integers
        prod_vertices = []
        vertex_map = {}
        idx = 0
        for a in g1.vertices:
            for b in g2.vertices:
                vertex_map[(a, b)] = idx
                prod_vertices.append(idx)
                idx += 1
        
        prod_edges = []
        for (a1, a2) in g1.edges:
            for (b1, b2) in g2.edges:
                prod_edges.append((vertex_map[(a1, b1)], vertex_map[(a2, b2)]))
        
        return ProofArchitecture(prod_vertices, prod_edges)
    
    def complexity_profile(self, max_length: int = 10) -> Dict[str, object]:
        """Compute a comprehensive complexity profile.
        
        Args:
            max_length: Maximum walk length
            
        Returns:
            Dictionary with complexity invariants
        """
        obs = self.has_branching_obstruction()
        walk_counts = [self.walk_count(k) for k in range(max_length + 1)]
        
        return {
            'vertices': self.n,
            'edges': len(self.edges),
            'max_branching_degree': self.max_branching_degree(),
            'has_obstruction': obs is not None,
            'obstruction_witness': obs,
            'spectral_radius': self.spectral_radius(),
            'topological_entropy': self.topological_entropy(),
            'walk_counts': walk_counts,
            'upper_bounds': [self.upper_bound(k) for k in range(max_length + 1)],
            'branching_degrees': {v: self.branching_degree(v) for v in self.vertices},
        }


# ─────────────────────────────────────────────────────────────────────────
# Example usage
# ─────────────────────────────────────────────────────────────────────────

if __name__ == '__main__':
    print("=" * 60)
    print("Proof Architecture Complexity Analysis")
    print("=" * 60)
    print()
    
    # Example 1: Binary tree proof architecture
    print("Example 1: Binary tree (depth 3)")
    tree_edges = []
    for i in range(7):
        if 2 * i + 1 < 15:
            tree_edges.append((i, 2 * i + 1))
        if 2 * i + 2 < 15:
            tree_edges.append((i, 2 * i + 2))
    tree = ProofArchitecture(list(range(15)), tree_edges)
    profile = tree.complexity_profile(max_length=4)
    
    print(f"  Vertices: {profile['vertices']}")
    print(f"  Edges: {profile['edges']}")
    print(f"  Max branching degree: {profile['max_branching_degree']}")
    print(f"  Spectral radius: {profile['spectral_radius']:.4f}")
    print(f"  Topological entropy: {profile['topological_entropy']:.4f}")
    print(f"  Walk counts: {profile['walk_counts']}")
    print(f"  Upper bounds: {profile['upper_bounds']}")
    print()
    
    # Example 2: Cycle
    print("Example 2: Directed cycle C₅")
    cycle = ProofArchitecture(list(range(5)),
                               [(i, (i + 1) % 5) for i in range(5)])
    profile = cycle.complexity_profile(max_length=6)
    
    print(f"  Vertices: {profile['vertices']}")
    print(f"  Max branching degree: {profile['max_branching_degree']}")
    print(f"  Has obstruction: {profile['has_obstruction']}")
    print(f"  Spectral radius: {profile['spectral_radius']:.4f}")
    print(f"  Walk counts: {profile['walk_counts']}")
    print()
    
    # Example 3: Product architecture
    print("Example 3: Product of two paths P₃ × P₃")
    p3 = ProofArchitecture([0, 1, 2], [(0, 1), (1, 2)])
    prod = ProofArchitecture.product(p3, p3)
    
    for k in range(4):
        wc_prod = prod.walk_count(k)
        wc_p3 = p3.walk_count(k)
        print(f"  Length {k}: product = {wc_prod}, "
              f"component² = {wc_p3 ** 2}, "
              f"bound holds: {wc_prod <= wc_p3 ** 2}")
