#!/usr/bin/env python3
"""
Consistency laws for recorded information quantities -- numerical companion.

This script illustrates, on concrete finite samples, every law used to audit a
family of recorded marginal / joint / battery information values:

  1. empirical (plug-in) entropy and mutual information on a finite sample;
  2. the capacity lattice: 0 <= cap(S) <= cap(T) <= min(H(L), cap(S) + sum_{T\\S} H(F_i));
  3. the synergy identity  Syn = I(f;g|L) - I(f;g);
  4. the synergy sandwich  -min(I(L;f),I(L;g)) <= Syn <= min(H(f|L),H(g|L));
  5. sharpness via the XOR battery and failure of submodularity;
  6. the entropy-column obstruction and the audit of the recorded table;
  7. the battery synergy budget and the forced residual entropy of 4.3147 bits;
  8. an arithmetic "XOR in nature": splitting types of primes in two cubic fields.

Everything is self-contained (standard library only).
"""
from __future__ import annotations

import itertools
import math
import random
from collections import Counter
from typing import Callable, Hashable, Sequence

LOG2: float = math.log(2.0)
Sample = Sequence[Hashable]


# ---------------------------------------------------------------------------
# 1. Empirical Shannon calculus on a finite, uniformly weighted sample
# ---------------------------------------------------------------------------
def entropy(values: Sample) -> float:
    """Plug-in entropy (nats) of a statistic observed on a uniform finite sample."""
    n = len(values)
    return -sum((c / n) * math.log(c / n) for c in Counter(values).values())


def bits(x: float) -> float:
    return x / LOG2


def pair(f: Sample, g: Sample) -> list[tuple[Hashable, Hashable]]:
    return list(zip(f, g))


def mutual_info(label: Sample, f: Sample) -> float:
    """I(L;f) = H(L) + H(f) - H(L,f)."""
    return entropy(label) + entropy(f) - entropy(pair(label, f))


def cond_entropy(f: Sample, label: Sample) -> float:
    """Residual entropy H(f|L) = H(f,L) - H(L)."""
    return entropy(pair(f, label)) - entropy(label)


def sub_battery(battery: Sequence[Sample], subset: Sequence[int]) -> list[tuple]:
    """Joint reading of the dials with indices in `subset`."""
    n = len(battery[0]) if battery else 0
    return [tuple(battery[i][x] for i in sorted(subset)) for x in range(n)]


def capacity(label: Sample, battery: Sequence[Sample], subset: Sequence[int]) -> float:
    """cap(S) = I(L ; F|_S); the empty battery reads a constant."""
    if not subset:
        return mutual_info(label, [()] * len(label))
    return mutual_info(label, sub_battery(battery, subset))


def synergy(label: Sample, f: Sample, g: Sample) -> float:
    return mutual_info(label, pair(f, g)) - mutual_info(label, f) - mutual_info(label, g)


def dial_mi(f: Sample, g: Sample) -> float:
    return entropy(f) + entropy(g) - entropy(pair(f, g))


def cond_dial_mi(label: Sample, f: Sample, g: Sample) -> float:
    return (entropy(pair(label, f)) + entropy(pair(label, g))
            - entropy(pair(label, pair(f, g))) - entropy(label))


# ---------------------------------------------------------------------------
# 2. Random batteries: check the capacity lattice and the synergy laws
# ---------------------------------------------------------------------------
def random_battery(n: int, k: int, rng: random.Random) -> tuple[list[int], list[list[int]]]:
    """A label and k dials on n sample points, with some built-in dependence."""
    base = [[rng.randrange(3) for _ in range(n)] for _ in range(k)]
    label = [(sum(col[x] for col in base[:2]) + rng.randrange(2)) % 3 for x in range(n)]
    dials = [[(b[x] + (rng.random() < 0.2)) % 3 for x in range(n)] for b in base]
    return label, dials


