"""
Positional geometry of the Fermat / quadratic-sieve polynomial
==============================================================

Numerical demonstrations of the results:

  v(j) = (b + j)^2 - N,   b = ceil(sqrt(N)),   v(0) = b^2 - N

  1. Position-GCD law            gcd(j, v(j)) = gcd(j, v(0))
  2. Free cofactor reduction     v is B-smooth  <=>  v/g is B-smooth   (g | v, g < B)
  3. Window equidistribution     local carriers have translation-invariant window counts
  4. Prime divisibility          at most two residue classes mod p, exactly uniform
  5. Exact 1/d density           exactly t multiples of d in any window of length d*t
  6. Harmonic block decline      sum_{K<j<=2K} 1/j  <  sum_{1<=j<=K} 1/j
  7. Small-j excess              the self-divisibility carrier prefers small positions
  8. Magnitude sandwich          2bj <= v(j) <= 2bj + j^2 + 2b
  9. Cell collapse               v(j2) <= 2 v(j1)  =>  b j2 <= 2 b j1 + 2b + j1^2
 10. Non-locality                degenerate sieve: unbounded block imbalance
 11. Terminal Fermat position    v(s - b) = d^2, and 2 b (s - b) <= d^2
 12. A miniature sieve experiment reproducing the monotone-declining decile profile,
     together with the magnitude-only prediction that accounts for it.

Pure standard library; run with `python3 demo.py`.
"""

from __future__ import annotations

import math
import random
from fractions import Fraction
from typing import Callable, Dict, List, Sequence, Tuple


# ----------------------------------------------------------------------------- basics


def isqrt_ceil(n: int) -> int:
    """Smallest integer b with b*b >= n."""
    r = math.isqrt(n)
    return r if r * r == n else r + 1


def sieve_val(b: int, n: int, j: int) -> int:
    """The sieve polynomial v(j) = (b + j)^2 - N."""
    return (b + j) ** 2 - n


def primes_below(limit: int) -> List[int]:
    """All primes strictly below `limit` by a simple sieve of Eratosthenes."""
    if limit <= 2:
        return []
    flags = bytearray([1]) * limit
    flags[0] = flags[1] = 0
    for p in range(2, math.isqrt(limit - 1) + 1):
        if flags[p]:
            flags[p * p : limit : p] = bytearray(len(range(p * p, limit, p)))
    return [i for i, f in enumerate(flags) if f]


def smooth_part(value: int, primes: Sequence[int]) -> int:
    """Remove all factors of the listed primes from |value|; returns the cofactor."""
    m = abs(value)
    if m == 0:
        return 0
    for p in primes:
        while m % p == 0:
            m //= p
    return m


def is_smooth(value: int, primes: Sequence[int]) -> bool:
    """True iff every prime factor of |value| lies in `primes` (and value != 0)."""
    return abs(value) != 0 and smooth_part(value, primes) == 1


# ------------------------------------------------------------- 1. position-gcd law


def check_position_gcd_law(trials: int = 2000, seed: int = 20260825) -> Tuple[int, int]:
    """gcd(j, v(j)) = gcd(j, v(0)) for random b, N, j.  Returns (checked, failures)."""
    rng = random.Random(seed)
    failures = 0
    for _ in range(trials):
        b = rng.randrange(1, 10**9)
        n = rng.randrange(1, 10**18)
        j = rng.randrange(-10**6, 10**6)
        lhs = math.gcd(j, sieve_val(b, n, j))
        rhs = math.gcd(j, sieve_val(b, n, 0))
        failures += lhs != rhs
    return trials, failures


# ------------------------------------------------- 2. free cofactor reduction (gcd carrier)


