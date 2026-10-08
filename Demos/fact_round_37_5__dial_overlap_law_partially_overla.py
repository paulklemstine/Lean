#!/usr/bin/env python3
"""
The Dial-Overlap Law: numerical demonstrations.

Two number fields whose Galois groups G and H both map onto a common quotient C
(the Galois group of a shared subfield) have compositum group the fibre product
    G x_C H = {(g, h) : chi1(g) = chi2(h)}.
By Chebotarev, Frobenius pairs of unramified primes are uniformly distributed on
this fibre product.  The Overlap Law says: readouts that determine the shared
character share exactly log2|C| bits, and no readouts share more.

Sections
  1. Exact entropies on finite uniform sample spaces (the counting framework).
  2. The S3 pairs: order 18, joint table 1:2:2:4:9, I = 1 bit, agreement 7/9.
  3. The overlap ladder: coprime 0 / shared quadratic 1 / same field H(T).
  4. Insight L11: sign information is blind, type statistics discriminate.
  5. The law for S_n x_{C2} S_m and for cyclic quartics C4 x_{C2} C4.
  6. Three dials over one subfield: total correlation 2, co-information +1.
  7. Real primes: Frobenius splitting types of the four cubics up to 60000.
  8. Plug-in bias: why sparse joint tables mislead.

Pure Python standard library only.  Seeded for reproducibility.
"""
from __future__ import annotations

import itertools
import math
import random
from collections import Counter
from typing import Callable, Hashable, Iterable, Sequence, TypeVar

T = TypeVar("T")
Perm = tuple[int, ...]

# ---------------------------------------------------------------------------
# 1. Entropy on a finite uniform sample space
# ---------------------------------------------------------------------------


def entropy_of_counts(counts: Iterable[int]) -> float:
    """Shannon entropy (bits) of the distribution proportional to `counts`."""
    cs = [c for c in counts if c > 0]
    n = sum(cs)
    return -sum(c / n * math.log2(c / n) for c in cs)


def H(space: Sequence[T], f: Callable[[T], Hashable]) -> float:
    """Entropy of the readout f under the uniform distribution on `space`."""
    return entropy_of_counts(Counter(f(x) for x in space).values())


def MI(space: Sequence[T], f: Callable[[T], Hashable], g: Callable[[T], Hashable]) -> float:
    """Mutual information I(f ; g) = H(f) + H(g) - H(f, g) on a uniform space."""
    return H(space, f) + H(space, g) - H(space, lambda x: (f(x), g(x)))


def fibre_product(G: Sequence, Hs: Sequence, chi1: Callable, chi2: Callable) -> list[tuple]:
    """G x_C H = {(g, h) : chi1(g) = chi2(h)}."""
    return [(g, h) for g in G for h in Hs if chi1(g) == chi2(h)]


# ---------------------------------------------------------------------------
# Symmetric groups: sign and cycle type
# ---------------------------------------------------------------------------


def perms(n: int) -> list[Perm]:
    return list(itertools.permutations(range(n)))


def cycle_type(p: Perm) -> tuple[int, ...]:
    seen, lengths = set(), []
    for i in range(len(p)):
        if i not in seen:
            j, L = i, 0
            while j not in seen:
                seen.add(j)
                j = p[j]
                L += 1
            lengths.append(L)
    return tuple(sorted(lengths, reverse=True))


def sign(p: Perm) -> int:
    return (-1) ** sum(L - 1 for L in cycle_type(p))


TYPE_NAME = {(1, 1, 1): "111", (3,): "3", (2, 1): "12"}


def split_type(p: Perm) -> str:
    """Splitting type of an unramified prime in an S3 cubic field with Frobenius p."""
    return TYPE_NAME[cycle_type(p)]


def banner(title: str) -> None:
    print("\n" + "=" * 74 + "\n" + title + "\n" + "=" * 74)


# ---------------------------------------------------------------------------
# 2-4. The S3 pairs, the ladder, insight L11
# ---------------------------------------------------------------------------


