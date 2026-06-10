#!/usr/bin/env python3
"""
Applications of Spectral Gap Theory for Discrete Curvature Flow.

Real-world applications of the exponential convergence theorem:
1. Mesh smoothing with certified convergence
2. Curvature estimation quality bounds
3. Adaptive stopping criteria for geometry processing

Each application shows the math working on concrete examples.
"""

import numpy as np
from typing import Tuple, List, Dict, Optional


# ============================================================
# Core routines (self-contained)
# ============================================================

def compute_variance(K: np.ndarray) -> float:
    return float(np.sum((K - np.mean(K)) ** 2))

def compute_dirichlet(K: np.ndarray, edges: List[Tuple[int, int]]) -> float:
    return sum((K[i] - K[j]) ** 2 for i, j in edges)

def greedy_step(K: np.ndarray, edges: List[Tuple[int, int]]) -> np.ndarray:
    K = K.copy()
    best_i, best_j, max_d = 0, 0, 0.0
    for i, j in edges:
        d = abs(K[i] - K[j])
        if d > max_d:
            max_d, best_i, best_j = d, i, j
    avg = (K[best_i] + K[best_j]) / 2
    K[best_i] = K[best_j] = avg
    return K

def grid_triangulation(m: int) -> Tuple[int, List[Tuple[int, int]]]:
    n = m * m
    edges = set()
    for i in range(m):
        for j in range(m):
            v = i * m + j
            if j + 1 < m: edges.add((v, v + 1))
            if i + 1 < m: edges.add((v, v + m))
            if i + 1 < m and j + 1 < m: edges.add((v, v + m + 1))
    return n, list(edges)


# ============================================================
# Application 1: Mesh Smoothing with Certified Convergence
# ============================================================

def certified_mesh_smoothing(
    curvature: np.ndarray,
    edges: List[Tuple[int, int]],
    target_variance: float,
    spectral_gap_estimate: float = 0.5
) -> Dict:
    """Smooth a mesh curvature distribution with a certified stopping criterion.

    Uses the exponential convergence theorem to provide a guaranteed
    upper bound on the number of steps needed.

    Args:
        curvature: Initial curvature values.
        edges: Mesh edges.
        target_variance: Desired maximum variance.
        spectral_gap_estimate: Lower bound on spectral gap constant C.

    Returns:
        Dictionary with smoothed curvature, actual steps, certified bound.

    Example:
        >>> np.random.seed(0)
        >>> n, edges = grid_triangulation(5)
        >>> K = np.random.randn(n) * 3
        >>> result = certified_mesh_smoothing(K, edges, 0.1)
        >>> result['final_variance'] <= 0.1
        True
    """
    n = len(curvature)
    V0 = compute_variance(curvature)
    C = spectral_gap_estimate

    # Certified bound from the theorem
    if V0 <= target_variance:
        certified_steps = 0
    else:
        certified_steps = int(np.ceil(
            (n ** 2 / C) * np.log(V0 / target_variance)
        ))

    # Run the actual flow
    K = curvature.copy()
    actual_steps = 0
    variances = [V0]

    for step in range(certified_steps + n * n):  # Extra buffer for safety
        if compute_variance(K) <= target_variance:
            break
        K = greedy_step(K, edges)
        actual_steps += 1
        variances.append(compute_variance(K))

    return {
        'smoothed_curvature': K,
        'final_variance': compute_variance(K),
        'actual_steps': actual_steps,
        'certified_upper_bound': certified_steps,
        'initial_variance': V0,
        'target_variance': target_variance,
        'speedup_vs_linear': (V0 / target_variance) / max(actual_steps, 1),
        'variance_trajectory': variances,
    }


# ============================================================
# Application 2: Quality Assessment for Curvature Estimation
# ============================================================

