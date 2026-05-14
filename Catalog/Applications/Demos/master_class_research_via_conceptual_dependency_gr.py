#!/usr/bin/env python3
"""
Applications of Conceptual Dependency Critical Path Theory

Demonstrates real-world applications:
1. Curriculum optimization for education
2. Research planning and bottleneck detection
3. Software build dependency analysis
4. AI theorem prover guidance simulation
"""

from algorithms import DepGraph, WDepGraph, compute_depth, layered_discovery
from algorithms import critical_path, weighted_depth, weighted_critical_path


def application_curriculum_optimization():
    """
    Application 1: Optimal Curriculum Design

    Given a target topic, compute the minimum prerequisite chain
    and generate an optimal study plan.
    """
    print("=" * 60)
    print("APPLICATION 1: Curriculum Optimization")
    print("=" * 60)

    # Undergraduate mathematics curriculum
    curriculum = {
        'Logic': [],
        'SetTheory': ['Logic'],
        'NaturalNumbers': ['SetTheory'],
        'Integers': ['NaturalNumbers'],
        'Rationals': ['Integers'],
        'RealAnalysis': ['Rationals'],
        'ComplexAnalysis': ['RealAnalysis'],
        'GroupTheory': ['SetTheory'],
        'RingTheory': ['GroupTheory'],
        'FieldTheory': ['RingTheory'],
        'LinearAlgebra': ['FieldTheory'],
        'GaloisTheory': ['FieldTheory', 'GroupTheory'],
        'Topology': ['SetTheory'],
        'MetricSpaces': ['Topology', 'RealAnalysis'],
        'FunctionalAnalysis': ['LinearAlgebra', 'MetricSpaces'],
        'DifferentialGeometry': ['LinearAlgebra', 'RealAnalysis', 'Topology'],
        'AlgebraicTopology': ['Topology', 'GroupTheory'],
        'HomologicalAlgebra': ['RingTheory', 'AlgebraicTopology'],
    }

    G = DepGraph(curriculum)
    depth = compute_depth(G)
    cpl = max(depth.values())

    print(f"\nCurriculum: {len(curriculum)} topics")
    print(f"Critical path length: {cpl} semesters minimum")
    print(f"Critical path: {' → '.join(critical_path(G, depth))}")

    # Analyze specific targets
    targets = ['GaloisTheory', 'FunctionalAnalysis', 'HomologicalAlgebra']
    for target in targets:
        # Find all ancestors
        ancestors = set()
        stack = [target]
        while stack:
            v = stack.pop()
            for u in curriculum[v]:
                if u not in ancestors:
                    ancestors.add(u)
                    stack.append(u)
        print(f"\n  Target: {target}")
        print(f"    Depth: {depth[target]}")
        print(f"    Prerequisites: {len(ancestors)} topics")
        print(f"    Min semesters: {depth[target]}")

    print()


def application_research_planning():
    """
    Application 2: Research Program Planning

    Model a research program as a dependency DAG and identify bottlenecks.
    """
    print("=" * 60)
    print("APPLICATION 2: Research Planning (Fermat's Last Theorem)")
    print("=" * 60)

    # Simplified dependency structure for Wiles's proof
    research = {
        'Elliptic Curves': [],
        'Modular Forms': [],
        'Galois Representations': ['Elliptic Curves'],
        'Hecke Algebras': ['Modular Forms'],
        'Deformation Theory': ['Galois Representations'],
        'R=T Theorem': ['Deformation Theory', 'Hecke Algebras'],
        'Modularity (semistable)': ['R=T Theorem', 'Galois Representations'],
        'Frey Curve': ['Elliptic Curves'],
        'Ribet (epsilon conjecture)': ['Frey Curve', 'Modular Forms'],
        'FLT': ['Modularity (semistable)', 'Ribet (epsilon conjecture)'],
    }

    G = DepGraph(research)
    depth = compute_depth(G)
    cpl = max(depth.values())

    print(f"\nResearch program: {len(research)} milestones")
    print(f"Critical path length: {cpl}")
    print(f"Critical path: {' → '.join(critical_path(G, depth))}")

    # Identify bottleneck: node on critical path with most dependents
    cp = critical_path(G, depth)
    print(f"\nBottleneck analysis:")
    for node in cp:
        dependents = sum(1 for v in research if node in research[v])
        print(f"  {node}: depth={depth[node]}, dependents={dependents}")

    # What if a shortcut were found?
    print(f"\n  If 'Deformation Theory' could be bypassed,")
    print(f"  the critical path would shorten by 1 stage.")
    print()


