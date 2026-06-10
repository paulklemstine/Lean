#!/usr/bin/env python3
"""
Applications of Discrete Gauss-Bonnet and Euler Characteristic.

Demonstrates real-world applications in mesh processing, topology detection,
Regge calculus, and curvature analysis.
"""

import math
from typing import List, Tuple, Dict


# ============================================================
# Application 1: Mesh Quality and Topology Validation
# ============================================================

def validate_mesh_topology(
    vertices: List[Tuple[float, float, float]],
    faces: List[Tuple[int, int, int]],
    expected_genus: int = 0
) -> Dict[str, object]:
    """Validate mesh topology using Euler characteristic and Gauss-Bonnet.

    This is a practical mesh quality check used in computer graphics
    and CAD software. A mesh with topological errors (missing faces,
    extra edges, non-manifold vertices) will fail this check.

    Args:
        vertices: Mesh vertex coordinates
        faces: Triangle faces as vertex index triples
        expected_genus: Expected topological genus

    Returns:
        Validation report dictionary.
    """
    n_V = len(vertices)

    # Compute edges
    edge_set = set()
    edge_face_count = {}
    for f in faces:
        for i in range(3):
            e = tuple(sorted((f[i], f[(i + 1) % 3])))
            edge_set.add(e)
            edge_face_count[e] = edge_face_count.get(e, 0) + 1

    n_E = len(edge_set)
    n_F = len(faces)
    chi = n_V - n_E + n_F
    expected_chi = 2 - 2 * expected_genus

    # Check manifold condition: each edge should be shared by exactly 2 faces
    boundary_edges = [e for e, c in edge_face_count.items() if c == 1]
    non_manifold_edges = [e for e, c in edge_face_count.items() if c > 2]
    is_closed = len(boundary_edges) == 0
    is_manifold = len(non_manifold_edges) == 0

    # Check closure condition: 3|F| = 2|E| for closed surfaces
    closure_satisfied = 3 * n_F == 2 * n_E

    # Compute total curvature
    angle_sum_at_vertex = [0.0] * n_V
    for f in faces:
        v0, v1, v2 = [vertices[i] for i in f]
        for i, (vi, vj, vk) in enumerate([(v0,v1,v2), (v1,v0,v2), (v2,v0,v1)]):
            d1 = tuple(a - b for a, b in zip(vj, vi))
            d2 = tuple(a - b for a, b in zip(vk, vi))
            dot = sum(a * b for a, b in zip(d1, d2))
            n1 = math.sqrt(sum(a**2 for a in d1))
            n2 = math.sqrt(sum(a**2 for a in d2))
            cos_a = max(-1.0, min(1.0, dot / (n1 * n2 + 1e-30)))
            angle_sum_at_vertex[f[i]] += math.acos(cos_a)

    curvatures = [2 * math.pi - s for s in angle_sum_at_vertex]
    total_K = sum(curvatures)
    gauss_bonnet_error = abs(total_K - 2 * math.pi * chi)

    return {
        'V': n_V, 'E': n_E, 'F': n_F,
        'chi': chi,
        'expected_chi': expected_chi,
        'chi_correct': chi == expected_chi,
        'is_closed': is_closed,
        'is_manifold': is_manifold,
        'closure_3F_eq_2E': closure_satisfied,
        'boundary_edges': len(boundary_edges),
        'non_manifold_edges': len(non_manifold_edges),
        'total_curvature': total_K,
        'gauss_bonnet_error': gauss_bonnet_error,
        'gauss_bonnet_verified': gauss_bonnet_error < 1e-8,
        'topology_valid': (chi == expected_chi and is_closed and is_manifold),
    }


# ============================================================
# Application 2: Curvature-Based Shape Recognition
# ============================================================

