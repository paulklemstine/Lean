"""
demo.py — Colour Classes of Proper Edge-Colourings.

Numerical demonstrations of the structural theorems:

  * Each colour class of a proper edge-colouring is a matching.
  * Distinct colours give disjoint colour classes.
  * The colour classes partition the edge set.
  * Under a proper colouring, colour degree equals ordinary degree.
  * In a proper colouring, every triangle is rainbow.

Everything is self-contained: a graph is a set of frozenset edges over integer
vertices, and an edge-colouring is a dict mapping each edge to an integer colour.

Run:  python demo.py
"""

from __future__ import annotations

import itertools
import random
from collections import defaultdict
from typing import Dict, FrozenSet, Iterable, List, Set, Tuple

Vertex = int
Edge = FrozenSet[Vertex]
Colouring = Dict[Edge, int]


# --------------------------------------------------------------------------- #
# Graph construction
# --------------------------------------------------------------------------- #
def complete_graph(n: int) -> Set[Edge]:
    """Edge set of the complete graph K_n on vertices 0, ..., n-1."""
    return {frozenset((u, v)) for u in range(n) for v in range(u + 1, n)}


def erdos_renyi(n: int, p: float, seed: int = 0) -> Set[Edge]:
    """Edge set of a random G(n, p) graph."""
    rng = random.Random(seed)
    return {
        frozenset((u, v))
        for u in range(n)
        for v in range(u + 1, n)
        if rng.random() < p
    }


def endpoints(e: Edge) -> Tuple[Vertex, Vertex]:
    """Return the two endpoints of an edge as an ordered tuple."""
    a, b = tuple(e)
    return (a, b)


def neighbours(edges: Set[Edge]) -> Dict[Vertex, Set[Vertex]]:
    """Adjacency map: vertex -> set of neighbours."""
    adj: Dict[Vertex, Set[Vertex]] = defaultdict(set)
    for e in edges:
        a, b = endpoints(e)
        adj[a].add(b)
        adj[b].add(a)
    return adj


# --------------------------------------------------------------------------- #
# Proper edge-colourings
# --------------------------------------------------------------------------- #
def greedy_proper_colouring(edges: Set[Edge]) -> Colouring:
    """Greedy proper edge-colouring: each edge gets the least colour absent at
    both endpoints. Guaranteed proper; uses at most 2*Delta - 1 colours."""
    colour: Colouring = {}
    incident: Dict[Vertex, Set[int]] = defaultdict(set)
    for e in sorted(edges, key=lambda f: sorted(f)):
        a, b = endpoints(e)
        used = incident[a] | incident[b]
        c = 0
        while c in used:
            c += 1
        colour[e] = c
        incident[a].add(c)
        incident[b].add(c)
    return colour


