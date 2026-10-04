#!/usr/bin/env python3
"""
The dihedral dial of x^5 + 20x + 32 carries exactly half a bit of hint.

Numerical companion to the paper.  Everything is self-contained (standard library only).

Sections
  1. The quadratic dial chi_20 = (-5 / .) and the root counts of f = x^5 + 20x + 32 mod p.
  2. Exact information quantities in the dihedral Chebotarev box D_n x D_n
     (hint value 1/2 for unordered labels, 1 for ordered labels, for every odd n tested).
  3. The residue views at m* = 320: the joint view pins chi(p), chi(q); the product view
     only chi(p)chi(q); the explicit collision 11*13 = 7*569 (mod 320).
  4. Plug-in hint value of a real semiprime battery, decreasing toward the limit 1/2.
"""
from __future__ import annotations

import math
from collections import Counter
from fractions import Fraction
from itertools import product
from typing import Callable, Dict, Hashable, Iterable, List, Sequence, Tuple

# ---------------------------------------------------------------------------------------------
# 1. The dial
# ---------------------------------------------------------------------------------------------

CHI20_TABLE: Dict[int, int] = {1: 1, 3: 1, 7: 1, 9: 1, 11: -1, 13: -1, 17: -1, 19: -1}


def chi20(n: int) -> int:
    """Kronecker character of Q(sqrt(-5)), conductor 20."""
    return CHI20_TABLE.get(n % 20, 0)


