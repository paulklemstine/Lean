#!/usr/bin/env python3
"""
Applications of Proof Architecture Complexity Theory.

Demonstrates real-world applications of walk-count bounds and branching
invariants to proof search, cryptographic analysis, and network routing.
"""

import numpy as np
from typing import List, Tuple, Dict, Set
from collections import defaultdict
import itertools


# ─────────────────────────────────────────────────────────────────────────
# Application 1: Proof Search Budget Estimation
# ─────────────────────────────────────────────────────────────────────────

def estimate_proof_search_budget(
    num_goals: int,
    num_tactics: int,
    max_depth: int,
    branching_factor: float = None
) -> Dict[str, object]:
    """Estimate the search budget for a proof system.
    
    Models a proof system where each goal state has some number of
    applicable tactics, creating a branching proof architecture.
    
    Args:
        num_goals: Number of distinct proof states
        num_tactics: Average number of applicable tactics per state
        max_depth: Maximum proof depth to explore
        branching_factor: Override average branching (default: num_tactics)
    
    Returns:
        Dictionary with search budget estimates
    """
    if branching_factor is None:
        branching_factor = num_tactics
    
    results = {
        'num_goals': num_goals,
        'num_tactics': num_tactics,
        'max_depth': max_depth,
    }
    
    # Upper bound from our theorem
    upper_bounds = []
    cumulative = 0
    for depth in range(max_depth + 1):
        bound = num_goals ** (depth + 1)
        cumulative += bound
        upper_bounds.append({
            'depth': depth,
            'upper_bound': bound,
            'cumulative': cumulative
        })
    
    results['upper_bounds'] = upper_bounds
    results['total_upper_bound'] = cumulative
    
    # Practical estimate using branching factor
    practical_bounds = []
    cumulative_practical = 0
    for depth in range(max_depth + 1):
        est = int(branching_factor ** depth)
        cumulative_practical += est
        practical_bounds.append({
            'depth': depth,
            'estimated_paths': est,
            'cumulative': cumulative_practical
        })
    
    results['practical_bounds'] = practical_bounds
    results['total_practical'] = cumulative_practical
    
    # Search reduction ratio
    if cumulative > 0:
        results['reduction_ratio'] = cumulative_practical / cumulative
    
    return results


# ─────────────────────────────────────────────────────────────────────────
# Application 2: Cryptographic Key Space Analysis
# ─────────────────────────────────────────────────────────────────────────

def analyze_key_space(
    key_bits: int,
    rounds: int,
    branching_per_round: int
) -> Dict[str, object]:
    """Analyze a cryptographic key space as a proof architecture.
    
    Models a block cipher as a directed graph where vertices are
    intermediate states and edges are round transformations.
    
    Args:
        key_bits: Key length in bits
        rounds: Number of cipher rounds
        branching_per_round: Number of distinct transformations per round
    
    Returns:
        Analysis results
    """
    key_space_size = 2 ** key_bits
    
    # Each round creates branching in the attacker's search space
    # Our theorem bounds the total paths
    total_paths_upper = key_space_size ** (rounds + 1)
    branching_paths = branching_per_round ** rounds
    
    # Security margin: ratio of search space to key space
    security_margin = total_paths_upper / key_space_size if key_space_size > 0 else float('inf')
    
    # Effective security (in bits)
    effective_security_bits = np.log2(branching_paths) if branching_paths > 0 else 0
    
    return {
        'key_bits': key_bits,
        'key_space_size': key_space_size,
        'rounds': rounds,
        'branching_per_round': branching_per_round,
        'total_paths_upper_bound': total_paths_upper,
        'attacker_search_paths': branching_paths,
        'effective_security_bits': effective_security_bits,
        'security_margin': security_margin,
    }


# ─────────────────────────────────────────────────────────────────────────
# Application 3: Network Path Diversity
# ─────────────────────────────────────────────────────────────────────────

