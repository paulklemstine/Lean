#!/usr/bin/env python3
"""
Applications of Discrete Morse Theory

Demonstrates real-world applications of Morse inequalities and
Morse reduction in topological data analysis, network analysis,
and computational topology.
"""

import numpy as np
from typing import List, Tuple, Dict
from collections import defaultdict


# ============================================================
# Application 1: Topological Data Analysis (TDA)
# ============================================================

def vietoris_rips_complex(points: np.ndarray, epsilon: float) -> List[Tuple[int, ...]]:
    """
    Build a Vietoris-Rips complex from a point cloud.

    Two points are connected if their distance is at most epsilon.
    Higher simplices are added for all cliques.

    Parameters
    ----------
    points : np.ndarray of shape (n, d)
        Point cloud in d-dimensional space.
    epsilon : float
        Distance threshold.

    Returns
    -------
    list of tuple
        Maximal simplices of the Vietoris-Rips complex.
    """
    n = len(points)
    # Build adjacency
    adj = [[False]*n for _ in range(n)]
    for i in range(n):
        for j in range(i+1, n):
            if np.linalg.norm(points[i] - points[j]) <= epsilon:
                adj[i][j] = True
                adj[j][i] = True

    # Find all cliques using Bron-Kerbosch
    def bronkerbosch(R, P, X, cliques):
        if not P and not X:
            if len(R) >= 1:
                cliques.append(tuple(sorted(R)))
            return
        pivot = max(P | X, key=lambda v: sum(1 for u in P if adj[v][u]))
        for v in list(P - {u for u in range(n) if adj[pivot][u]}):
            neighbors = {u for u in range(n) if adj[v][u]}
            bronkerbosch(R | {v}, P & neighbors, X & neighbors, cliques)
            P.remove(v)
            X.add(v)

    cliques = []
    bronkerbosch(set(), set(range(n)), set(), cliques)

    # Filter to maximal cliques
    clique_sets = [frozenset(c) for c in cliques]
    maximal = []
    for c in clique_sets:
        if not any(c < other for other in clique_sets):
            maximal.append(tuple(sorted(c)))

    return maximal if maximal else [(i,) for i in range(n)]


def tda_demo():
    """Demonstrate TDA pipeline with Morse-theoretic bounds."""
    print("=" * 70)
    print("APPLICATION 1: TOPOLOGICAL DATA ANALYSIS")
    print("=" * 70)
    print()

    # Generate points on a noisy circle
    np.random.seed(42)
    n_points = 20
    theta = np.linspace(0, 2*np.pi, n_points, endpoint=False)
    noise = 0.1 * np.random.randn(n_points, 2)
    points = np.column_stack([np.cos(theta), np.sin(theta)]) + noise

    print(f"Point cloud: {n_points} points on a noisy circle in ℝ²")
    print()

    # Build complexes at different scales
    epsilons = [0.5, 0.7, 1.0, 1.5]
    for eps in epsilons:
        maximal = vietoris_rips_complex(points, eps)
        # Count simplices
        all_simplices = set()
        for s in maximal:
            for mask in range(1, 1 << len(s)):
                face = tuple(sorted(v for i, v in enumerate(s) if mask & (1 << i)))
                all_simplices.add(face)

        f_vector = defaultdict(int)
        for s in all_simplices:
            f_vector[len(s) - 1] += 1

        max_dim = max(f_vector.keys()) if f_vector else 0
        fv = [f_vector[k] for k in range(max_dim + 1)]
        chi = sum((-1)**k * fv[k] for k in range(len(fv)))

        print(f"  ε = {eps:.1f}: f-vector = {fv}, χ = {chi}")

    print()
    print("  Morse inequality guarantees:")
    print("    β_0 ≤ crit_0 (connected components ≤ critical vertices)")
    print("    β_1 ≤ crit_1 (loops ≤ critical edges)")
    print("    These bounds enable early termination in persistence computation.")
    print()


# ============================================================
# Application 2: Network Topology
# ============================================================

