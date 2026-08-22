"""
The Non-Backtracking Trace Formula: numerical demonstrations
============================================================

For a finite simple graph G = (V, E) let

    D = { (u, v) : {u, v} in E }

be its set of *darts* (each undirected edge gives two darts, so |D| = 2|E|).
The Hashimoto (non-backtracking) matrix B is the |D| x |D| zero-one matrix

    B[(u,v), (x,y)] = 1   iff   v = x  and  y != u.

A *rooted closed non-backtracking walk of length n* is a list of n + 1 darts
d_0, d_1, ..., d_n with B[d_i, d_{i+1}] = 1 for all i and d_0 = d_n.

Main theorem demonstrated here:

    trace(B^n) = # { rooted closed non-backtracking walks of length n }.

Together with its corollaries:

  * trace(B^0) = |D| = sum of degrees,  trace(B^1) = trace(B^2) = 0;
  * trace(B^3) = number of ordered triangles (= 6 * #triangles);
  * every trace(B^n) is even (dart reversal is a fixed-point-free involution);
  * row sums: sum_{d'} B[d, d'] = deg(head(d)) - 1; for a (q+1)-regular graph
    every row sums to q, so trace(B^n) <= |D| * q^n;
  * G is a forest  iff  trace(B^n) = 0 for all n >= 1;
  * girth(G) = min { n >= 1 : trace(B^n) != 0 }, and 2 * girth(G) <= trace(B^girth);
  * H subgraph of G  implies  trace(B_H^n) <= trace(B_G^n).

Everything below is plain Python with no third-party dependencies: the matrix
powers are computed with exact integer arithmetic, and the walk counts are
obtained by explicit enumeration, so the two sides of the theorem are compared
by two genuinely independent computations.
"""

from __future__ import annotations

from itertools import combinations
from typing import Dict, FrozenSet, Iterable, List, Optional, Sequence, Set, Tuple

Vertex = int
Edge = FrozenSet[Vertex]
Dart = Tuple[Vertex, Vertex]
Matrix = List[List[int]]


# ---------------------------------------------------------------------------
# Graphs
# ---------------------------------------------------------------------------

class Graph:
    """A finite simple graph on the vertex set {0, ..., n-1}."""

    def __init__(self, n: int, edges: Iterable[Tuple[Vertex, Vertex]]) -> None:
        self.n: int = n
        self.edges: List[Edge] = []
        seen: Set[Edge] = set()
        for u, v in edges:
            if u == v:
                raise ValueError("simple graphs have no loops")
            e = frozenset((u, v))
            if e not in seen:
                seen.add(e)
                self.edges.append(e)
        self.adj: Dict[Vertex, Set[Vertex]] = {v: set() for v in range(n)}
        for e in self.edges:
            u, v = tuple(e)
            self.adj[u].add(v)
            self.adj[v].add(u)

    def degree(self, v: Vertex) -> int:
        return len(self.adj[v])

    def darts(self) -> List[Dart]:
        """All darts, in a fixed deterministic order."""
        out: List[Dart] = []
        for e in sorted(self.edges, key=lambda s: sorted(s)):
            u, v = sorted(e)
            out.append((u, v))
            out.append((v, u))
        return out

    def is_regular(self) -> Optional[int]:
        """Return the common degree if the graph is regular, else None."""
        degs = {self.degree(v) for v in range(self.n)}
        return degs.pop() if len(degs) == 1 else None


def complete_graph(n: int) -> Graph:
    return Graph(n, combinations(range(n), 2))


def cycle_graph(n: int) -> Graph:
    return Graph(n, [(i, (i + 1) % n) for i in range(n)])


def path_graph(n: int) -> Graph:
    return Graph(n, [(i, i + 1) for i in range(n - 1)])


def petersen_graph() -> Graph:
    outer = [(i, (i + 1) % 5) for i in range(5)]
    inner = [(5 + i, 5 + (i + 2) % 5) for i in range(5)]
    spokes = [(i, 5 + i) for i in range(5)]
    return Graph(10, outer + inner + spokes)


# ---------------------------------------------------------------------------
# The Hashimoto matrix and exact integer linear algebra
# ---------------------------------------------------------------------------

def nb_adjacent(d: Dart, e: Dart) -> bool:
    """Non-backtracking succession: d = (u,v) is followed by e = (x,y)."""
    (u, v), (x, y) = d, e
    return v == x and y != u


def hashimoto(g: Graph) -> Matrix:
    darts = g.darts()
    return [[1 if nb_adjacent(d, e) else 0 for e in darts] for d in darts]


def mat_mul(a: Matrix, b: Matrix) -> Matrix:
    n, m, p = len(a), len(b), len(b[0])
    out = [[0] * p for _ in range(n)]
    for i in range(n):
        row = a[i]
        oi = out[i]
        for k in range(m):
            aik = row[k]
            if aik:
                bk = b[k]
                for j in range(p):
                    oi[j] += aik * bk[j]
    return out


def mat_identity(n: int) -> Matrix:
    return [[1 if i == j else 0 for j in range(n)] for i in range(n)]


def mat_pow(a: Matrix, n: int) -> Matrix:
    """Exact integer matrix power by repeated squaring."""
    result = mat_identity(len(a))
    base = [row[:] for row in a]
    while n:
        if n & 1:
            result = mat_mul(result, base)
        base = mat_mul(base, base)
        n >>= 1
    return result


def trace(a: Matrix) -> int:
    return sum(a[i][i] for i in range(len(a)))


def nb_trace(g: Graph, n: int) -> int:
    return trace(mat_pow(hashimoto(g), n))


# ---------------------------------------------------------------------------
# Brute-force enumeration of rooted closed non-backtracking walks
# ---------------------------------------------------------------------------

def closed_nb_walks(g: Graph, n: int) -> List[Tuple[Dart, ...]]:
    """All rooted closed non-backtracking walks of length n, as dart lists."""
    darts = g.darts()
    if n == 0:
        return [(d,) for d in darts]
    successors: Dict[Dart, List[Dart]] = {
        d: [e for e in darts if nb_adjacent(d, e)] for d in darts
    }
    out: List[Tuple[Dart, ...]] = []

    def extend(prefix: List[Dart]) -> None:
        if len(prefix) == n + 1:
            if prefix[0] == prefix[-1]:
                out.append(tuple(prefix))
            return
        for e in successors[prefix[-1]]:
            prefix.append(e)
            extend(prefix)
            prefix.pop()

    for d in darts:
        extend([d])
    return out


def count_closed_nb_walks(g: Graph, n: int) -> int:
    return len(closed_nb_walks(g, n))


# ---------------------------------------------------------------------------
# Combinatorial invariants used by the corollaries
# ---------------------------------------------------------------------------

def ordered_triangles(g: Graph) -> int:
    """Number of triples (a,b,c) with a~b, b~c, c~a; equals 6 * #triangles."""
    return sum(
        1
        for a in range(g.n)
        for b in g.adj[a]
        for c in g.adj[b]
        if a in g.adj[c]
    )


def girth(g: Graph) -> Optional[int]:
    """Length of a shortest cycle, or None for a forest (BFS from each vertex)."""
    best: Optional[int] = None
    for root in range(g.n):
        dist = {root: 0}
        parent: Dict[Vertex, Optional[Vertex]] = {root: None}
        queue = [root]
        while queue:
            nxt: List[Vertex] = []
            for u in queue:
                for w in g.adj[u]:
                    if w not in dist:
                        dist[w] = dist[u] + 1
                        parent[w] = u
                        nxt.append(w)
                    elif parent[u] != w:
                        cand = dist[u] + dist[w] + 1
                        best = cand if best is None else min(best, cand)
            queue = nxt
    return best


def first_nonzero_trace(g: Graph, bound: int = 12) -> Optional[int]:
    b = hashimoto(g)
    power = mat_identity(len(b))
    for n in range(1, bound + 1):
        power = mat_mul(power, b)
        if trace(power) != 0:
            return n
    return None


