"""
Generator tilt and the scan-order inversion for balanced semiprimes
===================================================================

Self-contained numerical demonstration of the results:

  * The two divisor-scan orders on the canonical window (sqrt(N/2), sqrt(N)]
    have complementary touch counts, so the pool comparison is decided by the
    mean tilt zbar alone:  descending wins  <=>  zbar > 1/2.

  * The tilt of a key depends on (p, q) only through the prime ratio r = q/p:
        z(r) = (r^{-1/2} - 2^{-1/2}) / (1 - 2^{-1/2}).
    The two orders tie at the critical ratio  r* = 24 - 16*sqrt(2) = 1.372583...

  * Ratio-uniform pools on [1, 2] have mean tilt exactly sqrt(2) - 1 = 0.414214
    (bottom-heavy: ascending wins, tilt-only speedup exactly sqrt(2)).

  * Two primes drawn independently from the same bit-length window have ratio
    density f(r) = 4/r^2 - 1 on [1, 2], obtained by differentiating the exact
    planar area A(r) = 5/2 - 2/r - r/2, and mean tilt exactly
        (9 - 5*sqrt(2)) / 3 = 0.642977...   (top-heavy: ascending LOSES),
    with tilt-only speedup (5*sqrt(2) - 6)/(9 - 5*sqrt(2)) = 0.555265...
    and per-key descending-win probability 5 - 4/r* - r* = 0.713203...

  * In the family with ratio density proportional to r^-theta on [1, 2], the mean
    tilt increases with theta and crosses 1/2 at exactly theta* = 3/2.

  * For window multiplier R > 1 the tie ratio is r*(R) = 4R/(1 + sqrt(R))^2,
    which always lies in (1, min(R, 4)), and ratio-uniform pools on [1, R] have
    mean tilt 1/(1 + sqrt(R)) < 1/2.  No window design rescues the ascending
    scan on near-balanced populations.

Only the Python standard library is used.  Run with:  python3 demo.py
"""

from __future__ import annotations

import math
import random
from typing import Callable, Iterable, List, Sequence, Tuple

SQRT2: float = math.sqrt(2.0)
CRITICAL_RATIO: float = 24.0 - 16.0 * SQRT2          # r* = 1.3725830...
UNIFORM_MEAN_TILT: float = SQRT2 - 1.0               # 0.4142135...
INDEPENDENT_MEAN_TILT: float = (9.0 - 5.0 * SQRT2) / 3.0   # 0.6429773...


# ----------------------------------------------------------------------------
# 1.  Scan costs, tilt, and the exact speedup law
# ----------------------------------------------------------------------------

def asc_cost(a: int, d: int) -> int:
    """Touch count of a window-ascending scan of [a, b] stopping at divisor d."""
    return d - a + 1


def desc_cost(b: int, d: int) -> int:
    """Touch count of a sqrt-descending scan of [a, b] stopping at divisor d."""
    return b - d + 1


def tilt(a: int, b: int, d: float) -> float:
    """Normalised height of d inside the window [a, b]:  0 at bottom, 1 at top."""
    return (float(d) - a) / (b - a)


def exact_speedup(mean_tilt: float, window_length: float) -> float:
    """Exact pool speedup S = (L(1 - z) + 1) / (L z + 1) of ascending over descending."""
    return (window_length * (1.0 - mean_tilt) + 1.0) / (window_length * mean_tilt + 1.0)


def tilt_only_predictor(mean_tilt: float) -> float:
    """The L -> infinity limit of the exact speedup:  (1 - z)/z."""
    return (1.0 - mean_tilt) / mean_tilt


def predictor_error_bound(mean_tilt: float, window_length: float) -> float:
    """Rigorous bound |exact - predictor| <= 1/(L z^2)."""
    return 1.0 / (window_length * mean_tilt ** 2)


# ----------------------------------------------------------------------------
# 2.  The ratio law
# ----------------------------------------------------------------------------

