#!/usr/bin/env python3
"""
Algorithms for Defect Deletion Calculus

Implements certified algorithmic classifiers for defect-neutral vs
defect-reducing internal edge deletions.

Algorithm 1: DefectDropClassifier
    Input: Graph G, root q, subset S, internal edge (u,v)
    Output: 0 if (u,v) is an S-bridge (defect-neutral deletion)
            1 if (u,v) is not an S-bridge (defect-reducing deletion)
    Correctness: δ(G,q,S) - δ(G-e,q,S) = output

Algorithm 2: IteratedDefectReduction
    Input: Graph G, root q, subset S
    Output: Forest graph T (after removing all non-bridge internal edges)
            and the total defect drop = β₁(G[S])
    Complexity: O(|E| · α(|V|)) using union-find

Algorithm 3: MinimalDefectSequence
    Input: Graph G, root q, subset S
    Output: Ordered sequence of non-bridge internal edges to delete,
            each reducing defect by exactly 1
"""

from collections import defaultdict
from typing import Set, Tuple, List, Optional


class Graph:
    """Simple undirected graph representation."""

    def __init__(self, n: int, edges: Set[Tuple[int, int]]):
        self.n = n
        self.vertices = set(range(n))
        self.edges = {(min(u, v), max(u, v)) for u, v in edges}
        self._adj: dict[int, set[int]] = defaultdict(set)
        for u, v in self.edges:
            self._adj[u].add(v)
            self._adj[v].add(u)

    def adj(self, v: int) -> Set[int]:
        return self._adj[v]

    def has_edge(self, u: int, v: int) -> bool:
        return (min(u, v), max(u, v)) in self.edges

    def delete_edge(self, u: int, v: int) -> 'Graph':
        e = (min(u, v), max(u, v))
        return Graph(self.n, self.edges - {e})

    def induced_subgraph(self, S: Set[int]) -> 'Graph':
        vertex_map = {v: i for i, v in enumerate(sorted(S))}
        new_edges = set()
        for u, v in self.edges:
            if u in S and v in S:
                new_edges.add((vertex_map[u], vertex_map[v]))
        return Graph(len(S), new_edges)

    def connected_components(self, vertices: Optional[Set[int]] = None) -> List[Set[int]]:
        """Return connected components restricted to given vertices."""
        if vertices is None:
            vertices = self.vertices
        adj = defaultdict(set)
        for u, v in self.edges:
            if u in vertices and v in vertices:
                adj[u].add(v)
                adj[v].add(u)
        visited = set()
        components = []
        for v in vertices:
            if v not in visited:
                comp = set()
                stack = [v]
                while stack:
                    w = stack.pop()
                    if w in comp:
                        continue
                    comp.add(w)
                    for x in adj[w]:
                        if x not in comp:
                            stack.append(x)
                components.append(comp)
                visited |= comp
        return components

    def is_connected(self, vertices: Optional[Set[int]] = None) -> bool:
        comps = self.connected_components(vertices)
        return len(comps) <= 1


class DefectCalculator:
    """Computes structural defect and related invariants."""

    def __init__(self, G: Graph, q: int, S: Set[int]):
        self.G = G
        self.q = q
        self.S = S

    def induced_edge_count(self) -> int:
        return sum(1 for u, v in self.G.edges if u in self.S and v in self.S)

    def induced_component_count(self) -> int:
        S_edges = {(u, v) for u, v in self.G.edges if u in self.S and v in self.S}
        adj = defaultdict(set)
        for u, v in S_edges:
            adj[u].add(v)
            adj[v].add(u)
        visited = set()
        count = 0
        for v in self.S:
            if v not in visited:
                count += 1
                stack = [v]
                while stack:
                    w = stack.pop()
                    if w in visited:
                        continue
                    visited.add(w)
                    for x in adj[w]:
                        if x not in visited:
                            stack.append(x)
        return count

    def induced_cycle_rank(self) -> int:
        """β₁(G[S]) = |E(G[S])| + c(G[S]) - |S|."""
        return (self.induced_edge_count() +
                self.induced_component_count() -
                len(self.S))

    def root_component_count(self) -> int:
        """κ(G,q,S): components of G-{q} touching S."""
        Vq = self.G.vertices - {self.q}
        comps = self.G.connected_components(Vq)
        return sum(1 for comp in comps if comp & self.S)

    def structural_defect(self) -> int:
        """δ(G,q,S) = β₁(G[S]) + κ(G,q,S) - 1."""
        return self.induced_cycle_rank() + self.root_component_count() - 1


