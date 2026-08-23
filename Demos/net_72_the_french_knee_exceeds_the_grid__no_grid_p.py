"""
Numerical demonstrations for "The Memory Knee of an Attention Profile:
Grids, Dilution, and Collision Mass".

Everything here is self-contained: no third-party dependencies, exact
rational arithmetic where it matters (via `fractions.Fraction`), and one
function per theorem being illustrated.

Objects
-------
An *attention profile* is a nonincreasing, nonnegative sequence
p(0) >= p(1) >= ... >= 0.  Its *retained mass* at budget k is
M_p(k) = sum_{i<k} p(i), and its *knee* at bar tau is the least k with
M_p(k) >= tau.

Results demonstrated
--------------------
1.  Grid lower bound:  a failed probe at g certifies knee > g.
2.  Grid underdetermination:  profiles agreeing at every grid point with
    knees anywhere above the ceiling.
3.  Dilution law:  r*(K-1) < K_dil <= r*K, with both ends attained.
4.  No additive domain-shift law:  the jump beats every fixed offset d.
5.  Variable dilution law:  C_w(K-1) < K_dil <= C_w(K).
6.  Collision-mass bound:  knee >= tau^2 / C, sharp on flat profiles,
    amplified by exactly r under dilution.
7.  Geometric vs arithmetic grids.
8.  Mixture law and accuracy/knee decoupling.
"""

from __future__ import annotations

from fractions import Fraction
from typing import Callable, List, Sequence, Tuple

Number = Fraction

# --------------------------------------------------------------------------
# Core definitions
# --------------------------------------------------------------------------


def retained_mass(p: Sequence[Number], k: int) -> Number:
    """M_p(k) = sum_{i<k} p(i); indices beyond the list carry zero mass."""
    return sum((p[i] for i in range(min(k, len(p)))), Fraction(0))


def knee(p: Sequence[Number], tau: Number, cap: int | None = None) -> int:
    """Least k with M_p(k) >= tau.  Returns -1 if the bar is unattainable."""
    limit = len(p) if cap is None else cap
    total = Fraction(0)
    if total >= tau:
        return 0
    for k in range(limit):
        total += p[k]
        if total >= tau:
            return k + 1
    return -1


def collision_mass(p: Sequence[Number], k: int | None = None) -> Number:
    """C_p(k) = sum_{i<k} p(i)^2 (whole profile when k is None)."""
    n = len(p) if k is None else min(k, len(p))
    return sum((p[i] ** 2 for i in range(n)), Fraction(0))


# --------------------------------------------------------------------------
# Calibration profiles
# --------------------------------------------------------------------------


def flat(n: int, c: Number = Fraction(1)) -> List[Number]:
    """Scaled flat profile: mass c on each of the first n keys."""
    return [c] * n


def two_level(g: int, N: int, c: Number) -> List[Number]:
    """Height 1 on the first g keys, height c on keys g..N-1, then zero."""
    return [Fraction(1)] * g + [c] * (N - g)


def dilate(p: Sequence[Number], r: int) -> List[Number]:
    """Uniform r-fold token dilution: each unit becomes r tokens of mass p(i)/r."""
    out: List[Number] = []
    for value in p:
        out.extend([Fraction(value, 1) / r] * r)
    return out


def variable_dilate(p: Sequence[Number], w: Sequence[int]) -> List[Number]:
    """Variable dilution: word i becomes w[i] tokens each of mass p(i)/w(i)."""
    out: List[Number] = []
    for value, count in zip(p, w):
        out.extend([Fraction(value, 1) / count] * count)
    return out


def cumulative(w: Sequence[int], m: int) -> int:
    """C_w(m) = sum_{i<m} w(i): tokens spent on the top m words."""
    return sum(w[:m])


# --------------------------------------------------------------------------
# 1. A failed grid sweep certifies only a lower bound
# --------------------------------------------------------------------------


def demo_grid_lower_bound() -> None:
    print("=" * 74)
    print("1. GRID LOWER BOUND  --  a failed sweep is one-sided")
    print("=" * 74)

    # A stand-in for the measured French cell at context 1024: retention
    # 0.9680 at budget 32, bar 0.97, knee somewhere above the grid.
    bar = Fraction(97, 100)
    grid = [8, 16, 24, 32]

    # Profile: 0.9680 spread over 32 keys, remaining 0.032 over 168 more.
    head = [Fraction(968, 100 * 32 * 10)] * 32          # 0.9680 total
    tail = [Fraction(32, 1000 * 168)] * 168             # 0.0320 total
    p = head + tail

    for g in grid:
        m = retained_mass(p, g)
        print(f"   budget {g:>3}: retained {float(m):.4f}   "
              f"{'below bar' if m < bar else 'MEETS BAR'}")
    K = knee(p, bar)
    print(f"\n   every grid point fails  =>  knee > 32 (certified)")
    print(f"   actual knee of this profile: {K}")
    print(f"   the grid could not have distinguished it from any other value > 32.\n")


def demo_grid_underdetermination() -> None:
    print("=" * 74)
    print("2. GRID UNDERDETERMINATION  --  the excess is invisible")
    print("=" * 74)

    g = 8
    bar = Fraction(g + 1)
    print(f"   grid ceiling g = {g}, bar tau = g + 1 = {bar}\n")
    print(f"   {'target N':>9} {'M(2)':>7} {'M(4)':>7} {'M(6)':>7} {'M(8)':>7} {'knee':>6}")
    for N in (9, 12, 20, 33, 64, 200):
        p = two_level(g, N, Fraction(1, N - g))
        masses = [retained_mass(p, k) for k in (2, 4, 6, 8)]
        K = knee(p, bar)
        assert K == N, (K, N)
        print(f"   {N:>9} " + " ".join(f"{float(m):>7.3f}" for m in masses) + f" {K:>6}")
    print("\n   identical readings at every grid point; knees from 9 to 200.\n")


# --------------------------------------------------------------------------
# 3-4. The dilution law and the death of additive brackets
# --------------------------------------------------------------------------


def demo_dilution_law() -> None:
    print("=" * 74)
    print("3. DILUTION LAW  --  r*(K-1) < K_dil <= r*K, both ends attained")
    print("=" * 74)
    print(f"   {'r':>3} {'K':>4} {'r(K-1)':>8} {'K_dil':>7} {'rK':>5}   verdict")
    for (n, tau_num, r) in [(4, 4, 1), (4, 4, 2), (4, 4, 3), (8, 5, 4),
                            (8, 5, 7), (10, 3, 12)]:
        p = flat(n)
        tau = Fraction(tau_num)
        K = knee(p, tau)
        q = dilate(p, r)
        Kd = knee(q, tau)
        lo, hi = r * (K - 1), r * K
        ok = lo < Kd <= hi
        tag = "upper attained" if Kd == hi else ("lower+1" if Kd == lo + 1 else "interior")
        assert ok
        print(f"   {r:>3} {K:>4} {lo:>8} {Kd:>7} {hi:>5}   {tag}")

    # Lower end attained: bar just above K-1 on a flat profile.
    p = flat(8)
    tau = Fraction(3) + Fraction(1, 1000)     # K = 4
    K = knee(p, tau)
    r = 5
    Kd = knee(dilate(p, r), tau)
    print(f"\n   bar just above K-1:  K = {K}, r = {r}, "
          f"K_dil = {Kd} = r*(K-1)+1 = {r * (K - 1) + 1}\n")