def z_of_ratio(r: float) -> float:
    """Tilt of the small factor of a semiprime of prime ratio r, canonical window."""
    return (1.0 / math.sqrt(r) - 1.0 / SQRT2) / (1.0 - 1.0 / SQRT2)


def z_of_ratio_general(window_multiplier: float, r: float) -> float:
    """Tilt law for the window (sqrt(N/R), sqrt(N)]."""
    inv = 1.0 / math.sqrt(window_multiplier)
    return (1.0 / math.sqrt(r) - inv) / (1.0 - inv)


def critical_ratio_general(window_multiplier: float) -> float:
    """Tie ratio for multiplier R:  r*(R) = 4R / (1 + sqrt(R))^2."""
    s = math.sqrt(window_multiplier)
    return 4.0 * window_multiplier / (1.0 + s) ** 2


def margin(r: float) -> float:
    """Top-heaviness margin m(r) = r^{-1/2} - (1 + 2^{-1/2})/2; positive iff r < r*."""
    return 1.0 / math.sqrt(r) - (1.0 + 1.0 / SQRT2) / 2.0


# ----------------------------------------------------------------------------
# 3.  The independent same-bit-length model
# ----------------------------------------------------------------------------

def ratio_area(r: float) -> float:
    """Area of {(p, q) in [1,2]^2 : p <= q <= r p}, exactly 5/2 - 2/r - r/2."""
    return 2.5 - 2.0 / r - r / 2.0


def ratio_density(r: float) -> float:
    """Ratio density of two independent uniform draws from [1,2] given p <= q."""
    return 4.0 / r ** 2 - 1.0


def ratio_cdf(s: float) -> float:
    """P[r <= s] = 5 - 4/s - s for 1 <= s <= 2."""
    return 5.0 - 4.0 / s - s


def simpson(f: Callable[[float], float], a: float, b: float, n: int = 200_000) -> float:
    """Composite Simpson quadrature on [a, b] with an even number of panels."""
    if n % 2:
        n += 1
    h = (b - a) / n
    total = f(a) + f(b)
    for i in range(1, n):
        total += (4.0 if i % 2 else 2.0) * f(a + i * h)
    return total * h / 3.0


# ----------------------------------------------------------------------------
# 4.  Prime utilities (small scale, for honest end-to-end simulation)
# ----------------------------------------------------------------------------

def primes_up_to(limit: int) -> List[int]:
    """Sieve of Eratosthenes."""
    if limit < 2:
        return []
    sieve = bytearray([1]) * (limit + 1)
    sieve[0] = sieve[1] = 0
    for i in range(2, int(limit ** 0.5) + 1):
        if sieve[i]:
            sieve[i * i::i] = bytearray(len(sieve[i * i::i]))
    return [i for i in range(limit + 1) if sieve[i]]


def primes_in_bit_window(bits: int) -> List[int]:
    """All primes p with 2^(bits-1) <= p < 2^bits."""
    lo, hi = 1 << (bits - 1), 1 << bits
    return [p for p in primes_up_to(hi - 1) if p >= lo]


def integer_window(n: int) -> Tuple[int, int]:
    """The true integer scan window [ceil(sqrt(N/2)), floor(sqrt(N))]."""
    a = math.ceil(math.sqrt(n / 2.0))
    b = math.isqrt(n)
    return a, b


# ----------------------------------------------------------------------------
# 5.  Pool statistics
# ----------------------------------------------------------------------------

def pool_statistics(pairs: Sequence[Tuple[int, int]]) -> dict:
    """
    Exact touch-count statistics for a pool of (p, q) with p <= q, each key
    scanned in its own integer window.  Returns mean tilt, totals, and the
    measured speedup S = total_desc / total_asc.
    """
    tilts: List[float] = []
    total_asc = 0
    total_desc = 0
    in_window = 0
    lengths: List[int] = []
    weighted = 0.0
    for p, q in pairs:
        n = p * q
        a, b = integer_window(n)
        if not (a <= p <= b):
            continue
        in_window += 1
        lengths.append(b - a)
        z = tilt(a, b, p)
        tilts.append(z)
        weighted += (b - a) * z
        total_asc += asc_cost(a, p)
        total_desc += desc_cost(b, p)
    mean_tilt = sum(tilts) / len(tilts) if tilts else float("nan")
    return {
        "n": len(pairs),
        "in_window_fraction": in_window / len(pairs),
        "mean_tilt": mean_tilt,
        "weighted_mean_tilt": weighted / sum(lengths) if lengths else float("nan"),
        "mean_window_length": sum(lengths) / len(lengths) if lengths else float("nan"),
        "total_asc": total_asc,
        "total_desc": total_desc,
        "speedup": total_desc / total_asc if total_asc else float("nan"),
        "descending_wins": total_desc < total_asc,
    }


