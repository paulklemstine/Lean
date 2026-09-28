#!/usr/bin/env python3
"""
Dial cross-talk: are the splitting types of two cubic polynomials independent?

Self-contained numerical companion to "The Dials Are Independent".

Part 1 (exact, group theory):
    * the Chebotarev law of one S3 dial and its entropy 2/3 + (log2 3)/2,
    * I(T1;T2) = 0 on S3 x S3 (distinct quadratic resolvents),
    * I(T1;T2) = 1 on the fibre product S3 x_{C2} S3 (shared resolvent),
    * semiprime pair read-outs: 0 bits resp. 2 bits (additivity).
Part 2 (empirical, primes):
    * splitting types of real cubics modulo primes p < 30000,
    * plug-in mutual information, Miller-Madow bias, permutation null z-score.

Only the Python standard library is used.
"""
from __future__ import annotations

import itertools
import math
import random
from collections import Counter
from fractions import Fraction
from typing import Callable, Dict, Hashable, Iterable, List, Sequence, Tuple

Perm = Tuple[int, int, int]
Sample = Tuple[Hashable, Hashable]

# ----------------------------------------------------------------------------
# Part 0: entropy on a finite uniform sample space
# ----------------------------------------------------------------------------


def entropy_of_counts(counts: Iterable[int]) -> float:
    """Shannon entropy (bits) of the empirical law given by a list of counts."""
    cs = [c for c in counts if c > 0]
    n = sum(cs)
    return -sum(c / n * math.log2(c / n) for c in cs)


def mutual_information(pairs: Sequence[Sample]) -> float:
    """Plug-in mutual information I(X;Y) = H(X) + H(Y) - H(X,Y), in bits."""
    hx = entropy_of_counts(Counter(x for x, _ in pairs).values())
    hy = entropy_of_counts(Counter(y for _, y in pairs).values())
    hxy = entropy_of_counts(Counter(pairs).values())
    return hx + hy - hxy


def count_independent(pairs: Sequence[Sample]) -> bool:
    """Exact test of |S| * #{X=b, Y=c} == #{X=b} * #{Y=c} for every cell."""
    n = len(pairs)
    cx = Counter(x for x, _ in pairs)
    cy = Counter(y for _, y in pairs)
    cxy = Counter(pairs)
    return all(n * cxy.get((b, c), 0) == cx[b] * cy[c] for b in cx for c in cy)


# ----------------------------------------------------------------------------
# Part 1: the group S3, splitting types, sign
# ----------------------------------------------------------------------------

S3: List[Perm] = list(itertools.permutations(range(3)))


def cycle_type(p: Perm) -> str:
    """Splitting type of a Frobenius element: '111', '12' or '3'."""
    seen = [False] * 3
    lengths: List[int] = []
    for i in range(3):
        if not seen[i]:
            j, length = i, 0
            while not seen[j]:
                seen[j] = True
                j = p[j]
                length += 1
            lengths.append(length)
    return {(1, 1, 1): "111", (1, 2): "12", (3,): "3"}[tuple(sorted(lengths))]


def sign(p: Perm) -> int:
    """Sign character S3 -> {+1,-1}; it is read off from the type ('12' <=> odd)."""
    return -1 if cycle_type(p) == "12" else 1


def product_space() -> List[Tuple[Perm, Perm]]:
    """Galois group of a linearly disjoint compositum: S3 x S3 (36 elements)."""
    return [(a, b) for a in S3 for b in S3]


def fibre_product_space() -> List[Tuple[Perm, Perm]]:
    """Shared quadratic resolvent: S3 x_{C2} S3 = {(a,b) : sign a = sign b} (18 elements)."""
    return [(a, b) for a in S3 for b in S3 if sign(a) == sign(b)]


def joint_table(space: Sequence[Tuple[Perm, Perm]]) -> Dict[Tuple[str, str], int]:
    return dict(Counter((cycle_type(a), cycle_type(b)) for a, b in space))


def exact_part() -> None:
    print("=" * 72)
    print("PART 1 - exact values from the Galois groups")
    print("=" * 72)
    law = Counter(cycle_type(p) for p in S3)
    print("Chebotarev law of one dial:",
          {t: str(Fraction(c, 6)) for t, c in sorted(law.items())})
    h1 = entropy_of_counts(law.values())
    print(f"H(T)          = {h1:.6f}   (2/3 + log2(3)/2 = {2/3 + math.log2(3)/2:.6f})")

    prod = product_space()
    pairs = [(cycle_type(a), cycle_type(b)) for a, b in prod]
    print(f"\nS3 x S3: |G| = {len(prod)}, joint table = {joint_table(prod)}")
    print(f"  count-independent table?  {count_independent(pairs)}")
    print(f"  I(T1;T2)    = {abs(mutual_information(pairs)):.12f}   (theorem: 0)")
    hj = entropy_of_counts(Counter(pairs).values())
    print(f"  H(T1,T2)    = {hj:.6f}   (4/3 + log2 3 = {4/3 + math.log2(3):.6f})")

    fib = fibre_product_space()
    fpairs = [(cycle_type(a), cycle_type(b)) for a, b in fib]
    print(f"\nS3 x_C2 S3: |G| = {len(fib)}, joint table = {joint_table(fib)}")
    print(f"  count-independent table?  {count_independent(fpairs)}")
    print(f"  marginal of T1 = {dict(Counter(x for x, _ in fpairs))}  (still 1:3:2)")
    print(f"  I(T1;T2)    = {mutual_information(fpairs):.12f}   (theorem: exactly 1)")

    # Semiprimes: two independent Frobenius draws (p, q), pair read-outs.
    semi = [((cycle_type(a1), cycle_type(a2)), (cycle_type(b1), cycle_type(b2)))
            for (a1, b1) in prod for (a2, b2) in prod]
    semi_sh = [((cycle_type(a1), cycle_type(a2)), (cycle_type(b1), cycle_type(b2)))
               for (a1, b1) in fib for (a2, b2) in fib]
    print(f"\nSemiprimes, distinct resolvents: I(pair1;pair2) = "
          f"{abs(mutual_information(semi)):.12f}   (theorem: 0)")
    print(f"Semiprimes, shared resolvent:    I(pair1;pair2) = "
          f"{mutual_information(semi_sh):.12f}   (theorem: exactly 2)")
    hp = entropy_of_counts(Counter(x for x, _ in semi_sh).values())
    print(f"  H(pair1) under shared resolvent = {hp:.6f}  (4/3 + log2 3)")


