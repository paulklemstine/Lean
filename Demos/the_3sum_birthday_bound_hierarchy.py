#!/usr/bin/env python3
"""
The 3SUM-Birthday-Bound Hierarchy: numerical demonstrations.

This self-contained script demonstrates, by direct computation, every
quantitative claim of the accompanying work:

  1. The reveal lemma.  For a semiprime N = p*q and any s with 0 < s < N and
     p | s, one has gcd(s, N) = p -- with no side condition "q does not
     divide s", which is implied by s < N.

  2. The N = 143 census.  Over all triples 1 <= a < b < c <= 12 there are
     exactly 20 triples whose sum is divisible by 11 and not by 13, and
     exactly 0 whose sum is divisible by both.

  3. The collapse of the hierarchy.  A collision is guaranteed on a search
     space S modulo p if and only if p < |S|.  Both directions are exhibited:
     the pigeonhole side and an explicit adversarial residue map that defeats
     any scheme with |S| <= p.

  4. The exponent illusion.  Raising the arity r lowers the stored-element
     count from ~p^(1/2) to ~p^(1/3) and beyond, but the number of inspected
     tuples always exceeds p, hence exceeds sqrt(N).

  5. The amplitude barrier.  r-tuples over A subset of [1, M] realise at most
     r*M + 1 distinct sums; when r*M < p every modular collision is trivial.

  6. The span barrier.  Any scheme revealing a factor f produces two values
     differing by at least f.

  7. The coverage barrier.  A fixed scheme with k search points and values
     below B reveals at most log_P(B) * k^2 primes >= P.

  8. End-to-end collision factoring on genuine semiprimes.

Run:  python3 demo.py
"""

from __future__ import annotations

import itertools
import math
from math import gcd, isqrt
from typing import Dict, Iterable, List, Optional, Sequence, Set, Tuple


# ---------------------------------------------------------------------------
# Section 1 -- the reveal lemma
# ---------------------------------------------------------------------------


def reveal(s: int, N: int) -> int:
    """The reveal step: one gcd turns a hidden multiple of p into p itself."""
    return gcd(s, N)


def check_reveal_lemma(p: int, q: int, verbose: bool = True) -> bool:
    """Exhaustively verify gcd(s, p*q) == p for all 0 < s < p*q with p | s."""
    N = p * q
    ok = True
    witnesses: List[int] = []
    for s in range(p, N, p):
        g = reveal(s, N)
        if g != p:
            ok = False
        witnesses.append(s)
    if verbose:
        print(f"  reveal lemma for N = {p}*{q} = {N}")
        print(f"    multiples of {p} strictly between 0 and {N}: {len(witnesses)}")
        print(f"    every one satisfies gcd(s, N) = {p}: {ok}")
        print(f"    sample: s = {witnesses[:6]} -> "
              f"{[reveal(s, N) for s in witnesses[:6]]}")
    return ok


def check_no_double_divisibility(p: int, q: int, verbose: bool = True) -> bool:
    """No 0 < s < p*q is divisible by both p and q (the hypothesis is free)."""
    N = p * q
    bad = [s for s in range(1, N) if s % p == 0 and s % q == 0]
    if verbose:
        print(f"    integers 0 < s < {N} divisible by both {p} and {q}: {len(bad)}")
    return not bad


# ---------------------------------------------------------------------------
# Section 2 -- the N = 143 census
# ---------------------------------------------------------------------------


def triple_census(n: int, p: int, q: int) -> Tuple[int, int, int]:
    """Count triples 1 <= a < b < c <= n by divisibility of a+b+c.

    Returns (total, mod_p_only, mod_both).
    """
    total = 0
    mod_p_only = 0
    mod_both = 0
    for a, b, c in itertools.combinations(range(1, n + 1), 3):
        total += 1
        s = a + b + c
        dp, dq = (s % p == 0), (s % q == 0)
        if dp and not dq:
            mod_p_only += 1
        if dp and dq:
            mod_both += 1
    return total, mod_p_only, mod_both