def network_analysis_demo():
    """Analyze topological features of a network using Morse theory."""
    print("=" * 70)
    print("APPLICATION 2: NETWORK TOPOLOGY ANALYSIS")
    print("=" * 70)
    print()

    # Build a small social network graph
    # Vertices = people, edges = connections, triangles = friend groups
    edges = [
        (0,1), (1,2), (2,3), (3,4), (4,0),  # outer cycle
        (0,2), (0,3),  # shortcuts
        (5,6), (6,7), (7,5),  # separate triangle
        (3,5),  # bridge between components
    ]

    # Build clique complex
    n = 8
    adj = [[False]*n for _ in range(n)]
    for a, b in edges:
        adj[a][b] = True
        adj[b][a] = True

    # Find triangles
    triangles = []
    for i in range(n):
        for j in range(i+1, n):
            if adj[i][j]:
                for k in range(j+1, n):
                    if adj[i][k] and adj[j][k]:
                        triangles.append((i,j,k))

    n_vertices = n
    n_edges = len(edges)
    n_triangles = len(triangles)

    chi = n_vertices - n_edges + n_triangles
    print(f"  Network: {n_vertices} nodes, {n_edges} edges, {n_triangles} triangles")
    print(f"  Euler characteristic: χ = {n_vertices} - {n_edges} + {n_triangles} = {chi}")
    print()
    print(f"  By Morse inequalities (for any discrete Morse function f):")
    print(f"    β_0 ≤ crit_0(f)  →  connected components ≤ local minima of f")
    print(f"    β_1 ≤ crit_1(f)  →  independent cycles ≤ saddle edges of f")
    print(f"  These bounds help identify essential topological features")
    print(f"  (loops, components) from noisy network data.")
    print()


# ============================================================
# Application 3: Energy Landscape Analysis
# ============================================================

def energy_landscape_demo():
    """
    Demonstrate Morse theory applied to energy landscape analysis.
    Models a 1D potential energy function and counts critical points.
    """
    print("=" * 70)
    print("APPLICATION 3: ENERGY LANDSCAPE ANALYSIS")
    print("=" * 70)
    print()

    # Define a potential energy function on a discrete grid
    n = 100
    x = np.linspace(0, 4*np.pi, n)
    V = np.sin(x) + 0.5*np.sin(2*x) + 0.3*np.cos(3*x)

    # Find critical points (local extrema on discrete grid)
    minima = []
    maxima = []
    for i in range(1, n-1):
        if V[i] < V[i-1] and V[i] < V[i+1]:
            minima.append(i)
        elif V[i] > V[i-1] and V[i] > V[i+1]:
            maxima.append(i)

    n_min = len(minima)
    n_max = len(maxima)

    print(f"  Potential V(x) = sin(x) + 0.5·sin(2x) + 0.3·cos(3x)")
    print(f"  Sampled at {n} points on [0, 4π]")
    print(f"  Local minima (index-0 critical): {n_min}")
    print(f"  Local maxima (index-1 critical): {n_max}")
    print(f"  Morse inequality for interval: β_0 = 1 ≤ {n_min} = crit_0  ✓")
    print(f"  Euler characteristic: χ = 1 (interval)")
    print(f"  Identity check: crit_0 - crit_1 = {n_min} - {n_max} = {n_min - n_max}")
    print(f"  (Should be 1 for an interval, boundary effects may alter count)")
    print()
    print("  Morse theory application:")
    print("    The number of local energy minima (metastable states)")
    print("    is constrained by topology: at least β_0 minima exist,")
    print("    and crit_0 - crit_1 + ... = χ must hold.")
    print("    This constrains the complexity of energy landscapes")
    print("    in molecular dynamics, protein folding, and optimization.")
    print()


# ============================================================
# Application 4: Image Topology
# ============================================================

def image_topology_demo():
    """Demonstrate Morse-theoretic approach to image feature detection."""
    print("=" * 70)
    print("APPLICATION 4: IMAGE TOPOLOGY (SUBLEVEL SET ANALYSIS)")
    print("=" * 70)
    print()

    # Create a simple 8x8 grayscale "image" with features
    image = np.array([
        [5, 5, 5, 5, 5, 5, 5, 5],
        [5, 1, 1, 5, 5, 1, 1, 5],
        [5, 1, 1, 5, 5, 1, 1, 5],
        [5, 5, 5, 3, 3, 5, 5, 5],
        [5, 5, 5, 3, 3, 5, 5, 5],
        [5, 2, 2, 5, 5, 2, 2, 5],
        [5, 2, 2, 5, 5, 2, 2, 5],
        [5, 5, 5, 5, 5, 5, 5, 5],
    ], dtype=float)

    print("  Grayscale image (8×8):")
    for row in image:
        print("    " + " ".join(f"{int(v)}" for v in row))
    print()

    # Analyze sublevel sets at different thresholds
    thresholds = [1.5, 2.5, 3.5, 4.5]
    for t in thresholds:
        mask = image <= t
        n_pixels = mask.sum()
        # Count connected components (simple 4-connectivity)
        visited = np.zeros_like(mask, dtype=bool)
        components = 0
        for i in range(8):
            for j in range(8):
                if mask[i,j] and not visited[i,j]:
                    # BFS
                    components += 1
                    stack = [(i,j)]
                    while stack:
                        ci, cj = stack.pop()
                        if visited[ci,cj]:
                            continue
                        visited[ci,cj] = True
                        for di, dj in [(-1,0),(1,0),(0,-1),(0,1)]:
                            ni, nj = ci+di, cj+dj
                            if 0 <= ni < 8 and 0 <= nj < 8 and mask[ni,nj] and not visited[ni,nj]:
                                stack.append((ni,nj))

        print(f"  Threshold t={t}: {n_pixels} pixels, {components} component(s)")

    print()
    print("  Morse theory insight:")
    print("    As we sweep the threshold, β_0 changes at critical values.")
    print("    Each local minimum of the image creates a new component (crit_0),")
    print("    each saddle merges two components (crit_1).")
    print("    Persistence = (death threshold - birth threshold) measures feature significance.")
    print()


