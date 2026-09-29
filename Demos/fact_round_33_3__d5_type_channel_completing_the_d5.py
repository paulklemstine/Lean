#!/usr/bin/env python3
"""
The D5 dial is measured: numerical companion.

Self-contained demonstrations of the main results:

  1. Exact theory on the dihedral group D5: H(T) = 1/5 + (1/2) log2 5,
     H(T | sign) = (1/2) log2 5 - 4/5, and I(sign ; T) = 1 bit exactly.
  2. The Chebotarev fibre-product model at conductor m* = 320 with the quadratic
     character of Q(sqrt(-10)): I(p mod 320 ; T) = 1 bit, and the semiprime
     type-pair channel also carries exactly 1 bit.
  3. Quantisation: every abelian read-out of a D5 Frobenius carries 0 or 1 bit.
  4. The dihedral family: exactly 1 bit for every odd n, 0.311 bit for D2.
  5. Real primes: splitting types of x^5 - 5x + 12 (a D5 quintic) and the
     plug-in estimate of I(p mod 320 ; T), together with the semiprime channel.

Only the Python standard library is used.
"""
from __future__ import annotations

import math
import random
from collections import Counter
from typing import Callable, Dict, Hashable, Iterable, List, Sequence, Tuple

# ---------------------------------------------------------------------------
# Entropy on a finite uniform sample space
# ---------------------------------------------------------------------------


def entropy(samples: Sequence[Hashable]) -> float:
    """Shannon entropy (bits) of the empirical law of `samples`."""
    n = len(samples)
    if n == 0:
        return 0.0
    return -sum((c / n) * math.log2(c / n) for c in Counter(samples).values())


def cond_entropy(pairs: Sequence[Tuple[Hashable, Hashable]]) -> float:
    """H(X | Y) for the empirical law of the pairs (x, y)."""
    n = len(pairs)
    cells: Dict[Hashable, List[Hashable]] = {}
    for x, y in pairs:
        cells.setdefault(y, []).append(x)
    return sum(len(c) / n * entropy(c) for c in cells.values())


def mutual_info(pairs: Sequence[Tuple[Hashable, Hashable]]) -> float:
    """I(X ; Y) = H(X) - H(X | Y)."""
    return entropy([x for x, _ in pairs]) - cond_entropy(pairs)


# ---------------------------------------------------------------------------
# Dihedral groups: element (k, e) = r^k s^e, with n-gon rotations r and
# reflections s.  Multiplication: (a,0)(b,f) = (a+b, f); (a,1)(b,f) = (a-b, 1+f).
# ---------------------------------------------------------------------------

Elem = Tuple[int, int]


def dihedral(n: int) -> List[Elem]:
    return [(k, e) for e in (0, 1) for k in range(n)]


def dmul(n: int, x: Elem, y: Elem) -> Elem:
    a, e = x
    b, f = y
    return ((a + b) % n, f) if e == 0 else ((a - b) % n, (1 + f) % 2)


def dorder(n: int, x: Elem) -> int:
    ident: Elem = (0, 0)
    y, k = x, 1
    while y != ident:
        y, k = dmul(n, y, x), k + 1
    return k


def dsign(x: Elem) -> int:
    """The sign character D_n -> Z/2: rotations -> 0, reflections -> 1."""
    return x[1]


def d5_type(x: Elem) -> str:
    """Splitting type of a quintic prime with Frobenius x in D5."""
    return {1: "1^5", 5: "5", 2: "1.2^2"}[dorder(5, x)]


def vertex_cycle_type(n: int, x: Elem) -> Tuple[int, ...]:
    """Cycle type of x acting on the n vertices of the n-gon."""
    k, e = x
    perm = [((k + v) % n) if e == 0 else ((k - v) % n) for v in range(n)]
    seen, lengths = [False] * n, []
    for v in range(n):
        if not seen[v]:
            length, w = 0, v
            while not seen[w]:
                seen[w], w, length = True, perm[w], length + 1
            lengths.append(length)
    return tuple(sorted(lengths))


# ---------------------------------------------------------------------------
# 1. Exact D5 theory
# ---------------------------------------------------------------------------


def demo_exact_d5() -> None:
    print("=" * 72)
    print("1. Exact type channel of D5 (uniform Chebotarev law on the group)")
    print("=" * 72)
    G = dihedral(5)
    types = [d5_type(g) for g in G]
    print("type densities:", {t: f"{c}/10" for t, c in Counter(types).items()})
    L = math.log2(5)
    pairs = [(d5_type(g), dsign(g)) for g in G]
    print(f"H(T)          = {entropy(types):.6f}   theory 1/5 + log2(5)/2 = {0.2 + L / 2:.6f}")
    print(f"H(T | sign)   = {cond_entropy(pairs):.6f}   theory log2(5)/2 - 4/5 = {L / 2 - 0.8:.6f}")
    print(f"I(sign ; T)   = {mutual_info(pairs):.6f}   theory 1 bit exactly")
    print()


