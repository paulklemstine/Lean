#!/usr/bin/env python3
"""
Numerical demonstration of the factor-blindness of Q(a) = a^(N-1) mod N.

For a semiprime N = p*q with distinct primes p, q, this script verifies, purely
by direct computation, every quantitative claim of the accompanying paper:

  1. The asymmetric CRT split
         Q(a) = a^(q-1) mod p   in the left  CRT coordinate,
         Q(a) = a^(p-1) mod q   in the right CRT coordinate,
     together with CRT exactness (Q(a) is the unique residue below N with those
     two coordinates).

  2. The exponent gcd collapse
         gcd(N-1, p-1) = gcd(N-1, q-1) = g := gcd(p-1, q-1),
     and its consequence, the Euler-gap form of the Fermat test:
         u^(N-1) = 1  <=>  u^g = 1     for every unit u mod N.

  3. The liar count |L| = g^2, the liar group structure (Z/g) x (Z/g) exhibited
     as an explicit exponent lattice, the image size phi(N)/g^2, and the
     bijectivity criterion (the (N-1)-power map is a bijection iff g = 1).

  4. The reveal-density law: gcd(a^(N-1) - 1, N) returns a proper factor for
     exactly g(q-1) + g(p-1) - 2g^2 of the phi(N) units.

  5. The component-reading barrier: a component reader s, evaluated at the
     single base a = 1, yields the factor q as gcd(s(1), N).

  6. The contrast hint: N together with phi(N) factors N in closed form.

  7. Factor-blindness in the aggregate: correlations of Q with p, q, p+q and
     |p-q| across a family of near-equal-factor semiprimes, compared against a
     permutation null distribution.

Self-contained: standard library only.
"""

from __future__ import annotations

import math
import random
from typing import Dict, Iterable, List, Sequence, Tuple

# ----------------------------------------------------------------------------
# Elementary number theory
# ----------------------------------------------------------------------------


def is_prime(n: int) -> bool:
    """Deterministic Miller-Rabin, exact for all 64-bit inputs."""
    if n < 2:
        return False
    for small in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
        if n % small == 0:
            return n == small
    d, r = n - 1, 0
    while d % 2 == 0:
        d //= 2
        r += 1
    for a in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
        x = pow(a, d, n)
        if x in (1, n - 1):
            continue
        for _ in range(r - 1):
            x = x * x % n
            if x == n - 1:
                break
        else:
            return False
    return True


def primes_up_to(limit: int) -> List[int]:
    """Sieve of Eratosthenes."""
    sieve = bytearray([1]) * (limit + 1)
    sieve[0:2] = b"\x00\x00"
    for i in range(2, int(limit**0.5) + 1):
        if sieve[i]:
            sieve[i * i :: i] = bytearray(len(sieve[i * i :: i]))
    return [i for i, flag in enumerate(sieve) if flag]


def next_prime(n: int) -> int:
    """Smallest prime strictly greater than n."""
    candidate = n + 1
    while not is_prime(candidate):
        candidate += 1
    return candidate


def euler_gap(p: int, q: int) -> int:
    """g = gcd(p-1, q-1)."""
    return math.gcd(p - 1, q - 1)


def fetq(N: int, a: int) -> int:
    """Q(a) = a^(N-1) mod N, computed by square-and-multiply."""
    return pow(a, N - 1, N)


def pow_mod_depth(n: int) -> int:
    """Recursion depth of binary exponentiation on exponent n."""
    depth = 0
    while n > 0:
        n //= 2
        depth += 1
    return depth


def units_mod(N: int) -> List[int]:
    """All residues in [0, N) coprime to N."""
    return [a for a in range(N) if math.gcd(a, N) == 1]


def multiplicative_order(a: int, m: int) -> int:
    """Least k >= 1 with a^k = 1 mod m (assumes gcd(a, m) = 1)."""
    k, value = 1, a % m
    while value != 1:
        value = value * a % m
        k += 1
    return k


# ----------------------------------------------------------------------------
# 1. The asymmetric CRT split and its exactness
# ----------------------------------------------------------------------------


