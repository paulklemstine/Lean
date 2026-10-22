#!/usr/bin/env python3
"""
The Split Set Decides: numerical companion.

Self-contained demonstrations of the main results about the single-polynomial
quadratic sieve (QS):

  1. Split-set forcing: a prime r not dividing N that divides some x^2 - N has
     Legendre symbol (N/r) = +1.  The factor base the sieve can reach is exactly
     the admissible (ramified + split) set, of size Q(N,B) <= pi(B).
  2. Smooth counts over a prime set S: the multiplicative step, the exponential
     floor 2^|S| and ceiling (log2 X + 1)^|S|, and the sign-flip criterion for the
     model work (|S|+1)/Psi_S(X).
  3. Paid sieve work decreases as the column set grows (fixed B, fixed window).
  4. The prefix-rank identity k_success = rank(prefix k_success) + 1 <= Q + 1.
  5. The GF(2)-rank trap: rank over Q versus rank over GF(2), the even-determinant
     discrimination criterion, and the one-sided error rank_F2 <= rank_Q.
  6. Large-prime pairing: a + (b - D) > Q forces a square in the same column space.

Only the Python standard library is used.
"""
from __future__ import annotations

import math
import random
from fractions import Fraction
from itertools import combinations
from typing import Iterable, Sequence

# ---------------------------------------------------------------------------
# Elementary number theory
# ---------------------------------------------------------------------------


def primes_upto(n: int) -> list[int]:
    """Sieve of Eratosthenes."""
    if n < 2:
        return []
    is_p = bytearray([1]) * (n + 1)
    is_p[0] = is_p[1] = 0
    for i in range(2, int(n ** 0.5) + 1):
        if is_p[i]:
            is_p[i * i:: i] = bytearray(len(is_p[i * i:: i]))
    return [i for i in range(n + 1) if is_p[i]]


def factorize(n: int) -> dict[int, int]:
    """Trial-division factorisation of a positive integer."""
    out: dict[int, int] = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            out[d] = out.get(d, 0) + 1
            n //= d
        d += 1 if d == 2 else 2
    if n > 1:
        out[n] = out.get(n, 0) + 1
    return out


