#!/usr/bin/env python3
"""
Applications of the Heterogeneity–Gap Theory

Demonstrates real-world applications of edge-size disorder analysis
in combinatorial optimization, including:
1. Solver selection based on disorder parameters
2. Approximation quality prediction
3. Set cover / hitting set analysis
"""

from typing import List, Set, Dict, Tuple
from collections import Counter
import random
import math


class SetCoverInstance:
    """A weighted set cover instance, viewed as a hypergraph transversal problem.

    Models real-world scenarios: facility location, sensor placement,
    test coverage, etc.

    Attributes:
        universe: Set of elements to cover
        sets: List of (cost, elements) pairs
    """

    def __init__(self, universe: Set[int], sets: List[Tuple[float, Set[int]]]):
        self.universe = universe
        self.sets = sets
        self.n = len(universe)
        self.m = len(sets)

    def as_hypergraph_edges(self) -> List[Set[int]]:
        """View as hypergraph: each element defines an edge
        (the indices of sets containing it)."""
        element_to_sets: Dict[int, Set[int]] = {e: set() for e in self.universe}
        for i, (_, s) in enumerate(self.sets):
            for e in s:
                if e in element_to_sets:
                    element_to_sets[e].add(i)
        return list(element_to_sets.values())

    def edge_heterogeneity(self) -> float:
        """Compute heterogeneity of the dual hypergraph."""
        edges = self.as_hypergraph_edges()
        if not edges:
            return 0.0
        sizes = [len(e) for e in edges]
        mean = sum(sizes) / len(sizes)
        return sum((s - mean) ** 2 for s in sizes) / len(sizes)

    def collision_index(self) -> float:
        """Compute collision index of set-size distribution."""
        sizes = [len(s) for _, s in self.sets]
        if not sizes:
            return 1.0
        counts = Counter(sizes)
        n = len(sizes)
        return sum((c / n) ** 2 for c in counts.values())

    def support_width(self) -> int:
        """Compute support width of set sizes."""
        sizes = [len(s) for _, s in self.sets]
        if not sizes:
            return 0
        return max(sizes) - min(sizes)

    def predict_lp_quality(self) -> str:
        """Predict LP relaxation quality based on disorder parameters.

        Application: solver selection without solving the LP.
        """
        het = self.edge_heterogeneity()
        ci = self.collision_index()
        sw = self.support_width()

        if sw == 0:
            return "UNIFORM: LP relaxation likely tight or near-tight. Use LP-based solver."
        elif ci > 0.8:
            return "LOW DISORDER: LP relaxation moderately informative. LP rounding recommended."
        elif ci > 0.5:
            return "MODERATE DISORDER: Significant integrality gap expected. Consider branch-and-bound."
        else:
            return "HIGH DISORDER: Large integrality gap likely. Use combinatorial algorithms."

    def disorder_report(self) -> Dict:
        """Generate a comprehensive disorder analysis report."""
        het = self.edge_heterogeneity()
        ci = self.collision_index()
        sw = self.support_width()

        set_sizes = [len(s) for _, s in self.sets]
        size_dist = Counter(set_sizes)

        return {
            'instance_size': f'{self.n} elements, {self.m} sets',
            'set_size_distribution': dict(size_dist),
            'heterogeneity': round(het, 4),
            'collision_index': round(ci, 4),
            'support_width': sw,
            'disorder_level': 'uniform' if sw == 0 else
                             'low' if ci > 0.8 else
                             'moderate' if ci > 0.5 else 'high',
            'recommendation': self.predict_lp_quality(),
        }


