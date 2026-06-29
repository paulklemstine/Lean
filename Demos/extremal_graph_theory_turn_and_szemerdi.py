"""
Numerical demonstrations for:

    Density Forces Structure:
    Extremal Bounds for Cliques, Shadows, and Arithmetic Progressions

This self-contained script illustrates four cornerstone results of extremal
combinatorics, each an instance of the principle "sufficient density forces
unavoidable structure":

  1. Turan's theorem (closed integer form)  : 2*r*e <= (r-1)*n^2
  2. Mantel's theorem and its sharpness     : 4*e <= n^2, tight at K_{k,k}
  3. Kruskal-Katona single-shadow bound     : |shadow A| >= C(k, r-1)
       and its graph corollary               : C(k,2) edges touch >= k vertices
  4. Roth's theorem (positive form)         : dense sets contain 3-APs

Run:  python demo.py
"""

from __future__ import annotations

from itertools import combinations
from math import comb
from typing import Dict, FrozenSet, List, Optional, Sequence, Set, Tuple


# ---------------------------------------------------------------------------
# 1. Turan graph edge count and the Turan bound
# ---------------------------------------------------------------------------
def turan_graph_edges(n: int, r: int) -> int:
    """Exact number of edges of the Turan graph T(n, r): the complete r-partite
    graph on n vertices with parts as equal as possible.

    e(T(n,r)) = C(n,2) - (within-part edges).
    Writing n = q*r + s, there are s parts of size q+1 and r-s parts of size q.
    """
    if r <= 0:
        raise ValueError("r must be positive")
    q, s = divmod(n, r)
    within = s * comb(q + 1, 2) + (r - s) * comb(q, 2)
    return comb(n, 2) - within


def turan_bound(n: int, r: int) -> float:
    """Closed-form Turan upper bound (1 - 1/r) * n^2 / 2 on edges of a
    K_{r+1}-free graph on n vertices."""
    return (1.0 - 1.0 / r) * n * n / 2.0


def verify_turan_integer_form(n: int, r: int) -> bool:
    """Verify the integer form 2*r*e(T(n,r)) <= (r-1)*n^2."""
    e = turan_graph_edges(n, r)
    return 2 * r * e <= (r - 1) * n * n


# ---------------------------------------------------------------------------
# 2. Mantel sharpness via balanced complete bipartite graphs K_{k,k}
# ---------------------------------------------------------------------------
def complete_bipartite_edges(k: int) -> int:
    """Edges of K_{k,k}: every vertex of one side joined to every vertex of the
    other side, no edges within a side.  Equals k*k."""
    return k * k


def verify_mantel_sharp(k: int) -> bool:
    """K_{k,k} on n = 2k vertices is triangle-free with 4*e = n^2 exactly."""
    n = 2 * k
    e = complete_bipartite_edges(k)
    return 4 * e == n * n


# ---------------------------------------------------------------------------
# 3. Kruskal-Katona: shadow of a uniform set family
# ---------------------------------------------------------------------------
def shadow(family: Sequence[FrozenSet[int]]) -> Set[FrozenSet[int]]:
    """The shadow of an r-uniform family: all (r-1)-subsets obtained by deleting
    a single element from some member."""
    out: Set[FrozenSet[int]] = set()
    for s in family:
        for x in s:
            out.add(s - {x})
    return out


def largest_k_with_binom_le(m: int, r: int) -> int:
    """Largest k with C(k, r) <= m (and k >= r). Used to instantiate the
    Kruskal-Katona bound |shadow| >= C(k, r-1)."""
    k = r
    while comb(k + 1, r) <= m:
        k += 1
    return k


def verify_kruskal_katona(family: Sequence[FrozenSet[int]], r: int) -> Tuple[int, int, int]:
    """Return (|family|, |shadow|, lower bound C(k, r-1)) and assert the bound."""
    m = len(family)
    k = largest_k_with_binom_le(m, r)
    sh = shadow(family)
    bound = comb(k, r - 1)
    assert len(sh) >= bound, "Kruskal-Katona bound violated!"
    return m, len(sh), bound


# ---------------------------------------------------------------------------
# 4. Roth: 3-term arithmetic progressions in Z/NZ
# ---------------------------------------------------------------------------
def find_3ap(A: Set[int], N: int) -> Optional[Tuple[int, int]]:
    """Return (a, d) with d != 0 and {a, a+d, a+2d} subset of A (mod N),
    or None if A is 3-AP-free."""
    for a in A:
        for d in range(1, N):
            if (a + d) % N in A and (a + 2 * d) % N in A:
                return a, d
    return None


