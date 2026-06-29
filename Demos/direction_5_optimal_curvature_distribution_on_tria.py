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


"""
Demo: Optimal Curvature Distribution on Triangulated Surfaces

Demonstrates the formally verified theorems:
1. Quadratic energy decomposition identity
2. Variance-zero iff equicurved
3. Topological curvature determination via Gauss-Bonnet
4. Angle-bound realizability obstructions
5. Curvature energy minimization

Tests sphere cases (n=4,6,12,42,80), torus cases (n=7,14,20,30),
and genus-2 cases (n=10,20,30).
"""

import math
import numpy as np


# ============================================================
# Core definitions (self-contained, no local imports)
# ============================================================

def curvature_average(K):
    """Avg(K) = (1/n) Σ K(v)"""
    return np.mean(K)


def curvature_variance(K):
    """Var(K) = (1/n) Σ (K(v) - Avg(K))²"""
    return np.mean((K - curvature_average(K)) ** 2)


def curvature_energy(K, t):
    """E_t(K) = Σ (K(v) - t)²"""
    return np.sum((K - t) ** 2)


def target_curvature(genus, n):
    """K* = 2π(2-2g)/n"""
    return 2 * math.pi * (2 - 2 * genus) / n


def is_equicurved(K, tol=1e-12):
    """Check if all values are equal."""
    return np.allclose(K, curvature_average(K), atol=tol)


def defect_vector(K):
    """δ(v) = K(v) - Avg(K)"""
    return K - curvature_average(K)


# ============================================================
# Demo 1: Quadratic Decomposition Identity
# ============================================================

def demo_decomposition_identity():
    print("=" * 70)
    print("DEMO 1: Quadratic Energy Decomposition Identity")
    print("  Σ(K(v)-t)² = Σ(K(v)-avg)² + n·(avg-t)²")
    print("=" * 70)

    np.random.seed(42)
    for name, K in [
        ("Uniform (n=6)", np.full(6, 2*math.pi/3)),
        ("Random (n=10)", np.random.randn(10) + 1.0),
        ("Sparse (n=8)", np.array([3, 0, 0, 0, 0, 0, 0, 1.0]) * math.pi / 2),
    ]:
        n = len(K)
        avg = curvature_average(K)
        print(f"\n  {name}: avg = {avg:.4f}")
        print(f"  {'t':<10} {'LHS':<15} {'Var term':<15} {'Penalty':<15} {'Match?'}")
        print(f"  {'-'*60}")

        for t in [0.0, 0.5, avg, 1.0, 2.0]:
            lhs = curvature_energy(K, t)
            var_term = curvature_energy(K, avg)
            penalty = n * (avg - t) ** 2
            rhs = var_term + penalty
            match = abs(lhs - rhs) < 1e-10
            marker = " ← min" if abs(t - avg) < 1e-10 else ""
            print(f"  {t:<10.4f} {lhs:<15.6f} {var_term:<15.6f} "
                  f"{penalty:<15.6f} {'✓' if match else '✗'}{marker}")


# ============================================================
# Demo 2: Variance-Zero Characterization
# ============================================================

def demo_variance_zero():
    print("\n" + "=" * 70)
    print("DEMO 2: Variance = 0 ⟺ Equicurved")
    print("=" * 70)

    cases = [
        ("Constant K=π/3", np.full(12, math.pi / 3)),
        ("Nearly constant", np.full(12, math.pi / 3) + 1e-15 * np.random.randn(12)),
        ("Slightly perturbed", np.full(12, math.pi / 3) + np.array(
            [0.1, -0.1, 0.05, -0.05, 0, 0, 0.02, -0.02, 0, 0, 0, 0])),
        ("Two-valued", np.array([1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0.0])),
    ]

    print(f"\n  {'Profile':<25} {'Variance':<15} {'Equicurved?':<12} {'Theorem confirms?'}")
    print(f"  {'-'*65}")

    for name, K in cases:
        var = curvature_variance(K)
        equi = is_equicurved(K)
        # Theorem: var=0 iff equicurved
        theorem_ok = (var < 1e-20) == equi
        print(f"  {name:<25} {var:<15.2e} {'Yes' if equi else 'No':<12} "
              f"{'✓' if theorem_ok else '✗'}")


# ============================================================
# Demo 3: Sphere Triangulations
# ============================================================

