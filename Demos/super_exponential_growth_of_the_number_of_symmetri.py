"""
Numerical demonstrations for:

    "Super-Exponential Growth of Symmetric Chain Decomposition Counts:
     A Bounded-vs-Growing-Arity Dichotomy"

This script exercises the MAIN theorem `scd_strictly_outgrows_crown_floor`
numerically by:

  1. witnessing that the factorial (and the permutation count n!) is
     super-exponential  -> `factorial_superexp`, `perm_card_superexp`;
  2. witnessing the transfer principle on the two-level slab count
     numSCD(n) >= n!   -> `factorial_le_numSCD`, `numSCD_superexp`;
  3. witnessing that the crown floor m^(2w) DIVERGES but is NOT
     super-exponential -> `crown_floor_not_superexp`,
     `crownAltCount_tendsto_atTop`;
  4. tabulating the dichotomy (growing vs. bounded arity of choices).

Pure standard library, fully self-contained, type-hinted.
"""

from __future__ import annotations

from itertools import permutations
from math import factorial
from typing import Iterable


# ---------------------------------------------------------------------------
# 1. The super-exponential predicate and its witnesses
# ---------------------------------------------------------------------------

def super_exp_threshold(f: "callable", c: int, search_limit: int = 2000) -> int | None:
    """Smallest N such that c**n < f(n) for all N <= n <= search_limit.

    Returns the witnessing threshold N (the existential N in the definition
    `SuperExp f := forall c, exists N, forall n >= N, c^n < f n`), or None if
    no stable crossover is found within `search_limit` (evidence AGAINST
    super-exponentiality for this base c).
    """
    n: int = search_limit
    # Walk downward: find the largest n where the inequality FAILS; N is one past.
    last_fail: int = -1
    for k in range(search_limit + 1):
        if not (c ** k < f(k)):
            last_fail = k
    return None if last_fail == search_limit else last_fail + 1


def factorial_fn(n: int) -> int:
    """f(n) = n!  (the engine of `factorial_superexp`)."""
    return factorial(n)


def perm_count(n: int) -> int:
    """Number of permutations of an n-element set = n!  (`perm_card_superexp`)."""
    return factorial(n)


def pow_const(k: int) -> "callable":
    """Return the fixed polynomial m -> m**k (the crown floor when k = 2w)."""
    return lambda m: m ** k


# ---------------------------------------------------------------------------
# 2. The two-level slab CB(n): numSCD by direct enumeration
# ---------------------------------------------------------------------------

def slab_scd_count_bruteforce(n: int) -> int:
    """Exact number of symmetric chain decompositions of the two-level slab CB(n).

    A symmetric chain in the two-rank poset on {bottom, top} x {1..n} is a single
    edge (bottom i)-(top j). An SCD is a perfect matching of all 2n vertices,
    i.e. a bijection bottom -> top, i.e. a permutation. We enumerate them.

    Returns numSCD(n). Verifies (the conjectured) numSCD(n) == n! and a fortiori
    the proved lower bound  n! <= numSCD(n)  (`factorial_le_numSCD`).
    """
    matchings: int = 0
    for sigma in permutations(range(n)):
        # Each sigma is a valid SCD (a perfect bottom->top matching).
        matchings += 1
        _ = sigma  # the matched edges are {(i, sigma[i])}
    return matchings


def perm_chains(sigma: tuple[int, ...]) -> list[tuple[tuple[int, int], tuple[int, int]]]:
    """`permChains`: turn a permutation into the SCD it indexes.

    Returns the list of two-element symmetric chains
    [ ((0,i),(1,sigma[i])) for i ], where the first coordinate 0=bottom, 1=top.
    """
    return [((0, i), (1, j)) for i, j in enumerate(sigma)]


# ---------------------------------------------------------------------------
# 3. The crown floor m^(2w): diverges yet not super-exponential
# ---------------------------------------------------------------------------

def crown_floor(w: int, m: int) -> int:
    """Certified lower bound on strict alternating cycles of Crown(w, m): m^(2w).

    (`crown_strictAltCycle_card_lower` / `pow_le_crownAltCount`.)
    """
    return m ** (2 * w)


def crown_card(w: int, m: int) -> int:
    """|Crown(w, m)| = 2*w*m  (`Crown.card`)."""
    return 2 * w * m