def classify_surface_shape(
    vertices: List[Tuple[float, float, float]],
    faces: List[Tuple[int, int, int]]
) -> str:
    """Classify a triangulated surface by its curvature properties.

    Uses the Euler characteristic and curvature distribution to
    determine the topological type and geometric character.

    Returns a human-readable classification string.
    """
    result = validate_mesh_topology(vertices, faces)
    chi = result['chi']

    if not result['is_closed']:
        return "Open surface (has boundary)"

    genus = (2 - chi) // 2 if (2 - chi) % 2 == 0 else None

    if genus is None:
        return f"Non-orientable surface (χ = {chi})"

    # Analyze curvature distribution
    angle_sum_at_vertex = [0.0] * len(vertices)
    for f in faces:
        v_coords = [vertices[i] for i in f]
        for i in range(3):
            vi = v_coords[i]
            vj = v_coords[(i+1) % 3]
            vk = v_coords[(i+2) % 3]
            d1 = tuple(a - b for a, b in zip(vj, vi))
            d2 = tuple(a - b for a, b in zip(vk, vi))
            dot = sum(a * b for a, b in zip(d1, d2))
            n1 = math.sqrt(sum(a**2 for a in d1))
            n2 = math.sqrt(sum(a**2 for a in d2))
            cos_a = max(-1.0, min(1.0, dot / (n1 * n2 + 1e-30)))
            angle_sum_at_vertex[f[i]] += math.acos(cos_a)

    K = [2 * math.pi - s for s in angle_sum_at_vertex]
    K_min, K_max = min(K), max(K)

    if genus == 0:
        if K_min > 0:
            return f"Convex sphere-like surface (all K > 0, χ = {chi})"
        else:
            return f"Non-convex sphere-like surface (χ = {chi})"
    elif genus == 1:
        return f"Torus-like surface (genus 1, χ = {chi})"
    else:
        return f"High-genus surface (genus {genus}, χ = {chi})"


# ============================================================
# Application 3: Regge Calculus — Curvature on Simplicial Spacetime
# ============================================================

def regge_action_2d(
    vertices: List[Tuple[float, float, float]],
    faces: List[Tuple[int, int, int]]
) -> Dict[str, float]:
    """Compute the 2D Regge action (Einstein-Hilbert action for
    piecewise-flat 2D gravity).

    In 2D Regge calculus, the action is proportional to the total
    angle defect, which by Gauss-Bonnet equals 2πχ. This means
    the 2D Einstein-Hilbert action is purely topological.

    S = (1/8πG) ∑_v ε_v · A_v

    where ε_v = 2π - ∑θ is the deficit angle and A_v is the dual area.
    For simplicity, we compute ∑ ε_v (total deficit), which by
    Gauss-Bonnet equals 2πχ.

    Returns:
        Dictionary with Regge calculus quantities.
    """
    n_V = len(vertices)

    angle_sum = [0.0] * n_V
    for f in faces:
        v_coords = [vertices[i] for i in f]
        for i in range(3):
            vi, vj, vk = v_coords[i], v_coords[(i+1)%3], v_coords[(i+2)%3]
            d1 = tuple(a - b for a, b in zip(vj, vi))
            d2 = tuple(a - b for a, b in zip(vk, vi))
            dot = sum(a*b for a, b in zip(d1, d2))
            n1 = math.sqrt(sum(a**2 for a in d1))
            n2 = math.sqrt(sum(a**2 for a in d2))
            cos_a = max(-1.0, min(1.0, dot / (n1*n2 + 1e-30)))
            angle_sum[f[i]] += math.acos(cos_a)

    deficits = [2 * math.pi - s for s in angle_sum]
    total_deficit = sum(deficits)

    # Dual area: 1/3 of the total area of incident faces
    face_areas = []
    for f in faces:
        v0, v1, v2 = [vertices[i] for i in f]
        e1 = tuple(a - b for a, b in zip(v1, v0))
        e2 = tuple(a - b for a, b in zip(v2, v0))
        cross = (
            e1[1]*e2[2] - e1[2]*e2[1],
            e1[2]*e2[0] - e1[0]*e2[2],
            e1[0]*e2[1] - e1[1]*e2[0]
        )
        face_areas.append(0.5 * math.sqrt(sum(c**2 for c in cross)))

    dual_areas = [0.0] * n_V
    for fi, f in enumerate(faces):
        for vi in f:
            dual_areas[vi] += face_areas[fi] / 3.0

    # Weighted action: ∑ ε_v * A_v
    weighted_action = sum(d * a for d, a in zip(deficits, dual_areas))
    total_area = sum(face_areas)

    edges = set()
    for f in faces:
        for i in range(3):
            edges.add(tuple(sorted((f[i], f[(i+1)%3]))))
    chi = n_V - len(edges) + len(faces)

    return {
        'total_deficit_angle': total_deficit,
        'expected_from_topology': 2 * math.pi * chi,
        'topological': abs(total_deficit - 2 * math.pi * chi) < 1e-8,
        'total_area': total_area,
        'weighted_action': weighted_action,
        'euler_characteristic': chi,
    }


