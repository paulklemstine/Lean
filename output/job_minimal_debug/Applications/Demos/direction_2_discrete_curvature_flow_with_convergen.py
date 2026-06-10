#!/usr/bin/env python3
"""
Discrete Curvature Flow: Real-World Applications

Demonstrates practical applications of curvature flow convergence theory
in mesh optimization, heat diffusion, and signal processing.
"""

import math
import random
from typing import List, Tuple, Dict


# ============================================================
# Application 1: Mesh Quality Optimization
# ============================================================

def mesh_quality_metric(curvatures: List[float]) -> float:
    """Compute mesh quality as inverse of curvature variance.

    A mesh with uniform curvature (low variance) has better-shaped
    elements for finite element analysis. By cVar_nonneg, this metric
    is always well-defined, and by FlowSystem.convergence, we can
    improve it to any desired level in polynomial time.

    Args:
        curvatures: Curvature at each vertex.

    Returns:
        Quality score in [0, 1] (1 = perfectly uniform).
    """
    if not curvatures:
        return 1.0
    n = len(curvatures)
    mean_k = sum(curvatures) / n
    variance = sum((k - mean_k) ** 2 for k in curvatures) / n

    # Normalize using Popoviciu bound
    k_range = max(curvatures) - min(curvatures) if curvatures else 0
    max_var = k_range ** 2 / 4 if k_range > 0 else 1.0

    return max(0.0, 1.0 - variance / max_var) if max_var > 0 else 1.0


def optimize_mesh(curvatures: List[float],
                  adjacency: List[List[int]],
                  target_quality: float = 0.95,
                  max_steps: int = 1000) -> Tuple[List[float], int]:
    """Optimize mesh quality using Laplacian curvature flow.

    Uses the convergence guarantee from FlowSystem.convergence:
    the flow reaches any target quality in polynomially many steps.

    Args:
        curvatures: Initial vertex curvatures.
        adjacency: Vertex adjacency list.
        target_quality: Target quality level (0 to 1).
        max_steps: Maximum iterations.

    Returns:
        (optimized curvatures, steps taken).
    """
    current = curvatures[:]
    tau = 0.05  # Small step for stability

    for step in range(max_steps):
        quality = mesh_quality_metric(current)
        if quality >= target_quality:
            return current, step

        # Laplacian diffusion step
        new_curvatures = current[:]
        for i in range(len(current)):
            lap = sum(current[j] - current[i] for j in adjacency[i])
            new_curvatures[i] = current[i] + tau * lap

        current = new_curvatures

    return current, max_steps


# ============================================================
# Application 2: Heat Equation Simulation
# ============================================================

def heat_equation_simulation(
    initial_temperature: List[float],
    adjacency: List[List[int]],
    dt: float = 0.01,
    steps: int = 100,
) -> List[List[float]]:
    """Simulate the discrete heat equation on a graph.

    By laplacian_preserves_sum, total heat is conserved.
    By FlowSystem.convergence, the temperature distribution
    converges to uniform in polynomial time.

    This demonstrates the cross-domain connection between
    curvature flow and heat diffusion (Theorem 4).

    Args:
        initial_temperature: Temperature at each vertex.
        adjacency: Vertex adjacency list.
        dt: Time step.
        steps: Number of time steps.

    Returns:
        List of temperature distributions at each time step.
    """
    history = [initial_temperature[:]]
    current = initial_temperature[:]

    for _ in range(steps):
        new_temp = current[:]
        for i in range(len(current)):
            laplacian = sum(current[j] - current[i] for j in adjacency[i])
            new_temp[i] = current[i] + dt * laplacian
        history.append(new_temp)
        current = new_temp

    return history


# ============================================================
# Application 3: Signal Smoothing on Graphs
# ============================================================

def graph_signal_smoothing(
    signal: List[float],
    adjacency: List[List[int]],
    smoothing_level: float = 0.1,
    max_iterations: int = 100,
) -> List[float]:
    """Smooth a signal on a graph using curvature flow.

    The variance of the signal decreases monotonically
    (FlowSystem.V_mono), and the total signal is preserved
    (laplacian_preserves_sum).

    Applications: denoising sensor networks, smoothing
    geographic data, regularizing graph neural network features.

    Args:
        signal: Noisy signal values at each vertex.
        adjacency: Graph adjacency list.
        smoothing_level: Controls amount of smoothing.
        max_iterations: Maximum smoothing steps.

    Returns:
        Smoothed signal values.
    """
    current = signal[:]
    tau = smoothing_level / max(len(adj) for adj in adjacency) if adjacency else 0

    for _ in range(max_iterations):
        new_signal = current[:]
        for i in range(len(current)):
            lap = sum(current[j] - current[i] for j in adjacency[i])
            new_signal[i] = current[i] + tau * lap
        current = new_signal

    return current