# ---------------------------------------------------------------------------
# 2. The fibre-product model at m* = 320
# ---------------------------------------------------------------------------

CHI_M10_ZERO = {1, 7, 9, 11, 13, 19, 23, 37}   # residues mod 40 where chi_{-10} = +1


def chi_m10(a: int) -> int:
    """Quadratic character of Q(sqrt(-10)), written additively (0 = +1, 1 = -1)."""
    return 0 if a % 40 in CHI_M10_ZERO else 1


def chi_5(a: int) -> int:
    """Quadratic character of Q(sqrt 5), written additively."""
    return 0 if a % 5 in (1, 4) else 1


def reduced_residues(m: int) -> List[int]:
    return [a for a in range(m) if math.gcd(a, m) == 1]


def demo_fibre_product(m: int = 320) -> None:
    print("=" * 72)
    print(f"2. Chebotarev fibre product at conductor m* = {m}")
    print("=" * 72)
    U = reduced_residues(m)
    for name, chi in (("chi_{-10}", chi_m10), ("chi_5", chi_5)):
        bal = Counter(chi(a) for a in U)
        G = dihedral(5)
        fp = [(a, g) for a in U for g in G if chi(a) == dsign(g)]
        I = mutual_info([(d5_type(g), a) for a, g in fp])
        print(f"{name}: balance {dict(bal)}, |fibre product| = {len(fp)}, "
              f"I(p mod {m} ; T) = {I:.12f}")
    # semiprime channel: (N mod m, Frob_p, Frob_q) with chi(N) = sign(p) + sign(q)
    G2 = [(g, h) for g in dihedral(5) for h in dihedral(5)]
    fp2 = [(a, gh) for a in U for gh in G2
           if chi_m10(a) == (dsign(gh[0]) + dsign(gh[1])) % 2]
    pair = [((d5_type(g), d5_type(h)), a) for a, (g, h) in fp2]
    print(f"semiprime: H(pair) = {entropy([p for p, _ in pair]):.6f} "
          f"(= 2 H(T)), I(N mod {m} ; pair) = {mutual_info(pair):.12f}")
    print()


# ---------------------------------------------------------------------------
# 3. Quantisation of abelian read-outs
# ---------------------------------------------------------------------------


def demo_quantisation() -> None:
    print("=" * 72)
    print("3. Every abelian read-out of D5 carries 0 or exactly 1 bit")
    print("=" * 72)
    G = dihedral(5)
    # A homomorphism to an abelian group kills the commutator subgroup <r>,
    # so it is determined by the image of s, an element of order 1 or 2.
    readouts: Dict[str, Callable[[Elem], Hashable]] = {
        "trivial map": lambda g: 1,
        "sign to Z/2": dsign,
        "sign to {+1,-1}": lambda g: -1 if g[1] else 1,
        "sign to Z/6 (s -> 3)": lambda g: 3 * g[1],
    }
    for name, phi in readouts.items():
        print(f"  {name:22s}: I = {mutual_info([(d5_type(g), phi(g)) for g in G]):.6f}")
    # a NON-homomorphic read-out may carry any intermediate amount:
    print(f"  (non-homomorphic 'is identity'): "
          f"I = {mutual_info([(d5_type(g), g == (0, 0)) for g in G]):.6f}")
    print()


# ---------------------------------------------------------------------------
# 4. The dihedral family
# ---------------------------------------------------------------------------


def demo_dihedral_family(nmax: int = 14) -> None:
    print("=" * 72)
    print("4. Dihedral dial: I(sign ; T) for D_n")
    print("=" * 72)
    print("   n   T = order of Frobenius   T = cycle type on n-gon vertices")
    for n in range(2, nmax + 1):
        G = dihedral(n)
        i_ord = mutual_info([(dorder(n, g), dsign(g)) for g in G])
        i_cyc = mutual_info([(vertex_cycle_type(n, g), dsign(g)) for g in G])
        print(f"  {n:2d}   {i_ord:.6f}                 {i_cyc:.6f}")
    print(f"   D2 exact value 3/2 - (3/4) log2 3 = {1.5 - 0.75 * math.log2(3):.6f}")
    print()


# ---------------------------------------------------------------------------
# 5. Real primes: the D5 quintic x^5 - 5x + 12
# ---------------------------------------------------------------------------

F: List[int] = [12, -5, 0, 0, 0, 1]   # coefficients, lowest degree first


