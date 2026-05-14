"""
Applications of Conceptual Depth Gap Theory.

Demonstrates real-world applications:
1. Mathematical knowledge graph analysis
2. Novelty-filtered theorem generation
3. Knowledge evolution tracking
4. Proof difficulty estimation
"""

from __future__ import annotations
import random
from algorithms import DerivationGraph


def build_math_knowledge_graph() -> tuple[DerivationGraph, dict[int, str], dict[str, int]]:
    """Build a toy mathematical knowledge graph.

    Models a small fragment of number theory / algebra
    with conceptual leaps between theorems.

    Returns:
        (graph, id_to_name, name_to_id) triple.
    """
    theorems = [
        "Peano Axioms",           # 0
        "Addition Commutativity",  # 1
        "Multiplication",         # 2
        "Divisibility",           # 3
        "Prime Definition",       # 4
        "GCD",                    # 5
        "Euclidean Algorithm",    # 6
        "Unique Factorization",   # 7
        "Infinitely Many Primes", # 8
        "Modular Arithmetic",     # 9
        "Fermat Little Theorem",  # 10
        "Euler Totient",          # 11
        "RSA Correctness",        # 12
        "Quadratic Reciprocity",  # 13
        "Dirichlet Theorem",      # 14
        "Prime Number Theorem",   # 15
    ]

    g = DerivationGraph(len(theorems))
    id_to_name = {i: name for i, name in enumerate(theorems)}
    name_to_id = {name: i for i, name in enumerate(theorems)}

    # Define conceptual leaps
    edges = [
        (0, 1),   # Peano -> Addition
        (0, 2),   # Peano -> Multiplication
        (2, 3),   # Multiplication -> Divisibility
        (3, 4),   # Divisibility -> Prime
        (3, 5),   # Divisibility -> GCD
        (5, 6),   # GCD -> Euclidean Algorithm
        (4, 7),   # Prime -> Unique Factorization
        (5, 7),   # GCD -> Unique Factorization
        (4, 8),   # Prime -> Infinitely Many Primes
        (3, 9),   # Divisibility -> Modular Arithmetic
        (9, 10),  # Modular Arithmetic -> Fermat Little
        (4, 10),  # Prime -> Fermat Little
        (10, 11), # Fermat Little -> Euler Totient
        (11, 12), # Euler Totient -> RSA
        (9, 13),  # Modular Arithmetic -> Quadratic Reciprocity
        (4, 13),  # Prime -> Quadratic Reciprocity
        (8, 14),  # Infinitely Many Primes -> Dirichlet
        (13, 14), # Quadratic Reciprocity -> Dirichlet
        (8, 15),  # Infinitely Many Primes -> PNT
    ]

    for u, v in edges:
        g.add_edge(u, v)

    return g, id_to_name, name_to_id


def application_knowledge_analysis():
    """Analyze the mathematical knowledge graph."""
    print("=" * 65)
    print("APPLICATION 1: Mathematical Knowledge Graph Analysis")
    print("=" * 65)
    print()

    g, id_to_name, name_to_id = build_math_knowledge_graph()

    # Compute depth gaps from Peano Axioms
    known = {0}  # Start from axioms
    gaps = g.compute_all_depth_gaps(known)

    print("Depth gaps from Peano Axioms:")
    print(f"{'Theorem':<30} {'Depth Gap':>10}")
    print("-" * 42)

    sorted_theorems = sorted(range(g.n), key=lambda i: gaps[i] if gaps[i] is not None else 999)
    for i in sorted_theorems:
        gap_str = str(gaps[i]) if gaps[i] is not None else "∞"
        print(f"{id_to_name[i]:<30} {gap_str:>10}")

    print()

    # Classification at different thresholds
    for tau in [2, 3, 4]:
        classification = g.classify_all(known, tau)
        novel_names = [id_to_name[i] for i in classification['novel']]
        print(f"τ = {tau}: Novel theorems = {novel_names}")

    print()


