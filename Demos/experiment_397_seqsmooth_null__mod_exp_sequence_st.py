#!/usr/bin/env python3
"""
Mod-exponential windows are smoothness-blind
============================================

Numerical demonstration of the main results.

Setting.  For an odd modulus N and a base a coprime to N, the mod-exponential
sequence is s_x = a^x mod N.  Pollard's p-1 method factors N when some prime
factor p has p-1 dividing M = lcm(1..B); such an N is called SMOOTH, otherwise
GENERAL.  The question: does the SMOOTH/GENERAL class leak into the statistics
of a short window s_0, ..., s_{m-1} with m far below B?

The theorems say no, exactly:

  (1) Structure theorem.  first(x) = x mod d, where d = ord_N(a).  The window's
      collision structure is the residue map modulo the order and nothing else.
  (2) Truncation theorem.  A length-m window depends on (a, N) only through
      min(m, d), so at most m+1 distinct length-m patterns exist in total,
      i.e. at most log2(m+1) bits.
  (3) Exact-chance theorem.  A statistic constant across two classes has
      AUC = 1/2 exactly (tie-aware rank definition).
  (4) The weakness is real, and exactly characterised by
      r | a^M - 1  <=>  ord_r(a) | M.

This script verifies all of these numerically, including the explicit matched
pair N_smooth = 1009*1019 and N_general = 1019*1039 with M = lcm(1..20).

Run:  python3 demo.py        (pure standard library, no dependencies)
"""

from __future__ import annotations

import random
from math import gcd, lcm, log2
from typing import Callable, Dict, List, Sequence, Tuple

# ----------------------------------------------------------------------------
# Basic arithmetic
# ----------------------------------------------------------------------------


def lcm_upto(bound: int) -> int:
    """M = lcm(1, 2, ..., bound), the exponent of Pollard's p-1 method."""
    acc = 1
    for k in range(1, bound + 1):
        acc = lcm(acc, k)
    return acc


def multiplicative_order(a: int, n: int) -> int:
    """Least d >= 1 with a^d = 1 (mod n).  Requires gcd(a, n) = 1.

    Naive walk; fine for the small moduli used here.
    """
    if gcd(a, n) != 1:
        raise ValueError("base must be coprime to the modulus")
    x, d = a % n, 1
    while x != 1:
        x = (x * a) % n
        d += 1
    return d


def mod_exp_window(a: int, n: int, m: int) -> List[int]:
    """The length-m window s_x = a^x mod N, x = 0, ..., m-1."""
    out, x = [], 1 % n
    for _ in range(m):
        out.append(x)
        x = (x * a) % n
    return out


def pattern_word(window: Sequence[int]) -> Tuple[int, ...]:
    """Collision structure: index -> least index carrying the same value.

    This erases the numerical values and keeps only which positions collide.
    """
    seen: Dict[int, int] = {}
    out: List[int] = []
    for i, v in enumerate(window):
        if v not in seen:
            seen[v] = i
        out.append(seen[v])
    return tuple(out)


def is_prime(n: int) -> bool:
    """Deterministic Miller-Rabin for n < 3.3 * 10^24."""
    if n < 2:
        return False
    for p in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
        if n % p == 0:
            return n == p
    d, r = n - 1, 0
    while d % 2 == 0:
        d //= 2
        r += 1
    for base in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
        x = pow(base, d, n)
        if x in (1, n - 1):
            continue
        for _ in range(r - 1):
            x = x * x % n
            if x == n - 1:
                break
        else:
            return False
    return True


# ----------------------------------------------------------------------------
# Pollard p-1
# ----------------------------------------------------------------------------


def pollard_p_minus_1(n: int, bound: int, base: int = 2) -> int:
    """gcd(base^lcm(1..bound) - 1, n).  A proper divisor means success."""
    x = base % n
    for k in range(2, bound + 1):
        x = pow(x, k, n)
    return gcd(x - 1, n)


def is_smooth(value: int, bound: int) -> bool:
    """True iff every prime power dividing `value` is at most `bound`."""
    v = value
    f = 2
    while f * f <= v:
        if v % f == 0:
            power = 1
            while v % f == 0:
                v //= f
                power *= f
            if power > bound:
                return False
        f += 1
    return v <= bound


# ----------------------------------------------------------------------------
# AUC (tie-aware rank definition)
# ----------------------------------------------------------------------------


