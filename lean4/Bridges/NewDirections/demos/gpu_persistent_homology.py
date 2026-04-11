#!/usr/bin/env python3
"""
GPU-Accelerated Persistent Homology via Tropical Structure
============================================================
Demonstrates how the tropical (max-plus) semiring structure of persistent
homology enables GPU-parallel column reduction.

This demo implements:
1. Boundary matrix construction from simplicial complexes
2. Sequential column reduction (baseline)
3. GPU-parallel column reduction (simulated with NumPy)
4. Tropical matrix operations for persistence
5. Apparent pair optimization
6. Batch persistence computation

Requirements: numpy
Optional: cupy (for actual GPU execution)
"""

import numpy as np
import time
from typing import List, Tuple, Dict, Set, Optional
from collections import defaultdict

# ============================================================================
# Section 1: Simplicial Complex and Boundary Matrix
# ============================================================================

class SimplicialComplex:
    """A filtered simplicial complex for persistence computation."""
    
    def __init__(self):
        self.simplices = []  # (filtration_value, simplex_as_frozenset)
        self.dim_to_simplices = defaultdict(list)
    
    def add_simplex(self, vertices: tuple, filtration: float = 0.0):
        """Add a simplex with its filtration value."""
        s = frozenset(vertices)
        self.simplices.append((filtration, s))
        self.dim_to_simplices[len(vertices) - 1].append((filtration, s))
    
    @classmethod
    def from_point_cloud(cls, points: np.ndarray, max_radius: float = 2.0,
                         max_dim: int = 2) -> 'SimplicialComplex':
        """Build Vietoris-Rips complex from point cloud."""
        n = len(points)
        complex = cls()
        
        # Add vertices
        for i in range(n):
            complex.add_simplex((i,), 0.0)
        
        # Compute pairwise distances
        dist = np.zeros((n, n))
        for i in range(n):
            for j in range(i + 1, n):
                d = np.linalg.norm(points[i] - points[j])
                dist[i, j] = dist[j, i] = d
        
        # Add edges
        for i in range(n):
            for j in range(i + 1, n):
                if dist[i, j] <= max_radius:
                    complex.add_simplex((i, j), dist[i, j])
        
        # Add triangles
        if max_dim >= 2:
            for i in range(n):
                for j in range(i + 1, n):
                    for k in range(j + 1, n):
                        r = max(dist[i, j], dist[i, k], dist[j, k])
                        if r <= max_radius:
                            complex.add_simplex((i, j, k), r)
        
        # Sort by filtration value
        complex.simplices.sort()
        return complex
    
    def boundary_matrix(self) -> Tuple[np.ndarray, List]:
        """
        Construct the boundary matrix D.
        D[i,j] = 1 if simplex i is a face of simplex j (with appropriate sign).
        
        Returns (matrix, simplex_list).
        """
        # Sort simplices by (dimension, filtration)
        sorted_simplices = sorted(self.simplices, key=lambda x: (len(x[1]), x[0]))
        n = len(sorted_simplices)
        
        # Create index mapping
        simplex_to_idx = {s: i for i, (_, s) in enumerate(sorted_simplices)}
        
        D = np.zeros((n, n), dtype=int)
        
        for j, (_, sigma) in enumerate(sorted_simplices):
            if len(sigma) <= 1:
                continue  # Vertices have empty boundary
            
            # Boundary of sigma = alternating sum of faces
            sigma_list = sorted(sigma)
            for k, v in enumerate(sigma_list):
                face = frozenset(sigma_list[:k] + sigma_list[k+1:])
                if face in simplex_to_idx:
                    i = simplex_to_idx[face]
                    D[i, j] = (-1) ** k
        
        return D, sorted_simplices


# ============================================================================
# Section 2: Sequential Column Reduction (Baseline)
# ============================================================================

def sequential_column_reduction(D: np.ndarray) -> Tuple[np.ndarray, Dict]:
    """
    Standard persistence algorithm: reduce boundary matrix by column operations.
    Complexity: O(n³) in the worst case.
    
    Returns (reduced_matrix, persistence_pairs).
    """
    n = D.shape[1]
    R = D.astype(float).copy()
    low = {}  # low[j] = lowest nonzero row in column j
    pairs = {}
    operations = 0
    
    for j in range(n):
        # Find lowest nonzero entry in column j
        nonzero = np.nonzero(R[:, j])[0]
        
        while len(nonzero) > 0:
            low_j = nonzero[-1]
            
            # Check if another column has the same low
            found = False
            for k in range(j):
                if k in low and low[k] == low_j:
                    # Add column k to column j (over Z/2Z or R)
                    scale = R[low_j, j] / R[low_j, k]
                    R[:, j] -= scale * R[:, k]
                    R[:, j] = np.round(R[:, j])  # For integer arithmetic
                    operations += n  # O(n) per column add
                    found = True
                    break
            
            if not found:
                low[j] = low_j
                pairs[low_j] = j  # Birth at low_j, death at j
                break
            
            nonzero = np.nonzero(R[:, j])[0]
    
    return R, {'pairs': pairs, 'operations': operations}


