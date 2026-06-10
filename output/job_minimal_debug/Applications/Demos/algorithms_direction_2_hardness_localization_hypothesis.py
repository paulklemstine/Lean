"""
algorithms.py — Algorithms for Hardness-Localization in Proof-Theoretic Topology

Implements the core computational methods for:
1. Edge cycle participation detection
2. Local cycle pressure computation
3. Hardness potential estimation via graph distance
4. Cycle-rank computation and threshold graph construction

All algorithms operate on NetworkX graphs for clarity and reproducibility.
"""

from typing import Dict, List, Set, Tuple, Optional
import networkx as nx
import numpy as np
from collections import defaultdict


def edge_in_cycle(G: nx.Graph, u: int, v: int) -> bool:
    """
    Determine whether edge (u, v) lies on some cycle in G.

    An edge is in a cycle iff it is not a bridge. Equivalently,
    removing it does not disconnect its endpoints.

    Time complexity: O(|V| + |E|) via bridge detection.

    Parameters
    ----------
    G : nx.Graph
        A simple undirected graph.
    u, v : int
        Endpoints of the edge.

    Returns
    -------
    bool
        True if the edge lies on at least one cycle.

    Example
    -------
    >>> G = nx.cycle_graph(4)
    >>> edge_in_cycle(G, 0, 1)
    True
    >>> T = nx.path_graph(4)
    >>> edge_in_cycle(T, 0, 1)
    False
    """
    if not G.has_edge(u, v):
        return False
    bridges = set(nx.bridges(G))
    return (u, v) not in bridges and (v, u) not in bridges


def compute_all_bridges(G: nx.Graph) -> Set[Tuple[int, int]]:
    """
    Compute the set of all bridge edges in G.

    Time complexity: O(|V| + |E|) using Tarjan's bridge-finding algorithm.

    Returns
    -------
    Set[Tuple[int, int]]
        Set of bridge edges as (u, v) tuples.
    """
    return set(nx.bridges(G))


def edge_cycle_participation(G: nx.Graph, u: int, v: int) -> int:
    """
    Binary cycle participation indicator for edge (u, v).

    Returns 1 if the edge lies on some cycle, 0 otherwise.

    Parameters
    ----------
    G : nx.Graph
    u, v : int

    Returns
    -------
    int
        1 if edge is in a cycle, 0 otherwise.
    """
    return 1 if edge_in_cycle(G, u, v) else 0


def local_cycle_pressure(G: nx.Graph, v: int) -> int:
    """
    Compute the local cycle pressure at vertex v.

    This is the number of edges incident to v that lie on some cycle
    (i.e., are not bridges).

    Time complexity: O(|V| + |E|) for bridge computation, then O(deg(v)).

    Parameters
    ----------
    G : nx.Graph
    v : int

    Returns
    -------
    int
        Number of non-bridge edges incident to v.

    Example
    -------
    >>> G = nx.cycle_graph(5)
    >>> local_cycle_pressure(G, 0)
    2
    >>> T = nx.path_graph(5)
    >>> local_cycle_pressure(T, 2)
    0
    """
    bridges = compute_all_bridges(G)
    pressure = 0
    for u in G.neighbors(v):
        if (v, u) not in bridges and (u, v) not in bridges:
            pressure += 1
    return pressure


def compute_all_cycle_pressures(G: nx.Graph) -> Dict[int, int]:
    """
    Compute local cycle pressure for every vertex in G.

    Time complexity: O(|V| + |E|).

    Returns
    -------
    Dict[int, int]
        Mapping from vertex to its local cycle pressure.
    """
    bridges = compute_all_bridges(G)
    pressures = {}
    for v in G.nodes():
        p = 0
        for u in G.neighbors(v):
            if (v, u) not in bridges and (u, v) not in bridges:
                p += 1
        pressures[v] = p
    return pressures