def demo_spheres():
    print("\n" + "=" * 70)
    print("DEMO 3: Sphere Triangulations (genus 0, total K = 4π)")
    print("=" * 70)

    print(f"\n  Gauss-Bonnet: Σ K(v) = 2π·χ = 2π·2 = 4π ≈ {4*math.pi:.4f}")
    print(f"\n  {'Surface':<25} {'n':<6} {'K*':<12} {'Σ K(v)':<12} "
          f"{'Variance':<12} {'Equicurved?'}")
    print(f"  {'-'*75}")

    sphere_cases = [
        ("Tetrahedron", 4),
        ("Octahedron", 6),
        ("Icosahedron", 12),
        ("Subdivided icosahedron", 42),
        ("Fine sphere mesh", 80),
    ]

    for name, n in sphere_cases:
        K_star = target_curvature(0, n)
        K = np.full(n, K_star)  # Ideal equicurved profile
        total = np.sum(K)
        var = curvature_variance(K)
        equi = is_equicurved(K)
        print(f"  {name:<25} {n:<6} {K_star:<12.6f} {total:<12.6f} "
              f"{var:<12.2e} {'Yes' if equi else 'No'}")

    # Non-equicurved sphere
    print(f"\n  --- Non-equicurved sphere examples ---")
    n = 12
    K_nonuniform = np.array([
        0.8, 1.2, 0.5, 1.5, 0.9, 1.1, 0.7, 1.3, 0.6, 1.4, 1.0, 1.0
    ])
    K_nonuniform = K_nonuniform * 4 * math.pi / np.sum(K_nonuniform)
    var = curvature_variance(K_nonuniform)
    print(f"  {'Irregular (n=12)':<25} {12:<6} {'varies':<12} "
          f"{np.sum(K_nonuniform):<12.6f} {var:<12.6f} {'No'}")


# ============================================================
# Demo 4: Torus Triangulations
# ============================================================

def demo_tori():
    print("\n" + "=" * 70)
    print("DEMO 4: Torus Triangulations (genus 1, total K = 0)")
    print("=" * 70)

    print(f"\n  Gauss-Bonnet: Σ K(v) = 2π·χ = 2π·0 = 0")
    print(f"  Target curvature: K* = 0 for all n")
    print(f"\n  {'Surface':<25} {'n':<6} {'K*':<12} {'Σ K(v)':<12} "
          f"{'Variance':<12} {'Equicurved?'}")
    print(f"  {'-'*75}")

    torus_cases = [
        ("Minimal torus (7V)", 7),
        ("Torus (14V)", 14),
        ("Torus (20V)", 20),
        ("Torus (30V)", 30),
    ]

    for name, n in torus_cases:
        K_star = target_curvature(1, n)  # = 0
        K = np.full(n, K_star)
        total = np.sum(K)
        var = curvature_variance(K)
        equi = is_equicurved(K)
        print(f"  {name:<25} {n:<6} {K_star:<12.6f} {total:<12.6f} "
              f"{var:<12.2e} {'Yes' if equi else 'No'}")

    # Non-flat torus
    print(f"\n  --- Non-equicurved torus example ---")
    n = 14
    K_torus = np.zeros(n)
    K_torus[:7] = 0.5  # Positive curvature on outer rim
    K_torus[7:] = -0.5  # Negative curvature on inner rim
    var = curvature_variance(K_torus)
    print(f"  {'Bumpy torus (14V)':<25} {14:<6} {'varies':<12} "
          f"{np.sum(K_torus):<12.6f} {var:<12.6f} {'No'}")


# ============================================================
# Demo 5: Genus-2 Surfaces
# ============================================================

def demo_genus2():
    print("\n" + "=" * 70)
    print("DEMO 5: Genus-2 Surface Triangulations (total K = -4π)")
    print("=" * 70)

    print(f"\n  Gauss-Bonnet: Σ K(v) = 2π·χ = 2π·(-2) = -4π ≈ {-4*math.pi:.4f}")
    print(f"\n  {'Surface':<25} {'n':<6} {'K*':<12} {'Σ K(v)':<12} "
          f"{'Variance':<12} {'Equicurved?'}")
    print(f"  {'-'*75}")

    g2_cases = [
        ("Genus-2 (10V)", 10),
        ("Genus-2 (20V)", 20),
        ("Genus-2 (30V)", 30),
    ]

    for name, n in g2_cases:
        K_star = target_curvature(2, n)
        K = np.full(n, K_star)
        total = np.sum(K)
        var = curvature_variance(K)
        equi = is_equicurved(K)
        print(f"  {name:<25} {n:<6} {K_star:<12.6f} {total:<12.6f} "
              f"{var:<12.2e} {'Yes' if equi else 'No'}")


# ============================================================
# Demo 6: Defect Vector and Sum
# ============================================================