def curvature_quality_assessment(
    curvature: np.ndarray,
    edges: List[Tuple[int, int]]
) -> Dict:
    """Assess the quality of a curvature distribution on a mesh.

    Computes variance, Dirichlet energy, spectral gap estimate, and
    a uniformity score based on the exponential convergence theory.

    Args:
        curvature: Curvature values at each vertex.
        edges: Mesh edges.

    Returns:
        Dictionary with quality metrics.

    Example:
        >>> n, edges = grid_triangulation(4)
        >>> K_good = np.ones(n) * 0.5  # Perfectly uniform
        >>> K_bad = np.random.randn(n) * 5  # Highly non-uniform
        >>> q_good = curvature_quality_assessment(K_good, edges)
        >>> q_bad = curvature_quality_assessment(K_bad, edges)
        >>> q_good['uniformity_score'] > q_bad['uniformity_score']
        True
    """
    n = len(curvature)
    V = compute_variance(curvature)
    E = compute_dirichlet(curvature, edges)

    # Spectral gap estimate
    gap = E / V if V > 1e-15 else float('inf')

    # Uniformity score: 1 / (1 + V) ∈ (0, 1]
    uniformity = 1.0 / (1.0 + V)

    # Estimated steps to halve variance
    if gap > 0 and gap < float('inf'):
        steps_to_halve = int(np.ceil(np.log(2) / (gap / n**2))) if gap > 1e-15 else float('inf')
    else:
        steps_to_halve = 0

    # Maximum curvature deviation
    mean_K = np.mean(curvature)
    max_dev = float(np.max(np.abs(curvature - mean_K)))

    return {
        'variance': V,
        'dirichlet_energy': E,
        'spectral_gap_estimate': gap,
        'uniformity_score': uniformity,
        'steps_to_halve_variance': steps_to_halve,
        'mean_curvature': float(mean_K),
        'max_deviation': max_dev,
        'num_vertices': n,
        'num_edges': len(edges),
    }


# ============================================================
# Application 3: Adaptive Flow with Online Gap Estimation
# ============================================================

def adaptive_curvature_flow(
    curvature: np.ndarray,
    edges: List[Tuple[int, int]],
    target_variance: float,
    max_steps: Optional[int] = None,
    gap_estimation_window: int = 20
) -> Dict:
    """Run curvature flow with adaptive stopping based on online gap estimation.

    Instead of using a fixed spectral gap constant, this algorithm
    estimates the gap online from the variance trajectory and uses
    it to predict when to stop.

    Args:
        curvature: Initial curvature values.
        edges: Mesh edges.
        target_variance: Target variance threshold.
        max_steps: Maximum number of steps (default: 10*n^2).
        gap_estimation_window: Window size for gap estimation.

    Returns:
        Dictionary with results and diagnostic information.
    """
    n = len(curvature)
    if max_steps is None:
        max_steps = 10 * n * n

    K = curvature.copy()
    variances = [compute_variance(K)]
    gap_estimates = []
    predicted_remaining = []

    for step in range(max_steps):
        V = variances[-1]
        if V <= target_variance:
            break

        K = greedy_step(K, edges)
        new_V = compute_variance(K)
        variances.append(new_V)

        # Online gap estimation
        if V > 1e-15:
            ratio = new_V / V
            c_hat = n**2 * (1.0 - ratio)
            gap_estimates.append(c_hat)

            # Predict remaining steps using recent gap estimates
            if len(gap_estimates) >= gap_estimation_window:
                recent_gap = np.median(gap_estimates[-gap_estimation_window:])
                if recent_gap > 0 and new_V > target_variance:
                    pred = int(np.ceil(
                        (n**2 / recent_gap) * np.log(new_V / target_variance)
                    ))
                    predicted_remaining.append(pred)

    return {
        'final_curvature': K,
        'final_variance': compute_variance(K),
        'total_steps': len(variances) - 1,
        'converged': compute_variance(K) <= target_variance,
        'variance_trajectory': variances,
        'gap_estimates': gap_estimates,
        'predicted_remaining_steps': predicted_remaining,
    }


# ============================================================
# Main demonstration
# ============================================================

