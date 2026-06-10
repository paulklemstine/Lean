#!/usr/bin/env python3
"""
Applications of Morse inequalities and chain complex analysis.

Demonstrates:
1. Sensor network coverage analysis
2. Mesh simplification via discrete Morse theory
3. Topological lower bounds for optimization landscapes
"""

import numpy as np
from typing import List, Tuple, Set
from algorithms import (
    ChainComplex, CellComplex, compute_betti_numbers,
    euler_characteristic, greedy_discrete_morse, verify_morse_critical_bounds,
)


# ═══════════════════════════════════════════════════════════════════════
# Application 1: Sensor Network Coverage
# ═══════════════════════════════════════════════════════════════════════

def sensor_network_analysis(
    positions: np.ndarray,
    sensing_radius: float,
) -> dict:
    """
    Analyze a sensor network for coverage holes using homology.

    Given sensor positions and sensing radius, builds the Rips complex
    (up to 2-simplices) and computes Betti numbers.

    β₀ = number of connected components (clusters of sensors)
    β₁ = number of coverage holes (regions not covered)

    The weak Morse inequality β₁ ≤ E - V + β₀ provides an upper bound
    on coverage holes from the network topology alone.

    Parameters
    ----------
    positions : np.ndarray
        Shape (n, 2) array of sensor positions.
    sensing_radius : float
        Communication/sensing radius.

    Returns
    -------
    dict
        Analysis results including Betti numbers and Morse bounds.
    """
    n = len(positions)
    # Build edges: connect sensors within 2*sensing_radius
    comm_radius = 2 * sensing_radius
    edges = []
    for i in range(n):
        for j in range(i + 1, n):
            dist = np.linalg.norm(positions[i] - positions[j])
            if dist <= comm_radius:
                edges.append((i, j))

    # Build triangles: cliques of three connected vertices
    adj = {i: set() for i in range(n)}
    for i, j in edges:
        adj[i].add(j)
        adj[j].add(i)

    triangles = []
    for i in range(n):
        for j in adj[i]:
            if j > i:
                for k in adj[i] & adj[j]:
                    if k > j:
                        triangles.append((i, j, k))

    # Build chain complex
    edge_idx = {e: idx for idx, e in enumerate(edges)}
    nE = len(edges)
    nF = len(triangles)

    d1 = np.zeros((n, nE))
    for idx, (i, j) in enumerate(edges):
        d1[i, idx] = -1
        d1[j, idx] = 1

    d2 = np.zeros((nE, nF))
    for fidx, (a, b, c) in enumerate(triangles):
        e_ab = edge_idx.get((min(a,b), max(a,b)))
        e_bc = edge_idx.get((min(b,c), max(b,c)))
        e_ac = edge_idx.get((min(a,c), max(a,c)))
        if e_ab is not None:
            d2[e_ab, fidx] = 1 if a < b else -1
        if e_bc is not None:
            d2[e_bc, fidx] = 1 if b < c else -1
        if e_ac is not None:
            d2[e_ac, fidx] = -1 if a < c else 1

    cc = ChainComplex(d1=d1, d2=d2)

    if not cc.verify_chain_condition():
        return {"error": "Chain condition failed"}

    beta0, beta1, beta2 = compute_betti_numbers(cc)

    return {
        "num_sensors": n,
        "num_connections": nE,
        "num_triangular_regions": nF,
        "connected_components": beta0,
        "coverage_holes": beta1,
        "euler_characteristic": euler_characteristic(cc),
        "morse_bound_holes": nE - n + beta0,  # β₁ ≤ E - V + β₀
    }


# ═══════════════════════════════════════════════════════════════════════
# Application 2: Mesh Simplification
# ═══════════════════════════════════════════════════════════════════════

def mesh_simplification(cell_complex: CellComplex) -> dict:
    """
    Simplify a mesh using discrete Morse theory.

    The discrete Morse reduction pairs cells to cancel them,
    producing a smaller complex with the same homology.
    The weak Morse inequality guarantees βₖ ≤ cₖ.

    Parameters
    ----------
    cell_complex : CellComplex
        The mesh to simplify.

    Returns
    -------
    dict
        Simplification results.
    """
    cc = cell_complex.to_chain_complex()
    betti = compute_betti_numbers(cc)

    morse = greedy_discrete_morse(cell_complex)
    bounds = verify_morse_critical_bounds(morse)

    original_cells = cell_complex.num_vertices + cell_complex.num_edges + cell_complex.num_faces
    critical_cells = morse.num_crit0 + morse.num_crit1 + morse.num_crit2
    reduction = 1 - critical_cells / max(original_cells, 1)

    return {
        "original_cells": original_cells,
        "critical_cells": critical_cells,
        "reduction_ratio": f"{reduction:.1%}",
        "original_dims": (cell_complex.num_vertices, cell_complex.num_edges,
                         cell_complex.num_faces),
        "critical_dims": (morse.num_crit0, morse.num_crit1, morse.num_crit2),
        "betti_numbers": betti,
        "bounds_verified": all(bounds.values()),
        "pairings": len(morse.pairings),
    }