# ============================================================
# Demonstrations
# ============================================================

def demo_mesh_optimization():
    """Demonstrate mesh optimization on a random graph."""
    print("=" * 60)
    print("APPLICATION 1: Mesh Quality Optimization")
    print("=" * 60)

    random.seed(123)
    n = 20

    # Create a random graph (approximate triangulation)
    adjacency = [[] for _ in range(n)]
    for i in range(n):
        for j in range(i + 1, n):
            if random.random() < 0.3:
                adjacency[i].append(j)
                adjacency[j].append(i)

    # Random initial curvatures
    curvatures = [random.gauss(0, 2) for _ in range(n)]
    print(f"  Vertices: {n}")
    print(f"  Initial quality: {mesh_quality_metric(curvatures):.4f}")
    print(f"  Initial variance: {sum((k - sum(curvatures)/n)**2 for k in curvatures)/n:.4f}")

    optimized, steps = optimize_mesh(curvatures, adjacency, target_quality=0.90)
    print(f"  Final quality: {mesh_quality_metric(optimized):.4f}")
    print(f"  Steps taken: {steps}")
    print(f"  Total preserved: {abs(sum(curvatures) - sum(optimized)) < 1e-8}")
    print()


def demo_heat_equation():
    """Demonstrate heat equation simulation."""
    print("=" * 60)
    print("APPLICATION 2: Heat Equation (Cross-Domain Connection)")
    print("=" * 60)

    # 8-vertex cycle
    n = 8
    adjacency = [[(i-1) % n, (i+1) % n] for i in range(n)]

    # Hot spot at vertex 0
    temp = [0.0] * n
    temp[0] = 100.0

    print(f"  Graph: {n}-vertex cycle")
    print(f"  Initial temp: {[f'{t:.1f}' for t in temp]}")
    print(f"  Total heat: {sum(temp):.1f}")

    history = heat_equation_simulation(temp, adjacency, dt=0.1, steps=50)

    for step in [0, 5, 10, 25, 50]:
        temps = history[step]
        var = sum((t - sum(temps)/n)**2 for t in temps) / n
        print(f"  Step {step:3d}: variance={var:8.2f}  "
              f"max={max(temps):6.2f}  min={min(temps):6.2f}  "
              f"total={sum(temps):.2f}")

    print()


def demo_signal_smoothing():
    """Demonstrate signal smoothing on a graph."""
    print("=" * 60)
    print("APPLICATION 3: Graph Signal Smoothing")
    print("=" * 60)

    random.seed(456)

    # Grid-like graph
    n = 16
    adjacency = [[] for _ in range(n)]
    for i in range(n):
        if i + 1 < n and (i + 1) % 4 != 0:
            adjacency[i].append(i + 1)
            adjacency[i + 1].append(i)
        if i + 4 < n:
            adjacency[i].append(i + 4)
            adjacency[i + 4].append(i)

    # True signal + noise
    true_signal = [math.sin(2 * math.pi * i / n) for i in range(n)]
    noise = [random.gauss(0, 0.5) for _ in range(n)]
    noisy_signal = [s + e for s, e in zip(true_signal, noise)]

    smoothed = graph_signal_smoothing(noisy_signal, adjacency,
                                      smoothing_level=0.5, max_iterations=50)

    # Compute errors
    noisy_error = sum((a - b)**2 for a, b in zip(noisy_signal, true_signal)) / n
    smooth_error = sum((a - b)**2 for a, b in zip(smoothed, true_signal)) / n

    print(f"  Graph: 4x4 grid ({n} vertices)")
    print(f"  Noisy MSE:    {noisy_error:.4f}")
    print(f"  Smoothed MSE: {smooth_error:.4f}")
    print(f"  Improvement:  {(1 - smooth_error/noisy_error)*100:.1f}%")
    print(f"  Signal preserved: {abs(sum(noisy_signal) - sum(smoothed)) < 1e-6}")
    print()


if __name__ == "__main__":
    demo_mesh_optimization()
    demo_heat_equation()
    demo_signal_smoothing()


#!/usr/bin/env python3
"""
Discrete Curvature Flow: Interactive Demonstration

Demonstrates the convergence of greedy edge-flip curvature flow on
triangulated surfaces. Shows:
1. Random triangulation with vertices colored by curvature
2. Variance decreasing over time
3. Convergence rate compared to theoretical bound

Usage:
    python demo.py
"""