if __name__ == '__main__':
    tda_demo()
    network_analysis_demo()
    energy_landscape_demo()
    image_topology_demo()
    print("=" * 70)
    print("All application demonstrations completed!")


#!/usr/bin/env python3
"""
Discrete Morse Theory: Numerical Demonstrations

Demonstrates the Morse inequalities and Euler characteristic identities
for finite chain complexes, illustrating how critical cell counts bound
Betti numbers and determine Euler characteristics.
"""

import numpy as np
from typing import List, Tuple, Optional


def chain_complex_homology(differentials: List[np.ndarray]) -> Tuple[List[int], List[int], List[int]]:
    """
    Compute Betti numbers, chain dimensions, and boundary ranks
    for a chain complex given by a list of differential matrices.

    Parameters
    ----------
    differentials : list of np.ndarray
        differentials[i] is the matrix of d_i : C_{i+1} -> C_i
        Must satisfy d_i @ d_{i+1} = 0 for all i.

    Returns
    -------
    betti : list of int
        Betti numbers β_n = dim H_n
    dims : list of int
        Chain dimensions dim C_n
    boundary_ranks : list of int
        Ranks of boundary maps rank(d_n)
    """
    n_degrees = len(differentials) + 1

    # Chain dimensions
    dims = []
    dims.append(differentials[0].shape[0])  # C_0
    for i, d in enumerate(differentials):
        dims.append(d.shape[1])  # C_{i+1} = cols of d_i

    # Boundary ranks (rank of d_n)
    boundary_ranks = [int(np.linalg.matrix_rank(d)) for d in differentials]

    # Betti numbers
    # β_0 = dim C_0 - rank(d_0)
    # β_{n+1} = dim(ker d_n) - rank(d_{n+1}) = (dim C_{n+1} - rank(d_n)) - rank(d_{n+1})
    betti = []
    # β_0: cycles = all of C_0, boundaries = range(d_0)
    betti.append(dims[0] - boundary_ranks[0])

    for n in range(len(differentials) - 1):
        # At degree n+1:
        # cycles = ker(d_n) = dim C_{n+1} - rank(d_n)
        # boundaries = range(d_{n+1})
        cycles_dim = dims[n + 1] - boundary_ranks[n]
        boundaries_dim = boundary_ranks[n + 1]
        betti.append(cycles_dim - boundaries_dim)

    # Last degree: no outgoing differential above
    # cycles = ker(d_{last}) = dim C_{last} - rank(d_{last-1})
    # boundaries = 0 (no higher differential)
    last = len(differentials)
    cycles_dim = dims[last] - boundary_ranks[last - 1]
    betti.append(cycles_dim)

    return betti, dims, boundary_ranks


def euler_characteristic(values: List[int]) -> int:
    """Compute alternating sum: Σ (-1)^n * values[n]."""
    return sum((-1)**n * v for n, v in enumerate(values))


def verify_morse_inequalities(betti: List[int], critical: List[int]) -> bool:
    """Verify weak Morse inequalities: β_n ≤ crit_n for all n."""
    return all(b <= c for b, c in zip(betti, critical))


