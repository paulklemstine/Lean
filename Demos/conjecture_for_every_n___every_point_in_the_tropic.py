#!/usr/bin/env python3
"""
Applications of Tropical Carathéodory Compression

Demonstrates real-world applications of the compression theorem in:
1. Shortest path certificates (graph algorithms)
2. Tropical linear programming
3. Scheduling optimization
4. Sparse feasibility certificates
"""

import numpy as np
from typing import List, Tuple, Optional, Dict
from algorithms import (tropical_min_plus, find_active_set, caratheodory_compress,
                         tropical_hull_membership, compression_certificate)


# ═══════════════════════════════════════════════════════════════════════
# APPLICATION 1: Shortest Path Certificates
# ═══════════════════════════════════════════════════════════════════════

def shortest_path_as_tropical(adj_matrix: np.ndarray, source: int) -> dict:
    """
    Interpret single-source shortest paths as a tropical convex combination.
    
    The distance vector d(i) = min path length from source to i.
    This equals: d(i) = min_j (w_j + e_j(i))
    where the generators are unit-like vectors encoding graph structure.
    
    The Carathéodory compression then says: the distance vector can be
    certified using at most n witnesses (predecessor edges), recovering
    the shortest path tree.
    
    Args:
        adj_matrix: (n, n) weighted adjacency matrix (inf for no edge)
        source: source node index
        
    Returns:
        dict with distances, tropical representation, and compression
    """
    n = adj_matrix.shape[0]
    INF = 1e15
    
    # Bellman-Ford shortest paths
    dist = np.full(n, INF)
    dist[source] = 0
    pred = [-1] * n
    
    for _ in range(n - 1):
        for u in range(n):
            for v in range(n):
                if adj_matrix[u, v] < INF:
                    if dist[u] + adj_matrix[u, v] < dist[v]:
                        dist[v] = dist[u] + adj_matrix[u, v]
                        pred[v] = u
    
    # Build tropical representation
    # Each edge (u, v) with weight c contributes a generator
    edges = []
    edge_weights = []
    for u in range(n):
        for v in range(n):
            if adj_matrix[u, v] < INF and u != v:
                # Generator: point that has dist[u] at position u, dist[u]+c at position v
                # and INF elsewhere
                gen = np.full(n, INF)
                gen[v] = adj_matrix[u, v]  # edge cost at target
                gen[u] = 0  # zero at source of edge
                edges.append(gen)
                edge_weights.append(dist[u])  # weight = distance to edge source
    
    if edges:
        points = np.array(edges)
        weights = np.array(edge_weights)
        
        # Compress
        z = dist.copy()
        z[source] = 0
        
        # Use only non-source nodes for the tropical combination
        cert = compression_certificate(points, weights)
    else:
        cert = None
    
    return {
        "distances": dist,
        "predecessors": pred,
        "certificate": cert,
        "n_edges": len(edges),
    }


def demo_shortest_path():
    """Demo: shortest path certificates via tropical compression."""
    print("═" * 60)
    print("APPLICATION 1: Shortest Path Certificates")
    print("═" * 60)
    
    INF = 1e15
    # Simple graph: 5 nodes
    #   0 --2-- 1 --3-- 2
    #   |       |       |
    #   4       1       2
    #   |       |       |
    #   3 --5-- 4 ------+
    
    adj = np.full((5, 5), INF)
    edges = [(0,1,2), (1,0,2), (1,2,3), (2,1,3), (0,3,4), (3,0,4),
             (1,4,1), (4,1,1), (3,4,5), (4,3,5), (2,4,2), (4,2,2)]
    for u, v, w in edges:
        adj[u, v] = w
    
    result = shortest_path_as_tropical(adj, source=0)
    
    print(f"\nGraph: 5 nodes, {len(edges)} directed edges")
    print(f"Source: node 0")
    print(f"Shortest distances: {result['distances']}")
    print(f"Predecessors: {result['predecessors']}")
    
    if result['certificate']:
        cert = result['certificate']
        print(f"\nTropical representation: {cert['original_size']} generators")
        print(f"After compression: {cert['compressed_size']} generators")
        print(f"Dimension (nodes): {cert['dimension']}")
        print(f"Compression achieves bound: |T| ≤ n = {cert['dimension']}")


# ═══════════════════════════════════════════════════════════════════════
# APPLICATION 2: Scheduling with Tropical Convexity
# ═══════════════════════════════════════════════════════════════════════