def demo_no_additive_law() -> None:
    print("=" * 74)
    print("4. NO ADDITIVE DOMAIN-SHIFT LAW  --  every offset d is beaten")
    print("=" * 74)
    print(f"   {'claimed d':>10} {'K':>4} {'K_dil':>7} {'jump':>6}   K + d < K_dil ?")
    for d in (0, 1, 2, 4, 8, 16):
        n = d + 2
        p = flat(n)
        tau = Fraction(n)
        r = n
        K = knee(p, tau)
        Kd = knee(dilate(p, r), tau)
        jump = Kd - K
        assert K + d < Kd
        print(f"   {d:>10} {K:>4} {Kd:>7} {jump:>6}   yes")
    print("\n   a multiplicative tax admits no uniform additive bracket.\n")


# --------------------------------------------------------------------------
# 5. Variable tokenization: the top-K cumulative count
# --------------------------------------------------------------------------


def demo_variable_dilution() -> None:
    print("=" * 74)
    print("5. VARIABLE DILUTION  --  the knee is a top-K token count")
    print("=" * 74)

    # A plausible sorted attention profile over 12 "words".
    raw = [30, 18, 12, 9, 7, 6, 5, 4, 3, 3, 2, 1]      # sums to 100
    p = [Fraction(v, 100) for v in raw]
    bar = Fraction(90, 100)
    K = knee(p, bar)
    print(f"   undiluted knee at bar 0.90:  K = {K}")

    # English-like and French-like tokens-per-word profiles.
    scenarios = {
        "English-like (mostly 1 token/word)": [1, 1, 1, 1, 2, 1, 1, 1, 2, 1, 1, 1],
        "French-like (accents, elisions)   ": [3, 2, 3, 2, 3, 2, 3, 2, 2, 3, 2, 2],
        "heavy tokenizer                   ": [4, 4, 3, 5, 4, 4, 3, 4, 5, 4, 4, 4],
    }
    print(f"\n   {'scenario':<36} {'C_w(K-1)':>9} {'K_dil':>7} {'C_w(K)':>8} "
          f"{'top-K avg':>10} {'corpus avg':>11}")
    for name, w in scenarios.items():
        q = variable_dilate(p, w)
        Kd = knee(q, bar)
        lo, hi = cumulative(w, K - 1), cumulative(w, K)
        assert lo < Kd <= hi, (lo, Kd, hi)
        top_avg = hi / K
        corpus_avg = sum(w) / len(w)
        print(f"   {name:<36} {lo:>9} {Kd:>7} {hi:>8} {top_avg:>10.3f} {corpus_avg:>11.3f}")
    print("\n   the knee tracks the TOP-K average, which can differ from the")
    print("   corpus average whenever attention sits on atypically costly words.\n")


# --------------------------------------------------------------------------
# 6. Collision mass
# --------------------------------------------------------------------------


def demo_collision_bound() -> None:
    print("=" * 74)
    print("6. COLLISION MASS  --  a tokenizer-free floor, sharp on flat profiles")
    print("=" * 74)

    print("   (a) sharpness on the flat probability profile, bar tau = 1")
    print(f"   {'n':>5} {'C':>12} {'tau^2/C':>10} {'knee':>6}")
    for n in (2, 4, 8, 16, 32, 64):
        p = flat(n, Fraction(1, n))
        C = collision_mass(p)
        K = knee(p, Fraction(1))
        assert C == Fraction(1, n) and K == n and Fraction(1) / C == n
        print(f"   {n:>5} {str(C):>12} {float(Fraction(1) / C):>10.2f} {K:>6}")

    print("\n   (b) the floor on genuinely peaked profiles (bar = 0.90)")
    bar = Fraction(90, 100)
    profiles = {
        "peaked  (geometric 1/2)": [Fraction(1, 2 ** (i + 1)) for i in range(20)],
        "moderate (1/(i+1), normed)": None,
        "flat over 40 keys      ": flat(40, Fraction(1, 40)),
    }
    harmonic = [Fraction(1, i + 1) for i in range(40)]
    total = sum(harmonic, Fraction(0))
    profiles["moderate (1/(i+1), normed)"] = [h / total for h in harmonic]
    print(f"   {'profile':<28} {'C':>10} {'floor tau^2/C':>14} {'true knee':>10}")
    for name, p in profiles.items():
        C = collision_mass(p)
        floor = bar ** 2 / C
        K = knee(p, bar)
        assert floor <= K, (floor, K)
        print(f"   {name:<28} {float(C):>10.5f} {float(floor):>14.2f} {K:>10}")

    print("\n   (c) dilution divides collision mass by r, so the floor multiplies by r")
    base = [Fraction(1, 8)] * 8
    C0 = collision_mass(base)
    print(f"   {'r':>3} {'C(diluted)':>12} {'C0/r':>10} {'floor':>8} {'true knee':>10}")
    for r in (1, 2, 3, 5, 8):
        q = dilate(base, r)
        Cq = collision_mass(q)
        assert Cq == C0 / r
        floor = Fraction(1) ** 2 / Cq
        K = knee(q, Fraction(1))
        print(f"   {r:>3} {float(Cq):>12.5f} {float(C0 / r):>10.5f} "
              f"{float(floor):>8.2f} {K:>10}")
    print()


# --------------------------------------------------------------------------
# 7. Grid geometry
# --------------------------------------------------------------------------


def geometric_bracket(oracle: Callable[[int], Number], tau: Number,
                      cap: int) -> Tuple[int, int, int]:
    """Return (lo, hi, probes) with lo <= knee <= hi and hi < 2*knee (S > 0)."""
    S, probes = 0, 0
    while 2 ** S <= cap:
        probes += 1
        if oracle(2 ** S) >= tau:
            lo = 2 ** (S - 1) + 1 if S > 0 else 1
            return lo, 2 ** S, probes
        S += 1
    return cap + 1, -1, probes            # unbounded above


def demo_grids() -> None:
    print("=" * 74)
    print("7. GEOMETRIC VS ARITHMETIC GRIDS")
    print("=" * 74)

    bar = Fraction(90, 100)
    for n in (5, 13, 31, 47, 100):
        p = flat(n, Fraction(1, n))
        K = knee(p, bar)
        lo, hi, probes = geometric_bracket(lambda k: retained_mass(p, k), bar, 4096)
        arith = [8, 16, 24, 32]
        arith_verdict = next((g for g in arith if retained_mass(p, g) >= bar), None)
        assert lo <= K <= hi and (hi < 2 * K or hi == 1)
        a_txt = f"knee <= {arith_verdict}" if arith_verdict else "knee > 32 (no upper bound)"
        print(f"   true knee {K:>4}:  geometric -> [{lo:>4}, {hi:>4}] "
              f"in {probes} probes   |   arithmetic -> {a_txt}")
    print("\n   the geometric bracket always has ratio < 2; the arithmetic grid")
    print("   returns an unbounded verdict as soon as the knee escapes it.\n")