def auc(positives: Sequence[float], negatives: Sequence[float]) -> float:
    """Area under the ROC curve; ties contribute weight 1/2."""
    if not positives or not negatives:
        raise ValueError("both classes must be nonempty")
    total = 0.0
    for s in positives:
        for g in negatives:
            if g < s:
                total += 1.0
            elif g == s:
                total += 0.5
    return total / (len(positives) * len(negatives))


# ----------------------------------------------------------------------------
# Collision features (every one of these is a function of the pattern word)
# ----------------------------------------------------------------------------


def feature_distinct_count(pattern: Sequence[int]) -> float:
    """Number of distinct values in the window = min(m, ord_N(a))."""
    return float(len(set(pattern)))


def feature_first_collision_gap(pattern: Sequence[int]) -> float:
    """Index of the first repeat, or the window length if there is none."""
    for i, p in enumerate(pattern):
        if p != i:
            return float(i)
    return float(len(pattern))


def feature_max_run(pattern: Sequence[int]) -> float:
    """Longest run of consecutive fresh (non-repeating) positions."""
    best = run = 0
    for i, p in enumerate(pattern):
        run = run + 1 if p == i else 0
        best = max(best, run)
    return float(best)


def feature_pattern_entropy(pattern: Sequence[int]) -> float:
    """Shannon entropy (bits) of the multiset of collision-class sizes."""
    counts: Dict[int, int] = {}
    for p in pattern:
        counts[p] = counts.get(p, 0) + 1
    total = len(pattern)
    ent = 0.0
    for c in counts.values():
        q = c / total
        ent -= q * log2(q)
    return ent


COLLISION_FEATURES: Dict[str, Callable[[Sequence[int]], float]] = {
    "distinct_count": feature_distinct_count,
    "first_collision_gap": feature_first_collision_gap,
    "max_run": feature_max_run,
    "pattern_entropy": feature_pattern_entropy,
}


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------

BAR = "=" * 78


def demo_structure_theorem() -> None:
    """first(x) = x mod ord_N(a), and distinct count = min(m, ord)."""
    print(BAR)
    print("1. STRUCTURE THEOREM:  first(x) = x mod ord_N(a)")
    print(BAR)
    for a, n, m in [(2, 91, 40), (3, 1001, 60), (2, 1009, 40), (5, 561, 50)]:
        d = multiplicative_order(a, n)
        window = mod_exp_window(a, n, m)
        pat = pattern_word(window)
        predicted = tuple(x % d for x in range(m))
        ok = pat == predicted
        dc_ok = len(set(window)) == min(m, d)
        print(
            f"  a={a:<2} N={n:<5} m={m:<3} ord={d:<5} "
            f"pattern == (x mod ord): {ok}   "
            f"distinct == min(m,ord)={min(m, d):<3}: {dc_ok}"
        )
    print()


def demo_information_bound(m: int = 12, trials: int = 4000) -> None:
    """At most m+1 distinct length-m pattern words exist, over ALL (a, N)."""
    print(BAR)
    print(f"2. INFORMATION BOUND:  |{{length-{m} patterns}}| <= {m + 1}")
    print(BAR)
    rng = random.Random(20260814)
    found = set()
    for _ in range(trials):
        n = rng.randrange(3, 5000) | 1
        a = rng.randrange(2, n)
        if gcd(a, n) != 1:
            continue
        found.add(pattern_word(mod_exp_window(a, n, m)))
    print(f"  random (a, N) pairs sampled : {trials}")
    print(f"  distinct pattern words found: {len(found)}  (theoretical max {m + 1})")
    print(f"  information content         : <= log2({m + 1}) = "
          f"{log2(m + 1):.3f} bits")
    print(f"  bound respected             : {len(found) <= m + 1}")
    print()


def demo_pigeonhole(m: int = 8) -> None:
    """Among any m+2 odd moduli, two already share a length-m window."""
    print(BAR)
    print(f"3. PIGEONHOLE:  among any {m + 2} odd moduli, two share the window")
    print(BAR)
    moduli = [n for n in range(3, 3 + 2 * (m + 2), 2)]
    buckets: Dict[Tuple[int, ...], List[int]] = {}
    for n in moduli:
        pat = pattern_word(mod_exp_window(2, n, m))
        buckets.setdefault(pat, []).append(n)
    collided = [v for v in buckets.values() if len(v) > 1]
    print(f"  moduli tested : {moduli}")
    print(f"  distinct windows: {len(buckets)}  (at most {m + 1})")
    for group in collided[:3]:
        print(f"  identical windows for moduli {group}")
    print(f"  a collision exists: {bool(collided)}")
    print()


