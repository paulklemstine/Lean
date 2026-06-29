#!/usr/bin/env python3
"""
Algorithms for Discrete Gauss-Bonnet, Euler Characteristic, and Poincaré-Hopf.

Implements the verified algorithms from the research paper with full
docstrings, type hints, and example usage.
"""

import math
from typing import List, Tuple, Dict, Set, Optional


# ============================================================
# Algorithm 1: Euler Characteristic Computation
# ============================================================

def compute_euler_char(n_vertices: int, n_edges: int, n_faces: int) -> int:
    """Compute the Euler characteristic χ = V - E + F.

    This is the fundamental topological invariant of a cell complex.
    For closed orientable surfaces: χ = 2 - 2g where g is the genus.

    Args:
        n_vertices: Number of 0-cells (vertices)
        n_edges: Number of 1-cells (edges)
        n_faces: Number of 2-cells (faces)

    Returns:
        The Euler characteristic as an integer.

    Time complexity: O(1)
    Space complexity: O(1)

    Examples:
        >>> compute_euler_char(4, 6, 4)   # tetrahedron
        2
        >>> compute_euler_char(7, 21, 14)  # minimal torus
        0
        >>> compute_euler_char(12, 30, 20) # icosahedron
        2
    """
    return n_vertices - n_edges + n_faces


def compute_genus(euler_char: int) -> Optional[int]:
    """Compute the genus from the Euler characteristic.

    For orientable closed surfaces, g = (2 - χ) / 2.
    Returns None if χ is odd (non-orientable or invalid).

    Args:
        euler_char: The Euler characteristic

    Returns:
        The genus, or None if not a valid orientable closed surface.

    Examples:
        >>> compute_genus(2)   # sphere
        0
        >>> compute_genus(0)   # torus
        1
        >>> compute_genus(-2)  # genus-2
        2
    """
    if (2 - euler_char) % 2 != 0:
        return None
    g = (2 - euler_char) // 2
    return g if g >= 0 else None


# ============================================================
# Algorithm 2: Vertex Angle-Defect Curvature
# ============================================================

def compute_face_angles(
    vertices: List[Tuple[float, float, float]],
    faces: List[Tuple[int, int, int]]
) -> List[Tuple[float, float, float]]:
    """Compute the interior angles of each triangular face.

    Uses the law of cosines to compute the angle at each vertex
    of each triangle from the vertex coordinates.

    Args:
        vertices: List of (x, y, z) coordinates
        faces: List of (v0, v1, v2) vertex index triples

    Returns:
        List of (angle_at_v0, angle_at_v1, angle_at_v2) for each face.

    Time complexity: O(|F|)
    Space complexity: O(|F|)
    """
    def dot(a, b):
        return sum(x * y for x, y in zip(a, b))

    def sub(a, b):
        return tuple(x - y for x, y in zip(a, b))

    def norm(a):
        return math.sqrt(dot(a, a))

    def angle_at(vertex, p1, p2):
        d1 = sub(p1, vertex)
        d2 = sub(p2, vertex)
        cos_a = dot(d1, d2) / (norm(d1) * norm(d2) + 1e-30)
        cos_a = max(-1.0, min(1.0, cos_a))
        return math.acos(cos_a)

    result = []
    for v0, v1, v2 in faces:
        a0 = angle_at(vertices[v0], vertices[v1], vertices[v2])
        a1 = angle_at(vertices[v1], vertices[v0], vertices[v2])
        a2 = angle_at(vertices[v2], vertices[v0], vertices[v1])
        result.append((a0, a1, a2))
    return result


def compute_vertex_curvature(
    n_vertices: int,
    faces: List[Tuple[int, int, int]],
    angles: List[Tuple[float, float, float]]
) -> List[float]:
    """Compute the angle-defect curvature at each vertex.

    K(v) = 2π - ∑_{f ∋ v} θ_{f,v}

    where θ_{f,v} is the angle at vertex v in face f.

    Args:
        n_vertices: Total number of vertices
        faces: List of (v0, v1, v2) face triples
        angles: List of (a0, a1, a2) angle triples for each face

    Returns:
        List of curvatures K[v] for each vertex v.

    Time complexity: O(|V| + |F|)
    Space complexity: O(|V|)

    Example:
        >>> # Regular tetrahedron
        >>> faces = [(0,1,2),(0,1,3),(0,2,3),(1,2,3)]
        >>> angles = compute_face_angles(verts, faces)
        >>> K = compute_vertex_curvature(4, faces, angles)
        >>> abs(sum(K) - 4*math.pi) < 1e-10
        True
    """
    angle_sum = [0.0] * n_vertices
    for fi, (v0, v1, v2) in enumerate(faces):
        a0, a1, a2 = angles[fi]
        angle_sum[v0] += a0
        angle_sum[v1] += a1
        angle_sum[v2] += a2

    return [2 * math.pi - s for s in angle_sum]


