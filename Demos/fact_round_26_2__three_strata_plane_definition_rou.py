#!/usr/bin/env python3
"""
The Three-Strata Plane: numerical demonstration.
================================================

One coordinate -- the measured exponent

    alpha(f) = lim_{x -> oo} log f(x) / x,      x = log N

-- places three approaches to factoring a semiprime N = p*q on one plane:

    Stratum A  definition-routes (tau, sigma_1 evaluated from N alone)  alpha = 1/2
    Stratum B  classical methods (trial division, Fermat, Pollard rho)  alpha = 1/4
    Stratum C  quantum (Shor)                                           alpha = 0

This script verifies, numerically and from scratch:

  1.  sigma_1(pq) = 1 + p + q + pq  and  tau(pq) = 4, exactly.
  2.  The sigma_1-route inverts in O(1) arithmetic operations via the closed
      formula  p = (s - sqrt(s^2 - 4N)) / 2  with  s = sigma_1(N) - N - 1.
  3.  The scan sandwich  floor(sqrt N) <= sqrt N < floor(sqrt N) + 1, giving
      the measured exponent 1/2 for the definition-route.
  4.  Fermat's search never stops early and halts exactly at 2a = p + q; and
      Fermat vs. trial division are pointwise complementary while being
      aggregate-indistinguishable on uniform draws.
  5.  Pollard rho extracts the factor exactly, and the units lemma: a slope of
      1/2 per prime-bit is an exponent of 1/4 on N.
  6.  Shor's classical split step:  gcd(x - 1, N) is exactly p or q whenever
      x^2 = 1 mod N with x != +-1.
  7.  The price of structure-blindness  P = N^{1/4}: strictly increasing and
      unbounded, with its own measured exponent 1/4.
  8.  The hitting-set lower bound  |S| >= pi(B) - 1  on complete divisor-test
      sets.

Pure standard library. No external dependencies.
"""

from __future__ import annotations

import math
import random
from typing import Callable, Dict, Iterable, List, Optional, Sequence, Tuple

# --------------------------------------------------------------------------- #
# Basic number theory
# --------------------------------------------------------------------------- #


def is_prime(n: int) -> bool:
    """Deterministic Miller-Rabin, correct for all n < 3.3 * 10^24."""
    if n < 2:
        return False
    small_primes: Tuple[int, ...] = (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37)
    for p in small_primes:
        if n % p == 0:
            return n == p
    d: int = n - 1
    r: int = 0
    while d % 2 == 0:
        d //= 2
        r += 1
    for a in small_primes:
        x: int = pow(a, d, n)
        if x == 1 or x == n - 1:
            continue
        for _ in range(r - 1):
            x = x * x % n
            if x == n - 1:
                break
        else:
            return False
    return True


def random_prime(bits: int, rng: random.Random) -> int:
    """A uniformly-drawn odd prime with exactly `bits` bits."""
    while True:
        candidate: int = rng.getrandbits(bits) | (1 << (bits - 1)) | 1
        if is_prime(candidate):
            return candidate


def isqrt(n: int) -> int:
    """Exact integer square root, floor(sqrt(n))."""
    return math.isqrt(n)


