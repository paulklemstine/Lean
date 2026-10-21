#!/usr/bin/env python3
"""
Who controls the columns?  Quadratic sieve versus the quadratic number field sieve.

Self-contained numerical companion to the paper
"The Boundary Is the Number Field Sieve: Column Sets Governed by the Field, Not by N".

Every result demonstrated here is stated and proved in the paper:

  1. Split predicate = Legendre condition  (Euler's criterion cross-check).
  2. QS columns are slaved to N: r | x^2 - N y^2 with r not dividing N y forces (N/r) = +1.
  3. Degree-one prime count: #Hom(Z[sqrt d], F_r) = 1 + (d/r) for odd primes r.
  4. Decoupling theorem: for fixed N and root m, valid fields d (N | m^2 - d) realise
     every one of the 2^|S| column patterns on the coprime factor base S (constructive CRT).
  5. Yield cancellation: sum over d = 0..r-1 of #Hom(Z[sqrt d], F_r) equals r.
  6. Residual coupling: a valid field d splits at every hidden prime p | N with p not dividing d.
  7. Lab data at B = 200: d = -7 has 21 odd split primes; QS column counts 20, 19, 21, 25
     for N = 11, 23, 15, 47.

Run:  python3 demo.py
"""

from __future__ import annotations

from itertools import product
from math import gcd, prod
from typing import Iterable


# ----------------------------------------------------------------------------
# Elementary number theory (all inlined)
# ----------------------------------------------------------------------------

def is_prime(n: int) -> bool:
    """Deterministic trial-division primality test (fine for small n)."""
    if n < 2:
        return False
    if n % 2 == 0:
        return n == 2
    f = 3
    while f * f <= n:
        if n % f == 0:
            return False
        f += 2
    return True


def odd_factor_base(B: int) -> list[int]:
    """The odd primes r <= B."""
    return [r for r in range(3, B + 1) if is_prime(r)]


def splits(a: int, r: int) -> bool:
    """r splits a: r does not divide a and a is a square modulo r (brute force)."""
    if a % r == 0:
        return False
    a %= r
    return any((x * x - a) % r == 0 for x in range(r))