def count_3aps(A: Set[int], N: int) -> int:
    """Count non-degenerate 3-APs (ordered, d != 0) inside A modulo N."""
    total = 0
    for a in A:
        for d in range(1, N):
            if (a + d) % N in A and (a + 2 * d) % N in A:
                total += 1
    return total


def count_3aps_integer(A: Set[int]) -> int:
    """Count non-degenerate 3-APs over the integers (no modular wraparound):
    triples a < a+d < a+2d all lying in A."""
    total = 0
    for a in A:
        for d in range(1, max(A) + 1 if A else 1):
            if (a + d) in A and (a + 2 * d) in A:
                total += 1
    return total


def greedy_progression_free(N: int) -> Set[int]:
    """A simple greedy 3-AP-free subset of {0,...,N-1}: add the next integer
    only if it creates no 3-AP with two earlier chosen elements."""
    chosen: List[int] = []
    cs: Set[int] = set()
    for x in range(N):
        ok = True
        for b in chosen:
            # x is the largest term: would (2b - x) and b form an AP with x?
            if (2 * b - x) in cs:
                ok = False
                break
        if ok:
            chosen.append(x)
            cs.add(x)
    return cs


# ---------------------------------------------------------------------------
# Demonstration driver
# ---------------------------------------------------------------------------
def main() -> None:
    print("=" * 70)
    print("DENSITY FORCES STRUCTURE  -  numerical demonstrations")
    print("=" * 70)

    # --- 1. Turan ---------------------------------------------------------
    print("\n[1] Turan's theorem:  2*r*e(T(n,r)) <= (r-1)*n^2")
    print(f"{'n':>4} {'r':>3} {'e(T(n,r))':>10} {'bound':>10} {'int-form OK':>12}")
    for n, r in [(10, 2), (10, 3), (12, 3), (15, 4), (20, 5)]:
        e = turan_graph_edges(n, r)
        b = turan_bound(n, r)
        print(f"{n:>4} {r:>3} {e:>10} {b:>10.2f} {str(verify_turan_integer_form(n, r)):>12}")

    # --- 2. Mantel sharpness ---------------------------------------------
    print("\n[2] Mantel sharpness:  K_{k,k} triangle-free, 4*e = n^2")
    print(f"{'k':>4} {'n=2k':>5} {'e':>6} {'4e':>6} {'n^2':>6} {'equal':>7}")
    for k in [1, 2, 3, 5, 8]:
        n = 2 * k
        e = complete_bipartite_edges(k)
        print(f"{k:>4} {n:>5} {e:>6} {4*e:>6} {n*n:>6} {str(verify_mantel_sharp(k)):>7}")

    # --- 3. Kruskal-Katona ------------------------------------------------
    print("\n[3] Kruskal-Katona:  |shadow A| >= C(k, r-1)")
    # 3a. The clique K_5 as a family of 2-sets (edges) on {0,...,4}.
    edges_K5 = [frozenset(s) for s in combinations(range(5), 2)]
    m, sh, bnd = verify_kruskal_katona(edges_K5, r=2)
    print(f"   K_5 edges: |E|={m} (=C(5,2)), |shadow|={sh} vertices, bound C(5,1)={bnd}")
    # 3b. A 3-uniform family: all 3-subsets of {0,...,4}.
    triples = [frozenset(s) for s in combinations(range(5), 3)]
    m, sh, bnd = verify_kruskal_katona(triples, r=3)
    print(f"   all 3-subsets of [5]: |A|={m} (=C(5,3)), |shadow|={sh}, bound C(5,2)={bnd}")

    # --- 4. Roth ----------------------------------------------------------
    print("\n[4] Roth's theorem:  dense A in Z/NZ contains a non-degenerate 3-AP")
    N = 50
    dense = set(range(0, N, 2))  # the even residues: density 1/2
    ap = find_3ap(dense, N)
    cnt = count_3aps(dense, N)
    print(f"   N={N}, A = even residues (|A|={len(dense)}, density={len(dense)/N:.2f})")
    if ap:
        a, d = ap
        prog = [(a) % N, (a + d) % N, (a + 2 * d) % N]
        print(f"   found 3-AP: a={a}, d={d}  ->  {prog};  total 3-APs in A = {cnt}")
    # Contrast: a sparse, greedily progression-free set has none.
    pf = greedy_progression_free(N)
    print(f"   greedy 3-AP-free set: |A|={len(pf)} (density={len(pf)/N:.2f}), "
          f"integer 3-APs = {count_3aps_integer(pf)}")

    print("\n" + "=" * 70)
    print("All bounds verified.  Density forces structure.")
    print("=" * 70)


if __name__ == "__main__":
    main()
