#!/usr/bin/env python3
"""
Induced-universal posets: numerical demonstrations.
===================================================

A poset H is *induced-universal for size n* if every partial order on n points
occurs as an induced subposet of H:  there is a map f from the n points into H
with

        f(x) <= f(y)   in H     <==>     x <= y   in P.

U(n) denotes the least number of points of such a host.

This script demonstrates, by direct computation, every quantitative statement
of the accompanying paper:

  1.  The principal-ideal (Boolean) embedding:  U(n) <= 2^n,  and the sharper
      U(n) <= 2^n - 1 because the empty label is never used.
  2.  The counting lower bound  2^(kl) <= N^(k+l)  for hosts of the
      (k,l)-bipartite family, and its analytic form  N >= 2^(kl/(k+l)).
  3.  The tagged-neighbourhood host B(k,l) on  k + 2^k * l  points, verified
      exhaustively to contain every (k,l)-bipartite poset, and the necessity of
      the tag coordinate.
  4.  The overlap method:  incompatible posets force  N >= 2n - s;  the
      chain/antichain pair gives  U(n) >= 2n - 1, and adding a two-chain poset
      gives  U(n) >= 3n - ceil(n/2) - 3.
  5.  Exact small values  U(0)=0, U(1)=1, U(2)=3, U(3)=5, and  7 <= U(4) <= 8,
      including an exhaustive check that a specific 5-point host works for
      n = 3 and that no 4-point host does.
  6.  The geometric chain-union family, the Bonferroni bound for k posets, and
      the resulting superlinear bound  n*log_4(n) <= 6*U(n).
  7.  The full bound table, showing where the exponential counting bound
      overtakes the linear structural bounds.

Everything is self-contained: standard library only.
"""

from __future__ import annotations

from itertools import combinations, product
from math import floor, log, log10
from typing import Dict, FrozenSet, Iterator, List, Sequence, Set, Tuple

Relation = Tuple[Tuple[bool, ...], ...]  # r[x][y] means x <= y


def pow2_str(exponent: float) -> str:
    """Render 2**exponent in scientific notation without overflowing floats."""
    log10v = exponent * log10(2.0)
    e = floor(log10v)
    mant = 10.0 ** (log10v - e)
    return f"{mant:.3f}e+{e:03d}"


# --------------------------------------------------------------------------- #
# 0.  Basic poset machinery
# --------------------------------------------------------------------------- #

def is_partial_order(r: Relation) -> bool:
    """Reflexive, transitive, antisymmetric."""
    n = len(r)
    for x in range(n):
        if not r[x][x]:
            return False
    for x in range(n):
        for y in range(n):
            if x != y and r[x][y] and r[y][x]:
                return False
    for x in range(n):
        for y in range(n):
            if r[x][y]:
                for z in range(n):
                    if r[y][z] and not r[x][z]:
                        return False
    return True


def all_partial_orders(n: int) -> List[Relation]:
    """Every partial order on the labelled set {0,...,n-1}."""
    if n == 0:
        return [tuple()]
    orders: List[Relation] = []
    offdiag = [(x, y) for x in range(n) for y in range(n) if x != y]
    for bits in product([False, True], repeat=len(offdiag)):
        table = [[x == y for y in range(n)] for x in range(n)]
        for (x, y), b in zip(offdiag, bits):
            table[x][y] = b
        r: Relation = tuple(tuple(row) for row in table)
        if is_partial_order(r):
            orders.append(r)
    return orders


def is_induced_embedding(r: Relation, host: Relation, f: Sequence[int]) -> bool:
    """f realises r as an induced subposet of host."""
    n = len(r)
    return all(host[f[x]][f[y]] == r[x][y] for x in range(n) for y in range(n))


def hosts_all(host: Relation, n: int, orders: List[Relation] | None = None) -> bool:
    """Brute force: does `host` contain every n-element poset as an induced subposet?"""
    N = len(host)
    if orders is None:
        orders = all_partial_orders(n)
    for r in orders:
        if not any(is_induced_embedding(r, host, f) for f in product(range(N), repeat=n)):
            return False
    return True


# --------------------------------------------------------------------------- #
# 1.  The principal-ideal (Boolean) host
# --------------------------------------------------------------------------- #

def principal_ideals(r: Relation) -> List[FrozenSet[int]]:
    """The down-set labels  down(x) = {y : y <= x}."""
    n = len(r)
    return [frozenset(y for y in range(n) if r[y][x]) for x in range(n)]


