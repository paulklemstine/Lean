"""
Algorithms for analyzing the DAG structure of proof networks.

Implements:
1. DAG construction from dependency relations
2. In-degree / out-degree computation
3. Topological layering (rank function)
4. Hub identification and fragility analysis
5. Power-law fitting (Clauset-Shalizi-Newman MLE)
"""
from typing import Dict, List, Set, Tuple, Optional
from collections import defaultdict
import math
import random


class ProofDAG:
    """A directed acyclic graph representing proof dependencies.

    Nodes are theorem identifiers (strings), edges represent
    'theorem A is used in the proof of theorem B'.
    """

    def __init__(self) -> None:
        self.nodes: Set[str] = set()
        self.edges: List[Tuple[str, str]] = []
        self._successors: Dict[str, Set[str]] = defaultdict(set)
        self._predecessors: Dict[str, Set[str]] = defaultdict(set)

    def add_node(self, name: str) -> None:
        self.nodes.add(name)

    def add_edge(self, source: str, target: str) -> None:
        """Add edge: source is used in proof of target."""
        self.nodes.add(source)
        self.nodes.add(target)
        self.edges.append((source, target))
        self._successors[source].add(target)
        self._predecessors[target].add(source)

    def in_degree(self, node: str) -> int:
        """Number of theorems that node depends on."""
        return len(self._predecessors.get(node, set()))

    def out_degree(self, node: str) -> int:
        """Number of theorems that depend on node."""
        return len(self._successors.get(node, set()))

    def in_degree_distribution(self) -> Dict[int, int]:
        """Compute in-degree distribution: P(k) = count of nodes with in-degree k."""
        dist: Dict[int, int] = defaultdict(int)
        for node in self.nodes:
            dist[self.in_degree(node)] += 1
        return dict(dist)

    def out_degree_distribution(self) -> Dict[int, int]:
        """Compute out-degree distribution."""
        dist: Dict[int, int] = defaultdict(int)
        for node in self.nodes:
            dist[self.out_degree(node)] += 1
        return dict(dist)

    def topological_layers(self) -> Dict[str, int]:
        """Compute the topological rank (layer) of each node.

        Layer 0 = sources (axioms), layer k+1 = nodes whose predecessors
        are all in layers ≤ k.

        Returns dict mapping node -> layer number.
        """
        layers: Dict[str, int] = {}
        remaining = set(self.nodes)

        layer = 0
        while remaining:
            # Find nodes whose all predecessors are already assigned
            current_layer = {
                n for n in remaining
                if all(p in layers for p in self._predecessors.get(n, set()))
            }
            if not current_layer:
                raise ValueError("Graph contains a cycle!")
            for n in current_layer:
                layers[n] = layer
            remaining -= current_layer
            layer += 1

        return layers

    def hub_scores(self, top_k: int = 10) -> List[Tuple[str, int]]:
        """Return the top-k nodes by out-degree (most depended-upon)."""
        scores = [(node, self.out_degree(node)) for node in self.nodes]
        scores.sort(key=lambda x: -x[1])
        return scores[:top_k]

    def remove_node(self, node: str) -> 'ProofDAG':
        """Return a new DAG with the given node and all its edges removed."""
        new_dag = ProofDAG()
        for n in self.nodes:
            if n != node:
                new_dag.add_node(n)
        for s, t in self.edges:
            if s != node and t != node:
                new_dag.add_edge(s, t)
        return new_dag

    def connected_components(self) -> List[Set[str]]:
        """Compute weakly connected components (treating edges as undirected)."""
        visited: Set[str] = set()
        components: List[Set[str]] = []

        # Build undirected adjacency
        undirected: Dict[str, Set[str]] = defaultdict(set)
        for s, t in self.edges:
            undirected[s].add(t)
            undirected[t].add(s)

        for node in self.nodes:
            if node not in visited:
                component: Set[str] = set()
                stack = [node]
                while stack:
                    current = stack.pop()
                    if current in visited:
                        continue
                    visited.add(current)
                    component.add(current)
                    for neighbor in undirected.get(current, set()):
                        if neighbor not in visited:
                            stack.append(neighbor)
                components.append(component)

        return components

    def fragility_analysis(self, node: str) -> Dict[str, any]:
        """Analyze what happens when a hub node is removed."""
        original_components = self.connected_components()
        reduced = self.remove_node(node)
        new_components = reduced.connected_components()

        return {
            'removed_node': node,
            'out_degree': self.out_degree(node),
            'in_degree': self.in_degree(node),
            'original_components': len(original_components),
            'new_components': len(new_components),
            'component_sizes': sorted([len(c) for c in new_components], reverse=True),
            'fragmentation_ratio': len(new_components) / max(len(original_components), 1),
        }

    def verify_handshaking(self) -> bool:
        """Verify the directed handshaking lemma: sum(in_degrees) = sum(out_degrees) = |E|."""
        sum_in = sum(self.in_degree(n) for n in self.nodes)
        sum_out = sum(self.out_degree(n) for n in self.nodes)
        return sum_in == sum_out == len(self.edges)