# ============================================================
# Application 4: Curvature Flow Analysis
# ============================================================

def curvature_flow_step(
    vertices: List[List[float]],
    faces: List[Tuple[int, int, int]],
    dt: float = 0.01
) -> List[List[float]]:
    """Perform one step of discrete mean curvature flow.

    Moves each vertex in the direction of the mean curvature normal,
    which tends to smooth the surface. The Gauss-Bonnet theorem
    guarantees that the total curvature is preserved (since topology
    doesn't change).

    This is a simplified Laplacian smoothing that approximates
    mean curvature flow.

    Args:
        vertices: Mutable list of [x, y, z] coordinates
        faces: Triangle faces
        dt: Time step

    Returns:
        Updated vertex positions.
    """
    n_V = len(vertices)

    # Build adjacency
    neighbors: Dict[int, set] = {i: set() for i in range(n_V)}
    for f in faces:
        for i in range(3):
            neighbors[f[i]].add(f[(i+1)%3])
            neighbors[f[i]].add(f[(i+2)%3])

    # Laplacian smoothing (approximates mean curvature flow)
    new_vertices = [list(v) for v in vertices]
    for i in range(n_V):
        if not neighbors[i]:
            continue
        nbrs = list(neighbors[i])
        centroid = [
            sum(vertices[j][k] for j in nbrs) / len(nbrs)
            for k in range(3)
        ]
        for k in range(3):
            new_vertices[i][k] += dt * (centroid[k] - vertices[i][k])

    return new_vertices


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    print("=== Application Examples ===\n")

    # Application 1: Mesh validation
    print("1. Mesh Topology Validation")
    print("-" * 40)

    # Valid tetrahedron
    verts = [(1,0,-1/math.sqrt(2)), (-1,0,-1/math.sqrt(2)),
             (0,1,1/math.sqrt(2)), (0,-1,1/math.sqrt(2))]
    faces = [(0,1,2), (0,1,3), (0,2,3), (1,2,3)]
    result = validate_mesh_topology(verts, faces, expected_genus=0)
    print(f"  Tetrahedron: topology_valid={result['topology_valid']}, "
          f"χ={result['chi']}, GB_verified={result['gauss_bonnet_verified']}")

    # Octahedron
    verts2 = [(1,0,0), (-1,0,0), (0,1,0), (0,-1,0), (0,0,1), (0,0,-1)]
    faces2 = [(0,2,4),(2,1,4),(1,3,4),(3,0,4),(0,5,2),(2,5,1),(1,5,3),(3,5,0)]
    result2 = validate_mesh_topology(verts2, faces2, expected_genus=0)
    print(f"  Octahedron: topology_valid={result2['topology_valid']}, "
          f"χ={result2['chi']}, GB_verified={result2['gauss_bonnet_verified']}")

    # Application 2: Shape classification
    print("\n2. Surface Classification")
    print("-" * 40)
    print(f"  Tetrahedron: {classify_surface_shape(verts, faces)}")
    print(f"  Octahedron: {classify_surface_shape(verts2, faces2)}")

    # Application 3: Regge calculus
    print("\n3. Regge Calculus (2D Gravity)")
    print("-" * 40)
    regge = regge_action_2d(verts2, faces2)
    print(f"  Octahedron:")
    print(f"    Total deficit angle: {regge['total_deficit_angle']:.6f}")
    print(f"    2πχ: {regge['expected_from_topology']:.6f}")
    print(f"    Topological (match): {regge['topological']}")
    print(f"    Total area: {regge['total_area']:.6f}")

    # Application 4: Curvature flow
    print("\n4. Curvature Flow (3 steps on tetrahedron)")
    print("-" * 40)
    current = [list(v) for v in verts]
    for step in range(3):
        # Compute curvature before flow
        angle_sums = [0.0] * 4
        for f in faces:
            vc = [current[i] for i in f]
            for i in range(3):
                vi, vj, vk = vc[i], vc[(i+1)%3], vc[(i+2)%3]
                d1 = [a-b for a,b in zip(vj,vi)]
                d2 = [a-b for a,b in zip(vk,vi)]
                dot = sum(a*b for a,b in zip(d1,d2))
                n1 = math.sqrt(sum(a**2 for a in d1))
                n2 = math.sqrt(sum(a**2 for a in d2))
                cos_a = max(-1.0, min(1.0, dot/(n1*n2+1e-30)))
                angle_sums[f[i]] += math.acos(cos_a)
        total_K = sum(2*math.pi - s for s in angle_sums)
        print(f"  Step {step}: total curvature = {total_K:.6f} "
              f"(should be 4π ≈ {4*math.pi:.6f})")
        current = curvature_flow_step(current, faces, dt=0.05)

    print("\n  (Total curvature preserved by Gauss-Bonnet!)")