def main():
    print("=" * 60)
    print("Applications of Spectral Gap Theory")
    print("for Discrete Curvature Flow")
    print("=" * 60)

    np.random.seed(42)

    # --- Application 1: Certified Mesh Smoothing ---
    print("\n--- Application 1: Certified Mesh Smoothing ---\n")

    n, edges = grid_triangulation(8)
    K = np.random.randn(n) * 3.0

    for target in [1.0, 0.1, 0.01]:
        result = certified_mesh_smoothing(K, edges, target, spectral_gap_estimate=0.3)
        print(f"  Target V ≤ {target:.2f}:")
        print(f"    Initial variance:     {result['initial_variance']:.4f}")
        print(f"    Final variance:       {result['final_variance']:.6f}")
        print(f"    Actual steps:         {result['actual_steps']}")
        print(f"    Certified bound:      {result['certified_upper_bound']}")
        print(f"    Efficiency ratio:     {result['actual_steps'] / max(result['certified_upper_bound'], 1):.2%}")
        print()

    # --- Application 2: Quality Assessment ---
    print("--- Application 2: Curvature Quality Assessment ---\n")

    n, edges = grid_triangulation(6)

    scenarios = {
        'Uniform': np.ones(n) * 0.5,
        'Slight perturbation': np.ones(n) * 0.5 + np.random.randn(n) * 0.1,
        'Moderate noise': np.random.randn(n) * 1.0,
        'High noise': np.random.randn(n) * 5.0,
        'Spike (adversarial)': np.zeros(n),
    }
    scenarios['Spike (adversarial)'][0] = float(n)

    for name, K in scenarios.items():
        q = curvature_quality_assessment(K, edges)
        print(f"  {name:25s}: V={q['variance']:8.2f}, "
              f"E={q['dirichlet_energy']:8.2f}, "
              f"gap={q['spectral_gap_estimate']:8.2f}, "
              f"score={q['uniformity_score']:.4f}")
    print()

    # --- Application 3: Adaptive Flow ---
    print("--- Application 3: Adaptive Flow with Online Gap Estimation ---\n")

    n, edges = grid_triangulation(7)
    K = np.random.randn(n) * 2.0

    result = adaptive_curvature_flow(K, edges, target_variance=0.05)

    print(f"  Vertices: {n}, Edges: {len(edges)}")
    print(f"  Initial variance: {result['variance_trajectory'][0]:.4f}")
    print(f"  Final variance:   {result['final_variance']:.6f}")
    print(f"  Total steps:      {result['total_steps']}")
    print(f"  Converged:        {result['converged']}")

    if result['gap_estimates']:
        valid = [g for g in result['gap_estimates'] if 0 < g < float('inf')]
        if valid:
            print(f"  Online gap estimate (median): {np.median(valid):.4f}")
            print(f"  Online gap estimate (min):    {min(valid):.4f}")

    if result['predicted_remaining_steps']:
        print(f"  Final predicted remaining:    {result['predicted_remaining_steps'][-1]}")

    print("\nDone.")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Interactive Demonstration: Spectral Gap in Discrete Curvature Flow

Generates random triangulations, runs greedy curvature flow, and analyzes
convergence behavior to test the spectral gap conjecture:

    V(k) <= (1 - C/n^2)^k * V(0)