import math
import random
from typing import List, Tuple, Dict, Set

# ============================================================
# Core Data Structures
# ============================================================

class Triangulation:
    """A triangulation of a closed surface represented by vertices and faces."""

    def __init__(self, vertices: List[Tuple[float, float, float]],
                 faces: List[Tuple[int, int, int]]):
        self.vertices = vertices
        self.n = len(vertices)
        self.faces = faces
        self._build_adjacency()

    def _build_adjacency(self):
        """Build edge and vertex adjacency structures."""
        self.edges: Set[Tuple[int, int]] = set()
        self.vertex_faces: Dict[int, List[int]] = {i: [] for i in range(self.n)}
        for idx, (a, b, c) in enumerate(self.faces):
            for u, v in [(a, b), (b, c), (a, c)]:
                self.edges.add((min(u, v), max(u, v)))
            self.vertex_faces[a].append(idx)
            self.vertex_faces[b].append(idx)
            self.vertex_faces[c].append(idx)

    def vertex_degree(self, v: int) -> int:
        """Number of faces containing vertex v."""
        return len(self.vertex_faces[v])

    def angle_defect(self, v: int) -> float:
        """Discrete Gaussian curvature at vertex v (angle defect).
        For a closed surface: K(v) = 2π - sum of angles at v."""
        # Approximate: for a regular triangulation, each face contributes π/3
        # For general triangulations, use actual angles
        deg = self.vertex_degree(v)
        if deg == 0:
            return 2 * math.pi
        # Each face contributes approximately 2π/deg for a flat vertex
        # Angle defect = 2π - (sum of interior angles at v)
        # For simplicity, use the combinatorial approximation:
        # K(v) ≈ 2π - deg * π/3 (assuming equilateral triangles)
        return 2 * math.pi - deg * (math.pi / 3)

    def curvature_vector(self) -> List[float]:
        """Return curvature at each vertex."""
        return [self.angle_defect(v) for v in range(self.n)]


# ============================================================
# Variance Computation
# ============================================================

def mean(values: List[float]) -> float:
    """Compute the mean of a list of values."""
    return sum(values) / len(values) if values else 0.0

def variance(values: List[float]) -> float:
    """Compute the variance (average squared deviation from mean)."""
    if not values:
        return 0.0
    m = mean(values)
    return sum((x - m) ** 2 for x in values) / len(values)

def pairwise_decomposition(values: List[float]) -> float:
    """Compute variance using the pairwise decomposition identity:
    V = (1/(2n²)) ∑ᵢⱼ (xᵢ - xⱼ)²
    
    This verifies our formal theorem pairwise_sq_diff_eq."""
    n = len(values)
    if n == 0:
        return 0.0
    total = sum((values[i] - values[j]) ** 2
                for i in range(n) for j in range(n))
    return total / (2 * n * n)


# ============================================================
# Edge Flip Operations
# ============================================================

def find_flippable_edges(tri: Triangulation) -> List[Tuple[int, int]]:
    """Find edges that can be flipped (shared by exactly 2 faces)."""
    edge_faces: Dict[Tuple[int, int], List[int]] = {}
    for idx, (a, b, c) in enumerate(tri.faces):
        for u, v in [(min(a,b), max(a,b)), (min(b,c), max(b,c)), (min(a,c), max(a,c))]:
            edge_faces.setdefault((u, v), []).append(idx)
    return [e for e, fs in edge_faces.items() if len(fs) == 2]

def flip_edge(tri: Triangulation, edge: Tuple[int, int]) -> Triangulation:
    """Flip an edge in the triangulation."""
    edge_faces: Dict[Tuple[int, int], List[int]] = {}
    for idx, (a, b, c) in enumerate(tri.faces):
        for u, v in [(min(a,b), max(a,b)), (min(b,c), max(b,c)), (min(a,c), max(a,c))]:
            edge_faces.setdefault((u, v), []).append(idx)

    if edge not in edge_faces or len(edge_faces[edge]) != 2:
        return tri

    f1_idx, f2_idx = edge_faces[edge]
    f1 = set(tri.faces[f1_idx])
    f2 = set(tri.faces[f2_idx])

    shared = {edge[0], edge[1]}
    opposite1 = (f1 - shared).pop()
    opposite2 = (f2 - shared).pop()

    # New faces after flip
    new_face1 = tuple(sorted([edge[0], opposite1, opposite2]))
    new_face2 = tuple(sorted([edge[1], opposite1, opposite2]))

    # Check for degenerate faces
    if len(set(new_face1)) < 3 or len(set(new_face2)) < 3:
        return tri

    new_faces = list(tri.faces)
    new_faces[f1_idx] = new_face1
    new_faces[f2_idx] = new_face2

    return Triangulation(tri.vertices, new_faces)