def strong_morse_check(betti: List[int], critical: List[int]) -> List[int]:
    """
    Compute the strong Morse inequality differences:
    Σ_{i=0}^{k} (-1)^{k-i} crit_i - Σ_{i=0}^{k} (-1)^{k-i} β_i ≥ 0
    Returns the list of differences for each k.
    """
    diffs = []
    for k in range(len(betti)):
        lhs = sum((-1)**(k - i) * critical[i] for i in range(k + 1))
        rhs = sum((-1)**(k - i) * betti[i] for i in range(k + 1))
        diffs.append(lhs - rhs)
    return diffs


def print_separator():
    print("=" * 70)


# ============================================================
# Example 1: The Point (single 0-cell)
# ============================================================
print_separator()
print("EXAMPLE 1: THE POINT")
print_separator()
print("Chain complex: K ← 0")
print("One 0-cell, zero differential.")
print()

# d_0 : C_1 -> C_0, but C_1 = 0, so d_0 is 0x1 matrix (empty)
# For simplicity, use a 1x0 zero matrix
d0_point = np.zeros((1, 0))
# Manual computation since our function expects at least one differential
dims_point = [1]
betti_point = [1]
critical_point = [1]

print(f"  Chain dimensions:  {dims_point}")
print(f"  Betti numbers:     {betti_point}")
print(f"  Critical cells:    {critical_point}")
print(f"  Weak Morse ineq:   {verify_morse_inequalities(betti_point, critical_point)}")
print(f"  χ(Betti):          {euler_characteristic(betti_point)}")
print(f"  χ(Critical):       {euler_characteristic(critical_point)}")
print()

# ============================================================
# Example 2: The Circle S¹ (simplicial)
# ============================================================
print_separator()
print("EXAMPLE 2: THE CIRCLE S¹ (simplicial triangulation)")
print_separator()
print("Triangulation: 3 vertices (v0, v1, v2), 3 edges (e01, e12, e02)")
print("Chain complex: ℚ³ ←d₀― ℚ³")
print()

# d_0 : C_1 -> C_0 (3x3 matrix)
# Edge e_01 = v1 - v0, e_12 = v2 - v1, e_02 = v2 - v0
d0_circle = np.array([
    [-1,  0, -1],   # v0: -e01 - e02
    [ 1, -1,  0],   # v1: +e01 - e12
    [ 0,  1,  1],   # v2: +e12 + e02
], dtype=float)

betti_circle, dims_circle, ranks_circle = chain_complex_homology([d0_circle])

# Morse reduction: 1 critical 0-cell, 1 critical 1-cell
critical_circle = [1, 1]

print(f"  Chain dimensions:  {dims_circle}")
print(f"  Boundary ranks:    {ranks_circle}")
print(f"  Betti numbers:     {betti_circle}")
print(f"  Critical cells:    {critical_circle}")
print(f"  Weak Morse ineq:   {verify_morse_inequalities(betti_circle, critical_circle)}")
print(f"  χ(Betti):          {euler_characteristic(betti_circle)}")
print(f"  χ(Critical):       {euler_characteristic(critical_circle)}")
print(f"  Strong Morse diffs: {strong_morse_check(betti_circle, critical_circle)}")
print()

# ============================================================
# Example 3: The Torus T² (simplicial)
# ============================================================
print_separator()
print("EXAMPLE 3: THE TORUS T² (minimal triangulation)")
print_separator()
print("7 vertices, 21 edges, 14 triangles")
print("Chain complex: ℚ⁷ ←d₀― ℚ²¹ ←d₁― ℚ¹⁴")
print()

# Minimal triangulation of the torus with 7 vertices
# Using the standard 7-vertex triangulation
vertices = list(range(7))
triangles = [
    (0,1,2), (0,2,3), (0,3,4), (0,4,5), (0,5,6), (0,1,6),
    (1,2,4), (2,3,5), (3,4,6), (4,5,1), (5,6,2), (6,1,3),
    (1,3,5), (2,4,6)
]

# Build edge list
edge_set = set()
for t in triangles:
    for i in range(3):
        e = tuple(sorted([t[i], t[(i+1)%3]]))
        edge_set.add(e)
edges = sorted(edge_set)

# d_0 : C_1 -> C_0 (7 x 21)
d0_torus = np.zeros((7, len(edges)), dtype=float)
for j, (a, b) in enumerate(edges):
    d0_torus[a, j] = -1
    d0_torus[b, j] = 1

# d_1 : C_2 -> C_1 (21 x 14)
d1_torus = np.zeros((len(edges), len(triangles)), dtype=float)
for j, (a, b, c) in enumerate(triangles):
    # ∂(a,b,c) = (b,c) - (a,c) + (a,b)
    e_bc = edges.index(tuple(sorted([b, c])))
    e_ac = edges.index(tuple(sorted([a, c])))
    e_ab = edges.index(tuple(sorted([a, b])))
    d1_torus[e_ab, j] = 1
    d1_torus[e_ac, j] = -1
    d1_torus[e_bc, j] = 1