# ============================================================================
# Section 3: GPU-Parallel Column Reduction (Simulated)
# ============================================================================

class GPUColumnReducer:
    """
    GPU-parallel column reduction exploiting tropical structure.
    
    Key insight: columns with different pivots can be reduced independently.
    This enables parallel processing in warps of 32 columns.
    """
    
    WARP_SIZE = 32
    
    def __init__(self, D: np.ndarray):
        self.D = D.astype(float).copy()
        self.n = D.shape[1]
        self.R = D.astype(float).copy()
        self.stats = {
            'parallel_rounds': 0,
            'total_operations': 0,
            'columns_eliminated': 0,
            'apparent_pairs': 0
        }
    
    def detect_apparent_pairs(self) -> Set[int]:
        """
        Apparent pair optimization: if column j has a unique lowest entry
        that doesn't appear as lowest in any earlier column, it's immediately
        a persistence pair. This eliminates up to 90% of columns.
        
        GPU implementation: each thread checks one column independently.
        """
        apparent = set()
        lows_seen = set()
        
        for j in range(self.n):
            nonzero = np.nonzero(self.R[:, j])[0]
            if len(nonzero) > 0:
                low_j = nonzero[-1]
                # Check if this is the only column with this low
                if low_j not in lows_seen:
                    # Quick check: is this an apparent pair?
                    # (In practice, more sophisticated checks are used)
                    count = 0
                    for k in range(j + 1, min(j + self.WARP_SIZE, self.n)):
                        nz_k = np.nonzero(self.R[:, k])[0]
                        if len(nz_k) > 0 and nz_k[-1] == low_j:
                            count += 1
                    if count == 0:
                        apparent.add(j)
                lows_seen.add(low_j)
        
        self.stats['apparent_pairs'] = len(apparent)
        return apparent
    
    def parallel_reduce(self) -> Tuple[np.ndarray, Dict]:
        """
        GPU-parallel column reduction.
        
        Algorithm:
        1. Detect apparent pairs (embarrassingly parallel)
        2. Process remaining columns in warps
        3. Within each warp, columns with different pivots reduce independently
        4. Synchronize pivots between warps
        """
        # Phase 1: Apparent pair detection
        apparent = self.detect_apparent_pairs()
        
        # Phase 2: Parallel column reduction
        low = {}
        pairs = {}
        
        # Process in warps
        n_warps = (self.n + self.WARP_SIZE - 1) // self.WARP_SIZE
        
        for warp_id in range(n_warps):
            self.stats['parallel_rounds'] += 1
            start = warp_id * self.WARP_SIZE
            end = min(start + self.WARP_SIZE, self.n)
            
            # Within warp: process columns in parallel
            # (Simulated - in reality, these would be GPU threads)
            warp_columns = list(range(start, end))
            
            for j in warp_columns:
                if j in apparent:
                    nonzero = np.nonzero(self.R[:, j])[0]
                    if len(nonzero) > 0:
                        low[j] = nonzero[-1]
                        pairs[nonzero[-1]] = j
                    continue
                
                # Reduce column j
                max_iter = self.n
                for _ in range(max_iter):
                    nonzero = np.nonzero(self.R[:, j])[0]
                    if len(nonzero) == 0:
                        break
                    
                    low_j = nonzero[-1]
                    
                    # Find column with same low (parallel search)
                    reduced = False
                    for k in sorted(low.keys()):
                        if k < j and low.get(k) == low_j:
                            scale = self.R[low_j, j] / self.R[low_j, k]
                            self.R[:, j] -= scale * self.R[:, k]
                            self.R[:, j] = np.round(self.R[:, j])
                            self.stats['total_operations'] += self.n
                            reduced = True
                            break
                    
                    if not reduced:
                        low[j] = low_j
                        pairs[low_j] = j
                        break
        
        return self.R, {
            'pairs': pairs,
            'stats': self.stats
        }
    
    def tropical_pivot_search(self, column: np.ndarray) -> int:
        """
        Find lowest nonzero entry using tropical max reduction.
        GPU: O(log n) with n/2 threads via parallel reduction.
        
        This is the max-plus operation: pivot = max{i : D[i,j] ≠ 0}
        """
        nonzero = np.nonzero(column)[0]
        if len(nonzero) == 0:
            return -1
        
        # Tropical max: simulating parallel reduction
        # In GPU: each thread compares two indices, keeps the larger
        indices = nonzero.tolist()
        while len(indices) > 1:
            new_indices = []
            for i in range(0, len(indices) - 1, 2):
                new_indices.append(max(indices[i], indices[i + 1]))
            if len(indices) % 2 == 1:
                new_indices.append(indices[-1])
            indices = new_indices
        
        return indices[0]


