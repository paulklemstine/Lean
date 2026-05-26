#!/usr/bin/env python3
"""
Applications of Dynamic Lorentzian Certificates

Demonstrates real-world applications of the dynamic certificate theory:
1. Streaming graph algorithms: edge-by-edge matroid certification
2. Online combinatorial sampling with warm starts
3. Dynamic network reliability analysis
"""

from typing import List, Tuple, Dict, Set
from collections import defaultdict
from itertools import combinations
import random
import math

random.seed(42)


def streaming_matroid_certification(n_vertices: int, edge_stream: List[Tuple[int, int]]):
    """
    Simulate streaming matroid certification on a growing graph.

    As edges arrive one by one, maintain a Lorentzian certificate for the
    graphic matroid's basis generating polynomial using dynamic updates.

    Parameters:
        n_vertices: Number of graph vertices.
        edge_stream: Sequence of edges arriving over time.

    Returns:
        List of dictionaries with per-step metrics.
    """
    results = []
    current_edges = []

    for step, edge in enumerate(edge_stream):
        current_edges.append(edge)
        n_edges = len(current_edges)
        degree = n_vertices - 1

        # Find spanning trees in current graph
        trees = find_spanning_trees(n_vertices, current_edges)

        if not trees:
            results.append({
                'step': step,
                'edge': edge,
                'n_edges': n_edges,
                'n_trees': 0,
                'dynamic_cost': 0,
                'rebuild_cost': 0,
                'connected': False,
            })
            continue

        # The new edge creates new spanning trees
        # The update is a sum of monomials for newly created trees
        # In the single-basis model, take one new tree
        new_tree = trees[-1]  # Last tree (likely involves the new edge)
        alpha = tuple(1 if i in new_tree else 0 for i in range(n_edges))

        # Compute costs
        affected = sum(
            affected_count_backtrack(alpha, k)
            for k in range(max(degree - 1, 0))
        )
        dynamic_cost = n_edges**2 * affected
        rebuild_cost = n_edges**degree

        results.append({
            'step': step,
            'edge': edge,
            'n_edges': n_edges,
            'n_trees': len(trees),
            'dynamic_cost': dynamic_cost,
            'rebuild_cost': rebuild_cost,
            'connected': True,
            'savings': 1 - dynamic_cost / max(rebuild_cost, 1),
        })

    return results


def online_sampling_simulation(
    n_items: int,
    n_steps: int,
    perturbation_scale: float = 0.05
):
    """
    Simulate online sampling with warm starts vs cold starts.

    Maintains a probability distribution that evolves over time through
    small perturbations. Compares warm-start (using previous distribution)
    with cold-start (from uniform) sampling.

    Parameters:
        n_items: Number of items in the distribution.
        n_steps: Number of time steps to simulate.
        perturbation_scale: Scale of per-step perturbations.

    Returns:
        Dictionary with simulation results.
    """
    # Initialize weights
    weights = [random.expovariate(1.0) for _ in range(n_items)]
    Z = sum(weights)
    dist = [w / Z for w in weights]

    cold_start_tvs = []
    warm_start_tvs = []
    bounds = []

    for step in range(n_steps):
        # Perturb weights
        new_weights = [
            max(0, w + random.gauss(0, perturbation_scale * w))
            for w in weights
        ]
        Z_new = sum(new_weights)
        if Z_new <= 0:
            continue

        new_dist = [w / Z_new for w in new_weights]

        # Cold start: TV from uniform to new distribution
        uniform = [1.0 / n_items] * n_items
        cold_tv = 0.5 * sum(abs(u - n) for u, n in zip(uniform, new_dist))

        # Warm start: TV from old distribution to new
        warm_tv = 0.5 * sum(abs(o - n) for o, n in zip(dist, new_dist))

        # Theoretical bound
        delta = sum(abs(a - b) for a, b in zip(weights, new_weights))
        bound = delta / min(Z, Z_new)

        cold_start_tvs.append(cold_tv)
        warm_start_tvs.append(warm_tv)
        bounds.append(bound)

        # Update for next step
        weights = new_weights
        Z = Z_new
        dist = new_dist

    return {
        'n_items': n_items,
        'n_steps': n_steps,
        'cold_start_mean_tv': sum(cold_start_tvs) / len(cold_start_tvs) if cold_start_tvs else 0,
        'warm_start_mean_tv': sum(warm_start_tvs) / len(warm_start_tvs) if warm_start_tvs else 0,
        'mean_bound': sum(bounds) / len(bounds) if bounds else 0,
        'advantage_ratio': (
            sum(cold_start_tvs) / max(sum(warm_start_tvs), 1e-15)
            if warm_start_tvs else float('inf')
        ),
    }


