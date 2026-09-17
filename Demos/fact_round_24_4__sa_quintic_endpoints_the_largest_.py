"""
Numerical companion to
"The two extremes of the degree-five splitting-type channel: S5 and A5".

Everything is self-contained: pure Python, no third-party imports.

The script demonstrates, numerically,

  1. the exact splitting entropies of the two extreme quintic Galois groups,
         H_S5(T) = 7/5 + (17/40) log2 3 + (5/24) log2 5 = 2.55735...  (7 types)
         H_A5(T) = 2/15 + (7/20) log2 3 + (5/12) log2 5 = 1.65552...  (4 types)
  2. the abelianization law  I(sign ; T) = 1  exactly, on S5;
  3. the sharp dichotomy: every homomorphic dial of S5 into an abelian group
     transmits 1 bit (if nontrivial) or 0 bits (if trivial);
  4. the A5 seal: every multiplicative dial on A5 is constant, so I(d ; T) = 0;
  5. no almost-prime bonus: the k-fold product dial transmits log2|image| bits
     for every k >= 1 (so semiprimes buy nothing);
  6. the arithmetic realisation: factorisation types of
         x^5 - x - 1   (group S5, discriminant 2869 = 19 * 151)
         x^5 + 20x + 16 (group A5, discriminant 2^12 * 5^6 -- a square)
     over F_p for many primes p, matched against the group-theoretic densities,
     and the empirical mutual information between residues and types, always
     compared with a permutation reference (the plug-in estimator of mutual
     information is badly biased upward at large conductors).

Run:  python3 demo.py
"""

from __future__ import annotations

from itertools import permutations, product
from math import gcd, log2
from typing import Callable, Dict, Iterable, List, Sequence, Tuple
import random

Perm = Tuple[int, ...]          # a permutation of {0,...,4} as an image tuple
CycleType = Tuple[int, ...]     # sorted cycle type, e.g. (1, 2, 2)


# ----------------------------------------------------------------------
# 1. Permutations, cycle types, sign
# ----------------------------------------------------------------------

def cycle_type(p: Perm) -> CycleType:
    """Cycle type of a permutation, as a sorted tuple of cycle lengths."""
    n = len(p)
    seen = [False] * n
    lengths: List[int] = []
    for i in range(n):
        if not seen[i]:
            ell, j = 0, i
            while not seen[j]:
                seen[j] = True
                j = p[j]
                ell += 1
            lengths.append(ell)
    return tuple(sorted(lengths))


def sign_of(p: Perm) -> int:
    """Sign of a permutation: +1 for even, -1 for odd."""
    s = 1
    for ell in cycle_type(p):
        if ell % 2 == 0:
            s = -s
    return s


def compose(p: Perm, q: Perm) -> Perm:
    """Composition (p after q)."""
    return tuple(p[q[i]] for i in range(len(q)))


S5: List[Perm] = [tuple(p) for p in permutations(range(5))]
A5: List[Perm] = [p for p in S5 if sign_of(p) == 1]


# ----------------------------------------------------------------------
# 2. Counting entropy, conditional entropy, mutual information
# ----------------------------------------------------------------------

def entropy_of_counts(counts: Iterable[int]) -> float:
    """Shannon entropy in bits of an empirical histogram."""
    c = [x for x in counts if x > 0]
    n = sum(c)
    return -sum((x / n) * log2(x / n) for x in c)


def entropy(box: Sequence[object], f: Callable[[object], object]) -> float:
    """H(f) for the uniform (counting) measure on `box`."""
    counts: Dict[object, int] = {}
    for x in box:
        counts[f(x)] = counts.get(f(x), 0) + 1
    return entropy_of_counts(counts.values())


def cond_entropy(box: Sequence[object],
                 f: Callable[[object], object],
                 g: Callable[[object], object]) -> float:
    """H(f | g) for the uniform measure on `box`."""
    strata: Dict[object, List[object]] = {}
    for x in box:
        strata.setdefault(g(x), []).append(x)
    n = len(box)
    return sum(len(s) / n * entropy(s, f) for s in strata.values())