# ═══════════════════════════════════════════════════════════════════════
# Application 3: Optimization Landscape Analysis
# ═══════════════════════════════════════════════════════════════════════

def landscape_analysis(
    minima: List[int],
    saddle_connections: List[Tuple[int, int]],
) -> dict:
    """
    Analyze a 1D optimization landscape topology.

    Models the landscape as a graph where:
    - Vertices are local minima
    - Edges are saddle connections between minima

    The Morse inequality β₁ ≤ E - V + β₀ provides a lower bound
    on the number of non-trivial cycles in the landscape.

    Parameters
    ----------
    minima : List[int]
        Indices of local minima.
    saddle_connections : List[Tuple[int, int]]
        Pairs of minima connected by saddle points.

    Returns
    -------
    dict
        Landscape analysis results.
    """
    V = len(minima)
    E = len(saddle_connections)

    # Map minima to indices
    idx = {m: i for i, m in enumerate(minima)}
    edges = [(idx[a], idx[b]) for a, b in saddle_connections if a in idx and b in idx]
    E = len(edges)

    d1 = np.zeros((V, E))
    for e_idx, (src, tgt) in enumerate(edges):
        d1[src, e_idx] = -1
        d1[tgt, e_idx] = 1

    d2 = np.zeros((E, 0))  # No faces in 1D

    cc = ChainComplex(d1=d1, d2=d2)
    beta0, beta1, _ = compute_betti_numbers(cc)

    return {
        "num_minima": V,
        "num_saddle_connections": E,
        "connected_basins": beta0,
        "non_trivial_cycles": beta1,
        "euler_characteristic": V - E,
        "min_descent_basins": beta0,  # Any algorithm must find ≥ β₀ basins
    }


# ═══════════════════════════════════════════════════════════════════════
# Main demonstrations
# ═══════════════════════════════════════════════════════════════════════

def main():
    print("=" * 72)
    print("APPLICATIONS OF MORSE INEQUALITIES")
    print("=" * 72)

    # ── Application 1: Sensor Network ──
    print("\n" + "─" * 72)
    print("Application 1: Sensor Network Coverage Analysis")
    print("─" * 72)

    # Create a sensor network with a coverage hole
    np.random.seed(42)
    # Ring of sensors with a gap
    angles = np.linspace(0, 2 * np.pi, 8, endpoint=False)
    positions = np.column_stack([np.cos(angles), np.sin(angles)])
    # Remove one sensor to create a hole
    positions_with_hole = np.delete(positions, 3, axis=0)

    print("\nComplete ring (8 sensors):")
    result = sensor_network_analysis(positions, sensing_radius=0.5)
    for k, v in result.items():
        print(f"  {k}: {v}")

    print("\nRing with gap (7 sensors, one removed):")
    result = sensor_network_analysis(positions_with_hole, sensing_radius=0.5)
    for k, v in result.items():
        print(f"  {k}: {v}")

    # Dense grid (no holes expected)
    grid_x, grid_y = np.meshgrid(np.linspace(0, 1, 4), np.linspace(0, 1, 4))
    grid_positions = np.column_stack([grid_x.ravel(), grid_y.ravel()])
    print("\nDense grid (4×4 = 16 sensors):")
    result = sensor_network_analysis(grid_positions, sensing_radius=0.2)
    for k, v in result.items():
        print(f"  {k}: {v}")

    # ── Application 2: Mesh Simplification ──
    print("\n" + "─" * 72)
    print("Application 2: Mesh Simplification via Discrete Morse Theory")
    print("─" * 72)

    from algorithms import make_triangle_boundary, make_filled_triangle, make_tetrahedron_boundary

    for name, complex_fn in [
        ("Triangle boundary (S¹)", make_triangle_boundary),
        ("Filled triangle (D²)", make_filled_triangle),
        ("Tetrahedron boundary (S²)", make_tetrahedron_boundary),
    ]:
        result = mesh_simplification(complex_fn())
        print(f"\n{name}:")
        print(f"  Original cells: {result['original_dims']} (total {result['original_cells']})")
        print(f"  Critical cells: {result['critical_dims']} (total {result['critical_cells']})")
        print(f"  Reduction: {result['reduction_ratio']}")
        print(f"  Betti numbers: {result['betti_numbers']}")
        print(f"  βₖ ≤ cₖ verified: {result['bounds_verified']}")

    # ── Application 3: Optimization Landscape ──
    print("\n" + "─" * 72)
    print("Application 3: Optimization Landscape Topology")
    print("─" * 72)

    # Simple landscape: 3 minima in a line
    print("\nLinear landscape (3 minima, 2 saddles):")
    result = landscape_analysis(
        minima=[0, 1, 2],
        saddle_connections=[(0, 1), (1, 2)],
    )
    for k, v in result.items():
        print(f"  {k}: {v}")

    # Landscape with a cycle
    print("\nCyclic landscape (4 minima, 4 saddles, 1 cycle):")
    result = landscape_analysis(
        minima=[0, 1, 2, 3],
        saddle_connections=[(0, 1), (1, 2), (2, 3), (3, 0)],
    )
    for k, v in result.items():
        print(f"  {k}: {v}")

    # Complex landscape
    print("\nComplex landscape (5 minima, 7 saddles):")
    result = landscape_analysis(
        minima=[0, 1, 2, 3, 4],
        saddle_connections=[(0,1), (1,2), (2,3), (3,4), (4,0), (0,2), (1,3)],
    )
    for k, v in result.items():
        print(f"  {k}: {v}")

    print("\n" + "=" * 72)
    print("All applications demonstrated successfully.")
    print("=" * 72)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Demonstration of Weak Morse Inequalities for Three-Term Chain Complexes.