def network_reliability_analysis(n_vertices: int, edge_reliability: Dict[Tuple[int, int], float]):
    """
    Analyze how network reliability changes under edge addition/removal.

    The reliability polynomial is related to the basis generating polynomial
    of the graphic matroid. Dynamic certificate updates allow efficient
    re-certification after network topology changes.

    Parameters:
        n_vertices: Number of network nodes.
        edge_reliability: Map from edge to reliability probability.

    Returns:
        Analysis results.
    """
    edges = list(edge_reliability.keys())
    n_edges = len(edges)
    degree = n_vertices - 1

    # Find spanning trees
    trees = find_spanning_trees(n_vertices, edges)

    if not trees:
        return {'connected': False, 'reliability': 0.0}

    # Compute reliability (simplified: product of edge reliabilities for each tree)
    tree_weights = []
    for tree in trees:
        weight = 1.0
        for e_idx in tree:
            weight *= edge_reliability[edges[e_idx]]
        tree_weights.append(weight)

    total_reliability = sum(tree_weights)
    normalized = [w / total_reliability for w in tree_weights]

    # Simulate edge reliability change
    changed_edge = edges[0]
    old_rel = edge_reliability[changed_edge]
    new_rel = min(1.0, old_rel * 1.1)  # 10% improvement

    new_weights = []
    for tree, w in zip(trees, tree_weights):
        if 0 in tree:  # Tree uses the changed edge
            new_weights.append(w * new_rel / old_rel)
        else:
            new_weights.append(w)

    delta = sum(abs(a - b) for a, b in zip(tree_weights, new_weights))
    tv_bound = delta / min(sum(tree_weights), sum(new_weights))

    return {
        'connected': True,
        'n_trees': len(trees),
        'reliability': total_reliability,
        'tv_bound_after_change': tv_bound,
        'changed_edge': changed_edge,
        'reliability_change': new_rel - old_rel,
    }


# ==============================================================================
# Utility Functions
# ==============================================================================

def find_spanning_trees(n_vertices, edges):
    """Find all spanning trees (returns list of frozensets of edge indices)."""
    if n_vertices <= 1:
        return [frozenset()]

    needed = n_vertices - 1
    trees = []

    for combo in combinations(range(len(edges)), needed):
        edge_set = [edges[i] for i in combo]
        adj = defaultdict(set)
        for u, v in edge_set:
            adj[u].add(v)
            adj[v].add(u)

        visited = set()
        queue = [0]
        visited.add(0)
        while queue:
            node = queue.pop(0)
            for neighbor in adj[node]:
                if neighbor not in visited:
                    visited.add(neighbor)
                    queue.append(neighbor)

        if len(visited) == n_vertices:
            trees.append(frozenset(combo))

    return trees


def affected_count_backtrack(alpha, k):
    """Count affected multiindices at depth k."""
    n = len(alpha)
    count = [0]

    def backtrack(pos, remaining, current):
        if pos == n:
            if remaining == 0:
                count[0] += 1
            return
        for val in range(min(remaining, alpha[pos]) + 1):
            backtrack(pos + 1, remaining - val, current + [val])

    backtrack(0, k, [])
    return count[0]


# ==============================================================================
# Main
# ==============================================================================

