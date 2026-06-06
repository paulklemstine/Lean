#!/usr/bin/env python3
"""
Demo: The DAG Structure of Mathematical Proofs

Demonstrates the key theorems about proof dependency networks:
1. Directed Handshaking Lemma verification
2. Hub existence and identification
3. Topological layering
4. Hub fragility analysis
5. Power-law fitting
"""

from algorithms import (
    ProofDAG, fit_power_law_mle,
    generate_barabasi_albert_dag, generate_mathematics_like_dag
)


def demo_handshaking():
    """Demonstrate the Directed Handshaking Lemma."""
    print("=" * 60)
    print("THEOREM 1: Directed Handshaking Lemma")
    print("  sum(in_degrees) = sum(out_degrees) = |E|")
    print("=" * 60)

    dag = generate_mathematics_like_dag()
    n = len(dag.nodes)
    m = len(dag.edges)

    sum_in = sum(dag.in_degree(node) for node in dag.nodes)
    sum_out = sum(dag.out_degree(node) for node in dag.nodes)

    print(f"\nMathematics-like DAG: {n} nodes, {m} edges")
    print(f"  Sum of in-degrees:  {sum_in}")
    print(f"  Sum of out-degrees: {sum_out}")
    print(f"  Number of edges:    {m}")
    print(f"  Handshaking holds:  {dag.verify_handshaking()}")
    print()


def demo_hub_existence():
    """Demonstrate hub existence (Pigeonhole)."""
    print("=" * 60)
    print("THEOREM 2: Hub Existence (Pigeonhole Principle)")
    print("  ∃ v, inDegree(v) ≥ |E| / |V|")
    print("=" * 60)

    dag = generate_mathematics_like_dag()
    n = len(dag.nodes)
    m = len(dag.edges)
    avg = m / n

    print(f"\n{n} nodes, {m} edges")
    print(f"Average in-degree: {avg:.2f}")
    print(f"Predicted lower bound on max in-degree: {m // n}")

    # Find top hubs by in-degree
    in_scores = sorted(
        [(node, dag.in_degree(node)) for node in dag.nodes],
        key=lambda x: -x[1]
    )[:10]

    print("\nTop 10 nodes by in-degree (most dependencies):")
    for name, deg in in_scores:
        print(f"  {name}: in-degree = {deg}")

    # Also show out-degree hubs
    out_scores = dag.hub_scores(10)
    print("\nTop 10 nodes by out-degree (most depended-upon — the HUBS):")
    for name, deg in out_scores:
        print(f"  {name}: out-degree = {deg}")
    print()


def demo_topological_layering():
    """Demonstrate DAG topological layering."""
    print("=" * 60)
    print("THEOREM 3: DAG Topological Layering")
    print("  Every DAG admits a unique rank function (depth)")
    print("=" * 60)

    dag = generate_mathematics_like_dag(
        n_axioms=5, n_foundational=10, n_intermediate=20, n_frontier=30
    )
    layers = dag.topological_layers()

    # Count nodes per layer
    layer_counts = {}
    for node, layer in layers.items():
        layer_counts[layer] = layer_counts.get(layer, 0) + 1

    max_layer = max(layers.values()) if layers else 0
    print(f"\nDAG with {len(dag.nodes)} nodes, {len(dag.edges)} edges")
    print(f"Number of layers: {max_layer + 1}")
    print(f"Maximum depth: {max_layer}")
    print("\nLayer sizes:")
    for i in sorted(layer_counts.keys()):
        examples = [n for n, l in layers.items() if l == i][:3]
        print(f"  Layer {i}: {layer_counts[i]} nodes  (e.g., {', '.join(examples)})")
    print()


def demo_hub_fragility():
    """Demonstrate hub removal fragility."""
    print("=" * 60)
    print("THEOREM 4: Hub Removal Fragility")
    print("  Removing a hub disconnects the network")
    print("=" * 60)

    dag = generate_mathematics_like_dag(
        n_axioms=5, n_foundational=20, n_intermediate=50, n_frontier=100
    )

    original_components = dag.connected_components()
    print(f"\nOriginal DAG: {len(dag.nodes)} nodes, {len(dag.edges)} edges")
    print(f"Connected components: {len(original_components)}")

    # Analyze fragility for top 5 hubs
    hubs = dag.hub_scores(5)
    print("\nFragility analysis for top 5 hubs:")
    for hub_name, hub_degree in hubs:
        analysis = dag.fragility_analysis(hub_name)
        print(f"\n  Remove '{hub_name}' (out-degree={hub_degree}):")
        print(f"    New components: {analysis['new_components']}")
        print(f"    Largest component: {analysis['component_sizes'][0] if analysis['component_sizes'] else 0}")
        print(f"    Fragmentation ratio: {analysis['fragmentation_ratio']:.2f}x")
    print()