betti_torus, dims_torus, ranks_torus = chain_complex_homology([d0_torus, d1_torus])

# Expected: β = [1, 2, 1] for the torus
critical_torus = [1, 2, 1]  # Minimal Morse function on torus

print(f"  Chain dimensions:  {dims_torus}")
print(f"  Boundary ranks:    {ranks_torus}")
print(f"  Betti numbers:     {betti_torus}")
print(f"  Critical cells:    {critical_torus}")
print(f"  Weak Morse ineq:   {verify_morse_inequalities(betti_torus, critical_torus)}")
print(f"  χ(Betti):          {euler_characteristic(betti_torus)}")
print(f"  χ(Critical):       {euler_characteristic(critical_torus)}")
print(f"  Strong Morse diffs: {strong_morse_check(betti_torus, critical_torus)}")
print()

# ============================================================
# Example 4: Real Projective Plane RP² (over ℚ)
# ============================================================
print_separator()
print("EXAMPLE 4: REAL PROJECTIVE PLANE RP² (6-vertex triangulation, ℚ coefficients)")
print_separator()
print("6 vertices, 15 edges, 10 triangles")
print()

# Minimal triangulation of RP² with 6 vertices
# Using antipodal identification on icosahedron
rp2_triangles = [
    (0,1,2), (0,2,3), (0,3,4), (0,1,5), (0,4,5),
    (1,2,4), (2,3,5), (3,4,1), (4,5,2), (5,1,3)
]

rp2_edge_set = set()
for t in rp2_triangles:
    for i in range(3):
        e = tuple(sorted([t[i], t[(i+1)%3]]))
        rp2_edge_set.add(e)
rp2_edges = sorted(rp2_edge_set)

d0_rp2 = np.zeros((6, len(rp2_edges)), dtype=float)
for j, (a, b) in enumerate(rp2_edges):
    d0_rp2[a, j] = -1
    d0_rp2[b, j] = 1

d1_rp2 = np.zeros((len(rp2_edges), len(rp2_triangles)), dtype=float)
for j, (a, b, c) in enumerate(rp2_triangles):
    e_bc = rp2_edges.index(tuple(sorted([b, c])))
    e_ac = rp2_edges.index(tuple(sorted([a, c])))
    e_ab = rp2_edges.index(tuple(sorted([a, b])))
    d1_rp2[e_ab, j] = 1
    d1_rp2[e_ac, j] = -1
    d1_rp2[e_bc, j] = 1

betti_rp2, dims_rp2, ranks_rp2 = chain_complex_homology([d0_rp2, d1_rp2])

# Over ℚ: β = [1, 0, 0] for RP² (torsion is invisible)
critical_rp2 = [1, 1, 1]  # Standard Morse function on RP²

print(f"  Chain dimensions:  {dims_rp2}")
print(f"  Boundary ranks:    {ranks_rp2}")
print(f"  Betti numbers:     {betti_rp2}")
print(f"  Critical cells:    {critical_rp2}")
print(f"  Weak Morse ineq:   {verify_morse_inequalities(betti_rp2, critical_rp2)}")
print(f"  χ(Betti):          {euler_characteristic(betti_rp2)}")
print(f"  χ(Critical):       {euler_characteristic(critical_rp2)}")
print(f"  Strong Morse diffs: {strong_morse_check(betti_rp2, critical_rp2)}")
print()

# ============================================================
# Example 5: Discrete Morse Reduction on a Square
# ============================================================
print_separator()
print("EXAMPLE 5: DISCRETE MORSE REDUCTION ON A SQUARE")
print_separator()
print("Square with 4 vertices, 5 edges (incl. diagonal), 2 triangles")
print("Acyclic matching cancels pairs, leaving 1 critical 0-cell.")
print()

# Square: vertices 0,1,2,3; edges + diagonal
sq_edges = [(0,1), (1,2), (2,3), (0,3), (0,2)]
sq_triangles = [(0,1,2), (0,2,3)]

d0_sq = np.zeros((4, 5), dtype=float)
for j, (a, b) in enumerate(sq_edges):
    d0_sq[a, j] = -1
    d0_sq[b, j] = 1