def analyze_network_diversity(
    num_routers: int,
    connections: List[Tuple[int, int]],
    max_hops: int
) -> Dict[str, object]:
    """Analyze path diversity in a communication network.
    
    Models a network as a digraph and computes walk-count invariants
    for routing analysis.
    
    Args:
        num_routers: Number of routers
        connections: List of directed links (source, target)
        max_hops: Maximum path length to analyze
    
    Returns:
        Network diversity analysis
    """
    # Build adjacency matrix
    A = np.zeros((num_routers, num_routers))
    adj = defaultdict(list)
    for u, v in connections:
        A[u][v] = 1
        adj[u].append(v)
    
    # Branching analysis
    branching_degrees = [len(adj[v]) for v in range(num_routers)]
    max_branching = max(branching_degrees)
    avg_branching = sum(branching_degrees) / num_routers
    
    # Walk counts per hop count
    walk_counts = []
    for k in range(max_hops + 1):
        if k == 0:
            count = num_routers
        else:
            Ak = np.linalg.matrix_power(A, k)
            count = int(round(np.sum(Ak)))
        upper = num_routers ** (k + 1)
        walk_counts.append({
            'hops': k,
            'paths': count,
            'upper_bound': upper,
            'utilization': count / upper if upper > 0 else 0
        })
    
    # Spectral radius for asymptotic growth
    eigenvalues = np.linalg.eigvals(A)
    spectral_radius = float(max(abs(eigenvalues)))
    
    # Find bottleneck vertices (low branching)
    bottlenecks = [v for v in range(num_routers) if branching_degrees[v] <= 1]
    
    return {
        'num_routers': num_routers,
        'num_links': len(connections),
        'max_branching_degree': max_branching,
        'avg_branching_degree': avg_branching,
        'spectral_radius': spectral_radius,
        'walk_counts': walk_counts,
        'bottleneck_vertices': bottlenecks,
        'branching_degrees': branching_degrees,
    }


# ─────────────────────────────────────────────────────────────────────────
# Main: Run all applications
# ─────────────────────────────────────────────────────────────────────────

if __name__ == '__main__':
    print("=" * 70)
    print("APPLICATION 1: Proof Search Budget Estimation")
    print("=" * 70)
    print()
    
    # Scenario: Small proof system
    result = estimate_proof_search_budget(
        num_goals=100,
        num_tactics=5,
        max_depth=4,
        branching_factor=3.2
    )
    
    print(f"Proof system: {result['num_goals']} goals, "
          f"{result['num_tactics']} tactics/goal, "
          f"max depth {result['max_depth']}")
    print()
    print("  Depth | Upper Bound (|V|^(d+1)) | Practical Estimate")
    print("  ------+-------------------------+-------------------")
    for ub, pb in zip(result['upper_bounds'], result['practical_bounds']):
        print(f"  {ub['depth']:5d} | {ub['upper_bound']:23,d} | {pb['estimated_paths']:17,d}")
    print()
    print(f"  Total upper bound:     {result['total_upper_bound']:>20,d}")
    print(f"  Practical estimate:    {result['total_practical']:>20,d}")
    print(f"  Reduction ratio:       {result['reduction_ratio']:.2e}")
    
    print()
    print("=" * 70)
    print("APPLICATION 2: Cryptographic Key Space Analysis")
    print("=" * 70)
    print()
    
    for key_bits in [8, 16, 32]:
        result = analyze_key_space(
            key_bits=key_bits,
            rounds=10,
            branching_per_round=4
        )
        print(f"  {key_bits}-bit key, {result['rounds']} rounds, "
              f"branching={result['branching_per_round']}")
        print(f"    Key space: 2^{key_bits} = {result['key_space_size']:,}")
        print(f"    Attacker paths: {result['attacker_search_paths']:,}")
        print(f"    Effective security: {result['effective_security_bits']:.1f} bits")
        print()
    
    print("=" * 70)
    print("APPLICATION 3: Network Path Diversity")
    print("=" * 70)
    print()
    
    # Small mesh network
    connections = [
        (0, 1), (0, 2), (1, 2), (1, 3), (2, 3), (2, 4),
        (3, 4), (3, 5), (4, 5), (4, 0), (5, 1)
    ]
    result = analyze_network_diversity(
        num_routers=6,
        connections=connections,
        max_hops=5
    )
    
    print(f"  Network: {result['num_routers']} routers, {result['num_links']} links")
    print(f"  Max branching degree: {result['max_branching_degree']}")
    print(f"  Avg branching degree: {result['avg_branching_degree']:.2f}")
    print(f"  Spectral radius: {result['spectral_radius']:.4f}")
    print(f"  Bottleneck vertices: {result['bottleneck_vertices']}")
    print()
    print("  Hops | Paths | Upper Bound | Utilization")
    print("  -----+-------+-------------+------------")
    for wc in result['walk_counts']:
        print(f"  {wc['hops']:4d} | {wc['paths']:5d} | {wc['upper_bound']:11,d} | {wc['utilization']:.4f}")