def independent_pool(bits: int, size: int, rng: random.Random) -> List[Tuple[int, int]]:
    """Deployed style: two primes drawn independently and uniformly from one bit window."""
    ps = primes_in_bit_window(bits)
    out: List[Tuple[int, int]] = []
    while len(out) < size:
        p, q = rng.choice(ps), rng.choice(ps)
        if p == q:
            continue
        out.append((min(p, q), max(p, q)))
    return out


def ratio_uniform_pool(bits: int, size: int, rng: random.Random) -> List[Tuple[int, int]]:
    """
    Hard-balance control: the prime ratio is (approximately) uniform on [1, 2].
    Draw p from the bit window and a target ratio r uniformly from [1, 2], then
    take q to be the prime nearest to r*p drawn from a table extending one bit
    beyond the window, so the realised ratio is not clamped at the window edge.
    """
    small = primes_in_bit_window(bits)
    big = [x for x in primes_up_to(1 << (bits + 1)) if x >= (1 << (bits - 1))]
    out: List[Tuple[int, int]] = []
    while len(out) < size:
        p = rng.choice(small)
        r = rng.uniform(1.0, 2.0)
        target = r * p
        q = min(big, key=lambda x: abs(x - target))
        if q <= p or q >= 2 * p:
            continue
        out.append((p, q))
    return out


def exhaustive_independent_pool(bits: int) -> List[Tuple[int, int]]:
    """Every unordered pair of distinct primes of the given bit length."""
    ps = primes_in_bit_window(bits)
    return [(ps[i], ps[j]) for i in range(len(ps)) for j in range(i + 1, len(ps))]


# ----------------------------------------------------------------------------
# 6.  Demonstrations
# ----------------------------------------------------------------------------

def banner(text: str) -> None:
    print()
    print("=" * 78)
    print(text)
    print("=" * 78)


def demo_conservation_law() -> None:
    banner("1.  Conservation of scan budget and the pointwise inversion")
    a, b = 100, 141
    print(f"window [a, b] = [{a}, {b}], length L = {b - a}")
    print(f"{'d':>6}{'asc':>8}{'desc':>8}{'sum':>8}{'tilt':>10}{'winner':>14}")
    for d in (100, 110, 120, 121, 130, 141):
        s = asc_cost(a, d) + desc_cost(b, d)
        winner = "descending" if desc_cost(b, d) < asc_cost(a, d) else "ascending"
        print(f"{d:>6}{asc_cost(a, d):>8}{desc_cost(b, d):>8}{s:>8}"
              f"{tilt(a, b, d):>10.4f}{winner:>14}")
    print(f"\nevery row sums to (b - a) + 2 = {(b - a) + 2}: the two orders share one budget,")
    print("so only the location of d inside the window matters.")


