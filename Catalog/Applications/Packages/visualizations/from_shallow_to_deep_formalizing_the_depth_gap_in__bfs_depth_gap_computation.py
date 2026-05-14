"""
Algorithms for Conceptual Depth Gap Theory.

Implements the core algorithms from the research paper:
- BFS-based depth gap computation
- Derivative classification
- Chain graph construction
- Library enrichment analysis
"""

from __future__ import annotations
from collections import deque
from typing import Optional


class DerivationGraph:
    """A finite derivation graph with labeled nodes and directed edges.

    Represents the conceptual transformation graph where nodes are
    theorem presentations and edges are elementary conceptual leaps.

    Attributes:
        n: Number of nodes.
        adj: Adjacency list representation.
    """

    def __init__(self, n: int) -> None:
        """Initialize a derivation graph with n nodes (labeled 0..n-1)."""
        self.n = n
        self.adj: list[list[int]] = [[] for _ in range(n)]

    def add_edge(self, u: int, v: int) -> None:
        """Add a directed edge u -> v (a single conceptual leap)."""
        if v not in self.adj[u]:
            self.adj[u].append(v)

    def edge_count(self) -> int:
        """Return the total number of edges."""
        return sum(len(neighbors) for neighbors in self.adj)

    def compute_depth_gap(self, known: set[int], target: int) -> Optional[int]:
        """Compute the depth gap from the known set to the target.

        Uses multi-source BFS from all known nodes simultaneously.

        Args:
            known: Set of known theorem indices (the library K).
            target: Index of the target theorem.

        Returns:
            The shortest path length from any node in known to target,
            or None if the target is unreachable.

        Time complexity: O(|V| + |E|)
        Space complexity: O(|V|)
        """
        if target in known:
            return 0

        visited = set()
        queue: deque[tuple[int, int]] = deque()

        for k in known:
            queue.append((k, 0))
            visited.add(k)

        while queue:
            v, d = queue.popleft()
            for w in self.adj[v]:
                if w == target:
                    return d + 1
                if w not in visited:
                    visited.add(w)
                    queue.append((w, d + 1))

        return None  # Unreachable

    def compute_all_depth_gaps(self, known: set[int]) -> list[Optional[int]]:
        """Compute depth gaps from known set to all nodes.

        Uses multi-source BFS.

        Args:
            known: Set of known theorem indices.

        Returns:
            List where result[i] is the depth gap to node i,
            or None if unreachable.
        """
        dist: list[Optional[int]] = [None] * self.n
        queue: deque[tuple[int, int]] = deque()

        for k in known:
            dist[k] = 0
            queue.append((k, 0))

        while queue:
            v, d = queue.popleft()
            for w in self.adj[v]:
                if dist[w] is None:
                    dist[w] = d + 1
                    queue.append((w, d + 1))

        return dist

    def is_derivative(self, known: set[int], threshold: int, target: int) -> bool:
        """Check if target is derivative at the given threshold.

        A target is derivative if its depth gap is at most threshold.

        Args:
            known: Set of known theorem indices.
            threshold: Maximum allowed depth.
            target: Index of the target theorem.

        Returns:
            True if depth gap ≤ threshold, False otherwise.
        """
        gap = self.compute_depth_gap(known, target)
        return gap is not None and gap <= threshold

    def classify_all(self, known: set[int], threshold: int) -> dict[str, list[int]]:
        """Classify all nodes as derivative, novel, or unreachable.

        Args:
            known: Set of known theorem indices.
            threshold: Derivative threshold τ.

        Returns:
            Dictionary with keys 'derivative', 'novel', 'unreachable',
            each mapping to a list of node indices.
        """
        gaps = self.compute_all_depth_gaps(known)
        result: dict[str, list[int]] = {
            'derivative': [],
            'novel': [],
            'unreachable': []
        }

        for i, gap in enumerate(gaps):
            if gap is None:
                result['unreachable'].append(i)
            elif gap <= threshold:
                result['derivative'].append(i)
            else:
                result['novel'].append(i)

        return result


def make_chain_graph(n: int) -> DerivationGraph:
    """Create a chain graph: 0 -> 1 -> 2 -> ... -> n-1.

    This is the canonical example demonstrating exact depth gaps.

    Args:
        n: Number of nodes.

    Returns:
        A chain derivation graph.
    """
    g = DerivationGraph(n)
    for i in range(n - 1):
        g.add_edge(i, i + 1)
    return g


def make_binary_tree(depth: int) -> DerivationGraph:
    """Create a complete binary tree of given depth.

    Nodes are numbered by BFS order: root=0, children of i are 2i+1, 2i+2.

    Args:
        depth: Depth of the tree (root has depth 0).

    Returns:
        A binary tree derivation graph.
    """
    n = 2 ** (depth + 1) - 1
    g = DerivationGraph(n)
    for i in range(n):
        left = 2 * i + 1
        right = 2 * i + 2
        if left < n:
            g.add_edge(i, left)
        if right < n:
            g.add_edge(i, right)
    return g


def make_random_graph(n: int, p: float, seed: int = 42) -> DerivationGraph:
    """Create a random Erdős–Rényi directed graph G(n, p).

    Args:
        n: Number of nodes.
        p: Edge probability.
        seed: Random seed for reproducibility.

    Returns:
        A random derivation graph.
    """
    import random
    rng = random.Random(seed)
    g = DerivationGraph(n)
    for i in range(n):
        for j in range(n):
            if i != j and rng.random() < p:
                g.add_edge(i, j)
    return g


def library_enrichment_experiment(
    graph: DerivationGraph,
    initial_known: set[int],
    additions: list[int],
    target: int
) -> list[tuple[int, Optional[int]]]:
    """Track depth gap as the known library grows.

    Args:
        graph: The derivation graph.
        initial_known: Initial known set.
        additions: Nodes to add one by one.
        target: Target node.

    Returns:
        List of (library_size, depth_gap) pairs.
    """
    known = set(initial_known)
    results = [(len(known), graph.compute_depth_gap(known, target))]

    for node in additions:
        known.add(node)
        gap = graph.compute_depth_gap(known, target)
        results.append((len(known), gap))

    return results


if __name__ == "__main__":
    # Quick demo
    print("=== Chain Graph Demo ===")
    chain = make_chain_graph(11)
    known = {0}
    for t in range(11):
        gap = chain.compute_depth_gap(known, t)
        deriv = chain.is_derivative(known, 3, t)
        print(f"  Target {t:2d}: depth_gap={gap}, derivative(τ=3)={deriv}")

    print("\n=== Library Enrichment Demo ===")
    chain = make_chain_graph(11)
    results = library_enrichment_experiment(chain, {0}, [3, 5, 7, 9], 10)
    for size, gap in results:
        print(f"  |K|={size}: depthGap(target=10) = {gap}")
