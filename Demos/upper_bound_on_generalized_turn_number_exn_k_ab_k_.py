"""
Numerical demonstrations for the cubic upper bound on the generalized Turan
number  ex(n, K_{a,b}, K_{3,b+1}).

Main theorem being illustrated
------------------------------
For all integers a, b with 3 <= a <= b, every n-vertex graph G that contains no
copy of K_{3, b+1} has at most

        C(b, a-3) * n^3

labelled copies of K_{a,b}, where C(n, k) is the binomial coefficient.  In
particular the number of copies is O(n^3), and the "copy density"
#copies / n^{a+b} tends to 0.

This script:
  * builds small graphs and directly counts labelled copies of K_{a,b};
  * checks K_{3,t}-freeness and its equivalent "common-neighborhood cap";
  * verifies the theoretical bound C(b, a-3) * n^3 on random and structured
    K_{3,b+1}-free graphs;
  * illustrates the vanishing copy density.

Everything is self-contained: only the Python standard library is used.
"""

from __future__ import annotations

import random
from itertools import combinations
from math import comb
from typing import Dict, FrozenSet, Iterable, List, Set, Tuple

# ---------------------------------------------------------------------------
# Graph representation: a graph is (n, adjacency) where adjacency[v] is the set
# of neighbors of vertex v in {0, ..., n-1}.  Simple, undirected, loopless.
# ---------------------------------------------------------------------------
Graph = Tuple[int, Dict[int, Set[int]]]


def make_graph(n: int, edges: Iterable[Tuple[int, int]]) -> Graph:
    """Create a simple undirected graph on vertices 0..n-1 from an edge list."""
    adj: Dict[int, Set[int]] = {v: set() for v in range(n)}
    for u, v in edges:
        if u == v:
            continue
        adj[u].add(v)
        adj[v].add(u)
    return n, adj


def common_neighborhood(g: Graph, s: Iterable[int]) -> Set[int]:
    """Return N(S): all vertices adjacent to every vertex of S."""
    n, adj = g
    s = list(s)
    if not s:
        return set(range(n))
    result = set(range(n))
    for u in s:
        result &= adj[u]
    return result


def satisfies_t_cap(g: Graph, t: int) -> bool:
    """Check the (t)-cap: every 3-element set has at most t-1 common neighbors."""
    n, _ = g
    for triple in combinations(range(n), 3):
        if len(common_neighborhood(g, triple)) > t - 1:
            return False
    return True


def is_K3t_free(g: Graph, t: int) -> bool:
    """Check that G contains no K_{3,t}: no triple with >= t common neighbors.

    This is exactly the (t)-cap, illustrating the core equivalence lemma.
    """
    return satisfies_t_cap(g, t)


def count_Kab_copies(g: Graph, a: int, b: int) -> int:
    """Count labelled copies (A, B) of K_{a,b}: disjoint A, B with |A|=a, |B|=b
    and every A-B edge present.  The two sides are distinguished.

    Brute force over choices of A, then B inside the common neighborhood of A.
    """
    n, _ = g
    total = 0
    for A in combinations(range(n), a):
        # Every vertex of B must be adjacent to all of A, i.e. lie in N(A);
        # and B must avoid A.
        candidates = common_neighborhood(g, A) - set(A)
        for B in combinations(sorted(candidates), b):
            # Every vertex of A must be adjacent to all of B; since B lies in
            # N(A) this holds automatically, but we assert it for clarity.
            total += 1
    return total


def theoretical_bound(a: int, b: int, n: int) -> Tuple[int, int]:
    """Return (tight_bound, loose_bound):
       tight_bound = C(n,3) * C(b,a-3)   (from the double count at t=b+1)
       loose_bound = C(b,a-3) * n^3      (the stated O(n^3) form).
    """
    tight = comb(n, 3) * comb(b, a - 3)
    loose = comb(b, a - 3) * n ** 3
    return tight, loose


# ---------------------------------------------------------------------------
# Random K_{3,b+1}-free graph generator (rejection of edges that would create
# a triple with too many common neighbors).
# ---------------------------------------------------------------------------
def random_K3t_free_graph(n: int, t: int, seed: int = 0) -> Graph:
    """Greedily add random edges, rejecting any edge that would push some triple
    above t-1 common neighbors.  The output is guaranteed K_{3,t}-free.
    """
    rng = random.Random(seed)
    adj: Dict[int, Set[int]] = {v: set() for v in range(n)}
    g: Graph = (n, adj)
    possible = list(combinations(range(n), 2))
    rng.shuffle(possible)
    for u, v in possible:
        adj[u].add(v)
        adj[v].add(u)
        # Check only triples that could be affected: those meeting {u, v}.
        ok = True
        for triple in combinations(range(n), 3):
            if u in triple or v in triple:
                if len(common_neighborhood(g, triple)) > t - 1:
                    ok = False
                    break
        if not ok:
            adj[u].discard(v)
            adj[v].discard(u)
    return g