def legendre(a: int, p: int) -> int:
    """Legendre symbol (a/p) for an odd prime p; for p = 2 returns 1 if a odd, 0 if even."""
    a %= p
    if a == 0:
        return 0
    if p == 2:
        return 1
    return 1 if pow(a, (p - 1) // 2, p) == 1 else -1


def is_square_mod(a: int, p: int) -> bool:
    """Is a a square modulo the prime p (zero counts as a square)?"""
    return a % p == 0 or legendre(a, p) == 1


def admissible_primes(N: int, B: int) -> list[int]:
    """Primes p <= B with N a square mod p: the ramified and split primes."""
    return [p for p in primes_upto(B) if is_square_mod(N, p)]


def sieve_reachable(N: int, B: int) -> list[int]:
    """Primes p <= B dividing x^2 - N for SOME x (checked over one full period)."""
    return [p for p in primes_upto(B) if any((x * x - N) % p == 0 for x in range(p))]


# ---------------------------------------------------------------------------
# Smooth counting over a prime set
# ---------------------------------------------------------------------------


def psi_S(S: Iterable[int], X: int) -> int:
    """Number of n in [1, X] all of whose prime factors lie in S (by enumeration of products)."""
    primes = sorted(set(S))
    count = 0

    def rec(i: int, cur: int) -> None:
        nonlocal count
        if i == len(primes):
            count += 1
            return
        p = primes[i]
        v = cur
        while v <= X:
            rec(i + 1, v)
            v *= p

    rec(0, 1)
    return count


def model_work(S: Sequence[int], X: int) -> Fraction:
    """Model cost (|S| + 1) / Psi_S(X): positions per guaranteed dependence."""
    return Fraction(len(S) + 1, psi_S(S, X))


def is_smooth_over(v: int, S: set[int]) -> bool:
    """Is v > 0 composed only of primes in S?"""
    if v <= 0:
        return False
    for p in S:
        while v % p == 0:
            v //= p
    return v == 1


# ---------------------------------------------------------------------------
# Linear algebra over GF(2) and over Q
# ---------------------------------------------------------------------------


def rank_gf2(rows: Sequence[Sequence[int]]) -> int:
    """Rank over GF(2) via XOR elimination on bit-packed rows."""
    basis: dict[int, int] = {}  # pivot bit -> row
    for row in rows:
        v = 0
        for j, a in enumerate(row):
            if a % 2:
                v |= 1 << j
        while v:
            h = v.bit_length() - 1
            if h in basis:
                v ^= basis[h]
            else:
                basis[h] = v
                break
    return len(basis)


def rank_rational(rows: Sequence[Sequence[int]]) -> int:
    """Exact rank over Q via fraction-based Gaussian elimination."""
    M = [[Fraction(a) for a in r] for r in rows]
    if not M:
        return 0
    rank, ncols = 0, len(M[0])
    for c in range(ncols):
        piv = next((i for i in range(rank, len(M)) if M[i][c] != 0), None)
        if piv is None:
            continue
        M[rank], M[piv] = M[piv], M[rank]
        for i in range(len(M)):
            if i != rank and M[i][c] != 0:
                f = M[i][c] / M[rank][c]
                M[i] = [a - f * b for a, b in zip(M[i], M[rank])]
        rank += 1
    return rank


def det_int(rows: Sequence[Sequence[int]]) -> int:
    """Exact integer determinant (Bareiss fraction-free elimination)."""
    M = [list(r) for r in rows]
    n = len(M)
    sign, prev = 1, 1
    for k in range(n - 1):
        if M[k][k] == 0:
            sw = next((i for i in range(k + 1, n) if M[i][k] != 0), None)
            if sw is None:
                return 0
            M[k], M[sw] = M[sw], M[k]
            sign = -sign
        for i in range(k + 1, n):
            for j in range(k + 1, n):
                M[i][j] = (M[i][j] * M[k][k] - M[i][k] * M[k][j]) // prev
        prev = M[k][k]
    return sign * M[n - 1][n - 1]


def k_success(vectors: Sequence[Sequence[int]]) -> int:
    """Length of the shortest linearly dependent prefix over GF(2)."""
    for k in range(1, len(vectors) + 1):
        if rank_gf2(vectors[:k]) < k:
            return k
    raise ValueError("no dependent prefix among the supplied vectors")


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------


def banner(title: str) -> None:
    print("\n" + "=" * 78 + f"\n{title}\n" + "=" * 78)


def demo_split_set_forcing() -> None:
    banner("1. Split-set forcing: the factor base IS the split set")
    N, x = 103764863, 10188
    v = x * x - N
    print(f"N = {N}, x = {x}: x^2 - N = {v} = {factorize(v)}")
    for r in factorize(v):
        print(f"   ({N}/{r}) = {legendre(N, r):+d}")
    for B in (100, 500, 2000):
        A = admissible_primes(N, B)
        R = sieve_reachable(N, B)
        pi_B = len(primes_upto(B))
        print(f"B = {B:5d}: pi(B) = {pi_B:4d}, Q(N,B) = {len(A):4d}, "
              f"inert = {pi_B - len(A):4d}, reachable == admissible: {A == R}")
    # Every prime factor (not dividing N) of every smooth sieve value is split.
    B = 500
    S = set(primes_upto(B))
    a = math.isqrt(N) + 1
    smooth = [y * y - N for y in range(a, a + 20000) if is_smooth_over(y * y - N, S)]
    bad = sum(1 for w in smooth for r in factorize(w) if N % r and legendre(N, r) != 1)
    print(f"{len(smooth)} smooth sieve values in a 20000-wide window (B={B}); "
          f"prime factors with (N/r) != +1: {bad}")


def demo_smooth_counts() -> None:
    banner("2. Smooth counts over a prime set, and the sign-flip criterion")
    print(f"Psi_{{2,3}}(100)   = {psi_S([2, 3], 100)}   (expected 20)")
    print(f"Psi_{{2,3}}(20)    = {psi_S([2, 3], 20)}   (expected 10)")
    print(f"Psi_{{2,3,5}}(100) = {psi_S([2, 3, 5], 100)}   (expected 34)")
    print("Multiplicative step  Psi_S(X) + Psi_S(X/p) <= Psi_{S+p}(X):",
          psi_S([2, 3], 100) + psi_S([2, 3], 20), "<=", psi_S([2, 3, 5], 100))
    w23, w235 = model_work([2, 3], 100), model_work([2, 3, 5], 100)
    print(f"work({{2,3}}) = {w23} = {float(w23):.4f};  work({{2,3,5}}) = {w235} = {float(w235):.4f}")
    print(f"Marginal criterion (|S|+1)*Psi_S(X/p) >= Psi_S(X):  3*10 = 30 >= 20 -> flip certified")
    print("\nFloor 2^|S| <= Psi_S(X) <= (floor(log2 X)+1)^|S| when prod(S) <= X:")
    X = 10 ** 6
    ps = primes_upto(60)
    for k in range(1, 8):
        S = ps[:k]
        if math.prod(S) > X:
            break
        lo, val, hi = 2 ** k, psi_S(S, X), (int(math.log2(X)) + 1) ** k
        print(f"  |S|={k}: {lo:6d} <= {val:7d} <= {hi:12d}")


def demo_paid_work_decreases() -> None:
    banner("3. Paid sieve work at fixed B DECREASES as the column set grows")
    N = 103764863
    B = 400
    A = admissible_primes(N, B)
    a = math.isqrt(N) + 1
    # Precompute factorisations along a long window once.
    window = 400000
    vals = [(y, y * y - N) for y in range(a, a + window)]
    Aset = set(A)
    smooth_full = [(y, w) for (y, w) in vals if is_smooth_over(w, Aset)]
    print(f"N = {N}, B = {B}, Q(N,B) = {len(A)}; smooth values in window: {len(smooth_full)}")
    print("Using only the q smallest admissible primes as columns:")
    print("   q   positions examined to collect q+1 relations")
    results: list[tuple[int, int]] = []
    for frac in (0.4, 0.55, 0.7, 0.85, 1.0):
        q = max(3, int(frac * len(A)))
        S = set(A[:q])
        needed, seen = q + 1, 0
        pos = None
        for (y, w) in smooth_full:
            if is_smooth_over(w, S):
                seen += 1
                if seen == needed:
                    pos = y - a + 1
                    break
        results.append((q, pos if pos is not None else -1))
        print(f"  {q:3d}   {pos if pos is not None else '> window'}")
    finite = [p for _, p in results if p > 0]
    if len(finite) >= 2:
        print(f"Ratio (smallest q) / (largest q) in paid work: {finite[0] / finite[-1]:.1f}x")


def demo_prefix_rank() -> None:
    banner("4. Prefix-rank identity:  k_success = rank(prefix k_success) + 1 <= Q + 1")
    rng = random.Random(42)
    for Q in (8, 16, 32):
        ks = []
        for _ in range(200):
            vecs = [[1 if rng.random() < 0.15 else 0 for _ in range(Q)] for _ in range(3 * Q)]
            k = k_success(vecs)
            assert k == rank_gf2(vecs[:k]) + 1 and k <= Q + 1
            assert k <= rank_gf2(vecs) + 1  # original chain with the FULL collected rank
            ks.append(k)
        print(f"Q = {Q:2d}: identity held 200/200; mean k_success/Q = {sum(ks) / len(ks) / Q:.2f}, "
              f"max = {max(ks)}")
    Q = 10
    basis = [[1 if j == i else 0 for j in range(Q)] for i in range(Q)] + [[1] * Q]
    print(f"Sharpness: standard basis first in GF(2)^{Q} gives k_success = {k_success(basis)} = Q + 1")


def demo_gf2_trap() -> None:
    banner("5. The GF(2)-rank trap")
    trap = [[1, 1, 0], [0, 1, 1], [1, 0, 1]]
    print(f"Triangle incidence matrix {trap}: det = {det_int(trap)}, "
          f"rank_Q = {rank_rational(trap)}, rank_GF2 = {rank_gf2(trap)}")
    rng = random.Random(7)
    disc = blind = 0
    for _ in range(2000):
        M = [[rng.randint(0, 1) for _ in range(4)] for _ in range(4)]
        d = det_int(M)
        full_q, full_2 = rank_rational(M) == 4, rank_gf2(M) == 4
        assert (full_q != full_2) == (d != 0 and d % 2 == 0)
        assert rank_gf2(M) <= rank_rational(M)
        disc += (d != 0 and d % 2 == 0)
        blind += not (d != 0 and d % 2 == 0)
    print(f"2000 random 0/1 4x4 matrices: criterion 'disagree <=> det nonzero even' held 2000/2000;")
    print(f"   discriminating test matrices: {disc}, blind ones: {blind}; rank_GF2 <= rank_Q always")
    # Mutation test: a deliberately wrong 'GF(2) rank' (actually rank over Q).
    suite_blind = [[[1, 0], [0, 1]], [[1, 1], [0, 1]], [[1, 1], [1, 1]]]
    suite_good = suite_blind + [trap]
    wrong = rank_rational
    for name, suite in (("odd/zero-det suite", suite_blind), ("suite with det=2 witness", suite_good)):
        caught = any(wrong(M) != rank_gf2(M) for M in suite)
        print(f"   mutation (Q-rank posing as GF(2)-rank) caught by {name}: {caught}")


def demo_large_primes() -> None:
    banner("6. Large-prime pairing: a + (b - D) > Q forces a square, same column space")
    A = [2, 3]
    full = [6]
    partials = [(2, 101), (3, 101), (6, 101)]  # (A-part s, large prime l)
    D = len({l for _, l in partials})
    a, b, Q = len(full), len(partials), len(A)
    print(f"Q = {Q}, a = {a}, b = {b}, D = {D}: a + (b - D) = {a + b - D} > Q ? {a + b - D > Q}")
    rep: dict[int, int] = {}
    combined: list[tuple[str, int]] = [(f"F{j}", f) for j, f in enumerate(full)]
    for i, (s, l) in enumerate(partials):
        if l in rep:
            j = rep[l]
            combined.append((f"P{i}*P{j}", s * l * partials[j][0] * l))
        else:
            rep[l] = i
    for T in range(1, len(combined) + 1):
        for sub in combinations(combined, T):
            prod = math.prod(v for _, v in sub)
            if math.isqrt(prod) ** 2 == prod:
                print(f"Square found: {' * '.join(n for n, _ in sub)} = {prod} = {math.isqrt(prod)}^2")
                break
        else:
            continue
        break
    # Birthday-type growth of b - D for large primes in (B, B^2] with weight ~ 1/l.
    rng = random.Random(1)
    B = 300
    big = [p for p in primes_upto(B * B) if p > B]
    weights = [1 / p for p in big]
    print("\nCollisions b - D among b partials (large primes in (B, B^2], weight ~ 1/l), B = 300:")
    for b2 in (50, 100, 200, 400, 800):
        trials = []
        for _ in range(40):
            ls = rng.choices(big, weights=weights, k=b2)
            trials.append(b2 - len(set(ls)))
        print(f"  b = {b2:4d}: mean (b - D) = {sum(trials) / len(trials):7.2f}")


def main() -> None:
    demo_split_set_forcing()
    demo_smooth_counts()
    demo_paid_work_decreases()
    demo_prefix_rank()
    demo_gf2_trap()
    demo_large_primes()


if __name__ == "__main__":
    main()