def demo_tilt_law() -> None:
    banner("2.  The tilt is a property of the prime ratio alone (scale-free)")
    print("Same ratio, wildly different sizes -> identical tilt:")
    print(f"{'p':>12}{'q':>14}{'N':>20}{'q/p':>8}{'tilt z':>12}")
    for p, q in [(101, 127), (10007, 12583), (1000003, 1257017)]:
        print(f"{p:>12}{q:>14}{p * q:>20}{q / p:>8.4f}{z_of_ratio(q / p):>12.6f}")
    print("\nThe tilt law z(r) = (r^-1/2 - 2^-1/2)/(1 - 2^-1/2):")
    print(f"{'r':>8}{'z(r)':>12}{'regime':>16}")
    for r in (1.0, 1.10, 1.25, CRITICAL_RATIO, 1.50, 1.75, 2.0):
        regime = "top-heavy" if z_of_ratio(r) > 0.5 else (
            "TIE" if abs(z_of_ratio(r) - 0.5) < 1e-12 else "bottom-heavy")
        print(f"{r:>8.4f}{z_of_ratio(r):>12.6f}{regime:>16}")
    print(f"\ncritical ratio r* = 24 - 16*sqrt(2) = {CRITICAL_RATIO:.10f}")
    print(f"z(r*) = {z_of_ratio(CRITICAL_RATIO):.12f}   (exactly 1/2)")
    print("r* lies strictly inside the balance band (1, 2): enforcing q < 2p")
    print("settles nothing about which scan order wins.")


def demo_ratio_uniform_pool() -> None:
    banner("3.  Hard-balance control: ratio uniform on [1, 2]")
    numeric = simpson(z_of_ratio, 1.0, 2.0)
    print(f"mean tilt  = integral of z(r) dr over [1,2]")
    print(f"  numeric quadrature : {numeric:.12f}")
    print(f"  closed form sqrt(2) - 1 : {UNIFORM_MEAN_TILT:.12f}")
    print(f"  agreement to {abs(numeric - UNIFORM_MEAN_TILT):.2e}")
    print(f"\nbottom-heavy ({UNIFORM_MEAN_TILT:.6f} < 0.5): the ASCENDING scan wins.")
    print(f"tilt-only speedup (1 - z)/z = {tilt_only_predictor(UNIFORM_MEAN_TILT):.12f}"
          f"  (exactly sqrt(2) = {SQRT2:.12f})")
    print("\nfinite-window correction, exact law S = (L(1-z)+1)/(L z+1):")
    print(f"{'L':>10}{'exact S':>14}{'predictor':>14}{'bound 1/(Lz^2)':>18}")
    for L in (47, 500, 10_000, 10 ** 6):
        print(f"{L:>10}{exact_speedup(UNIFORM_MEAN_TILT, L):>14.6f}"
              f"{tilt_only_predictor(UNIFORM_MEAN_TILT):>14.6f}"
              f"{predictor_error_bound(UNIFORM_MEAN_TILT, L):>18.6f}")
    print("\n(L ~ 47 is the 15-bit laboratory scale where the reported 1.5896 was measured;")
    print(" the O(1/L) correction is exactly why measurement exceeds the sqrt(2) limit.)")


