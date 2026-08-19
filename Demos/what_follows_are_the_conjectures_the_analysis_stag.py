"""
Sidon sets in intervals and in cyclic groups: numerical demonstrations.
=======================================================================

A finite set A of integers (or of residues) is a *Sidon set* (a B_2-set) when

        a + b = c + d   with a, b, c, d in A   implies   {a, b} = {c, d}.

Equivalently, all differences of distinct elements are pairwise distinct: a
"perfect ruler" on which no two pairs of marks are the same distance apart.

This script demonstrates, purely numerically, every quantitative statement of
the accompanying paper:

  1. The Erdos-Turan construction  A_p = {2pk + (k^2 mod p) : 0 <= k < p}
     is a Sidon set of size p inside {0, ..., 2p^2 - 1}.
  2. THE MAIN RESULT: A_p is still Sidon *modulo 2p^2*, i.e. in the cyclic
     group Z/2p^2 Z, where sums wrap around.
  3. SHARPNESS: A_p is NOT Sidon modulo 2p^2 + 1 -- the phenomenon is a
     knife edge in the modulus.
  4. The counting characterisations |A+A| = C(|A|+1, 2) and
     |A-A| = |A|^2 - |A| + 1.
  5. The interval sandwich  sqrt(N/8) < F(N) <= sqrt(2N) + 1  for N >= 32,
     checked against exhaustively computed exact values of F(N).
  6. The cyclic sandwich  sqrt(N/16) < maxSidon(Z/NZ) <= sqrt(N) + 1
     for N >= 64, via the transfer principle plus Bertrand's postulate.
  7. Perfect difference sets: {0, 1, 3, 9} in Z/13Z hits every nonzero
     residue exactly once, and the order constraint |G| = k^2 - k + 1.
  8. Affine invariance of the Sidon property.

Self-contained: standard library only.
"""

from __future__ import annotations

import math
from itertools import combinations_with_replacement, combinations
from typing import Dict, List, Optional, Set, Tuple

# ---------------------------------------------------------------------------
# 0. Core predicates
# ---------------------------------------------------------------------------


def pairwise_sums(a: List[int], modulus: Optional[int] = None) -> List[int]:
    """All C(|A|+1, 2) unordered pairwise sums a_i + a_j (i <= j), optionally
    reduced modulo `modulus`."""
    sums = [x + y for x, y in combinations_with_replacement(sorted(a), 2)]
    if modulus is not None:
        sums = [s % modulus for s in sums]
    return sums


def is_sidon(a: List[int], modulus: Optional[int] = None) -> bool:
    """Test the Sidon property.

    By the sumset characterisation, A is Sidon exactly when its C(|A|+1, 2)
    unordered pairwise sums are pairwise distinct.  Runs in O(|A|^2).
    """
    sums = pairwise_sums(a, modulus)
    return len(set(sums)) == len(sums)


def sidon_violation(
    a: List[int], modulus: Optional[int] = None
) -> Optional[Tuple[Tuple[int, int], Tuple[int, int], int]]:
    """Return an explicit certificate of failure ((u,v), (w,x), common sum),
    or None if the set is Sidon."""
    seen: Dict[int, Tuple[int, int]] = {}
    for x, y in combinations_with_replacement(sorted(a), 2):
        s = (x + y) % modulus if modulus is not None else x + y
        if s in seen:
            return (seen[s], (x, y), s)
        seen[s] = (x, y)
    return None


def difference_set(a: List[int], modulus: Optional[int] = None) -> Set[int]:
    """The set of differences of *distinct* elements (never contains 0 for a
    set of distinct integers in Z; in Z/NZ it never contains 0 either)."""
    out: Set[int] = set()
    for x, y in combinations(sorted(a), 2):
        d, e = x - y, y - x
        if modulus is not None:
            d, e = d % modulus, e % modulus
        out.add(d)
        out.add(e)
    return out