def fit_power_law_mle(degrees: List[int], x_min: int = 1) -> Tuple[float, float]:
    """Fit a power law P(k) ~ k^{-gamma} using MLE (Clauset-Shalizi-Newman method).

    Returns (gamma, standard_error).
    """
    filtered = [d for d in degrees if d >= x_min]
    n = len(filtered)
    if n == 0:
        return (0.0, 0.0)

    # MLE estimator: gamma = 1 + n / sum(ln(x_i / (x_min - 0.5)))
    sum_log = sum(math.log(x / (x_min - 0.5)) for x in filtered)
    if sum_log == 0:
        return (0.0, 0.0)

    gamma = 1.0 + n / sum_log
    std_err = (gamma - 1.0) / math.sqrt(n)

    return (gamma, std_err)


def generate_barabasi_albert_dag(n: int, m: int = 2, seed: int = 42) -> ProofDAG:
    """Generate a scale-free DAG using preferential attachment.

    This models the hypothesis that proof networks grow by preferential
    attachment: new theorems preferentially depend on already well-connected
    foundational results.

    Args:
        n: Number of nodes
        m: Number of edges to attach from each new node
        seed: Random seed
    """
    rng = random.Random(seed)
    dag = ProofDAG()

    # Start with m+1 nodes in a chain
    for i in range(m + 1):
        dag.add_node(f"T{i}")
    for i in range(m):
        dag.add_edge(f"T{i}", f"T{i+1}")

    # Preferential attachment
    for i in range(m + 1, n):
        new_node = f"T{i}"
        dag.add_node(new_node)

        # Select m existing nodes with probability proportional to out-degree + 1
        existing = list(dag.nodes - {new_node})
        weights = [dag.out_degree(node) + 1 for node in existing]
        total = sum(weights)
        probs = [w / total for w in weights]

        targets = set()
        attempts = 0
        while len(targets) < min(m, len(existing)) and attempts < 100:
            r = rng.random()
            cumsum = 0
            for j, p in enumerate(probs):
                cumsum += p
                if r <= cumsum:
                    targets.add(existing[j])
                    break
            attempts += 1

        for target in targets:
            dag.add_edge(target, new_node)

    return dag


def generate_mathematics_like_dag(n_axioms: int = 10, n_foundational: int = 50,
                                   n_intermediate: int = 200, n_frontier: int = 500,
                                   seed: int = 42) -> ProofDAG:
    """Generate a DAG that mimics the structure of mathematical proof networks.

    Four layers:
    - Axioms: the foundation (e.g., ZFC axioms, logical rules)
    - Foundational theorems: depend on axioms (e.g., Zorn's Lemma, IVT)
    - Intermediate results: depend on foundational theorems
    - Frontier theorems: depend on intermediate and foundational results

    The key feature is hub dominance: foundational theorems have very high
    out-degree, while frontier theorems have low out-degree.
    """
    rng = random.Random(seed)
    dag = ProofDAG()

    axioms = [f"Axiom_{i}" for i in range(n_axioms)]
    foundational = [f"Foundation_{i}" for i in range(n_foundational)]
    intermediate = [f"Intermediate_{i}" for i in range(n_intermediate)]
    frontier = [f"Frontier_{i}" for i in range(n_frontier)]

    for a in axioms:
        dag.add_node(a)

    # Foundational theorems depend on 2-5 axioms
    for f in foundational:
        dag.add_node(f)
        n_deps = rng.randint(2, min(5, n_axioms))
        deps = rng.sample(axioms, n_deps)
        for d in deps:
            dag.add_edge(d, f)

    # Intermediate results depend on 1-3 foundational + 0-2 axioms
    for inter in intermediate:
        dag.add_node(inter)
        n_found = rng.randint(1, min(3, n_foundational))
        deps = rng.sample(foundational, n_found)
        n_ax = rng.randint(0, min(2, n_axioms))
        deps += rng.sample(axioms, n_ax)
        for d in deps:
            dag.add_edge(d, inter)

    # Frontier theorems depend on 1-4 intermediate + 0-2 foundational
    for front in frontier:
        dag.add_node(front)
        n_inter = rng.randint(1, min(4, n_intermediate))
        deps = rng.sample(intermediate, n_inter)
        n_found = rng.randint(0, min(2, n_foundational))
        deps += rng.sample(foundational, n_found)
        for d in deps:
            dag.add_edge(d, front)

    return dag