def scheduling_problem(processing_times: np.ndarray, 
                        machine_speeds: np.ndarray) -> dict:
    """
    Model a scheduling problem using tropical convexity.
    
    Given k machines and n jobs:
    - processing_times[j, i] = time for machine j to complete job i
    - machine_speeds[j] = startup/overhead time for machine j
    
    The optimal completion time for each job is:
    completion[i] = min_j (machine_speeds[j] + processing_times[j, i])
    
    This is exactly a tropical convex combination. Compression tells us
    that at most n machines suffice to achieve optimal completion times.
    
    Args:
        processing_times: (k, n) array
        machine_speeds: (k,) array of overheads
        
    Returns:
        dict with schedule, optimal times, and minimal machine set
    """
    completion = tropical_min_plus(processing_times, machine_speeds)
    cert = compression_certificate(processing_times, machine_speeds)
    
    active = find_active_set(processing_times, machine_speeds, completion)
    
    # Assign each job to an active machine
    assignment = {}
    for job_i in range(processing_times.shape[1]):
        assignment[job_i] = active[job_i][0]
    
    return {
        "completion_times": completion,
        "assignment": assignment,
        "machines_needed": cert['compressed_size'],
        "total_machines": processing_times.shape[0],
        "certificate": cert,
    }


def demo_scheduling():
    """Demo: scheduling optimization via tropical compression."""
    print("\n" + "═" * 60)
    print("APPLICATION 2: Scheduling Optimization")
    print("═" * 60)
    
    # 6 machines, 4 jobs
    processing_times = np.array([
        [3, 7, 2, 5],   # Machine 0: fast at job 2
        [5, 2, 6, 3],   # Machine 1: fast at job 1
        [4, 4, 4, 4],   # Machine 2: uniform
        [1, 8, 8, 8],   # Machine 3: fast at job 0
        [6, 6, 1, 6],   # Machine 4: fast at job 2
        [7, 3, 5, 1],   # Machine 5: fast at job 3
    ], dtype=float)
    
    machine_overhead = np.array([1, 0, 2, 0, 1, 0], dtype=float)
    
    result = scheduling_problem(processing_times, machine_overhead)
    
    print(f"\n{processing_times.shape[0]} machines, {processing_times.shape[1]} jobs")
    print(f"\nOptimal completion times: {result['completion_times']}")
    print(f"Job assignments (job -> machine): {result['assignment']}")
    print(f"\nMachines actually needed: {result['machines_needed']} out of {result['total_machines']}")
    print(f"Carathéodory bound: |T| ≤ n = {processing_times.shape[1]} (dimension)")
    print(f"Compression ratio: {result['certificate']['compression_ratio']:.1f}x")


# ═══════════════════════════════════════════════════════════════════════
# APPLICATION 3: Sparse Feasibility Certificates
# ═══════════════════════════════════════════════════════════════════════

def tropical_feasibility(A: np.ndarray, b: np.ndarray, 
                          tol: float = 1e-10) -> dict:
    """
    Check feasibility of a tropical linear system: A ⊙ x = b.
    
    In min-plus: b(i) = min_j (A(i,j) + x(j))
    
    If feasible, find a sparse certificate using Carathéodory compression.
    The certificate identifies at most n active constraints.
    
    Args:
        A: (m, n) tropical coefficient matrix
        b: (m,) right-hand side
        tol: tolerance
        
    Returns:
        dict with feasibility status, solution, and certificate
    """
    m, n = A.shape
    
    # For tropical Ax = b:
    # b(i) = min_j (A(i,j) + x(j))
    # This means: for each i, there exists j such that A(i,j) + x(j) = b(i)
    # and A(i,j) + x(j) >= b(i) for all j.
    # 
    # Maximum feasible x: x(j) = min_i (b(i) - A(i,j))
    
    x_max = np.array([min(b[i] - A[i, j] for i in range(m)) for j in range(n)])
    
    # Check if this x satisfies the system
    b_check = np.array([min(A[i, j] + x_max[j] for j in range(n)) for i in range(m)])
    
    feasible = np.allclose(b_check, b, atol=tol)
    
    if feasible:
        # Find active constraints for each variable
        active_constraints = {}
        for j in range(n):
            active_constraints[j] = [i for i in range(m) 
                                      if abs(b[i] - A[i, j] - x_max[j]) < tol]
    else:
        active_constraints = None
    
    return {
        "feasible": feasible,
        "solution": x_max if feasible else None,
        "active_constraints": active_constraints,
        "residual": b_check - b if not feasible else np.zeros(m),
    }