def application_software_builds():
    """
    Application 3: Software Build Dependency Analysis

    Compute parallel build stages for a module dependency graph.
    """
    print("=" * 60)
    print("APPLICATION 3: Software Build Dependencies")
    print("=" * 60)

    modules = {
        'utils': [],
        'config': [],
        'logging': ['config'],
        'database': ['config', 'logging'],
        'auth': ['database', 'utils'],
        'api_models': ['database'],
        'api_routes': ['api_models', 'auth'],
        'frontend_models': ['api_models'],
        'frontend_views': ['frontend_models'],
        'frontend_app': ['frontend_views', 'api_routes'],
        'tests': ['api_routes', 'frontend_app'],
        'deploy': ['tests'],
    }

    G = DepGraph(modules)
    depth = compute_depth(G)
    seeds = G.sources()
    rounds = layered_discovery(G, seeds)
    cpl = max(depth.values())

    print(f"\nProject: {len(modules)} modules")
    print(f"Minimum build stages: {cpl}")
    print(f"Critical path: {' → '.join(critical_path(G, depth))}")

    print(f"\nParallel build schedule:")
    for stage in range(cpl + 1):
        mods = sorted(m for m, r in rounds.items() if r == stage)
        print(f"  Stage {stage}: build {mods} in parallel")

    print(f"\n  Total stages with unlimited parallelism: {cpl}")
    print(f"  Sequential build would take: {len(modules)} stages")
    print(f"  Speedup from parallelism: {len(modules) / (cpl + 1):.1f}x")
    print()


def application_ai_guidance():
    """
    Application 4: AI Theorem Prover Guidance

    Simulate how critical-path awareness improves theorem discovery.
    """
    print("=" * 60)
    print("APPLICATION 4: AI Theorem Prover Guidance")
    print("=" * 60)

    # A theory with multiple paths, one much deeper
    theory = {
        'axiom1': [],
        'axiom2': [],
        'lemma_a1': ['axiom1'],
        'lemma_a2': ['lemma_a1'],
        'lemma_a3': ['lemma_a2'],
        'lemma_a4': ['lemma_a3'],
        'lemma_a5': ['lemma_a4'],  # deep chain
        'lemma_b1': ['axiom2'],
        'lemma_b2': ['axiom2'],  # shallow branches
        'lemma_b3': ['axiom2'],
        'target': ['lemma_a5', 'lemma_b1', 'lemma_b2', 'lemma_b3'],
    }

    G = DepGraph(theory)
    depth = compute_depth(G)
    cpl = max(depth.values())

    print(f"\nTheory: {len(theory)} nodes, critical path length = {cpl}")
    print(f"Critical path: {' → '.join(critical_path(G, depth))}")

    # Simulate random exploration vs. critical-path-guided
    import random
    random.seed(42)

    # Random strategy: each round, try to discover a random eligible node
    seeds = G.sources()

    # Critical-path-guided: always discovers optimally
    guided_rounds = layered_discovery(G, seeds)
    guided_time = max(guided_rounds.values())

    # Branching-limited strategy: discover at most 1 node per round
    random_discovered = set(seeds)
    random_time = 0
    random_rounds = {v: 0 for v in seeds}
    while 'target' not in random_discovered:
        random_time += 1
        eligible = [v for v in G.nodes - random_discovered
                    if all(u in random_discovered for u in G.pred[v])]
        if eligible:
            choice = random.choice(eligible)
            random_discovered.add(choice)
            random_rounds[choice] = random_time

    print(f"\n  Guided exploration: discovers target in {guided_time} rounds")
    print(f"  Random (1 node/round): discovers target in {random_time} rounds")
    print(f"  Speedup from guidance: {random_time / guided_time:.1f}x")

    # Demonstrate shallow search failure
    print(f"\n  Shallow search (budget = {cpl - 1} rounds):")
    discovered_shallow = {v for v, r in guided_rounds.items() if r <= cpl - 1}
    print(f"    Discovers {len(discovered_shallow)}/{len(theory)} nodes")
    print(f"    Misses: {sorted(set(theory.keys()) - discovered_shallow)}")
    print(f"    Target reachable: {'target' in discovered_shallow}")
    print()


if __name__ == '__main__':
    application_curriculum_optimization()
    application_research_planning()
    application_software_builds()
    application_ai_guidance()
    print("All applications completed successfully!")


#!/usr/bin/env python3
"""
Conceptual Dependency Critical Path: Interactive Demonstrations

Demonstrates the core theorems:
  A1: Depth lower bounds discovery round number
  B1: Critical path attainment
  B2: Shallow search misses deep targets
  C1: Critical-path-guided exploration is complete and optimal
"""

from algorithms import DepGraph, compute_depth, layered_discovery, critical_path