def demo_s3() -> None:
    S3 = perms(3)
    shared = fibre_product(S3, S3, sign, sign)  # S3 x_{C2} S3
    coprime = [(a, b) for a in S3 for b in S3]  # S3 x S3
    same = [(a, a) for a in S3]  # diagonal

    t1 = lambda x: split_type(x[0])
    t2 = lambda x: split_type(x[1])
    s1 = lambda x: sign(x[0])
    s2 = lambda x: sign(x[1])

    banner("2. Two S3 cubics sharing their quadratic resolvent field")
    print(f"|S3 x_C2 S3| = {len(shared)}   (order formula: |S3|*|S3|/|C2| = 36/2 = 18)")
    table = Counter((t1(x), t2(x)) for x in shared)
    print("Joint Chebotarev table (out of 18):")
    for a in ["111", "3", "12"]:
        print("   " + "  ".join(f"{a:>3}/{b:<3}:{table[(a, b)]:>2}" for b in ["111", "3", "12"]))
    print(f"H(T1) = {H(shared, t1):.6f}, H(T1,T2) = {H(shared, lambda x: (t1(x), t2(x))):.6f}")
    print(f"I(T1 ; T2) = {MI(shared, t1, t2):.12f}   <-- exactly one bit")
    agree = sum(t1(x) == t2(x) for x in shared)
    print(f"Type agreement {agree}/18 = {agree / 18:.4f} (7/9 = {7 / 9:.4f}); off-diagonal {18 - agree}/18")
    for c in (-1, 1):
        fib = [x for x in shared if s1(x) == c]
        ag = sum(t1(x) == t2(x) for x in fib)
        print(f"  fibre chi={c:+d}: size {len(fib)}, agreement {ag}/{len(fib)}, "
              f"I(T1;T2 | fibre) = {abs(MI(fib, t1, t2)):.12f}")

    banner("3. The overlap ladder for S3 cubics")
    print(f"coprime     (S3 x S3,   36): I = {abs(MI(coprime, t1, t2)):.6f},  agreement "
          f"{sum(t1(x) == t2(x) for x in coprime)}/36")
    print(f"shared quad (S3 xC2 S3, 18): I = {MI(shared, t1, t2):.6f},  agreement {agree}/18")
    print(f"same field  (diagonal,   6): I = {MI(same, t1, t2):.6f},  agreement 6/6")
    print(f"   H(T) = 2/3 + log2(3)/2 = {2 / 3 + math.log2(3) / 2:.6f}")

    banner("4. Insight L11: sign information cannot tell partial overlap from same field")
    print(f"sign MI, partial overlap: {MI(shared, s1, s2):.6f}")
    print(f"sign MI, same field     : {MI(same, s1, s2):.6f}")
    print("discriminators: type agreement 7/9 vs 1;  full-type MI 1 vs 1.4591")


# ---------------------------------------------------------------------------
# 5. Beyond S3
# ---------------------------------------------------------------------------


def demo_general() -> None:
    banner("5a. S_n x_{C2} S_m with cycle-type readouts: always exactly one bit")
    for n in range(2, 6):
        for m in range(n, 6):
            Sn, Sm = perms(n), perms(m)
            fp = fibre_product(Sn, Sm, sign, sign)
            i = MI(fp, lambda x: cycle_type(x[0]), lambda x: cycle_type(x[1]))
            print(f"  n={n}, m={m}: |fibre product| = {len(fp):>6}, I = {i:.12f}")

    banner("5b. Two cyclic quartic fields sharing their quadratic subfield (C4 x_C2 C4)")
    C4 = range(4)
    fp = fibre_product(C4, C4, lambda a: a % 2, lambda b: b % 2)
    deg = lambda a: {0: 1, 2: 2}.get(a, 4)  # residue degree = order of Frobenius
    d1 = lambda x: deg(x[0])
    d2 = lambda x: deg(x[1])
    print(f"|C4 x_C2 C4| = {len(fp)}")
    print(f"H(deg1) = {H(fp, d1):.6f},  H(deg1 | deg2) = "
          f"{H(fp, lambda x: (d1(x), d2(x))) - H(fp, d2):.6f},  I = {MI(fp, d1, d2):.6f}"
          "   (3/2 - 1/2 = 1)")

    banner("5c. The ceiling: no readouts share more than log2|C| (random readouts on S4 x_C2 S4)")
    rng = random.Random(20260821)
    S4 = perms(4)
    fp4 = fibre_product(S4, S4, sign, sign)
    worst = 0.0
    for _ in range(300):
        k = rng.randint(2, 24)
        r1 = {p: rng.randrange(k) for p in S4}
        r2 = {p: rng.randrange(k) for p in S4}
        worst = max(worst, MI(fp4, lambda x: r1[x[0]], lambda x: r2[x[1]]))
    print(f"max MI over 300 random readout pairs = {worst:.6f}  <=  log2|C2| = 1")