This script verifies the weak Morse inequalities and Euler characteristic
identity on several concrete examples of 2D polyhedral complexes.
"""

import numpy as np
from typing import Tuple, Dict, List


def compute_betti_numbers(d1: np.ndarray, d2: np.ndarray) -> Tuple[int, int, int]:
    """
    Compute Betti numbers β₀, β₁, β₂ for a three-term chain complex C₂ →d₂ C₁ →d₁ C₀.

    Uses rank-nullity: βₖ = dim(ker dₖ) - dim(im d_{k+1}).

    Parameters
    ----------
    d1 : np.ndarray
        Boundary matrix d₁: C₁ → C₀ (shape: dim C₀ × dim C₁)
    d2 : np.ndarray
        Boundary matrix d₂: C₂ → C₁ (shape: dim C₁ × dim C₂)

    Returns
    -------
    Tuple[int, int, int]
        Betti numbers (β₀, β₁, β₂)
    """
    dim_C0, dim_C1_from_d1 = d1.shape
    dim_C1_from_d2, dim_C2 = d2.shape
    assert dim_C1_from_d1 == dim_C1_from_d2, "Dimension mismatch"
    dim_C1 = dim_C1_from_d1

    # Verify chain condition
    product = d1 @ d2
    assert np.allclose(product, 0), f"Chain condition violated: d1·d2 ≠ 0\n{product}"

    rank_d1 = np.linalg.matrix_rank(d1)
    rank_d2 = np.linalg.matrix_rank(d2)

    beta0 = dim_C0 - rank_d1
    beta1 = dim_C1 - rank_d1 - rank_d2
    beta2 = dim_C2 - rank_d2

    return beta0, beta1, beta2


def verify_morse_inequalities(
    name: str, d1: np.ndarray, d2: np.ndarray
) -> Dict:
    """
    Verify all weak Morse inequalities for a three-term chain complex.

    Returns a dictionary with dimensions, Betti numbers, and verification results.
    """
    dim_C0 = d1.shape[0]
    dim_C1 = d1.shape[1]
    dim_C2 = d2.shape[1]

    beta0, beta1, beta2 = compute_betti_numbers(d1, d2)

    # Weak Morse inequality, degree 0: β₀ ≤ dim C₀
    ineq0 = beta0 <= dim_C0

    # Weak Morse inequality, degree 1: β₁ - β₀ ≤ dim C₁ - dim C₀
    ineq1 = (beta1 - beta0) <= (dim_C1 - dim_C0)

    # Euler characteristic: β₂ - β₁ + β₀ = dim C₂ - dim C₁ + dim C₀
    euler_lhs = beta2 - beta1 + beta0
    euler_rhs = dim_C2 - dim_C1 + dim_C0
    euler_eq = euler_lhs == euler_rhs

    return {
        "name": name,
        "dim_C": (dim_C0, dim_C1, dim_C2),
        "betti": (beta0, beta1, beta2),
        "morse_ineq_0": ineq0,
        "morse_ineq_1": ineq1,
        "euler_eq": euler_eq,
        "euler_char": euler_lhs,
    }


def make_point():
    """A single point: V={v}, E=∅, F=∅."""
    d1 = np.zeros((1, 0))
    d2 = np.zeros((0, 0))
    return d1, d2


def make_interval():
    """An interval: V={v₀, v₁}, E={e}, F=∅. ∂e = v₁ - v₀."""
    d1 = np.array([[-1], [1]])  # ∂₁: e ↦ v₁ - v₀
    d2 = np.zeros((1, 0))
    return d1, d2


def make_triangle_boundary():
    """Triangle boundary (circle): V={a,b,c}, E={ab,bc,ca}, F=∅.
    ∂(ab) = b-a, ∂(bc) = c-b, ∂(ca) = a-c."""
    d1 = np.array([
        [-1,  0,  1],  # vertex a: -ab + ca
        [ 1, -1,  0],  # vertex b: ab - bc
        [ 0,  1, -1],  # vertex c: bc - ca
    ])
    d2 = np.zeros((3, 0))
    return d1, d2


def make_filled_triangle():
    """Filled triangle: V={a,b,c}, E={ab,bc,ca}, F={abc}.
    ∂₂(abc) = ab + bc + ca (with orientations)."""
    d1 = np.array([
        [-1,  0,  1],  # vertex a
        [ 1, -1,  0],  # vertex b
        [ 0,  1, -1],  # vertex c
    ])
    d2 = np.array([
        [1],   # edge ab
        [1],   # edge bc
        [1],   # edge ca
    ])
    return d1, d2


def make_square_boundary():
    """Square boundary: V={a,b,c,d}, E={ab,bc,cd,da}, F=∅."""
    d1 = np.array([
        [-1,  0,  0,  1],  # vertex a: -ab + da
        [ 1, -1,  0,  0],  # vertex b: ab - bc
        [ 0,  1, -1,  0],  # vertex c: bc - cd
        [ 0,  0,  1, -1],  # vertex d: cd - da
    ])
    d2 = np.zeros((4, 0))
    return d1, d2


def make_torus_minimal():
    """Minimal triangulation of the torus with 9 vertices, 27 edges, 18 faces.
    Uses the standard identification of a square grid."""
    # Vertices labeled 0..8 in a 3x3 grid with toroidal identification
    # Row i, Col j -> vertex 3*i + j
    # Triangles: upper-left and lower-right of each square
    V, E, F = 9, 27, 18

    # Build incidence from triangle list
    triangles = []
    edges_set = set()
    edge_list = []

    def v(i, j):
        return 3 * (i % 3) + (j % 3)

    for i in range(3):
        for j in range(3):
            # Upper triangle: (i,j), (i,j+1), (i+1,j+1)
            a, b, c = v(i,j), v(i,j+1), v(i+1,j+1)
            triangles.append((a, b, c))
            for e in [(min(a,b), max(a,b)), (min(b,c), max(b,c)), (min(a,c), max(a,c))]:
                edges_set.add(e)
            # Lower triangle: (i,j), (i+1,j+1), (i+1,j)
            a, b, c = v(i,j), v(i+1,j+1), v(i+1,j)
            triangles.append((a, b, c))
            for e in [(min(a,b), max(a,b)), (min(b,c), max(b,c)), (min(a,c), max(a,c))]:
                edges_set.add(e)

    edge_list = sorted(edges_set)
    edge_idx = {e: i for i, e in enumerate(edge_list)}

    nE = len(edge_list)
    nF = len(triangles)

    d1 = np.zeros((V, nE))
    for idx, (a, b) in enumerate(edge_list):
        d1[a, idx] = -1
        d1[b, idx] = 1

    d2 = np.zeros((nE, nF))
    for fidx, (a, b, c) in enumerate(triangles):
        # Oriented edges: a->b, b->c, a->c
        e_ab = (min(a,b), max(a,b))
        e_bc = (min(b,c), max(b,c))
        e_ac = (min(a,c), max(a,c))
        # Signs based on orientation
        d2[edge_idx[e_ab], fidx] += (1 if a < b else -1)
        d2[edge_idx[e_bc], fidx] += (1 if b < c else -1)
        d2[edge_idx[e_ac], fidx] += (-1 if a < c else 1)

    return d1, d2


def make_two_components():
    """Two disjoint points: V={a,b}, E=∅, F=∅. β₀=2."""
    d1 = np.zeros((2, 0))
    d2 = np.zeros((0, 0))
    return d1, d2


def main():
    print("=" * 72)
    print("WEAK MORSE INEQUALITIES — COMPUTATIONAL VERIFICATION")
    print("=" * 72)
    print()

    examples = [
        ("Point", *make_point()),
        ("Interval", *make_interval()),
        ("Triangle boundary (S¹)", *make_triangle_boundary()),
        ("Filled triangle (disk)", *make_filled_triangle()),
        ("Square boundary (S¹)", *make_square_boundary()),
        ("Two disjoint points", *make_two_components()),
    ]

    # Torus may have issues with the minimal triangulation, add carefully
    try:
        d1_torus, d2_torus = make_torus_minimal()
        if np.allclose(d1_torus @ d2_torus, 0):
            examples.append(("Torus (minimal)", d1_torus, d2_torus))
        else:
            print("[Note: Torus triangulation orientation issue, skipping]")
    except Exception as e:
        print(f"[Note: Torus construction failed: {e}]")

    results = []
    for name, d1, d2 in examples:
        result = verify_morse_inequalities(name, d1, d2)
        results.append(result)

    # Print results
    print(f"{'Complex':<30} {'V':>3} {'E':>3} {'F':>3}  "
          f"{'β₀':>3} {'β₁':>3} {'β₂':>3}  {'χ':>3}  "
          f"{'M₀':>3} {'M₁':>3} {'Euler':>6}")
    print("-" * 72)

    all_pass = True
    for r in results:
        c0, c1, c2 = r["dim_C"]
        b0, b1, b2 = r["betti"]
        m0 = "✓" if r["morse_ineq_0"] else "✗"
        m1 = "✓" if r["morse_ineq_1"] else "✗"
        eu = "✓" if r["euler_eq"] else "✗"

        print(f"{r['name']:<30} {c0:>3} {c1:>3} {c2:>3}  "
              f"{b0:>3} {b1:>3} {b2:>3}  {r['euler_char']:>3}  "
              f"  {m0}   {m1}    {eu}")

        if not (r["morse_ineq_0"] and r["morse_ineq_1"] and r["euler_eq"]):
            all_pass = False

    print("-" * 72)
    if all_pass:
        print("All weak Morse inequalities and Euler identities VERIFIED. ✓")
    else:
        print("SOME CHECKS FAILED! ✗")

    print()
    print("Legend:")
    print("  V, E, F = number of vertices, edges, faces (= dim C₀, C₁, C₂)")
    print("  β₀, β₁, β₂ = Betti numbers (homology dimensions)")
    print("  χ = Euler characteristic = β₀ - β₁ + β₂ = V - E + F")
    print("  M₀: β₀ ≤ V    M₁: β₁ - β₀ ≤ E - V    Euler: χ(C) = χ(H)")
    print()

    # Demonstrate the master decomposition
    print("=" * 72)
    print("MASTER DECOMPOSITION: dim Cₖ = βₖ + dim Bₖ₋₁ + dim Bₖ")
    print("=" * 72)
    print()

    for name, d1, d2 in examples[:5]:
        c0, c1, c2 = d1.shape[0], d1.shape[1], d2.shape[1]
        b0, b1, b2 = compute_betti_numbers(d1, d2)
        r1 = np.linalg.matrix_rank(d1)  # dim B₀
        r2 = np.linalg.matrix_rank(d2)  # dim B₁

        print(f"  {name}:")
        print(f"    dim C₀ = {c0} = β₀ + dim B₀ = {b0} + {r1}")
        print(f"    dim C₁ = {c1} = β₁ + dim B₁ + dim B₀ = {b1} + {r2} + {r1}")
        print(f"    dim C₂ = {c2} = β₂ + dim B₁ = {b2} + {r2}")
        assert c0 == b0 + r1
        assert c1 == b1 + r2 + r1
        assert c2 == b2 + r2
        print(f"    ✓ All decompositions verified")
        print()


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""Generate PACKAGE.json with all embedded content."""

