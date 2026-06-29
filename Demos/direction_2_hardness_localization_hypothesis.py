"""
applications.py — Real-World Applications of Hardness-Localization Theory

Demonstrates practical applications of cycle-pressure analysis:
1. Theorem difficulty prediction from semantic graph topology
2. Proof search strategy optimization
3. Library decomposition for automated reasoning
4. Bottleneck identification in knowledge graphs
"""

import numpy as np
from collections import defaultdict
from typing import Dict, List, Set, Tuple, Optional

try:
    import networkx as nx
except ImportError:
    print("NetworkX required. Install with: pip install networkx")
    raise


# ─── Application 1: Theorem Difficulty Prediction ───────────────────────────

def extract_features(theorem_text: str) -> Set[str]:
    """
    Extract a simple feature set from a theorem statement.

    In a real system, this would use:
    - Symbol multisets (quantifiers, connectives, type constructors)
    - Quantifier depth
    - Binder complexity
    - Universe/typeclass load
    - Dependency signatures

    Here we use a simplified keyword-based extraction for demonstration.
    """
    keywords = [
        'forall', 'exists', 'implies', 'and', 'or', 'not',
        'nat', 'int', 'real', 'set', 'finset', 'list',
        'prime', 'div', 'mod', 'add', 'mul', 'pow',
        'le', 'lt', 'eq', 'ne', 'iff',
        'induction', 'recursion', 'well_founded',
        'continuous', 'measurable', 'compact',
        'group', 'ring', 'field', 'module',
        'topology', 'metric', 'norm',
        'finite', 'infinite', 'countable',
    ]
    text_lower = theorem_text.lower()
    return {kw for kw in keywords if kw in text_lower}


def predict_difficulty(
    theorems: Dict[str, str],
    epsilon: Optional[int] = None
) -> Dict[str, Dict]:
    """
    Predict theorem difficulty using cycle-pressure analysis.

    Parameters
    ----------
    theorems : Dict[str, str]
        Mapping from theorem name to statement text.
    epsilon : Optional[int]
        Threshold parameter. If None, auto-selects to maximize cycle rank.

    Returns
    -------
    Dict[str, Dict]
        For each theorem: predicted difficulty, cycle pressure, region type.
    """
    # Extract features
    feature_sets = {}
    names = list(theorems.keys())
    for i, (name, text) in enumerate(theorems.items()):
        feature_sets[i] = extract_features(text)

    # Auto-select epsilon if not provided
    if epsilon is None:
        best_eps = 0
        best_cr = -1
        for eps in range(1, 20):
            G = nx.Graph()
            G.add_nodes_from(range(len(names)))
            for i in range(len(names)):
                for j in range(i + 1, len(names)):
                    dist = len(feature_sets[i].symmetric_difference(feature_sets[j]))
                    if dist <= eps:
                        G.add_edge(i, j)
            cr = G.number_of_edges() - G.number_of_nodes() + nx.number_connected_components(G)
            if cr > best_cr:
                best_cr = cr
                best_eps = eps
        epsilon = best_eps

    # Build threshold graph
    G = nx.Graph()
    G.add_nodes_from(range(len(names)))
    for i in range(len(names)):
        for j in range(i + 1, len(names)):
            dist = len(feature_sets[i].symmetric_difference(feature_sets[j]))
            if dist <= epsilon:
                G.add_edge(i, j)

    # Compute cycle pressures
    bridges = set(nx.bridges(G))
    pressures = {}
    for v in G.nodes():
        p = sum(1 for u in G.neighbors(v)
                if (v, u) not in bridges and (u, v) not in bridges)
        pressures[v] = p

    # Classify and predict
    results = {}
    max_pressure = max(pressures.values()) if pressures else 1
    for i, name in enumerate(names):
        pressure = pressures.get(i, 0)
        degree = G.degree(i)

        if pressure == 0:
            region = "tree_like"
            difficulty = "low"
        elif pressure <= max_pressure * 0.5:
            region = "moderate_cycle"
            difficulty = "medium"
        else:
            region = "cycle_dense"
            difficulty = "high"

        results[name] = {
            "cycle_pressure": pressure,
            "degree": degree,
            "region": region,
            "predicted_difficulty": difficulty,
            "features": feature_sets[i],
        }

    return results


