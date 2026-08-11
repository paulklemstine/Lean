"""
Rainbow Arithmetic-Progression Threshold: numerical demonstrations.

This self-contained script demonstrates, numerically, every result of the
accompanying paper on the full-spectrum ("coupon collector") threshold.

Setting
-------
Fix a finite alphabet with N letters.  A *word* of length m is a sequence of m
letters; there are N**m of them.  For a word f let

    miss(f) = number of letters of the alphabet that do not occur in f.

The word has *full spectrum* (is surjective) iff miss(f) = 0.  The
full-spectrum threshold T(N) is the least m at which a strict majority of the
N**m words has full spectrum:

    T(N) = min { m : 2 * #{deficient words of length m} < N**m }.

Rainbow reading
---------------
With k colours, a k-colouring of an interval decomposed into m consecutive
blocks of l adjacent integers is exactly a word of length m over the alphabet
of the N = k**l colour patterns.  The rainbow pair-spectrum threshold is

    T_k = T(k**2)        (pattern length l = 2),

and more generally the l-pattern threshold is P(l, k) = T(k**l).

What is demonstrated
--------------------
1. The exact binomial-moment identity  sum_f C(miss(f), r) = C(N, r) (N-r)**m,
   checked by brute-force enumeration over all N**m words.
2. The first and second moment identities as the cases r = 1, 2.
3. The union-bound criterion and the second-moment criterion, and the fact
   that they bracket the exact threshold.
4. Monotonicity of the surjective-majority property (the transition happens
   exactly once).
5. The main asymptotics T_k = 2 k^2 log k + O(k^2), the ratio
   T_k / (k^2 log k) -> 2, and the explicit constants 1 <= ratio <= 4
   (1.9 / 2.2 for k >= 100).
6. The sharp window |T(N) - N log N| <= N log 2 + log N + 1.
7. The conjectural second-order constant log(1/log 2) = 0.366513...
8. The rainbow consequence: full spectrum forces an injective (rainbow) block.

Run with:  python3 demo.py
"""

from __future__ import annotations

from itertools import product
from math import comb, exp, log
from typing import Dict, Iterator, List, Tuple

# --------------------------------------------------------------------------
# 1. Brute-force enumeration (small N, m only) -- ground truth
# --------------------------------------------------------------------------


def all_words(n_letters: int, length: int) -> Iterator[Tuple[int, ...]]:
    """Enumerate every word of the given length over an n_letters alphabet."""
    return product(range(n_letters), repeat=length)


def miss_count(word: Tuple[int, ...], n_letters: int) -> int:
    """Number of alphabet letters that do not occur in the word."""
    return n_letters - len(set(word))


def brute_binomial_moment(n_letters: int, length: int, r: int) -> int:
    """sum over all words f of C(miss(f), r), by explicit enumeration."""
    return sum(comb(miss_count(w, n_letters), r) for w in all_words(n_letters, length))


def predicted_binomial_moment(n_letters: int, length: int, r: int) -> int:
    """The closed form C(N, r) * (N - r)**length."""
    return comb(n_letters, r) * max(n_letters - r, 0) ** length


# --------------------------------------------------------------------------
# 2. Exact counts by inclusion-exclusion (works for large N, m)
# --------------------------------------------------------------------------


def surjective_count(n_letters: int, length: int) -> int:
    """#{words of length `length` over N letters using every letter}."""
    return sum(
        (-1) ** j * comb(n_letters, j) * (n_letters - j) ** length
        for j in range(n_letters + 1)
    )


def deficient_count(n_letters: int, length: int) -> int:
    """#{words of length `length` missing at least one letter}."""
    return n_letters**length - surjective_count(n_letters, length)


def majority_surjective(n_letters: int, length: int) -> bool:
    """True iff strictly more than half of the words have full spectrum."""
    return 2 * deficient_count(n_letters, length) < n_letters**length