# ---------------------------------------------------------------------------
# 6. Three dials
# ---------------------------------------------------------------------------


def demo_three() -> None:
    banner("6. Three S3 cubics with one common quadratic resolvent")
    S3 = perms(3)
    trip = [(a, b, c) for a in S3 for b in S3 for c in S3 if sign(a) == sign(b) == sign(c)]
    T = [lambda x, i=i: split_type(x[i]) for i in range(3)]
    Hs = [H(trip, t) for t in T]
    Hj = H(trip, lambda x: tuple(t(x) for t in T))
    tc = sum(Hs) - Hj
    i12, i13 = MI(trip, T[0], T[1]), MI(trip, T[0], T[2])
    i1_23 = MI(trip, T[0], lambda x: (T[1](x), T[2](x)))
    print(f"|S3 x_C2 S3 x_C2 S3| = {len(trip)}  (= 6^3 / 2^2)")
    print(f"pairwise I: {i12:.6f}, {i13:.6f}, {MI(trip, T[1], T[2]):.6f};  I(T1 ; (T2,T3)) = {i1_23:.6f}")
    print(f"total correlation = {tc:.6f}  (law: 2 log2|C| = 2)")
    print(f"co-information    = {i12 + i13 - i1_23:+.6f}  (law: +log2|C| = +1, pure redundancy)")


# ---------------------------------------------------------------------------
# 7. Real primes
# ---------------------------------------------------------------------------


def primes_below(n: int) -> list[int]:
    sieve = bytearray([1]) * n
    sieve[0:2] = b"\x00\x00"
    for i in range(2, int(n ** 0.5) + 1):
        if sieve[i]:
            sieve[i * i::i] = bytearray(len(range(i * i, n, i)))
    return [i for i in range(n) if sieve[i]]


def polymulmod(a: list[int], b: list[int], f: list[int], p: int) -> list[int]:
    """Multiply polynomials (low-degree-first coefficient lists) modulo monic cubic f and p."""
    prod = [0] * (len(a) + len(b) - 1)
    for i, x in enumerate(a):
        for j, y in enumerate(b):
            prod[i + j] = (prod[i + j] + x * y) % p
    for d in range(len(prod) - 1, 2, -1):  # reduce using x^3 = -(f0 + f1 x + f2 x^2)
        c = prod[d]
        if c:
            for k in range(3):
                prod[d - 3 + k] = (prod[d - 3 + k] - c * f[k]) % p
    return (prod + [0, 0, 0])[:3]


def polygcd_deg(a: list[int], b: list[int], p: int) -> int:
    """Degree of gcd(a, b) over F_p."""
    def trim(v: list[int]) -> list[int]:
        v = [x % p for x in v]
        while v and v[-1] == 0:
            v.pop()
        return v
    a, b = trim(a), trim(b)
    while b:
        inv = pow(b[-1], p - 2, p)
        while len(a) >= len(b) and a:
            c = a[-1] * inv % p
            shift = len(a) - len(b)
            for i, y in enumerate(b):
                a[i + shift] = (a[i + shift] - c * y) % p
            a = trim(a)
        a, b = b, a
    return len(a) - 1