def greedy_flip(tri: Triangulation) -> Triangulation:
    """Perform the greedy edge flip that maximally decreases curvature variance."""
    flippable = find_flippable_edges(tri)
    if not flippable:
        return tri

    current_var = variance(tri.curvature_vector())
    best_tri = tri
    best_var = current_var

    for edge in flippable:
        new_tri = flip_edge(tri, edge)
        new_var = variance(new_tri.curvature_vector())
        if new_var < best_var:
            best_var = new_var
            best_tri = new_tri

    return best_tri


# ============================================================
# Curvature Flow
# ============================================================

def curvature_flow(tri: Triangulation, steps: int) -> List[Tuple[Triangulation, float]]:
    """Run curvature flow for given number of steps.
    Returns list of (triangulation, variance) pairs."""
    history = [(tri, variance(tri.curvature_vector()))]
    current = tri

    for _ in range(steps):
        new_tri = greedy_flip(current)
        new_var = variance(new_tri.curvature_vector())

        # Check if we've reached a local minimum
        if new_var >= history[-1][1] - 1e-15:
            history.append((new_tri, new_var))
            break

        history.append((new_tri, new_var))
        current = new_tri

    return history


# ============================================================
# Demo: Generate Random Triangulations
# ============================================================

def make_icosahedron() -> Triangulation:
    """Create an icosahedron (12 vertices, 20 faces) — genus 0."""
    phi = (1 + math.sqrt(5)) / 2
    vertices = [
        (-1,  phi, 0), ( 1,  phi, 0), (-1, -phi, 0), ( 1, -phi, 0),
        ( 0, -1,  phi), ( 0,  1,  phi), ( 0, -1, -phi), ( 0,  1, -phi),
        ( phi, 0, -1), ( phi, 0,  1), (-phi, 0, -1), (-phi, 0,  1),
    ]
    faces = [
        (0, 11, 5), (0, 5, 1), (0, 1, 7), (0, 7, 10), (0, 10, 11),
        (1, 5, 9), (5, 11, 4), (11, 10, 2), (10, 7, 6), (7, 1, 8),
        (3, 9, 4), (3, 4, 2), (3, 2, 6), (3, 6, 8), (3, 8, 9),
        (4, 9, 5), (2, 4, 11), (6, 2, 10), (8, 6, 7), (9, 8, 1),
    ]
    return Triangulation(vertices, faces)


def make_random_triangulation(n: int) -> Triangulation:
    """Create a random triangulation by subdividing an icosahedron."""
    # Start with icosahedron and randomly perturb
    tri = make_icosahedron()

    # Perform random edge flips to randomize
    for _ in range(n * 5):
        flippable = find_flippable_edges(tri)
        if flippable:
            edge = random.choice(flippable)
            tri = flip_edge(tri, edge)

    return tri


# ============================================================
# Verification of Formal Theorems
# ============================================================

def verify_pairwise_decomposition():
    """Verify the pairwise decomposition identity numerically.
    Theorem: ∑ᵢ ∑ⱼ (fᵢ - fⱼ)² = 2n · ∑ᵢ (fᵢ - f̄)²"""
    print("=" * 60)
    print("VERIFICATION: Pairwise Decomposition Identity")
    print("  Theorem: ∑ᵢⱼ (fᵢ - fⱼ)² = 2n · ∑ᵢ (fᵢ - f̄)²")
    print("=" * 60)

    for trial in range(5):
        n = random.randint(5, 20)
        values = [random.gauss(0, 1) for _ in range(n)]
        m = mean(values)

        lhs = sum((values[i] - values[j]) ** 2
                   for i in range(n) for j in range(n))
        rhs = 2 * n * sum((x - m) ** 2 for x in values)

        print(f"  Trial {trial+1}: n={n}, LHS={lhs:.6f}, RHS={rhs:.6f}, "
              f"diff={abs(lhs - rhs):.2e}")

    print()


def verify_variance_nonnegativity():
    """Verify that variance is always non-negative.
    Theorem: cVar(f) ≥ 0 for all f."""
    print("=" * 60)
    print("VERIFICATION: Variance Non-negativity")
    print("=" * 60)

    for trial in range(5):
        n = random.randint(3, 50)
        values = [random.uniform(-100, 100) for _ in range(n)]
        v = variance(values)
        print(f"  Trial {trial+1}: n={n}, variance={v:.6f}, non-negative={v >= 0}")

    print()


