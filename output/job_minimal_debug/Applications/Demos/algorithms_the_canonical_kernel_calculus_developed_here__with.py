"""
Canonical Kernel Calculus on Metric Graphs — Core Algorithms

Implements the canonical Green kernel, effective resistance computation,
and kernel approximation via adaptive subdivision for finite weighted
graph models of compact metric graphs.

Author: Harmonic Research
"""

import numpy as np
from typing import Dict, List, Tuple, Optional


class WeightedGraph:
    """A finite weighted graph modeling a compact metric graph.
    
    Each edge has a positive weight (conductance = 1/length).
    The weighted Laplacian governs potential theory on the graph.
    """
    
    def __init__(self, n: int, edges: List[Tuple[int, int, float]]):
        """
        Args:
            n: Number of vertices (labeled 0..n-1)
            edges: List of (u, v, weight) triples. Weight = conductance = 1/length.
        """
        self.n = n
        self.edges = edges
        self._build_laplacian()
    
    def _build_laplacian(self):
        """Build the weighted Laplacian matrix."""
        L = np.zeros((self.n, self.n))
        for u, v, w in self.edges:
            L[u, v] -= w
            L[v, u] -= w
            L[u, u] += w
            L[v, v] += w
        self.laplacian = L
    
    def canonical_kernel(self) -> np.ndarray:
        """Compute the canonical (mean-zero normalized) Green kernel.
        
        The kernel g satisfies:
          L @ g[:, p] = delta_p - (1/n) * ones
          sum(g[:, p]) = 0 for all p
        
        Implementation: g = L^+ (Moore-Penrose pseudoinverse) restricted
        to the orthogonal complement of the constant vector.
        
        Returns:
            n x n symmetric matrix g where g[p,q] is the kernel value.
        
        Complexity: O(n^3) via SVD or eigendecomposition.
        """
        n = self.n
        L = self.laplacian
        
        # Eigendecomposition: L = Q @ diag(evals) @ Q.T
        evals, evecs = np.linalg.eigh(L)
        
        # Pseudoinverse: invert nonzero eigenvalues, zero the null space (constants)
        tol = 1e-10 * max(abs(evals))
        g = np.zeros((n, n))
        for i in range(n):
            if abs(evals[i]) > tol:
                g += (1.0 / evals[i]) * np.outer(evecs[:, i], evecs[:, i])
        
        # Enforce exact mean-zero normalization
        mean_correction = g.mean(axis=0)
        g -= mean_correction[np.newaxis, :]
        mean_correction = g.mean(axis=1)
        g -= mean_correction[:, np.newaxis]
        
        return g
    
    def effective_resistance(self, p: int, q: int) -> float:
        """Compute effective resistance between vertices p and q.
        
        Uses the identity: r(p,q) = g(p,p) + g(q,q) - 2*g(p,q)
        where g is the canonical kernel.
        
        Args:
            p, q: Vertex indices.
            
        Returns:
            Effective resistance r(p,q) >= 0.
        """
        g = self.canonical_kernel()
        return g[p, p] + g[q, q] - 2 * g[p, q]
    
    def all_resistances(self) -> np.ndarray:
        """Compute all pairwise effective resistances.
        
        Returns:
            n x n symmetric matrix R where R[p,q] = r(p,q).
        """
        g = self.canonical_kernel()
        diag = np.diag(g)
        R = diag[:, np.newaxis] + diag[np.newaxis, :] - 2 * g
        return R
    
    def dirichlet_energy(self, f: np.ndarray) -> float:
        """Compute the Dirichlet energy E(f) = f^T L f.
        
        Args:
            f: Vertex potential vector of length n.
            
        Returns:
            E(f) >= 0, with equality iff f is constant (on connected graphs).
        """
        return float(f @ self.laplacian @ f)
    
    def dipole_potential(self, p: int, q: int) -> np.ndarray:
        """Compute the dipole potential g_p - g_q.
        
        This is the voltage pattern of unit current from p to q.
        
        Returns:
            Vector of length n.
        """
        g = self.canonical_kernel()
        return g[p, :] - g[q, :]
    
    def subdivide_edge(self, edge_idx: int, t: float = 0.5) -> 'WeightedGraph':
        """Subdivide an edge by inserting a new vertex at position t.
        
        The edge (u, v) with weight w (conductance = 1/length) is split into
        two edges (u, new) and (new, v) with weights w/t and w/(1-t).
        
        This preserves the effective resistance between u and v:
          t/w + (1-t)/w = 1/w (series combination).
        
        Args:
            edge_idx: Index into self.edges.
            t: Split position, 0 < t < 1.
            
        Returns:
            New WeightedGraph with one additional vertex.
        """
        u, v, w = self.edges[edge_idx]
        new_vertex = self.n
        
        # New edges: remove the old edge, add two new ones
        new_edges = []
        for i, (a, b, wt) in enumerate(self.edges):
            if i != edge_idx:
                new_edges.append((a, b, wt))
        
        # Series combination: length splits as t*L and (1-t)*L
        # Conductance: w_new1 = 1/(t*L) = w/t, w_new2 = 1/((1-t)*L) = w/(1-t)
        # But actually, the edge weight IS the conductance = 1/length.
        # So if original length = 1/w, new lengths are t/w and (1-t)/w.
        # New conductances: w/t and w/(1-t).
        new_edges.append((u, new_vertex, w / t))
        new_edges.append((new_vertex, v, w / (1 - t)))
        
        return WeightedGraph(self.n + 1, new_edges)