def check_asymmetric_split(p: int, q: int, a: int) -> Dict[str, int | bool]:
    """Verify Q(a) mod p = a^(q-1) mod p and Q(a) mod q = a^(p-1) mod q."""
    N = p * q
    Q = fetq(N, a)
    left, left_pred = Q % p, pow(a, q - 1, p)
    right, right_pred = Q % q, pow(a, p - 1, q)
    # CRT exactness: Q is the unique residue < N with these two coordinates.
    unique = [x for x in range(N) if x % p == left_pred and x % q == right_pred]
    return {
        "N": N,
        "a": a,
        "Q": Q,
        "left": left,
        "left_pred": left_pred,
        "right": right,
        "right_pred": right_pred,
        "split_ok": left == left_pred and right == right_pred,
        "unique_ok": unique == [Q],
    }


def demo_split() -> None:
    print("=" * 78)
    print("1. THE ASYMMETRIC CRT SPLIT:  Q(a) = a^(q-1) mod p ,  a^(p-1) mod q")
    print("=" * 78)
    header = f"{'N = p*q':<14}{'a':>3}{'Q(a)':>8}{'Q mod p':>10}{'a^(q-1)':>10}"
    print(header + f"{'Q mod q':>10}{'a^(p-1)':>10}{'unique':>9}")
    rows = [(3, 5, 2), (3, 7, 2), (3, 11, 2), (5, 7, 3), (7, 13, 5), (11, 13, 2)]
    all_ok = True
    for p, q, a in rows:
        r = check_asymmetric_split(p, q, a)
        all_ok &= bool(r["split_ok"]) and bool(r["unique_ok"])
        label = f"{r['N']} = {p}*{q}"
        print(
            f"{label:<14}{a:>3}{r['Q']:>8}{r['left']:>10}{r['left_pred']:>10}"
            f"{r['right']:>10}{r['right_pred']:>10}{str(r['unique_ok']):>9}"
        )
    # Exhaustive sweep, matching the reported experiment.
    small = [p for p in primes_up_to(19)]
    checked = 0
    for p in small:
        for q in small:
            if p == q:
                continue
            for a in (2, 3, 5):
                if math.gcd(a, p * q) != 1:
                    continue
                r = check_asymmetric_split(p, q, a)
                all_ok &= bool(r["split_ok"]) and bool(r["unique_ok"])
                checked += 1
    print(f"\nExhaustive sweep p,q <= 19 distinct, a in {{2,3,5}}: "
          f"{checked} triples, all correct = {all_ok}")


# ----------------------------------------------------------------------------
# 2. The exponent gcd collapse and the Euler-gap form of the Fermat test
# ----------------------------------------------------------------------------


def demo_gap_collapse() -> None:
    print()
    print("=" * 78)
    print("2. EXPONENT GCD COLLAPSE:  gcd(N-1, p-1) = gcd(N-1, q-1) = g")
    print("=" * 78)
    print(f"{'N':<8}{'p,q':<10}{'gcd(N-1,p-1)':>14}{'gcd(N-1,q-1)':>14}{'g':>5}"
          f"{'Fermat=g-test':>16}")
    for p, q in [(3, 5), (3, 11), (5, 7), (7, 13), (11, 13), (13, 17), (11, 31)]:
        N, g = p * q, euler_gap(p, q)
        gl, gr = math.gcd(N - 1, p - 1), math.gcd(N - 1, q - 1)
        same = all(
            (pow(u, N - 1, N) == 1) == (pow(u, g, N) == 1) for u in units_mod(N)
        )
        print(f"{N:<8}{f'{p},{q}':<10}{gl:>14}{gr:>14}{g:>5}{str(same):>16}")


# ----------------------------------------------------------------------------
# 3. Liar count, liar group, image size, bijectivity
# ----------------------------------------------------------------------------


def liar_data(p: int, q: int) -> Dict[str, object]:
    """Fermat liars, image size and bijectivity for N = p*q."""
    N, g = p * q, euler_gap(p, q)
    us = units_mod(N)
    liars = [u for u in us if pow(u, N - 1, N) == 1]
    image = {pow(u, N - 1, N) for u in us}
    return {
        "N": N,
        "g": g,
        "phi": (p - 1) * (q - 1),
        "liars": len(liars),
        "g2": g * g,
        "image": len(image),
        "phi_over_g2": (p - 1) * (q - 1) // (g * g),
        "bijective": len(image) == len(us),
    }