def verify_gauss_bonnet(
    n_vertices: int, n_edges: int, n_faces: int,
    faces: List[Tuple[int, int, int]],
    angles: List[Tuple[float, float, float]],
    tol: float = 1e-10
) -> Dict[str, object]:
    """Verify the discrete Gauss-Bonnet theorem on given data.

    Checks: ∑_v K(v) = 2πχ where χ = V - E + F.

    Args:
        n_vertices, n_edges, n_faces: Cell counts
        faces: Face triples
        angles: Angle triples
        tol: Tolerance for floating-point comparison

    Returns:
        Dictionary with keys:
            'chi': Euler characteristic
            'total_curvature': ∑ K(v)
            'expected': 2πχ
            'error': |∑K(v) - 2πχ|
            'verified': bool

    Time complexity: O(|V| + |F|)
    Space complexity: O(|V|)
    """
    chi = compute_euler_char(n_vertices, n_edges, n_faces)
    K = compute_vertex_curvature(n_vertices, faces, angles)
    total_K = sum(K)
    expected = 2 * math.pi * chi
    error = abs(total_K - expected)

    return {
        'chi': chi,
        'total_curvature': total_K,
        'expected': expected,
        'error': error,
        'verified': error < tol,
        'vertex_curvatures': K,
    }


# ============================================================
# Algorithm 3: Forman Field Critical Cell Analysis
# ============================================================

def compute_critical_cells(
    n_vertices: int, n_edges: int, n_faces: int,
    num_VE_pairs: int, num_EF_pairs: int
) -> Dict[str, int]:
    """Compute critical cell counts for a Forman discrete vector field.

    Critical cells are those not paired by the vector field:
        c₀ = |V| - numVEPairs (critical vertices)
        c₁ = |E| - numVEPairs - numEFPairs (critical edges)
        c₂ = |F| - numEFPairs (critical faces)

    The Poincaré-Hopf theorem guarantees: c₀ - c₁ + c₂ = χ.

    Args:
        n_vertices, n_edges, n_faces: Cell counts
        num_VE_pairs: Number of vertex-edge pairings
        num_EF_pairs: Number of edge-face pairings

    Returns:
        Dictionary with critical cell counts and verification.

    Time complexity: O(1)
    Space complexity: O(1)

    Example:
        >>> result = compute_critical_cells(4, 6, 4, 3, 3)
        >>> result['c0'] - result['c1'] + result['c2']
        2
    """
    assert num_VE_pairs <= n_vertices
    assert num_VE_pairs + num_EF_pairs <= n_edges
    assert num_EF_pairs <= n_faces

    c0 = n_vertices - num_VE_pairs
    c1 = n_edges - num_VE_pairs - num_EF_pairs
    c2 = n_faces - num_EF_pairs
    chi = n_vertices - n_edges + n_faces

    return {
        'c0': c0, 'c1': c1, 'c2': c2,
        'alternating_sum': c0 - c1 + c2,
        'euler_char': chi,
        'verified': c0 - c1 + c2 == chi,
    }


# ============================================================
# Algorithm 4: Subdivision Invariance Check
# ============================================================

def apply_subdivision(
    V: int, E: int, F: int, move: str
) -> Tuple[int, int, int]:
    """Apply a subdivision move and return new cell counts.

    Args:
        V, E, F: Current cell counts
        move: One of 'edge_split', 'face_split', 'stellar', 'vertex_insertion'

    Returns:
        (new_V, new_E, new_F)

    Time complexity: O(1)
    """
    deltas = {
        'edge_split': (1, 1, 0),
        'face_split': (0, 1, 1),
        'stellar': (1, 3, 2),
        'vertex_insertion': (1, 3, 2),
    }
    dV, dE, dF = deltas[move]
    return V + dV, E + dE, F + dF


def verify_subdivision_invariance(
    V: int, E: int, F: int, moves: List[str]
) -> Dict[str, object]:
    """Verify Euler characteristic is preserved through a sequence of moves.

    Args:
        V, E, F: Initial cell counts
        moves: List of move names

    Returns:
        Dictionary with trace of (V, E, F, χ) at each step.
    """
    chi_0 = V - E + F
    trace = [{'V': V, 'E': E, 'F': F, 'chi': chi_0, 'move': 'initial'}]

    for move in moves:
        V, E, F = apply_subdivision(V, E, F, move)
        chi = V - E + F
        trace.append({'V': V, 'E': E, 'F': F, 'chi': chi, 'move': move})

    all_same = all(t['chi'] == chi_0 for t in trace)
    return {'trace': trace, 'invariant': all_same, 'chi': chi_0}