# --------------------------------------------------------------------------
# 8. Mixtures and accuracy decoupling
# --------------------------------------------------------------------------


def demo_mixture_and_decoupling() -> None:
    print("=" * 74)
    print("8. MIXTURE LAW AND ACCURACY/KNEE DECOUPLING")
    print("=" * 74)

    bar = Fraction(90, 100)
    p = flat(10, Fraction(1, 10))          # knee 9
    q = flat(40, Fraction(1, 40))          # knee 36
    Kp, Kq = knee(p, bar), knee(q, bar)
    print(f"   component knees: {Kp} and {Kq}")
    print(f"   {'mixing s':>9} {'K_mix':>7}   min <= K_mix <= max ?")
    for s_num in (0, 1, 3, 5, 7, 9, 10):
        s = Fraction(s_num, 10)
        length = max(len(p), len(q))
        pp = list(p) + [Fraction(0)] * (length - len(p))
        qq = list(q) + [Fraction(0)] * (length - len(q))
        mix = [s * a + (1 - s) * b for a, b in zip(pp, qq)]
        Km = knee(mix, bar)
        assert min(Kp, Kq) <= Km <= max(Kp, Kq)
        print(f"   {float(s):>9.1f} {Km:>7}   yes")
    print("\n   provisioning rule: budget by the MAXIMUM, never by an average.\n")

    # Four cells, two accuracy values, both orderings realized.
    A, B = flat(4, Fraction(1)), flat(4, Fraction(1, 2))
    KA, KB = knee(A, Fraction(1)), knee(B, Fraction(1))
    cells = [("D1", Fraction(0), KA), ("D2", Fraction(1), KB),
             ("D3", Fraction(0), KB), ("D4", Fraction(1), KA)]
    print("   accuracy/knee decoupling:")
    for name, acc, K in cells:
        print(f"      {name}: accuracy {float(acc):.1f}, knee {K}")
    assert cells[0][2] < cells[1][2]        # higher accuracy, LARGER knee
    assert cells[3][2] < cells[2][2]        # higher accuracy, SMALLER knee
    print("      D1 -> D2: accuracy up, knee UP    (French: easier and dearer)")
    print("      D3 -> D4: accuracy up, knee DOWN  (code: easier and cheaper)")
    print("      => no function maps full-context accuracy to the knee.\n")


# --------------------------------------------------------------------------


def main() -> None:
    demo_grid_lower_bound()
    demo_grid_underdetermination()
    demo_dilution_law()
    demo_no_additive_law()
    demo_variable_dilution()
    demo_collision_bound()
    demo_grids()
    demo_mixture_and_decoupling()
    print("=" * 74)
    print("All assertions passed: every theorem checks out numerically.")
    print("=" * 74)


if __name__ == "__main__":
    main()


"""
Collision-Mass (Renyi-2) Floor for the Attention Knee.

Computes a tokenizer-free, domain-free lower bound on the memory knee from the
attention weights alone, using the inequality  M(k)^2 <= k * sum_{i<k} p(i)^2.
"""

from __future__ import annotations

import math
from typing import List, NamedTuple, Sequence


class Floor(NamedTuple):
    collision_mass: float       # C = sum_i p(i)^2
    effective_support: float    # 1 / C, the Renyi-2 effective number of keys
    floor: float                # tau^2 / C
    integer_floor: int          # ceil(tau^2 / C), a valid budget lower bound


def collision_mass(weights: Sequence[float]) -> float:
    """C = sum_i p(i)^2, the Renyi-2 (collision) mass of the profile."""
    return sum(w * w for w in weights)


def collision_floor(weights: Sequence[float], tau: float) -> Floor:
    """
    Lower-bound the knee from flatness alone.

    Cauchy-Schwarz on the first k coordinates gives M(k)^2 <= k * C, and at the
    knee M(K) >= tau, hence K >= tau^2 / C.  The bound is attained exactly by
    the flat probability profile on n keys (C = 1/n, tau = 1, knee = n), so no
    function of the collision mass can do better.

    Complexity: a single O(n) pass; no tokenizer and no domain label required.
    """
    if tau <= 0:
        raise ValueError("the retention bar must be positive")
    C = collision_mass(weights)
    if C <= 0:
        raise ValueError("degenerate profile: zero collision mass")
    value = tau * tau / C
    return Floor(C, 1.0 / C, value, math.ceil(value - 1e-12))


def dilate(weights: Sequence[float], r: int) -> List[float]:
    """Mass-preserving r-fold dilution: each unit becomes r tokens of mass p/r."""
    out: List[float] = []
    for w in weights:
        out.extend([w / r] * r)
    return out


def amplified_floor(weights: Sequence[float], tau: float, r: int) -> Floor:
    """
    The floor for the r-fold diluted profile, without materialising it.

    Dilution replaces each p(i)^2 by r copies of (p(i)/r)^2, so the collision
    mass is divided by exactly r and the floor is multiplied by exactly r --
    the same factor the combinatorial dilution law produces, obtained here from
    flatness alone.  Complexity: O(n), independent of r.
    """
    base = collision_floor(weights, tau)
    C = base.collision_mass / r
    value = tau * tau / C
    return Floor(C, 1.0 / C, value, math.ceil(value - 1e-12))


if __name__ == "__main__":
    def knee(p: Sequence[float], tau: float) -> int:
        total = 0.0
        for k, v in enumerate(p, start=1):
            total += v
            if total >= tau - 1e-12:
                return k
        return -1

    print("sharpness on flat probability profiles (bar tau = 1):")
    for n in (4, 8, 16, 32, 64):
        p = [1.0 / n] * n
        f = collision_floor(p, 1.0)
        assert f.integer_floor == n == knee(p, 1.0)
        print(f"  n={n:>3}  C={f.collision_mass:.5f}  floor={f.floor:6.2f}  "
              f"knee={knee(p, 1.0):>3}   (equality)")

    print("\nfloor on realistic profiles (bar tau = 0.90):")
    zipf = [1.0 / (i + 1) for i in range(40)]
    zipf = [z / sum(zipf) for z in zipf]
    geom = [0.75 ** i for i in range(40)]
    geom = [g / sum(geom) for g in geom]
    for name, p in (("Zipf-like", zipf), ("peaked geometric", geom),
                    ("flat over 40", [1 / 40] * 40)):
        f = collision_floor(p, 0.90)
        K = knee(p, 0.90)
        assert f.integer_floor <= K
        print(f"  {name:<18} C={f.collision_mass:.5f}  "
              f"effective support={f.effective_support:6.2f}  "
              f"floor={f.integer_floor:>3}  true knee={K:>3}")

    print("\namplification under dilution (flat profile, tau = 1):")
    base = [1 / 8] * 8
    for r in (1, 2, 3, 5, 8):
        f = amplified_floor(base, 1.0, r)
        true = knee(dilate(base, r), 1.0)
        assert f.integer_floor == true
        print(f"  r={r}: floor={f.integer_floor:>3}  true diluted knee={true:>3}")


