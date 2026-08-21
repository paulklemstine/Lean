#!/usr/bin/env python3
"""
The Probabilistic Method as Finite Counting — numerical demonstrations.

Every classical "random construction" below is replaced by an exact finite
computation: a comparison of integers, a greedy algorithm, or a local search.
Nothing in this file calls a random number generator.

Demonstrations
--------------
1. Erdos' Ramsey lower bound as an inequality between two integers, and the
   arithmetic engine  2^(k+2) < (k!)^2  for k >= 3.
2. The deletion method, and the verified gain over the union bound at k = 6
   (R(6,6) > 18, which the union bound cannot reach).
3. The Ramsey sandwich  2^(k/2) < R(k,k) <= 4^(k-1).
4. Caro-Wei by minimum-degree greedy deletion, compared with the bound
   sum_v 1/(deg v + 1) and with the exact independence number.
5. Turan's theorem: the exact edge identity 2 r e(T(n,r)) + s(r-s) = (r-1) n^2,
   the exact extremal number, and the failure of the floor formula at n=12, r=8.
6. MAX-CUT: the exact averaging identity, local search, and the identity
   maxcut(K_n) = e(T(n,2)).
7. The symmetric Lovasz Local Lemma in a finite weighted space, with the
   certified exhaustive search, on an explicit k-SAT instance.

Run:  python3 demo.py
"""

from __future__ import annotations

from itertools import combinations, product
from math import comb, factorial, exp
from typing import Dict, FrozenSet, Iterable, List, Sequence, Set, Tuple

Graph = Dict[int, Set[int]]


# ----------------------------------------------------------------------------
# Small graph utilities
# ----------------------------------------------------------------------------

def make_graph(n: int, edges: Iterable[Tuple[int, int]]) -> Graph:
    """Build an adjacency-set graph on vertices 0..n-1."""
    g: Graph = {v: set() for v in range(n)}
    for u, v in edges:
        if u == v:
            continue
        g[u].add(v)
        g[v].add(u)
    return g


def num_edges(g: Graph) -> int:
    """Number of edges of a simple graph."""
    return sum(len(nbrs) for nbrs in g.values()) // 2


def degrees(g: Graph) -> Dict[int, int]:
    """Degree of every vertex."""
    return {v: len(nbrs) for v, nbrs in g.items()}


def turan_graph(n: int, r: int) -> Graph:
    """T(n, r): vertices 0..n-1, adjacent iff their residues mod r differ."""
    return make_graph(n, [(u, v) for u in range(n) for v in range(u + 1, n)
                          if u % r != v % r])


def complement(g: Graph) -> Graph:
    """The complement graph."""
    n = len(g)
    return make_graph(n, [(u, v) for u in range(n) for v in range(u + 1, n)
                          if v not in g[u]])


def independence_number(g: Graph) -> int:
    """Exact independence number by exhaustive search (small graphs only)."""
    n = len(g)
    best = 0
    for size in range(n, 0, -1):
        if size <= best:
            break
        for s in combinations(range(n), size):
            if all(v not in g[u] for u, v in combinations(s, 2)):
                return size
    return best


# ----------------------------------------------------------------------------
# 1. Erdos' Ramsey lower bound as pure counting
# ----------------------------------------------------------------------------

def union_bound_holds(n: int, k: int) -> bool:
    """The counting hypothesis 2*C(n,k) < 2^C(k,2) of the union bound."""
    return 2 * comb(n, k) < 2 ** comb(k, 2)


def bad_colourings_upper_bound(n: int, k: int) -> int:
    """Upper bound on the number of colourings monochromatic on some k-set."""
    return comb(n, k) * 2 * 2 ** (comb(n, 2) - comb(k, 2))


def arithmetic_engine(k: int) -> Tuple[int, int, bool]:
    """The inequality 2^(k+2) < (k!)^2, valid for every k >= 3."""
    return 2 ** (k + 2), factorial(k) ** 2, 2 ** (k + 2) < factorial(k) ** 2


def largest_n_by_union_bound(k: int) -> int:
    """Largest n for which the union bound certifies R(k,k) > n."""
    n = k
    while union_bound_holds(n + 1, k):
        n += 1
    return n


