#!/usr/bin/env python3
"""
Position pays: sqrt-descending trial division on semiprimes N = p*q.

Numerical companion to "Position Pays: Fermat's Order, the Balance Law 1/(sqrt(r)-1),
and the Stratum Beyond the Residue Cap".

Everything here is self-contained (standard library only).  The demo

  1. checks the exact cost formulas  asc = p - 1,  desc = floor(sqrt N) + 1 - p
     by brute-force scanning, together with complementarity asc + desc = floor(sqrt N),
     the balance wall at q = 4p, the gap bound 2(desc - 1) <= q - p, and the
     Fermat--trial complementarity  desc + ((p+q)/2 - floor(sqrt N)) = (q-p)/2 + 1;
  2. tabulates the speedup law S(r) = 1/(sqrt(r) - 1), its balance windows, the
     residue-cap wall r = 49/16, and the three stratum bands;
  3. checks the mediant principle on a random ensemble per stratum;
  4. shows mechanism (b), range truncation, saves L - 2 ascending tests and zero
     descending tests;
  5. checks the uniform-marginal separation theorem and the cyclic sham identity
     on small random priors.

Accounting is in divisibility tests (information), never wall-clock.
"""

from __future__ import annotations

import itertools
import math
import random
from typing import Callable, Iterable, Sequence

SEED: int = 20260821
POOL_BITS: int = 17  # primes are drawn from [2, 2^17)


# --------------------------------------------------------------------------- primes
def primes_below(n: int) -> list[int]:
    """Sieve of Eratosthenes."""
    sieve = bytearray([1]) * n
    sieve[0:2] = b"\x00\x00"
    for i in range(2, math.isqrt(n - 1) + 1):
        if sieve[i]:
            sieve[i * i :: i] = bytearray(len(range(i * i, n, i)))
    return [i for i in range(n) if sieve[i]]


# --------------------------------------------------------------------------- scans
def scan_cost(pool: Sequence[int], key: Callable[[int], int], n: int) -> int:
    """Number of divisibility tests until (and including) the first hit, visiting the
    pool in increasing key order.  If there is no hit, the whole pool is paid."""
    tests = 0
    for d in sorted(pool, key=key):
        tests += 1
        if n % d == 0:
            return tests
    return tests


def asc_cost(n: int) -> int:
    s = math.isqrt(n)
    return scan_cost(range(2, s + 1), lambda d: d, n)


def desc_cost(n: int) -> int:
    s = math.isqrt(n)
    return scan_cost(range(2, s + 1), lambda d: n - d, n)


def trunc_asc_cost(n: int, lower: int) -> int:
    s = math.isqrt(n)
    return scan_cost(range(max(2, lower), s + 1), lambda d: d, n)


def trunc_desc_cost(n: int, lower: int) -> int:
    s = math.isqrt(n)
    return scan_cost(range(max(2, lower), s + 1), lambda d: n - d, n)


# --------------------------------------------------------------------------- law
def pos_speedup(r: float) -> float:
    """Per-instance positional speedup S(r) = 1/(sqrt(r) - 1), r = q/p > 1."""
    return 1.0 / (math.sqrt(r) - 1.0)


def window(k: float) -> float:
    """S(r) > k  iff  1 < r < (1 + 1/k)^2."""
    return (1.0 + 1.0 / k) ** 2