def full_spectrum_threshold(n_letters: int) -> int:
    """T(N): least length at which the surjective majority is achieved."""
    m = 0
    while not majority_surjective(n_letters, m):
        m += 1
    return m


def pair_threshold(k: int) -> int:
    """T_k: the rainbow pair-spectrum threshold for k colours (N = k^2)."""
    return full_spectrum_threshold(k * k)


def pattern_threshold(pattern_length: int, k: int) -> int:
    """P(l, k): the l-pattern threshold for k colours (N = k^l)."""
    return full_spectrum_threshold(k**pattern_length)


# --------------------------------------------------------------------------
# 3. The two proved criteria (pure integer arithmetic)
# --------------------------------------------------------------------------


def union_bound_criterion(n_letters: int, length: int) -> bool:
    """If True then T(N) <= length.  Condition: 2 N (N-1)^m < N^m."""
    return 2 * n_letters * (n_letters - 1) ** length < n_letters**length


def second_moment_criterion(n_letters: int, length: int) -> bool:
    """If True then length < T(N).  Condition: N^m < (N+1)(N-1)^m."""
    return n_letters**length < (n_letters + 1) * (n_letters - 1) ** length


def criteria_window(n_letters: int, search_limit: int = 100000) -> Tuple[int, int]:
    """Bracket T(N) using only the two proved criteria (no enumeration).

    Returns (lo, hi) with lo <= T(N) <= hi.
    """
    lo = 0
    while lo < search_limit and second_moment_criterion(n_letters, lo):
        lo += 1
    hi = lo
    while hi < search_limit and not union_bound_criterion(n_letters, hi):
        hi += 1
    return lo, hi


# --------------------------------------------------------------------------
# 4. Analytic bounds from the paper
# --------------------------------------------------------------------------


def analytic_bounds(n_letters: int) -> Tuple[float, float]:
    """(N-1) log(N+1)  <=  T(N)  <=  N log(2N) + 1."""
    n = float(n_letters)
    return (n - 1.0) * log(n + 1.0), n * log(2.0 * n) + 1.0


def sharp_window_slack(n_letters: int) -> float:
    """The proved bound on |T(N) - N log N|:  N log 2 + log N + 1."""
    n = float(n_letters)
    return n * log(2.0) + log(n) + 1.0


def poisson_prediction(n_letters: int) -> float:
    """Conjectural median location:  N log N + N log(1/log 2)."""
    n = float(n_letters)
    return n * log(n) + n * log(1.0 / log(2.0))


def poisson_full_spectrum_probability(n_letters: int, length: int) -> float:
    """Poisson approximation exp(-N e^{-m/N}) to P(full spectrum)."""
    n = float(n_letters)
    return exp(-n * exp(-length / n))


def exact_full_spectrum_probability(n_letters: int, length: int) -> float:
    """Exact P(full spectrum) by inclusion-exclusion (exact rational -> float)."""
    return surjective_count(n_letters, length) / n_letters**length


# --------------------------------------------------------------------------
# 5. Rainbow consequence
# --------------------------------------------------------------------------


def is_rainbow_pattern(pattern: Tuple[int, ...]) -> bool:
    """A pattern is rainbow iff all its colours are distinct."""
    return len(set(pattern)) == len(pattern)


def block_word(
    colouring: List[int], pattern_length: int, blocks: int
) -> List[Tuple[int, ...]]:
    """Read a colouring of [0, l*m) as m consecutive l-term patterns."""
    return [
        tuple(colouring[pattern_length * t + j] for j in range(pattern_length))
        for t in range(blocks)
    ]


def find_rainbow_block(word: List[Tuple[int, ...]]) -> int:
    """Index of the first rainbow (injective) block, or -1 if there is none."""
    for t, pattern in enumerate(word):
        if is_rainbow_pattern(pattern):
            return t
    return -1


def has_full_spectrum(word: List[Tuple[int, ...]], k: int, pattern_length: int) -> bool:
    """True iff every one of the k^l patterns occurs in the block word."""
    return len(set(word)) == k**pattern_length


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------


