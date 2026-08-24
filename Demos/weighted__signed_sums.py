"""
Weighted / signed sums: greedy difference avoidance and the B_h tower
=====================================================================

Numerical companion to the paper "Differences, Signed Sums, and the B_h Tower".

Everything is self-contained: no imports beyond the standard library.

The script demonstrates, by direct computation:

  1. Sums versus differences.  A finite set of naturals has all pairwise
     differences distinct exactly when it has all pairwise sums distinct
     (Sidon), so the greedy "avoid a repeated difference" process and the
     greedy "avoid a repeated sum" process generate the *same* sequence
     (the Mian-Chowla sequence, here normalised to start at 0).

  2. The cubic obstruction set.  Adjoining m to A repeats a difference
     exactly when m lies in {c + d - b : b, c, d in A}, a set of at most
     |A|^3 integers; for unordered candidates a second, quadratic
     "halving" obstruction {m : 2m = c + d} appears, and it is genuinely
     necessary.

  3. Growth sandwich for the greedy Sidon sequence:
        n(n+1) <= 2 a(n)      and      a(n) <= n^3 + n^2 + n.

  4. The collapse theorem: h-fold difference rigidity is *equivalent* to
     being a B_{2h} set.  Verified exhaustively on small sets.

  5. Strictness of the B_h tower: T(h) = {0, 1, h+1} is a B_h set but not
     a B_{h+1} set, for every h >= 1.

  6. The counting bound for B_h sets inside {0, ..., N-1}:
        C(|A|, h) <= h(N-1) + 1,   equivalently  (|A| - h + 1)^h <= h! (h(N-1)+1).

  7. Greedy B_h sequences for h = 2, 3, 4 and their two-sided bounds
        C(n+1, h) <= h a_h(n) + 1     and     a_h(n) <= n + h((h+1)(n+1)^h)^2.
"""

from __future__ import annotations

from itertools import combinations_with_replacement, product
from math import comb, factorial
from typing import Dict, Iterable, List, Optional, Sequence, Set, Tuple

# ---------------------------------------------------------------------------
# 1. Sidon sets: sums and differences
# ---------------------------------------------------------------------------


def is_sidon_by_sums(a: Sequence[int]) -> bool:
    """True iff all pairwise sums a_i + a_j (i <= j) are distinct."""
    seen: Set[int] = set()
    for i in range(len(a)):
        for j in range(i, len(a)):
            s = a[i] + a[j]
            if s in seen:
                return False
            seen.add(s)
    return True


def is_sidon_by_differences(a: Sequence[int]) -> bool:
    """True iff all differences a_i - a_j with i != j are distinct."""
    seen: Set[int] = set()
    for i in range(len(a)):
        for j in range(len(a)):
            if i == j:
                continue
            d = a[i] - a[j]
            if d in seen:
                return False
            seen.add(d)
    return True


def sidon_bad(a: Sequence[int]) -> Set[int]:
    """The cubic difference-obstruction set {c + d - b : b, c, d in A}."""
    return {c + d - b for b, c, d in product(a, repeat=3)}