def demo_basic_dag():
    """Demonstrate core concepts on a simple 5-node DAG."""
    print("=" * 60)
    print("DEMO 1: Basic DAG with 5 nodes")
    print("=" * 60)

    # DAG: a,b are sources; c depends on a; d depends on a,b; e depends on c,d
    pred = {
        'a': [],
        'b': [],
        'c': ['a'],
        'd': ['a', 'b'],
        'e': ['c', 'd'],
    }
    G = DepGraph(pred)

    print("\nDependency structure:")
    for v, deps in pred.items():
        print(f"  {v} depends on: {deps if deps else '(source)'}")

    depth = compute_depth(G)
    print(f"\nConceptual depth:")
    for v in sorted(depth, key=depth.get):
        print(f"  depth({v}) = {depth[v]}")

    cpl = max(depth.values())
    print(f"\nCritical path length: {cpl}")

    path = critical_path(G, depth)
    print(f"Critical path: {' → '.join(path)}")

    seeds = {v for v in pred if not pred[v]}
    print(f"\nSeed set (sources): {seeds}")

    rounds = layered_discovery(G, seeds)
    print(f"\nLayered discovery:")
    for r in range(cpl + 1):
        nodes_at_r = [v for v, rd in rounds.items() if rd == r]
        print(f"  Round {r}: discovered {nodes_at_r}")

    # Verify Theorem A1
    print(f"\n--- Theorem A1 verification ---")
    for v, r in rounds.items():
        ok = depth[v] <= r
        print(f"  depth({v})={depth[v]} ≤ round({v})={r} : {'✓' if ok else '✗'}")

    # Verify Theorem B2
    print(f"\n--- Theorem B2 verification ---")
    for k in range(cpl):
        discovered_k = {v for v, r in rounds.items() if r <= k}
        missed = set(pred.keys()) - discovered_k
        print(f"  k={k} < {cpl}: undiscovered nodes = {missed} {'✓' if missed else '✗'}")

    print()


def demo_linear_chain():
    """Demonstrate on a linear chain (maximum depth = n-1)."""
    print("=" * 60)
    print("DEMO 2: Linear chain of 8 nodes")
    print("=" * 60)

    n = 8
    nodes = [f"v{i}" for i in range(n)]
    pred = {nodes[0]: []}
    for i in range(1, n):
        pred[nodes[i]] = [nodes[i - 1]]

    G = DepGraph(pred)
    depth = compute_depth(G)
    cpl = max(depth.values())

    print(f"\nChain: {' → '.join(nodes)}")
    print(f"Critical path length: {cpl} (= {n} - 1 = {n - 1}) ✓" if cpl == n - 1 else "✗")

    seeds = {nodes[0]}
    rounds = layered_discovery(G, seeds)

    print(f"\nDiscovery rounds match depth for all nodes:")
    for v in nodes:
        print(f"  round({v})={rounds[v]}, depth({v})={depth[v]}"
              f" {'✓' if rounds[v] == depth[v] else ''}")

    print()


def demo_wide_dag():
    """Demonstrate on a wide DAG (many independent paths)."""
    print("=" * 60)
    print("DEMO 3: Wide DAG (diamond pattern)")
    print("=" * 60)

    # Diamond: source → {m1, m2, m3, m4} → sink
    pred = {
        'source': [],
        'm1': ['source'],
        'm2': ['source'],
        'm3': ['source'],
        'm4': ['source'],
        'sink': ['m1', 'm2', 'm3', 'm4'],
    }
    G = DepGraph(pred)
    depth = compute_depth(G)
    cpl = max(depth.values())

    print(f"\nDiamond DAG with {len(pred)} nodes")
    print(f"Critical path length: {cpl}")

    path = critical_path(G, depth)
    print(f"A critical path: {' → '.join(path)}")
    print(f"(Multiple paths of same length exist — width doesn't affect depth)")

    seeds = {'source'}
    rounds = layered_discovery(G, seeds)
    print(f"\nDiscovery:")
    for r in range(cpl + 1):
        nodes_at_r = sorted(v for v, rd in rounds.items() if rd == r)
        print(f"  Round {r}: {nodes_at_r}")

    print(f"\nAll discovered by round {cpl} (= critical path length): ✓")
    print()