def demo_boolean_host(n: int = 4) -> None:
    print("=" * 74)
    print("1.  PRINCIPAL-IDEAL (BOOLEAN) HOST:  U(n) <= 2^n - 1")
    print("=" * 74)
    orders = all_partial_orders(n)
    print(f"partial orders on {n} labelled points: {len(orders)}")
    all_ok = True
    empty_used = False
    labels_seen: Set[FrozenSet[int]] = set()
    for r in orders:
        ideals = principal_ideals(r)
        # injective?
        if len(set(ideals)) != n:
            all_ok = False
        # induced?
        for x in range(n):
            for y in range(n):
                if (ideals[x] <= ideals[y]) != r[x][y]:
                    all_ok = False
        labels_seen |= set(ideals)
        if frozenset() in ideals:
            empty_used = True
    print(f"  every order embedded by inclusion of down-sets : {all_ok}")
    print(f"  empty label ever used                          : {empty_used}")
    print(f"  distinct labels realised                       : {len(labels_seen)}"
          f"  (out of 2^{n} - 1 = {2**n - 1} nonempty subsets)")
    print(f"  => U({n}) <= 2^{n} - 1 = {2**n - 1}\n")


# --------------------------------------------------------------------------- #
# 2.  The counting lower bound
# --------------------------------------------------------------------------- #

def counting_bound(k: int, l: int) -> float:
    """Any (k,l)-bipartite-universal host has at least 2^(kl/(k+l)) points."""
    if k + l == 0:
        return 0.0
    return 2.0 ** (k * l / (k + l))


def demo_counting_bound() -> None:
    print("=" * 74)
    print("2.  COUNTING LOWER BOUND:  2^(kl) <= N^(k+l),  i.e.  N >= 2^(kl/(k+l))")
    print("=" * 74)
    print(f"{'k':>3} {'l':>3} {'#bipartite posets':>20} {'N >= 2^(kl/(k+l))':>20}")
    for k, l in [(1, 1), (2, 2), (3, 3), (4, 4), (5, 5), (8, 8), (16, 16), (25, 25)]:
        print(f"{k:>3} {l:>3} {'2^' + str(k*l):>20} {counting_bound(k, l):>20.3f}")
    print()
    print("Balanced case k = l = m, so n = 2m points:  N >= 2^(m/2) = 2^(n/4).")
    print("General n (split into floor(n/2) and ceil(n/2)):  log2 U(n) >= (n-1)/4.")
    print()
    print(f"{'n':>4} {'2^((n-1)/4)':>16} {'2n-1':>8} {'3n-ceil(n/2)-3':>16}")
    for n in [2, 4, 8, 12, 16, 20, 24, 28, 32, 40, 64]:
        print(f"{n:>4} {2.0**((n-1)/4):>16.2f} {2*n-1:>8} {3*n - (n+1)//2 - 3:>16}")
    print()


# --------------------------------------------------------------------------- #
# 3.  The tagged-neighbourhood host
# --------------------------------------------------------------------------- #

def bip_poset(k: int, l: int, R: FrozenSet[Tuple[int, int]]) -> Relation:
    """The (k,l)-bipartite poset:  points 0..k-1 low, k..k+l-1 high, a_i < b_j iff (i,j) in R."""
    n = k + l
    t = [[False] * n for _ in range(n)]
    for x in range(n):
        t[x][x] = True
    for i in range(k):
        for j in range(l):
            if (i, j) in R:
                t[i][k + j] = True
    return tuple(tuple(row) for row in t)


def tagged_neighbourhood_host(k: int, l: int) -> Tuple[Relation, List[str]]:
    """
    B(k,l):  k bottom points, plus all pairs (S, t) with S subset of [k], t in [l].
    Order:  bottom a <= (S,t) iff a in S; nothing else.  Size  k + 2^k * l.
    """
    points: List[Tuple[int, ...]] = []
    names: List[str] = []
    for i in range(k):
        points.append(("bot", i))            # type: ignore[arg-type]
        names.append(f"a{i}")
    for mask in range(1 << k):
        S = frozenset(i for i in range(k) if (mask >> i) & 1)
        for t in range(l):
            points.append(("top", mask, t))  # type: ignore[arg-type]
            names.append("({" + ",".join(f"a{i}" for i in sorted(S)) + "}," + str(t) + ")")
    N = len(points)
    tbl = [[False] * N for _ in range(N)]
    for x in range(N):
        tbl[x][x] = True
    for x in range(N):
        for y in range(N):
            px, py = points[x], points[y]
            if px[0] == "bot" and py[0] == "top":
                tbl[x][y] = bool((py[1] >> px[1]) & 1)
    return tuple(tuple(row) for row in tbl), names