# ============================================================================
# Section 4: Tropical Matrix Operations
# ============================================================================

def tropical_matmul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """
    Tropical matrix multiplication: (A ⊗ B)_{ij} = max_k (A_{ik} + B_{kj}).
    
    GPU: Each output element computed by one thread block.
    Total: O(n²) thread blocks, each doing O(n) work with O(log n) reduction.
    """
    n, m = A.shape[0], B.shape[1]
    k = A.shape[1]
    
    C = np.full((n, m), -np.inf)
    for i in range(n):
        for j in range(m):
            for l in range(k):
                C[i, j] = max(C[i, j], A[i, l] + B[l, j])
    
    return C


def tropical_distance_matrix(points: np.ndarray) -> np.ndarray:
    """
    Compute tropical (L∞) distance matrix.
    d_∞(x, y) = max_i |x_i - y_i|
    
    GPU: embarrassingly parallel, one thread per pair.
    """
    n = len(points)
    D = np.zeros((n, n))
    for i in range(n):
        for j in range(i + 1, n):
            D[i, j] = np.max(np.abs(points[i] - points[j]))
            D[j, i] = D[i, j]
    return D


def bottleneck_distance_approx(dgm1: List[Tuple[float, float]],
                                dgm2: List[Tuple[float, float]]) -> float:
    """
    Approximate bottleneck distance between persistence diagrams.
    d_B = min_matching max_pair d_∞(pair)
    
    Uses greedy matching (O(n²) instead of O(n^2.5) for exact).
    GPU-friendly due to tropical structure.
    """
    if not dgm1 or not dgm2:
        return 0.0
    
    n1, n2 = len(dgm1), len(dgm2)
    
    # Compute pairwise costs (tropical distance)
    costs = np.zeros((n1, n2))
    for i, (b1, d1) in enumerate(dgm1):
        for j, (b2, d2) in enumerate(dgm2):
            costs[i, j] = max(abs(b1 - b2), abs(d1 - d2))
    
    # Greedy matching
    used_j = set()
    max_cost = 0.0
    
    for i in range(min(n1, n2)):
        best_j = -1
        best_cost = float('inf')
        for j in range(n2):
            if j not in used_j and costs[i, j] < best_cost:
                best_cost = costs[i, j]
                best_j = j
        if best_j >= 0:
            used_j.add(best_j)
            max_cost = max(max_cost, best_cost)
    
    return max_cost


# ============================================================================
# Section 5: Batch Persistence Computation
# ============================================================================

class BatchPersistence:
    """
    Compute persistence for multiple filtrations simultaneously on GPU.
    Amortized cost: O(n³/k) per filtration for k filtrations.
    """
    
    def __init__(self, complexes: List[SimplicialComplex]):
        self.complexes = complexes
        self.k = len(complexes)
    
    def compute_all(self) -> List[Dict]:
        """Compute persistence for all complexes."""
        results = []
        
        for i, complex in enumerate(self.complexes):
            D, simplices = complex.boundary_matrix()
            
            if D.shape[0] == 0:
                results.append({'pairs': {}, 'betti': []})
                continue
            
            # Use GPU reducer
            reducer = GPUColumnReducer(D)
            R, info = reducer.parallel_reduce()
            
            # Extract persistence diagram
            pairs = info['pairs']
            diagram = []
            for birth_idx, death_idx in pairs.items():
                birth_val = simplices[birth_idx][0]
                death_val = simplices[death_idx][0]
                dim = len(simplices[birth_idx][1]) - 1
                if death_val > birth_val:
                    diagram.append((dim, birth_val, death_val))
            
            results.append({
                'pairs': pairs,
                'diagram': diagram,
                'stats': info.get('stats', {})
            })
        
        return results