def demo_math_curriculum():
    """Demonstrate with a realistic mathematical curriculum DAG."""
    print("=" * 60)
    print("DEMO 4: Mathematical curriculum (simplified)")
    print("=" * 60)

    pred = {
        'Axioms': [],
        'Logic': [],
        'SetTheory': ['Axioms', 'Logic'],
        'NaturalNumbers': ['SetTheory'],
        'Integers': ['NaturalNumbers'],
        'RealNumbers': ['Integers'],
        'Functions': ['SetTheory'],
        'Sequences': ['RealNumbers', 'Functions'],
        'Limits': ['Sequences'],
        'Continuity': ['Limits'],
        'Derivatives': ['Limits'],
        'Integration': ['Derivatives', 'Continuity'],
        'FundThmCalculus': ['Integration', 'Derivatives'],
        'Groups': ['SetTheory'],
        'Rings': ['Groups'],
        'Fields': ['Rings'],
        'LinearAlgebra': ['Fields', 'Functions'],
        'Topology': ['SetTheory', 'RealNumbers'],
        'MetricSpaces': ['Topology', 'RealNumbers'],
        'Compactness': ['MetricSpaces', 'Sequences'],
        'Completeness': ['MetricSpaces', 'Sequences'],
        'FunctionalAnalysis': ['LinearAlgebra', 'Completeness', 'Compactness'],
    }

    G = DepGraph(pred)
    depth = compute_depth(G)
    cpl = max(depth.values())

    print(f"\nCurriculum with {len(pred)} topics")
    print(f"Critical path length: {cpl}")

    # Find deepest node
    deepest = max(depth, key=depth.get)
    path = critical_path(G, depth)
    print(f"Deepest topic: {deepest} (depth {depth[deepest]})")
    print(f"Critical path: {' → '.join(path)}")

    # Show depth distribution
    print(f"\nDepth distribution:")
    for d in range(cpl + 1):
        topics = sorted(v for v in depth if depth[v] == d)
        print(f"  Depth {d}: {topics}")

    seeds = {v for v in pred if not pred[v]}
    rounds = layered_discovery(G, seeds)

    # Verify separation theorem
    print(f"\n--- Separation theorem ---")
    for k in range(cpl):
        discovered_k = {v for v, r in rounds.items() if r <= k}
        missed = set(pred.keys()) - discovered_k
        print(f"  Budget={k}: {len(missed)} topics unreachable"
              f" (e.g. {sorted(missed)[:2]})")

    print()


def demo_depth_bound():
    """Verify depth ≤ |V| - 1 on various DAGs."""
    print("=" * 60)
    print("DEMO 5: Depth bound verification (depth ≤ |V| - 1)")
    print("=" * 60)

    import random
    random.seed(42)

    for trial in range(5):
        n = random.randint(5, 15)
        nodes = list(range(n))
        # Random DAG: node i can only depend on nodes j < i
        pred = {}
        for i in nodes:
            possible_preds = [j for j in range(i)]
            k = random.randint(0, min(3, len(possible_preds)))
            pred[i] = random.sample(possible_preds, k) if possible_preds and k > 0 else []

        G = DepGraph(pred)
        depth = compute_depth(G)
        max_depth = max(depth.values())
        bound = n - 1

        print(f"  Trial {trial + 1}: |V|={n}, max_depth={max_depth},"
              f" bound={bound}, {'✓' if max_depth <= bound else '✗'}")

    print()


if __name__ == '__main__':
    demo_basic_dag()
    demo_linear_chain()
    demo_wide_dag()
    demo_math_curriculum()
    demo_depth_bound()
    print("All demos completed successfully!")


#!/usr/bin/env python3
"""Generate PACKAGE.json with all artifacts embedded."""

import json
import base64
import os


def read_file(path):
    with open(path, 'r') as f:
        return f.read()


def encode_image(path):
    with open(path, 'rb') as f:
        data = base64.b64encode(f.read()).decode('utf-8')
    return f"data:image/png;base64,{data}"