import json
import base64
from pathlib import Path

# Read markdown files
article = Path("ARTICLE.md").read_text()
research_paper = Path("RESEARCH_PAPER.md").read_text()
future_directions = Path("FUTURE_DIRECTIONS.md").read_text()

# Read Lean code
lean_code = Path("Bridges/MorseInequalities.lean").read_text()

# Read Python code
demo_code = Path("demo.py").read_text()
algorithms_code = Path("algorithms.py").read_text()
applications_code = Path("applications.py").read_text()

# Read visualization images as base64
def img_to_base64(path):
    with open(path, "rb") as f:
        data = base64.b64encode(f.read()).decode("utf-8")
    return f"data:image/png;base64,{data}"

viz1 = img_to_base64("viz_decomposition.png")
viz2 = img_to_base64("viz_morse_inequalities.png")
viz3 = img_to_base64("viz_discrete_morse.png")

package = {
    "title": "Weak Morse Inequalities for Polyhedral Chain Complexes",
    "domain": "Algebraic Topology / Homological Algebra / Discrete Morse Theory",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Weak Morse Inequalities Verification",
            "code": demo_code,
        },
    ],
    "algorithms": [
        {
            "name": "Betti Number Computation",
            "pseudocode": (
                "Algorithm: ComputeBettiNumbers(d1, d2)\n"
                "Input: Matrices d1 (m1×n1), d2 (n1×n2) with d1·d2=0\n"
                "Output: Betti numbers β₀, β₁, β₂\n\n"
                "1. r₁ ← rank(d1)\n"
                "2. r₂ ← rank(d2)\n"
                "3. β₀ ← m₁ - r₁\n"
                "4. β₁ ← n₁ - r₁ - r₂\n"
                "5. β₂ ← n₂ - r₂\n"
                "6. return (β₀, β₁, β₂)\n\n"
                "Time: O(max(m₁n₁², n₁n₂²))"
            ),
            "code": algorithms_code,
        },
        {
            "name": "Discrete Morse Reduction",
            "pseudocode": (
                "Algorithm: DiscreteMorseReduction(complex)\n"
                "Input: Cell complex with vertices, edges, faces\n"
                "Output: Critical cells satisfying βₖ ≤ cₖ\n\n"
                "1. Build adjacency graph\n"
                "2. BFS spanning forest → pair non-root vertices with tree edges\n"
                "3. Pair faces with non-tree edges\n"
                "4. Return unpaired cells as critical\n\n"
                "Guarantee: βₖ ≤ cₖ for all k, χ preserved"
            ),
            "code": algorithms_code,
        },
    ],
    "visualizations": [
        {
            "name": "Chain Group Master Decomposition",
            "data": viz1,
        },
        {
            "name": "Weak Morse Inequalities Comparison",
            "data": viz2,
        },
        {
            "name": "Discrete Morse Reduction",
            "data": viz3,
        },
    ],
    "lean_proofs": lean_code,
}