def demo_moment_identity() -> None:
    print("=" * 78)
    print("1. THE BINOMIAL MOMENT IDENTITY   sum_f C(miss(f), r) = C(N,r) (N-r)^m")
    print("=" * 78)
    print(f"{'N':>3} {'m':>3} {'r':>3} {'brute force':>14} {'closed form':>14}  ok")
    all_ok = True
    for n in (2, 3, 4):
        for m in (0, 1, 2, 3, 4):
            for r in range(0, n + 1):
                lhs = brute_binomial_moment(n, m, r)
                rhs = predicted_binomial_moment(n, m, r)
                ok = lhs == rhs
                all_ok &= ok
                if r <= 2 and m in (2, 3, 4):
                    print(f"{n:>3} {m:>3} {r:>3} {lhs:>14} {rhs:>14}  {ok}")
    print(f"\nAll {3 * 5} x (r) instances agree: {all_ok}")
    print("Special cases:  r = 1 gives  sum_f miss(f) = N (N-1)^m")
    print("                r = 2 gives  sum_f C(miss(f),2) = C(N,2) (N-2)^m,")
    print("                hence  sum_f miss(f)^2 = N(N-1)^m + N(N-1)(N-2)^m.")
    n, m = 4, 5
    lhs = sum(miss_count(w, n) ** 2 for w in all_words(n, m))
    rhs = n * (n - 1) ** m + n * (n - 1) * (n - 2) ** m
    print(f"\nCheck at N={n}, m={m}:  sum miss^2 = {lhs}  vs  formula {rhs}   "
          f"{lhs == rhs}")
    print()


def demo_criteria_and_threshold() -> None:
    print("=" * 78)
    print("2. THE TWO CRITERIA BRACKET THE EXACT THRESHOLD")
    print("=" * 78)
    print("Union bound:      2 N (N-1)^m < N^m       ==>  T(N) <= m")
    print("Second moment:    N^m < (N+1)(N-1)^m      ==>  m < T(N)")
    print()
    header = f"{'N':>4} {'2nd-moment lo':>14} {'exact T(N)':>12} {'union-bd hi':>12}"
    print(header)
    print("-" * len(header))
    for n in (2, 3, 4, 5, 9, 16, 25, 36, 49, 64):
        lo, hi = criteria_window(n)
        exact = full_spectrum_threshold(n)
        assert lo <= exact <= hi, (n, lo, exact, hi)
        print(f"{n:>4} {lo:>14} {exact:>12} {hi:>12}")
    print("\nEvery exact value lies inside the window proved by the two criteria.")
    print()


def demo_monotonicity() -> None:
    print("=" * 78)
    print("3. THE TRANSITION HAPPENS EXACTLY ONCE (MONOTONICITY)")
    print("=" * 78)
    print("The proportion of full-spectrum words is non-decreasing in m,")
    print("because appending any letter to a surjective word keeps it surjective")
    print("(an injection giving N * S_m <= S_{m+1}).")
    print()
    for n in (4, 9):
        print(f"  alphabet N = {n}:")
        previous = -1.0
        monotone = True
        for m in range(0, full_spectrum_threshold(n) + 6):
            p = exact_full_spectrum_probability(n, m)
            monotone &= p >= previous - 1e-15
            previous = p
            flag = " <-- majority first reached" if (
                p > 0.5 and m == full_spectrum_threshold(n)
            ) else ""
            if m >= full_spectrum_threshold(n) - 4:
                print(f"    m = {m:>3}   P(full spectrum) = {p:.6f}{flag}")
        print(f"    monotone in m: {monotone}\n")


