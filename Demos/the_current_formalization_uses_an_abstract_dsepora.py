"""Concrete d-Separation via Reachability — numerical demonstrations.

This self-contained script realizes, in plain Python, the combinatorial model
proved correct in the accompanying formalization:

    * an UndirectedGraph as a symmetric adjacency relation on {0, ..., n-1};
    * Z-avoiding reachability (a walk that never steps on the conditioning set Z);
    * separation  A ⊥ B | Z  :=  no vertex of A reaches any vertex of B avoiding Z.

It then *checks*, on concrete finite graphs, the five laws that the formalization
proves in general:

    symmetry, decomposition, weak union, contraction, composition,

and exhibits the classic probabilistic counterexample (parity of two coins) that
shows composition FAILS for generic probabilistic independence — the law that
graph separation, by contrast, always satisfies.

Run:  python demo.py
"""

from __future__ import annotations

from itertools import product
from typing import Dict, FrozenSet, Iterable, List, Set, Tuple

Vertex = int
VertexSet = FrozenSet[Vertex]


# --------------------------------------------------------------------------- #
# §1. Undirected graphs and Z-avoiding reachability                            #
# --------------------------------------------------------------------------- #
class UndirectedGraph:
    """A finite undirected graph: a symmetric adjacency relation on range(n)."""

    def __init__(self, n: int, edges: Iterable[Tuple[Vertex, Vertex]]) -> None:
        self.n: int = n
        self.adj: Dict[Vertex, Set[Vertex]] = {v: set() for v in range(n)}
        for (x, y) in edges:
            self.adj[x].add(y)
            self.adj[y].add(x)  # symmetry: undirected edges go both ways

    def step_z(self, x: Vertex, y: Vertex, z: VertexSet) -> bool:
        """One Z-avoiding step: an edge whose *both* endpoints lie outside Z."""
        return (y in self.adj[x]) and (x not in z) and (y not in z)

    def conn_avoid(self, u: Vertex, v: Vertex, z: VertexSet) -> bool:
        """Z-avoiding reachability: a walk u -> ... -> v never touching Z.

        This is the reflexive-transitive closure of step_z, computed by BFS on
        the graph with the vertices of Z deleted.
        """
        if u in z or v in z:
            # A walk must start and end outside Z (empty walk needs u == v ∉ Z).
            return u == v and u not in z
        if u == v:
            return True
        seen: Set[Vertex] = {u}
        frontier: List[Vertex] = [u]
        while frontier:
            x = frontier.pop()
            for y in self.adj[x]:
                if y not in z and y not in seen:
                    if y == v:
                        return True
                    seen.add(y)
                    frontier.append(y)
        return False

    def separated(self, a: VertexSet, b: VertexSet, z: VertexSet) -> bool:
        """A ⊥ B | Z : no a in A reaches any b in B while avoiding Z."""
        return all(
            not self.conn_avoid(a_, b_, z) for a_ in a for b_ in b
        )


def fs(*xs: Vertex) -> VertexSet:
    """Convenience constructor for a frozenset of vertices."""
    return frozenset(xs)


# --------------------------------------------------------------------------- #
# §2. Exhaustive verification of the graphoid axioms on a fixed graph          #
# --------------------------------------------------------------------------- #
def all_disjoint_triples(
    n: int,
) -> Iterable[Tuple[VertexSet, VertexSet, VertexSet, VertexSet]]:
    """Yield (A, B, W, Z): pairwise-disjoint subsets of range(n).

    Each vertex is assigned to exactly one of {A, B, W, Z, none}.
    """
    for labels in product(range(5), repeat=n):
        a = fs(*[v for v in range(n) if labels[v] == 0])
        b = fs(*[v for v in range(n) if labels[v] == 1])
        w = fs(*[v for v in range(n) if labels[v] == 2])
        z = fs(*[v for v in range(n) if labels[v] == 3])
        yield a, b, w, z