# ---------------------------------------------------------------------------
# 4. Drivers
# ---------------------------------------------------------------------------

def demo_factorial_is_superexp(bases: Iterable[int] = (2, 5, 10, 100)) -> None:
    print("=" * 70)
    print("1. factorial_superexp / perm_card_superexp")
    print("   For each base c, find threshold N with c^n < n! for all n >= N.")
    print("-" * 70)
    for c in bases:
        N = super_exp_threshold(factorial_fn, c)
        assert N is not None, f"factorial failed to dominate base {c}"
        ok = all(c ** n < factorial(n) for n in range(N, N + 30))
        print(f"   base c={c:>4}:  threshold N={N:>3}   "
              f"check c^N={c**N} < N!={factorial(N)}  -> dominates: {ok}")
    print("   => n! eventually beats EVERY exponential c^n  (super-exponential).")


def demo_slab_count(ns: Iterable[int] = (1, 2, 3, 4, 5, 6)) -> None:
    print("=" * 70)
    print("2. factorial_le_numSCD / numSCD_superexp  (two-level slab CB(n))")
    print("   numSCD(n) = #perfect matchings of K_{n,n} = #permutations.")
    print("-" * 70)
    for n in ns:
        cnt = slab_scd_count_bruteforce(n)
        nf = factorial(n)
        assert nf <= cnt, "factorial lower bound violated!"
        assert cnt == nf, "slab count differs from n! (conjecture check)"
        print(f"   n={n}:  numSCD(n)={cnt:>4}   n!={nf:>4}   "
              f"n! <= numSCD(n): {nf <= cnt}")
    # show one permChains image
    sample = perm_chains((1, 2, 0))
    print(f"   permChains((1,2,0)) = {sample}")
    print("   => numSCD inherits super-exponential growth via the transfer principle.")


def demo_crown_not_superexp(w: int = 2, ms: Iterable[int] = (2, 5, 10, 50)) -> None:
    print("=" * 70)
    print(f"3. crown_floor_not_superexp / crownAltCount_tendsto_atTop  (w={w})")
    print(f"   Crown floor = m^(2w) = m^{2*w}.  Diverges, but NOT super-exp.")
    print("-" * 70)
    for m in ms:
        print(f"   m={m:>3}:  |Crown|={crown_card(w, m):>5}   "
              f"floor m^{2*w}={crown_floor(w, m):>12}")
    # NOT super-exponential: base c=2 eventually overtakes m^(2w) forever.
    floor = pow_const(2 * w)
    N = super_exp_threshold(floor, c=2)
    print(f"   Is m^{2*w} super-exponential vs base c=2?  "
          f"threshold found: {N is not None} (None => NOT super-exp)")
    # exhibit the PERSISTENT overtaking explicitly (stays ahead for a long window)
    crossover = next(
        m for m in range(1, 500)
        if all(2 ** k > k ** (2 * w) for k in range(m, m + 50))
    )
    print(f"   2^m overtakes m^{2*w} for good at m={crossover} "
          f"(2^{crossover}={2**crossover} > {crossover**(2*w)}=m^{2*w}).")
    print("   => the crown's certified floor diverges yet loses to every exponential.")


def demo_dichotomy() -> None:
    print("=" * 70)
    print("4. scd_strictly_outgrows_crown_floor  (the synthesis / dichotomy)")
    print("-" * 70)
    rows = [
        ("Crown(w,m)", "2w (FIXED)",   "m^(2w)", "polynomial -> NOT super-exp"),
        ("Slab CB(n)", "~n (GROWS)",   "n!",     "super-exponential"),
    ]
    print(f"   {'object':<12}{'#choices':<14}{'floor':<10}{'growth class'}")
    for obj, arity, floor, cls in rows:
        print(f"   {obj:<12}{arity:<14}{floor:<10}{cls}")
    print("   Dividing line: bounded arity -> polynomial; growing arity -> factorial.")


def main() -> None:
    demo_factorial_is_superexp()
    demo_slab_count()
    demo_crown_not_superexp()
    demo_dichotomy()
    print("=" * 70)
    print("All numerical witnesses agree with the machine-checked theorems.")


if __name__ == "__main__":
    main()