# Application 1: Facility Location
def facility_location_example():
    """Model a facility location problem as set cover.

    Scenario: Place facilities to serve customer zones.
    Each facility serves a region of varying size.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 1: FACILITY LOCATION")
    print("=" * 60)

    # 20 customer zones, 10 potential facility locations
    universe = set(range(20))
    facilities = [
        (10.0, {0, 1, 2}),          # Small local facility
        (15.0, {3, 4, 5, 6}),       # Medium facility
        (8.0, {7, 8}),              # Tiny facility
        (25.0, {0, 1, 2, 3, 4, 5, 6, 7, 8, 9}),  # Large regional center
        (12.0, {10, 11, 12}),
        (20.0, {13, 14, 15, 16, 17}),
        (7.0, {18, 19}),
        (30.0, {5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15}),  # Very large
        (9.0, {16, 17, 18}),
        (11.0, {0, 5, 10, 15}),     # Scattered coverage
    ]

    instance = SetCoverInstance(universe, facilities)
    report = instance.disorder_report()

    print(f"  Instance: {report['instance_size']}")
    print(f"  Set size distribution: {report['set_size_distribution']}")
    print(f"  Heterogeneity: {report['heterogeneity']}")
    print(f"  Collision index: {report['collision_index']}")
    print(f"  Support width: {report['support_width']}")
    print(f"  Disorder level: {report['disorder_level']}")
    print(f"  Recommendation: {report['recommendation']}")


# Application 2: Test Suite Optimization
def test_coverage_example():
    """Model test suite optimization as set cover.

    Scenario: Select minimum test cases to cover all code paths.
    Test cases vary greatly in what they cover.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: TEST SUITE OPTIMIZATION")
    print("=" * 60)

    random.seed(123)
    n_paths = 50
    n_tests = 30
    universe = set(range(n_paths))

    tests = []
    for i in range(n_tests):
        # Mix of targeted tests (small) and integration tests (large)
        if random.random() < 0.4:
            # Targeted: covers 2-4 paths
            size = random.randint(2, 4)
        elif random.random() < 0.7:
            # Medium: covers 8-15 paths
            size = random.randint(8, 15)
        else:
            # Integration: covers 20-35 paths
            size = random.randint(20, 35)

        covered = set(random.sample(list(universe), min(size, n_paths)))
        tests.append((1.0, covered))  # unit cost

    instance = SetCoverInstance(universe, tests)
    report = instance.disorder_report()

    print(f"  Instance: {report['instance_size']}")
    print(f"  Test size distribution: {report['set_size_distribution']}")
    print(f"  Heterogeneity: {report['heterogeneity']}")
    print(f"  Collision index: {report['collision_index']}")
    print(f"  Support width: {report['support_width']}")
    print(f"  Disorder level: {report['disorder_level']}")
    print(f"  Recommendation: {report['recommendation']}")


# Application 3: Network Sensor Placement
def sensor_placement_example():
    """Model sensor placement as set cover.

    Scenario: uniform sensor range = uniform edge sizes.
    Mixed sensor types = heterogeneous edge sizes.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: SENSOR PLACEMENT (UNIFORM vs MIXED)")
    print("=" * 60)

    universe = set(range(30))

    # Uniform sensors: all cover exactly 5 nodes
    uniform_sensors = [(1.0, set(random.sample(list(universe), 5)))
                       for _ in range(15)]

    # Mixed sensors: short-range (3), medium (6), long-range (12)
    mixed_sensors = []
    for _ in range(5):
        mixed_sensors.append((1.0, set(random.sample(list(universe), 3))))
    for _ in range(5):
        mixed_sensors.append((1.0, set(random.sample(list(universe), 6))))
    for _ in range(5):
        mixed_sensors.append((1.0, set(random.sample(list(universe), 12))))

    for label, sensors in [("UNIFORM", uniform_sensors), ("MIXED", mixed_sensors)]:
        instance = SetCoverInstance(universe, sensors)
        report = instance.disorder_report()
        print(f"\n  {label} SENSORS:")
        print(f"    Heterogeneity: {report['heterogeneity']}")
        print(f"    Collision index: {report['collision_index']}")
        print(f"    Disorder level: {report['disorder_level']}")
        print(f"    Recommendation: {report['recommendation']}")


if __name__ == '__main__':
    random.seed(42)
    facility_location_example()
    test_coverage_example()
    sensor_placement_example()

    print("\n" + "=" * 60)
    print("SUMMARY: Disorder-guided solver selection")
    print("=" * 60)
    print("""
  The key insight: before investing computational effort in solving a
  covering/transversal problem, measure the disorder of constraint sizes.

  - LOW disorder (uniform or near-uniform sizes):
    LP relaxation is tight or near-tight. Use LP-based algorithms.
    Expected integrality gap: small.

  - HIGH disorder (mixed constraint sizes):
    LP relaxation may be far from optimal. Consider combinatorial
    algorithms, branch-and-bound, or randomized rounding with
    disorder-aware parameters.
    Expected integrality gap: potentially large.

  This is the practical impact of the Heterogeneity-Gap Theory:
  structural disorder in the instance predicts algorithmic behavior.
    """)


#!/usr/bin/env python3
"""
Heterogeneity–Gap Conjecture: Computational Demonstration

