#!/usr/bin/env python3
"""
Curvature Convergence Algorithms
=================================

Implements the algorithms underlying the discrete-to-smooth curvature
convergence framework:

1. Curvature pairing computation
2. Consistency error evaluation
3. Mesh refinement with convergence tracking
4. Test-function sampling error estimation
"""

import math
from typing import List, Tuple, Dict, Optional


# ─────────────────────────────────────────────────────────────
# Algorithm 1: Curvature Pairing
# ─────────────────────────────────────────────────────────────

def curvature_pairing(
    K: Dict[int, float],
    phi: Dict[int, float],
    vertices: Optional[set] = None
) -> float:
    """
    Compute the discrete curvature pairing ∑_{v ∈ V} K(v) · φ(v).

    This is the discrete analogue of the smooth integral ∫_S K · φ dA.

    Parameters
    ----------
    K : dict mapping vertex id → curvature value
    phi : dict mapping vertex id → test function value
    vertices : optional set of vertex ids (defaults to keys of K)

    Returns
    -------
    float : the pairing value

    Complexity: O(|V|)

    Example
    -------
    >>> curvature_pairing({0: 0.5, 1: -0.3}, {0: 1.0, 1: 1.0})
    0.2
    """
    verts = vertices or set(K.keys())
    return sum(K.get(v, 0.0) * phi.get(v, 0.0) for v in verts)


# ─────────────────────────────────────────────────────────────
# Algorithm 2: Consistency Error
# ─────────────────────────────────────────────────────────────

def consistency_error(
    K: Dict[int, float],
    w: Dict[int, float],
    kappa: Dict[int, float],
    vertices: Optional[set] = None
) -> float:
    """
    Compute the curvature consistency error ∑_{v ∈ V} |K(v) - κ(v)·w(v)|.

    Measures how well the discrete curvature K approximates the smooth
    curvature density κ weighted by dual-cell areas w.

    Parameters
    ----------
    K : dict mapping vertex id → discrete curvature
    w : dict mapping vertex id → dual-cell area
    kappa : dict mapping vertex id → sampled smooth curvature
    vertices : optional set of vertex ids

    Returns
    -------
    float : total consistency error (≥ 0)

    Complexity: O(|V|)
    """
    verts = vertices or set(K.keys())
    return sum(abs(K.get(v, 0.0) - kappa.get(v, 0.0) * w.get(v, 0.0))
               for v in verts)


# ─────────────────────────────────────────────────────────────
# Algorithm 3: Pairing Error Bound (Theorem 1)
# ─────────────────────────────────────────────────────────────

def pairing_error_bound(
    K: Dict[int, float],
    w: Dict[int, float],
    kappa: Dict[int, float],
    phi: Dict[int, float],
    C: float,
    vertices: Optional[set] = None
) -> Tuple[float, float]:
    """
    Compute the actual pairing error and its certified upper bound.

    By Theorem 1 (curvaturePairing_sub_le_of_bdd):
        |⟨K, φ⟩ - ⟨κ·w, φ⟩| ≤ C · consistency_error

    Parameters
    ----------
    K, w, kappa, phi : vertex data
    C : bound on |φ(v)| for all v
    vertices : optional vertex set

    Returns
    -------
    (actual_error, certified_bound) : the actual error and the bound
    """
    verts = vertices or set(K.keys())
    smooth_K = {v: kappa.get(v, 0.0) * w.get(v, 0.0) for v in verts}
    actual = abs(curvature_pairing(K, phi, verts) -
                 curvature_pairing(smooth_K, phi, verts))
    bound = C * consistency_error(K, w, kappa, verts)
    return actual, bound


# ─────────────────────────────────────────────────────────────
# Algorithm 4: Sampling Error Bound (Theorem 3)
# ─────────────────────────────────────────────────────────────

def sampling_error_bound(
    a: Dict[int, float],
    phi: Dict[int, float],
    psi: Dict[int, float],
    L: float,
    h: float,
    vertices: Optional[set] = None
) -> Tuple[float, float]:
    """
    Compute the actual sampling error and its certified bound.

    By Theorem 3 (pairing_stability_under_uniform_perturbation):
        |⟨a, φ⟩ - ⟨a, ψ⟩| ≤ (L·h) · ∑|a(v)|

    Parameters
    ----------
    a : vertex weights (e.g. curvature values)
    phi, psi : two test functions (original and sampled)
    L : Lipschitz constant bound
    h : mesh size bound

    Returns
    -------
    (actual_error, certified_bound)
    """
    verts = vertices or set(a.keys())
    actual = abs(curvature_pairing(a, phi, verts) -
                 curvature_pairing(a, psi, verts))
    total_abs = sum(abs(a.get(v, 0.0)) for v in verts)
    bound = L * h * total_abs
    return actual, bound


# ─────────────────────────────────────────────────────────────
# Algorithm 5: Sphere Mesh Generator and Convergence Tracker
# ─────────────────────────────────────────────────────────────

def normalize(v: Tuple[float, ...]) -> Tuple[float, ...]:
    n = math.sqrt(sum(x*x for x in v))
    return tuple(x/n for x in v) if n > 1e-15 else v