if __name__ == "__main__":
    print("Applications of Dynamic Lorentzian Certificates")
    print("=" * 55)

    # Application 1: Streaming matroid certification
    print("\n--- Application 1: Streaming Matroid Certification ---")
    edges = [(0, 1), (1, 2), (0, 2), (2, 3), (1, 3), (0, 3)]
    results = streaming_matroid_certification(4, edges)
    print(f"  {'Step':>4} | {'Edge':>8} | {'Trees':>5} | {'Dyn Cost':>10} | {'Rebuild':>10} | {'Savings':>8}")
    print(f"  {'-' * 55}")
    for r in results:
        if r['connected']:
            print(f"  {r['step']:4d} | {str(r['edge']):>8} | {r['n_trees']:5d} | "
                  f"{r['dynamic_cost']:10d} | {r['rebuild_cost']:10d} | {r['savings']:7.1%}")
        else:
            print(f"  {r['step']:4d} | {str(r['edge']):>8} | {'N/A':>5}")

    # Application 2: Online sampling
    print("\n--- Application 2: Online Sampling Simulation ---")
    for n in [10, 50, 100]:
        result = online_sampling_simulation(n, 100)
        print(f"  n={n:4d}: cold={result['cold_start_mean_tv']:.4f}, "
              f"warm={result['warm_start_mean_tv']:.4f}, "
              f"advantage={result['advantage_ratio']:.1f}x")

    # Application 3: Network reliability
    print("\n--- Application 3: Network Reliability ---")
    edges_rel = {(0, 1): 0.9, (1, 2): 0.95, (0, 2): 0.85, (2, 3): 0.9, (1, 3): 0.8}
    result = network_reliability_analysis(4, edges_rel)
    if result['connected']:
        print(f"  Spanning trees: {result['n_trees']}")
        print(f"  Reliability:    {result['reliability']:.6f}")
        print(f"  TV bound after {result['changed_edge']} change: {result['tv_bound_after_change']:.6f}")


#!/usr/bin/env python3
"""
Dynamic Lorentzian Certificates: Interactive Demonstration

This script demonstrates the core mathematical ideas behind dynamic Lorentzian
certificates through concrete numerical examples:
  1. Constructing homogeneous polynomials and graphic matroid generating polynomials
  2. Performing rank-1 monomial updates
  3. Computing affected-node counts and comparing update vs rebuild cost
  4. Simulating warm-start vs cold-start sampling behavior
  5. Running the computational disproof protocol on growing graph instances
"""

import numpy as np
from itertools import combinations, product
from collections import defaultdict
import random

random.seed(42)
np.random.seed(42)


# ==============================================================================
# 1. Affected Multiindices and Dynamic Certificate Cost
# ==============================================================================

def affected_multiindices(alpha, k):
    """
    Compute the set of derivative multiindices of total mass k that are
    coordinatewise bounded by alpha.

    Parameters:
        alpha: tuple of nonneg ints (the update exponent)
        k: int (the derivative order)

    Returns:
        list of tuples beta with sum(beta) = k and beta[i] <= alpha[i] for all i
    """
    n = len(alpha)
    if k == 0:
        return [tuple([0] * n)]

    result = []
    # Generate all multiindices of total mass k bounded by alpha
    def backtrack(pos, remaining, current):
        if pos == n:
            if remaining == 0:
                result.append(tuple(current))
            return
        for val in range(min(remaining, alpha[pos]) + 1):
            current.append(val)
            backtrack(pos + 1, remaining - val, current)
            current.pop()

    backtrack(0, k, [])
    return result


def affected_count(alpha, k):
    """Number of affected multiindices at depth k."""
    return len(affected_multiindices(alpha, k))


def dynamic_certificate_cost(n, d, alpha):
    """Dynamic certificate update cost: n^2 * sum of affected counts."""
    total = sum(affected_count(alpha, k) for k in range(d - 1))
    return n**2 * total


def full_rebuild_cost(n, d):
    """Full certificate rebuild cost: n^d."""
    return n**d


# ==============================================================================
# 2. Graphic Matroid Basis Generating Polynomials
# ==============================================================================

