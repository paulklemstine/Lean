"""
demo.py — The divisibility-mixture baseline for quadratic sieve values.

Numerical demonstration of every result in the accompanying paper:

  1.  Root counts of x^2 = a mod m, and mean preservation  sum_a X_m(a) = m,
      for prime, prime-power and composite moduli.
  2.  The exact over-dispersion identity  sum_a (X_p(a) - 1)^2 = p - 1
      for odd primes.
  3.  The exact functional identity
          sum_a g(X_p(a)) = g(1) + (p-1)(g(2) + g(0))/2,
      and its multiplicative specialisation
          sum_a c^{X_p(a)} = p c + (p-1)(c-1)^2 / 2.
  4.  The convexity (Jensen) mechanism:  m G(1) <= sum_a G(X_m(a))
      for convex G, strictly for m >= 3 and strictly convex G.
  5.  The no-single-carrier bound:  each prime's share of the total
      log-amplitude is at most 3/(2k).
  6.  The Dickman two-point hump  H(u, d) = (1/2) log(1 + d^2/(4u(u-d))),
      its strict monotonicity in d, and its exact closed-form inversion
      d(u, A) = 2u( sqrt(s^2+s) - s ),  s = exp(2A) - 1.
  7.  Amplitude tomography:  A/X <= k <= (3/2) A / log(1+X).
  8.  A direct sieve experiment on v = j^2 - N showing that small primes
      divide v at rate 2/q or 0 -- never the naive 1/q -- while the
      average over N is exactly 1/q.

Self-contained: standard library only.  Run with `python3 demo.py`.
"""

from __future__ import annotations

import math
import random
from typing import Callable, Dict, List, Sequence, Tuple

# ----------------------------------------------------------------------------
# 1. Root counts and mean preservation
# ----------------------------------------------------------------------------


def root_counts(m: int) -> List[int]:
    """X_m(a) = #{x mod m : x^2 = a} for every target a in Z/m."""
    counts = [0] * m
    for x in range(m):
        counts[(x * x) % m] += 1
    return counts


def mean_preservation_check(m: int) -> Tuple[int, int]:
    """Return (sum of root counts, m).  The theorem says they are equal."""
    return sum(root_counts(m)), m


def over_dispersion(p: int) -> int:
    """sum_a (X_p(a) - 1)^2 ; equals p - 1 for every odd prime p."""
    return sum((c - 1) ** 2 for c in root_counts(p))


# ----------------------------------------------------------------------------
# 2. Exact functional / generating identities
# ----------------------------------------------------------------------------


def functional_sum_bruteforce(p: int, g: Callable[[int], float]) -> float:
    """sum_a g(X_p(a)) by direct enumeration."""
    return sum(g(c) for c in root_counts(p))


def functional_sum_formula(p: int, g: Callable[[int], float]) -> float:
    """g(1) + (p-1)(g(2)+g(0))/2 -- the exact functional identity."""
    return g(1) + (p - 1) * (g(2) + g(0)) / 2.0


def generating_sum_formula(p: int, c: float) -> float:
    """p c + (p-1)(c-1)^2/2 -- naive baseline plus mixture excess."""
    return p * c + (p - 1) * (c - 1) ** 2 / 2.0


def excess_ratio(q: int, c: float) -> float:
    """E_q(c) = 1 + (1 - 1/q) (c-1)^2 / (2c)."""
    return 1.0 + (1.0 - 1.0 / q) * shape_factor(c)


def shape_factor(c: float) -> float:
    """X = (c-1)^2 / (2c), the prime-independent shape of the excess."""
    return (c - 1.0) ** 2 / (2.0 * c)


def log_excess(q: int, c: float) -> float:
    """Per-prime contribution to the hump log-amplitude."""
    return math.log(excess_ratio(q, c))


def hump_log_amplitude(primes: Sequence[int], c: float) -> float:
    """A = sum_q log E_q(c)."""
    return sum(log_excess(q, c) for q in primes)


# ----------------------------------------------------------------------------
# 3. Convexity mechanism
# ----------------------------------------------------------------------------


def jensen_gap(m: int, G: Callable[[float], float]) -> float:
    """sum_a G(X_m(a)) - m G(1) ; nonnegative for convex G, positive for m>=3
    and strictly convex G."""
    return sum(G(float(c)) for c in root_counts(m)) - m * G(1.0)


# ----------------------------------------------------------------------------
# 4. Dickman branch, hump, calibration
# ----------------------------------------------------------------------------