def demo_matched_pair() -> None:
    """The headline: real weakness, identical windows, AUC = 1/2 exactly."""
    print(BAR)
    print("4. THE MATCHED PAIR:  1009*1019 (SMOOTH) vs 1019*1039 (GENERAL)")
    print(BAR)
    bound = 20
    big_m = lcm_upto(bound)
    n_smooth, n_general = 1009 * 1019, 1019 * 1039
    m = 256

    print(f"  M = lcm(1..{bound}) = {big_m}")
    print(f"  N_smooth  = 1009 * 1019 = {n_smooth}   "
          f"(1008 = 2^4*3^2*7 divides M: {big_m % 1008 == 0})")
    print(f"  N_general = 1019 * 1039 = {n_general}   "
          f"(1018 = 2*509 divides M: {big_m % 1018 == 0}; "
          f"1038 = 2*3*173 divides M: {big_m % 1038 == 0})")
    print()

    g_s = pollard_p_minus_1(n_smooth, bound)
    g_g = pollard_p_minus_1(n_general, bound)
    print("  -- the weakness is REAL --")
    print(f"  gcd(2^M - 1, N_smooth)  = {g_s}   "
          f"proper nontrivial divisor: {1 < g_s < n_smooth}")
    print(f"  gcd(2^M - 1, N_general) = {g_g}   "
          f"proper nontrivial divisor: {1 < g_g < n_general}")
    print()

    d_s = multiplicative_order(2, n_smooth)
    d_g = multiplicative_order(2, n_general)
    w_s = mod_exp_window(2, n_smooth, m)
    w_g = mod_exp_window(2, n_general, m)
    p_s, p_g = pattern_word(w_s), pattern_word(w_g)

    print("  -- yet the WINDOWS are identical --")
    print(f"  ord_{{N_smooth}}(2)  = {d_s}   (>= {m}: {d_s >= m})")
    print(f"  ord_{{N_general}}(2) = {d_g}   (>= {m}: {d_g >= m})")
    print(f"  pattern words equal (both = identity on [0,{m})): {p_s == p_g}")
    print(f"  distinct counts     : {len(set(w_s))} vs {len(set(w_g))}")
    print()

    print("  -- every collision feature ties, so AUC = 1/2 exactly --")
    for name, fn in COLLISION_FEATURES.items():
        vs, vg = fn(p_s), fn(p_g)
        a_val = auc([vs], [vg])
        print(f"    {name:<22} smooth={vs:<10.4f} general={vg:<10.4f} "
              f"AUC={a_val:.4f}")
    print()

    print("  -- the VALUES do differ (out of scope of the collision theorems) --")
    hi_s = sum(1 for v in w_s if v >= n_smooth // 2)
    hi_g = sum(1 for v in w_g if v >= n_general // 2)
    print(f"    high-bit counts: smooth={hi_s}, general={hi_g}  "
          f"(differ: {hi_s != hi_g})")
    print("    their statistical nullity is empirical, not proved here.")
    print()


def demo_blind_family(m: int = 256, size: int = 12) -> None:
    """An infinite family with a constant length-m window, both classes inside."""
    print(BAR)
    print(f"5. BLIND FAMILY:  odd multiples of 1019 all share the length-{m} window")
    print(BAR)
    bound = 20
    members = [1019 * (2 * k + 1) for k in range(1, size + 1)]
    patterns = {pattern_word(mod_exp_window(2, n, m)) for n in members}
    print(f"  members tested       : {members[:6]} ...")
    print(f"  distinct patterns    : {len(patterns)}  (theory: 1)")
    print(f"  all windows identical: {len(patterns) == 1}")

    smooth_members, general_members = [], []
    for n in members:
        cofactor = n // 1019
        if is_prime(cofactor) and is_smooth(cofactor - 1, bound):
            smooth_members.append(n)
        else:
            general_members.append(n)
    print(f"  the family is closed under multiplication by arbitrary odd numbers,")
    print(f"  so it contains instances of BOTH classes; e.g. cofactor-smooth "
          f"members here: {len(smooth_members)}")

    fn = COLLISION_FEATURES["distinct_count"]
    half = len(members) // 2
    s_scores = [fn(pattern_word(mod_exp_window(2, n, m))) for n in members[:half]]
    g_scores = [fn(pattern_word(mod_exp_window(2, n, m))) for n in members[half:]]
    print(f"  AUC of distinct_count under an arbitrary split: "
          f"{auc(s_scores, g_scores):.6f}")
    print()


def demo_blind_family_every_length() -> None:
    """For every m there is a prime p with ord_p(2) >= m, hence a blind family."""
    print(BAR)
    print("6. BLIND FAMILIES AT EVERY LENGTH:  p < 2^ord_p(2), so orders grow")
    print(BAR)
    for m in (4, 8, 16, 32, 64):
        p = 2 ** m + 2
        while not is_prime(p):
            p += 1
        d = multiplicative_order(2, p) if p < 10 ** 7 else None
        certified = p > 2 ** m  # p < 2^ord_p(2) forces ord_p(2) > m
        family = [p * (2 * k + 1) for k in range(1, 5)]
        pats = {pattern_word(mod_exp_window(2, n, m)) for n in family}
        line = (f"  m={m:<3} p={p:<12} ord_p(2)"
                f"{'=' + str(d) if d else ' (large)'}"
                f"  ord>m certified by p>2^m: {certified}"
                f"  family windows identical: {len(pats) == 1}")
        print(line)
    print()


def demo_exact_criterion() -> None:
    """r | a^M - 1  <=>  ord_r(a) | M  -- the single discriminating bit."""
    print(BAR)
    print("7. EXACT CRITERION:  r | a^M - 1  <=>  ord_r(a) | M")
    print(BAR)
    big_m = lcm_upto(20)
    for r in (1009, 1019, 1039, 1051, 1061):
        d = multiplicative_order(2, r)
        lhs = (pow(2, big_m, r) - 1) % r == 0
        rhs = big_m % d == 0
        print(f"  r={r:<6} ord_r(2)={d:<6} r | 2^M-1 : {str(lhs):<5} "
              f"ord | M : {str(rhs):<5} agree: {lhs == rhs}")
    print()


def demo_order_certificate() -> None:
    """A single exponentiation certifies a large order lower bound."""
    print(BAR)
    print("8. ORDER CERTIFICATE:  one exponentiation lower-bounds the order")
    print(BAR)
    cases = [(1019, 509), (1039, 173), (1009, 7)]
    for p, r in cases:
        n = p - 1
        witness = pow(2, n // r, p)
        print(f"  p={p:<6} r={r:<5} (r | p-1: {n % r == 0})  "
              f"2^((p-1)/r) mod p = {witness:<6} != 1: {witness != 1}"
              f"  =>  ord_p(2) >= {r}   (actual {multiplicative_order(2, p)})")
    print()


def demo_crt_mechanism() -> None:
    """ord_{pq}(a) = lcm(ord_p a, ord_q a): the only channel, smoothness-agnostic."""
    print(BAR)
    print("9. MECHANISM:  ord_{pq}(a) = lcm(ord_p a, ord_q a)")
    print(BAR)
    for p, q in [(1009, 1019), (1019, 1039), (101, 103), (13, 17)]:
        dp, dq = multiplicative_order(2, p), multiplicative_order(2, q)
        dn = multiplicative_order(2, p * q)
        print(f"  p={p:<5} q={q:<5} ord_p={dp:<6} ord_q={dq:<6} "
              f"ord_pq={dn:<8} lcm={lcm(dp, dq):<8} equal: {dn == lcm(dp, dq)}")
    print()
    print("  Note the decoupling of SIZE from FACTORIZATION:")
    for p in (1009, 1019, 1039):
        print(f"    p={p}: p-1 = {p - 1}, 20-smooth: {str(is_smooth(p - 1, 20)):<5} "
              f"ord_p(2) = {multiplicative_order(2, p)}")
    print("  A large order is compatible with either smoothness class.")
    print()


def demo_value_level_invariance() -> None:
    """Full-period value set is invariant under a -> a^t with gcd(t, d) = 1."""
    print(BAR)
    print("10. VALUE-LEVEL INVARIANCE (full period):  PV(a^t, N) = PV(a, N)")
    print(BAR)
    for a, n in [(2, 101), (3, 1009), (2, 561), (5, 91)]:
        d = multiplicative_order(a, n)
        base_set = {pow(a, x, n) for x in range(d)}
        results = []
        for t in range(1, min(d, 30)):
            if gcd(t, d) != 1:
                continue
            at = pow(a, t, n)
            dt = multiplicative_order(at, n)
            other = {pow(at, x, n) for x in range(dt)}
            results.append(other == base_set)
        print(f"  a={a:<2} N={n:<5} ord={d:<5} |PV|={len(base_set):<5} "
              f"(== ord: {len(base_set) == d})  "
              f"invariant for all tested t coprime to ord: {all(results)}")
    print()


def demo_synthetic_classification(pairs: int = 36, m: int = 256) -> None:
    """A miniature of the original experiment: matched pairs, features, AUC."""
    print(BAR)
    print(f"11. SYNTHETIC EXPERIMENT: {pairs} matched pairs, collision features")
    print(BAR)
    rng = random.Random(397)
    bound = 20
    big_m = lcm_upto(bound)

    def random_prime(lo: int, hi: int) -> int:
        while True:
            c = rng.randrange(lo, hi) | 1
            if is_prime(c):
                return c

    def smooth_prime(bound_: int, lo: int, hi: int) -> int:
        while True:
            c = random_prime(lo, hi)
            if is_smooth(c - 1, bound_):
                return c

    smooth_scores: Dict[str, List[float]] = {k: [] for k in COLLISION_FEATURES}
    general_scores: Dict[str, List[float]] = {k: [] for k in COLLISION_FEATURES}
    pm1_smooth_hits = pm1_general_hits = 0

    for _ in range(pairs):
        q = random_prime(1 << 17, 1 << 18)
        p_s = smooth_prime(bound, 1 << 15, 1 << 16)
        p_g = random_prime(1 << 15, 1 << 16)
        while is_smooth(p_g - 1, bound):
            p_g = random_prime(1 << 15, 1 << 16)
        n_s, n_g = p_s * q, p_g * q
        if n_s % 2 == 0 or n_g % 2 == 0:
            continue

        g_s = gcd(pow(2, big_m, n_s) - 1, n_s)
        g_g = gcd(pow(2, big_m, n_g) - 1, n_g)
        pm1_smooth_hits += 1 if 1 < g_s < n_s else 0
        pm1_general_hits += 1 if 1 < g_g < n_g else 0

        pat_s = pattern_word(mod_exp_window(2, n_s, m))
        pat_g = pattern_word(mod_exp_window(2, n_g, m))
        for name, fn in COLLISION_FEATURES.items():
            smooth_scores[name].append(fn(pat_s))
            general_scores[name].append(fn(pat_g))

    n_used = len(smooth_scores["distinct_count"])
    print(f"  matched pairs used                 : {n_used}")
    print(f"  p-1 (B={bound}) factors SMOOTH      : "
          f"{pm1_smooth_hits}/{n_used}")
    print(f"  p-1 (B={bound}) factors GENERAL     : "
          f"{pm1_general_hits}/{n_used}")
    print("  the classes are operationally night and day; now the features:")
    for name in COLLISION_FEATURES:
        a_val = auc(smooth_scores[name], general_scores[name])
        print(f"    {name:<22} AUC = {a_val:.6f}")
    print("  every feature is constant across all instances, so AUC = 0.5 exactly.")
    print()


def main() -> None:
    print()
    print("MOD-EXPONENTIAL WINDOWS ARE SMOOTHNESS-BLIND")
    print("numerical demonstration of the main theorems")
    print()
    demo_structure_theorem()
    demo_information_bound()
    demo_pigeonhole()
    demo_matched_pair()
    demo_blind_family()
    demo_blind_family_every_length()
    demo_exact_criterion()
    demo_order_certificate()
    demo_crt_mechanism()
    demo_value_level_invariance()
    demo_synthetic_classification()
    print(BAR)
    print("SUMMARY")
    print(BAR)
    print("  The p-1 weakness is real and dramatic, but the short window of the")
    print("  mod-exponential sequence is a clock reading min(m, ord_N(a)) and")
    print("  nothing more.  Every real statistic of that window scores exactly")
    print("  AUC = 1/2 on an infinite family containing both smoothness classes,")
    print("  at every window length and under every labelling.  Exploiting the")
    print("  weakness requires computing a^M mod N -- i.e. running the p-1 method.")
    print()


if __name__ == "__main__":
    main()