def check_axioms(g: UndirectedGraph) -> Dict[str, int]:
    """Exhaustively verify all five axioms over pairwise-disjoint triples.

    Returns a dict mapping axiom name -> number of (vacuous or genuine)
    instances confirmed. A single failure raises AssertionError.
    """
    counts = {k: 0 for k in
              ("symmetry", "decomposition", "weak_union",
               "contraction", "composition")}
    sep = g.separated
    for a, b, w, z in all_disjoint_triples(g.n):
        bw = b | w
        zw = z | w
        zb = z | b

        # Symmetry: A ⊥ B | Z  ->  B ⊥ A | Z
        if sep(a, b, z):
            assert sep(b, a, z), "symmetry violated"
            counts["symmetry"] += 1

        # Decomposition: A ⊥ (B ∪ W) | Z  ->  A ⊥ B | Z
        if sep(a, bw, z):
            assert sep(a, b, z), "decomposition violated"
            counts["decomposition"] += 1

        # Weak union: A ⊥ (B ∪ W) | Z  ->  A ⊥ B | (Z ∪ W)
        if sep(a, bw, z):
            assert sep(a, b, zw), "weak union violated"
            counts["weak_union"] += 1

        # Contraction: A ⊥ B | Z  ∧  A ⊥ W | (Z ∪ B)  ->  A ⊥ (B ∪ W) | Z
        if sep(a, b, z) and sep(a, w, zb):
            assert sep(a, bw, z), "contraction violated"
            counts["contraction"] += 1

        # Composition: A ⊥ B | Z  ∧  A ⊥ W | Z  ->  A ⊥ (B ∪ W) | Z
        if sep(a, b, z) and sep(a, w, z):
            assert sep(a, bw, z), "composition violated"
            counts["composition"] += 1
    return counts


# --------------------------------------------------------------------------- #
# §3. The first-hitting decomposition (engine of contraction)                  #
# --------------------------------------------------------------------------- #
def first_hit(
    walk: List[Vertex], predicate
) -> Tuple[str, List[Vertex], Tuple[Vertex, Vertex] | None]:
    """Constructive content of Lemma 4.1 (first-hitting decomposition).

    Given a walk (list of vertices) whose first vertex satisfies ¬predicate,
    return either:
        ("avoid", walk, None)               -- predicate never fires; or
        ("hit", prefix, (w_prime, w))       -- prefix is predicate-free, then
                                               the edge (w_prime, w) enters the
                                               first predicate-vertex w.
    """
    assert walk and not predicate(walk[0]), "walk must start at a ¬P vertex"
    prefix: List[Vertex] = [walk[0]]
    for i in range(1, len(walk)):
        if predicate(walk[i]):
            return "hit", prefix, (walk[i - 1], walk[i])
        prefix.append(walk[i])
    return "avoid", walk, None


# --------------------------------------------------------------------------- #
# §4. Composition fails for probability: the parity (XOR) counterexample        #
# --------------------------------------------------------------------------- #
def prob_independent(
    joint: Dict[Tuple[int, ...], float], xs: Tuple[int, ...],
    ys: Tuple[int, ...]
) -> bool:
    """Test marginal independence of variable-index sets xs and ys under `joint`.

    `joint` maps a full assignment (tuple over all variables) to a probability.
    Variables are addressed by index into the assignment tuple.
    """
    def marg(idxs: Tuple[int, ...]) -> Dict[Tuple[int, ...], float]:
        out: Dict[Tuple[int, ...], float] = {}
        for assign, p in joint.items():
            key = tuple(assign[i] for i in idxs)
            out[key] = out.get(key, 0.0) + p
        return out

    pxy = marg(xs + ys)
    px = marg(xs)
    py = marg(ys)
    for assign, p in joint.items():
        kx = tuple(assign[i] for i in xs)
        ky = tuple(assign[i] for i in ys)
        if abs(pxy.get(kx + ky, 0.0) - px[kx] * py[ky]) > 1e-12:
            return False
    return True