# ---------------------------------------------------------------------------
# 1. The Erdos-Turan construction
# ---------------------------------------------------------------------------


def is_prime(n: int) -> bool:
    if n < 2:
        return False
    if n % 2 == 0:
        return n == 2
    f = 3
    while f * f <= n:
        if n % f == 0:
            return False
        f += 2
    return True


def erdos_turan_set(p: int) -> List[int]:
    """A_p = {2pk + (k^2 mod p) : 0 <= k < p}.

    In base 2p this stores the linear datum k in the high digit and the
    quadratic datum k^2 mod p in the low digit; since both are < p < 2p,
    adding two elements never produces a carry.
    """
    return [2 * p * k + (k * k) % p for k in range(p)]


def demo_construction() -> None:
    print("=" * 78)
    print("1.  THE ERDOS-TURAN CONSTRUCTION   A_p = {2pk + (k^2 mod p)}")
    print("=" * 78)
    print(f"{'p':>4} {'|A_p|':>6} {'max':>7} {'2p^2':>7} {'Sidon in Z':>12}")
    for p in [3, 5, 7, 11, 13, 17, 19, 23]:
        a = erdos_turan_set(p)
        print(f"{p:>4} {len(a):>6} {max(a):>7} {2*p*p:>7} {str(is_sidon(a)):>12}")
    print()
    print("  A_3  =", erdos_turan_set(3), "   (inside {0,...,17})")
    print("  A_5  =", erdos_turan_set(5), "   (inside {0,...,49})")
    print("  A_7  =", erdos_turan_set(7))
    print()
    print("  Composite moduli break it (Z/pZ is then not a field):")
    for p in [4, 9]:
        a = erdos_turan_set(p)
        v = sidon_violation(a)
        print(f"    p = {p}: set {a} -> violation {v[0]} and {v[1]} both sum to {v[2]}")
    print()


# ---------------------------------------------------------------------------
# 2 & 3.  MAIN RESULT: Sidon modulo 2p^2, and sharpness of the modulus
# ---------------------------------------------------------------------------


def demo_cyclic_main_theorem() -> None:
    print("=" * 78)
    print("2.  MAIN THEOREM:  A_p is Sidon MODULO 2p^2  (wrap-around is harmless)")
    print("3.  SHARPNESS:     A_p is NOT Sidon modulo 2p^2 + 1")
    print("=" * 78)
    print(f"{'p':>4} {'N = 2p^2':>9} {'Sidon mod N':>13} {'Sidon mod N+1':>15}")
    for p in [3, 5, 7, 11, 13, 17, 19, 23, 29, 31]:
        a = erdos_turan_set(p)
        n = 2 * p * p
        print(
            f"{p:>4} {n:>9} {str(is_sidon(a, n)):>13} {str(is_sidon(a, n + 1)):>15}"
        )
    print()
    print("  Explicit failure certificates at modulus 2p^2 + 1:")
    for p in [3, 5, 7]:
        a = erdos_turan_set(p)
        v = sidon_violation(a, 2 * p * p + 1)
        print(
            f"    p = {p} (mod {2*p*p+1}):  {v[0][0]} + {v[0][1]} = "
            f"{v[1][0]} + {v[1][1]} = {v[2]}  (mod {2*p*p+1})"
        )
    print()
    print("  Why 2p^2 is safe: 2p^2 = (2p) * p, so adding the modulus shifts the")
    print("  HIGH base-2p digit by exactly p and leaves the low digit alone.  The")
    print("  construction's rigidity pins the high-digit sum exactly, so a clean")
    print("  digit shift is contradictory.  At 2p^2 + 1 the shift is no longer")
    print("  clean and the collision is realised.")
    print()


# ---------------------------------------------------------------------------
# 4. Counting characterisations
# ---------------------------------------------------------------------------