def demo_census() -> None:
    print("\n[2] Census for N = 143 = 11 * 13")
    for n in (11, 12, 15):
        total, only_p, both = triple_census(n, 11, 13)
        print(f"    1 <= a < b < c <= {n:2d}:  {total:4d} triples,  "
              f"{only_p:3d} reveal 11,  {both} divisible by both")
    print("    the 'both' column is structurally empty: any such sum would be")
    print("    a positive multiple of 143, but all sums here are below 143.")
    winners = [(a, b, c) for a, b, c in itertools.combinations(range(1, 13), 3)
               if (a + b + c) % 11 == 0]
    print(f"    first revealing triples: {winners[:5]}")
    print(f"    each yields gcd(a+b+c, 143) = "
          f"{sorted({gcd(a + b + c, 143) for a, b, c in winners})}")


# ---------------------------------------------------------------------------
# Section 3 -- the collapse: threshold is |S|, not the arity
# ---------------------------------------------------------------------------


def find_collision(values: Sequence[int], p: int) -> Optional[Tuple[int, int]]:
    """Return two indices whose values are congruent modulo p, if any."""
    seen: Dict[int, int] = {}
    for i, v in enumerate(values):
        r = v % p
        if r in seen:
            return seen[r], i
        seen[r] = i
    return None


def adversarial_residue_map(space_size: int, p: int) -> Optional[List[int]]:
    """An injective residue map defeating any scheme with |S| <= p.

    Returns a list of |S| distinct residues in [0, p), or None if |S| > p
    (in which case, by pigeonhole, no such map exists).
    """
    if space_size > p:
        return None
    return list(range(space_size))


def demo_collapse(p: int = 97) -> None:
    print(f"\n[3] The collapse: threshold = |S|, modulus p = {p}")
    for size in (p - 1, p, p + 1, p + 40):
        adv = adversarial_residue_map(size, p)
        if adv is None:
            print(f"    |S| = {size:4d} > p : NO injective residue map exists; "
                  f"a collision is guaranteed")
        else:
            coll = find_collision(adv, p)
            print(f"    |S| = {size:4d} <= p: adversary succeeds, "
                  f"collision found = {coll is not None}")
    print("    the criterion mentions |S| only -- never the arity r.")


# ---------------------------------------------------------------------------
# Section 4 -- the exponent illusion
# ---------------------------------------------------------------------------


def storage_threshold(p: int, r: int) -> int:
    """Smallest k with k**r > p."""
    if r == 0:
        raise ValueError("arity must be positive")
    k = max(1, round(p ** (1.0 / r)))
    while k ** r <= p:
        k += 1
    while k > 1 and (k - 1) ** r > p:
        k -= 1
    return k


def hierarchy_table(p: int, q: int, arities: Iterable[int] = (2, 3, 4, 5, 6)) -> None:
    N = p * q
    print(f"\n[4] Hierarchy table for N = {N} = {p} * {q}, "
          f"floor(sqrt(N)) = {isqrt(N)}")
    print(f"    {'arity r':>7} | {'stored k':>10} | {'inspected k^r':>16} | "
          f"{'> p ?':>6} | {'> sqrt(N) ?':>12}")
    print("    " + "-" * 64)
    for r in arities:
        k = storage_threshold(p, r)
        work = k ** r
        print(f"    {r:>7} | {k:>10} | {work:>16} | "
              f"{str(work > p):>6} | {str(work > isqrt(N)):>12}")
    print("    storage shrinks like p^(1/r); inspected tuples never drop below p.")


def demo_exponent_gap_997() -> None:
    p = 997
    print(f"\n[4b] The exponent gap at p = {p}")
    k2, k3 = storage_threshold(p, 2), storage_threshold(p, 3)
    print(f"    sumset (r=2): smallest k with k^2 > {p} is k = {k2}, "
          f"work = {k2 ** 2}")
    print(f"    3SUM   (r=3): smallest k with k^3 > {p} is k = {k3}, "
          f"work = {k3 ** 3}")
    print(f"    storage improves by {k2 / k3:.2f}x; "
          f"work differs by {abs(k2 ** 2 - k3 ** 3) / min(k2 ** 2, k3 ** 3) * 100:.1f}%")
    assert (k2, k3) == (32, 10)
    assert 31 ** 2 <= p < 32 ** 2 and 9 ** 3 <= p < 10 ** 3


