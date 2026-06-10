#!/usr/bin/env python3
"""
Directed Cycle Pressure — Core Algorithms

Implements the SCC-based directed pressure computation with full pseudocode
documentation, complexity analysis, and correctness proofs.

Time complexity: O(V * (V + E)) per vertex-radius pair
Space complexity: O(V + E)
"""

from collections import defaultdict
from typing import Dict, List, Set, Tuple, Optional


class DirectedGraph:
    """A directed graph supporting SCC-based pressure computation.

    Attributes:
        adj: Adjacency list (forward edges).
        vertices: Set of all vertices.
    """

    def __init__(self, edges: List[Tuple[str, str]]):
        """Initialize from a list of directed edges (u, v)."""
        self.adj: Dict[str, List[str]] = defaultdict(list)
        self.vertices: Set[str] = set()
        for u, v in edges:
            self.adj[u].append(v)
            self.vertices.add(u)
            self.vertices.add(v)

    def out_ball(self, v: str, r: int) -> Set[str]:
        """Compute the directed out-ball of radius r around vertex v.

        Algorithm (iterative BFS):
            B_0 = {v}
            B_{k+1} = B_k ∪ { u : ∃ w ∈ B_k, (w,u) ∈ E }

        Returns B_r.

        Time: O(r * (|B_r| + E_local))
        Space: O(|B_r|)
        """
        ball = {v}
        for _ in range(r):
            frontier = set()
            for w in ball:
                for u in self.adj.get(w, []):
                    frontier.add(u)
            ball = ball | frontier
        return ball

    def tarjan_sccs(self, vertices: Optional[Set[str]] = None) -> List[Set[str]]:
        """Find all SCCs using Tarjan's algorithm.

        Pseudocode:
            index_counter = 0
            S = empty stack
            for each v in V:
                if v not yet visited:
                    STRONGCONNECT(v)

            STRONGCONNECT(v):
                v.index = v.lowlink = index_counter++
                push v onto S
                for each (v, w) in E:
                    if w not visited:
                        STRONGCONNECT(w)
                        v.lowlink = min(v.lowlink, w.lowlink)
                    elif w on stack:
                        v.lowlink = min(v.lowlink, w.index)
                if v.lowlink == v.index:
                    pop SCC from S until v is popped

        Time: O(V + E)
        Space: O(V)
        """
        if vertices is None:
            vertices = self.vertices

        index_counter = [0]
        stack: List[str] = []
        lowlink: Dict[str, int] = {}
        index: Dict[str, int] = {}
        on_stack: Set[str] = set()
        sccs: List[Set[str]] = []

        def strongconnect(v: str) -> None:
            index[v] = index_counter[0]
            lowlink[v] = index_counter[0]
            index_counter[0] += 1
            stack.append(v)
            on_stack.add(v)

            for w in self.adj.get(v, []):
                if w not in vertices:
                    continue
                if w not in index:
                    strongconnect(w)
                    lowlink[v] = min(lowlink[v], lowlink[w])
                elif w in on_stack:
                    lowlink[v] = min(lowlink[v], index[w])

            if lowlink[v] == index[v]:
                scc: Set[str] = set()
                while True:
                    w = stack.pop()
                    on_stack.remove(w)
                    scc.add(w)
                    if w == v:
                        break
                sccs.append(scc)

        for v in vertices:
            if v not in index:
                strongconnect(v)
        return sccs

    def is_recurrent(self, u: str) -> bool:
        """Check if vertex u is in a nontrivial SCC (|SCC| >= 2).

        Time: O(V + E) via Tarjan
        """
        sccs = self.tarjan_sccs()
        for scc in sccs:
            if u in scc and len(scc) >= 2:
                return True
        return False

    def dir_pressure(self, v: str, r: int) -> int:
        """Compute directed cycle pressure at vertex v with radius r.

        Algorithm:
            1. Compute B = out_ball(v, r)
            2. Find all SCCs in the global graph
            3. Count vertices in B that belong to nontrivial SCCs

        Time: O(r * |B| + V + E)
        Space: O(V)
        """
        ball = self.out_ball(v, r)
        sccs = self.tarjan_sccs()
        recurrent = set()
        for scc in sccs:
            if len(scc) >= 2:
                recurrent |= scc
        return len(ball & recurrent)

    def symmetrize(self) -> Dict[str, Set[str]]:
        """Return the symmetrized adjacency (SimpleGraph style, no self-loops).

        Time: O(V + E)
        """
        sym: Dict[str, Set[str]] = defaultdict(set)
        for u in self.adj:
            for v in self.adj[u]:
                if u != v:
                    sym[u].add(v)
                    sym[v].add(u)
        return dict(sym)

    def undir_ball(self, sym: Dict[str, Set[str]], v: str, r: int) -> Set[str]:
        """Compute the undirected ball in the symmetrized graph.

        Time: O(r * |B|)
        """
        ball = {v}
        for _ in range(r):
            frontier = set()
            for w in ball:
                for u in sym.get(w, set()):
                    frontier.add(u)
            ball = ball | frontier
        return ball

    def undir_pressure(self, v: str, r: int) -> int:
        """Compute undirected pressure on the symmetrization.

        Counts non-isolated vertices in the undirected ball.

        Time: O(r * |B| + V + E)
        """
        sym = self.symmetrize()
        ball = self.undir_ball(sym, v, r)
        return sum(1 for u in ball if len(sym.get(u, set())) > 0)

    def causal_asymmetry(self, v: str, r: int) -> int:
        """Compute causal asymmetry = undirPressure - dirPressure.

        This measures how much false cyclicity symmetrization introduces.

        Time: O(r * |B| + V + E)
        """
        return self.undir_pressure(v, r) - self.dir_pressure(v, r)

    def scc_profile(self, v: str, r: int) -> List[int]:
        """Compute the local SCC profile: sorted list of nontrivial SCC sizes
        intersected with the out-ball.

        Time: O(r * |B| + V + E)
        """
        ball = self.out_ball(v, r)
        sccs = self.tarjan_sccs()
        sizes = []
        for scc in sccs:
            overlap = scc & ball
            if len(overlap) >= 2:
                sizes.append(len(overlap))
        return sorted(sizes, reverse=True)

    def condensation(self) -> Tuple[List[Set[str]], List[Tuple[int, int]]]:
        """Compute the condensation DAG: SCCs as nodes, with edges between them.

        Returns:
            (sccs, edges) where edges are (i, j) meaning SCC_i → SCC_j.

        Time: O(V + E)
        """
        sccs = self.tarjan_sccs()
        scc_id: Dict[str, int] = {}
        for i, scc in enumerate(sccs):
            for v in scc:
                scc_id[v] = i

        edges: Set[Tuple[int, int]] = set()
        for u in self.adj:
            for v in self.adj[u]:
                i, j = scc_id.get(u, -1), scc_id.get(v, -1)
                if i != j and i >= 0 and j >= 0:
                    edges.add((i, j))

        return sccs, list(edges)