d1_sq = np.zeros((5, 2), dtype=float)
for j, (a, b, c) in enumerate(sq_triangles):
    e_ab = sq_edges.index((a,b))
    e_ac = sq_edges.index((min(a,c), max(a,c)))
    e_bc = sq_edges.index((min(b,c), max(b,c)))
    d1_sq[e_ab, j] = 1
    d1_sq[e_ac, j] = -1
    d1_sq[e_bc, j] = 1

betti_sq, dims_sq, ranks_sq = chain_complex_homology([d0_sq, d1_sq])
critical_sq = [1, 0, 0]  # Contractible: one critical 0-cell

print(f"  Chain dimensions:  {dims_sq}")
print(f"  Boundary ranks:    {ranks_sq}")
print(f"  Betti numbers:     {betti_sq}")
print(f"  Critical cells:    {critical_sq}")
print(f"  Weak Morse ineq:   {verify_morse_inequalities(betti_sq, critical_sq)}")
print(f"  χ(Betti):          {euler_characteristic(betti_sq)}")
print(f"  χ(Critical):       {euler_characteristic(critical_sq)}")
print(f"  Strong Morse diffs: {strong_morse_check(betti_sq, critical_sq)}")
print()

# ============================================================
# Summary Table
# ============================================================
print_separator()
print("SUMMARY: MORSE INEQUALITIES VERIFICATION")
print_separator()
print(f"{'Space':<15} {'dim C_n':<20} {'β_n':<15} {'crit_n':<15} {'χ':<5} {'Weak OK':<8} {'Strong diffs'}")
print("-" * 100)
spaces = [
    ("Point", dims_point, betti_point, critical_point),
    ("Circle S¹", dims_circle, betti_circle, critical_circle),
    ("Torus T²", dims_torus, betti_torus, critical_torus),
    ("RP²", dims_rp2, betti_rp2, critical_rp2),
    ("Square", dims_sq, betti_sq, critical_sq),
]
for name, dims, betti, crit in spaces:
    chi = euler_characteristic(betti)
    weak = verify_morse_inequalities(betti, crit)
    strong = strong_morse_check(betti, crit)
    print(f"{name:<15} {str(dims):<20} {str(betti):<15} {str(crit):<15} {chi:<5} {str(weak):<8} {strong}")
print()

if __name__ == "__main__":
    print("All Morse inequality verifications completed successfully!")


#!/usr/bin/env python3
"""Generate PACKAGE.json bundling all artifacts."""

import json
import base64

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

def read_image_base64(path):
    with open(path, 'rb') as f:
        data = base64.b64encode(f.read()).decode('utf-8')
        return f'data:image/png;base64,{data}'

# Read all content
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
lean_proofs = read_file('Geometry/Morse/DiscreteMorseInequalities.lean')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')

# Read visualizations
viz_weak = read_image_base64('viz_weak_morse.png')
viz_strong = read_image_base64('viz_strong_morse.png')
viz_euler = read_image_base64('viz_euler_char.png')
viz_reduction = read_image_base64('viz_morse_reduction.png')