def demo_defect_vector():
    print("\n" + "=" * 70)
    print("DEMO 6: Curvature Defect Vector (Σ δ(v) = 0)")
    print("=" * 70)

    np.random.seed(123)
    n = 10
    total = 4 * math.pi
    K = np.random.exponential(1, n)
    K = K * total / np.sum(K)  # Satisfy Gauss-Bonnet

    delta = defect_vector(K)
    print(f"\n  Sphere with n={n}, Σ K = {np.sum(K):.6f} ≈ 4π = {4*math.pi:.6f}")
    print(f"\n  {'v':<5} {'K(v)':<12} {'δ(v)':<12}")
    print(f"  {'-'*30}")
    for i in range(n):
        print(f"  {i:<5} {K[i]:<12.6f} {delta[i]:<+12.6f}")
    print(f"  {'-'*30}")
    print(f"  {'Sum':<5} {np.sum(K):<12.6f} {np.sum(delta):<+12.2e}")
    print(f"\n  → Defect sum = {np.sum(delta):.2e} ≈ 0 ✓ (Theorem: defect_sum_vanishes)")


# ============================================================
# Demo 7: Angle Lower Bound Feasibility
# ============================================================

def demo_angle_bounds():
    print("\n" + "=" * 70)
    print("DEMO 7: Angle Lower Bound Feasibility")
    print("  K* ≤ 2π - d(v)·α_min for equicurved realization")
    print("=" * 70)

    for genus, name in [(0, "Sphere"), (1, "Torus"), (2, "Genus-2")]:
        print(f"\n  --- {name} (genus {genus}) ---")
        for n in [12, 20, 50]:
            K_star = target_curvature(genus, n)
            print(f"\n    n={n}, K* = {K_star:.4f}")

            for alpha_deg, alpha in [(15, math.pi/12), (30, math.pi/6),
                                      (45, math.pi/4), (60, math.pi/3)]:
                # Max degree for feasibility
                if alpha > 0 and K_star <= 2 * math.pi:
                    max_d = (2 * math.pi - K_star) / alpha
                elif K_star > 2 * math.pi:
                    max_d = 0
                else:
                    max_d = float("inf")

                typical_d = 6  # Typical for large triangulations
                feasible = typical_d <= max_d
                print(f"      α_min = {alpha_deg}°: max degree ≤ {max_d:.1f}, "
                      f"typical d=6 → {'✓ Feasible' if feasible else '✗ Infeasible'}")


# ============================================================
# Demo 8: Energy Minimizer Uniqueness
# ============================================================

def demo_energy_minimizer():
    print("\n" + "=" * 70)
    print("DEMO 8: Unique Energy Minimizer (Theorem: curvatureEnergy_strict_min)")
    print("=" * 70)

    np.random.seed(7)
    K = np.random.randn(8) + 2.0
    K = K * 4 * math.pi / np.sum(K)  # Gauss-Bonnet
    avg = curvature_average(K)
    E_avg = curvature_energy(K, avg)

    print(f"\n  Profile: n=8, avg = {avg:.4f}")
    print(f"  Energy at avg: E_avg = {E_avg:.6f}")
    print(f"\n  {'t':<12} {'E_t(K)':<15} {'E_t - E_avg':<15} {'Strictly larger?'}")
    print(f"  {'-'*55}")

    for t in np.linspace(avg - 2, avg + 2, 21):
        E_t = curvature_energy(K, t)
        diff = E_t - E_avg
        larger = diff > 1e-12
        marker = " ← MINIMUM" if abs(t - avg) < 0.05 else ""
        print(f"  {t:<12.4f} {E_t:<15.6f} {diff:<15.6f} "
              f"{'Yes' if larger else 'No (min)'}{marker}")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    demo_decomposition_identity()
    demo_variance_zero()
    demo_spheres()
    demo_tori()
    demo_genus2()
    demo_defect_vector()
    demo_angle_bounds()
    demo_energy_minimizer()

    print("\n" + "=" * 70)
    print("ALL DEMOS COMPLETE")
    print("=" * 70)
    print("""
Summary of verified theorems demonstrated:
  1. sq_dist_decomposition_to_constant — Energy decomposition identity
  2. curvatureVariance_eq_zero_iff     — Variance = 0 ⟺ Equicurved
  3. equicurved_curvature_value        — Equicurved → K(v) = 2π(2-2g)/n
  4. defect_sum_vanishes               — Σ δ(v) = 0
  5. necessary_condition               — Angle bound → degree constraint
  6. curvatureEnergy_strict_min        — Unique energy minimizer at average
  7. surface_curvatureVariance_nonneg  — Variance ≥ 0
""")
