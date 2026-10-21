#!/usr/bin/env python3
"""
Large primes are split primes: numerical companion.

This script illustrates, on concrete numbers, the results of the paper
"Large Primes Are Split Primes: Why the Large-Prime Variant of the Quadratic
Sieve Cannot Decouple the Factor Base from the Split Set".

Sections
--------
1. The headline instance  N = 15916539906629, c = 3989570.
2. Scan of many sieve values c^2 - N: every prime factor r (r not dividing N)
   satisfies (N/r) = +1.
3. The per-period hit count equals 1 + (N/r).
4. Split primes are a union of residue classes modulo 4N.
5. A toy quadratic sieve with the single-large-prime variant: partial
   relations, pairing, and the final GF(2) matrix with Q(B) columns.
6. (Conjectural) split-restricted birthday law for large-prime collisions.

Only the Python standard library is used.
"""
from __future__ import annotations

import math
import random
from collections import defaultdict
from typing import Dict, List, Optional, Tuple

# ---------------------------------------------------------------------------
# Elementary number theory
# ---------------------------------------------------------------------------


def is_probable_prime(n: int) -> bool:
    """Deterministic Miller-Rabin for n < 3.3 * 10^24 (fixed witness set)."""
    if n < 2:
        return False
    small = (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37)
    for p in small:
        if n % p == 0:
            return n == p
    d, s = n - 1, 0
    while d % 2 == 0:
        d //= 2
        s += 1
    for a in small:
        x = pow(a, d, n)
        if x in (1, n - 1):
            continue
        for _ in range(s - 1):
            x = x * x % n
            if x == n - 1:
                break
        else:
            return False
    return True


def pollard_rho(n: int) -> int:
    """Return a nontrivial factor of the composite n (Brent's variant)."""
    if n % 2 == 0:
        return 2
    rng = random.Random(n)
    while True:
        y, c, m = rng.randrange(1, n), rng.randrange(1, n), 128
        g, r, q = 1, 1, 1
        x = ys = y
        while g == 1:
            x = y
            for _ in range(r):
                y = (y * y + c) % n
            k = 0
            while k < r and g == 1:
                ys = y
                for _ in range(min(m, r - k)):
                    y = (y * y + c) % n
                    q = q * abs(x - y) % n
                g = math.gcd(q, n)
                k += m
            r *= 2
        if g == n:
            g = 1
            while g == 1:
                ys = (ys * ys + c) % n
                g = math.gcd(abs(x - ys), n)
        if g != n:
            return g