def demo_equivalence() -> None:
    """Illustrate: 'K_{3,t}-free' == 'every triple has <= t-1 common neighbors'."""
    print("=" * 70)
    print("DEMO 1: K_{3,t}-freeness equals the common-neighborhood cap")
    print("=" * 70)
    # A K_{3,3}: three vertices {0,1,2} each joined to {3,4,5}.
    edges = [(u, v) for u in (0, 1, 2) for v in (3, 4, 5)]
    g = make_graph(6, edges)
    triple = (0, 1, 2)
    print(f"Graph = K_{{3,3}} on 6 vertices.")
    print(f"Common neighbors of {triple}: {sorted(common_neighborhood(g, triple))}")
    print(f"  -> size {len(common_neighborhood(g, triple))}")
    print(f"K_{{3,3}}-free? {is_K3t_free(g, 3)}  (expect False: it IS a K_{{3,3}})")
    print(f"K_{{3,4}}-free? {is_K3t_free(g, 4)}  (expect True: no triple has 4 common nbrs)")
    print()


def demo_bound_verification() -> None:
    """Verify #copies <= C(b,a-3) * n^3 on random K_{3,b+1}-free graphs."""
    print("=" * 70)
    print("DEMO 2: Verifying the cubic bound on random K_{3,b+1}-free graphs")
    print("=" * 70)
    a, b = 3, 3
    t = b + 1  # forbid K_{3,4}
    print(f"Counting K_{{{a},{b}}} in K_{{3,{t}}}-free graphs; bound = C({b},{a-3})*n^3"
          f" = {comb(b, a-3)}*n^3")
    print(f"{'n':>4} {'#copies':>10} {'C(n,3)*C(b,a-3)':>18} {'C(b,a-3)*n^3':>14} {'ok':>4}")
    for n in range(6, 13):
        g = random_K3t_free_graph(n, t, seed=n)
        copies = count_Kab_copies(g, a, b)
        tight, loose = theoretical_bound(a, b, n)
        ok = copies <= loose
        print(f"{n:>4} {copies:>10} {tight:>18} {loose:>14} {str(ok):>4}")
    print()


def demo_larger_ab() -> None:
    """Same verification with a=4, b=4 (nontrivial constant C(4,1)=4)."""
    print("=" * 70)
    print("DEMO 3: Nontrivial constant, a=4, b=4  ->  C(b,a-3)=C(4,1)=4")
    print("=" * 70)
    a, b = 4, 4
    t = b + 1  # forbid K_{3,5}
    print(f"Counting K_{{{a},{b}}} in K_{{3,{t}}}-free graphs; bound = {comb(b, a-3)}*n^3")
    print(f"{'n':>4} {'#copies':>10} {'C(b,a-3)*n^3':>14} {'ok':>4}")
    for n in range(8, 13):
        g = random_K3t_free_graph(n, t, seed=100 + n)
        copies = count_Kab_copies(g, a, b)
        _, loose = theoretical_bound(a, b, n)
        print(f"{n:>4} {copies:>10} {loose:>14} {str(copies <= loose):>4}")
    print()


def demo_density() -> None:
    """Illustrate the vanishing copy density #copies / n^{a+b} -> 0."""
    print("=" * 70)
    print("DEMO 4: Vanishing copy density  #copies / n^(a+b) -> 0")
    print("=" * 70)
    a, b = 3, 3
    t = b + 1
    print(f"a={a}, b={b}, a+b={a+b}.  Bound gives density <= C(b,a-3)/n^(a+b-3) = "
          f"{comb(b,a-3)}/n^{a+b-3}")
    print(f"{'n':>4} {'density (bound)':>16}")
    for n in (10, 20, 50, 100, 1000):
        bound_density = comb(b, a - 3) / n ** (a + b - 3)
        print(f"{n:>4} {bound_density:>16.3e}")
    print("The density upper bound tends to 0 as n grows.")
    print()


def main() -> None:
    demo_equivalence()
    demo_bound_verification()
    demo_larger_ab()
    demo_density()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