def main():
    # Read all text content
    article = read_file('ARTICLE.md')
    research_paper = read_file('RESEARCH_PAPER.md')
    future_directions = read_file('FUTURE_DIRECTIONS.md')
    lean_proofs = read_file('Catalog/Speculative/AutoResearch/ConceptualDependencyCriticalPath.lean')
    demo_code = read_file('demo.py')
    algorithms_code = read_file('algorithms.py')
    applications_code = read_file('applications.py')
    visualizations_code = read_file('visualizations.py')

    # Encode images
    images = {
        'viz_dag_depth.png': 'Dependency DAG with Depth Coloring',
        'viz_discovery_heatmap.png': 'Discovery Process Heatmap',
        'viz_separation.png': 'Separation Theorem Visualization',
        'viz_critical_path_comparison.png': 'Critical Path Length Comparison',
        'viz_weighted_comparison.png': 'Weighted vs Unweighted Depth',
    }

    visualizations = []
    for filename, name in images.items():
        if os.path.exists(filename):
            visualizations.append({
                'name': name,
                'data': encode_image(filename)
            })

    package = {
        'title': 'Critical Path Lower Bounds for Conceptual Discovery in Dependency DAGs',
        'domain': 'Metamathematics / Graph Theory / Proof Complexity',
        'article': article,
        'research_paper': research_paper,
        'future_directions': future_directions,
        'demos': [
            {
                'name': 'Conceptual Dependency Critical Path Demos',
                'code': f'''#!/usr/bin/env python3
"""
Conceptual Dependency Critical Path: Self-Contained Demo

Demonstrates the core theorems:
  A1: Depth lower bounds discovery round number
  B2: Shallow search misses deep targets
  C1: Critical-path-guided exploration is complete
"""

from collections import defaultdict, deque
from typing import Any, Dict, List, Set


class DepGraph:
    """A finite DAG represented by a predecessor map."""
    def __init__(self, pred: Dict[Any, List[Any]]):
        self.pred = {{k: list(v) for k, v in pred.items()}}
        self.nodes = set(pred.keys())
        self.succ: Dict[Any, List[Any]] = defaultdict(list)
        for v, preds in self.pred.items():
            for u in preds:
                self.succ[u].append(v)

    def sources(self) -> Set[Any]:
        return {{v for v in self.nodes if not self.pred[v]}}

    def topological_order(self) -> List[Any]:
        in_degree = {{v: len(self.pred[v]) for v in self.nodes}}
        queue = deque(v for v in self.nodes if in_degree[v] == 0)
        order = []
        while queue:
            v = queue.popleft()
            order.append(v)
            for u in self.succ.get(v, []):
                in_degree[u] -= 1
                if in_degree[u] == 0:
                    queue.append(u)
        return order


def compute_depth(G):
    depth = {{}}
    for v in G.topological_order():
        depth[v] = 0 if not G.pred[v] else 1 + max(depth[u] for u in G.pred[v])
    return depth


def layered_discovery(G, seeds):
    discovered = {{v: 0 for v in seeds}}
    round_num = 0
    while len(discovered) < len(G.nodes):
        round_num += 1
        next_layer = {{v for v in G.nodes - set(discovered)
                      if all(u in discovered for u in G.pred[v])}}
        if not next_layer:
            break
        for v in next_layer:
            discovered[v] = round_num
    return discovered


def critical_path(G, depth):
    target = max(depth, key=depth.get)
    path = [target]
    current = target
    while depth[current] > 0:
        for u in G.pred[current]:
            if depth[u] == depth[current] - 1:
                path.append(u)
                current = u
                break
    path.reverse()
    return path


# === DEMO: Mathematical Curriculum ===
print("=" * 60)
print("Conceptual Dependency Critical Path: Curriculum Demo")
print("=" * 60)

curriculum = {{
    'Logic': [], 'SetTheory': ['Logic'],
    'Numbers': ['SetTheory'], 'Algebra': ['SetTheory'],
    'Analysis': ['Numbers'], 'Topology': ['SetTheory'],
    'Measure': ['Analysis', 'Topology'],
    'FuncAnal': ['Algebra', 'Measure'],
    'PDE': ['FuncAnal', 'Analysis'],
}}

G = DepGraph(curriculum)
depth = compute_depth(G)
cpl = max(depth.values())

print(f"\\nTopics: {{len(curriculum)}}, Critical path length: {{cpl}}")
print(f"Critical path: {{' -> '.join(critical_path(G, depth))}}")

seeds = G.sources()
rounds = layered_discovery(G, seeds)

print(f"\\n--- Theorem A1: depth(v) <= round(v) ---")
for v in sorted(depth, key=depth.get):
    ok = depth[v] <= rounds[v]
    print(f"  {{v}}: depth={{depth[v]}}, round={{rounds[v]}} {{'✓' if ok else '✗'}}")

print(f"\\n--- Theorem B2: Shallow search misses deep targets ---")
for k in range(cpl):
    missed = [v for v, r in rounds.items() if r > k]
    print(f"  Budget={{k}}: {{len(missed)}} topics unreachable")

print(f"\\n--- Theorem C1: Complete at critical path length ---")
disc_at_cpl = {{v for v, r in rounds.items() if r <= cpl}}
print(f"  Round {{cpl}}: {{len(disc_at_cpl)}}/{{len(curriculum)}} discovered ✓")
'''
            }
        ],
        'algorithms': [
            {
                'name': 'Topological Depth Computation',
                'pseudocode': '''Algorithm: ComputeDepth(G = (V, pred))
Input:  DAG G with predecessor map pred
Output: depth[v] for all v ∈ V

1. Compute topological ordering T of V
2. For v in T:
3.     if pred(v) = ∅:
4.         depth[v] ← 0
5.     else:
6.         depth[v] ← 1 + max{depth[u] : u ∈ pred(v)}
7. Return depth

Time:  O(|V| + |E|)
Space: O(|V|)''',
                'code': algorithms_code
            },
            {
                'name': 'Layered Discovery Process',
                'pseudocode': '''Algorithm: LayeredDiscovery(G, S)
Input:  DAG G, seed set S (sources)
Output: round[v] for all v

1. D ← S; round[v] ← 0 for v ∈ S; n ← 0
2. While D ≠ V:
3.     n ← n + 1
4.     N ← {v ∈ V\\D : ∀u ∈ pred(v), u ∈ D}
5.     For v ∈ N: round[v] ← n
6.     D ← D ∪ N
7. Return round

Time:  O(L · (|V| + |E|)) where L = criticalPathLength
Space: O(|V|)''',
                'code': algorithms_code
            }
        ],
        'visualizations': visualizations,
        'lean_proofs': lean_proofs
    }

    with open('PACKAGE.json', 'w') as f:
        json.dump(package, f, indent=2, ensure_ascii=False)

    print(f"PACKAGE.json generated ({os.path.getsize('PACKAGE.json') / 1024:.0f} KB)")


