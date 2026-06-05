"""
Anti-Gravity Theorems: Algorithms for Analyzing Theorem Dependency Graphs

This module implements the core algorithms for computing anti-gravity scores,
weight-complexity duality verification, and Kraft sparsity bounds.
"""

from __future__ import annotations
from typing import Dict, List, Set, Tuple
from collections import defaultdict
import math


class DepGraph:
    """A directed graph modeling theorem dependencies.
    
    dep(u, v) means theorem u directly depends on theorem v.
    """
    
    def __init__(self, vertices: List[str], edges: List[Tuple[str, str]]):
        """Initialize with vertex list and edge list [(u, v)] meaning u depends on v."""
        self.vertices: List[str] = vertices
        self.edges: List[Tuple[str, str]] = edges
        self._dependents: Dict[str, Set[str]] = defaultdict(set)  # v -> {u : dep(u,v)}
        self._dependencies: Dict[str, Set[str]] = defaultdict(set)  # u -> {v : dep(u,v)}
        
        for u, v in edges:
            assert u != v, f"Self-loop detected: {u}"
            self._dependents[v].add(u)
            self._dependencies[u].add(v)
    
    def weight(self, v: str) -> int:
        """Number of vertices that directly depend on v."""
        return len(self._dependents.get(v, set()))
    
    def complexity(self, v: str) -> int:
        """Number of vertices that v directly depends on."""
        return len(self._dependencies.get(v, set()))
    
    def is_source(self, v: str) -> bool:
        """Whether v is a source (axiom) with no dependencies."""
        return self.complexity(v) == 0
    
    def sources(self) -> List[str]:
        """All source vertices."""
        return [v for v in self.vertices if self.is_source(v)]
    
    def total_edges(self) -> int:
        """Total number of dependency edges."""
        return len(self.edges)
    
    def anti_gravity_score(self, v: str) -> float:
        """Anti-gravity score: weight / (complexity + 1)."""
        return self.weight(v) / (self.complexity(v) + 1)
    
    def is_anti_gravity(self, v: str, w_threshold: int, c_threshold: int) -> bool:
        """Whether v is anti-gravity at given thresholds."""
        return self.weight(v) >= w_threshold and self.complexity(v) <= c_threshold
    
    def anti_gravity_set(self, w_threshold: int, c_threshold: int) -> List[str]:
        """All anti-gravity vertices at given thresholds."""
        return [v for v in self.vertices 
                if self.is_anti_gravity(v, w_threshold, c_threshold)]
    
    def transitive_weight(self, v: str) -> int:
        """Number of vertices transitively reachable from v (BFS)."""
        visited: Set[str] = set()
        queue = [v]
        while queue:
            u = queue.pop(0)
            if u in visited:
                continue
            visited.add(u)
            for w in self._dependents.get(u, set()):
                if w not in visited:
                    queue.append(w)
        return len(visited) - 1  # exclude v itself
    
    def depth(self, v: str) -> int:
        """Shortest path from any source to v (BFS from all sources)."""
        if self.is_source(v):
            return 0
        sources = self.sources()
        if not sources:
            return float('inf')  # type: ignore
        
        visited: Dict[str, int] = {}
        queue: List[Tuple[str, int]] = [(s, 0) for s in sources]
        
        for s, _ in queue:
            visited[s] = 0
        
        while queue:
            u, d = queue.pop(0)
            for w in self._dependents.get(u, set()):
                if w not in visited:
                    visited[w] = d + 1
                    queue.append((w, d + 1))
        
        return visited.get(v, float('inf'))  # type: ignore


def verify_weight_complexity_duality(G: DepGraph) -> Tuple[int, int, bool]:
    """Verify that sum of weights equals sum of complexities.
    
    Returns (total_weight, total_complexity, are_equal).
    """
    total_weight = sum(G.weight(v) for v in G.vertices)
    total_complexity = sum(G.complexity(v) for v in G.vertices)
    return total_weight, total_complexity, total_weight == total_complexity