"""
Geometric Budget Bracketing of the Attention Knee.

Locates the knee K = min{k : M(k) >= tau} of a monotone retention oracle to
within a factor of two using O(log K) oracle calls, and optionally refines to
the exact value with a further O(log K) calls by binary search.
"""

from __future__ import annotations

from typing import Callable, NamedTuple, Optional


class Bracket(NamedTuple):
    """A certified two-sided bracket lo <= knee <= hi, or hi = None if the
    knee exceeds the cap (in which case only `lo` is certified)."""
    lo: int
    hi: Optional[int]
    probes: int
    exact: Optional[int] = None


def geometric_bracket(
    retention: Callable[[int], float],
    tau: float,
    cap: int = 1 << 20,
    refine: bool = False,
) -> Bracket:
    """
    Bracket the knee of a nondecreasing retention function.

    Parameters
    ----------
    retention : k -> M(k), nondecreasing in k (the retained attention mass).
    tau       : the retention bar.
    cap       : largest budget the caller is willing to probe.
    refine    : if True, binary-search inside the bracket for the exact knee.

    Guarantees
    ----------
    * If the returned `hi` is not None then lo <= knee <= hi and hi < 2 * knee
      whenever hi > 1 -- a ratio-two bracket.
    * If `hi` is None then knee > cap is certified and nothing more; no
      arithmetic or geometric grid can certify an upper bound in that case.

    Complexity
    ----------
    ceil(log2 K) + 1 oracle calls for the bracket; a further
    ceil(log2(hi - lo)) calls when `refine` is set.
    """
    exponent, probes = 0, 0
    while (1 << exponent) <= cap:
        budget = 1 << exponent
        probes += 1
        if retention(budget) >= tau:
            lo = (1 << (exponent - 1)) + 1 if exponent > 0 else 1
            hi = budget
            if not refine:
                return Bracket(lo, hi, probes)
            # Binary search on the monotone predicate M(k) >= tau.
            left, right = lo, hi
            while left < right:
                mid = (left + right) // 2
                probes += 1
                if retention(mid) >= tau:
                    right = mid
                else:
                    left = mid + 1
            return Bracket(lo, hi, probes, exact=left)
        exponent += 1
    return Bracket(cap + 1, None, probes)


def arithmetic_verdict(
    retention: Callable[[int], float], tau: float, grid: list[int]
) -> str:
    """The verdict an arithmetic sweep can honestly report."""
    for g in sorted(grid):
        if retention(g) >= tau:
            below = [h for h in sorted(grid) if h < g]
            lo = (below[-1] + 1) if below else 1
            return f"knee in [{lo}, {g}]"
    return f"knee > {max(grid)} (no upper bound certified)"


if __name__ == "__main__":
    # A flat probability profile on n keys: retention is min(k, n) / n,
    # so the knee at bar tau is ceil(tau * n).
    import math

    for n in (5, 13, 31, 47, 100, 257):
        def M(k: int, n: int = n) -> float:
            return min(k, n) / n

        tau = 0.90
        true_knee = math.ceil(tau * n)
        br = geometric_bracket(M, tau, cap=4096, refine=True)
        arith = arithmetic_verdict(M, tau, [8, 16, 24, 32])
        assert br.lo <= true_knee <= (br.hi or true_knee)
        assert br.exact == true_knee
        print(f"n={n:>4}  true knee {true_knee:>4}  "
              f"geometric [{br.lo:>4},{br.hi:>4}] exact {br.exact:>4} "
              f"in {br.probes} probes  |  arithmetic: {arith}")


"""
Top-K Cumulative Tokenization Predictor for the Diluted Knee.

Given a word-level attention profile and the tokenizer's per-word token counts,
predicts the token-level knee exactly to within one word, and contrasts that
prediction with the naive corpus-average tokens-per-word estimate.
"""

from __future__ import annotations

from typing import List, NamedTuple, Sequence


class Prediction(NamedTuple):
    word_knee: int              # K, the knee measured in words
    lower: int                  # C_w(K-1) + 1
    upper: int                  # C_w(K)
    topk_average: float         # C_w(K) / K -- the correct predictor
    corpus_average: float       # mean token cost over the whole vocabulary
    corpus_prediction: int      # round(corpus_average * K) -- the naive one


def word_knee(profile: Sequence[float], tau: float) -> int:
    """Least m with sum_{i<m} profile[i] >= tau; -1 if the bar is unattainable."""
    total = 0.0
    for m, value in enumerate(profile, start=1):
        total += value
        if total >= tau - 1e-12:
            return m
    return -1


def cumulative_tokens(counts: Sequence[int], m: int) -> int:
    """C_w(m) = sum_{i<m} counts[i]: tokens spent on the top m words."""
    return sum(counts[:m])


def predict_diluted_knee(
    profile: Sequence[float], counts: Sequence[int], tau: float
) -> Prediction:
    """
    Predict the knee of the tokenized profile.

    The token-level knee obeys  C_w(K-1) < K_diluted <= C_w(K),  where K is the
    word-level knee.  The bracket has width w(K-1) -- the cost of a single word --
    so the prediction is exact up to one word.

    Complexity: O(K) after one tokenizer pass over the top attended words.
    """
    K = word_knee(profile, tau)
    if K < 0:
        raise ValueError("retention bar is unattainable for this profile")
    lower = cumulative_tokens(counts, K - 1) + 1
    upper = cumulative_tokens(counts, K)
    corpus_average = sum(counts) / len(counts)
    return Prediction(
        word_knee=K,
        lower=lower,
        upper=upper,
        topk_average=upper / K,
        corpus_average=corpus_average,
        corpus_prediction=round(corpus_average * K),
    )


def tokenize_profile(profile: Sequence[float], counts: Sequence[int]) -> List[float]:
    """Mass-preserving variable dilution: word i becomes counts[i] equal tokens."""
    out: List[float] = []
    for value, c in zip(profile, counts):
        out.extend([value / c] * c)
    return out


