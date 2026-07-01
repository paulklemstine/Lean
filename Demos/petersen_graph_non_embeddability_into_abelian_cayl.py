"""
Numerical demonstrations for:

    Non-Embeddability of the Petersen Graph into Bipartite Abelian Cayley Graphs

This self-contained script illustrates the two ingredients of the main theorem:

  1. A METRIC OBSTRUCTION (any number of colors): an isometric embedding pulls a
     proper n-coloring of the host back to the source. Hence a graph needing more
     than n colors cannot embed isometrically into an n-colorable host.

  2. A BIPARTITE CERTIFICATE for abelian Cayley graphs: an additive character
     psi : A -> Z/2 sending every connection-set element to 1 is itself a proper
     2-coloring.

Combining them: the Petersen graph (odd girth 5, chromatic number 3) admits no
isometric embedding into any bipartite abelian Cayley graph, in particular into
any hypercube (so it is not a partial cube).

Only the standard library is used.
"""

from __future__ import annotations

from collections import deque
from itertools import combinations, product
from typing import Dict, FrozenSet, Iterable, List, Optional, Tuple

Vertex = object  # graphs are represented as adjacency dictionaries


# --------------------------------------------------------------------------- #
# Generic graph utilities
# --------------------------------------------------------------------------- #
def all_pairs_distances(adj: Dict[Vertex, List[Vertex]]) -> Dict[Vertex, Dict[Vertex, int]]:
    """Breadth-first shortest-path distances between all pairs of vertices."""
    dist: Dict[Vertex, Dict[Vertex, int]] = {}
    for source in adj:
        d: Dict[Vertex, int] = {source: 0}
        queue: deque = deque([source])
        while queue:
            u = queue.popleft()
            for w in adj[u]:
                if w not in d:
                    d[w] = d[u] + 1
                    queue.append(w)
        dist[source] = d
    return dist


def is_bipartite(adj: Dict[Vertex, List[Vertex]]) -> Tuple[bool, Optional[List[Vertex]]]:
    """
    Two-color the graph by BFS. Returns (True, None) if bipartite, or
    (False, odd_cycle) exhibiting an odd cycle as a concrete witness.
    """
    color: Dict[Vertex, int] = {}
    parent: Dict[Vertex, Optional[Vertex]] = {}
    for start in adj:
        if start in color:
            continue
        color[start] = 0
        parent[start] = None
        queue: deque = deque([start])
        while queue:
            u = queue.popleft()
            for w in adj[u]:
                if w not in color:
                    color[w] = color[u] ^ 1
                    parent[w] = u
                    queue.append(w)
                elif color[w] == color[u]:
                    # Same-color edge closes an odd cycle; reconstruct it.
                    path_u, x = [u], u
                    while x is not None:
                        x = parent[x]
                        if x is not None:
                            path_u.append(x)
                    path_w, y = [w], w
                    while y is not None:
                        y = parent[y]
                        if y is not None:
                            path_w.append(y)
                    su, sw = set(path_u), path_w
                    lca = next(z for z in sw if z in su)
                    cyc = path_u[: path_u.index(lca) + 1]
                    cyc += list(reversed(path_w[: path_w.index(lca)]))
                    return False, cyc
    return True, None


# --------------------------------------------------------------------------- #
# The Petersen graph  P = Kneser graph K(5,2)
# --------------------------------------------------------------------------- #
def petersen_graph() -> Dict[FrozenSet[int], List[FrozenSet[int]]]:
    """Vertices: 2-subsets of {0,...,4}; adjacent iff disjoint."""
    verts: List[FrozenSet[int]] = [frozenset(c) for c in combinations(range(5), 2)]
    adj: Dict[FrozenSet[int], List[FrozenSet[int]]] = {v: [] for v in verts}
    for u, v in combinations(verts, 2):
        if u.isdisjoint(v):
            adj[u].append(v)
            adj[v].append(u)
    return adj


# --------------------------------------------------------------------------- #
# Cayley graph of a finite abelian group
# --------------------------------------------------------------------------- #
def cayley_graph(
    elements: List[Tuple[int, ...]],
    moduli: Tuple[int, ...],
    connection_set: List[Tuple[int, ...]],
) -> Dict[Tuple[int, ...], List[Tuple[int, ...]]]:
    """
    Cayley graph on an abelian group A = prod_j Z/moduli[j].
    g ~ h iff (h - g) mod moduli lies in the (symmetric, 0-free) connection set.
    """
    conn = {tuple(s) for s in connection_set}
    adj: Dict[Tuple[int, ...], List[Tuple[int, ...]]] = {g: [] for g in elements}
    for g in elements:
        for h in elements:
            if g == h:
                continue
            diff = tuple((h[j] - g[j]) % moduli[j] for j in range(len(moduli)))
            if diff in conn:
                adj[g].append(h)
    return adj


def group_elements(moduli: Tuple[int, ...]) -> List[Tuple[int, ...]]:
    return [tuple(x) for x in product(*(range(m) for m in moduli))]


def hypercube(k: int) -> Dict[Tuple[int, ...], List[Tuple[int, ...]]]:
    """Q_k = Cay((Z/2)^k, standard basis)."""
    moduli = (2,) * k
    basis = [tuple(1 if i == j else 0 for j in range(k)) for i in range(k)]
    return cayley_graph(group_elements(moduli), moduli, basis)


# --------------------------------------------------------------------------- #
# Character certificate for bipartiteness (Lemma 4.1)
# --------------------------------------------------------------------------- #
def parity_character(x: Tuple[int, ...]) -> int:
    """Coordinate-sum character psi(x) = sum(x) mod 2 on (Z/2)^k."""
    return sum(x) % 2