def check_lattice_and_synergy(trials: int = 300, seed: int = 107) -> None:
    rng = random.Random(seed)
    tol = 1e-9
    worst_identity = 0.0
    for _ in range(trials):
        n, k = rng.randrange(12, 80), rng.randrange(2, 5)
        L, F = random_battery(n, k, rng)
        idx = list(range(k))
        HL = entropy(L)
        for r in range(k + 1):
            for S in itertools.combinations(idx, r):
                for r2 in range(r, k + 1):
                    for extra in itertools.combinations([i for i in idx if i not in S], r2 - r):
                        T = tuple(sorted(S + extra))
                        cS, cT = capacity(L, F, S), capacity(L, F, T)
                        budget = cS + sum(entropy(F[i]) for i in extra)
                        assert -tol <= cS <= cT + tol, "monotonicity"
                        assert cT <= min(HL, budget) + tol, "incremental law"
        f, g = F[0], F[1]
        syn = synergy(L, f, g)
        worst_identity = max(worst_identity, abs(syn - (cond_dial_mi(L, f, g) - dial_mi(f, g))))
        lo = -min(mutual_info(L, f), mutual_info(L, g))
        hi = min(cond_entropy(f, L), cond_entropy(g, L))
        assert lo - tol <= syn <= hi + tol, "synergy sandwich"
        batt_syn = capacity(L, F, idx) - sum(capacity(L, F, [i]) for i in idx)
        assert batt_syn <= sum(cond_entropy(F[i], L) for i in idx) + tol, "synergy budget"
    print(f"[2] {trials} random batteries: capacity lattice, incremental law, synergy sandwich")
    print(f"    and battery synergy budget all hold; max |Syn - (I(f;g|L) - I(f;g))| = {worst_identity:.2e}")


# ---------------------------------------------------------------------------
# 3. XOR: sharpness of the sandwich and failure of submodularity
# ---------------------------------------------------------------------------
def xor_example() -> None:
    cube = list(itertools.product([0, 1], repeat=2))
    L = [a ^ b for a, b in cube]
    f = [a for a, _ in cube]
    g = [b for _, b in cube]
    F = [f, g]
    print("[3] XOR battery on the four-point cube {0,1}^2 (label = x1 XOR x2):")
    print(f"    I(L;f) = {bits(mutual_info(L, f)):.4f} bits, I(L;g) = {bits(mutual_info(L, g)):.4f} bits,"
          f" I(L;f,g) = {bits(mutual_info(L, pair(f, g))):.4f} bits")
    print(f"    Syn = {bits(synergy(L, f, g)):.4f} bits = min(H(f|L), H(g|L)) = "
          f"{bits(min(cond_entropy(f, L), cond_entropy(g, L))):.4f} bits  (upper bound attained)")
    d2 = capacity(L, F, [0, 1]) - capacity(L, F, [0]) - capacity(L, F, [1]) + capacity(L, F, [])
    print(f"    second difference cap{{1,2}} - cap{{1}} - cap{{2}} + cap(empty) = {bits(d2):.4f} bit > 0"
          "  => capacity is NOT submodular")


# ---------------------------------------------------------------------------
# 4. Audit of the recorded table (all values in bits)
# ---------------------------------------------------------------------------
RECORDED: dict[str, tuple[float, float]] = {
    "S3a@31 marginal": (1.0012, 1.0012),
    "S3b@23 marginal": (1.0008, 1.0012),
    "A4@9 marginal": (0.4733, 0.4733),
    "D4@8 marginal": (1.4302, 1.4342),
    "S3a x S3b joint": (2.1314, 2.1314),
    "A4 x D4 joint": (1.9125, 1.9125),
    "S3a x S3b overlap": (0.9919, 0.9919),
    "4-field battery capacity": (8.2246, 8.2246),
}