def parity_counterexample() -> Dict[str, bool]:
    """Variables (A, B, W) with A = B XOR W, B and W independent fair bits.

    Shows  A ⊥ B  and  A ⊥ W  but NOT  A ⊥ (B, W).
    """
    # assignment order: (A, B, W)
    joint: Dict[Tuple[int, ...], float] = {}
    for b in (0, 1):
        for w in (0, 1):
            a = b ^ w
            joint[(a, b, w)] = 0.25
    A, B, W = (0,), (1,), (2,)
    return {
        "A ⊥ B": prob_independent(joint, A, B),
        "A ⊥ W": prob_independent(joint, A, W),
        "A ⊥ (B,W)": prob_independent(joint, A, (1, 2)),
    }


# --------------------------------------------------------------------------- #
# §5. Driver                                                                    #
# --------------------------------------------------------------------------- #
def main() -> None:
    print("=" * 70)
    print("Concrete d-Separation via Reachability — demonstrations")
    print("=" * 70)

    # A path graph 0 - 1 - 2 - 3 - 4. Deleting any interior vertex separates.
    path = UndirectedGraph(5, [(0, 1), (1, 2), (2, 3), (3, 4)])
    print("\n[1] Path graph 0-1-2-3-4")
    print("    0 ⊥ 4 | {}      :", path.separated(fs(0), fs(4), fs()))          # False
    print("    0 ⊥ 4 | {2}     :", path.separated(fs(0), fs(4), fs(2)))         # True
    print("    {0} ⊥ {3,4} | {2}:", path.separated(fs(0), fs(3, 4), fs(2)))    # True

    # Exhaustive axiom verification on a richer graph (a 5-cycle with a chord).
    cyc = UndirectedGraph(5, [(0, 1), (1, 2), (2, 3), (3, 4), (4, 0), (0, 2)])
    print("\n[2] Exhaustive axiom check on a 5-cycle + chord (0-2)")
    counts = check_axioms(cyc)
    for name, c in counts.items():
        print(f"    {name:<14}: PASSED  ({c} instances confirmed)")

    # First-hitting decomposition on a sample walk, predicate 'in B = {2,3}'.
    print("\n[3] First-hitting decomposition  (P = membership in {2,3})")
    walk = [0, 1, 2, 3, 4]
    kind, prefix, edge = first_hit(walk, lambda v: v in {2, 3})
    print(f"    walk      = {walk}")
    print(f"    result    = {kind}")
    print(f"    P-free prefix = {prefix},  entering edge = {edge}")

    walk2 = [0, 1, 4]  # never hits {2,3}
    kind2, prefix2, edge2 = first_hit(walk2, lambda v: v in {2, 3})
    print(f"    walk      = {walk2}")
    print(f"    result    = {kind2}  (avoids P entirely)")

    # Composition holds for graphs but fails for probability.
    print("\n[4] Composition: graphs vs. probability")
    print("    Graph (path 0-1-2-3-4), A={0}, B={3}, W={4}, Z={2}:")
    A, B, W, Z = fs(0), fs(3), fs(4), fs(2)
    g_ab = path.separated(A, B, Z)
    g_aw = path.separated(A, W, Z)
    g_abw = path.separated(A, B | W, Z)
    print(f"        A ⊥ B | Z = {g_ab},  A ⊥ W | Z = {g_aw}"
          f"  =>  A ⊥ (B∪W) | Z = {g_abw}   (composition HOLDS)")
    print("    Probability (A = B XOR W, fair independent bits):")
    res = parity_counterexample()
    for k, v in res.items():
        print(f"        {k:<10} = {v}")
    print("        => A ⊥ B and A ⊥ W, but NOT A ⊥ (B,W): composition FAILS.")

    print("\nAll demonstrations completed successfully.")


if __name__ == "__main__":
    main()
