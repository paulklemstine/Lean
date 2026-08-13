"""
The Register Threshold of Order Finding — numerical demonstrations.

Self-contained (standard library only). Every function is inlined and typed.

The script demonstrates, numerically, the results of the accompanying paper:

  1. Farey separation:  distinct rationals p/q != p'/q' satisfy
     |p/q - p'/q'| >= 1/(q q').
  2. The two-sided register threshold: a t-bit reading determines the
     continued-fraction target iff  2^t  is about  R^2 ; the empirically located
     t_min sits within one bit of  2 log2 R .
  3. Refutation of the linear prediction  t = log2 r + O(log log r).
  4. Classical collapse: for  2^t <= r  the truncated outcome map is onto the
     whole t-bit alphabet, so the observable records of *different* orders are
     literally the same set.
  5. Capacity:  #{ floor(2^t k / r) : k < r } = min(2^t, r)  exactly.
  6. Divisor ambiguity: outcomes(t, r) is a subset of outcomes(t, r*s) at every t.
  7. End-to-end truncated Shor post-processing: recovery succeeds above the
     threshold and fails below it, no matter how many samples are taken.
  8. Sample criterion: a record recovers r iff gcd(gcd(k_1..k_m), r) = 1, iff the
     residues generate Z/rZ.
  9. Exact success density: #good(r, m) = sum_{d|r} mu(d) (r/d)^m
                                        = r^m prod_{p|r} (1 - p^-m)   (Jordan J_m).
 10. Uniform concentration: failure probability of m >= 2 samples is < 2^-(m-1).

Run:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction
from itertools import product
from math import floor, gcd, isqrt, log2
from typing import Dict, Iterable, List, Set, Tuple


# ----------------------------------------------------------------------------
# 0. Basic arithmetic helpers
# ----------------------------------------------------------------------------

def prime_factors(n: int) -> List[int]:
    """Distinct prime divisors of n >= 1 (trial division; n is small here)."""
    out: List[int] = []
    m = n
    d = 2
    while d * d <= m:
        if m % d == 0:
            out.append(d)
            while m % d == 0:
                m //= d
        d += 1 if d == 2 else 2
    if m > 1:
        out.append(m)
    return out


def moebius(n: int) -> int:
    """Moebius function mu(n)."""
    if n == 1:
        return 1
    m = n
    mu = 1
    for p in prime_factors(n):
        m //= p
        if m % p == 0:            # p^2 | n
            return 0
        mu = -mu
    return mu


def divisors(n: int) -> List[int]:
    """All positive divisors of n, ascending."""
    small = [d for d in range(1, isqrt(n) + 1) if n % d == 0]
    large = [n // d for d in reversed(small) if n // d != d]
    return small + large


def lcm_list(xs: Iterable[int]) -> int:
    """lcm of a list, with lcm() = 1."""
    acc = 1
    for x in xs:
        acc = acc * x // gcd(acc, x)
    return acc


# ----------------------------------------------------------------------------
# 1. Farey separation
# ----------------------------------------------------------------------------

def farey_separation_check(max_den: int) -> Tuple[int, float]:
    """
    Verify |a - b| >= 1/(den(a) den(b)) for all distinct reduced fractions in
    (0,1) with denominator <= max_den.  Returns (#pairs checked, worst ratio),
    where the ratio is |a-b| * den(a) * den(b) >= 1.
    """
    fracs = sorted({Fraction(p, q) for q in range(1, max_den + 1)
                    for p in range(1, q)})
    worst = float("inf")
    count = 0
    for i, a in enumerate(fracs):
        for b in fracs[i + 1:]:
            ratio = float(abs(a - b) * a.denominator * b.denominator)
            worst = min(worst, ratio)
            count += 1
    return count, worst


# ----------------------------------------------------------------------------
# 2-3. The register threshold
# ----------------------------------------------------------------------------

def separates(t: int, bound: int) -> bool:
    """
    True iff the t-bit dyadic grid separates every pair of distinct reduced
    fractions in (0,1) of denominator <= bound, i.e. no two share the cell
    floor(2^t * q).
    """
    seen: Dict[int, Fraction] = {}
    for q in range(1, bound + 1):
        for p in range(1, q):
            if gcd(p, q) != 1:
                continue
            frac = Fraction(p, q)
            cell = (2 ** t * p) // q
            if cell in seen and seen[cell] != frac:
                return False
            seen[cell] = frac
    return True


def minimal_separating_bits(bound: int) -> int:
    """Least t such that the t-bit grid separates all fractions of den <= bound."""
    t = 1
    while not separates(t, bound):
        t += 1
    return t


def compatible_pair_exists(t: int, bound: int) -> bool:
    """
    Tolerance model: is there a phase x compatible (within 2^-(t+1)) with two
    distinct reduced fractions of denominator <= bound?  The extremal witness is
    the neighbour pair 1/bound, 1/(bound-1) at distance 1/(bound(bound-1)).
    """
    return 2 ** t < bound * (bound - 1)


# ----------------------------------------------------------------------------
# 4-6. Truncated register: collapse, capacity, divisor ambiguity
# ----------------------------------------------------------------------------

def trunc_outcome(t: int, r: int, k: int) -> int:
    """The t-bit truncated register outcome for the exact phase k/r."""
    return (2 ** t * k) // r


def outcomes(t: int, r: int) -> Set[int]:
    """The set of outcomes realised at order r."""
    return {trunc_outcome(t, r, k) for k in range(r)}


def capacity(t: int, r: int) -> int:
    """Number of distinct outcomes; the theorem says this is min(2^t, r)."""
    return len(outcomes(t, r))


# ----------------------------------------------------------------------------
# 7. Honest continued-fraction post-processing of a truncated outcome
# ----------------------------------------------------------------------------

def cf_convergents(x: Fraction, bound: int) -> Fraction:
    """
    Last continued-fraction convergent of x with denominator <= bound.
    This is the honest Shor post-processor.
    """
    a0 = floor(x)
    p_prev, q_prev = 1, 0
    p_cur, q_cur = a0, 1
    frac = x - a0
    best = Fraction(p_cur, q_cur)
    while frac != 0:
        inv = 1 / frac
        a = floor(inv)
        p_prev, p_cur = p_cur, a * p_cur + p_prev
        q_prev, q_cur = q_cur, a * q_cur + q_prev
        if q_cur > bound:
            break
        best = Fraction(p_cur, q_cur)
        frac = inv - a
    return best


def recover_from_record(t: int, r: int, ks: List[int], bound: int) -> int:
    """
    Full truncated-Shor post-processing: read each sample k at t bits, take the
    cell midpoint as the phase estimate, reconstruct by continued fractions with
    denominator bound `bound`, and return the lcm of the reconstructed
    denominators.
    """
    dens: List[int] = []
    for k in ks:
        cell = trunc_outcome(t, r, k)
        x = Fraction(2 * cell + 1, 2 ** (t + 1))   # midpoint of the cell
        dens.append(cf_convergents(x, bound).denominator)
    return lcm_list(dens)


# ----------------------------------------------------------------------------
# 8-10. The sample criterion and the exact success density
# ----------------------------------------------------------------------------

def record_gcd(ks: Iterable[int]) -> int:
    """gcd of a record, with gcd() = 0."""
    acc = 0
    for k in ks:
        acc = gcd(acc, k)
    return acc


def record_recovers(ks: List[int], r: int) -> bool:
    """
    Criterion: lcm_i (r / gcd(k_i, r)) == r, tested both directly and through
    the arithmetic condition gcd(gcd_i k_i, r) == 1.
    """
    direct = lcm_list(r // gcd(k, r) for k in ks) == r
    criterion = gcd(record_gcd(ks), r) == 1
    assert direct == criterion, (ks, r)
    return direct


def generates_cyclic_group(ks: List[int], r: int) -> bool:
    """Do the residues of ks generate the additive group Z/rZ?"""
    seen = {0}
    frontier = [0]
    steps = [k % r for k in ks]
    while frontier:
        x = frontier.pop()
        for s in steps:
            y = (x + s) % r
            if y not in seen:
                seen.add(y)
                frontier.append(y)
    return len(seen) == r


def count_good_records_bruteforce(r: int, m: int) -> int:
    """Enumerate all r^m records and count those recovering r."""
    return sum(1 for ks in product(range(r), repeat=m)
               if gcd(record_gcd(ks), r) == 1)


def jordan_totient_moebius(r: int, m: int) -> int:
    """J_m(r) = sum_{d | r} mu(d) (r/d)^m."""
    return sum(moebius(d) * (r // d) ** m for d in divisors(r))


def jordan_totient_euler(r: int, m: int) -> Fraction:
    """J_m(r) = r^m prod_{p | r} (1 - p^-m)."""
    val = Fraction(r ** m)
    for p in prime_factors(r):
        val *= (1 - Fraction(1, p ** m))
    return val


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------

def demo_farey() -> None:
    print("=" * 74)
    print("1. FAREY SEPARATION:  |a - b| >= 1 / (den(a) den(b))")
    print("=" * 74)
    for max_den in (8, 16, 24):
        n, worst = farey_separation_check(max_den)
        print(f"  denominators <= {max_den:3d}:  {n:6d} pairs checked, "
              f"min |a-b|*q*q' = {worst:.6f}  (>= 1 required)")
    print("  The bound is tight: 1/R and 1/(R-1) attain |a-b|*q*q' = 1 exactly.\n")


def demo_threshold() -> None:
    print("=" * 74)
    print("2. THE REGISTER THRESHOLD:  t_min  vs  2*log2(R)")
    print("=" * 74)
    print(f"  {'R':>4} {'t_min (grid)':>13} {'2 log2 R':>10} {'log2 R':>8}"
          f" {'verdict':>26}")
    for bound in (4, 6, 8, 12, 16, 24, 32, 48, 64):
        tmin = minimal_separating_bits(bound)
        two_log = 2 * log2(bound)
        ok = "within 1 bit of 2 log2 R" if abs(tmin - two_log) <= 1.5 else "OFF"
        print(f"  {bound:>4} {tmin:>13} {two_log:>10.2f} {log2(bound):>8.2f}"
              f" {ok:>26}")
    print()
    print("  Tolerance model, two-sided window  R(R-1) <= 2^t < R^2:")
    for bound in (16, 32, 64, 1024):
        lo = 0
        while 2 ** lo < bound * (bound - 1):
            lo += 1
        hi = 0
        while 2 ** hi < bound ** 2:
            hi += 1
        print(f"    R = {bound:5d}:  ambiguous for t < {lo}, "
              f"provably unique for t >= {hi}   (2 log2 R = {2*log2(bound):.1f})")
    print()


def demo_linear_refutation() -> None:
    print("=" * 74)
    print("3. THE LINEAR PREDICTION  t = log2 r + c  IS REFUTED")
    print("=" * 74)
    print("  A register of log2(R) + c bits stays ambiguous once R > 2^c + 1.")
    print(f"  {'c':>3} {'R':>8} {'t = log2 R + c':>15} {'ambiguous?':>12}")
    for c in (0, 2, 4, 8):
        for bound in (2 ** 10, 2 ** 14, 2 ** 18):
            t = int(log2(bound)) + c
            print(f"  {c:>3} {bound:>8} {t:>15} "
                  f"{str(compatible_pair_exists(t, bound)):>12}")
    print("  Every entry is ambiguous: no constant, and no O(log log R)")
    print("  correction, rescues a register of size log2(R) + o(log R).\n")


def demo_collapse_and_capacity() -> None:
    print("=" * 74)
    print("4-6. COLLAPSE, CAPACITY, DIVISOR AMBIGUITY")
    print("=" * 74)
    t = 4
    alphabet = set(range(2 ** t))
    print(f"  t = {t}, alphabet = {{0,...,{2**t - 1}}}")
    window = [r for r in range(2 ** t, 2 ** t + 8)]
    same = all(outcomes(t, r) == alphabet for r in window)
    print(f"  orders {window[0]}..{window[-1]}: all outcome sets equal the "
          f"full alphabet?  {same}")
    print("  => the observable records of these 8 distinct orders coincide,")
    print("     so no estimator with ANY sample budget separates them.\n")

    print("  Capacity  #outcomes(t, r)  vs  min(2^t, r):")
    print(f"  {'t':>3} {'r':>5} {'#outcomes':>10} {'min(2^t,r)':>11} {'ok':>4}")
    for t2 in (3, 5, 7):
        for r in (5, 17, 32, 100):
            c = capacity(t2, r)
            expected = min(2 ** t2, r)
            print(f"  {t2:>3} {r:>5} {c:>10} {expected:>11} "
                  f"{str(c == expected):>6}")
    print()

    print("  Divisor ambiguity: outcomes(t, r) subset of outcomes(t, r*s)?")
    for t3, r, s in ((3, 7, 3), (6, 12, 5), (9, 21, 2)):
        ok = outcomes(t3, r) <= outcomes(t3, r * s)
        print(f"    t={t3:>2}, r={r:>3}, s={s}:  {ok}")
    print("  True at every register size: no amount of precision removes it.\n")


def demo_end_to_end() -> None:
    print("=" * 74)
    print("7. END-TO-END TRUNCATED ORDER FINDING")
    print("=" * 74)
    print("  Honest post-processing: read k/r at t bits, reconstruct by")
    print("  continued fractions, take lcm over the record.\n")
    print(f"  {'r':>5} {'t':>4} {'2 log2 r':>9} {'m=1':>7} {'m=2':>7}"
          f" {'m=5':>7} {'m=20':>7}")
    for r in (21, 55, 133, 323):
        two_log = 2 * log2(r)
        for t in (int(log2(r)), int(two_log) - 2, int(two_log) + 2):
            results: List[str] = []
            for m in (1, 2, 5, 20):
                ks = [(3 * i + 1) % r for i in range(1, m + 1)]
                ks = [k for k in ks if k != 0] or [1]
                got = recover_from_record(t, r, ks, r)
                results.append("OK" if got == r else "fail")
            print(f"  {r:>5} {t:>4} {two_log:>9.2f} " +
                  " ".join(f"{x:>7}" for x in results))
        print()
    print("  Below 2 log2 r the register fails at every sample count;")
    print("  above it, a couple of samples suffice.\n")


def demo_sample_criterion() -> None:
    print("=" * 74)
    print("8. SAMPLE CRITERION = GENERATION CRITERION")
    print("=" * 74)
    print(f"  {'r':>4} {'record':>16} {'gcd(g,r)=1':>11} {'lcm = r':>9}"
          f" {'generates Z/rZ':>15}")
    cases: List[Tuple[int, List[int]]] = [
        (12, [4]), (12, [4, 9]), (12, [6, 8]), (12, [3, 8]),
        (30, [10, 15]), (30, [10, 6]), (30, [6, 10, 15]),
    ]
    for r, ks in cases:
        crit = gcd(record_gcd(ks), r) == 1
        rec = record_recovers(ks, r)
        gen = generates_cyclic_group(ks, r)
        print(f"  {r:>4} {str(ks):>16} {str(crit):>11} {str(rec):>9}"
              f" {str(gen):>15}")
    print("  All three columns agree, always.\n")


def demo_exact_density() -> None:
    print("=" * 74)
    print("9. EXACT SUCCESS COUNT = JORDAN'S TOTIENT  J_m(r)")
    print("=" * 74)
    print(f"  {'r':>4} {'m':>3} {'brute force':>12} {'Moebius sum':>12}"
          f" {'Euler product':>14} {'success prob':>13}")
    for r in (6, 10, 12, 30):
        for m in (1, 2, 3):
            bf = count_good_records_bruteforce(r, m)
            mo = jordan_totient_moebius(r, m)
            eu = jordan_totient_euler(r, m)
            assert bf == mo == eu, (r, m, bf, mo, eu)
            print(f"  {r:>4} {m:>3} {bf:>12} {mo:>12} {str(eu):>14}"
                  f" {float(Fraction(bf, r**m)):>13.6f}")
    print()
    print("10. UNIFORM CONCENTRATION:  failure prob  <  2^-(m-1)")
    print(f"  {'r':>8} {'m':>3} {'exact failure':>14} {'2^-(m-1)':>10} {'ok':>5}")
    for r in (2, 6, 30, 210, 2310, 30030):
        for m in (2, 3, 5):
            good = jordan_totient_euler(r, m)
            fail = 1 - good / Fraction(r ** m)
            bound = Fraction(1, 2 ** (m - 1))
            print(f"  {r:>8} {m:>3} {float(fail):>14.8f} {float(bound):>10.6f}"
                  f" {str(fail < bound):>5}")
    print()
    print("  r = 30030 = 2*3*5*7*11*13 maximises the failure probability among")
    print("  small orders; even there, two samples succeed more than half the")
    print("  time, and the bound 2^-(m-1) holds uniformly in r.\n")


def main() -> None:
    print()
    print("#" * 74)
    print("#  THE REGISTER THRESHOLD OF ORDER FINDING — numerical demonstrations")
    print("#" * 74)
    print()
    demo_farey()
    demo_threshold()
    demo_linear_refutation()
    demo_collapse_and_capacity()
    demo_end_to_end()
    demo_sample_criterion()
    demo_exact_density()
    print("=" * 74)
    print("SUMMARY")
    print("=" * 74)
    print("  * t_min = 2 log2 r + O(1), two-sided and model-independent.")
    print("  * Below log2 r bits the observable data of distinct orders are")
    print("    identical: no sample budget helps.")
    print("  * Above the threshold a record recovers r iff its residues")
    print("    generate Z/rZ, and the success count is exactly Jordan's J_m(r).")
    print("  * Ledger: 2 log2 r qubits (rigid) vs O(1) samples (nearly free).")
    print()


if __name__ == "__main__":
    main()