#!/usr/bin/env python3
"""
Demonstration of Discrete Gauss-Bonnet, Euler Characteristic, and Poincare-Hopf.

This script provides interactive demonstrations of the theorems formalized
in Geometry/DiscreteGaussBonnet.lean, with concrete numerical examples.
"""

import math
from typing import List, Tuple, Dict, Optional

# ============================================================
# Core Data Structures
# ============================================================

class TriangulatedSurface:
    """A triangulated surface with vertices, edges, faces, and angle data."""

    def __init__(self, name: str, vertices: List[Tuple[float, float, float]],
                 faces: List[Tuple[int, int, int]],
                 angles: Optional[List[Tuple[float, float, float]]] = None):
        self.name = name
        self.vertices = vertices
        self.faces = faces
        self.edges = self._compute_edges()
        if angles is not None:
            self.angles = angles
        else:
            self.angles = self._compute_angles_from_coords()

    def _compute_edges(self) -> List[Tuple[int, int]]:
        edge_set = set()
        for f in self.faces:
            for i in range(3):
                e = tuple(sorted((f[i], f[(i + 1) % 3])))
                edge_set.add(e)
        return sorted(edge_set)

    def _compute_angles_from_coords(self) -> List[Tuple[float, float, float]]:
        """Compute face angles from vertex coordinates using the law of cosines."""
        angles = []
        for f in self.faces:
            v0 = self.vertices[f[0]]
            v1 = self.vertices[f[1]]
            v2 = self.vertices[f[2]]
            a = self._angle_at(v0, v1, v2)
            b = self._angle_at(v1, v0, v2)
            c = self._angle_at(v2, v0, v1)
            angles.append((a, b, c))
        return angles

    @staticmethod
    def _angle_at(vertex, p1, p2) -> float:
        """Angle at 'vertex' in triangle (vertex, p1, p2)."""
        d1 = [p1[i] - vertex[i] for i in range(3)]
        d2 = [p2[i] - vertex[i] for i in range(3)]
        dot = sum(a * b for a, b in zip(d1, d2))
        n1 = math.sqrt(sum(a**2 for a in d1))
        n2 = math.sqrt(sum(a**2 for a in d2))
        if n1 * n2 < 1e-15:
            return 0.0
        cos_angle = max(-1.0, min(1.0, dot / (n1 * n2)))
        return math.acos(cos_angle)

    @property
    def nV(self) -> int:
        return len(self.vertices)

    @property
    def nE(self) -> int:
        return len(self.edges)

    @property
    def nF(self) -> int:
        return len(self.faces)

    def euler_char(self) -> int:
        return self.nV - self.nE + self.nF

    def vertex_curvature(self, v: int) -> float:
        """Angle-defect curvature at vertex v."""
        total_angle = 0.0
        for fi, f in enumerate(self.faces):
            for i in range(3):
                if f[i] == v:
                    total_angle += self.angles[fi][i]
        return 2 * math.pi - total_angle

    def total_curvature(self) -> float:
        return sum(self.vertex_curvature(v) for v in range(self.nV))

    def verify_gauss_bonnet(self) -> Tuple[float, float, bool]:
        """Verify discrete Gauss-Bonnet: sum K(v) = 2*pi*chi."""
        total_K = self.total_curvature()
        expected = 2 * math.pi * self.euler_char()
        ok = abs(total_K - expected) < 1e-10
        return total_K, expected, ok