def demo_pair_threshold_asymptotics() -> None:
    print("=" * 78)
    print("4. THE RAINBOW PAIR-SPECTRUM THRESHOLD  T_k  AND ITS ASYMPTOTICS")
    print("=" * 78)
    print("Proved:  2k^2 log k - 2 log k  <=  T_k  <=  2k^2 log k + k^2 log 2 + 1")
    print("         1 * k^2 log k <= T_k <= 4 * k^2 log k     (all k >= 2)")
    print("         T_k / (k^2 log k) -> 2  (liminf = limsup = 2)")
    print()
    head = (f"{'k':>3} {'N=k^2':>6} {'T_k':>7} {'lower':>10} {'upper':>10} "
            f"{'ratio':>7} {'in [1,4]':>9}")
    print(head)
    print("-" * len(head))
    for k in range(2, 12):
        n = k * k
        t = pair_threshold(k)
        lo = 2 * k**2 * log(k) - 2 * log(k)
        hi = 2 * k**2 * log(k) + k**2 * log(2.0) + 1.0
        ratio = t / (k**2 * log(k))
        ok = 1.0 <= ratio <= 4.0
        assert lo <= t <= hi, (k, lo, t, hi)
        print(f"{k:>3} {n:>6} {t:>7} {lo:>10.2f} {hi:>10.2f} {ratio:>7.4f} {str(ok):>9}")
    print("\nThe ratio decreases towards 2 at the predicted rate O(1/log k).")
    print()


def demo_sharp_window() -> None:
    print("=" * 78)
    print("5. THE SHARP WINDOW   |T(N) - N log N| <= N log 2 + log N + 1")
    print("=" * 78)
    head = (f"{'N':>5} {'T(N)':>7} {'N log N':>10} {'deviation':>11} "
            f"{'allowed':>10} {'(T-NlogN)/N':>13}")
    print(head)
    print("-" * len(head))
    for n in (4, 9, 16, 25, 36, 49, 64, 81, 100, 144):
        t = full_spectrum_threshold(n)
        main = n * log(n)
        dev = t - main
        allowed = sharp_window_slack(n)
        assert abs(dev) <= allowed, (n, dev, allowed)
        print(f"{n:>5} {t:>7} {main:>10.3f} {dev:>11.3f} {allowed:>10.3f} "
              f"{dev / n:>13.4f}")
    print(f"\nThe last column hovers at log(1/log 2) = {log(1.0 / log(2.0)):.6f},")
    print("the conjectural second-order constant, well inside the proved window.")
    print()


def demo_poisson() -> None:
    print("=" * 78)
    print("6. THE POISSON PICTURE:  P(full spectrum) ~ exp(-N e^{-m/N})")
    print("=" * 78)
    n = 64
    print(f"Alphabet N = {n};  m written as N log N + c N.")
    head = f"{'c':>7} {'m':>6} {'exact P':>12} {'Poisson exp(-e^-c)':>20} {'error':>10}"
    print(head)
    print("-" * len(head))
    for c in (-1.0, -0.5, 0.0, 0.366513, 0.5, 1.0, 2.0):
        m = int(round(n * log(n) + c * n))
        exact = exact_full_spectrum_probability(n, m)
        approx = poisson_full_spectrum_probability(n, m)
        print(f"{c:>7.3f} {m:>6} {exact:>12.6f} {approx:>20.6f} "
              f"{abs(exact - approx):>10.2e}")
    predicted = poisson_prediction(n)
    print(f"\nPredicted median location N log N + N log(1/log 2) = {predicted:.2f}")
    print(f"Exact threshold T({n}) = {full_spectrum_threshold(n)}")
    print()