This script generates random hypergraphs, computes edge-size heterogeneity
(variance), transversal numbers (τ), fractional transversal bounds (τ*),
and visualizes the relationship between disorder and integrality gap.
"""

import random
import itertools
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from fractions import Fraction
from collections import Counter


def generate_random_hypergraph(n_vertices, n_edges, edge_sizes):
    """Generate a random hypergraph on n_vertices with random edges."""
    vertices = list(range(n_vertices))
    edges = set()
    attempts = 0
    while len(edges) < n_edges and attempts < n_edges * 100:
        k = random.choice(edge_sizes)
        if k <= n_vertices:
            edge = tuple(sorted(random.sample(vertices, k)))
            edges.add(edge)
        attempts += 1
    return vertices, list(edges)


def edge_heterogeneity(edges):
    """Compute edge-size variance (heterogeneity)."""
    if not edges:
        return 0.0
    sizes = [len(e) for e in edges]
    mean_size = sum(sizes) / len(sizes)
    variance = sum((s - mean_size) ** 2 for s in sizes) / len(sizes)
    return variance


def edge_size_support_width(edges):
    """Compute max edge size - min edge size."""
    if not edges:
        return 0
    sizes = [len(e) for e in edges]
    return max(sizes) - min(sizes)


def collision_index(edges):
    """Compute collision index Σ p_k^2 of edge-size distribution."""
    if not edges:
        return 1.0
    sizes = [len(e) for e in edges]
    counts = Counter(sizes)
    n = len(edges)
    return sum((c / n) ** 2 for c in counts.values())


def exact_transversal_number(vertices, edges):
    """Compute exact τ(H) by brute force for small instances."""
    n = len(vertices)
    for size in range(n + 1):
        for subset in itertools.combinations(vertices, size):
            S = set(subset)
            if all(S & set(e) for e in edges):
                return size
    return n


def greedy_fractional_transversal(vertices, edges):
    """Compute a fractional transversal using LP relaxation heuristic.
    Returns (value, weights) where value ≈ τ*(H)."""
    if not edges:
        return 0.0, {}

    n = len(vertices)
    m = len(edges)

    # Simple iterative method: assign weights proportional to coverage need
    weights = {v: 0.0 for v in vertices}

    # Initialize: distribute 1/|e| to each vertex in each edge
    for e in edges:
        for v in e:
            weights[v] += 1.0 / len(e)

    # Normalize to ensure feasibility
    for _ in range(100):
        # Check feasibility
        min_slack = float('inf')
        for e in edges:
            s = sum(weights[v] for v in e)
            min_slack = min(min_slack, s)

        if min_slack >= 1.0 - 1e-10:
            break

        # Scale up if needed
        if min_slack > 0:
            scale = 1.0 / min_slack
            for v in vertices:
                weights[v] *= scale

    # Try to reduce: iteratively reduce largest weights
    for _ in range(200):
        for v in sorted(vertices, key=lambda v: -weights[v]):
            if weights[v] <= 0:
                continue
            # Find minimum slack for edges containing v
            min_slack = float('inf')
            for e in edges:
                if v in e:
                    s = sum(weights[u] for u in e)
                    min_slack = min(min_slack, s - 1.0)

            if min_slack > 1e-10:
                reduction = min(weights[v], min_slack)
                weights[v] -= reduction

    value = sum(weights.values())
    return value, weights


def lp_fractional_transversal(vertices, edges):
    """Try to compute τ* using scipy LP solver if available."""
    try:
        from scipy.optimize import linprog
        n = len(vertices)
        m = len(edges)
        if m == 0 or n == 0:
            return 0.0

        # Minimize sum(x_v) subject to sum_{v in e} x_v >= 1 for each edge, x >= 0
        c = np.ones(n)
        vertex_to_idx = {v: i for i, v in enumerate(vertices)}

        A_ub = np.zeros((m, n))
        b_ub = -np.ones(m)  # -sum >= -1, i.e. sum >= 1

        for i, e in enumerate(edges):
            for v in e:
                A_ub[i, vertex_to_idx[v]] = -1.0

        bounds = [(0, None) for _ in range(n)]
        result = linprog(c, A_ub=A_ub, b_ub=b_ub, bounds=bounds, method='highs')

        if result.success:
            return result.fun
        else:
            return greedy_fractional_transversal(vertices, edges)[0]
    except ImportError:
        return greedy_fractional_transversal(vertices, edges)[0]


def run_experiment(n_vertices=15, n_trials=500, edge_sizes_options=None):
    """Run the main experiment: generate hypergraphs and measure gap vs heterogeneity."""
    if edge_sizes_options is None:
        edge_sizes_options = [2, 3, 4, 5]

    results = []
    for trial in range(n_trials):
        n_edges = random.randint(5, 20)
        vertices, edges = generate_random_hypergraph(n_vertices, n_edges, edge_sizes_options)

        if not edges:
            continue

        het = edge_heterogeneity(edges)
        sw = edge_size_support_width(edges)
        ci = collision_index(edges)

        # For small enough instances, compute exact tau
        if n_vertices <= 15 and len(edges) <= 20:
            tau = exact_transversal_number(vertices, edges)
        else:
            tau = None

        tau_star = lp_fractional_transversal(vertices, edges)

        if tau is not None:
            gap = tau - tau_star
            ceil_gap = tau - int(np.ceil(tau_star))
            results.append({
                'heterogeneity': het,
                'support_width': sw,
                'collision_index': ci,
                'tau': tau,
                'tau_star': tau_star,
                'gap': gap,
                'ceil_gap': ceil_gap,
                'n_edges': len(edges),
            })

        if (trial + 1) % 100 == 0:
            print(f"  Trial {trial + 1}/{n_trials} complete")

    return results


def explicit_two_scale_family(m):
    """Construct the explicit two-scale hypergraph family.

    Vertex set: {0, ..., 2m} (2m+1 vertices)
    Small edges: {2i, 2i+1} for i = 0, ..., m-1  (m pairs, size 2)
    Large edge: {0, 2, 4, ..., 2(m-1)} (m vertices, size m)

    τ = m (must hit each pair, and at least one even vertex for large edge)
    τ* ≤ m - (m-2)/(2m) for large m (fractional advantage from overlap)
    """
    n = 2 * m + 1
    vertices = list(range(n))
    edges = []

    # Small edges (disjoint pairs)
    for i in range(m):
        edges.append((2 * i, 2 * i + 1))

    # Large edge (even vertices)
    large_edge = tuple(range(0, 2 * m, 2))
    if len(large_edge) >= 2:
        edges.append(large_edge)

    return vertices, edges


def analyze_explicit_family():
    """Analyze the explicit two-scale family for various parameter values."""
    print("\n" + "=" * 60)
    print("EXPLICIT TWO-SCALE FAMILY ANALYSIS")
    print("=" * 60)

    family_results = []
    for m in range(2, 10):
        vertices, edges = explicit_two_scale_family(m)
        het = edge_heterogeneity(edges)
        sw = edge_size_support_width(edges)
        ci = collision_index(edges)
        tau = exact_transversal_number(vertices, edges)
        tau_star = lp_fractional_transversal(vertices, edges)
        gap = tau - tau_star
        ceil_gap = tau - int(np.ceil(tau_star))

        family_results.append({
            'm': m,
            'n_vertices': len(vertices),
            'n_edges': len(edges),
            'heterogeneity': het,
            'support_width': sw,
            'collision_index': ci,
            'tau': tau,
            'tau_star': round(tau_star, 4),
            'gap': round(gap, 4),
            'ceil_gap': ceil_gap,
        })

        print(f"m={m}: |V|={len(vertices)}, |E|={len(edges)}, "
              f"het={het:.4f}, sw={sw}, CI={ci:.4f}, "
              f"τ={tau}, τ*={tau_star:.4f}, gap={gap:.4f}, ceil_gap={ceil_gap}")

    return family_results


def search_counterexamples(n_vertices=15, n_trials=1000):
    """Search for counterexamples: high heterogeneity but τ = ⌈τ*⌉."""
    print("\n" + "=" * 60)
    print("COUNTEREXAMPLE SEARCH: het > 2 with τ = ⌈τ*⌉")
    print("=" * 60)

    counterexamples = []
    high_het_count = 0

    for trial in range(n_trials):
        n_edges = random.randint(5, 25)
        vertices, edges = generate_random_hypergraph(n_vertices, n_edges, [2, 3, 4, 5])

        if not edges:
            continue

        het = edge_heterogeneity(edges)
        if het <= 2.0:
            continue

        high_het_count += 1
        tau = exact_transversal_number(vertices, edges)
        tau_star = lp_fractional_transversal(vertices, edges)
        ceil_gap = tau - int(np.ceil(tau_star))

        if ceil_gap == 0:
            counterexamples.append({
                'heterogeneity': het,
                'tau': tau,
                'tau_star': tau_star,
                'edges': edges,
            })
            print(f"  COUNTEREXAMPLE FOUND: het={het:.4f}, τ={tau}, τ*={tau_star:.4f}")

    print(f"\nTotal with het > 2: {high_het_count}")
    print(f"Counterexamples found: {len(counterexamples)}")
    if high_het_count > 0:
        print(f"Counterexample rate: {len(counterexamples)/high_het_count:.4f}")

    return counterexamples


def plot_results(results, family_results):
    """Generate visualization plots."""

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    # Plot 1: Gap vs Heterogeneity
    ax = axes[0, 0]
    hets = [r['heterogeneity'] for r in results]
    gaps = [r['gap'] for r in results]
    colors = ['red' if r['ceil_gap'] >= 1 else 'blue' for r in results]
    ax.scatter(hets, gaps, c=colors, alpha=0.4, s=10)
    ax.set_xlabel('Edge-Size Heterogeneity (σ²)')
    ax.set_ylabel('Integrality Gap (τ - τ*)')
    ax.set_title('Gap vs Heterogeneity (red = positive ceiling gap)')
    ax.axhline(y=1, color='green', linestyle='--', alpha=0.5, label='Gap = 1')
    ax.legend()

    # Plot 2: Collision Index vs Gap
    ax = axes[0, 1]
    cis = [r['collision_index'] for r in results]
    ax.scatter(cis, gaps, c=colors, alpha=0.4, s=10)
    ax.set_xlabel('Collision Index (Σ p_k²)')
    ax.set_ylabel('Integrality Gap (τ - τ*)')
    ax.set_title('Gap vs Collision Index')

    # Plot 3: Support Width vs Gap
    ax = axes[1, 0]
    sws = [r['support_width'] for r in results]
    ax.scatter(sws, gaps, c=colors, alpha=0.4, s=10)
    ax.set_xlabel('Support Width')
    ax.set_ylabel('Integrality Gap (τ - τ*)')
    ax.set_title('Gap vs Support Width')

    # Plot 4: Explicit Family
    ax = axes[1, 1]
    ms = [r['m'] for r in family_results]
    fam_hets = [r['heterogeneity'] for r in family_results]
    fam_gaps = [r['gap'] for r in family_results]
    ax.plot(ms, fam_gaps, 'ro-', label='Gap (τ - τ*)', markersize=8)
    ax2 = ax.twinx()
    ax2.plot(ms, fam_hets, 'bs-', label='Heterogeneity', markersize=8)
    ax.set_xlabel('Family Parameter m')
    ax.set_ylabel('Integrality Gap', color='r')
    ax2.set_ylabel('Heterogeneity', color='b')
    ax.set_title('Explicit Two-Scale Family')
    lines1, labels1 = ax.get_legend_handles_labels()
    lines2, labels2 = ax2.get_legend_handles_labels()
    ax.legend(lines1 + lines2, labels1 + labels2)

    plt.tight_layout()
    plt.savefig('heterogeneity_gap_analysis.png', dpi=150, bbox_inches='tight')
    print("\nPlot saved to heterogeneity_gap_analysis.png")


def main():
    random.seed(42)
    np.random.seed(42)

    print("=" * 60)
    print("HETEROGENEITY–GAP CONJECTURE: COMPUTATIONAL DEMONSTRATION")
    print("=" * 60)

    # 1. Run main experiment
    print("\n1. Running random hypergraph experiment (n=15, edge sizes {2,3,4,5})...")
    results = run_experiment(n_vertices=15, n_trials=500)
    print(f"   Collected {len(results)} valid data points")

    # Statistics
    positive_ceil_gaps = sum(1 for r in results if r['ceil_gap'] >= 1)
    print(f"   Positive ceiling gaps: {positive_ceil_gaps}/{len(results)} "
          f"({100*positive_ceil_gaps/len(results):.1f}%)")

    # Find threshold
    if results:
        sorted_by_het = sorted(results, key=lambda r: r['heterogeneity'])
        # Find empirical threshold where most have positive gap
        for i in range(len(sorted_by_het)):
            remaining = sorted_by_het[i:]
            if remaining:
                frac_pos = sum(1 for r in remaining if r['ceil_gap'] >= 1) / len(remaining)
                if frac_pos > 0.9:
                    print(f"   Empirical threshold δ* ≈ {sorted_by_het[i]['heterogeneity']:.4f} "
                          f"(90%+ positive ceiling gap above this)")
                    break

    # 2. Analyze explicit family
    family_results = analyze_explicit_family()

    # 3. Search for counterexamples
    counterexamples = search_counterexamples(n_vertices=15, n_trials=1000)

    # 4. Generate plots
    if results and family_results:
        plot_results(results, family_results)

    # 5. Information-theoretic summary
    print("\n" + "=" * 60)
    print("INFORMATION-THEORETIC SUMMARY")
    print("=" * 60)
    if results:
        uniform_results = [r for r in results if r['collision_index'] > 0.99]
        nonuniform_results = [r for r in results if r['collision_index'] < 0.99]
        if uniform_results:
            avg_gap_uni = np.mean([r['gap'] for r in uniform_results])
            print(f"  Near-uniform (CI > 0.99): avg gap = {avg_gap_uni:.4f} "
                  f"({len(uniform_results)} instances)")
        if nonuniform_results:
            avg_gap_nonuni = np.mean([r['gap'] for r in nonuniform_results])
            print(f"  Non-uniform (CI < 0.99): avg gap = {avg_gap_nonuni:.4f} "
                  f"({len(nonuniform_results)} instances)")

    print("\nDone!")


if __name__ == '__main__':
    main()


#!/usr/bin/env python3
"""
Visualization: Explicit Two-Scale Family Analysis