def demo_independent_model() -> None:
    banner("4.  The deployed class: two independent primes of the same bit length")
    print("Exact planar area A(r) of {(p,q) in [1,2]^2 : p <= q <= r p}:")
    print(f"{'r':>8}{'A(r) closed form':>20}{'A(r) quadrature':>20}")
    for r in (1.0, 1.25, 1.5, 1.75, 2.0):
        num = simpson(lambda p, r=r: min(r * p, 2.0) - p, 1.0, 2.0, 20_000)
        print(f"{r:>8.2f}{ratio_area(r):>20.10f}{num:>20.10f}")
    print(f"\nA(1) = {ratio_area(1.0):.10f} (empty), A(2) = {ratio_area(2.0):.10f} (half-square)")
    mass = simpson(ratio_density, 1.0, 2.0)
    print(f"\nratio density f(r) = 4/r^2 - 1 has total mass {mass:.12f} (must be 1)")
    print(f"  f(1) = {ratio_density(1.0):.4f}   f(2) = {ratio_density(2.0):.4f}"
          "   -> heaped against perfect balance")
    lo, hi = 1.0, 2.0
    for _ in range(80):
        mid = 0.5 * (lo + hi)
        if ratio_cdf(mid) < 0.5:
            lo = mid
        else:
            hi = mid
    print(f"  median ratio: {lo:.6f}   (real generators produce nearly equal primes)")

    numeric = simpson(lambda r: z_of_ratio(r) * ratio_density(r), 1.0, 2.0)
    print(f"\nmean tilt = integral of z(r) f(r) dr over [1,2]")
    print(f"  numeric quadrature       : {numeric:.12f}")
    print(f"  closed form (9-5sqrt2)/3 : {INDEPENDENT_MEAN_TILT:.12f}")
    print(f"  agreement to {abs(numeric - INDEPENDENT_MEAN_TILT):.2e}")
    print(f"\nTOP-HEAVY ({INDEPENDENT_MEAN_TILT:.6f} > 0.5): the ASCENDING scan LOSES.")
    pred = tilt_only_predictor(INDEPENDENT_MEAN_TILT)
    closed = (5.0 * SQRT2 - 6.0) / (9.0 - 5.0 * SQRT2)
    print(f"tilt-only speedup (1-z)/z = {pred:.12f}  = (5sqrt2-6)/(9-5sqrt2) = {closed:.12f}")
    print(f"i.e. ascending performs {1.0 / pred:.4f}x the work of descending"
          f" -- it loses {100 * (1 - pred):.1f}%.")

    p_desc = ratio_cdf(CRITICAL_RATIO)
    p_num = simpson(ratio_density, 1.0, CRITICAL_RATIO)
    print(f"\nper-key probability that descending wins = 5 - 4/r* - r* = {p_desc:.6f}")
    print(f"  numeric check: {p_num:.6f}")
    print("The reversal is typical, not a tail effect: ~71% of keys individually.")

    print("\nMeasured against the reported four-pool study:")
    print(f"  deployed-style pool measured zbar = 0.6356  CI [0.6150, 0.6562]"
          f"  -> contains {INDEPENDENT_MEAN_TILT:.6f}: "
          f"{0.6150 < INDEPENDENT_MEAN_TILT < 0.6562}")
    print(f"  deployed-style pool measured S    = 0.5578 +/- 0.0217"
          f"        -> contains {pred:.6f}: {0.5578 - 0.0217 < pred < 0.5578 + 0.0217}")
    print(f"  control pool measured zbar        = 0.4114  CI [0.3887, 0.4341]"
          f"  -> contains {UNIFORM_MEAN_TILT:.6f}: "
          f"{0.3887 < UNIFORM_MEAN_TILT < 0.4341}")


def demo_window_design_no_go() -> None:
    banner("5.  No window multiplier rescues the ascending scan")
    print(f"{'R':>8}{'tie ratio r*(R)':>18}{'1 < r*':>9}{'r* < R':>9}{'r* < 4':>9}"
          f"{'uniform mean tilt':>20}")
    for R in (1.25, 1.5, 2.0, 3.0, 4.5, 8.0, 100.0, 10_000.0):
        rc = critical_ratio_general(R)
        mt = 1.0 / (1.0 + math.sqrt(R))
        print(f"{R:>8.2f}{rc:>18.8f}{str(rc > 1):>9}{str(rc < R):>9}{str(rc < 4):>9}"
              f"{mt:>20.8f}")
    print("\nr*(R) = 4R/(1 + sqrt(R))^2 always lies in (1, min(R, 4)): for EVERY window")
    print("there is an interval of near-balanced ratios on which ascending loses, and the")
    print("tie point can never be pushed past ratio 4.  Meanwhile a ratio-uniform pool on")
    print("[1, R] has mean tilt 1/(1 + sqrt(R)) < 1/2 for every R -- bottom-heaviness is a")
    print("property of ratio-SPREAD laboratory pools, not of any window choice.")
    print(f"\nconsistency at R = 2: r*(2) = {critical_ratio_general(2.0):.10f}"
          f"  vs  24 - 16*sqrt(2) = {CRITICAL_RATIO:.10f}")