def compute_all_pressures(G: DirectedGraph, max_radius: int = 3) -> Dict:
    """Compute pressure profiles for all vertices.

    Returns a dict mapping vertex → {radius → (dirP, undirP, CA)}.
    """
    result = {}
    for v in sorted(G.vertices):
        result[v] = {}
        for r in range(max_radius + 1):
            dp = G.dir_pressure(v, r)
            up = G.undir_pressure(v, r)
            ca = up - dp
            result[v][r] = (dp, up, ca)
    return result


# ============================================================
# Example usage
# ============================================================

if __name__ == '__main__':
    print("Directed Cycle Pressure — Algorithm Demonstration")
    print("=" * 55)

    # Oriented diamond
    diamond = DirectedGraph([('s', 'a'), ('s', 'b'), ('a', 't'), ('b', 't')])
    print("\nOriented Diamond:")
    print(f"  SCCs: {[sorted(s) for s in diamond.tarjan_sccs()]}")
    print(f"  Condensation: {diamond.condensation()}")
    profiles = compute_all_pressures(diamond)
    for v, data in profiles.items():
        print(f"  {v}: {data}")

    # Feedback cycle
    feedback = DirectedGraph([('a', 'b'), ('b', 'c'), ('c', 'a'), ('d', 'a')])
    print("\nFeedback Graph (a→b→c→a, d→a):")
    print(f"  SCCs: {[sorted(s) for s in feedback.tarjan_sccs()]}")
    profiles = compute_all_pressures(feedback)
    for v, data in profiles.items():
        print(f"  {v}: {data}")

    print("\nSCC Profiles:")
    for v in sorted(feedback.vertices):
        for r in range(4):
            prof = feedback.scc_profile(v, r)
            if prof:
                print(f"  {v}, r={r}: {prof}")