Plots the behavior of the explicit two-scale hypergraph family H_m
as the parameter m grows, showing how heterogeneity, collision index,
and integrality gap evolve. This family is the key constructive
example in the Heterogeneity-Gap theory.
"""

import itertools
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from collections import Counter


def two_scale_family(m):
    """Construct H_m: m disjoint pairs + one large edge of even vertices."""
    n = 2 * m + 1
    vertices = list(range(n))
    edges = []
    for i in range(m):
        edges.append((2 * i, 2 * i + 1))
    large = tuple(range(0, 2 * m, 2))
    if len(large) >= 2:
        edges.append(large)
    return vertices, edges


def edge_heterogeneity(edges):
    if not edges:
        return 0.0
    sizes = [len(e) for e in edges]
    mean_size = sum(sizes) / len(sizes)
    return sum((s - mean_size) ** 2 for s in sizes) / len(sizes)


def collision_index(edges):
    if not edges:
        return 1.0
    sizes = [len(e) for e in edges]
    counts = Counter(sizes)
    n = len(edges)
    return sum((c / n) ** 2 for c in counts.values())


def support_width(edges):
    if not edges:
        return 0
    sizes = [len(e) for e in edges]
    return max(sizes) - min(sizes)


def exact_transversal_number(vertices, edges):
    n = len(vertices)
    for size in range(n + 1):
        for subset in itertools.combinations(vertices, size):
            S = set(subset)
            if all(S & set(e) for e in edges):
                return size
    return n


def lp_fractional_transversal(vertices, edges):
    try:
        from scipy.optimize import linprog
        n = len(vertices)
        m = len(edges)
        if m == 0:
            return 0.0
        c = np.ones(n)
        A_ub = np.zeros((m, n))
        b_ub = -np.ones(m)
        for i, e in enumerate(edges):
            for v in e:
                A_ub[i, v] = -1.0
        bounds = [(0, None)] * n
        result = linprog(c, A_ub=A_ub, b_ub=b_ub, bounds=bounds, method='highs')
        if result.success:
            return result.fun
    except ImportError:
        pass
    return float('nan')


ms = list(range(2, 12))
hets, cis, sws, taus, tau_stars, gaps = [], [], [], [], [], []

for m in ms:
    vertices, edges = two_scale_family(m)
    hets.append(edge_heterogeneity(edges))
    cis.append(collision_index(edges))
    sws.append(support_width(edges))

    if m <= 9:
        tau = exact_transversal_number(vertices, edges)
    else:
        tau = m  # Known: τ = m for this family
    tau_star = lp_fractional_transversal(vertices, edges)

    taus.append(tau)
    tau_stars.append(tau_star)
    gaps.append(tau - tau_star)

fig, axes = plt.subplots(2, 2, figsize=(13, 10))

# Plot 1: Disorder invariants vs m
ax = axes[0, 0]
ax.plot(ms, hets, 'ro-', label='Heterogeneity (σ²)', markersize=7)
ax.plot(ms, cis, 'bs-', label='Collision Index', markersize=7)
ax.set_xlabel('Family Parameter m', fontsize=12)
ax.set_ylabel('Value', fontsize=12)
ax.set_title('Disorder Invariants vs Parameter m', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Plot 2: Support width vs m
ax = axes[0, 1]
ax.bar(ms, sws, color='#27ae60', alpha=0.7)
ax.set_xlabel('Family Parameter m', fontsize=12)
ax.set_ylabel('Support Width', fontsize=12)
ax.set_title('Support Width Growth', fontsize=13)
ax.grid(True, alpha=0.3, axis='y')

# Plot 3: τ and τ* vs m
ax = axes[1, 0]
ax.plot(ms, taus, 'ro-', label='τ (integer)', markersize=8, linewidth=2)
ax.plot(ms, tau_stars, 'b^-', label='τ* (fractional)', markersize=8, linewidth=2)
ax.fill_between(ms, tau_stars, taus, alpha=0.2, color='purple',
                label='Integrality gap')
ax.set_xlabel('Family Parameter m', fontsize=12)
ax.set_ylabel('Transversal Number', fontsize=12)
ax.set_title('Integer vs Fractional Transversal', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Plot 4: Gap vs heterogeneity for this family
ax = axes[1, 1]
ax.scatter(hets, gaps, c='purple', s=80, zorder=5)
for i, m in enumerate(ms):
    ax.annotate(f'm={m}', (hets[i], gaps[i]), textcoords="offset points",
                xytext=(5, 5), fontsize=9)
ax.set_xlabel('Heterogeneity (σ²)', fontsize=12)
ax.set_ylabel('Integrality Gap (τ − τ*)', fontsize=12)
ax.set_title('Gap vs Heterogeneity in Two-Scale Family', fontsize=13)
ax.grid(True, alpha=0.3)

plt.suptitle('Two-Scale Hypergraph Family H_m: Disorder Forces Gap',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_family_analysis.png', dpi=150, bbox_inches='tight')
print("Saved viz_family_analysis.png")


#!/usr/bin/env python3
"""
Visualization: Integrality Gap vs Edge-Size Heterogeneity