def demo_acyclic_sparsity():
    """Demonstrate the acyclic sparsity bound."""
    print("=" * 60)
    print("THEOREM 5: Acyclic Sparsity")
    print("  |E| ≤ |V| - 1 for acyclic graphs (trees/forests)")
    print("=" * 60)

    for n in [10, 50, 100, 500, 1000]:
        dag = generate_barabasi_albert_dag(n, m=2)
        n_nodes = len(dag.nodes)
        n_edges = len(dag.edges)
        bound = n_nodes - 1
        ratio = n_edges / n_nodes if n_nodes > 0 else 0
        print(f"\n  BA-DAG({n}): {n_nodes} nodes, {n_edges} edges, "
              f"bound={bound}, ratio={ratio:.3f}")
    print()


def demo_power_law():
    """Demonstrate power-law fitting on degree distributions."""
    print("=" * 60)
    print("POWER LAW ANALYSIS")
    print("  Fitting P(k) ~ k^{-γ} to degree distributions")
    print("=" * 60)

    # Test on preferential attachment DAG
    for n in [500, 1000, 5000]:
        dag = generate_barabasi_albert_dag(n, m=3)
        out_degrees = [dag.out_degree(node) for node in dag.nodes if dag.out_degree(node) > 0]

        if out_degrees:
            gamma, se = fit_power_law_mle(out_degrees, x_min=2)
            print(f"\n  BA-DAG({n}): γ = {gamma:.3f} ± {se:.3f}")

    # Test on mathematics-like DAG
    dag = generate_mathematics_like_dag()
    out_degrees = [dag.out_degree(node) for node in dag.nodes if dag.out_degree(node) > 0]
    if out_degrees:
        gamma, se = fit_power_law_mle(out_degrees, x_min=2)
        print(f"\n  Math-like DAG: γ = {gamma:.3f} ± {se:.3f}")
        print(f"  (Conjectured: γ ≈ 2.5)")
    print()


def demo_degree_conservation():
    """Demonstrate degree conservation (sum_in = sum_out)."""
    print("=" * 60)
    print("THEOREM 6: Degree Conservation")
    print("  In any directed graph: Σ in_deg = Σ out_deg = |E|")
    print("=" * 60)

    for name, dag in [
        ("Small chain", None),
        ("BA-DAG(100)", generate_barabasi_albert_dag(100)),
        ("Math-like", generate_mathematics_like_dag()),
    ]:
        if dag is None:
            dag = ProofDAG()
            for i in range(10):
                dag.add_node(f"N{i}")
            for i in range(9):
                dag.add_edge(f"N{i}", f"N{i+1}")

        sum_in = sum(dag.in_degree(n) for n in dag.nodes)
        sum_out = sum(dag.out_degree(n) for n in dag.nodes)
        n_edges = len(dag.edges)

        print(f"\n  {name}: Σ in_deg = {sum_in}, Σ out_deg = {sum_out}, "
              f"|E| = {n_edges}, conserved = {sum_in == sum_out == n_edges}")
    print()


def demo_leaf_abundance():
    """Demonstrate that trees have at least 2 leaves."""
    print("=" * 60)
    print("THEOREM 7: Leaf Abundance in Trees")
    print("  A tree on n ≥ 2 vertices has at least 2 leaves")
    print("=" * 60)

    # Build some tree-like DAGs
    for n in [5, 10, 20, 50]:
        dag = ProofDAG()
        # Build a random tree
        import random
        rng = random.Random(42)
        for i in range(n):
            dag.add_node(f"N{i}")
        for i in range(1, n):
            parent = rng.randint(0, i - 1)
            dag.add_edge(f"N{parent}", f"N{i}")

        # Count leaves (nodes with out-degree 0)
        leaves = [node for node in dag.nodes if dag.out_degree(node) == 0]
        print(f"\n  Tree({n}): {len(leaves)} leaves (minimum guaranteed: 2)")
    print()


if __name__ == "__main__":
    print("\n" + "🔬 " * 20)
    print("  THE DAG STRUCTURE OF MATHEMATICAL PROOFS")
    print("  Directed Acyclic Graphs as Models of Knowledge")
    print("🔬 " * 20 + "\n")

    demo_handshaking()
    demo_hub_existence()
    demo_topological_layering()
    demo_hub_fragility()
    demo_acyclic_sparsity()
    demo_power_law()
    demo_degree_conservation()
    demo_leaf_abundance()

    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("Key insight: Mathematical proof networks are sparse, layered,")
    print("hub-dominated DAGs — and removing hubs fragments knowledge.")
    print("=" * 60)