def graph_cycle_rank(G: nx.Graph) -> int:
    """
    Compute the cycle rank (cyclomatic number) of G.

    cycle_rank = |E| - |V| + c, where c is the number of connected components.
    This is the first Betti number of the graph as a 1-dimensional CW complex.

    Parameters
    ----------
    G : nx.Graph

    Returns
    -------
    int
        The cycle rank (always ≥ 0 for simple graphs).

    Example
    -------
    >>> graph_cycle_rank(nx.cycle_graph(5))
    1
    >>> graph_cycle_rank(nx.path_graph(5))
    0
    >>> graph_cycle_rank(nx.complete_graph(4))
    3
    """
    return G.number_of_edges() - G.number_of_nodes() + nx.number_connected_components(G)


def hardness_potential(G: nx.Graph, targets: Set[int], v: int) -> float:
    """
    Compute the hardness potential of vertex v with respect to target set.

    This is the minimum graph distance from v to any vertex in the target set.
    Returns float('inf') if v is unreachable from all targets.

    Parameters
    ----------
    G : nx.Graph
    targets : Set[int]
        The target vertex set.
    v : int
        Source vertex.

    Returns
    -------
    float
        Minimum distance to target set.
    """
    if v in targets:
        return 0
    min_dist = float('inf')
    for t in targets:
        try:
            d = nx.shortest_path_length(G, v, t)
            min_dist = min(min_dist, d)
        except nx.NetworkXNoPath:
            continue
    return min_dist


def build_semantic_threshold_graph(
    feature_sets: Dict[int, Set[str]],
    epsilon: int
) -> nx.Graph:
    """
    Construct the semantic threshold graph at parameter epsilon.

    Two distinct nodes are adjacent iff their symmetric difference
    cardinality (semantic distance) is at most epsilon.

    Parameters
    ----------
    feature_sets : Dict[int, Set[str]]
        Mapping from node ID to its feature set.
    epsilon : int
        Distance threshold.

    Returns
    -------
    nx.Graph
        The threshold graph.
    """
    G = nx.Graph()
    nodes = list(feature_sets.keys())
    G.add_nodes_from(nodes)
    for i in range(len(nodes)):
        for j in range(i + 1, len(nodes)):
            u, v = nodes[i], nodes[j]
            dist = len(feature_sets[u].symmetric_difference(feature_sets[v]))
            if dist <= epsilon:
                G.add_edge(u, v, weight=dist)
    return G


def transition_profile(
    feature_sets: Dict[int, Set[str]],
    thresholds: List[int]
) -> List[Tuple[int, int, int, int]]:
    """
    Compute the transition profile across threshold values.

    For each threshold epsilon, computes:
    - Number of edges
    - Cycle rank
    - Number of connected components
    - Maximum local cycle pressure

    Parameters
    ----------
    feature_sets : Dict[int, Set[str]]
    thresholds : List[int]

    Returns
    -------
    List[Tuple[int, int, int, int]]
        List of (edges, cycle_rank, components, max_pressure) per threshold.
    """
    profile = []
    for eps in thresholds:
        G = build_semantic_threshold_graph(feature_sets, eps)
        edges = G.number_of_edges()
        cr = graph_cycle_rank(G)
        comp = nx.number_connected_components(G)
        pressures = compute_all_cycle_pressures(G)
        max_p = max(pressures.values()) if pressures else 0
        profile.append((edges, cr, comp, max_p))
    return profile


def simulate_random_walk_hitting_time(
    G: nx.Graph,
    start: int,
    targets: Set[int],
    max_steps: int = 10000,
    num_trials: int = 1000,
    seed: Optional[int] = None
) -> float:
    """
    Estimate expected hitting time from start to target set via Monte Carlo.

    Simulates a simple random walk on G starting from `start`, counting
    steps until the walker first reaches a vertex in `targets`.

    Parameters
    ----------
    G : nx.Graph
    start : int
    targets : Set[int]
    max_steps : int
        Maximum walk length before declaring timeout.
    num_trials : int
        Number of independent walk simulations.
    seed : Optional[int]

    Returns
    -------
    float
        Estimated expected hitting time (average over trials).
    """
    rng = np.random.RandomState(seed)
    total_time = 0
    for _ in range(num_trials):
        v = start
        steps = 0
        while v not in targets and steps < max_steps:
            neighbors = list(G.neighbors(v))
            if not neighbors:
                steps = max_steps
                break
            v = neighbors[rng.randint(len(neighbors))]
            steps += 1
        total_time += steps
    return total_time / num_trials


