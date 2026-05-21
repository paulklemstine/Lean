"""
Applications of the Curvature Variance Theory.

Demonstrates real-world applications of the formally verified theorems:
1. Mesh quality assessment for computer graphics
2. Finite element mesh optimization guidance
3. Equicurvature feasibility analysis for surface design
4. Curvature energy landscape visualization
"""

import math
import numpy as np
from algorithms import (
    CurvatureProfile,
    TriangulatedSurface,
    curvature_variance_evaluator,
    gauss_bonnet_verifier,
    equicurvature_feasibility_checker,
    energy_decomposition_verifier,
)


def application_1_mesh_quality_assessment():
    """
    Application: Mesh Quality Assessment for Computer Graphics

    Compare curvature variance across different triangulations of
    the same topological surface. Lower variance = more uniform
    curvature distribution = better mesh quality.
    """
    print("=" * 70)
    print("APPLICATION 1: Mesh Quality Assessment")
    print("=" * 70)

    # Simulate different sphere triangulations
    print("\nComparing sphere triangulations (genus 0, χ = 2):")
    print(f"{'Mesh':<25} {'Vertices':<10} {'Target K*':<12} {'Variance':<12} {'Quality'}")
    print("-" * 70)

    for name, n, curvatures in [
        ("Tetrahedron", 4, np.full(4, math.pi)),
        ("Octahedron", 6, np.full(6, 2 * math.pi / 3)),
        ("Icosahedron", 12, np.full(12, math.pi / 3)),
        ("Perturbed icosahedron", 12,
         np.array([math.pi/3 + 0.1*np.sin(i) for i in range(12)])),
        ("Highly irregular", 12,
         np.array([math.pi, 0, math.pi, 0, math.pi, 0,
                    math.pi/3, math.pi/3, math.pi/3, math.pi/3, 0, 0])),
    ]:
        # Adjust to satisfy Gauss-Bonnet: total = 4π
        curvatures = curvatures - (np.sum(curvatures) - 4 * math.pi) / n
        profile = CurvatureProfile(curvatures)
        quality = "★★★★★" if profile.variance < 1e-10 else \
                  "★★★★" if profile.variance < 0.01 else \
                  "★★★" if profile.variance < 0.1 else \
                  "★★" if profile.variance < 1.0 else "★"
        print(f"{name:<25} {n:<10} {profile.average:<12.4f} "
              f"{profile.variance:<12.6f} {quality}")

    print("\n→ The equicurved triangulations (tetrahedron, octahedron, icosahedron)")
    print("  achieve zero variance — they are optimal mesh quality.")