def roots_mod_p(f: list[int], p: int) -> int:
    """Number of roots of the monic cubic f in F_p via deg gcd(x^p - x, f)."""
    result, base, e = [1, 0, 0], [0, 1, 0], p
    while e:
        if e & 1:
            result = polymulmod(result, base, f, p)
        base = polymulmod(base, base, f, p)
        e >>= 1
    xp_minus_x = [result[0], (result[1] - 1) % p, result[2]]
    return polygcd_deg(xp_minus_x, f + [1], p)


def frob_type(f: list[int], p: int) -> str:
    return {3: "111", 1: "12", 0: "3"}[roots_mod_p(f, p)]


def plugin_mi(pairs: Sequence[tuple[Hashable, Hashable]]) -> float:
    a = Counter(x for x, _ in pairs)
    b = Counter(y for _, y in pairs)
    j = Counter(pairs)
    return entropy_of_counts(a.values()) + entropy_of_counts(b.values()) - entropy_of_counts(j.values())


def demo_primes(bound: int = 60000) -> None:
    banner(f"7. Frobenius splitting types of real primes 7 < p < {bound}")
    # cubics x^3 + a x + b stored as [b, a, 0] (constant, x, x^2)
    pairs = {
        "d=-7: x^3-5x-5 & x^3-3x-5": ([-5, -5, 0], [-5, -3, 0]),
        "d=-3: x^3-6x-6 & x^3-3": ([-6, -6, 0], [-3, 0, 0]),
        "coprime: x^3+x+1 & x^3-x-1": ([1, 1, 0], [-1, -1, 0]),
        "same field: x^3-5x-5 twice": ([-5, -5, 0], [-5, -5, 0]),
    }
    discs = {"d=-7": (175 * 567), "d=-3": (108 * 243), "coprime": 31 * 23, "same field": 175}
    ps = [p for p in primes_below(bound) if p > 7]
    for name, (f, g) in pairs.items():
        D = discs[name.split(":")[0]]
        data = [(frob_type(f, p), frob_type(g, p)) for p in ps if D % p]
        n = len(data)
        agree = sum(x == y for x, y in data) / n
        print(f"{name:32s} n={n}  plug-in I = {plugin_mi(data):.4f}  agreement = {agree:.4f}")
        if name.startswith("d=-7"):
            c = Counter(data)
            print("    table:", ", ".join(f"{a}/{b}: {c[(a, b)]}" for a, b in
                                         [("111", "111"), ("111", "3"), ("3", "111"), ("3", "3"),
                                          ("12", "12"), ("12", "111"), ("3", "12")]))
            print("    law 1:2:2:4:9 predicts", [round(n * k / 18) for k in (1, 2, 2, 4, 9)])
    print("laws: I = 1, 1, 0, 1.4591; agreement = 0.7778, 0.7778, 0.3889, 1")


# ---------------------------------------------------------------------------
# 8. Plug-in bias
# ---------------------------------------------------------------------------


def demo_bias() -> None:
    banner("8. Plug-in bias: independent readouts on a large sparse joint")
    rng = random.Random(20260821)
    K = 30  # 30 x 30 = 900 cells, true MI = 0
    for per_cell in (1, 2, 10, 100):
        n = per_cell * K * K
        est = [plugin_mi([(rng.randrange(K), rng.randrange(K)) for _ in range(n)]) for _ in range(5)]
        print(f"  {per_cell:>3} samples/cell (n={n:>6}): plug-in I ~ {sum(est) / 5:.3f} bits (true 0)")
    print("  Miller-Madow first-order bias (K-1)^2/(2 n ln 2) at 2/cell:",
          f"{(K - 1) ** 2 / (2 * 2 * K * K * math.log(2)):.3f} bits")
    print("The S3 shared-subfield table has only 5 non-zero cells -> negligible bias at n ~ 6000.")


if __name__ == "__main__":
    demo_s3()
    demo_general()
    demo_three()
    demo_primes()
    demo_bias()