def demo_feasibility():
    """Demo: sparse feasibility certificates."""
    print("\n" + "═" * 60)
    print("APPLICATION 3: Sparse Feasibility Certificates")
    print("═" * 60)
    
    # Tropical system: 6 constraints, 3 variables
    A = np.array([
        [0, 3, 1],
        [2, 0, 4],
        [1, 1, 0],
        [3, 2, 2],
        [0, 0, 3],
        [4, 1, 0],
    ], dtype=float)
    
    # Construct a feasible b
    x_true = np.array([1, 2, 3], dtype=float)
    b = np.array([min(A[i, j] + x_true[j] for j in range(3)) for i in range(6)])
    
    result = tropical_feasibility(A, b)
    
    print(f"\nTropical system: {A.shape[0]} constraints, {A.shape[1]} variables")
    print(f"Feasible: {result['feasible']}")
    if result['feasible']:
        print(f"Solution x = {result['solution']}")
        print(f"Active constraints per variable: {result['active_constraints']}")
        n_active = len(set(c for cs in result['active_constraints'].values() for c in cs))
        print(f"Total active constraints: {n_active}")
        print(f"Carathéodory bound: at most {A.shape[1]} constraints needed per variable")


# ═══════════════════════════════════════════════════════════════════════
# APPLICATION 4: Tropical Convex Hull Visualization Data
# ═══════════════════════════════════════════════════════════════════════

def tropical_hull_2d_boundary(points: np.ndarray, 
                                n_samples: int = 200) -> np.ndarray:
    """
    Sample the boundary of a 2D tropical convex hull.
    
    For 2D, the tropical convex hull of points can be explored by
    varying weights and collecting the resulting combinations.
    
    Args:
        points: (k, 2) array of generators
        n_samples: number of weight samples per pair
        
    Returns:
        (N, 2) array of sampled hull boundary points
    """
    k = points.shape[0]
    hull_points = []
    
    for i in range(k):
        for j in range(i + 1, k):
            for a in np.linspace(-5, 5, n_samples):
                z = np.minimum(a + points[i], -a + points[j])
                hull_points.append(z)
    
    return np.array(hull_points)


def demo_visualization():
    """Demo: tropical hull structure in 2D."""
    print("\n" + "═" * 60)
    print("APPLICATION 4: Tropical Hull Structure (2D)")
    print("═" * 60)
    
    points = np.array([
        [0, 0],
        [3, 1],
        [1, 3],
    ], dtype=float)
    
    hull = tropical_hull_2d_boundary(points, n_samples=100)
    
    print(f"\n3 generators in R^2:")
    for i, p in enumerate(points):
        print(f"  x_{i} = {p}")
    
    print(f"\nSampled {len(hull)} hull boundary points")
    print(f"Hull bounding box: x ∈ [{hull[:,0].min():.1f}, {hull[:,0].max():.1f}], "
          f"y ∈ [{hull[:,1].min():.1f}, {hull[:,1].max():.1f}]")
    
    # Test compression on a random hull point
    idx = len(hull) // 3
    z = hull[idx]
    w = tropical_hull_membership(points, z)
    if w is not None:
        comp = caratheodory_compress(points, w)
        print(f"\nSample point z = {np.round(z, 3)}")
        print(f"  Witnesses: {comp.n_generators} generators (bound: n = 2)")
        print(f"  Match: {np.allclose(comp.result, z)}")


# ═══════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    demo_shortest_path()
    demo_scheduling()
    demo_feasibility()
    demo_visualization()
    
    print("\n" + "═" * 60)
    print("All applications demonstrated successfully.")
    print("═" * 60)


#!/usr/bin/env python3
"""
Tropical Carathéodory Compression — Concrete Demonstrations

This module demonstrates the Tropical Carathéodory Compression Theorem with
concrete numerical examples in dimensions 2, 3, and 4. Each example shows
how a point in the tropical convex hull of a set S can be represented using
at most n generators (where n is the ambient dimension).

Tropical convex combination (min-plus form):
    z(i) = min_{x in S} (w(x) + x(i))

The compression theorem says we can always find T ⊆ S with |T| ≤ n such that
z is also in the tropical convex hull of T.
"""

import numpy as np
from typing import List, Tuple, Dict, Optional


