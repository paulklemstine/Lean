"""
Numerical demonstrations for
"Multiplicability of Upho Posets from Vertex-Transitive Graphs".

This script exercises the main structural results numerically:

  * Left-divisibility is a preorder; on a free monoid it is the (finitary,
    antisymmetric) prefix order  -- Lemmas/Theorems 3.2, 4.2, 4.3, 4.4.
  * In a group, left-divisibility collapses: everybody divides everybody,
    and antisymmetry fails unless the group is trivial -- Lemma 3.4, Thm 3.5.
  * Sabidussi's theorem (Thm 5.7): a graph is a Cayley graph iff its
    automorphism group has a regular (sharply transitive) subgroup. We test
    this on the 5-cycle (Cayley), the Petersen graph (non-Cayley) and the
    line graph of the Petersen graph (Cayley), reproducing the dichotomy of
    Conjecture 6.2.

Pure-Python, standard library only.
"""

from __future__ import annotations

from itertools import permutations, product
from typing import Dict, FrozenSet, List, Optional, Sequence, Set, Tuple

# ---------------------------------------------------------------------------
# Order pillar: left-divisibility / prefix order on the free monoid of walks
# ---------------------------------------------------------------------------

Word = Tuple[str, ...]


def left_divides(a: Word, b: Word) -> bool:
    """`a` left-divides `b` in the free monoid: b = a * c for some word c.

    By Lemma 4.2 this is exactly the prefix relation a <+: b.
    """
    return len(a) <= len(b) and b[: len(a)] == a


def left_divisors(b: Word) -> List[Word]:
    """All left-divisors (prefixes) of a word -- its initial segments.

    By Theorem 4.4 this set is finite, of size len(b) + 1 (finitariness).
    """
    return [tuple(b[:k]) for k in range(len(b) + 1)]


def prefix_order_is_partial_order(words: Sequence[Word]) -> Tuple[bool, bool, bool]:
    """Verify reflexivity, transitivity, antisymmetry on a finite sample."""
    refl = all(left_divides(w, w) for w in words)
    trans = all(
        (not (left_divides(a, b) and left_divides(b, c))) or left_divides(a, c)
        for a in words
        for b in words
        for c in words
    )
    antisym = all(
        (not (left_divides(a, b) and left_divides(b, a))) or a == b
        for a in words
        for b in words
    )
    return refl, trans, antisym


# ---------------------------------------------------------------------------
# Group collapse: left-divisibility on Z/n
# ---------------------------------------------------------------------------

def zmod_left_divides(n: int, a: int, b: int) -> bool:
    """In the additive group Z/n, a 'left-divides' b iff exists c, b = a + c.

    Since every c is available, this is ALWAYS true (Lemma 3.4): the order
    collapses to the indiscrete relation.
    """
    return any((a + c) % n == b % n for c in range(n))


def zmod_antisymmetry_holds(n: int) -> bool:
    """Antisymmetry of left-divisibility on Z/n holds iff n == 1 (Thm 3.5)."""
    return all(
        (not (zmod_left_divides(n, a, b) and zmod_left_divides(n, b, a))) or a == b
        for a in range(n)
        for b in range(n)
    )


# ---------------------------------------------------------------------------
# Symmetry pillar: graphs, automorphisms, regular subgroups (Sabidussi)
# ---------------------------------------------------------------------------

Graph = Dict[int, Set[int]]  # adjacency: vertex -> set of neighbors
Perm = Tuple[int, ...]       # perm[i] = image of vertex i


def cycle_graph(n: int) -> Graph:
    return {i: {(i - 1) % n, (i + 1) % n} for i in range(n)}


def pentagonal_prism() -> Graph:
    """Pentagonal prism C5 x K2: a 3-regular vertex-transitive Cayley graph on
    10 vertices (Cayley graph of Z10), the genuine Cayley contrast to Petersen."""
    g: Graph = {i: set() for i in range(10)}
    def add(u: int, v: int) -> None:
        g[u].add(v)
        g[v].add(u)
    for i in range(5):
        add(i, (i + 1) % 5)            # outer 5-cycle
        add(5 + i, 5 + (i + 1) % 5)    # inner 5-cycle
        add(i, i + 5)                  # rungs
    return g


def petersen_graph() -> Graph:
    """Standard Petersen graph: outer 5-cycle 0..4, inner pentagram 5..9."""
    g: Graph = {i: set() for i in range(10)}
    def add(u: int, v: int) -> None:
        g[u].add(v)
        g[v].add(u)
    for i in range(5):
        add(i, (i + 1) % 5)            # outer cycle
        add(i, i + 5)                  # spokes
        add(5 + i, 5 + (i + 2) % 5)    # inner pentagram
    return g


def line_graph(g: Graph) -> Graph:
    """Line graph: vertices are edges of g, adjacent if they share an endpoint."""
    edges: List[FrozenSet[int]] = sorted(
        {frozenset((u, v)) for u in g for v in g[u]}, key=lambda e: sorted(e)
    )
    idx = {e: i for i, e in enumerate(edges)}
    lg: Graph = {i: set() for i in range(len(edges))}
    for e in edges:
        for f in edges:
            if e != f and (e & f):
                lg[idx[e]].add(idx[f])
    return lg


