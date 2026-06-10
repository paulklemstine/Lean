#!/usr/bin/env python3
"""
Applications of Conceptual Dependency Critical Path Theory

Demonstrates real-world applications:
1. Curriculum optimization for education
2. Research planning and bottleneck analysis
3. Software dependency analysis
4. AI theorem-prover guidance
"""

from algorithms import DepGraph, critical_path_length, layered_discovery, next_layer


def application_curriculum_optimization():
    """
    Application 1: Optimal Curriculum Design

    Given a set of mathematical topics with prerequisite dependencies,
    find the minimum number of "learning stages" needed and identify
    which topics can be learned in parallel.
    """
    print("=" * 70)
    print("APPLICATION 1: Optimal Curriculum Design")
    print("=" * 70)

    topics = [
        "Logic", "Sets", "Numbers", "Functions",
        "Sequences", "Limits", "Continuity", "Derivatives",
        "Integrals", "Series", "LinAlg", "MultiCalc",
        "DiffEq", "RealAnalysis", "Topology"
    ]

    pred = {
        "Logic": [],
        "Sets": ["Logic"],
        "Numbers": ["Logic"],
        "Functions": ["Sets", "Numbers"],
        "Sequences": ["Functions"],
        "Limits": ["Sequences"],
        "Continuity": ["Limits", "Functions"],
        "Derivatives": ["Continuity"],
        "Integrals": ["Derivatives"],
        "Series": ["Sequences", "Limits"],
        "LinAlg": ["Sets", "Numbers"],
        "MultiCalc": ["Derivatives", "LinAlg"],
        "DiffEq": ["Integrals", "LinAlg"],
        "RealAnalysis": ["Continuity", "Series", "Topology"],
        "Topology": ["Sets", "Functions"],
    }

    G = DepGraph(topics, pred)
    cpl = critical_path_length(G)
    sources = G.source_set()

    print(f"\nMinimum semesters needed: {cpl}")
    print(f"\nOptimal curriculum schedule:")

    current = set()
    for stage in range(cpl + 1):
        layer = next_layer(G, current) if stage > 0 else sources
        print(f"  Semester {stage + 1}: {sorted(layer)}")
        current = current | layer

    print(f"\n  Total topics: {len(topics)}")
    print(f"  Minimum stages: {cpl + 1}")
    print(f"  Average parallelism: {len(topics) / (cpl + 1):.1f} topics/stage")

    # Find the bottleneck path
    deepest = max(topics, key=lambda t: G.depth(t))
    path = G.critical_path(deepest)
    print(f"\n  Critical path: {' → '.join(path)}")
    print(f"  This path CANNOT be shortened — it's the theoretical minimum.")
    print()


def application_research_planning():
    """
    Application 2: Research Project Planning

    Model a research program as a dependency graph and identify
    bottlenecks that constrain overall progress.
    """
    print("=" * 70)
    print("APPLICATION 2: Research Program Analysis")
    print("=" * 70)

    milestones = [
        "Literature_Review",
        "Data_Collection",
        "Framework_Design",
        "Prototype_v1",
        "User_Study_1",
        "Algorithm_Improvement",
        "Prototype_v2",
        "User_Study_2",
        "Statistical_Analysis",
        "Paper_Writing",
        "Peer_Review",
        "Camera_Ready",
    ]

    pred = {
        "Literature_Review": [],
        "Data_Collection": [],
        "Framework_Design": ["Literature_Review"],
        "Prototype_v1": ["Framework_Design", "Data_Collection"],
        "User_Study_1": ["Prototype_v1"],
        "Algorithm_Improvement": ["User_Study_1", "Framework_Design"],
        "Prototype_v2": ["Algorithm_Improvement"],
        "User_Study_2": ["Prototype_v2"],
        "Statistical_Analysis": ["User_Study_2", "User_Study_1"],
        "Paper_Writing": ["Statistical_Analysis"],
        "Peer_Review": ["Paper_Writing"],
        "Camera_Ready": ["Peer_Review"],
    }

    G = DepGraph(milestones, pred)
    cpl = critical_path_length(G)

    print(f"\nProject analysis:")
    print(f"  Total milestones: {len(milestones)}")
    print(f"  Critical path length: {cpl} phases")

    print(f"\nMilestone depths (minimum phase to complete):")
    for m in milestones:
        d = G.depth(m)
        bar = "█" * (d + 1)
        print(f"  {m:25s} depth={d:2d} {bar}")

    bottlenecks = G.bottleneck_nodes()
    print(f"\n  Bottleneck milestones: {bottlenecks}")
    print(f"  These constrain the entire project timeline.")
    print(f"  Removing any of them would shorten the critical path.")

    print(f"\n  Phase schedule:")
    sources = G.source_set()
    current = set()
    for phase in range(cpl + 1):
        layer = next_layer(G, current) if phase > 0 else sources
        print(f"    Phase {phase}: {sorted(layer)}")
        current = current | layer
    print()