def icosahedron() -> Tuple[List[Tuple[float,...]], List[Tuple[int,int,int]]]:
    """Return vertices and faces of a unit icosahedron."""
    phi = (1 + math.sqrt(5)) / 2
    raw = [
        (-1, phi, 0), (1, phi, 0), (-1,-phi, 0), (1,-phi, 0),
        (0,-1, phi), (0, 1, phi), (0,-1,-phi), (0, 1,-phi),
        (phi, 0,-1), (phi, 0, 1), (-phi, 0,-1), (-phi, 0, 1),
    ]
    return [normalize(v) for v in raw], [
        (0,11,5),(0,5,1),(0,1,7),(0,7,10),(0,10,11),
        (1,5,9),(5,11,4),(11,10,2),(10,7,6),(7,1,8),
        (3,9,4),(3,4,2),(3,2,6),(3,6,8),(3,8,9),
        (4,9,5),(2,4,11),(6,2,10),(8,6,7),(9,8,1),
    ]

def subdivide_sphere(verts, faces):
    """Subdivide each triangle into 4 and project to unit sphere."""
    edge_cache = {}
    new_verts = list(verts)
    def midpt(i, j):
        key = (min(i,j), max(i,j))
        if key not in edge_cache:
            mid = normalize(tuple(0.5*(new_verts[i][k]+new_verts[j][k]) for k in range(3)))
            edge_cache[key] = len(new_verts)
            new_verts.append(mid)
        return edge_cache[key]
    new_faces = []
    for a, b, c in faces:
        ab, bc, ca = midpt(a,b), midpt(b,c), midpt(c,a)
        new_faces.extend([(a,ab,ca),(b,bc,ab),(c,ca,bc),(ab,bc,ca)])
    return new_verts, new_faces

def compute_mesh_curvature(verts, faces):
    """Compute angle defect and dual areas for a triangulated surface."""
    nv = len(verts)
    angle_sum = [0.0] * nv
    dual_area = [0.0] * nv
    for a, b, c in faces:
        for v0, v1, v2 in [(a,b,c),(b,c,a),(c,a,b)]:
            e1 = tuple(verts[v1][k]-verts[v0][k] for k in range(3))
            e2 = tuple(verts[v2][k]-verts[v0][k] for k in range(3))
            n1 = math.sqrt(sum(x*x for x in e1))
            n2 = math.sqrt(sum(x*x for x in e2))
            if n1 > 1e-15 and n2 > 1e-15:
                cos_a = max(-1.0, min(1.0, sum(e1[k]*e2[k] for k in range(3))/(n1*n2)))
                angle_sum[v0] += math.acos(cos_a)
        cx = tuple(
            (verts[b][k]-verts[a][k]) for k in range(3))
        cy = tuple(
            (verts[c][k]-verts[a][k]) for k in range(3))
        cr = (cx[1]*cy[2]-cx[2]*cy[1], cx[2]*cy[0]-cx[0]*cy[2], cx[0]*cy[1]-cx[1]*cy[0])
        fa = 0.5 * math.sqrt(sum(x*x for x in cr))
        dual_area[a] += fa/3; dual_area[b] += fa/3; dual_area[c] += fa/3
    K = {v: 2*math.pi - angle_sum[v] for v in range(nv)}
    w = {v: dual_area[v] for v in range(nv)}
    edges = set()
    for a, b, c in faces:
        edges.update([(min(a,b),max(a,b)),(min(b,c),max(b,c)),(min(a,c),max(a,c))])
    mesh_h = max(math.sqrt(sum((verts[i][k]-verts[j][k])**2 for k in range(3)))
                 for i, j in edges)
    return K, w, mesh_h

def convergence_analysis(max_level: int = 5) -> List[Dict]:
    """
    Run full convergence analysis on icosahedral sphere subdivisions.

    Returns a list of dicts with convergence data at each level.

    Complexity: O(4^level) per level (number of faces quadruples)
    """
    verts, faces = icosahedron()
    results = []
    kappa_const = 1.0  # sphere: κ ≡ 1

    for level in range(max_level + 1):
        K, w, mesh_h = compute_mesh_curvature(verts, faces)
        nv = len(verts)
        kappa = {v: kappa_const for v in range(nv)}
        phi_one = {v: 1.0 for v in range(nv)}

        total_K = sum(K.values())
        total_area = sum(w.values())
        cons_err = consistency_error(K, w, kappa)
        actual_err, bound = pairing_error_bound(K, w, kappa, phi_one, 1.0)

        results.append({
            'level': level,
            'n_verts': nv,
            'n_faces': len(faces),
            'mesh_h': mesh_h,
            'total_K': total_K,
            'total_area': total_area,
            'consistency_error': cons_err,
            'pairing_error': actual_err,
            'pairing_bound': bound,
        })

        if level < max_level:
            verts, faces = subdivide_sphere(verts, faces)

    return results


# ─────────────────────────────────────────────────────────────
# Example usage
# ─────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Curvature Convergence Analysis")
    print("=" * 60)
    results = convergence_analysis(5)
    four_pi = 4 * math.pi

    for r in results:
        print(f"Level {r['level']}: V={r['n_verts']:>6}, h={r['mesh_h']:.6f}, "
              f"∑K={r['total_K']:.8f}, err={r['consistency_error']:.6f}")

    print(f"\n4π = {four_pi:.10f}")
    print(f"Final ∑K = {results[-1]['total_K']:.10f}")
    print(f"Final consistency error = {results[-1]['consistency_error']:.8f}")

    # Verify Theorem 1 bound
    print("\nTheorem 1 verification (|actual| ≤ bound):")
    for r in results:
        ok = "✓" if r['pairing_error'] <= r['pairing_bound'] + 1e-12 else "✗"
        print(f"  Level {r['level']}: actual={r['pairing_error']:.2e}, "
              f"bound={r['pairing_bound']:.2e} {ok}")