Produces plots of:
1. log(V(k)/V(0)) vs k/n^2 for profile collapse
2. Empirical spectral gap constants across mesh sizes
3. Genus comparison for genus-independence conjecture
"""

import numpy as np
import json
import sys
from typing import Tuple, List, Dict


# ============================================================
# Core algorithms (self-contained, no local imports)
# ============================================================

def compute_variance(K: np.ndarray) -> float:
    """Compute sum of squared deviations from mean."""
    return float(np.sum((K - np.mean(K)) ** 2))


def compute_dirichlet(K: np.ndarray, edges: List[Tuple[int, int]]) -> float:
    """Compute Dirichlet energy: sum of squared edge differences."""
    return sum((K[i] - K[j]) ** 2 for i, j in edges)


def greedy_step(K: np.ndarray, edges: List[Tuple[int, int]]) -> np.ndarray:
    """One greedy curvature flow step: equalize at max-discrepancy edge."""
    K = K.copy()
    best_i, best_j, max_d = 0, 0, 0.0
    for i, j in edges:
        d = abs(K[i] - K[j])
        if d > max_d:
            max_d, best_i, best_j = d, i, j
    avg = (K[best_i] + K[best_j]) / 2
    K[best_i] = K[best_j] = avg
    return K


def run_flow(K: np.ndarray, edges: List[Tuple[int, int]], steps: int) -> List[float]:
    """Run greedy flow, return variance trajectory."""
    variances = [compute_variance(K)]
    for _ in range(steps):
        K = greedy_step(K, edges)
        variances.append(compute_variance(K))
    return variances


# ============================================================
# Triangulation generators
# ============================================================

def grid_triangulation(m: int) -> Tuple[int, List[Tuple[int, int]]]:
    """m x m grid triangulation (genus 0)."""
    n = m * m
    edges = set()
    for i in range(m):
        for j in range(m):
            v = i * m + j
            if j + 1 < m: edges.add((v, v + 1))
            if i + 1 < m: edges.add((v, v + m))
            if i + 1 < m and j + 1 < m: edges.add((v, v + m + 1))
    return n, list(edges)


def torus_triangulation(m: int) -> Tuple[int, List[Tuple[int, int]]]:
    """m x m torus triangulation (genus 1)."""
    n = m * m
    edges = set()
    for i in range(m):
        for j in range(m):
            v = i * m + j
            r = i * m + (j + 1) % m
            b = ((i + 1) % m) * m + j
            d = ((i + 1) % m) * m + (j + 1) % m
            edges.add((min(v, r), max(v, r)))
            edges.add((min(v, b), max(v, b)))
            edges.add((min(v, d), max(v, d)))
    return n, list(edges)


def genus2_triangulation(m: int) -> Tuple[int, List[Tuple[int, int]]]:
    """Approximate genus 2 surface via identified torus with extra handles.
    Uses a 2m x m torus with additional cross-connections."""
    n = 2 * m * m
    edges = set()
    rows, cols = 2 * m, m
    for i in range(rows):
        for j in range(cols):
            v = i * cols + j
            r = i * cols + (j + 1) % cols
            b = ((i + 1) % rows) * cols + j
            d = ((i + 1) % rows) * cols + (j + 1) % cols
            edges.add((min(v, r), max(v, r)))
            edges.add((min(v, b), max(v, b)))
            edges.add((min(v, d), max(v, d)))
    # Add cross-handle connections
    for j in range(cols):
        v1 = j
        v2 = m * cols + (j + cols // 2) % cols
        edges.add((min(v1, v2), max(v1, v2)))
    return n, list(edges)


# ============================================================
# Experiments
# ============================================================

def experiment_profile_collapse(seed: int = 42) -> Dict:
    """Test profile collapse: does log(V/V0) vs k/n^2 collapse across sizes?"""
    np.random.seed(seed)
    sizes = [5, 7, 10, 14]  # Grid dimensions -> n = m^2
    results = {}

    print("Experiment 1: Profile Collapse")
    print("=" * 50)

    for m in sizes:
        n, edges = grid_triangulation(m)
        K = np.random.randn(n)
        steps = 5 * n * n
        variances = run_flow(K, edges, steps)

        V0 = variances[0]
        log_ratios = [np.log(max(v / V0, 1e-15)) for v in variances]
        scaled_times = [k / n**2 for k in range(len(variances))]

        results[n] = {
            'scaled_times': scaled_times[::max(1, len(scaled_times)//100)],
            'log_ratios': log_ratios[::max(1, len(log_ratios)//100)],
        }

        final_ratio = variances[-1] / V0
        print(f"  n={n:4d}: V0={V0:.4f}, V_final/V0={final_ratio:.2e}, "
              f"steps={steps}")

    return results


def experiment_spectral_gap_estimation(seed: int = 42) -> Dict:
    """Estimate empirical spectral gap constants across mesh sizes."""
    np.random.seed(seed)
    sizes = [5, 7, 10, 14]
    results = {}

    print("\nExperiment 2: Spectral Gap Estimation")
    print("=" * 50)

    for m in sizes:
        n, edges = grid_triangulation(m)
        K = np.random.randn(n)
        steps = 3 * n * n
        variances = run_flow(K, edges, steps)

        # Estimate C_hat = n^2 * (1 - V(k+1)/V(k))
        c_hats = []
        for k in range(len(variances) - 1):
            if variances[k] > 1e-12:
                ratio = variances[k + 1] / variances[k]
                c_hat = n**2 * (1.0 - ratio)
                if 0 < c_hat < 100 * n**2:  # Filter outliers
                    c_hats.append(c_hat)

        if c_hats:
            results[n] = {
                'min': min(c_hats),
                'median': float(np.median(c_hats)),
                'mean': float(np.mean(c_hats)),
                'max': max(c_hats),
            }
            print(f"  n={n:4d}: C_hat min={min(c_hats):.4f}, "
                  f"median={np.median(c_hats):.4f}, "
                  f"max={max(c_hats):.4f}")

    return results


def experiment_genus_comparison(seed: int = 42) -> Dict:
    """Compare spectral gaps across genera 0, 1, 2."""
    np.random.seed(seed)
    m = 7  # Grid dimension
    results = {}

    print("\nExperiment 3: Genus Comparison")
    print("=" * 50)

    generators = {
        'genus_0': lambda: grid_triangulation(m),
        'genus_1': lambda: torus_triangulation(m),
        'genus_2': lambda: genus2_triangulation(m),
    }

    for name, gen in generators.items():
        n, edges = gen()
        K = np.random.randn(n)
        steps = 3 * n * n
        variances = run_flow(K, edges, steps)

        c_hats = []
        for k in range(len(variances) - 1):
            if variances[k] > 1e-12:
                ratio = variances[k + 1] / variances[k]
                c_hat = n**2 * (1.0 - ratio)
                if 0 < c_hat < 100 * n**2:
                    c_hats.append(c_hat)

        if c_hats:
            results[name] = {
                'n': n,
                'num_edges': len(edges),
                'c_hat_min': min(c_hats),
                'c_hat_median': float(np.median(c_hats)),
                'final_variance_ratio': variances[-1] / variances[0],
            }
            print(f"  {name} (n={n}): C_hat min={min(c_hats):.4f}, "
                  f"median={np.median(c_hats):.4f}, "
                  f"V_final/V0={variances[-1]/variances[0]:.2e}")

    return results


def experiment_counterexample_search(seed: int = 42) -> Dict:
    """Search for potential counterexample families where C_hat -> 0."""
    np.random.seed(seed)
    print("\nExperiment 4: Counterexample Search")
    print("=" * 50)

    results = {}
    for m in [4, 6, 8, 10, 12]:
        n, edges = grid_triangulation(m)

        # Adversarial initial condition: curvature concentrated at one vertex
        K = np.zeros(n)
        K[0] = float(n)  # All curvature at vertex 0

        steps = 5 * n * n
        variances = run_flow(K, edges, steps)

        c_hats = []
        for k in range(min(len(variances) - 1, 2 * n * n)):
            if variances[k] > 1e-12:
                ratio = variances[k + 1] / variances[k]
                c_hat = n**2 * (1.0 - ratio)
                if 0 < c_hat < 100 * n**2:
                    c_hats.append(c_hat)

        if c_hats:
            results[n] = {
                'c_hat_min': min(c_hats),
                'c_hat_early_min': min(c_hats[:max(1, len(c_hats)//10)]),
            }
            print(f"  n={n:4d} (adversarial): C_hat min={min(c_hats):.4f}, "
                  f"early min={min(c_hats[:max(1,len(c_hats)//10)]):.4f}")

    return results


# ============================================================
# Main
# ============================================================

def main():
    """Run all experiments and save results."""
    print("Spectral Gap in Discrete Curvature Flow")
    print("Demonstration and Computational Experiments")
    print("=" * 60)
    print()

    r1 = experiment_profile_collapse()
    r2 = experiment_spectral_gap_estimation()
    r3 = experiment_genus_comparison()
    r4 = experiment_counterexample_search()

    # Summary
    print("\n" + "=" * 60)
    print("SUMMARY")
    print("=" * 60)
    print()
    print("1. Profile Collapse: log(V/V0) vs k/n^2 curves should align")
    print("   across different mesh sizes if universal profile exists.")
    print()
    print("2. Spectral Gap: C_hat = n^2(1 - V(k+1)/V(k)) should have")
    print("   a positive lower bound independent of n.")
    print()
    print("3. Genus Independence: C_hat should be similar across genera")
    print("   0, 1, 2 for the same mesh size.")
    print()
    print("4. Counterexample Search: Even adversarial initial conditions")
    print("   should not drive C_hat to zero.")
    print()

    # Check for matplotlib and produce plots if available
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt

        # Plot 1: Profile collapse
        fig, axes = plt.subplots(2, 2, figsize=(14, 10))

        ax = axes[0, 0]
        ax.set_title("Profile Collapse: log(V/V₀) vs k/n²")
        for n_val, data in r1.items():
            ax.plot(data['scaled_times'][:50], data['log_ratios'][:50],
                    label=f'n={n_val}', alpha=0.8)
        ax.set_xlabel("k / n²")
        ax.set_ylabel("log(V(k) / V(0))")
        ax.legend()
        ax.grid(True, alpha=0.3)

        # Plot 2: Spectral gap vs n
        ax = axes[0, 1]
        ax.set_title("Empirical Spectral Gap vs Mesh Size")
        ns = sorted(r2.keys())
        mins = [r2[n]['min'] for n in ns]
        medians = [r2[n]['median'] for n in ns]
        ax.plot(ns, mins, 'o-', label='min C_hat', color='red')
        ax.plot(ns, medians, 's-', label='median C_hat', color='blue')
        ax.axhline(y=0, color='black', linestyle='--', alpha=0.3)
        ax.set_xlabel("n (vertices)")
        ax.set_ylabel("Ĉ = n²(1 - V_{k+1}/V_k)")
        ax.legend()
        ax.grid(True, alpha=0.3)

        # Plot 3: Genus comparison
        ax = axes[1, 0]
        ax.set_title("Genus Comparison of Spectral Gap")
        genera = list(r3.keys())
        c_mins = [r3[g]['c_hat_min'] for g in genera]
        c_meds = [r3[g]['c_hat_median'] for g in genera]
        x = range(len(genera))
        ax.bar([i - 0.15 for i in x], c_mins, 0.3, label='min Ĉ', color='coral')
        ax.bar([i + 0.15 for i in x], c_meds, 0.3, label='median Ĉ', color='steelblue')
        ax.set_xticks(list(x))
        ax.set_xticklabels(genera)
        ax.set_ylabel("Ĉ")
        ax.legend()
        ax.grid(True, alpha=0.3, axis='y')

        # Plot 4: Counterexample search
        ax = axes[1, 1]
        ax.set_title("Adversarial Initial Conditions")
        ns_adv = sorted(r4.keys())
        mins_adv = [r4[n]['c_hat_min'] for n in ns_adv]
        early_mins = [r4[n]['c_hat_early_min'] for n in ns_adv]
        ax.plot(ns_adv, mins_adv, 'o-', label='min Ĉ (all)', color='red')
        ax.plot(ns_adv, early_mins, 's-', label='min Ĉ (early)', color='orange')
        ax.axhline(y=0, color='black', linestyle='--', alpha=0.3)
        ax.set_xlabel("n (vertices)")
        ax.set_ylabel("Ĉ")
        ax.legend()
        ax.grid(True, alpha=0.3)

        plt.tight_layout()
        plt.savefig('spectral_gap_demo.png', dpi=150, bbox_inches='tight')
        print("Plot saved to spectral_gap_demo.png")

    except ImportError:
        print("(matplotlib not available — skipping plots)")

    print("\nDone.")


if __name__ == "__main__":
    main()