def sidon_bad_half(a: Sequence[int]) -> Set[int]:
    """The quadratic halving obstruction {m : 2m = c + d, c, d in A}."""
    out: Set[int] = set()
    for c, d in product(a, repeat=2):
        if (c + d) % 2 == 0:
            out.add((c + d) // 2)
    return out


def greedy_sidon(n_terms: int, use_differences: bool = True) -> List[int]:
    """Greedy Sidon set over the naturals, starting from 0.

    If use_differences is True the greedy test refuses a repeated difference;
    otherwise it refuses a repeated sum.  The two agree, by the equivalence of
    the two formulations.
    """
    test = is_sidon_by_differences if use_differences else is_sidon_by_sums
    out: List[int] = []
    m = 0
    while len(out) < n_terms:
        if test(out + [m]):
            out.append(m)
        m += 1
    return out


# ---------------------------------------------------------------------------
# 2. B_h sets and h-fold difference rigidity
# ---------------------------------------------------------------------------


def multisets(a: Sequence[int], h: int) -> Iterable[Tuple[int, ...]]:
    """All size-h multisets of A, as sorted tuples."""
    return combinations_with_replacement(sorted(a), h)


def is_bh(a: Sequence[int], h: int) -> bool:
    """True iff A is a B_h set: distinct size-h multisets have distinct sums."""
    if h == 0:
        return True
    seen: Dict[int, Tuple[int, ...]] = {}
    for s in multisets(a, h):
        total = sum(s)
        if total in seen and seen[total] != s:
            return False
        seen[total] = s
    return True


def bh_witness(a: Sequence[int], h: int) -> Optional[Tuple[Tuple[int, ...], Tuple[int, ...]]]:
    """A pair of distinct size-h multisets with equal sums, if one exists."""
    seen: Dict[int, Tuple[int, ...]] = {}
    for s in multisets(a, h):
        total = sum(s)
        if total in seen and seen[total] != s:
            return seen[total], s
        seen[total] = s
    return None


def is_diff_bh(a: Sequence[int], h: int) -> bool:
    """h-fold difference rigidity.

    For all size-h multisets s, t, s', t' from A:
        sum(s) - sum(t) = sum(s') - sum(t')   ==>   s + t' = s' + t
    as multisets.  Written additively, the hypothesis is
    sum(s) + sum(t') = sum(s') + sum(t).
    """
    ms = list(multisets(a, h))
    # s + t' = s' + t is exactly equality of the formal differences s - t and
    # s' - t' in the free abelian group on A, so rigidity says: the numerical
    # difference sum(s) - sum(t) determines the formal difference s - t.
    seen: Dict[int, Tuple[Tuple[int, int], ...]] = {}
    for s in ms:
        for t in ms:
            key = sum(s) - sum(t)
            counts: Dict[int, int] = {}
            for x in s:
                counts[x] = counts.get(x, 0) + 1
            for x in t:
                counts[x] = counts.get(x, 0) - 1
            formal = tuple(sorted((x, c) for x, c in counts.items() if c != 0))
            if key in seen and seen[key] != formal:
                return False
            seen[key] = formal
    return True


# ---------------------------------------------------------------------------
# 3. Greedy B_h process
# ---------------------------------------------------------------------------


def greedy_bh(n_terms: int, h: int) -> List[int]:
    """Greedy B_h set over the naturals, starting from 0."""
    out: List[int] = []
    m = 0
    while len(out) < n_terms:
        if is_bh(out + [m], h):
            out.append(m)
        m += 1
    return out


def bh_counting_bound_ok(a: Sequence[int], h: int) -> Tuple[int, int, bool]:
    """Check C(|A|, h) <= h(N-1) + 1 with N = max(A) + 1."""
    n_big = max(a) + 1
    lhs = comb(len(a), h)
    rhs = h * (n_big - 1) + 1
    return lhs, rhs, lhs <= rhs


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------


def demo_sums_versus_differences() -> None:
    print("=" * 72)
    print("1. Sums versus differences: the two greedy processes coincide")
    print("=" * 72)
    by_diff = greedy_sidon(14, use_differences=True)
    by_sum = greedy_sidon(14, use_differences=False)
    print(f"   greedy by differences : {by_diff}")
    print(f"   greedy by sums        : {by_sum}")
    print(f"   identical             : {by_diff == by_sum}")
    print("   (this is the Mian-Chowla sequence 1, 2, 4, 8, 13, ... shifted by 1)")
    print()
    print("   exhaustive check of 'all sums distinct <=> all differences distinct'")
    print("   over every subset of {0,...,9}:")
    bad = 0
    for size in range(0, 6):
        for sub in combinations_with_replacement(range(10), size):
            s = sorted(set(sub))
            if is_sidon_by_sums(s) != is_sidon_by_differences(s):
                bad += 1
    print(f"   counterexamples found : {bad}")
    print()


def demo_obstruction_sets() -> None:
    print("=" * 72)
    print("2. The obstruction sets and their sizes")
    print("=" * 72)
    a = greedy_sidon(6)
    print(f"   A = {a}")
    bad = sidon_bad(a)
    half = sidon_bad_half(a)
    print(f"   |A|                          = {len(a)}")
    print(f"   |{{c + d - b}}|                = {len(bad)}   (bound |A|^3 = {len(a)**3})")
    print(f"   |{{m : 2m = c + d}}|           = {len(half)}   (bound |A|^2 = {len(a)**2})")
    print()
    print("   Exact greedy step criterion for m above A:")
    m = max(a) + 1
    while m in bad:
        m += 1
    print(f"   smallest m > max A avoiding the cubic obstruction: {m}")
    print(f"   is A + {{{m}}} Sidon? {is_sidon_by_sums(a + [m])}")
    print()
    print("   The halving obstruction is genuinely necessary (unordered candidates):")
    a2, m2 = [0, 2], 1
    print(f"   A = {a2}, m = {m2}")
    print(f"   m avoids the cubic obstruction   : {m2 not in sidon_bad(a2)}")
    print(f"   m lies in the halving obstruction: {m2 in sidon_bad_half(a2)}")
    print(f"   A + {{m}} Sidon?                   : {is_sidon_by_sums(a2 + [m2])}"
          "    (0 + 2 = 1 + 1)")
    print()
    print("   A witness of every size k >= 2: dilate a Sidon set by 2 and try m = 1.")
    for k in range(2, 6):
        base = [2 * x for x in greedy_sidon(k)]
        print(f"     k = {k}: A = {base}, m = 1, "
              f"cubic-avoided = {1 not in sidon_bad(base)}, "
              f"halving-hit = {1 in sidon_bad_half(base)}, "
              f"Sidon after insert = {is_sidon_by_sums(base + [1])}")
    print()


def demo_growth_sandwich() -> None:
    print("=" * 72)
    print("3. Growth sandwich for the greedy Sidon sequence")
    print("=" * 72)
    seq = greedy_sidon(14)
    print(f"   {'n':>3} {'n(n+1)/2':>10} {'a(n)':>8} {'n^3+n^2+n':>12}   sandwich")
    for n, val in enumerate(seq):
        lo = n * (n + 1) // 2
        hi = n**3 + n**2 + n
        ok = (n * (n + 1) <= 2 * val) and (val <= hi)
        print(f"   {n:>3} {lo:>10} {val:>8} {hi:>12}   {'OK' if ok else 'FAIL'}")
    print()


def demo_collapse() -> None:
    print("=" * 72)
    print("4. The collapse theorem:  h-fold difference rigidity  <=>  B_{2h}")
    print("=" * 72)
    tested = 0
    mismatches = 0
    for h in (1, 2):
        for size in range(0, 5):
            for sub in combinations_with_replacement(range(9), size):
                a = sorted(set(sub))
                if len(a) != size:
                    continue
                lhs = is_diff_bh(a, h)
                rhs = is_bh(a, 2 * h)
                tested += 1
                if lhs != rhs:
                    mismatches += 1
                    print(f"   MISMATCH h={h}, A={a}: Diff_h={lhs}, B_2h={rhs}")
    print(f"   pairs (h, A) tested   : {tested}")
    print(f"   mismatches            : {mismatches}")
    print("   In particular Diff_1 <=> B_2 <=> Sidon:")
    for a in ([0, 1, 3, 7], [0, 1, 2, 4], [0, 2, 3, 4]):
        print(f"     A = {a}: Diff_1 = {is_diff_bh(a, 1)}, "
              f"B_2 = {is_bh(a, 2)}, Sidon = {is_sidon_by_sums(a)}")
    print()


def demo_tower_strictness() -> None:
    print("=" * 72)
    print("5. Strictness of the tower:  T(h) = {0, 1, h+1} is B_h but not B_{h+1}")
    print("=" * 72)
    for h in range(1, 8):
        t = [0, 1, h + 1]
        w = bh_witness(t, h + 1)
        print(f"   h = {h}: T = {t}, B_h = {is_bh(t, h)}, "
              f"B_{{h+1}} = {is_bh(t, h + 1)}, witness = {w}")
    print("   The failing coincidence is always (h+1) copies of 1 against")
    print("   one copy of h+1 padded with h zeros.")
    print()
    print("   Consequently the difference layers are strict too, since")
    print("   Diff_h = B_{2h}:")
    for h in range(1, 5):
        t = [0, 1, 2 * h + 1]
        print(f"     h = {h}: T = {t}, Diff_h = {is_diff_bh(t, h)}, "
              f"Diff_{{h+1}} = {is_diff_bh(t, h + 1)}")
    print()


def demo_counting_bound() -> None:
    print("=" * 72)
    print("6. Counting bound for B_h sets inside {0, ..., N-1}")
    print("=" * 72)
    print("   C(|A|, h) <= h(N-1) + 1     and     (|A|-h+1)^h <= h! (h(N-1)+1)")
    for h in (2, 3, 4):
        a = greedy_bh(7, h)
        lhs, rhs, ok = bh_counting_bound_ok(a, h)
        k = len(a)
        n_big = max(a) + 1
        lhs2 = (k - h + 1) ** h
        rhs2 = factorial(h) * (h * (n_big - 1) + 1)
        print(f"   h = {h}: A = {a}")
        print(f"          C({k},{h}) = {lhs} <= {rhs} : {ok}")
        print(f"          ({k}-{h}+1)^{h} = {lhs2} <= {h}!*({h}*{n_big - 1}+1) = {rhs2} :"
              f" {lhs2 <= rhs2}")
    print()


def demo_greedy_bh() -> None:
    print("=" * 72)
    print("7. Greedy B_h sequences and their two-sided bounds")
    print("=" * 72)
    for h, n_terms in ((2, 10), (3, 9), (4, 8)):
        seq = greedy_bh(n_terms, h)
        print(f"   h = {h}: {seq}")
        print(f"          (+1 shift: {[x + 1 for x in seq]})")
        print(f"   {'n':>3} {'C(n+1,h)':>10} {'a_h(n)':>9} {'h a+1':>9} "
              f"{'deg-2h bound':>16}")
        for n, val in enumerate(seq):
            lo = comb(n + 1, h)
            hi = n + h * ((h + 1) * (n + 1) ** h) ** 2
            print(f"   {n:>3} {lo:>10} {val:>9} {h * val + 1:>9} {hi:>16}"
                  f"   {'OK' if lo <= h * val + 1 and val <= hi else 'FAIL'}")
        print()


def main() -> None:
    demo_sums_versus_differences()
    demo_obstruction_sets()
    demo_growth_sandwich()
    demo_collapse()
    demo_tower_strictness()
    demo_counting_bound()
    demo_greedy_bh()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