def spanning_trees(n_vertices, edges):
    """
    Find all spanning trees of a graph using brute force (for small graphs).
    Returns list of edge-index sets.
    """
    if n_vertices <= 1:
        return [frozenset()]

    trees = []
    needed = n_vertices - 1

    for combo in combinations(range(len(edges)), needed):
        edge_set = [edges[i] for i in combo]
        # Check if these edges form a spanning tree (connected + n-1 edges)
        adj = defaultdict(set)
        for u, v in edge_set:
            adj[u].add(v)
            adj[v].add(u)

        # BFS to check connectivity
        visited = set()
        queue = [0]
        visited.add(0)
        while queue:
            node = queue.pop(0)
            for neighbor in adj[node]:
                if neighbor not in visited:
                    visited.add(neighbor)
                    queue.append(neighbor)

        if len(visited) == n_vertices:
            trees.append(frozenset(combo))

    return trees


def basis_monomial(tree_edges, n_edges):
    """Convert a spanning tree (set of edge indices) to an exponent vector."""
    alpha = [0] * n_edges
    for e in tree_edges:
        alpha[e] = 1
    return tuple(alpha)


# ==============================================================================
# 3. Warm-Start Total Variation Bound
# ==============================================================================

def normalize_weights(w):
    """Normalize a weight vector to a probability distribution."""
    Z = sum(w)
    if Z <= 0:
        return [1.0 / len(w)] * len(w)
    return [wi / Z for wi in w]


def total_variation(mu, nu):
    """Total variation distance between two distributions."""
    return 0.5 * sum(abs(m - n) for m, n in zip(mu, nu))


def l1_distance(w, w_prime):
    """L1 distance between weight vectors."""
    return sum(abs(a - b) for a, b in zip(w, w_prime))


def warm_start_bound(w, w_prime):
    """Compute the warm-start TV bound: Delta / min(Z, Z')."""
    Z = sum(w)
    Z_prime = sum(w_prime)
    delta = l1_distance(w, w_prime)
    return delta / min(Z, Z_prime)


# ==============================================================================
# 4. Demonstration
# ==============================================================================

def demo_affected_nodes():
    """Demonstrate affected node counting for a rank-1 update."""
    print("=" * 70)
    print("DEMO 1: Affected Derivative Nodes for Rank-1 Updates")
    print("=" * 70)

    # Example: 4 variables, degree 4, update monomial X0^2 * X1 * X3
    alpha = (2, 1, 0, 1)
    d = sum(alpha)
    n = len(alpha)

    print(f"\nUpdate exponent α = {alpha}")
    print(f"Number of variables n = {n}")
    print(f"Degree d = {d}")
    print()

    total_affected = 0
    for k in range(d - 1):
        aff = affected_multiindices(alpha, k)
        count = len(aff)
        total_affected += count
        print(f"  Depth k={k}: {count} affected nodes")
        if count <= 10:
            for beta in aff:
                print(f"    β = {beta}")

    dyn_cost = dynamic_certificate_cost(n, d, alpha)
    rebuild = full_rebuild_cost(n, d)

    print(f"\nDynamic certificate cost:  {dyn_cost}")
    print(f"Full rebuild cost:         {rebuild}")
    print(f"Savings ratio:             {dyn_cost / rebuild:.4f}")
    print(f"Speedup factor:            {rebuild / max(dyn_cost, 1):.2f}x")


def demo_graphic_matroid():
    """Demonstrate locality for graphic matroid basis polynomials."""
    print("\n" + "=" * 70)
    print("DEMO 2: Graphic Matroid Basis Generating Polynomial")
    print("=" * 70)

    # Small graph: K4 (complete graph on 4 vertices)
    n_vertices = 4
    edges = [(i, j) for i in range(n_vertices) for j in range(i + 1, n_vertices)]
    n_edges = len(edges)

    print(f"\nGraph: K_{n_vertices} with {n_edges} edges")
    print(f"Edges: {edges}")

    trees = spanning_trees(n_vertices, edges)
    print(f"Number of spanning trees: {len(trees)}")

    # Compute basis generating polynomial coefficients
    monomials = [basis_monomial(tree, n_edges) for tree in trees]
    d = n_vertices - 1  # spanning tree has n-1 edges

    print(f"\nDegree of basis polynomial: {d}")
    print(f"First few basis monomials:")
    for i, mono in enumerate(monomials[:5]):
        print(f"  Tree {i}: {mono}")

    # Simulate adding a new spanning tree
    if len(monomials) > 0:
        new_mono = monomials[0]  # Pretend this is a new basis
        print(f"\nRank-1 update with α = {new_mono}")

        total_affected = 0
        for k in range(d - 1):
            count = affected_count(new_mono, k)
            total_affected += count
            print(f"  Depth k={k}: {count} affected derivative nodes")

        dyn_cost = dynamic_certificate_cost(n_edges, d, new_mono)
        rebuild = full_rebuild_cost(n_edges, d)
        print(f"\nDynamic cost:  {dyn_cost}")
        print(f"Rebuild cost:  {rebuild}")
        print(f"Savings:       {1 - dyn_cost / rebuild:.1%}")


