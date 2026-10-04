#!/usr/bin/env python3
"""
The octic cyclic rung: numerical companion.

Demonstrates, by exact rational/float computation and by sampling real primes:

  1. The splitting law of the octic field Q(zeta_17)^+ and its type census {2, 2, 4, 8}.
  2. H(T) = 7/4 bits exactly, and full pinning: I(p mod 17 ; T) = H(T).
  3. The real-cyclotomic ladder at every degree: H(T) = typeEntropy((f-1)/2)
     for every odd prime f (prime degree or not).
  4. The type-count law: exactly 2*phi(d) classes mod f have residue degree d.
  5. The two-power ladder typeEntropy(2^m) = 2 - 2^(1-m) and the Fermat rungs.
  6. The octic tower filtration I(T ; layer_j) = 1, 3/2, 7/4 bits.
  7. The semiprime type-pair channel at degree 8: 21/16 bits, which-factor gain 0.
  8. The uniform-cover invariance of counting entropy.
  9. Real primes: empirical frequencies and the plug-in entropy estimate.

Self-contained: standard library only.
"""
from __future__ import annotations

from collections import Counter
from fractions import Fraction
from math import gcd, log2
from typing import Callable, Hashable, Iterable, Sequence, TypeVar

A = TypeVar("A")
B = TypeVar("B", bound=Hashable)


# ---------------------------------------------------------------- basic tools
def entropy_of_counts(counts: Iterable[int]) -> float:
    """Shannon entropy (bits) of the distribution proportional to `counts`."""
    cs = [c for c in counts if c > 0]
    n = sum(cs)
    h = -sum(c / n * log2(c / n) for c in cs) if n else 0.0
    return abs(h)  # normalise -0.0 to 0.0


def counting_entropy(s: Sequence[A], g: Callable[[A], B]) -> float:
    """Entropy of the read-out g under the uniform measure on the finite set s."""
    return entropy_of_counts(Counter(g(a) for a in s).values())


def cond_entropy(s: Sequence[A], g: Callable[[A], Hashable], x: Callable[[A], Hashable]) -> float:
    """H(g | x) under the uniform measure on s."""
    fibres: dict[Hashable, list[A]] = {}
    for a in s:
        fibres.setdefault(x(a), []).append(a)
    return sum(len(F) / len(s) * counting_entropy(F, g) for F in fibres.values())


def mutual_info(s: Sequence[A], g: Callable[[A], Hashable], x: Callable[[A], Hashable]) -> float:
    """I(g ; x) = H(g) - H(g | x)."""
    return counting_entropy(s, g) - cond_entropy(s, g, x)


def totient(n: int) -> int:
    return sum(1 for k in range(1, n + 1) if gcd(k, n) == 1)


def divisors(n: int) -> list[int]:
    return [d for d in range(1, n + 1) if n % d == 0]


def is_prime(n: int) -> bool:
    if n < 2:
        return False
    i = 2
    while i * i <= n:
        if n % i == 0:
            return False
        i += 1
    return True


def primes_up_to(N: int) -> list[int]:
    sieve = bytearray([1]) * (N + 1)
    sieve[0:2] = b"\x00\x00"
    for i in range(2, int(N ** 0.5) + 1):
        if sieve[i]:
            sieve[i * i :: i] = bytearray(len(sieve[i * i :: i]))
    return [i for i in range(N + 1) if sieve[i]]


# ------------------------------------------------------- the cyclic type model
def ord_type(n: int, a: int) -> int:
    """Order of a in the cyclic group Z/n: n / gcd(a, n)."""
    return n // gcd(a, n)


def type_entropy(n: int) -> float:
    """Entropy of the order of a uniformly random element of C_n."""
    return counting_entropy(range(n), lambda a: ord_type(n, a))


def type_entropy_phi_law(n: int) -> float:
    """The phi-law: sum over d | n of (phi(d)/n) log2(n/phi(d))."""
    return sum(totient(d) / n * log2(n / totient(d)) for d in divisors(n))


# ------------------------------------------------- the real cyclotomic field
def real_degree(f: int, u: int) -> int:
    """Residue degree of a prime p = u (mod f) in Q(zeta_f)^+:
    the least k >= 1 with u^k = +-1 (mod f)."""
    k, x = 1, u % f
    while x not in (1, f - 1):
        x = x * u % f
        k += 1
    return k


def units(f: int) -> list[int]:
    return [u for u in range(1, f) if gcd(u, f) == 1]


def octic_type_by_residue(r: int) -> int:
    """The octic splitting law in congruence form."""
    r %= 17
    if r in (1, 16):
        return 1
    if r in (4, 13):
        return 2
    if r in (2, 8, 9, 15):
        return 4
    return 8


def section(title: str) -> None:
    print("\n" + "=" * 72 + f"\n{title}\n" + "=" * 72)