class FormanField:
    """A Forman discrete vector field on a cell complex."""

    def __init__(self, nV: int, nE: int, nF: int,
                 num_VE_pairs: int, num_EF_pairs: int):
        self.nV = nV
        self.nE = nE
        self.nF = nF
        self.num_VE_pairs = num_VE_pairs
        self.num_EF_pairs = num_EF_pairs
        assert num_VE_pairs <= nV
        assert num_VE_pairs + num_EF_pairs <= nE
        assert num_EF_pairs <= nF

    @property
    def critical_0(self) -> int:
        return self.nV - self.num_VE_pairs

    @property
    def critical_1(self) -> int:
        return self.nE - self.num_VE_pairs - self.num_EF_pairs

    @property
    def critical_2(self) -> int:
        return self.nF - self.num_EF_pairs

    def euler_char(self) -> int:
        return self.nV - self.nE + self.nF

    def verify_poincare_hopf(self) -> Tuple[int, int, bool]:
        """Verify: c0 - c1 + c2 = chi."""
        alt_sum = self.critical_0 - self.critical_1 + self.critical_2
        chi = self.euler_char()
        return alt_sum, chi, alt_sum == chi


# ============================================================
# Sample Triangulations
# ============================================================

def make_tetrahedron() -> TriangulatedSurface:
    """Regular tetrahedron (sphere, chi=2)."""
    s = 1.0 / math.sqrt(2)
    vertices = [(1, 0, -s), (-1, 0, -s), (0, 1, s), (0, -1, s)]
    faces = [(0, 1, 2), (0, 1, 3), (0, 2, 3), (1, 2, 3)]
    return TriangulatedSurface("Tetrahedron", vertices, faces)


def make_octahedron() -> TriangulatedSurface:
    """Regular octahedron (sphere, chi=2)."""
    vertices = [
        (1, 0, 0), (-1, 0, 0),
        (0, 1, 0), (0, -1, 0),
        (0, 0, 1), (0, 0, -1)
    ]
    faces = [
        (0, 2, 4), (2, 1, 4), (1, 3, 4), (3, 0, 4),
        (0, 5, 2), (2, 5, 1), (1, 5, 3), (3, 5, 0)
    ]
    return TriangulatedSurface("Octahedron", vertices, faces)


def make_icosahedron() -> TriangulatedSurface:
    """Regular icosahedron (sphere, chi=2)."""
    phi = (1 + math.sqrt(5)) / 2
    vertices = [
        (-1, phi, 0), (1, phi, 0), (-1, -phi, 0), (1, -phi, 0),
        (0, -1, phi), (0, 1, phi), (0, -1, -phi), (0, 1, -phi),
        (phi, 0, -1), (phi, 0, 1), (-phi, 0, -1), (-phi, 0, 1)
    ]
    faces = [
        (0, 11, 5), (0, 5, 1), (0, 1, 7), (0, 7, 10), (0, 10, 11),
        (1, 5, 9), (5, 11, 4), (11, 10, 2), (10, 7, 6), (7, 1, 8),
        (3, 9, 4), (3, 4, 2), (3, 2, 6), (3, 6, 8), (3, 8, 9),
        (4, 9, 5), (2, 4, 11), (6, 2, 10), (8, 6, 7), (9, 8, 1)
    ]
    return TriangulatedSurface("Icosahedron", vertices, faces)


def make_cube_triangulated() -> TriangulatedSurface:
    """Cube with each face triangulated (sphere, chi=2)."""
    vertices = [
        (-1, -1, -1), (1, -1, -1), (1, 1, -1), (-1, 1, -1),
        (-1, -1, 1), (1, -1, 1), (1, 1, 1), (-1, 1, 1)
    ]
    faces = [
        (0, 1, 2), (0, 2, 3),  # bottom
        (4, 6, 5), (4, 7, 6),  # top
        (0, 5, 1), (0, 4, 5),  # front
        (2, 7, 3), (2, 6, 7),  # back
        (0, 3, 7), (0, 7, 4),  # left
        (1, 5, 6), (1, 6, 2),  # right
    ]
    return TriangulatedSurface("Cube (triangulated)", vertices, faces)