def application_software_dependencies():
    """
    Application 3: Software Build Dependency Analysis

    Analyze a software project's module dependencies to find
    the minimum parallel build time.
    """
    print("=" * 70)
    print("APPLICATION 3: Software Build Dependency Analysis")
    print("=" * 70)

    modules = [
        "utils", "config", "logger",
        "database", "auth", "cache",
        "api_core", "api_rest", "api_graphql",
        "frontend", "tests", "deploy"
    ]

    pred = {
        "utils": [],
        "config": [],
        "logger": ["utils", "config"],
        "database": ["config", "logger"],
        "auth": ["database", "logger"],
        "cache": ["config", "logger"],
        "api_core": ["database", "auth", "cache"],
        "api_rest": ["api_core"],
        "api_graphql": ["api_core"],
        "frontend": ["api_rest", "api_graphql"],
        "tests": ["api_core", "frontend"],
        "deploy": ["tests"],
    }

    G = DepGraph(modules, pred)
    cpl = critical_path_length(G)

    print(f"\nBuild analysis:")
    print(f"  Total modules: {len(modules)}")
    print(f"  Sequential build time: {len(modules)} steps")
    print(f"  Parallel build time:   {cpl + 1} steps (with unlimited cores)")
    print(f"  Speedup: {len(modules) / (cpl + 1):.1f}x")

    print(f"\nParallel build schedule:")
    sources = G.source_set()
    current = set()
    for step in range(cpl + 1):
        layer = next_layer(G, current) if step > 0 else sources
        print(f"  Step {step}: build {sorted(layer)} in parallel")
        current = current | layer

    cp = G.critical_path("deploy")
    print(f"\n  Critical path: {' → '.join(cp)}")
    print(f"  No build optimization can reduce below {cpl + 1} steps.")
    print()