def reverse_walk(walk: Sequence[Dart]) -> Tuple[Dart, ...]:
    """The reversal involution: reverse the list and flip every dart."""
    return tuple((v, u) for (u, v) in reversed(list(walk)))


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_main_theorem() -> None:
    print("=" * 72)
    print("1. THE TRACE FORMULA:  trace(B^n) = #rooted closed NB walks of length n")
    print("=" * 72)
    examples = [
        ("K3  (triangle)", complete_graph(3), 7),
        ("K4  (complete, 4 vertices)", complete_graph(4), 6),
        ("C5  (pentagon)", cycle_graph(5), 6),
        ("P4  (path, a tree)", path_graph(4), 6),
        ("Petersen graph", petersen_graph(), 5),
    ]
    for name, g, nmax in examples:
        print(f"\n{name}:  |V| = {g.n}, |E| = {len(g.edges)}, |darts| = {2*len(g.edges)}")
        print("   n :  trace(B^n)   enumerated   match")
        for n in range(0, nmax + 1):
            t = nb_trace(g, n)
            c = count_closed_nb_walks(g, n)
            print(f"  {n:2d} : {t:11d} {c:12d}     {'OK' if t == c else 'MISMATCH'}")
            assert t == c


def demo_small_powers() -> None:
    print()
    print("=" * 72)
    print("2. SMALL POWERS:  trace(B^0) = sum of degrees, trace(B^1) = trace(B^2) = 0,")
    print("   trace(B^3) = number of ordered triangles = 6 * #triangles")
    print("=" * 72)
    for name, g in [
        ("K3", complete_graph(3)),
        ("K4", complete_graph(4)),
        ("K5", complete_graph(5)),
        ("C5", cycle_graph(5)),
        ("Petersen", petersen_graph()),
    ]:
        degsum = sum(g.degree(v) for v in range(g.n))
        t0, t1, t2, t3 = (nb_trace(g, k) for k in range(4))
        tri = ordered_triangles(g)
        print(f"{name:9s}  trace(B^0) = {t0:3d} = sum deg = {degsum:3d} | "
              f"trace(B^1) = {t1} | trace(B^2) = {t2} | "
              f"trace(B^3) = {t3:3d} = ordered triangles = {tri:3d} "
              f"(= 6 * {tri // 6})")
        assert (t0, t1, t2, t3) == (degsum, 0, 0, tri)


def demo_parity() -> None:
    print()
    print("=" * 72)
    print("3. EVENNESS:  dart reversal is a fixed-point-free involution on the set of")
    print("   rooted closed non-backtracking walks, hence every trace is even")
    print("=" * 72)
    g = complete_graph(4)
    for n in range(1, 6):
        walks = closed_nb_walks(g, n)
        s = set(walks)
        assert all(reverse_walk(w) in s for w in walks), "reversal must preserve the set"
        assert all(reverse_walk(w) != w for w in walks), "reversal has no fixed point"
        print(f"  K4, n = {n}: {len(walks):4d} walks, "
              f"reversal is an involution without fixed points -> even: "
              f"{len(walks) % 2 == 0}")
    if walks:
        w = walks[0]
        print(f"\n  Example pairing at n = 5:\n    walk     {list(w)}\n"
              f"    reversed {list(reverse_walk(w))}")


def demo_row_sums_and_growth() -> None:
    print()
    print("=" * 72)
    print("4. ROW SUMS AND GROWTH:  row of dart (u,v) sums to deg(v) - 1;")
    print("   for a (q+1)-regular graph, trace(B^n) <= |darts| * q^n")
    print("=" * 72)
    for name, g in [("K4", complete_graph(4)), ("C5", cycle_graph(5)),
                    ("Petersen", petersen_graph())]:
        b = hashimoto(g)
        darts = g.darts()
        ok = all(sum(b[i]) == g.degree(d[1]) - 1 for i, d in enumerate(darts))
        deg = g.is_regular()
        q = None if deg is None else deg - 1
        print(f"\n{name}: row-sum identity holds for every dart: {ok}"
              + (f";  (q+1)-regular with q = {q}" if q is not None else ""))
        assert ok
        if q is not None:
            for n in range(1, 7):
                t = nb_trace(g, n)
                bound = len(darts) * q ** n
                print(f"    n = {n}: trace = {t:6d}  <=  |darts|*q^n = {bound:8d}   "
                      f"{'OK' if t <= bound else 'VIOLATED'}")
                assert t <= bound


def demo_acyclicity_and_girth() -> None:
    print()
    print("=" * 72)
    print("5. ACYCLICITY AND GIRTH:  forests have identically zero trace, and for a")
    print("   graph with a cycle, girth = min{n >= 1 : trace(B^n) != 0},")
    print("   with 2 * girth <= trace(B^girth)")
    print("=" * 72)
    forests = [
        ("path P5", path_graph(5)),
        ("star K_{1,4}", Graph(5, [(0, i) for i in range(1, 5)])),
        ("two disjoint edges", Graph(4, [(0, 1), (2, 3)])),
    ]
    for name, g in forests:
        traces = [nb_trace(g, n) for n in range(1, 9)]
        print(f"  forest {name:20s} traces n=1..8: {traces}  girth = {girth(g)}")
        assert all(t == 0 for t in traces)

    cyclic = [
        ("K3", complete_graph(3)),
        ("K4", complete_graph(4)),
        ("C5", cycle_graph(5)),
        ("C7", cycle_graph(7)),
        ("Petersen", petersen_graph()),
        ("K_{3,3}", Graph(6, [(i, 3 + j) for i in range(3) for j in range(3)])),
    ]
    print()
    for name, g in cyclic:
        gg = girth(g)
        first = first_nonzero_trace(g)
        tg = nb_trace(g, gg)
        print(f"  {name:10s} girth = {gg}, first n with trace != 0 = {first}, "
              f"trace(B^girth) = {tg:4d} >= 2*girth = {2*gg:3d}   "
              f"{'OK' if gg == first and tg >= 2*gg else 'FAIL'}")
        assert gg == first and tg >= 2 * gg
    print("\n  (For a cycle graph C_m the first nonzero trace is exactly 2m:")
    for m in (3, 4, 5, 6, 7):
        g = cycle_graph(m)
        print(f"     C{m}: trace(B^{m}) = {nb_trace(g, m)} = 2 * {m}")
        assert nb_trace(g, m) == 2 * m
    print("   the m rotations times the 2 orientations of the unique cycle.)")


def demo_monotonicity() -> None:
    print()
    print("=" * 72)
    print("6. MONOTONICITY:  if H is a subgraph of G on the same vertices, then")
    print("   trace(B_H^n) <= trace(B_G^n) for all n")
    print("=" * 72)
    chain = [
        ("C5", cycle_graph(5)),
        ("C5 + one chord", Graph(5, [(i, (i + 1) % 5) for i in range(5)] + [(0, 2)])),
        ("C5 + two chords",
         Graph(5, [(i, (i + 1) % 5) for i in range(5)] + [(0, 2), (0, 3)])),
        ("K5", complete_graph(5)),
    ]
    print("   graph              n=3    n=4    n=5    n=6")
    rows: List[List[int]] = []
    for name, g in chain:
        row = [nb_trace(g, n) for n in (3, 4, 5, 6)]
        rows.append(row)
        print(f"   {name:18s}" + "".join(f"{x:7d}" for x in row))
    for a, b in zip(rows, rows[1:]):
        assert all(x <= y for x, y in zip(a, b))
    print("   -> every column is nondecreasing, as predicted.")


def demo_triangle_periodicity() -> None:
    print()
    print("=" * 72)
    print("7. THE TRIANGLE IS A PERMUTATION:  for K3, B^3 = I, so trace(B^n) = 6 if")
    print("   3 | n and 0 otherwise; for C5, B^5 = I and trace(B^n) = 10 iff 5 | n")
    print("=" * 72)
    k3 = complete_graph(3)
    b3 = mat_pow(hashimoto(k3), 3)
    print(f"  K3: B^3 = I ?  {b3 == mat_identity(6)}")
    print("      traces n=0..9: ", [nb_trace(k3, n) for n in range(10)])
    assert b3 == mat_identity(6)
    assert [nb_trace(k3, n) for n in range(10)] == [
        6 if n % 3 == 0 else 0 for n in range(10)
    ]
    c5 = cycle_graph(5)
    b5 = mat_pow(hashimoto(c5), 5)
    print(f"  C5: B^5 = I ?  {b5 == mat_identity(10)}")
    print("      traces n=0..9: ", [nb_trace(c5, n) for n in range(10)])
    assert b5 == mat_identity(10)


def main() -> None:
    demo_main_theorem()
    demo_small_powers()
    demo_parity()
    demo_row_sums_and_growth()
    demo_acyclicity_and_girth()
    demo_monotonicity()
    demo_triangle_periodicity()
    print()
    print("=" * 72)
    print("All demonstrations completed and all assertions passed.")
    print("=" * 72)


