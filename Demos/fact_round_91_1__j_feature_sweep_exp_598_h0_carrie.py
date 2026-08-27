"""
Numerical companions to
"Marginal Blindness and the Consecutive-Position Law of the Sieve Polynomial".

Everything is self-contained: no third-party imports, no external data.  Each
section reproduces, by direct enumeration or by Monte-Carlo, one of the exact
statements proved in the paper.

Sections
--------
1. Two roots per prime and the adjacency obstruction  (local law mod q)
2. The exact adjacent covariance  -4/q^2  and its exceptional value 1/q - 4/q^2
3. The flat lag spectrum and its two exceptional lags  k = +-2r
4. Chinese-remainder additivity of the covariance across independent primes
5. The factor-base deficit law  cov = -sum_i 4/q_i^2  and the bound  <= 2
6. Marginal blindness: a hit set flat on every marginal cell, enriched by
   |B| on a joint cell
7. The selection floor and max-statistic calibration: why a raw best-of-105
   ratio of 1.5578 is not evidence
8. A real sieve trace: the predicted adjacent deficit, measured on the actual
   polynomial over 400,000 positions

Run with:  python3 demo.py
"""

from __future__ import annotations

import math
import random
from itertools import product
from typing import Callable, Dict, Iterable, List, Sequence, Tuple

# ----------------------------------------------------------------------------
# Section 1.  The local law of the sieve polynomial  y_v = (s + v)^2 - N mod q
# ----------------------------------------------------------------------------


def y_value(s: int, N: int, v: int, q: int) -> int:
    """The sieve polynomial y_v = (s + v)^2 - N, reduced mod q."""
    return ((s + v) ** 2 - N) % q


def div_set(s: int, N: int, q: int) -> List[int]:
    """Residues v in Z/q at which q divides y_v."""
    return [v for v in range(q) if y_value(s, N, v, q) == 0]


def pair_set_lag(s: int, N: int, q: int, k: int) -> List[int]:
    """Residues v at which q divides both y_v and y_{v+k}."""
    return [
        v
        for v in range(q)
        if y_value(s, N, v, q) == 0 and y_value(s, N, v + k, q) == 0
    ]