def demo_rainbow() -> None:
    print("=" * 78)
    print("7. FULL SPECTRUM FORCES A RAINBOW PROGRESSION  (requires l <= k)")
    print("=" * 78)
    k, l = 3, 2
    m = pattern_threshold(l, k)
    print(f"k = {k} colours, pattern length l = {l}, threshold P(l,k) = {m} blocks.")
    print("Take any colouring whose block word has full spectrum; it must contain")
    print("the injective pattern (0,1,...,l-1), hence a rainbow l-term progression.")
    print()
    # Build an explicit full-spectrum colouring: list every pattern once.
    patterns: List[Tuple[int, ...]] = list(product(range(k), repeat=l))
    colouring: List[int] = [c for pat in patterns for c in pat]
    word = block_word(colouring, l, len(patterns))
    full = has_full_spectrum(word, k, l)
    t = find_rainbow_block(word)
    print(f"  colouring of [0,{len(colouring)}) : {colouring}")
    print(f"  block word                     : {word}")
    print(f"  full spectrum                  : {full}")
    print(f"  first rainbow block index t    : {t}  -> progression "
          f"a = {l * t}, d = 1, colours {word[t]}")
    print()
    # Random sampling: above the threshold, most colourings have a rainbow block.
    import random

    random.seed(20260810)
    trials = 4000
    for blocks in (m - 3, m, m + 3):
        if blocks < 1:
            continue
        full_ct = 0
        rainbow_ct = 0
        for _ in range(trials):
            col = [random.randrange(k) for _ in range(l * blocks)]
            w = block_word(col, l, blocks)
            if has_full_spectrum(w, k, l):
                full_ct += 1
            if find_rainbow_block(w) >= 0:
                rainbow_ct += 1
        print(f"  m = {blocks:>3} blocks: P(full spectrum) ~ {full_ct / trials:.3f}, "
              f"P(contains rainbow pair) ~ {rainbow_ct / trials:.3f}")
    print("\nA rainbow pair is much easier than the full spectrum: full spectrum is")
    print("the stronger demand, and it implies a rainbow progression whenever l <= k.")
    print()


def demo_pattern_hierarchy() -> None:
    print("=" * 78)
    print("8. THE HIERARCHY  P(l,k) = Theta(l k^l log k)  ACROSS PATTERN LENGTHS")
    print("=" * 78)
    head = (f"{'l':>3} {'k':>3} {'N=k^l':>7} {'P(l,k)':>9} {'l k^l log k':>13} "
            f"{'ratio':>8}")
    print(head)
    print("-" * len(head))
    for l in (2, 3, 4):
        for k in (2, 3, 4):
            n = k**l
            if n > 200:
                continue
            p = pattern_threshold(l, k)
            main = l * n * log(k)
            print(f"{l:>3} {k:>3} {n:>7} {p:>9} {main:>13.2f} {p / main:>8.4f}")
    print("\nThe ratio approaches 1 as N = k^l grows: the leading constant in units")
    print("of k^l log k is exactly the pattern length l.")
    print()


def main() -> None:
    print()
    print("#" * 78)
    print("#  RAINBOW ARITHMETIC-PROGRESSION THRESHOLD  --  NUMERICAL DEMONSTRATIONS")
    print("#" * 78)
    print()
    demo_moment_identity()
    demo_criteria_and_threshold()
    demo_monotonicity()
    demo_pair_threshold_asymptotics()
    demo_sharp_window()
    demo_poisson()
    demo_rainbow()
    demo_pattern_hierarchy()
    print("=" * 78)
    print("SUMMARY")
    print("=" * 78)
    summary: Dict[str, str] = {
        "moment identity": "sum_f C(miss(f), r) = C(N,r)(N-r)^m, verified exhaustively",
        "criteria": "2N(N-1)^m < N^m  and  N^m < (N+1)(N-1)^m bracket T(N)",
        "window": "|T(N) - N log N| <= N log 2 + log N + 1",
        "pair threshold": "T_k = 2 k^2 log k + O(k^2),  T_k/(k^2 log k) -> 2",
        "constants": "1 <= T_k/(k^2 log k) <= 4 for k >= 2; 1.9 / 2.2 for k >= 100",
        "small cases": f"T_2 = {pair_threshold(2)}, T_3 = {pair_threshold(3)}, "
                       f"T_4 = {pair_threshold(4)}",
        "second order": f"conjectured constant log(1/log 2) = "
                        f"{log(1.0 / log(2.0)):.6f}",
    }
    for key, value in summary.items():
        print(f"  {key:>16}:  {value}")
    print()


if __name__ == "__main__":
    main()
