#!/usr/bin/env python3
"""
The Detector Law: why the largest abelianization leaks the least.

Numerical companion to the paper "Large Quotients, Small Leaks".
Everything is computed by exhaustive enumeration with exact rational
probabilities; only the final logarithms are floating point.

Sections
  1. Shannon calculus on finite uniform sample spaces
  2. Finite fields GF(p^k) and the affine groups AGL(1, q)
  3. AGL(1, 8): derived subgroup, abelianization C7, class-function check
  4. The prime channel I1 and the semiprime channel I2 of AGL(1, 8)
  5. The detector law  I = h(1/n)  and its consequences
  6. The extended reversal table (S3, S4, A4, D4, V4, C4, D5, AGL(1,8))
  7. The pair-detector formula (conjectural in general) at n = 3, 4, 7
  8. The totient (resolved-quotient) formula for AGL(1, q), several q

Run:  python3 demo.py
"""
from __future__ import annotations

import random
from collections import Counter
from fractions import Fraction
from itertools import permutations, product
from math import gcd, log2
from typing import Callable, Hashable, Iterable, Sequence, TypeVar

S = TypeVar("S")
Perm = tuple[int, ...]

# ---------------------------------------------------------------------------
# 1. Shannon calculus
# ---------------------------------------------------------------------------


def distribution(samples: Sequence[S], f: Callable[[S], Hashable]) -> dict[Hashable, Fraction]:
    """Exact law of the readout f under the uniform measure on `samples`."""
    cnt = Counter(f(s) for s in samples)
    n = len(samples)
    return {k: Fraction(v, n) for k, v in cnt.items()}


def entropy_of(dist: dict[Hashable, Fraction]) -> float:
    """Shannon entropy in bits."""
    return -sum(float(p) * log2(float(p)) for p in dist.values() if p > 0)


def entropy(samples: Sequence[S], f: Callable[[S], Hashable]) -> float:
    return entropy_of(distribution(samples, f))


def mutual_info(samples: Sequence[S], c: Callable[[S], Hashable],
                t: Callable[[S], Hashable]) -> float:
    """I(c ; t) = H(c) + H(t) - H(c, t)."""
    return (entropy(samples, c) + entropy(samples, t)
            - entropy(samples, lambda s: (c(s), t(s))))


def bin_entropy(p: float) -> float:
    """Binary entropy h(p) in bits."""
    if p <= 0.0 or p >= 1.0:
        return 0.0
    return -p * log2(p) - (1 - p) * log2(1 - p)


# ---------------------------------------------------------------------------
# 2. Finite fields and affine groups
# ---------------------------------------------------------------------------


def is_prime(n: int) -> bool:
    return n >= 2 and all(n % d for d in range(2, int(n ** 0.5) + 1))


def prime_power(q: int) -> tuple[int, int]:
    for p in range(2, q + 1):
        if q % p == 0 and is_prime(p):
            k, m = 0, q
            while m % p == 0:
                m //= p
                k += 1
            if m != 1:
                raise ValueError(f"{q} is not a prime power")
            return p, k
    raise ValueError(q)