#!/usr/bin/env python3
"""
Demonstration of Proof Architecture Complexity Theory.

This script demonstrates the main theorems with concrete numerical examples:
1. Universal upper bound on walk counts
2. Branching lower bounds
3. Product architecture walk bounds
4. Branching degree computation
"""

import itertools
from typing import Dict, List, Set, Tuple


def enumerate_walks(vertices: List[int], edges: Set[Tuple[int, int]], length: int) -> List[Tuple[int, ...]]:
    """Enumerate all walks of given length in a digraph.
    
    A walk of length n is a sequence of n+1 vertices where consecutive
    vertices are connected by an edge.
    
    Args:
        vertices: List of vertex labels
        edges: Set of directed edges (u, v)
        length: Walk length (number of edges)
    
    Returns:
        List of walks, each as a tuple of vertices
    """
    if length == 0:
        return [(v,) for v in vertices]
    
    walks = []
    for walk in itertools.product(vertices, repeat=length + 1):
        if all((walk[i], walk[i + 1]) in edges for i in range(length)):
            walks.append(walk)
    return walks


def branching_degree(vertices: List[int], edges: Set[Tuple[int, int]], v: int) -> int:
    """Compute the branching degree of a vertex."""
    return sum(1 for w in vertices if (v, w) in edges)


def has_branching_obstruction(vertices: List[int], edges: Set[Tuple[int, int]]) -> Tuple[bool, ...]:
    """Check if the digraph has a branching obstruction.
    
    Returns (True, v, w1, w2) if found, (False,) otherwise.
    """
    for v in vertices:
        successors = [w for w in vertices if (v, w) in edges]
        if len(successors) >= 2:
            return (True, v, successors[0], successors[1])
    return (False,)


def product_edges(
    v1: List[int], e1: Set[Tuple[int, int]],
    v2: List[int], e2: Set[Tuple[int, int]]
) -> Tuple[List[Tuple[int, int]], Set[Tuple[Tuple[int, int], Tuple[int, int]]]]:
    """Construct the product digraph."""
    prod_vertices = [(a, b) for a in v1 for b in v2]
    prod_edges = set()
    for (a1, b1) in prod_vertices:
        for (a2, b2) in prod_vertices:
            if (a1, a2) in e1 and (b1, b2) in e2:
                prod_edges.add(((a1, b1), (a2, b2)))
    return prod_vertices, prod_edges


# ─────────────────────────────────────────────────────────────────────────
# Demo 1: Universal Upper Bound
# ─────────────────────────────────────────────────────────────────────────
print("=" * 70)
print("DEMO 1: Universal Upper Bound on Walk Counts")
print("=" * 70)
print()
print("Theorem: card(DigraphWalk E n) ≤ (card V)^(n+1)")
print()

# Example: Path graph on 5 vertices
V_path = [0, 1, 2, 3, 4]
E_path = {(i, i + 1) for i in range(4)}

