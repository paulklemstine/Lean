"""
Tangled Hierarchies: Order, Grading, and the Ultimate Tangle
============================================================

Self-contained numerical demonstrations of the paper's results.

A relation r on a finite carrier is represented as a set of ordered pairs
(directed edges). We demonstrate:

  1. Tangle detection (two-cycles) and self-loops.
  2. Well-founded / strict orders (like (N, <)) carry no tangle.
  3. Grading forbids tangles; a tangle has no grading (consistency dichotomy).
  4. Adjacency (symmetric neighbour reference) is tangled though the order is not.
  5. The Russell diagonal witness: no decoding of a finite universe onto its
     power set can be surjective (the ultimate tangle is inconsistent).

Run:  python demo.py
"""

from __future__ import annotations

from itertools import product
from typing import Callable, FrozenSet, Iterable, Optional, Set, Tuple

Relation = Set[Tuple[int, int]]


# ---------------------------------------------------------------------------
# Part 1 -- Tangles and cycles
# ---------------------------------------------------------------------------

def is_tangled(edges: Relation) -> Optional[Tuple[int, int]]:
    """Return a witnessing two-cycle (x, y) with x != y-order irrelevant,
    i.e. (x, y) and (y, x) both present, or None if the relation is untangled.
    Also detects self-loops (x, x)."""
    for (x, y) in edges:
        if (y, x) in edges:
            return (x, y)
    return None


def has_self_loop(edges: Relation) -> Optional[int]:
    """Return an x with (x, x) in the relation, else None."""
    for (x, y) in edges:
        if x == y:
            return x
    return None


def is_asymmetric(edges: Relation) -> bool:
    """True iff no edge has a reverse (the strict-order character)."""
    return all((y, x) not in edges for (x, y) in edges if x != y) and \
        has_self_loop(edges) is None


# ---------------------------------------------------------------------------
# Part 2 & 3 -- Gradings and the consistency dichotomy
# ---------------------------------------------------------------------------

def find_grading(vertices: Iterable[int], edges: Relation) -> Optional[dict]:
    """Attempt to build a grading rank: V -> N with rank(a) < rank(b) for every
    edge (a, b). Returns the rank dict if the graph is acyclic (Kahn's
    topological sort), else None (a cycle -- a genuine tangle at some length --
    is present)."""
    verts = list(vertices)
    indeg = {v: 0 for v in verts}
    succ: dict = {v: [] for v in verts}
    for (a, b) in edges:
        succ[a].append(b)
        indeg[b] += 1
    queue = [v for v in verts if indeg[v] == 0]
    rank: dict = {}
    level = 0
    processed = 0
    while queue:
        nxt = []
        for v in queue:
            rank[v] = level
            processed += 1
            for w in succ[v]:
                indeg[w] -= 1
                if indeg[w] == 0:
                    nxt.append(w)
        queue = nxt
        level += 1
    if processed != len(verts):
        return None  # cycle detected: no grading exists
    return rank


def grading_is_valid(rank: dict, edges: Relation) -> bool:
    """Verify rank(a) < rank(b) for every edge."""
    return all(rank[a] < rank[b] for (a, b) in edges)


# ---------------------------------------------------------------------------
# Part 4 -- Adjacency (polymorphic reference)
# ---------------------------------------------------------------------------

def refers_adjacent_edges(n_levels: int) -> Relation:
    """Symmetric adjacency on levels 0..n_levels-1: m = n+1 or n = m+1."""
    edges: Relation = set()
    for n in range(n_levels):
        for m in range(n_levels):
            if m == n + 1 or n == m + 1:
                edges.add((n, m))
    return edges


# ---------------------------------------------------------------------------
# Part 5 -- The Russell diagonal witness (ultimate tangle)
# ---------------------------------------------------------------------------

def russell_diagonal(
    universe: Iterable[int],
    decode: Callable[[int], FrozenSet[int]],
) -> FrozenSet[int]:
    """Given decode: U -> P(U), build the diagonal set
    R = { x in U : x not in decode(x) }, which is provably NOT decode(c) for
    any c, witnessing that no decoding is surjective."""
    return frozenset(x for x in universe if x not in decode(x))


def decode_is_surjective(
    universe: Iterable[int],
    decode: Callable[[int], FrozenSet[int]],
) -> bool:
    """Brute-force check whether decode hits every subset of the (small) universe."""
    U = list(universe)
    image = {decode(c) for c in U}
    # enumerate all subsets
    for bits in product([False, True], repeat=len(U)):
        subset = frozenset(u for u, b in zip(U, bits) if b)
        if subset not in image:
            return False
    return True


# ---------------------------------------------------------------------------
# Driver
# ---------------------------------------------------------------------------

def main() -> None:
    line = "=" * 68

    print(line)
    print("1. Tangles, self-loops, asymmetry")
    print(line)
    ladder = {(i, j) for i in range(5) for j in range(5) if i < j}  # (N,<) up to 5
    print("Strict order < on {0..4}: tangled? ", is_tangled(ladder),
          "| asymmetric?", is_asymmetric(ladder))
    two_cycle = {(0, 1), (1, 0)}
    print("Two-cycle {0<->1}:          tangled? ", is_tangled(two_cycle),
          "| asymmetric?", is_asymmetric(two_cycle))
    self_loop = {(3, 3)}
    print("Self-loop {3->3}:           tangled? ", is_tangled(self_loop),
          "| self-loop at", has_self_loop(self_loop))

    print()
    print(line)
    print("2 & 3. Grading and the consistency dichotomy")
    print(line)
    V = list(range(5))
    g = find_grading(V, ladder)
    print("Grading of (N,<) ladder:", g, "-> valid?", grading_is_valid(g, ladder))
    g2 = find_grading([0, 1], two_cycle)
    print("Grading of two-cycle:   ", g2, "(None => tangle admits NO grading)")

    print()
    print(line)
    print("4. Adjacency is tangled though the level order is not")
    print(line)
    adj = refers_adjacent_edges(6)
    print("Adjacency on levels 0..5: tangled witness =", is_tangled(adj))
    print("Adjacency grading:", find_grading(list(range(6)), adj),
          "(None => symmetric reference graph is ungradable)")

    print()
    print(line)
    print("5. The Russell diagonal witness -- no reflective universe")
    print(line)
    universe = [0, 1, 2]

    # A concrete (arbitrary) attempted decoding U -> P(U):
    table = {
        0: frozenset({0, 1}),
        1: frozenset({2}),
        2: frozenset({0, 1, 2}),
    }
    decode = lambda c: table[c]
    R = russell_diagonal(universe, decode)
    print("Universe:", universe)
    print("decode:  ", {c: set(table[c]) for c in universe})
    print("Russell diagonal R = { x : x not in decode(x) } =", set(R))
    named = [c for c in universe if decode(c) == R]
    print("Codes naming R:", named, "(empty => R is unnamed, decode not onto)")
    print("Is decode surjective onto P(U)?", decode_is_surjective(universe, decode))

    # Try EVERY possible decoding of a 2-element universe; none is surjective.
    print()
    print("Exhaustive check: no decoding of a 2-element universe is surjective")
    U2 = [0, 1]
    subsets = [frozenset(s) for r in range(3)
               for s in __import__("itertools").combinations(U2, r)]
    found_surjective = False
    for f0 in subsets:
        for f1 in subsets:
            d = {0: f0, 1: f1}
            if decode_is_surjective(U2, lambda c: d[c]):
                found_surjective = True
    print("Any surjective decoding found?", found_surjective,
          "(False => the ultimate tangle is impossible)")


if __name__ == "__main__":
    main()