def liar_group_exponents(p: int, q: int) -> Tuple[List[Tuple[int, int]], int]:
    """Exhibit the liar group as a Z/g x Z/g lattice of CRT-coordinate exponents.

    Each liar corresponds to a pair (i, j) of exponents of the g-torsion
    generators in the two CRT coordinates.
    """
    N, g = p * q, euler_gap(p, q)
    gp = primitive_root(p)
    gq = primitive_root(q)
    tp = pow(gp, (p - 1) // g, p)  # generator of the g-torsion mod p
    tq = pow(gq, (q - 1) // g, q)  # generator of the g-torsion mod q
    pairs: List[Tuple[int, int]] = []
    for i in range(g):
        for j in range(g):
            x, y = pow(tp, i, p), pow(tq, j, q)
            u = crt(x, p, y, q)
            assert pow(u, N - 1, N) == 1, "lattice point is not a Fermat liar"
            pairs.append((i, j))
    return pairs, g


def primitive_root(r: int) -> int:
    """A generator of the cyclic group (Z/r)^* for prime r."""
    if r == 2:
        return 1
    factors = distinct_prime_factors(r - 1)
    for cand in range(2, r):
        if all(pow(cand, (r - 1) // f, r) != 1 for f in factors):
            return cand
    raise ValueError(f"no primitive root found mod {r}")


def distinct_prime_factors(n: int) -> List[int]:
    """Distinct prime factors of n by trial division."""
    out, d = [], 2
    while d * d <= n:
        if n % d == 0:
            out.append(d)
            while n % d == 0:
                n //= d
        d += 1
    if n > 1:
        out.append(n)
    return out


def crt(x: int, p: int, y: int, q: int) -> int:
    """The unique residue mod p*q congruent to x mod p and y mod q."""
    inv = pow(p, -1, q)
    return (x + p * ((y - x) * inv % q)) % (p * q)


def demo_liars() -> None:
    print()
    print("=" * 78)
    print("3. LIAR COUNT g^2, IMAGE SIZE phi(N)/g^2, BIJECTIVITY  <=>  g = 1")
    print("=" * 78)
    print(f"{'N':<8}{'p,q':<10}{'g':>4}{'liars':>8}{'g^2':>6}{'|image|':>9}"
          f"{'phi/g^2':>9}{'bijective':>11}")
    for p, q in [(3, 5), (3, 11), (5, 7), (7, 13), (11, 13), (5, 11), (7, 11)]:
        d = liar_data(p, q)
        print(f"{d['N']:<8}{f'{p},{q}':<10}{d['g']:>4}{d['liars']:>8}{d['g2']:>6}"
              f"{d['image']:>9}{d['phi_over_g2']:>9}{str(d['bijective']):>11}")
    print("\nLiar group as an exponent lattice (Z/g x Z/g), N = 91 = 7*13:")
    pairs, g = liar_group_exponents(7, 13)
    print(f"  g = {g}, lattice has {len(pairs)} = {g}^2 points, "
          f"each a verified Fermat liar.")


# ----------------------------------------------------------------------------
# 4. The reveal-density law
# ----------------------------------------------------------------------------


def reveal_count(p: int, q: int) -> Tuple[int, int]:
    """(measured, predicted) count of bases for which the gcd variant fires."""
    N, g = p * q, euler_gap(p, q)
    measured = 0
    for a in units_mod(N):
        # gcd(a^(N-1) - 1, N), computed from the residue Q(a) for efficiency
        d = math.gcd((fetq(N, a) - 1) % N, N)
        if 1 < d < N:
            measured += 1
    predicted = g * (q - 1) + g * (p - 1) - 2 * g * g
    return measured, predicted


def demo_reveal() -> None:
    print()
    print("=" * 78)
    print("4. REVEAL DENSITY:  gcd(a^(N-1)-1, N) fires for g(q-1)+g(p-1)-2g^2 bases")
    print("=" * 78)
    print(f"{'N':<8}{'p,q':<10}{'g':>4}{'measured':>10}{'predicted':>11}"
          f"{'density':>10}{'~ g/p+g/q':>12}")
    for p, q in [(3, 5), (5, 7), (3, 11), (7, 13), (11, 13), (11, 31),
                 (101, 103), (101, 211), (211, 401)]:
        N, g = p * q, euler_gap(p, q)
        measured, predicted = reveal_count(p, q)
        phi = (p - 1) * (q - 1)
        print(f"{N:<8}{f'{p},{q}':<10}{g:>4}{measured:>10}{predicted:>11}"
              f"{measured / phi:>10.4f}{g / p + g / q:>12.4f}")


# ----------------------------------------------------------------------------
# 5. The component-reading barrier
# ----------------------------------------------------------------------------


def component_reader(p: int, q: int) -> "callable":
    """Build a component reader: s(a) = a^(q-1) mod p in the left coordinate,
    0 in the right coordinate.  Constructing it needs the factorisation; the
    barrier says that owning it is equivalent to owning the factorisation."""

    def s(a: int) -> int:
        return crt(pow(a, q - 1, p), p, 0, q)

    return s


def demo_barrier() -> None:
    print()
    print("=" * 78)
    print("5. COMPONENT-READING BARRIER:  gcd(s(1), N) = q, from the base a = 1")
    print("=" * 78)
    print(f"{'N':<10}{'p,q':<12}{'s(1)':>10}{'gcd(s(1),N)':>14}{'= q':>8}")
    for p, q in [(3, 5), (5, 7), (7, 13), (11, 13), (101, 103), (10007, 10009)]:
        N = p * q
        s = component_reader(p, q)
        val = s(1)
        d = math.gcd(val, N)
        print(f"{N:<10}{f'{p},{q}':<12}{val:>10}{d:>14}{str(d == q):>8}")
    print("\nSame engine, two classical splits:")
    # Nontrivial idempotent: e = crt(1, p, 0, q).
    p, q = 101, 103
    N = p * q
    e = crt(1, p, 0, q)
    print(f"  idempotent e = {e} mod {N}:  e^2 = e mod N is "
          f"{pow(e, 2, N) == e % N}, gcd(e, N) = {math.gcd(e, N)}")
    # Nontrivial square root of 1: x = crt(1, p, -1, q).
    x = crt(1, p, q - 1, q)
    print(f"  sqrt of 1:  x = {x}, x^2 mod N = {pow(x, 2, N)}, "
          f"gcd(x-1, N) = {math.gcd(x - 1, N)}")


# ----------------------------------------------------------------------------
# 6. The contrast hint: the totient factors N in closed form
# ----------------------------------------------------------------------------


def factor_from_totient(N: int, phi: int) -> Tuple[int, int]:
    """Recover (p, q) from N = p*q and phi(N) = (p-1)(q-1) in closed form."""
    s = N + 1 - phi                       # s = p + q
    disc = math.isqrt(s * s - 4 * N)      # disc = |p - q|
    return (s + disc) // 2, (s - disc) // 2


def demo_totient_contrast() -> None:
    print()
    print("=" * 78)
    print("6. CONTRAST: the totient IS a factoring hint (closed form)")
    print("=" * 78)
    print(f"{'N':<14}{'phi(N)':<14}{'recovered p':>13}{'recovered q':>13}{'ok':>6}")
    for p, q in [(101, 103), (1009, 1013), (100003, 100019), (1000003, 1000033)]:
        N, phi = p * q, (p - 1) * (q - 1)
        rp, rq = factor_from_totient(N, phi)
        print(f"{N:<14}{phi:<14}{rp:>13}{rq:>13}{str({rp, rq} == {p, q}):>6}")
    print("\nBy contrast, Q(a) determines nothing beyond (N, g): see section 7.")


# ----------------------------------------------------------------------------
# 7. Factor-blindness at scale: correlations against a permutation null
# ----------------------------------------------------------------------------


def pearson(xs: Sequence[float], ys: Sequence[float]) -> float:
    """Pearson correlation coefficient."""
    n = len(xs)
    mx, my = sum(xs) / n, sum(ys) / n
    sxy = sum((x - mx) * (y - my) for x, y in zip(xs, ys))
    sxx = sum((x - mx) ** 2 for x in xs)
    syy = sum((y - my) ** 2 for y in ys)
    if sxx == 0 or syy == 0:
        return 0.0
    return sxy / math.sqrt(sxx * syy)


def near_equal_semiprimes(target: int, count: int) -> List[Tuple[int, int]]:
    """Semiprimes p*q near `target` with p, q of near-equal size."""
    root = math.isqrt(target)
    out: List[Tuple[int, int]] = []
    p = root
    while len(out) < count:
        p = next_prime(p)
        q = next_prime(p)
        out.append((p, q))
    return out


def permutation_null(
    xs: Sequence[float], ys: Sequence[float], shuffles: int, rng: random.Random
) -> float:
    """95th percentile of |corr| under random relabelling of ys."""
    perm = list(ys)
    vals: List[float] = []
    for _ in range(shuffles):
        rng.shuffle(perm)
        vals.append(abs(pearson(xs, perm)))
    vals.sort()
    return vals[int(0.95 * (len(vals) - 1))]


def demo_factor_blindness(
    family_size: int = 80, target: int = 10**7, shuffles: int = 300, seed: int = 20260812
) -> None:
    print()
    print("=" * 78)
    print("7. FACTOR-BLINDNESS AT SCALE: corr(Q, factor statistics) vs. null")
    print("=" * 78)
    rng = random.Random(seed)
    pairs = near_equal_semiprimes(target, family_size)
    stats: Dict[str, List[float]] = {
        "p": [float(p) for p, _ in pairs],
        "q": [float(q) for _, q in pairs],
        "p+q": [float(p + q) for p, q in pairs],
        "|p-q|": [float(abs(p - q)) for p, q in pairs],
        "g": [float(euler_gap(p, q)) for p, q in pairs],
    }
    print(f"family: {family_size} semiprimes with near-equal factors around "
          f"{target:.1e}")
    print(f"{'base a':>7}{'statistic':>10}{'|corr(Q, .)|':>14}"
          f"{'null 95th pct':>15}{'inside null':>13}")
    for a in (2, 3, 5):
        qs = [float(fetq(p * q, a)) for p, q in pairs]
        for name in ("p", "q", "p+q", "|p-q|"):
            obs = abs(pearson(qs, stats[name]))
            thr = permutation_null(qs, stats[name], shuffles, rng)
            print(f"{a:>7}{name:>10}{obs:>14.4f}{thr:>15.4f}"
                  f"{str(obs <= thr):>13}")
    print("\nQ(a) mod N is a function of N alone; the factor-dependence sits in")
    print("the CRT coordinates, and reading a coordinate is factoring.")


# ----------------------------------------------------------------------------
# 8. Cost of Q
# ----------------------------------------------------------------------------


def demo_cost() -> None:
    print()
    print("=" * 78)
    print("8. COST:  Q(a) needs O(log N) modular multiplications")
    print("=" * 78)
    print(f"{'bit-size of N':>15}{'recursion depth':>18}{'binary length':>16}")
    for bits in (16, 32, 64, 128, 512, 1024, 2048):
        N = (1 << bits) - 1
        depth = pow_mod_depth(N - 1)
        print(f"{bits:>15}{depth:>18}{(N - 1).bit_length():>16}")


# ----------------------------------------------------------------------------


def main() -> None:
    print("Factor-blindness of Q(a) = a^(N-1) mod N — numerical demonstration")
    demo_split()
    demo_gap_collapse()
    demo_liars()
    demo_reveal()
    demo_barrier()
    demo_totient_contrast()
    demo_factor_blindness()
    demo_cost()
    print()
    print("=" * 78)
    print("SUMMARY: the asymmetry Q(a) = a^(q-1) mod p, a^(p-1) mod q is exact,")
    print("but reading a coordinate is factoring, every multiplicative statistic")
    print("collapses onto g = gcd(p-1, q-1), and the gcd variant reveals a factor")
    print("for exactly g(q-1) + g(p-1) - 2g^2 bases.  Q is factor-blind.")
    print("=" * 78)


if __name__ == "__main__":
    main()