if __name__ == "__main__":
    main()


"""
Algorithm: construction of the Hashimoto (non-backtracking) matrix of a finite simple graph.

Given G = (V, E), the darts are the ordered pairs (u, v) with {u, v} in E, so |D| = 2|E|.
The Hashimoto matrix B is indexed by darts with

    B[(u,v), (x,y)] = 1  iff  v = x and y != u,

that is, the second dart continues the first without an immediate reversal.  Both a dense
and a sparse (adjacency-list) construction are provided.  The dense build costs
O(|D|^2) = O(|E|^2) time; the sparse build costs O(sum_v deg(v)^2) time and produces
sum_v deg(v)^2 - 2|E| nonzeros, which for a (q+1)-regular graph is exactly 2|E|q.
"""

from __future__ import annotations

from typing import Dict, List, Sequence, Tuple

Dart = Tuple[int, int]


def darts(n_vertices: int, edges: Sequence[Tuple[int, int]]) -> List[Dart]:
    """Every edge contributes two darts, in a deterministic order."""
    out: List[Dart] = []
    for u, v in sorted({(min(a, b), max(a, b)) for a, b in edges}):
        out.append((u, v))
        out.append((v, u))
    return out


def may_follow(d: Dart, e: Dart) -> bool:
    """Non-backtracking succession: head(d) = tail(e) and e is not the reversal of d."""
    (u, v), (x, y) = d, e
    return v == x and y != u


def hashimoto_dense(n_vertices: int,
                    edges: Sequence[Tuple[int, int]]) -> Tuple[List[Dart], List[List[int]]]:
    """Dense zero-one Hashimoto matrix; O(|D|^2) time and space."""
    ds = darts(n_vertices, edges)
    b = [[1 if may_follow(d, e) else 0 for e in ds] for d in ds]
    return ds, b


def hashimoto_sparse(n_vertices: int,
                     edges: Sequence[Tuple[int, int]]
                     ) -> Tuple[List[Dart], List[List[int]]]:
    """Sparse Hashimoto matrix as successor lists (row d -> indices of legal successors).

    Row (u, v) contains every dart leaving v except (v, u), so it has deg(v) - 1 entries:
    this is the row-sum identity  sum_e B[d, e] = deg(head d) - 1.
    """
    ds = darts(n_vertices, edges)
    index: Dict[Dart, int] = {d: i for i, d in enumerate(ds)}
    out_of: Dict[int, List[Dart]] = {v: [] for v in range(n_vertices)}
    for d in ds:
        out_of[d[0]].append(d)
    succ: List[List[int]] = []
    for (u, v) in ds:
        succ.append([index[e] for e in out_of[v] if e[1] != u])
    return ds, succ


"""
Algorithm: orbit decomposition of cyclic non-backtracking words at the girth.

Deleting the redundant last entry of a rooted closed non-backtracking walk of length n
gives a *cyclic non-backtracking word*: a list c_1, ..., c_n of darts with c_i followed by
c_{i+1} and, at the seam, c_n followed by c_1.  The set of such words is stable under the
two natural symmetries

    rotation   c  |->  (c_2, ..., c_n, c_1),
    reversal   c  |->  (c_n^{-1}, ..., c_1^{-1}),

which together generate a dihedral group of order 2n.  A cycle of length n has all its
darts distinct, so its orbit under this group has full size 2n: the n rotations times the
2 orientations.  This routine enumerates the cyclic words of length n, splits them into
orbits, and reports the orbit sizes -- exhibiting the lower bound
2 * girth <= trace(B^girth) as an orbit count, and testing the conjectured exact value
trace(B^girth) = 2 * girth * (number of shortest cycles).

Complexity: enumeration is O(|D| q^n) for a (q+1)-regular graph, and the orbit
decomposition adds O(n) work per word.
"""

from __future__ import annotations

from typing import Dict, List, Sequence, Set, Tuple

Dart = Tuple[int, int]
Word = Tuple[Dart, ...]


def darts_of(edges: Sequence[Tuple[int, int]]) -> List[Dart]:
    out: List[Dart] = []
    for u, v in sorted({(min(a, b), max(a, b)) for a, b in edges}):
        out.append((u, v))
        out.append((v, u))
    return out


def may_follow(d: Dart, e: Dart) -> bool:
    return d[1] == e[0] and e[1] != d[0]


def cyclic_nb_words(edges: Sequence[Tuple[int, int]], n: int) -> List[Word]:
    """All cyclic non-backtracking words of n darts (chain condition plus seam)."""
    ds = darts_of(edges)
    succ: Dict[Dart, List[Dart]] = {d: [e for e in ds if may_follow(d, e)] for d in ds}
    out: List[Word] = []

    def extend(word: List[Dart]) -> None:
        if len(word) == n:
            if may_follow(word[-1], word[0]):
                out.append(tuple(word))
            return
        for e in succ[word[-1]]:
            word.append(e)
            extend(word)
            word.pop()

    for d in ds:
        extend([d])
    return out


def rotate(w: Word, i: int) -> Word:
    return w[i:] + w[:i]


def reverse(w: Word) -> Word:
    return tuple((v, u) for (u, v) in reversed(w))


def dihedral_orbits(words: Sequence[Word]) -> List[List[Word]]:
    """Split a set of cyclic words into orbits under rotation and reversal."""
    pool: Set[Word] = set(words)
    orbits: List[List[Word]] = []
    while pool:
        w = next(iter(pool))
        n = len(w)
        orbit = {rotate(w, i) for i in range(n)} | {rotate(reverse(w), i) for i in range(n)}
        orbit &= pool
        pool -= orbit
        orbits.append(sorted(orbit))
    return orbits


def is_cycle_word(w: Word) -> bool:
    """A word is the dart word of a cycle when its tails are pairwise distinct."""
    tails = [d[0] for d in w]
    return len(set(tails)) == len(tails)


def multiplicity_report(edges: Sequence[Tuple[int, int]], n: int) -> Dict[str, object]:
    """Enumerate cyclic words of length n and describe their dihedral orbit structure."""
    words = cyclic_nb_words(edges, n)
    orbits = dihedral_orbits(words)
    return {
        "length": n,
        "total_words": len(words),
        "orbits": len(orbits),
        "orbit_sizes": sorted(len(o) for o in orbits),
        "all_orbits_full": all(len(o) == 2 * n for o in orbits),
        "all_words_are_cycles": all(is_cycle_word(w) for w in words),
        "predicted_2n_times_cycles": 2 * n * len(orbits),
    }


"""
Algorithms: the non-backtracking trace sequence, girth detection from it, and
brute-force verification by enumeration.

  * trace_sequence(G, N) returns [trace(B^0), ..., trace(B^N)].  Sparse successor lists
    make each step a matrix-vector product, so the whole prefix costs
    O(N * nnz(B) * |D|) with nnz(B) = sum_v deg(v)^2 - 2|E|.
  * girth_from_traces(G) returns the least n >= 1 with trace(B^n) != 0, which is the girth;
    a search reaching |V| without a hit certifies that the graph is a forest.
  * count_closed_nb_walks(G, n) enumerates rooted closed non-backtracking walks directly,
    in O(|D| q^n) time for a (q+1)-regular graph, and must agree with trace(B^n).
"""

from __future__ import annotations

from typing import Dict, List, Optional, Sequence, Tuple

Dart = Tuple[int, int]


def _darts(edges: Sequence[Tuple[int, int]]) -> List[Dart]:
    out: List[Dart] = []
    for u, v in sorted({(min(a, b), max(a, b)) for a, b in edges}):
        out.append((u, v))
        out.append((v, u))
    return out


def _successors(ds: Sequence[Dart]) -> List[List[int]]:
    index: Dict[Dart, int] = {d: i for i, d in enumerate(ds)}
    out_of: Dict[int, List[Dart]] = {}
    for d in ds:
        out_of.setdefault(d[0], []).append(d)
    return [[index[e] for e in out_of.get(v, []) if e[1] != u] for (u, v) in ds]