def make_torus_flat() -> TriangulatedSurface:
    """Minimal flat torus triangulation with 7 vertices, 21 edges, 14 faces.
    This is the Heawood map / Möbius-Kantor triangulation of the torus.
    All angles are set to pi/3 (equilateral) for the flat torus."""
    # For a flat torus, we use abstract vertices (no embedding in R^3)
    # Coordinates are symbolic; angles are exactly pi/3
    vertices = [(i, 0, 0) for i in range(7)]  # abstract

    # Heawood triangulation of the torus (mod 7 structure)
    faces = [
        (0, 1, 3), (1, 3, 4), (1, 2, 4), (2, 4, 5),
        (2, 3, 5), (3, 5, 6), (3, 4, 6), (4, 6, 0),
        (4, 5, 0), (5, 0, 1), (5, 6, 1), (6, 1, 2),
        (6, 0, 2), (0, 2, 3)
    ]

    # Flat torus: all angles = pi/3
    angles = [(math.pi / 3, math.pi / 3, math.pi / 3)] * 14
    return TriangulatedSurface("Flat Torus (7 vertices)", vertices, faces, angles)


# ============================================================
# Main Demonstrations
# ============================================================

def demo_euler_characteristic():
    """Demonstrate Euler characteristic computation."""
    print("=" * 70)
    print("DEMO 1: Euler Characteristic V - E + F")
    print("=" * 70)
    print()

    surfaces = [
        make_tetrahedron(),
        make_octahedron(),
        make_icosahedron(),
        make_cube_triangulated(),
        make_torus_flat(),
    ]

    print(f"{'Surface':<30} {'V':>4} {'E':>4} {'F':>4} {'χ':>4} {'Genus':>6}")
    print("-" * 60)
    for s in surfaces:
        chi = s.euler_char()
        genus = (2 - chi) // 2 if chi <= 2 and (2 - chi) % 2 == 0 else "?"
        print(f"{s.name:<30} {s.nV:>4} {s.nE:>4} {s.nF:>4} {chi:>4} {genus:>6}")
    print()


def demo_gauss_bonnet():
    """Demonstrate discrete Gauss-Bonnet theorem."""
    print("=" * 70)
    print("DEMO 2: Discrete Gauss-Bonnet Theorem: ∑ K(v) = 2πχ")
    print("=" * 70)
    print()

    surfaces = [
        make_tetrahedron(),
        make_octahedron(),
        make_icosahedron(),
        make_cube_triangulated(),
        make_torus_flat(),
    ]

    for s in surfaces:
        total_K, expected, ok = s.verify_gauss_bonnet()
        chi = s.euler_char()
        status = "✓ VERIFIED" if ok else "✗ FAILED"
        print(f"{s.name}:")
        print(f"  χ = {chi}")
        print(f"  ∑ K(v) = {total_K:.10f}")
        print(f"  2πχ    = {expected:.10f}")
        print(f"  Status: {status}")

        # Show individual vertex curvatures
        curvatures = [s.vertex_curvature(v) for v in range(s.nV)]
        unique_K = sorted(set(round(k, 8) for k in curvatures))
        for k in unique_K:
            count = sum(1 for c in curvatures if abs(c - k) < 1e-6)
            print(f"  K = {k:+.6f} rad ({k * 180 / math.pi:+.3f}°) at {count} vertices")
        print()


