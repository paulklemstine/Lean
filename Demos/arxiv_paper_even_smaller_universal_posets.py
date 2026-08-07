#!/usr/bin/env python3
"""
Universal Posets: numerical demonstrations
==========================================

A poset H is *universal* for the n-element posets if every partial order on n
points occurs as an INDUCED subposet of H, i.e. there is an injective map f with

        f(x) <= f(y)   <==>   x <= y      (for all x, y).

U(n) denotes the least number of points of such a host.  This script verifies,
by explicit finite computation, the quantitative results of the accompanying
paper:

  1. exhaustive enumeration of the partial orders on n <= 4 points (1, 1, 3, 19, 219);
  2. U(2) = 3 exactly (brute force over all hosts on <= 3 points);
  3. U(3) = 5 exactly: the diamond-plus-isolated-point host works, and no
     4-point host does;
  4. U(4) <= 8: an explicit 8-point host serves all 219 four-element posets,
     while the structural bound gives U(4) >= 7;
  5. the principal-ideal (Boolean) host: U(n) <= 2^n - 1, and every nonempty
     subset really occurs as a label;
  6. the tagged-neighbourhood host of size k + 2^k * l is (k,l)-bipartite
     universal, and the tag coordinate is necessary;
  7. the counting lower bound 2^{kl} <= N^{k+l}, its logarithmic form
     (n-1)/4 <= log2 U(n) <= n, and the crossover with the structural bounds;
  8. the overlap method: 2n-1, then 3n-ceil(n/2)-3, then the geometric
     block-chain family giving n*log_4(n) <= 6*U(n) -- and the degeneration of
     the same computation at ratio 2.

Self-contained: standard library only.
"""

from __future__ import annotations

from itertools import combinations, product
from math import log2
from typing import Dict, FrozenSet, Iterable, List, Sequence, Set, Tuple

# ----------------------------------------------------------------------------
# Representation
# ----------------------------------------------------------------------------
# A poset on {0, ..., n-1} is a tuple of n bitmasks: up[x] has bit y set iff
# x <= y.  This makes composition and comparison cheap.

Poset = Tuple[int, ...]


def leq(P: Poset, x: int, y: int) -> bool:
    """True iff x <= y in the poset P."""
    return (P[x] >> y) & 1 == 1


def is_partial_order(P: Poset) -> bool:
    """Reflexive, transitive, antisymmetric?"""
    n = len(P)
    for x in range(n):
        if not leq(P, x, x):
            return False
        for y in range(n):
            if leq(P, x, y):
                if x != y and leq(P, y, x):
                    return False  # antisymmetry
                for z in range(n):
                    if leq(P, y, z) and not leq(P, x, z):
                        return False  # transitivity
    return True


def all_posets(n: int) -> List[Poset]:
    """Every labelled partial order on {0,...,n-1}, by brute force over the
    n(n-1) off-diagonal bits."""
    off = [(i, j) for i in range(n) for j in range(n) if i != j]
    out: List[Poset] = []
    for bits in range(1 << len(off)):
        up = [1 << i for i in range(n)]  # reflexive part
        for b, (i, j) in enumerate(off):
            if (bits >> b) & 1:
                up[i] |= 1 << j
        P = tuple(up)
        if is_partial_order(P):
            out.append(P)
    return out


def embeds_induced(P: Poset, H: Poset) -> Tuple[bool, Sequence[int]]:
    """Is P an induced subposet of H?  Returns (yes/no, witness)."""
    n, N = len(P), len(H)
    assign: List[int] = []

    def rec(x: int) -> bool:
        if x == n:
            return True
        for h in range(N):
            if h in assign:
                continue
            ok = True
            for y, hy in enumerate(assign):
                if leq(H, h, hy) != leq(P, x, y) or leq(H, hy, h) != leq(P, y, x):
                    ok = False
                    break
            if ok:
                assign.append(h)
                if rec(x + 1):
                    return True
                assign.pop()
        return False

    found = rec(0)
    return found, tuple(assign)


