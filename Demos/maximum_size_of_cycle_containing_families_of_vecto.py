"""Numerical demonstrations for cycle-containing families of vectors.

This self-contained script illustrates the mathematics of the accompanying
paper "Cycle-Containing Families of Vectors":

  * the bipartite *pair graph* G(u, v) of two vectors over an alphabet [b];
  * the *cycle-containing* (goodness) relation: G(u, v) is not a forest;
  * the *girth threshold*: a good pair forces length k >= 4;
  * the binary *shattering* (qualitative independence) reformulation;
  * the explicit cyclic triple {0011, 0101, 0110} at k = 4;
  * the computed binary maxima M_2(k) = 1, 1, 3, 4, 10, 15 for k = 2..7.

All functions are inlined; only the Python standard library is used.
"""

from __future__ import annotations

from itertools import product
from typing import Dict, List, Sequence, Set, Tuple

# A vector is a tuple of symbols in {0, ..., b-1}.
Vector = Tuple[int, ...]
# An edge of the pair graph: (("L", s), ("R", t)) with s, t in [b].
Vertex = Tuple[str, int]
Edge = Tuple[Vertex, Vertex]


# ---------------------------------------------------------------------------
# Pair graph and the cycle-containing (goodness) relation
# ---------------------------------------------------------------------------
def pair_graph_edges(u: Vector, v: Vector) -> Set[Edge]:
    """Return the distinct edges of the bipartite pair graph G(u, v).

    Each coordinate i contributes the edge L_{u_i} -- R_{v_i}.  As a simple
    graph, repeated coordinates collapse to a single edge.
    """
    if len(u) != len(v):
        raise ValueError("vectors must have equal length")
    edges: Set[Edge] = set()
    for ui, vi in zip(u, v):
        edges.add((("L", ui), ("R", vi)))
    return edges


def graph_has_cycle(edges: Set[Edge]) -> bool:
    """Decide whether an undirected graph (given by its edge set) has a cycle.

    Uses a union-find forest test: a graph is acyclic iff scanning its edges
    never connects two already-connected endpoints.  Runs in near-linear time.
    """
    parent: Dict[Vertex, Vertex] = {}

    def find(x: Vertex) -> Vertex:
        parent.setdefault(x, x)
        root = x
        while parent[root] != root:
            root = parent[root]
        # Path compression.
        while parent[x] != root:
            parent[x], x = root, parent[x]
        return root

    for a, b in edges:
        ra, rb = find(a), find(b)
        if ra == rb:
            return True  # edge closes a cycle
        parent[ra] = rb
    return False


def contains_cycle(u: Vector, v: Vector) -> bool:
    """The goodness relation: G(u, v) contains a cycle (is not a forest)."""
    return graph_has_cycle(pair_graph_edges(u, v))


# ---------------------------------------------------------------------------
# Binary shattering (qualitative independence)
# ---------------------------------------------------------------------------
def shatter(u: Vector, v: Vector) -> bool:
    """Binary shattering: all four patterns (s, t) in {0,1}^2 occur."""
    seen: Set[Tuple[int, int]] = set(zip(u, v))
    return all((s, t) in seen for s in (0, 1) for t in (0, 1))


# ---------------------------------------------------------------------------
# Cyclic families and the extremal function M_b(k)
# ---------------------------------------------------------------------------
def is_cyclic_family(family: Sequence[Vector]) -> bool:
    """A family is cyclic iff every distinct pair is cycle-containing."""
    fam = list(family)
    for i in range(len(fam)):
        for j in range(i + 1, len(fam)):
            if not contains_cycle(fam[i], fam[j]):
                return False
    return True


def max_cyclic_family(b: int, k: int) -> Tuple[int, List[Vector]]:
    """Compute M_b(k) and a witnessing maximum cyclic family.

    Builds the *goodness graph* on all b^k vectors (edges = good pairs) and
    finds a maximum clique by branch-and-bound.  Exponential in general, but
    fine for the small (b, k) reported in the paper.
    """
    vectors: List[Vector] = list(product(range(b), repeat=k))
    n = len(vectors)
    # Adjacency as bitmasks over vector indices.
    adj: List[int] = [0] * n
    for i in range(n):
        for j in range(i + 1, n):
            if contains_cycle(vectors[i], vectors[j]):
                adj[i] |= 1 << j
                adj[j] |= 1 << i

    best: List[int] = []

    def expand(clique: List[int], candidates: int) -> None:
        nonlocal best
        if candidates == 0:
            if len(clique) > len(best):
                best = clique[:]
            return
        # Simple bound: prune if no improvement is possible.
        if len(clique) + bin(candidates).count("1") <= len(best):
            return
        rem = candidates
        while rem:
            low = rem & (-rem)
            v = low.bit_length() - 1
            rem ^= low
            candidates ^= low
            expand(clique + [v], candidates & adj[v])

    full = (1 << n) - 1
    expand([], full)
    return len(best), [vectors[i] for i in best]


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------
def demo_girth_threshold() -> None:
    """No good pair can exist for k <= 3; the first appears at k = 4."""
    print("=" * 64)
    print("Girth threshold: cycle-containing pairs require length k >= 4")
    print("=" * 64)
    for k in range(1, 5):
        found = any(
            contains_cycle(u, v)
            for u in product(range(2), repeat=k)
            for v in product(range(2), repeat=k)
            if u != v
        )
        print(f"  k = {k}: a good binary pair exists? {found}")
    print()


def demo_shattering_equiv() -> None:
    """For b = 2, goodness coincides with shattering on all length-4 pairs."""
    print("=" * 64)
    print("Binary equivalence: contains_cycle == shatter (length 4)")
    print("=" * 64)
    agree = all(
        contains_cycle(u, v) == shatter(u, v)
        for u in product(range(2), repeat=4)
        for v in product(range(2), repeat=4)
        if u != v
    )
    print(f"  contains_cycle and shatter agree on every distinct pair? {agree}")
    print()


def demo_triple() -> None:
    """The explicit cyclic triple {0011, 0101, 0110} at k = 4."""
    print("=" * 64)
    print("Extremal triple at k = 4: {0011, 0101, 0110}")
    print("=" * 64)
    w1: Vector = (0, 0, 1, 1)
    w2: Vector = (0, 1, 0, 1)
    w3: Vector = (0, 1, 1, 0)
    fam = [w1, w2, w3]
    for a in range(3):
        for c in range(a + 1, 3):
            print(
                f"  pair ({''.join(map(str, fam[a]))}, "
                f"{''.join(map(str, fam[c]))}): "
                f"shatter={shatter(fam[a], fam[c])}, "
                f"contains_cycle={contains_cycle(fam[a], fam[c])}"
            )
    print(f"  is_cyclic_family({{w1,w2,w3}}) = {is_cyclic_family(fam)}")
    print()


def demo_sequence() -> None:
    """Recompute the binary maxima M_2(k) for k = 2..7."""
    print("=" * 64)
    print("Computed binary maxima M_2(k)")
    print("=" * 64)
    expected = {2: 1, 3: 1, 4: 3, 5: 4, 6: 10, 7: 15}
    for k in range(2, 8):
        size, witness = max_cyclic_family(2, k)
        flag = "OK" if size == expected[k] else "MISMATCH"
        print(f"  M_2({k}) = {size}   (expected {expected[k]}: {flag})")
        if k <= 4:
            shown = ", ".join("".join(map(str, w)) for w in witness)
            print(f"        witness: {{{shown}}}")
    print()


def main() -> None:
    demo_girth_threshold()
    demo_shattering_equiv()
    demo_triple()
    demo_sequence()


if __name__ == "__main__":
    main()