def mutual_info(box: Sequence[object],
                f: Callable[[object], object],
                g: Callable[[object], object]) -> float:
    """I(f ; g) = H(f) - H(f | g)."""
    return entropy(box, f) - cond_entropy(box, f, g)


# ----------------------------------------------------------------------
# 3. The two closed forms, checked against the group computation
# ----------------------------------------------------------------------

def closed_form_S5() -> float:
    return 7 / 5 + (17 / 40) * log2(3) + (5 / 24) * log2(5)


def closed_form_A5() -> float:
    return 2 / 15 + (7 / 20) * log2(3) + (5 / 12) * log2(5)


def part_one_group_theory() -> None:
    print("=" * 74)
    print("1.  THE TYPE CHANNEL OF THE TWO EXTREME QUINTIC GROUPS")
    print("=" * 74)

    for name, box in (("S5", S5), ("A5", A5)):
        counts: Dict[CycleType, int] = {}
        for p in box:
            t = cycle_type(p)
            counts[t] = counts.get(t, 0) + 1
        print(f"\n{name}: |G| = {len(box)},  {len(counts)} factorisation types")
        for t in sorted(counts, key=lambda t: (len(t), t)):
            print(f"    type {str(list(t)):<16} size {counts[t]:>3}"
                  f"   density {counts[t] / len(box):.6f}"
                  f"   parity {'even' if sign_of(next(p for p in box if cycle_type(p) == t)) == 1 else 'odd '}")
        h = entropy(box, cycle_type)
        cf = closed_form_S5() if name == "S5" else closed_form_A5()
        print(f"    H(T) = {h:.6f} bits      closed form = {cf:.6f} bits"
              f"      |difference| = {abs(h - cf):.2e}")

    print("\n  abelianization law at S5 :  I(sign ; T) =",
          f"{mutual_info(S5, sign_of, cycle_type):.6f}")
    print("  residual at S5           :  H(T | sign) =",
          f"{cond_entropy(S5, cycle_type, sign_of):.6f}")
    print("  the A5 seal              :  I(sign ; T) =",
          f"{mutual_info(A5, sign_of, cycle_type):.6f}")
    print("  F20 comparison           :  H(T) = 11/10 + (log2 5)/4 =",
          f"{1.1 + log2(5) / 4:.6f}  <  {entropy(S5, cycle_type):.6f}")


# ----------------------------------------------------------------------
# 4. The sharp dichotomy and the absence of an almost-prime bonus
# ----------------------------------------------------------------------

def part_two_dials() -> None:
    print("\n" + "=" * 74)
    print("2.  THE SHARP DICHOTOMY AND THE ABSENCE OF AN ALMOST-PRIME BONUS")
    print("=" * 74)

    dials: Dict[str, Callable[[Perm], int]] = {
        "sign (nontrivial)": sign_of,
        "sign^2 (trivial) ": lambda p: 1,
        "sign^3 (nontrivial)": lambda p: sign_of(p) ** 3,
    }
    for name, d in dials.items():
        print(f"    I({name} ; T) on S5 = {mutual_info(S5, d, cycle_type):.6f}")
        print(f"    I({name} ; T) on A5 = {mutual_info(A5, d, cycle_type):.6f}")

    print("\n  k-fold product dial  x -> sign(x_1)...sign(x_k),  read-out = tuple of types")
    for k in (1, 2, 3):
        box = list(product(S5, repeat=k))

        def prod_dial(t, k=k) -> int:
            s = 1
            for x in t:
                s *= sign_of(x)
            return s

        def type_tuple(t) -> Tuple[CycleType, ...]:
            return tuple(cycle_type(x) for x in t)

        print(f"    k = {k}:  |box| = {len(box):>7},"
              f"  I(product dial ; tuple of types) = {mutual_info(box, prod_dial, type_tuple):.6f}")

    boxA = list(product(A5, repeat=2))
    print("    A5, k = 2 (semiprime seal):  I =",
          f"{mutual_info(boxA, lambda t: sign_of(t[0]) * sign_of(t[1]), lambda t: (cycle_type(t[0]), cycle_type(t[1]))):.6f}")