# ============================================================
# Algorithm 5: Curvature-Based Topology Detection
# ============================================================

def detect_topology(
    n_vertices: int, n_edges: int, n_faces: int,
    faces: List[Tuple[int, int, int]],
    angles: List[Tuple[float, float, float]]
) -> Dict[str, object]:
    """Detect the topology of a triangulated surface from curvature data.

    Uses:
    1. Euler characteristic χ = V - E + F
    2. Total curvature ∑K(v) ≈ 2πχ (Gauss-Bonnet verification)
    3. Genus g = (2-χ)/2

    Args:
        n_vertices, n_edges, n_faces: Cell counts
        faces, angles: Triangulation data

    Returns:
        Dictionary with topological classification.
    """
    chi = compute_euler_char(n_vertices, n_edges, n_faces)
    genus = compute_genus(chi)
    K = compute_vertex_curvature(n_vertices, faces, angles)
    total_K = sum(K)

    gb_verified = abs(total_K - 2 * math.pi * chi) < 1e-8

    # Curvature statistics
    K_min = min(K)
    K_max = max(K)
    K_mean = total_K / n_vertices if n_vertices > 0 else 0
    K_var = sum((k - K_mean)**2 for k in K) / n_vertices if n_vertices > 0 else 0

    topology_name = {
        0: "Sphere (S²)",
        1: "Torus (T²)",
        2: "Double torus",
        3: "Triple torus",
    }.get(genus, f"Genus-{genus} surface" if genus is not None else "Unknown")

    return {
        'chi': chi,
        'genus': genus,
        'topology': topology_name,
        'gauss_bonnet_verified': gb_verified,
        'total_curvature': total_K,
        'curvature_stats': {
            'min': K_min, 'max': K_max,
            'mean': K_mean, 'variance': K_var,
        },
    }


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    print("=== Algorithm Examples ===\n")

    # Example 1: Euler characteristic
    print("1. Euler Characteristic:")
    for name, V, E, F in [
        ("Tetrahedron", 4, 6, 4),
        ("Cube", 8, 12, 6),
        ("Octahedron", 6, 12, 8),
        ("Torus", 7, 21, 14),
    ]:
        chi = compute_euler_char(V, E, F)
        genus = compute_genus(chi)
        print(f"  {name}: χ = {chi}, genus = {genus}")

    # Example 2: Gauss-Bonnet verification
    print("\n2. Gauss-Bonnet Verification (Regular Octahedron):")
    verts = [(1,0,0), (-1,0,0), (0,1,0), (0,-1,0), (0,0,1), (0,0,-1)]
    faces = [(0,2,4),(2,1,4),(1,3,4),(3,0,4),(0,4+1,2),(2,4+1,1),(1,4+1,3),(3,4+1,0)]
    faces = [(0,2,4),(2,1,4),(1,3,4),(3,0,4),(0,5,2),(2,5,1),(1,5,3),(3,5,0)]
    angles = compute_face_angles(verts, faces)
    result = verify_gauss_bonnet(6, 12, 8, faces, angles)
    print(f"  χ = {result['chi']}")
    print(f"  ∑K(v) = {result['total_curvature']:.8f}")
    print(f"  2πχ = {result['expected']:.8f}")
    print(f"  Verified: {result['verified']}")

    # Example 3: Forman field
    print("\n3. Poincaré-Hopf (Tetrahedron):")
    for ve, ef in [(0,0), (1,1), (3,3)]:
        result = compute_critical_cells(4, 6, 4, ve, ef)
        print(f"  VE={ve}, EF={ef}: c=({result['c0']},{result['c1']},{result['c2']}), "
              f"alt_sum={result['alternating_sum']}, χ={result['euler_char']}, "
              f"verified={result['verified']}")

    # Example 4: Subdivision invariance
    print("\n4. Subdivision Invariance:")
    result = verify_subdivision_invariance(4, 6, 4,
        ['edge_split', 'stellar', 'face_split', 'vertex_insertion'])
    for step in result['trace']:
        print(f"  {step['move']:<20}: V={step['V']}, E={step['E']}, "
              f"F={step['F']}, χ={step['chi']}")
    print(f"  Invariant: {result['invariant']}")