class KernelApproximator:
    """Certified approximation of the continuous kernel via adaptive subdivision.
    
    Given a metric graph model and two points (possibly on edge interiors),
    approximates g(p, q) by refining the graph through subdivision.
    
    The key theorem (proved in Lean): subdivision preserves kernel values
    on existing vertices. Therefore, for points on vertices, the kernel
    is exact. For interior points, adaptive subdivision converges.
    """
    
    def __init__(self, graph: WeightedGraph):
        self.base_graph = graph
    
    def approximate_kernel(self, p_edge: int, p_t: float,
                           q_edge: int, q_t: float,
                           depth: int = 5) -> float:
        """Approximate g(p, q) where p and q are points on edges.
        
        Args:
            p_edge: Edge index for point p.
            p_t: Position of p on edge (0 = first vertex, 1 = second vertex).
            q_edge: Edge index for point q.
            q_t: Position of q on edge.
            depth: Number of subdivision refinements.
            
        Returns:
            Approximation of g(p, q).
        """
        graph = self.base_graph
        p_vertex = None
        q_vertex = None
        
        # Handle vertex-exact cases
        if abs(p_t) < 1e-12:
            p_vertex = graph.edges[p_edge][0]
        elif abs(p_t - 1.0) < 1e-12:
            p_vertex = graph.edges[p_edge][1]
        
        if abs(q_t) < 1e-12:
            q_vertex = graph.edges[q_edge][0]
        elif abs(q_t - 1.0) < 1e-12:
            q_vertex = graph.edges[q_edge][1]
        
        # Subdivide to place p and q as vertices
        if p_vertex is None:
            graph = graph.subdivide_edge(p_edge, p_t)
            p_vertex = graph.n - 1
            # Adjust q_edge if it was the same edge
            if q_edge == p_edge:
                if q_t < p_t:
                    q_edge = len(graph.edges) - 2  # first sub-edge
                    q_t = q_t / p_t
                else:
                    q_edge = len(graph.edges) - 1  # second sub-edge
                    q_t = (q_t - p_t) / (1 - p_t)
            elif q_edge > p_edge:
                q_edge -= 1  # edge indices shifted
        
        if q_vertex is None:
            graph = graph.subdivide_edge(q_edge, q_t)
            q_vertex = graph.n - 1
        
        # Additional refinement rounds for convergence
        for _ in range(depth):
            # Subdivide all edges at midpoint
            new_edges = []
            new_n = graph.n
            for u, v, w in graph.edges:
                mid = new_n
                new_n += 1
                new_edges.append((u, mid, 2 * w))
                new_edges.append((mid, v, 2 * w))
            if new_n > 500:  # prevent explosion
                break
            graph = WeightedGraph(new_n, new_edges)
        
        g = graph.canonical_kernel()
        return g[p_vertex, q_vertex]
    
    def convergence_test(self, p: int, q: int, max_depth: int = 6) -> List[float]:
        """Test convergence of kernel approximation under subdivision.
        
        For vertex-to-vertex queries, subdivision should give exact results
        (up to numerical precision). This tests the invariance theorem.
        
        Returns:
            List of kernel values at each subdivision depth.
        """
        results = []
        graph = self.base_graph
        
        for depth in range(max_depth):
            g = graph.canonical_kernel()
            results.append(g[p, q])
            
            # Subdivide all edges at midpoint
            new_edges = []
            new_n = graph.n
            for u, v, w in graph.edges:
                mid = new_n
                new_n += 1
                new_edges.append((u, mid, 2 * w))
                new_edges.append((mid, v, 2 * w))
            if new_n > 1000:
                break
            graph = WeightedGraph(new_n, new_edges)
        
        return results


def make_path_graph(n: int, weights: Optional[List[float]] = None) -> WeightedGraph:
    """Create a path graph P_n with given edge weights."""
    if weights is None:
        weights = [1.0] * (n - 1)
    edges = [(i, i + 1, weights[i]) for i in range(n - 1)]
    return WeightedGraph(n, edges)


def make_cycle_graph(n: int, weights: Optional[List[float]] = None) -> WeightedGraph:
    """Create a cycle graph C_n with given edge weights."""
    if weights is None:
        weights = [1.0] * n
    edges = [(i, (i + 1) % n, weights[i]) for i in range(n)]
    return WeightedGraph(n, edges)


def make_complete_graph(n: int, weight: float = 1.0) -> WeightedGraph:
    """Create a complete graph K_n with uniform weights."""
    edges = [(i, j, weight) for i in range(n) for j in range(i + 1, n)]
    return WeightedGraph(n, edges)


def make_star_graph(n: int, weight: float = 1.0) -> WeightedGraph:
    """Create a star graph S_n with center vertex 0."""
    edges = [(0, i, weight) for i in range(1, n)]
    return WeightedGraph(n, edges)


def make_lollipop_graph(cycle_size: int, path_length: int,
                        weight: float = 1.0) -> WeightedGraph:
    """Create a lollipop graph: cycle + pendant path."""
    n = cycle_size + path_length
    edges = [(i, (i + 1) % cycle_size, weight) for i in range(cycle_size)]
    for i in range(path_length):
        u = cycle_size - 1 if i == 0 else cycle_size + i - 1
        v = cycle_size + i
        edges.append((u, v, weight))
    return WeightedGraph(n, edges)


def test_total_positivity_conjecture(graph: WeightedGraph,
                                     xs: List[int],
                                     ys: List[int]) -> Tuple[float, bool]:
    """Test the geodesic kernel minor non-negativity conjecture.
    
    For ordered points on a geodesic, check if the kernel submatrix
    has non-negative determinant.
    
    Returns:
        (determinant, is_nonneg)
    """
    g = graph.canonical_kernel()
    n = len(xs)
    K = np.array([[g[xs[i], ys[j]] for j in range(n)] for i in range(n)])
    det = np.linalg.det(K)
    return det, det >= -1e-10