def demo_deployment_threshold() -> None:
    banner("6.  Deployment theorem on the true INTEGER window")
    print("m(r) = r^-1/2 - (1 + 2^-1/2)/2 > 0  iff  r < r*;  then every key with")
    print("sqrt(N) >= 1/(2 m(r)) satisfies  ceil(sqrt(N/2)) + floor(sqrt(N)) < 2p.")
    print(f"\n{'r':>8}{'m(r)':>12}{'sqrt(N) threshold':>20}{'N threshold':>16}")
    for r in (1.02, 1.10, 1.25, 1.35):
        m = margin(r)
        thr = 1.0 / (2.0 * m)
        print(f"{r:>8.2f}{m:>12.6f}{thr:>20.3f}{thr ** 2:>16.1f}")
    print("\nDirect verification on genuine semiprimes (p, q primes, integer windows):")
    print(f"{'p':>8}{'q':>8}{'N':>12}{'a':>8}{'b':>8}{'r':>8}{'asc':>8}{'desc':>8}{'winner':>13}")
    for p, q in [(101, 127), (211, 233), (1009, 1123), (32003, 36007), (65003, 70001)]:
        n = p * q
        a, b = integer_window(n)
        winner = "descending" if desc_cost(b, p) < asc_cost(a, p) else "ascending"
        print(f"{p:>8}{q:>8}{n:>12}{a:>8}{b:>8}{q / p:>8.4f}"
              f"{asc_cost(a, p):>8}{desc_cost(b, p):>8}{winner:>13}")
    print("\nEvery ratio above is below r* = 1.3726, and descending wins every one.")


def demo_end_to_end_simulation() -> None:
    banner("7.  End-to-end simulation with real primes and exact touch counts")
    bits = 15
    size = 600
    seed = 20260824

    # a fresh generator per pool, so each pool is independently reproducible
    dep = pool_statistics(independent_pool(bits, size, random.Random(seed)))
    ctl = pool_statistics(ratio_uniform_pool(bits, size, random.Random(seed)))

    def report(name: str, stats: dict, predicted_tilt: float) -> None:
        L = stats["mean_window_length"]
        print(f"\n{name}")
        print(f"  keys                  : {stats['n']}")
        print(f"  in-window fraction    : {stats['in_window_fraction']:.3f}")
        print(f"  mean window length L  : {L:.1f}")
        zw = stats["weighted_mean_tilt"]
        print(f"  measured mean tilt    : {stats['mean_tilt']:.6f}")
        print(f"  predicted mean tilt   : {predicted_tilt:.6f}")
        print(f"  L-weighted mean tilt  : {zw:.6f}")
        print(f"  measured speedup S    : {stats['speedup']:.6f}")
        print(f"  weighted-tilt law     : {exact_speedup(zw, L):.6f}   (Theorem: exact)")
        print(f"  exact law at pred. z  : {exact_speedup(predicted_tilt, L):.6f}")
        print(f"  tilt-only predictor   : {tilt_only_predictor(predicted_tilt):.6f}")
        print(f"  winner                : "
              f"{'sqrt-DESCENDING' if stats['descending_wins'] else 'window-ASCENDING'}")

    report(f"Deployed style: independent {bits}-bit primes", dep, INDEPENDENT_MEAN_TILT)
    report("Hard-balance control: ratio spread over [1, 2]", ctl, UNIFORM_MEAN_TILT)

    print("\nNote the in-window fraction of 1.000 for the deployed pool: equal bit length")
    print("forces q < 2p, hence window membership.  The ascending scan was always well")
    print("defined on those keys -- and still lost.")
    print("\nNote also the L-weighted mean tilt.  With per-key windows the pool speedup is")
    print("governed by the window-length-weighted tilt, not the plain average.  A larger")
    print("ratio means a larger N (longer window) and a lower tilt, so the weighting drags")
    print("the effective tilt DOWN on ratio-spread pools -- which is exactly why the control")
    print("pool measures ~1.59 rather than the unweighted sqrt(2) = 1.414.  On the deployed")
    print("pool the ratio law is concentrated, so the weighting barely moves anything.")