def find_above_average_weight(G: DepGraph) -> Tuple[str, int, float]:
    """Find a vertex with above-average weight.
    
    Returns (vertex, weight, average_weight).
    """
    n = len(G.vertices)
    if n == 0:
        raise ValueError("Empty graph")
    
    avg = G.total_edges() / n
    best_v = max(G.vertices, key=lambda v: G.weight(v))
    return best_v, G.weight(best_v), avg


def markov_bound(G: DepGraph, w: int) -> Tuple[int, int]:
    """Compute the Markov bound on high-weight vertices.
    
    Returns (actual_count, upper_bound).
    """
    actual = sum(1 for v in G.vertices if G.weight(v) >= w)
    bound = G.total_edges() // w if w > 0 else len(G.vertices)
    return actual, bound


def kraft_sparsity_bound(k: int) -> int:
    """Maximum number of prefix-free codewords with length <= k.
    
    Returns 2^(k+1) - 1.
    """
    return 2 ** (k + 1) - 1


def compute_anti_gravity_profile(G: DepGraph) -> List[Dict]:
    """Compute full anti-gravity profile for all vertices.
    
    Returns list of dicts with vertex info, sorted by anti-gravity score.
    """
    profile = []
    for v in G.vertices:
        w = G.weight(v)
        c = G.complexity(v)
        score = w / (c + 1)
        profile.append({
            'vertex': v,
            'weight': w,
            'complexity': c,
            'anti_gravity_score': score,
            'is_source': G.is_source(v),
            'transitive_weight': G.transitive_weight(v),
        })
    
    profile.sort(key=lambda x: x['anti_gravity_score'], reverse=True)
    return profile


def weight_distribution(G: DepGraph) -> Dict[int, int]:
    """Compute the weight distribution: weight -> count of vertices with that weight."""
    dist: Dict[int, int] = defaultdict(int)
    for v in G.vertices:
        dist[G.weight(v)] += 1
    return dict(sorted(dist.items()))


# Example mathematical library DAG
def example_math_library() -> DepGraph:
    """A small example modeling a mathematical library.
    
    Axioms -> Basic lemmas -> Intermediate results -> Advanced theorems
    """
    vertices = [
        # Axioms (sources)
        'axiom_nat_ind', 'axiom_add_comm', 'axiom_mul_assoc',
        # Basic lemmas
        'add_zero', 'mul_one', 'succ_pos',
        # Intermediate
        'nat_add_comm', 'mul_comm', 'pow_succ',
        # Advanced
        'binomial_theorem', 'fermat_little', 'euclid_inf_primes',
        # Very advanced
        'prime_number_theorem', 'quadratic_reciprocity',
    ]
    
    edges = [
        # Basic lemmas depend on axioms
        ('add_zero', 'axiom_nat_ind'),
        ('mul_one', 'axiom_nat_ind'),
        ('mul_one', 'axiom_mul_assoc'),
        ('succ_pos', 'axiom_nat_ind'),
        # Intermediate depends on basics
        ('nat_add_comm', 'axiom_add_comm'),
        ('nat_add_comm', 'add_zero'),
        ('mul_comm', 'mul_one'),
        ('mul_comm', 'nat_add_comm'),
        ('pow_succ', 'mul_one'),
        ('pow_succ', 'axiom_nat_ind'),
        # Advanced depends on intermediate
        ('binomial_theorem', 'nat_add_comm'),
        ('binomial_theorem', 'mul_comm'),
        ('binomial_theorem', 'pow_succ'),
        ('fermat_little', 'mul_comm'),
        ('fermat_little', 'pow_succ'),
        ('euclid_inf_primes', 'succ_pos'),
        ('euclid_inf_primes', 'mul_comm'),
        # Very advanced
        ('prime_number_theorem', 'euclid_inf_primes'),
        ('prime_number_theorem', 'binomial_theorem'),
        ('quadratic_reciprocity', 'fermat_little'),
        ('quadratic_reciprocity', 'mul_comm'),
    ]
    
    return DepGraph(vertices, edges)