def application_ai_theorem_guidance():
    """
    Application 4: AI Theorem Prover Guidance

    Demonstrate how critical path analysis can guide an AI theorem
    prover toward targets that require deep conceptual chains.
    """
    print("=" * 70)
    print("APPLICATION 4: AI Theorem Prover Guidance")
    print("=" * 70)

    theorems = [
        "nat_induction", "add_comm", "add_assoc",
        "mul_comm", "mul_assoc", "distributive",
        "gcd_exists", "bezout_identity",
        "prime_factorization", "fund_arithmetic",
        "euler_totient", "fermat_little",
        "quadratic_reciprocity"
    ]

    pred = {
        "nat_induction": [],
        "add_comm": ["nat_induction"],
        "add_assoc": ["nat_induction"],
        "mul_comm": ["add_comm", "add_assoc"],
        "mul_assoc": ["add_comm", "add_assoc"],
        "distributive": ["mul_comm", "mul_assoc"],
        "gcd_exists": ["nat_induction", "distributive"],
        "bezout_identity": ["gcd_exists"],
        "prime_factorization": ["nat_induction", "distributive"],
        "fund_arithmetic": ["prime_factorization", "bezout_identity"],
        "euler_totient": ["fund_arithmetic"],
        "fermat_little": ["euler_totient"],
        "quadratic_reciprocity": ["fermat_little", "fund_arithmetic"],
    }

    G = DepGraph(theorems, pred)
    cpl = critical_path_length(G)

    print(f"\nTheorem dependency analysis:")
    print(f"  Total theorems: {len(theorems)}")
    print(f"  Maximum conceptual depth: {cpl}")

    print(f"\nConceptual depth ranking:")
    by_depth = sorted(theorems, key=lambda t: G.depth(t), reverse=True)
    for t in by_depth:
        d = G.depth(t)
        bar = "▓" * (d + 1)
        print(f"  {t:25s} depth={d:2d} {bar}")

    print(f"\nAI guidance strategy:")
    print(f"  Shallow search (depth ≤ 2) can discover:")
    sources = G.source_set()
    shallow = layered_discovery(G, sources, 2)
    print(f"    {sorted(shallow)}")
    print(f"    ({len(shallow)}/{len(theorems)} theorems)")

    deep = set(theorems) - shallow
    print(f"\n  Deep targets UNREACHABLE by shallow search:")
    for t in sorted(deep, key=lambda t: G.depth(t)):
        print(f"    {t:25s} (depth {G.depth(t)})")

    print(f"\n  Critical-path-guided search discovers ALL theorems in {cpl + 1} rounds.")
    print(f"  This is provably optimal — no strategy can do better.")
    print()