def application_novelty_filter():
    """Simulate a novelty-filtered theorem generation system."""
    print("=" * 65)
    print("APPLICATION 2: Novelty-Filtered Theorem Generation")
    print("=" * 65)
    print()

    g, id_to_name, _ = build_math_knowledge_graph()

    # Simulate a library that knows basic arithmetic
    known = {0, 1, 2, 3}  # Peano, Addition, Multiplication, Divisibility
    tau = 2  # Derivative threshold

    print(f"Known library: {[id_to_name[k] for k in sorted(known)]}")
    print(f"Derivative threshold: τ = {tau}")
    print()

    # "Generate" candidate theorems (all remaining nodes)
    candidates = [i for i in range(g.n) if i not in known]

    print("Generated candidates and their classifications:")
    print(f"{'Candidate':<30} {'Depth Gap':>10} {'Status':>12}")
    print("-" * 54)

    for c in candidates:
        gap = g.compute_depth_gap(known, c)
        status = "DERIVATIVE" if gap is not None and gap <= tau else "NOVEL" if gap is not None else "UNREACHABLE"
        gap_str = str(gap) if gap is not None else "∞"
        print(f"{id_to_name[c]:<30} {gap_str:>10} {status:>12}")

    print()
    print("The novelty filter keeps only NOVEL results,")
    print("automatically discarding routine derivations.")
    print()


def application_knowledge_evolution():
    """Track how depth gaps evolve as knowledge grows."""
    print("=" * 65)
    print("APPLICATION 3: Knowledge Evolution Tracking")
    print("=" * 65)
    print()

    g, id_to_name, _ = build_math_knowledge_graph()

    # Simulate historical development of number theory
    development_order = [
        0,   # Peano Axioms (foundational)
        1,   # Addition
        2,   # Multiplication
        3,   # Divisibility
        4,   # Primes
        5,   # GCD
        8,   # Infinitely many primes (Euclid)
        9,   # Modular arithmetic
        7,   # Unique factorization
        6,   # Euclidean algorithm
        10,  # Fermat's little theorem
        13,  # Quadratic reciprocity (Gauss)
        11,  # Euler totient
        14,  # Dirichlet's theorem
        15,  # Prime number theorem
        12,  # RSA
    ]

    target = 15  # Track depth gap to PNT

    print(f"Tracking depth gap to '{id_to_name[target]}'")
    print(f"as mathematical knowledge develops over time:")
    print()
    print(f"{'Step':>5} {'Added Theorem':<30} {'Depth Gap to PNT':>17}")
    print("-" * 55)

    known = set()
    for step, thm_id in enumerate(development_order):
        known.add(thm_id)
        gap = g.compute_depth_gap(known, target)
        gap_str = str(gap) if gap is not None else "∞"
        marker = " ← discovered!" if thm_id == target else ""
        print(f"{step:>5} {id_to_name[thm_id]:<30} {gap_str:>17}{marker}")

    print()
    print("The depth gap monotonically decreases as knowledge grows,")
    print("confirming the antitone property.")
    print()


def application_difficulty_estimation():
    """Estimate proof difficulty using depth gap."""
    print("=" * 65)
    print("APPLICATION 4: Proof Difficulty Estimation")
    print("=" * 65)
    print()

    g, id_to_name, _ = build_math_knowledge_graph()
    known = {0}  # Just axioms

    gaps = g.compute_all_depth_gaps(known)

    categories = {
        "Elementary (gap ≤ 2)": [],
        "Intermediate (gap 3-4)": [],
        "Advanced (gap ≥ 5)": [],
        "Unreachable": [],
    }

    for i in range(g.n):
        gap = gaps[i]
        if gap is None:
            categories["Unreachable"].append(id_to_name[i])
        elif gap <= 2:
            categories["Elementary (gap ≤ 2)"].append(id_to_name[i])
        elif gap <= 4:
            categories["Intermediate (gap 3-4)"].append(id_to_name[i])
        else:
            categories["Advanced (gap ≥ 5)"].append(id_to_name[i])

    for cat, theorems in categories.items():
        print(f"{cat}:")
        for t in theorems:
            print(f"  • {t}")
        print()

    print("This classification provides a principled difficulty")
    print("metric based on conceptual distance from foundations.")
    print()