if __name__ == "__main__":
    attention = [0.24, 0.16, 0.12, 0.09, 0.075, 0.065, 0.055, 0.045,
                 0.04, 0.035, 0.03, 0.025, 0.02, 0.015, 0.01, 0.005]
    bar = 0.90
    scenarios = {
        "English-like": [1, 1, 1, 1, 2, 1, 1, 1, 2, 1, 1, 2, 1, 1, 2, 1],
        "French-like": [3, 2, 3, 2, 3, 2, 3, 2, 2, 3, 2, 2, 3, 2, 2, 2],
        "rare-word-heavy": [5, 5, 4, 5, 4, 4, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    }
    for name, counts in scenarios.items():
        pred = predict_diluted_knee(attention, counts, bar)
        actual = word_knee(tokenize_profile(attention, counts), bar)
        assert pred.lower <= actual <= pred.upper
        print(f"{name:<16} K={pred.word_knee:>2}  true diluted knee={actual:>3}  "
              f"bracket=[{pred.lower},{pred.upper}]  "
              f"top-K avg={pred.topk_average:.3f}  "
              f"corpus avg={pred.corpus_average:.3f} -> predicts "
              f"{pred.corpus_prediction:>3} "
              f"({'ok' if abs(pred.corpus_prediction - actual) <= 1 else 'MISSES'})")


"""Assemble PACKAGE.json from the deliverable files and the package assets."""

from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
ASSETS = ROOT / "package_assets"


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


LEAN_FILES = [
    "Catalog/Novelty/KneeDilutionGrid.lean",
    "Catalog/Novelty/KneeVariableDilution.lean",
    "Catalog/Novelty/KneeCollisionBound.lean",
]

lean_proofs = "\n\n".join(
    f"-- ===== FILE: {rel} =====\n\n{read(ROOT / rel)}" for rel in LEAN_FILES
)

package = {
    "title": "The Memory Knee of an Attention Profile: Grids, Dilution, and Collision Mass",
    "domain": "Novelty",
    "description": (
        "The smallest key budget retaining a prescribed share of attention mass — the knee — "
        "is shown to be a multiplicative quantity: it scales with the tokens a tokenizer spends "
        "on the top attended words, is bounded below by the sharp tokenizer-free floor tau^2/C "
        "given by the collision mass, and therefore admits no additive domain-shift law, so "
        "arithmetic budget sweeps must be replaced by geometric ones."
    ),
    "authors": ["Aristotle"],
    "date": "2026-08-23",
    "key_results": [
        "Grid Lower Bound Theorem: a budget probe that misses the retention bar certifies only "
        "that the knee is strictly larger than that probe, and a whole failed grid certifies only "
        "that the knee exceeds its largest point.",
        "Grid Underdetermination Theorem: for every target beyond a grid ceiling there is an "
        "attention profile with identical retention at every grid point and knee exactly that "
        "target, so the size of the excess is invisible to any arithmetic sweep.",
        "Dilution Law: mass-preserving r-fold token dilution multiplies the knee, r(K-1) < K_diluted "
        "<= rK, with both endpoints attained; consequently no additive domain-shift offset of any "
        "fixed size can bound the jump.",
        "Variable Dilution Law: with per-word token counts w, the diluted knee is bracketed by the "
        "cumulative token counts of the top attended words, C_w(K-1) < K_diluted <= C_w(K), making "
        "the top-K tokens-per-word average — not the corpus average — the exact predictor.",
        "Collision-Mass Bound: Cauchy-Schwarz gives the tokenizer-free lower bound knee >= tau^2/C "
        "whenever the Renyi-2 collision mass never exceeds C; the bound is attained by flat profiles "
        "and dilution divides the collision mass by exactly r, recovering the same multiplicative "
        "factor from flatness alone.",
        "Geometric Grid Theorem: a geometric budget sweep always brackets the knee within a factor "
        "two using logarithmically many probes, whereas an arithmetic grid supplies no upper bound "
        "once escaped; and mixed traffic must be provisioned by the maximum of component knees.",
    ],
    "keywords": [
        "attention profile",
        "memory knee",
        "prefix mass",
        "token dilution",
        "tokens-per-word",
        "collision mass",
        "Renyi-2 entropy",
        "geometric budget grid",
    ],
    "article": read(ROOT / "ARTICLE.md"),
    "research_paper": read(ROOT / "RESEARCH_PAPER.md"),
    "research_paper_tex": read(ROOT / "RESEARCH_PAPER.tex"),
    "demo": read(ROOT / "demo.py"),
    "demos": [
        {
            "name": "End-to-End Numerical Verification of the Knee Laws",
            "description": (
                "A self-contained, dependency-free suite that instantiates every theorem of the "
                "development on explicit attention profiles using exact rational arithmetic. It "
                "reproduces a failed arithmetic sweep against a bar of 0.97 and shows the true knee "
                "sitting at 43; exhibits six two-level profiles with byte-identical readings at every "
                "grid point and knees ranging from 9 to 200; checks the dilution sandwich "
                "r(K-1) < K_diluted <= rK at both endpoints; defeats each claimed additive offset "
                "d in {0,1,2,4,8,16}; verifies the cumulative top-K token bracket on English-like, "
                "French-like and heavy-tokenizer scenarios; confirms that the collision-mass floor "
                "tau^2/C is attained exactly on flat profiles and multiplies by exactly r under "
                "dilution; contrasts geometric with arithmetic bracketing; and validates both the "
                "mixture sandwich and the two-signed accuracy/knee decoupling. Every claim is "
                "guarded by an assertion, so a clean run is itself the verification."
            ),
            "code": read(ROOT / "demo.py"),
        }
    ],
    "algorithms": [
        {
            "name": "Geometric Budget Bracketing of the Attention Knee",
            "description": (
                "Locates the knee K = min{k : M(k) >= tau} of a monotone retention oracle by probing "
                "the geometric ladder 1, 2, 4, 8, ... and stopping at the least exponent S whose budget "
                "clears the bar. The returned bracket [2^(S-1)+1, 2^S] is certified two-sided: the upper "
                "end is a witness, and the lower end follows because the previous probe failed, which by "
                "the Grid Lower Bound Theorem forces the knee above it. The bracket therefore has ratio "
                "strictly below two, and a multiplicative domain tax of factor r only shifts S by log2(r) "
                "rather than escaping the instrument — the precise sense in which a geometric grid is the "
                "right measuring device for a multiplicative quantity. An optional binary-search refinement "
                "exploits monotonicity of the retention oracle to return the exact knee. Complexity: "
                "ceil(log2 K) + 1 oracle calls for the bracket and a further ceil(log2 of the bracket width) "
                "for the exact value, against the unbounded verdict an arithmetic grid returns once escaped."
            ),
            "pseudocode": (
                "ALGORITHM GeometricBracket(retention M, bar tau, cap C, refine)\n"
                "  S <- 0\n"
                "  while 2^S <= C do\n"
                "      if M(2^S) >= tau then\n"
                "          lo <- 2^(S-1) + 1 if S > 0 else 1\n"
                "          hi <- 2^S\n"
                "          if not refine then return (lo, hi)\n"
                "          # binary search on the monotone predicate M(k) >= tau\n"
                "          left <- lo ; right <- hi\n"
                "          while left < right do\n"
                "              mid <- floor((left + right) / 2)\n"
                "              if M(mid) >= tau then right <- mid else left <- mid + 1\n"
                "          return (lo, hi, exact = left)\n"
                "      S <- S + 1\n"
                "  return (C + 1, UNBOUNDED)      # only a lower bound is certified\n"
                "\n"
                "CORRECTNESS\n"
                "  hi is a witness, so knee <= hi.\n"
                "  M(2^(S-1)) < tau by minimality of S, so knee > 2^(S-1) = hi/2, giving hi < 2*knee."
            ),
            "code": read(ASSETS / "alg_geometric_bracket.py"),
        },
        {
            "name": "Top-K Cumulative Tokenization Predictor for the Diluted Knee",
            "description": (
                "Turns the tokenization hypothesis into a quantitative prediction. Given a word-level "
                "attention profile and the tokenizer's per-word token counts w, the algorithm computes the "
                "word-level knee K and returns the bracket (C_w(K-1), C_w(K)] for the token-level knee, "
                "where C_w(m) is the cumulative token count of the top m words. Correctness rests on mass "
                "preservation: because the tokens of a word carry equal shares that sum back to the word's "
                "attention mass, the diluted retention at budget C_w(m) equals the undiluted retention at "
                "budget m; the upper end is then a witness and the lower end a failed probe. The bracket has "
                "width w(K-1), the cost of a single word, so the prediction is exact up to one word. The "
                "routine also reports the naive corpus-average estimate for contrast: the two agree only "
                "when token cost is uncorrelated with attention, and diverge sharply — as on rare-word-heavy "
                "or heavily accented text — exactly where the empirical anomaly lives. Complexity: O(K) after "
                "one tokenizer pass over the top attended words."
            ),
            "pseudocode": (
                "ALGORITHM PredictDilutedKnee(profile p, token counts w, bar tau)\n"
                "  # 1. word-level knee\n"
                "  total <- 0 ; K <- -1\n"
                "  for m = 1 .. len(p) do\n"
                "      total <- total + p[m-1]\n"
                "      if total >= tau then K <- m ; break\n"
                "  if K < 0 then error 'bar unattainable'\n"
                "\n"
                "  # 2. cumulative token counts over the top words\n"
                "  lower <- w[0] + ... + w[K-2]        # C_w(K-1)\n"
                "  upper <- w[0] + ... + w[K-1]        # C_w(K)\n"
                "\n"
                "  # 3. competing predictors\n"
                "  topK_average   <- upper / K\n"
                "  corpus_average <- mean(w)\n"
                "  return (bracket = (lower + 1, upper),\n"
                "          topK_average, corpus_average,\n"
                "          corpus_prediction = round(corpus_average * K))\n"
                "\n"
                "GUARANTEE\n"
                "  C_w(K-1) < true diluted knee <= C_w(K)."
            ),
            "code": read(ASSETS / "alg_topk_tokens.py"),
        },
        {
            "name": "Collision-Mass (Renyi-2) Floor for the Attention Knee",
            "description": (
                "Computes a lower bound on the knee from the attention weights alone — no tokenizer, no "
                "domain label, no notion of 'word'. Applying Cauchy-Schwarz to the all-ones vector and the "
                "profile on the first k coordinates gives M(k)^2 <= k * sum_{i<k} p(i)^2, so if the collision "
                "mass never exceeds C then meeting a bar tau requires at least tau^2 / C keys: flat, "
                "high-entropy attention cannot be summarized by few keys. The bound is optimal as a function "
                "of the collision mass, since the flat probability profile on n keys attains it with equality "
                "(C = 1/n, tau = 1, knee = n). The companion routine amplifies the floor under dilution "
                "without materialising the diluted profile: each squared weight p^2 becomes r copies of "
                "(p/r)^2, so the collision mass is divided by exactly r and the floor multiplied by exactly r "
                "— reproducing the multiplicative factor of the dilution law from flatness alone, by a "
                "completely disjoint argument. Complexity: one O(n) reduction over the attention weights, "
                "independent of r, and computable from attention maps that logging pipelines already emit."
            ),
            "pseudocode": (
                "ALGORITHM CollisionFloor(weights p, bar tau)\n"
                "  require tau > 0\n"
                "  C <- sum_i p[i]^2                       # Renyi-2 collision mass\n"
                "  require C > 0\n"
                "  effective_support <- 1 / C\n"
                "  floor <- tau^2 / C\n"
                "  return (C, effective_support, floor, ceil(floor))\n"
                "\n"
                "ALGORITHM AmplifiedFloor(weights p, bar tau, dilution r)\n"
                "  C <- sum_i p[i]^2\n"
                "  C_diluted <- C / r                      # exact, by block splitting\n"
                "  return ceil(tau^2 / C_diluted)          # = r * ceil-free floor tau^2 / C\n"
                "\n"
                "CORRECTNESS\n"
                "  Cauchy-Schwarz: M(k)^2 <= k * sum_{i<k} p[i]^2 <= k * C.\n"
                "  At the knee K, tau <= M(K), hence tau^2 <= K * C, i.e. K >= tau^2 / C.\n"
                "  Equality for the flat profile p = (1/n, ..., 1/n) with tau = 1."
            ),
            "code": read(ASSETS / "alg_collision_floor.py"),
        },
    ],
    "visualizations": [
        {
            "name": "What a Budget Sweep Certifies: Underdetermination and Grid Geometry",
            "description": (
                "Two panels. The left panel overlays the retention curves of a family of two-level "
                "attention profiles that coincide exactly throughout the sweep region k <= 8 — so every "
                "arithmetic probe reads an identical number, all below the bar — while their knees range "
                "from 9 to 60, drawing the Grid Underdetermination Theorem to scale. The right panel plots "
                "the bracket ratio (upper bound divided by lower bound) that each grid can certify as a "
                "function of the true knee: the geometric grid stays below two forever, while the "
                "arithmetic grid's ratio becomes infinite the moment the knee passes its ceiling of 32."
            ),
            "code": read(ASSETS / "viz_underdetermination.py"),
        },
        {
            "name": "Two Independent Derivations of One Multiplicative Exponent",
            "description": (
                "Three panels tracing the factor r along both routes. The left panel draws a base attention "
                "profile and its three-fold dilution on a common word axis, showing mass and shape preserved "
                "while the knee moves from 8 words to 24 tokens. The middle panel plots the measured diluted "
                "knee against r inside the provably sharp envelopes r(K-1) and rK, with the refuted additive "
                "rule K + 4 drawn as a flat line that the true curve leaves immediately. The right panel "
                "shows the tokenizer-free collision-mass floor tau^2/C tracking the true diluted knee exactly "
                "as r grows, because dilution divides the collision mass by precisely r."
            ),
            "code": read(ASSETS / "viz_dilution_collision.py"),
        },
    ],
    "interactive_demos": [
        {
            "title": "The Knee Laboratory — Watch a Budget Escape Its Ruler",
            "description": (
                "A live canvas laboratory for the central object. Choose an attention shape (Zipf-like, "
                "peaked geometric, flat, or a two-level staircase), set the number of words, move the "
                "retention bar, and turn the tokens-per-word dial r that splits every word into r equal "
                "tokens. The canvas draws the sorted attention weights, the cumulative retention curve, the "
                "bar, the knee, an arithmetic probe grid {8,16,24,32} in orange and a geometric grid "
                "{1,2,4,8,...} in green, plus the tokenizer-free collision-mass floor tau^2/C as a dashed "
                "line. Readouts report the knee, the collision mass, the floor, and the provable sandwich "
                "r(K-1)+1 to rK, and a verdict panel states exactly what each grid can honestly certify — "
                "flipping to 'arithmetic grid escaped: all it certifies is knee > 32' the moment the knee "
                "leaves the grid, while still reporting the geometric bracket. Two guided experiments are "
                "suggested: break the arithmetic grid by raising r on a flat profile, and watch the "
                "collision-mass floor move in exact lockstep with the true knee. Collapsible sections give "
                "the Cauchy-Schwarz derivation of the floor and its sharpness."
            ),
            "html": read(ASSETS / "widget_knee_lab.html"),
        },
        {
            "title": "Tokenizer Bench — Corpus Average versus Top-K Average",
            "description": (
                "An editable bench that pits the two competing predictors of the tokenized knee against "
                "each other. A fixed sorted attention profile over sixteen words is displayed with an "
                "editable per-word token cost; presets supply English-like, French-like and rare-word-heavy "
                "cost patterns, and the retention bar is adjustable. The bench computes the word-level knee "
                "K, the true token-level knee, the exact cumulative bracket (C_w(K-1), C_w(K)] predicted by "
                "the variable dilution law, and the naive corpus-average prediction, badging each as a hit "
                "or a miss. Making the heavily attended words expensive — the way accented and elided "
                "high-frequency French function words are — drives the corpus average to under-predict by a "
                "third while the top-K bracket remains exact, which is precisely the discriminating test "
                "the theory proposes. A collapsible panel states and proves the underlying theorem, "
                "including the extreme-ratio corollary L(K-1) < K_diluted <= RK that explains how language "
                "families end up whole grid ranges apart."
            ),
            "html": read(ASSETS / "widget_tokenizer_bench.html"),
        },
    ],
    "interactive_layout": read(ASSETS / "interactive_layout.md"),
    "lean_proofs": lean_proofs,
    "future_directions": read(ASSETS / "future_directions.md"),
    "modules": {
        "demo": read(ROOT / "demo.py"),
        "geometric_bracket": read(ASSETS / "alg_geometric_bracket.py"),
        "topk_tokens": read(ASSETS / "alg_topk_tokens.py"),
        "collision_floor": read(ASSETS / "alg_collision_floor.py"),
        "viz_underdetermination": read(ASSETS / "viz_underdetermination.py"),
        "viz_dilution_collision": read(ASSETS / "viz_dilution_collision.py"),
    },
    "lean_files": LEAN_FILES,
}

out = ROOT / "PACKAGE.json"
out.write_text(json.dumps(package, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
print(f"wrote {out} ({out.stat().st_size} bytes)")


"""
Visualization: the two independent routes to the multiplicative factor r.

LEFT  -- Token dilution in the profile domain.  A base attention profile p
         over "words" is shown as bars; its r-fold dilution splits each bar
         into r bars of height p(i)/r.  Total mass is preserved, the shape is
         preserved, but the knee (marked) moves from K to essentially r*K.

MIDDLE-- The dilution sandwich.  For a fixed base knee K, the diluted knee is
         plotted against r together with the two provably sharp envelopes
         r*(K-1) and r*K.  Any additive "fine-step" rule would be a horizontal
         offset; the picture shows why no such rule can exist.

RIGHT -- The collision-mass route.  For each r the collision (Renyi-2) mass of
         the diluted profile is exactly C/r, so the tokenizer-free floor
         tau^2 / C multiplies by exactly r.  Plotted against the true diluted
         knee, showing the floor tracking it with the same slope.

Produces `knee_dilution_collision.png`.
"""

from __future__ import annotations

from typing import List, Sequence

import matplotlib.pyplot as plt
import numpy as np


def dilate(p: Sequence[float], r: int) -> List[float]:
    out: List[float] = []
    for v in p:
        out.extend([v / r] * r)
    return out


def knee(p: Sequence[float], tau: float) -> int:
    running = 0.0
    for k, v in enumerate(p, start=1):
        running += v
        if running >= tau - 1e-12:
            return k
    return -1


def collision(p: Sequence[float]) -> float:
    return float(sum(v * v for v in p))


def main() -> None:
    fig, (ax1, ax2, ax3) = plt.subplots(1, 3, figsize=(16.5, 4.9))

    # ---------------- LEFT: dilution in the profile domain ----------------
    base = [0.30, 0.18, 0.12, 0.09, 0.07, 0.06, 0.05, 0.04, 0.03, 0.03, 0.02, 0.01]
    tau = 0.90
    r = 3
    dil = dilate(base, r)
    Kb, Kd = knee(base, tau), knee(dil, tau)

    ax1.bar(np.arange(len(base)) + 0.5, base, width=0.9, color="#4575b4",
            alpha=0.85, label="base profile $p$")
    ax1.bar(np.arange(len(dil)) / r + 0.5 / r, dil, width=0.9 / r,
            color="#d73027", alpha=0.75, label=f"{r}-fold dilution $D_{r}p$")
    ax1.axvline(Kb, color="#4575b4", ls="--", lw=2)
    ax1.axvline(Kd / r, color="#d73027", ls="--", lw=2)
    ax1.text(Kb + 0.15, 0.27, f"$K={Kb}$", color="#4575b4", fontsize=11)
    ax1.text(Kd / r + 0.15, 0.22, f"$K_{{dil}}={Kd}$\n(tokens)", color="#d73027", fontsize=11)
    ax1.set_xlabel("word index (diluted profile drawn on the same word axis)")
    ax1.set_ylabel("attention mass")
    ax1.set_title("Dilution preserves mass, moves the knee")
    ax1.legend(fontsize=9)
    ax1.grid(alpha=0.2)

    # ---------------- MIDDLE: the sandwich ----------------
    rs = np.arange(1, 13)
    kd = np.array([knee(dilate(base, int(rr)), tau) for rr in rs])
    K = Kb
    ax2.fill_between(rs, rs * (K - 1), rs * K, color="0.85",
                     label=r"sandwich $r(K-1) < K_{dil} \leq rK$")
    ax2.plot(rs, rs * K, color="0.35", lw=1.6, ls="--")
    ax2.plot(rs, rs * (K - 1), color="0.35", lw=1.6, ls="--")
    ax2.plot(rs, kd, "o-", color="#d73027", lw=2.2, ms=6, label="measured diluted knee")
    ax2.plot(rs, K + 4 * np.ones_like(rs), ":", color="#1a9850", lw=2.2,
             label=r'the refuted additive rule $K + 4$')
    ax2.set_xlabel("tokens per word $r$")
    ax2.set_ylabel("knee (in tokens)")
    ax2.set_title("Multiplicative law vs. the additive fine-step")
    ax2.legend(fontsize=9, loc="upper left")
    ax2.grid(alpha=0.25)

    # ---------------- RIGHT: collision-mass floor ----------------
    flat = [1.0 / 16] * 16
    tau2 = 1.0
    floors, knees, Cs = [], [], []
    for rr in rs:
        q = dilate(flat, int(rr))
        C = collision(q)
        Cs.append(C)
        floors.append(tau2 ** 2 / C)
        knees.append(knee(q, tau2))
    ax3.plot(rs, knees, "o-", color="#4575b4", lw=2.2, ms=6, label="true knee")
    ax3.plot(rs, floors, "s--", color="#f46d43", lw=2.2, ms=6,
             label=r"tokenizer-free floor $\tau^2/C$")
    ax3.set_xlabel("tokens per word $r$")
    ax3.set_ylabel("keys")
    ax3.set_title(r"Collision mass divides by $r$: floor multiplies by $r$")
    ax3.legend(fontsize=10, loc="upper left")
    ax3.grid(alpha=0.25)
    ax3.text(1.2, max(knees) * 0.55,
             "flat profile: the floor is\nattained exactly",
             fontsize=10, color="0.3")

    fig.suptitle("Two independent derivations of one multiplicative exponent", fontsize=14)
    fig.tight_layout(rect=(0, 0, 1, 0.94))
    fig.savefig("knee_dilution_collision.png", dpi=160)
    print("wrote knee_dilution_collision.png")


if __name__ == "__main__":
    main()


"""
Visualization: what a failed budget sweep can and cannot see.

Two panels.

LEFT  -- Retention curves of a family of two-level attention profiles
         T(g, N, c) with g = 8, c = 1/(N-g), for several targets N.  All of
         them coincide exactly on the sweep region k <= 8, so every probe of
         an arithmetic grid reads the same number, yet their knees (the first
         budget reaching the bar tau = g + 1 = 9) range over 9 ... 200.
         This is the underdetermination theorem drawn to scale.

RIGHT -- Arithmetic versus geometric sweeps against a multiplicative tax.
         For a family of flat profiles with knee K, we plot the bracket width
         (upper/lower ratio) certified by an arithmetic grid {8,16,24,32} and
         by a geometric grid {1,2,4,...}.  The geometric ratio never exceeds
         2; the arithmetic ratio becomes infinite the moment the knee escapes
         the grid ceiling.

Produces `knee_underdetermination.png`.
"""

from __future__ import annotations

from fractions import Fraction
from typing import List, Sequence

import matplotlib.pyplot as plt
import numpy as np


def two_level(g: int, N: int) -> List[float]:
    """Height 1 on the first g keys, height 1/(N-g) on keys g..N-1."""
    c = 1.0 / (N - g)
    return [1.0] * g + [c] * (N - g)


def retention_curve(p: Sequence[float], kmax: int) -> np.ndarray:
    """M_p(k) for k = 0..kmax."""
    out = np.zeros(kmax + 1)
    running = 0.0
    for k in range(1, kmax + 1):
        running += p[k - 1] if k - 1 < len(p) else 0.0
        out[k] = running
    return out


def knee(p: Sequence[float], tau: float) -> int:
    running = 0.0
    for k, v in enumerate(p, start=1):
        running += v
        if running >= tau - 1e-12:
            return k
    return -1


def geometric_ratio(K: int) -> float:
    """Width of the ratio-bracket a geometric sweep certifies for knee K."""
    S = 0
    while 2 ** S < K:
        S += 1
    lo = 2 ** (S - 1) + 1 if S > 0 else 1
    return (2 ** S) / lo


def main() -> None:
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13.5, 5.2))

    # ---------------- LEFT: underdetermination ----------------
    g, tau, kmax = 8, 9.0, 60
    targets = [9, 12, 20, 33, 48, 60]
    colors = plt.cm.viridis(np.linspace(0.05, 0.85, len(targets)))
    ks = np.arange(kmax + 1)
    for N, col in zip(targets, colors):
        p = two_level(g, N)
        ax1.plot(ks, retention_curve(p, kmax), color=col, lw=2,
                 label=f"knee = {knee(p, tau)}")
    ax1.axhline(tau, color="crimson", ls="--", lw=1.6, label=r"bar $\tau=9$")
    ax1.axvspan(0, g, color="0.85", alpha=0.7)
    for probe in (2, 4, 6, 8):
        ax1.plot([probe], [probe], marker="o", ms=7, color="black", zorder=5)
    ax1.annotate("sweep region:\nall curves identical",
                 xy=(6, 6), xytext=(22, 3.6), fontsize=10, color="0.25",
                 arrowprops=dict(arrowstyle="->", color="0.45"))
    ax1.set_xlabel("key budget $k$")
    ax1.set_ylabel(r"retained mass $M_p(k)$")
    ax1.set_title("A failed sweep fixes only a lower bound")
    ax1.set_xlim(0, kmax)
    ax1.set_ylim(0, 10.5)
    ax1.legend(fontsize=9, loc="lower right", ncol=2)
    ax1.grid(alpha=0.25)

    # ---------------- RIGHT: grid geometry ----------------
    Ks = np.arange(2, 129)
    geo = np.array([geometric_ratio(int(K)) for K in Ks])
    arith = []
    grid = [8, 16, 24, 32]
    for K in Ks:
        upper = next((gp for gp in grid if gp >= K), None)
        if upper is None:
            arith.append(np.nan)                       # no upper bound at all
        else:
            lower = max([gp for gp in grid if gp < K], default=0) + 1
            arith.append(upper / lower)
    arith = np.array(arith, dtype=float)

    ax2.plot(Ks, geo, color="#1b7837", lw=2.4, label="geometric grid $1,2,4,8,\\dots$")
    ax2.plot(Ks, arith, color="#762a83", lw=2.4, label="arithmetic grid $8,16,24,32$")
    ax2.axhline(2.0, color="#1b7837", ls=":", lw=1.4)
    ax2.axvline(32, color="0.4", ls="--", lw=1.2)
    ax2.text(34, 5.2, "arithmetic grid escaped:\nno upper bound exists",
             fontsize=10, color="#762a83")
    ax2.set_xlabel("true knee $K$")
    ax2.set_ylabel("certified bracket ratio (upper / lower)")
    ax2.set_title("Only a multiplicative grid survives a multiplicative tax")
    ax2.set_ylim(0.8, 9)
    ax2.legend(fontsize=10, loc="upper left")
    ax2.grid(alpha=0.25)

    fig.suptitle("The memory knee: what a budget sweep certifies", fontsize=14)
    fig.tight_layout(rect=(0, 0, 1, 0.95))
    fig.savefig("knee_underdetermination.png", dpi=160)
    print("wrote knee_underdetermination.png")


if __name__ == "__main__":
    main()