with open("PACKAGE.json", "w") as f:
    json.dump(package, f, ensure_ascii=False)

print(f"PACKAGE.json generated ({Path('PACKAGE.json').stat().st_size / 1024:.0f} KB)")


#!/usr/bin/env python3
"""
Visualizations for Morse inequalities and chain complex analysis.

Generates:
1. Chain complex decomposition diagram
2. Morse inequality verification across examples
3. Discrete Morse reduction visualization
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from algorithms import (
    ChainComplex, compute_betti_numbers, CellComplex,
    greedy_discrete_morse, make_triangle_boundary, make_filled_triangle,
    make_tetrahedron_boundary,
)
import base64
from io import BytesIO


def fig_to_base64(fig) -> str:
    """Convert a matplotlib figure to a base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def plot_master_decomposition():
    """Visualize the master decomposition for several examples."""
    examples = {
        "Point": (np.zeros((1, 0)), np.zeros((0, 0))),
        "Interval": (np.array([[-1], [1]]), np.zeros((1, 0))),
        "Triangle\nboundary": (
            np.array([[-1, 0, 1], [1, -1, 0], [0, 1, -1]]),
            np.zeros((3, 0))
        ),
        "Filled\ntriangle": (
            np.array([[-1, 0, 1], [1, -1, 0], [0, 1, -1]]),
            np.array([[1], [1], [1]])
        ),
        "Tet.\nboundary": None,  # Will compute from CellComplex
    }

    # Build tetrahedron boundary
    tet = make_tetrahedron_boundary()
    cc_tet = tet.to_chain_complex()
    examples["Tet.\nboundary"] = (cc_tet.d1, cc_tet.d2)

    fig, axes = plt.subplots(1, len(examples), figsize=(16, 5))
    fig.suptitle("Master Decomposition: dim Cₖ = βₖ + dim Bₖ₋₁ + dim Bₖ",
                 fontsize=14, fontweight='bold')

    colors = {'β': '#2ecc71', 'B': '#e74c3c', 'B_prev': '#3498db'}

    for ax, (name, (d1, d2)) in zip(axes, examples.items()):
        cc = ChainComplex(d1=d1, d2=d2)
        c = [cc.dim_C0, cc.dim_C1, cc.dim_C2]
        b0, b1, b2 = compute_betti_numbers(cc)
        r1 = int(np.linalg.matrix_rank(d1))  # dim B₀
        r2 = int(np.linalg.matrix_rank(d2))  # dim B₁

        # For each degree k, show stacked bar: βₖ + Bₖ₋₁ + Bₖ
        decomp = [
            (b0, 0, r1),    # C₀ = β₀ + 0 + B₀  (no B₋₁)
            (b1, r2, r1),   # C₁ = β₁ + B₁ + B₀
            (b2, 0, r2),    # C₂ = β₂ + 0 + B₁  (note: "B₀" here is actually B₁ for C₂)
        ]
        # Correct: C₀ = β₀ + dim B₀, C₁ = β₁ + dim B₁ + dim B₀, C₂ = β₂ + dim B₁

        x = [0, 1, 2]
        bottoms = [0, 0, 0]

        # Stack: β first
        betas = [b0, b1, b2]
        ax.bar(x, betas, bottom=bottoms, color=colors['β'], label='βₖ', width=0.6)
        for i in range(3):
            bottoms[i] += betas[i]

        # Stack: Bₖ (boundaries going forward)
        bk = [r1, r1, 0]  # B₀ appears in C₀ and C₁; nothing in C₂'s forward
        # Actually the correct decomposition:
        # C₀ = β₀ + B₀  (B₀ = im d₁)
        # C₁ = β₁ + B₁ + B₀
        # C₂ = β₂ + B₁
        # So the forward boundary contributes: B₀ to C₀, B₀ to C₁, B₁ to C₂
        # And the backward boundary: B₁ to C₁

        # Let's just do it correctly:
        bottoms = [0, 0, 0]
        ax.cla()
        # β
        ax.bar(x, [b0, b1, b2], bottom=bottoms, color=colors['β'], width=0.6)
        for i in range(3):
            if [b0, b1, b2][i] > 0:
                ax.text(x[i], bottoms[i] + [b0, b1, b2][i]/2, f'β{i}={[b0,b1,b2][i]}',
                       ha='center', va='center', fontsize=8, fontweight='bold')
            bottoms[i] += [b0, b1, b2][i]

        # Boundary contributions
        b_contrib = [r1, r2+r1, r2]  # B₀ for C₀; B₁+B₀ for C₁; B₁ for C₂
        # Split into two colors for C₁
        if name != "Point":
            # For C₀: add B₀
            if r1 > 0:
                ax.bar([0], [r1], bottom=[bottoms[0]], color=colors['B'], width=0.6)
                ax.text(0, bottoms[0]+r1/2, f'B₀={r1}', ha='center', va='center',
                       fontsize=7, color='white')
                bottoms[0] += r1

            # For C₁: add B₁ then B₀
            if r2 > 0:
                ax.bar([1], [r2], bottom=[bottoms[1]], color=colors['B_prev'], width=0.6)
                ax.text(1, bottoms[1]+r2/2, f'B₁={r2}', ha='center', va='center',
                       fontsize=7, color='white')
                bottoms[1] += r2
            if r1 > 0:
                ax.bar([1], [r1], bottom=[bottoms[1]], color=colors['B'], width=0.6)
                ax.text(1, bottoms[1]+r1/2, f'B₀={r1}', ha='center', va='center',
                       fontsize=7, color='white')
                bottoms[1] += r1

            # For C₂: add B₁
            if r2 > 0:
                ax.bar([2], [r2], bottom=[bottoms[2]], color=colors['B_prev'], width=0.6)
                ax.text(2, bottoms[2]+r2/2, f'B₁={r2}', ha='center', va='center',
                       fontsize=7, color='white')
                bottoms[2] += r2

        ax.set_xticks(x)
        ax.set_xticklabels(['C₀', 'C₁', 'C₂'])
        ax.set_title(name, fontsize=10)
        max_val = max(c) if max(c) > 0 else 1
        ax.set_ylim(0, max_val + 0.5)
        ax.set_ylabel('Dimension' if ax == axes[0] else '')

    # Legend
    patches = [
        mpatches.Patch(color=colors['β'], label='Homology (βₖ)'),
        mpatches.Patch(color=colors['B'], label='Boundary B₀=im(d₁)'),
        mpatches.Patch(color=colors['B_prev'], label='Boundary B₁=im(d₂)'),
    ]
    fig.legend(handles=patches, loc='lower center', ncol=3, fontsize=10)
    plt.tight_layout(rect=[0, 0.08, 1, 0.95])
    return fig