def trace_sequence(n_vertices: int,
                   edges: Sequence[Tuple[int, int]],
                   nmax: int) -> List[int]:
    """[trace(B^0), ..., trace(B^nmax)], computed with sparse matrix-vector products.

    trace(B^n) = sum over darts d of (B^n)[d, d]; the d-th diagonal entry is obtained by
    propagating the indicator vector of d forward n steps along successor lists.
    """
    ds = _darts(edges)
    succ = _successors(ds)
    m = len(ds)
    out = [m]
    for n in range(1, nmax + 1):
        total = 0
        for start in range(m):
            vec = [0] * m
            vec[start] = 1
            for _ in range(n):
                nxt = [0] * m
                for i, x in enumerate(vec):
                    if x:
                        for j in succ[i]:
                            nxt[j] += x
                vec = nxt
            total += vec[start]
        out.append(total)
    return out


def girth_from_traces(n_vertices: int,
                      edges: Sequence[Tuple[int, int]]) -> Optional[int]:
    """The girth, as the first index with a nonzero non-backtracking trace.

    Returns None when the graph is a forest.  Correct because (a) a cycle of length m
    yields a closed non-backtracking walk of length m, and (b) a closed non-backtracking
    walk of length n forces a cycle of length at most n.  A graph with a cycle has girth
    at most |V|, which bounds the search.
    """
    seq = trace_sequence(n_vertices, edges, max(n_vertices, 1))
    for n in range(1, len(seq)):
        if seq[n] != 0:
            return n
    return None


def count_closed_nb_walks(n_vertices: int,
                          edges: Sequence[Tuple[int, int]],
                          n: int) -> int:
    """Brute-force count of rooted closed non-backtracking walks of length n."""
    ds = _darts(edges)
    if n == 0:
        return len(ds)
    succ = _successors(ds)
    total = 0

    def extend(start: int, cur: int, steps: int) -> None:
        nonlocal total
        if steps == n:
            if cur == start:
                total += 1
            return
        for j in succ[cur]:
            extend(start, j, steps + 1)

    for s in range(len(ds)):
        extend(s, s, 0)
    return total


"""Assemble PACKAGE.json from the prose deliverables and the package assets."""

from __future__ import annotations

import json
import pathlib

ROOT = pathlib.Path(__file__).resolve().parent.parent
A = ROOT / "package_assets"


def read(p: pathlib.Path) -> str:
    return p.read_text(encoding="utf-8")


LEAN_FILES = [
    "Catalog/Algebra/NonBacktracking.lean",
    "Catalog/Algebra/NonBacktracking/RelWalkCount.lean",
    "Catalog/Algebra/NonBacktracking/HashimotoTrace.lean",
    "Catalog/Algebra/NonBacktracking/VertexCycles.lean",
    "Catalog/Algebra/NonBacktracking/CyclePositivity.lean",
    "Catalog/Algebra/NonBacktracking/AcyclicVanishing.lean",
    "Catalog/Algebra/NonBacktracking/Girth.lean",
    "Catalog/Algebra/NonBacktracking/ReversalParity.lean",
    "Catalog/Algebra/NonBacktracking/CycleMultiplicity.lean",
    "Catalog/Algebra/NonBacktracking/Monotonicity.lean",
    "Catalog/Algebra/NonBacktracking/Examples.lean",
]

lean_proofs = "\n\n".join(
    f"-- ===== {rel} =====\n{read(ROOT / rel)}" for rel in LEAN_FILES
)

FUTURE_DIRECTIONS = """# Future directions: the non-backtracking trace after the counting theorem

The development proves `trace(Bⁿ) = #{rooted closed non-backtracking walks of length n}`
in three equivalent shapes (dart lists, cyclic dart words, cyclic vertex words), and then
extracts the structural consequences:

* vanishing at `n = 1, 2`, the ordered-triangle count at `n = 3`, and the `(q+1)`-regular
  growth bound `#darts · qⁿ`;
* evenness of every trace, together with its algebraic source `J B J = Bᵀ` (dart reversal
  conjugates `B` into its transpose);
* the exact acyclicity criterion `G is acyclic ↔ ∀ n ≥ 1, trace(Bⁿ) = 0`;
* the girth criterion `girth G = min {n ≥ 1 : trace(Bⁿ) ≠ 0}` for a graph with a cycle,
  together with the lower bound `2 · girth ≤ trace(B^girth)`;
* monotonicity of the whole sequence under graph inclusion.

Two conjectures of the previous cycle — the reversal intertwiner and the identification of
the girth with the first nonvanishing index — are therefore now theorems. The directions
below are the conjectures that the current state makes testable next.

## 1. Chebyshev recursion for non-backtracking walk matrices

**Conjecture.** For a `(q+1)`-regular graph let `A_m` be the matrix counting
non-backtracking walks of length `m` between vertices. Then `A₁ = A`,
`A₂ = A² − (q+1)I` and `A_{m+1} = A·A_m − q·A_{m−1}`; consequently `A_m = P_m(A)` for an
explicit Chebyshev-like polynomial `P_m`, and `trace(Bᵐ)` is a fixed linear combination of
`trace(Aᵏ)`.

*The key insight is* that the vertex form of the trace formula already exhibits closed
non-backtracking walks as ordinary walks with a purely local forbidden pattern
(`u_{i+2} ≠ u_i`), so inclusion–exclusion on that single pattern should close into a
three-term recursion rather than an infinite hierarchy.
*Why now?* The vertex form of the trace theorem and the row-sum computation are exactly
the two ingredients the recursion needs, and both are established.

## 2. Ihara determinant identity from the trace generating function

**Conjecture.** For a finite graph, `∑_{n≥1} trace(Bⁿ) uⁿ / n = −log det(I − uB)`, and
for `(q+1)`-regular graphs the right-hand side equals
`−log[(1−u²)^{|E|−|V|} · det(I − uA + qu²I)]`.

*The key insight is* that the counting theorem converts the analytic Ihara identity into a
statement about counting cyclic words, so the hard direction becomes a bijection between
cyclic non-backtracking words and multisets of primitive cycles.
*Why now?* The set of cyclic non-backtracking words is now known to be stable under
rotation and under reversal, so the rotation action needed for the primitive-cycle
decomposition is available; what remains is the orbit/stabiliser bookkeeping.

## 3. Exact multiplicity of the girth in the trace sequence

**Conjecture.** For a graph containing a cycle,
`trace(B^girth) = 2 · girth · #{cycles of length girth}`, i.e. the first nonzero term of
the sequence counts shortest cycles with multiplicity exactly `2 · girth`. The lower bound
`2 · girth ≤ trace(B^girth)` is already a theorem; the remaining content is that every
cyclic non-backtracking word of length exactly the girth is the dart word of a shortest
cycle. Orbit enumeration confirms the identity on the pentagon, `K₄`, `K₅`, `K₃,₃`, the
cube and the Petersen graph.
"""

INTERACTIVE_LAYOUT = read(A / "interactive_layout.md")