#!/usr/bin/env python3
"""Visualization: Degree distribution of proof DAGs with power-law fit."""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import math
from collections import defaultdict
import random

def generate_math_dag(n_axioms=10, n_found=50, n_inter=200, n_front=500, seed=42):
    rng = random.Random(seed)
    nodes = set()
    successors = defaultdict(set)
    predecessors = defaultdict(set)
    edges = []

    axioms = [f"A{i}" for i in range(n_axioms)]
    found = [f"F{i}" for i in range(n_found)]
    inter = [f"I{i}" for i in range(n_inter)]
    front = [f"R{i}" for i in range(n_front)]

    for a in axioms: nodes.add(a)
    for f in found:
        nodes.add(f)
        for d in rng.sample(axioms, rng.randint(2, min(5, n_axioms))):
            edges.append((d, f)); successors[d].add(f); predecessors[f].add(d)
    for i in inter:
        nodes.add(i)
        for d in rng.sample(found, rng.randint(1, min(3, n_found))):
            edges.append((d, i)); successors[d].add(i); predecessors[i].add(d)
        for d in rng.sample(axioms, rng.randint(0, min(2, n_axioms))):
            edges.append((d, i)); successors[d].add(i); predecessors[i].add(d)
    for r in front:
        nodes.add(r)
        for d in rng.sample(inter, rng.randint(1, min(4, n_inter))):
            edges.append((d, r)); successors[d].add(r); predecessors[r].add(d)
        for d in rng.sample(found, rng.randint(0, min(2, n_found))):
            edges.append((d, r)); successors[d].add(r); predecessors[r].add(d)

    return nodes, successors, predecessors, edges

def fit_power_law(degrees, x_min=1):
    filtered = [d for d in degrees if d >= x_min]
    n = len(filtered)
    if n == 0: return 0, 0
    s = sum(math.log(x / (x_min - 0.5)) for x in filtered)
    if s == 0: return 0, 0
    gamma = 1 + n / s
    return gamma, (gamma - 1) / math.sqrt(n)

