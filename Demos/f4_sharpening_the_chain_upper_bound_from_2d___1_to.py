"""
Forbidden Boolean-lattice subposets: numerical demonstration.
=============================================================

This self-contained script demonstrates, numerically, the results on the
extremal function

    La(n, B_d) = max { |F| : F a family of subsets of [n] containing no
                             weak copy of the d-dimensional Boolean lattice }

where a *weak copy* of B_d in F is an injective, containment-preserving map
from the subsets of [d] into F.

Demonstrated results
--------------------
1.  Chain-to-cube        : a chain of 2^d sets contains a weak copy of B_d.
2.  Chain bound          : La(n, B_d) <= (2^d - 1) * C(n, floor(n/2)).
3.  Mirsky + LYM         : a family with no chain of k+1 sets has Lubell mass
                           sum_{A in F} 1 / C(n,|A|) <= k.
4.  Sperner case         : La(n, B_1) = C(n, floor(n/2)).
5.  Levels lower bound   : d consecutive levels are B_d-free.
6.  Complete levels      : any d+1 complete levels contain a weak copy of B_d,
                           hence La <= d * C(n, floor(n/2)) for level unions.
7.  Sharpened bounds     : (m+1) La(2m,B_d)   <= ((2^d-1)m+1) C(2m,m)
                           (m+2) La(2m+1,B_d) <= ((2^d-1)m+4) C(2m+1,m)
8.  Small ground sets    : La(n, B_3) <= 4 C(n, floor(n/2)) for n <= 8.
9.  Doubling criterion   : two pointwise-nested, disjoint chains of 2^d sets
                           contain a weak copy of B_{d+1}.

Everything is exact integer / rational arithmetic; no external dependencies.

Sets are encoded as bitmasks (integers), families as frozensets of bitmasks.
"""

from __future__ import annotations

from fractions import Fraction
from itertools import combinations
from math import comb
from typing import Dict, Iterable, List, Optional, Sequence, Tuple

# ----------------------------------------------------------------------------
# Basic combinatorial helpers
# ----------------------------------------------------------------------------


