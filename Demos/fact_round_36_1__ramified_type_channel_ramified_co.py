#!/usr/bin/env python3
"""
Ramified primes carry negligible information
=============================================

Numerical companion to "Ramified Primes Are Information-Theoretically Negligible".

For a finite sample S of primes and two read-outs g (splitting type) and k (residue
class), the *counting channel* is the empirical mutual information I_S(g ; k) of the
uniform distribution on S.  We demonstrate:

  1. The fibre log-sum identity  N * I(g;k) = N log2 N - Lam(g) - Lam(k) + Lam(k,g).
  2. The x^2 - 3 experiment: including the ramified primes {2, 3} moves the
     residue-to-type channel by about +0.002 bits.
  3. The universal bound |I_{U u R} - I_U| <= (|R|/N)(3 log2 N + 2/ln 2), tested on the
     experiment and on thousands of random channels.
  4. Sharpness: an explicit configuration achieving (r/N) log2 N.
  5. The certified regime: r <= 2 ramified points among N >= 2^16 points move the
     channel by at most 0.002 bits.

Pure Python 3, no third-party dependencies.
"""
from __future__ import annotations

import math
import random
from collections import Counter
from typing import Callable, Hashable, Sequence, TypeVar

T = TypeVar("T")
LN2: float = math.log(2.0)


# ---------------------------------------------------------------------------
# Counting entropies via fibre log-sums
# ---------------------------------------------------------------------------
def fibre_log_sum(sample: Sequence[T], read: Callable[[T], Hashable]) -> float:
    """Lam(s, g) = sum_{a in s} log2 |{x in s : g(x) = g(a)}| = sum_v c_v log2 c_v."""
    counts = Counter(read(x) for x in sample)
    return sum(c * math.log2(c) for c in counts.values())


def entropy(sample: Sequence[T], read: Callable[[T], Hashable]) -> float:
    """H_s(g) = log2 N - Lam(s, g) / N  (empirical Shannon entropy, in bits)."""
    n = len(sample)
    return 0.0 if n == 0 else math.log2(n) - fibre_log_sum(sample, read) / n


def mutual_information(sample: Sequence[T], g: Callable[[T], Hashable],
                       k: Callable[[T], Hashable]) -> float:
    """I_s(g;k) = (N log2 N - Lam(g) - Lam(k) + Lam(k,g)) / N."""
    n = len(sample)
    if n == 0:
        return 0.0
    lam_g = fibre_log_sum(sample, g)
    lam_k = fibre_log_sum(sample, k)
    lam_kg = fibre_log_sum(sample, lambda x: (k(x), g(x)))
    return (n * math.log2(n) - lam_g - lam_k + lam_kg) / n


def ramified_bound(r: int, n: int) -> float:
    """B(r, N) = (r / N) * (3 log2 N + 2 / ln 2)."""
    return 0.0 if n == 0 else r / n * (3 * math.log2(n) + 2 / LN2)


# ---------------------------------------------------------------------------
# Primes and the splitting type of x^2 - 3
# ---------------------------------------------------------------------------
def primes_up_to(x: int) -> list[int]:
    sieve = bytearray([1]) * (x + 1)
    sieve[0:2] = b"\x00\x00"
    for p in range(2, int(x ** 0.5) + 1):
        if sieve[p]:
            sieve[p * p::p] = bytearray(len(sieve[p * p::p]))
    return [i for i in range(x + 1) if sieve[i]]