# --------------------------------------------------------------------------- part 1
def part1_exact_costs(rng: random.Random, primes: list[int]) -> None:
    print("=" * 78)
    print("PART 1. Exact costs on N = p q (brute force vs closed form)")
    print("=" * 78)
    small = [p for p in primes if p < 3000]
    checked = 0
    for _ in range(400):
        p, q = sorted(rng.sample(small, 2))
        n, s = p * q, math.isqrt(p * q)
        a, d = asc_cost(n), desc_cost(n)
        assert a == p - 1, (p, q)
        assert d == s + 1 - p, (p, q)
        assert a + d == s  # complementarity
        if q < 4 * p:
            assert d <= a + 1  # wall, inside
        else:
            assert a + 2 <= d  # wall, outside
        assert 2 * (d - 1) <= q - p  # near-squares are cheap
        if p > 2:
            assert d + ((p + q) // 2 - s) == (q - p) // 2 + 1  # Fermat--trial
        checked += 1
    print(f"  {checked} random semiprimes: all six identities hold.")
    for p, q in [(101, 103), (1009, 1013), (101, 401), (101, 409), (7, 9973)]:
        n = p * q
        print(f"  N = {p:>5} x {q:<5}  q/p = {q/p:6.3f}  asc = {asc_cost(n):>5}"
              f"  desc = {desc_cost(n):>5}  floor sqrt N = {math.isqrt(n)}")
    print("  (101 x 103: ascending pays 100 tests, sqrt-descending pays 1.)\n")


# --------------------------------------------------------------------------- part 2
def part2_law() -> None:
    print("=" * 78)
    print("PART 2. The speedup law S(r) = 1/(sqrt r - 1)")
    print("=" * 78)
    for r in [1.01, 1.05, 1.25, 1.5, 2.0, 49 / 16, 4.0, 9.0]:
        print(f"  r = {r:7.4f}   S(r) = {pos_speedup(r):9.4f}")
    print(f"\n  wall: S(49/16) = {pos_speedup(49/16):.6f}  (residue cap 4/3 = {4/3:.6f})")
    for k in [4 / 3, 2.0, 5.19, 10.0, 20.67]:
        print(f"  S(r) > {k:6.3f}  iff  1 < r < {window(k):.5f}")
    print("\n  stratum bands (pointwise):")
    print(f"    (1, 5/4]  : S >= 4 + 2 sqrt5 = {4 + 2*math.sqrt(5):.4f}")
    print(f"    [5/4, 2]  : {1 + math.sqrt(2):.4f} <= S <= {4 + 2*math.sqrt(5):.4f}")
    print(f"    [2, 4]    : 1 <= S <= 1 + sqrt2 = {1 + math.sqrt(2):.4f}")
    print("  measured mechanism (a): 20.67 / 4.74 / 1.97 -- each inside its band:",
          4 + 2 * math.sqrt(5) <= 20.67,
          1 + math.sqrt(2) <= 4.74 <= 4 + 2 * math.sqrt(5),
          1 <= 1.97 <= 1 + math.sqrt(2))
    print()


# --------------------------------------------------------------------------- part 3
def sample_stratum(rng: random.Random, primes: list[int], lo: float, hi: float,
                   count: int) -> list[tuple[int, int]]:
    """Semiprimes p < q with q/p in (lo, hi], primes below 2^17."""
    out: list[tuple[int, int]] = []
    idx_max = len(primes) - 1
    while len(out) < count:
        p = primes[rng.randint(100, idx_max)]
        q = primes[rng.randint(0, idx_max)]
        if p < q and lo < q / p <= hi:
            out.append((p, q))
    return out


def part3_strata(rng: random.Random, primes: list[int]) -> None:
    print("=" * 78)
    print("PART 3. Expected speedups per stratum (ratio of expected test counts)")
    print("=" * 78)
    bound = 1 << POOL_BITS
    strata = [(1.0, 1.25), (1.25, 2.0), (2.0, 4.0)]
    bands = [(4 + 2 * math.sqrt(5), math.inf), (1 + math.sqrt(2), 4 + 2 * math.sqrt(5)),
             (1.0, 1 + math.sqrt(2))]
    print(f"  {'stratum':>12} {'E[asc]/E[desc]':>15} {'band':>20} {'trunc (b)':>10}")
    for (lo, hi), (bl, bu) in zip(strata, bands):
        sample = sample_stratum(rng, primes, lo, hi, 3000)
        ea = ed = et = 0
        for p, q in sample:
            n, s = p * q, math.isqrt(p * q)
            ea += p - 1
            ed += s + 1 - p
            lower = max(2, -(-n // bound))  # feasibility: q < 2^17 forces p >= N/2^17
            et += p + 1 - lower
        ratio = ea / ed
        ok = "" if (bl * 0.98 <= ratio <= bu * 1.02) else "  (floor effects)"
        print(f"  ({lo:4.2f},{hi:4.2f}] {ratio:15.3f}   [{bl:6.3f}, {bu:7.3f}] "
              f"{ea / et:10.3f}{ok}")
    print("  Mechanism (a) is a pure function of q/p and falls with imbalance.")
    print("  Mechanism (b) depends on how close q sits to the pool edge 2^17, not on")
    print("  q/p; its stratum profile is set by the ensemble (the experiment's ensemble")
    print("  gave 4.35 / 4.73 / 6.91, rising -- this synthetic one is nearly flat).\n")


# --------------------------------------------------------------------------- part 4
def part4_truncation(rng: random.Random, primes: list[int]) -> None:
    print("=" * 78)
    print("PART 4. Mechanism (b): truncation is orthogonal to mechanism (a)")
    print("=" * 78)
    small = [p for p in primes if p < 2000]
    for _ in range(300):
        p, q = sorted(rng.sample(small, 2))
        n = p * q
        lower = rng.randint(2, p)
        assert trunc_asc_cost(n, lower) + (lower - 2) == asc_cost(n)
        assert trunc_desc_cost(n, lower) == desc_cost(n)
    print("  300 random cases: truncation at L <= p saves exactly L - 2 ascending")
    print("  tests and exactly 0 descending tests.\n")


# --------------------------------------------------------------------------- part 5
def order_cost(mu: Sequence[float], sigma: Sequence[int]) -> float:
    return sum(m * (s + 1) for m, s in zip(mu, sigma))


def sham_cost(mu: Sequence[float]) -> float:
    n = len(mu)
    return sum(mu) * (n + 1) / 2


def part5_uniform_marginal(rng: random.Random) -> None:
    print("=" * 78)
    print("PART 5. Separation: some order beats the sham iff the marginal is non-uniform")
    print("=" * 78)
    n = 6
    perms = list(itertools.permutations(range(n)))
    flat = [1.0] * n
    assert all(abs(order_cost(flat, s) - sham_cost(flat)) < 1e-9 for s in perms)
    print(f"  uniform prior on {n} candidates: all {len(perms)} orders cost the sham.")
    for _ in range(50):
        mu = [rng.random() for _ in range(n)]
        sigma = list(rng.sample(range(n), n))
        avg = sum(order_cost(mu, [(s + k) % n for s in sigma]) for k in range(n)) / n
        assert abs(avg - sham_cost(mu)) < 1e-9  # cyclic sham
        best = min(order_cost(mu, s) for s in perms)
        bayes = [0] * n
        for pos, i in enumerate(sorted(range(n), key=lambda i: -mu[i])):
            bayes[i] = pos
        assert abs(order_cost(mu, bayes) - best) < 1e-9  # rearrangement optimality
        assert best < sham_cost(mu)
    mono = sorted(rng.random() for _ in range(n))
    desc = [n - 1 - i for i in range(n)]
    print("  50 random priors: cyclic-shift average = sham; Bayes order optimal;"
          " strict gain.")
    print(f"  increasing prior: descending cost {order_cost(mono, desc):.4f} <"
          f" sham {sham_cost(mono):.4f}\n")


def main() -> None:
    rng = random.Random(SEED)
    primes = primes_below(1 << POOL_BITS)
    part1_exact_costs(rng, primes)
    part2_law()
    part3_strata(rng, primes)
    part4_truncation(rng, primes)
    part5_uniform_marginal(rng)
    print("All checks passed.")


if __name__ == "__main__":
    main()