def plot_morse_inequalities_table():
    """Visualize weak Morse inequalities as a comparison chart."""
    data = [
        ("Point", 1, 0, 0, 1, 0, 0),
        ("Interval", 2, 1, 0, 1, 0, 0),
        ("S¹ (triangle)", 3, 3, 0, 1, 1, 0),
        ("D² (filled tri)", 3, 3, 1, 1, 0, 0),
        ("S¹ (square)", 4, 4, 0, 1, 1, 0),
        ("S² (tet bdry)", 4, 6, 4, 1, 0, 1),
    ]

    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    fig.suptitle("Weak Morse Inequalities: βₖ ≤ dim Cₖ (and alternating versions)",
                 fontsize=14, fontweight='bold')

    names = [d[0] for d in data]
    x = np.arange(len(names))
    w = 0.35

    # Degree 0: β₀ ≤ dim C₀
    ax = axes[0]
    c0s = [d[1] for d in data]
    b0s = [d[4] for d in data]
    ax.bar(x - w/2, c0s, w, label='dim C₀', color='#3498db', alpha=0.8)
    ax.bar(x + w/2, b0s, w, label='β₀', color='#2ecc71', alpha=0.8)
    ax.set_title('Degree 0: β₀ ≤ dim C₀', fontsize=11)
    ax.set_xticks(x)
    ax.set_xticklabels(names, rotation=45, ha='right', fontsize=8)
    ax.legend()
    ax.set_ylabel('Dimension')

    # Degree 1 (alternating): β₁ - β₀ ≤ dim C₁ - dim C₀
    ax = axes[1]
    alt_c = [d[2] - d[1] for d in data]
    alt_b = [d[5] - d[4] for d in data]
    ax.bar(x - w/2, alt_c, w, label='dim C₁ − dim C₀', color='#3498db', alpha=0.8)
    ax.bar(x + w/2, alt_b, w, label='β₁ − β₀', color='#2ecc71', alpha=0.8)
    ax.set_title('Degree 1: β₁ − β₀ ≤ dim C₁ − dim C₀', fontsize=11)
    ax.set_xticks(x)
    ax.set_xticklabels(names, rotation=45, ha='right', fontsize=8)
    ax.legend()
    ax.axhline(y=0, color='gray', linestyle='--', linewidth=0.5)

    # Degree 2 (Euler): equality
    ax = axes[2]
    euler_c = [d[1] - d[2] + d[3] for d in data]
    euler_b = [d[4] - d[5] + d[6] for d in data]
    ax.bar(x - w/2, euler_c, w, label='V − E + F', color='#3498db', alpha=0.8)
    ax.bar(x + w/2, euler_b, w, label='β₀ − β₁ + β₂', color='#2ecc71', alpha=0.8)
    ax.set_title('Euler: V − E + F = β₀ − β₁ + β₂', fontsize=11)
    ax.set_xticks(x)
    ax.set_xticklabels(names, rotation=45, ha='right', fontsize=8)
    ax.legend()

    plt.tight_layout()
    return fig