def central(n: int) -> int:
    """The size C(n, floor(n/2)) of the largest level of the Boolean lattice."""
    return comb(n, n // 2)


def popcount(x: int) -> int:
    """Cardinality of the set encoded by the bitmask ``x``."""
    return bin(x).count("1")


def subsets_of(n: int) -> List[int]:
    """All 2^n subsets of [n], as bitmasks."""
    return list(range(1 << n))


def is_subset(a: int, b: int) -> bool:
    """Containment test for bitmask-encoded sets: a subseteq b."""
    return a & ~b == 0


def linear_extension(d: int) -> List[int]:
    """A linear extension of the subset lattice of [d].

    Returns the 2^d bitmasks ordered so that ``a subseteq b`` implies ``a``
    occurs no later than ``b``: sort by cardinality, ties broken numerically.
    """
    return sorted(range(1 << d), key=lambda s: (popcount(s), s))


# ----------------------------------------------------------------------------
# Detecting a weak copy of B_d
# ----------------------------------------------------------------------------


def find_bd_copy(family: Sequence[int], d: int) -> Optional[Dict[int, int]]:
    """Search for a weak copy of B_d inside ``family``.

    Backtracks over a linear extension of the subset lattice of [d]; a partial
    assignment is extended by a set of the family that is new and that contains
    the images of all previously assigned subsets below the current one.

    Returns the assignment ``{subset of [d] -> member of family}`` if one
    exists, otherwise ``None``.
    """
    order = linear_extension(d)
    fam = sorted(set(family), key=popcount)
    assign: Dict[int, int] = {}
    used: set[int] = set()

    def backtrack(j: int) -> bool:
        if j == len(order):
            return True
        s = order[j]
        for cand in fam:
            if cand in used:
                continue
            ok = True
            for t in order[:j]:
                if is_subset(t, s) and not is_subset(assign[t], cand):
                    ok = False
                    break
            if not ok:
                continue
            assign[s] = cand
            used.add(cand)
            if backtrack(j + 1):
                return True
            used.discard(cand)
            del assign[s]
        return False

    return dict(assign) if backtrack(0) else None


def is_bd_free(family: Sequence[int], d: int) -> bool:
    """True iff ``family`` contains no weak copy of B_d."""
    return find_bd_copy(family, d) is None


# ----------------------------------------------------------------------------
# Chains and the Lubell mass
# ----------------------------------------------------------------------------


def longest_chain(family: Sequence[int]) -> int:
    """Number of sets in a longest strictly increasing chain inside ``family``."""
    fam = sorted(set(family), key=popcount)
    best: Dict[int, int] = {}
    answer = 0
    for a in fam:
        cur = 1
        for b in fam:
            if b != a and is_subset(b, a) and popcount(b) < popcount(a):
                cur = max(cur, best[b] + 1)
        best[a] = cur
        answer = max(answer, cur)
    return answer


def lubell_mass(family: Iterable[int], n: int) -> Fraction:
    """Exact Lubell mass  sum_{A in F} 1 / C(n, |A|)."""
    return sum((Fraction(1, comb(n, popcount(a))) for a in family), Fraction(0))


# ----------------------------------------------------------------------------
# Constructions
# ----------------------------------------------------------------------------


def level_family(n: int, a: int, d: int) -> List[int]:
    """All subsets of [n] whose size lies in [a, a+d): a union of d levels."""
    return [s for s in subsets_of(n) if a <= popcount(s) < a + d]


def complete_levels_copy(n: int, sizes: Sequence[int]) -> Dict[int, int]:
    """Explicit weak copy of B_d built from d+1 complete levels of 2^[n].

    ``sizes`` must be a strictly increasing list i_0 < ... < i_d of at most n.
    Reserves the top d ground-set points as markers and uses low blocks:

        f(S) = { 0, ..., i_{|S|} - |S| - 1 }  union  { markers indexed by S }.
    """
    d = len(sizes) - 1
    assert d <= n, "need d <= n"
    assert all(sizes[i] < sizes[i + 1] for i in range(d)), "sizes must increase"
    assert sizes[-1] <= n, "sizes must be at most n"
    markers = [n - d + t for t in range(d)]  # the d largest points of [n]
    out: Dict[int, int] = {}
    for s in range(1 << d):
        k = popcount(s)
        block = sizes[k] - k
        mask = (1 << block) - 1  # the low block of size ``block``
        for t in range(d):
            if s >> t & 1:
                mask |= 1 << markers[t]
        out[s] = mask
    return out


def chain_family(n: int, length: int) -> List[int]:
    """A strictly increasing chain of ``length`` subsets of [n] (needs length <= n+1)."""
    assert length <= n + 1
    return [(1 << k) - 1 for k in range(length)]


# ----------------------------------------------------------------------------
# Exhaustive extremal values (feasible for n <= 3)
# ----------------------------------------------------------------------------


def la_exhaustive(n: int, d: int) -> Tuple[int, List[int]]:
    """Exact La(n, B_d) by exhaustive search over all families, plus a witness.

    Iterates over family sizes downwards, so it stops at the first size that is
    achievable. Practical for n <= 3 (2^8 = 256 families of subsets of [3]).
    """
    universe = subsets_of(n)
    for size in range(len(universe), -1, -1):
        for fam in combinations(universe, size):
            if is_bd_free(fam, d):
                return size, list(fam)
    return 0, []


# ----------------------------------------------------------------------------
# Bound formulas
# ----------------------------------------------------------------------------


def chain_bound(n: int, d: int) -> int:
    """(2^d - 1) * C(n, floor(n/2))."""
    return (2 ** d - 1) * central(n)


def sharpened_bound(n: int, d: int) -> Fraction:
    """The sharpened chain bound as an exact rational upper bound on La(n,B_d).

    n = 2m   :  ((2^d-1) m + 1) / (m+1) * C(2m, m)
    n = 2m+1 :  ((2^d-1) m + 4) / (m+2) * C(2m+1, m)
    """
    k = 2 ** d - 1
    if n % 2 == 0:
        m = n // 2
        if m == 0:
            return Fraction(chain_bound(n, d))
        return Fraction(k * m + 1, m + 1) * comb(2 * m, m)
    m = (n - 1) // 2
    if m == 0:
        return Fraction(chain_bound(n, d))
    return Fraction(k * m + 4, m + 2) * comb(2 * m + 1, m)


def levels_lower_bound(n: int, d: int) -> int:
    """Best d-consecutive-levels lower bound for La(n, B_d)."""
    if d >= n + 1:
        return 2 ** n
    return max(sum(comb(n, i) for i in range(a, a + d)) for a in range(0, n + 2 - d))


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------


def demo_chain_to_cube() -> None:
    print("=" * 74)
    print("1. Chains contain cubes:  a chain of 2^d sets carries a weak copy of B_d")
    print("=" * 74)
    for d in (1, 2, 3):
        n = 2 ** d - 1  # height n+1 = 2^d, just enough for the chain
        chain = chain_family(n, 2 ** d)
        copy = find_bd_copy(chain, d)
        assert copy is not None
        print(f"  d = {d}:  chain of {2**d} subsets of [{n}] -> copy of B_{d} found")
        rendered = ", ".join(
            f"{{{','.join(str(i) for i in range(n) if s >> i & 1) or '-'}}}"
            f"->{{{','.join(str(i) for i in range(n) if copy[s] >> i & 1) or '-'}}}"
            for s in linear_extension(d)
        )
        print(f"          {rendered}")
        # And one set shorter it is B_d-free (the structural obstruction):
        short = chain_family(n, 2 ** d - 1)
        assert is_bd_free(short, d)
        print(f"          a chain of {2**d - 1} sets is B_{d}-free  <-- why 2^d-1 is a barrier")
    print()


def demo_mirsky_lym() -> None:
    print("=" * 74)
    print("2. Mirsky + LYM:  no chain of k+1 sets  =>  Lubell mass <= k")
    print("=" * 74)
    for n in (4, 5, 6):
        print(f"  n = {n},  C(n,floor(n/2)) = {central(n)}")
        for d in (1, 2, 3):
            fam = level_family(n, max(0, n // 2 - d // 2), d)
            k = longest_chain(fam)
            mass = lubell_mass(fam, n)
            print(
                f"    {d} middle levels: |F| = {len(fam):4d}, longest chain = {k}, "
                f"Lubell mass = {float(mass):.4f} <= {k}   "
                f"[|F| <= mass * C = {float(mass) * central(n):.1f}]"
            )
            assert mass <= k
            assert len(fam) <= k * central(n)
    print()


def demo_bounds_table() -> None:
    print("=" * 74)
    print("3. Bounds on La(n, B_3), in units of C(n, floor(n/2))")
    print("=" * 74)
    print(f"  {'n':>3} {'C(n)':>7} {'levels LB':>11} {'sharpened UB':>14} "
          f"{'chain UB':>10} {'conj 4C':>9} {'2^n':>8}")
    for n in range(1, 17):
        c = central(n)
        lb = levels_lower_bound(n, 3)
        ub = sharpened_bound(n, 3)
        print(
            f"  {n:>3} {c:>7} {lb / c:>11.3f} {float(ub) / c:>14.3f} "
            f"{chain_bound(n,3)/c:>10.3f} {4.0:>9.3f} {2**n/c:>8.3f}"
        )
        assert lb <= chain_bound(n, 3)
        assert ub <= chain_bound(n, 3)
    print("\n  The sharpened bound is strictly below the chain bound 7C for every n,")
    print("  and converges to 7 at rate Theta(1/n).  The conjecture asserts 4.")
    print()


def demo_small_n_conjecture() -> None:
    print("=" * 74)
    print("4. The d = 3 conjecture for small ground sets:  2^n <= 4 C(n,floor(n/2))")
    print("=" * 74)
    for n in range(0, 11):
        lhs, rhs = 2 ** n, 4 * central(n)
        flag = "OK   La(n,B_3) <= 4C" if lhs <= rhs else "FAILS (trivial bound useless)"
        print(f"  n = {n:>2}:  2^n = {lhs:>5}   4*C = {rhs:>5}   {flag}")
    print("\n  The trivial argument works exactly up to n = 8; a counterexample")
    print("  to the d = 3 conjecture would need n >= 9.")
    print()


def demo_complete_levels() -> None:
    print("=" * 74)
    print("5. Complete Levels Theorem:  any d+1 complete levels contain a B_d copy")
    print("=" * 74)
    for n, sizes in ((6, [0, 2, 5]), (7, [1, 3, 4, 7]), (8, [2, 3, 6])):
        d = len(sizes) - 1
        f = complete_levels_copy(n, sizes)
        # verify the three defining properties
        assert len(set(f.values())) == len(f), "injective"
        assert all(popcount(v) in sizes for v in f.values()), "correct levels"
        for s in range(1 << d):
            for t in range(1 << d):
                if is_subset(s, t):
                    assert is_subset(f[s], f[t]), "monotone"
        print(f"  n = {n}, levels {sizes}: explicit copy of B_{d} verified "
              f"({len(f)} distinct sets, sizes {sorted(popcount(v) for v in f.values())})")
    print("\n  Consequence: a B_d-free union of complete levels occupies <= d levels,")
    print("  so |F| <= d * C(n,floor(n/2)) -- the conjecture with c = 0 in the")
    print("  symmetric case.  Any counterexample must break ground-set symmetry.")
    print()


def demo_levels_are_free() -> None:
    print("=" * 74)
    print("6. Levels lower bound:  d consecutive levels are B_d-free")
    print("=" * 74)
    for n in (4, 5, 6):
        for d in (1, 2, 3):
            a = max(0, (n - d + 1) // 2)
            fam = level_family(n, a, d)
            free = is_bd_free(fam, d)
            has_copy = find_bd_copy(fam, d + 1) is not None
            print(
                f"  n = {n}, levels {a}..{a+d-1}: |F| = {len(fam):4d} = "
                f"{len(fam)/central(n):.3f} C,  B_{d}-free: {free},  contains B_{d+1}: {has_copy}"
            )
            assert free
    print()


def demo_doubling() -> None:
    print("=" * 74)
    print("7. Doubling criterion: two parallel chains of 2^d sets force a B_{d+1}")
    print("=" * 74)
    d = 2
    n = 6
    # x_i = {0,...,i-1}; y_i = x_i union {5}. Pointwise nested, value-disjoint.
    x = [(1 << i) - 1 for i in range(2 ** d)]
    y = [xi | (1 << (n - 1)) for xi in x]
    fam = x + y
    assert all(is_subset(x[i], y[i]) for i in range(2 ** d))
    assert not (set(x) & set(y))
    copy = find_bd_copy(fam, d + 1)
    assert copy is not None
    print(f"  two nested disjoint chains of {2**d} subsets of [{n}]  ->  copy of B_{d+1} found")
    print(f"  total sets used: {len(set(copy.values()))} (a single chain of {2**(d+1)} "
          f"sets would need height {2**(d+1)}, here the height is only {2**d + 1})")
    # A single chain of 2^{d+1} sets does not even fit if n+1 < 2^{d+1}:
    print(f"  note: for n = {n} the lattice has height {n+1} < {2**(d+1)}, so the")
    print("  chain criterion is vacuous while the parallel-chain criterion is not.")
    print()


def demo_exhaustive() -> None:
    print("=" * 74)
    print("8. Exact extremal values by exhaustive search (n <= 3)")
    print("=" * 74)
    print(f"  {'n':>3} {'C(n)':>5} {'La(n,B_1)':>10} {'La(n,B_2)':>10} {'La(n,B_3)':>10}")
    for n in (1, 2, 3):
        row = [la_exhaustive(n, d)[0] for d in (1, 2, 3)]
        print(f"  {n:>3} {central(n):>5} {row[0]:>10} {row[1]:>10} {row[2]:>10}")
        assert row[0] == central(n), "Sperner"
        for d, v in zip((1, 2, 3), row):
            assert v <= chain_bound(n, d)
            assert v >= levels_lower_bound(n, d)
    print("\n  Row check: La(n,B_1) = C(n,floor(n/2)) exactly (Sperner), and every")
    print("  value lies between the levels lower bound and the chain bound.")
    print()


def demo_sandwich() -> None:
    print("=" * 74)
    print("9. The d = 3 corridor:  (3m+1)/(m+1) <= La(2m,B_3)/C(2m,m) <= (7m+1)/(m+1)")
    print("=" * 74)
    print(f"  {'m':>4} {'n=2m':>5} {'lower':>9} {'upper':>9} {'conjecture':>11}")
    for m in (1, 2, 3, 5, 10, 25, 50, 100):
        lo = Fraction(3 * m + 1, m + 1)
        hi = Fraction(7 * m + 1, m + 1)
        # cross-check the lower bound against the explicit three-level count
        three = comb(2 * m, m - 1) + comb(2 * m, m) + comb(2 * m, m + 1)
        assert Fraction(three, comb(2 * m, m)) == lo
        print(f"  {m:>4} {2*m:>5} {float(lo):>9.4f} {float(hi):>9.4f} {4.0:>11.4f}")
    print("\n  limits: 3 (lower) and 7 (upper); the conjecture asserts 4.")
    print()


def main() -> None:
    print()
    print("#" * 74)
    print("#  Forbidden Boolean-lattice subposets: from the 2^d - 1 chain bound")
    print("#  towards the conjectured d + c")
    print("#" * 74)
    print()
    demo_chain_to_cube()
    demo_mirsky_lym()
    demo_bounds_table()
    demo_small_n_conjecture()
    demo_complete_levels()
    demo_levels_are_free()
    demo_doubling()
    demo_exhaustive()
    demo_sandwich()
    print("All assertions passed.")


if __name__ == "__main__":
    main()