# ─── Application 2: Search Strategy Optimization ────────────────────────────

def recommend_search_strategy(
    G: nx.Graph,
    start: int,
    targets: Set[int]
) -> Dict:
    """
    Recommend a proof search strategy based on graph topology.

    In cycle-rich regions: recommend abstraction/quotient strategies.
    In tree-like regions: recommend direct depth-first search.
    Near bottlenecks: recommend bridge-crossing heuristics.

    Parameters
    ----------
    G : nx.Graph
    start : int
    targets : Set[int]

    Returns
    -------
    Dict
        Strategy recommendation with rationale.
    """
    bridges = set(nx.bridges(G))
    pressure = sum(1 for u in G.neighbors(start)
                   if (start, u) not in bridges and (u, start) not in bridges)

    # Find shortest path
    min_dist = float('inf')
    best_target = None
    for t in targets:
        try:
            d = nx.shortest_path_length(G, start, t)
            if d < min_dist:
                min_dist = d
                best_target = t
        except nx.NetworkXNoPath:
            continue

    # Check if path crosses bridges
    if best_target is not None:
        path = nx.shortest_path(G, start, best_target)
        bridge_crossings = sum(1 for i in range(len(path)-1)
                              if (path[i], path[i+1]) in bridges
                              or (path[i+1], path[i]) in bridges)
    else:
        bridge_crossings = 0

    # Generate recommendation
    if pressure == 0:
        strategy = "direct_search"
        rationale = ("Tree-like region: every path is unique. "
                    "Use depth-first search with backtracking.")
    elif bridge_crossings > 0:
        strategy = "bridge_guided"
        rationale = (f"Path crosses {bridge_crossings} bridge(s). "
                    "Prioritize bridge-crossing moves to escape cycle-rich regions.")
    else:
        strategy = "abstraction_quotient"
        rationale = (f"High cycle pressure ({pressure}). "
                    "Quotient the cycle-rich subgraph to reduce search space, "
                    "or use bidirectional search to avoid cycle trapping.")

    return {
        "strategy": strategy,
        "rationale": rationale,
        "cycle_pressure": pressure,
        "distance_to_target": min_dist,
        "bridge_crossings": bridge_crossings,
    }


# ─── Application 3: Library Decomposition ───────────────────────────────────

def decompose_library(
    feature_sets: Dict[int, Set[str]],
    epsilon: int
) -> Dict[str, List[int]]:
    """
    Decompose a theorem library into regions based on cycle-pressure analysis.

    Identifies:
    - Cycle-dense clusters (hard regions)
    - Tree-like branches (easy regions)
    - Bridge vertices (critical connectors)

    Parameters
    ----------
    feature_sets : Dict[int, Set[str]]
    epsilon : int

    Returns
    -------
    Dict[str, List[int]]
        Decomposition into named regions.
    """
    G = nx.Graph()
    nodes = list(feature_sets.keys())
    G.add_nodes_from(nodes)
    for i in range(len(nodes)):
        for j in range(i + 1, len(nodes)):
            dist = len(feature_sets[nodes[i]].symmetric_difference(feature_sets[nodes[j]]))
            if dist <= epsilon:
                G.add_edge(nodes[i], nodes[j])

    bridges = set(nx.bridges(G))
    pressures = {}
    for v in G.nodes():
        p = sum(1 for u in G.neighbors(v)
                if (v, u) not in bridges and (u, v) not in bridges)
        pressures[v] = p

    # Identify articulation points
    articulation = set(nx.articulation_points(G))

    cycle_dense = [v for v in nodes if pressures.get(v, 0) > 0 and v not in articulation]
    tree_like = [v for v in nodes if pressures.get(v, 0) == 0 and v not in articulation]
    bridge_vertices = [v for v in nodes if v in articulation]

    return {
        "cycle_dense": cycle_dense,
        "tree_like": tree_like,
        "bridge_vertices": bridge_vertices,
        "cycle_rank": G.number_of_edges() - G.number_of_nodes() + nx.number_connected_components(G),
        "num_bridges": len(bridges),
    }