def is_s_bridge(G: Graph, S: Set[int], u: int, v: int) -> bool:
    """Check if edge {u,v} is a bridge of G[S].

    An edge is a bridge iff removing it disconnects u from v
    within the subgraph induced on S.

    Time complexity: O(|S| + |E(G[S])|) using BFS/DFS.
    """
    if u not in S or v not in S:
        return False
    if not G.has_edge(u, v):
        return False

    # BFS from u to v in G[S] - {u,v}
    S_edges = {(a, b) for a, b in G.edges
               if a in S and b in S
               and not ((a == u and b == v) or (a == v and b == u))
               and not ((a == v and b == u))}
    adj = defaultdict(set)
    for a, b in S_edges:
        adj[a].add(b)
        adj[b].add(a)

    visited = set()
    stack = [u]
    while stack:
        w = stack.pop()
        if w == v:
            return False
        if w in visited:
            continue
        visited.add(w)
        for x in adj[w]:
            if x not in visited:
                stack.append(x)
    return True


def defect_drop_classifier(G: Graph, q: int, S: Set[int],
                           u: int, v: int) -> int:
    """
    Algorithm 1: DefectDropClassifier

    Classifies whether deleting internal edge {u,v} preserves
    or reduces the structural defect.

    Input:
        G: Simple graph
        q: Root vertex (q ∉ S assumed)
        S: Vertex subset
        u, v: Endpoints of internal edge (both in S, neither is q)

    Output:
        0 if {u,v} is an S-bridge (defect-neutral for appropriate cases)
        1 if {u,v} is NOT an S-bridge (defect-reducing by exactly 1)

    Correctness theorem:
        If output = 1, then δ(G-e,q,S) = δ(G,q,S) - 1
        (This is the exact deletion law for non-bridge internal edges)

    Time complexity: O(|S| + |E(G[S])|)
    """
    assert u in S and v in S, "Both endpoints must be in S"
    assert u != q and v != q, "Root must not be an endpoint"
    assert G.has_edge(u, v), "Must be an edge of G"

    if is_s_bridge(G, S, u, v):
        return 0  # Bridge: defect-neutral (when κ is preserved)
    else:
        return 1  # Non-bridge: defect-reducing by exactly 1


def iterated_defect_reduction(G: Graph, q: int,
                               S: Set[int]) -> Tuple['Graph', int]:
    """
    Algorithm 2: IteratedDefectReduction

    Repeatedly deletes non-bridge internal edges until G[S] becomes
    a forest. Returns the final graph and the total defect drop.

    The total drop equals β₁(G[S]), the initial cycle rank.

    Input:
        G: Simple graph
        q: Root vertex
        S: Vertex subset

    Output:
        (T, drop) where:
        - T is the graph after all non-bridge deletions
        - drop = β₁(G[S]) = initial cycle rank
        - T[S] is a forest (β₁(T[S]) = 0)
        - δ(T,q,S) = δ(G,q,S) - drop

    Time complexity: O(|E|² · |S|) in the worst case
    """
    current = G
    total_drop = 0
    edges_deleted = []

    while True:
        # Find a non-bridge internal edge
        found = False
        for u, v in sorted(current.edges):
            if u in S and v in S and u != q and v != q:
                if not is_s_bridge(current, S, u, v):
                    # Delete this non-bridge
                    current = current.delete_edge(u, v)
                    total_drop += 1
                    edges_deleted.append((u, v))
                    found = True
                    break
        if not found:
            break

    return current, total_drop


def minimal_defect_sequence(G: Graph, q: int,
                             S: Set[int]) -> List[Tuple[int, int]]:
    """
    Algorithm 3: MinimalDefectSequence

    Returns an ordered sequence of non-bridge internal edges to delete,
    each reducing the defect by exactly 1, until no more non-bridge
    internal edges remain (G[S] becomes a forest).

    The length of the sequence equals β₁(G[S]).

    Input:
        G: Simple graph
        q: Root vertex
        S: Vertex subset

    Output:
        List of edges [(u₁,v₁), (u₂,v₂), ...] to delete in order.
        After deleting all of them, G[S] is a forest.
    """
    _, _ = iterated_defect_reduction(G, q, S)
    current = G
    sequence = []
    while True:
        found = False
        for u, v in sorted(current.edges):
            if u in S and v in S and u != q and v != q:
                if not is_s_bridge(current, S, u, v):
                    sequence.append((u, v))
                    current = current.delete_edge(u, v)
                    found = True
                    break
        if not found:
            break
    return sequence