def audit_table(tolerance: float = 0.0040) -> None:
    print("[4] Audit of the eight recorded quantities (bits):")
    for name, (a, b) in RECORDED.items():
        spread = abs(a - b)
        print(f"    {name:26s} {a:.4f}  {b:.4f}  spread {spread:.4f}  {'ok' if spread <= tolerance + 1e-12 else 'FAIL'}")
    s3a, s3b = 1.0012, 1.0012
    a4, d4 = 0.4733, 1.4342
    j1, j2, cap4, ceiling = 2.1314, 1.9125, 8.2246, 9.5276
    checks = {
        "marginal <= joint (S3a x S3b)": max(s3a, s3b) <= j1,
        "marginal <= joint (A4 x D4)": max(a4, d4) <= j2,
        "joint <= four-field capacity": max(j1, j2) <= cap4,
        "capacity <= label-entropy ceiling 9.5276": cap4 <= ceiling,
        "Syn >= -min (S3a x S3b)": j1 - s3a - s3b >= -min(s3a, s3b),
        "Syn >= -min (A4 x D4)": j2 - a4 - d4 >= -min(a4, d4),
    }
    for k, v in checks.items():
        print(f"    {k:42s} {'PASS' if v else 'FAIL'}")
    print(f"    implied synergies: S3a x S3b = {j1 - s3a - s3b:+.4f} bits, A4 x D4 = {j2 - a4 - d4:+.4f} bits")
    print(f"    entropy reading? joint {j1} <= {s3a} + {s3b} = {s3a + s3b:.4f} is "
          f"{j1 <= s3a + s3b}: the joint column CANNOT consist of entropies (subadditivity).")
    marg_sum = 3.9099
    print(f"    battery synergy budget: residual dial entropies >= {cap4} - {marg_sum} = "
          f"{cap4 - marg_sum:.4f} bits (forced)")


# ---------------------------------------------------------------------------
# 5. An arithmetic XOR: splitting types of primes in two cubic fields
# ---------------------------------------------------------------------------
def primes_up_to(n: int) -> list[int]:
    sieve = bytearray([1]) * (n + 1)
    sieve[0:2] = b"\x00\x00"
    for p in range(2, int(n ** 0.5) + 1):
        if sieve[p]:
            sieve[p * p::p] = bytearray(len(sieve[p * p::p]))
    return [p for p in range(n + 1) if sieve[p]]


def root_count(poly: Callable[[int], int], p: int) -> int:
    """Number of roots of a cubic modulo p: 3 (split), 1 (linear x quadratic), 0 (inert)."""
    return sum(1 for x in range(p) if poly(x) % p == 0)


def legendre(a: int, p: int) -> int:
    r = pow(a % p, (p - 1) // 2, p)
    return -1 if r == p - 1 else r


def arithmetic_xor(limit: int = 4000) -> None:
    """Dials: number of roots of x^3-x-1 (disc -23) and x^3+x+1 (disc -31) mod p.
    Label: (-23/p)(-31/p), the product of the signs of the two Frobenius permutations.
    Each type alone determines only its own sign, so it says (almost) nothing about the
    product; together they determine it -- a naturally occurring XOR battery."""
    ps = [p for p in primes_up_to(limit) if p not in (2, 3, 23, 31)]
    f = [root_count(lambda x: x ** 3 - x - 1, p) for p in ps]
    g = [root_count(lambda x: x ** 3 + x + 1, p) for p in ps]
    L = [legendre(-23, p) * legendre(-31, p) for p in ps]
    F = [f, g]
    print(f"[5] Arithmetic XOR over {len(ps)} primes p <= {limit} (illustrative label):")
    print(f"    H(f) = {bits(entropy(f)):.4f}, H(g) = {bits(entropy(g)):.4f}, H(L) = {bits(entropy(L)):.4f} bits")
    print(f"    I(L;f) = {bits(mutual_info(L, f)):.4f}, I(L;g) = {bits(mutual_info(L, g)):.4f}, "
          f"I(L;f,g) = {bits(mutual_info(L, pair(f, g))):.4f} bits")
    syn = synergy(L, f, g)
    hi = min(cond_entropy(f, L), cond_entropy(g, L))
    print(f"    Syn = {bits(syn):.4f} bits <= min(H(f|L),H(g|L)) = {bits(hi):.4f} bits")
    print(f"    redundancy I(f;g) = {bits(dial_mi(f, g)):.4f}, conditional I(f;g|L) = "
          f"{bits(cond_dial_mi(L, f, g)):.4f}  (Syn = difference)")
    d2 = capacity(L, F, [0, 1]) - capacity(L, F, [0]) - capacity(L, F, [1]) + capacity(L, F, [])
    print(f"    second difference of capacity = {bits(d2):.4f} bits > 0 (non-submodular in the wild)")


if __name__ == "__main__":
    check_lattice_and_synergy()
    xor_example()
    audit_table()
    arithmetic_xor()