def demo_warm_start():
    """Demonstrate warm-start total variation control."""
    print("\n" + "=" * 70)
    print("DEMO 3: Warm-Start Total Variation Control")
    print("=" * 70)

    # Original weights and perturbed weights
    w = [3.0, 5.0, 2.0, 4.0, 1.0]
    perturbation = [0.1, -0.2, 0.05, 0.15, -0.1]
    w_prime = [max(0, w[i] + perturbation[i]) for i in range(len(w))]

    mu = normalize_weights(w)
    nu = normalize_weights(w_prime)

    tv = total_variation(mu, nu)
    delta = l1_distance(w, w_prime)
    bound = warm_start_bound(w, w_prime)

    print(f"\nOriginal weights:    {w}")
    print(f"Perturbed weights:   {[f'{x:.2f}' for x in w_prime]}")
    print(f"\nOriginal distribution: {[f'{x:.4f}' for x in mu]}")
    print(f"Perturbed distribution: {[f'{x:.4f}' for x in nu]}")
    print(f"\nL1 coefficient drift Δ: {delta:.4f}")
    print(f"Total variation TV:     {tv:.4f}")
    print(f"Warm-start bound:       {bound:.4f}")
    print(f"Bound is valid:         {tv <= bound + 1e-10}")


def demo_scaling_experiment():
    """Run the computational disproof protocol on growing graph instances."""
    print("\n" + "=" * 70)
    print("DEMO 4: Scaling Experiment (Disproof Protocol)")
    print("=" * 70)

    print("\n  n  | edges | trees |  dyn_cost  | rebuild_cost | ratio")
    print("  " + "-" * 60)

    for n_vertices in [4, 5, 6, 7]:
        # Random graph: complete graph minus some edges
        all_edges = [(i, j) for i in range(n_vertices) for j in range(i + 1, n_vertices)]
        n_edges = len(all_edges)

        # Use all edges (complete graph)
        trees = spanning_trees(n_vertices, all_edges)
        if not trees:
            continue

        d = n_vertices - 1
        # Pick a random spanning tree as the update monomial
        tree = random.choice(trees)
        alpha = basis_monomial(tree, n_edges)

        dyn = dynamic_certificate_cost(n_edges, d, alpha)
        rebuild = full_rebuild_cost(n_edges, d)
        ratio = dyn / rebuild if rebuild > 0 else float('inf')

        print(f"  {n_vertices:2d} | {n_edges:5d} | {len(trees):5d} | {dyn:10d} | {rebuild:12d} | {ratio:.4f}")


def demo_warm_start_scaling():
    """Simulate warm-start vs cold-start on growing problem sizes."""
    print("\n" + "=" * 70)
    print("DEMO 5: Warm-Start vs Cold-Start Sampling (Simulation)")
    print("=" * 70)

    print("\n  size | cold_start_TV | warm_start_TV | bound    | advantage")
    print("  " + "-" * 60)

    for size in [5, 10, 20, 50, 100]:
        # Generate random nonneg weights
        w = np.random.exponential(1.0, size)

        # Small perturbation
        perturbation = np.random.normal(0, 0.01, size)
        w_prime = np.maximum(0, w + perturbation)

        # Cold start: TV from uniform to target
        uniform = np.ones(size) / size
        target = w / w.sum()
        target_prime = w_prime / w_prime.sum()

        cold_tv = total_variation(uniform.tolist(), target_prime.tolist())
        warm_tv = total_variation(target.tolist(), target_prime.tolist())
        delta = l1_distance(w.tolist(), w_prime.tolist())
        bound = delta / min(w.sum(), w_prime.sum())

        advantage = cold_tv / max(warm_tv, 1e-15)

        print(f"  {size:4d} | {cold_tv:13.6f} | {warm_tv:13.6f} | {bound:.6f} | {advantage:.1f}x")