def is_universal(H: Poset, family: Iterable[Poset]) -> bool:
    return all(embeds_induced(P, H)[0] for P in family)


# ----------------------------------------------------------------------------
# 1. Counting the partial orders
# ----------------------------------------------------------------------------

def demo_enumeration() -> Dict[int, List[Poset]]:
    print("=" * 74)
    print("1. Labelled partial orders on n points")
    print("=" * 74)
    fam: Dict[int, List[Poset]] = {}
    for n in range(5):
        fam[n] = all_posets(n)
        print(f"   n = {n}:  {len(fam[n]):5d} partial orders")
    print("   (the sequence 1, 1, 3, 19, 219 -- labelled posets)")
    print()
    return fam


# ----------------------------------------------------------------------------
# 2. U(2) = 3
# ----------------------------------------------------------------------------

def demo_U2(fam: Dict[int, List[Poset]]) -> None:
    print("=" * 74)
    print("2. U(2) = 3, exactly")
    print("=" * 74)
    for N in range(0, 4):
        hosts = [H for H in all_posets(N) if is_universal(H, fam[2])]
        print(f"   hosts on {N} points universal for the 2-element posets: {len(hosts)}")
        if hosts and N == 3:
            H = hosts[0]
            print(f"   e.g. up-sets {[bin(m) for m in H]}  "
                  f"(a 2-chain plus an isolated point)")
    print("   => U(2) = 3.  The counting bound only predicts U(2) >= 2:")
    print("      2^(k*l) <= N^(k+l) with k = l = 1 reads 2 <= N^2, i.e. N >= 2.")
    print()


# ----------------------------------------------------------------------------
# 3. U(3) = 5
# ----------------------------------------------------------------------------

def diamond_plus_point() -> Poset:
    """5 points: 4 < {2,3} < 1 (a diamond), and 0 isolated."""
    n = 5
    rel = {(4, 2), (4, 3), (4, 1), (2, 1), (3, 1)}
    up = [1 << i for i in range(n)]
    for (a, b) in rel:
        up[a] |= 1 << b
    return tuple(up)


def demo_U3(fam: Dict[int, List[Poset]]) -> None:
    print("=" * 74)
    print("3. U(3) = 5, exactly")
    print("=" * 74)
    H = diamond_plus_point()
    assert is_partial_order(H)
    ok = is_universal(H, fam[3])
    print(f"   diamond (4 < 2,3 < 1) plus isolated point 0 is a poset: True")
    print(f"   it contains all {len(fam[3])} three-element posets as induced "
          f"subposets: {ok}")
    four = [H4 for H4 in all_posets(4) if is_universal(H4, fam[3])]
    print(f"   four-point hosts universal for the 3-element posets: {len(four)}")
    print("   structural reason (no search needed): a 4-point host containing a")
    print("   3-chain has only 1 point left, so it cannot contain a 3-antichain;")
    print("   in general U(n) >= 2n - 1 (chain vs. antichain overlap <= 1).")
    print("   => U(3) = 5.")
    print()


# ----------------------------------------------------------------------------
# 4. U(4) <= 8 via an explicit host
# ----------------------------------------------------------------------------

HOST8_ROWS: Tuple[int, ...] = (251, 226, 132, 232, 80, 96, 64, 128)


def host8() -> Poset:
    """The explicit 8-point host: row i is the bitmask of {j : i <= j}."""
    return HOST8_ROWS


