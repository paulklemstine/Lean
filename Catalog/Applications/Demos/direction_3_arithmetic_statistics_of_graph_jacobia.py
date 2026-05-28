#!/usr/bin/env python3
"""
applications.py — Real-World Applications of Cohen-Lenstra Graph Jacobian Theory

Demonstrates practical applications connecting:
1. Network reliability analysis via spanning tree enumeration
2. Cryptographic group generation from random graphs
3. Error-correcting code design via Jacobian structure
4. Chip-firing dynamics simulation
"""

import numpy as np
from typing import List, Tuple, Dict
import math


def cohen_lenstra_moment(p: int, k: int) -> float:
    """Cohen-Lenstra moment ∏_{i=1}^{k} (1 - p^{-i})^{-1}."""
    result = 1.0
    for i in range(1, k + 1):
        result /= (1.0 - p ** (-i))
    return result


def graph_laplacian(adj: np.ndarray) -> np.ndarray:
    """Compute the Laplacian matrix of a graph from its adjacency matrix."""
    degrees = np.sum(adj, axis=1)
    return np.diag(degrees) - adj


def spanning_tree_count(adj: np.ndarray) -> int:
    """Count spanning trees via Kirchhoff's theorem."""
    n = adj.shape[0]
    L = graph_laplacian(adj)
    reduced = L[:n-1, :n-1].astype(float)
    return abs(int(round(np.linalg.det(reduced))))


# ============================================================
# Application 1: Network Reliability Analysis
# ============================================================