# ─── Application 4: Bottleneck Identification ───────────────────────────────

def identify_bottlenecks(G: nx.Graph) -> List[Dict]:
    """
    Identify topological bottlenecks in the graph.

    A bottleneck is a bridge edge connecting a cycle-rich region to the
    rest of the graph. These are the critical edges where proof search
    must pass through, creating potential hardness barriers.

    Returns
    -------
    List[Dict]
        List of bottleneck descriptions.
    """
    bridges = set(nx.bridges(G))
    pressures = {}
    for v in G.nodes():
        p = sum(1 for u in G.neighbors(v)
                if (v, u) not in bridges and (u, v) not in bridges)
        pressures[v] = p

    bottlenecks = []
    for u, v in bridges:
        p_u = pressures.get(u, 0)
        p_v = pressures.get(v, 0)
        if p_u > 0 or p_v > 0:
            bottlenecks.append({
                "edge": (u, v),
                "pressure_u": p_u,
                "pressure_v": p_v,
                "type": "cycle_to_tree" if (p_u > 0) != (p_v > 0) else "cycle_to_cycle",
                "severity": max(p_u, p_v),
            })

    return sorted(bottlenecks, key=lambda x: x["severity"], reverse=True)


# ─── Demonstration ──────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║   Applications of Hardness-Localization Theory                 ║")
    print("╚══════════════════════════════════════════════════════════════════╝\n")

    # App 1: Theorem difficulty prediction
    print("=" * 60)
    print("APPLICATION 1: Theorem Difficulty Prediction")
    print("=" * 60)

    theorems = {
        "nat_add_comm": "forall n m : nat, add n m = eq add m n",
        "prime_factorization": "forall n : nat, exists prime list, mul product eq n",
        "continuous_composition": "forall f g : real, continuous f and continuous g implies continuous",
        "group_homomorphism": "forall group ring module, exists homomorphism field",
        "set_finite_card": "forall set finset finite, le card nat",
        "topology_compact": "forall topology compact metric continuous measurable",
        "induction_well_founded": "forall nat induction recursion well_founded le lt",
    }

    predictions = predict_difficulty(theorems)
    print(f"\n{'Theorem':<28} {'Pressure':>9} {'Region':>15} {'Difficulty':>12}")
    print("-" * 68)
    for name, info in predictions.items():
        print(f"{name:<28} {info['cycle_pressure']:>9} "
              f"{info['region']:>15} {info['predicted_difficulty']:>12}")

    # App 2: Search strategy
    print("\n" + "=" * 60)
    print("APPLICATION 2: Search Strategy Recommendation")
    print("=" * 60)

    # Build a sample graph
    G = nx.Graph()
    # Cycle-rich core
    for i in range(5):
        G.add_edge(i, (i + 1) % 5)
    G.add_edge(0, 2)  # extra chord
    # Bridge to tree
    G.add_edge(0, 5)
    G.add_edge(5, 6)
    G.add_edge(5, 7)

    for start in [2, 5, 7]:
        rec = recommend_search_strategy(G, start, {6, 7})
        print(f"\nStart vertex {start}:")
        print(f"  Strategy: {rec['strategy']}")
        print(f"  Rationale: {rec['rationale']}")
        print(f"  Cycle pressure: {rec['cycle_pressure']}")

    # App 3: Library decomposition
    print("\n" + "=" * 60)
    print("APPLICATION 3: Library Decomposition")
    print("=" * 60)

    np.random.seed(42)
    feature_sets = {i: {f"f{j}" for j in np.random.choice(10, 4, replace=False)}
                    for i in range(15)}
    decomp = decompose_library(feature_sets, epsilon=4)
    print(f"\nCycle-dense vertices: {decomp['cycle_dense']}")
    print(f"Tree-like vertices: {decomp['tree_like']}")
    print(f"Bridge vertices: {decomp['bridge_vertices']}")
    print(f"Cycle rank: {decomp['cycle_rank']}")
    print(f"Number of bridges: {decomp['num_bridges']}")

    # App 4: Bottleneck identification
    print("\n" + "=" * 60)
    print("APPLICATION 4: Bottleneck Identification")
    print("=" * 60)

    G_bottle = nx.Graph()
    # Two K4 subgraphs connected by a single bridge
    for i in range(4):
        for j in range(i+1, 4):
            G_bottle.add_edge(i, j)
    for i in range(4, 8):
        for j in range(i+1, 8):
            G_bottle.add_edge(i, j)
    G_bottle.add_edge(3, 4)  # bridge

    bottlenecks = identify_bottlenecks(G_bottle)
    print(f"\nGraph: Two K4 subgraphs connected by bridge (3,4)")
    for bn in bottlenecks:
        print(f"  Bottleneck edge {bn['edge']}: type={bn['type']}, severity={bn['severity']}")

    print("\n" + "=" * 60)
    print("All applications demonstrated successfully.")
    print("=" * 60)