Visualizes the core conjecture: as edge-size heterogeneity (variance)
increases, the integrality gap τ - τ* tends to grow, and positive
ceiling gaps become more frequent. The plot shows random hypergraphs
on 15 vertices with edge sizes in {2,3,4,5}, colored by whether they
exhibit a positive ceiling gap.
"""

import random
import itertools
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from collections import Counter


def generate_random_hypergraph(n_vertices, n_edges, edge_sizes):
    vertices = list(range(n_vertices))
    edges = set()
    attempts = 0
    while len(edges) < n_edges and attempts < n_edges * 100:
        k = random.choice(edge_sizes)
        if k <= n_vertices:
            edge = tuple(sorted(random.sample(vertices, k)))
            edges.add(edge)
        attempts += 1
    return vertices, list(edges)


def edge_heterogeneity(edges):
    if not edges:
        return 0.0
    sizes = [len(e) for e in edges]
    mean_size = sum(sizes) / len(sizes)
    return sum((s - mean_size) ** 2 for s in sizes) / len(sizes)


def collision_index(edges):
    if not edges:
        return 1.0
    sizes = [len(e) for e in edges]
    counts = Counter(sizes)
    n = len(edges)
    return sum((c / n) ** 2 for c in counts.values())


def exact_transversal_number(vertices, edges):
    n = len(vertices)
    for size in range(n + 1):
        for subset in itertools.combinations(vertices, size):
            S = set(subset)
            if all(S & set(e) for e in edges):
                return size
    return n


def lp_fractional_transversal(vertices, edges):
    try:
        from scipy.optimize import linprog
        n = len(vertices)
        m = len(edges)
        if m == 0:
            return 0.0
        c = np.ones(n)
        A_ub = np.zeros((m, n))
        b_ub = -np.ones(m)
        for i, e in enumerate(edges):
            for v in e:
                A_ub[i, v] = -1.0
        bounds = [(0, None)] * n
        result = linprog(c, A_ub=A_ub, b_ub=b_ub, bounds=bounds, method='highs')
        if result.success:
            return result.fun
    except ImportError:
        pass
    # Fallback
    if not edges:
        return 0.0
    weights = {v: 0.0 for v in vertices}
    for e in edges:
        for v in e:
            weights[v] += 1.0 / len(e)
    for _ in range(200):
        min_s = min(sum(weights[v] for v in e) for e in edges)
        if min_s >= 1.0 - 1e-10:
            break
        if min_s > 0:
            for v in vertices:
                weights[v] /= min_s
    return sum(weights.values())


random.seed(42)
np.random.seed(42)

hets, gaps, ceil_gaps, cis = [], [], [], []

for _ in range(600):
    n_edges = random.randint(4, 18)
    vertices, edges = generate_random_hypergraph(15, n_edges, [2, 3, 4, 5])
    if not edges:
        continue
    h = edge_heterogeneity(edges)
    ci = collision_index(edges)
    tau = exact_transversal_number(vertices, edges)
    tau_star = lp_fractional_transversal(vertices, edges)
    hets.append(h)
    gaps.append(tau - tau_star)
    ceil_gaps.append(tau - int(np.ceil(tau_star)))
    cis.append(ci)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Left: Gap vs Heterogeneity
colors = ['#e74c3c' if cg >= 1 else '#3498db' for cg in ceil_gaps]
ax1.scatter(hets, gaps, c=colors, alpha=0.5, s=20, edgecolors='none')
ax1.set_xlabel('Edge-Size Heterogeneity (σ²)', fontsize=13)
ax1.set_ylabel('Integrality Gap (τ − τ*)', fontsize=13)
ax1.set_title('Integrality Gap vs Edge-Size Heterogeneity', fontsize=14)
ax1.axhline(y=1, color='gray', linestyle='--', alpha=0.5)

# Add legend
from matplotlib.patches import Patch
legend_elements = [Patch(facecolor='#e74c3c', label='Positive ceiling gap (τ > ⌈τ*⌉)'),
                   Patch(facecolor='#3498db', label='No ceiling gap')]
ax1.legend(handles=legend_elements, fontsize=10)

# Right: Collision Index vs Gap
ax2.scatter(cis, gaps, c=colors, alpha=0.5, s=20, edgecolors='none')
ax2.set_xlabel('Collision Index (Σ pₖ²)', fontsize=13)
ax2.set_ylabel('Integrality Gap (τ − τ*)', fontsize=13)
ax2.set_title('Integrality Gap vs Collision Index', fontsize=14)
ax2.axhline(y=1, color='gray', linestyle='--', alpha=0.5)
ax2.legend(handles=legend_elements, fontsize=10)

plt.tight_layout()
plt.savefig('viz_gap_vs_heterogeneity.png', dpi=150, bbox_inches='tight')
print("Saved viz_gap_vs_heterogeneity.png")


#!/usr/bin/env python3
"""
Visualization: Phase Diagram of Edge-Size Disorder