package = {
    "title": "The Non-Backtracking Trace Formula: Counting Rooted Closed "
             "Non-Backtracking Walks by Powers of the Hashimoto Matrix",
    "domain": "Algebra",
    "description": (
        "For a finite simple graph, the trace of the n-th power of the Hashimoto "
        "(non-backtracking) matrix equals the number of rooted closed non-backtracking "
        "walks of length n. From this counting theorem follow a complete dictionary "
        "between the trace sequence and the cycle structure of the graph: vanishing "
        "exactly on forests, the girth as the first nonzero index, evenness of every "
        "trace, the ordered-triangle count at length three, and monotonicity under "
        "subgraph inclusion."
    ),
    "authors": ["Aristotle"],
    "date": "2026-08-22",
    "key_results": [
        "Non-Backtracking Trace Formula: for every finite simple graph and every n, the "
        "trace of the n-th power of the Hashimoto matrix equals the number of rooted "
        "closed non-backtracking walks of length n, equivalently the number of cyclic "
        "non-backtracking dart words of length n, equivalently the number of cyclic "
        "vertex sequences with consecutive adjacency and no return at distance two",
        "Acyclicity criterion: a finite simple graph is a forest if and only if the trace "
        "of every positive power of its Hashimoto matrix vanishes",
        "Girth criterion: for a graph containing a cycle, the girth equals the least n at "
        "which the non-backtracking trace is nonzero, and the value there is at least "
        "twice the girth",
        "Parity theorem: every non-backtracking trace is even, because dart reversal is a "
        "fixed-point-free involution on closed non-backtracking walks; its algebraic "
        "source is that reversal conjugates the Hashimoto matrix into its transpose",
        "Low-order evaluations and growth: the traces at lengths one and two vanish for "
        "every graph, the trace at length three is six times the number of triangles, "
        "each row of the Hashimoto matrix sums to the head degree minus one, and a "
        "(q+1)-regular graph satisfies the bound trace(B^n) at most 2|E| q^n; the whole "
        "trace sequence is monotone under subgraph inclusion",
    ],
    "keywords": [
        "non-backtracking walk",
        "Hashimoto matrix",
        "trace formula",
        "girth",
        "acyclicity",
        "Ihara zeta function",
        "graph spectrum",
        "dart",
    ],
    "article": read(ROOT / "ARTICLE.md"),
    "research_paper": read(ROOT / "RESEARCH_PAPER.md"),
    "research_paper_tex": read(ROOT / "RESEARCH_PAPER.tex"),
    "demo": read(ROOT / "demo.py"),
    "demos": [
        {
            "name": "End-to-End Verification of the Non-Backtracking Trace Formula and "
                    "Its Corollaries",
            "description": (
                "A dependency-free demonstration that computes the Hashimoto matrix of a "
                "library of graphs (the triangle, the complete graph on four vertices, "
                "the pentagon, a path, the Petersen graph) with exact integer arithmetic, "
                "and compares the trace of every power against an independent brute-force "
                "enumeration of rooted closed non-backtracking walks. It then exercises "
                "each corollary in turn: the trace at length zero equals the number of "
                "darts, the traces at lengths one and two vanish, the trace at length "
                "three equals six times the number of triangles, dart reversal pairs the "
                "walks so every trace is even, each row sums to the head degree minus one "
                "and the regular growth bound holds, forests have identically zero traces "
                "while the first nonzero trace of a graph with a cycle occurs exactly at "
                "the girth with value at least twice the girth, the sequence is monotone "
                "under adding edges, and the triangle and pentagon have permutation "
                "Hashimoto matrices with exactly periodic trace sequences."
            ),
            "code": read(ROOT / "demo.py"),
        },
        {
            "name": "The Girth as the First Nonzero Trace, and the Multiplicity 2g of "
                    "Each Shortest Cycle",
            "description": (
                "For ten graphs — two forests, complete graphs, cycles, the complete "
                "bipartite graph on three plus three vertices, the three-dimensional cube "
                "and the Petersen graph — the script computes the girth twice: once by "
                "breadth-first search and once as the first index at which the "
                "non-backtracking trace becomes nonzero, and checks that the two agree. "
                "It then enumerates all cyclic non-backtracking words of length equal to "
                "the girth and decomposes them into orbits under the dihedral action "
                "generated by rotation and reversal. Every orbit is found to have full "
                "size twice the girth, and the number of orbits equals the number of "
                "shortest cycles, so the value of the first nonzero trace is exactly "
                "twice the girth times the number of shortest cycles — for instance 120 = "
                "2 x 5 x 12 for the Petersen graph and 72 = 2 x 4 x 9 for the complete "
                "bipartite graph on three plus three vertices."
            ),
            "code": read(A / "demo_girth_multiplicity.py"),
        },
        {
            "name": "Dart Reversal as a Fixed-Point-Free Involution: Why Every "
                    "Non-Backtracking Trace Is Even",
            "description": (
                "This demonstration exhibits the pairing behind the parity theorem "
                "explicitly. For each graph it enumerates the rooted closed "
                "non-backtracking walks of every length up to six, applies the reversal "
                "map that reads the dart list backwards and flips each dart, and verifies "
                "that reversal maps the set of walks to itself, is an involution, and "
                "never fixes a walk — so the walks fall into pairs and the count is even. "
                "It also verifies the algebraic identity behind the combinatorics: "
                "conjugating the Hashimoto matrix by the permutation matrix of dart "
                "reversal produces exactly its transpose."
            ),
            "code": read(A / "demo_parity.py"),
        },
    ],
    "algorithms": [
        {
            "name": "Construction of the Hashimoto Matrix from a Graph's Dart Set",
            "description": (
                "The Hashimoto matrix is indexed by the darts of the graph — the ordered "
                "pairs of adjacent vertices, two per edge — and records the "
                "non-backtracking succession relation: the dart (x, y) may follow the "
                "dart (u, v) precisely when v = x and y is not u. The first clause is "
                "composability, the second forbids the immediate U-turn. Two "
                "constructions are given. The dense construction tests all pairs of "
                "darts and costs O(|D|^2) time and space, where |D| = 2|E|. The sparse "
                "construction groups darts by their tails and emits, for the row of "
                "(u, v), every dart leaving v except (v, u); this costs time "
                "proportional to the sum of squared degrees and produces exactly "
                "sum_v deg(v)^2 - 2|E| nonzeros, which is the row-sum identity "
                "(each row of (u,v) has deg(v) - 1 entries) made computational. For a "
                "(q+1)-regular graph the sparse matrix has 2|E|q nonzeros."
            ),
            "pseudocode": (
                "INPUT: vertex count n, edge list E\n"
                "OUTPUT: dart list D and the matrix B indexed by D\n"
                "\n"
                "1. D <- empty list\n"
                "2. for each edge {u, v} of E (in canonical order):\n"
                "3.     append (u, v) and (v, u) to D\n"
                "4. DENSE:\n"
                "5.     for each d = (u, v) in D:\n"
                "6.         for each e = (x, y) in D:\n"
                "7.             B[d][e] <- 1 if (v = x and y != u) else 0\n"
                "8. SPARSE:\n"
                "9.     out[w] <- list of darts with tail w, for every vertex w\n"
                "10.    for each d = (u, v) in D:\n"
                "11.        succ[d] <- [ e in out[v] : head(e) != u ]     // deg(v) - 1 entries\n"
                "12. return D, B (or D, succ)"
            ),
            "code": read(A / "algo_hashimoto.py"),
        },
        {
            "name": "The Non-Backtracking Trace Sequence and Girth Detection",
            "description": (
                "The trace of the n-th power of the Hashimoto matrix counts rooted closed "
                "non-backtracking walks of length n, so the sequence of traces is a cycle "
                "fingerprint of the graph. The routine computes the whole prefix "
                "trace(B^0), ..., trace(B^N) by propagating, for each starting dart, its "
                "indicator vector forward n steps along the sparse successor lists and "
                "reading off the coefficient of the starting dart; this costs "
                "O(N x nnz(B) x |D|) for the whole prefix and avoids ever forming a dense "
                "power. Girth detection then returns the least n >= 1 with a nonzero "
                "trace. Correctness rests on two facts: a cycle of length m produces a "
                "closed non-backtracking walk of length m, so the trace at the girth is "
                "positive; and a closed non-backtracking walk of length n has distinct "
                "consecutive edges, which forces a cycle of length at most n inside the "
                "subgraph it traverses, so no trace can be nonzero below the girth. A "
                "graph with a cycle has girth at most |V|, so a search that reaches |V| "
                "without a hit certifies that the graph is a forest. A brute-force "
                "enumerator, costing O(|D| q^n) on a (q+1)-regular graph, is included so "
                "that the algebraic and combinatorial sides can be cross-checked."
            ),
            "pseudocode": (
                "INPUT: graph G, bound N\n"
                "OUTPUT: [trace(B^0), ..., trace(B^N)] and the girth\n"
                "\n"
                "1. D <- darts of G;  succ <- sparse successor lists\n"
                "2. traces[0] <- |D|\n"
                "3. for n = 1 to N:\n"
                "4.     total <- 0\n"
                "5.     for each start dart s in D:\n"
                "6.         vec <- indicator vector of s\n"
                "7.         repeat n times:  vec <- vec propagated along succ\n"
                "8.         total <- total + vec[s]\n"
                "9.     traces[n] <- total\n"
                "10. GIRTH:\n"
                "11.    for n = 1 to |V|:\n"
                "12.        if traces[n] != 0 : return n           // n is the girth\n"
                "13.    return FOREST                              // no cycle exists"
            ),
            "code": read(A / "algo_traces_girth.py"),
        },
        {
            "name": "Dihedral Orbit Decomposition of Cyclic Non-Backtracking Words at the "
                    "Girth",
            "description": (
                "Deleting the redundant final entry of a rooted closed non-backtracking "
                "walk yields a cyclic non-backtracking word: a list of darts in which "
                "each is followed by the next and, at the seam, the last is followed by "
                "the first. This set is stable under rotation and under reversal (reading "
                "backwards and flipping every dart), which generate a dihedral group of "
                "order twice the length. A cycle of length m has pairwise distinct darts, "
                "so its orbit has full size 2m: m rotations times two orientations. This "
                "is the combinatorial engine behind the lower bound 2 x girth <= "
                "trace(B^girth). The algorithm enumerates all cyclic words of a given "
                "length, splits them into dihedral orbits, reports the orbit sizes, and "
                "tests whether every word is the dart word of a genuine cycle (equivalent "
                "to its tails being pairwise distinct). Enumeration costs O(|D| q^n) on a "
                "(q+1)-regular graph and the orbit pass adds O(n) per word. Running it at "
                "the girth provides the evidence for the conjectured exact identity "
                "trace(B^girth) = 2 x girth x (number of shortest cycles)."
            ),
            "pseudocode": (
                "INPUT: graph G, length n\n"
                "OUTPUT: orbit statistics of the cyclic non-backtracking words of length n\n"
                "\n"
                "1. W <- all lists (c_1, ..., c_n) of darts with c_i -> c_{i+1} for i < n\n"
                "2.      and c_n -> c_1                              // depth-first search\n"
                "3. pool <- set(W);  orbits <- empty list\n"
                "4. while pool is nonempty:\n"
                "5.     pick w in pool\n"
                "6.     rev <- (reverse of w with every dart flipped)\n"
                "7.     orb <- { rotations of w } union { rotations of rev }\n"
                "8.     orb <- orb intersect pool\n"
                "9.     remove orb from pool;  append orb to orbits\n"
                "10. report |W|, |orbits|, the multiset of orbit sizes,\n"
                "11.        whether every orbit has size 2n,\n"
                "12.        and whether every word has pairwise distinct tails (is a cycle)"
            ),
            "code": read(A / "algo_multiplicity.py"),
        },
    ],
    "visualizations": [
        {
            "name": "The Trace Sequence as a Cycle Fingerprint",
            "description": (
                "Plots n against the trace of the n-th power of the Hashimoto matrix, on "
                "a logarithmic scale, for a family of graphs including complete graphs, "
                "cycles, the complete bipartite graph on three plus three vertices, the "
                "Petersen graph and a path. Each curve is flat at the baseline until the "
                "girth, where a vertical marker is drawn and the value is annotated in "
                "the form twice the girth times the number of shortest cycles; the path, "
                "being a forest, never leaves the baseline. The picture makes visible "
                "both the acyclicity criterion and the girth criterion at once."
            ),
            "code": read(A / "viz_trace_sequences.py"),
        },
        {
            "name": "Spectra of the Hashimoto Matrix and the Circle of Radius sqrt(q)",
            "description": (
                "Scatters the complex eigenvalues of the non-backtracking matrix for four "
                "regular graphs (the complete graph on four vertices, the three-cube, the "
                "Petersen graph and the complete graph on six vertices), overlaying the "
                "circle of radius the square root of the branching factor q and, dashed, "
                "the circle of radius q itself. The Perron eigenvalue sits at q, matching "
                "the row-sum identity and the growth bound trace(B^n) at most 2|E| q^n, "
                "while the bulk of the spectrum clusters on the circle of radius sqrt(q) "
                "— the graph-theoretic analogue of the critical line, and the threshold "
                "defining a Ramanujan graph."
            ),
            "code": read(A / "viz_spectrum.py"),
        },
    ],
    "interactive_demos": [
        {
            "title": "The Non-Backtracking Trace Laboratory",
            "description": (
                "A single self-contained page in which the whole theory can be operated "
                "by hand. Choose a graph from a library (triangle, complete graph on four "
                "vertices, pentagon, hexagon, complete bipartite on three plus three, "
                "Petersen, bowtie, path, star, pentagon-with-chord) or type your own edge "
                "list. The page draws the graph, builds its darts and Hashimoto matrix, "
                "and shows a table of the trace of every power alongside an independent "
                "brute-force enumeration of rooted closed non-backtracking walks, with a "
                "column confirming they agree and a column confirming every value is "
                "even. The first nonzero row is highlighted and matched against a girth "
                "computed by breadth-first search, and a running commentary reports the "
                "number of darts, the triangle count read off from the trace at length "
                "three, the factorisation of the value at the girth as twice the girth "
                "times the number of shortest cycles, and the regular growth bound where "
                "it applies. Pressing play animates a shortest closed non-backtracking "
                "walk one dart at a time, highlighting the current dart in cyan and the "
                "forbidden U-turn in grey, so that the rule generating the whole theory "
                "can literally be watched."
            ),
            "html": read(A / "widget.html"),
        }
    ],
    "interactive_layout": INTERACTIVE_LAYOUT,
    "lean_proofs": lean_proofs,
    "future_directions": FUTURE_DIRECTIONS,
    "modules": {"demo": read(ROOT / "demo.py")},
    "lean_files": LEAN_FILES,
}

