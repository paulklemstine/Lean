"""
The Computational Complexity of Recipes
=======================================

Numerical demonstration of the query-theoretic model of cooking and tasting.

A pantry of n ingredients is a tuple of n bits.  A dish is a Boolean function
f : {0,1}^n -> {0,1}.  Cooking costs C(f) = n (every ingredient is handled).
Tasting costs V(f) = the minimum worst-case depth of an adaptive decision tree
computing f.

This script verifies, by exhaustive computation on small pantries, every
quantitative claim of the accompanying paper:

  1.  V(f) <= C(f) = n                                  (tasting <= cooking)
  2.  max_x s(f,x) <= V(f)                              (sensitivity bound)
  3.  V(f) = 0  iff  f constant                         (no free verdicts)
  4.  V(OR_n) = n but every 1-input has a 1-probe cert  (kitchen P != NP)
  5.  Every certificate of PARITY_n is the whole pantry (the souffle theorem)
  6.  V(parity on first k coords) = k                   (the spectrum)
  7.  C/V = 1  iff  f is evasive                        (the inversion)
  8.  the hundred-recipe census has aggregate ratio 200/101
  9.  #{f : V(f) <= d} <= (6n)^(2^d)                    (counting bound)
 10.  V(mux) = 2 but every fixed checklist has size 3   (adaptivity gap)
 11.  V(f) <= C0(f) * C1(f)                             (product bound)

Self-contained: standard library only.
"""

from __future__ import annotations

from fractions import Fraction
from functools import lru_cache
from itertools import combinations, product
from typing import Callable, Dict, FrozenSet, Iterable, List, Sequence, Tuple

Pantry = Tuple[int, ...]
Dish = Callable[[Pantry], int]


# ----------------------------------------------------------------------------
# Truth tables
# ----------------------------------------------------------------------------

def all_pantries(n: int) -> List[Pantry]:
    """Every pantry state on n ingredients, in lexicographic order."""
    return [tuple(p) for p in product((0, 1), repeat=n)]


def truth_table(f: Dish, n: int) -> Tuple[int, ...]:
    """The 2^n-entry verdict table of a dish, indexed by all_pantries(n)."""
    return tuple(f(x) for x in all_pantries(n))


def table_index(x: Pantry) -> int:
    """Index of a pantry in all_pantries(len(x)) (big-endian bit order)."""
    idx = 0
    for bit in x:
        idx = 2 * idx + bit
    return idx


# ----------------------------------------------------------------------------
# 1. Verification cost V(f): exact, by memoised restriction search
# ----------------------------------------------------------------------------