def application_2_finite_element_guidance():
    """
    Application: Finite Element Mesh Optimization Guidance

    Given a mesh with known curvature profile, compute:
    1. How far it is from optimal (variance)
    2. Which vertices need the most correction (defect vector)
    3. The energy improvement possible by balancing
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Finite Element Mesh Optimization")
    print("=" * 70)

    # Simulate a mesh with non-uniform curvature
    n = 20
    np.random.seed(42)
    target = 4 * math.pi / n
    K = target + 0.5 * np.random.randn(n)
    K = K - (np.sum(K) - 4 * math.pi) / n  # Enforce Gauss-Bonnet

    profile = CurvatureProfile(K)
    print(f"\nMesh: sphere with {n} vertices")
    print(f"Target curvature per vertex: {target:.4f}")
    print(f"Current variance: {profile.variance:.6f}")
    print(f"Current energy at target: {np.sum((K - target)**2):.6f}")
    print(f"Optimal energy (at avg): {np.sum((K - profile.average)**2):.6f}")

    # Identify worst vertices
    defect = profile.defect_vector
    worst_indices = np.argsort(np.abs(defect))[::-1][:5]
    print(f"\nTop 5 vertices needing correction:")
    print(f"{'Vertex':<10} {'K(v)':<12} {'Defect':<12} {'|Defect|':<12}")
    print("-" * 46)
    for idx in worst_indices:
        print(f"{idx:<10} {K[idx]:<12.4f} {defect[idx]:<12.4f} "
              f"{abs(defect[idx]):<12.4f}")

    # Decomposition identity verification
    result = energy_decomposition_verifier(K, target)
    print(f"\nEnergy decomposition at target t = {target:.4f}:")
    print(f"  Total energy:   {result['lhs']:.6f}")
    print(f"  Variance term:  {result['variance_term']:.6f}")
    print(f"  Penalty term:   {result['penalty_term']:.6f}")
    print(f"  Identity holds: {result['identity_verified']}")


def application_3_equicurvature_feasibility():
    """
    Application: Equicurvature Feasibility for Surface Design

    For various surface types and angle bounds, determine whether
    equicurvature is geometrically realizable.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Equicurvature Feasibility Analysis")
    print("=" * 70)

    alpha_min_values = [math.pi / 12, math.pi / 6, math.pi / 4, math.pi / 3]
    alpha_names = ["15°", "30°", "45°", "60°"]

    for genus, genus_name in [(0, "Sphere"), (1, "Torus"), (2, "Genus-2")]:
        print(f"\n--- {genus_name} (genus {genus}) ---")
        target = 2 * math.pi * (2 - 2 * genus)
        print(f"Total curvature budget: {target:.4f} ({target/math.pi:.2f}π)")

        for n in [10, 20, 50, 100]:
            if n == 0:
                continue
            K_star = target / n
            print(f"\n  n = {n}, K* = {K_star:.4f}:")

            for alpha, alpha_name in zip(alpha_min_values, alpha_names):
                # Compute max allowed degree
                if alpha > 0:
                    if K_star <= 2 * math.pi:
                        max_degree = int((2 * math.pi - K_star) / alpha)
                    else:
                        max_degree = 0
                else:
                    max_degree = float("inf")

                # Typical degree for a triangulation: ~6 for large n
                typical_degree = 6
                degrees = np.full(n, typical_degree)
                result = equicurvature_feasibility_checker(
                    genus, n, alpha, degrees
                )
                status = "✓ Feasible" if result["feasible"] else "✗ Infeasible"
                print(f"    α_min = {alpha_name}: max d = {max_degree}, "
                      f"typical d = {typical_degree} → {status}")


def application_4_energy_landscape():
    """
    Application: Curvature Energy Landscape Visualization

    Show how the energy E_t(K) varies as a function of the target t,
    confirming the unique minimum at t = avg(K).
    """
    print("\n" + "=" * 70)
    print("APPLICATION 4: Curvature Energy Landscape")
    print("=" * 70)

    # Create a non-uniform curvature profile on a sphere
    n = 12
    K = np.array([
        0.8, 1.2, 0.5, 1.5, 0.9, 1.1,
        0.7, 1.3, 0.6, 1.4, 1.0, 1.0
    ])
    K = K * 4 * math.pi / np.sum(K)  # Normalize to satisfy Gauss-Bonnet

    avg = np.mean(K)
    print(f"\nCurvature profile (n={n}):")
    print(f"  Values: {np.round(K, 4)}")
    print(f"  Average: {avg:.4f}")
    print(f"  Variance: {np.var(K):.6f}")

    print(f"\nEnergy E_t(K) = Σ(K(v) - t)² at various targets:")
    print(f"{'t':<10} {'E_t(K)':<15} {'Var term':<15} {'Penalty':<15} {'Ratio'}")
    print("-" * 65)

    min_energy = np.sum((K - avg) ** 2)
    for t in np.linspace(avg - 1.0, avg + 1.0, 11):
        result = energy_decomposition_verifier(K, t)
        ratio = result["lhs"] / min_energy if min_energy > 0 else float("inf")
        marker = " ← MINIMUM" if abs(t - avg) < 0.01 else ""
        print(f"{t:<10.4f} {result['lhs']:<15.6f} {result['variance_term']:<15.6f} "
              f"{result['penalty_term']:<15.6f} {ratio:<8.4f}{marker}")

    print(f"\n→ The minimum energy {min_energy:.6f} is achieved uniquely at t = {avg:.4f}")
    print(f"  Any deviation increases energy by exactly n·(avg - t)²")


if __name__ == "__main__":
    application_1_mesh_quality_assessment()
    application_2_finite_element_guidance()
    application_3_equicurvature_feasibility()
    application_4_energy_landscape()