def character_certifies_bipartite(
    connection_set: Iterable[Tuple[int, ...]],
    character,
) -> bool:
    """True iff the additive character sends every connection-set element to 1."""
    return all(character(s) == 1 for s in connection_set)


# --------------------------------------------------------------------------- #
# The metric obstruction (Lemma 3.1 / Theorem 3.2)
# --------------------------------------------------------------------------- #
def pullback_coloring_is_proper(
    source_adj: Dict[Vertex, List[Vertex]],
    embedding: Dict[Vertex, Vertex],
    host_coloring,
) -> Tuple[bool, Optional[Tuple[Vertex, Vertex]]]:
    """
    Pull the host coloring back along the embedding, c'(v) = c(f(v)), and check
    it is proper on the source. Returns (True, None) or (False, bad_edge).
    """
    for u in source_adj:
        for v in source_adj[u]:
            if host_coloring(embedding[u]) == host_coloring(embedding[v]):
                return False, (u, v)
    return True, None


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_petersen_is_not_bipartite() -> None:
    print("=" * 70)
    print("DEMO 1  The Petersen graph is not bipartite (odd girth 5)")
    print("=" * 70)
    P = petersen_graph()
    bip, cycle = is_bipartite(P)
    print(f"  vertices: {len(P)}   edges: {sum(len(a) for a in P.values()) // 2}")
    print(f"  bipartite? {bip}")
    if cycle is not None:
        pretty = " -> ".join("{" + ",".join(map(str, sorted(v))) + "}" for v in cycle)
        print(f"  odd cycle length {len(cycle)}: {pretty}")
    assert not bip and cycle is not None and len(cycle) % 2 == 1
    print("  => chromatic number > 2, so P needs 3 colors.\n")


def demo_hypercube_is_bipartite() -> None:
    print("=" * 70)
    print("DEMO 2  Hypercubes are bipartite via the parity character")
    print("=" * 70)
    for k in range(1, 5):
        basis = [tuple(1 if i == j else 0 for j in range(k)) for i in range(k)]
        cert = character_certifies_bipartite(basis, parity_character)
        Q = hypercube(k)
        bip, _ = is_bipartite(Q)
        print(f"  Q_{k}: character sends every basis vector to 1? {cert}; "
              f"BFS bipartite? {bip}")
        assert cert and bip
    print("  => psi(x)=sum(x) mod 2 is a proper 2-coloring of every Q_k.\n")


def demo_general_abelian_certificate() -> None:
    print("=" * 70)
    print("DEMO 3  Character certificate on a general abelian group")
    print("=" * 70)
    # A = Z/4 x Z/2, connection set {(1,0),(3,0),(0,1)} (symmetric, 0-free).
    moduli = (4, 2)
    S = [(1, 0), (3, 0), (0, 1)]

    def psi(x: Tuple[int, ...]) -> int:
        # additive character A -> Z/2:  x0 parity plus second coordinate
        return (x[0] + x[1]) % 2

    cert = character_certifies_bipartite(S, psi)
    G = cayley_graph(group_elements(moduli), moduli, S)
    bip, _ = is_bipartite(G)
    print(f"  A = Z/4 x Z/2, S = {S}")
    print(f"  character certifies bipartite? {cert};  BFS bipartite? {bip}")
    print("  (the certificate is sufficient: whenever it holds, the graph is")
    print("   bipartite; a bipartite host may also arise without a certificate.)")
    assert cert and bip
    print()


def demo_metric_obstruction_refutes_embedding() -> None:
    print("=" * 70)
    print("DEMO 4  Any map into a bipartite host fails to be isometric")
    print("=" * 70)
    P = petersen_graph()
    dP = all_pairs_distances(P)
    Q = hypercube(4)  # a bipartite abelian Cayley host
    dQ = all_pairs_distances(Q)
    hosts = list(Q.keys())

    import random
    random.seed(0)
    tried, isometric_found = 0, False
    for _ in range(20000):
        tried += 1
        f = {v: random.choice(hosts) for v in P}
        ok = True
        for u in P:
            for v in P:
                if dQ[f[u]][f[v]] != dP[u][v]:
                    ok = False
                    break
            if not ok:
                break
        if ok:
            isometric_found = True
            break
    print(f"  random maps P -> Q_4 tried: {tried}; isometric found? {isometric_found}")

    # Whatever the map, the pullback coloring must fail on some edge, because
    # any isometric map would give a proper 2-coloring of P (impossible).
    f = {v: random.choice(hosts) for v in P}
    proper, bad_edge = pullback_coloring_is_proper(P, f, parity_character)
    print(f"  pullback of parity coloring proper on P? {proper}")
    if bad_edge is not None:
        u, v = bad_edge
        print(f"    monochromatic edge witness: {set(u)} -- {set(v)}")
    assert not isometric_found
    print("  => consistent with the theorem: no isometric embedding exists.\n")


def demo_summary() -> None:
    print("=" * 70)
    print("SUMMARY")
    print("=" * 70)
    print("  * Metric principle: isometric embeddings pull back n-colorings.")
    print("  * Abelian certificate: one Z/2 character 2-colors a Cayley graph.")
    print("  * Petersen graph has an odd 5-cycle, so needs 3 colors.")
    print("  => It embeds isometrically into NO bipartite abelian Cayley graph,")
    print("     in particular into no hypercube (it is not a partial cube).")


if __name__ == "__main__":
    demo_petersen_is_not_bipartite()
    demo_hypercube_is_bipartite()
    demo_general_abelian_certificate()
    demo_metric_obstruction_refutes_embedding()
    demo_summary()