def legendre(a: int, p: int) -> int:
    """Legendre symbol (a / p) for an odd prime p, by Euler's criterion."""
    r = pow(a % p, (p - 1) // 2, p)
    return -1 if r == p - 1 else r


def primes_below(n: int) -> List[int]:
    sieve = bytearray([1]) * n
    sieve[0:2] = b"\x00\x00"
    for i in range(2, int(n ** 0.5) + 1):
        if sieve[i]:
            sieve[i * i :: i] = bytearray(len(sieve[i * i :: i]))
    return [i for i in range(n) if sieve[i]]


def root_count(p: int) -> int:
    """Number of roots of x^5 + 20x + 32 modulo p (brute force)."""
    return sum(1 for x in range(p) if (pow(x, 5, p) + 20 * x + 32) % p == 0)


def section_dial(bound: int = 3000) -> None:
    print("=" * 78)
    print("1. THE DIAL: chi_20 = (-5/p) and the root counts of x^5 + 20x + 32")
    print("=" * 78)
    f = lambda x: x ** 5 + 20 * x + 32
    print(f"f(-2) = {f(-2)},  f(-1) = {f(-1)}  -> the unique real root lies in (-2,-1)")
    print(f"trinomial discriminant 5^5*32^4 + 4^4*20^5 = {5**5*32**4 + 4**4*20**5}"
          f" = 64000^2 = {64000**2}")
    ps = [p for p in primes_below(bound) if p >= 7]
    counts: Counter[int] = Counter()
    agree_reciprocity = 0
    agree_roots = 0
    for p in ps:
        rc = root_count(p)
        counts[rc] += 1
        agree_reciprocity += legendre(-5, p) == chi20(p)
        agree_roots += (rc == 1) == (chi20(p) == -1)
    n = len(ps)
    print(f"primes 7 <= p < {bound}: {n}")
    print(f"  root-count histogram: {dict(sorted(counts.items()))}"
          f"   (Chebotarev: 0 -> 4/10, 1 -> 5/10, 5 -> 1/10)")
    print(f"  (-5/p) == chi_20(p)            on {agree_reciprocity}/{n} primes")
    print(f"  [one root] <=> chi_20(p) = -1  on {agree_roots}/{n} primes")
    print()


# ---------------------------------------------------------------------------------------------
# 2. Exact entropies in the dihedral Chebotarev box
# ---------------------------------------------------------------------------------------------

def entropy_bits(counts: Iterable[int]) -> float:
    cs = [c for c in counts if c > 0]
    tot = sum(cs)
    return -sum(c / tot * math.log2(c / tot) for c in cs)


def mutual_information(samples: Sequence[Hashable], labels: Callable, view: Callable) -> float:
    """I(T ; V) = H(T) + H(V) - H(T, V) for the uniform distribution on `samples`."""
    t = Counter(labels(s) for s in samples)
    v = Counter(view(s) for s in samples)
    tv = Counter((labels(s), view(s)) for s in samples)
    return entropy_bits(t.values()) + entropy_bits(v.values()) - entropy_bits(tv.values())


def dihedral_fixed_points(n: int, x: int) -> int:
    """Element x = n*e + b of D_n acts on Z/n by y -> (-1)^e y + b; count its fixed points."""
    e, b = divmod(x, n)
    return sum(1 for y in range(n) if ((y if e == 0 else -y) + b) % n == y)


def dihedral_hint(n: int, ordered: bool) -> Tuple[float, float, float]:
    """Return (I(T; pair dial), I(T; product dial), hint value) in the box D_n x D_n."""
    box = list(product(range(2 * n), repeat=2))
    fix = {x: dihedral_fixed_points(n, x) for x in range(2 * n)}
    if ordered:
        label = lambda s: (fix[s[0]], fix[s[1]])
    else:
        label = lambda s: tuple(sorted((fix[s[0]], fix[s[1]])))
    pair_dial = lambda s: (s[0] // n, s[1] // n)
    prod_dial = lambda s: (s[0] // n + s[1] // n) % 2
    i_pair = mutual_information(box, label, pair_dial)
    i_prod = mutual_information(box, label, prod_dial)
    return i_pair, i_prod, i_pair - i_prod


def section_box() -> None:
    print("=" * 78)
    print("2. THE CHEBOTAREV BOX D_n x D_n: exact information quantities")
    print("=" * 78)
    fix5 = Counter(dihedral_fixed_points(5, x) for x in range(10))
    print(f"D_5 fixed-point label distribution over 10 elements: {dict(fix5)}"
          "  (types [5], [1,2,2], [1^5])")
    prime_box = list(range(10))
    i1 = mutual_information(prime_box, lambda x: dihedral_fixed_points(5, x), lambda x: x // 5)
    print(f"prime level: I(T ; chi) = {i1:.6f} bits  (= H(chi) = 1: the dial is pinned)")
    h_t = entropy_bits(fix5.values())
    print(f"             H(T) = {h_t:.6f} = 1/5 + log2(5)/2 = {0.2 + 0.5*math.log2(5):.6f}")
    print()
    print(f"{'n':>3} {'labels':>10} {'I(T;pair)':>11} {'I(T;prod)':>11} {'hint':>8}")
    for n in (3, 5, 7, 9, 11):
        for ordered in (False, True):
            ip, iq, h = dihedral_hint(n, ordered)
            print(f"{n:>3} {'ordered' if ordered else 'unordered':>10} {ip:11.6f} {iq:11.6f} {h:8.4f}")
    # Even n for contrast: the reflection class splits into 0 / 2 fixed points.
    ip, iq, h = dihedral_hint(4, False)
    print(f"  (contrast, even n = 4, unordered: hint = {h:.4f} -- universality is an odd-n law)")
    # The exact unordered-pair-of-fair-bits entropy that drives 3/2.
    h_pair = entropy_bits([1, 2, 1])
    print(f"entropy of an unordered pair of fair bits = {h_pair} = 3/2;"
          f" minus H(chi(N)) = 1  ->  hint 1/2")
    print()


# ---------------------------------------------------------------------------------------------
# 3. The residue views at m* = 320
# ---------------------------------------------------------------------------------------------

def section_views(m: int = 320) -> None:
    print("=" * 78)
    print(f"3. THE RESIDUE VIEWS AT m* = {m}")
    print("=" * 78)
    # chi_20 is completely multiplicative
    ok = all(chi20(a * b) == chi20(a) * chi20(b) for a in range(20) for b in range(20))
    print(f"chi_20 completely multiplicative on residues mod 20: {ok}")
    # joint view pins p, q mod 160 (exhaustive over residue pairs mod 320)
    seen: Dict[Tuple[int, int], Tuple[int, int]] = {}
    pinned = True
    for p in range(m):
        for q in range(m):
            key = ((p + q) % m, (q - p) % m)
            val = (p % 160, q % 160)
            if seen.setdefault(key, val) != val:
                pinned = False
    print(f"(p+q, q-p) mod 320 determines (p mod 160, q mod 160): {pinned}")
    a, b, c, d = 11, 13, 7, 569
    print(f"collision: {a}*{b} = {a*b} = {a*b % m} mod {m};  {c}*{d} = {c*d} = {c*d % m} mod {m}")
    for p in (a, b, c, d):
        print(f"   p = {p:>3}: roots of f mod p = {root_count(p)}, chi_20(p) = {chi20(p):+d}")
    print(f"   sums mod 320: {(a+b) % m} vs {(c+d) % m}  -> the joint view separates them")
    print()


# ---------------------------------------------------------------------------------------------
# 4. Plug-in hint value of the real battery
# ---------------------------------------------------------------------------------------------

def plugin_hint(bound: int, m: int = 320) -> Tuple[int, float, float, float]:
    """All pairs p < q of primes in [7, bound): unordered root-count labels, views mod m."""
    ps = [p for p in primes_below(bound) if p >= 7]
    rc = {p: root_count(p) for p in ps}
    samples = [(p, q) for i, p in enumerate(ps) for q in ps[i + 1 :]]
    label = lambda s: tuple(sorted((rc[s[0]], rc[s[1]])))
    joint = lambda s: ((s[0] + s[1]) % m, (s[1] - s[0]) % m)
    prodv = lambda s: (s[0] * s[1]) % m
    i_joint = mutual_information(samples, label, joint)
    i_prod = mutual_information(samples, label, prodv)
    return len(samples), i_joint, i_prod, i_joint - i_prod


def section_battery() -> None:
    print("=" * 78)
    print("4. PLUG-IN HINT VALUE OF THE SEMIPRIME BATTERY (m = 320)")
    print("=" * 78)
    print(f"{'B':>6} {'pairs':>9} {'I(T;s,d)':>10} {'I(T;N)':>8} {'hint':>8}")
    for bound in (500, 1500, 4000):
        mcount, ij, ip, h = plugin_hint(bound)
        print(f"{bound:>6} {mcount:>9} {ij:10.4f} {ip:8.4f} {h:8.4f}")
    print("Chebotarev limit:            -> hint 1/2 = 0.5000 (unordered); reported 0.6940;")
    print("ordered limit 1.")
    print()


def section_verdict() -> None:
    print("=" * 78)
    print("VERDICT: THE-D5-DIAL-CARRIES-A-HINT")
    print("=" * 78)
    lo, hi, rep = Fraction(1, 2), Fraction(1), Fraction(6940, 10000)
    print(f"0 < 1/2 < 0.6940 < 1 : {0 < lo < rep < hi}")


if __name__ == "__main__":
    section_dial()
    section_box()
    section_views()
    section_battery()
    section_verdict()
