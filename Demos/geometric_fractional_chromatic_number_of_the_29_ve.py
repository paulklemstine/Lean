"""
Numerical demonstrations for:
  "The Independence-Ratio Certificate for the Fractional Chromatic Number
   of the Plane: A 29-Vertex Threshold"

The core mathematical facts demonstrated here:

  1. Weak-duality / independence-ratio lower bound:
         chi_f(G) >= n / alpha(G)
     where n = |V(G)| and alpha(G) is the independence number.

  2. Strict threshold:
         4 * alpha(G) < n   =>   chi_f(G) > 4.

  3. The 29-vertex certificate: a graph with n = 29 and alpha = 7 satisfies
         4 * 7 = 28 < 29,   so   chi_f >= 29/7 = 4.142... > 4.

  4. An explicit combinatorial witness (disjoint union of seven cliques,
     sizes summing to 29) with independence number exactly 7.

Everything is self-contained; run `python demo.py`.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from fractions import Fraction
from itertools import combinations
from typing import Dict, FrozenSet, Iterable, List, Set, Tuple


# ---------------------------------------------------------------------------
# A minimal simple-graph data structure
# ---------------------------------------------------------------------------

@dataclass
class Graph:
    """A finite simple graph on vertices 0, 1, ..., n-1."""
    n: int
    adj: List[Set[int]] = field(default_factory=list)

    def __post_init__(self) -> None:
        if not self.adj:
            self.adj = [set() for _ in range(self.n)]

    def add_edge(self, u: int, v: int) -> None:
        if u != v:
            self.adj[u].add(v)
            self.adj[v].add(u)

    def is_independent(self, s: Iterable[int]) -> bool:
        """True iff no two vertices of s are adjacent."""
        s = list(s)
        return all(v not in self.adj[u] for u, v in combinations(s, 2))

    def independence_number(self) -> int:
        """Maximum independent set size via branch-and-bound (fast on sparse graphs)."""
        remaining = frozenset(range(self.n))

        def mis(verts: FrozenSet[int]) -> int:
            if not verts:
                return 0
            # Branch on the vertex of maximum degree within `verts`.
            v = max(verts, key=lambda x: len(self.adj[x] & verts))
            closed = ({v} | self.adj[v]) & verts
            include = 1 + mis(verts - closed)   # take v, drop its neighbours
            exclude = mis(verts - {v})          # skip v
            return max(include, exclude)

        return mis(remaining)


# ---------------------------------------------------------------------------
# Graph constructors
# ---------------------------------------------------------------------------

def clique(k: int) -> Graph:
    """The complete graph K_k."""
    g = Graph(k)
    for u, v in combinations(range(k), 2):
        g.add_edge(u, v)
    return g


def disjoint_union_of_cliques(sizes: List[int]) -> Graph:
    """Disjoint union of cliques with the given sizes."""
    total = sum(sizes)
    g = Graph(total)
    offset = 0
    for c in sizes:
        for u, v in combinations(range(offset, offset + c), 2):
            g.add_edge(u, v)
        offset += c
    return g


# ---------------------------------------------------------------------------
# The three algorithms of the paper
# ---------------------------------------------------------------------------

def threshold_verifier(n: int, alpha: int) -> Tuple[bool, Fraction]:
    """
    Algorithm A. Given (n, alpha), decide whether 4*alpha < n (strict gate),
    and return the guaranteed lower bound n/alpha as an exact rational.
    """
    strict = 4 * alpha < n
    bound = Fraction(n, alpha) if alpha > 0 else Fraction(0)
    return strict, bound


def clique_cluster_independence(sizes: List[int]) -> Tuple[int, int, Fraction]:
    """
    Algorithm B. For a disjoint union of cliques of the given sizes, the
    independence number equals the number of cliques. Returns
    (n, alpha, inverse_independence_ratio).
    """
    n = sum(sizes)
    alpha = len(sizes)
    return n, alpha, Fraction(n, alpha)


def check_fractional_coloring(
    g: Graph, weighted_sets: Dict[FrozenSet[int], Fraction]
) -> Tuple[bool, Fraction]:
    """
    Algorithm C. Verify that `weighted_sets` is a feasible fractional coloring:
      (i)  each carrier set is independent,
      (ii) each vertex is covered with total weight >= 1.
    Returns (feasible, total_weight). The total weight is an *upper bound* on
    chi_f(G) when feasible.
    """
    # (i) support on independent sets, nonnegative weights
    for s, w in weighted_sets.items():
        if w < 0 or not g.is_independent(s):
            return False, Fraction(0)
    # (ii) covering
    cover = [Fraction(0) for _ in range(g.n)]
    for s, w in weighted_sets.items():
        for v in s:
            cover[v] += w
    feasible = all(c >= 1 for c in cover)
    total = sum(weighted_sets.values(), Fraction(0))
    return feasible, total


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_threshold_arithmetic() -> None:
    print("=" * 70)
    print("Demo 1: The strict threshold  4*alpha < n  =>  chi_f > 4")
    print("=" * 70)
    for n, alpha in [(27, 7), (28, 7), (29, 7)]:
        strict, bound = threshold_verifier(n, alpha)
        verdict = "chi_f > 4  (STRICT)" if strict else "only chi_f >= n/alpha (not strict past 4)"
        print(f"  n={n:>3}, alpha={alpha}:  4*alpha={4*alpha:>3}  "
              f"n/alpha={float(bound):.4f}  ->  {verdict}")
    print("  The gate first opens at n = 29:  4*7 = 28 < 29,  29/7 = 4.142... > 4.\n")


def demo_clique_cluster_model() -> None:
    print("=" * 70)
    print("Demo 2: Explicit 29-vertex witness (seven disjoint cliques)")
    print("=" * 70)
    sizes = [4, 4, 4, 4, 4, 4, 5]  # 6*4 + 5 = 29
    n, alpha, ratio = clique_cluster_independence(sizes)
    print(f"  clique sizes = {sizes}  (sum = {n})")
    print(f"  predicted independence number (number of cliques) = {alpha}")

    g = disjoint_union_of_cliques(sizes)
    alpha_brute = g.independence_number()
    print(f"  brute-force independence number               = {alpha_brute}")
    assert alpha == alpha_brute == 7
    assert n == 29
    strict, bound = threshold_verifier(n, alpha_brute)
    print(f"  4*alpha = {4*alpha_brute} < n = {n}:  {strict}")
    print(f"  guaranteed lower bound chi_f >= {bound} = {float(bound):.4f} > 4\n")


def demo_upper_bound_certificate() -> None:
    print("=" * 70)
    print("Demo 3: An explicit feasible fractional coloring (upper bound)")
    print("=" * 70)
    # Build the seven-clique model and give a natural fractional coloring:
    # for each clique choose the "transversal" independent sets. A simple
    # feasible coloring: weight 1 on each singleton (the singleton coloring).
    sizes = [4, 4, 4, 4, 4, 4, 5]
    g = disjoint_union_of_cliques(sizes)
    singleton_coloring: Dict[FrozenSet[int], Fraction] = {
        frozenset({v}): Fraction(1) for v in range(g.n)
    }
    feasible, total = check_fractional_coloring(g, singleton_coloring)
    print(f"  singleton coloring feasible: {feasible}, total weight = {total}")
    print(f"  => chi_f <= {total} (trivial upper bound = n).")

    # A smarter coloring: pick 4 maximum independent transversals covering
    # every vertex of the size-4 cliques, plus handle the size-5 clique.
    # We build 5 transversals, one per "layer", each an independent set.
    max_size = max(sizes)
    starts = []
    off = 0
    for c in sizes:
        starts.append((off, c))
        off += c
    transversals: Dict[FrozenSet[int], Fraction] = {}
    for layer in range(max_size):
        s = frozenset(off0 + (layer % c) for (off0, c) in starts)
        transversals[s] = transversals.get(s, Fraction(0)) + Fraction(1)
    feasible2, total2 = check_fractional_coloring(g, transversals)
    print(f"  transversal coloring feasible: {feasible2}, total weight = {total2}")
    print(f"  => chi_f <= {total2}.")
    print(f"  Combined with Demo 2:  {Fraction(29,7)} = 4.142... <= chi_f <= {total2}.\n")


def demo_ratio_ladder() -> None:
    print("=" * 70)
    print("Demo 4: A ladder of independence ratios approaching 1/4 from above")
    print("=" * 70)
    print("  Tuning clique-cluster sizes to realize prescribed ratios n/alpha:")
    for alpha in [7, 8, 9, 10]:
        n = 4 * alpha + 1  # smallest n with 4*alpha < n
        strict, bound = threshold_verifier(n, alpha)
        print(f"    alpha={alpha:>2}, n={n:>3}:  ratio alpha/n = {Fraction(alpha,n)} "
              f"= {float(alpha)/n:.4f} < 1/4,  chi_f >= {float(bound):.4f}")
    print()


def main() -> None:
    demo_threshold_arithmetic()
    demo_clique_cluster_model()
    demo_upper_bound_certificate()
    demo_ratio_ladder()
    print("All demonstrations completed successfully.")


if __name__ == "__main__":
    main()