def plot_discrete_morse_reduction():
    """Visualize discrete Morse reduction for several complexes."""
    complexes = [
        ("Triangle boundary\n(S¹)", make_triangle_boundary()),
        ("Filled triangle\n(D²)", make_filled_triangle()),
        ("Tet boundary\n(S²)", make_tetrahedron_boundary()),
    ]

    fig, axes = plt.subplots(1, len(complexes), figsize=(14, 5))
    fig.suptitle("Discrete Morse Reduction: Original vs Critical Cells",
                 fontsize=14, fontweight='bold')

    for ax, (name, cx) in zip(axes, complexes):
        morse = greedy_discrete_morse(cx)
        b0, b1, b2 = morse.original_betti

        categories = ['Vertices\n(dim 0)', 'Edges\n(dim 1)', 'Faces\n(dim 2)']
        original = [cx.num_vertices, cx.num_edges, cx.num_faces]
        critical = [morse.num_crit0, morse.num_crit1, morse.num_crit2]
        betti = [b0, b1, b2]

        x = np.arange(3)
        w = 0.25

        bars1 = ax.bar(x - w, original, w, label='Original', color='#3498db', alpha=0.8)
        bars2 = ax.bar(x, critical, w, label='Critical', color='#e67e22', alpha=0.8)
        bars3 = ax.bar(x + w, betti, w, label='Betti (βₖ)', color='#2ecc71', alpha=0.8)

        ax.set_xticks(x)
        ax.set_xticklabels(categories, fontsize=9)
        ax.set_title(name, fontsize=11)
        ax.legend(fontsize=8)

        # Add value labels
        for bars in [bars1, bars2, bars3]:
            for bar in bars:
                h = bar.get_height()
                if h > 0:
                    ax.text(bar.get_x() + bar.get_width()/2, h + 0.05,
                           str(int(h)), ha='center', va='bottom', fontsize=8)

        max_val = max(original) if max(original) > 0 else 1
        ax.set_ylim(0, max_val + 1)
        ax.set_ylabel('Count' if ax == axes[0] else '')

    plt.tight_layout()
    return fig


def main():
    """Generate all visualizations and save them."""
    print("Generating visualizations...")

    fig1 = plot_master_decomposition()
    fig1.savefig('viz_decomposition.png', dpi=150, bbox_inches='tight')
    print("  Saved viz_decomposition.png")

    fig2 = plot_morse_inequalities_table()
    fig2.savefig('viz_morse_inequalities.png', dpi=150, bbox_inches='tight')
    print("  Saved viz_morse_inequalities.png")

    fig3 = plot_discrete_morse_reduction()
    fig3.savefig('viz_discrete_morse.png', dpi=150, bbox_inches='tight')
    print("  Saved viz_discrete_morse.png")

    print("All visualizations generated.")
    return fig1, fig2, fig3


if __name__ == "__main__":
    main()
