"""
Exact Coverings by Distinct Unit Fractions
==========================================

Numerical demonstrations of the structure theory of exact Egyptian coverings:
finite sets S of integers >= 2 with  sum_{n in S} 1/n = 1.

Everything here is exact rational arithmetic (fractions.Fraction) -- no floats
are used in any statement that is claimed to be an identity.

Contents
--------
 1. Basic verification of coverings, and the archetype {2, 3, 6}.
 2. Minimum size 3, and uniqueness of the three-term covering {2, 3, 6}
    (exhaustive check over a finite window, plus the sharp inequality).
 3. The splitting operator 1/m = 1/(m+1) + 1/(m(m+1)) and the cardinality
    spectrum {3, 4, 5, ...}.
 4. Bracketing: every covering has an element <= |S| and an element >= |S|.
 5. The dyadic harmonic lower bound  sum_{n=2}^{2^k} 1/n >= k/2.
 6. The local p-adic obstruction: the maximal p-power is attained twice.
 7. p-adic separation: primes, prime powers, pairwise coprime sets are
    covering-free; divergence of reciprocals does NOT imply a covering.
 8. Explicit coverings evading the obstructions (21 non-prime-powers; 23
    denominators all >= 10).
 9. Divisor duality with pseudoperfect numbers, the deficiency obstruction,
    and the weird number 70.
10. Finitisation: EG(1, N) is true exactly for N >= 6.
11. A two-colouring of {2, ..., 55} with no monochromatic exact covering,
    verified by two independent exact searches.

Run:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction
from itertools import combinations
from math import gcd, isqrt
from typing import Dict, Iterable, List, Optional, Sequence, Set, Tuple

# ----------------------------------------------------------------------------
# 0. Basic utilities
# ----------------------------------------------------------------------------


def reciprocal_sum(s: Iterable[int]) -> Fraction:
    """Exact value of sum_{n in s} 1/n as a rational number."""
    return sum((Fraction(1, n) for n in s), Fraction(0))


def is_covering(s: Sequence[int]) -> bool:
    """True iff `s` is an exact Egyptian covering: distinct integers >= 2 with
    reciprocal sum exactly 1."""
    members = set(s)
    if len(members) != len(list(s)):
        return False
    if any(n < 2 for n in members):
        return False
    return reciprocal_sum(members) == 1


def prime_factors(n: int) -> Dict[int, int]:
    """Prime factorisation of n >= 1 as {prime: exponent}, by trial division."""
    factors: Dict[int, int] = {}
    m = n
    d = 2
    while d * d <= m:
        while m % d == 0:
            factors[d] = factors.get(d, 0) + 1
            m //= d
        d += 1 if d == 2 else 2
    if m > 1:
        factors[m] = factors.get(m, 0) + 1
    return factors


def valuation(n: int, p: int) -> int:
    """The p-adic valuation v_p(n): the exponent of p in n."""
    v = 0
    while n % p == 0 and n > 0:
        n //= p
        v += 1
    return v


def is_prime(n: int) -> bool:
    if n < 2:
        return False
    if n % 2 == 0:
        return n == 2
    for d in range(3, isqrt(n) + 1, 2):
        if n % d == 0:
            return False
    return True


def is_prime_power(n: int) -> bool:
    """True iff n = p^e for a prime p and e >= 1."""
    return n >= 2 and len(prime_factors(n)) == 1


def divisors(n: int) -> List[int]:
    """All positive divisors of n, sorted."""
    small = [d for d in range(1, isqrt(n) + 1) if n % d == 0]
    big = [n // d for d in reversed(small) if n // d != d]
    return small + big


def banner(title: str) -> None:
    print()
    print("=" * 74)
    print(title)
    print("=" * 74)


# ----------------------------------------------------------------------------
# 1. The archetype
# ----------------------------------------------------------------------------


def demo_archetype() -> None:
    banner("1. The archetype: 1 = 1/2 + 1/3 + 1/6")
    s = [2, 3, 6]
    print(f"  S = {s}")
    print(f"  sum 1/n  = {reciprocal_sum(s)}")
    print(f"  covering = {is_covering(s)}")


# ----------------------------------------------------------------------------
# 2. Minimum size, and uniqueness in size three
# ----------------------------------------------------------------------------


def search_coverings(limit: int, size: int) -> List[Tuple[int, ...]]:
    """All exact coverings of the given size with denominators in [2, limit]."""
    return [
        c
        for c in combinations(range(2, limit + 1), size)
        if reciprocal_sum(c) == 1
    ]


def demo_minimum_size() -> None:
    banner("2. No covering with 1 or 2 terms; the 3-term covering is unique")
    print("  Exhaustive search with denominators up to 200:")
    for size in (1, 2, 3):
        found = search_coverings(200, size)
        print(f"    size {size}: {found if found else 'none'}")
    print()
    print("  The two-term bound is sharp: for distinct a < b with a >= 2,")
    print("  the largest possible value is 1/2 + 1/3 = "
          f"{Fraction(1, 2) + Fraction(1, 3)} < 1.")
    print()
    print("  Size-4 coverings with denominators up to 60:")
    for c in search_coverings(60, 4):
        print(f"    {c}")


# ----------------------------------------------------------------------------
# 3. The splitting operator and the cardinality spectrum
# ----------------------------------------------------------------------------


def split_maximum(s: Set[int]) -> Set[int]:
    """One application of the splitting operator: remove the maximum m and
    insert m+1 and m(m+1), using 1/m = 1/(m+1) + 1/(m(m+1))."""
    m = max(s)
    out = set(s)
    out.remove(m)
    out.add(m + 1)
    out.add(m * (m + 1))
    return out


def covering_of_size(k: int) -> Set[int]:
    """An exact covering with exactly k elements, for any k >= 3."""
    if k < 3:
        raise ValueError("no exact covering has fewer than 3 elements")
    s: Set[int] = {2, 3, 6}
    while len(s) < k:
        s = split_maximum(s)
    return s


def demo_spectrum() -> None:
    banner("3. Splitting operator and the cardinality spectrum {3, 4, 5, ...}")
    print("  Identity check 1/m = 1/(m+1) + 1/(m(m+1)) for m = 2..10:")
    ok = all(
        Fraction(1, m) == Fraction(1, m + 1) + Fraction(1, m * (m + 1))
        for m in range(2, 11)
    )
    print(f"    all identities exact: {ok}")
    print()
    print("  The splitting ladder from {2, 3, 6}:")
    s: Set[int] = {2, 3, 6}
    for _ in range(5):
        pretty = sorted(s)
        shown = pretty if len(str(pretty)) < 62 else pretty[:4] + ["..."]
        print(f"    |S| = {len(s):2d}  sum = {reciprocal_sum(s)}   {shown}")
        s = split_maximum(s)
    print()
    print("  Coverings of every size 3..12 exist (verified exactly):")
    for k in range(3, 13):
        c = covering_of_size(k)
        assert is_covering(sorted(c)) and len(c) == k
    print("    sizes 3..12: all realised, all reciprocal sums exactly 1")


# ----------------------------------------------------------------------------
# 4. Bracketing
# ----------------------------------------------------------------------------


def demo_bracketing() -> None:
    banner("4. Bracketing: min(S) <= |S| <= max(S)")
    samples: List[List[int]] = [
        [2, 3, 6],
        [2, 3, 7, 42],
        [2, 3, 7, 43, 1806],
        [6, 10, 12, 14, 15, 18, 20, 21, 22, 24, 28,
         30, 33, 36, 40, 42, 44, 45, 55, 60, 63],
        [10, 11, 12, 14, 15, 16, 18, 20, 21, 22, 24, 28,
         30, 33, 36, 40, 42, 45, 48, 55, 60, 63, 66],
    ]
    print(f"  {'|S|':>4} {'min':>6} {'max':>10}   bracketing holds")
    for s in samples:
        assert is_covering(s)
        print(f"  {len(s):>4} {min(s):>6} {max(s):>10}   "
              f"{min(s) <= len(s) <= max(s)}")
    print()
    print("  Consequence: a covering with all denominators >= 10 needs >= 11")
    print("  terms; the explicit example above uses 23.")


# ----------------------------------------------------------------------------
# 5. The dyadic harmonic bound
# ----------------------------------------------------------------------------


def demo_dyadic() -> None:
    banner("5. Dyadic harmonic bound: sum_{n=2}^{2^k} 1/n >= k/2")
    print(f"  {'k':>3} {'sum (exact, decimal)':>24} {'k/2':>7}   holds")
    for k in range(0, 13):
        total = sum((Fraction(1, n) for n in range(2, 2 ** k + 1)),
                    Fraction(0))
        print(f"  {k:>3} {float(total):>24.6f} {k / 2:>7.2f}   "
              f"{total >= Fraction(k, 2)}")
    print()
    print("  Each dyadic block (2^k, 2^{k+1}] has 2^k terms, each >= 2^-(k+1),")
    print("  so contributes at least 1/2. Divergence needs no analysis.")


# ----------------------------------------------------------------------------
# 6. The local p-adic obstruction
# ----------------------------------------------------------------------------


def valuation_profile(s: Sequence[int], p: int) -> List[Tuple[int, int]]:
    return [(n, valuation(n, p)) for n in sorted(s)]


def max_valuation_attained_twice(s: Sequence[int], p: int) -> bool:
    """True iff the maximal positive p-adic valuation among members of s is
    attained by at least two members (or no member is divisible by p)."""
    vals = [valuation(n, p) for n in s]
    top = max(vals)
    if top == 0:
        return True
    return vals.count(top) >= 2


def demo_local_obstruction() -> None:
    banner("6. Local obstruction: the maximal p-power is attained twice")
    coverings: List[List[int]] = [
        [2, 3, 6],
        [2, 3, 7, 42],
        [2, 4, 6, 12],
        [6, 10, 12, 14, 15, 18, 20, 21, 22, 24, 28,
         30, 33, 36, 40, 42, 44, 45, 55, 60, 63],
    ]
    for s in coverings:
        assert is_covering(s), s
        primes = sorted({p for n in s for p in prime_factors(n)})
        flags = {p: max_valuation_attained_twice(s, p) for p in primes}
        head = s if len(s) <= 6 else s[:5] + ["..."]
        print(f"  S = {head}")
        for p in primes:
            top = max(valuation(n, p) for n in s)
            wit = [n for n in s if valuation(n, p) == top]
            print(f"    p = {p:>2}: max v_p = {top}, attained by {wit}")
        print(f"    all primes doubly attained: {all(flags.values())}")
        print()
    print("  Pairing corollary: the number of multiples of p is never 1.")
    for s in coverings:
        for p in sorted({p for n in s for p in prime_factors(n)}):
            assert sum(1 for n in s if n % p == 0) != 1
    print("    verified on all examples above.")


# ----------------------------------------------------------------------------
# 7. p-adic separation and the failure of "divergence implies covering"
# ----------------------------------------------------------------------------


def is_padically_separated(a: Sequence[int]) -> bool:
    """True iff no two distinct members share the same positive p-adic
    valuation at any prime p."""
    primes = sorted({p for n in a for p in prime_factors(n)})
    for p in primes:
        seen: Dict[int, int] = {}
        for n in a:
            v = valuation(n, p)
            if v > 0:
                if v in seen:
                    return False
                seen[v] = n
    return True


def has_covering_subset(a: Sequence[int]) -> Optional[Tuple[int, ...]]:
    """Search all subsets of a small set `a` for an exact covering."""
    for size in range(3, len(a) + 1):
        for c in combinations(sorted(a), size):
            if reciprocal_sum(c) == 1:
                return c
    return None


def demo_separation() -> None:
    banner("7. p-adic separation: primes and prime powers are covering-free")
    primes = [p for p in range(2, 60) if is_prime(p)]
    powers = sorted({p ** e for p in (2, 3, 5, 7) for e in (1, 2, 3, 4)
                     if p ** e < 100})
    coprime_family = [2, 9, 25, 49, 11, 13]
    for name, a in (("primes < 60", primes),
                    ("prime powers < 100", powers),
                    ("pairwise coprime family", coprime_family)):
        sep = is_padically_separated(a)
        found = has_covering_subset(a[:14])
        print(f"  {name:>24}: p-adically separated = {sep}, "
              f"covering subset = {found}")
    print()
    print("  Reciprocal sum of the primes grows without bound, slowly:")
    running = Fraction(0)
    marks = {10, 100, 1000, 5000}
    for n in range(2, 5001):
        if is_prime(n):
            running += Fraction(1, n)
        if n in marks:
            print(f"    sum_{{p <= {n:>4}}} 1/p = {float(running):.6f}")
    print()
    print("  So the primes are reciprocally divergent yet covering-free:")
    print("  divergence of a colour class can NEVER, by itself, produce an")
    print("  exact covering.")


# ----------------------------------------------------------------------------
# 8. Explicit coverings evading the obstructions
# ----------------------------------------------------------------------------


NON_PRIME_POWER_COVERING: List[int] = [
    6, 10, 12, 14, 15, 18, 20, 21, 22, 24, 28,
    30, 33, 36, 40, 42, 44, 45, 55, 60, 63,
]

MIN_TEN_COVERING: List[int] = [
    10, 11, 12, 14, 15, 16, 18, 20, 21, 22, 24, 28,
    30, 33, 36, 40, 42, 45, 48, 55, 60, 63, 66,
]


def demo_explicit_witnesses() -> None:
    banner("8. Explicit coverings that dodge the obstructions")
    s = NON_PRIME_POWER_COVERING
    print(f"  A 21-term covering with no prime powers ({len(s)} terms):")
    print(f"    {s}")
    print(f"    reciprocal sum = {reciprocal_sum(s)}")
    print(f"    any prime powers? {any(is_prime_power(n) for n in s)}")
    print(f"    all divide 27720? {all(27720 % n == 0 for n in s)}")
    print()
    t = MIN_TEN_COVERING
    print(f"  A 23-term covering with every denominator >= 10 ({len(t)} terms):")
    print(f"    {t}")
    print(f"    reciprocal sum = {reciprocal_sum(t)}, min = {min(t)}")
    print()
    print("  Unconditional two-colour consequences:")
    print("    - if colour 0 is used only on prime powers, colour 1 contains")
    print("      the 21-term covering;")
    print("    - if colour 0 is used only below 10, colour 1 contains the")
    print("      23-term covering.")


# ----------------------------------------------------------------------------
# 9. Divisor duality with pseudoperfect numbers
# ----------------------------------------------------------------------------


def subset_summing_to(target: int, parts: Sequence[int]) -> Optional[List[int]]:
    """Distinct subset of `parts` summing exactly to `target`, by dynamic
    programming with parent pointers. Returns None if impossible."""
    reachable: Dict[int, Optional[int]] = {0: None}
    order: List[int] = []
    for x in parts:
        additions: Dict[int, Optional[int]] = {}
        for total in reachable:
            nxt = total + x
            if nxt <= target and nxt not in reachable and nxt not in additions:
                additions[nxt] = x
        reachable.update(additions)
        order.append(x)
        if target in reachable:
            break
    if target not in reachable:
        return None
    # Reconstruct greedily: re-run the DP recording one witness per total.
    witness: Dict[int, Tuple[int, int]] = {}
    totals: Set[int] = {0}
    for x in order:
        new_totals = set()
        for total in totals:
            nxt = total + x
            if nxt <= target and nxt not in totals and nxt not in witness:
                witness[nxt] = (total, x)
                new_totals.add(nxt)
        totals |= new_totals
    if target not in witness:
        return None
    chosen: List[int] = []
    cur = target
    while cur != 0:
        prev, x = witness[cur]
        chosen.append(x)
        cur = prev
    return sorted(chosen)


def is_pseudoperfect(n: int) -> bool:
    """True iff some set of distinct proper divisors of n sums to n."""
    proper = [d for d in divisors(n) if d < n]
    return subset_summing_to(n, proper) is not None


def covering_from_pseudoperfect(n: int) -> Optional[List[int]]:
    """Dualise a pseudoperfect representation of n into an exact covering,
    via d -> n/d."""
    proper = [d for d in divisors(n) if d < n]
    d_set = subset_summing_to(n, proper)
    if d_set is None:
        return None
    return sorted(n // d for d in d_set)


def abundance(n: int) -> int:
    """sigma(n) - 2n : positive iff abundant, zero iff perfect."""
    return sum(divisors(n)) - 2 * n


def demo_duality() -> None:
    banner("9. Divisor duality: pseudoperfect numbers <-> exact coverings")
    print(f"  {'N':>5} {'status':>12} {'covering from divisors of N'}")
    for n in (6, 12, 20, 24, 28, 70, 27720):
        a = abundance(n)
        status = ("perfect" if a == 0 else
                  "abundant" if a > 0 else "deficient")
        cov = covering_from_pseudoperfect(n)
        if cov is None:
            shown = "NONE (not pseudoperfect)"
        else:
            assert is_covering(cov)
            shown = str(cov if len(cov) <= 8 else cov[:7] + ["..."])
        print(f"  {n:>5} {status:>12} {shown}")
    print()
    print("  Deficient numbers are barren (global mass obstruction):")
    for n in (8, 9, 27, 49, 125):
        print(f"    N = {n:>4}: deficient (sigma - 2N = {abundance(n)}), "
              f"covering = {covering_from_pseudoperfect(n)}")
    print()
    print("  The weird number 70 defeats both obstructions:")
    div70 = [d for d in divisors(70) if d >= 2]
    print(f"    divisors >= 2 : {div70}")
    print(f"    proper divisor sum = {sum(d for d in divisors(70) if d < 70)}"
          f" > 70   (abundant: plenty of mass)")
    print(f"    p-adically separated? {is_padically_separated(div70)}"
          "   (2 and 10 both have v_2 = 1)")
    print(f"    contains a covering?  "
          f"{has_covering_subset(div70) is not None}")
    print("    => a third mechanism ('weirdness') blocks exact coverings.")


# ----------------------------------------------------------------------------
# 10. Finitisation: the one-colour bound
# ----------------------------------------------------------------------------


def exists_covering_within(bound: int) -> bool:
    """True iff some exact covering has all denominators <= bound."""
    pool = list(range(2, bound + 1))
    for size in range(3, len(pool) + 1):
        for c in combinations(pool, size):
            if reciprocal_sum(c) == 1:
                return True
    return False


def demo_finitisation() -> None:
    banner("10. Finitisation: the one-colour bound EG(1, N)")
    print("  With one colour, EG(1, N) says simply that some exact covering")
    print("  uses only denominators <= N.")
    print(f"  {'N':>3}  EG(1, N)")
    for n in range(2, 9):
        print(f"  {n:>3}  {exists_covering_within(n)}")
    print()
    print("  So the optimal one-colour bound is exactly N = 6, witnessed by")
    print("  {2, 3, 6} -- the unique minimal covering.")
    print()
    print("  For r >= 2 the bound N(r) is known to exist (by a compactness")
    print("  argument taking an ultrafilter limit of bad colourings), but the")
    print("  argument yields no numerical value. Determining N(2) is open.")


# ----------------------------------------------------------------------------
# 11. An adversarial two-colouring of {2, ..., 55}
# ----------------------------------------------------------------------------


def class_contains_covering_mitm(cls: Sequence[int]) -> Optional[List[int]]:
    """Meet-in-the-middle search for a subset of `cls` with reciprocal sum 1.
    Exact: all values are integers L/n with L = lcm(cls), target L."""
    if not cls:
        return None
    ell = 1
    for n in cls:
        ell = ell * n // gcd(ell, n)
    items = [(n, ell // n) for n in sorted(cls)]
    half = len(items) // 2
    left, right = items[:half], items[half:]
    table: Dict[int, Tuple[int, ...]] = {}
    for size in range(len(left) + 1):
        for combo in combinations(left, size):
            total = sum(v for _, v in combo)
            if total <= ell:
                table.setdefault(total, tuple(n for n, _ in combo))
    for size in range(len(right) + 1):
        for combo in combinations(right, size):
            total = sum(v for _, v in combo)
            if total <= ell and (ell - total) in table:
                return sorted(list(table[ell - total])
                              + [n for n, _ in combo])
    return None


def class_contains_covering_dfs(cls: Sequence[int]) -> bool:
    """Independent check: depth-first search with suffix-sum pruning and
    memoisation of failed states."""
    if not cls:
        return False
    ell = 1
    for n in cls:
        ell = ell * n // gcd(ell, n)
    vals = [ell // n for n in sorted(cls)]
    k = len(vals)
    suffix = [0] * (k + 1)
    for i in range(k - 1, -1, -1):
        suffix[i] = suffix[i + 1] + vals[i]
    failed: Set[Tuple[int, int]] = set()

    def dfs(i: int, rem: int) -> bool:
        if rem == 0:
            return True
        if i >= k or suffix[i] < rem or (i, rem) in failed:
            return False
        if vals[i] <= rem and dfs(i + 1, rem - vals[i]):
            return True
        if dfs(i + 1, rem):
            return True
        failed.add((i, rem))
        return False

    return dfs(0, ell)


ADVERSARY_55_RED: List[int] = [
    3, 4, 6, 7, 8, 10, 11, 14, 17, 20, 21, 24, 25, 27, 29, 31, 32, 33, 34,
    37, 41, 45, 46, 47, 49, 50, 52,
]
ADVERSARY_55_BLUE: List[int] = [
    2, 5, 9, 12, 13, 15, 16, 18, 19, 22, 23, 26, 28, 30, 35, 36, 38, 39, 40,
    42, 43, 44, 48, 51, 53, 54, 55,
]


def demo_adversary() -> None:
    banner("11. An adversarial two-colouring of {2, ..., 55}")
    red, blue = ADVERSARY_55_RED, ADVERSARY_55_BLUE
    assert sorted(red + blue) == list(range(2, 56))
    for name, cls in (("red ", red), ("blue", blue)):
        mitm = class_contains_covering_mitm(cls)
        dfs = class_contains_covering_dfs(cls)
        print(f"  {name} class ({len(cls):>2} elements), reciprocal mass "
              f"{float(reciprocal_sum(cls)):.4f}")
        print(f"       meet-in-the-middle: covering = {mitm}")
        print(f"       pruned DFS        : covering exists = {dfs}")
    print()
    print("  Both classes carry reciprocal mass far above 1, yet neither")
    print("  contains a subset of reciprocal sum exactly 1. So no bound N <= 55")
    print("  can work for two colours: the least valid bound exceeds 55.")
    print("  (This is a computational observation, not a proof of a bound.)")


# ----------------------------------------------------------------------------


def main() -> None:
    print(__doc__.split("Run:")[0].strip())
    demo_archetype()
    demo_minimum_size()
    demo_spectrum()
    demo_bracketing()
    demo_dyadic()
    demo_local_obstruction()
    demo_separation()
    demo_explicit_witnesses()
    demo_duality()
    demo_finitisation()
    demo_adversary()
    banner("All demonstrations completed with exact rational arithmetic.")


if __name__ == "__main__":
    main()