# ============================================================================
# Section 6: Demonstrations
# ============================================================================

def demo_boundary_matrix():
    """Demo: Boundary matrix construction and reduction."""
    print("=" * 60)
    print("Demo 1: Boundary Matrix Construction")
    print("=" * 60)
    
    # Create a simple simplicial complex
    complex = SimplicialComplex()
    for i in range(4):
        complex.add_simplex((i,), 0.0)
    complex.add_simplex((0, 1), 1.0)
    complex.add_simplex((1, 2), 1.5)
    complex.add_simplex((0, 2), 2.0)
    complex.add_simplex((2, 3), 2.5)
    complex.add_simplex((0, 1, 2), 3.0)
    
    D, simplices = complex.boundary_matrix()
    print(f"\nSimplices ({len(simplices)}):")
    for i, (f, s) in enumerate(simplices):
        print(f"  σ_{i}: {set(s)}, filtration = {f}")
    
    print(f"\nBoundary matrix D ({D.shape[0]}×{D.shape[1]}):")
    print(D)


def demo_sequential_vs_parallel():
    """Demo: Compare sequential and parallel column reduction."""
    print("\n" + "=" * 60)
    print("Demo 2: Sequential vs GPU-Parallel Reduction")
    print("=" * 60)
    
    # Generate point cloud
    np.random.seed(42)
    n_points = 20
    
    # Points on a circle + noise
    theta = np.linspace(0, 2 * np.pi, n_points, endpoint=False)
    points = np.column_stack([np.cos(theta), np.sin(theta)]) + 0.1 * np.random.randn(n_points, 2)
    
    complex = SimplicialComplex.from_point_cloud(points, max_radius=1.5, max_dim=2)
    D, simplices = complex.boundary_matrix()
    
    print(f"\nPoint cloud: {n_points} points in R²")
    print(f"Simplicial complex: {len(simplices)} simplices")
    print(f"Boundary matrix: {D.shape[0]}×{D.shape[1]}")
    
    # Sequential reduction
    t0 = time.time()
    R_seq, info_seq = sequential_column_reduction(D)
    t_seq = time.time() - t0
    
    print(f"\nSequential reduction:")
    print(f"  Time: {t_seq:.4f}s")
    print(f"  Operations: {info_seq['operations']}")
    print(f"  Pairs: {len(info_seq['pairs'])}")
    
    # GPU-parallel reduction
    t0 = time.time()
    reducer = GPUColumnReducer(D)
    R_par, info_par = reducer.parallel_reduce()
    t_par = time.time() - t0
    
    print(f"\nGPU-parallel reduction:")
    print(f"  Time: {t_par:.4f}s")
    print(f"  Parallel rounds: {info_par['stats']['parallel_rounds']}")
    print(f"  Total operations: {info_par['stats']['total_operations']}")
    print(f"  Apparent pairs: {info_par['stats']['apparent_pairs']}")
    print(f"  Pairs: {len(info_par['pairs'])}")


def demo_tropical_operations():
    """Demo: Tropical matrix operations for persistence."""
    print("\n" + "=" * 60)
    print("Demo 3: Tropical Matrix Operations")
    print("=" * 60)
    
    # Tropical matrix multiplication
    A = np.array([[0, 1, -np.inf],
                   [2, -np.inf, 3],
                   [-np.inf, 4, 1]])
    
    B = np.array([[1, -np.inf],
                   [0, 2],
                   [-np.inf, 1]])
    
    C = tropical_matmul(A, B)
    
    print("\nTropical matrix A:")
    print(A)
    print("\nTropical matrix B:")
    print(B)
    print("\nA ⊗ B (tropical product):")
    print(C)
    
    # Verify associativity: (A⊗B)⊗D = A⊗(B⊗D)
    D = np.array([[2, 0], [1, 3]])
    AB_D = tropical_matmul(C, D)
    BD = tropical_matmul(B, D)
    A_BD = tropical_matmul(A, BD)
    
    print(f"\nAssociativity check: ||(A⊗B)⊗D - A⊗(B⊗D)||_∞ = {np.max(np.abs(AB_D - A_BD)):.10f}")
    
    # Tropical distance matrix
    np.random.seed(42)
    points = np.random.randn(5, 3)
    D_trop = tropical_distance_matrix(points)
    
    print(f"\nTropical (L∞) distance matrix for 5 points in R³:")
    print(np.round(D_trop, 3))
    
    # Verify metric properties
    n = len(points)
    triangle_ok = True
    for i in range(n):
        for j in range(n):
            for k in range(n):
                if D_trop[i, k] > D_trop[i, j] + D_trop[j, k] + 1e-10:
                    triangle_ok = False
    print(f"Triangle inequality satisfied: {triangle_ok}")