def splitting_type_x2_minus_3(p: int) -> str:
    """Factorisation pattern of x^2 - 3 modulo p."""
    if p in (2, 3):
        return "ramified"            # x^2-3 = (x+1)^2 mod 2,  x^2 mod 3
    return "split" if pow(3, (p - 1) // 2, p) == 1 else "inert"


def residue12(p: int) -> int:
    return p % 12


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------
def demo_identity() -> None:
    print("1. Fibre log-sum identity  N*I = N log2 N - Lam(g) - Lam(k) + Lam(k,g)")
    rng = random.Random(1)
    sample = list(range(200))
    g_tab = {x: rng.randrange(4) for x in sample}
    k_tab = {x: rng.randrange(6) for x in sample}
    g, k = g_tab.__getitem__, k_tab.__getitem__
    n = len(sample)
    lhs = n * mutual_information(sample, g, k)
    h_direct = entropy(sample, g) - (entropy(sample, lambda x: (k(x), g(x))) - entropy(sample, k))
    print(f"   N*I via fibre sums = {lhs:.10f};  N*(H(g) - H(g|k)) = {n * h_direct:.10f}\n")


def demo_x2_minus_3() -> None:
    print("2. The x^2 - 3 experiment (residue p mod 12 -> splitting type)")
    print(f"   {'X':>9} {'N':>7} {'I(all)':>9} {'I(unram)':>9} {'gap':>9} {'bound':>9}")
    for x in (10 ** 3, 10 ** 4, 10 ** 5, 10 ** 6):
        ps = primes_up_to(x)
        unram = [p for p in ps if p not in (2, 3)]
        i_all = mutual_information(ps, splitting_type_x2_minus_3, residue12)
        i_un = mutual_information(unram, splitting_type_x2_minus_3, residue12)
        b = ramified_bound(2, len(ps))
        assert abs(i_all - i_un) <= b
        print(f"   {x:>9} {len(ps):>7} {i_all:9.4f} {i_un:9.4f} {i_all - i_un:+9.5f} {b:9.5f}")
    print("   (the gap is always inside the proved bound and shrinks like log N / N)\n")


def demo_random_channels(trials: int = 3000) -> None:
    print("3. Universal bound on random channels")
    rng = random.Random(2026)
    worst = 0.0
    for _ in range(trials):
        u = rng.randint(1, 300)
        r = rng.randint(0, 6)
        pts = list(range(u + r))
        U, R = pts[:u], pts[u:]
        ng, nk = rng.randint(1, 8), rng.randint(1, 8)
        g_tab = {x: rng.randrange(ng) for x in pts}
        k_tab = {x: rng.randrange(nk) for x in pts}
        # make ramified points adversarial half of the time
        if rng.random() < 0.5:
            for x in R:
                g_tab[x] = ("ram", x)
                k_tab[x] = ("ram", x)
        g, k = g_tab.__getitem__, k_tab.__getitem__
        gap = abs(mutual_information(pts, g, k) - mutual_information(U, g, k))
        b = ramified_bound(r, len(pts))
        assert gap <= b + 1e-12
        if b > 0:
            worst = max(worst, gap / b)
    print(f"   {trials} random channels: bound never violated; max(gap/bound) = {worst:.3f}\n")


def demo_sharpness() -> None:
    print("4. Sharpness: unramified points share one type, ramified points all distinct")
    print(f"   {'N':>8} {'r':>3} {'gain':>10} {'(r/N)log2N':>11} {'bound':>10}")
    for n, r in ((100, 1), (1000, 2), (10 ** 4, 2), (10 ** 5, 5)):
        u = n - r
        t = lambda x, u=u: 0 if x < u else x + 1
        pts = list(range(n))
        gain = mutual_information(pts, t, t) - mutual_information(pts[:u], t, t)
        low = r / n * math.log2(n)
        assert gain >= low - 1e-12
        print(f"   {n:>8} {r:>3} {gain:10.6f} {low:11.6f} {ramified_bound(r, n):10.6f}")
    print("   (the gain always exceeds (r/N) log2 N: the log N / N rate is optimal)\n")


def demo_certified_regime() -> None:
    print("5. Certified regime: r <= 2, N >= 2^16  =>  change <= 0.002 bits")
    for n in (2 ** 16, 2 ** 18, 2 ** 20):
        print(f"   N = {n:>8}:  B(2, N) = {ramified_bound(2, n):.6f}  <= 0.002")
    print()


if __name__ == "__main__":
    demo_identity()
    demo_x2_minus_3()
    demo_random_channels()
    demo_sharpness()
    demo_certified_regime()