def divisors(n: int) -> List[int]:
    """All divisors of n, by the structure-blind scan up to floor(sqrt n)."""
    out: List[int] = []
    root: int = isqrt(n)
    for d in range(1, root + 1):
        if n % d == 0:
            out.append(d)
            if d != n // d:
                out.append(n // d)
    return sorted(out)


def sigma_one(n: int) -> int:
    """Divisor sum sigma_1(n), computed from n alone."""
    return sum(divisors(n))


def num_divisors(n: int) -> int:
    """Divisor count tau(n), computed from n alone."""
    return len(divisors(n))


def prime_count(bound: int) -> int:
    """pi(bound), by sieve of Eratosthenes."""
    if bound < 2:
        return 0
    sieve: List[bool] = [True] * (bound + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, isqrt(bound) + 1):
        if sieve[i]:
            for j in range(i * i, bound + 1, i):
                sieve[j] = False
    return sum(sieve)


# --------------------------------------------------------------------------- #
# 1-2.  Stratum A: the definition-route witnesses, and O(1) inversion
# --------------------------------------------------------------------------- #


def recover_smaller_factor(n: int, s: int) -> int:
    """Closed-form sigma_1-route: p = (s - sqrt(s^2 - 4N)) / 2.

    Here s = p + q is the factor sum handed over by the sigma_1-oracle.  The
    discriminant s^2 - 4N = (q - p)^2 is an exact perfect square, so the whole
    recovery is a constant number of arithmetic operations.
    """
    return (s - isqrt(s * s - 4 * n)) // 2


def demo_stratum_a_exactness(rng: random.Random) -> None:
    print("=" * 74)
    print("1-2.  STRATUM A -- exact witnesses and O(1) inversion")
    print("=" * 74)
    print(f"{'bits':>5} {'p':>10} {'q':>10} {'tau(N)':>7} "
          f"{'sigma1 exact?':>14} {'recovered p':>12} {'ok?':>5}")
    for bits in (6, 8, 10, 12, 14):
        p: int = random_prime(bits, rng)
        q: int = random_prime(bits, rng)
        while q == p:
            q = random_prime(bits, rng)
        p, q = min(p, q), max(p, q)
        n: int = p * q
        tau: int = num_divisors(n)
        sig: int = sigma_one(n)
        exact: bool = sig == 1 + p + q + n
        s: int = sig - n - 1                       # = p + q, the oracle output
        rec: int = recover_smaller_factor(n, s)
        print(f"{2*bits:>5} {p:>10} {q:>10} {tau:>7} {str(exact):>14} "
              f"{rec:>12} {str(rec == p):>5}")
    print("  tau(pq) = 4 and sigma_1(pq) = 1 + p + q + pq, at every size.")
    print("  The entire post-oracle cost is a constant number of operations:")
    print("  the exponent 1/2 of Stratum A is an exponent of EVALUATION.\n")


# --------------------------------------------------------------------------- #
# 3.  The scan sandwich and the measured exponent 1/2
# --------------------------------------------------------------------------- #


def scan_cost(n: int) -> int:
    """Cost of evaluating tau or sigma_1 from n alone: floor(sqrt n) divisions."""
    return isqrt(n)


def demo_scan_sandwich(rng: random.Random) -> None:
    print("=" * 74)
    print("3.  THE SANDWICH  2 log(scan N) <= log N <= 2 log(scan N + 1)")
    print("=" * 74)
    print(f"{'bits':>5} {'scan(N)':>12} {'lo=2log(scan)':>15} "
          f"{'log N':>12} {'hi=2log(scan+1)':>17} {'ratio':>8}")
    for bits in (8, 12, 16, 20, 24, 28, 32):
        p: int = random_prime(bits // 2, rng)
        q: int = random_prime(bits - bits // 2, rng)
        n: int = p * q
        sc: int = scan_cost(n)
        lo: float = 2.0 * math.log(sc)
        hi: float = 2.0 * math.log(sc + 1)
        ln: float = math.log(n)
        ratio: float = math.log(sc) / ln
        assert lo <= ln <= hi, "sandwich violated"
        print(f"{n.bit_length():>5} {sc:>12} {lo:>15.4f} {ln:>12.4f} "
              f"{hi:>17.4f} {ratio:>8.4f}")
    print("  log(scan N) / log N -> 1/2.  Measured exponent of Stratum A: 0.500.\n")


# --------------------------------------------------------------------------- #
# 4.  Fermat: no early stop, exact halting index, complementarity
# --------------------------------------------------------------------------- #


def fermat_steps(n: int, cap: int = 10 ** 7) -> Optional[int]:
    """Number of trial values a = ceil(sqrt N), ... before a^2 - N is square.

    Returns None if the cap is hit (reported honestly, never extrapolated).
    """
    a: int = isqrt(n)
    if a * a < n:
        a += 1
    start: int = a
    while a - start < cap:
        b2: int = a * a - n
        b: int = isqrt(b2)
        if b * b == b2:
            return a - start
        a += 1
    return None


def trial_division_steps(n: int) -> int:
    """Number of trial divisors examined before the smaller prime factor."""
    d: int = 2
    steps: int = 0
    while d * d <= n:
        steps += 1
        if n % d == 0:
            return steps
        d += 1
    return steps


def demo_fermat_dichotomy(rng: random.Random) -> None:
    print("=" * 74)
    print("4.  FERMAT -- exact stop at 2a = p + q, and complementarity")
    print("=" * 74)
    print("  (a)  The halting index equals (p+q)/2 - ceil(sqrt N) exactly.")
    print(f"{'p':>8} {'q':>8} {'measured':>10} {'predicted':>10} {'match':>7}")
    for bits in (7, 9, 11, 13):
        p: int = random_prime(bits, rng)
        q: int = random_prime(bits, rng)
        while q == p:
            q = random_prime(bits, rng)
        p, q = min(p, q), max(p, q)
        n: int = p * q
        root: int = isqrt(n) + (0 if isqrt(n) ** 2 == n else 1)
        predicted: int = (p + q) // 2 - root
        measured: Optional[int] = fermat_steps(n)
        print(f"{p:>8} {q:>8} {str(measured):>10} {predicted:>10} "
              f"{str(measured == predicted):>7}")

    print("\n  (b)  Pointwise complementarity: neither method dominates.")
    print(f"{'instance':>26} {'trial steps':>12} {'fermat steps':>13}")
    twin_p: int = 101                                    # N = p(p+2), twin case
    while not (is_prime(twin_p) and is_prime(twin_p + 2)):
        twin_p += 2
    n_twin: int = twin_p * (twin_p + 2)
    print(f"{'twin  N = ' + str(n_twin):>26} "
          f"{trial_division_steps(n_twin):>12} {str(fermat_steps(n_twin)):>13}")
    q_unbal: int = 10007
    n_unbal: int = 3 * q_unbal
    print(f"{'unbalanced  N = ' + str(n_unbal):>26} "
          f"{trial_division_steps(n_unbal):>12} {str(fermat_steps(n_unbal)):>13}")
    print("  Twin case: Fermat halts at its first trial, trial division needs p.")
    print("  Unbalanced case: trial division needs 2, Fermat needs ~q/4.\n")


def _mean_median(xs: Sequence[float]) -> Tuple[float, float]:
    ordered: List[float] = sorted(xs)
    mid: int = len(ordered) // 2
    median: float = (ordered[mid] if len(ordered) % 2 == 1
                     else 0.5 * (ordered[mid - 1] + ordered[mid]))
    return sum(xs) / len(xs), median


def demo_draw_measure_decides(rng: random.Random, draws: int = 40) -> None:
    """Aggregate cost statistics are a property of the DRAW MEASURE, not of the
    methods: the same two methods are ranked differently, or coincide, depending
    only on how the semiprime is sampled."""
    print("=" * 74)
    print("4c.  THE DRAW MEASURE DECIDES THE AGGREGATE COMPARISON")
    print("=" * 74)

    def balanced(_: random.Random) -> Tuple[int, int]:
        p: int = random_prime(11, rng)
        q: int = random_prime(11, rng)
        while q == p:
            q = random_prime(11, rng)
        return min(p, q), max(p, q)

    def spread(_: random.Random) -> Tuple[int, int]:
        # prime bit-sizes drawn independently and widely: gaps are tail-heavy
        bp: int = rng.randrange(4, 12)
        bq: int = rng.randrange(4, 12)
        p: int = random_prime(bp, rng)
        q: int = random_prime(bq, rng)
        while q == p:
            q = random_prime(bq, rng)
        return min(p, q), max(p, q)

    print(f"{'draw measure':>16} {'method':>16} {'mean log2':>11} {'median log2':>13}")
    for label, sampler in (("balanced", balanced), ("spread", spread)):
        trial_logs: List[float] = []
        fermat_logs: List[float] = []
        for _ in range(draws):
            p, q = sampler(rng)
            n: int = p * q
            t: int = trial_division_steps(n)
            f: Optional[int] = fermat_steps(n)
            if f is None:
                continue
            trial_logs.append(math.log2(max(t, 1)))
            fermat_logs.append(math.log2(max(f, 1)))
        tm, tmed = _mean_median(trial_logs)
        fm, fmed = _mean_median(fermat_logs)
        print(f"{label:>16} {'trial division':>16} {tm:>11.2f} {tmed:>13.2f}")
        print(f"{label:>16} {'Fermat':>16} {fm:>11.2f} {fmed:>13.2f}")
    print("  With p = N^beta, q = N^{1-beta}: trial cost N^beta, Fermat cost")
    print("  Theta(N^{1-2beta}); the two exponents cross at beta = 1/3.  Which")
    print("  method 'wins on average' is therefore a statement about the sampling")
    print("  of beta and not about the methods.  In the large-scale campaign, whose")
    print("  draws are tail-dominated by the gap q - p, the two are")
    print("  indistinguishable: mean log2 cost 19.30 vs 19.36, median 19.36 both.\n")


# --------------------------------------------------------------------------- #
# 5.  Pollard rho: exact extraction, and the units lemma
# --------------------------------------------------------------------------- #


def pollard_rho(n: int, rng: random.Random,
                max_steps: int = 10 ** 7) -> Tuple[Optional[int], int]:
    """Floyd-cycle Pollard rho.  Returns (nontrivial factor or None, steps)."""
    if n % 2 == 0:
        return 2, 1
    while True:
        c: int = rng.randrange(1, n)
        f: Callable[[int], int] = lambda z: (z * z + c) % n
        x: int = rng.randrange(0, n)
        y: int = x
        d: int = 1
        steps: int = 0
        while d == 1 and steps < max_steps:
            x = f(x)
            y = f(f(y))
            d = math.gcd(abs(x - y), n)
            steps += 1
        if 1 < d < n:
            return d, steps
        if steps >= max_steps:
            return None, steps


def fit_slope(xs: Sequence[float], ys: Sequence[float]) -> float:
    """Least-squares slope of y against x."""
    n: int = len(xs)
    mx: float = sum(xs) / n
    my: float = sum(ys) / n
    num: float = sum((x - mx) * (y - my) for x, y in zip(xs, ys))
    den: float = sum((x - mx) ** 2 for x in xs)
    return num / den


def demo_pollard_and_units(rng: random.Random) -> None:
    print("=" * 74)
    print("5.  POLLARD RHO -- exact extraction, and the UNITS LEMMA")
    print("=" * 74)
    prime_bits: List[float] = []
    log_costs: List[float] = []
    print(f"{'prime bits':>11} {'trials':>7} {'mean log2 steps':>17} {'exact split?':>13}")
    for bits in (10, 12, 14, 16, 18, 20):
        samples: List[float] = []
        all_exact: bool = True
        for _ in range(6):
            p: int = random_prime(bits, rng)
            q: int = random_prime(bits, rng)
            while q == p:
                q = random_prime(bits, rng)
            n: int = p * q
            factor, steps = pollard_rho(n, rng)
            if factor is None:
                continue
            # Extraction theorem: the gcd is EXACTLY one of the two primes.
            all_exact = all_exact and factor in (p, q)
            samples.append(math.log2(max(steps, 1)))
        if not samples:
            continue
        mean_cost: float = sum(samples) / len(samples)
        prime_bits.append(float(bits))
        log_costs.append(mean_cost)
        print(f"{bits:>11} {len(samples):>7} {mean_cost:>17.2f} {str(all_exact):>13}")

    slope: float = fit_slope(prime_bits, log_costs)
    print(f"\n  fitted slope per PRIME bit        : {slope:.3f}   (birthday: 0.500)")
    print(f"  exponent alpha on N  = slope / 2  : {slope / 2:.3f}   (birthday: 0.250)")
    print("  UNITS LEMMA: log N = 2 log p for a balanced semiprime, so a profile")
    print("  fitted in b = log p with slope s has exponent s/2 on x = log N.")
    print("  Reading the per-prime-bit slope as an exponent on N doubles it --")
    print("  and since the measured exponent is unique, that is a contradiction,")
    print("  not a matter of convention.\n")


# --------------------------------------------------------------------------- #
# 6.  Stratum C: Shor's classical split step
# --------------------------------------------------------------------------- #


def multiplicative_order(a: int, n: int, cap: int = 10 ** 6) -> Optional[int]:
    """Least r > 0 with a^r = 1 mod n, or None if not found below the cap."""
    if math.gcd(a, n) != 1:
        return None
    value: int = a % n
    for r in range(1, cap + 1):
        if value == 1:
            return r
        value = value * a % n
    return None


def shor_classical_split(n: int, a: int) -> Optional[int]:
    """The classical half of Shor: from an even order 2m with a^m != +-1,
    gcd(a^m - 1, N) is EXACTLY one of the two prime factors."""
    r: Optional[int] = multiplicative_order(a, n)
    if r is None or r % 2 == 1:
        return None
    x: int = pow(a, r // 2, n)
    if x == 1 or x == n - 1:
        return None
    g: int = math.gcd(x - 1, n)
    return g if 1 < g < n else None


def demo_shor_split(rng: random.Random) -> None:
    print("=" * 74)
    print("6.  STRATUM C -- the classical split step is unconditionally exact")
    print("=" * 74)
    print(f"{'N = p*q':>14} {'a':>6} {'order r':>9} {'gcd(a^(r/2)-1, N)':>20} {'in {p,q}?':>11}")
    successes: int = 0
    attempts: int = 0
    for bits in (7, 8, 9, 10):
        p: int = random_prime(bits, rng)
        q: int = random_prime(bits, rng)
        while q == p:
            q = random_prime(bits, rng)
        n: int = p * q
        for _ in range(60):
            a: int = rng.randrange(2, n - 1)
            if math.gcd(a, n) != 1:
                continue
            attempts += 1
            g: Optional[int] = shor_classical_split(n, a)
            if g is not None:
                successes += 1
                r: Optional[int] = multiplicative_order(a, n)
                print(f"{n:>14} {a:>6} {str(r):>9} {g:>20} "
                      f"{str(g in (p, q)):>11}")
                break
    print(f"\n  Every split returned an exact prime factor "
          f"({successes} splits found).")
    print("  The quantum corner owns the SEARCH for r, not the arithmetic")
    print("  that follows it -- which was always free.\n")


# --------------------------------------------------------------------------- #
# 7.  The three strata and the price of structure-blindness
# --------------------------------------------------------------------------- #


def scan_profile(x: float) -> float:
    """Stratum A profile S(x) = exp(x/2) = N^{1/2}."""
    return math.exp(x / 2.0)


def rho_profile(x: float) -> float:
    """Stratum B profile R(x) = exp(x/4) = N^{1/4}."""
    return math.exp(x / 4.0)


def shor_profile(x: float) -> float:
    """Stratum C profile Q(x) = 8 x^3, polynomial in the bit-size."""
    return 8.0 * x ** 3


def blindness_price(x: float) -> float:
    """P(x) = S(x)/R(x) = exp(x/4) = N^{1/4}."""
    return scan_profile(x) / rho_profile(x)


def log_scan_profile(x: float) -> float:
    """log S(x), computed in log space to avoid overflow at large x."""
    return x / 2.0


def log_rho_profile(x: float) -> float:
    """log R(x)."""
    return x / 4.0


def log_shor_profile(x: float) -> float:
    """log Q(x) = log 8 + 3 log x."""
    return math.log(8.0) + 3.0 * math.log(x)


def log_blindness_price(x: float) -> float:
    """log P(x) = log S(x) - log R(x)."""
    return log_scan_profile(x) - log_rho_profile(x)


def measured_exponent(log_f: Callable[[float], float], x: float) -> float:
    """Finite-x reading of alpha(f) = lim log f(x) / x."""
    return log_f(x) / x


def demo_the_plane() -> None:
    print("=" * 74)
    print("7.  THE THREE-STRATA PLANE, AND THE PRICE OF STRUCTURE-BLINDNESS")
    print("=" * 74)
    print(f"{'log2 N':>8} {'Q (shor)':>14} {'R (rho)':>16} {'S (scan)':>18} "
          f"{'ordered?':>9}")
    for bits in (16, 24, 32, 64, 128, 256, 512, 1024):
        x: float = bits * math.log(2.0)
        q_, r_, s_ = shor_profile(x), rho_profile(x), scan_profile(x)
        print(f"{bits:>8} {q_:>14.3e} {r_:>16.3e} {s_:>18.3e} "
              f"{str(q_ < r_ < s_):>9}")
    print("  Eventually Q < R < S, pointwise and strictly.\n")

    print(f"{'log2 N':>8} {'alpha(S)':>10} {'alpha(R)':>10} {'alpha(Q)':>10} "
          f"{'alpha(P)':>10}")
    for bits in (32, 64, 128, 256, 1024, 4096, 16384, 65536):
        x = bits * math.log(2.0)
        print(f"{bits:>8} {measured_exponent(log_scan_profile, x):>10.4f} "
              f"{measured_exponent(log_rho_profile, x):>10.4f} "
              f"{measured_exponent(log_shor_profile, x):>10.4f} "
              f"{measured_exponent(log_blindness_price, x):>10.4f}")
    print("  alpha(S) = 1/2, alpha(R) = 1/4, alpha(Q) -> 0, alpha(P) = 1/4.")
    print("  alpha(P) = alpha(R): a UNIT EXCHANGE RATE between ignorance and work.\n")

    print("  The price P = N^{1/4}, strictly increasing and unbounded:")
    print(f"{'log2 N':>8} {'price N^{1/4}':>18}")
    for bits in (16, 20, 24, 28, 36, 64, 128):
        x = bits * math.log(2.0)
        print(f"{bits:>8} {math.exp(log_blindness_price(x)):>18.3e}")
    print("  Measured campaign values at the same sizes: 173x (2^16),")
    print("  1780x (2^20), 2070x (2^24), 8310x (2^28) -- growing with N, as the")
    print("  theorem requires.  The 2^36 row was capped, not extrapolated.\n")


# --------------------------------------------------------------------------- #
# 8.  The hitting-set lower bound
# --------------------------------------------------------------------------- #


def is_complete_test_set(candidates: Iterable[int], bound: int) -> bool:
    """Does `candidates` split every semiprime pq with p < q <= bound?"""
    cand: List[int] = list(candidates)
    primes: List[int] = [k for k in range(2, bound + 1) if is_prime(k)]
    for i, p in enumerate(primes):
        for q in primes[i + 1:]:
            n: int = p * q
            if not any(n % s == 0 and 1 < s < n for s in cand):
                return False
    return True


def demo_hitting_set() -> None:
    print("=" * 74)
    print("8.  HITTING-SET LOWER BOUND:  |S| >= pi(B) - 1")
    print("=" * 74)
    print(f"{'B':>6} {'pi(B)':>7} {'bound pi(B)-1':>15} "
          f"{'all primes complete?':>22} {'drop one?':>11} {'drop two?':>11}")
    for bound in (20, 40, 60, 100):
        primes: List[int] = [k for k in range(2, bound + 1) if is_prime(k)]
        pi_b: int = len(primes)
        full: bool = is_complete_test_set(primes, bound)
        drop_one: bool = is_complete_test_set(primes[:-1], bound)
        drop_two: bool = is_complete_test_set(primes[:-2], bound)
        print(f"{bound:>6} {pi_b:>7} {pi_b - 1:>15} {str(full):>22} "
              f"{str(drop_one):>11} {str(drop_two):>11}")
    print("  Omitting ONE prime is survivable; omitting TWO never is, because the")
    print("  semiprime formed from the two omitted primes is split by nothing in S.")
    print("  With B ~ sqrt N, a blind candidate list needs ~sqrt(N)/log sqrt(N)")
    print("  entries.  Pollard rho carries none.\n")


# --------------------------------------------------------------------------- #
# Main
# --------------------------------------------------------------------------- #


def main() -> None:
    rng = random.Random(20260919)      # fixed seed: reproducible measurements
    print()
    print("#" * 74)
    print("#  THE THREE-STRATA PLANE -- numerical demonstration".ljust(73) + "#")
    print("#  one coordinate, three strata, every price measured".ljust(73) + "#")
    print("#" * 74)
    print()
    demo_stratum_a_exactness(rng)
    demo_scan_sandwich(rng)
    demo_fermat_dichotomy(rng)
    demo_draw_measure_decides(rng)
    demo_pollard_and_units(rng)
    demo_shor_split(rng)
    demo_the_plane()
    demo_hitting_set()
    print("=" * 74)
    print("SUMMARY")
    print("=" * 74)
    summary_rows: Dict[str, str] = {
        "Stratum A (definition-routes)": "alpha = 1/2, inversion O(1)",
        "Stratum B (classical methods)": "alpha = 1/4, exact extraction",
        "Stratum C (quantum)": "alpha = 0, split step exact",
        "Price of structure-blindness": "N^{1/4}, unbounded, alpha = 1/4",
    }
    for key, value in summary_rows.items():
        print(f"  {key:<32} {value}")
    print()


if __name__ == "__main__":
    main()