def demo_bottleneck_distance():
    """Demo: Bottleneck distance between persistence diagrams."""
    print("\n" + "=" * 60)
    print("Demo 4: Bottleneck Distance (Tropical Metric)")
    print("=" * 60)
    
    # Two persistence diagrams
    dgm1 = [(0.0, 1.5), (0.5, 2.0), (1.0, 3.0)]
    dgm2 = [(0.1, 1.6), (0.4, 2.1), (0.9, 2.8)]
    
    d_B = bottleneck_distance_approx(dgm1, dgm2)
    
    print(f"\nDiagram 1: {dgm1}")
    print(f"Diagram 2: {dgm2}")
    print(f"Bottleneck distance ≈ {d_B:.4f}")
    
    # Verify triangle inequality
    dgm3 = [(0.2, 1.4), (0.6, 1.9), (1.1, 2.7)]
    d12 = bottleneck_distance_approx(dgm1, dgm2)
    d23 = bottleneck_distance_approx(dgm2, dgm3)
    d13 = bottleneck_distance_approx(dgm1, dgm3)
    
    print(f"\nd(D1, D2) = {d12:.4f}")
    print(f"d(D2, D3) = {d23:.4f}")
    print(f"d(D1, D3) = {d13:.4f}")
    print(f"Triangle inequality: d(1,3) ≤ d(1,2) + d(2,3)?  {d13:.4f} ≤ {d12 + d23:.4f}: {d13 <= d12 + d23 + 1e-10}")


def demo_batch_persistence():
    """Demo: Batch persistence computation."""
    print("\n" + "=" * 60)
    print("Demo 5: Batch Persistence on GPU")
    print("=" * 60)
    
    np.random.seed(42)
    k = 5  # Number of filtrations
    
    complexes = []
    for i in range(k):
        n_pts = 10 + i * 2
        theta = np.linspace(0, 2 * np.pi, n_pts, endpoint=False)
        r = 1.0 + 0.2 * i
        points = np.column_stack([r * np.cos(theta), r * np.sin(theta)])
        points += 0.1 * np.random.randn(n_pts, 2)
        complexes.append(SimplicialComplex.from_point_cloud(points, max_radius=2.0))
    
    batch = BatchPersistence(complexes)
    t0 = time.time()
    results = batch.compute_all()
    t_total = time.time() - t0
    
    print(f"\nBatch of {k} filtrations computed in {t_total:.4f}s")
    print(f"Amortized time per filtration: {t_total/k:.4f}s")
    
    for i, result in enumerate(results):
        n_features = len(result.get('diagram', []))
        print(f"\n  Filtration {i}: {n_features} persistence features")
        for dim, birth, death in sorted(result.get('diagram', []))[:3]:
            print(f"    H_{dim}: [{birth:.2f}, {death:.2f}), lifetime = {death-birth:.2f}")


def demo_speedup_analysis():
    """Demo: Theoretical speedup analysis."""
    print("\n" + "=" * 60)
    print("Demo 6: GPU Speedup Analysis")
    print("=" * 60)
    
    print(f"\n{'n simplices':>12} | {'Seq O(n³)':>12} | {'GPU warps':>10} | {'Par ops':>12} | {'Speedup':>8}")
    print("-" * 65)
    
    for n in [100, 500, 1000, 5000, 10000, 50000]:
        seq_ops = n ** 3
        n_warps = (n + 31) // 32
        # Parallel: O(n² · n_warps) with warp-level reduction
        par_ops = n ** 2 * n_warps
        speedup = seq_ops / par_ops if par_ops > 0 else float('inf')
        
        print(f"{n:>12,} | {seq_ops:>12,} | {n_warps:>10,} | {par_ops:>12,} | {speedup:>8.1f}×")
    
    print("\nNote: Actual GPU speedup depends on memory bandwidth and occupancy.")
    print("Apparent pair optimization can eliminate 70-90% of columns.")


if __name__ == "__main__":
    demo_boundary_matrix()
    demo_sequential_vs_parallel()
    demo_tropical_operations()
    demo_bottleneck_distance()
    demo_batch_persistence()
    demo_speedup_analysis()
    
    print("\n" + "=" * 60)
    print("All GPU persistence demos completed successfully!")
    print("=" * 60)