print("Graph: Directed path P₅ = 0 → 1 → 2 → 3 → 4")
print(f"  |V| = {len(V_path)}")
print()

for n in range(5):
    walks = enumerate_walks(V_path, E_path, n)
    upper = len(V_path) ** (n + 1)
    print(f"  Length {n}: {len(walks):6d} walks  ≤  {upper:6d} = {len(V_path)}^{n+1}   "
          f"(ratio = {len(walks)/upper:.4f})")

print()

# Example: Complete digraph on 4 vertices
V_complete = [0, 1, 2, 3]
E_complete = {(i, j) for i in V_complete for j in V_complete}

print("Graph: Complete digraph K₄ (with self-loops)")
print(f"  |V| = {len(V_complete)}")
print()

for n in range(5):
    walks = enumerate_walks(V_complete, E_complete, n)
    upper = len(V_complete) ** (n + 1)
    print(f"  Length {n}: {len(walks):6d} walks  ≤  {upper:6d} = {len(V_complete)}^{n+1}   "
          f"(ratio = {len(walks)/upper:.4f})")
    assert len(walks) == upper, "Complete graph should saturate the bound!"

print()
print("  ✓ Complete graph saturates the bound (ratio = 1.0)")

# ─────────────────────────────────────────────────────────────────────────
# Demo 2: Branching Lower Bound
# ─────────────────────────────────────────────────────────────────────────
print()
print("=" * 70)
print("DEMO 2: Branching Obstruction Lower Bound")
print("=" * 70)
print()
print("Theorem: If ∃ v with two distinct successors, then walk count ≥ 2")
print()

# Diamond graph: 0 → 1, 0 → 2, 1 → 3, 2 → 3
V_diamond = [0, 1, 2, 3]
E_diamond = {(0, 1), (0, 2), (1, 3), (2, 3)}

print("Graph: Diamond  0 → {1, 2} → 3")
print(f"  Edges: {sorted(E_diamond)}")
print()

obs = has_branching_obstruction(V_diamond, E_diamond)
print(f"  Branching obstruction: vertex {obs[1]} has successors {obs[2]} and {obs[3]}")
print()

for n in range(4):
    walks = enumerate_walks(V_diamond, E_diamond, n)
    print(f"  Length {n}: {len(walks)} walks")

# The theorem guarantees ≥ 2 walks at length 1 (DigraphWalk E 1 = walks with 2 vertices)
walks_len1 = enumerate_walks(V_diamond, E_diamond, 1)
assert len(walks_len1) >= 2, "Should have at least 2 walks of length 1!"
print()
print("  ✓ Walk count at length 1 is at least 2 (branching lower bound)")

# ─────────────────────────────────────────────────────────────────────────
# Demo 3: Product Architecture
# ─────────────────────────────────────────────────────────────────────────
print()
print("=" * 70)
print("DEMO 3: Product Architecture Walk Bound")
print("=" * 70)
print()
print("Theorem: card(walks in E₁×E₂) ≤ card(walks in E₁) × card(walks in E₂)")
print()

# Two small graphs
V1 = [0, 1, 2]
E1 = {(0, 1), (1, 2), (0, 2)}

V2 = [0, 1]
E2 = {(0, 1), (1, 0)}

print(f"Graph 1: V = {V1}, E = {sorted(E1)}")
print(f"Graph 2: V = {V2}, E = {sorted(E2)}")
print()

prod_V, prod_E = product_edges(V1, E1, V2, E2)
# Convert for our walk enumeration
prod_V_flat = list(range(len(prod_V)))
prod_V_map = {v: i for i, v in enumerate(prod_V)}
prod_E_flat = {(prod_V_map[a], prod_V_map[b]) for (a, b) in prod_E}