def demo_tagged_host(k: int = 3, l: int = 3) -> None:
    print("=" * 74)
    print("3.  TAGGED-NEIGHBOURHOOD HOST  B(k,l)  ON  k + 2^k * l  POINTS")
    print("=" * 74)
    host, names = tagged_neighbourhood_host(k, l)
    N = len(host)
    print(f"k = {k}, l = {l}:  |B(k,l)| = k + 2^k*l = {k} + {2**k}*{l} = {N}")
    assert N == k + (1 << k) * l

    # exhaustively verify universality over all 2^(kl) bipartite posets
    pairs = [(i, j) for i in range(k) for j in range(l)]
    total = 0
    ok = 0
    for bits in product([0, 1], repeat=len(pairs)):
        R = frozenset(p for p, b in zip(pairs, bits) if b)
        P = bip_poset(k, l, R)
        # the canonical embedding of the theorem
        f: List[int] = list(range(k))
        for j in range(l):
            mask = sum(1 << i for i in range(k) if (i, j) in R)
            f.append(k + mask * l + j)
        total += 1
        if is_induced_embedding(P, host, f):
            ok += 1
    print(f"  canonical embedding verified for all {total} = 2^{k*l} bipartite posets: {ok == total}")

    # the tag is necessary
    R_empty: FrozenSet[Tuple[int, int]] = frozenset()
    f0 = k + 0 * l + 0
    f1 = k + 0 * l + 1 if l >= 2 else None
    print(f"  neighbourhoods of the two 'empty' top elements coincide, but their")
    print(f"  host points differ:  {names[f0]}  vs  {names[f1] if f1 else 'n/a'}")
    print("  => the tag coordinate is necessary (Proposition: necessity of the tag).")

    m = 4
    print()
    print(f"{'m (n=2m)':>10} {'2^(m/2) lower':>16} {'m*2^m+m upper':>16}")
    for m in [1, 2, 4, 8, 16, 32]:
        print(f"{m:>10} {2.0**(m/2):>16.2f} {m*2**m + m:>16}")
    print()


# --------------------------------------------------------------------------- #
# 4.  The overlap method
# --------------------------------------------------------------------------- #

def chain(n: int) -> Relation:
    return tuple(tuple(x <= y for y in range(n)) for x in range(n))


def antichain(n: int) -> Relation:
    return tuple(tuple(x == y for y in range(n)) for x in range(n))