# ---------------------------------------------------------------------------
# Section 5 -- the amplitude barrier
# ---------------------------------------------------------------------------


def sum_set(A: Sequence[int], r: int) -> Set[int]:
    """All distinct integer sums of r-tuples drawn (with repetition) from A."""
    sums: Set[int] = {0}
    for _ in range(r):
        sums = {s + a for s in sums for a in A}
    return sums


def demo_amplitude(p: int = 11, r: int = 3, max_M: int = 8) -> None:
    print(f"\n[5] Amplitude barrier, p = {p}, arity r = {r}")
    print(f"    {'M':>3} | {'|A|^r':>7} | {'distinct sums':>14} | "
          f"{'bound rM+1':>11} | {'> p ?':>6} | {'all trivial?':>13}")
    print("    " + "-" * 70)
    first_ok: Optional[int] = None
    for M in range(1, max_M + 1):
        A = list(range(1, M + 1))
        S = sum_set(A, r)
        trivial = (r * M < p)
        useful = len(S) > p
        if useful and first_ok is None:
            first_ok = M
        print(f"    {M:>3} | {len(A) ** r:>7} | {len(S):>14} | "
              f"{r * M + 1:>11} | {str(useful):>6} | {str(trivial):>13}")
    print(f"    smallest workable entry bound: M = {first_ok} "
          f"(predicted ceil(p/r)+1 = {-(-p // r) + 1})")
    print("    note: |A|^r can be huge while the distinct-sum count stays <= rM+1.")