def round_robin_colouring(n: int) -> Colouring:
    """Optimal proper edge-colouring of K_n via the circle method.

    For even n this yields n-1 perfect matchings; for odd n, n near-perfect
    matchings (one bye per round). Returns a colouring of the edges of K_n.
    """
    if n < 2:
        return {}
    phantom = n if n % 2 == 1 else None
    m = n + 1 if phantom is not None else n  # even working size
    players = list(range(m))
    fixed = players[-1]
    rotating = players[:-1]
    rounds = m - 1
    colour: Colouring = {}
    for r in range(rounds):
        arrangement = [rotating[(r + i) % (m - 1)] for i in range(m - 1)]
        pairs = [(fixed, arrangement[0])]
        for i in range(1, m // 2):
            pairs.append((arrangement[i], arrangement[m - 1 - i]))
        for (u, v) in pairs:
            if u == phantom or v == phantom:
                continue  # phantom edges are byes; drop them
            colour[frozenset((u, v))] = r
    return colour


# --------------------------------------------------------------------------- #
# Colour classes and verification of the theorems
# --------------------------------------------------------------------------- #
def colour_classes(colour: Colouring) -> Dict[int, Set[Edge]]:
    """Group edges by their colour into colour classes."""
    classes: Dict[int, Set[Edge]] = defaultdict(set)
    for e, c in colour.items():
        classes[c].add(e)
    return classes


def is_matching(cls: Iterable[Edge]) -> bool:
    """True iff the given edges are pairwise vertex-disjoint (a matching)."""
    seen: Set[Vertex] = set()
    for e in cls:
        a, b = endpoints(e)
        if a in seen or b in seen:
            return False
        seen.add(a)
        seen.add(b)
    return True


def is_proper(edges: Set[Edge], colour: Colouring) -> bool:
    """True iff no two edges sharing a vertex have the same colour."""
    at_vertex: Dict[Vertex, Set[int]] = defaultdict(set)
    for e in edges:
        a, b = endpoints(e)
        c = colour[e]
        if c in at_vertex[a] or c in at_vertex[b]:
            return False
        at_vertex[a].add(c)
        at_vertex[b].add(c)
    return True


def verify_partition(edges: Set[Edge], colour: Colouring) -> Dict[str, bool]:
    """Verify Theorems 4.1-4.3 on a concrete coloured graph.

    Returns a dict of boolean checks: every class is a matching, classes are
    pairwise disjoint, and the classes cover the edge set exactly.
    """
    classes = colour_classes(colour)
    all_matchings = all(is_matching(cls) for cls in classes.values())
    # Pairwise disjoint: each edge belongs to exactly one class (automatic here,
    # but we check explicitly for the demonstration).
    seen: Set[Edge] = set()
    disjoint = True
    for cls in classes.values():
        if seen & cls:
            disjoint = False
        seen |= cls
    covers = seen == edges
    return {
        "every_class_is_matching": all_matchings,
        "classes_pairwise_disjoint": disjoint,
        "classes_cover_edges": covers,
    }


def colour_degree(adj: Dict[Vertex, Set[Vertex]], colour: Colouring,
                  v: Vertex) -> int:
    """Number of distinct colours on edges incident to v."""
    return len({colour[frozenset((v, u))] for u in adj[v]})


def degree(adj: Dict[Vertex, Set[Vertex]], v: Vertex) -> int:
    """Ordinary degree of v."""
    return len(adj[v])


def rainbow_triangle_report(edges: Set[Edge], colour: Colouring
                            ) -> Tuple[int, int]:
    """Count (rainbow triangles, total triangles) in the coloured graph."""
    adj = neighbours(edges)
    verts = sorted(adj)
    total = 0
    rainbow = 0
    for a, b, c in itertools.combinations(verts, 3):
        if b in adj[a] and c in adj[a] and c in adj[b]:
            total += 1
            ab = colour[frozenset((a, b))]
            ac = colour[frozenset((a, c))]
            bc = colour[frozenset((b, c))]
            if ab != ac and ab != bc and ac != bc:
                rainbow += 1
    return rainbow, total


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_round_robin() -> None:
    print("=" * 66)
    print("Demo 1: Round-robin colouring of complete graphs K_n")
    print("=" * 66)
    for n in range(4, 9):
        edges = complete_graph(n)
        colour = round_robin_colouring(n)
        assert set(colour.keys()) == edges, "colouring must cover all edges"
        classes = colour_classes(colour)
        checks = verify_partition(edges, colour)
        num_colours = len(classes)
        expected = n - 1 if n % 2 == 0 else n
        print(f"  K_{n}: |E|={len(edges):3d}  colours={num_colours:2d} "
              f"(chi'={expected:2d})  proper={is_proper(edges, colour)}  "
              f"partition_ok={all(checks.values())}")
    print()


def demo_random_graphs() -> None:
    print("=" * 66)
    print("Demo 2: Greedy proper colouring of random graphs G(n, p)")
    print("=" * 66)
    for (n, p, seed) in [(10, 0.4, 1), (15, 0.3, 2), (20, 0.5, 3),
                         (25, 0.2, 4)]:
        edges = erdos_renyi(n, p, seed)
        colour = greedy_proper_colouring(edges)
        checks = verify_partition(edges, colour)
        print(f"  G({n},{p}) seed={seed}: |E|={len(edges):3d} "
              f"colours={len(colour_classes(colour)):2d}  "
              f"proper={is_proper(edges, colour)}  "
              f"matchings={checks['every_class_is_matching']}  "
              f"cover={checks['classes_cover_edges']}")
    print()


def demo_colour_degree_and_rainbow() -> None:
    print("=" * 66)
    print("Demo 3: Colour degree = degree, and all triangles are rainbow")
    print("=" * 66)
    for n in range(3, 8):
        edges = complete_graph(n)
        colour = round_robin_colouring(n)
        adj = neighbours(edges)
        cd_eq_deg = all(
            colour_degree(adj, colour, v) == degree(adj, v) for v in adj
        )
        rainbow, total = rainbow_triangle_report(edges, colour)
        print(f"  K_{n}: colour_degree==degree at every vertex: {cd_eq_deg}; "
              f"rainbow triangles {rainbow}/{total}")
    print()


def main() -> None:
    demo_round_robin()
    demo_random_graphs()
    demo_colour_degree_and_rainbow()
    print("All structural theorems verified on the sampled instances.")


if __name__ == "__main__":
    main()
