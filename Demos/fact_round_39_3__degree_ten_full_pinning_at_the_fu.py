#!/usr/bin/env python3
"""
Full pinning at degree ten: the cyclotomic field Q(zeta_11).

Numerical companion to the paper.  Everything is computed from scratch:

  1. The Frobenius type T(p) = ord_11(p) and its Chebotarev densities phi(d)/10.
  2. Exact type entropy H(T) = log2(5) - 3/5 and full pinning I(p mod 11; T) = H(T).
  3. The loss H(p mod 11 | T) = 8/5 bits, and per-class degeneracy H(T | p mod 11) = 0.
  4. An independent polynomial check: factor-degree patterns of Phi_11 over F_p
     (computed by distinct-degree factorisation, NOT from the order of p).
  5. The tower Q < Q(zeta_11)^+ < Q(zeta_11): H(T+) = log2(5) - 8/5, the tower bit,
     and the CRT split C10 = C2 x C5.
  6. The semiprime channel I(N mod 11; {T(p), T(q)}) = log2 5 + (12/25) log2 3 - 47/25,
     the vanishing which-factor wall, and the attenuation 32/25 - (12/25) log2 3.
  7. Certified enclosures of log2 5 and log2 3 from exact integer power comparisons.
  8. An empirical check of the densities on actual primes.

Only the Python standard library is used.
"""
from __future__ import annotations

import math
from collections import Counter
from fractions import Fraction
from typing import Callable, Dict, Hashable, Iterable, List, Sequence, Tuple, TypeVar

ELL: int = 11                     # conductor
UNITS: List[int] = list(range(1, ELL))   # (Z/11)^x, uniform Frobenius model
K = TypeVar("K", bound=Hashable)


# ---------------------------------------------------------------- basic arithmetic
def mult_order(a: int, n: int) -> int:
    """Multiplicative order of a modulo n (gcd(a, n) = 1 assumed)."""
    a %= n
    k, x = 1, a
    while x != 1:
        x = (x * a) % n
        k += 1
    return k


def totient(n: int) -> int:
    return sum(1 for k in range(1, n + 1) if math.gcd(k, n) == 1)


def divisors(n: int) -> List[int]:
    return [d for d in range(1, n + 1) if n % d == 0]


def primes_up_to(n: int) -> List[int]:
    sieve = bytearray([1]) * (n + 1)
    sieve[0:2] = b"\x00\x00"
    for i in range(2, int(n ** 0.5) + 1):
        if sieve[i]:
            sieve[i * i:: i] = bytearray(len(sieve[i * i:: i]))
    return [i for i in range(n + 1) if sieve[i]]


# ---------------------------------------------------------------- information theory
def entropy(sample: Sequence[object], f: Callable[[object], K]) -> float:
    """Shannon entropy (bits) of the readout f on a uniform finite sample."""
    counts = Counter(f(w) for w in sample)
    n = len(sample)
    return -sum((c / n) * math.log2(c / n) for c in counts.values())


def mutual_info(sample: Sequence[object], f: Callable[[object], K],
                g: Callable[[object], K]) -> float:
    """I(f; g) = H(f) + H(g) - H(f, g)."""
    return (entropy(sample, f) + entropy(sample, g)
            - entropy(sample, lambda w: (f(w), g(w))))


def cond_entropy(sample: Sequence[object], f: Callable[[object], K],
                 g: Callable[[object], K]) -> float:
    """H(f | g) = H(f, g) - H(g)."""
    return entropy(sample, lambda w: (f(w), g(w))) - entropy(sample, g)


# ---------------------------------------------------------------- polynomials over F_p
Poly = List[int]  # coefficient list, lowest degree first


def trim(a: Poly) -> Poly:
    while a and a[-1] == 0:
        a.pop()
    return a


def pmod(a: Poly, b: Poly, p: int) -> Poly:
    a = a[:]
    inv = pow(b[-1], p - 2, p)
    while len(a) >= len(b) and trim(a):
        if len(a) < len(b):
            break
        c = (a[-1] * inv) % p
        s = len(a) - len(b)
        for i, bi in enumerate(b):
            a[s + i] = (a[s + i] - c * bi) % p
        trim(a)
    return a


def pmul(a: Poly, b: Poly, p: int) -> Poly:
    if not a or not b:
        return []
    r = [0] * (len(a) + len(b) - 1)
    for i, ai in enumerate(a):
        if ai:
            for j, bj in enumerate(b):
                r[i + j] = (r[i + j] + ai * bj) % p
    return trim(r)


