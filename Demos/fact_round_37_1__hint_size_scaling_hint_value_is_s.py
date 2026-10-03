#!/usr/bin/env python3
"""
Hint-size scaling: numerical companion.

This script illustrates, with exact enumeration and seeded simulation, the results of
"The Hint Value Has No Size Law":

  1. The hint value I(L; P) - I(L; N) is computed by exact counting on finite
     uniform sample spaces (the population law).
  2. Size-stability: replicating every residue class by any number of prime
     identities leaves the hint value exactly unchanged.
  3. The residue lift: the S3 hint value is exactly 1/2 on the full residue box
     mod 31, on the 36-point dial box, and at every other conductor.
  4. Closed-form plateaus for S3, C3, D4, C5 and their residual entropies.
  5. Pool leakage: thin prime pools can only inflate the hint value, at most up to
     the ceiling H(L | N); a one-prime-per-class pool reaches that ceiling.
  6. Plug-in bias: finite samples of n = 15000 read the S3 plateau ~0.04 bits high.
  7. The which-factor wall: the conditional orientation statistic is exactly 0,
     while a naive unconditional statistic can read a full bit.

Only the Python standard library is used.
"""
from __future__ import annotations

import itertools
import math
import random
from collections import Counter
from typing import Callable, Hashable, Iterable, List, Sequence, Tuple, TypeVar

T = TypeVar("T")
log2 = math.log2


# ---------------------------------------------------------------------------
# 1. Counting entropies on a finite sample (uniform measure on a list)
# ---------------------------------------------------------------------------

def entropy(sample: Sequence[T], f: Callable[[T], Hashable]) -> float:
    """Plug-in Shannon entropy (bits) of the read-out f under the uniform law on sample."""
    n = len(sample)
    counts = Counter(f(x) for x in sample)
    return -sum(c / n * log2(c / n) for c in counts.values())


def cond_entropy(sample: Sequence[T], f: Callable[[T], Hashable],
                 g: Callable[[T], Hashable]) -> float:
    """H(f | g) = H(f, g) - H(g)."""
    return entropy(sample, lambda x: (f(x), g(x))) - entropy(sample, g)


def mutual_info(sample: Sequence[T], f: Callable[[T], Hashable],
                g: Callable[[T], Hashable]) -> float:
    """I(f ; g) = H(f) - H(f | g)."""
    return entropy(sample, f) - cond_entropy(sample, f, g)


def hint(sample: Sequence[T], L: Callable[[T], Hashable], P: Callable[[T], Hashable],
         N: Callable[[T], Hashable]) -> float:
    """Hint value I(L; P) - I(L; N): what the factor-pair view adds beyond the product view."""
    return mutual_info(sample, L, P) - mutual_info(sample, L, N)


# ---------------------------------------------------------------------------
# 2. Residue arithmetic
# ---------------------------------------------------------------------------

def units(m: int) -> List[int]:
    return [a for a in range(1, m) if math.gcd(a, m) == 1]


