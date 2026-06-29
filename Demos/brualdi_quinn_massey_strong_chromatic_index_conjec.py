"""Numerical demonstrations for the Brualdi--Quinn--Massey strong chromatic
index results and the Fibonacci--Riordan bridge.

This script is fully self-contained (standard library only) and demonstrates,
with concrete numbers:

  1. The conflict graph of a complete bipartite graph K_{m,n} is complete, so
     its strong chromatic index equals m * n = Delta_A * Delta_B
     (Theorem: completeBipartite_strongChromaticIndex).
  2. The universal star-clique lower bound chi'_s(G) >= max(Delta_A, Delta_B)
     (Theorem: maxDegA_le_strongChromaticIndex).
  3. The Riordan row-sum identity  sum_k C(n+k, 2k) = F_{2n+1}
     (Theorem: pascalRiordanA_eq_fib) and its companion = F_{2n}
     (pascalRiordanB_eq_fib), plus the recurrence A(n+2)=3A(n+1)-A(n)
     (pascalRiordan_three_term).
  4. The bridge  chi'_s(K_{A(a),A(b)}) = F_{2a+1} * F_{2b+1}
     (Theorem: strongChromaticIndex_riordan_complete_bipartite).
"""

from __future__ import annotations

from itertools import combinations, product
from math import comb, isqrt
from typing import Dict, List, Tuple

Edge = Tuple[int, int]


# --------------------------------------------------------------------------
# Fibonacci numbers and Riordan row sums
# --------------------------------------------------------------------------
def fib(n: int) -> int:
    """Return the n-th Fibonacci number with F_0 = 0, F_1 = 1."""
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def riordan_A(n: int) -> int:
    """Steep-diagonal row sum  A(n) = sum_{k=0}^{n} C(n+k, 2k)."""
    return sum(comb(n + k, 2 * k) for k in range(n + 1))


def riordan_B(n: int) -> int:
    """Companion row sum  B(n) = sum_{k=0}^{n} C(n+k, 2k+1)."""
    return sum(comb(n + k, 2 * k + 1) for k in range(n + 1))


# --------------------------------------------------------------------------
# Strong chromatic index via the conflict graph
# --------------------------------------------------------------------------
def complete_bipartite_edges(m: int, n: int) -> List[Edge]:
    """Edges (a, b) of K_{m,n} with a in {0..m-1} (side A), b in {0..n-1}."""
    return [(a, b) for a, b in product(range(m), range(n))]


def edges_conflict(e: Edge, f: Edge) -> bool:
    """Two distinct edges conflict iff they are at distance <= 1 in a complete
    bipartite graph: they share an endpoint, or the cross pair is also an edge
    (which it always is in a complete bipartite graph)."""
    if e == f:
        return False
    a1, b1 = e
    a2, b2 = f
    # Share an endpoint -> adjacent.
    if a1 == a2 or b1 == b2:
        return True
    # In K_{m,n} the cross edge (a1, b2) always exists, linking the two edges.
    return True


def conflict_graph(edges: List[Edge]) -> Dict[Edge, List[Edge]]:
    """Adjacency lists of the conflict graph on the given edge set."""
    adj: Dict[Edge, List[Edge]] = {e: [] for e in edges}
    for e, f in combinations(edges, 2):
        if edges_conflict(e, f):
            adj[e].append(f)
            adj[f].append(e)
    return adj


def greedy_chromatic_number(adj: Dict[Edge, List[Edge]]) -> int:
    """Exact chromatic number for a complete conflict graph (greedy is exact
    when the graph is complete: each vertex needs its own color)."""
    color: Dict[Edge, int] = {}
    for v in adj:
        used = {color[u] for u in adj[v] if u in color}
        c = 0
        while c in used:
            c += 1
        color[v] = c
    return (max(color.values()) + 1) if color else 0


def strong_chromatic_index_complete_bipartite(m: int, n: int) -> int:
    """chi'_s(K_{m,n}) computed by coloring the conflict graph."""
    edges = complete_bipartite_edges(m, n)
    if not edges:
        return 0
    return greedy_chromatic_number(conflict_graph(edges))