def demo_ramsey_counting() -> None:
    print("=" * 74)
    print("1. ERDOS' RAMSEY BOUND AS AN INEQUALITY BETWEEN TWO INTEGERS")
    print("=" * 74)
    print("A colouring of K_n is a subset of the pair set: 2^C(n,2) of them.")
    print("Bad colourings (monochromatic on some k-set) number at most")
    print("    C(n,k) * 2 * 2^(C(n,2)-C(k,2)).")
    print()
    print(f"{'k':>3} {'n':>4} {'bad <= ':>24} {'total = 2^C(n,2)':>26} {'good?':>7}")
    for k, n in [(3, 3), (4, 4), (5, 5), (6, 10), (6, 17), (6, 18)]:
        bad = bad_colourings_upper_bound(n, k)
        tot = 2 ** comb(n, 2)
        print(f"{k:>3} {n:>4} {bad:>24} {tot:>26} {str(bad < tot):>7}")
    print()
    print("The arithmetic engine  2^(k+2) < (k!)^2  (equivalently 2*2^(k/2) < k!):")
    for k in range(3, 10):
        lhs, rhs, ok = arithmetic_engine(k)
        print(f"   k={k}: 2^(k+2) = {lhs:<10} (k!)^2 = {rhs:<14} holds: {ok}")
    print()
    print("Largest n certified by the union bound, versus floor(2^(k/2)):")
    for k in range(3, 13):
        n_star = largest_n_by_union_bound(k)
        sqrt_bound = int(2 ** (k / 2))
        print(f"   k={k:<3} union bound gives R(k,k) > {n_star:<6} "
              f"(2^(k/2) = {sqrt_bound})")
    print()


# ----------------------------------------------------------------------------
# 2. The deletion method
# ----------------------------------------------------------------------------

def deletion_bound_holds(n: int, k: int, t: int) -> bool:
    """The averaging hypothesis 2*C(n,k) < (t+1)*2^C(k,2) of the deletion method."""
    return 2 * comb(n, k) < (t + 1) * 2 ** comb(k, 2)


def best_deletion_bound(k: int, t_max: int = 2000) -> Tuple[int, int, int]:
    """Best (n, t, n-t) for which the deletion method certifies R(k,k) > n-t."""
    best = (0, 0, 0)
    for t in range(t_max + 1):
        n = k
        while deletion_bound_holds(n + 1, k, t):
            n += 1
        if n - t > best[2]:
            best = (n, t, n - t)
    return best


def demo_deletion() -> None:
    print("=" * 74)
    print("2. THE DELETION METHOD, AND A VERIFIED GAIN AT k = 6")
    print("=" * 74)
    print("Averaging: if 2*C(n,k) < (t+1)*2^C(k,2), some colouring has at most t")
    print("monochromatic k-sets; delete the minimum vertex of each, so R(k,k) > n-t.")
    print()
    k = 6
    print(f"   union bound at n=18, k=6: 2*C(18,6) = {2*comb(18,6)}, "
          f"2^C(6,2) = {2**comb(6,2)}  -> fails")
    print(f"   deletion at n=19, t=1  : 2*C(19,6) = {2*comb(19,6)}, "
          f"2*2^C(6,2) = {2*2**comb(6,2)}  -> holds")
    print(f"   conclusion: R(6,6) > 19 - 1 = 18")
    print()
    print("Best certificate per k (union bound t=0 versus optimised deletion):")
    print(f"{'k':>3} {'union: R > ':>14} {'deletion: R > ':>16} {'n':>7} {'t':>7}")
    for k in range(4, 13):
        u = largest_n_by_union_bound(k)
        n, t, val = best_deletion_bound(k)
        print(f"{k:>3} {u:>14} {val:>16} {n:>7} {t:>7}")
    print()


# ----------------------------------------------------------------------------
# 3. The Ramsey sandwich
# ----------------------------------------------------------------------------