def block_chains(n: int, d: int) -> Relation:
    """C_{n,d}: consecutive blocks of length d, each block a chain."""
    return tuple(tuple(x <= y and x // d == y // d for y in range(n)) for x in range(n))


def two_chains(n: int) -> Relation:
    """Disjoint union of a chain on the low ceil(n/2) points and a chain on the rest."""
    half = (n + 1) // 2
    return tuple(
        tuple(x <= y and ((x < half) == (y < half)) for y in range(n)) for x in range(n)
    )


def max_common_induced(r: Relation, s: Relation) -> int:
    """
    Brute-force size of the largest poset embedding as an induced subposet into BOTH
    r and s.  Exponential; only for tiny n.
    """
    n = len(r)
    best = 0
    for size in range(n, 0, -1):
        found = False
        for A in combinations(range(n), size):
            for phi in permutations_of(range(n), size):
                if all(
                    r[A[i]][A[j]] == s[phi[i]][phi[j]]
                    for i in range(size)
                    for j in range(size)
                ):
                    found = True
                    break
            if found:
                break
        if found:
            return size
    return best


def permutations_of(pool: range, size: int) -> Iterator[Tuple[int, ...]]:
    from itertools import permutations
    return permutations(pool, size)


def demo_overlap() -> None:
    print("=" * 74)
    print("4.  THE OVERLAP METHOD:  incompatible posets force  N >= 2n - s")
    print("=" * 74)
    print(f"{'n':>3} {'s(chain,antichain)':>20} {'2n-s':>8} {'s(chain,2-chains)':>20} "
          f"{'s(anti,2-chains)':>18} {'3-poset bound':>15}")
    for n in range(2, 7):
        c, a, d = chain(n), antichain(n), two_chains(n)
        s_ca = max_common_induced(c, a)
        s_cd = max_common_induced(c, d)
        s_ad = max_common_induced(a, d)
        three = 3 * n - (s_ca + s_cd + s_ad)
        print(f"{n:>3} {s_ca:>20} {2*n - s_ca:>8} {s_cd:>20} {s_ad:>18} {three:>15}")
    print()
    print("Theoretical bounds:  s(chain,antichain) = 1,  s(chain,2-chains) = ceil(n/2),")
    print("s(antichain,2-chains) = 2, giving  U(n) >= 3n - ceil(n/2) - 3.")
    print(f"{'n':>4} {'2n-1':>8} {'3n-ceil(n/2)-3':>16} {'max':>8}")
    for n in [2, 3, 4, 5, 6, 8, 10, 20, 50, 100]:
        a, b = 2 * n - 1, 3 * n - (n + 1) // 2 - 3
        print(f"{n:>4} {a:>8} {b:>16} {max(a, b):>8}")
    print()


# --------------------------------------------------------------------------- #
# 5.  Exact small values
# --------------------------------------------------------------------------- #

FIVE_POINT_HOST_FOR_N3 = None  # discovered by search below


def search_host(N: int, n: int, tries: int | None = None) -> Relation | None:
    """
    Search all partial orders on N points for one that is induced-universal for
    size n.  Feasible for N <= 5.
    """
    orders_n = all_partial_orders(n)
    for host in all_partial_orders(N):
        if hosts_all(host, n, orders_n):
            return host
    return None


def show_poset(r: Relation, label: str = "") -> None:
    n = len(r)
    covers = []
    for x in range(n):
        for y in range(n):
            if x != y and r[x][y]:
                # is it a cover?
                if not any(x != z and z != y and r[x][z] and r[z][y] for z in range(n)):
                    covers.append((x, y))
    print(f"  {label}({n} points)  cover relations: "
          + (", ".join(f"{x}<{y}" for x, y in covers) if covers else "none (antichain)"))


def demo_exact_small_values() -> None:
    print("=" * 74)
    print("5.  EXACT SMALL VALUES OF U(n)")
    print("=" * 74)

    # U(2) = 3 : B(1,1)
    host11, _ = tagged_neighbourhood_host(1, 1)
    print(f"U(2): B(1,1) has {len(host11)} points; universal for n=2: "
          f"{hosts_all(host11, 2)}")
    two_point_hosts = [h for h in all_partial_orders(2) if hosts_all(h, 2)]
    print(f"      any 2-point host universal for n=2? {len(two_point_hosts) > 0}")
    print("      => U(2) = 3   (counting bound only gives 2: already lossy)")

    # U(3) = 5
    print("U(3): searching all partial orders on 4 points ...")
    h4 = search_host(4, 3)
    print(f"      4-point host exists? {h4 is not None}")
    print("      searching all partial orders on 5 points ...")
    h5 = search_host(5, 3)
    print(f"      5-point host exists? {h5 is not None}")
    if h5 is not None:
        show_poset(h5, "found host: ")
    print("      => U(3) = 5")

    print("U(4): 2n-1 = 7 lower bound; an explicit 8-point host is known.")
    print("      => 7 <= U(4) <= 8   (exact value open)")
    print()
    print(f"{'n':>3} {'U(n)':>8}")
    for n, v in [(0, "0"), (1, "1"), (2, "3"), (3, "5"), (4, "7 or 8")]:
        print(f"{n:>3} {v:>8}")
    print()


# --------------------------------------------------------------------------- #
# 6.  The geometric family and superlinearity
# --------------------------------------------------------------------------- #

def chain_union_overlap(n: int, e: int, d: int) -> int:
    """Common induced bound for (C_{n,e}, C_{n,d}):  (#blocks of coarse) * (block size of fine)."""
    return ((n - 1) // e + 1) * d


def geometric_family_bound(k: int) -> Tuple[int, int, int]:
    """
    For n = 4^k and the family C_{n,4^i}, 0 <= i < k:
    returns (n, total overlap sum, resulting lower bound  k*n - overlaps).
    """
    n = 4 ** k
    total = 0
    for i in range(k):
        for j in range(i):
            total += min(chain_union_overlap(n, 4 ** i, 4 ** j), 4 ** (k - i) * 4 ** j)
    return n, total, k * n - total


def demo_superlinear() -> None:
    print("=" * 74)
    print("6.  GEOMETRIC CHAIN-UNION FAMILY:  n*log_4(n) <= 6*U(n)")
    print("=" * 74)
    print(f"{'k':>3} {'n = 4^k':>10} {'k*n':>14} {'overlap sum':>14} "
          f"{'bound k*n-ovl':>14} {'2k*4^k/3':>12}")
    for k in range(1, 9):
        n, ovl, bound = geometric_family_bound(k)
        print(f"{k:>3} {n:>10} {k*n:>14} {ovl:>14} {bound:>14} {2*k*4**k/3:>12.1f}")
    print()
    print("Certified:  2*k*4^k <= 3*U(4^k), hence  n*floor(log_4 n) <= 6*U(n).")
    print()
    print(f"{'n':>10} {'n*log4(n)/6':>14} {'2n-1':>10} {'3n-ceil(n/2)-3':>16} {'2^((n-1)/4)':>16}")
    for n in [4, 16, 64, 256, 1024, 4096, 16384]:
        lg = floor(log(n, 4) + 1e-9)
        print(f"{n:>10} {n*lg/6:>14.1f} {2*n-1:>10} {3*n-(n+1)//2-3:>16} "
              f"{pow2_str((n-1)/4):>16}")
    print()
    print("Threshold analysis: with ratio r the family bound is")
    print("      k*r^k * (1 - 1/(r-1))  <=  U(r^k),")
    print("nontrivial only for r > 2.  Values of the factor (1 - 1/(r-1)):")
    for r in [2, 3, 4, 5, 8, 16]:
        factor = 1 - 1 / (r - 1)
        print(f"      r = {r:>2}:  factor = {factor:+.4f}"
              + ("   <-- degenerate" if factor <= 0 else ""))
    print()


# --------------------------------------------------------------------------- #
# 7.  Full bound table
# --------------------------------------------------------------------------- #

def all_lower_bounds(n: int) -> Dict[str, float]:
    lg4 = floor(log(n, 4) + 1e-9) if n >= 1 else 0
    return {
        "2n-1": float(2 * n - 1),
        "3n-ceil(n/2)-3": float(3 * n - (n + 1) // 2 - 3),
        "n*log4(n)/6": n * lg4 / 6,
        "2^((n-1)/4)": 2.0 ** ((n - 1) / 4),
    }


def demo_bound_table() -> None:
    print("=" * 74)
    print("7.  THE FULL CORRIDOR:  best lower bound  <=  U(n)  <=  2^n - 1")
    print("=" * 74)
    hdr = f"{'n':>5} {'2n-1':>10} {'3n-n/2-3':>10} {'nlog4n/6':>12} {'2^((n-1)/4)':>14} " \
          f"{'BEST':>14} {'winner':>16} {'2^n - 1':>16}"
    print(hdr)
    for n in [2, 4, 8, 12, 16, 20, 24, 25, 26, 28, 32, 40, 64]:
        b = all_lower_bounds(n)
        best_name = max(b, key=lambda kk: b[kk])
        print(f"{n:>5} {b['2n-1']:>10.0f} {b['3n-ceil(n/2)-3']:>10.0f} "
              f"{b['n*log4(n)/6']:>12.1f} {b['2^((n-1)/4)']:>14.2f} "
              f"{b[best_name]:>14.2f} {best_name:>16} {pow2_str(n):>16}")
    print()
    print("Exponent corridor:   1/4  <=  limsup log2 U(n) / n  <=  1/2 + eta.")
    print("Lower end: counting.  Upper end: the labelling scheme of size 2^((1+eta)n/2).")
    print()
    print("Label lengths (bits per element) implied by the hosts:")
    print(f"{'n':>6} {'Boolean host':>14} {'exponent 1/2':>14} {'counting floor':>16}")
    for n in [16, 64, 256, 1024]:
        print(f"{n:>6} {n:>14} {n/2:>14.1f} {(n-1)/4:>16.2f}")
    print()


# --------------------------------------------------------------------------- #

def main() -> None:
    print()
    print("#" * 74)
    print("#  INDUCED-UNIVERSAL POSETS: NUMERICAL DEMONSTRATIONS".ljust(73) + "#")
    print("#" * 74)
    print()
    demo_boolean_host(n=4)
    demo_counting_bound()
    demo_tagged_host(k=3, l=3)
    demo_overlap()
    demo_exact_small_values()
    demo_superlinear()
    demo_bound_table()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