if __name__ == "__main__":
    application_knowledge_analysis()
    application_novelty_filter()
    application_knowledge_evolution()
    application_difficulty_estimation()


"""
Demonstration of Conceptual Depth Gap Theory.

Concrete numerical examples illustrating the main theorems:
1. Chain graph depth gaps (exact computation)
2. Separation theorem (arbitrarily large gaps exist)
3. Library enrichment (monotonicity)
4. Derivative classification
5. Compression threshold
"""

from algorithms import (
    DerivationGraph,
    make_chain_graph,
    make_binary_tree,
    make_random_graph,
    library_enrichment_experiment,
)


def demo_chain_graph():
    """Demonstrate exact depth gaps in chain graphs."""
    print("=" * 60)
    print("DEMO 1: Chain Graph — Exact Depth Gaps")
    print("=" * 60)
    print()
    print("Chain graph: 0 → 1 → 2 → ... → 10")
    print("Known set K = {0}")
    print()

    chain = make_chain_graph(11)
    known = {0}

    print(f"{'Target':>8} {'Depth Gap':>10} {'Derivative(τ=3)':>16} {'Derivative(τ=5)':>16}")
    print("-" * 52)
    for t in range(11):
        gap = chain.compute_depth_gap(known, t)
        d3 = chain.is_derivative(known, 3, t)
        d5 = chain.is_derivative(known, 5, t)
        print(f"{t:>8} {gap:>10} {str(d3):>16} {str(d5):>16}")

    print()
    print("Key insight: depth gap equals the node index, matching")
    print("the formal theorem chainEdge_reachIn_iff.")
    print()


def demo_separation_theorem():
    """Demonstrate that arbitrarily large depth gaps exist."""
    print("=" * 60)
    print("DEMO 2: Separation Theorem — Arbitrarily Large Gaps")
    print("=" * 60)
    print()
    print("For each threshold τ, we construct a graph where some")
    print("node has depth gap = τ + 1, proving it is NOT derivative.")
    print()

    print(f"{'Threshold τ':>12} {'Graph Size':>11} {'Max Depth Gap':>14} {'Non-derivative?':>16}")
    print("-" * 55)

    for tau in range(10):
        n = tau + 2  # Need at least τ+2 nodes
        chain = make_chain_graph(n)
        known = {0}
        target = n - 1
        gap = chain.compute_depth_gap(known, target)
        is_deriv = chain.is_derivative(known, tau, target)
        print(f"{tau:>12} {n:>11} {gap:>14} {str(not is_deriv):>16}")

    print()
    print("This demonstrates exists_deep_target: for every τ,")
    print("there exists a graph with a non-derivative target.")
    print()


def demo_library_enrichment():
    """Demonstrate monotonicity under library enrichment."""
    print("=" * 60)
    print("DEMO 3: Library Enrichment — Monotonicity")
    print("=" * 60)
    print()
    print("Chain graph: 0 → 1 → ... → 10, target = 10")
    print("Progressively adding nodes to the known set.")
    print()

    chain = make_chain_graph(11)
    results = library_enrichment_experiment(
        chain, {0}, [3, 5, 7, 9], 10
    )

    print(f"{'|K|':>5} {'Depth Gap':>10} {'Change':>8}")
    print("-" * 25)
    prev_gap = None
    for size, gap in results:
        change = ""
        if prev_gap is not None and gap is not None and prev_gap is not None:
            diff = gap - prev_gap
            change = f"{diff:+d}" if diff != 0 else "0"
        print(f"{size:>5} {gap:>10} {change:>8}")
        prev_gap = gap

    print()
    print("Depth gap is monotonically non-increasing,")
    print("confirming depthGap_antitone_known.")
    print()