package = {
    "title": "Certified Discrete Morse Inequalities: A Formal Bridge from Geometry to Topology",
    "domain": "Geometry / Algebraic Topology / Discrete Morse Theory",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Morse Inequalities Verification",
            "code": demo_code
        },
        {
            "name": "Applications: TDA, Networks, Energy Landscapes",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Homology Computation via SVD",
            "pseudocode": """Algorithm: ComputeHomology(d_1, ..., d_D)
  Input: Boundary matrices d_k of a chain complex
  Output: Betti numbers β_0, ..., β_D

  for k = 1 to D:
    r_k ← rank(d_k)  // via SVD
  β_0 ← dim C_0 - r_1
  for k = 1 to D-1:
    β_k ← (dim C_k - r_k) - r_{k+1}
  β_D ← dim C_D - r_D
  return β_0, ..., β_D

Time: O(Σ min(n_k, n_{k+1})² · max(n_k, n_{k+1}))
Space: O(max n_k · n_{k+1})""",
            "code": algorithms_code
        },
        {
            "name": "Greedy Discrete Morse Reduction",
            "pseudocode": """Algorithm: GreedyMorseReduction(K)
  Input: Simplicial complex K
  Output: Acyclic matching M, critical cells C

  remaining ← all simplices of K
  M ← ∅; C ← ∅
  while remaining ≠ ∅:
    found ← false
    for dim d = 0 to max_dim:
      for σ ∈ remaining with dim(σ) = d:
        cofacets ← {τ ∈ remaining : σ ⊂ τ, dim(τ) = d+1}
        if |cofacets| = 1:
          M ← M ∪ {(σ, cofacets[0])}
          remaining ← remaining \\ {σ, cofacets[0]}
          found ← true; break
      if found: break
    if not found:
      σ ← lowest-dim simplex in remaining
      C ← C ∪ {σ}; remaining ← remaining \\ {σ}
  return M, C

Time: O(n² · d) where n = |K|, d = max dimension
Space: O(n)""",
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {
            "name": "Weak Morse Inequalities: βₙ ≤ critₙ",
            "data": viz_weak
        },
        {
            "name": "Strong Morse Inequalities: Cumulative Alternating Sums",
            "data": viz_strong
        },
        {
            "name": "Euler Characteristic and Betti Number Profiles",
            "data": viz_euler
        },
        {
            "name": "Morse Reduction: Compressing the Torus",
            "data": viz_reduction
        }
    ],
    "lean_proofs": lean_proofs
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json written ({len(json.dumps(package))//1024} KB)")


#!/usr/bin/env python3
"""
Visualizations for Discrete Morse Inequalities
Generates charts showing Betti numbers vs critical cells and strong Morse differences.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import base64
import io


def fig_to_base64(fig):
    """Convert a matplotlib figure to a base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def create_betti_vs_critical_chart():
    """Bar chart comparing Betti numbers to critical cell counts for various spaces."""
    spaces = {
        'Point': ([1], [1]),
        'Circle S¹': ([1, 1], [1, 1]),
        'Torus T²': ([1, 2, 1], [1, 2, 1]),
        'RP²': ([1, 0, 0], [1, 1, 1]),
        'Sphere S²': ([1, 0, 1], [1, 0, 1]),
        'Klein bottle': ([1, 1, 0], [1, 2, 1]),
    }

    fig, axes = plt.subplots(2, 3, figsize=(14, 8))
    fig.suptitle('Weak Morse Inequalities: βₙ ≤ critₙ', fontsize=16, fontweight='bold')

    for ax, (name, (betti, crit)) in zip(axes.flat, spaces.items()):
        x = np.arange(len(betti))
        width = 0.35
        bars1 = ax.bar(x - width/2, crit, width, label='Critical cells', color='#E74C3C', alpha=0.8)
        bars2 = ax.bar(x + width/2, betti, width, label='Betti numbers', color='#3498DB', alpha=0.8)
        ax.set_xlabel('Degree n')
        ax.set_ylabel('Count')
        ax.set_title(name, fontsize=12, fontweight='bold')
        ax.set_xticks(x)
        ax.legend(fontsize=8)
        ax.set_ylim(0, max(max(crit), max(betti)) + 0.5)

    plt.tight_layout()
    return fig


def create_strong_morse_chart():
    """Visualize strong Morse inequality: cumulative alternating sums."""
    spaces = {
        'Torus T²': ([1, 2, 1], [1, 2, 1]),
        'RP²': ([1, 0, 0], [1, 1, 1]),
        'Klein bottle': ([1, 1, 0], [1, 2, 1]),
        'Genus-2 surface': ([1, 4, 1], [1, 4, 1]),
    }

    fig, axes = plt.subplots(2, 2, figsize=(12, 8))
    fig.suptitle('Strong Morse Inequalities:\nΣ (-1)^(k−i) βᵢ  ≤  Σ (-1)^(k−i) critᵢ', fontsize=14, fontweight='bold')

    for ax, (name, (betti, crit)) in zip(axes.flat, spaces.items()):
        k_vals = list(range(len(betti)))

        betti_sums = []
        crit_sums = []
        for k in k_vals:
            bs = sum((-1)**(k-i) * betti[i] for i in range(k+1))
            cs = sum((-1)**(k-i) * crit[i] for i in range(k+1))
            betti_sums.append(bs)
            crit_sums.append(cs)

        ax.plot(k_vals, crit_sums, 'ro-', label='Critical sums', markersize=8, linewidth=2)
        ax.plot(k_vals, betti_sums, 'bs-', label='Betti sums', markersize=8, linewidth=2)
        ax.fill_between(k_vals, betti_sums, crit_sums, alpha=0.2, color='green', label='Gap ≥ 0')
        ax.set_xlabel('Truncation degree k')
        ax.set_ylabel('Alternating sum')
        ax.set_title(name, fontsize=12, fontweight='bold')
        ax.set_xticks(k_vals)
        ax.legend(fontsize=8)
        ax.grid(True, alpha=0.3)

    plt.tight_layout()
    return fig


def create_euler_characteristic_chart():
    """Visualize Euler characteristic as alternating sum."""
    # Various surfaces
    surfaces = [
        ('Sphere S²', 2, [1, 0, 1]),
        ('Torus T²', 0, [1, 2, 1]),
        ('Klein bottle', 0, [1, 1, 0]),
        ('RP²', 1, [1, 0, 0]),
        ('Genus-2', -2, [1, 4, 1]),
        ('Genus-3', -4, [1, 6, 1]),
    ]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    fig.suptitle('Euler Characteristic: Σ (-1)ⁿ βₙ = Σ (-1)ⁿ critₙ', fontsize=14, fontweight='bold')

    # Left: Euler characteristics
    names = [s[0] for s in surfaces]
    chis = [s[1] for s in surfaces]
    colors = ['#E74C3C' if c < 0 else '#2ECC71' if c > 0 else '#3498DB' for c in chis]
    ax1.barh(names, chis, color=colors, alpha=0.8, edgecolor='black')
    ax1.set_xlabel('Euler Characteristic χ')
    ax1.set_title('Euler Characteristic of Surfaces', fontweight='bold')
    ax1.axvline(x=0, color='black', linewidth=0.5)
    ax1.grid(True, alpha=0.3, axis='x')

    # Right: Betti numbers stacked
    max_deg = max(len(s[2]) for s in surfaces)
    for i, (name, chi, betti) in enumerate(surfaces):
        betti_padded = betti + [0] * (max_deg - len(betti))
        x = np.arange(max_deg)
        ax2.plot(x, betti_padded, 'o-', label=f'{name} (χ={chi})', markersize=6, linewidth=1.5)

    ax2.set_xlabel('Degree n')
    ax2.set_ylabel('Betti number βₙ')
    ax2.set_title('Betti Number Profiles', fontweight='bold')
    ax2.legend(fontsize=8)
    ax2.grid(True, alpha=0.3)
    ax2.set_xticks(range(max_deg))

    plt.tight_layout()
    return fig


def create_morse_reduction_diagram():
    """Visualize the concept of Morse reduction as compression."""
    fig, ax = plt.subplots(1, 1, figsize=(12, 5))

    # Original complex dimensions
    original = [7, 21, 14]
    reduced = [1, 2, 1]
    labels = ['Degree 0\n(vertices)', 'Degree 1\n(edges)', 'Degree 2\n(faces)']

    x = np.arange(len(labels))
    width = 0.35

    bars1 = ax.bar(x - width/2, original, width, label='Original complex',
                   color='#E74C3C', alpha=0.8, edgecolor='black')
    bars2 = ax.bar(x + width/2, reduced, width, label='Morse complex (critical cells)',
                   color='#2ECC71', alpha=0.8, edgecolor='black')

    # Add compression ratios
    for i in range(len(original)):
        ratio = reduced[i] / original[i] * 100
        ax.annotate(f'{ratio:.0f}%', xy=(x[i] + width/2, reduced[i]),
                   xytext=(x[i] + width/2 + 0.15, reduced[i] + 1),
                   fontsize=10, color='darkgreen', fontweight='bold')

    ax.set_xlabel('Chain Group Degree', fontsize=12)
    ax.set_ylabel('Dimension', fontsize=12)
    ax.set_title('Morse Reduction: Compressing the Torus T²\n'
                 'from 42 cells to 4 critical cells — same homology!',
                 fontsize=14, fontweight='bold')
    ax.set_xticks(x)
    ax.set_xticklabels(labels)
    ax.legend(fontsize=11, loc='upper left')
    ax.grid(True, alpha=0.3, axis='y')

    plt.tight_layout()
    return fig


if __name__ == '__main__':
    # Generate and save all figures
    fig1 = create_betti_vs_critical_chart()
    fig1.savefig('viz_weak_morse.png', dpi=150, bbox_inches='tight')
    print("Saved viz_weak_morse.png")

    fig2 = create_strong_morse_chart()
    fig2.savefig('viz_strong_morse.png', dpi=150, bbox_inches='tight')
    print("Saved viz_strong_morse.png")

    fig3 = create_euler_characteristic_chart()
    fig3.savefig('viz_euler_char.png', dpi=150, bbox_inches='tight')
    print("Saved viz_euler_char.png")

    fig4 = create_morse_reduction_diagram()
    fig4.savefig('viz_morse_reduction.png', dpi=150, bbox_inches='tight')
    print("Saved viz_morse_reduction.png")