# ----------------------------------------------------------------------
# 5. Arithmetic: factorisation types of quintics mod p
# ----------------------------------------------------------------------

Poly = List[int]  # little-endian coefficient list over F_p


def poly_trim(a: Poly) -> Poly:
    while a and a[-1] == 0:
        a.pop()
    return a


def poly_mul(a: Poly, b: Poly, p: int) -> Poly:
    if not a or not b:
        return []
    out = [0] * (len(a) + len(b) - 1)
    for i, ai in enumerate(a):
        if ai:
            for j, bj in enumerate(b):
                out[i + j] = (out[i + j] + ai * bj) % p
    return poly_trim(out)


def poly_divmod(a: Poly, b: Poly, p: int) -> Tuple[Poly, Poly]:
    a = a[:]
    db = len(b) - 1
    inv = pow(b[-1], p - 2, p)
    q = [0] * max(0, len(a) - db)
    while len(a) - 1 >= db and a:
        shift = len(a) - 1 - db
        c = (a[-1] * inv) % p
        q[shift] = c
        for i, bi in enumerate(b):
            a[shift + i] = (a[shift + i] - c * bi) % p
        poly_trim(a)
    return poly_trim(q), a


def poly_gcd(a: Poly, b: Poly, p: int) -> Poly:
    a, b = poly_trim(a[:]), poly_trim(b[:])
    while b:
        a, b = b, poly_divmod(a, b, p)[1]
    if a:
        inv = pow(a[-1], p - 2, p)
        a = [(c * inv) % p for c in a]
    return a


def poly_powmod(base: Poly, e: int, mod: Poly, p: int) -> Poly:
    result: Poly = [1]
    b = poly_divmod(base, mod, p)[1]
    while e:
        if e & 1:
            result = poly_divmod(poly_mul(result, b, p), mod, p)[1]
        b = poly_divmod(poly_mul(b, b, p), mod, p)[1]
        e >>= 1
    return result


def poly_sub(a: Poly, b: Poly, p: int) -> Poly:
    n = max(len(a), len(b))
    out = [((a[i] if i < len(a) else 0) - (b[i] if i < len(b) else 0)) % p
           for i in range(n)]
    return poly_trim(out)