def automorphisms(g: Graph) -> List[Perm]:
    """All graph automorphisms via adjacency-preserving backtracking search."""
    n = len(g)
    verts = list(range(n))
    deg = {v: len(g[v]) for v in verts}
    result: List[Perm] = []
    image: List[int] = [-1] * n
    used = [False] * n

    def consistent(v: int, w: int) -> bool:
        if deg[v] != deg[w]:
            return False
        for u in range(v):  # already-assigned earlier vertices
            if (u in g[v]) != (image[u] in g[w]):
                return False
        return True

    def backtrack(v: int) -> None:
        if v == n:
            result.append(tuple(image))
            return
        for w in verts:
            if not used[w] and consistent(v, w):
                image[v] = w
                used[w] = True
                backtrack(v + 1)
                used[w] = False
                image[v] = -1

    backtrack(0)
    return result


def compose(p: Perm, q: Perm) -> Perm:
    """(p . q)(x) = p(q(x))."""
    return tuple(p[q[x]] for x in range(len(p)))


def is_fixed_point_free(p: Perm) -> bool:
    return all(p[x] != x for x in range(len(p)))


def closure(gens: Sequence[Perm], n: int, cap: int) -> Optional[Set[Perm]]:
    """Subgroup generated by `gens`; returns None if it exceeds `cap`."""
    identity: Perm = tuple(range(n))
    elems: Set[Perm] = {identity}
    frontier = list(gens)
    elems.update(gens)
    while frontier:
        a = frontier.pop()
        for b in list(elems):
            for c in (compose(a, b), compose(b, a)):
                if c not in elems:
                    if len(elems) >= cap:
                        return None
                    elems.add(c)
                    frontier.append(c)
    return elems


def is_regular_subgroup(elems: Set[Perm], n: int) -> bool:
    """A set of permutations acts regularly iff |elems| == n, it is transitive,
    and every non-identity element is fixed-point-free (semiregular)."""
    if len(elems) != n:
        return False
    identity: Perm = tuple(range(n))
    if any((p != identity) and not is_fixed_point_free(p) for p in elems):
        return False
    # transitivity from vertex 0:
    return {p[0] for p in elems} == set(range(n))


def has_regular_aut_subgroup(g: Graph) -> Optional[Set[Perm]]:
    """Sabidussi test: search Aut(g) for a regular subgroup.

    Returns the subgroup (as a set of permutations) if found, else None.
    """
    n = len(g)
    auts = automorphisms(g)
    fpf = [p for p in auts if is_fixed_point_free(p)]
    # try single generators (cyclic regular subgroups)...
    for a in fpf:
        sub = closure([a], n, cap=n + 1)
        if sub is not None and is_regular_subgroup(sub, n):
            return sub
    # ...then pairs (e.g. dihedral regular subgroups).
    for a, b in product(fpf, repeat=2):
        sub = closure([a, b], n, cap=n + 1)
        if sub is not None and is_regular_subgroup(sub, n):
            return sub
    return None


def is_vertex_transitive(g: Graph) -> bool:
    auts = automorphisms(g)
    return {p[0] for p in auts} == set(range(len(g)))


# ---------------------------------------------------------------------------
# Driver
# ---------------------------------------------------------------------------

def main() -> None:
    print("=" * 70)
    print("ORDER PILLAR: prefix order on the free monoid of walks")
    print("=" * 70)
    sample: List[Word] = [
        (),
        ("N",), ("E",),
        ("N", "E"), ("N", "N"), ("E", "S"),
        ("N", "E", "S"), ("N", "E", "S", "W"),
    ]
    refl, trans, antisym = prefix_order_is_partial_order(sample)
    print(f"reflexive={refl}, transitive={trans}, antisymmetric={antisym}")
    walk: Word = ("N", "E", "S", "W")
    divs = left_divisors(walk)
    print(f"left-divisors of {walk}: {divs}")
    print(f"finitariness: |divisors| = {len(divs)} == len+1 = {len(walk)+1} "
          f"-> {len(divs) == len(walk)+1}")

    print()
    print("=" * 70)
    print("GROUP COLLAPSE: left-divisibility on Z/n is indiscrete")
    print("=" * 70)
    for n in (1, 2, 3, 5):
        universal = all(zmod_left_divides(n, a, b)
                        for a in range(n) for b in range(n))
        print(f"Z/{n}: every element divides every other = {universal}; "
              f"antisymmetric (=> trivial) = {zmod_antisymmetry_holds(n)}")

    print()
    print("=" * 70)
    print("SYMMETRY PILLAR (Sabidussi) + the Petersen dichotomy")
    print("=" * 70)
    tests = [
        ("C5 (5-cycle, Cayley of Z5)", cycle_graph(5)),
        ("Pentagonal prism (Cayley of Z10)", pentagonal_prism()),
        ("Petersen graph", petersen_graph()),
        ("Line graph of Petersen", line_graph(petersen_graph())),
    ]
    for name, g in tests:
        vt = is_vertex_transitive(g)
        naut = len(automorphisms(g))
        reg = has_regular_aut_subgroup(g)
        cayley = reg is not None
        order = len(reg) if reg is not None else 0
        print(f"{name}: |V|={len(g)}, vertex-transitive={vt}, "
              f"|Aut|={naut}, regular subgroup found={cayley}"
              + (f" (order {order})" if cayley else ""))
        print(f"    => Conjecture 6.2 predicts P(G,v0) "
              f"{'MULTIPLICABLE' if cayley else 'NOT multiplicable'}")


if __name__ == "__main__":
    main()