if __name__ == "__main__":
    demo_affected_nodes()
    demo_graphic_matroid()
    demo_warm_start()
    demo_scaling_experiment()
    demo_warm_start_scaling()

    print("\n" + "=" * 70)
    print("All demonstrations completed successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Visualization: Affected Derivative Nodes Heatmap

Visualizes the affected derivative profile for rank-1 updates. Shows how the
number of affected certificate nodes varies with derivative depth and update
exponent structure, illustrating the sparsity that enables dynamic certification.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def affected_count(alpha, k):
    """Count affected multiindices at depth k bounded by alpha."""
    n = len(alpha)
    count = [0]

    def backtrack(pos, remaining):
        if pos == n:
            if remaining == 0:
                count[0] += 1
            return
        for val in range(min(remaining, alpha[pos]) + 1):
            backtrack(pos + 1, remaining - val)

    backtrack(0, k)
    return count[0]


def total_multiindices(n, k):
    """Total number of multiindices of order k in n variables (stars and bars)."""
    from math import comb
    return comb(n + k - 1, k) if n > 0 else (1 if k == 0 else 0)


# Parameters
n = 6  # number of variables

# Different update patterns
patterns = {
    'Dense: α=(2,2,1,1,1,0)': (2, 2, 1, 1, 1, 0),
    'Sparse: α=(3,0,0,0,0,0)': (3, 0, 0, 0, 0, 0),
    'Squarefree: α=(1,1,1,0,0,0)': (1, 1, 1, 0, 0, 0),
    'Uniform: α=(1,1,1,1,1,1)': (1, 1, 1, 1, 1, 1),
}

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Affected Derivative Nodes: Sparsity of Certificate Updates',
             fontsize=14, fontweight='bold')

for ax, (label, alpha) in zip(axes.flat, patterns.items()):
    d = sum(alpha)
    max_k = d

    depths = list(range(max_k + 1))
    aff_counts = [affected_count(alpha, k) for k in depths]
    total_counts = [total_multiindices(n, k) for k in depths]
    fractions = [a / max(t, 1) for a, t in zip(aff_counts, total_counts)]

    # Bar chart
    x = np.arange(len(depths))
    width = 0.35

    bars1 = ax.bar(x - width/2, total_counts, width, label='Total nodes',
                   color='lightcoral', alpha=0.7)
    bars2 = ax.bar(x + width/2, aff_counts, width, label='Affected nodes',
                   color='steelblue', alpha=0.9)

    ax.set_xlabel('Derivative Depth k')
    ax.set_ylabel('Number of Nodes')
    ax.set_title(label, fontsize=11)
    ax.set_xticks(x)
    ax.set_xticklabels(depths)
    ax.legend(fontsize=8)

    # Add fraction labels
    for i, (a, t) in enumerate(zip(aff_counts, total_counts)):
        if t > 0:
            frac = a / t
            ax.text(i, max(a, t) * 1.05, f'{frac:.0%}',
                    ha='center', va='bottom', fontsize=7, color='darkgreen')

plt.tight_layout()
plt.savefig('viz_affected_nodes.png', dpi=150, bbox_inches='tight')
print("Saved viz_affected_nodes.png")

# Second figure: scaling comparison
fig2, ax2 = plt.subplots(1, 1, figsize=(10, 6))

ns = [4, 5, 6, 7, 8, 9, 10]
rebuild_costs = []
dynamic_costs = []