def demo_local_law() -> None:
    print("=" * 78)
    print("1.  Two roots per prime, and the adjacency obstruction  4N = 1")
    print("=" * 78)
    print(f"{'q':>4} {'N':>4} {'|divSet|':>9} {'|pairSet|':>10} {'4N mod q':>9}"
          f"  {'verdict':<28}")
    for q in (5, 7, 11, 13, 17, 19, 23):
        for r in range(1, q // 2 + 1):
            N = (r * r) % q
            s = (3 * q // 7) % q  # an arbitrary shift; the law is s-independent
            d = div_set(s, N, q)
            p = pair_set_lag(s, N, q, 1)
            assert len(d) == 2, "a nonzero square always has exactly two roots"
            exceptional = (4 * N) % q == 1
            assert len(p) == (1 if exceptional else 0)
            if exceptional or r == 1:
                verdict = ("EXCEPTIONAL: one adjacent hit"
                           if exceptional else "generic: no adjacent hit")
                print(f"{q:>4} {N:>4} {len(d):>9} {len(p):>10} {(4*N)%q:>9}"
                      f"  {verdict:<28}")
    print("\nEvery nonzero square target has exactly two roots mod q, and two")
    print("consecutive positions are simultaneously divisible only when 4N = 1.")
    print()


# ----------------------------------------------------------------------------
# Section 2.  Exact covariance of the divisibility indicators
# ----------------------------------------------------------------------------


def avg(values: Sequence[float]) -> float:
    """Empirical mean over the uniform measure on a finite index set."""
    return sum(values) / len(values)


def cov(f: Sequence[float], g: Sequence[float]) -> float:
    """Empirical covariance  E[fg] - E[f]E[g]  over the uniform measure."""
    return avg([a * b for a, b in zip(f, g)]) - avg(f) * avg(g)


def hit_indicator(s: int, N: int, q: int, shift: int = 0) -> List[float]:
    """Indicator of  q | y_{v+shift}, as a vector indexed by v in Z/q."""
    return [1.0 if y_value(s, N, v + shift, q) == 0 else 0.0 for v in range(q)]


def demo_adjacent_covariance() -> None:
    print("=" * 78)
    print("2.  The exact adjacent covariance")
    print("=" * 78)
    print(f"{'q':>4} {'N':>4} {'cov(empirical)':>16} {'predicted':>14}  {'case':<12}")
    for q in (5, 7, 11, 13, 17, 19, 23, 29, 31):
        for r in (1, 2, 3):
            if r >= q:
                continue
            N = (r * r) % q
            s = 1
            c = cov(hit_indicator(s, N, q), hit_indicator(s, N, q, shift=1))
            if (4 * N) % q == 1:
                predicted = 1.0 / q - 4.0 / q ** 2
                case = "exceptional"
            else:
                predicted = -4.0 / q ** 2
                case = "generic"
            assert abs(c - predicted) < 1e-12
            if r <= 2 or case == "exceptional":
                print(f"{q:>4} {N:>4} {c:>16.10f} {predicted:>14.10f}  {case:<12}")
    print("\nThe empirical covariance equals  (#adjacent double hits)/q - (2/q)^2")
    print("exactly: -4/q^2 generically, and 1/q - 4/q^2 on the locus 4N = 1.")
    print()


# ----------------------------------------------------------------------------
# Section 3.  The lag spectrum
# ----------------------------------------------------------------------------


def lag_spectrum(s: int, N: int, q: int) -> Dict[int, float]:
    """cov(1[q | y_v], 1[q | y_{v+k}]) for every nonzero lag k."""
    base = hit_indicator(s, N, q)
    return {k: cov(base, hit_indicator(s, N, q, shift=k)) for k in range(1, q)}


def demo_lag_spectrum() -> None:
    print("=" * 78)
    print("3.  The lag spectrum is flat, with exactly two exceptional lags")
    print("=" * 78)
    for q, r in ((13, 1), (17, 3), (23, 5)):
        N = (r * r) % q
        s = 2
        spec = lag_spectrum(s, N, q)
        exceptional = sorted(k for k, c in spec.items() if c > 0)
        generic_values = {round(c, 12) for k, c in spec.items()
                          if k not in exceptional}
        print(f"q = {q:>3}, N = r^2 with r = {r}:")
        print(f"    exceptional lags        : {exceptional}"
              f"   (predicted: {sorted({(2*r) % q, (-2*r) % q})})")
        print(f"    covariance there        : {spec[exceptional[0]]:+.10f}"
              f"   (predicted {1/q - 4/q**2:+.10f})")
        print(f"    covariance at all others: {generic_values.pop():+.10f}"
              f"   (predicted {-4/q**2:+.10f})")
        assert sorted(exceptional) == sorted({(2 * r) % q, (-2 * r) % q})
    print("\nNo lag is independent: the covariance is never zero for q >= 5.")
    print()


# ----------------------------------------------------------------------------
# Section 4.  Chinese-remainder additivity of the covariance
# ----------------------------------------------------------------------------


def crt_index(residues: Sequence[int], moduli: Sequence[int]) -> int:
    """Chinese-remainder reconstruction of a residue tuple."""
    M = 1
    for m in moduli:
        M *= m
    total = 0
    for a, m in zip(residues, moduli):
        Mi = M // m
        total += a * Mi * pow(Mi, -1, m)
    return total % M


def factor_base_count(v: int, s_list: Sequence[int], N_list: Sequence[int],
                      primes: Sequence[int]) -> float:
    """Number of factor-base primes dividing y_v, evaluated coordinatewise."""
    return float(sum(1 for s, N, q in zip(s_list, N_list, primes)
                     if y_value(s, N, v, q) == 0))


def demo_crt_additivity() -> None:
    print("=" * 78)
    print("4.  Covariance additivity across Chinese-remainder coordinates")
    print("=" * 78)
    for primes, rs in (((5, 7), (1, 1)), ((7, 11), (2, 3)), ((5, 7, 11), (1, 2, 3))):
        M = 1
        for q in primes:
            M *= q
        s_list = [1 for _ in primes]
        N_list = [(r * r) % q for r, q in zip(rs, primes)]
        # skip exceptional coordinates so the generic law applies
        if any((4 * N) % q == 1 for N, q in zip(N_list, primes)):
            continue
        f = [factor_base_count(v, s_list, N_list, primes) for v in range(M)]
        g = [factor_base_count(v + 1, s_list, N_list, primes) for v in range(M)]
        joint = cov(f, g)
        additive = sum(
            cov(hit_indicator(s, N, q), hit_indicator(s, N, q, shift=1))
            for s, N, q in zip(s_list, N_list, primes)
        )
        predicted = -sum(4.0 / q ** 2 for q in primes)
        print(f"factor base {list(primes)} (period {M}):")
        print(f"    joint covariance of the counts : {joint:+.12f}")
        print(f"    sum of per-prime covariances   : {additive:+.12f}")
        print(f"    closed form  -sum 4/q^2        : {predicted:+.12f}")
        assert abs(joint - additive) < 1e-10
        assert abs(joint - predicted) < 1e-10
    print("\nAll cross terms between distinct primes vanish identically.")
    print()


# ----------------------------------------------------------------------------
# Section 5.  The factor-base deficit and its uniform bound
# ----------------------------------------------------------------------------


def odd_primes_upto(limit: int) -> List[int]:
    """All odd primes below `limit` by a simple sieve of Eratosthenes."""
    sieve = [True] * limit
    sieve[0:2] = [False, False]
    for p in range(2, int(limit ** 0.5) + 1):
        if sieve[p]:
            for m in range(p * p, limit, p):
                sieve[m] = False
    return [p for p in range(3, limit) if sieve[p]]


def factor_base_deficit(primes: Iterable[int]) -> float:
    """The accumulated adjacent deficit  sum_i 4/q_i^2."""
    return sum(4.0 / q ** 2 for q in primes)


def demo_factor_base_deficit() -> None:
    print("=" * 78)
    print("5.  The accumulated deficit is O(1): bounded by 2, dominated by 3 and 5")
    print("=" * 78)
    print(f"{'bound B':>9} {'#primes':>8} {'deficit':>12} {'share of 3,5':>14}")
    head = 4.0 / 9 + 4.0 / 25
    for B in (10, 100, 1000, 10_000, 100_000, 1_000_000):
        ps = odd_primes_upto(B)
        d = factor_base_deficit(ps)
        print(f"{B:>9} {len(ps):>8} {d:>12.8f} {head / d:>13.2%}")
    print(f"\nThe telescoping estimate sum_{{m>=3}} 4/m^2 <= 2 caps every base of")
    print(f"distinct odd primes; the true limit over all odd primes is "
          f"{factor_base_deficit(odd_primes_upto(2_000_000)):.6f}.")
    print()


# ----------------------------------------------------------------------------
# Section 6.  Marginal blindness
# ----------------------------------------------------------------------------


def rate(hits: Iterable[Tuple[int, int]], cell: Iterable[Tuple[int, int]]) -> float:
    """Hit rate inside a cell: |H cap C| / |C|."""
    cell = list(cell)
    hitset = set(hits)
    return sum(1 for x in cell if x in hitset) / len(cell)


def enrichment(hits: Sequence[Tuple[int, int]], cell: Sequence[Tuple[int, int]],
               ambient: Sequence[Tuple[int, int]]) -> float:
    """Enrichment ratio: hit rate inside the cell over hit rate outside it."""
    cellset = set(cell)
    complement = [x for x in ambient if x not in cellset]
    return rate(hits, cell) / rate(hits, complement)


def demo_marginal_blindness() -> None:
    print("=" * 78)
    print("6.  A carrier invisible to every marginal feature")
    print("=" * 78)
    n = 12
    ambient = list(product(range(n), range(n)))
    sigma = [(3 * a + 5) % n for a in range(n)]   # a permutation of Z/12
    hits = [(a, sigma[a]) for a in range(n)]
    global_rate = len(hits) / len(ambient)

    features: Dict[str, Callable[[int], int]] = {
        "a mod 2": lambda a: a % 2,
        "a mod 3": lambda a: a % 3,
        "a mod 4": lambda a: a % 4,
        "a is a square": lambda a: int(int(math.isqrt(a)) ** 2 == a),
        "popcount(a) mod 2": lambda a: bin(a).count("1") % 2,
    }
    print(f"global hit rate = {global_rate:.6f}\n")
    print(f"{'feature':<20} {'cell':<8} {'rate':>10} {'enrichment':>12}")
    worst = 0.0
    for name, u in features.items():
        for k in sorted({u(a) for a in range(n)}):
            cell = [x for x in ambient if u(x[0]) == k]
            if len(cell) == len(ambient):
                continue
            e = enrichment(hits, cell, ambient)
            worst = max(worst, abs(e - 1.0))
            print(f"{name:<20} {k:<8} {rate(hits, cell):>10.6f} {e:>12.6f}")
    print(f"\nlargest deviation of any marginal enrichment from 1: {worst:.2e}")
    joint_rate = rate(hits, hits)
    print(f"joint cell (the graph itself): rate = {joint_rate:.6f} "
          f"= {joint_rate / global_rate:.0f} x global rate")
    print("Marginal flatness is therefore no evidence at all against a joint carrier.")
    print()


# ----------------------------------------------------------------------------
# Section 7.  Selection floor and max-statistic calibration
# ----------------------------------------------------------------------------


def scan_max_ratio(hit_cells: Sequence[int], cell_sizes: Sequence[int]) -> float:
    """Largest cell-to-global hit-rate ratio over the scanned cells."""
    total_hits = sum(hit_cells)
    total_size = sum(cell_sizes)
    global_rate = total_hits / total_size
    return max(h / s for h, s in zip(hit_cells, cell_sizes)) / global_rate


def null_max_distribution(n_cells: int, n_positions: int, n_hits: int,
                          clump: int, trials: int,
                          rng: random.Random) -> List[float]:
    """Null distribution of the best-of-`n_cells` enrichment ratio.

    Hits are thrown at the cells in clumps of `clump` at a time.  `clump = 1`
    is the naive independent null; larger values model hits that arrive in
    correlated batches (as they do when detections cluster inside windows),
    which inflates the variance of the cell counts and hence the maximum.
    """
    cell_sizes = [n_positions // n_cells] * n_cells
    for i in range(n_positions - sum(cell_sizes)):
        cell_sizes[i] += 1
    n_clumps = max(1, n_hits // clump)
    cells = range(n_cells)
    maxima: List[float] = []
    for _ in range(trials):
        counts = [0] * n_cells
        for c in rng.choices(cells, weights=cell_sizes, k=n_clumps):
            counts[c] += clump
        maxima.append(scan_max_ratio(counts, cell_sizes))
    maxima.sort()
    return maxima


def demo_max_statistic(trials: int = 400, seed: int = 20260908) -> None:
    print("=" * 78)
    print("7.  Selection floor and max-statistic calibration")
    print("=" * 78)
    rng = random.Random(seed)
    n_cells, n_positions, n_hits = 105, 104_200, 9_594
    observed = 1.5578

    print(f"scan of {n_cells} cells over {n_positions} positions carrying "
          f"{n_hits} hits")
    print(f"observed best cell: R = {observed}\n")
    print(f"{'clump':>6} {'floor':>8} {'median max':>12} {'p95':>8} "
          f"{'P(max >= 1.5578)':>18}")
    for clump in (1, 3, 6, 10):
        maxima = null_max_distribution(n_cells, n_positions, n_hits, clump,
                                       trials, rng)
        median = maxima[len(maxima) // 2]
        p95 = maxima[int(0.95 * len(maxima))]
        p_global = sum(1 for m in maxima if m >= observed) / len(maxima)
        assert maxima[0] >= 1.0, "pigeonhole guarantees the floor"
        print(f"{clump:>6} {maxima[0]:>8.4f} {median:>12.4f} {p95:>8.4f} "
              f"{p_global:>18.3f}")
    print("\nEvery null draw exceeds 1: the floor is a theorem, not a signal, so a")
    print("test of 'best cell > 1' rejects on the whole ensemble and has size 1.")
    print("As the hits become more clustered the null maximum grows, and once the")
    print("null median max exceeds the observation the p-value is at least 1/2 --")
    print("the exact inference that dismissed R = 1.5578 against a median of")
    print("1.6334 in the survey that motivated this work.")
    print()


# ----------------------------------------------------------------------------
# Section 8.  A real sieve trace
# ----------------------------------------------------------------------------


def sqrt_mod_small(N: int, q: int) -> List[int]:
    """All square roots of N mod q, by direct search (q small)."""
    return [r for r in range(q) if (r * r - N) % q == 0]


def sieve_divisor_counts(N: int, base: Sequence[int], length: int) -> List[int]:
    """For v = 0, ..., length-1, the number of base primes dividing y_v."""
    s = math.isqrt(N)
    counts = [0] * length
    for q in base:
        for r in sqrt_mod_small(N % q, q):
            for v in range((r - s) % q, length, q):
                counts[v] += 1
    return counts


def predicted_trace_covariance(N: int, base: Sequence[int]) -> Tuple[float, int, int]:
    """Closed-form adjacent covariance of the divisor count, with a census."""
    total, split, exceptional = 0.0, 0, 0
    for q in base:
        d = len(sqrt_mod_small(N % q, q))
        exc = d > 0 and (4 * N - 1) % q == 0
        total += (1.0 / q if exc else 0.0) - (d / q) ** 2
        split += 1 if d == 2 else 0
        exceptional += 1 if exc else 0
    return total, split, exceptional


def demo_sieve_trace() -> None:
    print("=" * 78)
    print("8.  A real sieve trace: prediction versus measurement")
    print("=" * 78)
    N = 1_000_000_000_039           # a prime near 10^12
    base = odd_primes_upto(500)
    length = 400_000
    counts = sieve_divisor_counts(N, base, length)
    n = length - 1
    mx = sum(counts[:n]) / n
    my = sum(counts[1:]) / n
    empirical = sum(counts[i] * counts[i + 1] for i in range(n)) / n - mx * my
    predicted, split, exceptional = predicted_trace_covariance(N, base)
    print(f"N = {N}")
    print(f"factor base                : odd primes below 500 "
          f"({split} split, {exceptional} exceptional)")
    print(f"positions sieved           : {length}")
    print(f"mean divisor count         : {sum(counts) / length:.6f}")
    print(f"empirical lag-1 covariance : {empirical:+.6f}")
    print(f"predicted (no fitting)     : {predicted:+.6f}")
    print(f"relative discrepancy       : {abs(empirical - predicted) / abs(predicted):.3%}")
    print("\nConsecutive sieve positions genuinely repel, prime by prime, and the")
    print("per-prime deficits add up exactly as the closed form predicts.")
    print()


def main() -> None:
    demo_local_law()
    demo_adjacent_covariance()
    demo_lag_spectrum()
    demo_crt_additivity()
    demo_factor_base_deficit()
    demo_marginal_blindness()
    demo_max_statistic()
    demo_sieve_trace()
    print("All exact identities checked against their closed forms.")


if __name__ == "__main__":
    main()