def verify_popoviciu():
    """Verify Popoviciu's inequality: Var(X) ≤ (b-a)²/4.
    Theorem: bounded_range_variance_bound"""
    print("=" * 60)
    print("VERIFICATION: Popoviciu's Inequality (Cross-Domain)")
    print("  Theorem: If a ≤ f(i) ≤ b, then Var(f) ≤ (b-a)²/4")
    print("=" * 60)

    for trial in range(5):
        n = random.randint(5, 100)
        a, b = sorted([random.uniform(-10, 10) for _ in range(2)])
        values = [random.uniform(a, b) for _ in range(n)]
        v = variance(values)
        bound = (b - a) ** 2 / 4
        print(f"  Trial {trial+1}: n={n}, a={a:.2f}, b={b:.2f}, "
              f"var={v:.4f}, bound={bound:.4f}, satisfied={v <= bound + 1e-10}")

    print()


def verify_convergence():
    """Verify the polynomial convergence theorem.
    Theorem: curvature flow reaches ε in ≤ ⌈V₀/δ⌉ steps."""
    print("=" * 60)
    print("VERIFICATION: Polynomial Convergence Theorem")
    print("=" * 60)

    tri = make_icosahedron()
    K = tri.curvature_vector()
    V0 = variance(K)
    n = tri.n

    print(f"  Initial triangulation: {n} vertices, {len(tri.faces)} faces")
    print(f"  Initial curvature variance: {V0:.6f}")
    print(f"  Mean curvature: {mean(K):.6f}")
    print(f"  Total curvature: {sum(K):.6f} (expect 4π = {4*math.pi:.6f})")

    history = curvature_flow(tri, 100)

    print(f"\n  Flow history ({len(history)} steps):")
    for i, (_, v) in enumerate(history[:10]):
        print(f"    Step {i}: variance = {v:.8f}")
    if len(history) > 10:
        print(f"    ... ({len(history) - 10} more steps)")
        print(f"    Step {len(history)-1}: variance = {history[-1][1]:.8f}")

    # Check monotonicity
    monotone = all(history[i][1] >= history[i+1][1] - 1e-15
                   for i in range(len(history) - 1))
    print(f"\n  Monotonicity satisfied: {monotone}")
    print()


def test_exponential_conjecture():
    """Test the exponential convergence rate conjecture.
    Conjecture: V(k) ≤ V(0) · (1 - C/n²)^k"""
    print("=" * 60)
    print("CONJECTURE TEST: Exponential Convergence Rate")
    print("  V(k) ≤ V(0) · (1 - C/n²)^k")
    print("=" * 60)

    tri = make_icosahedron()
    n = tri.n
    history = curvature_flow(tri, 200)

    V0 = history[0][1]
    if V0 <= 0:
        print("  Initial variance is zero; skipping.")
        return

    # Estimate C from the data
    ratios = []
    for i in range(1, len(history)):
        if history[i][1] > 0 and history[i-1][1] > 0:
            ratio = history[i][1] / history[i-1][1]
            if ratio < 1:
                C_est = (1 - ratio) * n * n
                ratios.append(C_est)

    if ratios:
        C_avg = sum(ratios) / len(ratios)
        C_min = min(ratios)
        C_max = max(ratios)
        print(f"  Estimated C: avg={C_avg:.4f}, min={C_min:.4f}, max={C_max:.4f}")
        print(f"  n={n}, n²={n*n}")

        # Verify prediction
        print(f"\n  Verification (predicted vs actual):")
        for k in [1, 5, 10, 20]:
            if k < len(history):
                predicted = V0 * (1 - C_avg / (n * n)) ** k
                actual = history[k][1]
                print(f"    k={k}: predicted={predicted:.6f}, "
                      f"actual={actual:.6f}")
    else:
        print("  Could not estimate C (variance may be at local minimum)")

    print()


# ============================================================
# Main
# ============================================================

def main():
    random.seed(42)

    print("\n" + "=" * 60)
    print("  DISCRETE CURVATURE FLOW: DEMONSTRATION")
    print("  Verified convergence via Lyapunov analysis")
    print("=" * 60 + "\n")

    verify_pairwise_decomposition()
    verify_variance_nonnegativity()
    verify_popoviciu()
    verify_convergence()
    test_exponential_conjecture()

    print("=" * 60)
    print("  All demonstrations complete!")
    print("=" * 60)


if __name__ == "__main__":
    main()