def demo_counting() -> None:
    print("=" * 78)
    print("4.  COUNTING CHARACTERISATIONS")
    print("      A Sidon  <=>  |A+A| = C(|A|+1, 2)      and  |A-A| = |A|^2-|A|+1")
    print("=" * 78)
    print(f"{'p':>4} {'k=|A|':>6} {'|A+A|':>7} {'C(k+1,2)':>9} {'|A-A|':>7} {'k^2-k+1':>9}")
    for p in [3, 5, 7, 11, 13]:
        a = erdos_turan_set(p)
        k = len(a)
        n = 2 * p * p
        sumset = {(x + y) % n for x, y in combinations_with_replacement(a, 2)}
        diffs = difference_set(a, n) | {0}
        print(
            f"{p:>4} {k:>6} {len(sumset):>7} {k*(k+1)//2:>9} "
            f"{len(diffs):>7} {k*k-k+1:>9}"
        )
    print()
    print("  A NON-Sidon set falls short of both maxima:")
    bad = [0, 1, 2, 3]
    k = len(bad)
    print(
        f"    A = {bad}:  |A+A| = {len({x+y for x,y in combinations_with_replacement(bad,2)})}"
        f"  <  C(5,2) = {k*(k+1)//2};   Sidon? {is_sidon(bad)}"
    )
    print()


# ---------------------------------------------------------------------------
# 5. Exact maxima on an interval, and the interval sandwich
# ---------------------------------------------------------------------------


def max_sidon_interval(n: int) -> Tuple[int, List[int]]:
    """Exact F(n) = largest Sidon subset of {0, ..., n-1}, by depth-first search
    with difference-collision pruning.  Exponential in the worst case; fine for
    n up to ~40."""
    best: List[int] = []

    def extend(current: List[int], diffs: Set[int], start: int) -> None:
        nonlocal best
        if len(current) > len(best):
            best = list(current)
        # optimistic bound: at most this many further marks can help
        if len(current) + (n - start) <= len(best):
            return
        for x in range(start, n):
            new = {x - y for y in current}
            if len(new) == len(current) and not (new & diffs):
                extend(current + [x], diffs | new, x + 1)

    extend([], set(), 0)
    return len(best), best