def max_degrees_complete_bipartite(m: int, n: int) -> Tuple[int, int]:
    """(Delta_A, Delta_B) for K_{m,n}: every A-vertex has degree n, every
    B-vertex has degree m."""
    return (n, m)


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------
def demo_tightness() -> None:
    print("=" * 68)
    print("1. Tightness: chi'_s(K_{m,n}) = Delta_A * Delta_B = m * n")
    print("=" * 68)
    print(f"{'m':>3} {'n':>3} | {'Delta_A':>7} {'Delta_B':>7} "
          f"{'D_A*D_B':>8} | {'chi_s':>6} | match")
    for m, n in [(1, 1), (2, 3), (3, 3), (4, 5), (5, 13)]:
        dA, dB = max_degrees_complete_bipartite(m, n)
        chi = strong_chromatic_index_complete_bipartite(m, n)
        ok = "YES" if chi == dA * dB == m * n else "NO"
        print(f"{m:>3} {n:>3} | {dA:>7} {dB:>7} {dA*dB:>8} | {chi:>6} | {ok}")
    print()


def demo_lower_bound() -> None:
    print("=" * 68)
    print("2. Universal lower bound: chi'_s >= max(Delta_A, Delta_B)")
    print("=" * 68)
    for m, n in [(2, 3), (3, 5), (4, 4)]:
        dA, dB = max_degrees_complete_bipartite(m, n)
        chi = strong_chromatic_index_complete_bipartite(m, n)
        print(f"K_{{{m},{n}}}: max(Delta_A,Delta_B)={max(dA,dB)} "
              f"<= chi'_s={chi}  (and chi'_s <= Delta_A*Delta_B={dA*dB})")
    print()


def demo_fibonacci_identity() -> None:
    print("=" * 68)
    print("3. Riordan row sums: A(n)=F_{2n+1}, B(n)=F_{2n}")
    print("=" * 68)
    print(f"{'n':>3} | {'A(n)':>6} {'F_2n+1':>7} | {'B(n)':>6} {'F_2n':>6}")
    for n in range(8):
        A, B = riordan_A(n), riordan_B(n)
        print(f"{n:>3} | {A:>6} {fib(2*n+1):>7} | {B:>6} {fib(2*n):>6}")
    print("\n  Three-term recurrence A(n+2) = 3*A(n+1) - A(n):")
    for n in range(6):
        lhs = riordan_A(n + 2)
        rhs = 3 * riordan_A(n + 1) - riordan_A(n)
        print(f"    A({n+2})={lhs}  3*A({n+1})-A({n})={rhs}  "
              f"{'OK' if lhs == rhs else 'FAIL'}")
    print()


def demo_bridge() -> None:
    print("=" * 68)
    print("4. Bridge: chi'_s(K_{A(a),A(b)}) = F_{2a+1} * F_{2b+1}")
    print("=" * 68)
    print(f"{'a':>2} {'b':>2} | {'A(a)':>5} {'A(b)':>5} | "
          f"{'F2a+1*F2b+1':>12} | {'chi_s':>7} | match")
    for a, b in [(0, 0), (1, 1), (2, 2), (2, 3), (3, 3)]:
        Aa, Ab = riordan_A(a), riordan_A(b)
        prod_fib = fib(2 * a + 1) * fib(2 * b + 1)
        chi = strong_chromatic_index_complete_bipartite(Aa, Ab)
        ok = "YES" if chi == prod_fib == Aa * Ab else "NO"
        print(f"{a:>2} {b:>2} | {Aa:>5} {Ab:>5} | {prod_fib:>12} | "
              f"{chi:>7} | {ok}")
    print()
    # Golden-ratio growth illustration.
    phi = (1 + 5 ** 0.5) / 2
    print(f"  Golden ratio phi = {phi:.6f}, phi^2 = {phi**2:.6f}")
    print("  Ratio chi'_s(K_{A(a+1),A(0)}) / chi'_s(K_{A(a),A(0)}):")
    for a in range(1, 7):
        num = fib(2 * (a + 1) + 1)
        den = fib(2 * a + 1)
        print(f"    a={a}: {num}/{den} = {num/den:.5f}  (-> phi^2 = "
              f"{phi**2:.5f})")
    print()


def main() -> None:
    demo_tightness()
    demo_lower_bound()
    demo_fibonacci_identity()
    demo_bridge()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