def demo_sandwich() -> None:
    print("=" * 74)
    print("3. THE RAMSEY SANDWICH  2^(k/2) < R(k,k) <= 4^(k-1)")
    print("=" * 74)
    print("Lower: counting/deletion.  Upper: Erdos-Szekeres, R(k,k) <= C(2k-2,k-1) <= 4^(k-1).")
    print()
    print(f"{'k':>3} {'2^(k/2)':>14} {'C(2k-2,k-1)':>16} {'4^(k-1)':>16}")
    for k in range(3, 13):
        print(f"{k:>3} {2 ** (k / 2):>14.2f} {comb(2 * k - 2, k - 1):>16} "
              f"{4 ** (k - 1):>16}")
    print()
    print("Sanity check C(2m,m) <= 4^m:")
    for m in range(0, 8):
        print(f"   m={m}: C(2m,m) = {comb(2*m, m):<8} <= 4^m = {4**m}")
    print()


# ----------------------------------------------------------------------------
# 4. Caro-Wei by greedy deletion
# ----------------------------------------------------------------------------

def caro_wei_sum(g: Graph) -> float:
    """The Caro-Wei quantity sum_v 1/(deg v + 1)."""
    return sum(1.0 / (len(nbrs) + 1) for nbrs in g.values())


def greedy_independent_set(g: Graph) -> List[int]:
    """
    Minimum-degree greedy deletion: repeatedly take a vertex of minimum degree
    inside the surviving set, output it, and delete its closed neighbourhood.
    This is the de-randomised random-permutation proof of Caro-Wei; the set it
    returns has size at least sum_v 1/(deg v + 1).
    """
    remaining: Set[int] = set(g.keys())
    chosen: List[int] = []
    while remaining:
        v = min(remaining, key=lambda u: len(g[u] & remaining))
        chosen.append(v)
        remaining -= ({v} | g[v])
    return sorted(chosen)


def demo_caro_wei() -> None:
    print("=" * 74)
    print("4. CARO-WEI BY MINIMUM-DEGREE GREEDY DELETION")
    print("=" * 74)
    print("alpha(G) >= sum_v 1/(deg v + 1) >= n/(Delta+1),  and  alpha >= n^2/(2m+n).")
    print()
    examples: List[Tuple[str, Graph]] = [
        ("C_4 = T(4,2)", turan_graph(4, 2)),
        ("C_5", make_graph(5, [(0, 1), (1, 2), (2, 3), (3, 4), (4, 0)])),
        ("Petersen", make_graph(10,
            [(0, 1), (1, 2), (2, 3), (3, 4), (4, 0),
             (5, 7), (7, 9), (9, 6), (6, 8), (8, 5),
             (0, 5), (1, 6), (2, 7), (3, 8), (4, 9)])),
        ("K_{3,3}", make_graph(6, [(i, j) for i in range(3) for j in range(3, 6)])),
        ("T(7,3)", turan_graph(7, 3)),
        ("path P_6", make_graph(6, [(i, i + 1) for i in range(5)])),
    ]
    header = (f"{'graph':>14} {'n':>3} {'m':>4} {'CW sum':>9} {'n/(D+1)':>9} "
              f"{'n^2/(2m+n)':>11} {'greedy':>7} {'alpha':>6}")
    print(header)
    for name, g in examples:
        n, m = len(g), num_edges(g)
        delta = max(degrees(g).values()) if n else 0
        cw = caro_wei_sum(g)
        greedy = len(greedy_independent_set(g))
        alpha = independence_number(g)
        print(f"{name:>14} {n:>3} {m:>4} {cw:>9.3f} {n/(delta+1):>9.3f} "
              f"{n*n/(2*m+n):>11.3f} {greedy:>7} {alpha:>6}")
        assert greedy >= cw - 1e-9, "greedy must meet the Caro-Wei bound"
        assert alpha >= greedy
    print()
    print("Triangle-free corollary  n <= alpha*(alpha+1), i.e. R(3,k+1) > k^2:")
    for k in range(1, 7):
        print(f"   every graph on more than {k*(k+1)} vertices has a triangle "
              f"or an independent set of size {k+1}  =>  R(3,{k+1}) > {k*k}")
    print()


# ----------------------------------------------------------------------------
# 5. Turan: exact counts
# ----------------------------------------------------------------------------

def turan_edges(n: int, r: int) -> int:
    """Edge count of T(n,r) from the closed-form class sizes."""
    q, s = divmod(n, r)
    sizes = [q + 1] * s + [q] * (r - s)
    return (n * n - sum(c * c for c in sizes)) // 2