def legendre(a: int, r: int) -> int:
    """Legendre symbol (a/r) for an odd prime r, via Euler's criterion."""
    t = pow(a % r, (r - 1) // 2, r)
    return -1 if t == r - 1 else t


def qs_columns(N: int, B: int) -> list[int]:
    """Quadratic-sieve column set: odd primes r <= B with (N/r) = +1."""
    return [r for r in odd_factor_base(B) if splits(N, r)]


def nfs_columns(d: int, B: int) -> list[int]:
    """Quadratic-NFS (ideal-sieve) column set: odd primes r <= B with (d/r) = +1."""
    return [r for r in odd_factor_base(B) if splits(d, r)]


def coprime_base(N: int, B: int) -> list[int]:
    """Odd factor-base primes not dividing N."""
    return [r for r in odd_factor_base(B) if N % r != 0]


def ring_homs_zsqrtd(d: int, r: int) -> list[int]:
    """Ring homomorphisms Z[sqrt d] -> F_r, each determined by the image s of sqrt d,
    which must satisfy s^2 = d in F_r.  Returns the list of admissible s."""
    return [s for s in range(r) if (s * s - d) % r == 0]


def crt(residues: Iterable[tuple[int, int]]) -> tuple[int, int]:
    """Chinese remainder theorem for pairwise coprime moduli: list of (a_i, n_i) -> (x, M)."""
    x, M = 0, 1
    for a, n in residues:
        # solve x + M*k = a (mod n)
        k = ((a - x) * pow(M, -1, n)) % n
        x, M = x + M * k, M * n
    return x % M, M


def a_nonresidue(r: int) -> int:
    """Smallest quadratic non-residue modulo the odd prime r."""
    return next(t for t in range(2, r) if legendre(t, r) == -1)


def field_with_pattern(N: int, m: int, B: int, target: set[int]) -> int:
    """Constructive decoupling theorem: return d with N | m^2 - d and
    nfs_columns(d, B) restricted to the coprime base equal to `target`."""
    congruences: list[tuple[int, int]] = [(m * m, abs(N))]
    for r in coprime_base(N, B):
        congruences.append((1 if r in target else a_nonresidue(r), r))
    d, _ = crt(congruences)
    return d


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------

def banner(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


def demo_split_equals_legendre(B: int = 200) -> None:
    banner("1. The split predicate is exactly the Legendre condition (a/r) = +1")
    bad = 0
    for r in odd_factor_base(B):
        for a in range(-60, 61):
            if splits(a, r) != (legendre(a, r) == 1):
                bad += 1
    print(f"   checked all a in [-60, 60] against all odd primes r <= {B}: mismatches = {bad}")


def demo_qs_slaved(N: int = 1009 * 1013, trials: int = 4000) -> None:
    banner("2. QS relations force the N-Legendre condition")
    import random
    rng = random.Random(43)
    hits = 0
    violations = 0
    for _ in range(trials):
        x = rng.randrange(1, 10 ** 6)
        y = rng.randrange(1, 10 ** 3)
        v = x * x - N * y * y
        for r in odd_factor_base(200):
            if v % r == 0 and N % r != 0 and y % r != 0:
                hits += 1
                if legendre(N, r) != 1:
                    violations += 1
    print(f"   N = {N}: {hits} prime hits r | x^2 - N y^2 (r coprime to N y);")
    print(f"   hits at primes with (N/r) != +1 : {violations}   (theorem predicts 0)")


def demo_degree_one_count(B: int = 60) -> None:
    banner("3. #Hom(Z[sqrt d], F_r) = 1 + (d/r)")
    bad = 0
    for r in odd_factor_base(B):
        for d in range(-40, 41):
            if len(ring_homs_zsqrtd(d, r)) != 1 + legendre(d, r):
                bad += 1
    print(f"   all d in [-40, 40], all odd primes r <= {B}: mismatches = {bad}")
    d, r = -7, 11
    print(f"   example: d = {d}, r = {r}: sqrt d -> {ring_homs_zsqrtd(d, r)}  "
          f"(two conjugate degree-one primes, (d/r) = {legendre(d, r)})")


def demo_decoupling(N: int = 11 * 23, m: int = 5, B: int = 13) -> None:
    banner("4. Decoupling theorem: every column pattern is attained by a valid field")
    S = coprime_base(N, B)
    print(f"   N = {N}, root m = {m}, B = {B}; coprime base S = {S}  (|S| = {len(S)})")
    print(f"   QS pattern (the single point d = N, m = 0): "
          f"{[r for r in S if splits(N, r)]}")
    patterns_hit = set()
    for bits in product([0, 1], repeat=len(S)):
        target = {r for r, b in zip(S, bits) if b}
        d = field_with_pattern(N, m, B, target)
        assert (m * m - d) % N == 0, "validity failed"
        got = frozenset(r for r in S if splits(d, r))
        assert got == frozenset(target), "pattern failed"
        patterns_hit.add(got)
    print(f"   distinct patterns realised by valid d: {len(patterns_hit)} = 2^{len(S)}")
    for target in [set(), set(S), {3, 7}]:
        d = field_with_pattern(N, m, B, target)
        print(f"     target {sorted(target)!s:<20} -> d = {d:>8}   "
              f"(N | m^2 - d: {(m*m - d) % N == 0})")


def demo_yield_cancellation(B: int = 100) -> None:
    banner("5. Yield cancellation: sum_{d=0}^{r-1} #Hom(Z[sqrt d], F_r) = r")
    for r in odd_factor_base(B)[:10]:
        total = sum(len(ring_homs_zsqrtd(d, r)) for d in range(r))
        print(f"   r = {r:>3}: total degree-one primes over a full period of d = {total}")


def demo_residual_coupling() -> None:
    banner("6. Residual coupling: valid fields split at the hidden primes of N")
    p, q = 1009, 1013
    N = p * q
    for m in [2, 77, 12345, 999]:
        for k in [1, 5, -3]:
            d = m * m - k * N
            print(f"   m = {m:>5}, d = m^2 - {k:>2}N = {d:>12}: "
                  f"(d/{p}) = {legendre(d, p):>2}, (d/{q}) = {legendre(d, q):>2}")


def demo_lab_data(B: int = 200) -> None:
    banner(f"7. Lab data at B = {B}")
    cols = nfs_columns(-7, B)
    print(f"   d = -7: {len(cols)} odd split primes (+ r = 2, since -7 = 1 mod 8 -> 22 total)")
    print(f"   valid for N = 11 (2^2 + 7 = 11) and N = 23 (4^2 + 7 = 23): same column set")
    for N in (11, 23, 15, 47):
        print(f"   QS columns for N = {N:>2}: {len(qs_columns(N, B))}")
    print(f"   QS(11) == QS(23)? {qs_columns(11, B) == qs_columns(23, B)}")


if __name__ == "__main__":
    demo_split_equals_legendre()
    demo_qs_slaved()
    demo_degree_one_count()
    demo_decoupling()
    demo_yield_cancellation()
    demo_residual_coupling()
    demo_lab_data()
    print()