def demo_U4(fam: Dict[int, List[Poset]]) -> None:
    print("=" * 74)
    print("4. 7 <= U(4) <= 8")
    print("=" * 74)
    H = host8()
    print(f"   host rows (up-set bitmasks): {list(H)}")
    print(f"   is a partial order: {is_partial_order(H)}")
    bad = [P for P in fam[4] if not embeds_induced(P, H)[0]]
    print(f"   four-element posets NOT embedding: {len(bad)}  "
          f"(out of {len(fam[4])})")
    print(f"   => U(4) <= 8;  and U(4) >= 2*4 - 1 = 7 by the overlap bound.")
    P = fam[4][len(fam[4]) // 2]
    ok, w = embeds_induced(P, H)
    print(f"   sample witness for one poset: f = {list(w)}  (induced: {ok})")
    print()


# ----------------------------------------------------------------------------
# 5. The Boolean / principal-ideal host
# ----------------------------------------------------------------------------

def ideal_labels(P: Poset) -> List[int]:
    """iota(x) = {y : y <= x}, as a bitmask."""
    n = len(P)
    return [sum(1 << y for y in range(n) if leq(P, y, x)) for x in range(n)]


def demo_ideal_host(fam: Dict[int, List[Poset]]) -> None:
    print("=" * 74)
    print("5. The principal-ideal host:  U(n) <= 2^n - 1")
    print("=" * 74)
    for n in range(1, 5):
        used: Set[int] = set()
        good = True
        for P in fam[n]:
            lab = ideal_labels(P)
            used.update(lab)
            for x in range(n):
                for y in range(n):
                    # inclusion of ideals must match the order exactly
                    if ((lab[x] & ~lab[y]) == 0) != leq(P, x, y):
                        good = False
        print(f"   n = {n}: ideal labelling is induced for all "
              f"{len(fam[n]):3d} posets: {good};  "
              f"distinct labels used = {len(used):3d} = 2^{n} - 1 "
              f"= {2**n - 1}: {len(used) == 2**n - 1}")
    print("   The empty label is never used (x is always in its own ideal), so")
    print("   the empty set may be deleted: U(n) <= 2^n - 1 < 2^n, always.")
    print("   And every nonempty subset IS used, so no further deletion is")
    print("   possible for this labelling scheme.")
    print()


# ----------------------------------------------------------------------------
# 6. The tagged-neighbourhood host for bipartite posets
# ----------------------------------------------------------------------------

def bipartite_poset(k: int, l: int, R: Sequence[Sequence[int]]) -> Poset:
    """B_R on k+l points: 0..k-1 bottom, k..k+l-1 top, a < b iff R[a][b]."""
    n = k + l
    up = [1 << i for i in range(n)]
    for a in range(k):
        for b in range(l):
            if R[a][b]:
                up[a] |= 1 << (k + b)
    return tuple(up)


def tagged_host(k: int, l: int) -> Tuple[Poset, List[str]]:
    """k bottom points, then all pairs (S, j) with S subset of [k], j < l."""
    points: List[Tuple[int, int]] = [(-1, a) for a in range(k)]  # bottom a
    for S in range(1 << k):
        for j in range(l):
            points.append((S, j))
    N = len(points)
    up = [1 << i for i in range(N)]
    for i, pi in enumerate(points):
        if pi[0] != -1:
            continue
        a = pi[1]
        for j2, pj in enumerate(points):
            if pj[0] != -1 and (pj[0] >> a) & 1:
                up[i] |= 1 << j2
    names = [f"bot{p[1]}" if p[0] == -1 else f"({bin(p[0])[2:].zfill(k)},{p[1]})"
             for p in points]
    return tuple(up), names


def demo_tagged_host() -> None:
    print("=" * 74)
    print("6. The tagged-neighbourhood host: size k + 2^k * l, exponent n/2")
    print("=" * 74)
    for (k, l) in [(1, 1), (2, 2), (3, 2), (2, 3)]:
        H, names = tagged_host(k, l)
        assert is_partial_order(H)
        size = len(H)
        # check every bipartite relation embeds, by the explicit formula
        allR = list(product([0, 1], repeat=k * l))
        ok = True
        for flat in allR:
            R = [[flat[a * l + b] for b in range(l)] for a in range(k)]
            P = bipartite_poset(k, l, R)
            # explicit embedding: bottom a -> bot a; top b -> (N_R(b), b)
            f: List[int] = list(range(k))
            for b in range(l):
                S = sum(1 << a for a in range(k) if R[a][b])
                f.append(k + S * l + b)
            for x in range(k + l):
                for y in range(k + l):
                    if leq(H, f[x], f[y]) != leq(P, x, y):
                        ok = False
        print(f"   (k,l) = ({k},{l}): host size {size} = {k} + 2^{k}*{l};  "
              f"all {len(allR)} bipartite posets embed via the explicit "
              f"formula: {ok}")
    print()
    print("   Balanced case n = 2m -> size m*2^m + m, i.e. exponent n/2,")
    print("   matching the exponent of the best asymptotic construction, while")
    print("   the counting bound on the same class gives only 2^{n/4}:")
    print(f"   {'m':>3} {'n=2m':>5} {'lower 2^(n/4)':>15} {'host m*2^m+m':>15}")
    for m in (2, 4, 8, 16, 32):
        print(f"   {m:>3} {2*m:>5} {2**(m/2):>15.3e} {m*2**m + m:>15.3e}")
    print()
    print("   The tag is necessary: in ANY host for the (k,2)-bipartite posets,")
    print("   the two top points of the all-incomparable relation get distinct")
    print("   host points -- an induced embedding is injective -- yet they have")
    print("   the same down-set.  Down-sets alone cannot separate twins.")
    print()


# ----------------------------------------------------------------------------
# 7. Counting bound, logarithmic form, crossover
# ----------------------------------------------------------------------------

def counting_lower_bound(n: int) -> float:
    """2^{floor(n/2)*ceil(n/2)/n} <= U(n)."""
    k, l = n // 2, n - n // 2
    return 2.0 ** (k * l / n)


def structural_bound_2n1(n: int) -> int:
    return max(0, 2 * n - 1)


def structural_bound_three(n: int) -> int:
    return max(0, 3 * n - (3 + (n + 1) // 2))


def geometric_bound(n: int) -> float:
    """n*log_4(n) <= 6*U(n)."""
    if n < 2:
        return 0.0
    return n * (log2(n) / 2) / 6


def demo_bounds() -> None:
    print("=" * 74)
    print("7. All lower bounds against each other, and the crossover")
    print("=" * 74)
    print(f"   {'n':>4} {'2n-1':>8} {'3n-ce(n/2)-3':>14} {'n log4 n / 6':>14}"
          f" {'2^(kl/n)':>14} {'2^n - 1':>14}")
    for n in [2, 3, 4, 5, 6, 8, 10, 16, 20, 24, 32, 40, 64]:
        print(f"   {n:>4} {structural_bound_2n1(n):>8}"
              f" {structural_bound_three(n):>14}"
              f" {geometric_bound(n):>14.1f}"
              f" {counting_lower_bound(n):>14.3e}"
              f" {2.0**n - 1:>14.3e}")
    print()
    print("   Logarithmic sandwich  (n-1)/4 <= log2 U(n) <= n:")
    print(f"   {'n':>4} {'(n-1)/4':>10} {'kl/n (exact)':>14} {'n':>6}")
    for n in [1, 2, 3, 4, 10, 40, 100]:
        k, l = n // 2, n - n // 2
        print(f"   {n:>4} {(n - 1) / 4:>10.3f} {k * l / n:>14.3f} {n:>6}")
    print()
    cross_lin = next(n for n in range(2, 400)
                     if counting_lower_bound(n) > structural_bound_three(n))
    print(f"   The counting bound overtakes the best linear bound at n = {cross_lin}.")
    first6 = next(n for n in range(1, 50)
                  if structural_bound_three(n) > structural_bound_2n1(n))
    print(f"   The three-poset bound overtakes 2n-1 at n = {first6}.")
    print()


# ----------------------------------------------------------------------------
# 8. The overlap method, and the ratio-2 threshold
# ----------------------------------------------------------------------------

def block_chains(n: int, d: int) -> Poset:
    """Disjoint union of chains: x <= y iff x <= y and x//d == y//d."""
    up = [1 << i for i in range(n)]
    for x in range(n):
        for y in range(n):
            if x <= y and x // d == y // d:
                up[x] |= 1 << y
    return tuple(up)


def max_common_induced(P: Poset, Q: Poset) -> int:
    """Largest A that sits order-isomorphically inside both P and Q
    (brute force; only for tiny n)."""
    n = len(P)
    best = 0
    for size in range(n, 0, -1):
        if size <= best:
            break
        for A in combinations(range(n), size):
            for phi in combinations(range(n), size):
                for perm in _perms(phi):
                    ok = True
                    for i, x in enumerate(A):
                        for j, y in enumerate(A):
                            if leq(P, x, y) != leq(Q, perm[i], perm[j]):
                                ok = False
                                break
                        if not ok:
                            break
                    if ok:
                        best = max(best, size)
                        break
                if best == size:
                    break
            if best == size:
                break
    return best


def _perms(t: Sequence[int]) -> Iterable[Tuple[int, ...]]:
    from itertools import permutations
    return permutations(t)


def demo_overlap() -> None:
    print("=" * 74)
    print("8. The overlap method")
    print("=" * 74)
    n = 6
    chain = block_chains(n, n)
    anti = block_chains(n, 1)
    print(f"   n = {n}: chain vs antichain, largest common induced "
          f"configuration = {max_common_induced(chain, anti)}  (theory: 1)")
    print(f"   => U({n}) >= 2*{n} - 1 = {2*n-1}")
    two = block_chains(n, (n + 1) // 2)
    print(f"   chain vs two-chains: {max_common_induced(chain, two)}  "
          f"(theory: ceil(n/2) = {(n+1)//2})")
    print(f"   antichain vs two-chains: {max_common_induced(anti, two)}  "
          f"(theory: 2)")
    print(f"   => U({n}) >= 3*{n} - (3 + {(n+1)//2}) = "
          f"{structural_bound_three(n)}")
    print()
    print("   Geometric family:  P_i = block chains of size r^i inside n = r^k.")
    print("   Pairwise overlap bound  s_ij = r^{k-i} * r^j  for j < i.")
    print(f"   {'ratio r':>8} {'k':>3} {'n = r^k':>10} {'gain k*n':>12}"
          f" {'total overlap':>14} {'bound':>12}")
    for r in (2, 3, 4, 5):
        for k in (3, 5):
            n_ = r ** k
            gain = k * n_
            overlap = sum(r ** (k - i) * r ** j
                          for i in range(k) for j in range(i))
            print(f"   {r:>8} {k:>3} {n_:>10} {gain:>12} {overlap:>14}"
                  f" {max(0, gain - overlap):>12}")
    print()
    print("   At ratio 2 the surviving bound is exactly 2^(k+1) - 2 = 2n - 2,")
    print("   independent of k: no superlinear gain at all.  Ratio 2 is the")
    print("   threshold of the method.")
    print("   Ratio 4 keeps two thirds of the gain: 2*k*4^k <= 3*U(4^k),")
    print("   hence n*log_4(n) <= 6*U(n) and U(n)/n -> infinity.")
    print(f"   {'k':>3} {'n = 4^k':>10} {'2k*4^k/3 <= U(n)':>20}")
    for k in range(1, 9):
        n_ = 4 ** k
        print(f"   {k:>3} {n_:>10} {2 * k * n_ / 3:>20.1f}")
    print()


# ----------------------------------------------------------------------------
# 9. Strict monotonicity, illustrated
# ----------------------------------------------------------------------------

def demo_strict_mono(fam: Dict[int, List[Poset]]) -> None:
    print("=" * 74)
    print("9. Deleting a maximal point:  U(n) < U(n+1)")
    print("=" * 74)
    H = diamond_plus_point()  # universal for n = 3, 5 points
    n = 5
    maximal = [x for x in range(n)
               if all(y == x for y in range(n) if leq(H, x, y))]
    print(f"   the 5-point host universal for the 3-element posets has maximal "
          f"points {maximal}")
    for m in maximal:
        keep = [x for x in range(n) if x != m]
        idx = {x: i for i, x in enumerate(keep)}
        up = [sum(1 << idx[y] for y in keep if leq(H, x, y)) for x in keep]
        H2 = tuple(up)
        ok = is_universal(H2, fam[2])
        print(f"   delete maximal point {m}: the remaining 4-point poset is "
              f"universal for the 2-element posets: {ok}")
    print("   In general: adjoin a global top to an n-element poset; inside a")
    print("   host for the (n+1)-element posets the image of the top lies")
    print("   strictly above the other n images, so none of them is a maximal")
    print("   point of the host.  Delete it:  U(n) <= U(n+1) - 1.")
    print()


# ----------------------------------------------------------------------------
# 10. Comparability graphs
# ----------------------------------------------------------------------------

def comparability_edges(P: Poset) -> FrozenSet[FrozenSet[int]]:
    n = len(P)
    return frozenset(frozenset((x, y)) for x in range(n) for y in range(n)
                     if x != y and (leq(P, x, y) or leq(P, y, x)))


def demo_comparability() -> None:
    print("=" * 74)
    print("10. The comparability bridge: height two loses nothing")
    print("=" * 74)
    k, l = 2, 3
    seen: Set[FrozenSet[FrozenSet[int]]] = set()
    for flat in product([0, 1], repeat=k * l):
        R = [[flat[a * l + b] for b in range(l)] for a in range(k)]
        P = bipartite_poset(k, l, R)
        E = comparability_edges(P)
        expected = frozenset(frozenset((a, k + b)) for a in range(k)
                             for b in range(l) if R[a][b])
        assert E == expected, "comparability graph must equal the bipartite graph"
        seen.add(E)
    print(f"   (k,l) = ({k},{l}): the comparability graph of B_R equals the")
    print(f"   bipartite graph of R, for all {2**(k*l)} relations, and the map")
    print(f"   R -> Comp(B_R) is injective: {len(seen)} distinct graphs "
          f"= 2^(k*l) = {2**(k*l)}")
    print("   Hence the poset counting bound 2^{kl} <= N^{k+l} is exactly the")
    print("   graph counting bound, and regularity-based graph technology")
    print("   applies to height-two posets with no loss.  For general posets")
    print("   the comparability graph forgets orientation, which is why any")
    print("   graph construction must be re-oriented afterwards.")
    print()


# ----------------------------------------------------------------------------

def main() -> None:
    print()
    print("#" * 74)
    print("#  UNIVERSAL POSETS -- numerical demonstrations".ljust(73) + "#")
    print("#" * 74)
    print()
    fam = demo_enumeration()
    demo_U2(fam)
    demo_U3(fam)
    demo_U4(fam)
    demo_ideal_host(fam)
    demo_tagged_host()
    demo_bounds()
    demo_overlap()
    demo_strict_mono(fam)
    demo_comparability()
    print("=" * 74)
    print("SUMMARY")
    print("=" * 74)
    print("   U(0)=0, U(1)=1, U(2)=3, U(3)=5, 7 <= U(4) <= 8")
    print("   max(3n - ceil(n/2) - 3,  n*log_4(n)/6,  2^((n-1)/4))"
          " <= U(n) <= 2^n - 1")
    print("   U is strictly increasing; on the balanced bipartite class an")
    print("   explicit host of size m*2^m + m attains exponent n/2, while")
    print("   counting gives only 2^{n/4}.  The gap is a factor 2 in the")
    print("   exponent, and it is open.")
    print()


if __name__ == "__main__":
    main()