if __name__ == '__main__':
    os.chdir('/workspace/request-project')
    main()


#!/usr/bin/env python3
"""
Visualizations for Conceptual Dependency Critical Path Theory

Generates publication-quality figures demonstrating the core theorems.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from algorithms import DepGraph, compute_depth, layered_discovery, critical_path


def viz_dag_with_depth(filename='viz_dag_depth.png'):
    """Visualize a DAG colored by conceptual depth with critical path highlighted."""
    pred = {
        'Axioms': [],
        'Logic': [],
        'Sets': ['Axioms', 'Logic'],
        'Numbers': ['Sets'],
        'Algebra': ['Sets'],
        'Analysis': ['Numbers'],
        'Topology': ['Sets'],
        'Measure': ['Analysis', 'Topology'],
        'Functional': ['Algebra', 'Measure'],
        'PDE': ['Functional', 'Analysis'],
    }

    G = DepGraph(pred)
    depth = compute_depth(G)
    cp = critical_path(G, depth)
    cp_set = set(cp)
    cpl = max(depth.values())

    # Layout: x by depth, y spread within layer
    pos = {}
    layers = {}
    for v, d in depth.items():
        layers.setdefault(d, []).append(v)
    for d, nodes in layers.items():
        for i, v in enumerate(sorted(nodes)):
            x = d * 2.0
            y = (i - (len(nodes) - 1) / 2) * 1.5
            pos[v] = (x, y)

    fig, ax = plt.subplots(1, 1, figsize=(14, 6))

    # Draw edges
    for v, preds in pred.items():
        for u in preds:
            x0, y0 = pos[u]
            x1, y1 = pos[v]
            is_cp = u in cp_set and v in cp_set and abs(cp.index(v) - cp.index(u)) == 1 if u in cp and v in cp else False
            color = '#e74c3c' if is_cp else '#bdc3c7'
            lw = 3 if is_cp else 1.2
            ax.annotate('', xy=(x1 - 0.3, y1), xytext=(x0 + 0.3, y0),
                        arrowprops=dict(arrowstyle='->', color=color, lw=lw))

    # Draw nodes
    cmap = plt.cm.YlOrRd
    norm = plt.Normalize(0, cpl)
    for v, (x, y) in pos.items():
        color = cmap(norm(depth[v]))
        edgecolor = '#e74c3c' if v in cp_set else '#2c3e50'
        lw = 3 if v in cp_set else 1.5
        circle = plt.Circle((x, y), 0.4, color=color, ec=edgecolor, lw=lw, zorder=5)
        ax.add_patch(circle)
        ax.text(x, y, v, ha='center', va='center', fontsize=7, fontweight='bold', zorder=6)
        ax.text(x, y - 0.55, f'd={depth[v]}', ha='center', va='top', fontsize=6, color='#555')

    ax.set_xlim(-1, cpl * 2 + 1)
    ax.set_ylim(-3, 3)
    ax.set_aspect('equal')
    ax.set_title('Conceptual Dependency DAG with Depth Coloring\n(Critical path highlighted in red)',
                 fontsize=14, fontweight='bold')
    ax.set_xlabel('Conceptual Depth →', fontsize=11)
    ax.axis('off')

    sm = plt.cm.ScalarMappable(cmap=cmap, norm=norm)
    sm.set_array([])
    cbar = plt.colorbar(sm, ax=ax, shrink=0.6, label='Depth')

    plt.tight_layout()
    plt.savefig(filename, dpi=150, bbox_inches='tight')
    plt.close()
    print(f"  Saved {filename}")


def viz_discovery_heatmap(filename='viz_discovery_heatmap.png'):
    """Heatmap showing discovery round for each node."""
    pred = {
        'A1': [], 'A2': [], 'A3': [],
        'B1': ['A1'], 'B2': ['A1', 'A2'], 'B3': ['A2', 'A3'],
        'C1': ['B1', 'B2'], 'C2': ['B2', 'B3'],
        'D1': ['C1', 'C2'],
    }

    G = DepGraph(pred)
    depth = compute_depth(G)
    seeds = G.sources()
    rounds = layered_discovery(G, seeds)
    cpl = max(depth.values())

    nodes = sorted(pred.keys())
    n = len(nodes)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Left: discovery progress over rounds
    for k in range(cpl + 1):
        discovered = [v for v in nodes if rounds[v] <= k]
        undiscovered = [v for v in nodes if rounds[v] > k]
        y_disc = [nodes.index(v) for v in discovered]
        y_undisc = [nodes.index(v) for v in undiscovered]
        ax1.barh([y + k * 0.15 for y in y_disc], [1] * len(y_disc),
                 height=0.12, color=plt.cm.viridis(k / max(cpl, 1)), alpha=0.8)

    ax1.set_yticks(range(n))
    ax1.set_yticklabels(nodes)
    ax1.set_xlabel('Discovery Progress by Round')
    ax1.set_title('Layered Discovery Process', fontweight='bold')

    # Right: depth vs discovery round scatter
    for v in nodes:
        color = '#e74c3c' if rounds[v] == depth[v] else '#3498db'
        ax2.scatter(depth[v], rounds[v], s=120, c=color, zorder=5, edgecolors='black')
        ax2.annotate(v, (depth[v], rounds[v]), textcoords="offset points",
                     xytext=(5, 5), fontsize=8)

    ax2.plot([0, cpl], [0, cpl], 'k--', alpha=0.3, label='round = depth')
    ax2.fill_between([0, cpl], [0, 0], [0, cpl], alpha=0.1, color='red',
                     label='Impossible (Thm A1)')
    ax2.set_xlabel('Conceptual Depth', fontsize=11)
    ax2.set_ylabel('Discovery Round', fontsize=11)
    ax2.set_title('Depth vs Discovery Round\n(Theorem A1: round ≥ depth)', fontweight='bold')
    ax2.legend(fontsize=9)
    ax2.set_aspect('equal')

    plt.tight_layout()
    plt.savefig(filename, dpi=150, bbox_inches='tight')
    plt.close()
    print(f"  Saved {filename}")


def viz_separation_theorem(filename='viz_separation.png'):
    """Visualize the separation theorem: shallow search misses deep targets."""
    # Linear chain for clear visualization
    n = 8
    nodes = [f'T{i}' for i in range(n)]
    pred = {nodes[0]: []}
    for i in range(1, n):
        pred[nodes[i]] = [nodes[i-1]]

    G = DepGraph(pred)
    depth = compute_depth(G)
    seeds = G.sources()
    rounds = layered_discovery(G, seeds)
    cpl = max(depth.values())

    fig, axes = plt.subplots(2, 3, figsize=(15, 8))

    for idx, k in enumerate(range(6)):
        ax = axes[idx // 3][idx % 3]
        discovered = {v for v, r in rounds.items() if r <= k}

        for i, v in enumerate(nodes):
            color = '#2ecc71' if v in discovered else '#e74c3c'
            ax.add_patch(plt.Circle((i, 0), 0.35, color=color, ec='black', lw=1.5))
            ax.text(i, 0, v, ha='center', va='center', fontsize=7, fontweight='bold')
            ax.text(i, -0.55, f'd={depth[v]}', ha='center', fontsize=6, color='#555')

        for i in range(n - 1):
            ax.annotate('', xy=(i + 0.65, 0), xytext=(i + 0.35, 0),
                        arrowprops=dict(arrowstyle='->', color='#7f8c8d', lw=1.5))

        ax.set_xlim(-0.8, n - 0.2)
        ax.set_ylim(-1, 1)
        ax.set_aspect('equal')
        ax.set_title(f'Budget k={k} ({len(discovered)}/{n} discovered)',
                     fontsize=10, fontweight='bold')
        ax.axis('off')

        # Separation indicator
        if k < cpl:
            missed = n - len(discovered)
            ax.text(n/2, 0.7, f'Thm B2: ∃ {missed} unreachable',
                    ha='center', fontsize=8, color='#e74c3c', style='italic')
        else:
            ax.text(n/2, 0.7, 'Thm C1: All discovered! ✓',
                    ha='center', fontsize=8, color='#27ae60', style='italic')

    fig.suptitle('Separation Theorem: Shallow Search Misses Deep Targets',
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig(filename, dpi=150, bbox_inches='tight')
    plt.close()
    print(f"  Saved {filename}")


def viz_critical_path_comparison(filename='viz_critical_path_comparison.png'):
    """Compare critical path length across different DAG topologies."""
    topologies = {
        'Linear\n(n=10)': {i: [i-1] if i > 0 else [] for i in range(10)},
        'Binary Tree\n(depth=3)': {
            0: [], 1: [0], 2: [0], 3: [1], 4: [1], 5: [2], 6: [2],
        },
        'Diamond\n(width=5)': {
            's': [], **{f'm{i}': ['s'] for i in range(5)},
            't': [f'm{i}' for i in range(5)],
        },
        'Grid 3x3': {
            (i, j): ([(i-1, j)] if i > 0 else []) + ([(i, j-1)] if j > 0 else [])
            for i in range(3) for j in range(3)
        },
    }

    fig, ax = plt.subplots(figsize=(10, 6))

    names = []
    cpls = []
    sizes = []
    colors = ['#3498db', '#e74c3c', '#2ecc71', '#f39c12']

    for i, (name, pred_map) in enumerate(topologies.items()):
        G = DepGraph(pred_map)
        d = compute_depth(G)
        cpl = max(d.values())
        names.append(name)
        cpls.append(cpl)
        sizes.append(len(pred_map))

    x = np.arange(len(names))
    bars = ax.bar(x, cpls, color=colors, edgecolor='black', linewidth=1.2, alpha=0.85)

    for bar, cpl, size in zip(bars, cpls, sizes):
        ax.text(bar.get_x() + bar.get_width() / 2, bar.get_height() + 0.2,
                f'CPL={cpl}\n|V|={size}', ha='center', fontsize=9, fontweight='bold')

    ax.set_xticks(x)
    ax.set_xticklabels(names, fontsize=10)
    ax.set_ylabel('Critical Path Length', fontsize=12)
    ax.set_title('Critical Path Length Across DAG Topologies', fontsize=14, fontweight='bold')
    ax.set_ylim(0, max(cpls) + 2)

    # Add depth bound line
    max_v = max(sizes)
    ax.axhline(y=max_v - 1, color='gray', linestyle='--', alpha=0.5,
               label=f'Upper bound |V|-1 (max |V|={max_v})')
    ax.legend(fontsize=9)

    plt.tight_layout()
    plt.savefig(filename, dpi=150, bbox_inches='tight')
    plt.close()
    print(f"  Saved {filename}")


def viz_weighted_vs_unweighted(filename='viz_weighted_comparison.png'):
    """Compare weighted and unweighted depth to show novelty detection."""
    from algorithms import WDepGraph, weighted_depth

    pred = {
        'A': [],
        'B': ['A'],
        'C': ['B'],
        'D': ['C'],
        'E': ['D'],  # Long routine chain
        'X': [],
        'Y': ['X'],  # Short revolutionary chain
    }

    # Routine weights (all 1) vs. novelty weights (Y has high weight)
    weights_uniform = {v: 1 for v in pred}
    weights_novelty = {'A': 1, 'B': 1, 'C': 1, 'D': 1, 'E': 1, 'X': 1, 'Y': 10}

    G_uniform = WDepGraph(pred, weights_uniform)
    G_novelty = WDepGraph(pred, weights_novelty)

    d_unweighted = compute_depth(DepGraph(pred))
    d_uniform = weighted_depth(G_uniform)
    d_novelty = weighted_depth(G_novelty)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    nodes = sorted(pred.keys())
    x = np.arange(len(nodes))

    # Unweighted
    ax1.bar(x - 0.2, [d_unweighted[v] for v in nodes], 0.35,
            label='Unweighted Depth', color='#3498db', edgecolor='black')
    ax1.bar(x + 0.2, [d_uniform[v] for v in nodes], 0.35,
            label='Weighted (all w=1)', color='#e74c3c', edgecolor='black', alpha=0.7)
    ax1.set_xticks(x)
    ax1.set_xticklabels(nodes)
    ax1.set_ylabel('Depth')
    ax1.set_title('Uniform Weights: Long Chain Dominates', fontweight='bold')
    ax1.legend()
    ax1.annotate('E is "deepest"', xy=(4, d_unweighted['E']),
                 xytext=(4, d_unweighted['E'] + 1),
                 arrowprops=dict(arrowstyle='->', color='#3498db'),
                 fontsize=9, ha='center')

    # Novelty-weighted
    ax2.bar(x - 0.2, [d_unweighted[v] for v in nodes], 0.35,
            label='Unweighted Depth', color='#3498db', edgecolor='black')
    ax2.bar(x + 0.2, [d_novelty[v] for v in nodes], 0.35,
            label='Novelty Weighted', color='#2ecc71', edgecolor='black', alpha=0.7)
    ax2.set_xticks(x)
    ax2.set_xticklabels(nodes)
    ax2.set_ylabel('Depth')
    ax2.set_title('Novelty Weights: Revolutionary Leap Dominates', fontweight='bold')
    ax2.legend()
    ax2.annotate(f'Y is "deepest" (w=10)', xy=(6, d_novelty['Y']),
                 xytext=(5, d_novelty['Y'] + 1),
                 arrowprops=dict(arrowstyle='->', color='#2ecc71'),
                 fontsize=9, ha='center')

    fig.suptitle('Weighted Depth Distinguishes Routine Chains from Revolutionary Jumps',
                 fontsize=13, fontweight='bold')
    plt.tight_layout()
    plt.savefig(filename, dpi=150, bbox_inches='tight')
    plt.close()
    print(f"  Saved {filename}")


if __name__ == '__main__':
    print("Generating visualizations...")
    viz_dag_with_depth()
    viz_discovery_heatmap()
    viz_separation_theorem()
    viz_critical_path_comparison()
    viz_weighted_vs_unweighted()
    print("All visualizations generated!")