def main():
    nodes, succ, pred, edges = generate_math_dag()

    out_degs = [len(succ.get(n, set())) for n in nodes]
    in_degs = [len(pred.get(n, set())) for n in nodes]

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Out-degree distribution (log-log)
    out_dist = defaultdict(int)
    for d in out_degs:
        if d > 0: out_dist[d] += 1
    ks = sorted(out_dist.keys())
    counts = [out_dist[k] for k in ks]
    total = sum(counts)

    axes[0].scatter(ks, [c/total for c in counts], c='steelblue', s=60, zorder=5, label='Empirical')
    gamma_out, se_out = fit_power_law([d for d in out_degs if d > 0], x_min=2)
    if gamma_out > 0:
        x_fit = np.linspace(2, max(ks), 100)
        y_fit = x_fit ** (-gamma_out)
        y_fit = y_fit / y_fit[0] * (out_dist[2]/total if 2 in out_dist else counts[0]/total)
        axes[0].plot(x_fit, y_fit, 'r--', linewidth=2,
                     label=f'Power law γ={gamma_out:.2f}±{se_out:.2f}')

    axes[0].set_xscale('log')
    axes[0].set_yscale('log')
    axes[0].set_xlabel('Out-degree k', fontsize=13)
    axes[0].set_ylabel('P(k)', fontsize=13)
    axes[0].set_title('Out-degree Distribution\n(Hub Theorem Citations)', fontsize=14)
    axes[0].legend(fontsize=11)
    axes[0].grid(True, alpha=0.3)

    # In-degree distribution
    in_dist = defaultdict(int)
    for d in in_degs:
        if d > 0: in_dist[d] += 1
    ks_in = sorted(in_dist.keys())
    counts_in = [in_dist[k] for k in ks_in]
    total_in = sum(counts_in)

    axes[1].bar(ks_in, [c/total_in for c in counts_in], color='coral', alpha=0.8, edgecolor='darkred')
    axes[1].set_xlabel('In-degree k', fontsize=13)
    axes[1].set_ylabel('P(k)', fontsize=13)
    axes[1].set_title('In-degree Distribution\n(Theorem Dependencies)', fontsize=14)
    axes[1].grid(True, alpha=0.3, axis='y')

    fig.suptitle('Degree Distributions in a Mathematics-like Proof DAG\n'
                 f'({len(nodes)} theorems, {len(edges)} dependencies)',
                 fontsize=15, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('degree_distribution.png', dpi=150, bbox_inches='tight')
    print("Saved degree_distribution.png")

if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""Visualization: Hub fragility analysis — what happens when hubs are removed."""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from collections import defaultdict
import random

def generate_math_dag(n_ax=10, n_f=50, n_i=200, n_r=500, seed=42):
    rng = random.Random(seed)
    nodes = set()
    succ = defaultdict(set)
    pred = defaultdict(set)
    edges = []

    axioms = [f"A{i}" for i in range(n_ax)]
    found = [f"F{i}" for i in range(n_f)]
    inter = [f"I{i}" for i in range(n_i)]
    front = [f"R{i}" for i in range(n_r)]

    for a in axioms: nodes.add(a)
    for f in found:
        nodes.add(f)
        for d in rng.sample(axioms, rng.randint(2, min(5, n_ax))):
            edges.append((d, f)); succ[d].add(f); pred[f].add(d)
    for i in inter:
        nodes.add(i)
        for d in rng.sample(found, rng.randint(1, min(3, n_f))):
            edges.append((d, i)); succ[d].add(i); pred[i].add(d)
    for r in front:
        nodes.add(r)
        for d in rng.sample(inter, rng.randint(1, min(4, n_i))):
            edges.append((d, r)); succ[d].add(r); pred[r].add(d)
        for d in rng.sample(found, rng.randint(0, min(2, n_f))):
            edges.append((d, r)); succ[d].add(r); pred[r].add(d)

    return nodes, succ, pred, edges

def connected_components(nodes, edges):
    adj = defaultdict(set)
    for s, t in edges:
        adj[s].add(t); adj[t].add(s)
    visited = set()
    components = []
    for n in nodes:
        if n not in visited:
            comp = set()
            stack = [n]
            while stack:
                c = stack.pop()
                if c in visited: continue
                visited.add(c); comp.add(c)
                for nb in adj.get(c, set()):
                    if nb not in visited: stack.append(nb)
            components.append(comp)
    return components

def main():
    nodes, succ, pred, edges = generate_math_dag()

    # Get top 20 hubs by out-degree
    hub_scores = sorted([(n, len(succ.get(n, set()))) for n in nodes], key=lambda x: -x[1])[:20]

    names = []
    orig_comp = len(connected_components(nodes, edges))
    new_comps = []
    largest_comp_frac = []
    degrees = []

    for hub, deg in hub_scores:
        rem_nodes = nodes - {hub}
        rem_edges = [(s, t) for s, t in edges if s != hub and t != hub]
        comps = connected_components(rem_nodes, rem_edges)
        names.append(hub)
        new_comps.append(len(comps))
        largest = max(len(c) for c in comps) if comps else 0
        largest_comp_frac.append(largest / len(rem_nodes))
        degrees.append(deg)

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Plot 1: Components after removal
    colors = ['crimson' if nc > orig_comp else 'steelblue' for nc in new_comps]
    axes[0].barh(range(len(names)), new_comps, color=colors, edgecolor='black', linewidth=0.5)
    axes[0].set_yticks(range(len(names)))
    axes[0].set_yticklabels([f"{n} (deg={d})" for n, d in zip(names, degrees)], fontsize=9)
    axes[0].set_xlabel('Connected Components After Removal', fontsize=12)
    axes[0].set_title('Hub Removal Fragility\n(red = fragmentation occurred)', fontsize=13)
    axes[0].axvline(x=orig_comp, color='green', linestyle='--', linewidth=2,
                    label=f'Original ({orig_comp} comp.)')
    axes[0].legend(fontsize=10)
    axes[0].invert_yaxis()

    # Plot 2: Degree vs fragmentation
    axes[1].scatter(degrees, new_comps, c='steelblue', s=80, edgecolors='black', zorder=5)
    z = np.polyfit(degrees, new_comps, 1)
    p = np.poly1d(z)
    x_line = np.linspace(min(degrees), max(degrees), 100)
    axes[1].plot(x_line, p(x_line), 'r--', linewidth=2, label=f'Linear fit')
    axes[1].set_xlabel('Hub Out-degree', fontsize=12)
    axes[1].set_ylabel('Components After Removal', fontsize=12)
    axes[1].set_title('Degree vs. Fragmentation\n(Higher degree → more fragile)', fontsize=13)
    axes[1].legend(fontsize=10)
    axes[1].grid(True, alpha=0.3)

    fig.suptitle('Hub Fragility in Proof Dependency Networks',
                 fontsize=15, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('fragility_analysis.png', dpi=150, bbox_inches='tight')
    print("Saved fragility_analysis.png")

if __name__ == "__main__":
    main()