def factorize(n: int) -> Dict[int, int]:
    """Prime factorisation of |n| as a dict prime -> exponent."""
    n = abs(n)
    out: Dict[int, int] = defaultdict(int)
    for p in (2, 3, 5, 7, 11, 13):
        while n % p == 0:
            out[p] += 1
            n //= p
    stack = [n] if n > 1 else []
    while stack:
        m = stack.pop()
        if m == 1:
            continue
        if is_probable_prime(m):
            out[m] += 1
            continue
        d = pollard_rho(m)
        stack += [d, m // d]
    return dict(out)


def legendre(a: int, p: int) -> int:
    """Legendre symbol (a/p) for an odd prime p, via Euler's criterion."""
    a %= p
    if a == 0:
        return 0
    return 1 if pow(a, (p - 1) // 2, p) == 1 else -1


def jacobi(a: int, n: int) -> int:
    """Jacobi symbol (a/n) for odd n > 0 (binary algorithm)."""
    assert n > 0 and n % 2 == 1
    a %= n
    result = 1
    while a:
        while a % 2 == 0:
            a //= 2
            if n % 8 in (3, 5):
                result = -result
        a, n = n, a
        if a % 4 == 3 and n % 4 == 3:
            result = -result
        a %= n
    return result if n == 1 else 0


def primes_upto(n: int) -> List[int]:
    """Sieve of Eratosthenes."""
    if n < 2:
        return []
    sieve = bytearray([1]) * (n + 1)
    sieve[0:2] = b"\x00\x00"
    for i in range(2, math.isqrt(n) + 1):
        if sieve[i]:
            sieve[i * i :: i] = bytearray(len(range(i * i, n + 1, i)))
    return [i for i in range(n + 1) if sieve[i]]


def is_split_or_ramified(N: int, p: int) -> bool:
    """True iff N is a square modulo p (the 'admissible' condition)."""
    if p == 2:
        return True  # every residue is a square mod 2
    return legendre(N, p) != -1


def admissible_primes(N: int, L: int) -> List[int]:
    """The split set: primes p <= L with N a square mod p.  Q(L) = its size."""
    return [p for p in primes_upto(L) if is_split_or_ramified(N, p)]


def hit_count(N: int, r: int) -> int:
    """Number of residues c mod r with r | c^2 - N."""
    return sum(1 for c in range(r) if (c * c - N) % r == 0)


# ---------------------------------------------------------------------------
# Section 1: the headline instance
# ---------------------------------------------------------------------------


def section_instance() -> None:
    print("=" * 72)
    print("1. The headline instance")
    print("=" * 72)
    N, c = 15916539906629, 3989570
    v = c * c - N
    print(f"N = {N},  c = {c},  floor(sqrt N) = {math.isqrt(N)}")
    print(f"f(c) = c^2 - N = {v}")
    print(f"f(c) is prime: {is_probable_prime(v)}")
    print(f"N mod f(c) = {N % v},  c^2 mod f(c) = {c * c % v}  (equal: N is a square mod r)")
    print(f"Legendre symbol (N / {v}) = {legendre(N, v)}")
    print("=> the whole value is a single 'large prime' with smooth part 1, and that")
    print("   large prime splits, exactly as the one-line argument predicts.\n")


# ---------------------------------------------------------------------------
# Section 2: scan many sieve values
# ---------------------------------------------------------------------------


def section_scan(N: int = 15916539906629, count: int = 400) -> None:
    print("=" * 72)
    print("2. Every prime divisor of every sieve value is split")
    print("=" * 72)
    c0 = math.isqrt(N) + 1
    checked = split = ramified = inert = 0
    largest = 0
    for c in range(c0, c0 + count):
        for r in factorize(c * c - N):
            if r == 2:
                continue
            checked += 1
            s = legendre(N, r)
            if s == 1:
                split += 1
                largest = max(largest, r)
            elif s == 0:
                ramified += 1
            else:
                inert += 1
    print(f"values scanned: {count} (c = {c0} .. {c0 + count - 1})")
    print(f"odd prime divisors checked: {checked}")
    print(f"  split (N/r)=+1   : {split}")
    print(f"  ramified (N/r)=0 : {ramified}")
    print(f"  inert (N/r)=-1   : {inert}   <-- the theorem says this is always 0")
    print(f"largest split prime divisor seen: {largest}\n")
    assert inert == 0


# ---------------------------------------------------------------------------
# Section 3: hit counts
# ---------------------------------------------------------------------------


def section_hit_count(N: int = 87463) -> None:
    print("=" * 72)
    print(f"3. Hit count per period = 1 + (N/r)    (N = {N})")
    print("=" * 72)
    print(f"{'r':>5} {'(N/r)':>6} {'hits':>5} {'1+(N/r)':>8}")
    for r in primes_upto(60)[1:]:
        s, h = legendre(N, r), hit_count(N, r)
        assert h == 1 + s
        print(f"{r:>5} {s:>6} {h:>5} {1 + s:>8}")
    print("Inert primes (symbol -1) have zero hits: they can never be a column.\n")


# ---------------------------------------------------------------------------
# Section 4: periodicity modulo 4N
# ---------------------------------------------------------------------------


def section_periodicity(N: int = 15) -> None:
    print("=" * 72)
    print(f"4. Splitness depends only on r mod 4N     (N = {N}, 4N = {4 * N})")
    print("=" * 72)
    classes: Dict[int, set] = defaultdict(set)
    for r in primes_upto(20000)[1:]:
        if N % r == 0:
            continue
        classes[r % (4 * N)].add(legendre(N, r))
    consistent = all(len(v) == 1 for v in classes.values())
    split_classes = sorted(k for k, v in classes.items() if v == {1})
    inert_classes = sorted(k for k, v in classes.items() if v == {-1})
    print(f"each class mod {4 * N} has a single symbol value: {consistent}")
    print(f"split classes : {split_classes}")
    print(f"inert classes : {inert_classes}")
    print(f"phi(4N)/2 = {sum(1 for a in range(4 * N) if math.gcd(a, 4 * N) == 1) // 2}"
          f" ; number of split classes = {len(split_classes)}")
    # Jacobi symbol agrees with Legendre on the class
    for k in split_classes[:3]:
        print(f"  Jacobi(N | {k}) = {jacobi(N, k) if k % 2 else 'n/a'}")
    print()


# ---------------------------------------------------------------------------
# Section 5: toy quadratic sieve with large primes
# ---------------------------------------------------------------------------

Relation = Tuple[int, int, Dict[int, int]]  # (x, value, factorisation of value)


def smooth_part(v: int, base: List[int]) -> Tuple[Dict[int, int], int]:
    """Divide |v| by the factor base; return (exponents, cofactor)."""
    v = abs(v)
    exps: Dict[int, int] = {}
    for p in base:
        if v % p == 0:
            e = 0
            while v % p == 0:
                v //= p
                e += 1
            exps[p] = e
    return exps, v


def gf2_dependency(rows: List[Dict[int, int]], cols: List[int]) -> Optional[List[int]]:
    """Find a nonempty subset of rows whose exponent vectors sum to 0 mod 2."""
    index = {p: i for i, p in enumerate(cols)}
    pivots: Dict[int, Tuple[int, int]] = {}  # pivot bit -> (vector, combination mask)
    for k, row in enumerate(rows):
        vec = 0
        for p, e in row.items():
            if e % 2:
                vec ^= 1 << index[p]
        comb = 1 << k
        while vec:
            top = vec.bit_length() - 1
            if top not in pivots:
                pivots[top] = (vec, comb)
                break
            pv, pc = pivots[top]
            vec ^= pv
            comb ^= pc
        if vec == 0:
            return [i for i in range(len(rows)) if comb >> i & 1]
    return None


def toy_lp_sieve(N: int, B: int, L: int, span: int) -> None:
    print("=" * 72)
    print(f"5. Toy QS with the large-prime variant   N = {N}, B = {B}, L = {L}")
    print("=" * 72)
    base = [p for p in admissible_primes(N, B) if N % p != 0 or p == 2]
    sign_col = -1
    c0 = math.isqrt(N) + 1
    fulls: List[Relation] = []
    partials: Dict[int, List[Relation]] = defaultdict(list)
    for x in range(c0 - span, c0 + span):
        v = x * x - N
        if v == 0:
            continue
        exps, cof = smooth_part(v, base)
        if v < 0:
            exps[sign_col] = 1
        if cof == 1:
            fulls.append((x, v, exps))
        elif B < cof <= L and is_probable_prime(cof):
            assert legendre(N, cof) != -1, "an inert large prime?!"
            partials[cof].append((x, v, exps))
    n_part = sum(len(v) for v in partials.values())
    print(f"Q(B) = |split set up to B| = {len(base)}   Q(L) = {len(admissible_primes(N, L))}")
    print(f"full relations: {len(fulls)}   partial relations: {n_part}")
    print(f"distinct large primes: {len(partials)}  (none inert -- checked by assertion)")
    combined: List[Relation] = []
    for r, group in partials.items():
        x1, v1, e1 = group[0]
        for x2, v2, e2 in group[1:]:
            e = defaultdict(int)
            for d in (e1, e2):
                for p, k in d.items():
                    e[p] += k
            # r appears squared in v1*v2: it cancels mod 2 and leaves the matrix
            combined.append((x1 * x2, v1 * v2, dict(e)))
    print(f"combined relations from pairs: {len(combined)}"
          " (their large prime appears squared and drops out)")
    rows = fulls + combined
    cols = [sign_col] + base
    print(f"final GF(2) matrix: {len(rows)} rows x {len(cols)} columns"
          f" (= Q(B) + 1 sign column, independent of L)")
    # try every dependency until a factor appears
    remaining = list(range(len(rows)))
    for attempt in range(40):
        random.Random(attempt).shuffle(remaining)
        dep = gf2_dependency([rows[i][2] for i in remaining], cols)
        if dep is None:
            print("not enough relations for a dependency")
            return
        chosen = [rows[remaining[i]] for i in dep]
        X = 1
        Y2 = 1
        for x, v, _ in chosen:
            X = X * x % N
            Y2 *= v
        Y = math.isqrt(abs(Y2))
        assert Y * Y == abs(Y2)
        g = math.gcd(X - Y, N)
        if 1 < g < N:
            print(f"dependency of size {len(dep)} gives gcd(X - Y, N) = {g};"
                  f"  N = {g} * {N // g}\n")
            return
    print("no nontrivial factor found in 40 dependencies\n")


# ---------------------------------------------------------------------------
# Section 6: birthday law (conjectural)
# ---------------------------------------------------------------------------


def section_birthday(N: int = 15916539906629, B: int = 2000, L: int = 200000,
                     trials: int = 4000, m: int = 60) -> None:
    print("=" * 72)
    print("6. Split-restricted birthday law (a conjecture -- heuristic check only)")
    print("=" * 72)
    lo = primes_upto(L)
    all_large = [p for p in lo if p > B]
    split_large = [p for p in all_large if legendre(N, p) == 1]
    rng = random.Random(1)

    def mean_pairs(pool: List[int]) -> float:
        tot = 0
        for _ in range(trials):
            seen: Dict[int, int] = defaultdict(int)
            for _ in range(m):
                seen[rng.choice(pool)] += 1
            tot += sum(k * (k - 1) // 2 for k in seen.values())
        return tot / trials

    print(f"primes in (B, L]: {len(all_large)};  split ones Q(L) - Q(B) = {len(split_large)}")
    print(f"m = {m} partials, uniform model:")
    print(f"  predicted pairs, split denominator  m^2/(2(Q(L)-Q(B))) = "
          f"{m * m / (2 * len(split_large)):.4f}; simulated {mean_pairs(split_large):.4f}")
    print(f"  predicted pairs, naive denominator  m^2/(2(pi(L)-pi(B))) = "
          f"{m * m / (2 * len(all_large)):.4f}; simulated {mean_pairs(all_large):.4f}")
    print("Real large primes come only from the split pool, so the first line is the")
    print("relevant model: about twice as many collisions as the naive estimate.\n")


def main() -> None:
    section_instance()
    section_scan()
    section_hit_count()
    section_periodicity()
    toy_lp_sieve(N=87463, B=60, L=3000, span=1500)
    toy_lp_sieve(N=1000000016000000063, B=4000, L=400000, span=60000)
    section_birthday()


if __name__ == "__main__":
    main()