def taste_cost(table: Sequence[int], n: int) -> int:
    """Exact deterministic query complexity V(f) of the dish given by `table`.

    Uses the structure theorem: a dish tastable in d+1 probes is constant, or
    is `probe i, then follow one of two dishes each tastable in d probes`.
    Read as an equation this gives

        V(f) = 0                                          if f is constant
        V(f) = 1 + min_i max(V(f|i=0), V(f|i=1))          otherwise.
    """

    @lru_cache(maxsize=None)
    def rec(tab: Tuple[int, ...], m: int) -> int:
        if len(set(tab)) == 1:
            return 0
        best = m
        half = 1 << (m - 1)
        for i in range(m):
            # split the table on coordinate i (big-endian: coordinate 0 is the
            # most significant bit of the index)
            block = 1 << (m - 1 - i)
            lo: List[int] = []
            hi: List[int] = []
            for idx, v in enumerate(tab):
                (hi if (idx // block) % 2 else lo).append(v)
            assert len(lo) == len(hi) == half
            cost = 1 + max(rec(tuple(lo), m - 1), rec(tuple(hi), m - 1))
            best = min(best, cost)
        return best

    return rec(tuple(table), n)


# ----------------------------------------------------------------------------
# 2. Sensitivity
# ----------------------------------------------------------------------------

def flip(x: Pantry, i: int) -> Pantry:
    """Flip ingredient i of the pantry x."""
    y = list(x)
    y[i] ^= 1
    return tuple(y)


def pivotal_set(f: Dish, x: Pantry) -> FrozenSet[int]:
    """Ingredients whose single flip changes the verdict at x."""
    return frozenset(i for i in range(len(x)) if f(flip(x, i)) != f(x))


def sensitivity(f: Dish, n: int) -> int:
    """max_x |piv(f,x)|, the maximal sensitivity of the dish."""
    return max(len(pivotal_set(f, x)) for x in all_pantries(n))


# ----------------------------------------------------------------------------
# 3. Certificates
# ----------------------------------------------------------------------------

def is_certificate(f: Dish, x: Pantry, S: Iterable[int]) -> bool:
    """Does fixing the ingredients in S to their values at x pin the verdict?"""
    S = frozenset(S)
    n = len(x)
    free = [i for i in range(n) if i not in S]
    target = f(x)
    for bits in product((0, 1), repeat=len(free)):
        y = list(x)
        for i, b in zip(free, bits):
            y[i] = b
        if f(tuple(y)) != target:
            return False
    return True


def min_certificate_size(f: Dish, x: Pantry) -> int:
    """Least size of a certificate for f at x.  Pruned: every certificate
    must contain the pivotal set."""
    n = len(x)
    forced = pivotal_set(f, x)
    others = [i for i in range(n) if i not in forced]
    for extra in range(len(others) + 1):
        for T in combinations(others, extra):
            S = forced | frozenset(T)
            if is_certificate(f, x, S):
                return len(S)
    return n


def certificate_complexities(f: Dish, n: int) -> Tuple[int, int]:
    """(C0, C1): the worst-case certificate sizes over 0-inputs and 1-inputs."""
    c0 = c1 = 0
    for x in all_pantries(n):
        size = min_certificate_size(f, x)
        if f(x):
            c1 = max(c1, size)
        else:
            c0 = max(c0, size)
    return c0, c1


# ----------------------------------------------------------------------------
# 4. The model dishes
# ----------------------------------------------------------------------------

def salad(i: int) -> Dish:
    """Good iff ingredient i is fresh (a dictator)."""
    return lambda x: x[i]


def spoiled(x: Pantry) -> int:
    """Alarm iff some ingredient is spoiled (the OR function)."""
    return int(any(x))


def souffle(x: Pantry) -> int:
    """It rises iff an odd number of the critical steps went right (PARITY)."""
    return sum(x) % 2


def parity_on(k: int) -> Dish:
    """Parity of the first k ingredients; the tunable family with V = k."""
    return lambda x: sum(x[:k]) % 2


def mux(x: Pantry) -> int:
    """If the sauce (0) is on, judge by the fish (1), else by the soup (2)."""
    return x[1] if x[0] else x[2]


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------

def hdr(title: str) -> None:
    print("\n" + "=" * 74)
    print(title)
    print("=" * 74)


def demo_basic_bounds(n: int = 4) -> None:
    hdr(f"1-3.  Basic bounds on n = {n} ingredients")
    dishes: List[Tuple[str, Dish]] = [
        ("constant 0", lambda x: 0),
        ("salad (dictator on ingredient 0)", salad(0)),
        ("spoiled (OR)", spoiled),
        ("souffle (PARITY)", souffle),
        ("parity on first 2", parity_on(2)),
    ]
    print(f"{'dish':38s} {'V':>3s} {'C':>3s} {'sens':>5s} {'C/V':>8s}")
    for name, f in dishes:
        v = taste_cost(truth_table(f, n), n)
        s = sensitivity(f, n)
        assert v <= n, "tasting must never exceed cooking"
        assert s <= v, "sensitivity is a lower bound on tasting"
        constant = len(set(truth_table(f, n))) == 1
        assert (v == 0) == constant, "V = 0 iff constant"
        ratio = "inf" if v == 0 else str(Fraction(n, v))
        print(f"{name:38s} {v:3d} {n:3d} {s:5d} {ratio:>8s}")
    print("\n  verified:  V <= C,   max sensitivity <= V,   V = 0 iff constant.")


def demo_kitchen_p_ne_np(n: int = 4) -> None:
    hdr(f"4.  Kitchen P != NP:  the spoiled-ingredient dish on n = {n}")
    v = taste_cost(truth_table(spoiled, n), n)
    c0, c1 = certificate_complexities(spoiled, n)
    print(f"  deterministic tasting cost   V  = {v}   (= n)")
    print(f"  badness certificates (1-inp) C1 = {c1}   (one spoiled ingredient suffices)")
    print(f"  goodness certificates (0-inp) C0 = {c0}   (must check everything)")
    assert v == n and c1 == 1 and c0 == n
    print(f"\n  Every 1-input has a 1-probe certificate, yet V = {n}.")
    print("  A hint compresses verification from n probes to 1: an unconditional")
    print("  separation of nondeterministic from deterministic kitchen verification.")


def demo_souffle(n: int = 4) -> None:
    hdr(f"5.  The souffle theorem:  PARITY on n = {n}")
    v = taste_cost(truth_table(souffle, n), n)
    c0, c1 = certificate_complexities(souffle, n)
    print(f"  V = {v},  C0 = {c0},  C1 = {c1}   (all equal n = {n})")
    every_cert_full = all(
        min_certificate_size(souffle, x) == n for x in all_pantries(n)
    )
    assert v == n == c0 == c1 and every_cert_full
    print("  Every certificate at every pantry is the ENTIRE pantry:")
    print("  no proof of goodness and no proof of badness beats a full cook.")
    print("  This is the honest combinatorial content of 'the souffle is hard'.")


def demo_spectrum(n: int = 5) -> None:
    hdr(f"6-7.  The spectrum and the inversion, n = {n}")
    print(f"{'k':>3s} {'dish':>22s} {'V':>3s} {'C':>3s} {'C/V':>8s}  evasive?")
    for k in range(0, n + 1):
        f = parity_on(k)
        v = taste_cost(truth_table(f, n), n)
        assert v == k, "V(parity on first k) must equal k"
        ratio = "inf" if v == 0 else str(Fraction(n, v))
        ev = "yes" if v == n else "no"
        print(f"{k:3d} {f'parity on first {k}':>22s} {v:3d} {n:3d} {ratio:>8s}  {ev}")
    print("\n  Ratio C/V = 1 occurs exactly at k = n, the EVASIVE dish.")
    print("  The easiest non-trivial dish (k = 1) has the EXTREME ratio n.")
    print("  The naive conjecture 'easy dishes have C = V' is exactly inverted.")


def demo_census(n: int = 100) -> None:
    hdr(f"8.  The census of {n} recipes")
    cooks = [n] * n
    tastes = list(range(1, n + 1))  # V(parity on first k) = k, proved above
    ratios = [Fraction(c, v) for c, v in zip(cooks, tastes)]
    agg = Fraction(sum(cooks), sum(tastes))
    print(f"  recipe k has C = {n}, V = k, hence ratio {n}/k")
    print(f"  largest individual ratio  : {max(ratios)}          (k = 1, one probe)")
    print(f"  smallest individual ratio : {min(ratios)}            (k = {n}, evasive)")
    print(f"  mean of individual ratios : {float(sum(ratios) / n):.4f}")
    print(f"  aggregate cook time       : {sum(cooks)}")
    print(f"  aggregate taste time      : {sum(tastes)}   (= {n}({n}+1)/2)")
    print(f"  AGGREGATE RATIO           : {agg} = {float(agg):.4f}")
    assert agg == Fraction(200, 101)
    print("\n  The aggregate weights each dish by its VERIFICATION load, so the")
    print("  hard dishes dominate: the menu is nearly break-even (~1.98), far")
    print("  below the mean of the individual ratios.")


def demo_counting(max_n: int = 3, max_d: int = 3) -> None:
    hdr("9.  Counting quick dishes:  c_d <= (6n)^(2^d)")
    print(f"{'n':>3s} {'d':>3s} {'exact c_d':>12s} {'bound (6n)^(2^d)':>22s} {'all dishes':>14s}")
    for n in range(1, max_n + 1):
        tables = list(product((0, 1), repeat=1 << n))
        costs = [taste_cost(t, n) for t in tables]
        for d in range(0, min(max_d, n) + 1):
            exact = sum(1 for c in costs if c <= d)
            bound = (6 * n) ** (2 ** d)
            total = 2 ** (2 ** n)
            assert exact <= bound
            if d == 0:
                assert exact == 2, "exactly two dishes need no tasting"
            if d == 1:
                assert exact <= 2 * n + 2, "at most 2n+2 one-probe dishes"
            print(f"{n:3d} {d:3d} {exact:12d} {bound:22d} {total:14d}")
    print("\n  The bound is doubly exponential in d but only polynomial in n,")
    print("  while the number of dishes is doubly exponential in n.")
    print("  With n = 16 and d = 7:  2*(96)^128 <= 2^897 <= 2^65536,")
    print("  so at least HALF of all 2^65536 dishes need more than 7 probes.")


def demo_adaptivity() -> None:
    hdr("10.  The adaptivity gap:  the multiplexer")
    n = 3
    v = taste_cost(truth_table(mux, n), n)
    relevant = sorted({
        i for x in all_pantries(n) for i in pivotal_set(mux, x)
    })
    checklists = [
        S for r in range(n + 1) for S in combinations(range(n), r)
        if all(is_certificate(mux, x, S) for x in all_pantries(n))
    ]
    smallest = min(checklists, key=len)
    print(f"  adaptive tasting cost V(mux)        = {v}")
    print(f"  relevant ingredients                = {relevant}  (sauce, fish, soup)")
    print(f"  smallest fixed (nonadaptive) checklist = {list(smallest)}, size {len(smallest)}")
    assert v == 2 and len(smallest) == 3
    print("\n  Deciding what to taste NEXT, in the light of what you just found,")
    print("  is strictly more powerful than committing to a checklist in advance.")


def demo_product_bound(n: int = 4) -> None:
    hdr(f"11.  The certificate product bound  V <= C0 * C1,  n = {n}")
    dishes: List[Tuple[str, Dish]] = [
        ("salad (dictator)", salad(0)),
        ("spoiled (OR)", spoiled),
        ("souffle (PARITY)", souffle),
        ("parity on first 2", parity_on(2)),
        ("majority of 3 (pad)", lambda x: int(sum(x[:3]) >= 2)),
    ]
    print(f"{'dish':22s} {'V':>3s} {'C0':>3s} {'C1':>3s} {'C0*C1':>6s} {'max(C0,C1)^2':>13s}  tight?")
    for name, f in dishes:
        v = taste_cost(truth_table(f, n), n)
        c0, c1 = certificate_complexities(f, n)
        prod = c0 * c1
        sq = max(c0, c1) ** 2
        assert v <= prod, "the product bound must hold"
        assert v <= sq
        print(f"{name:22s} {v:3d} {c0:3d} {c1:3d} {prod:6d} {sq:13d}  "
              f"{'YES' if v == prod else 'no'}")
    print("\n  For the spoiled-ingredient dish the bound 1 * n = n is ATTAINED.")
    print("  For the souffle both certificate costs are n, so the bound gives")
    print("  only n^2 while the truth is n: the theorem is powerless exactly")
    print("  where there is nothing to gain.")


def demo_overlap(n: int = 4) -> None:
    hdr("Bonus.  Certificate overlap: goodness proofs meet badness proofs")
    checked = 0
    for x in all_pantries(n):
        for y in all_pantries(n):
            if spoiled(x) == spoiled(y):
                continue
            S = min_cert_set(spoiled, x)
            T = min_cert_set(spoiled, y)
            assert S & T, f"disjoint certificates at {x}, {y}"
            checked += 1
    print(f"  checked {checked} opposite-verdict pairs for the OR dish on n = {n};")
    print("  every goodness certificate meets every badness certificate.")
    print("  This overlap is the engine of the product bound: each probed")
    print("  certificate shrinks the opposite budget by at least one.")


def min_cert_set(f: Dish, x: Pantry) -> FrozenSet[int]:
    """A minimum-size certificate for f at x (not merely its size)."""
    n = len(x)
    forced = pivotal_set(f, x)
    others = [i for i in range(n) if i not in forced]
    for extra in range(len(others) + 1):
        for T in combinations(others, extra):
            S = forced | frozenset(T)
            if is_certificate(f, x, S):
                return S
    return frozenset(range(n))


def main() -> None:
    print(__doc__)
    demo_basic_bounds(4)
    demo_kitchen_p_ne_np(4)
    demo_souffle(4)
    demo_spectrum(5)
    demo_census(100)
    demo_counting(3, 3)
    demo_adaptivity()
    demo_product_bound(4)
    demo_overlap(4)
    hdr("All assertions passed.")


if __name__ == "__main__":
    main()