def main() -> None:
    f = 17
    U = units(f)

    section("1. Splitting law and type census in Q(zeta_17)^+")
    for u in U:
        assert real_degree(f, u) == octic_type_by_residue(u)
    census = Counter(real_degree(f, u) for u in U)
    for d in (1, 2, 4, 8):
        cls = [u for u in U if real_degree(f, u) == d]
        print(f"  degree {d}: {census[d]:2d} classes  {cls}   density {Fraction(census[d], 16)}")
    print("  examples: 103 ->", real_degree(f, 103), " 13 ->", real_degree(f, 13),
          " 2 ->", real_degree(f, 2), " 3 ->", real_degree(f, 3))

    section("2. H(T) = 7/4 exactly, and full pinning")
    HT = counting_entropy(U, lambda u: real_degree(f, u))
    print(f"  H(T)                    = {HT:.6f}  (exact 7/4 = 1.75)")
    print(f"  H(T | p mod 17)         = {cond_entropy(U, lambda u: real_degree(f, u), lambda u: u):.6f}")
    print(f"  H(T | sign class +-p)   = {cond_entropy(U, lambda u: real_degree(f, u), lambda u: min(u, f - u)):.6f}")
    print(f"  I(p mod 17 ; T)         = {mutual_info(U, lambda u: real_degree(f, u), lambda u: u):.6f}")
    print(f"  reported 1.7474: gap to 7/4 = {1.75 - 1.7474:.4f} (< 0.003)")

    section("3. The real-cyclotomic ladder at every degree")
    print("    f   (f-1)/2  prime?   H(T) arithmetic   typeEntropy   phi-law")
    for q in [p for p in range(3, 80) if is_prime(p)]:
        n = (q - 1) // 2
        Ha = counting_entropy(units(q), lambda u, q=q: real_degree(q, u))
        Hm, Hp = type_entropy(n), type_entropy_phi_law(n)
        assert abs(Ha - Hm) < 1e-12 and abs(Hm - Hp) < 1e-12
        print(f"  {q:3d}   {n:5d}    {'yes' if is_prime(n) else ' no'}     {Ha:12.6f}  {Hm:12.6f}  {Hp:9.6f}")

    section("4. Type-count law: #{u : deg(u) = d} = 2 phi(d)")
    for q in (17, 13, 31, 37, 41, 73):
        n = (q - 1) // 2
        c = Counter(real_degree(q, u) for u in units(q))
        ok = all(c[d] == 2 * totient(d) for d in divisors(n))
        print(f"  f = {q:3d}: {dict(sorted(c.items()))}   law holds: {ok}")

    section("5. Two-power ladder and Fermat rungs")
    for m in range(0, 8):
        n = 2 ** m
        print(f"  m = {m}: typeEntropy(2^m) = {type_entropy(n):.6f}   2 - 2^(1-m) = {2 - 2 / n:.6f}")
    for q, m in ((3, 0), (5, 1), (17, 3), (257, 7)):
        Ha = counting_entropy(units(q), lambda u, q=q: real_degree(q, u))
        print(f"  Fermat prime f = {q:3d} = 2^{m + 1}+1: H(T) = {Ha:.6f}, formula {2 - 2 / 2 ** m:.6f}")

    section("6. The octic tower Q < Q(sqrt17) < K4 < Q(zeta_17)^+")
    T = lambda u: real_degree(f, u)
    for j, e in ((1, 8), (2, 4), (3, 2)):
        obs = lambda u, e=e: pow(u, e, f)
        print(f"  layer degree {2 ** j}: observable u^{e}:  H(T|layer) = {cond_entropy(U, T, obs):.4f}"
              f"   I(T;layer) = {mutual_info(U, T, obs):.4f}   typeEntropy({2 ** j}) = {type_entropy(2 ** j):.4f}")

    section("7. Semiprime type-pair channel in the C_8 exponent model")
    n = 8
    pairs = [(a, b) for a in range(n) for b in range(n)]
    s = lambda ab: (ab[0] + ab[1]) % n
    unordered = lambda ab: tuple(sorted((ord_type(n, ab[0]), ord_type(n, ab[1]))))
    ordered = lambda ab: (ord_type(n, ab[0]), ord_type(n, ab[1]))
    Iu, Io = mutual_info(pairs, s, unordered), mutual_info(pairs, s, ordered)
    print(f"  I(N mod 17 ; unordered type pair) = {Iu:.6f}  (exact 21/16 = {21 / 16})")
    print(f"  I(N mod 17 ; ordered type pair)   = {Io:.6f}  which-factor gain = {Io - Iu:.2e}")
    for m in range(1, 6):
        n = 2 ** m
        pairs = [(a, b) for a in range(n) for b in range(n)]
        Iu = mutual_info(pairs, lambda ab, n=n: (ab[0] + ab[1]) % n,
                         lambda ab, n=n: tuple(sorted((ord_type(n, ab[0]), ord_type(n, ab[1])))))
        print(f"  n = 2^{m}: Ipair = {Iu:.6f}   conjectured (4/3)(1-4^-m) = {4 / 3 * (1 - 4 ** -m):.6f}")

    section("8. Uniform-cover invariance of counting entropy")
    nn = (f - 1) // 2
    g = 3  # a primitive root mod 17
    H_units = counting_entropy(U, T)
    H_exp = counting_entropy(range(f - 1), lambda a: real_degree(f, pow(g, a, f)))
    H_half = counting_entropy(range(nn), lambda a: ord_type(nn, a))
    print(f"  on (Z/17)^x: {H_units:.6f}   pulled back to exponents [0,16): {H_exp:.6f}"
          f"   pushed to C_8: {H_half:.6f}")

    section("9. Real primes: Chebotarev frequencies and the plug-in estimate")
    for N in (10 ** 3, 10 ** 4, 10 ** 5, 10 ** 6):
        ps = [p for p in primes_up_to(N) if p != 17]
        c = Counter(octic_type_by_residue(p) for p in ps)
        freqs = {d: round(c[d] / len(ps), 4) for d in (1, 2, 4, 8)}
        print(f"  primes <= {N:>8}: {len(ps):6d} primes  freqs {freqs}  plug-in H = {entropy_of_counts(c.values()):.4f}")


if __name__ == "__main__":
    main()