def demo_amplitude_thresholds() -> None:
    print("\n[5b] Measured amplitude thresholds (full interval A = [1, M], r = 3)")
    for p in (11, 101):
        r = 3
        M = 1
        while len(range(r, r * M + 1)) <= p:
            M += 1
        predicted = -(-p // r) + 1
        print(f"    p = {p:4d}: measured M = {M}, predicted ceil(p/3)+1 = {predicted}")
        assert M == predicted


# ---------------------------------------------------------------------------
# Section 6 -- the span barrier
# ---------------------------------------------------------------------------


def scheme_differences(values: Sequence[int]) -> Set[int]:
    """All nonnegative pairwise differences of a scheme's values."""
    return {abs(x - y) for x in values for y in values}


def demo_span(p: int = 61, q: int = 53) -> None:
    N = p * q
    print(f"\n[6] Span barrier, N = {N} = {p} * {q}, floor(sqrt(N)) = {isqrt(N)}")
    small = list(range(0, isqrt(N)))          # all values below sqrt(N)
    diffs = scheme_differences(small)
    revealed = {gcd(d, N) for d in diffs if d > 0}
    print(f"    scheme with all values < sqrt(N) = {isqrt(N)}: "
          f"{len(diffs)} differences")
    print(f"    factors it can reveal: {sorted(revealed - {1})} "
          f"(the larger factor p = {p} is absent)")
    print(f"    max difference {max(diffs)} < p = {p}: revealing p is "
          f"impossible, by the span barrier")
    assert p not in revealed
    wide = [0, p, 2 * p, 3 * p]
    revealed_wide = {gcd(d, N) for d in scheme_differences(wide) if d > 0}
    print(f"    a scheme spanning >= p does reveal it: {sorted(revealed_wide)}")


# ---------------------------------------------------------------------------
# Section 7 -- the coverage barrier
# ---------------------------------------------------------------------------


def large_prime_divisors(d: int, P: int) -> Set[int]:
    """Distinct prime divisors of d that are at least P."""
    out: Set[int] = set()
    m, f = d, 2
    while f * f <= m:
        if m % f == 0:
            if f >= P:
                out.add(f)
            while m % f == 0:
                m //= f
        f += 1
    if m > 1 and m >= P:
        out.add(m)
    return out


def demo_coverage(k: int = 12, B: int = 10 ** 6, P: int = 100, seed: int = 7) -> None:
    print(f"\n[7] Coverage barrier: k = {k} search points, values < B = {B}, "
          f"P = {P}")
    # deterministic pseudo-random values, no external dependencies
    state = seed
    values: List[int] = []
    for _ in range(k):
        state = (1103515245 * state + 12345) % (2 ** 31)
        values.append(state % B)
    diffs = {d for d in scheme_differences(values) if 0 < d <= B}
    exposed: Set[int] = set()
    for d in diffs:
        exposed |= large_prime_divisors(d, P)
    bound = int(math.log(B, P)) * k ** 2
    print(f"    pairwise differences: {len(diffs)} (bound k^2 = {k ** 2})")
    print(f"    distinct primes >= {P} exposed: {len(exposed)}")
    print(f"    coverage bound log_P(B) * k^2 = {bound}")
    print(f"    bound respected: {len(exposed) <= bound}")
    assert len(exposed) <= bound


# ---------------------------------------------------------------------------
# Section 8 -- end-to-end collision factoring
# ---------------------------------------------------------------------------


def collision_factor(N: int, r: int, M: int) -> Optional[Tuple[int, int, int]]:
    """Factor N by an r-SUM collision search over A = {1, ..., M}.

    Returns (s, t, factor) where s > t are achieved r-tuple sums with
    gcd(s - t, N) a nontrivial factor, or None if no useful collision exists.
    Note that p is never used by the search: only the final gcd test looks
    at N.
    """
    sums = sorted(sum_set(list(range(1, M + 1)), r))
    for i, s in enumerate(sums):
        for t in sums[:i]:
            g = gcd(s - t, N)
            if 1 < g < N:
                return s, t, g
    return None


def demo_end_to_end() -> None:
    print("\n[8] End-to-end r-SUM collision factoring")
    cases: List[Tuple[int, int, int, int]] = [
        (11, 13, 3, 6),     # N = 143
        (23, 19, 3, 12),    # N = 437
        (31, 29, 2, 20),    # N = 899
        (41, 37, 4, 14),    # N = 1517
    ]
    for p, q, r, M in cases:
        N = p * q
        res = collision_factor(N, r, M)
        if res is None:
            print(f"    N = {N:5d}, r = {r}, M = {M:3d}: no useful collision "
                  f"(amplitude barrier: r*M = {r * M} vs p = {p})")
        else:
            s, t, g = res
            print(f"    N = {N:5d} = {p}*{q}, r = {r}, M = {M:3d}: "
                  f"sums {s} and {t}, gcd({s - t}, {N}) = {g}  "
                  f"[{'correct' if N % g == 0 and 1 < g < N else 'ERROR'}]")
    print("    below the amplitude threshold the search provably fails:")
    p, q, r, M = 41, 37, 3, 5
    N = p * q
    res = collision_factor(N, r, M)
    print(f"    N = {N}, r = {r}, M = {M}: r*M = {r * M} < p = {p}  ->  "
          f"result = {res}")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------


def main() -> None:
    print("=" * 74)
    print("THE 3SUM-BIRTHDAY-BOUND HIERARCHY -- numerical demonstrations")
    print("=" * 74)

    print("\n[1] The reveal lemma")
    for p, q in ((11, 13), (17, 19), (61, 53)):
        assert check_reveal_lemma(p, q)
        assert check_no_double_divisibility(p, q)

    demo_census()
    demo_collapse()
    hierarchy_table(1009, 997)
    demo_exponent_gap_997()
    demo_amplitude()
    demo_amplitude_thresholds()
    demo_span()
    demo_coverage()
    demo_end_to_end()

    print("\n" + "=" * 74)
    print("All demonstrations completed; every assertion held.")
    print("=" * 74)


if __name__ == "__main__":
    main()