def demo_poincare_hopf():
    """Demonstrate discrete Poincaré-Hopf theorem."""
    print("=" * 70)
    print("DEMO 3: Discrete Poincaré-Hopf: c₀ - c₁ + c₂ = χ")
    print("=" * 70)
    print()

    examples = [
        ("Tetrahedron (sphere)", 4, 6, 4, [
            (0, 0, "Trivial field: no pairings"),
            (1, 1, "One VE pair, one EF pair"),
            (3, 3, "Maximal: 3 VE + 3 EF pairs"),
        ]),
        ("Torus (7v)", 7, 21, 14, [
            (0, 0, "Trivial field"),
            (7, 14, "Perfect: all cells paired"),
            (3, 5, "Partial pairing"),
        ]),
    ]

    for name, nV, nE, nF, fields in examples:
        chi = nV - nE + nF
        print(f"{name}: V={nV}, E={nE}, F={nF}, χ={chi}")
        for ve, ef, desc in fields:
            ff = FormanField(nV, nE, nF, ve, ef)
            alt, chi_check, ok = ff.verify_poincare_hopf()
            status = "✓" if ok else "✗"
            print(f"  {desc}:")
            print(f"    VE={ve}, EF={ef} → c₀={ff.critical_0}, "
                  f"c₁={ff.critical_1}, c₂={ff.critical_2}")
            print(f"    c₀ - c₁ + c₂ = {alt} = χ = {chi_check} {status}")
        print()


def demo_genus_curvature():
    """Demonstrate the curvature-genus formula."""
    print("=" * 70)
    print("DEMO 4: Curvature-Genus Formula: ∑ K(v) = 2π(2 - 2g)")
    print("=" * 70)
    print()

    data = [
        ("Sphere (g=0)", 0, make_tetrahedron()),
        ("Torus (g=1)", 1, make_torus_flat()),
    ]

    for name, genus, s in data:
        total_K = s.total_curvature()
        expected = 2 * math.pi * (2 - 2 * genus)
        ok = abs(total_K - expected) < 1e-10
        status = "✓" if ok else "✗"
        print(f"{name}:")
        print(f"  genus = {genus}")
        print(f"  χ = 2 - 2g = {2 - 2 * genus}")
        print(f"  ∑ K(v) = {total_K:.10f}")
        print(f"  2π(2-2g) = {expected:.10f}")
        print(f"  {status}")
        print()


def demo_subdivision_invariance():
    """Demonstrate Euler characteristic invariance under subdivision."""
    print("=" * 70)
    print("DEMO 5: Subdivision Invariance")
    print("=" * 70)
    print()

    print("Starting with tetrahedron: V=4, E=6, F=4, χ=2")
    print()

    moves = [
        ("Edge split", 1, 1, 0),
        ("Face split", 0, 1, 1),
        ("Stellar subdivision", 1, 3, 2),
        ("Vertex insertion", 1, 3, 2),
    ]

    V, E, F = 4, 6, 4
    for name, dV, dE, dF in moves:
        V2, E2, F2 = V + dV, E + dE, F + dF
        chi1 = V - E + F
        chi2 = V2 - E2 + F2
        ok = chi1 == chi2
        status = "✓" if ok else "✗"
        print(f"  {name}: ({V},{E},{F}) → ({V2},{E2},{F2})")
        print(f"    χ: {chi1} → {chi2} {status}")
        V, E, F = V2, E2, F2
    print()


def demo_curvature_obstruction():
    """Demonstrate curvature obstruction for high-genus surfaces."""
    print("=" * 70)
    print("DEMO 6: Curvature Obstruction for High Genus")
    print("=" * 70)
    print()

    print("Theorem: For genus g ≥ 1, total curvature ∑ K(v) ≤ 0")
    print()

    for genus in range(4):
        chi = 2 - 2 * genus
        total_K = 2 * math.pi * chi
        sign = "positive" if total_K > 0 else ("zero" if total_K == 0 else "negative")
        print(f"  Genus {genus}: χ = {chi:>3}, "
              f"∑K(v) = 2π·{chi} = {total_K:>10.4f} ({sign})")

    print()
    print("Consequence: On a torus or higher-genus surface, positive curvature")
    print("at some vertices must be compensated by negative curvature elsewhere.")
    print()


if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║  Discrete Gauss-Bonnet, Euler Characteristic, Poincaré-Hopf    ║")
    print("║  Interactive Demonstration                                      ║")
    print("╚══════════════════════════════════════════════════════════════════╝")
    print()

    demo_euler_characteristic()
    demo_gauss_bonnet()
    demo_poincare_hopf()
    demo_genus_curvature()
    demo_subdivision_invariance()
    demo_curvature_obstruction()

    print("All demonstrations complete.")