def primes_upto(n: int) -> List[int]:
    sieve = bytearray([1]) * (n + 1)
    sieve[0:2] = b"\x00\x00"
    for i in range(2, int(n ** 0.5) + 1):
        if sieve[i]:
            sieve[i * i::i] = bytearray(len(sieve[i * i::i]))
    return [i for i, b in enumerate(sieve) if b]


def poly_mulmod(a: List[int], b: List[int], p: int) -> List[int]:
    """a*b mod (F, p) for polynomials of degree < 5 (F is monic of degree 5)."""
    prod = [0] * 9
    for i, x in enumerate(a):
        if x:
            for j, y in enumerate(b):
                prod[i + j] += x * y
    for d in range(8, 4, -1):          # x^5 = 5x - 12
        c = prod[d] % p
        if c:
            prod[d] = 0
            prod[d - 4] += 5 * c
            prod[d - 5] -= 12 * c
    return [c % p for c in prod[:5]]


def poly_gcd_degree(a: List[int], b: List[int], p: int) -> int:
    def trim(v: List[int]) -> List[int]:
        v = [c % p for c in v]
        while v and v[-1] == 0:
            v.pop()
        return v
    a, b = trim(a), trim(b)
    while b:
        inv = pow(b[-1], p - 2, p)
        while len(a) >= len(b):
            c = a[-1] * inv % p
            shift = len(a) - len(b)
            for i, y in enumerate(b):
                a[i + shift] = (a[i + shift] - c * y) % p
            a = trim(a)
            if not a:
                break
        a, b = b, a
    return len(a) - 1


def root_count(p: int) -> int:
    """Number of roots of F in F_p, via deg gcd(F, x^p - x)."""
    result, base, e = [1, 0, 0, 0, 0], [0, 1, 0, 0, 0], p
    while e:
        if e & 1:
            result = poly_mulmod(result, base, p)
        base = poly_mulmod(base, base, p)
        e >>= 1
    result[1] -= 1                     # x^p - x
    return poly_gcd_degree(F[:], result, p)


def splitting_type(p: int) -> str:
    """For a D5 quintic the root count determines the type: 5 -> 1^5, 0 -> 5, 1 -> 1.2^2."""
    return {5: "1^5", 0: "5", 1: "1.2^2"}[root_count(p)]


def demo_real_primes(bound: int = 400_000, m: int = 320, seed: int = 118) -> None:
    print("=" * 72)
    print(f"5. Real primes p < {bound}: splitting of x^5 - 5x + 12 (Galois group D5)")
    print("=" * 72)
    ps = [p for p in primes_upto(bound) if p not in (2, 3, 5)]
    T = {p: splitting_type(p) for p in ps}
    M = len(ps)
    agree = sum((T[p] == "1.2^2") == (chi_m10(p) == 1) for p in ps)
    print(f"primes used M = {M};  sign(Frob_p) = chi_(-10)(p) for {agree}/{M} primes")
    dens = Counter(T.values())
    print("empirical densities:", {t: round(c / M, 4) for t, c in dens.items()},
          " (theory 0.1, 0.4, 0.5)")
    pairs = [(T[p], p % m) for p in ps]
    H, Hc = entropy([t for t, _ in pairs]), cond_entropy(pairs)
    print(f"plug-in H(T) = {H:.4f}, H(T | p mod {m}) = {Hc:.4f}, "
          f"I = {H - Hc:.4f}   (exact: 1.3610, 0.3610, 1)")
    phi, k = len(reduced_residues(m)), 3
    print(f"generic plug-in bias (phi(m)-1)(|T|-1)/(2 M ln 2) = "
          f"{(phi - 1) * (k - 1) / (2 * M * math.log(2)):.4f}")
    # permutation baseline: shuffle the types against the residues
    rng = random.Random(seed)
    shuffled = [t for t, _ in pairs]
    null = []
    for _ in range(20):
        rng.shuffle(shuffled)
        null.append(mutual_info(list(zip(shuffled, [r for _, r in pairs]))))
    mu = sum(null) / len(null)
    sd = math.sqrt(sum((x - mu) ** 2 for x in null) / (len(null) - 1))
    print(f"shuffled null: mean {mu:.4f}, sd {sd:.4f}, z = {(H - Hc - mu) / sd:.0f}")
    # semiprime channel N = p q with the pair of types
    rng2 = random.Random(seed + 1)
    semi = []
    for _ in range(300_000):
        p, q = rng2.choice(ps), rng2.choice(ps)
        semi.append(((T[p], T[q]), (p * q) % m))
    print(f"semiprime channel (300000 random N = pq): plug-in I(N mod {m} ; pair) = "
          f"{mutual_info(semi):.4f}   (exact: 1)")
    print()


def main() -> None:
    demo_exact_d5()
    demo_fibre_product()
    demo_quantisation()
    demo_dihedral_family()
    demo_real_primes()


if __name__ == "__main__":
    main()