def classify_hardness_regions(
    G: nx.Graph,
    targets: Set[int]
) -> Dict[int, str]:
    """
    Classify vertices into hardness regions based on cycle pressure.

    Categories:
    - 'target': vertex is in the target set
    - 'tree_like': zero local cycle pressure (easy region)
    - 'cycle_trapped': positive local cycle pressure (hard region)

    Parameters
    ----------
    G : nx.Graph
    targets : Set[int]

    Returns
    -------
    Dict[int, str]
        Vertex-to-category mapping.
    """
    pressures = compute_all_cycle_pressures(G)
    classification = {}
    for v in G.nodes():
        if v in targets:
            classification[v] = 'target'
        elif pressures[v] == 0:
            classification[v] = 'tree_like'
        else:
            classification[v] = 'cycle_trapped'
    return classification


def lollipop_graph(cycle_size: int, tail_length: int) -> nx.Graph:
    """
    Construct a lollipop graph: a cycle of given size attached to a path.

    The cycle vertices are 0, ..., cycle_size-1.
    The tail vertices are cycle_size, ..., cycle_size + tail_length - 1.
    The tail is attached at vertex 0 of the cycle.

    Parameters
    ----------
    cycle_size : int
        Number of vertices in the cycle (must be ≥ 3).
    tail_length : int
        Number of vertices in the tail path.

    Returns
    -------
    nx.Graph
    """
    G = nx.Graph()
    # Build cycle
    for i in range(cycle_size):
        G.add_edge(i, (i + 1) % cycle_size)
    # Build tail
    if tail_length > 0:
        G.add_edge(0, cycle_size)
        for i in range(cycle_size, cycle_size + tail_length - 1):
            G.add_edge(i, i + 1)
    return G


def theta_graph(path_lengths: List[int]) -> nx.Graph:
    """
    Construct a theta graph: two vertices connected by multiple internally
    disjoint paths of given lengths.

    Vertex 0 and vertex 1 are the two endpoints.
    Each path has internal vertices labeled sequentially.

    Parameters
    ----------
    path_lengths : List[int]
        Lengths of the parallel paths (each ≥ 2).

    Returns
    -------
    nx.Graph
    """
    G = nx.Graph()
    G.add_node(0)
    G.add_node(1)
    next_id = 2
    for length in path_lengths:
        if length == 1:
            G.add_edge(0, 1)
        else:
            prev = 0
            for _ in range(length - 1):
                G.add_edge(prev, next_id)
                prev = next_id
                next_id += 1
            G.add_edge(prev, 1)
    return G


if __name__ == "__main__":
    # Quick demonstration
    print("=== Cycle Graph (C5) ===")
    C5 = nx.cycle_graph(5)
    print(f"Cycle rank: {graph_cycle_rank(C5)}")
    pressures = compute_all_cycle_pressures(C5)
    print(f"Cycle pressures: {pressures}")

    print("\n=== Path Graph (P5) ===")
    P5 = nx.path_graph(5)
    print(f"Cycle rank: {graph_cycle_rank(P5)}")
    pressures = compute_all_cycle_pressures(P5)
    print(f"Cycle pressures: {pressures}")

    print("\n=== Lollipop Graph (cycle=5, tail=3) ===")
    L = lollipop_graph(5, 3)
    print(f"Cycle rank: {graph_cycle_rank(L)}")
    pressures = compute_all_cycle_pressures(L)
    print(f"Cycle pressures: {pressures}")
    classification = classify_hardness_regions(L, {7})
    print(f"Classification: {classification}")

    print("\n=== Complete Graph (K4) ===")
    K4 = nx.complete_graph(4)
    print(f"Cycle rank: {graph_cycle_rank(K4)}")
    pressures = compute_all_cycle_pressures(K4)
    print(f"Cycle pressures: {pressures}")