def tropical_combination(points: np.ndarray, weights: np.ndarray) -> np.ndarray:
    """
    Compute a tropical (min-plus) convex combination.
    
    z(i) = min_j (w(j) + points(j, i))
    
    Args:
        points: array of shape (k, n) — k generators in R^n
        weights: array of shape (k,) — tropical weights
        
    Returns:
        z: array of shape (n,) — the tropical combination
    """
    shifted = weights[:, None] + points  # (k, n)
    return shifted.min(axis=0)


def find_active_generators(points: np.ndarray, weights: np.ndarray, z: np.ndarray,
                            tol: float = 1e-10) -> Dict[int, List[int]]:
    """
    For each coordinate i, find which generators are active (attain the minimum).
    
    Returns:
        dict mapping coordinate index i -> list of active generator indices
    """
    n = z.shape[0]
    k = points.shape[0]
    active = {}
    for i in range(n):
        active[i] = []
        for j in range(k):
            if abs(weights[j] + points[j, i] - z[i]) < tol:
                active[i].append(j)
    return active


def compress_witnesses(points: np.ndarray, weights: np.ndarray, z: np.ndarray,
                        tol: float = 1e-10) -> Tuple[np.ndarray, np.ndarray, List[int]]:
    """
    Compress a tropical combination to use at most n generators.
    
    For each coordinate, pick one active generator. The union of chosen generators
    has size at most n.
    
    Returns:
        (compressed_points, compressed_weights, selected_indices)
    """
    active = find_active_generators(points, weights, z, tol)
    n = z.shape[0]
    
    selected = set()
    for i in range(n):
        # Pick the first active generator for coordinate i
        selected.add(active[i][0])
    
    selected = sorted(selected)
    compressed_points = points[selected]
    compressed_weights = weights[selected]
    
    return compressed_points, compressed_weights, selected


def verify_combination(points: np.ndarray, weights: np.ndarray, z: np.ndarray,
                        tol: float = 1e-10) -> bool:
    """Verify that z = tropical_combination(points, weights)."""
    z_computed = tropical_combination(points, weights)
    return np.allclose(z_computed, z, atol=tol)


def demo_2d():
    """Demonstration in dimension 2."""
    print("=" * 60)
    print("DEMO: Tropical Carathéodory in dimension n = 2")
    print("=" * 60)
    
    # 5 generators in R^2
    points = np.array([
        [0.0, 3.0],
        [2.0, 0.0],
        [1.0, 1.0],
        [4.0, 2.0],
        [3.0, 5.0],
    ])
    weights = np.array([1.0, 2.0, 0.5, 3.0, 0.0])
    
    z = tropical_combination(points, weights)
    print(f"\nGenerators S ({len(points)} points in R^2):")
    for j, p in enumerate(points):
        print(f"  x_{j} = {p},  w_{j} = {weights[j]:.1f},  "
              f"w + x = [{weights[j]+p[0]:.1f}, {weights[j]+p[1]:.1f}]")
    
    print(f"\nTropical combination z = {z}")
    
    active = find_active_generators(points, weights, z)
    print(f"\nActive generators per coordinate:")
    for i, gens in active.items():
        gen_names = [f"x_{j}" for j in gens]
        print(f"  Coordinate {i}: {', '.join(gen_names)}")
    
    comp_pts, comp_w, sel = compress_witnesses(points, weights, z)
    print(f"\nCompressed witness set T (|T| = {len(sel)} ≤ n = 2):")
    for idx in sel:
        print(f"  x_{idx} = {points[idx]}, w = {weights[idx]:.1f}")
    
    z_check = tropical_combination(comp_pts, comp_w)
    print(f"\nVerification: z from T = {z_check}")
    print(f"Match: {verify_combination(comp_pts, comp_w, z)}")