def cofactor_discount_profile(n: int, bound: int, jmax: int) -> List[Tuple[int, int, int]]:
    """For each position with a nontrivial guaranteed factor g = gcd(j, v(0)) < B,
    report (j, g, number of bits saved on the smoothness test)."""
    b = isqrt_ceil(n)
    v0 = sieve_val(b, n, 0)
    out: List[Tuple[int, int, int]] = []
    for j in range(1, jmax + 1):
        g = math.gcd(j, v0)
        if 1 < g < bound:
            v = sieve_val(b, n, j)
            assert v % g == 0, "the position-gcd law guarantees divisibility"
            out.append((j, g, v.bit_length() - (v // g).bit_length()))
    return out


def check_free_cofactor(n: int, bound: int, jmax: int) -> Tuple[int, int]:
    """Verify: for g = gcd(j, v(0)) < B, v(j) is B-smooth iff v(j)/g is."""
    b = isqrt_ceil(n)
    v0 = sieve_val(b, n, 0)
    ps = primes_below(bound)
    checked = failures = 0
    for j in range(1, jmax + 1):
        g = math.gcd(j, v0)
        if 1 < g < bound:
            v = sieve_val(b, n, j)
            checked += 1
            failures += is_smooth(v, ps) != is_smooth(v // g, ps)
    return checked, failures


# ------------------------------------------- 3./4. window equidistribution, primes


def window_count(pred: Callable[[int], bool], a: int, length: int) -> int:
    """#{ 0 <= i < length : pred(a + i) }."""
    return sum(1 for i in range(length) if pred(a + i))


def prime_class_report(p: int, b: int, n: int, starts: Sequence[int]) -> Dict[str, object]:
    """Positions with p | v(j): count in each window of p consecutive positions,
    plus the residue classes themselves."""
    classes = [x for x in range(p) if (b + x) ** 2 % p == n % p]
    counts = [window_count(lambda j: sieve_val(b, n, j) % p == 0, a, p) for a in starts]
    return {"p": p, "classes": classes, "num_classes": len(classes), "window_counts": counts}


def gcd_carrier_uniformity(b: int, n: int, starts: Sequence[int]) -> List[int]:
    """Count of positions with gcd(j, v(0)) > 1 in windows of length |v(0)|."""
    v0 = sieve_val(b, n, 0)
    t = abs(v0)
    return [window_count(lambda j: math.gcd(j, v0) > 1, a, t) for a in starts]


# --------------------------------------------------- 5./6./7. the declining carrier


def divisibility_window_count(d: int, a: int, length: int) -> int:
    """#{ 0 <= i < length : d | a + i }."""
    return window_count(lambda x: x % d == 0, a, length)


def harmonic(lo: int, hi: int) -> Fraction:
    """Exact rational sum_{lo <= j <= hi} 1/j."""
    return sum((Fraction(1, j) for j in range(lo, hi + 1)), Fraction(0))


def small_j_excess(k: int) -> Tuple[Fraction, Fraction, Fraction]:
    """(first block mass, second block mass, excess) for the 1/j carrier."""
    first, second = harmonic(1, k), harmonic(k + 1, 2 * k)
    return first, second, first - second


def empirical_self_divisor_blocks(k: int, m: int, a: int) -> Tuple[int, int]:
    """Count self-divisor positions in [1,K] and (K,2K] over M consecutive base values."""
    lo = sum(divisibility_window_count(j, a, m) for j in range(1, k + 1))
    hi = sum(divisibility_window_count(j, a, m) for j in range(k + 1, 2 * k + 1))
    return lo, hi


def lcm_upto(k: int) -> int:
    """Smallest M divisible by every j <= k (so that all densities are exact)."""
    m = 1
    for j in range(1, k + 1):
        m = m * j // math.gcd(m, j)
    return m


# ------------------------------------------------------- 8./9. the magnitude channel


def check_sandwich(n: int, jmax: int) -> Tuple[int, int]:
    """Verify 2bj <= v(j) <= 2bj + j^2 + 2b for b = ceil(sqrt N)."""
    b = isqrt_ceil(n)
    bad = 0
    for j in range(0, jmax + 1):
        v = sieve_val(b, n, j)
        if not (2 * b * j <= v <= 2 * b * j + j * j + 2 * b):
            bad += 1
    return jmax + 1, bad


def cell_collapse_report(n: int, j1: int) -> Dict[str, int]:
    """Largest j2 with v(j2) <= 2 v(j1), against the proved bound."""
    b = isqrt_ceil(n)
    target = 2 * sieve_val(b, n, j1)
    j2 = j1
    while sieve_val(b, n, j2 + 1) <= target:
        j2 += 1
    bound = (2 * b * j1 + 2 * b + j1 * j1) // b
    return {"j1": j1, "largest_j2_in_cell": j2, "proved_bound": bound}


# ------------------------------------------------------------------ 10. non-locality


def degenerate_hits(a: int, length: int) -> int:
    """Hits of the degenerate sieve b = 1, N = 0, B = 3: positions i with i+1 a power of 2."""
    return sum(1 for i in range(a, a + length) if (i + 1) & i == 0)


def block_imbalance(n_exp: int) -> Tuple[int, int, int]:
    """(hits in [0,2^n), hits in [2^n, 2^{n+1}), imbalance)."""
    length = 1 << n_exp
    first = degenerate_hits(0, length)
    second = degenerate_hits(length, length)
    return first, second, first - second


# ------------------------------------------------------- 11. terminal Fermat position


def terminal_position(p: int, q: int) -> Dict[str, int]:
    """For N = p q, the terminal Fermat position and its value."""
    n = p * q
    b = isqrt_ceil(n)
    s, d = (p + q) // 2, (q - p) // 2
    j0 = s - b
    return {
        "N": n,
        "b": b,
        "terminal_j": j0,
        "value_there": sieve_val(b, n, j0),
        "d_squared": d * d,
        "magnitude_bound_2bj0": 2 * b * j0,
    }


# ----------------------------------------------- 12. miniature sieve experiment


def hit_positions(n: int, bound: int, jmax: int) -> List[int]:
    """Positions 1..jmax at which v(j) is B-smooth."""
    b = isqrt_ceil(n)
    ps = primes_below(bound)
    return [j for j in range(1, jmax + 1) if is_smooth(sieve_val(b, n, j), ps)]


def decile_profile(positions: Sequence[int], jmax: int) -> List[float]:
    """Fraction of hits falling in each tenth of the searched position range."""
    bins = [0] * 10
    for j in positions:
        idx = min(9, int(10 * (j - 1) / jmax))
        bins[idx] += 1
    total = max(1, len(positions))
    return [c / total for c in bins]


def ks_statistic_uniform(positions: Sequence[int], jmax: int) -> float:
    """Kolmogorov-Smirnov distance of the rescaled positions u = j / jmax from U[0,1]."""
    if not positions:
        return 0.0
    us = sorted(j / jmax for j in positions)
    m = len(us)
    return max(
        max(abs((i + 1) / m - u), abs(u - i / m)) for i, u in enumerate(us)
    )


_RHO_UMAX: float = 12.0
_RHO_STEPS: int = 6000
_RHO_TABLE: List[float] = []


def _build_rho_table() -> List[float]:
    """Tabulate Dickman's rho on [0, _RHO_UMAX] by integrating u rho'(u) = -rho(u-1)."""
    h = _RHO_UMAX / _RHO_STEPS
    grid = [0.0] * (_RHO_STEPS + 1)
    for i in range(_RHO_STEPS + 1):
        if i * h <= 1.0:
            grid[i] = 1.0
    for i in range(1, _RHO_STEPS + 1):
        x = i * h
        if x <= 1.0:
            continue
        k = (x - 1.0) / h
        k0 = min(_RHO_STEPS, int(k))
        frac = k - k0
        rho_shift = grid[k0] * (1 - frac) + grid[min(_RHO_STEPS, k0 + 1)] * frac
        grid[i] = max(0.0, grid[i - 1] - h * rho_shift / x)
    return grid


def dickman_rho(u: float) -> float:
    """Dickman's function rho(u): the density of u-smooth numbers, by table lookup."""
    global _RHO_TABLE
    if not _RHO_TABLE:
        _RHO_TABLE = _build_rho_table()
    if u <= 1.0:
        return 1.0
    if u >= _RHO_UMAX:
        return _RHO_TABLE[-1]
    k = u / (_RHO_UMAX / _RHO_STEPS)
    k0 = int(k)
    frac = k - k0
    return _RHO_TABLE[k0] * (1 - frac) + _RHO_TABLE[min(_RHO_STEPS, k0 + 1)] * frac


def magnitude_prediction(n: int, bound: int, jmax: int) -> List[float]:
    """Decile profile predicted by magnitude alone: smoothness probability of v(j)
    estimated by rho(log v(j) / log B), normalised over the ten position deciles."""
    b = isqrt_ceil(n)
    logb = math.log(bound)
    weights = [0.0] * 10
    for j in range(1, jmax + 1):
        v = abs(sieve_val(b, n, j))
        u = math.log(max(v, 2)) / logb
        weights[min(9, int(10 * (j - 1) / jmax))] += dickman_rho(u)
    total = sum(weights) or 1.0
    return [w / total for w in weights]


def random_balanced_semiprime(bits: int, rng: random.Random) -> int:
    """Product of two random primes of about `bits`/2 bits each."""

    def rand_prime(nbits: int) -> int:
        while True:
            c = rng.randrange(1 << (nbits - 1), 1 << nbits) | 1
            if is_probable_prime(c):
                return c

    return rand_prime(bits // 2) * rand_prime(bits - bits // 2)


def is_probable_prime(m: int, rounds: int = 24) -> bool:
    """Deterministic-enough Miller-Rabin for the sizes used here."""
    if m < 2:
        return False
    for p in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
        if m % p == 0:
            return m == p
    d, r = m - 1, 0
    while d % 2 == 0:
        d //= 2
        r += 1
    for a in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37)[:rounds]:
        x = pow(a, d, m)
        if x in (1, m - 1):
            continue
        for _ in range(r - 1):
            x = x * x % m
            if x == m - 1:
                break
        else:
            return False
    return True


# --------------------------------------------------------------------------- driver


def main() -> None:
    line = "=" * 78

    print(line)
    print("1. POSITION-GCD LAW      gcd(j, v(j)) = gcd(j, v(0))")
    print(line)
    checked, failures = check_position_gcd_law()
    print(f"random (b, N, j) triples checked : {checked}")
    print(f"failures                          : {failures}")

    n_demo = 1_000_003 * 1_000_033
    b_demo = isqrt_ceil(n_demo)
    print(f"\nexample N = {n_demo},  b = ceil(sqrt N) = {b_demo},  v(0) = {sieve_val(b_demo, n_demo, 0)}")
    for j in (6, 12, 35, 210):
        print(
            f"  j = {j:4d}:  gcd(j, v(j)) = {math.gcd(j, sieve_val(b_demo, n_demo, j)):6d}"
            f"   gcd(j, v(0)) = {math.gcd(j, sieve_val(b_demo, n_demo, 0)):6d}"
        )

    print()
    print(line)
    print("2. FREE COFACTOR REDUCTION      the beyond-magnitude gcd carrier")
    print(line)
    bound = 5000
    prof = cofactor_discount_profile(n_demo, bound, 4000)
    print(f"positions j <= 4000 with 1 < gcd(j, v(0)) < {bound}: {len(prof)}")
    for j, g, bits in prof[:8]:
        print(f"  j = {j:5d}  guaranteed factor g = {g:6d}  bits saved on the test = {bits}")
    checked, failures = check_free_cofactor(n_demo, bound, 4000)
    print(f"smoothness equivalence v ~ v/g checked at {checked} positions, failures = {failures}")

    print()
    print(line)
    print("3./4. LOCAL CARRIERS ARE POSITIONALLY UNIFORM")
    print(line)
    for p in (7, 11, 13, 101):
        rep = prime_class_report(p, b_demo, n_demo, starts=[0, 1, 500, -9999, 123456])
        print(
            f"  p = {p:4d}: residue classes with p | v(j) = {rep['classes']}"
            f"  -> counts in five different windows of length p: {rep['window_counts']}"
        )
    small_n = 3 * 11
    small_b = isqrt_ceil(small_n)
    counts = gcd_carrier_uniformity(small_b, small_n, starts=[0, 1, 7, -13, 400])
    print(
        f"  gcd carrier for N = {small_n} (v(0) = {sieve_val(small_b, small_n, 0)}): "
        f"counts of gcd(j, v(0)) > 1 in windows of length |v(0)| = {counts}"
    )
    print("  -> flat: a periodic carrier cannot cluster hits at small j.")

    print()
    print(line)
    print("5./6./7. THE UNIQUE DECLINING CARRIER:  j | v(j)  <=>  j | v(0),  density 1/j")
    print(line)
    for d in (3, 7, 12):
        for t in (1, 4, 9):
            got = divisibility_window_count(d, 17, d * t)
            print(f"  d = {d:3d}, window length d*t = {d*t:4d}: multiples found = {got} (= t = {t})")
    print()
    for k in (1, 2, 5, 20, 100):
        first, second, excess = small_j_excess(k)
        print(
            f"  K = {k:4d}: sum_[1,K] 1/j = {float(first):.6f}   "
            f"sum_(K,2K] 1/j = {float(second):.6f}   excess = {float(excess):+.6f}"
        )
    print("  (the second block mass tends to log 2 = 0.693147..., while the first grows")
    print("   like log K + gamma: the small-j excess is strict for every K and widens)")
    k = 6
    m = lcm_upto(2 * k)
    lo, hi = empirical_self_divisor_blocks(k, m, a=1)
    print(f"\n  exact block count over M = lcm(1..{2*k}) = {m} base values:")
    print(f"    positions j in [1,{k}]      with j | v(j): {lo}")
    print(f"    positions j in ({k},{2*k}]  with j | v(j): {hi}")
    print(f"    strict small-j excess       : {lo - hi}")

    print()
    print(line)
    print("8./9. THE MAGNITUDE CHANNEL:  2bj <= v(j) <= 2bj + j^2 + 2b,  and cell collapse")
    print(line)
    checked, bad = check_sandwich(n_demo, 5000)
    print(f"sandwich checked at {checked} positions, violations = {bad}")
    for j1 in (1, 4, 25, 400):
        rep = cell_collapse_report(n_demo, j1)
        print(
            f"  one-bit magnitude cell around j1 = {rep['j1']:4d}: "
            f"largest j2 with v(j2) <= 2 v(j1) is {rep['largest_j2_in_cell']:5d}, "
            f"proved bound j2 <= {rep['proved_bound']}"
        )
    print("  -> a size cell is a factor-two window of positions: it cannot decorrelate")
    print("     position from magnitude inside a single N.")

    print()
    print(line)
    print("10. NON-LOCALITY OF THE SMOOTH LOCUS  (degenerate sieve b = 1, N = 0, B = 3)")
    print(line)
    print("  n   hits in [0,2^n)   hits in [2^n,2^{n+1})   imbalance")
    for e in range(1, 13):
        first, second, imb = block_imbalance(e)
        print(f" {e:3d}      {first:6d}              {second:6d}              {imb:6d}")
    print("  -> unbounded imbalance; a carrier of modulus T has imbalance at most T,")
    print("     so no modulus whatsoever describes the smooth locus.")

    print()
    print(line)
    print("11. THE TERMINAL FERMAT POSITION")
    print(line)
    for p, q in ((1_000_003, 1_000_033), (99_991, 100_003), (65_521, 262_147)):
        rep = terminal_position(p, q)
        print(
            f"  N = {rep['N']:>16d}: terminal j0 = {rep['terminal_j']:>8d}, "
            f"v(j0) = {rep['value_there']:>14d} = d^2 = {rep['d_squared']:>14d}, "
            f"2 b j0 = {rep['magnitude_bound_2bj0']:>16d} <= d^2"
        )
    print("  -> a balanced semiprime halts at small j because the value there is small:")
    print("     magnitude, not extra positional structure.")

    print()
    print(line)
    print("12. MINIATURE SIEVE EXPERIMENT:  the declining decile profile, and its cause")
    print(line)
    rng = random.Random(20260825)
    bound = 2000
    jmax = 20000
    pooled: List[float] = []
    profiles: List[List[float]] = []
    predictions: List[List[float]] = []
    ks_values: List[float] = []
    for _ in range(12):
        n = random_balanced_semiprime(48, rng)
        hits = hit_positions(n, bound, jmax)
        if len(hits) < 10:
            continue
        profiles.append(decile_profile(hits, jmax))
        predictions.append(magnitude_prediction(n, bound, jmax))
        ks_values.append(ks_statistic_uniform(hits, jmax))
        pooled.extend(j / jmax for j in hits)
    if profiles:
        avg = [sum(p[i] for p in profiles) / len(profiles) for i in range(10)]
        pred = [sum(p[i] for p in predictions) / len(predictions) for i in range(10)]
        print(f"  moduli used: {len(profiles)},  pooled hits: {len(pooled)},  "
              f"smoothness bound B = {bound},  positions searched per modulus: {jmax}")
        print("  decile   observed   magnitude-only prediction")
        for i in range(10):
            print(f"   {i+1:2d}      {avg[i]:.4f}        {pred[i]:.4f}")
        pooled_positions = [u * jmax for u in pooled]
        print(f"  pooled KS distance from U[0,1]: {ks_statistic_uniform(pooled_positions, jmax):.5f}")
        print(f"  mean per-modulus KS distance   : {sum(ks_values)/len(ks_values):.5f}")
        print("  -> the observed decline is monotone, and is tracked closely by the")
        print("     magnitude-only prediction: v(j) ~ 2bj grows, so smoothness decays.")

    print()
    print(line)
    print("SUMMARY")
    print(line)
    print("  * the position-gcd law makes v(0) the sole arbiter of position/value arithmetic;")
    print("  * the resulting gcd carrier is real but positionally flat;")
    print("  * only full self-divisibility declines, with exact density 1/j;")
    print("  * every local carrier of modulus T has block imbalance at most T;")
    print("  * the smooth locus has unbounded imbalance, so it is not local;")
    print("  * size cells are position intervals, so within-N size stratification is a no-op.")


if __name__ == "__main__":
    main()