def turan_identity_check(n: int, r: int) -> Tuple[int, int, bool]:
    """Verify 2*r*e(T(n,r)) + s*(r-s) = (r-1)*n^2 with s = n mod r."""
    s = n % r
    lhs = 2 * r * turan_edges(n, r) + s * (r - s)
    rhs = (r - 1) * n * n
    return lhs, rhs, lhs == rhs


def turan_extremal_number(n: int, r: int) -> int:
    """ex(n, K_{r+1}) = ((r-1)n^2 - s(r-s)) / (2r)."""
    s = n % r
    return ((r - 1) * n * n - s * (r - s)) // (2 * r)


def brute_force_extremal(n: int, r: int) -> int:
    """Maximum edge count of a K_{r+1}-free graph on n vertices (tiny n only)."""
    pairs = list(combinations(range(n), 2))
    best = 0
    for mask in range(1 << len(pairs)):
        edges = [pairs[i] for i in range(len(pairs)) if mask >> i & 1]
        if len(edges) <= best:
            continue
        g = make_graph(n, edges)
        if not any(all(v in g[u] for u, v in combinations(cl, 2))
                   for cl in combinations(range(n), r + 1)):
            best = len(edges)
    return best


def demo_turan() -> None:
    print("=" * 74)
    print("5. TURAN'S THEOREM, COUNTED EXACTLY")
    print("=" * 74)
    print("Identity:  2*r*e(T(n,r)) + s*(r-s) = (r-1)*n^2,  s = n mod r.")
    print("So         e(T(n,r)) = (1-1/r)n^2/2 - s(r-s)/(2r),")
    print("with equality to the clean value exactly when r | n.")
    print()
    print(f"{'n':>4} {'r':>3} {'s':>3} {'e(T)':>7} {'clean':>10} {'floor':>7} "
          f"{'ex(n)':>7} {'identity':>9}")
    for n, r in [(4, 2), (6, 3), (7, 3), (9, 4), (10, 4), (12, 5), (12, 8),
                 (13, 8), (20, 8), (24, 8), (100, 7)]:
        s = n % r
        e = turan_edges(n, r)
        clean = (1 - 1 / r) * n * n / 2
        floor_val = (r - 1) * n * n // (2 * r)
        _, _, ok = turan_identity_check(n, r)
        print(f"{n:>4} {r:>3} {s:>3} {e:>7} {clean:>10.3f} {floor_val:>7} "
              f"{turan_extremal_number(n, r):>7} {str(ok):>9}")
    print()
    print("The floor formula is correct iff s(r-s) < 2r.  First failure:")
    n, r = 12, 8
    print(f"   n={n}, r={r}: s = {n % r}, s(r-s) = {(n%r)*(r-(n%r))} = 2r = {2*r}")
    print(f"   true extremal number ex(12,K_9) = {turan_extremal_number(12, 8)}, "
          f"floor formula = {(r-1)*n*n//(2*r)}")
    print()
    print("Exhaustive search over all failures with r <= 12, n <= 60:")
    failures = [(n, r) for r in range(1, 13) for n in range(1, 61)
                if (n % r) * (r - n % r) >= 2 * r]
    print(f"   {len(failures)} failing pairs; smallest modulus r that fails: "
          f"{min(r for _, r in failures)}")
    print(f"   first few: {failures[:6]}")
    print()
    print("Brute-force confirmation of the extremal number on tiny instances:")
    for n, r in [(4, 2), (5, 2), (5, 3), (6, 2)]:
        bf = brute_force_extremal(n, r)
        formula = turan_extremal_number(n, r)
        print(f"   n={n}, r={r}: brute force = {bf}, formula = {formula}, "
              f"match = {bf == formula}")
    print()


# ----------------------------------------------------------------------------
# 6. MAX-CUT
# ----------------------------------------------------------------------------

def cut_size(g: Graph, side: FrozenSet[int]) -> int:
    """Number of edges with exactly one endpoint in `side`."""
    return sum(1 for u in g for v in g[u] if u < v
               and ((u in side) != (v in side)))


def average_cut(g: Graph) -> float:
    """Average cut over all 2^n bipartitions; equals m/2 exactly."""
    n = len(g)
    total = 0
    for bits in product([0, 1], repeat=n):
        side = frozenset(v for v in range(n) if bits[v])
        total += cut_size(g, side)
    return total / 2 ** n