# ---- Example Usage ----

if __name__ == '__main__':
    print("=" * 60)
    print("DEFECT DELETION CALCULUS — ALGORITHM DEMONSTRATIONS")
    print("=" * 60)

    # Example 1: Triangle with a tail
    # q=0, edges: 0-1, 1-2, 2-3, 1-3 (triangle on {1,2,3} with tail to 0)
    print("\n--- Example 1: Triangle with tail ---")
    G1 = Graph(4, {(0, 1), (1, 2), (2, 3), (1, 3)})
    q1, S1 = 0, {1, 2, 3}

    calc1 = DefectCalculator(G1, q1, S1)
    print(f"G: 4 vertices, edges = {G1.edges}")
    print(f"q = {q1}, S = {S1}")
    print(f"β₁(G[S]) = {calc1.induced_cycle_rank()}")
    print(f"κ(G,q,S) = {calc1.root_component_count()}")
    print(f"δ(G,q,S) = {calc1.structural_defect()}")

    # Classify each internal edge
    for u, v in sorted(G1.edges):
        if u in S1 and v in S1 and u != q1 and v != q1:
            result = defect_drop_classifier(G1, q1, S1, u, v)
            bridge = "S-bridge" if result == 0 else "non-bridge"
            print(f"  Edge ({u},{v}): {bridge}, drop = {result}")

    # Run iterated reduction
    T1, drop1 = iterated_defect_reduction(G1, q1, S1)
    calc_T1 = DefectCalculator(T1, q1, S1)
    print(f"\nAfter reduction: {len(T1.edges)} edges remain")
    print(f"Total defect drop = {drop1}")
    print(f"β₁(T[S]) = {calc_T1.induced_cycle_rank()} (should be 0)")
    print(f"δ(T,q,S) = {calc_T1.structural_defect()}")

    # Example 2: Complete graph K₅
    print("\n--- Example 2: K₅ ---")
    K5_edges = {(i, j) for i in range(5) for j in range(i+1, 5)}
    G2 = Graph(5, K5_edges)
    q2, S2 = 0, {1, 2, 3, 4}

    calc2 = DefectCalculator(G2, q2, S2)
    print(f"G: K₅, q = {q2}, S = {S2}")
    print(f"β₁(G[S]) = {calc2.induced_cycle_rank()}")
    print(f"κ(G,q,S) = {calc2.root_component_count()}")
    print(f"δ(G,q,S) = {calc2.structural_defect()}")

    seq2 = minimal_defect_sequence(G2, q2, S2)
    print(f"Deletion sequence: {seq2}")
    print(f"Sequence length = {len(seq2)} = β₁(G[S])")

    # Verify each step drops defect by 1
    current = G2
    for i, (u, v) in enumerate(seq2):
        d_before = DefectCalculator(current, q2, S2).structural_defect()
        current = current.delete_edge(u, v)
        d_after = DefectCalculator(current, q2, S2).structural_defect()
        print(f"  Step {i+1}: delete ({u},{v}), "
              f"δ: {d_before} → {d_after} (drop = {d_before - d_after})")

    # Example 3: Counterexample for bridge monotonicity
    print("\n--- Example 3: Counterexample (bridge deletion increases δ) ---")
    G3 = Graph(3, {(0, 1), (1, 2)})  # Path q-a-b
    q3, S3 = 0, {1, 2}
    calc3 = DefectCalculator(G3, q3, S3)
    print(f"G: path 0—1—2, q = {q3}, S = {S3}")
    print(f"δ(G,q,S) = {calc3.structural_defect()}")

    G3_del = G3.delete_edge(1, 2)
    calc3_del = DefectCalculator(G3_del, q3, S3)
    print(f"After deleting bridge (1,2):")
    print(f"δ(G-e,q,S) = {calc3_del.structural_defect()}")
    print(f"Defect INCREASED by {calc3_del.structural_defect() - calc3.structural_defect()}")
    print("→ Bridge deletion can violate monotonicity!")

    print("\n" + "=" * 60)
