"""
Algorithms for Optimal Curvature Distribution on Triangulated Surfaces.

Implements:
- CurvatureVarianceEvaluator: computes average, variance, defect vector
- GaussBonnetVerifier: verifies Gauss-Bonnet for triangulated surfaces
- EquicurvatureFeasibilityChecker: checks angle-bound realizability
- CurvatureEnergyDecomposer: demonstrates the quadratic decomposition identity

All algorithms are direct implementations of the formally verified theorems.
"""

import math
from dataclasses import dataclass, field
from typing import List, Tuple, Optional, Dict
import numpy as np


@dataclass
class CurvatureProfile:
    """A curvature assignment on a finite vertex set."""
    values: np.ndarray  # K(v) for each vertex

    @property
    def n(self) -> int:
        return len(self.values)

    @property
    def average(self) -> float:
        """Avg(K) = (1/n) Σ K(v)"""
        return np.mean(self.values)

    @property
    def variance(self) -> float:
        """Var(K) = (1/n) Σ (K(v) - Avg(K))²"""
        return np.mean((self.values - self.average) ** 2)

    @property
    def defect_vector(self) -> np.ndarray:
        """δ(v) = K(v) - Avg(K)"""
        return self.values - self.average

    @property
    def total(self) -> float:
        """Σ K(v)"""
        return np.sum(self.values)

    @property
    def is_equicurved(self) -> bool:
        """Check if all values are equal (up to numerical tolerance)."""
        return np.allclose(self.values, self.average, atol=1e-12)


@dataclass
class TriangulatedSurface:
    """A triangulated surface with angle data."""
    n_vertices: int
    n_edges: int
    n_faces: int
    genus: int
    # face_vertices[f] = (v0, v1, v2) - vertex indices for face f
    face_vertices: List[Tuple[int, int, int]]
    # face_angles[f] = (a0, a1, a2) - angles at each corner
    face_angles: List[Tuple[float, float, float]]

    @property
    def euler_characteristic(self) -> int:
        return self.n_vertices - self.n_edges + self.n_faces

    @property
    def expected_euler(self) -> int:
        return 2 - 2 * self.genus

    def vertex_curvature(self) -> CurvatureProfile:
        """Compute vertex curvature K(v) = 2π - Σ angles at v."""
        angle_sums = np.zeros(self.n_vertices)
        for f_idx, (verts, angles) in enumerate(
            zip(self.face_vertices, self.face_angles)
        ):
            for i in range(3):
                angle_sums[verts[i]] += angles[i]
        curvatures = 2 * math.pi - angle_sums
        return CurvatureProfile(curvatures)

    def vertex_degrees(self) -> np.ndarray:
        """Compute vertex degrees (number of incident face-corners)."""
        degrees = np.zeros(self.n_vertices, dtype=int)
        for verts in self.face_vertices:
            for v in verts:
                degrees[v] += 1
        return degrees

    def target_curvature(self) -> float:
        """Target curvature K* = 2π(2-2g)/n."""
        return 2 * math.pi * (2 - 2 * self.genus) / self.n_vertices

    def min_face_angle(self) -> float:
        """Minimum angle across all faces."""
        return min(a for angles in self.face_angles for a in angles)


def curvature_variance_evaluator(
    K: np.ndarray,
) -> Dict[str, object]:
    """
    Evaluate curvature statistics for a curvature profile.

    Parameters
    ----------
    K : array of curvature values

    Returns
    -------
    Dictionary with average, variance, defect vector, equicurved status.

    Complexity: O(n) time, O(n) space.
    """
    profile = CurvatureProfile(np.asarray(K, dtype=float))
    return {
        "n": profile.n,
        "total": profile.total,
        "average": profile.average,
        "variance": profile.variance,
        "defect_vector": profile.defect_vector,
        "equicurved": profile.is_equicurved,
        "defect_sum": np.sum(profile.defect_vector),  # Should be ~0
    }


def gauss_bonnet_verifier(
    surface: TriangulatedSurface, tol: float = 1e-10
) -> Dict[str, object]:
    """
    Compute vertex curvatures and verify Gauss-Bonnet.

    Parameters
    ----------
    surface : TriangulatedSurface
    tol : numerical tolerance for verification

    Returns
    -------
    Dictionary with curvatures, total, expected, verification status.

    Complexity: O(|F|) time, O(|V|) space.
    """
    profile = surface.vertex_curvature()
    expected = 2 * math.pi * surface.expected_euler
    return {
        "curvatures": profile.values,
        "total_curvature": profile.total,
        "expected_total": expected,
        "gauss_bonnet_verified": abs(profile.total - expected) < tol,
        "euler_characteristic": surface.euler_characteristic,
        "expected_euler": surface.expected_euler,
    }