def rho1(u: float) -> float:
    """First Dickman branch rho(u) = 1 - log u, valid on [1, 2]."""
    return 1.0 - math.log(u)


def hump_amp_definition(u: float, delta: float) -> float:
    """(rho(u) + rho(u-d))/2 - rho(u - d/2), computed from the definition."""
    return (rho1(u) + rho1(u - delta)) / 2.0 - rho1(u - delta / 2.0)


def hump_amp_closed_form(u: float, delta: float) -> float:
    """(1/2) log(1 + d^2 / (4 u (u - d)))."""
    return 0.5 * math.log(1.0 + delta ** 2 / (4.0 * u * (u - delta)))


def calibrated_spread(u: float, A: float) -> float:
    """Exact inverse: the spread reproducing a measured amplitude A."""
    s = math.exp(2.0 * A) - 1.0
    return 2.0 * u * (math.sqrt(s * s + s) - s)


def carrier_count_bracket(A: float, c: float) -> Tuple[float, float]:
    """A/X <= k <= (3/2) A / log(1+X) with X = (c-1)^2/(2c)."""
    X = shape_factor(c)
    return A / X, 1.5 * A / math.log(1.0 + X)


# ----------------------------------------------------------------------------
# 5. A direct sieve experiment
# ----------------------------------------------------------------------------


def sieve_divisibility_rate(N: int, q: int, window: int) -> float:
    """Observed density of q | (j^2 - N) for j in a window above sqrt(N)."""
    j0 = math.isqrt(N) + 1
    hits = sum(1 for j in range(j0, j0 + window) if (j * j - N) % q == 0)
    return hits / window


def legendre_root_count(N: int, q: int) -> int:
    """Predicted X_q(N) = number of solutions of j^2 = N mod q."""
    return sum(1 for x in range(q) if (x * x - N) % q == 0)


# ----------------------------------------------------------------------------
# Reporting
# ----------------------------------------------------------------------------