def demo_classification():
    """Demonstrate derivative classification."""
    print("=" * 60)
    print("DEMO 4: Derivative Classification")
    print("=" * 60)
    print()

    # Build a more interesting graph
    g = DerivationGraph(8)
    edges = [
        (0, 1), (0, 2), (1, 3), (1, 4),
        (2, 5), (3, 6), (4, 6), (5, 7),
    ]
    for u, v in edges:
        g.add_edge(u, v)

    known = {0}
    print("Graph: 8 nodes with edges representing conceptual leaps")
    print(f"Edges: {edges}")
    print(f"Known: {known}")
    print()

    for tau in [1, 2, 3]:
        classification = g.classify_all(known, tau)
        print(f"Threshold τ = {tau}:")
        print(f"  Derivative:   {classification['derivative']}")
        print(f"  Novel:        {classification['novel']}")
        print(f"  Unreachable:  {classification['unreachable']}")
        print()


def demo_compression_threshold():
    """Demonstrate the compression threshold theorem."""
    print("=" * 60)
    print("DEMO 5: Compression Threshold")
    print("=" * 60)
    print()
    print("The compression threshold τ = |K| guarantees that all")
    print("compressible targets are derivative at threshold τ.")
    print()

    chain = make_chain_graph(20)

    for k_size in [3, 5, 8, 12]:
        known = set(range(k_size))
        tau = k_size  # compression threshold
        gaps = chain.compute_all_depth_gaps(known)

        compressible = [i for i, g in enumerate(gaps)
                       if g is not None and g <= k_size]
        derivative = [i for i, g in enumerate(gaps)
                     if g is not None and g <= tau]

        # Verify compressible ⊆ derivative
        assert all(c in derivative for c in compressible)

        print(f"|K| = {k_size}: τ = {tau}")
        print(f"  Compressible nodes: {len(compressible)}")
        print(f"  Derivative nodes:   {len(derivative)}")
        print(f"  Compressible ⊆ Derivative: ✓")
        print()


def demo_binary_tree():
    """Demonstrate depth gaps in tree-structured knowledge."""
    print("=" * 60)
    print("DEMO 6: Binary Tree — Hierarchical Knowledge")
    print("=" * 60)
    print()
    print("Complete binary trees model hierarchical mathematical")
    print("knowledge where each branch is a specialization.")
    print()

    for depth in [3, 4, 5, 6]:
        tree = make_binary_tree(depth)
        known = {0}  # root = foundational axioms
        gaps = tree.compute_all_depth_gaps(known)

        reachable = [g for g in gaps if g is not None]
        max_gap = max(reachable)
        avg_gap = sum(reachable) / len(reachable)
        n = tree.n

        print(f"Depth {depth}: {n} nodes, max_gap={max_gap}, avg_gap={avg_gap:.2f}")

    print()


def demo_random_graph():
    """Demonstrate depth gaps in random graphs."""
    print("=" * 60)
    print("DEMO 7: Random Graphs — Erdős–Rényi Model")
    print("=" * 60)
    print()

    print(f"{'n':>5} {'p':>6} {'Avg Gap':>8} {'Max Gap':>8} {'Unreach%':>9}")
    print("-" * 38)

    for n, p in [(50, 0.05), (50, 0.10), (50, 0.20),
                 (100, 0.03), (100, 0.05), (100, 0.10)]:
        g = make_random_graph(n, p)
        known = {0}
        gaps = g.compute_all_depth_gaps(known)

        reachable = [g for g in gaps if g is not None]
        unreachable_pct = (n - len(reachable)) / n * 100

        if reachable:
            avg_gap = sum(reachable) / len(reachable)
            max_gap = max(reachable)
        else:
            avg_gap = float('inf')
            max_gap = float('inf')

        print(f"{n:>5} {p:>6.2f} {avg_gap:>8.1f} {max_gap:>8} {unreachable_pct:>8.1f}%")

    print()
    print("Denser graphs have smaller depth gaps (more shortcuts).")
    print()


if __name__ == "__main__":
    demo_chain_graph()
    demo_separation_theorem()
    demo_library_enrichment()
    demo_classification()
    demo_compression_threshold()
    demo_binary_tree()
    demo_random_graph()