def pgcd(a: Poly, b: Poly, p: int) -> Poly:
    a, b = trim(a[:]), trim(b[:])
    while b:
        a, b = b, pmod(a, b, p)
    inv = pow(a[-1], p - 2, p)
    return [(c * inv) % p for c in a]


def pdiv(a: Poly, b: Poly, p: int) -> Poly:
    a = a[:]
    q = [0] * max(1, len(a) - len(b) + 1)
    inv = pow(b[-1], p - 2, p)
    while len(trim(a)) >= len(b):
        c = (a[-1] * inv) % p
        s = len(a) - len(b)
        q[s] = c
        for i, bi in enumerate(b):
            a[s + i] = (a[s + i] - c * bi) % p
    return trim(q)


def ppow_mod(base: Poly, e: int, m: Poly, p: int) -> Poly:
    result: Poly = [1]
    base = pmod(base, m, p)
    while e:
        if e & 1:
            result = pmod(pmul(result, base, p), m, p)
        base = pmod(pmul(base, base, p), m, p)
        e >>= 1
    return result


def factor_degree_pattern(f: Poly, p: int) -> List[int]:
    """Degrees of the irreducible factors of a squarefree monic f over F_p,
    by distinct-degree factorisation (independent of any group theory)."""
    pattern: List[int] = []
    f = f[:]
    h: Poly = [0, 1]          # x
    d = 0
    while len(f) > 1:
        d += 1
        if 2 * d > len(f) - 1:
            pattern.append(len(f) - 1)
            break
        h = ppow_mod(h, p, f, p)          # x^(p^d) mod f
        diff = h[:] + [0] * max(0, 2 - len(h))
        diff[1] = (diff[1] - 1) % p
        g = pgcd(f, trim(diff), p)
        k = len(g) - 1
        if k > 0:
            pattern += [d] * (k // d)
            f = pdiv(f, g, p)
            h = pmod(h, f, p)
    return sorted(pattern, reverse=True)


PHI11: Poly = [1] * 11  # 1 + x + ... + x^10


# ---------------------------------------------------------------- the readouts
def T(g: int) -> int:
    """Frobenius type in Q(zeta_11): the order of g in (Z/11)^x."""
    return mult_order(g, ELL)


def T_plus(g: int) -> int:
    """Frobenius type in the real subfield: order of g in (Z/11)^x / {+-1} = ord(g^2)."""
    return mult_order(g * g, ELL)


def section(title: str) -> None:
    print("\n" + "=" * 78 + f"\n{title}\n" + "=" * 78)


def main() -> None:
    log5, log3 = math.log2(5), math.log2(3)

    # 1. Chebotarev densities ---------------------------------------------------
    section("1. Frobenius types and Chebotarev densities in Q(zeta_11)")
    counts = Counter(T(g) for g in UNITS)
    for d in divisors(10):
        print(f"  ord = {d:2d}: residues {[g for g in UNITS if T(g) == d]!s:18s}"
              f" count {counts[d]}  phi(d) = {totient(d)}  density {Fraction(counts[d], 10)}")

    # 2. full pinning -------------------------------------------------------------
    section("2. Full pinning: I(p mod 11 ; T) = H(T) = log2 5 - 3/5")
    HT = entropy(UNITS, T)
    I = mutual_info(UNITS, lambda g: g, T)
    closed = -sum(totient(d) / 10 * math.log2(totient(d) / 10) for d in divisors(10))
    print(f"  H(T) (direct)            = {HT:.10f}")
    print(f"  cyclic closed form       = {closed:.10f}")
    print(f"  log2 5 - 3/5             = {log5 - 0.6:.10f}")
    print(f"  I(p mod 11 ; T)          = {I:.10f}")
    print(f"  H(T | p mod 11)          = {cond_entropy(UNITS, T, lambda g: g):.10f}  (per-class degenerate)")
    print(f"  H(p mod 11 | T)          = {cond_entropy(UNITS, lambda g: g, T):.10f}  (= 8/5)")
    print(f"  log2 10 - I              = {math.log2(10) - I:.10f}")

    # 3. polynomial cross-check -------------------------------------------------
    section("3. Factor patterns of Phi_11 over F_p (distinct-degree factorisation)")
    ok = 0
    test_primes = [p for p in primes_up_to(3000) if p != ELL][:400]
    for p in test_primes:
        t = mult_order(p, ELL)
        if factor_degree_pattern(PHI11, p) == [t] * (10 // t):
            ok += 1
    print(f"  pattern = [ord_11(p)] * (10/ord_11(p)) on {ok}/{len(test_primes)} primes")
    for p in (23, 43, 3, 2):
        print(f"  p = {p:2d} (p mod 11 = {p % 11:2d}, ord {mult_order(p, ELL):2d}):"
              f" pattern {factor_degree_pattern(PHI11, p)}")

    # 4. tower ---------------------------------------------------------------------
    section("4. The tower Q < Q(zeta_11)^+ < Q(zeta_11)")
    HTp = entropy(UNITS, T_plus)
    print(f"  H(T+)                    = {HTp:.10f}   (log2 5 - 8/5 = {log5 - 1.6:.10f})")
    print(f"  I(p mod 11 ; T+)         = {mutual_info(UNITS, lambda g: g, T_plus):.10f}")
    print(f"  tower bit H(T | T+)      = {cond_entropy(UNITS, T, T_plus):.10f}")
    S2, S5 = [1, 10], [g for g in UNITS if pow(g, 5, ELL) == 1]
    print(f"  CRT: H_C2 + H_C5         = {entropy(S2, T):.6f} + {entropy(S5, T):.6f}"
          f" = {entropy(S2, T) + entropy(S5, T):.10f}")

    # 5. semiprime channel ------------------------------------------------------
    section("5. Semiprime channel N = pq, independent uniform Frobenius classes")
    SP = [(g, h) for g in UNITS for h in UNITS]
    N = lambda w: (w[0] * w[1]) % ELL
    pair = lambda w: tuple(sorted((T(w[0]), T(w[1]))))
    ordered = lambda w: (T(w[0]), T(w[1]))
    Isemi = mutual_info(SP, N, pair)
    Iord = mutual_info(SP, N, ordered)
    print(f"  I(N mod 11 ; {{T(p),T(q)}}) = {Isemi:.10f}")
    print(f"  closed form              = {log5 + 12 / 25 * log3 - 47 / 25:.10f}")
    print(f"  I(N mod 11 ; (T(p),T(q))) = {Iord:.10f}")
    print(f"  which-factor wall        = {Iord - Isemi:.2e}")
    print(f"  attenuation H(T) - I     = {HT - Isemi:.10f}"
          f"   (32/25 - 12/25 log2 3 = {32 / 25 - 12 / 25 * log3:.10f})")
    print(f"  H(N mod 11) = {entropy(SP, N):.6f}, H(pair) = {entropy(SP, pair):.6f},"
          f" H(ordered) = {entropy(SP, ordered):.6f}")

    # 6. certified bounds -------------------------------------------------------
    section("6. Certified enclosures from exact integer powers")
    checks: List[Tuple[str, bool]] = [
        ("2^23219  < 5^10000   => log2 5 > 2.3219 ", 2 ** 23219 < 5 ** 10000),
        ("5^100000 < 2^232193  => log2 5 < 2.32193", 5 ** 100000 < 2 ** 232193),
        ("2^158496 < 3^100000  => log2 3 > 1.58496", 2 ** 158496 < 3 ** 100000),
        ("3^100000 < 2^158497  => log2 3 < 1.58497", 3 ** 100000 < 2 ** 158497),
    ]
    for s, b in checks:
        print(f"  {s}: {b}")
    lo5, hi5 = Fraction(23219, 10000), Fraction(232193, 100000)
    lo3, hi3 = Fraction(158496, 100000), Fraction(158497, 100000)
    print(f"  H(T)  in ({float(lo5 - Fraction(3, 5)):.6f}, {float(hi5 - Fraction(3, 5)):.6f})")
    print(f"  I_semi in ({float(lo5 + Fraction(12, 25) * lo3 - Fraction(47, 25)):.6f},"
          f" {float(hi5 + Fraction(12, 25) * hi3 - Fraction(47, 25)):.6f})")

    # 7. empirical primes -------------------------------------------------------
    section("7. Empirical densities on actual primes below 4,000,000")
    ps = [p for p in primes_up_to(4_000_000) if p != ELL]
    emp = Counter(mult_order(p, ELL) for p in ps)
    for d in divisors(10):
        print(f"  ord {d:2d}: {emp[d] / len(ps):.5f}   (predicted {totient(d) / 10:.1f})")
    print(f"  empirical H(T) on {len(ps)} primes = "
          f"{-sum(c / len(ps) * math.log2(c / len(ps)) for c in emp.values()):.5f}")


if __name__ == "__main__":
    main()