class GF:
    """GF(p^k); elements are integers 0..q-1 encoding coefficient vectors base p."""

    def __init__(self, q: int) -> None:
        self.q = q
        self.p, self.k = prime_power(q)
        self.modulus = self._find_irreducible()
        self.mul_table = [[self._mul(a, b) for b in range(q)] for a in range(q)]
        self.add_table = [[self._add(a, b) for b in range(q)] for a in range(q)]

    def _digits(self, a: int) -> list[int]:
        return [(a // self.p ** i) % self.p for i in range(self.k)]

    def _from(self, d: Sequence[int]) -> int:
        return sum((x % self.p) * self.p ** i for i, x in enumerate(d))

    def _add(self, a: int, b: int) -> int:
        return self._from([x + y for x, y in zip(self._digits(a), self._digits(b))])

    def _polymulmod(self, a: list[int], b: list[int], m: list[int]) -> list[int]:
        prod_ = [0] * (len(a) + len(b) - 1)
        for i, x in enumerate(a):
            for j, y in enumerate(b):
                prod_[i + j] = (prod_[i + j] + x * y) % self.p
        k = len(m) - 1  # m monic of degree k
        for deg in range(len(prod_) - 1, k - 1, -1):
            c = prod_[deg]
            if c:
                for i in range(k + 1):
                    prod_[deg - k + i] = (prod_[deg - k + i] - c * m[i]) % self.p
        return (prod_ + [0] * k)[:k]

    def _find_irreducible(self) -> list[int]:
        if self.k == 1:
            return [0, 1]
        for tail in product(range(self.p), repeat=self.k):
            m = list(tail) + [1]
            if m[0] == 0:
                continue
            # irreducible iff no root-free factorisation: brute force via
            # checking the multiplicative group generated is a field (all nonzero invertible)
            ok = True
            elems = list(product(range(self.p), repeat=self.k))
            one = [1] + [0] * (self.k - 1)
            for a in elems:
                if not any(a):
                    continue
                if not any(self._polymulmod(list(a), list(b), m) == one for b in elems):
                    ok = False
                    break
            if ok:
                return m
        raise RuntimeError("no irreducible polynomial found")

    def _mul(self, a: int, b: int) -> int:
        if self.k == 1:
            return (a * b) % self.p
        return self._from(self._polymulmod(self._digits(a), self._digits(b), self.modulus))

    def add(self, a: int, b: int) -> int:
        return self.add_table[a][b]

    def mul(self, a: int, b: int) -> int:
        return self.mul_table[a][b]

    def order(self, a: int) -> int:
        x, n = a, 1
        while x != 1:
            x = self.mul(x, a)
            n += 1
        return n

    def primitive(self) -> int:
        return next(a for a in range(1, self.q) if self.order(a) == self.q - 1)


def cycle_type(p: Perm) -> tuple[int, ...]:
    seen = [False] * len(p)
    out: list[int] = []
    for i in range(len(p)):
        if not seen[i]:
            j, length = i, 0
            while not seen[j]:
                seen[j] = True
                j = p[j]
                length += 1
            out.append(length)
    return tuple(sorted(out))


def compose(p: Perm, q: Perm) -> Perm:
    """(p o q)(i) = p(q(i))."""
    return tuple(p[q[i]] for i in range(len(p)))


def inverse(p: Perm) -> Perm:
    inv = [0] * len(p)
    for i, x in enumerate(p):
        inv[x] = i
    return tuple(inv)


def affine_group(F_: GF) -> tuple[list[Perm], dict[Perm, int]]:
    """All maps t -> a t + b as permutations, with the discrete log of the multiplier."""
    g = F_.primitive()
    dlog: dict[int, int] = {}
    x = 1
    for e in range(F_.q - 1):
        dlog[x] = e
        x = F_.mul(x, g)
    G: list[Perm] = []
    coset: dict[Perm, int] = {}
    for a in range(1, F_.q):
        for b in range(F_.q):
            sigma = tuple(F_.add(F_.mul(a, t), b) for t in range(F_.q))
            G.append(sigma)
            coset[sigma] = dlog[a]
    return G, coset


def commutator_subgroup(G: list[Perm]) -> set[Perm]:
    gens = {compose(compose(x, y), compose(inverse(x), inverse(y))) for x in G for y in G}
    H = set(gens)
    while True:
        new = H | {compose(a, b) for a in H for b in H}
        if new == H:
            return H
        H = new


# ---------------------------------------------------------------------------
# 3-4. AGL(1, 8)
# ---------------------------------------------------------------------------


def agl_channels(q: int, semiprime: bool = True) -> dict[str, float]:
    F_ = GF(q)
    G, coset = affine_group(F_)
    n = q - 1
    out: dict[str, float] = {"order": len(G), "n": n, "cap": log2(n)}
    out["I1"] = mutual_info(G, lambda g: coset[g], cycle_type)
    if semiprime:
        pairs = list(product(G, G))
        out["I2"] = mutual_info(pairs, lambda z: (coset[z[0]] + coset[z[1]]) % n,
                                lambda z: tuple(sorted((cycle_type(z[0]), cycle_type(z[1])))))
        out["I2_ordered"] = mutual_info(pairs, lambda z: (coset[z[0]] + coset[z[1]]) % n,
                                        lambda z: (cycle_type(z[0]), cycle_type(z[1])))
    return out


def section_agl8() -> None:
    print("=" * 74)
    print("AGL(1,8) = GF(8) x| GF(8)^*  as permutations of the 8 field points")
    print("=" * 74)
    F8 = GF(8)
    G, coset = affine_group(F8)
    print(f"|G| = {len(G)}   (modulus coefficients of x^3+.. : {F8.modulus})")
    D = commutator_subgroup(G)
    translations = {tuple(F8.add(t, b) for t in range(8)) for b in range(8)}
    print(f"|[G,G]| = {len(D)};  [G,G] == translation group C2^3 : {D == translations}")
    # coset readout is a homomorphism onto C7
    hom = all((coset[compose(x, y)] - coset[x] - coset[y]) % 7 == 0 for x in G for y in G)
    print(f"multiplier-log readout G -> C7 is a homomorphism: {hom};"
          f" kernel == [G,G]: {set(g for g in G if coset[g] == 0) == D}")
    # class function check on the whole symmetric group (random sample)
    rng = random.Random(1)
    ok = True
    for _ in range(2000):
        g = rng.choice(G)
        h = tuple(rng.sample(range(8), 8))
        ok &= cycle_type(compose(compose(h, g), inverse(h))) == cycle_type(g)
    print(f"cycle type is conjugation invariant in Sym(8) (2000 random checks): {ok}")
    types = Counter(cycle_type(g) for g in G)
    print("cycle-type census:", dict(types))
    joint = Counter((coset[g], cycle_type(g)) for g in G)
    print("joint (coset, type) census:", dict(sorted(joint.items())))

    ch = agl_channels(8)
    I1_closed = log2(7) - 6 / 7 * log2(6)
    I2_closed = log2(7) - 78 / 49 * log2(6) + 30 / 49 * log2(5)
    print(f"\ncap  = log2 7                         = {ch['cap']:.6f} bits")
    print(f"I1   = I(coset ; T)      (enumerated) = {ch['I1']:.6f}")
    print(f"       log2 7 - (6/7) log2 6          = {I1_closed:.6f}")
    print(f"       h(1/7)                         = {bin_entropy(1/7):.6f}")
    print(f"I2   = I(coset(xy) ; {{Tx,Ty}})  (3136 pairs) = {ch['I2']:.6f}")
    print(f"       log2 7 - (78/49) log2 6 + (30/49) log2 5 = {I2_closed:.6f}")
    print(f"       ordered readout (Tx,Ty)                 = {ch['I2_ordered']:.6f}")
    print(f"fractions of cap:  I1 {100*ch['I1']/ch['cap']:.2f}%   I2 {100*ch['I2']/ch['cap']:.2f}%")
    print(f"chain 0 < I2 < I1 < cap: {0 < ch['I2'] < ch['I1'] < ch['cap']};"
          f"  5*I2 < I1: {5*ch['I2'] < ch['I1']}")


# ---------------------------------------------------------------------------
# 5. Detector law
# ---------------------------------------------------------------------------


def detector_info(n: int) -> float:
    """delta(n) = log2 n - ((n-1)/n) log2 (n-1)  ( = h(1/n) )."""
    return log2(n) - (n - 1) / n * log2(n - 1)


def detector_channel_bruteforce(n: int, k: int, inner_types: int, seed: int = 0) -> float:
    """A synthetic detector: n balanced cosets of size k; the trivial coset is
    coloured with `inner_types` arbitrary random labels, every other element gets tau0."""
    rng = random.Random(seed)
    samples = [(c, j) for c in range(n) for j in range(k)]
    colour = {j: rng.randrange(inner_types) for j in range(k)}
    return mutual_info(samples, lambda s: s[0],
                       lambda s: ("in", colour[s[1]]) if s[0] == 0 else "tau0")


def section_detector() -> None:
    print("\n" + "=" * 74)
    print("The detector law  I(coset ; T) = log2 n - ((n-1)/n) log2(n-1) = h(1/n)")
    print("=" * 74)
    print("Synthetic detectors with arbitrary behaviour inside the trivial coset:")
    for n, k, m in [(3, 4, 3), (5, 6, 4), (7, 8, 2), (7, 8, 5), (12, 9, 7)]:
        bf = detector_channel_bruteforce(n, k, m, seed=n * k + m)
        print(f"  n={n:2d}, coset size {k}, {m} inner labels:  brute force {bf:.6f}"
              f"   law {detector_info(n):.6f}")
    print("\n   n    cap=log2 n    delta(n)   fraction   bound (log2 n + 3)/n")
    for n in [2, 3, 4, 5, 7, 15, 31, 127, 8191, 131071]:
        d = detector_info(n)
        print(f"{n:6d}  {log2(n):10.4f}  {d:10.6f}  {100*d/log2(n):7.3f}%   {(log2(n)+3)/n:10.6f}")
    mono = all(detector_info(n + 1) < detector_info(n) for n in range(2, 2000))
    print(f"strictly decreasing on 2..2000: {mono}")


# ---------------------------------------------------------------------------
# 6. Extended reversal table
# ---------------------------------------------------------------------------


def generate(gens: list[Perm]) -> list[Perm]:
    G = {tuple(range(len(gens[0])))}
    while True:
        new = G | {compose(a, b) for a in G for b in gens}
        if new == G:
            return sorted(G)
        G = new


def coset_readout(G: list[Perm]) -> Callable[[Perm], Hashable]:
    D = commutator_subgroup(G)
    return lambda g: frozenset(compose(g, d) for d in D)


def channels(G: list[Perm]) -> tuple[int, float, float, float]:
    c = coset_readout(G)
    n = len({c(g) for g in G})
    I1 = mutual_info(G, c, cycle_type)
    pairs = list(product(G, G))
    I2 = mutual_info(pairs, lambda z: c(compose(z[0], z[1])),
                     lambda z: tuple(sorted((cycle_type(z[0]), cycle_type(z[1])))))
    return n, log2(n), I1, I2


def section_table() -> None:
    print("\n" + "=" * 74)
    print("The extended reversal: channel vs. abelianization order")
    print("=" * 74)
    groups: dict[str, list[Perm]] = {
        "S3": generate([(1, 0, 2), (1, 2, 0)]),
        "S4": [tuple(p) for p in permutations(range(4))],
        "A4 = AGL(1,4)": affine_group(GF(4))[0],
        "D4": generate([(1, 2, 3, 0), (0, 3, 2, 1)]),
        "V4": [(0, 1, 2, 3), (1, 0, 3, 2), (2, 3, 0, 1), (3, 2, 1, 0)],
        "C4": generate([(1, 2, 3, 0)]),
        "D5": generate([(1, 2, 3, 4, 0), (0, 4, 3, 2, 1)]),
        "AGL(1,8)": affine_group(GF(8))[0],
    }
    print(f"{'group':15s}{'|G|':>5s}{'|G^ab|':>8s}{'cap':>8s}{'I1':>9s}{'%cap':>8s}{'I2':>9s}{'%cap':>8s}")
    for name, G in groups.items():
        n, cap, I1, I2 = channels(G)
        print(f"{name:15s}{len(G):5d}{n:8d}{cap:8.3f}{I1:9.4f}{100*I1/cap:7.1f}%{I2:9.4f}{100*I2/cap:7.1f}%")
    print("Detectors in the table: A4 (n=3), V4 (n=4), AGL(1,8) (n=7);"
          f" law values {detector_info(3):.4f}, {detector_info(4):.4f}, {detector_info(7):.4f}")


# ---------------------------------------------------------------------------
# 7. Pair-detector formula
# ---------------------------------------------------------------------------


def pair_detector_info(n: int) -> float:
    """delta_2(n) = log2 n - 2(n-1)/n^2 log2(n-1) - ((n-1)/n)^2 H_n."""
    if n == 2:
        Hn = 0.0
    else:
        Hn = 1 / (n - 1) * log2(n - 1) + (n - 2) / (n - 1) * log2((n - 1) ** 2 / (n - 2))
    return log2(n) - 2 * (n - 1) / n ** 2 * log2(n - 1) - ((n - 1) / n) ** 2 * Hn


def section_pair() -> None:
    print("\n" + "=" * 74)
    print("Pair-detector formula delta_2(n) vs exact semiprime channels")
    print("=" * 74)
    a4 = agl_channels(4)
    a8 = agl_channels(8)
    v4 = channels([(0, 1, 2, 3), (1, 0, 3, 2), (2, 3, 0, 1), (3, 2, 1, 0)])
    print(f"n=3  A4:        exact {a4['I2']:.6f}  (log2 3 - 10/9 = {log2(3)-10/9:.6f})"
          f"   delta_2 {pair_detector_info(3):.6f}")
    print(f"n=4  V4:        exact {v4[3]:.6f}   delta_2 {pair_detector_info(4):.6f}")
    print(f"n=7  AGL(1,8):  exact {a8['I2']:.6f}   delta_2 {pair_detector_info(7):.6f}")
    # n = 31: AGL(1,32), all 992^2 pairs, using precomputed types and cosets
    G32, c32 = affine_group(GF(32))
    tid = {t: i for i, t in enumerate(sorted({cycle_type(g) for g in G32}))}
    lab = [(c32[g], tid[cycle_type(g)]) for g in G32]
    joint: Counter = Counter()
    types: Counter = Counter()
    for (ex, tx) in lab:
        for (ey, ty) in lab:
            key = (min(tx, ty), max(tx, ty))
            types[key] += 1
            joint[((ex + ey) % 31, key)] += 1
    N = len(lab) ** 2
    Hc = log2(31)
    Ht = -sum(v / N * log2(v / N) for v in types.values())
    Hj = -sum(v / N * log2(v / N) for v in joint.values())
    print(f"n=31 AGL(1,32): exact {Hc + Ht - Hj:.7f}   delta_2 {pair_detector_info(31):.7f}")
    print(f"A4 pairing loss I1 - I2 = {a4['I1'] - a4['I2']:.6f}  (4/9 = {4/9:.6f})")
    print("\n  n   delta(n)    delta_2(n)   n*delta_2/delta")
    for n in [3, 7, 31, 127, 8191, 131071]:
        print(f"{n:6d} {detector_info(n):10.6f} {pair_detector_info(n):12.8f} "
              f"{n*pair_detector_info(n)/detector_info(n):10.4f}")


# ---------------------------------------------------------------------------
# 8. Totient formula for AGL(1, q)
# ---------------------------------------------------------------------------


def phi(d: int) -> int:
    return sum(1 for k in range(1, d + 1) if gcd(k, d) == 1)


def totient_formula(q: int) -> float:
    n = q - 1
    loss = sum(phi(d) / n * log2(phi(d)) for d in range(2, n + 1) if n % d == 0)
    return log2(n) - loss


def section_totient() -> None:
    print("\n" + "=" * 74)
    print("Resolved-quotient (totient) formula for the prime channel of AGL(1,q)")
    print("  I1 = log2(q-1) - sum_{d | q-1} (phi(d)/(q-1)) log2 phi(d)")
    print("=" * 74)
    for q in [3, 4, 5, 7, 8, 9, 11, 13, 16, 17, 19, 23, 25, 27, 32]:
        ch = agl_channels(q, semiprime=False)
        tag = "  detector (q-1 prime)" if is_prime(q - 1) else ""
        print(f"q={q:3d} |G|={int(ch['order']):4d} cap={ch['cap']:.4f}  I1={ch['I1']:.6f}"
              f"  formula={totient_formula(q):.6f}{tag}")


if __name__ == "__main__":
    section_agl8()
    section_detector()
    section_table()
    section_pair()
    section_totient()