for nv in ns:
    ne = nv * (nv - 1) // 2  # complete graph edges
    deg = nv - 1
    # Squarefree update: spanning tree monomial
    alpha = tuple([1] * (nv - 1) + [0] * (ne - nv + 1))

    rebuild = ne ** deg
    dynamic = ne**2 * sum(affected_count(alpha, k) for k in range(deg - 1))

    rebuild_costs.append(rebuild)
    dynamic_costs.append(dynamic)

ax2.semilogy(ns, rebuild_costs, 'ro-', linewidth=2, markersize=8, label='Full Rebuild Cost')
ax2.semilogy(ns, dynamic_costs, 'bs-', linewidth=2, markersize=8, label='Dynamic Update Cost')
ax2.set_xlabel('Number of Vertices (Complete Graph $K_n$)', fontsize=12)
ax2.set_ylabel('Certificate Cost (log scale)', fontsize=12)
ax2.set_title('Dynamic vs Rebuild Certificate Cost: Exponential Savings', fontsize=13)
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)

# Add ratio annotations
for i, nv in enumerate(ns):
    ratio = dynamic_costs[i] / rebuild_costs[i]
    ax2.annotate(f'{ratio:.1e}', (nv, dynamic_costs[i]),
                textcoords="offset points", xytext=(15, 5), fontsize=8, color='blue')

plt.tight_layout()
plt.savefig('viz_scaling.png', dpi=150, bbox_inches='tight')
print("Saved viz_scaling.png")


#!/usr/bin/env python3
"""
Visualization: Warm-Start vs Cold-Start Total Variation

Illustrates how the warm-start advantage grows with distribution size,
showing that the total variation between successive normalized distributions
remains small even as the overall distribution becomes more complex.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

np.random.seed(42)


def total_variation(mu, nu):
    """Total variation distance."""
    return 0.5 * np.sum(np.abs(mu - nu))


# Experiment parameters
sizes = [5, 10, 20, 50, 100, 200, 500]
perturbation_scales = [0.01, 0.05, 0.10]
n_trials = 50

fig, axes = plt.subplots(1, 3, figsize=(16, 5))
fig.suptitle('Warm-Start vs Cold-Start Sampling: Total Variation Analysis',
             fontsize=13, fontweight='bold')

for ax, scale in zip(axes, perturbation_scales):
    cold_means = []
    cold_stds = []
    warm_means = []
    warm_stds = []
    bound_means = []

    for size in sizes:
        cold_tvs = []
        warm_tvs = []
        bounds = []

        for _ in range(n_trials):
            # Generate random weights
            w = np.random.exponential(1.0, size)
            perturbation = np.random.normal(0, scale, size)
            w_prime = np.maximum(0, w + perturbation)

            Z = w.sum()
            Z_prime = w_prime.sum()

            if Z_prime <= 0:
                continue

            mu = w / Z
            nu = w_prime / Z_prime
            uniform = np.ones(size) / size

            cold_tv = total_variation(uniform, nu)
            warm_tv = total_variation(mu, nu)
            delta = np.sum(np.abs(w - w_prime))
            bound = delta / min(Z, Z_prime)

            cold_tvs.append(cold_tv)
            warm_tvs.append(warm_tv)
            bounds.append(bound)

        cold_means.append(np.mean(cold_tvs))
        cold_stds.append(np.std(cold_tvs))
        warm_means.append(np.mean(warm_tvs))
        warm_stds.append(np.std(warm_tvs))
        bound_means.append(np.mean(bounds))

    cold_means = np.array(cold_means)
    warm_means = np.array(warm_means)
    bound_means = np.array(bound_means)

    ax.semilogy(sizes, cold_means, 'ro-', linewidth=2, markersize=6, label='Cold-start TV')
    ax.semilogy(sizes, warm_means, 'bs-', linewidth=2, markersize=6, label='Warm-start TV')
    ax.semilogy(sizes, bound_means, 'g^--', linewidth=1.5, markersize=6, label='Theorem bound')

    ax.set_xlabel('Distribution Size')
    ax.set_ylabel('Total Variation (log scale)')
    ax.set_title(f'Perturbation scale = {scale}')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_warmstart.png', dpi=150, bbox_inches='tight')
print("Saved viz_warmstart.png")