Shows the structural phase diagram: uniform hypergraphs (collision index = 1,
heterogeneity = 0) occupy a single point in invariant space, while increasing
disorder traces a path through lower collision index and higher heterogeneity.
This visualizes the "phase transition" from ordered to disordered regimes.
"""

import random
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from collections import Counter


def edge_heterogeneity(edges):
    if not edges:
        return 0.0
    sizes = [len(e) for e in edges]
    mean_size = sum(sizes) / len(sizes)
    return sum((s - mean_size) ** 2 for s in sizes) / len(sizes)


def collision_index(edges):
    if not edges:
        return 1.0
    sizes = [len(e) for e in edges]
    counts = Counter(sizes)
    n = len(edges)
    return sum((c / n) ** 2 for c in counts.values())


def support_width(edges):
    if not edges:
        return 0
    sizes = [len(e) for e in edges]
    return max(sizes) - min(sizes)


def generate_random_hypergraph(n_vertices, n_edges, edge_sizes):
    vertices = list(range(n_vertices))
    edges = set()
    attempts = 0
    while len(edges) < n_edges and attempts < n_edges * 100:
        k = random.choice(edge_sizes)
        if k <= n_vertices:
            edge = tuple(sorted(random.sample(vertices, k)))
            edges.add(edge)
        attempts += 1
    return vertices, list(edges)


random.seed(42)
np.random.seed(42)

# Generate data points across different disorder regimes
data = {'het': [], 'ci': [], 'sw': [], 'regime': []}

# Regime 1: Uniform (single edge size)
for _ in range(80):
    k = random.choice([2, 3, 4, 5])
    n_edges = random.randint(4, 15)
    _, edges = generate_random_hypergraph(15, n_edges, [k])
    data['het'].append(edge_heterogeneity(edges))
    data['ci'].append(collision_index(edges))
    data['sw'].append(support_width(edges))
    data['regime'].append('Uniform')

# Regime 2: Two sizes (mild disorder)
for _ in range(120):
    a, b = sorted(random.sample([2, 3, 4, 5], 2))
    n_edges = random.randint(4, 15)
    _, edges = generate_random_hypergraph(15, n_edges, [a, b])
    data['het'].append(edge_heterogeneity(edges))
    data['ci'].append(collision_index(edges))
    data['sw'].append(support_width(edges))
    data['regime'].append('Two sizes')

# Regime 3: Three sizes (moderate disorder)
for _ in range(120):
    sizes = sorted(random.sample([2, 3, 4, 5], 3))
    n_edges = random.randint(4, 15)
    _, edges = generate_random_hypergraph(15, n_edges, sizes)
    data['het'].append(edge_heterogeneity(edges))
    data['ci'].append(collision_index(edges))
    data['sw'].append(support_width(edges))
    data['regime'].append('Three sizes')

# Regime 4: All four sizes (maximum disorder)
for _ in range(120):
    n_edges = random.randint(4, 15)
    _, edges = generate_random_hypergraph(15, n_edges, [2, 3, 4, 5])
    data['het'].append(edge_heterogeneity(edges))
    data['ci'].append(collision_index(edges))
    data['sw'].append(support_width(edges))
    data['regime'].append('Four sizes')

fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

colors_map = {
    'Uniform': '#2ecc71',
    'Two sizes': '#3498db',
    'Three sizes': '#e67e22',
    'Four sizes': '#e74c3c',
}

# Plot 1: Collision Index vs Heterogeneity
ax = axes[0]
for regime in ['Uniform', 'Two sizes', 'Three sizes', 'Four sizes']:
    idx = [i for i, r in enumerate(data['regime']) if r == regime]
    ax.scatter([data['ci'][i] for i in idx],
               [data['het'][i] for i in idx],
               c=colors_map[regime], label=regime, alpha=0.6, s=25,
               edgecolors='none')
ax.set_xlabel('Collision Index (Σ pₖ²)', fontsize=12)
ax.set_ylabel('Heterogeneity (σ²)', fontsize=12)
ax.set_title('Phase Diagram: Disorder Invariants', fontsize=13)
ax.legend(fontsize=9)
ax.annotate('ORDERED\nPHASE', xy=(0.95, 0.05), fontsize=10, color='green',
            ha='center', alpha=0.7)
ax.annotate('DISORDERED\nPHASE', xy=(0.35, 1.0), fontsize=10, color='red',
            ha='center', alpha=0.7)

# Plot 2: Support Width histogram by regime
ax = axes[1]
for i, regime in enumerate(['Uniform', 'Two sizes', 'Three sizes', 'Four sizes']):
    idx = [j for j, r in enumerate(data['regime']) if r == regime]
    sws = [data['sw'][j] for j in idx]
    ax.hist(sws, bins=range(0, 5), alpha=0.6, color=colors_map[regime],
            label=regime, align='left')
ax.set_xlabel('Support Width', fontsize=12)
ax.set_ylabel('Count', fontsize=12)
ax.set_title('Support Width Distribution by Regime', fontsize=13)
ax.legend(fontsize=9)

# Plot 3: Heterogeneity distribution by regime
ax = axes[2]
for regime in ['Uniform', 'Two sizes', 'Three sizes', 'Four sizes']:
    idx = [i for i, r in enumerate(data['regime']) if r == regime]
    hets = [data['het'][i] for i in idx]
    ax.hist(hets, bins=20, alpha=0.5, color=colors_map[regime],
            label=regime, density=True)
ax.set_xlabel('Heterogeneity (σ²)', fontsize=12)
ax.set_ylabel('Density', fontsize=12)
ax.set_title('Heterogeneity Distribution by Regime', fontsize=13)
ax.legend(fontsize=9)

plt.tight_layout()
plt.savefig('viz_phase_diagram.png', dpi=150, bbox_inches='tight')
print("Saved viz_phase_diagram.png")