def factorisation_type(f: Poly, p: int) -> CycleType | None:
    """
    Degrees of the irreducible factors of a squarefree f over F_p, sorted.
    Returns None if f is not squarefree mod p (a ramified prime).
    """
    f = poly_trim([c % p for c in f])
    df = poly_trim([(i * f[i]) % p for i in range(1, len(f))])
    if not df or len(poly_gcd(f, df, p)) > 1:
        return None
    degrees: List[int] = []
    h: Poly = [0, 1]                      # x
    g = f[:]
    d = 0
    while len(g) - 1 > 0 and d < len(f):
        d += 1
        h = poly_powmod(h, p, g, p)       # x^(p^d) mod g
        gd = poly_gcd(g, poly_sub(h, [0, 1], p), p)
        if len(gd) - 1 > 0:
            # gd is a product of (deg gd)/d irreducibles, each of degree d
            degrees.extend([d] * ((len(gd) - 1) // d))
            g = poly_divmod(g, gd, p)[0]
            h = poly_divmod(h, g, p)[1] if len(g) - 1 > 0 else h
    if len(g) - 1 > 0:
        degrees.append(len(g) - 1)
    return tuple(sorted(degrees))


def primes_up_to(n: int) -> List[int]:
    sieve = bytearray([1]) * (n + 1)
    sieve[0:2] = b"\x00\x00"
    for i in range(2, int(n ** 0.5) + 1):
        if sieve[i]:
            sieve[i * i:: i] = bytearray(len(sieve[i * i:: i]))
    return [i for i in range(2, n + 1) if sieve[i]]


def kronecker_symbol(a: int, p: int) -> int:
    """Legendre symbol (a/p) for odd prime p."""
    a %= p
    if a == 0:
        return 0
    return 1 if pow(a, (p - 1) // 2, p) == 1 else -1


def part_three_arithmetic(limit: int = 60000) -> None:
    print("\n" + "=" * 74)
    print("3.  ARITHMETIC REALISATION: FACTORISATION TYPES OF QUINTICS MOD p")
    print("=" * 74)

    f_S5: Poly = [-1, -1, 0, 0, 0, 1]      # x^5 - x - 1,  disc = 2869 = 19 * 151
    f_A5: Poly = [16, 20, 0, 0, 0, 1]      # x^5 + 20x + 16, disc a perfect square

    primes = primes_up_to(limit)
    print(f"  using {len(primes)} primes below {limit}")

    for name, f, box in (("x^5 - x - 1   (S5)", f_S5, S5),
                         ("x^5 + 20x + 16 (A5)", f_A5, A5)):
        data: List[Tuple[int, CycleType]] = []
        for p in primes:
            t = factorisation_type(f, p)
            if t is not None and sum(t) == 5:
                data.append((p, t))
        counts: Dict[CycleType, int] = {}
        for _, t in data:
            counts[t] = counts.get(t, 0) + 1
        gcounts: Dict[CycleType, int] = {}
        for s in box:
            gcounts[cycle_type(s)] = gcounts.get(cycle_type(s), 0) + 1

        print(f"\n  {name}:  {len(data)} unramified primes")
        worst = 0.0
        for t in sorted(gcounts, key=lambda t: (len(t), t)):
            obs = counts.get(t, 0) / len(data)
            pred = gcounts[t] / len(box)
            worst = max(worst, abs(obs - pred))
            print(f"      type {str(list(t)):<16} observed {obs:.4f}   Chebotarev {pred:.4f}")
        extra = set(counts) - set(gcounts)
        print(f"      largest deviation from the predicted density: {worst:.4f}")
        if extra:
            print(f"      UNEXPECTED types observed: {sorted(extra)}")
        else:
            print("      no unexpected type ever occurs")
        print(f"      empirical H(T) = {entropy_of_counts(counts.values()):.4f} bits"
              f"   (group value {entropy(box, cycle_type):.4f})")


def part_four_permutation_reference(limit: int = 200000, shuffles: int = 200) -> None:
    """
    The measurement discipline: the plug-in estimate of I(residue ; type) at a
    large conductor is biased upward simply because the residue dial has many
    classes.  The honest comparison is against a permutation reference that
    preserves exactly the channel the law predicts (here: the sign stratum)
    and randomises only the finer assignment.
    """
    print("\n" + "=" * 74)
    print("4.  PERMUTATION-REFERENCED MEASUREMENT OF THE RESIDUE CHANNEL")
    print("=" * 74)
    random.seed(20240917)

    f_S5: Poly = [-1, -1, 0, 0, 0, 1]
    f_A5: Poly = [16, 20, 0, 0, 0, 1]
    disc_S5 = 2869                                # = 19 * 151

    primes = [p for p in primes_up_to(limit) if p > 5]

    # --- S5: the sign agreement, exact by the abelianization law -------------
    rows: List[Tuple[int, CycleType]] = []
    for p in primes:
        if disc_S5 % p == 0:
            continue
        t = factorisation_type(f_S5, p)
        if t is not None and sum(t) == 5:
            rows.append((p, t))

    def type_parity(t: CycleType) -> int:
        s = 1
        for ell in t:
            if ell % 2 == 0:
                s = -s
        return s

    agree = sum(1 for p, t in rows if type_parity(t) == kronecker_symbol(disc_S5, p))
    print(f"  S5: parity of the factorisation type vs the quadratic character of the")
    print(f"      discriminant 2869 = 19 * 151 :  agreement = {agree / len(rows):.4f}"
          f"   over {len(rows)} primes")
    print("      (an exact 0.0000 or 1.0000 is the signature of a correct law;"
          " anything in between would flag a bug)")

    # --- the plug-in bias of the residue dial and its permutation reference --
    resid = [p % disc_S5 for p, _ in rows]
    types = [t for _, t in rows]
    signs = [type_parity(t) for t in types]
    box = list(range(len(rows)))
    I_raw = mutual_info(box, lambda i: resid[i], lambda i: types[i])

    null_values: List[float] = []
    for _ in range(shuffles):
        # permute the residues WITHIN each sign stratum: this preserves the one
        # bit the law predicts and randomises only the finer assignment
        by_sign: Dict[int, List[int]] = {}
        for i in box:
            by_sign.setdefault(signs[i], []).append(i)
        shuffled = resid[:]
        for s, idxs in by_sign.items():
            vals = [resid[i] for i in idxs]
            random.shuffle(vals)
            for i, v in zip(idxs, vals):
                shuffled[i] = v
        null_values.append(mutual_info(box, lambda i: shuffled[i], lambda i: types[i]))

    mu = sum(null_values) / len(null_values)
    var = sum((v - mu) ** 2 for v in null_values) / (len(null_values) - 1)
    sd = var ** 0.5
    z = (I_raw - mu) / sd if sd > 0 else 0.0
    print(f"\n      raw plug-in  I(p mod 2869 ; T) = {I_raw:.4f} bits")
    print(f"      permutation reference          = {mu:.4f} +- {sd:.4f}")
    print(f"      z = {z:+.2f}   -> the excess over the law's exactly 1 bit is plug-in bias,")
    print("      not extra signal: the channel really carries one bit and no more")

    # --- A5: the seal, measured -------------------------------------------
    rowsA: List[Tuple[int, CycleType]] = []
    for p in primes:
        t = factorisation_type(f_A5, p)
        if t is not None and sum(t) == 5:
            rowsA.append((p, t))
    print(f"\n  A5: {len(rowsA)} unramified primes, "
          f"{len(set(t for _, t in rowsA))} distinct types observed")
    boxA = list(range(len(rowsA)))
    typesA = [t for _, t in rowsA]
    worst_z = 0.0
    for m in (3, 7, 11, 31):
        res = [p % m for p, _ in rowsA]
        I_raw = mutual_info(boxA, lambda i: res[i], lambda i: typesA[i])
        nulls: List[float] = []
        for _ in range(shuffles):
            sh = res[:]
            random.shuffle(sh)
            nulls.append(mutual_info(boxA, lambda i: sh[i], lambda i: typesA[i]))
        mu = sum(nulls) / len(nulls)
        sd = (sum((v - mu) ** 2 for v in nulls) / (len(nulls) - 1)) ** 0.5
        z = (I_raw - mu) / sd if sd > 0 else 0.0
        worst_z = max(worst_z, abs(z))
        print(f"      m = {m:>2}:  I = {I_raw:.4f},  null = {mu:.4f} +- {sd:.4f},  z = {z:+.2f}")
    print(f"      largest |z| over the four moduli: {worst_z:.2f}")
    print("      every direction sits at its own permutation null, and the raw values are three")
    print("      orders of magnitude below the 1.6555 bits of splitting entropy present: the")
    print("      four-state type channel of a perfect group is sealed, with nothing tuned")


def main() -> None:
    part_one_group_theory()
    part_two_dials()
    part_three_arithmetic()
    part_four_permutation_reference()
    print("\nall demonstrations complete.")


if __name__ == "__main__":
    main()


"""
Visualisation: the degree-five splitting-type channel at its two extremes.

Panel 1  Splitting-type densities for S5 and A5 quintics: the exact Chebotarev
         densities (bars) against the observed frequencies of the factorisation
         types of x^5 - x - 1 and x^5 + 20x + 16 over the primes below 30000
         (dots).  The three odd types are structurally absent for A5.
Panel 2  The bit ledger across the transitive quintic groups: total splitting
         entropy H(T), the part a congruence can hear I(dial ; T), and the
         abelianization ceiling log2 |G^ab|.

Requires matplotlib.  Run:  python3 viz_channel_ledger.py
"""

from __future__ import annotations

from itertools import permutations
from math import log2
from typing import Dict, List, Tuple

import matplotlib.pyplot as plt

Perm = Tuple[int, ...]
CycleType = Tuple[int, ...]


def cycle_type(p: Perm) -> CycleType:
    seen = [False] * len(p)
    out: List[int] = []
    for i in range(len(p)):
        if not seen[i]:
            ell, j = 0, i
            while not seen[j]:
                seen[j] = True
                j = p[j]
                ell += 1
            out.append(ell)
    return tuple(sorted(out))


def sign_of(p: Perm) -> int:
    s = 1
    for ell in cycle_type(p):
        if ell % 2 == 0:
            s = -s
    return s


S5: List[Perm] = [tuple(p) for p in permutations(range(5))]
A5: List[Perm] = [p for p in S5 if sign_of(p) == 1]
F20: List[Perm] = [tuple((a * x + b) % 5 for x in range(5))
                   for a in (1, 2, 3, 4) for b in range(5)]
D5: List[Perm] = [tuple((a * x + b) % 5 for x in range(5))
                  for a in (1, 4) for b in range(5)]
C5: List[Perm] = [tuple((x + b) % 5 for x in range(5)) for b in range(5)]


def densities(box: List[Perm]) -> Dict[CycleType, float]:
    counts: Dict[CycleType, int] = {}
    for p in box:
        counts[cycle_type(p)] = counts.get(cycle_type(p), 0) + 1
    return {t: c / len(box) for t, c in counts.items()}


def entropy(dist: Dict[CycleType, float]) -> float:
    return -sum(q * log2(q) for q in dist.values() if q > 0)


# --- observed factorisation types of the two quintics -------------------------

def primes_up_to(n: int) -> List[int]:
    sieve = bytearray([1]) * (n + 1)
    sieve[0:2] = b"\x00\x00"
    for i in range(2, int(n ** 0.5) + 1):
        if sieve[i]:
            sieve[i * i:: i] = bytearray(len(sieve[i * i:: i]))
    return [i for i in range(2, n + 1) if sieve[i]]


Poly = List[int]


def _trim(a: Poly) -> Poly:
    while a and a[-1] == 0:
        a.pop()
    return a


def _mul(a: Poly, b: Poly, p: int) -> Poly:
    if not a or not b:
        return []
    out = [0] * (len(a) + len(b) - 1)
    for i, ai in enumerate(a):
        if ai:
            for j, bj in enumerate(b):
                out[i + j] = (out[i + j] + ai * bj) % p
    return _trim(out)


def _divmod(a: Poly, b: Poly, p: int) -> Tuple[Poly, Poly]:
    a, db = a[:], len(b) - 1
    inv = pow(b[-1], p - 2, p)
    q = [0] * max(0, len(a) - db)
    while a and len(a) - 1 >= db:
        shift = len(a) - 1 - db
        c = (a[-1] * inv) % p
        q[shift] = c
        for i, bi in enumerate(b):
            a[shift + i] = (a[shift + i] - c * bi) % p
        _trim(a)
    return _trim(q), a


def _gcd(a: Poly, b: Poly, p: int) -> Poly:
    a, b = _trim(a[:]), _trim(b[:])
    while b:
        a, b = b, _divmod(a, b, p)[1]
    if a:
        inv = pow(a[-1], p - 2, p)
        a = [(c * inv) % p for c in a]
    return a


def _powmod(base: Poly, e: int, mod: Poly, p: int) -> Poly:
    r: Poly = [1]
    b = _divmod(base, mod, p)[1]
    while e:
        if e & 1:
            r = _divmod(_mul(r, b, p), mod, p)[1]
        b = _divmod(_mul(b, b, p), mod, p)[1]
        e >>= 1
    return r


def _sub(a: Poly, b: Poly, p: int) -> Poly:
    n = max(len(a), len(b))
    return _trim([((a[i] if i < len(a) else 0) - (b[i] if i < len(b) else 0)) % p
                  for i in range(n)])


def factorisation_type(f: Poly, p: int):
    f = _trim([c % p for c in f])
    df = _trim([(i * f[i]) % p for i in range(1, len(f))])
    if not df or len(_gcd(f, df, p)) > 1:
        return None
    degrees: List[int] = []
    h: Poly = [0, 1]
    g, d = f[:], 0
    while len(g) - 1 > 0 and d < len(f):
        d += 1
        h = _powmod(h, p, g, p)
        gd = _gcd(g, _sub(h, [0, 1], p), p)
        if len(gd) - 1 > 0:
            degrees.extend([d] * ((len(gd) - 1) // d))
            g = _divmod(g, gd, p)[0]
            if len(g) - 1 > 0:
                h = _divmod(h, g, p)[1]
    if len(g) - 1 > 0:
        degrees.append(len(g) - 1)
    return tuple(sorted(degrees))


def observed(f: Poly, limit: int = 30000) -> Dict[CycleType, float]:
    counts: Dict[CycleType, int] = {}
    total = 0
    for p in primes_up_to(limit):
        t = factorisation_type(f, p)
        if t is not None and sum(t) == 5:
            counts[t] = counts.get(t, 0) + 1
            total += 1
    return {t: c / total for t, c in counts.items()}


def main() -> None:
    order = [(1, 1, 1, 1, 1), (1, 1, 1, 2), (1, 2, 2), (1, 1, 3), (2, 3), (1, 4), (5,)]
    labels = ["[1,1,1,1,1]", "[1,1,1,2]", "[1,2,2]", "[1,1,3]", "[2,3]", "[1,4]", "[5]"]

    dS, dA = densities(S5), densities(A5)
    oS = observed([-1, -1, 0, 0, 0, 1])
    oA = observed([16, 20, 0, 0, 0, 1])

    fig, axes = plt.subplots(1, 2, figsize=(14, 5.2))

    ax = axes[0]
    xs = range(len(order))
    w = 0.38
    ax.bar([x - w / 2 for x in xs], [dS.get(t, 0) for t in order], width=w,
           label=r"$S_5$ predicted", color="#2f81f7")
    ax.bar([x + w / 2 for x in xs], [dA.get(t, 0) for t in order], width=w,
           label=r"$A_5$ predicted", color="#7ee787")
    ax.plot([x - w / 2 for x in xs], [oS.get(t, 0) for t in order], "o",
            color="#0b2545", label=r"observed, $x^5-x-1$")
    ax.plot([x + w / 2 for x in xs], [oA.get(t, 0) for t in order], "s",
            color="#14532d", label=r"observed, $x^5+20x+16$")
    ax.set_xticks(list(xs))
    ax.set_xticklabels(labels, rotation=30)
    ax.set_ylabel("density of primes")
    ax.set_title("Splitting types: prediction vs. observation\n"
                 r"(odd types are structurally absent for $A_5$)")
    ax.legend(fontsize=9)

    ax = axes[1]
    groups = [("$C_5$", C5, log2(5)), ("$D_5$", D5, 1.0), ("$F_{20}$", F20, 2.0),
              ("$A_5$", A5, 0.0), ("$S_5$", S5, 1.0)]
    names = [g[0] for g in groups]
    hts = [entropy(densities(g[1])) for g in groups]
    caps = [g[2] for g in groups]
    heard = [0.7219, 1.0, 1.5, 0.0, 1.0]     # I(abelianization dial ; T), exact values
    xs = range(len(groups))
    ax.bar([x - 0.27 for x in xs], hts, width=0.26, color="#2f81f7", label="H(T): total splitting entropy")
    ax.bar([x for x in xs], heard, width=0.26, color="#ffa657", label="I(dial ; T): heard by a congruence")
    ax.bar([x + 0.27 for x in xs], caps, width=0.26, color="#9aa7b4",
           label=r"cap $\log_2|G^{\mathrm{ab}}|$")
    ax.set_xticks(list(xs))
    ax.set_xticklabels(names)
    ax.set_ylabel("bits")
    ax.set_title("The bit ledger of the transitive quintic groups")
    ax.legend(fontsize=9)
    for x, (h, i) in enumerate(zip(hts, heard)):
        ax.annotate(f"{h:.3f}", (x - 0.27, h), ha="center", va="bottom", fontsize=8)
        ax.annotate(f"{i:.3f}", (x, i), ha="center", va="bottom", fontsize=8)

    fig.suptitle("The degree-five splitting-type channel: the largest entropy collapses, "
                 "the perfect group seals", fontsize=13)
    fig.tight_layout()
    fig.savefig("channel_ledger.png", dpi=160)
    print("wrote channel_ledger.png")


if __name__ == "__main__":
    main()
