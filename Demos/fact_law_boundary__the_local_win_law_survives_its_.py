#!/usr/bin/env python3
"""
Counted versus uncounted cost in Pollard's rho: Brent vs Floyd, and the
gcd(E, p-1) = 1 automorphism cliff.

Self-contained numerical companion to the paper.  Every function is inlined;
only the Python standard library is used.  Run:  python3 demo.py
"""
from __future__ import annotations

import math
import random
import statistics
from typing import Callable, Dict, List, Tuple

# ---------------------------------------------------------------------------
# 1. Closed-form detector costs on a rho shape (tail mu, period lam)
# ---------------------------------------------------------------------------


def floyd_index(mu: int, lam: int) -> int:
    """Least i > 0 with i >= mu and lam | i (Floyd's stopping index)."""
    return lam * max(1, -(-mu // lam))


def brent_round(mu: int, lam: int) -> int:
    """Least k with mu < 2^k and lam <= 2^k (Brent's stopping round)."""
    k = 0
    while not (mu < (1 << k) and lam <= (1 << k)):
        k += 1
    return k


def floyd_costs(mu: int, lam: int) -> Tuple[int, int]:
    """(evaluations, comparisons) for Floyd: 3 evaluations and 1 comparison per index."""
    f = floyd_index(mu, lam)
    return 3 * f, f


def brent_costs(mu: int, lam: int) -> Tuple[int, int]:
    """(evaluations, comparisons) for power-of-two Brent: 1 + 1 per step."""
    k = brent_round(mu, lam)
    evals = (1 << k) - 1 + lam
    comps = sum(1 << i for i in range(k)) + lam
    assert comps == evals  # geometric series identity
    return evals, comps


# ---------------------------------------------------------------------------
# 2. Literal simulation of both detectors on an arbitrary sequence
# ---------------------------------------------------------------------------


def make_rho_sequence(mu: int, lam: int) -> Callable[[int], int]:
    """A concrete rho-shaped sequence x_i (values are labels 0..mu+lam-1)."""
    def x(i: int) -> int:
        return i if i < mu else mu + (i - mu) % lam
    return x


def simulate_floyd(x: Callable[[int], int]) -> Tuple[int, int]:
    i = 1
    while x(i) != x(2 * i):
        i += 1
    return 3 * i, i


def simulate_brent(x: Callable[[int], int]) -> Tuple[int, int]:
    comps, k = 0, 0
    while True:
        saved = x((1 << k) - 1)
        for j in range(1, (1 << k) + 1):
            comps += 1
            if saved == x((1 << k) - 1 + j):
                return (1 << k) - 1 + j, comps
        k += 1


def demo_survivor_and_boundary() -> None:
    print("=" * 72)
    print("1. THE SURVIVOR AND THE UNCOUNTED CHANNEL (exact, all shapes mu<=150, lam<=150)")
    print("=" * 72)
    worst_ratio, worst_shape = 0.0, (0, 1)
    n_shapes = 0
    for mu in range(0, 151):
        for lam in range(1, 151):
            fe, fc = floyd_costs(mu, lam)
            be, bc = brent_costs(mu, lam)
            if mu <= 40 and lam <= 40:  # cross-check closed forms by simulation
                x = make_rho_sequence(mu, lam)
                assert simulate_floyd(x) == (fe, fc)
                assert simulate_brent(x) == (be, bc)
            assert be + 1 <= 2 * floyd_index(mu, lam) + lam <= fe  # sharp survivor bound
            assert be < fe                                         # Brent wins evaluations
            assert fc <= bc                                        # Floyd wins comparisons
            r = be / fe
            if r > worst_ratio:
                worst_ratio, worst_shape = r, (mu, lam)
            n_shapes += 1
    print(f"  checked {n_shapes} rho shapes: Brent evals < Floyd evals on every one,")
    print(f"  Floyd comparisons <= Brent comparisons on every one.")
    print(f"  worst counted ratio brent/floyd = {worst_ratio:.4f} at (mu, lam) = {worst_shape}")
    print()
    print("  Sharpness: pure cycles of length 2^m + 1 (Brent saves 3 evals, overruns comps)")
    print(f"  {'m':>3} {'lam':>6} {'F evals':>8} {'F comps':>8} {'B evals':>8} {'B comps':>8}"
          f" {'saved':>6} {'overrun':>8}")
    for m in range(1, 11):
        lam = (1 << m) + 1
        fe, fc = floyd_costs(0, lam)
        be, bc = brent_costs(0, lam)
        print(f"  {m:>3} {lam:>6} {fe:>8} {fc:>8} {be:>8} {bc:>8} {fe - be:>6} {bc - fc:>8}")
    a, b = 1.0, 0.05  # a comparison costing 5% of an evaluation
    m = next(m for m in range(1, 64) if 3 * a + 3 * b < b * 2 ** m)
    lam = (1 << m) + 1
    fe, fc = floyd_costs(0, lam)
    be, bc = brent_costs(0, lam)
    print(f"\n  With a={a}, b={b}: at lam = 2^{m}+1 = {lam},"
          f" Floyd wall = {a*fe + b*fc:.2f} < Brent wall = {a*be + b*bc:.2f}")
    print()


# ---------------------------------------------------------------------------
# 3. The automorphism cliff for x -> x^E + c on Z/pZ
# ---------------------------------------------------------------------------


def is_prime(n: int) -> bool:
    if n < 2:
        return False
    for q in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
        if n % q == 0:
            return n == q
    d, s = n - 1, 0
    while d % 2 == 0:
        d //= 2
        s += 1
    for a in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
        y = pow(a, d, n)
        if y in (1, n - 1):
            continue
        for _ in range(s - 1):
            y = y * y % n
            if y == n - 1:
                break
        else:
            return False
    return True


def closure_time(seed: int, E: int, c: int, p: int) -> int:
    """mu + lam: the index of the first repeated point of the orbit of seed."""
    seen: Dict[int, int] = {}
    x, i = seed, 0
    while x not in seen:
        seen[x] = i
        x = (pow(x, E, p) + c) % p
        i += 1
    return i


def demo_cliff_criterion() -> None:
    print("=" * 72)
    print("2. THE CLIFF CRITERION: x^E + c permutes Z/pZ  <=>  gcd(E, p-1) = 1")
    print("=" * 72)
    checked = 0
    for p in [q for q in range(3, 200) if is_prime(q)]:
        for E in range(1, 13):
            image = {(pow(x, E, p) + 1) % p for x in range(p)}
            bij = len(image) == p
            assert bij == (math.gcd(E, p - 1) == 1)
            # compression bound: closure time <= (p-1)/d + 2
            d = math.gcd(E, p - 1)
            for seed in range(0, p, max(1, p // 7)):
                assert closure_time(seed, E, 1, p) <= (p - 1) // d + 2
            checked += 1
    print(f"  criterion and compression bound confirmed on {checked} (p, E) pairs, p < 200")
    for p in (101, 65537):
        assert all(closure_time(a, 1, 1, p) == p for a in range(0, p, max(1, p // 50)))
    print("  successor map x -> x + 1: closure time exactly p (checked p = 101, 65537)")
    p = 65537
    print(f"  p = 65537 = 2^16 + 1: gcd(3, p-1) = {math.gcd(3, p - 1)} -> x^3 + c is a permutation;"
          f" gcd(2, p-1) = {math.gcd(2, p - 1)} -> x^2 + c compresses,")
    print(f"  every x^2 + c orbit closes within (p-1)/2 + 2 = {(p - 1) // 2 + 2} steps.")
    print()


def demo_cliff_measured(trials: int = 60, rng: random.Random = random.Random(7)) -> None:
    print("=" * 72)
    print("3. THE CLIFF MEASURED: mean closure time / sqrt(p) at p = 65537")
    print("=" * 72)
    p = 65537
    for E in (2, 3, 4, 5, 6):
        d = math.gcd(E, p - 1)
        ts = [closure_time(rng.randrange(p), E, rng.randrange(1, p - 2), p) for _ in range(trials)]
        regime = "PERMUTATION (pure cycles)" if d == 1 else f"compressing, d = {d}"
        print(f"  E = {E}:  mean = {statistics.mean(ts)/math.sqrt(p):7.2f} sqrt(p),"
              f" median = {statistics.median(ts)/math.sqrt(p):7.2f} sqrt(p)   [{regime}]")
    t2 = statistics.mean(closure_time(rng.randrange(p), 2, rng.randrange(1, p - 2), p)
                         for _ in range(trials))
    t3 = statistics.mean(closure_time(rng.randrange(p), 3, rng.randrange(1, p - 2), p)
                         for _ in range(trials))
    print(f"  ratio cube/square closure time (fresh sample): {t3 / t2:.1f}x")
    print(f"  birthday reference sqrt(pi/2) = {math.sqrt(math.pi / 2):.4f}")
    print()
    print("  Split by gcd(3, p-1) for primes p near 2^14 (x^3 + c):")
    primes = [q for q in range(16000, 17500) if is_prime(q)]
    auto, comp = [], []
    for q in primes[:80]:
        t = closure_time(rng.randrange(q), 3, rng.randrange(1, q - 2), q) / math.sqrt(q)
        (auto if math.gcd(3, q - 1) == 1 else comp).append(t)
    print(f"  automorphism primes (p = 2 mod 3): median {statistics.median(auto):.2f} sqrt(p)"
          f"   ({len(auto)} primes)")
    print(f"  compressing  primes (p = 1 mod 3): median {statistics.median(comp):.2f} sqrt(p)"
          f"   ({len(comp)} primes)")
    print()


# ---------------------------------------------------------------------------
# 4. Pollard rho factoring with both channels counted
# ---------------------------------------------------------------------------


def rho_floyd(n: int, c: int, x0: int) -> Tuple[int, int, int]:
    """Return (factor, multiplications, gcds) for Floyd-driven rho with x^2 + c."""
    x = y = x0
    muls = gcds = 0
    while True:
        x = (x * x + c) % n
        y = (y * y + c) % n
        y = (y * y + c) % n
        muls += 3
        gcds += 1
        g = math.gcd(abs(x - y), n)
        if g != 1:
            return g, muls, gcds


def rho_brent(n: int, c: int, x0: int) -> Tuple[int, int, int]:
    """Return (factor, multiplications, gcds) for power-of-two Brent with x^2 + c."""
    saved, x = x0, x0
    muls = gcds = 0
    k = 0
    while True:
        for _ in range(1 << k):
            x = (x * x + c) % n
            muls += 1
            gcds += 1
            g = math.gcd(abs(x - saved), n)
            if g != 1:
                return g, muls, gcds
        saved = x
        k += 1


def random_prime(bits: int, rng: random.Random) -> int:
    while True:
        q = rng.getrandbits(bits) | (1 << (bits - 1)) | 1
        if is_prime(q):
            return q


def demo_factoring(runs: int = 300, rng: random.Random = random.Random(2026)) -> None:
    print("=" * 72)
    print("4. POLLARD RHO ON SEMIPRIMES: counted (muls) and uncounted (gcds) channels")
    print("=" * 72)
    ratios_mul: List[float] = []
    ratios_gcd: List[float] = []
    fm: List[float] = []
    bm: List[float] = []
    good = 0
    while good < runs:
        p, q = random_prime(18, rng), random_prime(24, rng)
        n, c, x0 = p * q, rng.randrange(1, 1000), rng.randrange(2, 1000)
        gf, mf, cf = rho_floyd(n, c, x0)
        gb, mb, cb = rho_brent(n, c, x0)
        if gf in (1, n) or gb in (1, n):  # trivial collision: not a success, discard
            continue
        good += 1
        s = math.sqrt(min(p, q))
        fm.append(mf / s)
        bm.append(mb / s)
        ratios_mul.append(mb / mf)
        ratios_gcd.append(cb / cf)
    print(f"  {runs} paired runs, smallest factor ~2^18")
    print(f"  Floyd muls/sqrt(p) = {statistics.mean(fm):.3f} +- {statistics.stdev(fm):.3f}")
    print(f"  Brent muls/sqrt(p) = {statistics.mean(bm):.3f} +- {statistics.stdev(bm):.3f}")
    print(f"  paired Brent/Floyd multiplications = {statistics.mean(ratios_mul):.4f}"
          f"   (counted channel: Brent wins)")
    print(f"  paired Brent/Floyd gcds            = {statistics.mean(ratios_gcd):.4f}"
          f"   (uncounted channel: moves the other way in this textbook variant)")
    print(f"  max paired mul ratio = {max(ratios_mul):.4f}  (never crosses 1, as the survivor theorem predicts)")
    print()


def demo_birthday(trials: int = 4000, n: int = 1 << 16,
                  rng: random.Random = random.Random(11)) -> None:
    print("=" * 72)
    print("5. BIRTHDAY CONSTANT: first repeat of uniform draws from n items")
    print("=" * 72)
    tot = 0
    for _ in range(trials):
        seen = set()
        while True:
            v = rng.randrange(n)
            if v in seen:
                break
            seen.add(v)
        tot += len(seen)
    print(f"  mean first-repeat index / sqrt(n) = {tot / trials / math.sqrt(n):.4f};"
          f"  sqrt(pi/2) = {math.sqrt(math.pi / 2):.4f}")
    print()


if __name__ == "__main__":
    demo_survivor_and_boundary()
    demo_cliff_criterion()
    demo_cliff_measured()
    demo_factoring()
    demo_birthday()
