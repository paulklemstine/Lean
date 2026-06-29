#!/usr/bin/env python3
"""
Tropical Curry–Howard: Algorithms

Implements the core algorithms from the research paper:
1. Cost evaluation (O(n) time)
2. Canonical normalization (O(n) time)
3. Step-by-step reduction with termination tracking
4. Polynomial interpretation for termination bound
5. Graph-to-tropical-proof encoding
6. Shortest-path via tropical normalization
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Optional, List, Tuple, Dict, Set
import heapq


# ═══════════════════════════════════════════════════════════════════════
# Core Data Structures
# ═══════════════════════════════════════════════════════════════════════

@dataclass(frozen=True)
class TropProof:
    """Base class for tropical proof terms."""
    pass

@dataclass(frozen=True)
class Atom(TropProof):
    n: int
    def __repr__(self): return f"atom({self.n})"

@dataclass(frozen=True)
class Cut(TropProof):
    left: TropProof
    right: TropProof
    def __repr__(self): return f"cut({self.left}, {self.right})"

@dataclass(frozen=True)
class TMin(TropProof):
    left: TropProof
    right: TropProof
    def __repr__(self): return f"tmin({self.left}, {self.right})"

@dataclass(frozen=True)
class TPlus(TropProof):
    left: TropProof
    right: TropProof
    def __repr__(self): return f"tplus({self.left}, {self.right})"


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 1: Cost Evaluation
# Time: O(|p|), Space: O(depth(p))
# ═══════════════════════════════════════════════════════════════════════

def cost(p: TropProof) -> int:
    """
    Evaluate the tropical cost of a proof term.

    Semantics (min-plus semiring):
        cost(atom(n))    = n
        cost(cut(p, q))  = cost(p) + cost(q)
        cost(tmin(p, q)) = min(cost(p), cost(q))
        cost(tplus(p, q))= cost(p) + cost(q)

    Time complexity: O(|p|) where |p| = number of nodes
    Space complexity: O(depth(p)) for recursion stack

    >>> cost(Atom(5))
    5
    >>> cost(Cut(Atom(3), Atom(4)))
    7
    >>> cost(TMin(Atom(2), Atom(7)))
    2
    """
    if isinstance(p, Atom): return p.n
    if isinstance(p, Cut): return cost(p.left) + cost(p.right)
    if isinstance(p, TMin): return min(cost(p.left), cost(p.right))
    if isinstance(p, TPlus): return cost(p.left) + cost(p.right)
    raise TypeError(f"Unknown term type: {type(p)}")


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 2: Canonical Normalization
# Time: O(|p|), Space: O(depth(p))
# ═══════════════════════════════════════════════════════════════════════

def normalize(p: TropProof) -> Atom:
    """
    Canonical normalizer: evaluates cost and wraps as atom.

    Correctness guarantees (all formally proved):
        1. p →* normalize(p)         [reachability]
        2. Normal(normalize(p))      [is a normal form]
        3. cost(normalize(p)) = cost(p)  [cost preservation]
        4. Unique normal form        [canonicality]

    Time complexity: O(|p|)
    Space complexity: O(depth(p))

    >>> normalize(Cut(TMin(Atom(1), Atom(5)), Atom(3)))
    atom(4)
    """
    return Atom(cost(p))


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 3: Polynomial Interpretation (Termination Measure)
# ═══════════════════════════════════════════════════════════════════════

def interp(p: TropProof) -> int:
    """
    Polynomial interpretation for proving termination.

    Maps:
        atom(_)    → 2
        cut(p, q)  → interp(p) × interp(q)
        tmin(p, q) → interp(p) + interp(q) + 1
        tplus(p, q)→ interp(p) × interp(q)

    Invariant: interp(p) ≥ 2 for all p.
    Key property: If p → q, then interp(q) < interp(p).

    >>> interp(Atom(42))
    2
    >>> interp(Cut(Atom(1), Atom(2)))
    4
    """
    if isinstance(p, Atom): return 2
    if isinstance(p, Cut): return interp(p.left) * interp(p.right)
    if isinstance(p, TMin): return interp(p.left) + interp(p.right) + 1
    if isinstance(p, TPlus): return interp(p.left) * interp(p.right)
    raise TypeError(f"Unknown term type: {type(p)}")


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 4: Step-by-Step Reduction
# ═══════════════════════════════════════════════════════════════════════

def try_reduce(p: TropProof) -> Optional[TropProof]:
    """
    Try to apply one reduction step. Returns None if p is normal.

    Reduction rules (in priority order):
        1. Distributive: cut/tplus distribute over tmin
        2. Idempotent: tmin(p, p) → p
        3. Computation: binary ops on atoms evaluate
        4. Congruence: reduce inside subterms

    Returns:
        The reduced term, or None if already in normal form.
    """
    # Distributive rules
    if isinstance(p, Cut) and isinstance(p.left, TMin):
        return TMin(Cut(p.left.left, p.right), Cut(p.left.right, p.right))
    if isinstance(p, Cut) and isinstance(p.right, TMin):
        return TMin(Cut(p.left, p.right.left), Cut(p.left, p.right.right))
    if isinstance(p, TPlus) and isinstance(p.left, TMin):
        return TMin(TPlus(p.left.left, p.right), TPlus(p.left.right, p.right))
    if isinstance(p, TPlus) and isinstance(p.right, TMin):
        return TMin(TPlus(p.left, p.right.left), TPlus(p.left, p.right.right))

    # Idempotent collapse
    if isinstance(p, TMin) and p.left == p.right:
        return p.left

    # Computation rules
    if isinstance(p, Cut) and isinstance(p.left, Atom) and isinstance(p.right, Atom):
        return Atom(p.left.n + p.right.n)
    if isinstance(p, TPlus) and isinstance(p.left, Atom) and isinstance(p.right, Atom):
        return Atom(p.left.n + p.right.n)
    if isinstance(p, TMin) and isinstance(p.left, Atom) and isinstance(p.right, Atom):
        return Atom(min(p.left.n, p.right.n))

    # Congruence: try subterms
    if isinstance(p, (Cut, TMin, TPlus)):
        r = try_reduce(p.left)
        if r is not None:
            return type(p)(r, p.right)
        r = try_reduce(p.right)
        if r is not None:
            return type(p)(p.left, r)

    return None


def reduce_fully(p: TropProof) -> Tuple[Atom, List[TropProof]]:
    """
    Reduce a term to normal form, recording the full trace.

    Returns:
        (normal_form, trace) where trace[0] = p and trace[-1] = normal_form.

    Guaranteed to terminate by strong normalization.
    Guaranteed to produce atom(cost(p)) by confluence.

    >>> nf, trace = reduce_fully(Cut(TMin(Atom(1), Atom(3)), Atom(2)))
    >>> nf
    atom(3)
    >>> len(trace) >= 2
    True
    """
    trace = [p]
    while True:
        q = try_reduce(p)
        if q is None:
            assert isinstance(p, Atom), f"Normal form should be atom, got {p}"
            return p, trace
        p = q
        trace.append(p)


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 5: Graph → Tropical Proof Encoding
# ═══════════════════════════════════════════════════════════════════════

def encode_graph_paths(
    adj: Dict[str, List[Tuple[str, int]]],
    source: str,
    target: str,
    max_depth: int = 20
) -> Optional[TropProof]:
    """
    Encode all source-to-target paths in a weighted graph as a tropical proof term.

    Args:
        adj: Adjacency list {node: [(neighbor, weight), ...]}
        source: Start node
        target: End node
        max_depth: Maximum path length to prevent infinite loops in cyclic graphs

    Returns:
        A TropProof term where:
        - Each path is a chain of Cut(Atom(w1), Cut(Atom(w2), ...))
        - Multiple paths are combined with TMin
        - normalize(result) = atom(shortest_path_cost)

    >>> adj = {'A': [('B', 2), ('C', 4)], 'B': [('C', 1)], 'C': []}
    >>> term = encode_graph_paths(adj, 'A', 'C')
    >>> cost(term)
    3
    """
    def find_all_paths(current: str, visited: Set[str], depth: int) -> Optional[TropProof]:
        if current == target:
            return Atom(0)  # Zero cost to reach target from target
        if depth <= 0 or current in visited:
            return None

        visited_new = visited | {current}
        paths: List[TropProof] = []

        for neighbor, weight in adj.get(current, []):
            sub = find_all_paths(neighbor, visited_new, depth - 1)
            if sub is not None:
                paths.append(Cut(Atom(weight), sub))

        if not paths:
            return None
        result = paths[0]
        for p in paths[1:]:
            result = TMin(result, p)
        return result

    return find_all_paths(source, set(), max_depth)


def shortest_path_dijkstra(
    adj: Dict[str, List[Tuple[str, int]]],
    source: str,
    target: str
) -> Optional[int]:
    """
    Classical Dijkstra's shortest path for comparison.

    >>> adj = {'A': [('B', 2), ('C', 4)], 'B': [('C', 1)], 'C': []}
    >>> shortest_path_dijkstra(adj, 'A', 'C')
    3
    """
    dist: Dict[str, int] = {source: 0}
    pq = [(0, source)]
    while pq:
        d, u = heapq.heappop(pq)
        if u == target:
            return d
        if d > dist.get(u, float('inf')):
            continue
        for v, w in adj.get(u, []):
            nd = d + w
            if nd < dist.get(v, float('inf')):
                dist[v] = nd
                heapq.heappush(pq, (nd, v))
    return None


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 6: Term Statistics
# ═══════════════════════════════════════════════════════════════════════

def term_size(p: TropProof) -> int:
    """Count total nodes in the term tree."""
    if isinstance(p, Atom): return 1
    if isinstance(p, (Cut, TMin, TPlus)):
        return 1 + term_size(p.left) + term_size(p.right)
    return 0

def term_depth(p: TropProof) -> int:
    """Maximum nesting depth."""
    if isinstance(p, Atom): return 0
    if isinstance(p, (Cut, TMin, TPlus)):
        return 1 + max(term_depth(p.left), term_depth(p.right))
    return 0

def min_depth(p: TropProof) -> int:
    """Count maximum nesting of TMin nodes."""
    if isinstance(p, Atom): return 0
    if isinstance(p, TMin):
        return 1 + max(min_depth(p.left), min_depth(p.right))
    if isinstance(p, (Cut, TPlus)):
        return max(min_depth(p.left), min_depth(p.right))
    return 0


# ═══════════════════════════════════════════════════════════════════════
# Example Usage
# ═══════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("=== Algorithm Demonstrations ===\n")

    # Example 1: Basic normalization
    term = Cut(TMin(Atom(1), Atom(5)), TMin(Atom(2), Atom(3)))
    nf, trace = reduce_fully(term)
    print(f"Term: {term}")
    print(f"Normal form: {nf}")
    print(f"Reduction steps: {len(trace) - 1}")
    print(f"Interp decrease: {interp(trace[0])} → {interp(trace[-1])}")
    print()

    # Example 2: Shortest path
    graph = {
        'S': [('A', 1), ('B', 4)],
        'A': [('B', 2), ('T', 6)],
        'B': [('T', 3)],
        'T': []
    }
    print(f"Graph: S→A(1), S→B(4), A→B(2), A→T(6), B→T(3)")
    term = encode_graph_paths(graph, 'S', 'T')
    if term:
        print(f"Tropical encoding: {term}")
        nf = normalize(term)
        dij = shortest_path_dijkstra(graph, 'S', 'T')
        print(f"Tropical normalization: {nf} (cost = {cost(nf)})")
        print(f"Dijkstra result: {dij}")
        print(f"Match: {'✓' if cost(nf) == dij else '✗'}")
    print()

    # Example 3: Term statistics
    big_term = Cut(
        TMin(Cut(Atom(1), Atom(2)), TPlus(Atom(3), Atom(1))),
        TMin(Atom(5), Cut(Atom(2), Atom(1)))
    )
    print(f"Term: {big_term}")
    print(f"  Size: {term_size(big_term)}")
    print(f"  Depth: {term_depth(big_term)}")
    print(f"  Min-depth: {min_depth(big_term)}")
    print(f"  Cost: {cost(big_term)}")
    print(f"  Interp: {interp(big_term)}")
    nf, trace = reduce_fully(big_term)
    print(f"  Reduction steps to normal form: {len(trace) - 1}")
    print(f"  Normal form: {nf}")