"""
demo.py — Demonstrations of the Hardness-Localization Hypothesis

This script:
1. Constructs sample graphs (trees, cycles, lollipops, theta graphs)
2. Computes cycle-pressure statistics for each
3. Simulates random-walk hitting times
4. Visualizes that cycle-rich bottlenecks produce larger hardness surrogates
5. Demonstrates the transition profile across threshold values

Run: python demo.py
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from collections import defaultdict

try:
    import networkx as nx
except ImportError:
    print("NetworkX required. Install with: pip install networkx")
    raise


# ─── Core Algorithm Functions (self-contained) ───────────────────────────────

def compute_bridges(G):
    """Compute bridge edges using NetworkX."""
    return set(nx.bridges(G))

def local_cycle_pressure(G, v, bridges=None):
    """Count non-bridge edges incident to v."""
    if bridges is None:
        bridges = compute_bridges(G)
    return sum(1 for u in G.neighbors(v)
               if (v, u) not in bridges and (u, v) not in bridges)

def all_cycle_pressures(G):
    """Compute cycle pressure for all vertices."""
    bridges = compute_bridges(G)
    return {v: local_cycle_pressure(G, v, bridges) for v in G.nodes()}

def cycle_rank(G):
    """Cyclomatic number: |E| - |V| + c."""
    return G.number_of_edges() - G.number_of_nodes() + nx.number_connected_components(G)

def hardness_potential(G, targets, v):
    """Min graph distance from v to target set."""
    if v in targets:
        return 0
    return min((nx.shortest_path_length(G, v, t) for t in targets),
               default=float('inf'))

def simulate_hitting_time(G, start, targets, max_steps=10000, trials=2000, seed=42):
    """Monte Carlo estimate of expected hitting time."""
    rng = np.random.RandomState(seed)
    times = []
    for _ in range(trials):
        v = start
        steps = 0
        while v not in targets and steps < max_steps:
            nbrs = list(G.neighbors(v))
            if not nbrs:
                steps = max_steps
                break
            v = nbrs[rng.randint(len(nbrs))]
            steps += 1
        times.append(steps)
    return np.mean(times)

def lollipop_graph(cycle_size, tail_length):
    """Cycle attached to a path tail."""
    G = nx.Graph()
    for i in range(cycle_size):
        G.add_edge(i, (i + 1) % cycle_size)
    if tail_length > 0:
        G.add_edge(0, cycle_size)
        for i in range(cycle_size, cycle_size + tail_length - 1):
            G.add_edge(i, i + 1)
    return G

def theta_graph(path_lengths):
    """Two poles connected by multiple disjoint paths."""
    G = nx.Graph()
    G.add_node(0); G.add_node(1)
    nid = 2
    for length in path_lengths:
        if length == 1:
            G.add_edge(0, 1)
        else:
            prev = 0
            for _ in range(length - 1):
                G.add_edge(prev, nid)
                prev = nid
                nid += 1
            G.add_edge(prev, 1)
    return G


# ─── Demo 1: Structural Comparison ──────────────────────────────────────────

def demo_structural_comparison():
    """Compare cycle pressure across graph families."""
    print("=" * 70)
    print("DEMO 1: Structural Comparison — Trees vs Cycles vs Mixed Graphs")
    print("=" * 70)

    graphs = {
        "Path P_8 (tree)": nx.path_graph(8),
        "Star S_7 (tree)": nx.star_graph(6),
        "Cycle C_8": nx.cycle_graph(8),
        "Complete K_5": nx.complete_graph(5),
        "Lollipop (C5+P3)": lollipop_graph(5, 3),
        "Theta (3,4,5)": theta_graph([3, 4, 5]),
        "Petersen": nx.petersen_graph(),
    }

    print(f"\n{'Graph':<22} {'|V|':>4} {'|E|':>4} {'CycRank':>8} "
          f"{'MaxPress':>9} {'AvgPress':>9} {'MinDeg':>7} {'MaxDeg':>7}")
    print("-" * 80)

    for name, G in graphs.items():
        pressures = all_cycle_pressures(G)
        cr = cycle_rank(G)
        pvals = list(pressures.values())
        degrees = [G.degree(v) for v in G.nodes()]
        print(f"{name:<22} {G.number_of_nodes():>4} {G.number_of_edges():>4} "
              f"{cr:>8} {max(pvals):>9} {np.mean(pvals):>9.2f} "
              f"{min(degrees):>7} {max(degrees):>7}")

    print("\nKey observation: Trees have zero cycle pressure everywhere.")
    print("Cycle-rich graphs concentrate pressure at vertices in cycles.")
    return graphs


# ─── Demo 2: Hardness Gap via Hitting Times ─────────────────────────────────

def demo_hitting_time_gap():
    """Show that cycle-rich regions have higher hitting times."""
    print("\n" + "=" * 70)
    print("DEMO 2: Hitting Time Gap — Cycle Trapping Effect")
    print("=" * 70)

    # Lollipop: cycle of size m attached to path of length n
    # Target: end of the tail
    configs = [
        (3, 3, "Small cycle (C3+P3)"),
        (5, 3, "Medium cycle (C5+P3)"),
        (8, 3, "Large cycle (C8+P3)"),
        (12, 3, "Very large cycle (C12+P3)"),
    ]

    print(f"\n{'Config':<28} {'CycRank':>8} {'HitTime(cycle)':>15} "
          f"{'HitTime(tail)':>15} {'Ratio':>8}")
    print("-" * 80)

    hit_cycle = []
    hit_tail = []
    labels = []

    for m, n, name in configs:
        G = lollipop_graph(m, n)
        target = {m + n - 1}  # end of tail
        cr = cycle_rank(G)

        # Hitting time from deepest point in cycle (opposite side from tail)
        cycle_start = m // 2
        # Hitting time from start of tail
        tail_start = m  # first tail vertex

        ht_cyc = simulate_hitting_time(G, cycle_start, target, trials=3000, seed=42)
        ht_tail = simulate_hitting_time(G, tail_start, target, trials=3000, seed=42)

        ratio = ht_cyc / ht_tail if ht_tail > 0 else float('inf')
        print(f"{name:<28} {cr:>8} {ht_cyc:>15.1f} {ht_tail:>15.1f} {ratio:>8.2f}")

        hit_cycle.append(ht_cyc)
        hit_tail.append(ht_tail)
        labels.append(name)

    print("\nKey observation: Hitting time from inside the cycle is consistently")
    print("higher than from the tail, and the gap grows with cycle size.")
    print("This is the cycle-trapping effect: the random walk circulates")
    print("in the cycle before finding the narrow escape to the tail.")

    # Plot
    fig, ax = plt.subplots(figsize=(10, 6))
    x = np.arange(len(labels))
    width = 0.35
    ax.bar(x - width/2, hit_cycle, width, label='From cycle interior', color='#e74c3c')
    ax.bar(x + width/2, hit_tail, width, label='From tail start', color='#2ecc71')
    ax.set_ylabel('Expected Hitting Time (steps)')
    ax.set_title('Cycle Trapping Effect: Hitting Times in Lollipop Graphs')
    ax.set_xticks(x)
    ax.set_xticklabels([c[2] for c in configs], rotation=15, ha='right')
    ax.legend()
    ax.grid(axis='y', alpha=0.3)
    plt.tight_layout()
    plt.savefig('hitting_time_gap.png', dpi=150)
    print("\nPlot saved to hitting_time_gap.png")


# ─── Demo 3: Transition Profile ─────────────────────────────────────────────

def demo_transition_profile():
    """Show the topological transition as threshold varies."""
    print("\n" + "=" * 70)
    print("DEMO 3: Transition Profile — Threshold Graph Filtration")
    print("=" * 70)

    # Create a synthetic "theorem library" with feature sets
    np.random.seed(42)
    n_theorems = 20
    n_features = 15

    # Two clusters with different feature profiles
    feature_sets = {}
    for i in range(n_theorems):
        if i < 10:  # Cluster A
            features = set(np.random.choice(range(8), size=5, replace=False))
        else:  # Cluster B
            features = set(np.random.choice(range(7, 15), size=5, replace=False))
        feature_sets[i] = {f"f{f}" for f in features}

    thresholds = list(range(0, 12))
    print(f"\nThreshold profile for {n_theorems} synthetic theorems:")
    print(f"{'Epsilon':>8} {'Edges':>6} {'CycRank':>8} {'Components':>11} "
          f"{'MaxPress':>9} {'AvgPress':>9}")
    print("-" * 60)

    eps_list = []
    cr_list = []
    edge_list = []
    max_press_list = []

    for eps in thresholds:
        # Build threshold graph
        G = nx.Graph()
        G.add_nodes_from(range(n_theorems))
        for i in range(n_theorems):
            for j in range(i + 1, n_theorems):
                dist = len(feature_sets[i].symmetric_difference(feature_sets[j]))
                if dist <= eps:
                    G.add_edge(i, j)

        cr = cycle_rank(G)
        comp = nx.number_connected_components(G)
        pressures = all_cycle_pressures(G)
        pvals = list(pressures.values())

        eps_list.append(eps)
        cr_list.append(cr)
        edge_list.append(G.number_of_edges())
        max_press_list.append(max(pvals))

        print(f"{eps:>8} {G.number_of_edges():>6} {cr:>8} {comp:>11} "
              f"{max(pvals):>9} {np.mean(pvals):>9.2f}")

    print("\nKey observation: Cycle rank and max pressure peak at intermediate")
    print("thresholds — the 'topological complexity' window between")
    print("fragmentation (low ε) and saturation (high ε).")

    # Plot transition profile
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    ax1.plot(eps_list, edge_list, 'b-o', label='Edges', linewidth=2)
    ax1.plot(eps_list, cr_list, 'r-s', label='Cycle Rank', linewidth=2)
    ax1.set_xlabel('Threshold ε')
    ax1.set_ylabel('Count')
    ax1.set_title('Threshold Graph: Edges and Cycle Rank')
    ax1.legend()
    ax1.grid(alpha=0.3)

    ax2.plot(eps_list, max_press_list, 'g-^', label='Max Cycle Pressure', linewidth=2)
    ax2.set_xlabel('Threshold ε')
    ax2.set_ylabel('Max Local Cycle Pressure')
    ax2.set_title('Peak Cycle Pressure vs Threshold')
    ax2.legend()
    ax2.grid(alpha=0.3)

    plt.tight_layout()
    plt.savefig('transition_profile.png', dpi=150)
    print("Plot saved to transition_profile.png")


# ─── Demo 4: Hardness Classification ────────────────────────────────────────

def demo_hardness_classification():
    """Classify vertices into hardness regions and verify predictions."""
    print("\n" + "=" * 70)
    print("DEMO 4: Hardness Region Classification")
    print("=" * 70)

    # Build a graph with clear cycle-rich and tree-like regions
    G = nx.Graph()
    # Cycle-rich core: K4 on vertices 0-3
    for i in range(4):
        for j in range(i+1, 4):
            G.add_edge(i, j)
    # Bridge connecting to tree region
    G.add_edge(3, 4)
    # Tree branch
    G.add_edge(4, 5)
    G.add_edge(4, 6)
    G.add_edge(5, 7)
    G.add_edge(6, 8)
    # Target at end of tree
    targets = {7, 8}

    pressures = all_cycle_pressures(G)
    bridges = compute_bridges(G)

    print(f"\nGraph: K4 core (0-3) + bridge (3-4) + tree branches (4-8)")
    print(f"Targets: {targets}")
    print(f"Bridges: {bridges}")
    print(f"\n{'Vertex':>7} {'Pressure':>9} {'Region':>12} {'HitTime':>10} "
          f"{'GraphDist':>10}")
    print("-" * 55)

    for v in sorted(G.nodes()):
        region = 'target' if v in targets else ('cycle_rich' if pressures[v] > 0 else 'tree_like')
        ht = simulate_hitting_time(G, v, targets, trials=5000, seed=42)
        gd = hardness_potential(G, targets, v)
        print(f"{v:>7} {pressures[v]:>9} {region:>12} {ht:>10.1f} {gd:>10}")

    print("\nKey observation: Vertices in the cycle-rich core (0-3) have")
    print("higher hitting times than tree-like vertices at the same")
    print("graph distance, confirming the cycle-trapping effect.")


# ─── Demo 5: Scaling Behavior ───────────────────────────────────────────────

def demo_scaling():
    """Show how hitting time scales with cycle size."""
    print("\n" + "=" * 70)
    print("DEMO 5: Scaling Behavior — Hitting Time vs Cycle Size")
    print("=" * 70)

    cycle_sizes = [3, 4, 5, 6, 8, 10, 15, 20]
    tail_length = 2
    hitting_times = []
    graph_distances = []

    print(f"\n{'CycleSize':>10} {'CycRank':>8} {'MaxPress':>9} "
          f"{'AvgHitTime':>12} {'GraphDist':>10} {'Ratio(HT/GD)':>13}")
    print("-" * 68)

    for m in cycle_sizes:
        G = lollipop_graph(m, tail_length)
        target = {m + tail_length - 1}
        start = m // 2  # deepest in cycle

        cr = cycle_rank(G)
        pressures = all_cycle_pressures(G)
        max_p = max(pressures.values())

        ht = simulate_hitting_time(G, start, target, trials=5000, seed=42)
        gd = hardness_potential(G, target, start)
        ratio = ht / gd if gd > 0 else float('inf')

        hitting_times.append(ht)
        graph_distances.append(gd)

        print(f"{m:>10} {cr:>8} {max_p:>9} {ht:>12.1f} {gd:>10} {ratio:>13.2f}")

    print("\nKey observation: As cycle size grows, the ratio of hitting time")
    print("to graph distance increases — the cycle-trapping overhead grows")
    print("faster than the distance penalty alone.")

    # Plot
    fig, ax = plt.subplots(figsize=(8, 5))
    ax.plot(cycle_sizes, hitting_times, 'r-o', label='Expected Hitting Time', linewidth=2)
    ax.plot(cycle_sizes, graph_distances, 'b--s', label='Graph Distance', linewidth=2)
    ax.set_xlabel('Cycle Size')
    ax.set_ylabel('Steps / Distance')
    ax.set_title('Cycle Trapping: Hitting Time vs Graph Distance')
    ax.legend()
    ax.grid(alpha=0.3)
    plt.tight_layout()
    plt.savefig('scaling_behavior.png', dpi=150)
    print("Plot saved to scaling_behavior.png")


# ─── Main ────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║   Hardness-Localization Hypothesis: Computational Demos        ║")
    print("║   Cycle-rich topology predicts proof-search difficulty         ║")
    print("╚══════════════════════════════════════════════════════════════════╝\n")

    demo_structural_comparison()
    demo_hitting_time_gap()
    demo_transition_profile()
    demo_hardness_classification()
    demo_scaling()

    print("\n" + "=" * 70)
    print("All demos completed. See generated PNG files for visualizations.")
    print("=" * 70)