def legendre(a: int, p: int) -> int:
    """Legendre symbol (a / p) in {+1, -1} for a coprime to the odd prime p."""
    return 1 if pow(a, (p - 1) // 2, p) == 1 else -1


# ---------------------------------------------------------------------------
# 3. The four dials (population models)
#    A sample point is ((a, b), (c1, c2)): residues of p and q plus Frobenius coins.
# ---------------------------------------------------------------------------

def s3_roots(sign: int, coin: int) -> int:
    """Root count of an S3 cubic mod p: non-residue -> transposition (1 root);
    residue -> identity (3 roots) with coin 0 of 3, 3-cycle (0 roots) otherwise."""
    if sign == -1:
        return 1
    return 3 if coin == 0 else 0


def s3_box(m: int) -> List[Tuple[Tuple[int, int], Tuple[int, int]]]:
    """Full residue box ((Z/m)^x)^2 x (Fin 3)^2 for an S3 field with quadratic dial mod m."""
    return [((a, b), (c1, c2)) for a in units(m) for b in units(m)
            for c1 in range(3) for c2 in range(3)]


def s3_views(m: int):
    def L(x):
        (a, b), (c1, c2) = x
        r = (s3_roots(legendre(a, m), c1), s3_roots(legendre(b, m), c2))
        return (min(r), max(r))

    def P(x):
        return x[0]

    def N(x):
        return (x[0][0] * x[0][1]) % m
    return L, P, N


def s3_dial_box() -> list:
    """The 36-point dial box {+-1}^2 x (Fin 3)^2."""
    return [((s, t), (c1, c2)) for s in (1, -1) for t in (1, -1)
            for c1 in range(3) for c2 in range(3)]


def s3_dial_views():
    def L(x):
        (s, t), (c1, c2) = x
        r = (s3_roots(s, c1), s3_roots(t, c2))
        return (min(r), max(r))
    return L, (lambda x: x[0]), (lambda x: x[0][0] * x[0][1])


def d4_roots(h: int, coin: int) -> int:
    """Root count of x^4 - 2 mod p as a function of p mod 8 and a coin."""
    if h == 1:
        return 4 if coin == 0 else 0
    if h == 7:
        return 2
    return 0


def d4_box() -> list:
    return [((a, b), (c1, c2)) for a in units(8) for b in units(8)
            for c1 in range(2) for c2 in range(2)]


def d4_views():
    def L(x):
        (a, b), (c1, c2) = x
        r = (d4_roots(a, c1), d4_roots(b, c2))
        return (min(r), max(r))
    return L, (lambda x: x[0]), (lambda x: (x[0][0] * x[0][1]) % 8)


def cyc_box(f: int) -> list:
    return [((a, b), ()) for a in units(f) for b in units(f)]


def cyc_views(f: int, n: int):
    def deg(a: int) -> int:
        return 1 if a in (1, f - 1) else n

    def L(x):
        r = (deg(x[0][0]), deg(x[0][1]))
        return (min(r), max(r))
    return L, (lambda x: x[0]), (lambda x: (x[0][0] * x[0][1]) % f)


# ---------------------------------------------------------------------------
# Sections of the demo
# ---------------------------------------------------------------------------

def section(title: str) -> None:
    print("\n" + "=" * 78 + f"\n{title}\n" + "=" * 78)


def demo_plateaus() -> None:
    section("A. Exact plateaus and residuals (population law)")
    L3 = log2(3)
    L5 = log2(5)
    rows = [
        ("S3@31", s3_box(31), s3_views(31), 0.5, L3 - 7 / 9, (0.5584, 0.5425, 0.5415)),
        ("C3@7", cyc_box(7), cyc_views(7, 3), L3 - 2 / 3, 0.0, (0.9115, 0.9140, 0.9169)),
        ("D4@8", d4_box(), d4_views(), 1.5 - 9 / 32 * L3, 15 / 32, (1.0540, 1.0536, 1.0507)),
        ("C5@11", cyc_box(11), cyc_views(11, 5), L5 - 12 / 25 * L3 - 16 / 25, 0.0,
         (0.9030, 0.9190, 0.9268)),
    ]
    print(f"{'dial':7s} {'|box|':>6s} {'hint (enum)':>12s} {'closed form':>12s} "
          f"{'H(L|P)':>8s} {'closed':>8s}   reported k=14/18/22")
    for name, box, (L, P, N), exact, resid, rep in rows:
        h = hint(box, L, P, N)
        r = cond_entropy(box, L, P)
        print(f"{name:7s} {len(box):6d} {h:12.6f} {exact:12.6f} {r:8.4f} {resid:8.4f}   "
              + " / ".join(f"{v:.4f}" for v in rep))
        assert abs(h - exact) < 1e-9 and abs(r - resid) < 1e-9


def demo_residue_lift() -> None:
    section("B. Residue lift: the S3 plateau is 1/2 at every conductor")
    L, P, N = s3_dial_views()
    print(f"36-point dial box             : hint = {hint(s3_dial_box(), L, P, N):.9f}")
    for m in (7, 11, 19, 23, 31, 43):
        box = s3_box(m)
        L, P, N = s3_views(m)
        print(f"full residue box mod {m:3d} ({len(box):6d} pts): hint = {hint(box, L, P, N):.9f}")


def demo_blowup() -> None:
    section("C. Size-stability: replicate each residue class by K prime identities")
    base = s3_box(31)
    L, P, N = s3_views(31)
    for K in (1, 2, 5, 16):
        blown = [(x, j) for x in base for j in range(K)]
        h = hint(blown, lambda y: L(y[0]), lambda y: P(y[0]), lambda y: N(y[0]))
        print(f"K = {K:3d}  |sample| = {len(blown):7d}   hint = {h:.12f}")


def make_pool(r: int, m: int, rng: random.Random) -> List[Tuple[int, int]]:
    """A pool of primes: r per residue class mod m, each with a Chebotarev-drawn root count."""
    pool = []
    for a in units(m):
        for _ in range(r):
            pool.append((a, s3_roots(legendre(a, m), rng.randrange(3))))
    return pool


def pool_hint(pool: List[Tuple[int, int]], m: int) -> Tuple[float, float]:
    """Exact (hint, H(L | N)) over all ordered pairs of distinct pool primes."""
    pairs = [(pool[i], pool[j]) for i in range(len(pool)) for j in range(len(pool)) if i != j]
    L = lambda x: (min(x[0][1], x[1][1]), max(x[0][1], x[1][1]))
    P = lambda x: (x[0][0], x[1][0])
    N = lambda x: (x[0][0] * x[1][0]) % m
    return hint(pairs, L, P, N), cond_entropy(pairs, L, N)


def demo_pool_floor() -> None:
    section("D. Pool leakage (seeded simulation; inflation is bounded by H(L|N))")
    ceiling = log2(3) - 5 / 18
    print(f"plateau = 0.5, ceiling H(L | N mod 31) = log2(3) - 5/18 = {ceiling:.4f}")
    print("(the anomalous k=10 reading 0.7423 lies strictly in between)")
    print("Theorem: on any pool, hint <= that pool's H(L|N), with equality when r = 1.")
    rng = random.Random(20260821)
    for r in (1, 2, 3, 5, 8):
        vals = [pool_hint(make_pool(r, 31, rng), 31) for _ in range(3)]
        print(f"r = {r} primes/class : (hint, pool's own H(L|N)) = "
              + ", ".join(f"({h:.4f}, {c:.4f})" for h, c in vals))
        assert all(h <= c + 1e-9 for h, c in vals)


def demo_plugin_bias() -> None:
    section("E. Plug-in bias at n = 15000 (seeded simulation of the ideal law)")
    m, n = 31, 15000
    L, P, N = s3_views(m)
    U = units(m)
    rng = random.Random(20260821)
    for rep in range(3):
        sample = [((rng.choice(U), rng.choice(U)), (rng.randrange(3), rng.randrange(3)))
                  for _ in range(n)]
        print(f"replicate {rep + 1}: plug-in hint = {hint(sample, L, P, N):.4f}")
    print(f"Miller-Madow bias estimate 840 / (2 n ln 2) = {840 / (2 * n * math.log(2)):.4f}")


def demo_wall() -> None:
    section("F. The which-factor wall and the instrument lesson")
    # Ordered semiprime battery from small primes: both orientations present.
    primes = [p for p in range(7, 400) if all(p % d for d in range(2, int(p ** 0.5) + 1))]
    battery = [(p, q) for p, q in itertools.permutations(primes, 2)]
    O = lambda x: x[0] < x[1]
    V = lambda x: ((x[0] * x[1]) % 31, min(x[0] % 31, x[1] % 31), max(x[0] % 31, x[1] % 31))
    print(f"swap-invariant battery of {len(battery)} ordered pairs")
    print(f"conditional statistic I(O ; N mod 31, unordered residues) = "
          f"{mutual_info(battery, O, V):.2e}")
    tiny = [(2, 3), (3, 2)]
    print(f"two-point battery {{(2,3),(3,2)}}: naive I(O ; p mod 5) = "
          f"{mutual_info(tiny, O, lambda x: x[0] % 5):.4f} bit")
    print(f"                              conditional I(O ; symmetric view) = "
          f"{mutual_info(tiny, O, lambda x: ((x[0]*x[1]) % 5, min(x[0] % 5, x[1] % 5), max(x[0] % 5, x[1] % 5))):.4f}")


def main() -> None:
    demo_plateaus()
    demo_residue_lift()
    demo_blowup()
    demo_pool_floor()
    demo_plugin_bias()
    demo_wall()


if __name__ == "__main__":
    main()
