#!/usr/bin/env python3
"""
The Umans-Wang (alpha, beta)-divisor conjecture: numerical companion.

Everything here is self-contained (standard library only).  The script
illustrates, on concrete numbers:

  1. the n-divisor property of a difference set S - T;
  2. the lcm wall      lcm(1..n) <= M^(|S||T|)   and the binomial wall
                       4^floor(n/2) <= (n+1) M^(|S||T|);
  3. the central binomial divisibility  C(2m, m) | lcm(1..2m);
  4. the exact optimum  lcm(1..n)+1  for |S| = |T| = 1;
  5. a brute-force search for the best |S| = |T| = 2 covers (small n);
  6. the trivial block cover  T = {1},  S = {1 + prod(block)}  (alpha = 1 - beta + o(1));
  7. the corrected asymptotic constraint  alpha >= 1 - 2 beta  and zero slack at 1/3;
  8. the CRT progression behind Lemma 6.2, and why "hitting every prime" is cheap;
  9. a small random-search experiment showing unstructured sets do not cover.
"""
from __future__ import annotations

import itertools
import math
import random
from functools import reduce
from typing import Iterable, Optional


# ---------------------------------------------------------------------------
# Basic objects
# ---------------------------------------------------------------------------

def lcm_upto(n: int) -> int:
    """lcm(1, 2, ..., n)  (equal to 1 for n = 0)."""
    return reduce(lambda a, b: a * b // math.gcd(a, b), range(1, n + 1), 1)


def positive_differences(S: Iterable[int], T: Iterable[int]) -> list[int]:
    """All differences s - t with s in S, t in T and t < s."""
    T = list(T)
    return [s - t for s in S for t in T if t < s]


def has_divisor_property(n: int, S: Iterable[int], T: Iterable[int]) -> bool:
    """Every 1 <= i <= n divides some positive difference s - t."""
    diffs = positive_differences(S, T)
    return all(any(d % i == 0 for d in diffs) for i in range(1, n + 1))


def coverage(n: int, S: Iterable[int], T: Iterable[int]) -> float:
    """Fraction of i in [1, n] dividing some positive difference."""
    diffs = positive_differences(S, T)
    hit = sum(1 for i in range(1, n + 1) if any(d % i == 0 for d in diffs))
    return hit / n


def primes_upto(n: int) -> list[int]:
    sieve = [True] * (n + 1)
    sieve[0:2] = [False, False][: n + 1]
    for p in range(2, int(n ** 0.5) + 1):
        if sieve[p]:
            sieve[p * p:: p] = [False] * len(sieve[p * p:: p])
    return [p for p in range(n + 1) if sieve[p]]


# ---------------------------------------------------------------------------
# 2-3. The walls
# ---------------------------------------------------------------------------

def check_walls(n: int, S: list[int], T: list[int]) -> dict[str, object]:
    """Verify lcm | prod(diffs) <= M^(|S||T|) and the binomial wall."""
    assert has_divisor_property(n, S, T)
    M = max(S)
    prod = math.prod(positive_differences(S, T))
    L = lcm_upto(n)
    k = len(S) * len(T)
    return {
        "lcm divides product": prod % L == 0,
        "lcm <= M^k": L <= M ** k,
        "4^(n//2) <= (n+1) M^k": 4 ** (n // 2) <= (n + 1) * M ** k,
        "log2 lcm": math.log2(L),
        "k log2 M": k * math.log2(M),
    }


def central_binomial_divides_lcm(m: int) -> bool:
    return lcm_upto(2 * m) % math.comb(2 * m, m) == 0


# ---------------------------------------------------------------------------
# 4-5. Optimal small covers
# ---------------------------------------------------------------------------

def best_singleton_cover(n: int) -> int:
    """Least max element of a cover with |S| = |T| = 1 over positive integers.

    Theory: it equals lcm(1..n) + 1 (s - t must be a positive multiple of
    lcm(1..n) and t >= 1).  We return the closed form and verify minimality
    by direct search for small n.
    """
    L = lcm_upto(n)
    if L < 3000:
        for s in range(2, L + 2):
            if any(has_divisor_property(n, [s], [t]) for t in range(1, s)):
                return s
    return L + 1


def best_two_by_two_cover(n: int, limit: int = 200) -> Optional[tuple[int, tuple[int, int], tuple[int, int]]]:
    """Least M such that positive integers S = {s1, s2}, T = {t1, t2},
    all <= M, divide-cover [n].  Brute force with a pruning on 4 differences."""
    targets = list(range(2, n + 1))
    for M in range(2, limit + 1):
        # at least one element equals M; WLOG it is s2 = M (the largest element
        # of S u T must be in S for its differences to matter, else drop it).
        s2 = M
        for s1 in range(1, M):
            for t1 in range(1, M):
                for t2 in range(t1 + 1, M):
                    diffs = [d for d in (s1 - t1, s1 - t2, s2 - t1, s2 - t2) if d > 0]
                    if all(any(d % i == 0 for d in diffs) for i in targets):
                        return M, (s1, s2), (t1, t2)
    return None


# ---------------------------------------------------------------------------
# 6. Trivial block cover
# ---------------------------------------------------------------------------

def trivial_block_cover(n: int, b: int) -> tuple[list[int], list[int]]:
    """Cut [1, n] into consecutive blocks of length b; S = {1 + prod(block)}, T = {1}."""
    S = [1 + math.prod(range(j, min(j + b, n + 1))) for j in range(1, n + 1, b)]
    return S, [1]


# ---------------------------------------------------------------------------
# 8. CRT progression (core of Lemma 6.2)
# ---------------------------------------------------------------------------

def crt(residues: list[int], moduli: list[int]) -> int:
    x, m = 0, 1
    for r, q in zip(residues, moduli):
        # solve x + m*k = r (mod q)
        k = ((r - x) * pow(m, -1, q)) % q
        x, m = x + m * k, m * q
    return x % m


def crt_progression(U: list[int], c: int) -> int:
    """For pairwise coprime U_0..U_{l-1}, find b with U_i | b + (i+1) c."""
    return crt([(-(i + 1) * c) % u for i, u in enumerate(U)], U)


# ---------------------------------------------------------------------------
# 9. Random search
# ---------------------------------------------------------------------------

def random_cover_experiment(n: int, trials: int = 20, seed: int = 0) -> float:
    """Best coverage of [n] by random S, T of size ~n^(1/3) with elements
    <= exp(n^(1/3)) (all i, including composite i and prime powers)."""
    rng = random.Random(seed)
    k = max(1, round(n ** (1 / 3)))
    top = int(math.exp(n ** (1 / 3)))
    best = 0.0
    for _ in range(trials):
        S = rng.sample(range(2, top + 1), k)
        T = rng.sample(range(1, top + 1), k)
        best = max(best, coverage(n, S, T))
    return best


# ---------------------------------------------------------------------------
def main() -> None:
    line = "=" * 74
    print(line)
    print("1-3. Walls on concrete covers")
    print(line)
    for n, b in [(10, 3), (20, 4), (30, 5)]:
        S, T = trivial_block_cover(n, b)
        w = check_walls(n, S, T)
        print(f"n={n:2d}, block length {b}: |S|={len(S)}, |T|=1, max S = {max(S)}")
        for key, val in w.items():
            print(f"     {key:24s}: {val if not isinstance(val, float) else round(val, 2)}")
    print("C(2m,m) | lcm(1..2m) for m = 1..40:",
          all(central_binomial_divides_lcm(m) for m in range(1, 41)))

    print()
    print(line)
    print("4. Exact optimum for |S| = |T| = 1:  min M = lcm(1..n) + 1")
    print(line)
    for n in range(1, 11):
        print(f"n={n:2d}: lcm={lcm_upto(n):5d}, optimum = {best_singleton_cover(n):5d}")

    print()
    print(line)
    print("5. Brute-force optimum for |S| = |T| = 2 versus the wall lcm^(1/4)")
    print(line)
    for n in range(2, 11):
        res = best_two_by_two_cover(n)
        L = lcm_upto(n)
        if res:
            M, S, T = res
            print(f"n={n:2d}: min M = {M:3d}  S={S}  T={T}  lcm^(1/4) = {L ** 0.25:6.2f}"
                  f"  ratio = {M / L ** 0.25:4.2f}")

    print()
    print(line)
    print("6-7. Exponents: wall alpha >= 1 - 2 beta vs trivial alpha = 1 - beta")
    print(line)
    for beta in [0.1, 0.2, 1 / 3, 0.4, 0.5]:
        print(f"beta = {beta:.3f}:  wall alpha >= {1 - 2 * beta:.3f}   "
              f"trivial alpha = {1 - beta:.3f}   gap = {beta:.3f}")
    print("At alpha = beta = 1/3:  1 - 2*beta =", 1 - 2 / 3, " -> zero slack.")
    print("Finite form at alpha=beta=1/3: (n-1) log 2 <= log(n+1) + n^(alpha+2beta) = log(n+1) + n")
    for n in [10, 100, 1000]:
        lhs = (n - 1) * math.log(2)
        rhs = math.log(n + 1) + n
        print(f"   n={n:5d}: lhs={lhs:9.2f}  rhs={rhs:9.2f}  (holds; ratio lhs/rhs={lhs / rhs:.3f})")
    print("With alpha + 2 beta = 0.9 the right side n^0.9 + log(n+1) eventually loses:")
    for n in [10, 100, 1000, 10 ** 4]:
        lhs = (n - 1) * math.log(2)
        rhs = math.log(n + 1) + n ** 0.9
        print(f"   n={n:6d}: lhs={lhs:10.1f}  rhs={rhs:10.1f}  wall violated: {lhs > rhs}")
    print("Trivial cover exponent check (b = n^(2/3), so |S| ~ n^(1/3)):")
    for n in [64, 512, 4096]:
        b = round(n ** (2 / 3))
        S, T = trivial_block_cover(n, b)
        logM = math.log(max(S))
        print(f"   n={n:5d}: |S|={len(S):3d} (n^(1/3)={n ** (1 / 3):.1f}),"
              f" log max S = {logM:8.1f},  log max S / (n^(2/3) log n) = {logM / (n ** (2 / 3) * math.log(n)):.3f}")
    print("   (ratio stays bounded: log M = n^(2/3 + o(1)), i.e. alpha = 1 - beta + o(1) with beta = 1/3)")

    print()
    print(line)
    print("8. CRT progression (Lemma 6.2 core): hitting all primes is cheap")
    print(line)
    for n in [10, 20, 30]:
        P = primes_upto(n)
        U = [math.prod(P[0::2]), math.prod(P[1::2])]       # a 2-part split
        c = 1
        b = crt_progression(U, c)
        ap = [b + (i + 1) * c for i in range(len(U))]
        ok = all(any(a % p == 0 for a in ap) for p in P)
        b1 = crt_progression([math.prod(P)], c)            # l = 1 already works
        print(f"n={n}: 2-term AP {ap} hits every prime <= n: {ok};"
              f"  1-term: {b1 + c} divisible by all: {all((b1 + c) % p == 0 for p in P)}")
    print("   (hitting primes is not the divisor property: prime powers and all i<=n are needed,"
          " and the sizes of b, c are the whole difficulty)")

    print()
    print(line)
    print("9. Random (1/3, 1/3) sets: best coverage of [n] over 20 trials")
    print(line)
    for n in [64, 128, 256, 512]:
        k = max(1, round(n ** (1 / 3)))
        print(f"n={n:4d}: |S|=|T|={k}, elements <= e^(n^(1/3)) = {int(math.exp(n ** (1 / 3)))}:"
              f" best coverage = {random_cover_experiment(n):.3f}  (full cover needs 1.000)")


if __name__ == "__main__":
    main()