def section(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


def demo_mean_preservation() -> None:
    section("1.  Mean preservation:  sum_a X_m(a) = m  at EVERY modulus")
    print(f"{'m':>6} {'sum X_m(a)':>12} {'m':>6} {'distribution of X_m':>34}")
    for m in [3, 5, 7, 8, 9, 11, 12, 13, 15, 16, 25, 27, 30, 49]:
        counts = root_counts(m)
        total = sum(counts)
        hist: Dict[int, int] = {}
        for v in counts:
            hist[v] = hist.get(v, 0) + 1
        shape = ", ".join(f"{k}:{hist[k]}" for k in sorted(hist))
        flag = "OK" if total == m else "FAIL"
        print(f"{m:>6} {total:>12} {m:>6} {shape:>34}   {flag}")
    print("\nPrimality is never used: this is pure fibre counting for x -> x^2.")


def demo_over_dispersion() -> None:
    section("2.  Exact over-dispersion:  sum_a (X_p(a)-1)^2 = p - 1  (odd primes)")
    print(f"{'p':>6} {'observed':>10} {'p-1':>10}")
    for p in [3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 97, 101]:
        print(f"{p:>6} {over_dispersion(p):>10} {p - 1:>10}")
    print("\nFor a mean-one count in {0,1,2} this is the extreme of over-dispersion:")
    print("every target except a = 0 sits at an endpoint (0 or 2).")


def demo_functional_identity() -> None:
    section("3.  Exact functional and generating identities")
    tests: List[Tuple[str, Callable[[int], float]]] = [
        ("g(x) = x", lambda x: float(x)),
        ("g(x) = x^2", lambda x: float(x * x)),
        ("g(x) = (3/2)^x", lambda x: 1.5 ** x),
        ("g(x) = exp(x/3)", lambda x: math.exp(x / 3.0)),
    ]
    print(f"{'p':>5} {'functional':>16} {'brute force':>16} {'formula':>16} {'diff':>10}")
    for p in [7, 11, 13, 29]:
        for name, g in tests:
            bf = functional_sum_bruteforce(p, g)
            fm = functional_sum_formula(p, g)
            print(f"{p:>5} {name:>16} {bf:>16.9f} {fm:>16.9f} {abs(bf - fm):>10.2e}")

    print("\nMultiplicative proxy: sum_a c^X = p c  +  (p-1)(c-1)^2/2")
    print(f"{'p':>5} {'c':>6} {'brute force':>16} {'baseline p c':>14} {'excess':>12}")
    for p in [7, 13, 31]:
        for c in [1.2, 1.5, 2.0]:
            bf = functional_sum_bruteforce(p, lambda x: c ** x)
            base = p * c
            print(f"{p:>5} {c:>6.2f} {bf:>16.9f} {base:>14.6f} {bf - base:>12.6f}"
                  f"   (formula excess {(p-1)*(c-1)**2/2:.6f})")
    print("\nThe excess is QUADRATIC in c-1: a variance effect, not a mean shift.")


def demo_convexity() -> None:
    section("4.  The convexity mechanism:  m G(1) <= sum_a G(X_m(a))")
    convex_funcs: List[Tuple[str, Callable[[float], float]]] = [
        ("G(x) = x^2", lambda x: x * x),
        ("G(x) = exp(x)", math.exp),
        ("G(x) = 1.5^x", lambda x: 1.5 ** x),
        ("G(x) = x^4", lambda x: x ** 4),
        ("G(x) = |x-1|", lambda x: abs(x - 1.0)),  # convex, not strictly
    ]
    print(f"{'m':>5} {'G':>14} {'sum G(X) - m G(1)':>20}")
    for m in [3, 4, 8, 9, 12, 15, 25, 27]:
        for name, G in convex_funcs:
            print(f"{m:>5} {name:>14} {jensen_gap(m, G):>20.9f}")
    print("\nAll gaps are >= 0 (Jensen), and > 0 for the strictly convex G at m >= 3.")
    print("Only mean preservation and non-constancy of the root count are used.")


def demo_no_single_carrier() -> None:
    section("5.  No single carrier:  each prime's share is at most 3/(2k)")
    for primes, c in [([3, 5, 7], 1.5), ([3, 5, 7, 11, 13], 1.5),
                      ([3, 5, 7, 11, 13, 17, 19], 1.3)]:
        k = len(primes)
        A = hump_log_amplitude(primes, c)
        print(f"\nprimes {primes},  weight c = {c},  X = {shape_factor(c):.6f}")
        print(f"total log-amplitude A = {A:.6f},  guaranteed ceiling 3/(2k) ="
              f" {3/(2*k):.4f}")
        print(f"{'q':>5} {'log E_q':>12} {'share':>10} {'<= 3/(2k)?':>12}")
        for q in primes:
            l = log_excess(q, c)
            share = l / A
            print(f"{q:>5} {l:>12.6f} {share:>9.2%} {str(share <= 3/(2*k)):>12}")
        best = max(log_excess(q, c) for q in primes) / A
        print(f"best possible single-covariate removal: {best:.2%} "
              f"(registered win bar: 60%)  ->  "
              f"{'UNREACHABLE' if best < 0.60 else 'reachable'}")
        lo, hi = carrier_count_bracket(A, c)
        print(f"tomography bracket: {lo:.3f} <= k <= {hi:.3f}   (true k = {k})")


def demo_dickman_hump() -> None:
    section("6.  The Dickman two-point hump and its exact calibration")
    print("Closed form  H(u,d) = (1/2) log(1 + d^2/(4u(u-d)))  vs. the definition:")
    print(f"{'u':>6} {'delta':>8} {'definition':>14} {'closed form':>14} {'diff':>10}")
    for u in [1.2, 1.6, 2.0, 3.0]:
        for frac in [0.0, 0.1, 0.3, 0.5, 0.8]:
            d = frac * u
            a1 = hump_amp_definition(u, d)
            a2 = hump_amp_closed_form(u, d)
            print(f"{u:>6.2f} {d:>8.4f} {a1:>14.10f} {a2:>14.10f} {abs(a1-a2):>10.2e}")

    print("\nStrict monotonicity in the spread (u = 2):")
    prev = -1.0
    for frac in [0.0, 0.05, 0.1, 0.2, 0.4, 0.6, 0.8, 0.95]:
        val = hump_amp_closed_form(2.0, frac * 2.0) if frac > 0 else 0.0
        assert val > prev or frac == 0.0
        print(f"   delta/u = {frac:>5.2f}   H = {val:.8f}"
              f"   {'increasing' if val > prev else ''}")
        prev = val

    print("\nExact inversion  d(u,A) = 2u(sqrt(s^2+s) - s),  s = exp(2A)-1:")
    print(f"{'u':>6} {'A':>10} {'delta':>12} {'delta/u':>10} {'H(u,delta)':>14} {'diff':>10}")
    for u in [1.5, 2.0, 4.0, 10.0]:
        for A in [0.02, 0.1163, 0.3, 1.0]:
            d = calibrated_spread(u, A)
            back = hump_amp_closed_form(u, d)
            print(f"{u:>6.2f} {A:>10.4f} {d:>12.6f} {d/u:>10.6f} {back:>14.10f}"
                  f" {abs(back - A):>10.2e}")
    print("\nNote the delta/u column: identical down the rows for fixed A.")
    print("The calibration is scale free.")

    A_measured, A_err = 0.1163, 0.0360
    print(f"\nMeasured amplitude A = {A_measured} +/- {A_err} (z = 3.23):")
    for u in [1.5, 2.0, 2.5]:
        d = calibrated_spread(u, A_measured)
        dlo = calibrated_spread(u, max(A_measured - A_err, 1e-9))
        dhi = calibrated_spread(u, A_measured + A_err)
        print(f"   u = {u:.2f}:  delta = {d:.5f}  (1-sigma band "
              f"[{dlo:.5f}, {dhi:.5f}]),  delta/u = {d/u:.5f}")
    print("Control amplitude 0.0269 +/- 0.0109 gives, for comparison, "
          f"delta/u = {calibrated_spread(1.0, 0.0269):.5f}.")


def demo_sieve_experiment(seed: int = 20260826) -> None:
    section("7.  A direct sieve experiment on v = j^2 - N")
    rng = random.Random(seed)
    window = 20000
    print(f"window of {window} consecutive j above sqrt(N); "
          "naive baseline predicts density 1/q for every N")
    for q in [3, 5, 7, 11]:
        print(f"\n  small prime q = {q}   (naive 1/q = {1/q:.5f}, "
              f"true rate is X_q(N)/q in {{0, {2/q:.5f}}} or {1/q:.5f} if q | N)")
        rates: List[float] = []
        for _ in range(8):
            N = rng.randrange(10 ** 14, 10 ** 15) | 1
            observed = sieve_divisibility_rate(N, q, window)
            predicted = legendre_root_count(N, q) / q
            rates.append(observed)
            print(f"    N mod {q} = {N % q}:  X_q(N) = {legendre_root_count(N, q)}"
                  f"   predicted {predicted:.5f}   observed {observed:.5f}")
        print(f"    mean of observed rates over these N: {sum(rates)/len(rates):.5f}"
              f"  (population mean is exactly {1/q:.5f})")
    print("\nEvery individual N is off the naive rate; the AVERAGE is exactly on it.")
    print("That is mean preservation, and convexity turns it into a positive hump.")


def demo_mixture_vs_pointwise() -> None:
    section("8.  Mixture baseline vs. pointwise baseline: the hump, end to end")
    primes = [3, 5, 7, 11, 13, 17, 19, 23]
    c = 1.35
    A = hump_log_amplitude(primes, c)
    k = len(primes)
    u = 1.8
    d = calibrated_spread(u, A)
    lo, hi = carrier_count_bracket(A, c)
    print(f"mixture over {primes} with weight c = {c}")
    print(f"  shape factor X          = {shape_factor(c):.6f}")
    print(f"  total log-amplitude A   = {A:.6f}")
    print(f"  largest single share    = "
          f"{max(log_excess(q, c) for q in primes)/A:.2%}   (ceiling {3/(2*k):.2%})")
    print(f"  residual after removing the largest single covariate = "
          f"{(A - max(log_excess(q, c) for q in primes))/A:.2%} of A")
    print(f"  carrier-count bracket   = [{lo:.3f}, {hi:.3f}]   (true k = {k})")
    print(f"  calibrated spread at u = {u}: delta = {d:.6f}  (delta/u = {d/u:.6f})")
    print(f"  check: H(u, delta) = {hump_amp_closed_form(u, d):.10f}  vs A = {A:.10f}")


def main() -> None:
    print(__doc__)
    demo_mean_preservation()
    demo_over_dispersion()
    demo_functional_identity()
    demo_convexity()
    demo_no_single_carrier()
    demo_dickman_hump()
    demo_sieve_experiment()
    demo_mixture_vs_pointwise()
    section("Summary")
    print("mean preservation  ->  the naive rate is right on average;")
    print("over-dispersion    ->  and wrong for every individual N;")
    print("convexity          ->  so the true smoothness rate exceeds the baseline;")
    print("3/(2k) share bound ->  and no single divisibility flag can carry it;")
    print("closed-form hump   ->  while the amplitude measures the mixture spread.")


if __name__ == "__main__":
    main()