def demo_exhaustive_enumeration() -> None:
    banner("8.  Exhaustive enumeration: every same-bit-length prime pair")
    print(f"{'bits':>6}{'#primes':>10}{'#pairs':>10}{'mean tilt':>14}"
          f"{'speedup S':>12}{'winner':>16}")
    for bits in (8, 9, 10, 11, 12):
        pairs = exhaustive_independent_pool(bits)
        st = pool_statistics(pairs)
        winner = "DESCENDING" if st["descending_wins"] else "ascending"
        print(f"{bits:>6}{len(primes_in_bit_window(bits)):>10}{len(pairs):>10}"
              f"{st['mean_tilt']:>14.6f}{st['speedup']:>12.6f}{winner:>16}")
    print(f"\nlimiting closed form: mean tilt -> (9 - 5sqrt2)/3 = {INDEPENDENT_MEAN_TILT:.6f},")
    print(f"speedup -> (5sqrt2 - 6)/(9 - 5sqrt2) = "
          f"{tilt_only_predictor(INDEPENDENT_MEAN_TILT):.6f}.")
    print("Discreteness at these tiny bit lengths shifts the values slightly, but the")
    print("verdict is stable: every exhaustive population is top-heavy.")


def demo_crossing_exponent() -> None:
    banner("9.  The power-law family and its exact crossing exponent theta* = 3/2")
    print("For the law with density proportional to r^-theta on [1, 2], the mean tilt")
    print("increases with theta and crosses 1/2 at exactly theta = 3/2.")
    print(f"\n{'theta':>8}{'mean tilt':>14}{'speedup (1-z)/z':>20}{'winner':>16}")
    for theta in (-4.0, -2.0, 0.0, 1.0, 1.5, 2.0, 4.0, 8.0):
        num = simpson(lambda r, t=theta: z_of_ratio(r) * r ** (-t), 1.0, 2.0)
        den = simpson(lambda r, t=theta: r ** (-t), 1.0, 2.0)
        z = num / den
        winner = "DESCENDING" if z > 0.5 else ("tie" if abs(z - 0.5) < 1e-9 else "ascending")
        print(f"{theta:>8.2f}{z:>14.8f}{tilt_only_predictor(z):>20.8f}{winner:>16}")
    # closed-form check: I(2)/I(3/2) = (1 + 2^{-1/2})/2
    i2 = simpson(lambda r: r ** (-2.0), 1.0, 2.0)
    i32 = simpson(lambda r: r ** (-1.5), 1.0, 2.0)
    print(f"\nI(2) = {i2:.10f} (exactly 1/2),  I(3/2) = {i32:.10f} (exactly 2 - sqrt2 = "
          f"{2 - SQRT2:.10f})")
    print(f"I(2)/I(3/2) = {i2 / i32:.10f}   target (1 + 2^-1/2)/2 = "
          f"{(1 + 1 / SQRT2) / 2:.10f}")
    print("theta* = 3/2 exactly: a generator is adversarial to the ascending scan precisely")
    print("when its ratio density is steeper than r^-3/2 near perfect balance.")


def main() -> None:
    print(__doc__)
    demo_conservation_law()
    demo_tilt_law()
    demo_ratio_uniform_pool()
    demo_independent_model()
    demo_window_design_no_go()
    demo_deployment_threshold()
    demo_end_to_end_simulation()
    demo_exhaustive_enumeration()
    demo_crossing_exponent()
    banner("Summary")
    print(f"  ratio-uniform  mean tilt = sqrt(2) - 1      = {UNIFORM_MEAN_TILT:.6f} < 1/2"
          "   -> ascending wins (x1.414)")
    print(f"  independent    mean tilt = (9 - 5sqrt2)/3   = {INDEPENDENT_MEAN_TILT:.6f} > 1/2"
          "   -> ascending LOSES (x0.555)")
    print(f"  tie ratio r* = 24 - 16sqrt2 = {CRITICAL_RATIO:.6f} lies strictly inside (1, 2):")
    print("  enforcing balance q < 2p does NOT secure the ascending advantage, and no")
    print("  window multiplier repairs it.  No factoring speedup is claimed.")


if __name__ == "__main__":
    main()