for n in range(4):
    w1 = len(enumerate_walks(V1, E1, n))
    w2 = len(enumerate_walks(V2, E2, n))
    wp = len(enumerate_walks(prod_V_flat, prod_E_flat, n))
    print(f"  Length {n}: product walks = {wp:4d}  ≤  {w1} × {w2} = {w1 * w2:4d}   "
          f"(ratio = {wp / max(1, w1 * w2):.4f})")
    assert wp <= w1 * w2, "Product bound violated!"

print()
print("  ✓ Product bound holds for all tested lengths")

# ─────────────────────────────────────────────────────────────────────────
# Demo 4: Branching Degree
# ─────────────────────────────────────────────────────────────────────────
print()
print("=" * 70)
print("DEMO 4: Branching Degree = One-Step Walk Count")
print("=" * 70)
print()
print("Theorem: card{p : p(0) = v, E(p(0), p(1))} = branchingDegree(v)")
print()

# Use the diamond graph
print("Graph: Diamond  0 → {1, 2} → 3")
print()

for v in V_diamond:
    deg = branching_degree(V_diamond, E_diamond, v)
    # Count one-step walks starting at v
    rooted_walks = [(v, w) for w in V_diamond if (v, w) in E_diamond]
    print(f"  Vertex {v}: branching degree = {deg}, "
          f"one-step walks from {v} = {len(rooted_walks)}  {'✓' if deg == len(rooted_walks) else '✗'}")
    assert deg == len(rooted_walks), "Branching degree should equal rooted walk count!"

print()
print("  ✓ Branching degree equals one-step walk count for all vertices")

# ─────────────────────────────────────────────────────────────────────────
# Summary
# ─────────────────────────────────────────────────────────────────────────
print()
print("=" * 70)
print("SUMMARY: All theorems verified on concrete examples")
print("=" * 70)
print()
print("1. Universal upper bound: card(walks) ≤ |V|^(n+1)           ✓")
print("2. Branching lower bound: obstruction ⟹ walks ≥ 2          ✓")
print("3. Product bound: product walks ≤ walk₁ × walk₂             ✓")
print("4. Branching degree = one-step walk count                    ✓")


#!/usr/bin/env python3
"""Generate PACKAGE.json bundling all artifacts."""

import json

# Load visualization data
with open('viz_data.json', 'r') as f:
    viz_data = json.load(f)

# Load article
with open('ARTICLE.md', 'r') as f:
    article = f.read()

# Load research paper
with open('RESEARCH_PAPER.md', 'r') as f:
    research_paper = f.read()

# Load future directions
with open('FUTURE_DIRECTIONS.md', 'r') as f:
    future_directions = f.read()

# Load Lean proofs
with open('Catalog/Bridges/ProofArchitecture/Basic.lean', 'r') as f:
    lean_proofs = f.read()

# Load Python code
with open('demo.py', 'r') as f:
    demo_code = f.read()

with open('algorithms.py', 'r') as f:
    algorithms_code = f.read()

with open('applications.py', 'r') as f:
    applications_code = f.read()

with open('visualizations.py', 'r') as f:
    viz_code = f.read()

package = {
    "title": "Proof Architecture Complexity: Universal Bounds on Search via Branching Invariants",
    "domain": "Bridges (Category Theory × Proof Complexity × Combinatorics)",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Proof Architecture Theorems Demo",
            "code": demo_code
        },
        {
            "name": "Applications Demo",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Walk Enumeration",
            "pseudocode": "Input: Digraph G = (V, E), length n\nOutput: All walks of length n+1\n\n1. If n = 0, return {(v) : v in V}\n2. For each walk p of length n:\n   For each v in V with E(p[last], v):\n     Append p ++ [v] to result\n3. Return result\n\nComplexity: O(|V|^(n+1)) time and space",
            "code": algorithms_code
        },
        {
            "name": "Branching Obstruction Detection",
            "pseudocode": "Input: Digraph G = (V, E)\nOutput: Branching obstruction witness or None\n\n1. For each v in V:\n   Compute successors S(v) = {w : E(v,w)}\n   If |S(v)| >= 2:\n     Return (v, S(v)[0], S(v)[1])\n2. Return None\n\nComplexity: O(|V| + |E|) time",
            "code": "def has_branching_obstruction(vertices, edges):\n    from collections import defaultdict\n    adj = defaultdict(list)\n    for u, v in edges:\n        adj[u].append(v)\n    for v in vertices:\n        if len(adj[v]) >= 2:\n            return (v, adj[v][0], adj[v][1])\n    return None"
        }
    ],
    "visualizations": [
        {
            "name": "Walk Count Upper Bounds",
            "data": viz_data['walk_bounds']
        },
        {
            "name": "Branching Structure Analysis",
            "data": viz_data['branching']
        },
        {
            "name": "Product Architecture Bounds",
            "data": viz_data['product']
        },
        {
            "name": "Entropy and Spectral Analysis",
            "data": viz_data['entropy']
        }
    ],
    "lean_proofs": lean_proofs
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2)