def equicurvature_feasibility_checker(
    genus: int,
    n_vertices: int,
    alpha_min: float,
    degrees: np.ndarray,
) -> Dict[str, object]:
    """
    Check necessary conditions for equicurved realization.

    For each vertex with degree d(v), checks:
        K* ≤ 2π - d(v) · α_min

    Parameters
    ----------
    genus : surface genus
    n_vertices : number of vertices
    alpha_min : minimum face angle
    degrees : array of vertex degrees

    Returns
    -------
    Dictionary with feasibility status and obstruction details.

    Complexity: O(n) time.
    """
    target = 2 * math.pi * (2 - 2 * genus) / n_vertices
    obstructions = []
    for v, d in enumerate(degrees):
        upper_bound = 2 * math.pi - d * alpha_min
        if target > upper_bound + 1e-12:
            obstructions.append({
                "vertex": v,
                "degree": int(d),
                "target": target,
                "upper_bound": upper_bound,
                "gap": target - upper_bound,
            })
    return {
        "target_curvature": target,
        "alpha_min": alpha_min,
        "feasible": len(obstructions) == 0,
        "n_obstructions": len(obstructions),
        "obstructions": obstructions,
    }


def energy_decomposition_verifier(
    K: np.ndarray, t: float
) -> Dict[str, float]:
    """
    Verify the quadratic energy decomposition identity:
        Σ(K(v) - t)² = Σ(K(v) - avg)² + n·(avg - t)²

    Parameters
    ----------
    K : curvature values
    t : target value

    Returns
    -------
    Dictionary with LHS, RHS components, and verification.
    """
    K = np.asarray(K, dtype=float)
    n = len(K)
    avg = np.mean(K)

    lhs = np.sum((K - t) ** 2)
    variance_term = np.sum((K - avg) ** 2)
    penalty_term = n * (avg - t) ** 2
    rhs = variance_term + penalty_term

    return {
        "lhs": lhs,
        "variance_term": variance_term,
        "penalty_term": penalty_term,
        "rhs": rhs,
        "identity_verified": abs(lhs - rhs) < 1e-10,
        "average": avg,
        "target": t,
    }


def search_low_variance_triangulation(
    genus: int, n_vertices: int, n_samples: int = 1000
) -> Dict[str, object]:
    """
    Search for low-variance curvature profiles satisfying Gauss-Bonnet.

    Generates random curvature profiles with the correct total and
    reports the one with minimum variance.

    Parameters
    ----------
    genus : target genus
    n_vertices : number of vertices
    n_samples : number of random samples

    Returns
    -------
    Best profile found and statistics.
    """
    total = 2 * math.pi * (2 - 2 * genus)
    target = total / n_vertices

    best_variance = float("inf")
    best_profile = None
    variances = []

    for _ in range(n_samples):
        # Generate random profile with correct sum
        raw = np.random.randn(n_vertices)
        raw = raw - np.mean(raw) + target  # Shift to have correct average
        profile = CurvatureProfile(raw)

        variances.append(profile.variance)
        if profile.variance < best_variance:
            best_variance = profile.variance
            best_profile = profile

    # The theoretical optimum
    optimal = CurvatureProfile(np.full(n_vertices, target))

    return {
        "genus": genus,
        "n_vertices": n_vertices,
        "target_curvature": target,
        "best_variance": best_variance,
        "optimal_variance": optimal.variance,
        "best_is_equicurved": best_profile.is_equicurved if best_profile else False,
        "mean_variance": np.mean(variances),
        "min_variance": np.min(variances),
    }


# Example usage
if __name__ == "__main__":
    # Icosahedron example
    print("=== Curvature Variance Evaluator ===")
    K_icosahedron = np.full(12, math.pi / 3)  # Equicurved icosahedron
    result = curvature_variance_evaluator(K_icosahedron)
    for key, val in result.items():
        if isinstance(val, np.ndarray):
            print(f"  {key}: {val[:5]}... (showing first 5)")
        else:
            print(f"  {key}: {val}")

    print("\n=== Energy Decomposition Verification ===")
    K_random = np.random.randn(10) + 1.0
    for t in [0.0, 0.5, 1.0, np.mean(K_random)]:
        result = energy_decomposition_verifier(K_random, t)
        print(f"  t={t:.3f}: LHS={result['lhs']:.6f}, RHS={result['rhs']:.6f}, "
              f"verified={result['identity_verified']}")

    print("\n=== Feasibility Check ===")
    degrees = np.array([5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5])  # Icosahedron
    result = equicurvature_feasibility_checker(0, 12, math.pi / 6, degrees)
    print(f"  Target: {result['target_curvature']:.4f}")
    print(f"  Feasible: {result['feasible']}")