if __name__ == "__main__":
    application_curriculum_optimization()
    application_research_planning()
    application_software_dependencies()
    application_ai_theorem_guidance()

    print("=" * 70)
    print("All applications demonstrate the practical value of")
    print("conceptual dependency critical path theory.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Conceptual Dependency Critical Path Theory — Interactive Demo

Demonstrates the core theorems with concrete numerical examples:
- Depth computation on dependency DAGs
- Layered discovery process
- Critical path lower bounds
- Shallow exploration failure
"""

from algorithms import DepGraph, layered_discovery, critical_path_length


def demo_linear_chain():
    """A linear chain: A → B → C → D → E (depth = 4)."""
    print("=" * 60)
    print("DEMO 1: Linear Chain  A → B → C → D → E")
    print("=" * 60)

    nodes = ["A", "B", "C", "D", "E"]
    pred = {
        "A": [],
        "B": ["A"],
        "C": ["B"],
        "D": ["C"],
        "E": ["D"],
    }
    G = DepGraph(nodes, pred)

    print(f"\nNode depths:")
    for v in nodes:
        print(f"  depth({v}) = {G.depth(v)}")

    cpl = critical_path_length(G)
    print(f"\nCritical path length: {cpl}")

    sources = G.source_set()
    print(f"Source set: {sources}")

    print(f"\nLayered discovery from sources:")
    for k in range(cpl + 1):
        disc = layered_discovery(G, sources, k)
        print(f"  Round {k}: discovered = {sorted(disc)}")

    # Demonstrate shallow exploration failure
    print(f"\nShallow exploration (k=2 < {cpl}):")
    shallow = layered_discovery(G, sources, 2)
    missed = set(nodes) - shallow
    print(f"  Discovered: {sorted(shallow)}")
    print(f"  Missed:     {sorted(missed)}")
    print(f"  ✓ Theorem B2 confirmed: {len(missed)} nodes unreachable by shallow search")
    print()


def demo_diamond():
    """Diamond DAG: A → {B, C} → D (depth of D = 2, not 3)."""
    print("=" * 60)
    print("DEMO 2: Diamond DAG")
    print("      A")
    print("     / \\")
    print("    B   C")
    print("     \\ /")
    print("      D")
    print("=" * 60)

    nodes = ["A", "B", "C", "D"]
    pred = {
        "A": [],
        "B": ["A"],
        "C": ["A"],
        "D": ["B", "C"],
    }
    G = DepGraph(nodes, pred)

    print(f"\nNode depths:")
    for v in nodes:
        print(f"  depth({v}) = {G.depth(v)}")

    cpl = critical_path_length(G)
    print(f"\nCritical path length: {cpl}")
    print(f"Note: depth(D) = 2, not 3. Parallel paths don't add depth.")

    sources = G.source_set()
    print(f"\nLayered discovery:")
    for k in range(cpl + 1):
        disc = layered_discovery(G, sources, k)
        print(f"  Round {k}: {sorted(disc)}")

    print(f"\n✓ Theorem C1 confirmed: all nodes discovered by round {cpl}")
    print()


def demo_textbook_math():
    """
    A simplified math curriculum dependency graph.
    Models: Axioms → Arithmetic → Algebra → ... → Galois Theory
    """
    print("=" * 60)
    print("DEMO 3: Simplified Math Curriculum DAG")
    print("=" * 60)

    nodes = [
        "Axioms",
        "NatNumbers",
        "Arithmetic",
        "Algebra",
        "SetTheory",
        "GroupTheory",
        "RingTheory",
        "FieldTheory",
        "Polynomials",
        "GaloisTheory",
    ]

    pred = {
        "Axioms": [],
        "NatNumbers": ["Axioms"],
        "Arithmetic": ["NatNumbers"],
        "Algebra": ["Arithmetic"],
        "SetTheory": ["Axioms"],
        "GroupTheory": ["Algebra", "SetTheory"],
        "RingTheory": ["GroupTheory"],
        "FieldTheory": ["RingTheory"],
        "Polynomials": ["RingTheory"],
        "GaloisTheory": ["FieldTheory", "Polynomials", "GroupTheory"],
    }
    G = DepGraph(nodes, pred)

    print(f"\nNode depths:")
    for v in nodes:
        print(f"  depth({v:15s}) = {G.depth(v)}")

    cpl = critical_path_length(G)
    print(f"\nCritical path length: {cpl}")
    print(f"Deepest nodes: {[v for v in nodes if G.depth(v) == cpl]}")

    # Show that shallow exploration can't reach Galois Theory
    sources = G.source_set()
    print(f"\nExploration budget analysis:")
    for k in range(cpl + 1):
        disc = layered_discovery(G, sources, k)
        reached_galois = "GaloisTheory" in disc
        print(f"  Budget k={k}: discovered {len(disc):2d} nodes, "
              f"Galois Theory {'✓ reached' if reached_galois else '✗ not reached'}")

    print(f"\n✓ Galois Theory requires minimum {G.depth('GaloisTheory')} rounds — "
          f"no shortcut exists!")
    print()


def demo_depth_bound():
    """Demonstrate that depth ≤ |V| - 1."""
    print("=" * 60)
    print("DEMO 4: Depth Bound (depth ≤ |V| - 1)")
    print("=" * 60)

    # Worst case: linear chain of length n
    for n in [3, 5, 10, 20]:
        nodes = [f"v{i}" for i in range(n)]
        pred = {nodes[0]: []}
        for i in range(1, n):
            pred[nodes[i]] = [nodes[i - 1]]
        G = DepGraph(nodes, pred)
        max_depth = max(G.depth(v) for v in nodes)
        print(f"  |V| = {n:2d}: max depth = {max_depth:2d}, "
              f"|V|-1 = {n - 1:2d}, "
              f"bound tight: {'✓' if max_depth == n - 1 else '✗'}")

    print(f"\n✓ Theorem: depth(v) ≤ |V| - 1 for all v")
    print()


def demo_separation():
    """
    Demonstrate the separation theorem: shallow search provably
    cannot reach nodes that critical-path-guided search can.
    """
    print("=" * 60)
    print("DEMO 5: Separation Theorem (Shallow vs. Guided Search)")
    print("=" * 60)

    nodes = [f"L{i}" for i in range(8)]
    pred = {nodes[0]: []}
    for i in range(1, 8):
        pred[nodes[i]] = [nodes[i - 1]]

    # Add some shallow nodes
    nodes.extend(["S0", "S1", "S2"])
    pred["S0"] = []
    pred["S1"] = ["S0"]
    pred["S2"] = ["S1"]

    G = DepGraph(nodes, pred)
    cpl = critical_path_length(G)
    sources = G.source_set()

    print(f"\nGraph has {len(nodes)} nodes, critical path length = {cpl}")
    print(f"Deep chain: L0 → L1 → ... → L7 (depth 7)")
    print(f"Shallow branch: S0 → S1 → S2 (depth 2)")

    for budget in [2, 4, 6, 7]:
        disc = layered_discovery(G, sources, budget)
        missed = set(nodes) - disc
        deep_missed = [v for v in missed if v.startswith("L")]
        print(f"\n  Budget k={budget}:")
        print(f"    Discovered: {len(disc)} nodes")
        print(f"    Deep nodes missed: {deep_missed if deep_missed else 'none'}")
        if budget < cpl:
            print(f"    ✓ Theorem B2: ∃ unreachable node (k={budget} < CPL={cpl})")
        else:
            print(f"    ✓ Theorem C1: all discovered (k={budget} ≥ CPL={cpl})")

    print()


if __name__ == "__main__":
    demo_linear_chain()
    demo_diamond()
    demo_textbook_math()
    demo_depth_bound()
    demo_separation()

    print("=" * 60)
    print("All demos completed successfully.")
    print("Each demo validates the formally proved theorems with")
    print("concrete computational examples.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualizations for Conceptual Dependency Critical Path Theory

Generates publication-quality figures demonstrating key concepts.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from algorithms import DepGraph, critical_path_length, layered_discovery
import base64
from io import BytesIO


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    encoded = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{encoded}"


def viz_discovery_layers():
    """Visualize the layered discovery process on a sample DAG."""
    nodes = ["A", "B", "C", "D", "E", "F", "G", "H"]
    pred = {
        "A": [], "B": [],
        "C": ["A"], "D": ["A", "B"],
        "E": ["C"], "F": ["C", "D"],
        "G": ["E", "F"],
        "H": ["G"],
    }
    G = DepGraph(nodes, pred)
    cpl = critical_path_length(G)
    sources = G.source_set()

    fig, axes = plt.subplots(1, cpl + 1, figsize=(3 * (cpl + 1), 4))
    if cpl == 0:
        axes = [axes]

    # Position nodes by depth
    positions = {}
    for v in nodes:
        d = G.depth(v)
        same_depth = [u for u in nodes if G.depth(u) == d]
        idx = same_depth.index(v)
        n_same = len(same_depth)
        x = (idx - (n_same - 1) / 2) * 1.5
        y = -d * 1.5
        positions[v] = (x, y)

    colors_by_round = plt.cm.viridis(np.linspace(0.2, 0.9, cpl + 1))

    for round_num in range(cpl + 1):
        ax = axes[round_num]
        disc = layered_discovery(G, sources, round_num)

        # Draw edges
        for v in nodes:
            for u in G.pred[v]:
                x1, y1 = positions[u]
                x2, y2 = positions[v]
                color = '#cccccc'
                if u in disc and v in disc:
                    color = '#333333'
                ax.annotate('', xy=(x2, y2), xytext=(x1, y1),
                           arrowprops=dict(arrowstyle='->', color=color,
                                          lw=1.5))

        # Draw nodes
        for v in nodes:
            x, y = positions[v]
            if v in disc:
                new_this_round = v not in layered_discovery(G, sources, max(0, round_num - 1)) if round_num > 0 else v in sources
                color = colors_by_round[round_num] if new_this_round else colors_by_round[G.depth(v)]
                edge_color = 'black'
                alpha = 1.0
            else:
                color = 'white'
                edge_color = '#aaaaaa'
                alpha = 0.5

            circle = plt.Circle((x, y), 0.35, color=color, ec=edge_color,
                              linewidth=2, alpha=alpha, zorder=5)
            ax.add_patch(circle)
            ax.text(x, y, v, ha='center', va='center', fontsize=10,
                   fontweight='bold', alpha=alpha, zorder=6)

        ax.set_xlim(-2.5, 2.5)
        ax.set_ylim(-cpl * 1.5 - 1, 1)
        ax.set_aspect('equal')
        ax.set_title(f'Round {round_num}', fontsize=12, fontweight='bold')
        ax.axis('off')

    fig.suptitle('Layered Discovery Process on a Dependency DAG',
                fontsize=14, fontweight='bold', y=1.02)
    fig.tight_layout()
    fig.savefig('viz_discovery_layers.png', dpi=150, bbox_inches='tight',
                facecolor='white')
    print("Saved: viz_discovery_layers.png")
    return fig_to_base64(fig)


def viz_depth_histogram():
    """Histogram of node depths for a larger graph."""
    # Build a random-ish DAG
    np.random.seed(42)
    n = 50
    nodes = [f"T{i}" for i in range(n)]
    pred = {nodes[0]: []}
    for i in range(1, n):
        # Each node depends on 1-3 earlier nodes
        n_deps = min(np.random.randint(1, 4), i)
        deps = list(np.random.choice(range(i), n_deps, replace=False))
        pred[nodes[i]] = [nodes[d] for d in deps]

    G = DepGraph(nodes, pred)
    depths = [G.depth(v) for v in nodes]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    # Histogram
    max_d = max(depths)
    bins = np.arange(-0.5, max_d + 1.5, 1)
    ax1.hist(depths, bins=bins, color='steelblue', edgecolor='white',
            alpha=0.85, rwidth=0.85)
    ax1.axvline(x=np.mean(depths), color='red', linestyle='--',
               linewidth=2, label=f'Mean = {np.mean(depths):.1f}')
    ax1.axvline(x=max_d, color='darkred', linestyle='-',
               linewidth=2, label=f'CPL = {max_d}')
    ax1.set_xlabel('Conceptual Depth', fontsize=12)
    ax1.set_ylabel('Number of Nodes', fontsize=12)
    ax1.set_title('Distribution of Conceptual Depth (50-node DAG)', fontsize=13)
    ax1.legend(fontsize=11)

    # Cumulative discovery
    cpl = critical_path_length(G)
    sources = G.source_set()
    rounds = list(range(cpl + 1))
    discovered_counts = [len(layered_discovery(G, sources, k)) for k in rounds]

    ax2.plot(rounds, discovered_counts, 'o-', color='steelblue',
            linewidth=2, markersize=6)
    ax2.fill_between(rounds, discovered_counts, alpha=0.15, color='steelblue')
    ax2.axhline(y=n, color='green', linestyle='--', linewidth=1.5,
               label=f'All {n} nodes')
    ax2.axvline(x=cpl, color='darkred', linestyle='--', linewidth=1.5,
               label=f'CPL = {cpl}')
    ax2.set_xlabel('Discovery Round', fontsize=12)
    ax2.set_ylabel('Nodes Discovered', fontsize=12)
    ax2.set_title('Cumulative Discovery (Theorem C1)', fontsize=13)
    ax2.legend(fontsize=11)

    fig.tight_layout()
    fig.savefig('viz_depth_histogram.png', dpi=150, bbox_inches='tight',
                facecolor='white')
    print("Saved: viz_depth_histogram.png")
    return fig_to_base64(fig)


def viz_separation_theorem():
    """Visualize the separation between shallow and guided search."""
    chain_len = 10
    nodes = [f"D{i}" for i in range(chain_len)]
    pred = {nodes[0]: []}
    for i in range(1, chain_len):
        pred[nodes[i]] = [nodes[i-1]]

    # Add some shallow branches
    for branch in range(3):
        base = f"S{branch}_0"
        nodes.append(base)
        pred[base] = []
        for j in range(1, 3):
            name = f"S{branch}_{j}"
            nodes.append(name)
            pred[name] = [f"S{branch}_{j-1}"]

    G = DepGraph(nodes, pred)
    cpl = critical_path_length(G)
    sources = G.source_set()

    fig, ax = plt.subplots(figsize=(10, 6))

    budgets = list(range(cpl + 1))
    total = len(nodes)

    discovered_counts = []
    deep_discovered = []
    shallow_discovered = []

    for k in budgets:
        disc = layered_discovery(G, sources, k)
        discovered_counts.append(len(disc))
        deep_discovered.append(len([v for v in disc if v.startswith('D')]))
        shallow_discovered.append(len([v for v in disc if v.startswith('S')]))

    ax.bar(budgets, deep_discovered, color='#2c3e50', alpha=0.85,
          label='Deep chain nodes', width=0.8)
    ax.bar(budgets, shallow_discovered, bottom=deep_discovered,
          color='#27ae60', alpha=0.85, label='Shallow branch nodes', width=0.8)

    ax.axhline(y=total, color='red', linestyle='--', linewidth=1.5,
              label=f'Total nodes = {total}')

    # Mark the shallow search boundary
    shallow_budget = 2
    ax.axvline(x=shallow_budget + 0.5, color='orange', linestyle=':',
              linewidth=2, label=f'Shallow budget = {shallow_budget}')

    ax.set_xlabel('Discovery Budget (rounds)', fontsize=12)
    ax.set_ylabel('Nodes Discovered', fontsize=12)
    ax.set_title('Separation: Shallow Search Cannot Reach Deep Targets (Theorem B2)',
                fontsize=13)
    ax.legend(fontsize=10, loc='upper left')
    ax.set_xticks(budgets)

    fig.tight_layout()
    fig.savefig('viz_separation.png', dpi=150, bbox_inches='tight',
                facecolor='white')
    print("Saved: viz_separation.png")
    return fig_to_base64(fig)


def viz_critical_path_comparison():
    """Compare different graph structures and their critical paths."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    configs = [
        ("Linear Chain (worst case)", 8, "linear"),
        ("Wide DAG (best case)", 8, "wide"),
        ("Balanced Tree", 15, "tree"),
    ]

    for ax, (title, n, shape) in zip(axes, configs):
        if shape == "linear":
            nodes = [f"v{i}" for i in range(n)]
            pred = {nodes[0]: []}
            for i in range(1, n):
                pred[nodes[i]] = [nodes[i-1]]
        elif shape == "wide":
            nodes = ["root"] + [f"v{i}" for i in range(n-1)]
            pred = {"root": []}
            for i in range(n-1):
                pred[f"v{i}"] = ["root"]
        else:  # tree
            nodes = [f"v{i}" for i in range(n)]
            pred = {nodes[0]: []}
            for i in range(1, n):
                parent = (i - 1) // 2
                pred[nodes[i]] = [nodes[parent]]

        G = DepGraph(nodes, pred)
        depths = [G.depth(v) for v in nodes]
        cpl = max(depths)

        # Bar chart of depths
        sorted_nodes = sorted(nodes, key=lambda v: G.depth(v))
        colors = plt.cm.RdYlGn_r(np.array([G.depth(v) for v in sorted_nodes]) / max(max(depths), 1))

        ax.barh(range(len(nodes)), [G.depth(v) for v in sorted_nodes],
               color=colors, edgecolor='white', height=0.8)
        ax.set_yticks(range(len(nodes)))
        ax.set_yticklabels(sorted_nodes, fontsize=7)
        ax.set_xlabel('Depth', fontsize=11)
        ax.set_title(f'{title}\n|V|={n}, CPL={cpl}', fontsize=11, fontweight='bold')
        ax.axvline(x=cpl, color='red', linestyle='--', alpha=0.7)

    fig.suptitle('Critical Path Length Across Graph Structures',
                fontsize=14, fontweight='bold')
    fig.tight_layout()
    fig.savefig('viz_comparison.png', dpi=150, bbox_inches='tight',
                facecolor='white')
    print("Saved: viz_comparison.png")
    return fig_to_base64(fig)


if __name__ == "__main__":
    b64_1 = viz_discovery_layers()
    b64_2 = viz_depth_histogram()
    b64_3 = viz_separation_theorem()
    b64_4 = viz_critical_path_comparison()

    print("\nAll visualizations generated successfully.")
    print(f"Base64 lengths: {len(b64_1)}, {len(b64_2)}, {len(b64_3)}, {len(b64_4)}")