def demo_interval_sandwich() -> None:
    print("=" * 78)
    print("5.  THE INTERVAL SANDWICH   sqrt(N/8) < F(N) <= sqrt(2N) + 1   (N >= 32)")
    print("=" * 78)
    print(f"{'N':>5} {'lower':>7} {'F(N)':>6} {'upper':>7} {'witness'}")
    for n in [18, 24, 32, 36, 40]:
        f, witness = max_sidon_interval(n)
        lo = math.isqrt(n // 8)
        hi = math.isqrt(2 * n) + 1
        flag = "OK" if (n < 32 or lo < f <= hi) else "VIOLATION"
        print(f"{n:>5} {lo:>7} {f:>6} {hi:>7} {witness}  [{flag}]")
    print()
    print("  Asymptotic check of the sandwich against the construction only:")
    print(f"{'N':>9} {'sqrt(N/8)':>11} {'ET size':>9} {'sqrt(2N)+1':>11}")
    for p in [11, 31, 101, 311, 1009]:
        n = 2 * p * p
        print(
            f"{n:>9} {math.isqrt(n//8):>11} {p:>9} {math.isqrt(2*n)+1:>11}"
        )
    print()


# ---------------------------------------------------------------------------
# 6. Transfer principle and the general cyclic sandwich
# ---------------------------------------------------------------------------


def next_prime_above(m: int) -> int:
    """Least prime > m.  Bertrand's postulate guarantees it is <= 2m for m >= 1."""
    q = m + 1
    while not is_prime(q):
        q += 1
    return q


def large_sidon_in_cyclic(n: int) -> List[int]:
    """A Sidon set in Z/nZ of size > sqrt(n/16), for n >= 64.

    Take m = floor(sqrt(n/16)), a prime p in (m, 2m] by Bertrand, and reduce
    the Erdos-Turan set A_p (which lives in {0, ..., 2p^2-1} with 2*(2p^2) <= n)
    modulo n.  The transfer principle applies because n >= 2 * (2p^2).
    """
    m = math.isqrt(n // 16)
    p = next_prime_above(m)
    return sorted({x % n for x in erdos_turan_set(p)})


def demo_cyclic_sandwich() -> None:
    print("=" * 78)
    print("6.  THE CYCLIC SANDWICH   sqrt(N/16) < maxSidon(Z/NZ) <= sqrt(N)+1")
    print("=" * 78)
    print(f"{'N':>7} {'lower':>6} {'built':>6} {'upper':>6} {'Sidon?':>8} {'p used':>7}")
    for n in [64, 100, 200, 500, 1000, 5000, 20000]:
        a = large_sidon_in_cyclic(n)
        lo = math.isqrt(n // 16)
        hi = math.isqrt(n) + 1
        ok = is_sidon(a, n) and lo < len(a) <= hi
        print(
            f"{n:>7} {lo:>6} {len(a):>6} {hi:>6} {str(is_sidon(a, n)):>8} "
            f"{len(a):>7}   [{'OK' if ok else 'VIOLATION'}]"
        )
    print()
    print("  On the special moduli N = 2p^2 the main theorem gives a much tighter")
    print("  sandwich, of ratio sqrt(2) instead of 4, with NO transfer loss:")
    print(f"{'N=2p^2':>9} {'sqrt(N/2)=p':>12} {'sqrt(N)+1':>10} {'ratio':>7}")
    for p in [11, 31, 101, 311]:
        n = 2 * p * p
        print(f"{n:>9} {p:>12} {math.isqrt(n)+1:>10} {(math.isqrt(n)+1)/p:>7.3f}")
    print()


# ---------------------------------------------------------------------------
# 7. Perfect difference sets
# ---------------------------------------------------------------------------


def demo_perfect_difference_sets() -> None:
    print("=" * 78)
    print("7.  PERFECT DIFFERENCE SETS:  differences exhaust G \\ {0}")
    print("      Rigidity:  perfect  <=>  k^2 - k = |G| - 1,  forcing |G| = k^2-k+1")
    print("=" * 78)
    a = [0, 1, 3, 9]
    n = 13
    diffs = difference_set(a, n)
    k = len(a)
    print(f"  A = {a}  in  Z/{n}Z,  k = {k},  k^2 - k + 1 = {k*k-k+1}")
    print(f"  Sidon?          {is_sidon(a, n)}")
    print(f"  |D(A)| = {len(diffs)},  |G| - 1 = {n-1}   ->  perfect: {len(diffs)==n-1}")
    print("  Unique representation of every nonzero residue as a - b:")
    for g in range(1, n):
        reps = [(x, y) for x in a for y in a if x != y and (x - y) % n == g]
        assert len(reps) == 1, (g, reps)
        print(f"      {g:>2} = {reps[0][0]} - {reps[0][1]}", end="")
        if g % 4 == 0:
            print()
    print()
    print()
    print("  Other perfect difference sets (searched exhaustively):")
    for k in [3, 4, 5, 6]:
        n = k * k - k + 1
        found = None
        for cand in combinations(range(1, n), k - 1):
            s = [0] + list(cand)
            if len(difference_set(s, n)) == n - 1:
                found = s
                break
        print(f"    k = {k}, |G| = {n}:  {found}   Sidon? {is_sidon(found, n)}")
    print()
    print("  The Erdos-Turan set is NEVER perfect in its own group Z/2p^2 Z:")
    print(f"{'p':>4} {'|D(A)| = p^2-p':>15} {'|G|-1 = 2p^2-1':>16} {'perfect?':>10}")
    for p in [3, 5, 7, 11]:
        a = erdos_turan_set(p)
        n = 2 * p * p
        d = len(difference_set(a, n))
        print(f"{p:>4} {d:>15} {n-1:>16} {str(d == n-1):>10}")
    print("  (Also forced structurally: k^2-k+1 is odd, while 2p^2 is even.)")
    print()


# ---------------------------------------------------------------------------
# 8. Affine invariance
# ---------------------------------------------------------------------------


def demo_affine_invariance() -> None:
    print("=" * 78)
    print("8.  AFFINE INVARIANCE:  translation and dilation by a unit preserve Sidon")
    print("=" * 78)
    p, n = 7, 98
    a = erdos_turan_set(p)
    print(f"  Base set A_7 mod {n}: {sorted(x % n for x in a)}  Sidon? {is_sidon(a, n)}")
    for t in [1, 5, 40]:
        b = sorted((x + t) % n for x in a)
        print(f"    translate by {t:>3}: {b}  Sidon? {is_sidon(b, n)}")
    for u in [3, 5, 9]:  # units mod 98
        assert math.gcd(u, n) == 1
        b = sorted((u * x) % n for x in a)
        print(f"    dilate  by {u:>3}: {b}  Sidon? {is_sidon(b, n)}")
    print("    dilate by a NON-unit collapses the set and destroys the property:")
    b = sorted({(7 * x) % n for x in a})
    print(f"      u = 7: {b}  size {len(b)} (was {len(a)}), Sidon? {is_sidon(b, n)}")
    print()


# ---------------------------------------------------------------------------
# 9. Sidon <=> C_4-free incidence graph
# ---------------------------------------------------------------------------


def demo_graph_bridge() -> None:
    print("=" * 78)
    print("9.  BRIDGE:  A is Sidon  <=>  its bipartite incidence graph is C_4-free")
    print("      Left x ~ right y  iff  y - x in A,  inside Z/NZ")
    print("=" * 78)

    def max_common_neighbours(a: List[int], n: int) -> int:
        # left-neighbourhoods of the right vertices: x ~ y iff y - x in A
        nbr = [{(y - c) % n for c in a} for y in range(n)]
        worst = 0
        for y1, y2 in combinations(range(n), 2):
            worst = max(worst, len(nbr[y1] & nbr[y2]))
        return worst

    for a, n, label in [
        (erdos_turan_set(3), 18, "A_3 mod 18 (Sidon)"),
        (erdos_turan_set(5), 50, "A_5 mod 50 (Sidon)"),
        ([0, 1, 2, 3], 18, "{0,1,2,3} mod 18 (NOT Sidon)"),
    ]:
        m = max_common_neighbours(a, n)
        print(
            f"  {label:<32} max common neighbours = {m}  "
            f"-> C_4-free: {m <= 1};  Sidon: {is_sidon(a, n)}"
        )
    print()
    print("  Reiman double count reproves the ceiling: each of the N right vertices")
    print("  contributes C(k,2) pairs of left neighbours, no pair repeats, so")
    print("  N*C(k,2) <= C(N,2), i.e. k(k-1) <= N-1.")
    print(f"{'p':>4} {'N':>7} {'k(k-1)':>8} {'N-1':>7} {'holds':>7}")
    for p in [3, 5, 7, 11, 13]:
        n, k = 2 * p * p, p
        print(f"{p:>4} {n:>7} {k*(k-1):>8} {n-1:>7} {str(k*(k-1) <= n-1):>7}")
    print()


# ---------------------------------------------------------------------------


def main() -> None:
    print()
    print("#" * 78)
    print("#  SIDON SETS IN INTERVALS AND IN CYCLIC GROUPS  --  numerical demos")
    print("#" * 78)
    print()
    demo_construction()
    demo_cyclic_main_theorem()
    demo_counting()
    demo_interval_sandwich()
    demo_cyclic_sandwich()
    demo_perfect_difference_sets()
    demo_affine_invariance()
    demo_graph_bridge()
    print("=" * 78)
    print("All demonstrations completed; every asserted identity checked numerically.")
    print("=" * 78)


if __name__ == "__main__":
    main()