def local_search_maxcut(g: Graph) -> Tuple[FrozenSet[int], int, int]:
    """
    Local search: while some single-vertex flip increases the cut, perform it.
    Returns the final side, its cut, and the number of improving steps taken.
    Guaranteed: at most m steps, and final cut >= m/2.
    """
    side: Set[int] = set()
    steps = 0
    improved = True
    while improved:
        improved = False
        current = cut_size(g, frozenset(side))
        for v in g:
            trial = set(side)
            trial.symmetric_difference_update({v})
            if cut_size(g, frozenset(trial)) > current:
                side = trial
                steps += 1
                improved = True
                break
    return frozenset(side), cut_size(g, frozenset(side)), steps


def max_cut_exhaustive(g: Graph) -> int:
    """Maximum cut by exhaustive search over all 2^n subsets."""
    n = len(g)
    return max(cut_size(g, frozenset(v for v in range(n) if bits[v]))
               for bits in product([0, 1], repeat=n))


def demo_maxcut() -> None:
    print("=" * 74)
    print("6. MAX-CUT: AVERAGING IDENTITY AND LOCAL SEARCH")
    print("=" * 74)
    print("Sum over all 2^n sides of cut(S) = 2m * 2^(n-2), so the average is m/2.")
    print("Flipping v changes the cut by deg(v) - 2*c_S(v); a locally maximal cut")
    print("therefore satisfies m <= 2*cut, and local search takes at most m steps.")
    print()
    examples: List[Tuple[str, Graph]] = [
        ("K_3", make_graph(3, list(combinations(range(3), 2)))),
        ("K_4", make_graph(4, list(combinations(range(4), 2)))),
        ("K_5", make_graph(5, list(combinations(range(5), 2)))),
        ("C_5", make_graph(5, [(0, 1), (1, 2), (2, 3), (3, 4), (4, 0)])),
        ("Petersen", make_graph(10,
            [(0, 1), (1, 2), (2, 3), (3, 4), (4, 0),
             (5, 7), (7, 9), (9, 6), (6, 8), (8, 5),
             (0, 5), (1, 6), (2, 7), (3, 8), (4, 9)])),
    ]
    print(f"{'graph':>10} {'n':>3} {'m':>4} {'avg cut':>9} {'m/2':>7} "
          f"{'local':>6} {'steps':>6} {'maxcut':>7}")
    for name, g in examples:
        n, m = len(g), num_edges(g)
        avg = average_cut(g)
        _, local, steps = local_search_maxcut(g)
        mx = max_cut_exhaustive(g)
        print(f"{name:>10} {n:>3} {m:>4} {avg:>9.3f} {m/2:>7.2f} "
              f"{local:>6} {steps:>6} {mx:>7}")
        assert abs(avg - m / 2) < 1e-9
        assert 2 * local >= m
        assert steps <= m
    print()
    print("maxcut(K_n) = floor(n/2)*ceil(n/2) = e(T(n,2)) = ex(n, K_3):")
    for n in range(2, 11):
        balanced = (n // 2) * (n - n // 2)
        print(f"   n={n:<3} balanced = {balanced:<5} e(T(n,2)) = {turan_edges(n, 2):<5} "
              f"match = {balanced == turan_edges(n, 2)}")
    print()


# ----------------------------------------------------------------------------
# 7. The Lovasz Local Lemma in a finite weighted space
# ----------------------------------------------------------------------------

Clause = Tuple[Tuple[int, bool], ...]  # (variable index, required truth value)


def clause_violated(clause: Clause, assignment: Sequence[bool]) -> bool:
    """A clause is violated when every literal is false."""
    return all(assignment[var] != want for var, want in clause)


def lll_symmetric_certificate(k: int, max_shared: int) -> Tuple[float, int, float, bool]:
    """
    For a k-CNF formula in which each clause shares a variable with at most
    `max_shared` other clauses, each bad event (clause violated) has probability
    p = 2^-k under the uniform distribution and dependency degree d = max_shared.
    Returns (p, d, e*p*(d+1), whether the symmetric condition e p (d+1) <= 1 holds).
    """
    p = 2.0 ** (-k)
    d = max_shared
    value = exp(1.0) * p * (d + 1)
    return p, d, value, value <= 1.0


def search_avoiding(num_vars: int, clauses: Sequence[Clause]) -> Tuple[bool, Tuple[bool, ...]]:
    """
    Exhaustive search of the finite sample space {0,1}^num_vars for a point
    avoiding all bad events (i.e. a satisfying assignment).  The Local Lemma is
    exactly the certificate that this search never fails.
    """
    for bits in product([False, True], repeat=num_vars):
        if not any(clause_violated(c, bits) for c in clauses):
            return True, bits
    return False, ()


def dependency_degree(clauses: Sequence[Clause]) -> int:
    """Maximum number of other clauses sharing a variable with a given clause."""
    best = 0
    for i, ci in enumerate(clauses):
        vi = {v for v, _ in ci}
        best = max(best, sum(1 for j, cj in enumerate(clauses)
                             if j != i and vi & {v for v, _ in cj}))
    return best


def demo_lll() -> None:
    print("=" * 74)
    print("7. THE SYMMETRIC LOCAL LEMMA AND THE CERTIFIED SEARCH")
    print("=" * 74)
    print("If P(A_i) <= p, |Gamma(i)| <= d and e*p*(d+1) <= 1, then some point of the")
    print("finite space avoids every bad event -- so exhaustive search cannot fail.")
    print()
    print("Threshold: the largest dependency degree d admissible for k-SAT (p = 2^-k):")
    print(f"{'k':>3} {'p = 2^-k':>12} {'max d with e p (d+1) <= 1':>28}")
    for k in range(3, 13):
        p = 2.0 ** (-k)
        d = 0
        while exp(1.0) * p * (d + 2) <= 1.0:
            d += 1
        print(f"{k:>3} {p:>12.6f} {d:>28}")
    print()
    # An explicit 4-CNF instance on 8 variables: four clauses on cyclically
    # overlapping windows, so each clause shares variables with exactly two
    # others.  With k = 4 the symmetric condition tolerates d up to 4.
    num_vars = 8
    clauses: List[Clause] = [
        ((0, True), (1, False), (2, True), (3, True)),
        ((2, False), (3, True), (4, True), (5, False)),
        ((4, True), (5, True), (6, False), (7, True)),
        ((6, True), (7, False), (0, False), (1, True)),
    ]
    d = dependency_degree(clauses)
    p, _, value, ok = lll_symmetric_certificate(4, d)
    print(f"Explicit 4-CNF instance: {len(clauses)} clauses on {num_vars} variables.")
    print(f"   p = {p}, d = {d}, e*p*(d+1) = {value:.4f}, "
          f"symmetric condition satisfied: {ok}")
    found, witness = search_avoiding(num_vars, clauses)
    print(f"   exhaustive search succeeded: {found}, witness = {witness}")
    print(f"   number of satisfying assignments: "
          f"{sum(1 for b in product([False, True], repeat=num_vars) if not any(clause_violated(c, b) for c in clauses))}"
          f" out of {2**num_vars}")
    print()
    # A sparse instance where the LLL condition genuinely holds.
    num_vars2 = 12
    clauses2: List[Clause] = [
        ((0, True), (1, False), (2, True), (3, True), (4, False), (5, True)),
        ((6, True), (7, True), (8, False), (9, True), (10, True), (11, False)),
    ]
    d2 = dependency_degree(clauses2)
    p2, _, value2, ok2 = lll_symmetric_certificate(6, d2)
    print(f"Sparse 6-CNF instance: {len(clauses2)} disjoint clauses, d = {d2}.")
    print(f"   p = {p2}, e*p*(d+1) = {value2:.5f}, condition satisfied: {ok2}")
    found2, witness2 = search_avoiding(num_vars2, clauses2)
    print(f"   exhaustive search succeeded: {found2}")
    print(f"   witness = {witness2}")
    print()


# ----------------------------------------------------------------------------

def main() -> None:
    print()
    print("THE PROBABILISTIC METHOD AS FINITE COUNTING")
    print("Erdos' existence proofs, executed as algorithms.")
    print()
    demo_ramsey_counting()
    demo_deletion()
    demo_sandwich()
    demo_caro_wei()
    demo_turan()
    demo_maxcut()
    demo_lll()
    print("=" * 74)
    print("All demonstrations completed; every assertion above was checked exactly.")
    print("=" * 74)


if __name__ == "__main__":
    main()