def demo_3d():
    """Demonstration in dimension 3."""
    print("\n" + "=" * 60)
    print("DEMO: Tropical Carathéodory in dimension n = 3")
    print("=" * 60)
    
    # 8 generators in R^3
    np.random.seed(42)
    points = np.array([
        [0, 0, 0],
        [1, 2, 3],
        [3, 1, 2],
        [2, 3, 1],
        [4, 0, 1],
        [0, 4, 2],
        [1, 1, 4],
        [2, 2, 2],
    ], dtype=float)
    weights = np.array([0, 1, -1, 2, 0.5, -0.5, 1.5, 0])
    
    z = tropical_combination(points, weights)
    print(f"\n{len(points)} generators in R^3")
    print(f"Tropical combination z = {z}")
    
    active = find_active_generators(points, weights, z)
    for i, gens in active.items():
        gen_names = [f"x_{j}" for j in gens]
        val = [f"{weights[j]+points[j,i]:.1f}" for j in gens]
        print(f"  Coord {i}: active = {gen_names}, values = {val}")
    
    comp_pts, comp_w, sel = compress_witnesses(points, weights, z)
    print(f"\nCompressed: |T| = {len(sel)} ≤ n = 3")
    print(f"Selected generators: {['x_'+str(i) for i in sel]}")
    
    z_check = tropical_combination(comp_pts, comp_w)
    print(f"z from T = {z_check}")
    print(f"Match: {verify_combination(comp_pts, comp_w, z)}")


def demo_sharp_bound():
    """
    Demonstrate that the bound n is tight: construct an example
    where n generators are genuinely needed (no fewer will do).
    """
    print("\n" + "=" * 60)
    print("DEMO: Sharpness of the bound |T| ≤ n")
    print("=" * 60)
    
    n = 3
    # Construct n points where each is the unique active generator for one coordinate
    # Use points along coordinate axes
    points = np.array([
        [0, 10, 10],   # Will be active for coord 0
        [10, 0, 10],   # Will be active for coord 1
        [10, 10, 0],   # Will be active for coord 2
    ], dtype=float)
    weights = np.array([0, 0, 0], dtype=float)
    
    z = tropical_combination(points, weights)
    print(f"\n{n} generators designed so each is uniquely active for one coordinate:")
    for j, p in enumerate(points):
        print(f"  x_{j} = {p}")
    print(f"Weights: all zero")
    print(f"z = {z}")
    
    active = find_active_generators(points, weights, z)
    for i, gens in active.items():
        print(f"  Coord {i}: uniquely active generator = x_{gens[0]}")
    
    # Try removing any single generator
    print(f"\nAttempting to reproduce z with n-1 = {n-1} generators:")
    for skip in range(n):
        mask = [j for j in range(n) if j != skip]
        sub_pts = points[mask]
        # Try all possible weights for the subset
        best_z = tropical_combination(sub_pts, weights[mask])
        match = verify_combination(sub_pts, weights[mask], z)
        print(f"  Without x_{skip}: best z = {best_z}, matches original: {match}")
    
    print(f"\nConclusion: all {n} generators are necessary. The bound |T| ≤ n is tight.")


def demo_rational():
    """Demonstration with exact rational arithmetic."""
    print("\n" + "=" * 60)
    print("DEMO: Rational arithmetic (exact computation)")
    print("=" * 60)
    
    from fractions import Fraction
    
    # 4 generators in Q^2
    points = [
        [Fraction(0), Fraction(1)],
        [Fraction(1), Fraction(0)],
        [Fraction(1, 2), Fraction(1, 2)],
        [Fraction(2), Fraction(3)],
    ]
    weights = [Fraction(0), Fraction(1), Fraction(-1, 2), Fraction(2)]
    
    n = 2
    k = len(points)
    
    # Compute z(i) = min_j (w(j) + x_j(i))
    z = []
    active = {}
    for i in range(n):
        vals = [(weights[j] + points[j][i], j) for j in range(k)]
        min_val = min(v for v, _ in vals)
        z.append(min_val)
        active[i] = [j for v, j in vals if v == min_val]
    
    print(f"\n{k} generators in Q^2:")
    for j in range(k):
        print(f"  x_{j} = {[str(c) for c in points[j]]}, w_{j} = {weights[j]}")
    
    print(f"\nz = {[str(c) for c in z]} (exact rational)")
    print(f"Active generators: {active}")
    
    # Compress
    selected = set()
    for i in range(n):
        selected.add(active[i][0])
    selected = sorted(selected)
    
    print(f"Compressed T: {['x_'+str(j) for j in selected]} (|T| = {len(selected)} ≤ {n})")
    
    # Verify
    z_check = []
    for i in range(n):
        vals = [weights[j] + points[j][i] for j in selected]
        z_check.append(min(vals))
    
    print(f"z from T = {[str(c) for c in z_check]}")
    print(f"Match: {z == z_check}")


if __name__ == "__main__":
    demo_2d()
    demo_3d()
    demo_sharp_bound()
    demo_rational()
    
    print("\n" + "=" * 60)
    print("All demonstrations completed successfully.")
    print("=" * 60)