def network_reliability_analysis(adj: np.ndarray, edge_failure_prob: float = 0.1) -> Dict:
    """
    Analyze network reliability using the Jacobian structure.

    The number of spanning trees is a measure of network redundancy.
    The Jacobian structure (via SNF) reveals the algebraic connectivity
    pattern — groups with many small invariant factors are more
    "uniformly connected" than those with one large factor.

    Args:
        adj: Adjacency matrix of the network
        edge_failure_prob: Probability of each edge failing

    Returns:
        Dictionary with reliability metrics
    """
    n = adj.shape[0]
    num_edges = int(np.sum(adj) // 2)
    num_trees = spanning_tree_count(adj)

    # Reliability polynomial approximation (first-order)
    # R(p) ≈ num_trees * (1-p)^{n-1} * p^{num_edges - (n-1)}
    # where p = edge_failure_prob
    q = 1 - edge_failure_prob
    reliability_lower = num_trees * (q ** (n - 1)) * (edge_failure_prob ** max(0, num_edges - (n - 1)))

    # Algebraic connectivity: second-smallest eigenvalue of Laplacian
    L = graph_laplacian(adj)
    eigenvalues = sorted(np.linalg.eigvalsh(L.astype(float)))
    algebraic_connectivity = eigenvalues[1] if len(eigenvalues) > 1 else 0

    return {
        'num_vertices': n,
        'num_edges': num_edges,
        'spanning_trees': num_trees,
        'algebraic_connectivity': algebraic_connectivity,
        'reliability_estimate': min(1.0, reliability_lower),
        'redundancy_ratio': num_trees / max(1, n ** (n - 2)),  # Compare to K_n
    }


# ============================================================
# Application 2: Cryptographic Group Generation
# ============================================================

def generate_cryptographic_group(n: int, target_order_bits: int = 128,
                                 seed: int = None) -> Dict:
    """
    Generate a finite abelian group suitable for cryptographic use
    by constructing a random graph and taking its Jacobian.

    The Cohen-Lenstra heuristics predict that for large n, the
    Jacobian will have good cryptographic properties (large cyclic
    component, no small factors).

    Args:
        n: Number of vertices (controls group order)
        target_order_bits: Desired bit length of group order
        seed: Random seed

    Returns:
        Dictionary with group parameters
    """
    if seed is not None:
        np.random.seed(seed)

    best_order = 0
    best_adj = None

    # Try several random graphs, keep the one with largest Jacobian
    for _ in range(20):
        adj = np.zeros((n, n), dtype=int)
        for i in range(n):
            for j in range(i + 1, n):
                if np.random.random() < 0.5:
                    adj[i, j] = 1
                    adj[j, i] = 1

        order = spanning_tree_count(adj)
        if order > best_order:
            best_order = order
            best_adj = adj

    if best_adj is None:
        return {'success': False}

    order_bits = math.floor(math.log2(best_order)) + 1 if best_order > 0 else 0

    return {
        'success': True,
        'group_order': best_order,
        'order_bits': order_bits,
        'target_bits': target_order_bits,
        'sufficient': order_bits >= target_order_bits,
        'graph_vertices': n,
    }


# ============================================================
# Application 3: Chip-Firing Simulation
# ============================================================

def chip_firing_simulation(adj: np.ndarray, initial_config: np.ndarray,
                           sink: int = 0, max_steps: int = 10000) -> Dict:
    """
    Simulate the abelian sandpile model (chip-firing) on a graph.

    Starting from an initial chip configuration, fire unstable
    vertices until reaching a stable (critical) configuration.

    The set of critical configurations forms the Jacobian group
    under chip-firing equivalence.

    Args:
        adj: Adjacency matrix
        initial_config: Initial chip counts per vertex
        sink: Index of the sink vertex
        max_steps: Maximum firing steps

    Returns:
        Dictionary with simulation results
    """
    n = adj.shape[0]
    config = initial_config.copy().astype(int)
    degrees = np.sum(adj, axis=1).astype(int)

    firings = np.zeros(n, dtype=int)
    steps = 0

    while steps < max_steps:
        # Find unstable non-sink vertex
        unstable = None
        for v in range(n):
            if v != sink and config[v] >= degrees[v]:
                unstable = v
                break

        if unstable is None:
            break  # Stable configuration reached

        # Fire the unstable vertex
        v = unstable
        config[v] -= degrees[v]
        for w in range(n):
            if adj[v, w]:
                config[w] += 1
        firings[v] += 1
        steps += 1

    is_stable = all(config[v] < degrees[v] for v in range(n) if v != sink)

    return {
        'final_config': config,
        'is_stable': is_stable,
        'total_firings': int(np.sum(firings)),
        'steps': steps,
        'firing_vector': firings,
    }


# ============================================================
# Application 4: Error-Correcting Code Parameters
# ============================================================

def jacobian_code_parameters(adj: np.ndarray) -> Dict:
    """
    Compute parameters of the linear code associated with a graph's Jacobian.

    The cycle space of a graph defines a binary linear code.
    The Jacobian structure determines the code's algebraic properties
    over various finite fields.

    Args:
        adj: Adjacency matrix

    Returns:
        Code parameters dictionary
    """
    n = adj.shape[0]
    num_edges = int(np.sum(adj) // 2)

    # Code parameters
    k = num_edges - n + 1  # Dimension (number of independent cycles)
    num_trees = spanning_tree_count(adj)

    # Minimum distance estimate (lower bound)
    # For cycle codes, min distance ≥ girth of graph
    min_degree = min(int(np.sum(adj[i])) for i in range(n)) if n > 0 else 0

    return {
        'block_length': num_edges,
        'dimension': max(0, k),
        'rate': k / num_edges if num_edges > 0 else 0,
        'spanning_trees': num_trees,
        'min_degree': min_degree,
        'num_codewords_estimate': num_trees,
    }


# ============================================================
# Main demonstration
# ============================================================

if __name__ == "__main__":
    np.random.seed(42)

    print("╔" + "═"*58 + "╗")
    print("║  Applications of Graph Jacobian Arithmetic Statistics   ║")
    print("╚" + "═"*58 + "╝")

    # Build example graphs
    # Petersen graph adjacency matrix
    petersen = np.zeros((10, 10), dtype=int)
    outer = [(0,1),(1,2),(2,3),(3,4),(4,0)]
    inner = [(5,7),(7,9),(9,6),(6,8),(8,5)]
    spokes = [(0,5),(1,6),(2,7),(3,8),(4,9)]
    for i, j in outer + inner + spokes:
        petersen[i, j] = 1
        petersen[j, i] = 1

    # Complete graph K_5
    k5 = np.ones((5, 5), dtype=int) - np.eye(5, dtype=int)

    # Cycle graph C_8
    c8 = np.zeros((8, 8), dtype=int)
    for i in range(8):
        c8[i, (i+1) % 8] = 1
        c8[(i+1) % 8, i] = 1

    print("\n=== Application 1: Network Reliability ===")
    for name, adj in [("Petersen", petersen), ("K_5", k5), ("C_8", c8)]:
        result = network_reliability_analysis(adj)
        print(f"\n  {name} graph:")
        print(f"    Vertices: {result['num_vertices']}, Edges: {result['num_edges']}")
        print(f"    Spanning trees: {result['spanning_trees']}")
        print(f"    Algebraic connectivity: {result['algebraic_connectivity']:.4f}")
        print(f"    Redundancy ratio: {result['redundancy_ratio']:.6f}")

    print("\n\n=== Application 2: Cryptographic Group Generation ===")
    for n in [10, 15, 20]:
        result = generate_cryptographic_group(n, target_order_bits=32, seed=42)
        print(f"\n  n={n}: |Jac| = {result['group_order']} "
              f"({result['order_bits']} bits)")

    print("\n\n=== Application 3: Chip-Firing Simulation ===")
    adj = k5.copy()
    initial = np.array([10, 5, 3, 8, 2])
    result = chip_firing_simulation(adj, initial, sink=0)
    print(f"  K_5 with initial config {list(initial)}:")
    print(f"    Final config: {list(result['final_config'])}")
    print(f"    Stable: {result['is_stable']}")
    print(f"    Total firings: {result['total_firings']}")

    print("\n\n=== Application 4: Error-Correcting Codes ===")
    for name, adj in [("Petersen", petersen), ("K_5", k5)]:
        result = jacobian_code_parameters(adj)
        print(f"\n  {name} code:")
        print(f"    Block length: {result['block_length']}")
        print(f"    Dimension: {result['dimension']}")
        print(f"    Rate: {result['rate']:.4f}")
        print(f"    Codewords estimate: {result['spanning_trees']}")

    print("\n\n=== Cohen-Lenstra Predictions vs Graph Data ===")
    print("  Comparing Jacobian p-divisibility for random graphs")
    print("  with Cohen-Lenstra moment predictions:")
    for p in [3, 5, 7]:
        m = cohen_lenstra_moment(p, 1)
        print(f"\n  p={p}: predicted Pr[p | |Jac|] = {m:.4f} "
              f"(= {p}/{p-1})")


#!/usr/bin/env python3
"""
demo.py — Cohen-Lenstra Heuristics for Graph Jacobians

Demonstrates the conjecture that the distribution of invariant factors
of random graph Jacobians converges to the Cohen-Lenstra distribution.

Tests the prediction: For odd prime p and k ≥ 1,
  Pr[p^k | |Jac(G)|] → ∏_{i=1}^{k} (1 - p^{-i})^{-1}
as the number of vertices n → ∞ in Erdős-Rényi G(n, 1/2).
"""

import numpy as np
from collections import defaultdict
import time


def cohen_lenstra_prediction(p: int, k: int) -> float:
    """
    Cohen-Lenstra prediction: the moment ∏_{i=1}^{k} (1 - p^{-i})^{-1}.

    For k=1: p/(p-1)
    For k=2: p/(p-1) * p^2/(p^2-1)
    """
    product = 1.0
    for i in range(1, k + 1):
        product /= (1.0 - p ** (-i))
    return product


def random_graph_laplacian(n: int, prob: float = 0.5) -> np.ndarray:
    """
    Generate the Laplacian matrix of a random Erdős-Rényi graph G(n, prob).

    Returns the n×n integer Laplacian matrix L where:
    - L[i,j] = -1 if edge (i,j) exists
    - L[i,i] = degree of vertex i
    """
    # Generate upper triangle of adjacency matrix
    adj = np.zeros((n, n), dtype=int)
    for i in range(n):
        for j in range(i + 1, n):
            if np.random.random() < prob:
                adj[i, j] = 1
                adj[j, i] = 1

    # Laplacian = D - A
    degrees = np.sum(adj, axis=1)
    laplacian = np.diag(degrees) - adj
    return laplacian


def reduced_laplacian_det(laplacian: np.ndarray) -> int:
    """
    Compute the determinant of the reduced Laplacian (delete last row/col).
    This equals |Jac(G)| = number of spanning trees by Kirchhoff's theorem.
    """
    n = laplacian.shape[0]
    if n <= 1:
        return 0
    reduced = laplacian[:n-1, :n-1]
    det = int(round(np.linalg.det(reduced.astype(float))))
    return abs(det)


def is_connected_laplacian(laplacian: np.ndarray) -> bool:
    """Check if the graph is connected by examining the Laplacian's rank."""
    n = laplacian.shape[0]
    if n <= 1:
        return True
    eigenvalues = np.linalg.eigvalsh(laplacian.astype(float))
    # Connected iff exactly one zero eigenvalue
    num_zero = np.sum(np.abs(eigenvalues) < 1e-6)
    return num_zero == 1


def test_cohen_lenstra_conjecture(
    n_values: list,
    p_values: list,
    k_values: list,
    num_samples: int = 5000,
    verbose: bool = True
) -> dict:
    """
    Test the Cohen-Lenstra conjecture for graph Jacobians.

    For each (n, p, k), generates random G(n, 1/2) graphs, computes
    |Jac(G)| = det(reduced Laplacian), and checks if p^k divides it.

    Returns dict mapping (n, p, k) -> {empirical, predicted, error}.
    """
    results = {}

    for n in n_values:
        if verbose:
            print(f"\n{'='*60}")
            print(f"Testing n = {n} vertices ({num_samples} samples)")
            print(f"{'='*60}")

        # Generate all graphs for this n
        jacobian_orders = []
        connected_count = 0
        t0 = time.time()

        for _ in range(num_samples):
            L = random_graph_laplacian(n)
            if is_connected_laplacian(L):
                det = reduced_laplacian_det(L)
                if det > 0:
                    jacobian_orders.append(det)
                    connected_count += 1

        elapsed = time.time() - t0
        if verbose:
            print(f"  Connected graphs: {connected_count}/{num_samples} "
                  f"({elapsed:.1f}s)")

        for p in p_values:
            for k in k_values:
                pk = p ** k
                count = sum(1 for order in jacobian_orders if order % pk == 0)
                if connected_count > 0:
                    empirical = count / connected_count
                else:
                    empirical = 0.0
                predicted = cohen_lenstra_prediction(p, k)
                error = abs(empirical - predicted)

                results[(n, p, k)] = {
                    'empirical': empirical,
                    'predicted': predicted,
                    'error': error,
                    'samples': connected_count
                }

                if verbose:
                    print(f"  p={p}, k={k}: empirical={empirical:.4f}, "
                          f"predicted={predicted:.4f}, "
                          f"|error|={error:.4f}")

    return results


def display_convergence_analysis(results: dict, p_values: list, k_values: list):
    """Analyze whether errors decrease with n (evidence for convergence)."""
    print(f"\n{'='*60}")
    print("CONVERGENCE ANALYSIS")
    print(f"{'='*60}")

    n_values = sorted(set(n for n, _, _ in results.keys()))

    for p in p_values:
        for k in k_values:
            print(f"\n  p={p}, k={k}:")
            prev_error = None
            for n in n_values:
                key = (n, p, k)
                if key in results:
                    r = results[key]
                    trend = ""
                    if prev_error is not None:
                        if r['error'] < prev_error:
                            trend = " ↓ (converging)"
                        else:
                            trend = " ↑ (diverging)"
                    print(f"    n={n:4d}: error={r['error']:.4f}{trend}")
                    prev_error = r['error']


def demonstrate_moment_values():
    """Show specific Cohen-Lenstra moment values (matching Lean proofs)."""
    print("\n" + "="*60)
    print("COHEN-LENSTRA MOMENT VALUES (verified in Lean)")
    print("="*60)

    test_cases = [
        (3, 1, "3/2 = 1.5"),
        (5, 1, "5/4 = 1.25"),
        (3, 2, "27/16 = 1.6875"),
        (7, 1, "7/6 ≈ 1.1667"),
        (2, 1, "2/1 = 2.0"),
    ]

    for p, k, expected in test_cases:
        val = cohen_lenstra_prediction(p, k)
        print(f"  M({p}, {k}) = {val:.6f}  (expected: {expected})")


def demonstrate_bosonic_partition():
    """Show the bosonic partition function connection."""
    print("\n" + "="*60)
    print("BOSONIC PARTITION FUNCTION CONNECTION")
    print("="*60)
    print("  The Cohen-Lenstra moment ∏(1 - p^{-i})^{-1}")
    print("  equals the partition function of a bosonic system")
    print("  with energy levels log(p), 2·log(p), 3·log(p), ...")
    print()

    for p in [2, 3, 5]:
        print(f"  p = {p}:")
        for k in range(1, 6):
            moment = cohen_lenstra_prediction(p, k)
            print(f"    Z_{p}({k}) = {moment:.6f}")
        print()


if __name__ == "__main__":
    np.random.seed(42)

    print("╔" + "═"*58 + "╗")
    print("║  Cohen-Lenstra Heuristics for Graph Jacobians — Demo    ║")
    print("╚" + "═"*58 + "╝")

    # 1. Show moment values
    demonstrate_moment_values()

    # 2. Show bosonic partition function connection
    demonstrate_bosonic_partition()

    # 3. Test the conjecture
    print("\n" + "="*60)
    print("TESTING COHEN-LENSTRA CONJECTURE FOR GRAPH JACOBIANS")
    print("="*60)
    print("Conjecture: Pr[p^k | |Jac(G(n,1/2))|] → ∏(1 - p^{-i})^{-1}")

    results = test_cohen_lenstra_conjecture(
        n_values=[8, 12, 16, 20],
        p_values=[3, 5, 7],
        k_values=[1, 2],
        num_samples=2000
    )

    # 4. Convergence analysis
    display_convergence_analysis(results, [3, 5, 7], [1, 2])

    print("\n" + "="*60)
    print("CONCLUSION")
    print("="*60)
    print("  If errors decrease with n, this supports the conjecture.")
    print("  If errors increase or plateau, the conjecture may be false.")
    print("  Full verification requires n = 50-100+ (computationally heavy).")


#!/usr/bin/env python3
"""
Visualization: Cohen-Lenstra Convergence for Graph Jacobians

Plots the empirical p-divisibility frequency of random graph Jacobians
versus the Cohen-Lenstra prediction, showing convergence as n → ∞.
This visualizes the central conjecture of the research.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def cohen_lenstra_moment(p, k):
    result = 1.0
    for i in range(1, k + 1):
        result /= (1.0 - p ** (-i))
    return result


def random_graph_jacobian_order(n, prob=0.5):
    adj = np.zeros((n, n), dtype=int)
    for i in range(n):
        for j in range(i + 1, n):
            if np.random.random() < prob:
                adj[i, j] = 1
                adj[j, i] = 1
    degrees = np.sum(adj, axis=1)
    L = np.diag(degrees) - adj
    reduced = L[:n-1, :n-1].astype(float)
    eigenvalues = np.linalg.eigvalsh(L.astype(float))
    if np.sum(np.abs(eigenvalues) < 1e-6) != 1:
        return None  # Not connected
    det = abs(int(round(np.linalg.det(reduced))))
    return det if det > 0 else None


np.random.seed(42)

n_values = [8, 10, 14, 18, 22]
primes = [3, 5, 7]
num_samples = 1500

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

for idx, p in enumerate(primes):
    ax = axes[idx]
    empirical_k1 = []
    empirical_k2 = []

    for n in n_values:
        orders = []
        for _ in range(num_samples):
            order = random_graph_jacobian_order(n)
            if order is not None:
                orders.append(order)

        if orders:
            freq_k1 = sum(1 for o in orders if o % p == 0) / len(orders)
            freq_k2 = sum(1 for o in orders if o % (p**2) == 0) / len(orders)
        else:
            freq_k1 = 0
            freq_k2 = 0

        empirical_k1.append(freq_k1)
        empirical_k2.append(freq_k2)

    pred_k1 = cohen_lenstra_moment(p, 1)
    pred_k2 = cohen_lenstra_moment(p, 2)

    ax.plot(n_values, empirical_k1, 'bo-', linewidth=2, markersize=8,
            label=f'Empirical (k=1)')
    ax.axhline(y=pred_k1, color='b', linestyle='--', alpha=0.7,
               label=f'CL prediction (k=1): {pred_k1:.4f}')

    ax.plot(n_values, empirical_k2, 'rs-', linewidth=2, markersize=8,
            label=f'Empirical (k=2)')
    ax.axhline(y=pred_k2, color='r', linestyle='--', alpha=0.7,
               label=f'CL prediction (k=2): {pred_k2:.4f}')

    ax.set_xlabel('Number of vertices n', fontsize=12)
    ax.set_ylabel(f'Pr[{p}^k | |Jac(G)|]', fontsize=12)
    ax.set_title(f'p = {p}', fontsize=14, fontweight='bold')
    ax.legend(fontsize=8, loc='best')
    ax.grid(True, alpha=0.3)
    ax.set_ylim(0, max(pred_k1, max(empirical_k1)) * 1.3)

fig.suptitle('Cohen-Lenstra Convergence for Random Graph Jacobians\n'
             f'G(n, 1/2), {num_samples} samples per point',
             fontsize=14, fontweight='bold', y=1.02)

plt.tight_layout()
plt.savefig('convergence_plot.png', dpi=150, bbox_inches='tight')
print("Saved convergence_plot.png")


#!/usr/bin/env python3
"""
Visualization: Distribution of Graph Jacobian Orders

Shows the distribution of |Jac(G)| for random Erdős-Rényi graphs
and highlights the p-divisibility patterns predicted by Cohen-Lenstra.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def random_graph_jacobian_order(n, prob=0.5):
    """Compute |Jac(G)| for a random G(n, prob) graph."""
    adj = np.zeros((n, n), dtype=int)
    for i in range(n):
        for j in range(i + 1, n):
            if np.random.random() < prob:
                adj[i, j] = 1
                adj[j, i] = 1
    degrees = np.sum(adj, axis=1)
    L = np.diag(degrees) - adj
    eigenvalues = np.linalg.eigvalsh(L.astype(float))
    if np.sum(np.abs(eigenvalues) < 1e-6) != 1:
        return None
    reduced = L[:n-1, :n-1].astype(float)
    det = abs(int(round(np.linalg.det(reduced))))
    return det if det > 0 else None


def cohen_lenstra_moment(p, k):
    result = 1.0
    for i in range(1, k + 1):
        result /= (1.0 - p ** (-i))
    return result


np.random.seed(123)

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Panel 1 & 2: Distribution of log|Jac(G)| for n=10 and n=16
for idx, n in enumerate([10, 16]):
    ax = axes[0, idx]
    orders = []
    for _ in range(3000):
        order = random_graph_jacobian_order(n)
        if order is not None and order > 0:
            orders.append(order)

    log_orders = [np.log10(o) for o in orders if o > 0]

    ax.hist(log_orders, bins=40, density=True, alpha=0.7, color='steelblue',
            edgecolor='navy', linewidth=0.5)
    ax.set_xlabel('log₁₀ |Jac(G)|', fontsize=12)
    ax.set_ylabel('Density', fontsize=12)
    ax.set_title(f'G({n}, 1/2): Jacobian Order Distribution',
                 fontsize=13, fontweight='bold')

    mean_log = np.mean(log_orders)
    std_log = np.std(log_orders)
    ax.axvline(x=mean_log, color='red', linestyle='--', linewidth=2,
               label=f'Mean: {mean_log:.2f}')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

# Panel 3: p-divisibility bar chart
ax = axes[1, 0]
n = 16
orders = []
for _ in range(5000):
    order = random_graph_jacobian_order(n)
    if order is not None and order > 0:
        orders.append(order)

primes = [2, 3, 5, 7, 11]
bar_width = 0.35
x = np.arange(len(primes))

empirical_freqs = []
predicted_freqs = []
for p in primes:
    emp = sum(1 for o in orders if o % p == 0) / len(orders)
    pred = cohen_lenstra_moment(p, 1)
    empirical_freqs.append(emp)
    predicted_freqs.append(pred)

bars1 = ax.bar(x - bar_width/2, empirical_freqs, bar_width,
               label='Empirical', color='steelblue', alpha=0.8)
bars2 = ax.bar(x + bar_width/2, predicted_freqs, bar_width,
               label='Cohen-Lenstra', color='coral', alpha=0.8)

ax.set_xlabel('Prime p', fontsize=12)
ax.set_ylabel('Pr[p | |Jac(G)|]', fontsize=12)
ax.set_title(f'p-Divisibility: Empirical vs. Predicted (n={n})',
             fontsize=13, fontweight='bold')
ax.set_xticks(x)
ax.set_xticklabels([str(p) for p in primes])
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3, axis='y')

# Panel 4: Valuation profile for a specific graph
ax = axes[1, 1]

# Use the Petersen graph
petersen_adj = np.zeros((10, 10), dtype=int)
outer = [(0,1),(1,2),(2,3),(3,4),(4,0)]
inner = [(5,7),(7,9),(9,6),(6,8),(8,5)]
spokes = [(0,5),(1,6),(2,7),(3,8),(4,9)]
for i, j in outer + inner + spokes:
    petersen_adj[i, j] = 1
    petersen_adj[j, i] = 1

petersen_order = random_graph_jacobian_order(10, 0)  # Not random
# Petersen graph has 2000 spanning trees
# Manually compute for illustration
L = np.diag(np.sum(petersen_adj, axis=1)) - petersen_adj
reduced = L[:9, :9].astype(float)
petersen_det = abs(int(round(np.linalg.det(reduced))))

# Show factorization structure
primes_to_check = [2, 3, 5, 7, 11, 13]
valuations = []
temp = petersen_det
for p in primes_to_check:
    v = 0
    t = temp
    while t > 0 and t % p == 0:
        t //= p
        v += 1
    valuations.append(v)

colors = plt.cm.Set2(np.linspace(0, 1, len(primes_to_check)))
bars = ax.bar(range(len(primes_to_check)), valuations, color=colors,
              edgecolor='black', linewidth=0.5)
ax.set_xlabel('Prime p', fontsize=12)
ax.set_ylabel('v_p(|Jac|)', fontsize=12)
ax.set_title(f'Petersen Graph: |Jac| = {petersen_det}\nPrime Factorization Profile',
             fontsize=13, fontweight='bold')
ax.set_xticks(range(len(primes_to_check)))
ax.set_xticklabels([str(p) for p in primes_to_check])
ax.grid(True, alpha=0.3, axis='y')

fig.suptitle('Arithmetic Statistics of Graph Jacobians',
             fontsize=15, fontweight='bold', y=1.02)

plt.tight_layout()
plt.savefig('jacobian_distribution.png', dpi=150, bbox_inches='tight')
print("Saved jacobian_distribution.png")


#!/usr/bin/env python3
"""
Visualization: Bosonic Partition Function — Arithmetic Statistics Bridge

Shows the identity between Cohen-Lenstra moments, bosonic partition functions,
and integer partition generating functions. This visualizes the cross-domain
theorem connecting number theory, statistical mechanics, and combinatorics.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def cohen_lenstra_moment(p, k):
    """∏_{i=1}^{k} (1 - p^{-i})^{-1}"""
    result = 1.0
    for i in range(1, k + 1):
        result /= (1.0 - p ** (-i))
    return result


def partition_count(n, k):
    """Number of partitions of n into at most k parts (dynamic programming)."""
    dp = [[0] * (k + 1) for _ in range(n + 1)]
    for j in range(k + 1):
        dp[0][j] = 1
    for i in range(1, n + 1):
        for j in range(1, k + 1):
            dp[i][j] = dp[i][j-1]
            if i >= j:
                dp[i][j] += dp[i-j][j]
    return dp[n][k]


fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Panel 1: Cohen-Lenstra moments for various primes
ax = axes[0, 0]
k_range = range(1, 12)
for p in [2, 3, 5, 7, 11]:
    moments = [cohen_lenstra_moment(p, k) for k in k_range]
    ax.plot(list(k_range), moments, 'o-', linewidth=2, markersize=6,
            label=f'p = {p}')
ax.set_xlabel('k (number of factors)', fontsize=12)
ax.set_ylabel('M(p, k)', fontsize=12)
ax.set_title('Cohen-Lenstra Moments ∏(1 - p⁻ⁱ)⁻¹', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_yscale('log')

# Panel 2: Partition function connection
ax = axes[0, 1]
q_vals = np.linspace(0.1, 0.9, 100)
for k in [1, 2, 3, 5, 10]:
    gen_func = np.array([np.prod([1/(1 - q**i) for i in range(1, k+1)])
                         for q in q_vals])
    ax.plot(q_vals, gen_func, linewidth=2, label=f'k = {k}')
ax.set_xlabel('q', fontsize=12)
ax.set_ylabel('∏(1 - qⁱ)⁻¹', fontsize=12)
ax.set_title('Partition Generating Functions', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_yscale('log')

# Panel 3: Heatmap of moments M(p, k)
ax = axes[1, 0]
primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29]
k_range_heat = range(1, 8)
moment_matrix = np.array([[cohen_lenstra_moment(p, k) for k in k_range_heat]
                           for p in primes])
im = ax.imshow(np.log10(moment_matrix), aspect='auto', cmap='YlOrRd',
               interpolation='nearest')
ax.set_xticks(range(len(list(k_range_heat))))
ax.set_xticklabels([str(k) for k in k_range_heat])
ax.set_yticks(range(len(primes)))
ax.set_yticklabels([str(p) for p in primes])
ax.set_xlabel('k', fontsize=12)
ax.set_ylabel('Prime p', fontsize=12)
ax.set_title('log₁₀ M(p,k) — Moment Heatmap', fontsize=13, fontweight='bold')
plt.colorbar(im, ax=ax, label='log₁₀(moment)')

# Panel 4: Convergence of partial products
ax = axes[1, 1]
for p in [2, 3, 5]:
    k_max = 30
    partial_prods = [cohen_lenstra_moment(p, k) for k in range(1, k_max + 1)]
    # The infinite product converges to ∏_{i=1}^∞ (1 - p^{-i})^{-1}
    limit = cohen_lenstra_moment(p, 50)  # Approximation of limit
    ratios = [pp / limit for pp in partial_prods]
    ax.plot(range(1, k_max + 1), ratios, 'o-', markersize=4, linewidth=1.5,
            label=f'p = {p} (limit ≈ {limit:.4f})')

ax.axhline(y=1.0, color='black', linestyle=':', alpha=0.5)
ax.set_xlabel('k (truncation level)', fontsize=12)
ax.set_ylabel('M(p,k) / M(p,∞)', fontsize=12)
ax.set_title('Convergence to Infinite Product', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_ylim(0.5, 1.05)

fig.suptitle('The Arithmetic–Physics–Combinatorics Bridge\n'
             'Cohen-Lenstra Moments = Bosonic Partition Functions = Partition Generating Functions',
             fontsize=14, fontweight='bold', y=1.02)

plt.tight_layout()
plt.savefig('partition_bridge.png', dpi=150, bbox_inches='tight')
print("Saved partition_bridge.png")