out = ROOT / "PACKAGE.json"
out.write_text(json.dumps(package, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
print(f"wrote {out} ({out.stat().st_size} bytes)")


"""
Demo: the first nonzero non-backtracking trace, and what its value counts.

Three statements are exercised on a library of graphs.

  1. Acyclicity.  A forest has trace(B^n) = 0 for every n >= 1.
  2. Girth.  For a graph with a cycle, girth = min { n >= 1 : trace(B^n) != 0 }.
  3. Multiplicity.  The value at that index satisfies 2 * girth <= trace(B^girth), because
     each shortest cycle contributes its girth rotations times its two orientations.  The
     enumeration below decomposes the cyclic non-backtracking words of length girth into
     orbits under rotation and reversal and finds every orbit of full size 2 * girth, with
     one orbit per shortest cycle -- i.e. exactly
         trace(B^girth) = 2 * girth * (number of shortest cycles).

The girth is independently computed by breadth-first search, so the trace-based value is
genuinely cross-checked rather than assumed.
"""

from __future__ import annotations

from itertools import combinations
from typing import Dict, List, Optional, Sequence, Set, Tuple

Dart = Tuple[int, int]
Word = Tuple[Dart, ...]


def darts_of(edges: Sequence[Tuple[int, int]]) -> List[Dart]:
    out: List[Dart] = []
    for u, v in sorted({(min(a, b), max(a, b)) for a, b in edges}):
        out.append((u, v))
        out.append((v, u))
    return out


def may_follow(d: Dart, e: Dart) -> bool:
    return d[1] == e[0] and e[1] != d[0]


def hashimoto(edges: Sequence[Tuple[int, int]]) -> List[List[int]]:
    ds = darts_of(edges)
    return [[1 if may_follow(d, e) else 0 for e in ds] for d in ds]


def mat_mul(a: List[List[int]], b: List[List[int]]) -> List[List[int]]:
    p = len(b[0])
    out = [[0] * p for _ in a]
    for i, row in enumerate(a):
        oi = out[i]
        for k, aik in enumerate(row):
            if aik:
                bk = b[k]
                for j in range(p):
                    oi[j] += aik * bk[j]
    return out


def trace_prefix(edges: Sequence[Tuple[int, int]], nmax: int) -> List[int]:
    b = hashimoto(edges)
    m = len(b)
    power = [[1 if i == j else 0 for j in range(m)] for i in range(m)]
    out = [m]
    for _ in range(nmax):
        power = mat_mul(power, b)
        out.append(sum(power[i][i] for i in range(m)))
    return out


def girth_bfs(n_vertices: int, edges: Sequence[Tuple[int, int]]) -> Optional[int]:
    adj: Dict[int, Set[int]] = {v: set() for v in range(n_vertices)}
    for u, v in edges:
        adj[u].add(v)
        adj[v].add(u)
    best: Optional[int] = None
    for root in range(n_vertices):
        dist = {root: 0}
        par: Dict[int, Optional[int]] = {root: None}
        layer = [root]
        while layer:
            nxt: List[int] = []
            for u in layer:
                for w in adj[u]:
                    if w not in dist:
                        dist[w] = dist[u] + 1
                        par[w] = u
                        nxt.append(w)
                    elif par[u] != w:
                        cand = dist[u] + dist[w] + 1
                        best = cand if best is None else min(best, cand)
            layer = nxt
    return best


def cyclic_nb_words(edges: Sequence[Tuple[int, int]], n: int) -> List[Word]:
    ds = darts_of(edges)
    succ: Dict[Dart, List[Dart]] = {d: [e for e in ds if may_follow(d, e)] for d in ds}
    out: List[Word] = []

    def extend(word: List[Dart]) -> None:
        if len(word) == n:
            if may_follow(word[-1], word[0]):
                out.append(tuple(word))
            return
        for e in succ[word[-1]]:
            word.append(e)
            extend(word)
            word.pop()

    for d in ds:
        extend([d])
    return out


def dihedral_orbits(words: Sequence[Word]) -> List[List[Word]]:
    pool: Set[Word] = set(words)
    orbits: List[List[Word]] = []
    while pool:
        w = next(iter(pool))
        n = len(w)
        rev = tuple((v, u) for (u, v) in reversed(w))
        orb = {w[i:] + w[:i] for i in range(n)} | {rev[i:] + rev[:i] for i in range(n)}
        orb &= pool
        pool -= orb
        orbits.append(sorted(orb))
    return orbits


GRAPHS: List[Tuple[str, int, List[Tuple[int, int]]]] = [
    ("path P5 (tree)", 5, [(0, 1), (1, 2), (2, 3), (3, 4)]),
    ("star K1,4 (tree)", 5, [(0, i) for i in range(1, 5)]),
    ("K3", 3, list(combinations(range(3), 2))),
    ("K4", 4, list(combinations(range(4), 2))),
    ("K5", 5, list(combinations(range(5), 2))),
    ("C5", 5, [(i, (i + 1) % 5) for i in range(5)]),
    ("C7", 7, [(i, (i + 1) % 7) for i in range(7)]),
    ("K3,3", 6, [(i, 3 + j) for i in range(3) for j in range(3)]),
    ("cube Q3", 8, [(u, u ^ (1 << b)) for u in range(8) for b in range(3)
                    if u < (u ^ (1 << b))]),
    ("Petersen", 10,
     [(i, (i + 1) % 5) for i in range(5)]
     + [(5 + i, 5 + (i + 2) % 5) for i in range(5)]
     + [(i, 5 + i) for i in range(5)]),
]


def main() -> None:
    print(f"{'graph':18s}{'girth(BFS)':>11s}{'first n':>9s}{'trace':>8s}"
          f"{'orbits':>8s}{'2g*orbits':>11s}  verdict")
    print("-" * 78)
    for name, nv, edges in GRAPHS:
        g_bfs = girth_bfs(nv, edges)
        seq = trace_prefix(edges, min(nv, 8))
        first = next((n for n in range(1, len(seq)) if seq[n] != 0), None)
        if g_bfs is None:
            assert all(t == 0 for t in seq[1:])
            print(f"{name:18s}{'inf':>11s}{'none':>9s}{'0':>8s}{'-':>8s}{'-':>11s}"
                  f"  forest: the whole sequence vanishes")
            continue
        assert first == g_bfs, (name, first, g_bfs)
        words = cyclic_nb_words(edges, g_bfs)
        orbits = dihedral_orbits(words)
        pred = 2 * g_bfs * len(orbits)
        full = all(len(o) == 2 * g_bfs for o in orbits)
        assert len(words) == seq[g_bfs] and pred == seq[g_bfs] and full
        print(f"{name:18s}{g_bfs:>11d}{first:>9d}{seq[g_bfs]:>8d}{len(orbits):>8d}"
              f"{pred:>11d}  girth criterion OK; every orbit has full size 2g")
    print("-" * 78)
    print("All assertions passed: the trace sequence vanishes exactly on forests, its first")
    print("nonzero index is the girth, and its value there is 2*girth*(#shortest cycles).")


if __name__ == "__main__":
    main()


"""
Demo: why every non-backtracking trace is even.

Reversing a rooted closed non-backtracking walk -- reading its darts backwards and
flipping each arrow -- produces another rooted closed non-backtracking walk of the same
length.  Doing it twice returns the original, so reversal is an involution; and it never
fixes a walk, because a fixed walk would need its first dart to equal its own reversal,
which is impossible in a loopless graph.  A fixed-point-free involution partitions a
finite set into pairs, so the number of walks -- that is, trace(B^n) -- is even.

This script exhibits the pairing explicitly and also verifies its algebraic shadow:
if J is the permutation matrix of dart reversal, then J B J = B transpose.
"""

from __future__ import annotations

from itertools import combinations
from typing import Dict, List, Sequence, Tuple

Dart = Tuple[int, int]
Walk = Tuple[Dart, ...]


def darts_of(edges: Sequence[Tuple[int, int]]) -> List[Dart]:
    out: List[Dart] = []
    for u, v in sorted({(min(a, b), max(a, b)) for a, b in edges}):
        out.append((u, v))
        out.append((v, u))
    return out


def may_follow(d: Dart, e: Dart) -> bool:
    return d[1] == e[0] and e[1] != d[0]


def closed_nb_walks(edges: Sequence[Tuple[int, int]], n: int) -> List[Walk]:
    ds = darts_of(edges)
    if n == 0:
        return [(d,) for d in ds]
    succ: Dict[Dart, List[Dart]] = {d: [e for e in ds if may_follow(d, e)] for d in ds}
    out: List[Walk] = []

    def extend(path: List[Dart]) -> None:
        if len(path) == n + 1:
            if path[0] == path[-1]:
                out.append(tuple(path))
            return
        for e in succ[path[-1]]:
            path.append(e)
            extend(path)
            path.pop()

    for d in ds:
        extend([d])
    return out


def reverse_walk(w: Walk) -> Walk:
    return tuple((v, u) for (u, v) in reversed(w))


def check_JBJ(edges: Sequence[Tuple[int, int]]) -> bool:
    """Verify J B J = B^T entrywise, i.e. B[d^{-1}, e^{-1}] = B[e, d]."""
    ds = darts_of(edges)
    idx: Dict[Dart, int] = {d: i for i, d in enumerate(ds)}
    b = [[1 if may_follow(d, e) else 0 for e in ds] for d in ds]
    for d in ds:
        for e in ds:
            lhs = b[idx[(d[1], d[0])]][idx[(e[1], e[0])]]
            rhs = b[idx[e]][idx[d]]
            if lhs != rhs:
                return False
    return True


GRAPHS: List[Tuple[str, List[Tuple[int, int]]]] = [
    ("K4", list(combinations(range(4), 2))),
    ("C5", [(i, (i + 1) % 5) for i in range(5)]),
    ("bowtie", [(0, 1), (1, 2), (2, 0), (2, 3), (3, 4), (4, 2)]),
]


def main() -> None:
    for name, edges in GRAPHS:
        print("=" * 66)
        print(f"{name}:  J B J = B^T ?  {check_JBJ(edges)}")
        for n in range(1, 7):
            walks = closed_nb_walks(edges, n)
            s = set(walks)
            stable = all(reverse_walk(w) in s for w in walks)
            free = all(reverse_walk(w) != w for w in walks)
            pairs = len(walks) // 2
            print(f"  n = {n}: trace = {len(walks):5d}  "
                  f"reversal stays inside: {stable}  no fixed point: {free}  "
                  f"-> {pairs} pairs, even: {len(walks) % 2 == 0}")
            assert stable and free and len(walks) % 2 == 0
        walks = closed_nb_walks(edges, 4)
        if walks:
            w = walks[0]
            print("  a paired example at n = 4:")
            print("     ", " ".join(f"({a}->{b})" for a, b in w))
            print("     ", " ".join(f"({a}->{b})" for a, b in reverse_walk(w)))
    print("=" * 66)
    print("Every trace inspected is even, and dart reversal conjugates B into B^T.")


if __name__ == "__main__":
    main()


"""
Visualization: the spectrum of the Hashimoto matrix in the complex plane.

For a (q+1)-regular graph the eigenvalues of the non-backtracking matrix B split into a
trivial part (the values +/- 1 and the two Perron values +/- q coming from the constant
vectors) and a bulk that, for a Ramanujan graph, lies exactly on the circle of radius
sqrt(q).  The circle of radius sqrt(q) drawn here is the graph-theoretic analogue of the
critical line: the branching factor q of the non-backtracking walk is the same q that
appears in the row-sum identity  sum_e B[d,e] = deg(head d) - 1  and in the growth bound
trace(B^n) <= |darts| * q^n, which is drawn as a dashed reference circle of radius q.

Run:  python viz_spectrum.py       (writes nb_spectrum.png)
"""

from __future__ import annotations

from itertools import combinations
from typing import List, Sequence, Tuple

import matplotlib.pyplot as plt
import numpy as np

Dart = Tuple[int, int]


def darts_of(edges: Sequence[Tuple[int, int]]) -> List[Dart]:
    out: List[Dart] = []
    for u, v in edges:
        out.append((u, v))
        out.append((v, u))
    return out


def hashimoto(edges: Sequence[Tuple[int, int]]) -> np.ndarray:
    ds = darts_of(edges)
    m = len(ds)
    b = np.zeros((m, m))
    for i, (u, v) in enumerate(ds):
        for j, (x, y) in enumerate(ds):
            if v == x and y != u:
                b[i, j] = 1.0
    return b


def petersen() -> List[Tuple[int, int]]:
    return ([(i, (i + 1) % 5) for i in range(5)]
            + [(5 + i, 5 + (i + 2) % 5) for i in range(5)]
            + [(i, 5 + i) for i in range(5)])


def cube_graph() -> List[Tuple[int, int]]:
    """The 3-cube Q3: vertices are 0..7, adjacent when they differ in one bit."""
    return [(u, u ^ (1 << b)) for u in range(8) for b in range(3) if u < (u ^ (1 << b))]


GRAPHS: List[Tuple[str, int, List[Tuple[int, int]]]] = [
    ("K₄  (q = 2)", 2, list(combinations(range(4), 2))),
    ("Q₃, the cube  (q = 2)", 2, cube_graph()),
    ("Petersen  (q = 2)", 2, petersen()),
    ("K₆  (q = 4)", 4, list(combinations(range(6), 2))),
]


def main() -> None:
    fig, axes = plt.subplots(1, 4, figsize=(16, 4.3))
    for ax, (name, q, edges) in zip(axes, GRAPHS):
        b = hashimoto(edges)
        ev = np.linalg.eigvals(b)
        theta = np.linspace(0, 2 * np.pi, 400)
        ax.plot(np.sqrt(q) * np.cos(theta), np.sqrt(q) * np.sin(theta),
                color="#ff9f43", lw=1.6, label=r"$|z|=\sqrt{q}$")
        ax.plot(q * np.cos(theta), q * np.sin(theta),
                color="#576574", lw=1.0, ls="--", label=r"$|z|=q$")
        ax.scatter(ev.real, ev.imag, s=26, color="#0abde3",
                   edgecolor="#0c2461", linewidth=0.4, zorder=3)
        ax.axhline(0, color="#dfe4ea", lw=0.6)
        ax.axvline(0, color="#dfe4ea", lw=0.6)
        ax.set_aspect("equal")
        ax.set_title(f"{name}\n{b.shape[0]} darts", fontsize=10)
        ax.grid(alpha=0.2)
        lim = q + 0.6
        ax.set_xlim(-lim, lim)
        ax.set_ylim(-lim, lim)
        ax.legend(fontsize=7, loc="lower left", frameon=False)

    fig.suptitle("Spectra of the non-backtracking matrix: the bulk sits on the circle of "
                 r"radius $\sqrt{q}$, the Perron eigenvalue at $q$", fontsize=12)
    fig.tight_layout()
    fig.savefig("nb_spectrum.png", dpi=160)
    print("wrote nb_spectrum.png")


if __name__ == "__main__":
    main()


"""
Visualization: the non-backtracking trace sequence as a cycle fingerprint.

For a family of graphs we plot n |-> trace(B^n) on a logarithmic scale, marking the
girth (the first index at which the sequence becomes nonzero) with a vertical line and
annotating the value there as 2 * girth * (number of shortest cycles).  Forests give an
identically zero sequence and are shown as a flat baseline, illustrating the acyclicity
criterion.

Run:  python viz_trace_sequences.py       (writes trace_sequences.png)
"""

from __future__ import annotations

from itertools import combinations
from typing import Dict, List, Optional, Sequence, Set, Tuple

import matplotlib.pyplot as plt

Dart = Tuple[int, int]


def darts_of(n: int, edges: Sequence[Tuple[int, int]]) -> List[Dart]:
    out: List[Dart] = []
    for u, v in edges:
        out.append((u, v))
        out.append((v, u))
    return out


def may_follow(d: Dart, e: Dart) -> bool:
    return d[1] == e[0] and e[1] != d[0]


def hashimoto(n: int, edges: Sequence[Tuple[int, int]]) -> List[List[int]]:
    ds = darts_of(n, edges)
    return [[1 if may_follow(d, e) else 0 for e in ds] for d in ds]


def mat_mul(a: List[List[int]], b: List[List[int]]) -> List[List[int]]:
    p = len(b[0])
    out = [[0] * p for _ in a]
    for i, row in enumerate(a):
        oi = out[i]
        for k, aik in enumerate(row):
            if aik:
                bk = b[k]
                for j in range(p):
                    oi[j] += aik * bk[j]
    return out


def trace_sequence(n: int, edges: Sequence[Tuple[int, int]], nmax: int) -> List[int]:
    b = hashimoto(n, edges)
    size = len(b)
    power = [[1 if i == j else 0 for j in range(size)] for i in range(size)]
    out = [size]
    for _ in range(nmax):
        power = mat_mul(power, b)
        out.append(sum(power[i][i] for i in range(size)))
    return out


def girth_bfs(n: int, edges: Sequence[Tuple[int, int]]) -> Optional[int]:
    adj: Dict[int, Set[int]] = {v: set() for v in range(n)}
    for u, v in edges:
        adj[u].add(v)
        adj[v].add(u)
    best: Optional[int] = None
    for root in range(n):
        dist = {root: 0}
        par: Dict[int, Optional[int]] = {root: None}
        layer = [root]
        while layer:
            nxt: List[int] = []
            for u in layer:
                for w in adj[u]:
                    if w not in dist:
                        dist[w] = dist[u] + 1
                        par[w] = u
                        nxt.append(w)
                    elif par[u] != w:
                        cand = dist[u] + dist[w] + 1
                        best = cand if best is None else min(best, cand)
            layer = nxt
    return best


GRAPHS: List[Tuple[str, int, List[Tuple[int, int]]]] = [
    ("K4", 4, list(combinations(range(4), 2))),
    ("C5", 5, [(i, (i + 1) % 5) for i in range(5)]),
    ("C7", 7, [(i, (i + 1) % 7) for i in range(7)]),
    ("K3,3", 6, [(i, 3 + j) for i in range(3) for j in range(3)]),
    ("Petersen", 10,
     [(i, (i + 1) % 5) for i in range(5)]
     + [(5 + i, 5 + (i + 2) % 5) for i in range(5)]
     + [(i, 5 + i) for i in range(5)]),
    ("path P6 (tree)", 6, [(i, i + 1) for i in range(5)]),
]


def main() -> None:
    nmax = 9
    fig, ax = plt.subplots(figsize=(10.5, 6.2))
    colours = plt.cm.viridis([0.05, 0.25, 0.42, 0.6, 0.78, 0.93])

    for (name, n, edges), colour in zip(GRAPHS, colours):
        seq = trace_sequence(n, edges, nmax)
        xs = list(range(1, nmax + 1))
        ys = [max(seq[k], 0.4) for k in xs]  # 0.4 stands in for 0 on a log axis
        ax.plot(xs, ys, "o-", color=colour, lw=2, ms=6, label=name)
        g = girth_bfs(n, edges)
        if g is not None and g <= nmax:
            ax.axvline(g, color=colour, ls=":", lw=1.1, alpha=0.55)
            mult = seq[g] // (2 * g)
            ax.annotate(f"{name}: girth {g}\ntrace = 2·{g}·{mult} = {seq[g]}",
                        xy=(g, seq[g]), xytext=(g + 0.18, seq[g] * 1.5),
                        fontsize=8, color=colour)

    ax.set_yscale("log")
    ax.set_xlabel("n")
    ax.set_ylabel("trace(Bⁿ)   (0 plotted at the baseline)")
    ax.set_title("The non-backtracking trace sequence is a cycle fingerprint\n"
                 "zero below the girth, equal to 2·girth·(number of shortest cycles) at it")
    ax.grid(alpha=0.25, which="both")
    ax.legend(frameon=False, ncol=3, fontsize=9)
    fig.tight_layout()
    fig.savefig("trace_sequences.png", dpi=160)
    print("wrote trace_sequences.png")


if __name__ == "__main__":
    main()