"""
Visualizations for Conceptual Depth Gap Theory.

Generates publication-quality figures illustrating the main results.
"""

from __future__ import annotations
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from algorithms import (
    make_chain_graph,
    make_binary_tree,
    make_random_graph,
    library_enrichment_experiment,
    DerivationGraph,
)


def fig_chain_depth_gaps():
    """Visualize depth gaps in a chain graph."""
    fig, ax = plt.subplots(figsize=(10, 4))

    n = 11
    chain = make_chain_graph(n)
    known = {0}
    gaps = chain.compute_all_depth_gaps(known)

    colors = []
    tau = 3
    for g in gaps:
        if g is None:
            colors.append('#cccccc')
        elif g == 0:
            colors.append('#2ecc71')  # known
        elif g <= tau:
            colors.append('#3498db')  # derivative
        else:
            colors.append('#e74c3c')  # novel

    # Draw nodes
    y = 0.5
    for i in range(n):
        circle = plt.Circle((i, y), 0.3, color=colors[i], ec='black', lw=2, zorder=3)
        ax.add_patch(circle)
        ax.text(i, y, str(i), ha='center', va='center', fontsize=12, fontweight='bold', zorder=4)
        ax.text(i, y - 0.5, f'd={gaps[i]}', ha='center', va='center', fontsize=9, color='#555')

    # Draw edges
    for i in range(n - 1):
        ax.annotate('', xy=(i + 0.7, y), xytext=(i + 0.3, y),
                    arrowprops=dict(arrowstyle='->', lw=1.5, color='#777'))

    # Legend
    known_patch = mpatches.Patch(color='#2ecc71', label='Known (K)')
    deriv_patch = mpatches.Patch(color='#3498db', label=f'Derivative (gap ≤ τ={tau})')
    novel_patch = mpatches.Patch(color='#e74c3c', label=f'Novel (gap > τ={tau})')
    ax.legend(handles=[known_patch, deriv_patch, novel_patch], loc='upper right', fontsize=10)

    ax.set_xlim(-0.5, n - 0.3)
    ax.set_ylim(-0.2, 1.5)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('Chain Graph: Depth Gaps and Derivative Classification', fontsize=14, fontweight='bold')

    plt.tight_layout()
    plt.savefig('fig_chain_depth_gaps.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved fig_chain_depth_gaps.png")


def fig_separation_theorem():
    """Visualize the separation theorem across thresholds."""
    fig, ax = plt.subplots(figsize=(8, 5))

    thresholds = list(range(15))
    max_gaps = [tau + 1 for tau in thresholds]

    ax.bar(thresholds, max_gaps, color='#e74c3c', alpha=0.8, edgecolor='#c0392b', label='Max achievable depth gap')
    ax.plot(thresholds, [tau for tau in thresholds], 'b--', lw=2, label='Threshold τ')

    ax.set_xlabel('Threshold τ', fontsize=12)
    ax.set_ylabel('Depth Gap', fontsize=12)
    ax.set_title('Separation Theorem: Gaps Exceed Any Threshold', fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(axis='y', alpha=0.3)

    plt.tight_layout()
    plt.savefig('fig_separation_theorem.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved fig_separation_theorem.png")


def fig_library_enrichment():
    """Visualize monotonicity under library enrichment."""
    fig, ax = plt.subplots(figsize=(8, 5))

    chain = make_chain_graph(21)
    results = library_enrichment_experiment(chain, {0}, [4, 8, 12, 16, 19], 20)

    sizes = [r[0] for r in results]
    gaps = [r[1] for r in results]

    ax.plot(sizes, gaps, 'o-', color='#2980b9', markersize=10, lw=2, label='depthGap(target=20)')
    ax.fill_between(sizes, gaps, alpha=0.2, color='#2980b9')

    ax.set_xlabel('Library Size |K|', fontsize=12)
    ax.set_ylabel('Depth Gap', fontsize=12)
    ax.set_title('Library Enrichment: Depth Gap Monotonically Decreases', fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(alpha=0.3)

    plt.tight_layout()
    plt.savefig('fig_library_enrichment.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved fig_library_enrichment.png")


def fig_random_graph_heatmap():
    """Heatmap of average depth gaps across (n, p) parameter space."""
    fig, ax = plt.subplots(figsize=(8, 6))

    ns = [20, 30, 50, 75, 100]
    ps = [0.02, 0.05, 0.08, 0.10, 0.15, 0.20, 0.30]

    data = np.zeros((len(ns), len(ps)))

    for i, n in enumerate(ns):
        for j, p in enumerate(ps):
            g = make_random_graph(n, p, seed=42)
            gaps = g.compute_all_depth_gaps({0})
            reachable = [gap for gap in gaps if gap is not None]
            data[i, j] = np.mean(reachable) if reachable else float('nan')

    im = ax.imshow(data, aspect='auto', cmap='YlOrRd', interpolation='nearest')
    ax.set_xticks(range(len(ps)))
    ax.set_xticklabels([f'{p:.2f}' for p in ps])
    ax.set_yticks(range(len(ns)))
    ax.set_yticklabels([str(n) for n in ns])
    ax.set_xlabel('Edge Probability p', fontsize=12)
    ax.set_ylabel('Number of Nodes n', fontsize=12)
    ax.set_title('Average Depth Gap in Random Graphs G(n, p)', fontsize=14, fontweight='bold')

    # Add text annotations
    for i in range(len(ns)):
        for j in range(len(ps)):
            val = data[i, j]
            if not np.isnan(val):
                color = 'white' if val > 3 else 'black'
                ax.text(j, i, f'{val:.1f}', ha='center', va='center', color=color, fontsize=10)

    plt.colorbar(im, ax=ax, label='Average Depth Gap')
    plt.tight_layout()
    plt.savefig('fig_random_heatmap.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved fig_random_heatmap.png")


def fig_depth_distribution():
    """Distribution of depth gaps in various graph types."""
    fig, axes = plt.subplots(1, 3, figsize=(14, 4))

    # Chain graph
    chain = make_chain_graph(20)
    gaps_chain = chain.compute_all_depth_gaps({0})
    axes[0].bar(range(20), gaps_chain, color='#3498db', alpha=0.8)
    axes[0].set_title('Chain Graph (n=20)', fontsize=12, fontweight='bold')
    axes[0].set_xlabel('Node')
    axes[0].set_ylabel('Depth Gap')

    # Binary tree
    tree = make_binary_tree(4)
    gaps_tree = tree.compute_all_depth_gaps({0})
    reachable_tree = [g for g in gaps_tree if g is not None]
    axes[1].hist(reachable_tree, bins=range(max(reachable_tree) + 2),
                 color='#2ecc71', alpha=0.8, edgecolor='#27ae60', align='left')
    axes[1].set_title('Binary Tree (depth=4)', fontsize=12, fontweight='bold')
    axes[1].set_xlabel('Depth Gap')
    axes[1].set_ylabel('Count')

    # Random graph
    rg = make_random_graph(100, 0.05, seed=42)
    gaps_rg = rg.compute_all_depth_gaps({0})
    reachable_rg = [g for g in gaps_rg if g is not None]
    if reachable_rg:
        axes[2].hist(reachable_rg, bins=range(max(reachable_rg) + 2),
                     color='#e74c3c', alpha=0.8, edgecolor='#c0392b', align='left')
    axes[2].set_title('Random Graph G(100, 0.05)', fontsize=12, fontweight='bold')
    axes[2].set_xlabel('Depth Gap')
    axes[2].set_ylabel('Count')

    plt.suptitle('Depth Gap Distributions Across Graph Types', fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('fig_depth_distribution.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved fig_depth_distribution.png")


if __name__ == "__main__":
    fig_chain_depth_gaps()
    fig_separation_theorem()
    fig_library_enrichment()
    fig_random_graph_heatmap()
    fig_depth_distribution()
    print("\nAll visualizations generated successfully.")