# ----------------------------------------------------------------------------
# Part 2: real cubics modulo primes
# ----------------------------------------------------------------------------

Cubic = Tuple[int, int, int]  # x^3 + a x^2 + b x + c


def primes_below(n: int) -> List[int]:
    sieve = bytearray([1]) * n
    sieve[0:2] = b"\x00\x00"
    for i in range(2, int(n ** 0.5) + 1):
        if sieve[i]:
            sieve[i * i::i] = bytearray(len(sieve[i * i::i]))
    return [i for i in range(n) if sieve[i]]


def discriminant(f: Cubic) -> int:
    a, b, c = f
    return a * a * b * b - 4 * b ** 3 - 4 * a ** 3 * c - 27 * c * c + 18 * a * b * c


def splitting_type_mod_p(f: Cubic, p: int) -> str:
    """For p not dividing disc(f): 3 roots -> '111', 1 root -> '12', 0 roots -> '3'."""
    a, b, c = f
    roots = sum(1 for x in range(p) if (x * x * x + a * x * x + b * x + c) % p == 0)
    return {3: "111", 1: "12", 0: "3"}[roots]


def dial_samples(f: Cubic, g: Cubic, bound: int, pmin: int = 5) -> List[Sample]:
    df, dg = discriminant(f), discriminant(g)
    return [(splitting_type_mod_p(f, p), splitting_type_mod_p(g, p))
            for p in primes_below(bound) if p >= pmin and df % p and dg % p]


def miller_madow_bias(rows: int, cols: int, n: int) -> float:
    """First-order bias of the plug-in MI of independent variables: (r-1)(c-1)/(2 n ln 2)."""
    return (rows - 1) * (cols - 1) / (2 * n * math.log(2))


def permutation_z(pairs: Sequence[Sample], trials: int, seed: int = 1) -> float:
    """z-score of the observed MI against shuffles of the second coordinate."""
    rng = random.Random(seed)
    obs = mutual_information(pairs)
    xs = [x for x, _ in pairs]
    ys = [y for _, y in pairs]
    null: List[float] = []
    for _ in range(trials):
        rng.shuffle(ys)
        null.append(mutual_information(list(zip(xs, ys))))
    mu = sum(null) / trials
    sd = math.sqrt(sum((v - mu) ** 2 for v in null) / (trials - 1))
    return (obs - mu) / sd


def empirical_part(bound: int = 30000, trials: int = 200) -> None:
    print("\n" + "=" * 72)
    print(f"PART 2 - splitting types of actual cubics, primes 5 <= p < {bound}")
    print("=" * 72)
    experiments: List[Tuple[str, Cubic, Cubic, str]] = [
        ("x^3+x+1 vs x^3-x-1  (disc -31 vs -23)", (0, 1, 1), (0, -1, -1), "0"),
        ("x^3-2   vs x^3+x+1  (disc -108 vs -31)", (0, 0, -2), (0, 1, 1), "0"),
        ("x^3-2   vs x^3-3    (both resolvent Q(sqrt-3))", (0, 0, -2), (0, 0, -3), "1"),
        ("x^3-2   vs x^3-5    (both resolvent Q(sqrt-3))", (0, 0, -2), (0, 0, -5), "1"),
    ]
    order = ["111", "12", "3"]
    for name, f, g, theory in experiments:
        pairs = dial_samples(f, g, bound)
        n = len(pairs)
        mi = mutual_information(pairs)
        tab = Counter(pairs)
        print(f"\n{name}")
        print(f"  n = {n} primes, plug-in I = {mi:.6f} bits   (exact value: {theory})")
        print("  joint table (rows f, cols g):  " + "  ".join(order))
        for r in order:
            print(f"      {r:>4}: " + " ".join(f"{tab.get((r, c), 0):6d}" for c in order))
        if theory == "0":
            print(f"  Miller-Madow bias 4/(2 n ln 2) = {miller_madow_bias(3, 3, n):.6f}"
                  f";  permutation-null z = {permutation_z(pairs, trials):+.2f}")

    # Semiprimes N = p q with consecutive primes: pair read-outs.
    f, g = (0, 1, 1), (0, -1, -1)
    pairs = dial_samples(f, g, bound)
    semi = [((pairs[i][0], pairs[i + 1][0]), (pairs[i][1], pairs[i + 1][1]))
            for i in range(0, len(pairs) - 1, 2)]
    n = len(semi)
    print(f"\nSemiprimes N = p q (consecutive good primes), x^3+x+1 vs x^3-x-1:")
    print(f"  n = {n}, plug-in I(pair1;pair2) = {mutual_information(semi):.6f} bits"
          f"  (exact: 0);  9x9 bias 64/(2 n ln 2) = {miller_madow_bias(9, 9, n):.6f}")


if __name__ == "__main__":
    exact_part()
    empirical_part()