print(f"PACKAGE.json generated ({len(json.dumps(package)):,} bytes)")


#!/usr/bin/env python3
"""
Generate visualizations for Proof Architecture Complexity Theory.
Saves figures as PNG files and returns base64-encoded data for JSON packaging.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import base64
import io
import json


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    encoded = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{encoded}"


def walk_count_upper_bound_chart():
    """Chart showing walk counts vs upper bound for various graph types."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Left: Different graph sizes with complete graphs
    ax = axes[0]
    lengths = np.arange(0, 8)
    for n in [3, 5, 8, 10]:
        upper = n ** (lengths + 1)
        ax.semilogy(lengths, upper, 'o-', label=f'|V| = {n}', markersize=5)
    ax.set_xlabel('Walk length k', fontsize=12)
    ax.set_ylabel('Upper bound |V|^(k+1)', fontsize=12)
    ax.set_title('Universal Upper Bound on Walk Counts', fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    
    # Right: Actual vs bound for different graph densities
    ax = axes[1]
    n_vertices = 8
    edge_probs = [0.1, 0.3, 0.5, 0.8, 1.0]
    lengths_short = np.arange(0, 6)
    
    np.random.seed(42)
    for p in edge_probs:
        # Generate random adjacency matrix
        A = (np.random.rand(n_vertices, n_vertices) < p).astype(float)
        walk_counts = []
        for k in lengths_short:
            if k == 0:
                walk_counts.append(n_vertices)
            else:
                Ak = np.linalg.matrix_power(A, k)
                walk_counts.append(int(np.sum(Ak)))
        ax.semilogy(lengths_short, walk_counts, 's-', label=f'p = {p}', markersize=5)
    
    upper = n_vertices ** (lengths_short + 1)
    ax.semilogy(lengths_short, upper, 'k--', linewidth=2, label='Upper bound')
    ax.set_xlabel('Walk length k', fontsize=12)
    ax.set_ylabel('Walk count', fontsize=12)
    ax.set_title(f'Walk Counts vs Bound (|V| = {n_vertices}, random)', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    fig.suptitle('Proof Architecture Walk Count Bounds', fontsize=15, fontweight='bold', y=1.02)
    fig.tight_layout()
    return fig


def branching_degree_chart():
    """Chart showing branching degree distribution and its effect on walks."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Left: Branching degree distribution for various graphs
    ax = axes[0]
    np.random.seed(123)
    
    n = 20
    configs = [
        ('Path', [(i, i+1) for i in range(n-1)]),
        ('Binary tree', [(i, 2*i+1) for i in range(n//2)] + [(i, 2*i+2) for i in range(n//2) if 2*i+2 < n]),
        ('Star', [(0, i) for i in range(1, n)]),
    ]
    
    bar_width = 0.25
    x = np.arange(max(n, 20))
    
    for idx, (name, edges) in enumerate(configs):
        adj = {v: [] for v in range(n)}
        for u, v in edges:
            if u < n and v < n:
                adj[u].append(v)
        degrees = [len(adj[v]) for v in range(n)]
        max_deg = max(degrees) + 1
        hist = [degrees.count(d) for d in range(max_deg)]
        ax.bar(np.arange(max_deg) + idx * bar_width, hist, bar_width, label=name, alpha=0.8)
    
    ax.set_xlabel('Branching degree', fontsize=12)
    ax.set_ylabel('Number of vertices', fontsize=12)
    ax.set_title('Branching Degree Distribution', fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3, axis='y')
    
    # Right: One-step walk counts from each vertex
    ax = axes[1]
    
    n_small = 8
    edges_diamond = [(0, 1), (0, 2), (1, 3), (1, 4), (2, 5), (2, 6), (3, 7), (4, 7), (5, 7), (6, 7)]
    adj = {v: [] for v in range(n_small)}
    for u, v in edges_diamond:
        adj[u].append(v)
    
    vertices = list(range(n_small))
    degrees = [len(adj[v]) for v in vertices]
    
    colors = ['#e74c3c' if d >= 2 else '#3498db' for d in degrees]
    bars = ax.bar(vertices, degrees, color=colors, edgecolor='black', alpha=0.85)
    ax.axhline(y=2, color='red', linestyle='--', alpha=0.5, label='Obstruction threshold')
    ax.set_xlabel('Vertex', fontsize=12)
    ax.set_ylabel('Branching degree', fontsize=12)
    ax.set_title('Branching Degree per Vertex\n(red = obstruction)', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3, axis='y')
    
    fig.suptitle('Branching Structure Analysis', fontsize=15, fontweight='bold', y=1.02)
    fig.tight_layout()
    return fig


def product_architecture_chart():
    """Chart showing product architecture walk bounds."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Left: Product walk count vs component product
    ax = axes[0]
    
    np.random.seed(456)
    sizes = [(4, 3), (5, 4), (6, 5), (8, 6)]
    
    for n1, n2 in sizes:
        A1 = (np.random.rand(n1, n1) < 0.4).astype(float)
        A2 = (np.random.rand(n2, n2) < 0.5).astype(float)
        
        # Product adjacency = Kronecker product
        A_prod = np.kron(A1, A2)
        
        lengths = np.arange(0, 5)
        prod_walks = []
        comp_product = []
        
        for k in lengths:
            if k == 0:
                pw = n1 * n2
                cp = n1 * n2
            else:
                pw = int(np.sum(np.linalg.matrix_power(A_prod, k)))
                w1 = int(np.sum(np.linalg.matrix_power(A1, k)))
                w2 = int(np.sum(np.linalg.matrix_power(A2, k)))
                cp = w1 * w2
            prod_walks.append(pw)
            comp_product.append(cp)
        
        ax.plot(lengths, [p/max(c, 1) for p, c in zip(prod_walks, comp_product)],
                'o-', label=f'{n1}×{n2}', markersize=6)
    
    ax.axhline(y=1, color='red', linestyle='--', alpha=0.5, label='Bound')
    ax.set_xlabel('Walk length k', fontsize=12)
    ax.set_ylabel('Ratio (product / component×component)', fontsize=12)
    ax.set_title('Product Walk Bound Tightness', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    # Right: Walk growth comparison
    ax = axes[1]
    
    n = 6
    np.random.seed(789)
    
    A_sparse = (np.random.rand(n, n) < 0.2).astype(float)
    A_dense = (np.random.rand(n, n) < 0.7).astype(float)
    A_complete = np.ones((n, n))
    
    lengths = np.arange(0, 8)
    
    for A, name in [(A_sparse, 'Sparse (p=0.2)'), (A_dense, 'Dense (p=0.7)'), (A_complete, 'Complete')]:
        walks = []
        for k in lengths:
            if k == 0:
                walks.append(n)
            else:
                walks.append(max(1, int(np.sum(np.linalg.matrix_power(A, k)))))
        ax.semilogy(lengths, walks, 'o-', label=name, markersize=5)
    
    upper = n ** (lengths + 1)
    ax.semilogy(lengths, upper, 'k--', linewidth=2, label='Upper bound |V|^(k+1)')
    
    ax.set_xlabel('Walk length k', fontsize=12)
    ax.set_ylabel('Walk count (log scale)', fontsize=12)
    ax.set_title(f'Walk Growth Rate Comparison (|V|={n})', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    fig.suptitle('Compositional and Growth Analysis', fontsize=15, fontweight='bold', y=1.02)
    fig.tight_layout()
    return fig


def entropy_chart():
    """Chart showing topological entropy and spectral radius."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Left: Entropy vs edge density
    ax = axes[0]
    
    n = 10
    np.random.seed(101)
    probs = np.linspace(0.05, 1.0, 20)
    entropies = []
    spectral_radii = []
    
    for p in probs:
        trials = []
        for _ in range(5):
            A = (np.random.rand(n, n) < p).astype(float)
            eigs = np.linalg.eigvals(A)
            rho = max(abs(eigs))
            trials.append(np.log(max(rho, 1e-10)))
        entropies.append(np.mean(trials))
        spectral_radii.append(np.exp(np.mean(trials)))
    
    ax.plot(probs, entropies, 'b-o', markersize=4)
    ax.set_xlabel('Edge probability p', fontsize=12)
    ax.set_ylabel('Topological entropy h = log(ρ)', fontsize=12)
    ax.set_title(f'Entropy vs Edge Density (|V|={n})', fontsize=13)
    ax.grid(True, alpha=0.3)
    
    # Right: Spectral radius vs max branching degree
    ax = axes[1]
    
    np.random.seed(202)
    max_degs = []
    radii = []
    
    for _ in range(100):
        n_v = np.random.randint(5, 15)
        p = np.random.uniform(0.1, 0.9)
        A = (np.random.rand(n_v, n_v) < p).astype(float)
        max_deg = max(A.sum(axis=1))
        rho = max(abs(np.linalg.eigvals(A)))
        max_degs.append(max_deg)
        radii.append(rho)
    
    ax.scatter(max_degs, radii, alpha=0.6, c='steelblue', edgecolors='navy', s=30)
    x_line = np.linspace(0, max(max_degs), 100)
    ax.plot(x_line, x_line, 'r--', label='ρ = max_deg', alpha=0.7)
    ax.set_xlabel('Max branching degree', fontsize=12)
    ax.set_ylabel('Spectral radius ρ', fontsize=12)
    ax.set_title('Spectral Radius vs Max Branching Degree', fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    
    fig.suptitle('Entropy and Spectral Analysis', fontsize=15, fontweight='bold', y=1.02)
    fig.tight_layout()
    return fig


if __name__ == '__main__':
    print("Generating visualizations...")
    
    figs = {
        'walk_bounds': walk_count_upper_bound_chart(),
        'branching': branching_degree_chart(),
        'product': product_architecture_chart(),
        'entropy': entropy_chart(),
    }
    
    # Save as PNG
    for name, fig in figs.items():
        fig.savefig(f'{name}.png', dpi=150, bbox_inches='tight')
        print(f"  Saved {name}.png")
    
    # Generate base64 for JSON
    viz_data = {}
    for name in ['walk_bounds', 'branching', 'product', 'entropy']:
        # Regenerate for base64 (figures were closed)
        if name == 'walk_bounds':
            fig = walk_count_upper_bound_chart()
        elif name == 'branching':
            fig = branching_degree_chart()
        elif name == 'product':
            fig = product_architecture_chart()
        elif name == 'entropy':
            fig = entropy_chart()
        viz_data[name] = fig_to_base64(fig)
    
    # Save visualization data for PACKAGE.json
    with open('viz_data.json', 'w') as f:
        json.dump(viz_data, f)
    
    print("  Saved viz_data.json")
    print("Done!")
